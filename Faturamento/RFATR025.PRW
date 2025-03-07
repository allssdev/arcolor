#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFATR025  �Autor  � J�lio Soares      � Data � 30/01/2014  ���
�������������������������������������������������������������������������͹��
���Desc.     � Relat�rio de documentos de devolu��o n�o amarrados a       ���
���          � origem.                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa ARCOLOR                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFATR025()

Local   _aSavArea  := GetArea()
Private _cRotina   := "RFATR025"
Private _cPerg     := _cRotina
Private _cTitulo   := ""
Private _cTitulo2  := ""
Private _cQuery    := ""
Private _tAlias	   := "TMPRFT25"
Private _cCampos   := ""
Private _aColuns   := {}
Private _lRet      := .T.

// - APRESENTA TELA DE PAR�METROS AO USU�RIO
ValidPerg()

// - PERGUNTA DE CANCELAMENTO
/* FB - RELEASE 12.1.23
While !Pergunte(_cPerg,.T.)
	If MsgYesNo("Deseja cancelar a emiss�o do relat�rio?",_cRotina+"_01")
		MSGBOX("Fun��o cancelada pelo usu�rio!",'CANCELADO','STOP')
		Return()
	EndIf
EndDo
*/
IF  !Pergunte(_cPerg,.T.)
	MSGBOX("Fun��o cancelada pelo usu�rio!",'CANCELADO','STOP')
	Return()
ENDIF

// - VERIFICA SE USU�RIO TEM PERMISS�O PARA GERAR DADOS EM EXCEL
If !(SubStr(cAcesso,160,1) == "S" .AND. SubStr(cAcesso,168,1) == "S" .AND. SubStr(cAcesso,170,1) == "S")
	MSGBOX('Usu�rio sem permiss�o para gerar relat�rio em Excel. Informe o Administrador.',_cRotina +"02",'STOP')
   Return(Nil)
EndIf

// - VERIFICA SE H� O EXCEL INSTALADO NA M�QUINA EM USO
If __cUserID <> '000000'
	If !ApOleClient('MsExcel')
		Msgbox('Excel n�o instalado.',_cRotina +"03",'ALERT')
	   Return(Nil)
	EndIf
EndIf
                                                                                                                             
_cTitulo  := ("Rela��o de devolu��o de " + (IIf (MV_PAR03 == 1,'Faturamento','Compras')) + " de " +(DTOC(mv_par01)) + " at� " + (DTOC(mv_par02)) + " sem os documentos originais. - " + _cRotina)
_cTitulo2 := ("PAR�METROS")

// CHAMA FUN��O DE CONSULTA CONFORME PAR�METROS DEFINIDO PELO USU�RIO
MsgRun("Selecionando dados... Por favor AGUARDE. ",_cTitulo,{ || SelectQry() })

// - CHAMA A FUN��O PARA EMITIR OS DADOS EM PLANILHA
Processa({ || Geraxls() },_cRotina,' Gerando relat�rio em Excel...   Por favor aguarde.',.T.)

// - SE A TABELA APRESENTAR DADOS FECHA A MESMA AP�S O USO
If Select (_tAlias) > 0
   (_tAlias)->(dbCloseArea())
Else
	MSGBOX('TABELA N�O CRIADA',_cRotina+'_01','STOP')
EndIf
//dbCloseArea(_tAlias)
RestArea(_aSavArea)
                                                                              
Return()

// - QUERY
Static Function SelectQry()

Local _cQuery  := ""
Local _cEmiss  := ""
Local _cQryFat := ""
Local _cSelFat := ""
Local _cGrpFat := ""
Local _cOrdFat := ""
Local _cQryDev := ""
Local _cSelDev := ""
Local _cGrpDev := ""
Local _cOrdDev := ""

If MV_PAR03 == 1
	_cQry := " SELECT SUBSTRING(SD1.D1_DTDIGIT,7,2)+'/'+SUBSTRING(SD1.D1_DTDIGIT,5,2)+'/'+SUBSTRING(SD1.D1_DTDIGIT,1,4)[ENTRADAS], "
	_cCampos := "(_tAlias)->ENTRADAS, "

	_cQry += " SD1.D1_FORNECE[CLIENTE],SD1.D1_LOJA[LOJA],SA1.A1_NOME[NOME], "
	_cCampos += "(_tAlias)->CLIENTE, (_tAlias)->LOJA, (_tAlias)->NOME, "
	
	_cQry += " SD1.D1_DOC[DOC_OFIC],SD1.D1_SERIE[SERIE_OFIC],SD1.D1_COD[PRODUTO],SD1.D1_QUANT[QTD_DEV], "
	_cCampos += "(_tAlias)->DOC_OFIC, (_tAlias)->SERIE_OFIC, (_tAlias)->PRODUTO, (_tAlias)->QTD_DEV, "
	
	_cQry += " SD1.D1_NFORI[NF_ORIG],SD1.D1_SERIORI[SERI_ORIG],SD1.D1_ITEMORI[ITEM_ORIG] "
	_cCampos += "(_tAlias)->NF_ORIG, (_tAlias)->SERI_ORIG, (_tAlias)->ITEM_ORIG "

	_cQry += " FROM " + RetSqlName("SD1") + " SD1 "

	_cQry += " 	INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' "
	_cQry += " 		AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	_cQry += " 		AND SA1.A1_COD    = SD1.D1_FORNECE "
	_cQry += " 		AND SA1.A1_LOJA   = SD1.D1_LOJA "

	_cQry += " WHERE SD1.D_E_L_E_T_ = '' "
	_cQry += " AND SD1.D1_FILIAL = '" + xFilial("SD1") + "' "
	_cQry += " AND (SD1.D1_NFORI <> '' OR SD1.D1_SERIORI = '' OR SD1.D1_ITEMORI = '') "
	_cQry += " AND SD1.D1_TIPO = 'D' "
	_cQry += " AND SD1.D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
	_cQry += " ORDER BY D1_DOC "

ElseIf MV_PAR03 == 2

	_cQry := " SELECT SUBSTRING(SD2.D2_EMISSAO,7,2)+'/'+SUBSTRING(SD2.D2_EMISSAO,5,2)+'/'+SUBSTRING(SD2.D2_EMISSAO,1,4) [SAIDAS], "
	_cCampos := "(_tAlias)->SAIDAS, "
	
	_cQry += " SD2.D2_CLIENTE[FORNECEDOR],SD2.D2_LOJA[LOJA],SA2.A2_NOME[NOME], "
	_cCampos += "(_tAlias)->FORNECEDOR, (_tAlias)->LOJA, (_tAlias)->NOME, "

	_cQry += " SD2.D2_DOC[DOC_OFIC],SD2.D2_SERIE[SERIE_OFIC],SD2.D2_COD[PRODUTO],SD2.D2_QTDAFAT[QTD_DEV], "
	_cCampos += "(_tAlias)->DOC_OFIC, (_tAlias)->SERIE_OFIC, (_tAlias)->PRODUTO, (_tAlias)->QTD_DEV, "

	_cQry += " SD2.D2_NFORI[NF_ORIG],SD2.D2_SERIORI[SERI_ORIG],SD2.D2_ITEMORI[ITEM_ORIG] "
	_cCampos += "(_tAlias)->NF_ORIG, (_tAlias)->SERI_ORIG, (_tAlias)->ITEM_ORIG "

	_cQry += " FROM " + RetSqlName("SD2") + " SD2 "

	_cQry += " 	INNER JOIN " + RetSqlName("SA2") + " SA2 ON SA2.D_E_L_E_T_ = '' "
	_cQry += " 		AND SA2.A2_FILIAL = '" + xFilial("SA2") + "' "
	_cQry += " 		AND SA2.A2_COD    = SD2.D2_CLIENTE "
	_cQry += " 		AND SA2.A2_LOJA   = SD2.D2_LOJA "
                                                      
	_cQry += " WHERE SD2.D_E_L_E_T_ = '' "
	_cQry += " AND SD2.D2_FILIAL = '" + xFilial("SD2") + "' "
	_cQry += " AND (SD2.D2_NFORI = '' OR SD2.D2_SERIORI = '' OR SD2.D2_ITEMORI = '') "
	_cQry += " AND SD2.D2_TIPO = 'D' "
	_cQry += " AND SD2.D2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
	_cQry += " ORDER BY D2_DOC "

EndIf

/*
If __cUserId == "000000"
	MemoWrite("\2.Memowrite\"+_cRotina+"_QRY_001.TXT",_cQuery)
EndIf
*/

If  (Len(_cQry) ) >0
	_cQuery := ChangeQuery(_cQry)
Else
	MSGBOX('CONSULTA N�O GERADA ','*** XXX ***','STOP')
	Return()	
EndIf

// - GERA A QUERY FORMADA
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_tAlias,.T.,.F.)

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATR025  �Autor  �Microsiga           � Data �  30/01/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o respons�vel por gerar a planilha conforme dados     ���
���          � obtidos da consulta formada de acordo com par�metros       ���
���          � inseridos pelo usu�rio.                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para empresa ARCOLOR              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Geraxls()

Local oExcel    := FWMSEXCEL():New()
Local _cSheet1  := (DTOC(MV_PAR01)) + " ~ " + (DTOC(MV_PAR02))
Local _cSheet2  := 'PAR�METROS'
Local _cFileTMP := ""
Local _cFile    := ""

Private _aPar   := {}

oExcel:AddWorkSheet(_cSheet1)
oExcel:AddTable(_cSheet1,_cTitulo)

If MV_PAR03 == 1
	oExcel:AddColumn(_cSheet1,_cTitulo,'ENTRADAS'  ,2,4,.F.)
ElseIf MV_PAR03 == 2
	oExcel:AddColumn(_cSheet1,_cTitulo,'SAIDAS'    ,2,4,.F.)
Endif
If MV_PAR03 == 1
	oExcel:AddColumn(_cSheet1,_cTitulo,'CLIENTE'   ,1,1,.F.)
ElseIf MV_PAR03 == 2
	oExcel:AddColumn(_cSheet1,_cTitulo,'FORNECEDOR',1,1,.F.)
Endif

oExcel:AddColumn(_cSheet1,_cTitulo,'LOJA'       ,1,1,.F.)
oExcel:AddColumn(_cSheet1,_cTitulo,'NOME'       ,1,1,.F.)
oExcel:AddColumn(_cSheet1,_cTitulo,'DOC_OFIC'   ,1,1,.F.)
oExcel:AddColumn(_cSheet1,_cTitulo,'SERIE_OFIC' ,1,1,.F.)
oExcel:AddColumn(_cSheet1,_cTitulo,'PRODUTO'    ,1,1,.F.)
oExcel:AddColumn(_cSheet1,_cTitulo,'QTD_DEV'    ,1,1,.F.)
oExcel:AddColumn(_cSheet1,_cTitulo,'NF_ORIG'    ,1,1,.F.)
oExcel:AddColumn(_cSheet1,_cTitulo,'SERI_ORIG'  ,1,1,.F.)
oExcel:AddColumn(_cSheet1,_cTitulo,'ITEM_ORIG'  ,1,1,.F.)

// - SELECIONA A TABELA TEMPOR�RIA
dbSelectArea(_tAlias)
ProcRegua(((_tAlias)->(RecCount())*2)+1)
(_tAlias)->(dbGoTop())
// - ACRESCENTA AS LINHAS COM INFORMA��ES WHILE ! TEMP ->(EOF())
While !(_tAlias)->(EOF())
	IncProc('PROCESSANDO DOCUMENTOS: '+ AllTrim((_tAlias)->DOC_OFIC) + '.')
	_aAux := StrTokArr(_cCampos,',')
	For _nCtn2 := 1 To Len(_aAux)
	    _aAux[_nCtn2] := &(_aAux[_nCtn2])
	Next
	oExcel:AddRow(_cSheet1, _cTitulo, _aAux )
	(_tAlias)->(dbSkip())
EndDo

// - INCLUI UMA ABA COM AS INFORMA��ES DOS PARAMETROS
oExcel:AddWorkSheet(_cSheet2)
oExcel:AddTable(_cSheet2,_cTitulo2)
oExcel:AddColumn(_cSheet2,_cTitulo2,"DESCRI��O" ,1,1,.F.)
oExcel:AddColumn(_cSheet2,_cTitulo2,"CONTE�DO"  ,1,1,.F.)

_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
dbSelectArea(_cAliasSX1)
(_cAliasSX1)->(dbSetOrder(1))

_cPerg := PADR(_cPerg,10)
If (_cAliasSX1)->(dbSeek(_cPerg))
	While !EOF() .And. (_cAliasSX1)->X1_GRUPO==_cPerg
		IncProc('PROCESSANDO PARAMETROS...')
		AAdd(_aPar,{ (_cAliasSX1)->X1_PERGUNT,&((_cAliasSX1)->X1_VAR01) })
		dbSelectArea(_cAliasSX1)
		(_cAliasSX1)->(dbSkip())
	EndDo
EndIf
If Len(_aPar) > 0
	For _nPosPar := 1 To Len(_aPar)
		oExcel:AddRow(_cSheet2, _cTitulo2, _aPar[_nPosPar])
	Next
EndIf

// - VALIDA A EMISS�O DO RELAT�RIO E IMPRIME
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
	INCPROC('RELAT�RIO GERADO COM SUCESSO!')
	MSGBOX('Relat�rio gerado, VERIFIQUE!!!',_cRotina+'_04','ALERT')
Else
	MSGBOX("N�o h� dados a serem apresentados. Informe o Administrador do sistema.",_cRotina+"_05",'ALERT')
EndIf
FreeObj(oExcel)
oExcel := NIL

dbCloseArea(_tAlias)

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ValidPerg � Autor �J�lio Soares         � Data �  04/10/13 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o respons�vel pela inclus�o de par�metros na rotina.  ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para empresa ARCOLOR              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ValidPerg()

_cAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
_cPerg   := PADR(_cPerg,10)
aRegs   :={}

AADD(aRegs,{_cPerg,"01","De Data?"              ,"","","mv_ch1","D",08,0,0,"G","NaoVazio()","mv_par01",""            ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{_cPerg,"02","At� Data?"             ,"","","mv_ch2","D",08,0,0,"G","NaoVazio()","mv_par02",""            ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{_cPerg,"03","Imprime devolu��o de?" ,"","","mv_ch3","N",01,0,0,"C",""          ,"mv_par03","Faturamento" ,"","","","","Compras"  ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})

For _x := 1 to Len(aRegs)
	If !MsSeek(_cPerg+aRegs[_x,2],.T.,.F.)
		RecLock("SX1",.T.)
		For _y := 1 to FCount()
			If _y <= Len(aRegs[_x])
				FieldPut(_y,aRegs[_x,_y])
			Else
				Exit
			Endif
		Next
		MsUnlock()
	Endif
Next
dbSelectArea(_cAlias)

Return()
