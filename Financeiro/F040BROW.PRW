#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH' 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ F040BROW  บAutor ณ J๚lio Soares       บ Data ณ  04/02/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ O ponto de entrada F040BROW ษ executado antes da execu็ใo  บฑฑ
ฑฑบ          ณ do browse serve para tratamentos de exibi็ใo dos dados no  บฑฑ
ฑฑบ          ณ browse.                                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico para a empresa Arcolor.            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function F040BROW()

Local _aSavArea    := GetArea()
Local _aSavSE1     := SE1->(GetArea())

Private _cAlias    := "SE1"
Private _cCarga    := ""
Private _cFilSEU   := ""
Private _cRotina   := "F040BROW"
Private _cUserId   := __cUserId
Private _cUserPer  := SuperGetMV('MV_USRCXIL',,"")

//Private _aCores    := {}
Private _aIndexSE1 := {}

Private _lRet      := .F.

//Public _cCarga

//SetKey(VK_F10, { || _CadCheq() })
// Teclas alterada em 19/08/15 por J๚lio Soares para nใo conflitar com as teclas de atalho padrใo.
//SetKey( VK_F10,{|| MsgAlert( "Tecla [ F10 ] foi alterada para [ Ctrl + F10 ]" , "Protheus11" )})
SetKey( K_CTRL_F10, { || })
SetKey( K_CTRL_F10, { || _CadCheq()})

If _cUserId $ (AllTrim(_cUserPer))
	_Param()
EndIf

RestArea(_aSavSE1)
RestArea(_aSavArea)
				
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ _CadCheq  บAutor  ณJ๚lio Soares       บ Data ณ  03/04/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina baseada no fonte padrใo para que seja inserido de   บฑฑ
ฑฑบ          ณ forma facilitada, via tecla de atalho, os cheques recebidosบฑฑ
ฑฑบ          ณ conforme o numero da carga.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function _CadCheq()

If Type("aColsSEF")<>"A"
	Public aColsSEF := {}
EndIf

//Somente gravo cheques de titulos que nao sejam abatimentos ou provisorios
If !(SE1->E1_TIPO $ MVPROVIS+"/"+MVABATIM)
//	CadCheqCR(cBanco,cAgencia,cConta,nValRec,dData,3,,lTela) // - Trecho original.
	CadCheqCR(      ,        ,      ,       ,     ,3,aColsSEF)

//	GravaChqCR(cSeqBaixa,cOrigem  ,aColsSEF,aSeqSe5,lBaixou) // - Trecho original.
	GravaChqCR(         ,"FINA040",aColsSEF) // Grava os cheques recebidos
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ _Param   บAutor  ณJ๚lio Soares        บ Data ณ  04/02/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina criada para filtrar os dados a serem apresentados   บฑฑ
ฑฑบ          ณ na tela do contas a receber conforme numero da carga       บฑฑ
ฑฑบ          ณ informado.                                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function _Param()

Local oGroup
Local oCancela
Local oConfirma
Local Carga

_cCarga  := Space(TamSx3("DAI_COD" )[01])

Static  oDlg
	DEFINE MSDIALOG oDlg TITLE "Filtro de tํtulos por carga." FROM 000, 000  TO 120, 200 COLORS 0, 16777215 PIXEL //STYLE DS_MODALFRAME // Inibe o botao "X" da tela
	If __cUserId <> '000000'
		oDlg:lEscClose := .F.//Nใo permite fechar a tela com o "Esc"
	EndIf
		@ 005, 005 GROUP   oGroup    TO 042, 095 PROMPT "Selecione o Nฐ da carga."                     OF oDlg COLOR 8404992, 16777215 PIXEL
		@ 022, 015 MSGET   Carga     VAR _cCarga F3 "DAK"  VALID ExistCpo("DAK",_cCarga) SIZE 065, 012 OF oDlg COLORS 0     , 16777215 PIXEL
		@ 045, 060 BUTTON  oConfirma PROMPT "Confirma"                                   SIZE 035, 012 OF oDlg ACTION Gravar()         PIXEL
    	@ 045, 020 BUTTON  oCancela  PROMPT "Cancela"                                    SIZE 035, 012 OF oDlg ACTION Cancelar()       PIXEL
	ACTIVATE MSDIALOG oDlg CENTERED
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCancelar  บAutor  ณJ๚lio Soares        บ Data ณ  31/01/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Sub-rotina de cancelamento (SEM USO NESTE PONTO DE ENTRADA)บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Cancelar()

_cFilSE1 := " E1_CLIENTE == '999999' .AND. E1_LOJA == '99' .AND. E1_NOMERAZ = 'XXX'"
bFiltraBrw := {|| FilBrowse(_cAlias,@_aIndexSE1,@_cFilSE1)}
Eval(bFiltraBrw)
Close(oDlg)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Gravar    บAutor  ณJ๚lio Soares       บ Data ณ  31/01/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Sub-rotina de grava็ใo                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Gravar()

If !Empty (_cCarga)
	_cCheck := " SELECT E1_CODCARG "
	_cCheck += " FROM " + RetSqlName("SE1") + " SE1 "
	_cCheck += " WHERE SE1.D_E_L_E_T_ = '' "
	_cCheck += "   AND SE1.E1_FILIAL  = '" + xFilial("SE1") + "' "
	_cCheck += "   AND SE1.E1_SALDO  <> 0 " // - aguardando valida็ใo para verificar se serแ necesแrio apresentar ou nใo os tํtulos baixados.
	_cCheck += "   AND SE1.E1_CODCARG = '" + _cCarga + "' "
	If TCSQLExec(_cCheck) >= 0
		_cFilSE1 := " E1_CODCARG == '" + Alltrim(_cCarga) + "' "
		If Valtype(_cFilSE1) == "C" .AND. !Empty(_cFilSE1)
			bFiltraBrw := {|| FilBrowse(_cAlias,@_aIndexSE1,@_cFilSE1)}
			Eval(bFiltraBrw)
		EndIf
	Else
		MSGBOX('NรO Hม DADOS A SEREM VISUALIZADOS',_cRotina+'_003','ALERT')
		_cFilSE1 := " E1_CLIENTE == '999999' .AND. E1_LOJA == '99' .AND. E1_NOMERAZ = 'XXX'"
		bFiltraBrw := {|| FilBrowse(_cAlias,@_aIndexSE1,@_cFilSE1)}
		Eval(bFiltraBrw)
	EndIf
	Close(oDlg)
EndIf

Return()

/*
//SetKey(VK_F10, { || _ImpCheq() })
//SetKey(VK_F9,  { || FA040Alter('SE1',(Recno()),4)})
//SetKey(VK_F10, { || CadCheqCR(,,,,,3) })

CadCheqCR(X1    ,X2      ,X3    ,X4     ,X5   ,3)
CadCheqCR(cBanco,cAgencia,cConta,nValRec,dData,3,,lTela)
DEFAULT cBanco   := Space(TamSx3("EF_BANCO")[1])
DEFAULT cAgencia := Space(TamSx3("EF_AGENCIA")[1])
DEFAULT cConta   := Space(TamSx3("EF_CONTA")[1])
DEFAULT nValRec  := 0
DEFAULT dData    := dDataBase
DEFAULT lTela    := .T.
*/