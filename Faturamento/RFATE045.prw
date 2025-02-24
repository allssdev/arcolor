#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFATE045  บAutor  ณJ๚lio Soares        บ Data ณ  04/02/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina utilizada para selecionar os tipos de opera็ใo      บฑฑ
ฑฑบ          ณ atrav้s de uma janela com op็๕es da tabela X5-DJ para que  บฑฑ
ฑฑบ          ณ o relat๓rio de Faturamento em Excel seja filtrado          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico empresa ARCOLOR                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RFATE045()

Local aArea      := GetArea()
Private _cRotina := 'RFATE045'
Private _lEnt    := CHR(13) + CHR(10)

_aStru1 := {}
AADD(_aStru1,{"TC_OK"     ,"C",02,0})
AADD(_aStru1,{"TC_CGCCENT","C",14,0})
AADD(_aStru1,{"TC_CGC"    ,"C",14,0})
AADD(_aStru1,{"TC_NOME"   ,"C",50,0})
AADD(_aStru1,{"TC_COD"    ,"C",06,0})
AADD(_aStru1,{"TC_LOJA"   ,"C",02,0})
AADD(_aStru1,{"TC_VEND"   ,"C",06,0})
AADD(_aStru1,{"TC_NOMEVD" ,"C",30,0})
/*
_cArq1 := CriaTrab(_aStru1,.T.)
dbUseArea(.T.,,_cArq1,"TRATMP",.T.,.F.)
IndRegua("TRATMP",_cArq1,"TC_CGCCENT + TC_NOME + TC_CGC",,,"Criando ํndice temporario...")
*/

//-------------------
//Criacao do objeto
//-------------------
oTempTable := FWTemporaryTable():New( "TRATMP" )
	
oTemptable:SetFields( _aStru1 )
oTempTable:AddIndex("indice1", {"TC_CGCCENT","TC_NOME","TC_CGC"} )

//------------------
//Criacao da tabela
//------------------
oTempTable:Create()

// - FORMACAO DA QUERY PARA VERIFICAR A TABELA SA1
_QryMark := " SELECT ''[MARQ],A1_CGCCENT[CNPJC],A1_CGC[CNPJ],A1_NOME[NOME],A1_COD[COD],A1_LOJA[LOJA],A1_VEND[VEND],A3_NOME[NOMEVD] " + _lEnt
_QryMark += " FROM " + RetSqlname("SA1") + " SA1 " + _lEnt
_QryMark += " INNER JOIN " + RetSqlName("SA3") + " SA3 " + _lEnt
_QryMark += "   ON SA3.D_E_L_E_T_ = '' " + _lEnt
_QryMark += "   AND SA3.A3_FILIAL = '" + xFilial("SA3") + "' " + _lEnt
_QryMark += "   AND SA3.A3_COD    = SA1.A1_VEND " + _lEnt
_QryMark += " WHERE SA1.D_E_L_E_T_ = '' " + _lEnt
_QryMark += " AND SA1.A1_FILIAL   = '" + xFilial("SA1") + "' " + _lEnt
_QryMark += " AND SA1.A1_CGCCENT <> '' " + _lEnt
_QryMark += " AND SA1.A1_NOME    <> '' " + _lEnt
_QryMark += " AND SA1.A1_MSBLQL  <> '1' " + _lEnt
_QryMark += " ORDER BY A1_CGCCENT, A1_NOME, A1_CGC " + _lEnt

//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_01",_QryMark)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_QryMark),"SA1MARK",.F.,.T.)

dbSelectArea("SA1MARK")
dbGoTop()
While !SA1MARK->(EOF())
	RecLock("TRATMP",.T.)
		TC_OK       := "  "
		TC_CGCCENT  := SA1MARK->(CNPJC)
		TC_CGC      := SA1MARK->(CNPJ)
		TC_NOME     := SA1MARK->(NOME)
		TC_COD      := SA1MARK->(COD)
		TC_LOJA     := SA1MARK->(LOJA)
		TC_VEND     := SA1MARK->(VEND)
		TC_NOMEVD   := SA1MARK->(NOMEVD)
	MsUnlock()
	SA1MARK->(dbSkip())
EndDo

PUBLIC _aSelCli       := {}

PRIVATE cFiltraTRATMP := " "
PRIVATE cMarca        := GetMark()
PRIVATE aCampos       := {}
PRIVATE aRotina       := {{"Confirma","U_SELON()",0,1}}
PRIVATE bFiltraBrw    := {|| NIL}

dbSelectArea("TRATMP")
dbSetOrder(1)
dbGotop()

//bFiltraBrw 	:= {|| FilBrowse("TRATMP",/*@aIndexTRB*A*/,@cFiltraTRATMP) }
bFiltraBrw 	:= {|| FilBrowse("TRATMP",,@cFiltraTRATMP) }
Eval(bFiltraBrw)

AADD(aCampos,{"TC_OK"      , ""," "                        ,"" })
AADD(aCampos,{"TC_CGCCENT" , "","CNPJ CENTRAL "            ,"" })
AADD(aCampos,{"TC_CGC"     , "","CNPJ         "            ,"" })
AADD(aCampos,{"TC_NOME"    , "","NOME CLIENTE             ","" })
AADD(aCampos,{"TC_COD"     , "","CODIGO CLIENTE"           ,"" })
AADD(aCampos,{"TC_LOJA"    , "","LOJA"                     ,"" })

// Altera็ใo - Fernando Bombardi - ALLSS - 02/03/2022
AADD(aCampos,{"TC_VEND"    , "","CODIGO REPRESENTANTE"    ,"" })
AADD(aCampos,{"TC_NOMEVD"  , "","NOME REPRESENTANTE"      ,"" })

//AADD(aCampos,{"TC_VEND"    , "","CODIGO VENDEDOR"          ,"" })
//AADD(aCampos,{"TC_NOMEVD"  , "","NOME VENDEDOR       "     ,"" })
// Fim - Fernando Bombardi - ALLSS - 02/03/2022

MarkBrowse("TRATMP","TC_OK",,aCampos,,cMarca,"U_SELALL()")

dbSelectArea("TRATMP")
dbSetOrder(1)
dbCloseArea()

RestArea( aArea ) 

// - Inicio da atualiza็ใo do campo auxiliar no cadastro do cliente
If Len(_aSelCli) > 0
	For _x := 1 To Len(_aSelCli)
		_cQry := " UPDATE " + RetSqlName("SA1") + " SET A1_RELFAT = '" + ALLTRIM(__cUserId) + "|" + "' "
		_cQry += " FROM " + RetSqlName("SA1") + ""
		_cQry += " WHERE D_E_L_E_T_     = ''"
		_cQry += " AND A1_FILIAL        = '" + xFilial("SA1") + "' "
		_cQry += " AND A1_COD + A1_LOJA = '" + _aSelCli[_x,1] + _aSelCli[_x,2] + "'"
		If TCSQLExec(_cQry) < 0
			MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_02")
		EndIf
		/*
		If _x == 1
		Else
		EndIf
		*/
	Next
EndIf

// - --------------------------------------------------------------


Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณSELON     บAutor  ณJ๚lio Soares           บ Data ณ 19/05/10 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณRotina utilizada para trazer os itens selecionados.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus10                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function SELON()

_aSelCli := {}

dbSelectArea("TRATMP")
dbSetOrder(1)
dbGoTop()
If !TRATMP->(EOF())
	While !EOF()
		_cQry := " UPDATE " + RetSqlName("SA1") + " SET A1_RELFAT = '" + ALLTRIM(__cUserId) + "|" + "' "
		_cQry += " FROM " + RetSqlName("SA1") + ""
		_cQry += " WHERE D_E_L_E_T_     = ''"
		_cQry += " AND A1_FILIAL        = '" + xFilial("SA1") + "' "
		_cQry += " AND A1_COD + A1_LOJA = '" + _aSelCli[_x,1] + _aSelCli[_x,2] + "'"
		If TCSQLExec(_cQry) < 0
			MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_02")
		EndIf
/*		If TRATMP->TC_OK <> "  "
			AADD(_aSelCli,{TRATMP->TC_COD,TRATMP->TC_LOJA,TC_CGCCENT})
		EndIf*/
		dbSkip()
	EndDo
Else
	MSGBOX("NENHUMA OPERAวรO FOI SELECIONADA",'','STOP')
EndIf

CloseBrowse()

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณSELALL    บAutor  ณJ๚lio Soares          บ Data ณ 19/05/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณMarca todos os itens do browse                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function SELALL()
Local _nReg := Recno()

dbSelectArea("TRATMP")
dbSetOrder(1)
dbGoTop()
While !EOF()
	RecLock("TRATMP",.F.)
		If TRATMP->TC_OK == cMarca
			TRATMP->TC_OK := "  "
		Else
			TRATMP->TC_OK := cMarca
		EndIf
	MsUnLock()
	dbSkip()
EndDo

dbGoTo(_nReg)

Return NIL
