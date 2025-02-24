#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE _lEnd (CHR(13)+CHR(10))
/*/{Protheus.doc} RFATE035
@description Execblock chamado na tecla de atalho F7 para alterar a condição de pagamento e respons abilidade do vendedor na liberação de crédito do pedido.
@author Júlio Soares
@since 29/01/2013
@version 1.0
@type function
@return _lRet, logico, Conteúdo lógico fixo .T..
@see https://allss.com.br
/*/
user function RFATE035()
	Private oGroup
	Private CondPag
	Private _cCondPag
	Private _cDescPg
	Private cRespRepre
	Private gRespRepre
	Private Cancela
	Private Confirma
	Private _aSavArea   := GetArea()
	Private _aSavSA1    := SA1->(GetArea())
	Private _aSavSC5    := SC5->(GetArea())
	Private _aSavSC9    := SC9->(GetArea())
	Private _aSavSE4    := SE4->(GetArea())
	Private _cRotina	:= "RFATE035"
	Private ccCondPag   := ""
	Private ccDescPg    := ""
	Private nRespRepre  := ""
	Private _lRet       := .T.
	Private _lEnt       := CHR(10)+CHR(13)
	if AllTrim(FunName()) == "MATA450"
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		SC5->(MsSeek(xFilial("SC5")+SC9->C9_PEDIDO,.T.,.F.))
	elseif AllTrim(FunName()) == "RFATA026"
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		SC5->(MsSeek(xFilial("SC5")+(_cTbTmp1)->C9_PEDIDO,.T.,.F.))
	elseif AllTrim(FunName()) == "RFATA029"
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		SC5->(MsSeek(xFilial("SC5")+(_cTbTmp2)->C9_PEDIDO,.T.,.F.))
	endif
	ccCondPag  := SC5->C5_CONDPAG
	nRespRepre := IIF(AllTrim(SC5->C5_VENDRES)=="S","SIM","NAO")
	ccDescPg   := ValidSE4()
	if MSGBOX('DESEJA ALTERAR AS INFORMAÇÕES DO PEDIDO: '+ Alltrim(SC5->C5_NUM) +' ?',_cRotina + '_001','YESNO')
		dbselectArea("SC5")
		DEFINE MSDIALOG oDlg TITLE " Alteração do Pedido de Vendas '"+SC5->C5_NUM+"'." FROM 000, 000  TO 230, 350 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME// Inibe o botao "X" da tela
		oDlg:lEscClose := .F.	//Não permite fechar a tela com o "Esc"
		@ 005, 007 GROUP oGroup TO 095, 170 PROMPT "Alteração das informações do pedido"             OF oDlg COLOR 8404992, 16777215                      PIXEL
		@ 017, 012 SAY CondPag              PROMPT "Cond. Pagamento"                   SIZE 057, 012 OF oDlg COLORS 0, 16777215                           PIXEL
		@ 030, 012 MSGET _cCondPag          VAR ccCondPag                              SIZE 040, 012 OF oDlg COLORS 0, 16777215 F3 "SE4" VALID  ValidSE4() PIXEL
		@ 030, 057 MSGET _cDescPg           VAR ccDescPg                               SIZE 107, 012 OF oDlg COLORS 0, 16777215 READONLY WHEN .F.         PIXEL
		@ 050, 012 SAY cRespRepre           PROMPT "Responsabilidade do Representante" SIZE 140, 012 OF oDlg COLORS 0, 16777215                           PIXEL
		@ 067, 012 MSCOMBOBOX gRespRepre    VAR nRespRepre ITEMS {"SIM","NAO",""}      SIZE 052, 012 OF oDlg COLORS 0, 16777215                           PIXEL
		@ 097, 075 BUTTON Cancela           PROMPT "&Cancelar"                         SIZE 040, 015 OF oDlg ACTION EVAL({|| IIF(type("oDlg")=="O",oDlg:End(),nil) }) PIXEL
	//	@ 097, 075 BUTTON Cancela           PROMPT "&Cancelar"                         SIZE 040, 015 OF oDlg ACTION EVAL({|| MSGBOX("ALTERAÇÃO CANCELADA!!!",_cRotina+"_002","ALERT"), oDlg:End()})     PIXEL
		@ 097, 125 BUTTON Confirma          PROMPT "&Ok"                               SIZE 040, 015 OF oDlg ACTION Confirma()                            PIXEL
		ACTIVATE MSDIALOG oDlg CENTERED
	endif
	RestArea(_aSavSA1)
	RestArea(_aSavSE4)
	RestArea(_aSavSC5)
	RestArea(_aSavSC9)
	RestArea(_aSavArea)
return _lRet
/*/{Protheus.doc} Confirma (RFATE035)
@description Sub rotina de Gravação das informações.
@author Júlio Soares
@since 29/01/2013
@version 1.0
@type function
@return _lRet, logico, Conteúdo lógico fixo .T..
@see https://allss.com.br
/*/
static function Confirma()
	Local _aSvA      := GetArea()
	Local _aSvC5     := SC5->(GetArea())
	local _lExecUpd  := .T.
//	Local _lAltCPSA1 := .F.
	Local _cQUpd     := ""
	Local _cQUpd1    := ""
	local _cLogx     := "Condição de Pagamento Alterada. De: " + SC5->C5_CONDPAG + " Para:" + ccCondPag  + "."

If !EMPTY(ccCondPag)

    _cQUpd := " UPDATE " + RetSqlName("SC5")
	_cQUpd += " SET C5_CONDPAG  = '" + ccCondPag		      + "' " + _lEnt		
	_cQUpd += "   , C5_DESCOND  = '" + ccDescPg 		      + "' " + _lEnt
	_cQUpd += "   , C5_DESCPAG  = '" + ccDescPg 		      + "' " + _lEnt
	_cQUpd += "   , C5_VENDRES  = '" + SubStr(nRespRepre,1,1) + "' " + _lEnt
	_cQUpd += " WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM = '" + SC5->C5_NUM + "' AND D_E_L_E_T_ = '' " +_lEnt	
	if TCSQLExec(_cQUpd) < 0
		_lExecUpd := .F.
		MSGBOX("[TCSQLError] " + TCSQLError(),_cRotina+"_001",'STOP')
	endif
	_cQUpd := " UPDATE " + RetSqlName("SC9") 
	_cQUpd += " SET C9_DESCPAG  =  SC5.C5_DESCPAG " + _lEnt		
	_cQUpd += " FROM " + RetSqlName("SC9") + " SC9 WITH (NOLOCK) " + _lEnt
	_cQUpd += "      INNER JOIN " + RetSqlName("SC5") + " SC5 WITH (NOLOCK) ON SC5.C5_FILIAL = SC9.C9_FILIAL AND SC5.C5_NUM = C9_PEDIDO AND SC5.D_E_L_E_T_ = '' "  + _lEnt
	_cQUpd += " WHERE C9_FILIAL  = '"+xFilial("SC9")+"' AND C9_PEDIDO = '" + SC5->C5_NUM + "' " + _lEnt	
	_cQUpd += "   AND C9_NFISCAL = '' " + _lEnt	
	if TCSQLExec(_cQUpd) < 0
		_lExecUpd := .F.
		MSGBOX("[TCSQLError] " + TCSQLError(),_cRotina+"_001",'STOP')
	endif
	if ExistBlock("RFATL001") .AND. _lExecUpd
		U_RFATL001(	SC5->C5_NUM  ,;
					POSICIONE("SUA",8,xFilial("SUA")+SC5->C5_NUM,"UA_NUM"),;		//Índice 8 da SUA: UA_FILIAL+UA_NUMSC5
					_cLogx     ,;
					_cRotina    )
	endif
	MSGBOX(">>> INFORMAÇÕES DO PEDIDO '"+ SC5->C5_NUM +"' ALTERADAS COM SUCESSO!!! <<<",_cRotina+"_003","INFO")
	if (SC5->C5_CONDPAG <> ccCondPag) .AND. (SA1->A1_COND<>ccCondPag) .AND. MsgYesNo("Deseja alterar a condição de pagamento no cadastro do cliente "+SC5->C5_CLIENTE+" - LOJA:"+ SC5->C5_LOJACLI+" NOME:"+SC5->C5_NOMCLI+", de "+ SA1->A1_COND +" para '"+ccCondPag+"' (além de alterar no pedido '"+SC5->C5_NUM+"'), neste momento?",_cRotina+"_004")
		_cQUpd1 := " UPDATE  " + RetSqlName("SA1") 
		_cQUpd1 += " SET A1_COND      = '" + ccCondPag       + "' " + _lEnt		
		_cQUpd1 += " WHERE A1_COD     = '" + SC5->C5_CLIENTE + "' " + _lEnt	
		_cQUpd1 += "   AND A1_LOJA    = '" + SC5->C5_LOJACLI + "' " + _lEnt
		_cQUpd1 += "   AND D_E_L_E_T_ = '' "	
		//MemoWrite("\2.MemoWrite\LibCredito\"+_cRotina+SC5->C5_NUM +"_UPD_002.TXT",_cQUpd1)	
		if TCSQLExec(_cQUpd1) < 0
			MSGBOX("[TCSQLError] " + TCSQLError(),_cRotina+"_002",'STOP')
		endif
		MSGBOX(">>> CONDIÇÃO DE PAGAMENTO ALTERADA COM SUCESSO NO CADASTRO DO CLIENTE CODIGO:"+SC5->C5_CLIENTE+" - LOJA:"+SC5->C5_LOJACLI+" NOME:"+SC5->C5_NOMCLI+" !!! <<<",_cRotina+"_006","INFO")
	endif
	if type("oDlg")=="O"
		Close(oDlg)
	endif
Else
	MSGBOX(">>> Campo Vazio!!! <<<",_cRotina+"_006","STOP")
EndIf
	
	
	RestArea(_aSvC5)
	RestArea(_aSvA)
return  
/*/{Protheus.doc} ValidSE4 (RFATE035)
@description Sub Rotina de Validação da condição de pagamento.
@author Júlio Soares
@since 29/01/2013
@version 1.0
@type function
@return ccDescPg, caracter, Retorna a descrição da condição de pagamento.
@see https://allss.com.br
/*/
static function ValidSE4()
	dbSelectArea("SE4")
	SE4->(dbSetOrder(1)) // - E4_FILIAL+E4_CODIGO
	if SE4->(MsSeek(xFilial("SE4") + ccCondPag,.T.,.F.))
		ccDescPg := SE4->E4_DESCRI
	ElseIf ccCondPag == ""
		MSGBOX("Campo VAZIO!",_cRotina+"_003",'STOP')
	Else
		MSGBOX("Código Inválido!",_cRotina+"_004",'STOP')
	EndIf		
return ccDescPg