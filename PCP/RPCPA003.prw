#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
#include "ap5mail.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "protheus.ch"
#define CENT CHR(13) + CHR(10)
/*/{Protheus.doc} RPCPA003
Fonte para a gerar mais de uma ordem de producao atraves de produto tipo MO documento de entrada.
@author Livia Della Corte (ALL System Solutions)
@since 11/10/2018
@version P12
@type function
@see https://allss.com.br
@history 10/11/2021, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Ajuste para impressão do layout da OP de acordo com o novo layout.
@history 13/07/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Inclusão da chamada para impressão da ordem de separação RPCPR008
/*/
user function RPCPA003()
Private   oSay1
Private   oSay3
Private   oGet1A
Private   oGet1B
Private   oGet2
Private   oGet4
Private   _lProc    := type("cFilAnt")=="U"
Private   _cRotina := "RPCPA003"
Private   oSay5
Private   oGet5
Private   oSay6
Private   oGet6
Private   oSay7
Private   oGet7
Private   oSay8
Private   oGet8
Private   oSay9
Private   oGet9
Private   oSay10
Private   oGet10
private oGroup1
Private oGroup2
Private oGroup3
Private oGroup4
Private oButCL
Private _aSize    := MsAdvSize()
Private cCadastro := "Ordem de produção"
Private cGet1A := space(12)
Private cGet1B := space(12)
Private cGet2 := space(12)
Private cGet3 := space(12)
Private cGet4 := 0
Private cGet5 := "01"
Private cGet6 := stod("")
Private cGet7 := stod("")
Private cGet8 := space(200)
Private cGet9 := space(12)
Private cGet10 := space(12)
Private cGet12 := space(12)
Private cGet14 := space(12)
Private cGet11 := space(12)
Private cGet13 := space(12)
Private cGet15 := space(12)
Private cUser := ""
Private _lRet := .T.

If _lProc
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" FUNNAME _cRotina tables "SB1", "SC2"
EndIf	
cGet6 := ddatabase
cGet7 := ddatabase	


PswOrder(1)
if PswSeek( __cUserId, .T. )   
	cUser:= __cUserId + " - " + PswRet()[1][4]
endif

	static oDlg
	
	DEFINE MSDIALOG oDlg TITLE ""    FROM 000, 000  TO 522,802        COLORS 0, 16777215          PIXEL
	
    @ _aSize[1]+009, _aSize[1]+015 GROUP oGroup2  TO 217,385 PROMPT "Geração Automática de Ordem de Produção"      OF oDlg COLOR  0, 16777215          PIXEL

    @ _aSize[1]+030, _aSize[1]+036 SAY   oSay1     PROMPT "Produto"                          SIZE 025, 007 OF oDlg COLORS 0, 16777215          PIXEL
    @ _aSize[1]+040, _aSize[1]+036 MSGET oGet1A    VAR    cGet1A  VALID AtuGe1()   F3 "SB1"   SIZE 060, 010 OF oDlg COLORS 0, 16777215          PIXEL
    @ _aSize[1]+040, _aSize[1]+097 MSGET oGet1B    VAR    cGet1B                 SIZE 275, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL


    @ _aSize[1]+070, _aSize[1]+036 SAY   oSay4     PROMPT "Quantidade a Produzir"               SIZE 100, 010 OF oDlg COLORS 0, 16777215  PIXEL
	@ _aSize[1]+080, _aSize[1]+038 MSGET oGet4     VAR    cGet4        Valid Positivo()     Picture "@E 999,999,999.9999"  SIZE 100, 010 OF oDlg COLORS 0, 16777215  PIXEL

    @ _aSize[1]+070, _aSize[1]+156 SAY   oSay5     PROMPT "Quantidade de Ordens"               SIZE 100, 010 OF oDlg COLORS 0, 16777215  PIXEL
	@ _aSize[1]+080, _aSize[1]+158 MSCOMBOBOX oGet5           VAR  cGet5 ITEMS {"01","02","03","04","05","06","07","08","09","10", "11","12","13","14","15","16","17","18","19","20", "21","22","23","24","25","26","27","28","29","30"} SIZE 100, 010 OF oDlg COLORS 0, 16777215  PIXEL



    @ _aSize[1]+111, _aSize[1]+036 SAY   oSay6     PROMPT "Previsão de Início"               SIZE 100, 010 OF oDlg COLORS 0, 16777215  PIXEL
	@ _aSize[1]+121, _aSize[1]+038 MSGET oGet6     VAR  cGet6          SIZE 100, 010 OF oDlg COLORS 0, 16777215  PIXEL

    @ _aSize[1]+111, _aSize[1]+156 SAY   oSay7     PROMPT "Previsão de Entrega"               SIZE 100, 010 OF oDlg COLORS 0, 16777215  PIXEL
	@ _aSize[1]+121, _aSize[1]+158 MSGET oGet7     VAR  cGet7   VALID AtuGe2()          SIZE 100, 010 OF oDlg COLORS 0, 16777215  PIXEL


    @ _aSize[1]+150, _aSize[1]+036 SAY   oSay8     PROMPT "Observação"               SIZE 200, 010 OF oDlg COLORS 0, 16777215  PIXEL
	@ _aSize[1]+160, _aSize[1]+038 MSGET oGet8     VAR  cGet8            SIZE 325, 030 OF oDlg COLORS 0, 16777215  PIXEL


    @ _aSize[1]+224, _aSize[1]+186 BUTTON oButCL PROMPT "Cancelar" 	SIZE 080, 015 OF oDlg ACTION EVAL({|| oDlg:End()})PIXEL
    @ _aSize[1]+224, _aSize[1]+301 BUTTON oButOK PROMPT "Confirmar"	SIZE 080, 015 OF oDlg ACTION Eval( {|| Processa({|lEnd| PCPA003(cGet1A,cGet3,cGet4,cGet6,cGet7, cGet8, cGet5) }, "["+_cRotina+"] Geração Automática de Ordens de Produção", "Processando...",.T.) } )  PIXEL


//	If !Empty(cGet1A) 
//		AtuGe1()
//	EndIf	
	
	oGet1A:SetFocus() 
	ACTIVATE MSDIALOG oDlg CENTERED




return

/*/{Protheus.doc} AtuGe1
Sub-rotina responsavel por atualizar o GetDados 1.
@author Livia Della Corte (ALL System Solutions)(ALL System Solutions)
@since 11/10/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function AtuGe1()

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1") + cGet1A ,.F.,.F.))

	if SB1->(Found())	
		cGet1A := UPPER(SB1->B1_COD)
		cGet1B := SB1->B1_DESC
		cGet2 := SB1->B1_TIPO
		cGet3 := SB1->B1_LOCPAD
	else
		dbSelectArea("SB1")
		SB1->(dbGoTop())
		SB1->(dbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1") + UPPER(cGet1A) ,.F.,.F.))
			if SB1->(Found())
				cGet1A := UPPER(SB1->B1_COD)
				cGet1B := SB1->B1_DESC
				cGet2 := SB1->B1_TIPO
				cGet3 := SB1->B1_LOCPAD		
			Else
				cGet1A := ""
				cGet1B := "Produto Não Encontrado!"	
			EndIf
	EndIf
	

Return .T.

Static function PCPA003(_cPRODUTO,_cLoc,_nQTD,_dIni, _dEntr, _ObsHIS, _nX )

Local _aSavArea   := GetArea()
Local _nOpc 	  := 3 //Variável de controle da função execauto - 1 = Pesquisa. 2 = Visualização. 3 = Inclusão. 4 = Alteração. 5 = Exclusão. 
Local _ObsOP  	  := ""		
//Local _nY	  	  := 0

Private cNumIni 	:= ""	
Private cNumFim 	:= ""	
Private lMsErroAuto := .F.
Private lRetOp 		:= .F.
Private MV_PAR01 	:= ""
Private MV_PAR02 	:= ""
Private _nY	  	  	:= 0

If Empty(_cPRODUTO) .or. Empty(_cLoc) .or. Empty(_nQTD) .or. Empty(_dIni) .or.  Empty(_dEntr) .or.  Empty(_nX)
	 MSGBOX("Preencha todos os campos",_cRotina+"_002","ALERT")
ElseIf _dIni  < ddatabase .or. _dEntr < ddatabase 
	 MSGBOX("Datas devem ser MAIOR/IGUAL a Data Base do Sistema!",_cRotina+"_003","ALERT")
ElseIf  _dEntr < _dIni 
	 MSGBOX("Data de Entrega MENOR que a Data de Previsão de Início!",_cRotina+"_004","ALERT")
	_dEntr := _dIni  
elseif !U_RPCPE019(_cPRODUTO)
	 MSGBOX("Problema Roteiro",_cRotina+"_004","ALERT")
Else
	FOR  _nY:=1 TO val(_nX)
	   	
	   	_ObsOP := "("+DtOc(date())+ " " + time()+ ") - OP.: " + cValtochar(_nY) +" de " + cValtochar(_nX) + " - [RPCPA003] Processo Automático. Responsável.: " + cUser +". " + CENT  + _ObsHIS
		_aRotAuto :=   {{"C2_PRODUTO" , _cPRODUTO  , Nil},;
						{"C2_LOCAL"   , _cLoc      , Nil},	;
						{"C2_QUANT"   , _nQTD , Nil},;
						{"C2_DATPRI"  , _dIni, Nil},;
						{"C2_DATPRF"  , _dEntr, Nil},;
						{"C2_EMISSAO" , ddataBase  , Nil},; 
						{"C2_OBS"     , "Incluido Por Processo Automático"     , Nil},; 
				    	{"C2_XOBSHIS" , _ObsOP     , Nil},; 
						{"AUTEXPLODE" , "S"        , Nil} }				
		//Inclui a ordem de produção
		MSExecAuto({|x,y| mata650(x,y)},_aRotAuto,_nOpc)
		If lMsErroAuto
			MsgStop("Atenção houve uma falha na rotina e isso impacta nos empenhos do sistema, informe ao Administrador imediatamente, os detalhes do erro serão exibidos a seguir.",_cRotina+"_003")
			MostraErro()
			Return()
		ElseIf !_lRet
			lRetOP := .F.	
			_lRet := .T.
			Return()
		Else
			lRetOP := .T.				
			If _nY == 1
				cNumIni:= cNumFim:= SC2->C2_NUM+ SC2->C2_ITEM+SC2->C2_SEQUEN
			Else
				cNumFim:= SC2->C2_NUM+ SC2->C2_ITEM+SC2->C2_SEQUEN
			EndIf		
		EndIf	
		dbSelectArea("SC2")
		SC2 ->(dbSetOrder(1))
		if SC2->(dbSeek(xFilial("SC2") + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN))
			RecLock("SC2",.F.) 
				SC2->C2_XDTVALI   := U_RESTE010(SC2->C2_DATPRF,SC2->C2_PRODUTO)
			SC2->(MsUnlock())
		Endif
	Next
	
	IF lRetOp
		If MsgYesNo("Ordens de Produção de: "+ cNumIni +" até: " + cNumFim +" Geradas! Deseja Imprimir?",_cRotina+"_004","ALERT")
			//U_RPCPR001(cNumIni,cNumFim)
			//U_RPCPR006(cNumIni,cNumFim)
			dbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			If SB1->(MsSeek(xFilial("SB1")+SC2->C2_PRODUTO,.T.,.F.))
				If !Empty(SB1->B1_OPERPAD)
					U_RPCPR013(cNumIni,cNumFim)		
					//_aOpImp := {}
				Else
					U_RPCPR006(cNumIni,cNumFim,)		
					//_aOpImp := {}
				EndIf
			EndIf
		EndIf		
		/* CONFORME ALINHADO COM O PAULO NÃO SERÁ IMPRESSA A ORDEM DE SEPARAÇÃO NO PRIMEIRA FASE DO PROJETO.
		If MsgYesNo("Ordens de Seração de: "+ cNumIni +" até: " + cNumFim +" Geradas! Deseja Imprimir?",_cRotina+"_005","ALERT")
			U_RPCPR008(cNumIni,cNumFim)
		EndIf
		*/
		cGet6 := ddatabase
		cGet7 := ddatabase
		cGet5 := "01"
		cGet4 := 0
		cGet1A := "       "
		cGet1B := cGet2 := cGet3 := cGet8 := cGet9 := cGet10 := cGet12 :=cGet14 := cGet11 := cGet13 := cGet15 := space(12)	
		oGet1A:SetFocus() 
	Else
		MsgStop("OPS não foram Geradas!",_cRotina+"_005")		
	EndIf
EndIf
	RestArea(_aSavArea)

return(lRetOP)

/*/{Protheus.doc} AtuGe1
Sub-rotina responsavel por atualizar o GetDados 2 conforme regra
@author Livia Della Corte (ALL System Solutions)(ALL System Solutions)
@since 11/10/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function AtuGe2()

If  cGet7 < cGet6  
	cGet7 := cGet6 
Endif	

Return .T.
