#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณRPCPR005  บ Autor ณAnderson C. P. Coelho บ Data ณ  21/01/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Relat๓rio Sint้tico de Produ็ใo por Produto, por Perํodo,  บฑฑ
ฑฑบ          ณem Excel.                                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para empresa ARCOLOR.             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RPCPR005()

Local   _aSavArea  := GetArea()

Private _cRotina   := "RPCPR005"
Private cPerg      := _cRotina
Private _cTitulo   := ""
Private _cTitulo2  := ""
Private _cQuery    := ""
Private _tAlias	   := "TMP005"
Private _cCampos   := ""
Private _aColuns   := {}
Private _lRet      := .T.

ValidPerg()
IF !Pergunte(cPerg,.T.) //.OR. Empty(MV_PAR01) .OR. Len(AllTrim(MV_PAR01)) <> 4
	If MsgYesNo("Deseja cancelar a emissใo do relat๓rio?"+IIF(Empty(MV_PAR01)," Primeiro parโmetro nใo preenchido!",""),_cRotina+"_001")
		MSGBOX("Fun็ใo cancelada pelo usuแrio!",_cRotina+"_002",'STOP')
		Return()
	EndIf
ENDIF
// - VERIFICA SE USUมRIO TEM PERMISSรO PARA GERAR DADOS EM EXCEL
/*
If !(SubStr(cAcesso,160,1) == "S" .AND. SubStr(cAcesso,168,1) == "S" .AND. SubStr(cAcesso,170,1) == "S")
	MSGBOX('Usuแrio sem permissใo para gerar relat๓rio em Excel. Informe o Administrador.',_cRotina+"_002",'STOP')
	Return(Nil)
EndIf
// - VERIFICA SE Hม O EXCEL INSTALADO NA MมQUINA EM USO
If __cUserID <> '000000'
	If !ApOleClient('MsExcel')
		Msgbox('Excel nใo instalado!',_cRotina+"_004",'ALERT')
		Return(Nil)
	EndIf
EndIf*/
cTitulo  := "RELATำRIO DE PRODUวรO POR PRODUTO - Sint้tico - ANO " + mv_par01

// CHAMA FUNวรO DE CONSULTA CONFORME PARยMETROS DEFINIDO PELO USUมRIO
//Processa({|| _cQuery := SelectQry()},"Rela็ใo de Faturamento","Selecionando dados... AGUARDE. ",.T.)
MsgRun("Processando dados... Por favor aguarde.",_cRotina,{ || _cQuery := SelectQry() })
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_tAlias,.T.,.F.)

Processa( { |lEnd| Geraxls(@lEnd) }, "["+_cRotina+"] "+cTitulo,"Gerando relat๓rio em Excel... Por favor aguarde...",.T.)

// - SE A TABELA APRESENTAR DADOS FECHA A MESMA APำS O USO
If Select (_tAlias) > 0
   (_tAlias)->(dbCloseArea())
EndIf

//dbCloseArea(_tAlias)

RestArea(_aSavArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณSelectQry บ Autor ณAnderson C. P. Coelho บ Data ณ  21/01/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Sub-Rotina para montagem da Query do Relat๓rio.            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para empresa ARCOLOR.             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SelectQry()

_cQuery := " SELECT D3_COD PRODUTO, B1_DESC DESCRI, B1_TIPO TIPO, B1_UM UM, "
_cQuery += " 		SUM(CASE WHEN D3_EMISSAO       = '" + AllTrim(MV_PAR01) + "01' THEN D3_QUANT ELSE 0 END ) Jan_"+AllTrim(MV_PAR01)+", "
_cQuery += " 		SUM(CASE WHEN D3_EMISSAO       = '" + AllTrim(MV_PAR01) + "02' THEN D3_QUANT ELSE 0 END ) Fev_"+AllTrim(MV_PAR01)+", "
_cQuery += " 		SUM(CASE WHEN D3_EMISSAO       = '" + AllTrim(MV_PAR01) + "03' THEN D3_QUANT ELSE 0 END ) Mar_"+AllTrim(MV_PAR01)+", "
_cQuery += " 		SUM(CASE WHEN D3_EMISSAO       = '" + AllTrim(MV_PAR01) + "04' THEN D3_QUANT ELSE 0 END ) Abr_"+AllTrim(MV_PAR01)+", "
_cQuery += " 		SUM(CASE WHEN D3_EMISSAO       = '" + AllTrim(MV_PAR01) + "05' THEN D3_QUANT ELSE 0 END ) Mai_"+AllTrim(MV_PAR01)+", "
_cQuery += " 		SUM(CASE WHEN D3_EMISSAO       = '" + AllTrim(MV_PAR01) + "06' THEN D3_QUANT ELSE 0 END ) Jun_"+AllTrim(MV_PAR01)+", "
_cQuery += " 		SUM(CASE WHEN D3_EMISSAO BETWEEN '" + AllTrim(MV_PAR01) + "01' AND '" + AllTrim(MV_PAR01) + "06' THEN D3_QUANT ELSE 0 END ) PRI_SEM, "
_cQuery += " 		SUM(CASE WHEN D3_EMISSAO       = '" + AllTrim(MV_PAR01) + "07' THEN D3_QUANT ELSE 0 END ) Jul_"+AllTrim(MV_PAR01)+", "
_cQuery += " 		SUM(CASE WHEN D3_EMISSAO       = '" + AllTrim(MV_PAR01) + "08' THEN D3_QUANT ELSE 0 END ) Ago_"+AllTrim(MV_PAR01)+", "
_cQuery += " 		SUM(CASE WHEN D3_EMISSAO       = '" + AllTrim(MV_PAR01) + "09' THEN D3_QUANT ELSE 0 END ) Set_"+AllTrim(MV_PAR01)+", "
_cQuery += " 		SUM(CASE WHEN D3_EMISSAO       = '" + AllTrim(MV_PAR01) + "10' THEN D3_QUANT ELSE 0 END ) Out_"+AllTrim(MV_PAR01)+", "
_cQuery += " 		SUM(CASE WHEN D3_EMISSAO       = '" + AllTrim(MV_PAR01) + "11' THEN D3_QUANT ELSE 0 END ) Nov_"+AllTrim(MV_PAR01)+", "
_cQuery += " 		SUM(CASE WHEN D3_EMISSAO       = '" + AllTrim(MV_PAR01) + "12' THEN D3_QUANT ELSE 0 END ) Dez_"+AllTrim(MV_PAR01)+", "
_cQuery += " 		SUM(CASE WHEN D3_EMISSAO BETWEEN '" + AllTrim(MV_PAR01) + "07' AND '" + AllTrim(MV_PAR01) + "12' THEN D3_QUANT ELSE 0 END ) SEG_SEM, "
_cQuery += " 		SUM(D3_QUANT) ANO "
_cQuery += " FROM (
_cQuery += " 		SELECT SUBSTRING(D3_EMISSAO,1,6) D3_EMISSAO, D3_COD, B1_DESC, B1_TIPO, B1_UM, "
_cQuery += " 		       SUM(CASE WHEN D3_TM > '500' THEN D3_QUANT*(-1) ELSE D3_QUANT END) D3_QUANT "
_cQuery += " 		FROM " + RetSqlName("SD3") + " SD3 (NOLOCK)"
_cQuery += " 		  INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.D_E_L_E_T_ = '' "
_cQuery += " 		                       AND SB1.B1_FILIAL      = '" + xFilial("SB1")                  + "' "
_cQuery += " 							   AND SB1.B1_COD   BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' "
_cQuery += " 							   AND SB1.B1_GRUPO BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "' "
_cQuery += " 							   AND SB1.B1_TIPO  BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' "
_cQuery += " 							   AND SB1.B1_COD         = SD3.D3_COD "
_cQuery += " 		WHERE SD3.D_E_L_E_T_ = '' "
_cQuery += " 		  AND SD3.D3_FILIAL  = '" + xFilial("SD3") + "' "
_cQuery += " 		  AND SD3.D3_OP     <> '' "
_cQuery += " 		  AND SUBSTRING(SD3.D3_EMISSAO,1,4) = '" + AllTrim(MV_PAR01) + "' "
_cQuery += " 		  AND (SD3.D3_TM    = '010' OR SD3.D3_TM     = '999') "
_cQuery += " 		GROUP BY SUBSTRING(D3_EMISSAO,1,6), D3_COD, B1_DESC, B1_TIPO, B1_UM "
_cQuery += " 	  ) XXX "
If MV_PAR08 == 1
	_cQuery += " WHERE XXX.D3_QUANT >= 0 "
EndIf
_cQuery += " GROUP BY D3_COD, B1_DESC, B1_TIPO, B1_UM "
_cQuery += " ORDER BY D3_COD, B1_DESC, B1_TIPO, B1_UM "
/*
If __cUserId == "000000"
	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001",_cQuery)
EndIf
*/
_cQuery := ChangeQuery(_cQuery)

Return(_cQuery)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณGeraxls   บAutor  ณAnderson C. P. Coelho บ Data ณ  15/01/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsใvel por gerar a planilha conforme dados     บฑฑ
ฑฑบ          ณ obtidos da consulta formada de acordo com parโmetros       บฑฑ
ฑฑบ          ณ inseridos pelo usuแrio.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para empresa ARCOLOR.             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Geraxls(lEnd)

Local oExcel    := FWMSEXCEL():New()
Local _aInfo    := {}
Local _cSheet1  := "Ano "+MV_PAR01
Local _cFileTMP := ""
Local _cFile    := ""

oExcel:AddWorkSheet(_cSheet1)
oExcel:AddTable(_cSheet1,cTitulo)
oExcel:AddColumn(_cSheet1,cTitulo,'PRODUTO'               ,1,1,.F.)
oExcel:AddColumn(_cSheet1,cTitulo,'DESCRIวรO'             ,1,1,.F.)
oExcel:AddColumn(_cSheet1,cTitulo,'TIPO'                  ,2,1,.F.)
oExcel:AddColumn(_cSheet1,cTitulo,'UM'                    ,2,1,.F.)
oExcel:AddColumn(_cSheet1,cTitulo,'Jan/'+AllTrim(MV_PAR01),3,2,.T.)
oExcel:AddColumn(_cSheet1,cTitulo,'Fev/'+AllTrim(MV_PAR01),3,2,.T.)
oExcel:AddColumn(_cSheet1,cTitulo,'Mar/'+AllTrim(MV_PAR01),3,2,.T.)
oExcel:AddColumn(_cSheet1,cTitulo,'Abr/'+AllTrim(MV_PAR01),3,2,.T.)
oExcel:AddColumn(_cSheet1,cTitulo,'Mai/'+AllTrim(MV_PAR01),3,2,.T.)
oExcel:AddColumn(_cSheet1,cTitulo,'Jun/'+AllTrim(MV_PAR01),3,2,.T.)
oExcel:AddColumn(_cSheet1,cTitulo,'1o. SEM.'              ,3,2,.T.)
oExcel:AddColumn(_cSheet1,cTitulo,'Jul/'+AllTrim(MV_PAR01),3,2,.T.)
oExcel:AddColumn(_cSheet1,cTitulo,'Ago/'+AllTrim(MV_PAR01),3,2,.T.)
oExcel:AddColumn(_cSheet1,cTitulo,'Set/'+AllTrim(MV_PAR01),3,2,.T.)
oExcel:AddColumn(_cSheet1,cTitulo,'Out/'+AllTrim(MV_PAR01),3,2,.T.)
oExcel:AddColumn(_cSheet1,cTitulo,'Nov/'+AllTrim(MV_PAR01),3,2,.T.)
oExcel:AddColumn(_cSheet1,cTitulo,'Dez/'+AllTrim(MV_PAR01),3,2,.T.)
oExcel:AddColumn(_cSheet1,cTitulo,'2o. SEM.'              ,3,2,.T.)
oExcel:AddColumn(_cSheet1,cTitulo,'ANO'                   ,3,2,.T.)	
dbSelectArea(_tAlias)
ProcRegua((_tAlias)->(RecCount())+1)
(_tAlias)->(dbGoTop())
While !(_tAlias)->(EOF())
	IncProc("Processando produto "+AllTrim((_tAlias)->PRODUTO)+"...")
	_aInfo := {	(_tAlias)->PRODUTO                     , ;
				(_tAlias)->DESCRI                      , ;
				(_tAlias)->TIPO                        , ;
				(_tAlias)->UM                          , ;
				&("(_tAlias)->Jan_"+AllTrim(MV_PAR01)) , ;
				&("(_tAlias)->Fev_"+AllTrim(MV_PAR01)) , ;
				&("(_tAlias)->Mar_"+AllTrim(MV_PAR01)) , ;
				&("(_tAlias)->Abr_"+AllTrim(MV_PAR01)) , ;
				&("(_tAlias)->Mai_"+AllTrim(MV_PAR01)) , ;
				&("(_tAlias)->Jun_"+AllTrim(MV_PAR01)) , ;
				(_tAlias)->PRI_SEM                     , ;
				&("(_tAlias)->Jul_"+AllTrim(MV_PAR01)) , ;
				&("(_tAlias)->Ago_"+AllTrim(MV_PAR01)) , ;
				&("(_tAlias)->Set_"+AllTrim(MV_PAR01)) , ;
				&("(_tAlias)->Out_"+AllTrim(MV_PAR01)) , ;
				&("(_tAlias)->Nov_"+AllTrim(MV_PAR01)) , ;
				&("(_tAlias)->Dez_"+AllTrim(MV_PAR01)) , ;
				(_tAlias)->SEG_SEM                     , ;
				(_tAlias)->ANO                           }
	oExcel:AddRow(	_cSheet1, cTitulo , _aInfo )
	dbSelectArea(_tAlias)
	(_tAlias)->(dbSkip())
EndDo
If _lRet == .T.
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
	oMsExcel:= oMsExcel:Destroy()
	MSGBOX('Relat๓rio gerado!',_cRotina+'_005','INFO')
Else
	MSGBOX("Nใo hแ dados a serem apresentados. Informe o Administrador do sistema.",_cRotina+"_006",'ALERT')
EndIf

FreeObj(oExcel)
oExcel := NIL

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg  บAutor  ณAnderson C. P. Coelho บ Data ณ  21/01/14บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se as perguntas existem na SX1. Caso nใo existam,  บฑฑ
ฑฑบ          ณas cria.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ValidPerg()

Local _y
Local _x
Local _aAlias := GetArea()
Local aRegs   := {}

cPerg         := PADR(cPerg,10)

AADD(aRegs,{cPerg,"01","Ano                  ?","","","mv_ch1","C"     ,04      ,0       ,0,"G","NaoVazio()","mv_par01",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})
_aTam := TamSx3("B1_COD")
AADD(aRegs,{cPerg,"02","Do Produto           ?","","","mv_ch2",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par02",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SB1","","","",""})
AADD(aRegs,{cPerg,"03","At้ o Produto        ?","","","mv_ch3",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par03",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SB1","","","",""})
_aTam := TamSx3("B1_GRUPO")
AADD(aRegs,{cPerg,"04","Do Grupo             ?","","","mv_ch4",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par04",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SBM","","","",""})
AADD(aRegs,{cPerg,"05","At้ o Grupo          ?","","","mv_ch5",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par05",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SBM","","","",""})
_aTam := TamSx3("B1_TIPO")
AADD(aRegs,{cPerg,"06","Do Tipo              ?","","","mv_ch6",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par06",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SBM","","","",""})
AADD(aRegs,{cPerg,"07","At้ o Tipo           ?","","","mv_ch7",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par07",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SBM","","","",""})
AADD(aRegs,{cPerg,"08","Apresenta Negativos  ?","","","mv_ch8","N"     ,01      ,0       ,0,"C","NaoVazio()","mv_par08","Nใo"        ,"","","","","Sim"      ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})

For _x := 1 To Len(aRegs)
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If !SX1->(dbSeek(cPerg+aRegs[_x,2]))
		RecLock("SX1",.T.)
		For _y := 1 To FCount()
			If _y <= Len(aRegs[_x])
				FieldPut(_y,aRegs[_x,_y])
			Else
				Exit
			EndIf
		Next
		SX1->(MsUnlock())
	EndIf
Next

RestArea(_aAlias)

Return()
