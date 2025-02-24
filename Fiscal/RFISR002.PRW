#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE _CRLF CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFISR002  º Autor ³Júlio Soares          º Data ³  04/10/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de relação de notas fiscais (analítico)          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFISR002()

Local _aSavArea    := GetArea()

Private _cRotina   := "RFISR002"
Private cPerg      := _cRotina
Private cDirDocs   := MsDocPath()
Private cNomeArq   := CriaTrab(,.F.)
Private _cExtArq   := GetDBExtension()
Private _cExtInd   := OrdBagExt()
Private SF3aStru   := SF3->(dbStruct())

ValidPerg()
If !Pergunte(cPerg,.T.)
	Return()
EndIf
If !(SubStr(cAcesso,160,1) == "S" .AND. SubStr(cAcesso,168,1) == "S" .AND. SubStr(cAcesso,170,1) == "S")
	MsgStop('Usuário sem permissão para exportar dados para Excel, informe o Administrador!',_cRotina +"001")
	Return(Nil)
EndIf
/*If !ApOleClient('MsExcel')
	MsgStop('Excel não instalado!',_cRotina +"002")
	Return(Nil)
EndIf*/

Processa( {|lEnd| SelDados(@lEnd) }, "Relatório de devolução de notas", "Processando informações...",.T.)        
//MsgRun("Selecionando os dados.","Aguarde.....",{|| SelDados()})
RestArea(_aSavArea)

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SelDados º Autor ³Júlio Soares          º Data ³  04/10/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função responsável pela seleção dos dados.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal.                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function SelDados(lEnd)
Local oFWMsExcel
Local oExcel
Local cArquivo    := GetTempPath()+"RFISR002_"+DTOS(dDataBase)+".xml"

Private _aCabec  := {}
Private _aItens  := {}

/*
_cQuery := " SELECT F3_FILIAL, F3_TIPO AS TIPO, CAST(F3_EMISSAO AS DATE) AS EMISSAO, CAST(F3_ENTRADA AS DATE) AS DIGITACAO, "+_CRLF
_cQuery += " F3_NFISCAL AS DOC_FISCAL, F3_SERIE AS SERIE, F3_CFO AS CFOP, F3_CLIEFOR AS CLIENTE, F3_LOJA AS LOJA, "+_CRLF
_cQuery += " (CASE WHEN  (F3_CFO >= '5' AND F3_TIPO <> 'D') OR (F3_CFO <  '5' AND F3_TIPO =  'D') THEN ISNULL((SELECT A1_NOME "+_CRLF
_cQuery += "                                                           FROM " + RetSqlName("SA1") + " SA1 "+_CRLF
_cQuery += "                                                           WHERE SA1.D_E_L_E_T_ = '' " +_CRLF
_cQuery += " 		                                                     AND SA1.A1_FILIAL  = '" + xFilial("SA1") + "' "+_CRLF
_cQuery += " 		                                                     AND SA1.A1_COD     = SF3.F3_CLIEFOR "+_CRLF
_cQuery += " 		                                                     AND SA1.A1_LOJA    = SF3.F3_LOJA "+_CRLF
_cQuery += " 		                                                     AND SA1.A1_EST     = SF3.F3_ESTADO "+_CRLF
_cQuery +=                                                             "),'') "+_CRLF
_cQuery +=                                                "ELSE ISNULL((SELECT A2_NOME "+_CRLF
_cQuery += "                                                           FROM " + RetSqlName("SA2") + " SA2 "+_CRLF
_cQuery += "                                                           WHERE SA2.D_E_L_E_T_ = '' " +_CRLF
_cQuery += " 		                                                     AND SA2.A2_FILIAL  = '" + xFilial("SA2") + "' "+_CRLF
_cQuery += " 		                                                     AND SA2.A2_COD     = SF3.F3_CLIEFOR "+_CRLF
_cQuery += " 		                                                     AND SA2.A2_LOJA    = SF3.F3_LOJA "+_CRLF
_cQuery += " 		                                                     AND SA2.A2_EST     = SF3.F3_ESTADO "+_CRLF
_cQuery +=                                                             "),'') "+_CRLF
_cQuery += " END) AS NOME, "+_CRLF
_cQuery += " F3_ESTADO AS ESTADO, "+_CRLF
_cQuery += " ROUND(F3_VALCONT,2) [VALOR],    ROUND(F3_BASEICM,2) AS BASE_ICMS, ROUND(F3_VALICM,2)  AS VALOR_ICMS, ROUND(F3_ISENICM,2) AS ISENT_ICMS, "+_CRLF
_cQuery += " ROUND(F3_BASEIPI,2) AS BASE_IPI, ROUND(F3_VALIPI,2)  AS VALOR_IPI, ROUND(F3_ISENIPI,2) AS ISENT_IPI,  ROUND(F3_DESCZFR,2) AS SUFRAMA, "+_CRLF
_cQuery += " F3_OBSERV AS OBS "+_CRLF
_cQuery += " FROM " + RetSqlName("SF3") + " SF3 "+_CRLF
_cQuery += " WHERE SF3.D_E_L_E_T_       = '' "+_CRLF
_cQuery += "   AND SF3.F3_FILIAL        = '" + xFilial("SF3") + "' "+_CRLF
// - ALTERADO EM 09/11/2015 POR JÚLIO SOARES APÓS CONSTATAR PROBLEMAS COM DATAS NO PARÂMETRO.
//_cQuery += "   AND SF3.F3_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "+_CRLF
_cQuery += "   AND SF3.F3_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "+_CRLF
_cQuery += "   AND SF3.F3_SERIE   BETWEEN '" + MV_PAR03       + "' AND '" + MV_PAR04       + "' "+_CRLF
_cQuery += "   AND SF3.F3_NFISCAL BETWEEN '" + MV_PAR05       + "' AND '" + MV_PAR06       + "' "+_CRLF
_cQuery += " ORDER BY F3_FILIAL, BASE_ICMS DESC, F3_EMISSAO, F3_NFISCAL, F3_SERIE "+_CRLF
//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",_cQuery)
//cQuery  := ChangeQuery(_cQuery)
dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),'TFIS', .F., .T.)
*/
BeginSql Alias 'TFIS'
	SELECT F3_FILIAL, F3_TIPO AS TIPO, CAST(F3_EMISSAO AS DATE) AS EMISSAO, CAST(F3_ENTRADA AS DATE) AS DIGITACAO,
	 F3_NFISCAL AS DOC_FISCAL, F3_SERIE AS SERIE, F3_CFO AS CFOP, F3_CLIEFOR AS CLIENTE, F3_LOJA AS LOJA
	 , (CASE WHEN  (F3_CFO >= '5' AND F3_TIPO <> 'D') OR (F3_CFO <  '5' AND F3_TIPO =  'D')
	 				THEN ISNULL((	SELECT A1_NOME
									FROM %table:SA1% SA1
									WHERE SA1.A1_FILIAL  = %xFilial:SA1%
									  AND SA1.A1_COD     = SF3.F3_CLIEFOR
									  AND SA1.A1_LOJA    = SF3.F3_LOJA
									  AND SA1.A1_EST     = SF3.F3_ESTADO
									  AND SA1.%NotDel%
								),'')
					ELSE ISNULL((	SELECT A2_NOME
									FROM %table:SA2% SA2
									WHERE SA2.A2_FILIAL  = %xFilial:SA2%
									  AND SA2.A2_COD     = SF3.F3_CLIEFOR
									  AND SA2.A2_LOJA    = SF3.F3_LOJA
									  AND SA2.A2_EST     = SF3.F3_ESTADO
									  AND SA2.%NotDel%
								),'')
		END)               AS NOME
	 , F3_ESTADO           AS ESTADO
	 , ROUND(F3_VALCONT,2) AS [VALOR]
	 , ROUND(F3_BASEICM,2) AS BASE_ICMS
	 , ROUND(F3_VALICM ,2) AS VALOR_ICMS
	 , ROUND(F3_ISENICM,2) AS ISENT_ICMS
	 , ROUND(F3_BASEIPI,2) AS BASE_IPI
	 , ROUND(F3_VALIPI ,2) AS VALOR_IPI
	 , ROUND(F3_ISENIPI,2) AS ISENT_IPI
	 , ROUND(F3_DESCZFR,2) AS SUFRAMA
	 , (CASE WHEN  (F3_CFO >= '5' AND F3_TIPO <> 'D') OR (F3_CFO <  '5' AND F3_TIPO =  'D')
	 				THEN ISNULL((	SELECT F2_VALIMP6
									FROM %table:SF2% SF2
									WHERE SF2.F2_FILIAL  = %xFilial:SF2%
									  AND SF2.F2_DOC     = SF3.F3_NFISCAL
									  AND SF2.F2_SERIE   = SF3.F3_SERIE
									  AND SF2.F2_CLIENTE = SF3.F3_CLIEFOR
									  AND SF2.F2_LOJA    = SF3.F3_LOJA
									  AND SF2.F2_EST     = SF3.F3_ESTADO
									  AND SF2.F2_EMISSAO = SF3.F3_ENTRADA
									  AND SF2.F2_ESPECIE = SF3.F3_ESPECIE
									  AND SF2.%NotDel%
								),'')
					ELSE ISNULL((	SELECT F1_VALIMP6
									FROM %table:SF1% SF1
									WHERE SF1.F1_FILIAL  = %xFilial:SF1%
									  AND SF1.F1_DOC     = SF3.F3_NFISCAL
									  AND SF1.F1_SERIE   = SF3.F3_SERIE
									  AND SF1.F1_FORNECE = SF3.F3_CLIEFOR
									  AND SF1.F1_LOJA    = SF3.F3_LOJA
									  AND SF1.F1_EST     = SF3.F3_ESTADO
									  AND SF1.F1_DTDIGIT = SF3.F3_ENTRADA
									  AND SF1.F1_ESPECIE = SF3.F3_ESPECIE
									  AND SF1.%NotDel%
								),'')
		END)               VALOR_PIS
	 , (CASE WHEN  (F3_CFO >= '5' AND F3_TIPO <> 'D') OR (F3_CFO <  '5' AND F3_TIPO =  'D')
	 				THEN ISNULL((	SELECT F2_VALIMP5
									FROM %table:SF2% SF2
									WHERE SF2.F2_FILIAL  = %xFilial:SF2%
									  AND SF2.F2_DOC     = SF3.F3_NFISCAL
									  AND SF2.F2_SERIE   = SF3.F3_SERIE
									  AND SF2.F2_CLIENTE = SF3.F3_CLIEFOR
									  AND SF2.F2_LOJA    = SF3.F3_LOJA
									  AND SF2.F2_EST     = SF3.F3_ESTADO
									  AND SF2.F2_EMISSAO = SF3.F3_ENTRADA
									  AND SF2.F2_ESPECIE = SF3.F3_ESPECIE
									  AND SF2.%NotDel%
								),'')
					ELSE ISNULL((	SELECT F1_VALIMP5
									FROM %table:SF1% SF1
									WHERE SF1.F1_FILIAL  = %xFilial:SF1%
									  AND SF1.F1_DOC     = SF3.F3_NFISCAL
									  AND SF1.F1_SERIE   = SF3.F3_SERIE
									  AND SF1.F1_FORNECE = SF3.F3_CLIEFOR
									  AND SF1.F1_LOJA    = SF3.F3_LOJA
									  AND SF1.F1_EST     = SF3.F3_ESTADO
									  AND SF1.F1_DTDIGIT = SF3.F3_ENTRADA
									  AND SF1.F1_ESPECIE = SF3.F3_ESPECIE
									  AND SF1.%NotDel%
								),'')
		END)               VALOR_COF
 	 , F3_OBSERV AS OBS
	 FROM %table:SF3% SF3
	 WHERE SF3.F3_FILIAL        = %xFilial:SF3%
	   AND SF3.F3_ENTRADA BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
	   AND SF3.F3_SERIE   BETWEEN %Exp:MV_PAR03      % AND %Exp:MV_PAR04      %
	   AND SF3.F3_NFISCAL BETWEEN %Exp:MV_PAR05      % AND %Exp:MV_PAR06      %
	   AND SF3.%NotDel%
	ORDER BY F3_FILIAL, BASE_ICMS DESC, F3_EMISSAO, F3_NFISCAL, F3_SERIE
EndSql
//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT", GetLastQuery()[02])

IF TFIS->(!EOF())
    //Criando o objeto que irá gerar o conteúdo do Excel
    oFWMsExcel := FWMSExcel():New()
     
    //Aba 01
    oFWMsExcel:AddworkSheet("NOTAS FISCAIS")

        //Criando a Tabela
        oFWMsExcel:AddTable("NOTAS FISCAIS","NF")
        oFWMsExcel:AddColumn("NOTAS FISCAIS","NF","TIPO",1)
        oFWMsExcel:AddColumn("NOTAS FISCAIS","NF","EMISSAO",1)
        oFWMsExcel:AddColumn("NOTAS FISCAIS","NF","DIGITACAO",1)
        oFWMsExcel:AddColumn("NOTAS FISCAIS","NF","DOC_FISCAL",1)
        oFWMsExcel:AddColumn("NOTAS FISCAIS","NF","SERIE",1)        
        oFWMsExcel:AddColumn("NOTAS FISCAIS","NF","CFOP",1)
        oFWMsExcel:AddColumn("NOTAS FISCAIS","NF","CLIENTE",1)
        oFWMsExcel:AddColumn("NOTAS FISCAIS","NF","LOJA",1)
        oFWMsExcel:AddColumn("NOTAS FISCAIS","NF","NOME",1)
        oFWMsExcel:AddColumn("NOTAS FISCAIS","NF","ESTADO",1)
        oFWMsExcel:AddColumn("NOTAS FISCAIS","NF","VALOR",1)
        oFWMsExcel:AddColumn("NOTAS FISCAIS","NF","BASE_ICMS",1)
        oFWMsExcel:AddColumn("NOTAS FISCAIS","NF","VALOR_ICMS",1)
        oFWMsExcel:AddColumn("NOTAS FISCAIS","NF","ISENT_ICMS",1)
        oFWMsExcel:AddColumn("NOTAS FISCAIS","NF","BASE_IPI",1)
        oFWMsExcel:AddColumn("NOTAS FISCAIS","NF","VALOR_IPI",1)
        oFWMsExcel:AddColumn("NOTAS FISCAIS","NF","ISENT_IPI",1)       
        oFWMsExcel:AddColumn("NOTAS FISCAIS","NF","SUFRAMA",1)
        oFWMsExcel:AddColumn("NOTAS FISCAIS","NF","VALOR_PIS",1)
        oFWMsExcel:AddColumn("NOTAS FISCAIS","NF","VALOR_COF",1) 
        oFWMsExcel:AddColumn("NOTAS FISCAIS","NF","OBS",1)
              
        //Criando as Linhas... Enquanto não for fim da query
        WHILE TFIS->(!EOF())
            oFWMsExcel:AddRow("NOTAS FISCAIS","NF",{;
            		TFIS->TIPO       ,;
					TFIS->EMISSAO    ,;
					TFIS->DIGITACAO  ,;
					TFIS->DOC_FISCAL ,;
					TFIS->SERIE      ,;
					TFIS->CFOP       ,;
					TFIS->CLIENTE    ,;
					TFIS->LOJA       ,;
					TFIS->NOME       ,;
					TFIS->ESTADO     ,;
					TFIS->VALOR      ,;
					TFIS->BASE_ICMS  ,;
					TFIS->VALOR_ICMS ,;
					TFIS->ISENT_ICMS ,;
					TFIS->BASE_IPI   ,;
					TFIS->VALOR_IPI  ,;
					TFIS->ISENT_IPI  ,;
					TFIS->VALOR_PIS  ,;
					TFIS->VALOR_COF  ,;
					TFIS->SUFRAMA    ,;
					TFIS->OBS;
            })
            TFIS->(dbSkip())
        ENDDO
     
    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
         
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()           //Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)              //Visualiza a planilha
    oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas

ENDIF
TFIS->(dbCloseArea())



/*
For nI  := 1 To Len(SF3aStru)
	If (SF3aStru[nI][2] $ 'DNL')
		TCSetField('TFIS',SF3aStru[nI,1], SF3aStru[nI,2],SF3aStru[nI,3],SF3aStru[nI,4])
	EndIf
Next
_aCabec := {"TIPO"       ,;
			"EMISSAO"    ,;
			"DIGITACAO"  ,;
			"DOC_FISCAL" ,;
			"SERIE"      ,;
			"CFOP"       ,;
			"CLIENTE"    ,;
			"LOJA"       ,;
			"NOME"       ,;
			"ESTADO"     ,;
			"VALOR"      ,;
			"BASE_ICMS"  ,;
			"VALOR_ICMS" ,;
			"ISENT_ICMS" ,;
			"BASE_IPI"   ,;
			"VALOR_IPI"  ,;
			"ISENT_IPI"  ,;
			"SUFRAMA"    ,;
			"VALOR_PIS"  ,;
			"VALOR_COF"  ,;
			"OBS"         }
dbSelectArea("TFIS")
TFIS->(dbGoTop())
While !TFIS->(EOF())
	AADD(_aItens,{	TFIS->TIPO       ,;
					TFIS->EMISSAO    ,;
					TFIS->DIGITACAO  ,;
					TFIS->DOC_FISCAL ,;
					TFIS->SERIE      ,;
					TFIS->CFOP       ,;
					TFIS->CLIENTE    ,;
					TFIS->LOJA       ,;
					TFIS->NOME       ,;
					TFIS->ESTADO     ,;
					TFIS->VALOR      ,;
					TFIS->BASE_ICMS  ,;
					TFIS->VALOR_ICMS ,;
					TFIS->ISENT_ICMS ,;
					TFIS->BASE_IPI   ,;
					TFIS->VALOR_IPI  ,;
					TFIS->ISENT_IPI  ,;
					TFIS->VALOR_PIS  ,;
					TFIS->VALOR_COF  ,;
					TFIS->SUFRAMA    ,;
					TFIS->OBS        })
	dbSelectArea("TFIS")
	TFIS->(dbSkip())
EndDo
If Len(_aItens) > 0
	MsgRun("Exportando os Registros para o Excel","Aguarde.....",{|| DlgToExcel({{'ARRAY','Relação de documentos fiscais',_aCabec,_aItens}})})	
EndIf
If Select("TFIS") > 0
   TFIS->(DBCLOSEAREA())
EndIf
//FErase(cDirDocs+"\"+cNomeArq+".DBF")
If File(cDirDocs+"\"+cNomeArq+_cExtArq)
	FErase(cDirDocs+"\"+cNomeArq+_cExtArq)
EndIf
If File(cDirDocs+"\"+cNomeArq+_cExtInd)
	FErase(cDirDocs+"\"+cNomeArq+_cExtInd)
EndIf
*/
Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ExpExcel º Autor ³Júlio Soares          º Data ³  04/10/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função responsável por exportar retorno de consultas(query)º±±
±±º          ³ diretamente para Excel.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal.                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ExpExcel(_cAREA)

Local oExcelApp
Local cPath    := AllTrim(GetTempPath())
Local cArquivo := cNomeArq

dbSelectArea(_cAREA)
/*
__X := cDirDocs+"\"+cArquivo+".DBF"
COPY TO &__X VIA "DBFCDXADS"
CpyS2T( cDirDocs+"\"+cArquivo+".DBF",cPath,.T.)
oExcelApp := MsExcel():New()
oExcelApp:WorkBooks:Open(cPath+cArquivo+".DBF")
oExcelApp:SetVisible(.T.)
*/
/*
DBFCDX...: RDD indicada no arquivo de configuração (.INI) do Server do Protheus pela chave LocalFiles
DBFCDXADS: ADS Local
DBFCDXAX.: ADS Server
TOPCONN..: Top Connect
BTVCDX...: BTrieve
CTREECDX.: CTree
*/
__X := cDirDocs+"\"+cArquivo+_cExtArq
COPY TO &__X VIA "DBFCDX"
CpyS2T( cDirDocs+"\"+cArquivo+_cExtArq,cPath,.T.)
oExcelApp := MsExcel():New()
oExcelApp:WorkBooks:Open(cPath+cArquivo+_cExtArq)
oExcelApp:SetVisible(.T.)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg º Autor ³Júlio Soares          º Data ³  04/10/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função responsável pela inclusão de parâmetros na rotina.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal.                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ValidPerg()

Local _sAlias := GetArea()
Local aRegs   := {}

cPerg := PADR(cPerg,10)

AADD(aRegs,{cPerg,"01","Emissão de ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Emissão até?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","De Série?"   ,"","","mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Até Série?"  ,"","","mv_ch4","C",03,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"05","De Nota?"    ,"","","mv_ch5","C",09,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"06","Até Nota?"   ,"","","mv_ch6","C",09,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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

Return
