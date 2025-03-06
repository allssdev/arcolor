#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE _CRLF CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ RFATR041 บ Autor ณ J๚lio Soares       บ Data ณ  04/02/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Relat๓rio de auditoria de documentos por pedido            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para a empresa Arcolor.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RFATR041()

Local _aSavArea    := GetArea()

Private _cRotina   := "RFATR041"
Private cPerg      := _cRotina
Private cDirDocs   := MsDocPath()
Private cNomeArq   := CriaTrab(,.F.)
Private _cExtArq   := GetDBExtension()
Private _cExtInd   := OrdBagExt()
Private SD2aStru   := SD2->(dbStruct())

ValidPerg()
If !Pergunte(cPerg,.T.)
	Return()
EndIf
If !(SubStr(cAcesso,160,1) == "S" .AND. SubStr(cAcesso,168,1) == "S" .AND. SubStr(cAcesso,170,1) == "S")
	MsgStop('Usuแrio sem permissใo para exportar dados para Excel, informe o Administrador!',_cRotina +"001")
	Return(Nil)
EndIf
If !ApOleClient('MsExcel')
	MsgStop('Excel nใo instalado!',_cRotina +"002")
	Return(Nil)
EndIf
Processa( {|lEnd| SelDados(@lEnd) }, "Relat๓rio de devolu็ใo de notas", "Processando informa็๕es...",.T.)        
RestArea(_aSavArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ SelDados บ Autor ณ J๚lio Soares       บ Data ณ  04/02/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsแvel pela sele็ใo dos dados.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SelDados(lEnd)
Local nI
Local oFWMsExcel
Local oExcel
Local cArquivo    := GetTempPath()+"RFATR041_"+DTOS(dDataBase)+".xml"

Private _aCabec  := {}
Private _aItens  := {}

cAliasTop1 := GetNextAlias()

_cQuery := ""
If MV_PAR05 == 2
	_cQuery += "SELECT * FROM ("																								+_CRLF
EndIf
_cQuery += " SELECT	C5_CLIENT CLIENTE,C5_LOJACLI LOJA,A1_NOME NOME, "															+_CRLF
_cQuery += " 		CASE "																										+_CRLF
_cQuery += " 			WHEN SC5.C5_TPDIV = 0 THEN '00' "																    	+_CRLF
_cQuery += " 			WHEN SC5.C5_TPDIV = 1 THEN '33' "																		+_CRLF
_cQuery += " 			WHEN SC5.C5_TPDIV = 2 THEN '50' "																		+_CRLF
_cQuery += " 			WHEN SC5.C5_TPDIV = 3 THEN '66' "																		+_CRLF
_cQuery += " 			WHEN SC5.C5_TPDIV = 4 THEN '100' "																		+_CRLF
_cQuery += " 			WHEN SC5.C5_TPDIV = 5 THEN 'DUPLO' "																	+_CRLF
_cQuery += " 		END TPDOC, "																								+_CRLF
_cQuery += " 		TS.D2_PEDIDO NUMPED, "																						+_CRLF
_cQuery += " 		SUBSTRING(TS.D2_EMISSAO,7,2) +'/'+SUBSTRING(TS.D2_EMISSAO,5,2) +'/'+SUBSTRING(TS.D2_EMISSAO,1,4)EMISSAO, "	+_CRLF
_cQuery += " 		MAX(TS.DOC1)DOC1,MAX(TS.SER1)SER1,MAX(TS.DOC2)DOC2,MAX(TS.SER2)SER2 "										+_CRLF
_cQuery += " FROM( "																											+_CRLF
_cQuery += " 	SELECT D2_EMISSAO,D2_PEDIDO,D2_DOC DOC1,D2_SERIE SER1,'' DOC2,'' SER2 "											+_CRLF
_cQuery += " 	FROM "+RetSqlName("SD2")+" SD2 "																				+_CRLF
_cQuery += " 	WHERE SD2.D2_FILIAL	= '"+xFilial("SD2")+"' "																	+_CRLF
_cQuery += " 	AND SD2.D2_PEDIDO	<> '' "																						+_CRLF
_cQuery += " 	AND SD2.D2_SERIE	= '1' "																						+_CRLF
_cQuery += " 	AND SD2.D_E_L_E_T_	= '' "																						+_CRLF
_cQuery += " 	UNION ALL "																										+_CRLF
_cQuery += " 	SELECT D2_EMISSAO,D2_PEDIDO,'' DOC1,'' SER1,D2_DOC DOC2,D2_SERIE SER2 "											+_CRLF
_cQuery += " 	FROM "+RetSqlName("SD2")+" SD2 "																				+_CRLF
_cQuery += " 	WHERE SD2.D2_FILIAL	= '"+xFilial("SD2")+"' "																	+_CRLF
_cQuery += " 	AND SD2.D2_PEDIDO	<> '' "																						+_CRLF
_cQuery += " 	AND SD2.D2_SERIE	= 'ZZZ' "																					+_CRLF
_cQuery += " 	AND SD2.D_E_L_E_T_	= '' "																						+_CRLF
_cQuery += " 	)TS "																											+_CRLF
_cQuery += " INNER JOIN "+RetSqlName("SC5")+" SC5 "																				+_CRLF
_cQuery += " 	ON SC5.C5_FILIAL	= '"+xFilial("SC5")+"' "																	+_CRLF
_cQuery += " 	AND SC5.C5_NUM		= TS.D2_PEDIDO "																			+_CRLF
_cQuery += " 	AND SC5.D_E_L_E_T_	= '' "																						+_CRLF
_cQuery += " LEFT JOIN "+RetSqlName("SA1")+" SA1 "																				+_CRLF
_cQuery += " 	ON SA1.A1_FILIAL	= '"+xFilial("SA1")+"' "																	+_CRLF
_cQuery += " 	AND SA1.A1_COD		= SC5.C5_CLIENT "																			+_CRLF
_cQuery += " 	AND SA1.A1_LOJA		= SC5.C5_LOJACLI "																			+_CRLF
_cQuery += " 	AND SA1.D_E_L_E_T_	= '' "																						+_CRLF
_cQuery += " WHERE D2_PEDIDO BETWEEN '"+MV_PAR01+"'	AND '"+MV_PAR02+"' "														+_CRLF
_cQuery += " AND D2_EMISSAO  BETWEEN '"+DTOS(MV_PAR03)+"'AND '"+DTOS(MV_PAR04)+"' "												+_CRLF
_cQuery += " GROUP BY C5_CLIENT,C5_LOJACLI,A1_NOME,D2_EMISSAO,D2_PEDIDO,C5_TPDIV "												+_CRLF
If MV_PAR05 == 1
	_cQuery += " ORDER BY D2_PEDIDO,D2_EMISSAO "																				+_CRLF
ElseIf MV_PAR05 = 2
	_cQuery += " )SC "																											+_CRLF
	_cQuery += " WHERE (SC.TPDOC <> '100' AND SC.TPDOC <> '00') "																+_CRLF
	_cQuery += " AND (SC.DOC1 = '' OR SC.DOC2 = '') "																			+_CRLF
	_cQuery += " ORDER BY SC.CLIENTE, SC.NUMPED, SC.EMISSAO "																	+_CRLF
EndIf

//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",_cQuery)
cQuery  := ChangeQuery(_cQuery)

dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),'FATD2', .F., .T.)
For nI  := 1 To Len(SD2aStru)
	TCSetField('FATD2',SD2aStru[nI,1], SD2aStru[nI,2],SD2aStru[nI,3],SD2aStru[nI,4])
Next


IF FATD2->(!EOF())
    //Criando o objeto que irแ gerar o conte๚do do Excel
    oFWMsExcel := FWMSExcel():New()
     
    //Aba 01
    oFWMsExcel:AddworkSheet("DOCUMENTO POR PEDIDO")

        //Criando a Tabela
        oFWMsExcel:AddTable("DOCUMENTO POR PEDIDO","DOCUMENTO")
        oFWMsExcel:AddColumn("DOCUMENTO POR PEDIDO","DOCUMENTO","CLIENTE",1)
        oFWMsExcel:AddColumn("DOCUMENTO POR PEDIDO","DOCUMENTO","LOJA",1)
        oFWMsExcel:AddColumn("DOCUMENTO POR PEDIDO","DOCUMENTO","NOME",1)
        oFWMsExcel:AddColumn("DOCUMENTO POR PEDIDO","DOCUMENTO","TPDOC",1)        
        oFWMsExcel:AddColumn("DOCUMENTO POR PEDIDO","DOCUMENTO","NUMPED",1)
        oFWMsExcel:AddColumn("DOCUMENTO POR PEDIDO","DOCUMENTO","EMISSAO",1)
        oFWMsExcel:AddColumn("DOCUMENTO POR PEDIDO","DOCUMENTO","DOC1",1)
        oFWMsExcel:AddColumn("DOCUMENTO POR PEDIDO","DOCUMENTO","SER1",1)
        oFWMsExcel:AddColumn("DOCUMENTO POR PEDIDO","DOCUMENTO","DOC2",1)
        oFWMsExcel:AddColumn("DOCUMENTO POR PEDIDO","DOCUMENTO","SER2",1)
              
        //Criando as Linhas... Enquanto nใo for fim da query
        WHILE FATD2->(!EOF())
            oFWMsExcel:AddRow("DOCUMENTO POR PEDIDO","DOCUMENTO",{;
            			FATD2->CLIENTE	,;
						FATD2->LOJA		,;
						FATD2->NOME		,;
						FATD2->TPDOC	,;
						FATD2->NUMPED	,;
						FATD2->EMISSAO	,;
						FATD2->DOC1		,;
						FATD2->SER1		,;
						FATD2->DOC2		,;
						FATD2->SER2;
            })
            FATD2->(dbSkip())
        ENDDO
     
    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
         
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()           //Abre uma nova conexใo com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)              //Visualiza a planilha
    oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas

ENDIF
FATD2->(dbCloseArea())


/*
_aCabec := {"CLIENTE"	,;
			"LOJA"		,;
			"NOME"		,;
			"TPDOC"		,;
			"NUMPED"	,;
			"EMISSAO"	,;
			"DOC1"		,;
			"SER1"		,;
			"DOC2"		,;
			"SER2"		}
dbSelectArea("FATD2")
FATD2->(dbGoTop())
	While !FATD2->(EOF())
		AADD(_aItens,{	FATD2->CLIENTE	,;
						FATD2->LOJA		,;
						FATD2->NOME		,;
						FATD2->TPDOC	,;
						FATD2->NUMPED	,;
						FATD2->EMISSAO	,;
						FATD2->DOC1		,;
						FATD2->SER1		,;
						FATD2->DOC2		,;
						FATD2->SER2		})
	dbSelectArea("FATD2")
	FATD2->(dbSkip())
EndDo
If Len(_aItens) > 0
	MsgRun("Exportando os Registros para o Excel","Aguarde.....",{|| DlgToExcel({{'ARRAY','Rela็ใo de documentos por pedido',_aCabec,_aItens}})})
EndIf
If Select("FATD2") > 0
   FATD2->(DBCLOSEAREA())
EndIf
If File(cDirDocs+"\"+cNomeArq+_cExtArq)
	FErase(cDirDocs+"\"+cNomeArq+_cExtArq)
EndIf
If File(cDirDocs+"\"+cNomeArq+_cExtInd)
	FErase(cDirDocs+"\"+cNomeArq+_cExtInd)
EndIf
*/
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ ExpExcel บ Autor ณ J๚lio Soares       บ Data ณ  04/02/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsแvel por exportar retorno de consultas(query)บฑฑ
ฑฑบ          ณ diretamente para Excel.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ExpExcel(_cAREA)

Local oExcelApp
Local cPath    := AllTrim(GetTempPath())
Local cArquivo := cNomeArq

dbSelectArea(_cAREA)
__X := cDirDocs+"\"+cArquivo+_cExtArq
COPY TO &__X VIA "DBFCDX"
CpyS2T( cDirDocs+"\"+cArquivo+_cExtArq,cPath,.T.)
oExcelApp := MsExcel():New()
oExcelApp:WorkBooks:Open(cPath+cArquivo+_cExtArq)
oExcelApp:SetVisible(.T.)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ ValidPergบ Autor ณ J๚lio Soares       บ Data ณ  04/02/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsแvel pela inclusใo de parโmetros na rotina.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ValidPerg()

Local _sAlias := GetArea()
Local aRegs   := {}

cPerg := PADR(cPerg,10)

_aTam := TamSx3("C5_NUM"    )
AADD(aRegs,{cPerg,"01","Pedido de?"		,"","","mv_ch1",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          	,"mv_par01",""		,"","","","",""				,"","","","","","","","","","","","","","","","","","","SC5","",""})
AADD(aRegs,{cPerg,"02","Pedido at้?"	,"","","mv_ch2",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()"	,"mv_par02",""		,"","","","",""				,"","","","","","","","","","","","","","","","","","","SC5","",""})
AADD(aRegs,{cPerg,"03","Emissใo de?"	,"","","mv_ch3","D"		,08			,0			,0,"G",""			,"mv_par03",""		,"","","","",""				,"","","","","","","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"04","Emissใo at้?"	,"","","mv_ch4","D"		,08			,0			,0,"G",""			,"mv_par04",""		,"","","","",""				,"","","","","","","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"05","Conte๚do?"		,"","","mv_ch5","N"		,01			,0			,0,"C",""			,"mv_par05","Tudo"	,"","","","","Diverg๊ncia"	,"","","","","","","","","","","","","","","","","","",""   ,"",""})

dbSelectArea("SX1")
SX1->(dbSetOrder(1))
For i := 1 To Len(aRegs)
	If !SX1->(dbSeek(cPerg+aRegs[i,2]))
		RecLock("SX1",.T.)
		For j:=1 To FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Else
				Exit
			EndIf
		Next
		SX1->(MsUnlock())
	EndIf
Next

RestArea(_sAlias)

Return()
