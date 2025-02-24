#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"

#DEFINE DMPAPER_A4 9 // A4 210 x 297 mm
#DEFINE ENT CHR(13)+CHR(10)
/*/{Protheus.doc} RFINR018
Rotina de Impressใo de Boleto Grแfico, previamentepreparado para o Banco Ita๚.
O nosso n๚mero aqui ้ gravado sem o c๓digo do Conv๊nio e sem o dํgito verificador,que ้ sempre calculado nesta rotina.
A Faixa Atual do Nosso N๚mero ้ considerada na tabela SEE como sendo a que jแ foi impressa.
As seguintes แreas podem ser localizadas neste fonte da seguinte maneira:
### REG.001 - Composi็ใo do Nosso N๚mero
### REG.002 - Composi็ใo dos valores e mensagens
### REG.003 - Composi็ใo do C๓digo de Barras
### REG.004 - Composi็ใo da Linha Digitแvel
### REG.005 - Processamento da Impressใo
@author Anderson Coelho / Julio Soares
@since 20/12/2013
@version P12
@type Function
@obs ษ necessแrio criar a pasta "BOLETOS" na Protheus_Data
@see https://allss.com.br
@history 24/08/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Corre็ใo de error_log conforme documenta็ใo ao longo do c๓digo-fonte.
/*/
user function RFINR018(cParSerie, cParNumero, lImprime, lEnvBol , lEnvRom , lOpcoes, cAnexo, cRomaneio, dDtInic, dDtFinal, cDanfe, cEndEmail)
//************************************************************
// INICIO
// ARCOLOR - Declara็ใo de varํaveis para nใo gerar error_log
// RODRIGO TELECIO em 24/08/2022
//************************************************************
local _x
// FIM
//************************************************************
/*
Local _aRotObr     := {	"RFINEBBD",;
						"RFINEBBE",;
						"RFINEBBI",;
						"RFINEBBJ",;
						"RFINEBBL",;
						"RFINEBIN",;
						"RFINEBBO",;
						"RFINEBIT",;
						"RFINEBBV",;
						"RFINEBIS" }
*/
Private oPrn
Private cTitulo		:= "Impressใo de Boleto"
Private _cRotina	:= "RFINR018"
Private cPerg		:= "RFINR018"
Private _cLogoEmp	:= FisxLogo("1")
Private _cLogoBco	:= ""
Private _cNomBco	:= ""
Private _cDgCart	:= ""
Private NOSSONUM	:= ""
Private _cDVNN		:= ""
Private _cDac		:= ""
Private CLINHA		:= ""
Private CBARRA		:= ""
Private MsgInstr01	:= ""
Private MsgInstr02	:= ""
Private MsgInstr03	:= ""
Private _cMensJur	:= ""
Private _cMensDesc	:= ""

//Inํcio - Trecho adicionado por Adriano Leonardo em 28/02/2014 - Inclusใo de envio por e-mail
Private _aAnexo    := {}
Private _aArquivo  := {}
Private _nQtdBole  := 0
Default lImprime   := .T.
Private _lImprime  := lImprime
Default lOpcoes	   := .T.
Private _lOpcoes   := lOpcoes
Default lEnvBol	   := .F.
Private _lEnvBol   := lEnvBol
Default lEnvRom	   := .F.
Private _lEnvRom   := lEnvRom
Default cAnexo	   := ""
Private _cAnexoAux := cAnexo
Default cRomaneio  := ""
Private _cRomaneio := cRomaneio
Default cDanfe	   := ""
Private _cDanfe	   := cDanfe
Default cEndEmail  := ""
Default dDtInic	   := Stod("20130101")
Private	_cDtInici  := dDtInic
Default dDtFinal   := Stod("20991231")
Private	_cDtFinal  := dDtFinal
Private _cEndEmail := cEndEmail
Private _cPrefixo  := cParSerie
Private _cNumTitu  := cParNumero
Private _lAlerta   := .T.
Private _lCancBole := .F.
Private _cNumAux   := ""
Private _lCancela  := .F.
Private _lCancRoma := .F.
Private	_dData     := ""
Private _cPedido   := ""
//************************************************************
// INICIO
// ARCOLOR - Declara็ใo de varํaveis para nใo gerar error_log
// RODRIGO TELECIO em 24/08/2022
//************************************************************
private _cCliente  := ""
private _cLojaCli  := ""
// FIM
//************************************************************
//Verifica se o boleto serแ enviado por e-mail
If _lEnvBol
	Private _cCaminho  := IIF(ExistDir("\boletos\"),"\boletos\","C:\Windows\Temp\")
	Private _cArqBol   := _cCaminho+"BOL_"+AllTrim(_cNumTitu)+"_"+AllTrim(_cPrefixo)
EndIf
//Final  - Trecho adicionado por Adriano Leonardo em 28/02/2014 - Inclusใo de envio por e-mail
Private _lValidMail := .T.

// FB - RELEASE 12.1.23
Private _bROTINA := "ExistBlock(_aRotObr[_x])"
Private _aRotObr := ""
// FIM FB

For _x := 1 To Len(_aRotObr)
	/* FB - RELEASE 12.1.23
	If !ExistBlock(_aRotObr[_x])
	*/
	If !&(_bROTINA)
		MsgAlert("Problemas! Solicite ao administrador que compile a seguinte rotina: " + _aRotObr[_x],_cRotina+"_000")
		Return()
	EndIf
Next

ValidPerg()
// - Trecho chamado pela impressใo da Danfe
If _lImprime .And. _lOpcoes
	If Pergunte(cPerg,.T.)
		If !Empty(MV_PAR04) .AND. !Empty(MV_PAR13) .AND. !Empty(MV_PAR14) .AND. !Empty(MV_PAR15) .AND. !Empty(MV_PAR16)
			Processa( { |lEnd| ImpBolIt(lEnd) }, cTitulo, "Processando informa็๕es...",.T.)			
		Else
			MsgAlert("Aten็ใo! Parโmetros preenchidos incorretamente. Opera็ใo abortada!",_cRotina+"_003")
		EndIf
	EndIf
// - Trecho para envio por e-mail chamado na rotina manual de impressใo.
Else
	Pergunte(cPerg,.F.)
	If !Empty(_cNumTitu)
		_aSavTmp := SE1->(GetArea())
		_cEmissao:= STOD("")
		_cPedido := ""
		_cCliente:= ""
		_cLojaCli:= ""
		_cInstru1:= ""
		_cInstru2:= ""
		_cQry2 := " SELECT DISTINCT E1_CLIENTE,E1_LOJA,E1_PEDIDO,E1_EMISSAO,E1_INSTR1,E1_INSTR2 " +ENT
		_cQry2 += " FROM " + RetSqlName("SE1") + " SE1 (NOLOCK)" +ENT
		_cQry2 += " WHERE SE1.D_E_L_E_T_ = '' " +ENT
		_cQry2 += " AND SE1.E1_FILIAL  = '" + xFilial("SE1") + "' " +ENT
		_cQry2 += " AND SE1.E1_PREFIXO = '" + _cPrefixo + "' " +ENT
		_cQry2 += " AND SE1.E1_NUM     = '" + _cNumTitu + "' " +ENT
		_cQry2 += " AND SE1.E1_TIPO    = 'NF' " +ENT
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry2),"TRATMP",.T.,.F.)
		dbSelectArea("TRATMP")
		If !(TRATMP->(EOF()))
			_cCliente := TRATMP->E1_CLIENTE
			_cLojaCli := TRATMP->E1_LOJA
			_cEmissao := TRATMP->E1_EMISSAO
			_cPedido  := TRATMP->E1_PEDIDO
			_cInstru1 := TRATMP->E1_INSTR1
			_cInstru2 := TRATMP->E1_INSTR2
		EndIf
		TRATMP->(dbCloseArea())
		RestArea(_aSavTmp)
		MV_PAR01 := Space(TamSx3("E1_PREFIXO")[01])						//"01","Prefixo de         ?
		MV_PAR02 := Replicate('Z',TamSx3("E1_PREFIXO")[01])				//"02","Prefixo ate        ?
		MV_PAR03 := Space(TamSx3("E1_NUM")[01])							//"03","Numero de          ?
		MV_PAR04 := Replicate('Z',TamSx3("E1_NUM")[01])					//"04","Numero ate         ?
		MV_PAR05 := Space(TamSx3("E1_NUMBOR")[01])						//"05","Bordero de         ?
		MV_PAR06 := Replicate('Z',TamSx3("E1_NUMBOR")[01])				//"06","Bordero ate        ?
		MV_PAR07 := _cEmissao											//"07","Emissao de         ?
		MV_PAR08 := _cEmissao											//"08","Emissao ate        ?
		MV_PAR11 := _cPedido											//"11","De pedido          ?
		MV_PAR12 := _cPedido											//"12","At้ pedido         ?
	Else
		MV_PAR01 := _cPrefixo											//"01","Prefixo de         ?
		MV_PAR02 := _cPrefixo											//"02","Prefixo ate        ?
		MV_PAR03 := _cNumTitu											//"03","Numero de          ?
		MV_PAR04 := _cNumTitu											//"04","Numero ate         ?
		MV_PAR05 := Space(TamSx3("E1_NUMBOR")[01])						//"05","Bordero de         ?
		MV_PAR06 := Replicate('Z',TamSx3("E1_NUMBOR")[01])				//"06","Bordero ate        ?
		MV_PAR07 := "20130101"											//"07","Emissao de         ?
		MV_PAR08 := "20493112"											//"08","Emissao ate        ?
		MV_PAR11 := Space(TamSx3("E1_PEDIDO")[01])						//"11","De pedido          ?
		MV_PAR12 := Replicate('Z',TamSx3("E1_PEDIDO")[01])				//"12","At้ pedido         ?
	EndIf
	MV_PAR09 := _cDtInici											//"09","Vencimento de      ?
	MV_PAR10 := _cDtFinal											//"10","Vencimento Ate     ?
    If (Alltrim(_cCarteir)) $ ("109/112")
		MV_PAR13 := Padr(SuperGetMv("MV_BCIT109",,"341"		),TamSx3("EE_CODIGO" )[01])		//"13","Banco              ?
		MV_PAR14 := Padr(SuperGetMv("MV_AGIT109",,"6748"	),TamSx3("EE_AGENCIA")[01])		//"14","Agencia            ?
		MV_PAR15 := Padr(SuperGetMv("MV_CCIT109",,"08277"	),TamSx3("EE_CONTA"  )[01])		//"15","Conta              ?
		MV_PAR16 := Padr(SuperGetMv("MV_SCIT109",,"001"		),TamSx3("EE_SUBCTA" )[01])		//"16","Sub-Conta          ?
	EndIF
	MV_PAR17 := ""													//"17","Msg 01 s๓ p/ boleto?
	MV_PAR18 := ""													//"18","Msg 02 s๓ p/ boleto?
	If !Empty(MV_PAR04) .AND. !Empty(MV_PAR13) .AND. !Empty(MV_PAR14) .AND. !Empty(MV_PAR15) .AND. !Empty(MV_PAR16)
		Processa( { |lEnd| ImpBolIt(lEnd) }, cTitulo, "Processando informa็๕es...",.T.)		
	EndIf
EndIf
If _lValidMail	
	// - Trecho adicionado para envio por e-mail
	If (_lEnvBol .And. !_lCancBole) .And. (_lEnvRom .And. !_lCancRoma) 
		MsAguarde({|lEnd|SendMail()  },"Aguarde...","Enviando romaneio e boleto(s) para o cliente...",.T.)
	ElseIf _lEnvRom  .And. !_lCancRoma
		MsAguarde({|lEnd|SendMail()  },"Aguarde...","Enviando romaneio para o cliente...",.T.)
	ElseIf _lEnvBol  .And. !_lCancBole
		MsAguarde({|lEnd|SendMail()  },"Aguarde...","Enviando boleto(s) para o cliente...",.T.)
	ElseIf _lEnvBol
		MsgBox("Nenhum e-mail a ser enviado para o cliente!" ,_cRotina + "_004","ALERT")
	EndIf
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณImpBolIt  บAutor  ณJ๚lio Soares          Data ณ 12/09/2015  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Processamento de impressใo da rotina.                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpBolIt(lEnd)
//************************************************************
// INICIO
// ARCOLOR - Declara็ใo de varํaveis para nใo gerar error_log
// RODRIGO TELECIO em 24/08/2022
//************************************************************
local _nLoop
local _nF
// FIM
//************************************************************
// FB - RELEASE 12.1.23
Local _lRFINEBBV  := EXISTBLOCK('RFINEBBV')
Local _lRFINEBBJ  := EXISTBLOCK('RFINEBBJ')
Local _lRFINEBBD  := EXISTBLOCK('RFINEBBD') 
Local _lRFINEBBL  := EXISTBLOCK('RFINEBBL')
Local _lRFINEBBI  := EXISTBLOCK("RFINEBBI") 
Local _bEENOMECOM := "Type('SEE->EE_NOMECOM')"
Local _lRFATL001  := ExistBlock("RFATL001")
// FIM FB

local nNewFator := 0

If !(MV_PAR13) $ '341'
	MsgAlert("Este banco nใo pode ser utilizado para a impressใo deste boleto. Por favor verifique!" ,_cRotina+"_005")
	Return()
Else
	dbSelectArea("SEE")
	dbSetOrder(1)
	If !dbSeek(xFilial("SEE") + MV_PAR13 + MV_PAR14 + MV_PAR15 + MV_PAR16)
		MsgAlert("Arquivo de parโmetros banco/cnab incorreto. Verifique banco/ag๊ncia/conta/sub-conta.",_cRotina+"_006")
		Return
	ElseIf UPPER(AllTrim(SEE->EE_EXTEN)) <> "REM"
		MsgAlert("Dados nใo se referem a configura็ใo de remessa! Verifique os parโmetros!",_cRotina+"_007")
		Return
	ElseIf Empty(SEE->EE_CODEMP) .OR. Len(Alltrim(SEE->EE_CODEMP))<4 .OR. Len(Alltrim(SEE->EE_CODEMP))>7
		MsgAlert("C๓digo do Conv๊nio incorreto!",_cRotina+"_008")
		Return
	ElseIf Empty(SEE->EE_CODCART)
		MsgAlert("Carteira nใo preenchida nos parโmetros bancos!",_cRotina+"_009")
		Return
	EndIf
	// - Incluido por J๚lio Soares em 21/03/2014 para valida็ใo das carteiras preenchidas
	dbSelectArea("SE1")
	SE1->(dbSetOrder(1)) // - INSERIR VALIDAวรO PARA VERIFICAR TAMBษM A INSTRUวรO DO TอTULO
	If SE1->(dbSeek(xFilial("SE1") + MV_PAR01 + MV_PAR03)) .AND. (SE1->E1_TIPO <> "NCC") // - Implementado tratamento para NCC
		If Empty(SE1->E1_INSTR1)
			MsgAlert("A instru็ใo primแria de cobran็a do tํtulo nใo estแ preenchida, Verifique...",_cRotina+"_017")
			Return
		ElseIf Empty(SE1->E1_INSTR2)
			MsgAlert("A instru็ใo secundแria de cobran็a do tํtulo nใo estแ preenchida, Verifique...",_cRotina+"_018")
			Return
        EndIf	
	EndIf
	// - FIM
EndIf
If Len(AllTrim(SEE->EE_AGENCIA))>4
	If "-"$AllTrim(SEE->EE_AGENCIA)
		_cAg := AllTrim(SEE->EE_AGENCIA)
	Else
		_cAg := SubStr(SEE->EE_AGENCIA,1,4) + "-" + SubStr(SEE->EE_AGENCIA,5,1)
	EndIf
Else
	_cAg := AllTrim(SEE->EE_AGENCIA) + "-" + AllTrim(SEE->EE_DVAGE)
EndIf
If "-"$AllTrim(SEE->EE_CONTA  )
	_cCC := AllTrim(SEE->EE_CONTA  )
ElseIf Empty(SEE->EE_DVCTA)
	_cCC := SubStr(AllTrim(SEE->EE_CONTA),1,Len(AllTrim(SEE->EE_CONTA))-1)+"-"+SubStr(AllTrim(SEE->EE_CONTA),Len(AllTrim(SEE->EE_CONTA))-1,1)
Else
	_cCC := AllTrim(SEE->EE_CONTA  ) + "-" + AllTrim(SEE->EE_DVCTA)
EndIf
dbSelectArea("SE1")
_cQry := "SELECT R_E_C_N_O_ RECSE1 " +ENT
_cQry += "FROM " + RetSqlName("SE1") + " SE1 (NOLOCK) " +ENT
_cQry += "WHERE SE1.D_E_L_E_T_ = '' " +ENT
_cQry += "  AND SE1.E1_FILIAL = '" + xFilial("SE1")  + "' " +ENT
_cQry += "  AND SE1.E1_PREFIXO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " +ENT
_cQry += "  AND SE1.E1_NUM     BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " +ENT
_cQry += "  AND SE1.E1_NUMBOR  BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " +ENT
If _lImprime .And. _lOpcoes
	_cQry += "  AND SE1.E1_EMISSAO BETWEEN '" + DTOS(MV_PAR07)  + "' AND '" + DTOS(MV_PAR08) + "' " +ENT
Else
	If Empty(MV_PAR07)
		_cQry += "  AND SE1.E1_EMISSAO BETWEEN '19000101' AND '19000101' "  +ENT// - Inserido para bloquear error log quando MV_PAR07 estแ nulo
	Else
		_cQry += "  AND SE1.E1_EMISSAO BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' " +ENT
	EndIf	
EndIf
_cQry += "  AND SE1.E1_VENCTO  BETWEEN '" + DTOS(MV_PAR09)  + "' AND '" + DTOS(MV_PAR10) + "' " +ENT 
_cQry += "  AND SE1.E1_PEDIDO  BETWEEN '" + MV_PAR11  		+ "' AND '" + MV_PAR12 		 + "' " +ENT
_cQry += "  AND SE1.E1_CARTEIR       = '" + SEE->EE_CODCART + "' " +ENT
_cQry += "  AND SE1.E1_SALDO         > 0 " +ENT
_cQry += "  AND SE1.E1_TIPO         <> 'CH'  " +ENT
_cQry += "  AND SE1.E1_TIPO         <> 'NCC' " +ENT
_cQry += "  AND (SE1.E1_PORTADO      = '' OR SE1.E1_PORTADO = '" + MV_PAR13        + "' )" +ENT
_cQry += "  AND (SE1.E1_AGEDEP       = '' OR SE1.E1_AGEDEP  = '" + MV_PAR14        + "' )" +ENT
_cQry += "  AND (SE1.E1_CONTA        = '' OR SE1.E1_CONTA   = '" + MV_PAR15        + "' )" +ENT
_cQry += "ORDER BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA " +ENT
/*
If __cUserId $ "000000|000155"
	MemoWrite("\2.MemoWrite\"+_cRotina +"-"+SE1->(E1_NUM)+"_QRY1.TXT",_cQry)
EndIf
*/
If CHKFILE("SE1TMP")
	SE1TMP->(dbCloseArea())
EndIf
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"SE1TMP",.T.,.F.)
dbSelectArea("SE1TMP")
If SE1TMP->(EOF())
	SE1TMP->(dbCloseArea())
	MsgAlert("Nใo hแ dados a serem impressos!",_cRotina+"_010")
	_lValidMail := .F.
	Return
EndIf
ProcRegua(SE1TMP->(RecCount()))
_cNomBco   := AllTrim(SEE->EE_DESCBCO)		//Descri็ใo do Banco a ser impresso no boleto
_cLogoBco  := AllTrim(SEE->EE_LOGO)			//Caminho do logotipo BMP do banco
oFont08    := TFont():New( "Arial"       ,,08,,.F.,,,,,.F. )
oFont08B   := TFont():New( "Arial"       ,,08,,.T.,,,,,.F. )
oFont12    := TFont():New( "Courier New" ,,09,,.t.,,,,,.f. )
oFont13    := TFont():New( "Arial"       ,,06,,.f.,,,,,.f. )
oFont14    := TFont():New( "Arial"       ,,08,,.F.,,,,,.f. )
oFont14B   := TFont():New( "Arial"       ,,14,,.T.,,,,,.F. )
oFont15    := TFont():New( "Arial"       ,,10,,.t.,,,,,.f. )
oFont17    := TFont():New( "Arial"       ,,14,,.T.,,,,,.f. )
oFont18    := TFont():New( "Arial"       ,,09,,.T.,,,,,.f. )
oFont20    := TFont():New( "Arial Black" ,,16,,.T.,,,,,.f. )
oFont21    := TFont():New( "Arial"       ,,18,,.T.,,,,,.f. )
oFont22B   := TFont():New( "Arial"       ,,22,,.T.,,,,,.F. )
oFont24    := TFont():New( "Arial"       ,,07,,.T.,,,,,.f. )
oPrn       := TMSPrinter():New()	// Declara o objeto a ser impresso
oPrn:SetPaperSize(DMPAPER_A4)		// Tamanho/Tipo do Papel
oPrn:SetPortRait()					// Impressใo em formato "retrato"
If _lImprime .And. _lOpcoes .And. _nQtdBole>0
	oPrn:Setup() //para configurar impressora, quando impressใo normal (sem ser em arquivo jpeg)
EndIf
oPrn:SetPaperSize(DMPAPER_A4)		// Tamanho/Tipo do Papel
oPrn:SetPortRait()					// Impressใo em formato "retrato"

dbSelectArea("SE1TMP")
While !SE1TMP->(EOF())
	dbSelectArea("SE1")
	SE1->(dbSetOrder(1))
	SE1->(dbGoTo(SE1TMP->RECSE1))
	IncProc("Processando " + SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA + "...")
	//Inํcio - Trecho adicionado por Adriano Leonardo em 06/03/2014
	If !Empty(SE1->E1_ENVMAIL) .And. (_lEnvBol .Or. _lEnvRom) .And. _lAlerta
		If !MsgYesNo("Aten็ใo! O(s) boleto(s) jแ foram enviados ao cliente anteriormente, deseja envia-lo(s) novamente?",_cRotina+"_016")
			_lCancela := .T.
			Return()
		Else
			_lAlerta :=	.F.
		EndIf
	EndIf
	//Final  - Trecho adicionado por Adriano Leonardo em 06/03/2014
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	If !SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.,.F.))
		MsgAlert("Problemas na localiza็ใo do cliente " + SE1->E1_CLIENTE+SE1->E1_LOJA + " do tํtulo " + SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA + ". Portanto, este nใo serแ impresso!",_cRotina+"_011")
		dbSelectArea("SE1TMP")
		SE1TMP->(dbSkip())
		Loop
	EndIf
	//### REG.001 - Composi็ใo do Nosso N๚mero
	NOSSONUM := ""
	_cDVNN   := ""
	_lContin := .T.
	//Cแlculo do Nosso N๚mero e do Dํgito Verificador, quando for o caso
	U_RFINEBIS(@NOSSONUM,@_cDVNN,@_lContin)
	If !_lContin
		dbSelectArea("SE1TMP")
		SE1TMP->(dbSkip())
		Loop
	EndIf
	//Fim do Cแlculo do Nosso N๚mero
	//### REG.002 - Composi็ใo dos valores e mensagens
	//Inํcio do c๔mputo dos valores
	/* FB - RELEASE 12.1.23
	_nSaldo     := IIF(EXISTBLOCK("RFINEBBV"),U_RFINEBBV()   ,SE1->(E1_SALDO-E1_SDDECRE+E1_SDACRES))
	_nJuros     := IIF(EXISTBLOCK("RFINEBBJ"),U_RFINEBBJ()   ,SE1->(E1_SALDO-E1_SDDECRE+E1_SDACRES)*(SE1->E1_PORCJUR/100))
	_nDescon    := IIF(EXISTBLOCK("RFINEBBD"),U_RFINEBBD('V'),IIF(EXISTBLOCK("RFINEBBV"),U_RFINEBBV(),SE1->(E1_SALDO-E1_SDDECRE+E1_SDACRES))*(SE1->E1_DESCFIN/100))
	//Fim do c๔mputo dos valores
	//Coleta das informa็๕es do cliente

	//Dados relativos a endere็o na rotina RFINEBBL:
	//2=Endere็o com n๚mero;E=Endere็o;N=N๚mero;C=Complemento;B=Bairro;M=Municํpio;U=Estado;P=CEP
	_cCEPc   := AllTrim(IIF(EXISTBLOCK("RFINEBBL"),U_RFINEBBL("P"),IIF(!Empty(SA1->A1_CEPC).AND.!Empty(SA1->A1_ESTC).AND.!Empty(SA1->A1_ENDCOB).AND.!Empty(SA1->A1_BAIRROC),SA1->A1_CEPC   ,SA1->A1_CEP    )))
	_cEndc   := AllTrim(IIf(!Empty(SA1->A1_ENDCOB),AllTrim(FisGetEnd(SA1->A1_ENDCOB,SA1->A1_ESTC)[1]) + ", " + AllTrim(IIF(!Empty(FisGetEnd(SA1->A1_ENDCOB,SA1->A1_ESTC)[3]),FisGetEnd(SA1->A1_ENDCOB,SA1->A1_ESTC)[3],"S/N")),AllTrim(FisGetEnd(SA1->A1_END   ,SA1->A1_EST )[1]) + ", " + AllTrim(IIF(!Empty(FisGetEnd(SA1->A1_END   ,SA1->A1_EST )[3]),FisGetEnd(SA1->A1_END   ,SA1->A1_EST )[3],"S/N")) ) )
	_cEndc   := AllTrim(IIF(EXISTBLOCK("RFINEBBL"),U_RFINEBBL("2"),_cEndc))
	_cBair   := AllTrim(IIF(EXISTBLOCK("RFINEBBL"),U_RFINEBBL("B"),IIF(!Empty(SA1->A1_CEPC).AND.!Empty(SA1->A1_ESTC).AND.!Empty(SA1->A1_ENDCOB).AND.!Empty(SA1->A1_BAIRROC),SA1->A1_BAIRROC,SA1->A1_BAIRRO )))
	_cMunc   := AllTrim(IIF(EXISTBLOCK("RFINEBBL"),U_RFINEBBL("M"),IIF(!Empty(SA1->A1_CEPC).AND.!Empty(SA1->A1_ESTC).AND.!Empty(SA1->A1_ENDCOB).AND.!Empty(SA1->A1_BAIRROC),SA1->A1_MUNC   ,SA1->A1_MUN    )))
	_cEstc   := AllTrim(IIF(EXISTBLOCK("RFINEBBL"),U_RFINEBBL("U"),IIF(!Empty(SA1->A1_CEPC).AND.!Empty(SA1->A1_ESTC).AND.!Empty(SA1->A1_ENDCOB).AND.!Empty(SA1->A1_BAIRROC),SA1->A1_ESTC   ,SA1->A1_EST    )))
	_cCompl  := AllTrim(IIF(EXISTBLOCK("RFINEBBL"),U_RFINEBBL("C"),IIF(!Empty(SA1->A1_CEPC).AND.!Empty(SA1->A1_ESTC).AND.!Empty(SA1->A1_ENDCOB).AND.!Empty(SA1->A1_BAIRROC),SA1->A1_COMPLC ,SA1->A1_COMPLEM)))
 	*/

	_nSaldo     := IIF(_lRFINEBBV,U_RFINEBBV()   ,SE1->(E1_SALDO-E1_SDDECRE+E1_SDACRES))
	_nJuros     := IIF(_lRFINEBBJ,U_RFINEBBJ()   ,SE1->(E1_SALDO-E1_SDDECRE+E1_SDACRES)*(SE1->E1_PORCJUR/100))
	_nDescon    := IIF(_lRFINEBBD,U_RFINEBBD('V'),IIF(_lRFINEBBV,U_RFINEBBV(),SE1->(E1_SALDO-E1_SDDECRE+E1_SDACRES))*(SE1->E1_DESCFIN/100))
	//Fim do c๔mputo dos valores
	//Coleta das informa็๕es do cliente

	//Dados relativos a endere็o na rotina RFINEBBL:
	//2=Endere็o com n๚mero;E=Endere็o;N=N๚mero;C=Complemento;B=Bairro;M=Municํpio;U=Estado;P=CEP
	_cCEPc   := AllTrim(IIF(_lRFINEBBL,U_RFINEBBL("P"),IIF(!Empty(SA1->A1_CEPC).AND.!Empty(SA1->A1_ESTC).AND.!Empty(SA1->A1_ENDCOB).AND.!Empty(SA1->A1_BAIRROC),SA1->A1_CEPC   ,SA1->A1_CEP    )))
	_cEndc   := AllTrim(IIf(!Empty(SA1->A1_ENDCOB),AllTrim(FisGetEnd(SA1->A1_ENDCOB,SA1->A1_ESTC)[1]) + ", " + AllTrim(IIF(!Empty(FisGetEnd(SA1->A1_ENDCOB,SA1->A1_ESTC)[3]),FisGetEnd(SA1->A1_ENDCOB,SA1->A1_ESTC)[3],"S/N")),AllTrim(FisGetEnd(SA1->A1_END   ,SA1->A1_EST )[1]) + ", " + AllTrim(IIF(!Empty(FisGetEnd(SA1->A1_END   ,SA1->A1_EST )[3]),FisGetEnd(SA1->A1_END   ,SA1->A1_EST )[3],"S/N")) ) )
	_cEndc   := AllTrim(IIF(_lRFINEBBL,U_RFINEBBL("2"),_cEndc))
	_cBair   := AllTrim(IIF(_lRFINEBBL,U_RFINEBBL("B"),IIF(!Empty(SA1->A1_CEPC).AND.!Empty(SA1->A1_ESTC).AND.!Empty(SA1->A1_ENDCOB).AND.!Empty(SA1->A1_BAIRROC),SA1->A1_BAIRROC,SA1->A1_BAIRRO )))
	_cMunc   := AllTrim(IIF(_lRFINEBBL,U_RFINEBBL("M"),IIF(!Empty(SA1->A1_CEPC).AND.!Empty(SA1->A1_ESTC).AND.!Empty(SA1->A1_ENDCOB).AND.!Empty(SA1->A1_BAIRROC),SA1->A1_MUNC   ,SA1->A1_MUN    )))
	_cEstc   := AllTrim(IIF(_lRFINEBBL,U_RFINEBBL("U"),IIF(!Empty(SA1->A1_CEPC).AND.!Empty(SA1->A1_ESTC).AND.!Empty(SA1->A1_ENDCOB).AND.!Empty(SA1->A1_BAIRROC),SA1->A1_ESTC   ,SA1->A1_EST    )))
	_cCompl  := AllTrim(IIF(_lRFINEBBL,U_RFINEBBL("C"),IIF(!Empty(SA1->A1_CEPC).AND.!Empty(SA1->A1_ESTC).AND.!Empty(SA1->A1_ENDCOB).AND.!Empty(SA1->A1_BAIRROC),SA1->A1_COMPLC ,SA1->A1_COMPLEM)))

 	If Len(AllTrim(SA1->A1_CGC)) == 14
		_cCnpj := "CNPJ: " + SubStr(SA1->A1_CGC,1,2)+"."+SubStr(SA1->A1_CGC,3,3)+"."+SubStr(SA1->A1_CGC,6,3)+"/"+SubStr(SA1->A1_CGC,9,4)+"-"+SubStr(SA1->A1_CGC,13,2)
	ElseIf Len(AllTrim(SM0->M0_CGC)) == 11
		_cCnpj := "CPF: "  + SubStr(SA1->A1_CGC,1,3)+"."+SubStr(SA1->A1_CGC,4,3)+"."+SubStr(SA1->A1_CGC,7,3)+"-"+SubStr(SA1->A1_CGC,10,2)
	Else
		_cCnpj := "CPF/CNPJ: " + AllTrim(SA1->A1_CGC)
	EndIf
	// - T้rmino das informa็๕es do cliente         
	// - Inํcio da แrea de mensagens para o boleto
	// - Mensagem relativa a juros
	_cMensJur   := ""
	If _nJuros<>0
		_cMensJur := "Ap๓s o vcto., cobrar R$ "+AllTrim(Transform(_nJuros,"@E 999,999.99"))+" por dia de atraso."
	EndIf
	//Fim da mensagem relativa a juros
	//Mensagem relativa a desconto
	_cMensDesc  := ""
	If _nDescon > 0
		_cMensDesc := "Desconto/Abatimento at้ " + DTOC(SE1->(E1_VENCTO-E1_DIADESC)) + ": R$ " + AllTrim(Transform(_nDescon,"@E 999,999.99")) + " fixo."
	EndIf
	//Fim da mensagem relativa a desconto
	//Instru็ใo bancแria 01
	MsgInstr01 := ""
	_cOcorr    := IIF(!EMPTY(SE1->E1_OCORREN),SE1->E1_OCORREN,SEE->EE_OCORREN)

	/* FB - RELEASE 12.1.23
	_cInstr01  := IIF(EXISTBLOCK("RFINEBBI"),U_RFINEBBI("1"),IIF(Empty(SE1->E1_INSTR1),SEE->EE_INSTPRI,SE1->E1_INSTR1))
	*/
	_cInstr01  := IIF(_lRFINEBBI,U_RFINEBBI("1"),IIF(Empty(SE1->E1_INSTR1),SEE->EE_INSTPRI,SE1->E1_INSTR1))

/* - Trecho desativado em 05/07/2016 por J๚lio Soares
	If SA1->(A1_EST) == 'RJ' 
		MsgInstr01 += "SUJEITO A PROTESTO" + ENT
	EndIf
*/
	If !Empty(_cInstr01)
		dbSelectArea("SZI")
		If !Empty(_cOcorr)
			//SZI->(dbSetOrder(5))		//ZI_FILIAL+ZI_BANCO+ZI_AGENCIA+ZI_CONTA+ZI_OCORREN+ZI_CODINST
			SZI->(dbOrderNickName("ZI_BANCO2"))
			_lAchou := SZI->(MsSeek(xFilial("SZI")+SEE->(EE_CODIGO+EE_AGENCIA+EE_CONTA)+_cOcorr+_cInstr01,.T.,.F.))
		Else
			//SZI->(dbSetOrder(1))		//ZI_FILIAL+ZI_BANCO+ZI_AGENCIA+ZI_CONTA+ZI_CODINST+ZI_OCORREN
			SZI->(dbOrderNickName("ZI_BANCO" ))
			_lAchou := SZI->(MsSeek(xFilial("SZI")+SEE->(EE_CODIGO+EE_AGENCIA+EE_CONTA)+_cInstr01        ,.T.,.F.))
		EndIf
		If _lAchou .AND. AllTrim(SZI->ZI_MSBLQL)<>"1" .AND. AllTrim(SZI->ZI_IMPBOL)=="S"
			If SZI->ZI_DIASPRO > 0 .Or. SA1->A1_PRZPROT > 0 .Or. SE1->E1_DIASPRO > 0
				If SZI->ZI_OCORREN == '01' .And. SZI->ZI_DIACONT == '2' // - TRECHO COMENTADO POR Diego Rodrigues
					MsgInstr01 += "PROTESTO: " + DTOC(DataValida(SE1->E1_VENCTO+IIF(SA1->A1_PRZPROT > 0, SA1->A1_PRZPROT, SE1->E1_DIASPRO),.T.)) //+ " - " + "Ap๓s essa data consultar o Banco do Brasil p/ Pgto."
				Else 
					MsgInstr01 += "PROTESTO: " + DTOC(DataValida(Dias(),.T.)) //+ " - " + "Ap๓s essa data consultar o "+_cNomBco+" p/ Pgto."
				EndIf
			Else
				MsgInstr01 += AllTrim(SZI->ZI_DESINST)
			EndIf
		EndIf
	EndIf
	//Instru็ใo bancแria 02
	MsgInstr02 := ""
	_cOcorr    := IIF(!EMPTY(SE1->E1_OCORREN),SE1->E1_OCORREN,SEE->EE_OCORREN)

	/* FB - RELEASE 12.1.23
	_cInstr02  := IIF(EXISTBLOCK("RFINEBBI"),U_RFINEBBI("2"),IIF(Empty(SE1->E1_INSTR2),SEE->EE_INSTSEC,SE1->E1_INSTR2))
	*/
	_cInstr02  := IIF(_lRFINEBBI,U_RFINEBBI("2"),IIF(Empty(SE1->E1_INSTR2),SEE->EE_INSTSEC,SE1->E1_INSTR2))

	If !Empty(_cInstr02)
		dbSelectArea("SZI")
		If !Empty(_cOcorr)
			//SZI->(dbSetOrder(5))//ZI_FILIAL+ZI_BANCO+ZI_AGENCIA+ZI_CONTA+ZI_OCORREN+ZI_CODINST+ZI_DIASPRO
			SZI->(dbOrderNickName("ZI_BANCO2"))
			//_lAchou := dbSeek(xFilial("SZI")+SEE->(EE_CODIGO+EE_AGENCIA+EE_CONTA)+_cOcorr+_cInstr02+Alltrim(Str(SA1->A1_PRZPROT)))//Alltrim(Str(SE1->E1_DIASPRO)))
			_lAchou := SZI->(MsSeek(xFilial("SZI")+SEE->(EE_CODIGO+EE_AGENCIA+EE_CONTA)+_cOcorr+_cInstr02+Alltrim(Str(SE1->E1_DIASPRO)),.T.,.F.))
		Else
			//SZI->(dbSetOrder(1))//ZI_FILIAL+ZI_BANCO+ZI_AGENCIA+ZI_CONTA+ZI_CODINST+ZI_OCORREN
			SZI->(dbOrderNickName("ZI_BANCO" ))
			_lAchou := SZI->(MsSeek(xFilial("SZI")+SEE->(EE_CODIGO+EE_AGENCIA+EE_CONTA)+_cInstr02,.T.,.F.))
		EndIf
		If _lAchou .AND. AllTrim(SZI->ZI_MSBLQL)<>"1" .AND. AllTrim(SZI->ZI_IMPBOL)=="S"
			If SZI->ZI_DIASPRO > 0 //.OR. SA1->A1_PRZPROT > 0 .Or. SE1->E1_DIASPRO > 0
				If SZI->ZI_OCORREN == '01' .And. SZI->ZI_DIACONT == '2' // - TRECHO COMENTADO POR Diego Rodrigues
					//MsgInstr02 := "PROTESTO: " + DTOC(DataValida(SE1->E1_VENCTO+IIF(SA1->A1_PRZPROT > 0, SA1->A1_PRZPROT, SE1->E1_DIASPRO ),.T.)) + " - " + "Ap๓s essa data consultar o "+_cNomBco+" p/ Pgto."
					MsgInstr02 := "PROTESTO: " + DTOC(DataValida(SE1->E1_VENCTO+SE1->E1_DIASPRO,.T.)) //+ " - " + "Ap๓s essa data consultar o "+_cNomBco+" p/ Pgto."
				Else 
					MsgInstr02 := "PROTESTO: " + DTOC(DataValida(Dias(),.T.)) //+ " - " + "Ap๓s essa data consultar o "+_cNomBco+" p/ Pgto."
				EndIf
			Else 
				MsgInstr02 := AllTrim(SZI->ZI_DESINST)
			EndIf
		EndIf
	EndIf
	//Mensagens adicionais s๓ para o boleto
	MsgInstr03 := ''
	If !Empty(MV_PAR17)
		If !Empty(MsgInstr03)
			MsgInstr03 += CHR(13) + CHR(10)
		EndIf
		MsgInstr03 += AllTrim(MV_PAR17)
	EndIf
	If !Empty(MV_PAR18)
		If !Empty(MsgInstr03)
			MsgInstr03 += " "
		EndIf
		MsgInstr03 += AllTrim(MV_PAR18)
	EndIf
	//Fim das mensagens adicionais s๓ para o boleto
	//Fim da มrea de Mensagens para o boleto
	
	//### REG.003 - Composi็ใo do C๓digo de Barras
	//Inํcio da montagem do C๓digo de Barras
	If SE1->E1_VENCTO>= STOD("20250222")
		nNewFator := 9000
	EndIf
	cFatVen     := SE1->E1_VENCTO - STOD("19971007") -nNewFator
	cBarra      := SubStr(SEE->EE_CODIGO,1,3)						//001 a 003 - C๓digo do Banco
	cBarra      += IIF(SE1->E1_MOEDA==1,'9','0')					//004 a 004 - C๓digo da Moeda
	cBarra      += "#"												//005 a 005 - DV C๓digo de Barras
	cBarra      += StrZero(cFatVen             ,04)					//006 a 009 - Fator de Vencimento
	cBarra      += StrZero(Round(((Round(_nSaldo,2))*100),0),10)	//010 a 019 - Valor (arredondado com 02 decimais)
	//Altera็๕es iniciadas
	cBarra  	+= StrZero(VAL(SEE->EE_CODCART),03)					//020 a 022 - Tipo de Carteira/Modalidade de Cobran็a
	cBarra  	+= StrZero(Val(NOSSONUM),08)						//023 a 030 - Nosso Numero - Livre do cliente
	//cBarra  	+= StrZero(Val(SEE->EE_FAXATU),08)					//023 a 030 - Nosso Numero - Livre do cliente
	cBarra  	+= StrZero(Val(_cDVNN),1)							//031 a 031 - DV C๓digo de Barras
	cBarra		+= StrZero(VAL(SubStr(_cAg,1,AT("-",_cAg)-1)),04)	//032 a 035 - N.บ da Ag๊ncia BENEFICIมRIO 
	cBarra		+= StrZero(VAL(SubStr(_cCC,1,AT("-",_cCC)-1)),05)	//036 a 040 - N.บ da Conta Corrente 
	
	CalcDigCart(@_cAg,@_cCC,@_lContin)
	cBarra      += StrZero(Val(_cDac),1)							//041 a 041 - DAC [Ag๊ncia/Conta Corrente] 
	cBarra  	+= StrZero(0,3)										//032 a 044 - ZEROS
	//Fun็ใo do Dํgito Verificador do C๓digo de Barras (posi็ใo 005 a 005)
	CDigCodBar()
	
	//### REG.004 - Composi็ใo da Linha Digitแvel
	//Fun็ใo para composi็ใo da Linha Digitแvel
	cLinha := CalcLinDig()
	
	//### REG.005 - Processamento da Impressใo
	//INอCIO DA IMPRESSรO
	oPrn:StartPage()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
	//ณImpressao do canhoto (comprovante de entrega)ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
	_nPosHor := 01
	_nLinha  := 02
	_nEspLin := 84
	
	// Posicionamento Vertical
	_nPosVer := 10
	
	// Posicionamento do Texto Dentro do Box
	_nTxtBox := 05
	
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+25,_nTxtBox+0005,_cNomBco+"   |" + SubStr(cBarra,01,03) + "-" + SubStr(cBarra,04,01) + "|",ofont14B,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+10,_nPosVer+1630,"Comprovante de Entrega",ofont14B,100)
	_nLinha++
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0830)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Beneficiแrio",ofont08,100)
	
	/* FB - RELEASE 12.1.23
	If Type("SEE->EE_NOMECOM")<>"U" .AND. !Empty(SEE->EE_NOMECOM)
	*/
	If &(_bEENOMECOM) <> "U" .AND. !Empty(SEE->EE_NOMECOM)
		oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox,_nPosVer+0010,AllTrim(SEE->EE_NOMECOM),ofont08,100)
	Else
		oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox,_nPosVer+0010,AllTrim(SM0->M0_NOMECOM),ofont08,100)
	EndIf
	// Box Agencia/Codigo Cedente
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0830,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1180)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0840,"Ag๊ncia/C๓d. Beneficiแrio",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox,_nPosVer+0850,_cAg + "/" + _cCC,ofont08B,100)
	// Box Motivos nao entrega
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1180,_nPosHor+(_nLinha*_nEspLin)+(2*_nEspLin),_nPosVer+2230)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1290,"Motivos de nใo entrega(para uso da empresa entregadora)",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0050)+_nTxtBox,_nPosVer+1210,"( ) Mudou-se",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0050)+_nTxtBox,_nPosVer+1490,"( ) Ausente",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0050)+_nTxtBox,_nPosVer+1820,"( ) Nใo existe n. indicado",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0100)+_nTxtBox+0025,_nPosVer+1210,"( ) Recusado",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0100)+_nTxtBox+0025,_nPosVer+1490,"( ) Nใo Procurado",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0100)+_nTxtBox+0025,_nPosVer+1820,"( ) Falecido",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0150)+_nTxtBox+0050,_nPosVer+1210,"( ) Desconhecido",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0150)+_nTxtBox+0050,_nPosVer+1490,"( ) Endere็o Insuficiente",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0150)+_nTxtBox+0050,_nPosVer+1820,"( ) Outros (anotar no verso)",ofont08,100)
	// Box Sacado
	_nLinha++
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0830)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Pagador",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0010,SubStr(SA1->A1_NOME,1,45),ofont08,100)
	// Box Nosso Numero
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0830,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1180)
	oprn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0840,"Nosso N๚mero",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0845,NOSSONUM+IIF(!Empty(_cDVNN),"-"+_cDVNN,""),ofont08B,100)
	// Box Vencimento
	_nLinha++
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0200)
	oprn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Vencimento",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0030,DTOC(SE1->E1_VENCTO),ofont08B,100)
	// Box Numero do Documento
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0200,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0520)
	oprn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0210,"N. do Documento",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0250,AllTrim(SE1->E1_NUM)+"  "+AllTrim(SE1->E1_PARCELA),ofont08,100)
	// Box Especie Moeda
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0520,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0830)
	oprn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0530,"Esp้cie Moeda",ofont08,100)
	oprn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0650,"R$",ofont08,100)
	// Box Valor do Documento
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0830,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1180)
	oprn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0840,"Valor do Documento",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0940,Transform(_nSaldo,"@E 999,999.99"),ofont08B,100)
	// Box Recebimento bloqueto
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0340)
	oprn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Recebi(emos) o bloqueto",ofont08,100)
	// Box Data
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0340,_nPosHor+(_nLinha*_nEspLin),_nPosVer+560)
	oprn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0350,"Data",ofont08,100)
	// Box Assinatura
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0560,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1180)
	oprn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0570,"Assinatura",ofont08,100)
	// Box Data
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1180,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1520)
	oprn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1190,"Data",ofont08,100)
	// Box Entregador
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1520,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
	oprn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1530,"Entregador",ofont08,100)
	// Box Local de Pagamento
	_nLinha  += 1
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+20,_nPosVer+0010,"__  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  ",ofont08,100)
	/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤAIXAฤฤฤฤAIXAฤฤฤฤAIXAAIXAณ
	//ณ       MONTA O RECIBO DO SACADO                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤAIXAฤฤฤฤAIXAฤฤฤฤAIXAฤฤฤฤ*/
	oPrn:Say ( 650, 1770, "RECIBO DO PAGADOR",oFont15,100)
	oPrn:Box ( 690, 0200, 1900, 2180)
	oPrn:SayBitmap( 700, 210,_cLogoBco,340,190 )
	/* FB - RELEASE 12.1.17
	If Type("SEE->EE_NOMECOM")<>"U" .AND. !Empty(SEE->EE_NOMECOM)
	*/
	If &(_bEENOMECOM) <> "U" .AND. !Empty(SEE->EE_NOMECOM)
		oPrn:Say ( 790, 560, AllTrim(SEE->EE_NOMECOM),oFont14B,100)
	Else
		oPrn:Say ( 790, 560, AllTrim(SM0->M0_NOMECOM),oFont14B,100)
	EndIf
	If Len(AllTrim(SM0->M0_CGC)) == 14
		_cCnpj := "CNPJ: " + AllTrim(SM0->M0_CGC)
	ElseIf Len(AllTrim(SM0->M0_CGC)) == 11
		_cCnpj := "CPF: " + SubStr(SM0->M0_CGC,1,3)+"."+SubStr(SM0->M0_CGC,4,3)+"."+SubStr(SM0->M0_CGC,7,3)+"-"+SubStr(SM0->M0_CGC,10,2)
	Else
		_cCnpj := "CPF/CNPJ: " + AllTrim(SM0->M0_CGC)
	EndIf
	oPrn:Say ( 860, 560,AllTrim(FisGetEnd(SM0->M0_ENDCOB,SM0->M0_ESTCOB)[1]) + ", " + ;
						AllTrim(IIF(!Empty(FisGetEnd(SM0->M0_ENDCOB,SM0->M0_ESTCOB)[3]),FisGetEnd(SM0->M0_ENDCOB,SM0->M0_ESTCOB)[3],"S/N")) + " - " + ;
						AllTrim(SM0->M0_BAIRCOB) + " - " + AllTrim(SM0->M0_CIDCOB) + "/" + SM0->M0_ESTCOB + " CEP " + Transform(SM0->M0_CEPCOB,"99999-999") + ;
						"  Tel: " + AllTrim(SM0->M0_TEL) + " " + _cCnpj ,oFont13,100)
	
	oPrn:line( 900, 200, 0901, 2180)
	oPrn:line(1100, 200, 1101, 2180)
	oPrn:line( 900, 1800,1100, 1801)
	oPrn:Say ( 955, 1870,"VENCIMENTO",oFont15,100)
		oPrn:Say( 0950, 0240, AllTrim(SE1->E1_CLIENTE)+AllTrim(SE1->E1_LOJA) + " - " + ALLTRIM(SA1->A1_NOME), oFont12,100  )
	If !Empty(_cCompl)
		oPrn:Say( 0990, 0240, ALLTRIM(_cEndc) + " - " + Alltrim(_cCompl), oFont12,100  )
	Else
		oPrn:Say( 0990, 0240, ALLTRIM(_cEndc)      ,oFont12,100  )
	Endif
	oPrn:Say( 1020, 1900, DTOC(SE1->E1_VENCTO)    ,oFont15,100  )   //Vencimento do Titulo
	oPrn:Say( 1030, 0240, SubStr(_cCEPc,1,5)+"-"+SubStr(_cCEPc,6,3)+"  "+RTrim(_cBair)+" - "+ALLTRIM(_cMunc)+"   "+_cEstc, oFont12,100  )
	/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤAIXAฤฤฤฤAIXAฤฤฤฤAIXAAIXAณ
	//ณ       MONTA PARTE INFERIOR DO RECIBO / CAIXA    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤAIXAฤฤฤฤAIXAฤฤฤฤAIXAฤฤฤฤ*/
	// Monta box do boleto
	//        lin   col   lin   col
	//	oPrn:Box (1380, 0200, 1900, 2180)
	// Monta linhas horizontais
	//        lin   col   lin   col
	oPrn:Line(1230, 1720, 1230, 2180)
	oPrn:Line(1300, 1720, 1300, 2180)
	oPrn:Line(1380, 1720, 1380, 2180)
	oPrn:Line(1450, 1720, 1450, 2180)
	oPrn:Line(1520, 0200, 1520, 2180)
	oPrn:Line(1590, 1720, 1590, 2180)
	oPrn:Line(1660, 1720, 1660, 2180)
	oPrn:Line(1730, 1720, 1730, 2180)
	oPrn:Line(1800, 0200, 1800, 2180)
	// Monta linha verticais
	//        lin   col   lin   col
	oPrn:SayBitmap( 1110, 0900,_cLogoEmp,400,400 )
	oPrn:Line(1230, 1720, 1900, 1720)
	oPrn:Say( 1235, 1730, "Codigo Beneficiแrio "														,oFont13,100)
	oPrn:Say( 1310, 1730, "Nบ. Documento "																,oFont13,100)
	oPrn:Say( 1385, 1730, "Nosso Numero "																,oFont13,100)
	oPrn:Say( 1455, 1730, "Valor do Documento "															,oFont13,100)
	oPrn:Say( 1265, 1740, _cAg + "/" + _cCC			  													,oFont12,100)//Codigo do Cedente
	oPrn:Say( 1340, 1830, AllTrim(SE1->E1_NUM)+"  "+AllTrim(SE1->E1_PARCELA)				 			,oFont12,100)
	oPrn:Say( 1410, 1755, Alltrim(SEE->EE_CODCART) + "/"+ NOSSONUM+IIF(!Empty(_cDVNN),"-"+_cDVNN,"")	,oFont12,100)
	oPrn:Say( 1480, 1970, Transform(_nSaldo,"@E 999,999.99")											,oFont12,100)
	oPrn:Say( 1525, 1730, "(-) Desconto/Abatimento"														,oFont13,100)
	oPrn:Say( 1525, 0220, "Instru็๕es "																	,oFont13,100)
	oPrn:Say( 1595, 1730, "(-) Outras dedu็๕es "														,oFont13,100)
	_nLinMsg := 1545
	oPrn:Say( _nLinMsg, 0220, "Desconto/Abatimento s๓ com instru็ใo do beneficiแrio.",oFont18,100  )
	_nLinMsg += 30
	If !Empty(MsgInstr01)
		oPrn:Say( _nLinMsg, 0220, SubStr(MsgInstr01,1,77) ,oFont18,100  )
		_nLinMsg += 30
	EndIf
	If !Empty(MsgInstr02)
		oPrn:Say( _nLinMsg, 0220, SubStr(MsgInstr02,1,77) ,oFont18,100  )
		_nLinMsg += 30
	EndIf
	If !Empty(_cMensJur)
		oPrn:Say( _nLinMsg, 0220, SubStr(_cMensJur ,1,77) ,oFont18,100  )
		_nLinMsg += 30
	EndIf
	If !Empty(_cMensDesc)
		oPrn:Say( _nLinMsg, 0220, SubStr(_cMensDesc,1,77) ,oFont18,100  )
		_nLinMsg += 30
	EndIf
	If !Empty(MsgInstr03)
		_cTxt   := AllTrim(MsgInstr03)
		_nLnTot := MlCount(_cTxt ,100)
		While !Empty(_cTxt)
			_cTexto := IIF(CHR(10)$_cTxt,SubStr(_cTxt,1,AT(CHR(10),_cTxt)-1),AllTrim(_cTxt))
			_cTxt   := IIF(CHR(10)$_cTxt,SubStr(_cTxt,AT(CHR(10),_cTxt)+1),"")
			If !Empty(_cTexto)
				_nMem1 := MlCount(_cTexto,100)
				For _nLoop := 1 To _nMem1
					oPrn:Say(_nLinMsg,0220,MemoLine(StrTran(_cTexto,CHR(13),""),100,_nLoop),oFont18,100  )
					_nLinMsg += 30
			  	Next
			EndIf
		EndDo
	EndIf
	oPrn:Say( 1665, 1730, "(+) Mora/Multa/Juros "  ,oFont13,100  )
	oPrn:Say( 1735, 1730, "(+) Outros Acrecimos "  ,oFont13,100  )
	oPrn:Say( 1805, 1730, "(=) Valor Cobrado "     ,oFont13,100  )
	oPrn:Say( 1815, 0220, _cNomBco,oFont20,100)
	oPrn:Say( 1815, 1100, SubStr(cBarra,01,03) + "-" + SubStr(cBarra,04,01),oFont21,100)

	//  MONTA FICHA COMPENSAวรO

	// Monta box do boleto
	oPrn:Box (2080, 0200, 3000, 2180)
	// Monta linhas horizontais
	oPrn:Line(2190, 0200, 2190, 2180)
	oPrn:Line(2260, 0200, 2260, 2180)
	oPrn:Line(2330, 0200, 2330, 2180)
	oPrn:Line(2400, 0200, 2400, 2180)
	oPrn:Line(2745, 0200, 2745, 2180)
	// Monta linha verticais
	oPrn:Line(2000, 0550, 2080, 0550)
	oPrn:Line(2000, 0551, 2080, 0551)
	oPrn:Line(2000, 0553, 2080, 0553)
	oPrn:Line(2000, 0730, 2080, 0730)
	oPrn:Line(2000, 0731, 2080, 0731)
	oPrn:Line(2000, 0733, 2080, 0733)
	oPrn:Line(2080, 1720, 2745, 1720)
	oPrn:Line(2470, 1720, 2470, 2180)
	oPrn:Line(2540, 1720, 2540, 2180)
	oPrn:Line(2610, 1720, 2610, 2180)
	oPrn:Line(2680, 1720, 2680, 2180)
	oPrn:Line(2260, 0500, 2401, 0500)
	oPrn:Line(2260, 0900, 2401, 0900)
	oPrn:Line(2260, 1100, 2331, 1100)
	oPrn:Line(2260, 1400, 2401, 1400)
	oPrn:Line(2330, 0700, 2401, 0700)
	oPrn:Line(2330, 0400, 2401, 0400)
	oPrn:SayBitmap(1955, 0222,_cLogoBco,255,120 )
	oPrn:Say( 2005, 0560, SubStr(cBarra,01,03) + "-" + SubStr(cBarra,04,01) ,oFont21,100)
	oPrn:Say( 2005, 0745, cLinha                   ,oFont17,150)
	oPrn:Say( 2085, 0220, "Local de Pagamento "    ,oFont13,100  )
	oPrn:Say( 2085, 1730, "Vencimento "            ,oFont13,100  )
	oPrn:Say( 2135, 0240, "Pagแvel em qualquer banco at้ o vencimento",oFont12,100 )
	oPrn:Say( 2135, 1900, DTOC(SE1->E1_VENCTO)     ,oFont15,100  )   //Vencimento do Titulo
	oPrn:Say( 2195, 0220, "Beneficiแrio "          ,oFont13,100  )
	oPrn:Say( 2195, 1730, "Codigo Beneficiแrio "   ,oFont13,100  )
	/* FB - RELEASE 12.1.23
	If Type("SEE->EE_NOMECOM")<>"U" .AND. !Empty(SEE->EE_NOMECOM)
	*/
	If &(_bEENOMECOM) <> "U" .AND. !Empty(SEE->EE_NOMECOM)	
		oPrn:Say( 2220, 0240, AllTrim(SEE->EE_NOMECOM) ,oFont12,100  )   //Cedente
	Else
		oPrn:Say( 2220, 0240, AllTrim(SM0->M0_NOMECOM) ,oFont12,100  )   //Cedente
	EndIf
	oPrn:Say( 2220, 1740, _cAg + "/" + _cCC        ,oFont12,100  )   //Codigo do Cedente
	oPrn:Say( 2265, 0220, "Data Documento "        ,oFont13,100  )
	oPrn:Say( 2265, 0510, "Nบ. Documento "         ,oFont13,100  )
	oPrn:Say( 2265, 0910, "Especie Doc. "          ,oFont13,100  )
	oPrn:Say( 2265, 1110, "Aceite "                ,oFont13,100  )
	oPrn:Say( 2265, 1410, "Data do Processamento " ,oFont13,100  )
	oPrn:Say( 2265, 1730, "Nosso Numero "          ,oFont13,100  )
	oPrn:Say( 2290, 0240, DTOC(SE1->E1_EMISSAO)    ,oFont12,100  )
	oPrn:Say( 2290, 0530, SE1->E1_NUM+" "+SE1->E1_PARCELA , oFont12,100  )	
	oPrn:Say( 2290, 0970, "DM"                     ,oFont12,100  )
	oPrn:Say( 2290, 1230, IIF(!Empty(SEE->EE_ACEITE),SEE->EE_ACEITE,"N"),oFont12,100  )
	oPrn:Say( 2290, 1440, DTOC(DDATABASE)          ,oFont12,100  )
	oPrn:Say( 2290, 1755, NOSSONUM+IIF(!Empty(_cDVNN),"-"+_cDVNN,""),oFont12,100  )
	oPrn:Say( 2335, 0220, "Uso do Banco "          ,oFont13,100  )
	oPrn:Say( 2335, 0510, "Carteira "			   ,oFont13,100  )
	oPrn:Say( 2335, 0710, "Especie "               ,oFont13,100  )
	oPrn:Say( 2335, 0910, "Quantidade "            ,oFont13,100  )
	oPrn:Say( 2335, 1410, "Valor "                 ,oFont13,100  )
	oPrn:Say( 2335, 1730, "Valor do Documento "    ,oFont13,100  )
	oPrn:Say( 2360, 0560, StrZero(VAL(SEE->EE_CODCART),03),oFont12,100  )
	oPrn:Say( 2360, 0770, "R$"                     ,oFont12,100  )
	oPrn:Say( 2360, 1975, Transform(_nSaldo,"@E 999,999.99") , oFont12,100  )
	oPrn:Say( 2405, 0220, "Instru็๕es "            ,oFont13,100  )
	oPrn:Say( 2405, 1730, "(-) Desconto/Abatimento",oFont13,100  )
	_nLinMsg := 2430
	oPrn:Say( _nLinMsg, 0220, "Desconto/Abatimento s๓ com instru็ใo do beneficiแrio.",oFont18,100  )
	_nLinMsg += 40
	If !Empty(MsgInstr01)
		oPrn:Say( _nLinMsg, 0220, SubStr(MsgInstr01,1,77) ,oFont18,100  )
		_nLinMsg += 40
	EndIf
	If !Empty(MsgInstr02)
		oPrn:Say( _nLinMsg, 0220, SubStr(MsgInstr02,1,77) ,oFont18,100  )
		_nLinMsg += 40
	EndIf
	If !Empty(_cMensJur)
		oPrn:Say( _nLinMsg, 0220, SubStr(_cMensJur ,1,77) ,oFont18,100  )
		_nLinMsg += 40
	EndIf
	If !Empty(_cMensDesc)
		oPrn:Say( _nLinMsg, 0220, SubStr(_cMensDesc,1,77) ,oFont18,100  )
		_nLinMsg += 40
	EndIf
	If !Empty(MsgInstr03)
		_cTxt   := AllTrim(MsgInstr03)
		_nLnTot := MlCount(_cTxt ,100)
		While !Empty(_cTxt)
			_cTexto := IIF(CHR(10)$_cTxt,SubStr(_cTxt,1,AT(CHR(10),_cTxt)-1),AllTrim(_cTxt))
			_cTxt   := IIF(CHR(10)$_cTxt,SubStr(_cTxt,AT(CHR(10),_cTxt)+1),"")
			If !Empty(_cTexto)
				_nMem1 := MlCount(_cTexto,100)
				For _nLoop := 1 To _nMem1
					oPrn:Say(_nLinMsg,0220,MemoLine(StrTran(_cTexto,CHR(13),""),100,_nLoop),oFont18,100  )
					_nLinMsg += 40
			  	Next
			EndIf
		EndDo
	EndIf
	oPrn:Say( 2475, 1730, "(-) Outras dedu็๕es "   ,oFont13,100  )
	oPrn:Say( 2545, 1730, "(+) Mora/Multa/Juros "  ,oFont13,100  )
	oPrn:Say( 2615, 1730, "(+) Outros Acrecimos "  ,oFont13,100  )
	oPrn:Say( 2685, 1730, "(=) Valor do Documento ",oFont13,100  )
	oPrn:Say( 2745, 0220, "Pagador"                 ,oFont13,100  )
	oPrn:Say( 2770, 0240, SE1->E1_CLIENTE+SE1->E1_LOJA + " - " + ALLTRIM(SA1->A1_NOME) , oFont12,100  )
	If !Empty(_cCompl)
		oPrn:Say( 2810, 0240, ALLTRIM(_cEndc) + " - " + Alltrim(_cCompl), oFont12,100  )
	Else
		oPrn:Say( 2810, 0240, ALLTRIM(_cEndc), oFont12,100  )
	EndIf
	oPrn:Say( 2850, 0240, Substr(_cCEPc,1,5)+"-"+Substr(_cCEPc,6,3)+"  "+ALLTRIM(_cBair)+" - "+ALLTRIM(_cMunc)+"   "+_cEstc, oFont12,100  )
	_cCGCCli := IIF(SA1->A1_PESSOA=="J", Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),Transform(SA1->A1_CGC,"@R 999.999.999-99"))
	oPrn:Say( 2890, 0240, _cCGCCli, oFont12,100  )
	oPrn:Say( 3010, 1450, "FICHA DE COMPENSAวรO - AUTENTICAวรO MECยNICA",oFont24,100  )
	MSBAR("INT25",26,1.8,Alltrim(cBarra),oPrn,.F.,,.T.,0.025,1.3,NIL,NIL,NIL,.F.)		//altura para impressoras PDF

	/* FB - RELEASE 12.1.23
	If ExistBlock("RFATL001") //.AND. !Empty(SE1->E1_NUMBCO)
	*/
	If _lRFATL001 //.AND. !Empty(SE1->E1_NUMBCO)	
		U_RFATL001(	SE1->E1_PEDIDO,;
					"",;
					"SE1 - Tit.: "+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)+" / N.N. Ant.: "+SE1->E1_NUMBCO+" / N.N. Novo: "+SubStr(NOSSONUM,Len(AllTrim(SEE->EE_CODEMP))+1),;
					_cRotina,;
					"Houve altera็ใo no Nosso N๚mero, de '"+SE1->E1_NUMBCO+"' para '"+SubStr(NOSSONUM,Len(AllTrim(SEE->EE_CODEMP))+1)+"', para o tํtulo de chave '"+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)+"', carteira '"+SE1->E1_CARTEIR+"'. Verifique! Seguem os อndices/RECNOs atuais: SEE (ํndice "+cValToChar(SEE->(IndexOrd()))+" / recno "+cValToChar(SEE->(Recno()))+") / SE1 (ํndice "+cValToChar(SE1->(IndexOrd()))+" / recno "+cValToChar(SE1->(Recno()))+")" )
	EndIf

	dbSelectArea("SE1")
	RecLock("SE1",.F.)
		SE1->E1_PORTADO := SEE->EE_CODIGO
		SE1->E1_AGEDEP  := SEE->EE_AGENCIA
		SE1->E1_CONTA   := SEE->EE_CONTA
		SE1->E1_CONVEN  := SEE->EE_CODEMP		//Guardo o c๓digo do conv๊nio separadamente
		SE1->E1_NUMBCO  := SubStr(ALLTRIM(NOSSONUM),1,8)//SEE->EE_FAXATU		//Guardo o nosso n๚mero sem o C๓digo do Conv๊nio e sem o Dํgito Verificador
	SE1->(MsUnLock())
	oPrn:EndPage()
	_nQtdBole++	 //Incrementa a variแvel de controle da quantidade de boletos gerados
	dbSelectArea("SE1TMP")
	SE1TMP->(dbSkip())
EndDo
dbSelectArea("SE1TMP")
SE1TMP->(dbCloseArea())
//Inicio - Trecho adicionado por Adriano Leonardo em 28/02/14 - Inclusใo de envio por e-mail
If _lEnvBol .And. _nQtdBole>0
	If oPrn:SaveAllAsJpeg(_cArqBol,0798,1129,130)
		_aAnexo   := aSort(_aAnexo,,,{|x,y| x[03] < y[03]})
		_aArquivo := {}
		_nVarIni  := 1
		For _nF := 1 To Len(_aAnexo)
			While _nF <= Len(_aAnexo) .AND. (_nF == _nVarIni .OR. _aAnexo[_nF][03] == _aAnexo[_nF-1][03])
				If !(_aAnexo[_nF][Len(_aAnexo[_nF])] := File(_aAnexo[_nF][01]))
					MsgAlert("Aten็ใo!!! Problemas na gera็ใo do arquivo " + _aAnexo[_nF][01] + ". Portanto, este arquivo nใo serแ enviado por e-mail ao cliente " + _aAnexo[_nF][03] + ", no e-mail " + _aAnexo[_nF][02] + "!")
				Else
					AADD(_aArquivo,_aAnexo[_nF])
				EndIf				
				_nF++
			EndDo
			_nVarIni  := _nF
			_aArquivo := {}
			_nF--
		Next
	Else
		MsgAlert("Aten็ใo! Nใo foi possํvel gerar os arquivos de boleto para envio por e-mail!", _cRotina+"_012")
	EndIf
EndIf
If _lImprime .And. _nQtdBole>0
	oPrn:Preview()
EndIf

return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณCDigCodBarบAutor  ณAnderson C. P. Coelho บ Data ณ  23/12/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Sub-Rotina de cแlculo do dํgito verificador do C๓digo de   บฑฑ
ฑฑบ          ณBarras.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CDigCodBar()
//************************************************************
// INICIO
// ARCOLOR - Declara็ใo de varํaveis para nใo gerar error_log
// RODRIGO TELECIO em 24/08/2022
//************************************************************
local _x
// FIM
//************************************************************
Local _nRegCont  := Len(AllTrim(cBarra))		//A posi็ใo do Dํgito Verificador foi reservada com o caracter "#"
Local _aSeq      := {2,3,4,5,6,7,8,9,2,3,4,5,6,7,8,9,2,3,4,5,6,7,8,9,2,3,4,5,6,7,8,9,2,3,4,5,6,7,8,9,2,3,4,5,6,7,8,9}
Local _nSeq      := 0
Local _nSomaDg   := 0

For _x := 1 To _nRegCont
	If SubStr(cBarra,((_nRegCont-_x)+1),1) == "#"
		Loop
	EndIf
	If _nSeq==Len(_aSeq)
		_nSeq := 0
	EndIf
	_nSeq++
	_nSomaDg += VAL(SubStr(AllTrim(cBarra),((_nRegCont-_x)+1),1))*_aSeq[_nSeq]
Next
_nResto	:= cValToChar(11-(MOD(_nSomaDg,11)))
// - OBS.: Se o resultado desta for igual a 0, 1, 10 ou 11, considere DAC = 1.
If _nResto $ '0/1/10/11'
	_nResto := '1'
EndIf

cBarra	:= StrTran(cBarra,"#",_nResto)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCalcLinDigบAutor  ณAnderson C. P. Coelho บ Data ณ  23/12/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Sub-Rotina utilizada para formar/calcular a Linha Digitแvelบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CalcLinDig()
//************************************************************
// INICIO
// ARCOLOR - Declara็ใo de varํaveis para nใo gerar error_log
// RODRIGO TELECIO em 24/08/2022
//************************************************************
local _x
local _nLnClcD
// FIM
//************************************************************
Local _aSeq      := {2,1}
Local _nSeq      := 0
Local _nRegCont  := 0
Local _nSomaDg   := 0
Local _nSomaTot  := 0

For _nLnClcD := 1 To 3// - Composi็ใo dos 03 campos da linha digitแvel com os seus dํgitos verificadores
	_nSeq      := 0
	_nRegCont  := 0
	_nSomaDg   := 0
	_nSomaTot  := 0
	If _nLnClcD == 1
		// - Cแlculo do Primeiro Campo
		cLinha    := SubStr(cBarra,01,04)									//Posi็ใo 001 a 004 do C๓d. Barras (Banco e Moeda)
		cLinha    += SubStr(cBarra,20,01) + "." + SubStr(cBarra,21,04)		//Posi็ใo de 020 a 024 do C๓d. Barras
		_nSeq     := 0
		_nRegCont := Len(AllTrim(cLinha))
	ElseIf _nLnClcD == 2
		// - Cแlculo do Segundo Campo
		cLinha    := SubStr(cBarra,25,05) + "." + SubStr(cBarra,30,05)		//Posi็ใo de 025 a 034 do C๓d. Barras
		_nSeq     := 0
		_nRegCont := Len(AllTrim(cLinha))
	ElseIf _nLnClcD == 3
		// - Cแlculo do Terceiro Campo
		cLinha    := SubStr(cBarra,35,05) + "." + SubStr(cBarra,40,05)		//Posi็ใo de 035 a 044 do C๓d. Barras
		_nSeq     := 0
		_nRegCont := Len(AllTrim(cLinha))
	EndIf
	For _x := 1 To _nRegCont
		If SubStr(cLinha,((_nRegCont-_x)+1),1) == "."
			Loop
		EndIf
		If _nSeq==Len(_aSeq)
			_nSeq := 0
		EndIf
		_nSeq++                                
		_nSomaDg  := Val(SubStr(AllTrim(cLinha),((_nRegCont-_x)+1),1))*_aSeq[_nSeq]
		If _nSomaDg <= 9
			_nSomaTot += _nSomaDg
		Else	
			_nSomaTot += Val(Substr(cValToChar(_nSomaDg),1,1)) + Val(Substr(cValToChar(_nSomaDg),2,1))
		EndIf
	Next
	If MOD(_nSomaTot,10) <> 0
		_cDv := (10-(MOD(_nSomaTot,10)))
	Else
		_cDv := 0
	EndIf
	&("cLinha"+cValToChar(_nLnClcD)) := cLinha+cValToChar(_cDv)+Space(01)
Next
// - Composi็ใo Final da Linha Digitแvel
If Type("cLinha1")<>"U".AND.Type("cLinha2")<>"U".AND.Type("cLinha3")<>"U"
	cLinha := cLinha1+cLinha2+cLinha3+SubStr(cBarra,05,01)+Space(01)+SubStr(cBarra,06,14) //Campos 1, 2 e 3, mais o Dํgito Verificador do C๓digo de Barras [01], mais o Fator de Vencimento [04], mais o valor [10]
Else
	MsgStop("Aten็ใo! Problemas na composi็ใo da linha digitแvel. Contate o administrador!",_cRotina+"_013")
EndIf

Return(cLinha)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ CalcDignNum บAutor  ณ J๚lio Soares      บ Data ณ  10/12/15 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Execblock de cแlculo do Nosso N๚mero para o Banco Ita๚     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CalcDigNnum(NOSSONUM,_cDVNN,_lContin)
//************************************************************
// INICIO
// ARCOLOR - Declara็ใo de varํaveis para nใo gerar error_log
// RODRIGO TELECIO em 24/08/2022
//************************************************************
local _x
// FIM
//************************************************************
Local _aSavArea  := GetArea()
Local _aSeq      := {1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2}
Local _nSeq      := 0
Local _nRegCont  := 0
Local _nSomaDg   := 0
Local _nSomaTot  := 0
Local _nResto    := ""

Default NOSSONUM := ""
Default _cDVNN   := ""
Default _lContin := .T.

dbSelectArea("SE1")
_aSavSE1 := SE1->(GetArea())
dbSelectArea("SEE")
_aSavSEE := SEE->(GetArea())

If !Empty(SE1->E1_NUMBCO)
	NOSSONUM := Strzero(Val(Alltrim(SE1->E1_NUMBCO)),08)
EndIf

If Empty(NOSSONUM)
	MsgAlert("Aten็ใo! Nใo foi possํvel calcular o Nosso N๚mero para o tํtulo " + SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA + ". Portanto, este nใo serแ impresso!",_cRotina+"_011")
	_lContin  := .F.
Else
	_nRegCont := Len(AllTrim(NOSSONUM))
	For _x := 1 To _nRegCont
		If _nSeq==Len(_aSeq)
			_nSeq := 0
		EndIf
		_nSeq++
		_nSomaDg := VAL(SubStr(AllTrim(NOSSONUM),((_nRegCont-_x)+1),1))*_aSeq[_nSeq]
		If _nSomaDg <= 9
			_nSomaTot += _nSomaDg
		Else	
			_nSomaTot += Val(Substr(cValToChar(_nSomaDg),1,1)) + Val(Substr(cValToChar(_nSomaDg),2,1))
		EndIf
	Next
	_nResto := (10-(MOD(_nSomaTot,10)))
EndIf
NOSSONUM  := AllTrim(NOSSONUM)
_cDVNN    := StrZero(_nResto,1)

RestArea(_aSavSEE)
RestArea(_aSavSE1)
RestArea(_aSavArea)

Return(NOSSONUM,_cDVNN)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ CalcDignNum บAutor  ณ J๚lio Soares      บ Data ณ  10/12/15 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Execblock de cแlculo do Nosso N๚mero para o Banco Ita๚     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CalcDigCart(_cAg,_cCC,_lContin)
//************************************************************
// INICIO
// ARCOLOR - Declara็ใo de varํaveis para nใo gerar error_log
// RODRIGO TELECIO em 24/08/2022
//************************************************************
local _x
// FIM
//************************************************************
Local _aSeq			:= {2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1}
Local _nSeq			:= 0
Local _nRegCont		:= 0
Local _nSomaDg		:= 0
Local _nSomaTot		:= 0
Local _cDac			:= ""
Default _cDgcart	:= ""
Default _lContin	:= .T.

_cDgcart := StrZero(VAL(SubStr(_cAg,1,AT("-",_cAg)-1)),04) + StrZero(VAL(SubStr(_cCC,1,AT("-",_cCC)-1)),05)
_nRegCont := Len(AllTrim(_cDgcart))
For _x := 1 To _nRegCont
	If _nSeq==Len(_aSeq)
		_nSeq := 0
	EndIf
	_nSeq++
	_nSomaDg := VAL(SubStr(AllTrim(_cDgcart),((_nRegCont-_x)+1),1))*_aSeq[_nSeq]
	If _nSomaDg <= 9
		_nSomaTot += _nSomaDg
	Else	
		_nSomaTot += Val(Substr(cValToChar(_nSomaDg),1,1)) + Val(Substr(cValToChar(_nSomaDg),2,1))
	EndIf
Next
If MOD(_nSomaTot,10) <> 0
	_cDac := (10-(MOD(_nSomaTot,10)))
Else
	_cDac := 0
EndIf

Return(_cDac)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณ SendMail  บAutor ณ Adriano Leonardo de Souza Data ณ22/08/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑ บDesc.   ณ Fun็ใo responsแvel pelo envio automแtico dos boletos por    นฑฑ
ฑฑ  		ณ e-mail.                                                     นฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso  P11  ณ Uso especํfico - Arcolor - Programa principal              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function SendMail()
//************************************************************
// INICIO
// ARCOLOR - Declara็ใo de varํaveis para nใo gerar error_log
// RODRIGO TELECIO em 24/08/2022
//************************************************************
local nCont
// FIM
//************************************************************
//Resgata parโmetros para envio de e-mail
Local _aSavSA1 := SA1->(GetArea())
_cClient 	:= ""
_cLoja 		:= ""
_cNumPed	:= ""
dbSelectArea("SE1")
//SE1->(dbSetOrder(23))
SE1->(dbOrderNickName("E1_NUM"))
If SE1->(dbSeek(xFilial("SE1") + _cNumTitu))
	_cClient    := SE1->E1_CLIENTE
	_cLoja 	    := SE1->E1_LOJA
	_cNumPed	:= SE1->E1_PEDIDO
	_cEmissao	:= SE1->E1_EMISSAO
EndIf
//Monta conte๚do do e-mail
_cHTML := "<HTML><HEAD><TITLE></TITLE>"
_cHTML += "<META http-equiv=Content-Type content='text/html; charset=windows-1252'>"
_cHTML += "<META content='MSHTML 6.00.6000.16735' name=GENERATOR></HEAD>"
_cHTML += "<BODY>"   		 //Inicia conteudo do e-mail
_cHTML += "<H4><B><Font Face = 'Arial' Size = '2'><P>Prezado Cliente: </P>"
_cHTML += "<P>Voc๊ esta recebendo uma c๓pia do(s) boleto(s) referente(s) เ compra efetuada na Arcolor. "
_cHTML += "Essa c๓pia poderแ ser utilizada para pagamento, at้ o vencimento, caso nใo tenha recebido o original via correio.</P>"
_cHTML += "<P>Qualquer d๚vida entrar em contato com Alecssandra, pelo telefone (011) 2191-2444 Ramal 410.</P>"
_cHTML += "</B><P><I>Este e-mail foi enviado automaticamente pelo sistema Protheus. (Nใo responder)</I></P></H4><BR>"
_cHTML += "<P>&nbsp;</P>"
_cHTML += "</A></P></BODY>" //Finaliza conteudo do e-mail
_cHTML += "</HTML>"
 
cTitulo 	:= "Arcolor - Boleto de Cobran็a referente a NF: " + AllTrim(_cNumTitu) + "-" + AllTrim(_cPrefixo)

_cNumerAux	:=	AllTrim(_cNumTitu)	//Armazena o n๚mero da nota
_cSerieAux	:=	AllTrim(_cPrefixo)	//Armazena a s้rie da nota

_cMensagem 	:= _cHTML
lOk 	 	:= .T.

If !_lEnvBol
	_nTtlParc := TtlParc(_cNumTitu,_cPrefixo)
Else
	If _lImprime .And. _lOpcoes
		_nTtlParc := TtlParc("","",_cPedido, DtoS(_cEmissao))
	Else
		_nTtlParc := TtlParc("","",_cPedido, DtoS(_cEmissao))
	EndIf
EndIf
_cAnexo := ""
If _lEnvBol //.And. !(_cTransp $ SuperGetMv("MV_AIBTRAN" ,,"INDEFINIDO" )) //Trecho comentado em 19/09/2013 por Adriano Leonardo a pedido do Sr. Marco
	_nQtdAnexo := 0
	For nCont  := 1 To _nTtlParc
		_cAux  := "\Boletos\BOL_" + AllTrim(_cNumTitu) + "_" + AllTrim(_cPrefixo) + "_pag" + Alltrim(Str(nCont)) + ".JPG"
	 	//Verifica a exist๊ncia do arquivo, para que o mesmo seja anexado
		If File (_cAux)
	 
			If nCont==1
				_cAnexo  := _cAux
				_nQtdAnexo++
			Else
				_cAnexo  += ";" + _cAux
				_nQtdAnexo++
			EndIf 
		EndIf
	Next nCont
	_cMensag := ""
EndIf
If !Empty(_cRomaneio) .And. _lEnvRom
 	//Verifica a exist๊ncia do arquivo, para que o mesmo seja anexado
	If File (_cRomaneio)
		_cAnexo += _cRomaneio
	EndIf		
EndIf

cIndice := _cAnexoAux + OrdBagExt()

//Verifica a exist๊ncia do arquivo, para que o mesmo seja anexado
If File (_cAnexoAux)
	If Empty(_cAnexo) .And. _lEnvRom
		_cAnexo += _cAnexoAux
	ElseIf !Empty(_cAnexoAux)
		_cAnexo += ";" + _cAnexoAux
	EndIf
EndIf
If !Empty(_cDanfe)
	If !Empty(_cAnexo)
		_cAnexo += ";" + _cDanfe
	Else
	    _cAnexo += _cDanfe
	EndIf
EndIf
If Empty(_cAnexo)
	MSGBOX("Nใo existe nenhum arquivo para envio por e-mail!" ,_cRotina + "_014","ALERT")
	Return(.F.)
EndIf
dbSelectArea("SA1")
SA1->(dbSetOrder(1))
If SA1->(MsSeek(xFilial("SA1") + _cCliente + _cLojaCli,.T.,.F.))
	If !Empty(SA1->A1_EMAIL2)
		_cMail := AllTrim(SA1->A1_EMAIL2) + IIF(Empty(SA1->A1_EMAIL2),"",";") + SuperGetMv("MV_FATCCO",,"") //"; ale.primilla@arcolor.com.br; vanessa.silva@arcolor.com.br
	Else
		_cMail := IIF(!Empty(_cEndEmail),_cEndEmail + "; ","") + SuperGetMv("MV_FATCCO",,"") //"ale.primilla@arcolor.com.br; vanessa.silva@arcolor.com.br
	EndIf
EndIf
_cCco := SuperGetMv("MV_FATCCO",,"")
If !("BOL_" $ Upper(_cAnexo)) .And. ("DANFE" $ Upper(_cAnexo)) .And. SuperGetMv("MV_ENVSBOL",,.F.)
	//Monta conte๚do do e-mail para os casos em que nใo hแ boletos e no anexo vai somente a Danfe
	_cHTML2 := "<HTML><HEAD><TITLE></TITLE>"
	_cHTML2 += "<META http-equiv=Content-Type content='text/html; charset=windows-1252'>"
	_cHTML2 += "<META content='MSHTML 6.00.6000.16735' name=GENERATOR></HEAD>"
	_cHTML2 += "<BODY>"   		 //Inicia conteudo do e-mail
	_cHTML2 += "<H4><B><Font Face = 'Arial' Size = '2'><P>Prezado Cliente: </P>"
	_cHTML2 += "<P>Esta mensagem refere-se a Nota Fiscal Eletr๔nica Nacional de serie/n๚mero [" + _cSerieAux + "/" + _cNumerAux + "] emitida para: "
	_cHTML2 += "Razใo Social: [ARCO IRIS BRASIL IND. COM. PROD. ALIM. LTDA] CNPJ: [52.072.238/0001-26]</P>"
	_cHTML2 += "<P>Qualquer d๚vida entrar em contato com Alecssandra, pelo telefone (011) 2191-2444 Ramal 410.</P>"
	_cHTML2 += "</B><P><I>Este e-mail foi enviado automaticamente pelo sistema Protheus. (Nใo responder)</I></P></H4><BR>"
	_cHTML2 += "<P>&nbsp;</P>"
	_cHTML2 += "</A></P></BODY>" //Finaliza conteudo do e-mail
	_cHTML2 += "</HTML>"
	_cMensagem := _cHTML2
EndIf
If !("BOL_" $ Upper(_cAnexo)) .And. !("DANFE" $ Upper(_cAnexo)) .And. ("ROMANEIO" $ Upper(_cAnexo))
	//Monta conte๚do do e-mail para os casos em que nใo hแ boletos e no anexo vai somente a Danfe
	_cHTML3 := "<HTML><HEAD><TITLE></TITLE>"
	_cHTML3 += "<META http-equiv=Content-Type content='text/html; charset=windows-1252'>"
	_cHTML3 += "<META content='MSHTML 6.00.6000.16735' name=GENERATOR></HEAD>"
	_cHTML3 += "<BODY>"   		 //Inicia conteudo do e-mail
	_cHTML3 += "<H4><B><Font Face = 'Arial' Size = '2'><P>Prezado Cliente: </P>"
	_cHTML3 += "<P>Pedimos que confira a sua solicita็ใo em anexo.</P> "
	_cHTML3 += "<P>Qualquer d๚vida entrar em contato com Alecssandra, pelo telefone (011) 2191-2444 Ramal 410.</P>"
	_cHTML3 += "</B><P><I>Este e-mail foi enviado automaticamente pelo sistema Protheus. (Nใo responder)</I></P></H4><BR>"
	_cHTML3 += "<P>&nbsp;</P>"
	_cHTML3 += "</A></P></BODY>" //Finaliza conteudo do e-mail
	_cHTML3 += "</HTML>"
	_cMensagem := _cHTML3
EndIf
If !_lCancela .And. ("BOL_" $ Upper(_cAnexo)) .Or. SuperGetMv("MV_ENVSBOL",,.F.) .Or. ("ROMANEIO_" $ Upper(_cAnexo)) //Parโmetro utilizado para definir se haverแ o envio do e-mail quando nใo houver boleto

	//Verifica se a rotina irแ esperar o envio do e-mail ou deixarแ que este seja realizado em segundo plano
	If SuperGetMv("MV_ENVBOLT",,.F.)
		If ExistBlock("RFINE015")
			StartJob("U_RFINE015",GetEnvServer(),.F.,cTitulo,_cMensagem,_cMail,_cAnexo,,_cCco) // Inicia o Job
		Else
			MsgAlert("Favor informar ao Administrador que a rotina RFINE015 precisa ser compilada!", _cRotina + "_015")
	    EndIf
	Else
		U_RCFGM001(cTitulo,_cMensagem,_cMail,_cAnexo,,_cCco) //Chamada da rotina responsแvel pelo envio de e-mails
	EndIf
Else
	MsAguarde({|lEnd|DeletTmp()},"Aguarde...","Finalizando processo...",.T.) //Chamada da rotina de dele็ใo dos arquivos temporแrios
EndIf
If !(SuperGetMv("MV_ENVBOLT",,.F.)) .Or. _lCancela
	MsAguarde({|lEnd|DeletTmp()},"Aguarde...","Finalizando processo...",.T.) //Chamada da rotina de dele็ใo dos arquivos temporแrios
EndIf

RestArea(_aSavSA1)

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณ DeletTmp  บAutor ณ Adriano Leonardo de Souza Data ณ22/08/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑ บDesc.   ณ Fun็ใo responsแvel deletar os arquivos temporแrios.         นฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso  P11  ณ Uso especํfico - Arcolor - Programa principal              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function DeletTmp()
//************************************************************
// INICIO
// ARCOLOR - Declara็ใo de varํaveis para nใo gerar error_log
// RODRIGO TELECIO em 24/08/2022
//************************************************************
local nCont2
// FIM
//************************************************************
If !Empty(_cAnexo) .And. ";" $ _cAnexo
	_aAnexo := StrTokArr(_cAnexo,";")
	For nCont2 := 1 To Len(_aAnexo)
		fErase(_aAnexo[nCont2])
	Next
Else 
	fErase(_cAnexo)
EndIf
	
Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณ ErroMail  บAutor ณ Adriano Leonardo de Souza Data ณ22/08/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑ บDesc.   ณ Fun็ใo responsแvel por Validar o envio do e-mail.           นฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso  P11  ณ Uso especํfico - Arcolor - Programa principal              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function ErroMail(lOk)

If !lOk
	GET MAIL ERROR cError
	qout(cError + if(lOk,"-OK","-Erro"))
EndIf

Return()
               
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณ TtlParc   บAutor ณ Adriano Leonardo de Souza Data ณ22/08/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑ บDesc.   ณ Fun็ใo responsแvel por retornar o n๚mero de parcelas a ser  นฑฑ
ฑฑ  		ณ processadas para envio como anexo.                          นฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso  P11  ณ Uso especํfico - Arcolor - Programa principal              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function TtlParc(_cNumNf, _cSerie, _cPNumPed, _cPEmissao)

_cQuery := "SELECT COUNT(SE1.E1_NUM) AS [NUM_PARC] "
_cQuery += "FROM " + RetSqlName("SE1") + " SE1 (NOLOCK) "
If Empty(_cPNumPed)
	_cQuery += "WHERE SE1.E1_FILIAL  = '" + xFilial("SE1") + "' "
	_cQuery += "  AND SE1.E1_NUM     = '" + _cNumNF        + "' "
	_cQuery += "  AND SE1.E1_SERIE   = '" + _cSerie        + "' "
Else
	_cQuery += "WHERE SE1.E1_FILIAL  = '" + xFilial("SE1") + "' "	
	_cQuery += "  AND SE1.E1_PEDIDO  = '" + _cPNumPed      + "' "
	_cQuery += "  AND SE1.E1_EMISSAO = '" + _cPEmissao     + "' "
EndIf
_cQuery += "AND SE1.D_E_L_E_T_ = '' "
// Cria tabela temporแria com resultado da query
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"TRBTMP",.T.,.F.)
dbSelectArea("TRBTMP")
TRBTMP->(dbGoTop())
_nTotal := TRBTMP->NUM_PARC
dbSelectArea("TRBTMP")
TRBTMP->(dbCloseArea())

Return(_nTotal)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDias()   บAutor  ณ J๚lio Soares        บ Data ณ  21/03/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cแlculo de dias ๚teis para valida็ใo de data do vencimento.บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico empresa Arcolor                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Dias()

_nCont := 1
_dData := SE1->E1_VENCTO

While  _nCont <= IIF(SE1->E1_DIASPRO > 0, SE1->E1_DIASPRO, SZI->ZI_DIASPRO)
	_dData := _dData + 1 //(incrementar 1 dia no vencimento)
	If _dData == DataValida(_dData,.T.)
		_nCont++
	EndIf
EndDo

Return(_dData)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg บAutor  ณAnderson C. P. Coelho บ Data ณ  20/12/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Sub-rotina utilizada para verificar se as perguntas ja     บฑฑ
ฑฑบ          ณestao cadastradas na SX1, as criando, caso nao existam.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidPerg()
//************************************************************
// INICIO
// ARCOLOR - Declara็ใo de varํaveis para nใo gerar error_log
// RODRIGO TELECIO em 24/08/2022
//************************************************************
local i
local j
// FIM
//************************************************************
Local _aSArea  := GetArea()
Local aRegs    := {}

cPerg          := PADR(cPerg,10)

_aTam := TamSx3("E1_PREFIXO")
AAdd(aRegs,{cPerg,"01","Prefixo de         ?","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"MV_PAR01",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
AAdd(aRegs,{cPerg,"02","Prefixo ate        ?","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"MV_PAR02",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
_aTam := TamSx3("E1_NUM"    )
AAdd(aRegs,{cPerg,"03","Numero de          ?","","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"MV_PAR03",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
AAdd(aRegs,{cPerg,"04","Numero ate         ?","","","mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR04",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
_aTam := TamSx3("E1_NUMBOR" )
AAdd(aRegs,{cPerg,"05","Bordero de         ?","","","mv_ch5",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"MV_PAR05",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
AAdd(aRegs,{cPerg,"06","Bordero ate        ?","","","mv_ch6",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR06",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
_aTam := TamSx3("E1_EMISSAO")
AAdd(aRegs,{cPerg,"07","Emissao de         ?","","","mv_ch7",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"MV_PAR07",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
AAdd(aRegs,{cPerg,"08","Emissao ate        ?","","","mv_ch8",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR08",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
_aTam := TamSx3("E1_VENCTO" )
AAdd(aRegs,{cPerg,"09","Vencimento de      ?","","","mv_ch9",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"MV_PAR09",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
AAdd(aRegs,{cPerg,"10","Vencimento Ate     ?","","","mv_cha",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR10",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
_aTam := TamSx3("C5_NUM"    )
AAdd(aRegs,{cPerg,"11","Do Pedido de Vendas?","","","mv_chb",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"MV_PAR11",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SC5","",""})
AAdd(aRegs,{cPerg,"12","Ao Pedido de Vendas?","","","mv_chc",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR12",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SC5","",""})
_aTam := TamSx3("EE_CODIGO" )
AADD(aRegs,{cPerg,"13","Banco              ?","","","mv_chd",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR13",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SA6","",""})
_aTam := TamSx3("EE_AGENCIA")
AADD(aRegs,{cPerg,"14","Agencia            ?","","","mv_che",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR14",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
_aTam := TamSx3("EE_CONTA"  )
AADD(aRegs,{cPerg,"15","Conta              ?","","","mv_chf",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR15",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
_aTam := TamSx3("EE_SUBCTA" )
AADD(aRegs,{cPerg,"16","Sub-Conta          ?","","","mv_chg",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR16",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"17","Msg 01 s๓ p/ boleto?","","","mv_chh","C"      ,60       ,0        ,0,"G",""          ,"MV_PAR17",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"18","Msg 02 s๓ p/ boleto?","","","mv_chi","C"      ,60       ,0        ,0,"G",""          ,"MV_PAR18",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})

For i := 1 To Len(aRegs)
	dbSelectArea("SX1")
	dbSetOrder(1)
	If !dbSeek(cPerg+aRegs[i,2])
        RecLock("SX1",.T.)
		For J:= 1 To FCount()
			If J <= Len(aRegs[i])
				FieldPut(J,aRegs[i,j])
			Else
				Exit
			EndIf
		Next
		SX1->(MsUnlock())
	EndIf
Next

RestArea(_aSArea)

Return()
