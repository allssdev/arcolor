#include "totvs.ch"
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#define ENT (CHR(13)+CHR(10))
#define DS_MODALFRAME 128
/*/{Protheus.doc} RPCPA001
Rotina para gestão/transformação das OPs previstas em OP's firmes.
@author Fernando Bombardi (fernando.bombardi@allss.com.br)
@since 06/09/2021
@version P12
@type Function
@obs Conforme fonte original RPCPA003 - Autor: Livia Della Corte (ALL System Solutions) - Data: 11/10/2018
@see https://allss.com.br
@history 13/10/2021, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Ajustes diversos conforme retorno dos usuários.
@history 19/10/2021, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Ajuste para reabrir a tela ao término da sequência de processamento.
@history 19/10/2021, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Ajuste para query recursiva de OPs intermediarias.
@history 04/11/2021, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Ajuste para passagem do controle de arquivo para impressão da OP.
@history 10/11/2021, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Ajuste para carga de dados no quadro das OPs mesmo que o produto informado esteja em minusculo.
@history 12/11/2021, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Ajuste para alteração da numeração das OPs apenas daquelas que possuem vinculo entre si.
@history 27/07/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Revisão para adequação de chamadas de tabela em querys sem NOLOCK.
@history 30/07/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Correção de error_log.
@history 29/05/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Ajuste para preenchimento da Validade de acordo com a nova data de previsão de apontamento
@history 13/07/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Inclusão da chamada para impressão da ordem de separação RPCPR008
/*/
user function RPCPA001()
local _lRet 	:= .T.
while _lRet
	if !ExecRotina()
		_lRet 	:= .F.
	endif
enddo
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ ExecRotina  º Autor ³ Fernando Bombardi º Data ³10/09/2021 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Rotina para montagem de formulario da Gestão de Ordens .   º±±
±±º          ³ de Produção.                                               º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ExecRotina()
local _nOpI      := 0
local _cCodPrd   := ""
local _cCodAux   := ""
local _nX		 := 0
local _nY		 := 0
private _aOpsI   := {}
private _lSeqOP  := .T.
private _nQtdSel := ""
private _cCodPI  := ""
private _lSair   := .F.
private _cNumIni := ""
private _cNumFim := ""
private _cImpIni := ""
private _aOpImp  := {}
private _nInput	 := 0
Private _nQtdAnt := 0
//Tela gestão de OP Intermediarias
RPCPA01T(PADR(_cCodPrd,TamSx3("C2_PRODUTO")[1]))
if !_lSair
	if Len(_aOpImp) > 0
		if Len(_aOpsI) > 0
			//Para encontrar total de OPs por OP
			for _nX := 1 to Len(_aOpImp)
				_nInput := 0
				for _nY := 1 to Len(_aOpsI)
					if AllTrim(_aOpImp[_nX,1]) == AllTrim(_aOpsI[_nY,2])
						_nInput++			
					endif
				next _nY
				if _nInput == 0
					_aOpImp[_nX,4] := 1
				else
					_aOpImp[_nX,4] := _nInput + 1
				endif
			next _nX
			//Atualiza quantidade unitária e quantidade total de OPs por OP
			for _nX := 1 to Len(_aOpImp)
				_nCount := 1
				dbSelectArea("SC2")
				SC2->(dbSetOrder(1))
				if SC2->(dbSeek(FwFilial("SC2") + AllTrim(_aOpImp[_nX,1]) + AllTrim(_aOpImp[_nX,2]) + AllTrim(_aOpImp[_nX,3])))
					RecLock("SC2",.F.)
					SC2->C2_XCTRATU := _nCount
					SC2->C2_XCTRTOT := _aOpImp[_nX,4]
					SC2->(MsUnlock())								
				endif
				for _nY := 1 to Len(_aOpsI)
					if AllTrim(_aOpImp[_nX,1]) == AllTrim(_aOpsI[_nY,2])
						_nCount++
						dbSelectArea("SC2")
						SC2->(dbSetOrder(1))
						if SC2->(dbSeek(FwFilial("SC2") + AllTrim(_aOpsI[_nY,2]) + AllTrim(_aOpsI[_nY,3]) + AllTrim(_aOpsI[_nY,4])))
							RecLock("SC2",.F.)
							SC2->C2_XCTRATU := _nCount
							SC2->C2_XCTRTOT := _aOpImp[_nX,4]
							SC2->(MsUnlock())								
						endif
					endif
				next _nY
			next _nX
		else
			for _nX := 1 to Len(_aOpImp)  
				dbSelectArea("SC2")
				SC2->(dbSetOrder(1))
				if SC2->(dbSeek(FwFilial("SC2") + AllTrim(_aOpImp[_nX,1]) + AllTrim(_aOpImp[_nX,2]) + AllTrim(_aOpImp[_nX,3])))
					RecLock("SC2",.F.)
					SC2->C2_XCTRATU := 1
					SC2->C2_XCTRTOT := 1
					SC2->(MsUnlock())								
				endif
			next _nX
		endif
	endif
	
	dbSelectArea("SB1")
	SB1->(dbGoTop())
	SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1") + UPPER(SC2->C2_PRODUTO) ,.F.,.F.))
	If !Empty(_cImpIni) .AND. SB1->B1_TIPO == 'PA' //********
	/* COMENTADO CONFORME MUDANÇA NA ABERTURA DE ORDENS DO PROCESSO PRODUTIVO
		if MsgYesNo("Ordens de Produção firmadas! Deseja Imprimir?",'[RPCPA001_101_1] - Atenção')
			//U_RPCPR001(_cNumIni,_cNumFim,_aOpImp)		
			U_RPCPR006(_cImpIni,_cNumFim,_aOpImp)
			_aOpImp 	:= {}
		endif
		*/
		/* CONFORME ALINHADO COM O PAULO NÃO SERÁ IMPRESSA A ORDEM DE SEPARAÇÃO NO PRIMEIRA FASE DO PROJETO.
		If MsgYesNo("Ordens de Seração de: "+ cNumIni +" até: " + cNumFim +" Geradas! Deseja Imprimir?",_cRotina+"_005","ALERT")
			U_RPCPR008(_cImpIni,_cNumFim)
		EndIf
		*/
		If MsgYesNo("Numeração do lote reservada. Deseja imprimir o Ordem do Rotulo?",'[RPCPA001_101_2] - Atenção')
			U_RPCPR012(_cNumIni,_cNumFim,_aOpImp)
			_aOpImp := {}
		endif
	EndIf
else
	return .F.	
endif
//Ordens de Produção Intermediarias
for _nOpI := 1 to Len(_aOpsI)
	if _lSair
		if MsgYesNo('Deseja realmente sair da rotina?' + chr(10) + chr(13) + 'Este procedimento poderá impactar ou não nas Ordens de Produção firmadas até o momento!','[RPCPA001_102] - Atenção')
			return .F.
		endif		
	endif
	if Alltrim(_cCodAux) <> Alltrim(_aOpsI[_nOpI,1]) .AND. !_aOpsI[_nOpI,8]
		_lSeqOP 	:= .F.
		 //Tela gestão de OP Intermediarias
		RPCPA01T(_aOpsI[_nOpI,1],_aOpsI)
		_cCodAux 	:= alltrim(_aOpsI[_nOpI,1])
		/*COMENTADO CONFORME MUDANÇA NA ABERTURA DE ORDENS DO PROCESSO PRODUTIVO
		if MsgYesNo("Ordens de Produção firmadas! Deseja Imprimir?",'[RPCPA001_101_2] - Atenção')
			//U_RPCPR001(_cNumIni,_cNumFim,_aOpImp)
			U_RPCPR006(_cImpIni,_cNumFim,_aOpImp)		
			_aOpImp := {}
		endif
		*/
		/* CONFORME ALINHADO COM O PAULO NÃO SERÁ IMPRESSA A ORDEM DE SEPARAÇÃO NO PRIMEIRA FASE DO PROJETO.
		If MsgYesNo("Ordens de Seração de: "+ cNumIni +" até: " + cNumFim +" Geradas! Deseja Imprimir?",_cRotina+"_005","ALERT")
			U_RPCPR008(_cImpIni,_cNumFim)
		EndIf
		*/
		If MsgYesNo("Numeração do lote reservada. Deseja imprimir o Ordem do Rotulo?",'[RPCPA001_101_2] - Atenção')
			U_RPCPR012(_cNumIni,_cNumFim,_aOpImp)
			_aOpImp := {}
		endif
	
	endif
next _nOpI
return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ RPCPA01T    º Autor ³ Fernando Bombardi º Data ³10/09/2021 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Rotina para montagem de formulario da Gestão de Ordens .   º±±
±±º          ³ de Produção.                                               º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function RPCPA01T(_cProduto,_aOpsI)
local _nX 			:= 1
private oSay1
private oSay3
private oCodProd
private oDesProd
private oGet2
private oGet4
private _cRotina 	:= "RPCPA001"
private oSay5
private oGet5
private oSay6
private oDatIni
private oSay7
private oDatEnt
private oSay8
private oObserv
private oSay9
private oQtdProd
private oGroup1
private oGroup2
private oGroup3
private oGroup4
private oButCL
private _aSize     	:= MsAdvSize()
private cCadastro  	:= "Ordem de produção"
private _cCodProd  	:= _cProduto
private _cDesProd  	:= Space(12)
private _nQtdPrd   	:= 0
private _dDatIni   	:= ddatabase
private _dDatEnt   	:= ddatabase
private _nQtdProd  	:= 0
private _nItem	   	:= 1
private _cObserv   	:= Space(200)
private _aHeaderOP 	:= {}
private _aColsOP   	:= {}
OpenSxs(,,,,,"SX3DIC","SX3",,.F.)
if Select("SX3DIC") > 0
	AADD(_aHeaderOP, {	"Item"						,;
						'C6_ITEM'					,;
						''							,;
						3							,;
						0							,;
						.T.							,;
						''							,;
						'N'							,;
						''							,;
						'V'							,;
						''							,;
						''							,;
						.T.							,;
						''							,;
						.T.							})						
	SX3DIC->(dbSetOrder(1))
	SX3DIC->(dbGoTop())
	if SX3DIC->(dbSeek("SC2"))
		while SX3DIC->(!EOF()) .AND. AllTrim(SX3DIC->X3_ARQUIVO) == "SC2"
			if AllTrim(SX3DIC->X3_CAMPO) $ ("C2_NUM|C2_ITEM|C2_SEQUEN|C2_DATPRI|C2_DATPRF|C2_QUANT")
				AADD(_aHeaderOP,{	AllTrim(FWX3Titulo(SX3DIC->X3_CAMPO))	,;
									SX3DIC->X3_CAMPO  						,;
									SX3DIC->X3_PICTURE						,;
									SX3DIC->X3_TAMANHO						,;
									SX3DIC->X3_DECIMAL						,;
									SX3DIC->X3_VALID  						,;
									SX3DIC->X3_USADO  						,;
									SX3DIC->X3_TIPO   						,;
									SX3DIC->X3_F3     						,;
									SX3DIC->X3_CONTEXT						,;
									SX3DIC->X3_CBOX   						,;
									SX3DIC->X3_RELACAO						})
			endif
			SX3DIC->(dbSkip())
		enddo
		nUsado := Len(_aHeaderOP)
		AADD(_aColsOP,Array(Len(_aHeaderOP)+1))
		for _nX := 1 to Len(_aHeaderOP)
			_aColsOP[1,_nX] := CriaVar(_aHeaderOP[_nX,2])
		next _nX
		_aColsOP[Len(_aColsOP), 1] 					:= _nItem
		_aColsOP[Len(_aColsOP), 2] 					:= ""
		_aColsOP[Len(_aColsOP), 3] 					:= ""
		_aColsOP[Len(_aColsOP), 4] 					:= ""
		_aColsOP[Len(_aColsOP), 5] 					:= 0
		_aColsOP[Len(_aColsOP), 6] 					:= CtoD("  /  /  ")
		_aColsOP[Len(_aColsOP), 7] 					:= CtoD("  /  /  ")
		_aColsOP[Len(_aColsOP), Len(_aHeaderOP)+1] 	:= .F.
	endif
endif
static oDlg
	DEFINE MSDIALOG oDlg TITLE "" FROM _aSize[7],0  TO 500,1320 COLORS 0, 16777215 PIXEL  Style DS_MODALFRAME // Cria Dialog sem o botão de Fechar.
   	@ _aSize[1]+009, _aSize[1]+300 GROUP oGroup2  	TO 217,650 	PROMPT "Gestão OP's Previstas"      																		OF oDlg COLOR  0, 16777215          PIXEL
    @ _aSize[1]+030, _aSize[1]+309 SAY   oSay1     				PROMPT "Produto"                          		SIZE _aSize[1]+235,_aSize[1]+660 							OF oDlg COLORS 0, 16777215          PIXEL
    @ _aSize[1]+040, _aSize[1]+309 MSGET oCodProd    VAR    _cCodProd  VALID AtuProd()  F3 "SB1" WHEN _lSeqOP  	SIZE 060, 010 												OF oDlg COLORS 0, 16777215          PIXEL
    @ _aSize[1]+040, _aSize[1]+369 MSGET oDesProd    VAR    _cDesProd               			 						WHEN .F.  		SIZE 275, 010 						OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ _aSize[1]+070, _aSize[1]+309 SAY   oSay4     				PROMPT "Quantidade a produzir por OP"            SIZE 100, 010 												OF oDlg COLORS 0, 16777215 		 	PIXEL
	@ _aSize[1]+080, _aSize[1]+309 MSGET oGet4   	 VAR    _nQtdPrd   VALID Positivo() PICTURE "@E 999,999,999.9999" 	/*WHEN .F.*/	SIZE 100, 010 						OF oDlg COLORS 0, 16777215  		PIXEL
    @ _aSize[1]+070, _aSize[1]+460 SAY   oSay5     				PROMPT "Quantidade de OP's"               		SIZE 100, 010												OF oDlg COLORS 0, 16777215  		PIXEL
	aItems 		:= {"  ","01","02","03","04","05","06","07","08","09","10", "11","12","13","14","15","16","17","18","19","20", "21","22","23","24","25","26","27","28","29","30"}
	_cCboQtd	:= ""
	oCombo1 	:= TComboBox():New(_aSize[1]+080, _aSize[1]+460,{|u|if(PCount()>0,_cCboQtd:=u,_cCboQtd)},aItems,100,10,oDlg,,{|| SomaOP(_cCboQtd) },,,,.T.,,,,,,,,,'_cCboQtd')
    @ _aSize[1]+100, _aSize[1]+309 SAY   oSay6     				PROMPT "Previsão de início"               		SIZE 100, 010 												OF oDlg COLORS 0, 16777215  		PIXEL
	@ _aSize[1]+110, _aSize[1]+309 MSGET oDatIni     VAR  	_dDatIni          									SIZE 100, 010 												OF oDlg COLORS 0, 16777215  		PIXEL
    @ _aSize[1]+100, _aSize[1]+460 SAY   oSay7     				PROMPT "Previsão de entrega"               		SIZE 100, 010 												OF oDlg COLORS 0, 16777215  		PIXEL
	@ _aSize[1]+110, _aSize[1]+460 MSGET oDatEnt     VAR    _dDatEnt   VALID ValDatas()         				SIZE 100, 010 												OF oDlg COLORS 0, 16777215  		PIXEL
    @ _aSize[1]+150, _aSize[1]+309 SAY   oSay8     				PROMPT "Observação"               				SIZE 200, 010 												OF oDlg COLORS 0, 16777215  		PIXEL
	@ _aSize[1]+160, _aSize[1]+309 MSGET oObserv     VAR  	_cObserv            								SIZE 325, 030 												OF oDlg COLORS 0, 16777215  		PIXEL

    @ _aSize[1]+224, _aSize[1]+300 BUTTON oButSr 				PROMPT "&Sair" 									SIZE 080, 015 												OF oDlg ACTION EVAL({|| _lSair := .T.,oDlg:End() }) 								PIXEL
    @ _aSize[1]+224, _aSize[1]+469 BUTTON oButCL 				PROMPT "&Cancelar" 							 	SIZE 080, 015 												OF oDlg ACTION EVAL({|| Cancelar() })												PIXEL
    @ _aSize[1]+224, _aSize[1]+570 BUTTON oButOK 				PROMPT "Confirma&r"								SIZE 080, 015 												OF oDlg ACTION EVAL({|| iif(ValidarDados(),(FirmarOP(_cCboQtd),oDlg:End()),) } )  	PIXEL
	//+--------------------------------------------------------------+
	// Grid para as OPs Previstas
	//+--------------------------------------------------------------+	
	_oGetOP   := MsNewGetDados():New(_aSize[1]+009,_aSize[1]+010,_aSize[1]+235,_aSize[1]+290,,"AllWaysTrue","AllwaysTrue","",,,,,,,oDlg,_aHeaderOP,_aColsOP)
	//Se o codigo do produto já estiver informado atualiza dados da tela.
	if !Empty(_cCodProd)
		AtuProd()
	endif
	if !_lSeqOP //OPs intermediarias previstas
		OpsInter(_aOpsI)
		oCombo1:SetFocus()
	else
		oCodProd:SetFocus()
	endif 
	oDlg:lEscClose := .F. //Nao permite sair ao se pressionar a tecla ESC.
	ACTIVATE MSDIALOG oDlg CENTERED
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ AtuProd     º Autor ³ Fernando Bombardi º Data ³10/09/2021 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Rotina responsavel por atualizar dados do produto.         º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function AtuProd()
_cCodProd := Upper(_cCodProd)
dbSelectArea("SB1")
SB1->(dbSetOrder(1))
SB1->(MsSeek(xFilial("SB1") + _cCodProd ,.F.,.F.))
if SB1->(Found())
	_cCodProd := UPPER(SB1->B1_COD)
	_cDesProd := SB1->B1_DESC
	CarregaOP(_cCodProd)
else
	dbSelectArea("SB1")
	SB1->(dbGoTop())
	SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1") + UPPER(_cCodProd) ,.F.,.F.))
	if SB1->(Found())
		_cCodProd := Upper(SB1->B1_COD)
		_cDesProd := SB1->B1_DESC
		CarregaOP(_cCodProd)
	Else
		_cCodProd := ""
		_cDesProd := Upper("Produto Não Encontrado!")
	EndIf
EndIf
return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ ValDatas    º Autor ³ Fernando Bombardi º Data ³10/09/2021 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Rotina responsavel por atualizar datas.				      º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ValDatas()
if _dDatEnt < _dDatIni  
	_dDatEnt := _dDatIni 
endif
return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ CarregaOP   º Autor ³ Fernando Bombardi º Data ³10/09/2021 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Rotina responsavel por buscar as OP's a serem apresentadas.º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/	
static function CarregaOP(_cCodProd)
local _nCnt := 1
BeginSql alias 'OPS'
	SELECT C2_NUM,C2_ITEM,C2_SEQUEN,C2_DATPRI,C2_DATPRF,C2_QUANT
	FROM
		%table:SC2% SC2 (NOLOCK)
	WHERE
		SC2.C2_FILIAL = %xfilial:SC2% AND
		SC2.C2_PRODUTO = %exp:_cCodProd% AND
		SC2.C2_TPOP = 'P' AND
		SUBSTRING(SC2.C2_NUM,1,1) = 'Z' AND
		SC2.%notDel%
	ORDER BY C2_NUM,C2_ITEM,C2_SEQUEN
EndSql
dbSelectArea("OPS")
if OPS->(!EOF())
	while OPS->(!EOF())
		if _nCnt == 1
			_dDatIni   := STOD(OPS->C2_DATPRI)
			_dDatEnt   := STOD(OPS->C2_DATPRF)
			_nQtdProd  := OPS->C2_QUANT					
		endif
		if _nCnt > 1 //.AND. _nCnt > len(_aHeaderOP)
			AADD(_oGetOP:aCols,Array(len(_aHeaderOP)+1))
		endif
		_oGetOP:aCols[len(_oGetOP:aCols),1] 				:= _nCnt
		_oGetOP:aCols[len(_oGetOP:aCols),2] 				:= OPS->C2_NUM
		_oGetOP:aCols[len(_oGetOP:aCols),3] 				:= OPS->C2_ITEM
		_oGetOP:aCols[len(_oGetOP:aCols),4] 				:= OPS->C2_SEQUEN
		_oGetOP:aCols[len(_oGetOP:aCols),5] 				:= OPS->C2_QUANT
		_oGetOP:aCols[len(_oGetOP:aCols),6] 				:= StoD(OPS->C2_DATPRI)
		_oGetOP:aCols[len(_oGetOP:aCols),7] 				:= StoD(OPS->C2_DATPRF)
		_oGetOP:aCols[len(_oGetOP:aCols),len(_aHeaderOP)+1] := .F.
		_nCnt++
		OPS->(dbSkip())
	enddo
endif
OPS->(dbCloseArea())
_oGetOP:oBrowse:Refresh()
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ SomaOP      º Autor ³ Fernando Bombardi º Data ³10/09/2021 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Rotina responsavel por somar quantidade das OPs.           º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function SomaOP(_nQtdFirm)
local _nOP    	:= 1
local _nQtdOP 	:= 0
if Val(_nQtdFirm) > Len(_oGetOP:aCols)
	Aviso(_cRotina + "_005",'A quantidade de OPs selecionadas é maior que a quantidade de OPs disponíveis. Verifique para continuar...',{"Ok"},3)
	_cCboQtd	:= ""
	oCombo1:Refresh()
	return
endif
for _nOP := 1 tO Val(_nQtdFirm)
	_nQtdOP 	:= _oGetOP:aCols[_nOP,5]
next _nOP
_nQtdPrd 		:= _nQtdOP
oGet4:Refresh()
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ FirmarOP    º Autor ³ Fernando Bombardi º Data ³10/09/2021 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Rotina responsavel por firmar as OPs previstas.            º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function FirmarOP(_cCboQtd)
//
//local _nFirmarOPI 	:= SuperGetMv("MV_XFIRMOPI",.F.,2) //Define se o OP intermediaria sera firmada em conjunto com OP Pai.
//local _lPri       	:= .T.
//local _nOpc       	:= 4
Local _lFirmaOK		:= .T.
Private _lRetSld	:= .T.
Private _nOP        := 0
Private _cNumAnt	:= ""
_nQtdSel 			:= _cCboQtd //Salva quantidade selecionada 
/*
if _lSeqOP
	RetNroOp() //Retorno o numero da OP para numeração oficial
endif
*/
for _nOP := 1 to Val(_cCboQtd)

	RetNroOp(_nOP) //Retorno o numero da OP para numeração oficial
	If !_lRetSld
		Return()
	EndIf
	_nNumOP := PADR(_oGetOP:aCols[_nOP,2],TAMSX3("C2_NUM")[1])+PADR(_oGetOP:aCols[_nOP,3],TAMSX3("C2_ITEM")[1])+PADR(_oGetOP:aCols[_nOP,4],TAMSX3("C2_SEQUEN")[1])
	/*if _lPri
		_cNumIni 	:= _nNumOP
		_lPri 		:= .F.
	endif
	*/
	If Substr(_nNumOP,1,1) <> 'Z'
		_cNumIni 	:= _nNumOP
		_cNumFim 	:= _nNumOP
		If _nOP == 1 .and. SB1->B1_TIPO = 'PA'
			_cImpIni := _nNumOP
		EndIf
	EndIf
	
	if _lSeqOP
		ConOpPi(PADR(_oGetOP:aCols[_nOP,2],TAMSX3("C2_NUM")[1]),PADR(_oGetOP:aCols[_nOP,3],TAMSX3("C2_ITEM")[1]),PADR(_oGetOP:aCols[_nOP,4],TAMSX3("C2_SEQUEN")[1])) //Consulta OP Intermediarios
		//ConOpPi(PADR(Substring(_cNumAnt,1,6),TAMSX3("C2_NUM")[1]),PADR(_oGetOP:aCols[_nOP,3],TAMSX3("C2_ITEM")[1]),PADR(_oGetOP:aCols[_nOP,4],TAMSX3("C2_SEQUEN")[1])) //Consulta OP Intermediarios
	endif
	//Ordens de Produção para impressão
	AADD(_aOpImp,{PADR(_oGetOP:aCols[_nOP,2],TAMSX3("C2_NUM")[1]),PADR(_oGetOP:aCols[_nOP,3],TAMSX3("C2_ITEM")[1]),PADR(_oGetOP:aCols[_nOP,4],TAMSX3("C2_SEQUEN")[1]),0})
	//Atualiza a data de inicio e entrega conforme parametrizado.
	dbSelectArea("SC2")
	dbSetOrder(1)
	if dbSeek(FWFilial("SC2") + _nNumOP)
		_nQtdAnt := SC2->C2_QUANT
		RecLock("SC2",.F.)
		SC2->C2_QUANT	:= _nQtdPrd
		SC2->C2_DATPRI  := _dDatIni
		SC2->C2_DATPRF  := _dDatEnt
		SC2->C2_QTSEGUM := ROUND(_nQtdPrd/Posicione("SB1",1,xFilial("SB1")+SC2->C2_PRODUTO,"SB1->B1_CONV"),4)
		SC2->C2_XDTVALI := U_RESTE010(_dDatEnt,SC2->C2_PRODUTO)
		SC2->(MsUnlock())
	endif

	If (_nQtdAnt==_nQtdPrd,.T.,U_RPCPE016(_nNumOP,_nQtdPrd,_nQtdAnt))
	/*
	If !Empty(_cNumIni) .and. !Empty(_cNumFim)
		lMsErroAuto 		:= .F.
		aInf 				:= {{“MV_PAR01”, ALLTRIM(_cCodProd) }	,;
								{“MV_PAR02”, ALLTRIM(_cCodProd) }	,;
								{“MV_PAR03”, _cNumIni }				,;
								{“MV_PAR04”, _cNumFim }				,;
								{“MV_PAR05”, CTOD("01/01/2001")}	,;
								{“MV_PAR06”, CTOD("31/12/2049")}	,;
								{“MV_PAR07”, CTOD("01/01/2001")}	,;
								{“MV_PAR08”, CTOD("31/12/2049")}	,;
								{“MV_PAR09”, _nFirmarOPI }			}
		MsgRun("Firmando Ordem(ns) de produção: "+cValtoChar(_nOP)+" de "+cValtoChar(Val(_cCboQtd))+", aguarde ...",,{|| MSExecAuto({|x,y| MATA651(x,y)},aInf,_nOpc,,) })
		if lMsErroAuto	
			MostraErro()
		else
			aInf := Nil
		endif
		_cNumIni := ""
	else
		If Substr(_nNumOP,1,1) == 'Z'//Empty(_cImpIni)
			_lFirmaOK := .F.
			Return()
		EndIf
	EndIf
	*/
next _nOP

If _lFirmaOK
	//MsgInfo("Ordens de Produção firmadas com sucesso!","Aviso")
	MsgInfo("Numeração das Ordens de Produção alteradas com sucesso!","Aviso")
EndIf
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ Cancelar    º Autor ³ Fernando Bombardi º Data ³10/09/2021 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Rotina para limpar tela configurada anteriormente.         º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function Cancelar()
_oGetOP:aCols 											:= {}
nUsado 													:= Len(_aHeaderOP)
AADD(_oGetOP:aCols,Array(Len(_aHeaderOP)+1))
_oGetOP:aCols[Len(_oGetOP:aCols), 1] 					:= 1
_oGetOP:aCols[Len(_oGetOP:aCols), 2] 					:= ""
_oGetOP:aCols[Len(_oGetOP:aCols), 3] 					:= ""
_oGetOP:aCols[Len(_oGetOP:aCols), 4] 					:= ""
_oGetOP:aCols[Len(_oGetOP:aCols), 5] 					:= 0
_oGetOP:aCols[Len(_oGetOP:aCols), 6] 					:= CtoD("  /  /  ")
_oGetOP:aCols[Len(_oGetOP:aCols), 7] 					:= CtoD("  /  /  ")
_oGetOP:aCols[Len(_oGetOP:aCols), Len(_aHeaderOP)+1] 	:= .F.
_cCodProd 												:= Space(15)
_cDesProd 												:= Space(12)
_nQtdPrd  												:= 0
_dDatIni  												:= ddatabase
_dDatEnt  												:= ddatabase
_cObserv  												:= Space(200)
_cCboQtd  												:= ""
oDlg:Refresh()
oCodProd:SetFocus() 
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ RetNroOp    º Autor ³ Fernando Bombardi º Data ³10/09/2021 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Rotina para limpar tela configurada anteriormente.         º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetNroOp(_nItOP)
//local _nItOP 		:= 1
local cAliasQry 	:= GetNextAlias()
local _cDadosAux  	:= "GETSC2"
local _cQry 	  	:= ""
local _cQuery		:= ""

//for _nItOP := 1 to val(_cCboQtd)
	_cQuery 	  	:= "WITH SC2C AS (																		" + ENT
	_cQuery 	  	+= "	SELECT																			" + ENT
	_cQuery 	  	+= "		SC2A.C2_FILIAL, SC2A.C2_NUM, SC2A.C2_ITEM, SC2A.C2_SEQUEN, 					" + ENT
	_cQuery 	  	+= "		SC2A.C2_SEQPAI, SC2A.C2_PRODUTO, SC2A.C2_TPOP, SC2A.C2_QUANT, 				" + ENT
	_cQuery 	  	+= "		SC2A.C2_DATPRI, SC2A.C2_DATPRF, 1 AS NIVEL									" + ENT
	_cQuery 	  	+= "	FROM																			" + ENT
	_cQuery 	  	+= 			RetSqlName("SC2") + " SC2A (NOLOCK) 										" + ENT
	_cQuery 	  	+= "	WHERE																			" + ENT
	_cQuery 	  	+= "		SC2A.C2_FILIAL = '" 	+ FWFilial("SC2") 			+ "'					" + ENT
	_cQuery 	  	+= "		AND SC2A.C2_NUM = '" 	+ _oGetOP:aCols[_nItOP,2] 	+ "'					" + ENT
	_cQuery 	  	+= "		AND SC2A.C2_ITEM = '"   + _oGetOP:aCols[_nItOP,3] 	+ "'					" + ENT
	_cQuery 	  	+= "		AND SC2A.C2_SEQUEN = '"	+ _oGetOP:aCols[_nItOP,4] 	+ "'					" + ENT
	_cQuery 	  	+= "		AND SC2A.C2_PRODUTO = '"+ _cCodProd 				+ "'					" + ENT
	_cQuery 	  	+= "		AND SC2A.D_E_L_E_T_ = ''													" + ENT
	_cQuery 	  	+= "	UNION ALL																		" + ENT
	_cQuery 	  	+= "	SELECT																			" + ENT
	_cQuery 	  	+= "		SC2B.C2_FILIAL, SC2B.C2_NUM, SC2B.C2_ITEM, SC2B.C2_SEQUEN, 					" + ENT
	_cQuery 	  	+= "		SC2B.C2_SEQPAI, SC2B.C2_PRODUTO, SC2B.C2_TPOP, SC2B.C2_QUANT, 				" + ENT
	_cQuery 	  	+= "		SC2B.C2_DATPRI, SC2B.C2_DATPRF, NIVEL + 1 AS NIVEL							" + ENT
	_cQuery 	  	+= "	FROM																			" + ENT
	_cQuery 	  	+= 			RetSqlName("SC2") + " SC2B (NOLOCK)											" + ENT
	_cQuery 	  	+= "		INNER JOIN SC2C AS X														" + ENT
	_cQuery 	  	+= "			ON SC2B.C2_FILIAL = X.C2_FILIAL											" + ENT
	_cQuery 	  	+= "			AND SC2B.C2_NUM = X.C2_NUM												" + ENT
	_cQuery 	  	+= "			AND SC2B.C2_ITEM = X.C2_ITEM											" + ENT
	_cQuery 	  	+= "			AND SC2B.C2_SEQPAI = X.C2_SEQUEN										" + ENT
	_cQuery 	  	+= "			AND SC2B.D_E_L_E_T_ = ''												" + ENT
	_cQuery 	  	+= "	)																				" + ENT
	_cQuery 	  	+= "SELECT																				" + ENT
	_cQuery 	  	+= "	SC2C.C2_FILIAL, 																" + ENT
	_cQuery 	  	+= "	SC2C.C2_NUM,																	" + ENT
	_cQuery 	  	+= "	SC2C.C2_ITEM,																	" + ENT
	_cQuery 	  	+= "	SC2C.C2_SEQUEN,																	" + ENT
	_cQuery 	  	+= "	SC2C.C2_SEQPAI,																	" + ENT
	_cQuery 	  	+= "	SC2C.C2_PRODUTO,																" + ENT
	_cQuery 	  	+= "	SB1.B1_DESC,																	" + ENT
	_cQuery 	  	+= "	SC2C.C2_TPOP,																	" + ENT
	_cQuery 	  	+= "	SC2C.C2_QUANT, 																	" + ENT
	_cQuery 	  	+= "	SC2C.C2_DATPRI,																	" + ENT
	_cQuery 	  	+= "	SC2C.C2_DATPRF,																	" + ENT
	_cQuery 	  	+= "	SC2C.NIVEL																		" + ENT
	_cQuery 	  	+= "FROM																				" + ENT
	_cQuery 	  	+= "	SC2C 																			" + ENT
	_cQuery 	  	+= "	INNER JOIN 																		" + ENT
	_cQuery 	  	+= 			RetSqlName("SB1") + " AS SB1 (NOLOCK)										" + ENT
	_cQuery 	  	+= "	ON 																				" + ENT
	_cQuery 	  	+= "		SB1.B1_FILIAL = SC2C.C2_FILIAL 												" + ENT
	_cQuery 	  	+= "		AND SB1.B1_COD = SC2C.C2_PRODUTO											" + ENT
	_cQuery 	  	+= "ORDER BY																			" + ENT
	_cQuery 	  	+= "	NIVEL ASC, SC2C.C2_PRODUTO														" + ENT
	//MemoWrite("\2.MemoWrite\" + _cRotina + "_QRY_001.TXT",_cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasQry,.F.,.T.)
	dbSelectArea(cAliasQry)
	_cQry 			:= GetLastQuery()
	_cQry 	  		:= " SELECT 																			" + ENT
	_cQry 	  		+= "	MAX(C2_NUM) + 1 AS C2_NUM 														" + ENT
	_cQry 	  		+= " FROM 																				" + ENT
	_cQry 	  		+=		RetSqlName("SC2") + " AS SC2 (NOLOCK)											" + ENT
	_cQry 	  		+= " WHERE 																				" + ENT
	_cQry 	  		+= "   	SC2.C2_FILIAL  = '" + FWFilial("SC2") + "' 										" + ENT
	_cQry 	  		+= "	AND SC2.C2_EMISSAO > '20130403' 												" + ENT
	_cQry 	  		+= "   	AND UPPER(SC2.C2_NUM) NOT LIKE ('%A%') AND UPPER(SC2.C2_NUM) NOT LIKE ('%Z%') 	" + ENT
	_cQry 	 		+= "   	AND (CASE WHEN SUBSTRING(SC2.C2_NUM,1,1) = '9' THEN '0' ELSE '1' END ) = '1' 	" + ENT
	//_cQry 	  		+= "   	AND SC2.D_E_L_E_T_ = '' 														" + ENT
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cDadosAux,.F.,.T.)
	dbSelectArea(_cDadosAux)
	if AllTrim(STR((_cDadosAux)->C2_NUM)) >= '000001'
		_cRet := AllTrim(STR((_cDadosAux)->C2_NUM))
	else
		_cRet := '000001'
	endif
	(_cDadosAux)->(dbCloseArea())
	//Begin Transaction
		while (cAliasQry)->(!EOF())
			_cNumAnt := (cAliasQry)->C2_NUM //+ (cAliasQry)->C2_ITEM + (cAliasQry)->C2_SEQUEN
			_nQtdAnt := (cAliasQry)->C2_QUANT
			//If (_nQtdAnt==_nQtdPrd,.T.,U_RPCPE016(_nNumOP,_nQtdPrd,_nQtdAnt))
			
			_lRetSld := If(_nOp == 1,U_RPCPE013((cAliasQry)->C2_NUM + (cAliasQry)->C2_ITEM + (cAliasQry)->C2_SEQUEN,_nQtdPrd,_nQtdAnt),.T.)
			If _lRetSld
				Begin Transaction
				while (cAliasQry)->(!EOF()) .AND. AllTrim(_cNumAnt) == AllTrim((cAliasQry)->C2_NUM)//+ (cAliasQry)->C2_ITEM + (cAliasQry)->C2_SEQUEN .AND. AllTrim(_cCodProd) == AllTrim((cAliasQry)->C2_PRODUTO)
					dbSelectArea("SC2")
					SC2 ->(dbSetOrder(1))
					if SC2->(dbSeek(xFilial("SC2") + (cAliasQry)->C2_NUM + (cAliasQry)->C2_ITEM + (cAliasQry)->C2_SEQUEN))
						//Atualiza OP
						RecLock("SC2",.F.) 
						SC2->C2_FILIAL := FWFilial("SC2")
						SC2->C2_NUM    := _cRet
						//SC2->C2_OBS    := If(Empty(AllTrim(_cObserv)),"Incluido por MRP",AllTrim(_cObserv))
						SC2->C2_OBS    := "Incluido por MRP"
						SC2->C2_XLOTE   := _cRet
						SC2->C2_XDTVALI   := U_RESTE010(SC2->C2_DATPRF,SC2->C2_PRODUTO)
						SC2->(MsUnlock())
						//Atualiza o numero da OP no grid.
						_oGetOP:aCols[_nItOP,2] := _cRet
						//Atualiza empenho 
						BeginSql Alias "EMPENHO"
							SELECT
								SD4.D4_OP, SD4.D4_COD, SD4.D4_LOCAL
							FROM
								%table:SD4% SD4 (NOLOCK) 
							WHERE
								SD4.D4_OP = %exp:_cNumAnt+SC2->C2_ITEM+SC2->C2_SEQUEN%
								AND SD4.%notDel%
							ORDER BY SD4.D4_OP, SD4.D4_COD, SD4.D4_LOCAL
						EndSql
						while EMPENHO->(!EOF())
							dbSelectArea("SD4")
							dbSetOrder(2) //D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
							if dbSeek(xFilial("SD4") + EMPENHO->D4_OP)
								RecLock("SD4",.F.)
								SD4->D4_OP := AllTrim(_cRet) + SC2->C2_ITEM + SC2->C2_SEQUEN
								/*if !Empty(SD4->D4_OPORIG) 
									//SD4->D4_OPORIG := AllTrim(_cRet) + SubStr(SD4->D4_OPORIG,7,10)
									SD4->D4_OPORIG := ""
								endif*/
								SD4->(MsUnlock())
							endif
							dbSelectArea("EMPENHO")
							EMPENHO->(dbSkip())
						enddo
						EMPENHO->(dbCloseArea())
						//U_RPCPE012(AllTrim(_cRet) + SC2->C2_ITEM + SC2->C2_SEQUEN)
					endif
					dbSelectArea(cAliasQry)     
					(cAliasQry)->(dbSkip())
				enddo
				End Transaction
			//_cRet := Soma1(_cRet)
			Else 
				MSGSTOP( "Não será convertida a ordem de produção prevista: "+ (cAliasQry)->C2_NUM + (cAliasQry)->C2_ITEM + (cAliasQry)->C2_SEQUEN +" em firme devido a falta de saldo", "ATENÇÃO" )
				//_lSeqOP := .F.
				dbSelectArea(cAliasQry)     
				(cAliasQry)->(dbCloseArea())
				Return()
			Endif
		enddo
		(cAliasQry)->(dbCloseArea())
	//End Transaction
//next _nItOP
return(_cRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ ConOpPi   º Autor ³ Rodrigo Telecio   º Data ³  19/10/2021 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Consulta OP Intermediarias         						  º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ConOpPi(_cNum,_cItem,_cSerie)
local _cDadosAux  	:= "OPINT"
local _cQry 	  	:= ""
_cQry 	  	:= "WITH SC2C AS (																		" + ENT
_cQry 	  	+= "	SELECT																			" + ENT
_cQry 	  	+= "		SC2A.C2_FILIAL, SC2A.C2_NUM, SC2A.C2_ITEM, SC2A.C2_SEQUEN, 					" + ENT
_cQry 	  	+= "		SC2A.C2_SEQPAI, SC2A.C2_PRODUTO, SC2A.C2_TPOP, SC2A.C2_QUANT, 				" + ENT
_cQry 	  	+= "		SC2A.C2_DATPRI, SC2A.C2_DATPRF, 1 AS NIVEL									" + ENT
_cQry 	  	+= "	FROM																			" + ENT
_cQry 	  	+= 			RetSqlName("SC2") + " SC2A (NOLOCK) 										" + ENT
_cQry 	  	+= "	WHERE																			" + ENT
_cQry 	  	+= "		SC2A.C2_FILIAL = '" 	+ FWFilial("SC2") 	+ "'							" + ENT
_cQry 	  	+= "		AND SC2A.C2_NUM = '" 	+ _cNum 			+ "'							" + ENT
_cQry 	  	+= "		AND SUBSTRING(SC2A.C2_NUM,1,1) <> 'Z'										" + ENT
_cQry 	  	+= "		AND SC2A.C2_ITEM = '"   + _cItem 			+ "'							" + ENT
_cQry 	  	+= "		AND SC2A.C2_SEQUEN = '"	+ _cSerie 			+ "' 							" + ENT
//_cQry 	  	+= "		AND SC2A.C2_SEQPAI = '"	+ _cSerie 			+ "' 							" + ENT
_cQry 	  	+= "		AND SC2A.D_E_L_E_T_ = ''													" + ENT
_cQry 	  	+= "	UNION ALL																		" + ENT
_cQry 	  	+= "	SELECT																			" + ENT
_cQry 	  	+= "		SC2B.C2_FILIAL, SC2B.C2_NUM, SC2B.C2_ITEM, SC2B.C2_SEQUEN, 					" + ENT
_cQry 	  	+= "		SC2B.C2_SEQPAI, SC2B.C2_PRODUTO, SC2B.C2_TPOP, SC2B.C2_QUANT, 				" + ENT
_cQry 	  	+= "		SC2B.C2_DATPRI, SC2B.C2_DATPRF, NIVEL + 1 AS NIVEL							" + ENT
_cQry 	  	+= "	FROM																			" + ENT
_cQry 	  	+= 			RetSqlName("SC2") + " SC2B (NOLOCK)											" + ENT
_cQry 	  	+= "		INNER JOIN SC2C AS X														" + ENT
_cQry 	  	+= "			ON SC2B.C2_FILIAL = X.C2_FILIAL											" + ENT
_cQry 	  	+= "			AND SC2B.C2_NUM = X.C2_NUM												" + ENT
_cQry 	  	+= "			AND SC2B.C2_ITEM = X.C2_ITEM											" + ENT
_cQry 	  	+= "			AND SC2B.C2_SEQPAI = X.C2_SEQUEN										" + ENT
_cQry 	  	+= "			AND SC2B.D_E_L_E_T_ = ''												" + ENT
_cQry 	  	+= "	)																				" + ENT
_cQry 	  	+= "SELECT																				" + ENT
_cQry 	  	+= "	SC2C.C2_FILIAL, 																" + ENT
_cQry 	  	+= "	SC2C.C2_NUM,																	" + ENT
_cQry 	  	+= "	SC2C.C2_ITEM,																	" + ENT
_cQry 	  	+= "	SC2C.C2_SEQUEN,																	" + ENT
_cQry 	  	+= "	SC2C.C2_SEQPAI,																	" + ENT
_cQry 	  	+= "	SC2C.C2_PRODUTO,																" + ENT
_cQry 	  	+= "	SB1.B1_DESC,																	" + ENT
_cQry 	  	+= "	SC2C.C2_TPOP,																	" + ENT
_cQry 	  	+= "	SC2C.C2_QUANT, 																	" + ENT
_cQry 	  	+= "	SC2C.C2_DATPRI,																	" + ENT
_cQry 	  	+= "	SC2C.C2_DATPRF,																	" + ENT
_cQry 	  	+= "	SC2C.NIVEL																		" + ENT
_cQry 	  	+= "FROM																				" + ENT
_cQry 	  	+= "	SC2C 																			" + ENT
_cQry 	  	+= "	INNER JOIN 																		" + ENT
_cQry 	  	+= 			RetSqlName("SB1") + " AS SB1 (NOLOCK)										" + ENT
_cQry 	  	+= "	ON 																				" + ENT
_cQry 	  	+= "		SB1.B1_FILIAL = SC2C.C2_FILIAL 												" + ENT
_cQry 	  	+= "		AND SB1.B1_COD = SC2C.C2_PRODUTO											" + ENT
_cQry 	  	+= "WHERE																				" + ENT
_cQry 	  	+= "	SC2C.C2_SEQPAI <> ''															" + ENT
_cQry 	  	+= "ORDER BY																			" + ENT
_cQry 	  	+= "	NIVEL ASC, SC2C.C2_PRODUTO														" + ENT
//MemoWrite("\2.MemoWrite\" + _cRotina + "_QRY_001.TXT",_cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cDadosAux,.F.,.T.)
dbSelectArea(_cDadosAux)
while (_cDadosAux)->(!EOF())
	AADD(_aOpsI,{	(_cDadosAux)->C2_PRODUTO,;
					(_cDadosAux)->C2_NUM	,;
					(_cDadosAux)->C2_ITEM	,;
					(_cDadosAux)->C2_SEQUEN	,;
					(_cDadosAux)->C2_QUANT	,;
					(_cDadosAux)->C2_DATPRI	,;
					(_cDadosAux)->C2_DATPRF ,;
					.F.						})
	(_cDadosAux)->(dbSkip())
enddo
(_cDadosAux)->(dbCloseArea())
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ OpsInter    º Autor ³ Fernando Bombardi º Data ³12/09/2021 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Carrega grid com as OPs Previstas da OP Pai.				  º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function OpsInter(_aOpsI)
local _nOpPv 	:= 0
local _nCtn  	:= 1
_oGetOP:aCols 	:= {}
for _nOpPv :=1 to len(_aOpsI)
	if !_aOpsI[_nOpPv,8]
		if Alltrim(_cCodProd) == Alltrim(_aOpsI[_nOpPv,1])				
			AADD(_oGetOP:aCols,Array(len(_aHeaderOP)+1))
			_oGetOP:aCols[len(_oGetOP:aCols),1] 				:= _nCtn
			_oGetOP:aCols[len(_oGetOP:aCols),2] 				:= _aOpsI[_nOpPv,2]
			_oGetOP:aCols[len(_oGetOP:aCols),3] 				:= _aOpsI[_nOpPv,3]
			_oGetOP:aCols[len(_oGetOP:aCols),4] 				:= _aOpsI[_nOpPv,4]
			_oGetOP:aCols[len(_oGetOP:aCols),5] 				:= _aOpsI[_nOpPv,5]
			_oGetOP:aCols[len(_oGetOP:aCols),6] 				:= STOD(_aOpsI[_nOpPv,6])
			_oGetOP:aCols[len(_oGetOP:aCols),7] 				:= STOD(_aOpsI[_nOpPv,7])
			_oGetOP:aCols[len(_oGetOP:aCols),len(_aHeaderOP)+1] := .F.
			_aOpsI[_nOpPv,8] 									:= .T.
			_nCtn++
		endif
	endif
next _nOpPv
_oGetOP:oBrowse:Refresh()
oCombo1:Refresh()    //Atualiza combo de quantidade
SomaOP(_cCboQtd)     //Soma quantidade  das OP Intermedias Previstas
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ ValidarDadosº Autor ³ Fernando Bombardi º Data ³17/09/2021 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Rotina para validar dados do formulario.  				  º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ValidarDados()
local _lRet := .T.
if Empty(_cCodProd)
	Aviso(_cRotina + "_002",'Código do produto não foi informado. Verifique para continuar...',{"Ok"},3)
	_lRet 	:= .F.
elseif _dDatIni  < ddatabase .OR. _dDatEnt < ddatabase
	Aviso(_cRotina + "_003",'As datas devem ser MAIORES ou IGUAIS à Data-base do sistema. Verifique para continuar...',{"Ok"},3)
	_lRet 	:= .F.	 
elseif  _dDatEnt < _dDatIni 
	Aviso(_cRotina + "_004",'A data de entrega está MENOR do que a data de previsão de inicio. Verifique para continuar...',{"Ok"},3)
	_dEntr 	:= _dDatIni
	_lRet 	:= .F.  
elseif empty(_cCboQtd)
	Aviso(_cRotina + "_099",'A quantidade de OPs previstas não foi definida. Verifique para continuar...',{"Ok"},3)
	_lRet := .F.
elseif !U_RPCPE019(_cCodProd)
	Aviso(_cRotina + "_100",'Problema no roteiro. Verifique para continuar...',{"Ok"},3)
	_lRet := .F.
endif
return(_lRet)
