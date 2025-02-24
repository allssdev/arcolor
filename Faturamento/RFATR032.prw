#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RFATR032    º Autor ³ Adriano Leonardo  º Data ³  01/09/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório para conferência dos pedidos de vendas, confron- º±±
±±º          ³ tando tipo de operação x finaceiro (TES e SE1).            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function RFATR032()

Local   _aSavArea  := GetArea()
Private _cRotina   := "RFATR032"
Private cPerg      := _cRotina
Private _cTitulo   := ""
Private _cTitulo2  := ""
Private _cQuery    := ""
Private _cAlias	   := GetNextAlias()
Private _lRet      := .T.
Private _cEnt      := + CHR(13) + CHR(10)
Private _cFileTMP  := ""
Private _cAliasSX1 := ""
ValidPerg()

Aviso(_cRotina + " -  Auditoria de Pedidos de Venda","Esse relatório tem objetivo de listar todos os pedidos de venda que tenham pelo menos um item com TES que não gere financeiro para fins de auditoria.",{"Ok"},3)

IF !Pergunte(cPerg,.T.)
	If MsgYesNo("Deseja cancelar a emissão do relatório?",_cRotina+"_01")
		Return()
	EndIf
EndIf

//Verifica se o usuário tem permissão para emitir relatórios em Excel
If !(SubStr(cAcesso,160,1) == "S" .AND. SubStr(cAcesso,168,1) == "S" .AND. SubStr(cAcesso,170,1) == "S")
	MSGBOX('Usuário sem permissão para gerar relatório em Excel. Informe o Administrador.',_cRotina +"03",'STOP')
   Return(Nil)
EndIf

/*//Verifica se o Excel está instalado
If !ApOleClient('MsExcel')
	Msgbox('Excel não instalado.',_cRotina +"04",'ALERT')
   Return(Nil)
EndIf*/

_cTitulo  := ("Pedidos de Venda - Operação x Financeiro - " + (DTOC(mv_par02)) + " até " + (DTOC(mv_par03)) + " - " + _cRotina)
_cTitulo2 := ("Parâmetros")

//Chamada da função responsável pela seleção dos dados
MsgRun("Selecionando dados... Por favor AGUARDE. ",_cTitulo,{ || SelectQry()})

//Chamada da função para construir as planilhas
Processa({ |lEnd| Geraxls(@lEnd) },_cTitulo," Gerando relatório em Excel...   Por favor aguarde.",.T.)

//Verifico a existência de resultados na consulta
If Select (_cAlias) > 0
   (_cAlias)->(dbCloseArea())
EndIf

dbCloseArea(_cAlias)

RestArea(_aSavArea)
                                                                              
Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RFATR032    º Autor ³ Adriano Leonardo  º Data ³  01/09/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função responsável por realizar a consulta no banco de da- º±±
±±º          ³ dos.                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para empresa ARCOLOR              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function SelectQry()

_cQuery := "SELECT C5_NUM , SUBSTRING(C5_EMISSAO,7,2) + '/' + SUBSTRING(C5_EMISSAO,5,2) + '/' + SUBSTRING(C5_EMISSAO,1,4) AS [C5_EMISSAO], SC5.C5_CLIENTE, SC5.C5_LOJACLI, C5_NOMCLI, C5_CONDPAG, E4_DESCRI, C5_TPDIV, C5_TPOPER, X5_DESCRI AS X5DESCRI, (SELECT ISNULL(SUM(E1_VALOR),0) FROM " + RetSqlName("SE1") + " SE1 WHERE SE1.D_E_L_E_T_='' AND SE1.E1_FILIAL='" + xFilial("SE1") + "' AND E1_PEDIDO=SC5.C5_NUM AND E1_TIPO='NF') E1_VALOR, CASE WHEN MAX(C6_NOTA)='' THEN 'NÃO FATURADO' ELSE 'FATURADO' END AS [SITUACAO] FROM " + RetSqlName("SC5") + " SC5 " + _cEnt
_cQuery += "INNER JOIN " + RetSqlName("SC6") + " SC6 " + _cEnt
_cQuery += "ON SC5.C5_NUM=SC6.C6_NUM " + _cEnt
_cQuery += "AND SC5.D_E_L_E_T_='' " + _cEnt
_cQuery += "AND SC5.C5_FILIAL='" + xFilial("SC5") + "' " + _cEnt
_cQuery += "AND SC5.C5_TIPO NOT IN ('D','B') " + _cEnt
_cQuery += "AND SC6.D_E_L_E_T_='' " + _cEnt
_cQuery += "AND SC6.C6_FILIAL='" + xFilial("SC6") + "' " + _cEnt
_cQuery += "AND SC5.C5_EMISSAO>='20130401' " + _cEnt //Adiciono filtro para não considerar os pedidos de vendas importados do Scoa
_cQuery += "INNER JOIN " + RetSqlName("SF4") + " SF4 " + _cEnt
_cQuery += "ON SC6.C6_TES=SF4.F4_CODIGO " + _cEnt
_cQuery += "AND SF4.D_E_L_E_T_='' " + _cEnt
_cQuery += "AND SF4.F4_FILIAL='" + xFilial("SF4") + "' " + _cEnt
_cQuery += "AND SF4.F4_DUPLIC='N' " + _cEnt
_cQuery += "INNER JOIN " + RetSqlName("SE4") + " SE4 " + _cEnt
_cQuery += "ON SC5.C5_CONDPAG=SE4.E4_CODIGO " + _cEnt
_cQuery += "AND SE4.D_E_L_E_T_='' " + _cEnt
_cQuery += "AND SE4.E4_FILIAL='" + xFilial("SE4") + "' " + _cEnt
_cQuery += "LEFT JOIN " + RetSqlName("SX5") + " SX5 " + _cEnt
_cQuery += "ON SX5.D_E_L_E_T_='' " + _cEnt
_cQuery += "AND SX5.X5_FILIAL='" + xFilial("SX5") + "' " + _cEnt
_cQuery += "AND SX5.X5_TABELA='DJ' " + _cEnt
_cQuery += "AND SX5.X5_CHAVE=SC5.C5_TPOPER " + _cEnt
_cQuery += "WHERE SC5.C5_TPOPER='" + MV_PAR01 + "' " + _cEnt
_cQuery += "AND SC5.C5_EMISSAO BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "' " + _cEnt
_cQuery += "AND SC5.C5_NUM BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "' " + _cEnt
_cQuery += "GROUP BY C5_NUM, C5_EMISSAO, C5_CLIENTE, C5_LOJACLI, C5_NOMCLI, C5_TPDIV, C5_CONDPAG, E4_DESCRI, C5_TPOPER, X5_DESCRI " + _cEnt
_cQuery += "ORDER BY C5_NUM " + _cEnt

If  Len(_cQuery) >0
	_cQuery := ChangeQuery(_cQuery)
Else
	MSGBOX('CONSULTA NÃO GERADA ',_cRotina + '_02','STOP')
	Return()
EndIf

//Cria tabela temporária com base no resultado da query
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.F.)

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RFATR032    º Autor ³ Adriano Leonardo  º Data ³  01/09/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa criado para gerar em Excel a planilha conforme    º±±
±±º          ³ dados obtidos na consulta do banco                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para empresa ARCOLOR              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function Geraxls(lEnd)

Local oExcel    := FWMSEXCEL():New()
Local _cSheet1  := "Pedidos - Operação x Financeiro"
Local _cSheet2  := "Parâmetros"
Local _cFileTMP := ""
Local _cFile    := ""
Private _aPar   := {}
Private _cAliasSX1 := ""

oExcel:AddWorkSheet(_cSheet1)
oExcel:AddTable(_cSheet1,_cTitulo)

oExcel:AddColumn(_cSheet1,_cTitulo,'EMISSAO'		,2,4,.F.)
oExcel:AddColumn(_cSheet1,_cTitulo,'PEDIDO'			,1,1,.F.)
oExcel:AddColumn(_cSheet1,_cTitulo,'CLIENTE'		,1,1,.F.)
oExcel:AddColumn(_cSheet1,_cTitulo,'LOJA'			,1,1,.F.)
oExcel:AddColumn(_cSheet1,_cTitulo,'NOME'			,1,1,.F.)
oExcel:AddColumn(_cSheet1,_cTitulo,'COND. PAGTO'	,1,1,.F.)
oExcel:AddColumn(_cSheet1,_cTitulo,'DESCRIÇÃO'		,1,1,.F.)
oExcel:AddColumn(_cSheet1,_cTitulo,'CLASSIFICAÇÃO'	,1,1,.F.)
oExcel:AddColumn(_cSheet1,_cTitulo,'CÓD. OPERAÇÃO'	,1,1,.F.)
oExcel:AddColumn(_cSheet1,_cTitulo,'OPERAÇÃO'		,1,1,.F.)
oExcel:AddColumn(_cSheet1,_cTitulo,'VALOR TÍTULOS'	,3,1,.T.)
oExcel:AddColumn(_cSheet1,_cTitulo,'SITUAÇÃO'		,1,1,.F.)

//Seleciona a tabela temporária
dbSelectArea(_cAlias)
ProcRegua(((_cAlias)->(RecCount())*2)+1)
(_cAlias)->(dbGoTop())

// - ACRESCENTA AS LINHAS COM INFORMAÇÕES WHILE ! TEMP ->(EOF())
While !(_cAlias)->(EOF()) .AND. !lEnd

	IncProc('PROCESSANDO PEDIDO: '+AllTrim((_cAlias)->C5_NUM))
	
	_aAux := {}
	
	AAdd(_aAux,(_cAlias)->C5_EMISSAO)
	AAdd(_aAux,(_cAlias)->C5_NUM)
	AAdd(_aAux,(_cAlias)->C5_CLIENTE)
	AAdd(_aAux,(_cAlias)->C5_LOJACLI)
	AAdd(_aAux,(_cAlias)->C5_NOMCLI)
	AAdd(_aAux,(_cAlias)->C5_CONDPAG)
	AAdd(_aAux,(_cAlias)->E4_DESCRI)
	AAdd(_aAux,(_cAlias)->C5_TPDIV)
	AAdd(_aAux,(_cAlias)->C5_TPOPER)
	AAdd(_aAux,(_cAlias)->X5DESCRI)
	AAdd(_aAux,(_cAlias)->E1_VALOR)
	AAdd(_aAux,(_cAlias)->SITUACAO)
	
	oExcel:AddRow(_cSheet1, _cTitulo, _aAux )
	
	(_cAlias)->(dbSkip())
EndDo

If lEnd
	Alert("Abortado!")
	FreeObj(oExcel)
	oExcel := NIL
	Return
EndIf

//Inclui nova sheet com informações dos parâmetros
oExcel:AddWorkSheet(_cSheet2)
oExcel:AddTable(_cSheet2,_cTitulo2)
oExcel:AddColumn(_cSheet2,_cTitulo2,"DESCRIÇÃO" ,1,1,.F.)
oExcel:AddColumn(_cSheet2,_cTitulo2,"CONTEÚDO"  ,1,1,.F.)

_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
dbSelectArea(_cAliasSX1)
(_cAliasSX1)->(dbSetOrder(1))
(_cAliasSX1)->(dbGoTop())

cPerg := PADR(cPerg,10)
If (_cAliasSX1)->(dbSeek(cPerg))
	While !EOF() .And. (_cAliasSX1)->X1_GRUPO==cPerg
	IncProc('Processando parâmetros.')
		AAdd(_aPar,{ (_cAliasSX1)->X1_PERGUNT,&((_cAliasSX1)->X1_VAR01) })
		dbSelectArea(_cAliasSX1)
		dbSetOrder(1)  //Grupo + Ordem
		dbSkip()
	EndDo
EndIf

If Len(_aPar) > 0
	For _nPosPar := 1 To Len(_aPar)
		oExcel:AddRow(_cSheet2, _cTitulo2, _aPar[_nPosPar])
	Next
EndIf

//Valida a emissão do relatório e imprime
If _lRet
IncProc("Abrindo Arquivo...")
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
	
	_cFileTMP  := cGetFile('Arquivo Arquivo XML|*.xml','Salvar como',0,'C:\Dir\',.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.F.) //Define o local onde o arquivo será gerado
	
	//Verifico se o formato do arquivo foi definido corretamente
	If !Empty(_cFileTMP)
		If !(".XML" $ Upper(_cFileTMP))
			_cFileTmp := StrTran(_cFileTmp,'.','')
			_cFileTmp += ".xml"
		EndIf
	Else
		_cFileTMP := (GetTempPath() + _cFile)
	EndIf
	
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
	IncProc('Relatório gerado com sucesso!')
	MSGBOX('Relatório gerado, por favor verifique!',_cRotina+'_05','ALERT')
	oMsExcel:= oMsExcel:Destroy()
Else
	MSGBOX("Não há dados a serem apresentados. Informe o Administrador do sistema.",_cRotina+"_06",'ALERT')
EndIf

FreeObj(oExcel)
oExcel := NIL

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ValidPerg º Autor ³Adriano Leonardo     º Data ³  01/09/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função responsável pela inclusão de parâmetros na rotina.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para empresa ARCOLOR              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ValidPerg()

Local _sAlias := GetArea()
Local aRegs   := {}
cPerg         := PADR(cPerg,10)

AADD(aRegs,{cPerg,"01","Tipo de Operação?"	,"","","mv_ch1","C",02,0,0,"G","NaoVazio()","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","DJ" ,"","","",""})
AADD(aRegs,{cPerg,"02","De Emissão?"		,"","","mv_ch2","D",08,0,0,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{cPerg,"03","Até Emissão?"		,"","","mv_ch3","D",08,0,0,"G","NaoVazio()","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{cPerg,"04","De Pedido?"			,"","","mv_ch4","C",06,0,0,"G",""          ,"mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SC5","","","",""})
AADD(aRegs,{cPerg,"05","Até Pedido?"		,"","","mv_ch5","C",06,0,0,"G","NaoVazio()","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SC5","","","",""})

For _x := 1 To Len(aRegs)
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If !SX1->(MsSeek(cPerg+aRegs[_x,2],.T.,.F.))
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

RestArea(_sAlias)

Return()
