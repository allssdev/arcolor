#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณRFATR028  บ Autor ณJ๚lio Soares          บ Data ณ  04/07/17 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Relat๓rio criado para compara็ใo das regras de neg๓cios porบฑฑ
ฑฑบ          ณ produto e volume conforme sele็ใo realizada.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para empresa ARCOLOR              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RFATR028()

Local   _aSavArea  := GetArea()
Private _cRotina   := "RFATR028"
Private _cPerg     := _cRotina
Private _cTitulo   := ""
Private _cTitulo2  := ""
Private _cQuery    := ""
Private _tAlias	   := "TMPRFT28"
Private _aCpos     := {}		//Campos a serem atualizados
Private _lEnt      := + CHR(13) + CHR(10)
Private _lRet      := .T.

// - TELA DE PARยMETROS
ValidPerg()
/* FB - RELEASE 12.1.23
While !Pergunte(_cPerg,.T.)
	If MsgYesNo("Deseja cancelar a emissใo do relat๓rio?",_cRotina+"_01")
		Return()
	EndIf
EndDo
*/
IF  !Pergunte(_cPerg,.T.)
	MSGBOX("Fun็ใo cancelada pelo usuแrio!",'CANCELADO','STOP')
	Return()
ENDIF


// - VERIFICA SE USUมRIO TEM PERMISSรO PARA GERAR DADOS EM EXCEL
If !(SubStr(cAcesso,160,1) == "S" .AND. SubStr(cAcesso,168,1) == "S" .AND. SubStr(cAcesso,170,1) == "S")
	MSGBOX('Usuแrio sem permissใo para gerar relat๓rio em Excel. Informe o Administrador.',_cRotina +"02",'STOP')
   Return(Nil)
EndIf

/*// - VERIFICA SE Hม O EXCEL INSTALADO NA MมQUINA EM USO
If __cUserID <> '000000'
	If !ApOleClient('MsExcel')
		Msgbox('Excel nใo instalado.',_cRotina +"03",'ALERT')
	   Return(Nil)
	EndIf
EndIf*/
_cTitulo  := (" Relat๓rio comparativo de regras de neg๓cio. Comparando regra " + MV_PAR01 + " e regra " + MV_PAR02 + " - " + _cRotina)

_cTitulo2 := ("PARยMETROS")

// CHAMA FUNวรO DE CONSULTA CONFORME PARยMETROS DEFINIDO PELO USUมRIO
MsgRun("Selecionando dados... Por favor AGUARDE. ",_cTitulo,{ || SelectQry() })

// - CHAMA A FUNวรO PARA EMITIR OS DADOS EM PLANILHA
Processa({ |lEnd| Geraxls(@lEnd) },_cRotina,' Gerando relat๓rio em Excel...   Por favor aguarde.',.T.)

// - SE A TABELA APRESENTAR DADOS FECHA A MESMA APำS O USO
If Select (_tAlias) > 0
   (_tAlias)->(dbCloseArea())
EndIf

dbCloseArea(_tAlias)

RestArea(_aSavArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ RFATR017  บ Autor ณJ๚lio Soares         บ Data ณ  04/10/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsแvel pela sele็ใo dos dados a partir da      บฑฑ
ฑฑบ          ณ consulta .                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para empresa ARCOLOR              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SelectQry()

// - MONTA O ARRAY COM A ORDEM DAS COLUNAS NO EXCEL
AADD(_aCpos,{"Grp.Prod."    ,"(_tAlias)->Grp1"   ,1,1,.F.})
AADD(_aCpos,{"Produto"      ,"(_tAlias)->Prd1"   ,1,1,.F.})
AADD(_aCpos,{"Descricao"    ,"(_tAlias)->Dsc1"   ,1,1,.F.})
AADD(_aCpos,{"Desconto1"    ,"(_tAlias)->Dsct11" ,3,2,.F.})
AADD(_aCpos,{"Desconto2"    ,"(_tAlias)->Dsct21" ,3,2,.F.})
AADD(_aCpos,{"Desconto3"    ,"(_tAlias)->Dsct31" ,3,2,.F.})
AADD(_aCpos,{"Desconto4"    ,"(_tAlias)->Dsct41" ,3,2,.F.})
AADD(_aCpos,{"Desc.Efetivo" ,"(_tAlias)->Dsct51" ,3,2,.F.})
AADD(_aCpos,{"Volume Ate"   ,"(_tAlias)->Vol11"  ,3,2,.F.})
AADD(_aCpos,{"Prioridade"   ,"(_tAlias)->Prio11" ,2,1,.F.})

AADD(_aCpos,{""             ,""                  ,2,1,.F.})

AADD(_aCpos,{"Grp.Prod."    ,"(_tAlias)->Grp2"   ,1,1,.F.})
AADD(_aCpos,{"Produto"      ,"(_tAlias)->Prd2"   ,1,1,.F.})
AADD(_aCpos,{"Descricao"    ,"(_tAlias)->Dsc2"   ,1,1,.F.})
AADD(_aCpos,{"Desconto1"    ,"(_tAlias)->Dsct12" ,3,2,.F.})
AADD(_aCpos,{"Desconto2"    ,"(_tAlias)->Dsct22" ,3,2,.F.})
AADD(_aCpos,{"Desconto3"    ,"(_tAlias)->Dsct32" ,3,2,.F.})
AADD(_aCpos,{"Desconto4"    ,"(_tAlias)->Dsct42" ,3,2,.F.})
AADD(_aCpos,{"Desc.Efetivo" ,"(_tAlias)->Dsct52" ,3,2,.F.})
AADD(_aCpos,{"Volume Ate"   ,"(_tAlias)->Vol22"  ,3,2,.F.})
AADD(_aCpos,{"Prioridade"   ,"(_tAlias)->Prio22" ,2,1,.F.})

// - CONSTROI A QUERY PARA A CONSULTA NO BANCO
_cQrySel := ""
_cQryGrp := ""
_cQryOrd := ""

_cQrySel += " SELECT * "                                                                                                       + _lEnt
_cQrySel += " FROM( "                                                                                                          + _lEnt
_cQrySel += " SELECT "                                                                                                         + _lEnt
_cQrySel += " ISNULL(RG1.[Grp1]  ,''              )[Grp1],   "                                                                 + _lEnt
_cQrySel += " ISNULL(RG1.[Prd1]  ,''              )[Prd1],   "                                                                 + _lEnt
_cQrySel += " ISNULL(RG1.[Dsc1]  ,'NAO ENCONTRADO')[Dsc1],   "                                                                 + _lEnt
_cQrySel += " ISNULL(RG1.[Dsct11],''              )[Dsct11], "                                                                 + _lEnt
_cQrySel += " ISNULL(RG1.[Dsct12],''              )[Dsct21], "                                                                 + _lEnt
_cQrySel += " ISNULL(RG1.[Dsct13],''              )[Dsct31], "                                                                 + _lEnt
_cQrySel += " ISNULL(RG1.[Dsct14],''              )[Dsct41], "                                                                 + _lEnt
_cQrySel += " ISNULL(RG1.[Dsct15],''              )[Dsct51], "                                                                 + _lEnt
_cQrySel += " ISNULL(RG1.[Vol1]  ,''              )[Vol11],  "                                                                 + _lEnt
_cQrySel += " ISNULL(RG1.[Prio1] ,''              )[Prio11], "                                                                 + _lEnt
_cQrySel += " '*'[-], "                                                                                                        + _lEnt
_cQrySel += " ISNULL(RG2.[Grp2]  ,''              )[Grp2],   "                                                                 + _lEnt
_cQrySel += " ISNULL(RG2.[Prd2]  ,''              )[Prd2],   "                                                                 + _lEnt
_cQrySel += " ISNULL(RG2.[Dsc2]  ,'NAO ENCONTRADO')[Dsc2],   "                                                                 + _lEnt
_cQrySel += " ISNULL(RG2.[Dsct21],''              )[Dsct12], "                                                                 + _lEnt
_cQrySel += " ISNULL(RG2.[Dsct22],''              )[Dsct22], "                                                                 + _lEnt
_cQrySel += " ISNULL(RG2.[Dsct23],''              )[Dsct32], "                                                                 + _lEnt
_cQrySel += " ISNULL(RG2.[Dsct24],''              )[Dsct42], "                                                                 + _lEnt
_cQrySel += " ISNULL(RG2.[Dsct25],''              )[Dsct52], "                                                                 + _lEnt
_cQrySel += " ISNULL(RG2.[Vol2]  ,''              )[Vol22],  "                                                                 + _lEnt
_cQrySel += " ISNULL(RG2.[Prio2] ,''              )[Prio22]  "                                                                 + _lEnt
_cQrySel += " FROM ( "                                                                                                         + _lEnt
_cQrySel += " 		SELECT ACN.ACN_GRPPRO[Grp1],ACN.ACN_CODPRO[Prd1],SB1.B1_DESC[Dsc1], "                                      + _lEnt
_cQrySel += " 		ACN.ACN_DESCV1[Dsct11],ACN.ACN_DESCV2[Dsct12],ACN.ACN_DESCV3[Dsct13],ACN.ACN_DESCV4[Dsct14], "             + _lEnt
_cQrySel += " 		ACN.ACN_DESCON[Dsct15],ACN.ACN_QUANTI[Vol1],ACN.ACN_PROMOC[Prio1] "                                        + _lEnt
_cQrySel += " 		FROM ACN010 ACN "                                                                                          + _lEnt
_cQrySel += " 			INNER JOIN " + RetSqlName("SB1") + " SB1 "                                                             + _lEnt
_cQrySel += " 				ON SB1.D_E_L_E_T_ = '' "                                                                           + _lEnt
_cQrySel += " 				AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "                                                     + _lEnt
_cQrySel += " 				AND SB1.B1_COD = ACN.ACN_CODPRO "                                                                  + _lEnt
_cQrySel += " 		WHERE ACN.D_E_L_E_T_ = '' "                                                                                + _lEnt
_cQrySel += " 		AND ACN.ACN_FILIAL = '" + xFilial("ACN") + "' "                                                            + _lEnt
_cQrySel += " 		AND ACN.ACN_CODREG = '" + MV_PAR01 + "' "                                                                  + _lEnt
_cQrySel += " 		AND ACN.ACN_GRPPRO BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "                                      + _lEnt
_cQrySel += " 		AND ACN.ACN_CODPRO BETWEEN '" + MV_PAR05 +"' AND '" + MV_PAR06 + "' "                                      + _lEnt
_cQrySel += " 	 ) RG1 "                                                                                                       + _lEnt
_cQrySel += " FULL OUTER JOIN ( "                                                                                              + _lEnt
_cQrySel += " 					SELECT ACN.ACN_GRPPRO[Grp2],ACN.ACN_CODPRO[Prd2],SB1.B1_DESC[Dsc2], "                          + _lEnt
_cQrySel += " 					ACN.ACN_DESCV1[Dsct21],ACN.ACN_DESCV2[Dsct22],ACN.ACN_DESCV3[Dsct23],ACN.ACN_DESCV4[Dsct24], " + _lEnt
_cQrySel += " 					ACN.ACN_DESCON[Dsct25],ACN.ACN_QUANTI[Vol2],ACN.ACN_PROMOC[Prio2] "                            + _lEnt
_cQrySel += " 					FROM ACN010 ACN "                                                                              + _lEnt
_cQrySel += " 						INNER JOIN " + RetSqlName("SB1") + " SB1 "                                                 + _lEnt
_cQrySel += " 							ON SB1.D_E_L_E_T_ = '' "                                                               + _lEnt
_cQrySel += " 							AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "                                         + _lEnt
_cQrySel += " 							AND SB1.B1_COD = ACN.ACN_CODPRO "                                                      + _lEnt
_cQrySel += " 					WHERE ACN.D_E_L_E_T_ = '' "                                                                    + _lEnt
_cQrySel += " 					AND ACN.ACN_FILIAL = '" + xFilial("ACN") + "' "                                                + _lEnt
_cQrySel += " 					AND ACN.ACN_CODREG = '" + MV_PAR02 + "' "                                                      + _lEnt
_cQrySel += " 					AND ACN.ACN_GRPPRO BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "                          + _lEnt
_cQrySel += " 					AND ACN.ACN_CODPRO BETWEEN '" + MV_PAR05 +"' AND '" + MV_PAR06 + "' "                          + _lEnt
_cQrySel += " 				) RG2 "                                                                                            + _lEnt
_cQrySel += " 				ON RG2.Prd2  = RG1.Prd1 "                                                                          + _lEnt
//_cQrySel += " 				OR RG2.Grp2  = RG1.Grp1 "                                                                         + _lEnt
_cQrySel += " 				AND RG2.Vol2 = RG1.Vol1 "                                                                          + _lEnt
_cQrySel += " ) TABTMP "                                                                                                       + _lEnt

If MV_PAR07 == 2
	_cQrySel += " WHERE [Grp1] <> [Grp2] OR [Prd1] <> [Prd2] OR [Vol11] <> [Vol22] "                                           + _lEnt
EndIf

_cQryOrd += " ORDER BY Grp1,Prd1,Vol11,Grp2,Prd2,Vol22 "

_cQry := _cQrySel + _cQryOrd

//MemoWrite("\2.Memowrite\"+_cRotina+"_QRY_01.TXT",_cQry)

If (Len(_cQry) ) >0
	_cQry := ChangeQuery(_cQry) // incluido para tratamento no novo processo.
Else
	MSGBOX('CONSULTA NรO GERADA ','*** ***','STOP')
	Return()	
EndIf

// - GERA A QUERY FORMADA
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_tAlias,.T.,.F.)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFATR017  บAutor  ณMicrosiga           บ Data ณ  15/01/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsใvel por gerar a planilha conforme dados     บฑฑ
ฑฑบ          ณ obtidos da consulta formada de acordo com parโmetros       บฑฑ
ฑฑบ          ณ inseridos pelo usuแrio.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para empresa ARCOLOR              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Geraxls(lEnd)

Local oExcel
Local _cSheet1  := (MV_PAR01) + "  " + (MV_PAR02)
Local _cSheet2  := 'PARยMETROS'
Local _cFileTMP := ""
Local _cFile    := ""

Private _aPar   := {}

dbSelectArea(_tAlias)
ProcRegua(((_tAlias)->(RecCount())*2)+1)
(_tAlias)->(dbGoTop())
If !(_tAlias)->(EOF())
	oExcel := FWMSEXCEL():New()
	oExcel:AddWorkSheet(_cSheet1)
	oExcel:AddTable(_cSheet1,_cTitulo)

	For _x := 1 To Len(_aCpos)
		oExcel:AddColumn(_cSheet1,_cTitulo,_aCpos[_x][01],_aCpos[_x][03],_aCpos[_x][04],_aCpos[_x][05])
	Next

	// - ACRESCENTA A LINHA PRIMARIA COM O SUBCABEวALHO.
	_aCabec := {'','','CODIGO DA REGRA: ' + MV_PAR01,'','','','','','','','*','','','CODIGO DA REGRA: ' + MV_PAR02,'','','','','','',''}
	oExcel:AddRow(_cSheet1, _cTitulo,_aCabec)

	// - ACRESCENTA AS LINHAS COM INFORMAวีES WHILE ! TEMP ->(EOF())
	While !(_tAlias)->(EOF()) .AND. !lEnd

		IncProc('PROCESSANDO REGRAS: '+ AllTrim((_tAlias)->Prd1) + '...')
		_aAux := {}
		For _x := 1 To Len(_aCpos)
		    AADD(_aAux, &(_aCpos[_x][02]))
		Next
		oExcel:AddRow(_cSheet1, _cTitulo, _aAux )
		(_tAlias)->(dbSkip())
	EndDo

	If lEnd
		Alert("Abortado!")
		FreeObj(oExcel)
		oExcel := NIL
		Return
	EndIf

	// - INCLUI UMA ABA COM AS INFORMAวีES DOS PARAMETROS
	oExcel:AddWorkSheet(_cSheet2)
	oExcel:AddTable(_cSheet2,_cTitulo2)
	oExcel:AddColumn(_cSheet2,_cTitulo2,"DESCRIวรO" ,1,1,.F.)
	oExcel:AddColumn(_cSheet2,_cTitulo2,"CONTEฺDO"  ,1,1,.F.)

	_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))

	_cPerg := PADR(_cPerg,10)
	If (_cAliasSX1)->(dbSeek(_cPerg))
		While !EOF() .And. (_cAliasSX1)->X1_GRUPO == _cPerg
			IncProc('PROCESSANDO PARAMETROS...')
			If AllTrim((_cAliasSX1)->X1_GSC)=="C"
				AAdd(_aPar,{ (_cAliasSX1)->X1_PERGUNT,&("(_cAliasSX1)->X1_DEF"+StrZero(&((_cAliasSX1)->X1_VAR01),2)) })
			Else
				AAdd(_aPar,{ (_cAliasSX1)->X1_PERGUNT,&((_cAliasSX1)->X1_VAR01) })
			EndIf
			dbSelectArea(_cAliasSX1)
			(_cAliasSX1)->(dbSkip())
		EndDo
	EndIf
	If Len(_aPar) > 0
		For _nPosPar := 1 To Len(_aPar)
			oExcel:AddRow(_cSheet2, _cTitulo2, _aPar[_nPosPar])
		Next
	EndIf

	// - IMPRIME O RELATำRIO NO EXCEL
	IncProc("ABRINDO ARQUIVO...")
	oExcel:Activate()
	_cFile := (CriaTrab(NIL, .F.) + ".xml")
	While File(_cFile)
		_cFile := (CriaTrab(NIL, .F.) + ".xml")
	EndDo
	oExcel:GetXMLFile(_cFile)
	oExcel:DeActivate()
	If !(File(_cFile))
		_cFile := ""
		Break
	EndIf
	_cFileTMP := (GetTempPath() + _cFile)
	If !(__CopyFile(_cFile , _cFileTMP))
		fErase( _cFile )
		_cFile := ""
		Break
	EndIf
	fErase(_cFile)
	_cFile := _cFileTMP
	If !(File(_cFile))                                                       	
		_cFile := ""
		Break
	EndIf
	oMsExcel:= MsExcel():New()
	oMsExcel:WorkBooks:Open(_cFile)
	oMsExcel:SetVisible(.T.)
	IncProc('RELATำRIO GERADO COM SUCESSO!')
	MSGBOX('Relat๓rio gerado, VERIFIQUE!!!',_cRotina+'_04','ALERT')
	oMsExcel:= oMsExcel:Destroy()
Else
	MSGBOX('Nใo hแ dados a serem apresentados. Informe o Administrador do sistema.',_cRotina+'_05','ALERT')
	Return()
EndIf

FreeObj(oExcel)
oExcel := NIL

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ ValidPerg บ Autor ณJ๚lio Soares         บ Data ณ  04/10/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsแvel pela inclusใo de parโmetros na rotina.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para empresa ARCOLOR              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ValidPerg()

Local _aSArea  := GetArea()
Local aHelpPor := {}
//Local aHelpSpa := {}
//Local aHelpEng := {}

_cPerg := PADR(_cPerg,10)

// - 01
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"Informe a primeira regra para a      "   )
AAdd(aHelpPor,"compara็ใo das informa็๕es."             )

PutSx1(_cPerg,"01","PrimeiraRegra ?"     ,"" ,"" ,"mv_ch1","C",06 ,0 ,0 ,"G" ,"NAOVAZIO()",""    ,"" ,"S" ,"mv_par01" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)

aHelpPor := {}
*/
_cPerg    := _cPerg
_cValid   := "NAOVAZIO()"
_cF3      := ""
_cPicture := ""
_cDef01   := ""
_cDef02   := ""
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Informe a primeira regra para a compara็ใo das informa็๕es."
U_RGENA001(_cPerg, "01" ,"Primeira Regra?" , "MV_PAR01", "MV_CH1", "C", 06, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

       
// - 02
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"Informe a segunda regra para a       "   )
AAdd(aHelpPor,"compara็ใo das informa็๕es."             )
PutSx1(_cPerg,"02","Segunda Regra ?"     ,"" ,"" ,"mv_ch2","C" ,06 ,0 ,0 ,"G" ,"NAOVAZIO()",""    ,"" ,"S" ,"mv_par02" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
*/
_cPerg    := _cPerg
_cValid   := "NAOVAZIO()"
_cF3      := ""
_cPicture := ""
_cDef01   := ""
_cDef02   := ""
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Informe a segunda regra para a compara็ใo das informa็๕es."
U_RGENA001(_cPerg, "02" ,"Primeira Regra?" , "MV_PAR02", "MV_CH2", "C", 06, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)


// - 03
/* FB - RELEASE 12.1.13
AAdd(aHelpPor,"Informe o grupo inicial dos produtos "   )
AAdd(aHelpPor,"para a compara็ใo das informa็๕es."      )
PutSx1(_cPerg,"03","De grupo ?"          ,"" ,"" ,"mv_ch3","C" ,04 ,0 ,0 ,"G" ,""          ,"SBM" ,"" ,"S" ,"mv_par03" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := "SBM"
_cPicture := ""
_cDef01   := ""
_cDef02   := ""
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Informe o grupo inicial dos produtos para a compara็ใo das informa็๕es."
U_RGENA001(_cPerg, "03" ,"De grupo?" , "MV_PAR03", "MV_CH3", "C", 04, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)


// - 04
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"Informe o grupo final dos produtos "     )
AAdd(aHelpPor,"para a compara็ใo das informa็๕es."      )
PutSx1(_cPerg,"04","At้ grupo ?"         ,"" ,"" ,"mv_ch4","C" ,04 ,0 ,0 ,"G" ,"NAOVAZIO()","SBM" ,"" ,"S" ,"mv_par04" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
*/
_cPerg    := _cPerg
_cValid   := "NAOVAZIO()"
_cF3      := "SBM"
_cPicture := ""
_cDef01   := ""
_cDef02   := ""
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Informe o grupo final dos produtos para a compara็ใo das informa็๕es."
U_RGENA001(_cPerg, "04" ,"De grupo?" , "MV_PAR04", "MV_CH4", "C", 04, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 05
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"Informe o c๓digo do produto inicial "    )
AAdd(aHelpPor,"para a compara็ใo das informa็๕es."      )
PutSx1(_cPerg,"05","De produto ?"        ,"" ,"" ,"mv_ch5","C" ,15 ,0 ,0 ,"G" ,""          ,"SB1" ,"" ,"S" ,"mv_par05" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := "SB1"
_cPicture := ""
_cDef01   := ""
_cDef02   := ""
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Informe o c๓digo do produto inicial para a compara็ใo das informa็๕es."
U_RGENA001(_cPerg, "05" ,"De produto ?" , "MV_PAR05", "MV_CH5", "C", 15, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)


// - 06
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"Informe o c๓digo do produto final "      )
AAdd(aHelpPor,"para a compara็ใo das informa็๕es."      )
PutSx1(_cPerg,"06","At้ produto ?"       ,"" ,"" ,"mv_ch6","C" ,15 ,0 ,0 ,"G" ,"NAOVAZIO()","SB1" ,"" ,"S" ,"mv_par06" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
*/
_cPerg    := _cPerg
_cValid   := "NAOVAZIO()"
_cF3      := "SB1"
_cPicture := ""
_cDef01   := ""
_cDef02   := ""
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Informe o c๓digo do produto final para a compara็ใo das informa็๕es."
U_RGENA001(_cPerg, "06" ,"At้ produto ?" , "MV_PAR06", "MV_CH6", "C", 15, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 07
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"Informe o tipo de compara็ใo a ser "     )
AAdd(aHelpPor,"realizada: "                             )
AAdd(aHelpPor,"- Informe 'DIFERENCAS' para que o relat๓")
AAdd(aHelpPor,"rio apresente apenas as diferen็as "     )
AAdd(aHelpPor,"encontradas.                       "     )
AAdd(aHelpPor,"- Informe 'TODAS' para que o relat๓rio"  )
AAdd(aHelpPor,"apresente todas as informa็๕es."         )
PutSx1(_cPerg,"07","Tipo de compara็ใo?" ,"" ,"" ,"mv_ch7","C" ,1 ,0 ,0 ,"C" ,""           ,""    ,"" ,"S" ,"mv_par07" ,"TODAS"        ,"" ,"" ,"" ,"DIFERENCAS"    ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := "TODAS"
_cDef02   := "DIFERENCAS"
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Informe o c๓digo do produto final para a compara็ใo das informa็๕es."
U_RGENA001(_cPerg, "07" ,"Tipo de compara็ใo?" , "MV_PAR07", "MV_CH7", "C", 01, 0, "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

RestArea(_aSArea)

Return()
