#include "PROTHEUS.CH"
#include "RWMAKE.CH"

#define _clrf CHR(13) + CHR(10)

/*/{Protheus.doc} SACI008
@description Ponto de entrada utilizado para que a data da comissão seja sempre a data da ultima movimentação do titulo (FINALIZAÇÃO). Vide também o Ponto de Entrada "FA070CA3".
@author Júlio Soares / Adriano Leonardo / Eduardo M. Antunes (ALL System Solutions)
@since 14/08/13
@version 1.0
@return nil, Sem retorno esperado.
@obs 26/09/2018 - Eduardo M. Antunes (ALL System Solutions) - Criada a funcionalidade de geração automática de título do tipo "NCC", quando da baixa dos títulos do tipo mencionado no parâmetro "MV_TIPOPG" (tipo "BOL"), a princípio.
@type function
@see https://allss.com.br
/*/
user function SACI008()
	Local    _aSavArea    := GetArea()
	Local    _aSavSE1     := SE1->(GetArea())
	Local    _aSavSE3     := SE3->(GetArea())
	Local    _aSavSE5     := SE5->(GetArea())
	Local    _aArray      := {}
	Local    _cNum        := (xFilial("SE3")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA))
	// - Alteração inserida em 20/01/2014 por Júlio Soares para que a comissão seja gerada com a data do crédito e não da baixa.
	// - AGUARDANDO DEFINIÇÃO DE DATA DE CORTE
	//Local _cBaixa   := (ddtcredito) //SE1->E1_DTACRED
	Local    _cBaixa      := SE1->E1_BAIXA
	Local    _cParcNCC    := SE1->E1_PARCELA
	Local    _cTipo       := AllTrim(SuperGetMv("MV_TIPOPG" ,,"BOL"))
	Private  lMsErroAuto  := .F.

	Private  _cRotina     := "SACI008"

	MotBaixa() //Chamada da função responsável por solicitar o motivo da baixa, quando esta não movimenta banco

	//If Upper(AllTrim(FunName()))=="FINA740" .OR. Upper(AllTrim(FunName()))=="FINA070"
		_cQry := " UPDATE " + RetSqlName("SE3")
		_cQry += " SET E3_EMISSAO   = '" + DTOS(_cBaixa)   + "' " + _clrf
		_cQry += " WHERE E3_FILIAL  = '" + xFilial("SE3")  + "' " + _clrf
		_cQry += "   AND E3_PREFIXO = '" + SE1->E1_PREFIXO + "' " + _clrf
		_cQry += "   AND E3_NUM     = '" + SE1->E1_NUM     + "' " + _clrf
		_cQry += "   AND E3_PARCELA = '" + SE1->E1_PARCELA + "' " + _clrf
		_cQry += "   AND E3_TIPO    = '" + SE1->E1_TIPO    + "' " + _clrf
		_cQry += "   AND D_E_L_E_T_ = '' " + _clrf
		If __cUserId == "000000"
			MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",_cQry)
		EndIf
		If TCSQLExec(_cQry) < 0
			MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_016")
		Else
			dbSelectArea("SE3")
			SE3->(dbSetOrder(1))
			If SE3->(dbSeek(_cNum)) //xFilial("SE3"))+ SE3->E3_SERIE + SE3->E3_NUM //+ SE1->E1_PARCELA
				While !SE3->(EOF()) .AND. (xFilial("SE3")+SE3->E3_PREFIXO+SE3->E3_NUM+SE3->E3_PARCELA) == _cNum
					If Empty(SE3->E3_DATA)
						while !Reclock("SE3",.F.) ; enddo
							SE3->E3_EMISSAO := _cBaixa
						SE3->(MSUNLOCK())
					EndIf
					dbSelectArea("SE3")
					SE3->(dbSetOrder(1))
					SE3->(dbSkip())
				EndDo
			Else
				If !AllTrim(SE1->E1_TIPO) <> 'NCC' // Condição incluida em 09/12/2013 por Júlio Soares após a apresentação do Alert nos recálculos de comissão.
					MSGBOX("TITULO DE COMISSÃO - " + _cNum + " - NÃO ENCONTRADO!",_cRotina+"_002","ALERT")
				EndIf
			EndIf
		EndIf
	//EndIf
	RestArea(_aSavSE1)
	RestArea(_aSavSE3)
	RestArea(_aSavSE5)
	RestArea(_aSavArea)
	If _cTipo == alltrim(SE1->E1_TIPO) 
		_aArray := { { "E1_FILIAL"   , SE1->E1_FILIAL             	, NIL },;
					 { "E1_PREFIXO"  , SE1->E1_PREFIXO             	, NIL },;
		             { "E1_NUM"      , SE1->E1_NUM           		, NIL },;
		             { "E1_PARCELA"  , _cParcNCC		        	, NIL },;
		             { "E1_TIPO"     , "NCC"             			, NIL },;
		             { "E1_CLIENTE"  , SE1->E1_CLIENTE		      	, NIL },;
		             { "E1_LOJA"     , SE1->E1_LOJA  		      	, NIL },;
		             { "E1_NATUREZ"  , SE1->E1_NATUREZ       	   	, NIL },;
		             { "E1_EMISSAO"  , SE5->E5_DTDISPO				, NIL },;
		             { "E1_VENCTO"   , SE5->E5_DTDISPO				, NIL },;
		             { "E1_VENCREA"  , DATAVALIDA(SE5->E5_DTDISPO)	, NIL },;
		             { "E1_VALOR"    , SE5->(E5_VALOR-E5_VLJUROS-E5_VLMULTA-E5_VLCORRE), NIL },;
		             { "E1_HIST"     , SE1->E1_HIST                  , NIL } }
		MsExecAuto( { |x,y| FINA040(x,y)} , _aArray, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
		If lMsErroAuto
			MsgStop("Atenção! Título 'NCC' não gerado. Veja os motivos a seguir!",_cRotina+"_001")
			MostraErro()
		Else
			MsgInfo("Título de crédito ao cliente gerado com sucesso (chave '"+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)+"')!",_cRotina+"_002")
		EndIf
	EndIf	
	RestArea(_aSavSE1)
	RestArea(_aSavSE3)
	RestArea(_aSavSE5)
	RestArea(_aSavArea)
return
/*/{Protheus.doc} MOTBAIXA
@description Sub-Função responsável por solicitar o motivo baixa para baixas que não movimentam banco (rotina principal: P.E.: SACI008).
@author Adriano Leonardo
@since 14/08/13
@version 1.0
@return nil, Sem retorno esperado.
@type function
@see https://allss.com.br
/*/
static function MOTBAIXA()
	//Trecho em desenvolvimento
	Local _aSavSE5 := SE5->(GetArea())
	Local _cMotBxa := ""
	Local _cDrive  := ""
	Local _cDir	   := CurDir() //Retorna o diretório configurado no INI do AppServer
	Local _cNome   := "SIGAADV"
	Local _cExt	   := ".MOT"

	dbSelectArea("SE5")
	_cMotBxa := SE5->E5_MOTBX
	//Faz a leitura do arquivo de configuração dos motivos de baixa
	FT_FUSE(_cDrive+_cDir+_cNome+_cExt)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	If !FT_FEOF()
		While !FT_FEOF()
			_cMotAux := SubStr(FT_FREADLN(),1 ,3)
			If _cMotBxa == _cMotAux
				_cValid := .T.
				_cMovBan := SubStr(FT_FREADLN(),15,1)
				If _cMovBan=='N'
					TelaMotivo() // Chamada da função responsável por abrir interface para digitação do motivo da baixa
				EndIf
				Exit
			EndIf
			FT_FSKIP()			
		EndDo
	EndIf
	FT_FUSE()
	RestArea(_aSavSE5)
return
/*/{Protheus.doc} TelaMotivo
@description Sub-Função para apresentação de Interface gráfica da solicitação do motivo da baixa. (rotina principal: SACI008 > MOTBAIXA).
@author Adriano Leonardo
@since 15/08/13
@version 1.0
@return lógico, .T. = Confirmado
@type function
@see https://allss.com.br
/*/
static function TelaMotivo()
	Local    _aSavArea := GetArea()
	Local    _lRet     := .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Implementado tela para solicitar motivo da baixa quanto esta não movimenta banco.            .³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Static oSay1
	Static oSay2
	Static lblInfo
	Static grpCart
	Static oCart
	Static grpObs
	Static oMotBx
	Static oCancela
	Static oConfirma
	Static oDlg
	Static _lRet     := .T.
	Static _cMotivo  := SE5->E5_MOTIVO
	DEFINE MSDIALOG oDlg TITLE "Informe o motivo da baixa" FROM 000, 000  TO 235, 450 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME// Inibe o botao "X" da tela
		oDlg:lEscClose := .F.//Não permite fechar a tela com o "Esc"

		//    @ 030, 002 SAY lblInfo PROMPT "Esta baixa não movimenta banco, favor informar o motivo." SIZE 063, 007 OF oDlg COLORS 0, 16777215 PIXEL	
    
		@ 030, 007 GROUP  grpObs    TO 095, 220 PROMPT "Motivo da Baixa"  OF oDlg COLOR  0, 16777215 PIXEL
		@ 038, 010 GET    oMotBx    VAR _cMotivo VALID !Empty(_cMotivo)   OF oDlg MULTILINE SIZE 207, 054 COLORS 0, 16777215 HSCROLL PIXEL
    
		@ 100, 157 BUTTON oConfirma PROMPT "&Confirmar" SIZE 060, 015 OF oDlg ACTION Confirmar() PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED
return _lRet
/*/{Protheus.doc} Confirmar
@description Sub-unção responsável por gravar o motivo da baixa. (rotina principal: SACI008 > MOTBAIXA > TelaMotivo).
@author Adriano Leonardo
@since 15/08/13
@version 1.0
@return lógico, .T. = Confirmado
@type function
@see https://allss.com.br
/*/
static function Confirmar()
	Local _aSavTemp := SE5->(GetArea())
	dbSelectArea("SE5")
	while !RecLock("SE5",.F.) ; enddo
		SE5->E5_MOTIVO 	:= _cMotivo
		SE5->E5_HORA	:= Time()
		SE5->E5_USUARIO	:= Alltrim(UsrRetName(__CUSERID))
	SE5->(MsUnLock())
	RestArea(_aSavTemp)
	Close(oDlg)
return