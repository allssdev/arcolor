#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFISR004  º Autor ³Adriano Leonardo      º Data ³  18/06/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Exporta para excel a relação de notas fiscais de saída     º±±
±±º          ³ por itens, dentro do período específicado.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFISR004()

Local _aSavArea	   := GetArea()
Private _cRotina   := "RFISR004"
Private cPerg      := _cRotina
Private cDirDocs   := MsDocPath()
Private cNomeArq   := CriaTrab(,.F.)
Private _cExtArq   := GetDBExtension()
Private _cExtInd   := OrdBagExt()

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
EndIf
*/
Processa( {|lEnd| SelDados(@lEnd) }, "Relatório de Relação de Notas Fiscais de Saída", "Processando informações...",.T.)
        
RestArea(_aSavArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SelDados  º Autor ³Adriano Leonardo      º Data ³  18/06/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função responsável pela seleção dos dados.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SelDados(lEnd)
Local oFWMsExcel
Local oExcel
Local cArquivo    := GetTempPath()+"RFISR004_"+DTOS(dDataBase)+".xml"

cAliasTop1 := GetNextAlias()
    
_cQuery := " SELECT F3_TIPO AS TIPO,CAST (F3_EMISSAO AS DATE) AS EMISSAO,CAST (F3_ENTRADA AS DATE) AS DIGITACAO, "
_cQuery += " F3_NFISCAL  AS DOC_FISCAL,F3_SERIE AS SERIE,F3_CFO AS CFOP,F3_CLIEFOR AS CLIENTE,F3_LOJA AS LOJA, "
_cQuery += " CASE WHEN  (F3_CFO >= '5' AND F3_TIPO <> 'D') THEN ISNULL(A1_NOME,'') ELSE "
_cQuery += " (CASE WHEN (F3_CFO >= '5' AND F3_TIPO =  'D') THEN ISNULL(A2_NOME,'') ELSE "
_cQuery += " (CASE WHEN (F3_CFO <  '5' AND F3_TIPO <> 'D') THEN ISNULL(A2_NOME,'') ELSE "
_cQuery += " (CASE WHEN (F3_CFO <  '5' AND F3_TIPO =  'D') THEN ISNULL(A1_NOME,'') END) END) END) END AS NOME, "
_cQuery += " F3_ESTADO AS ESTADO, "
_cQuery += " F3_VALCONT AS VALOR,F3_BASEICM AS BASE_ICMS,F3_VALICM AS VALOR_ICMS,F3_ISENICM AS ISENT_ICMS, "
_cQuery += " F3_BASEIPI AS BASE_IPI,F3_VALIPI AS VALOR_IPI,F3_ISENIPI AS ISENT_IPI,F3_DESCZFR AS SUFRAMA, "
_cQuery += " F3_OBSERV AS OBS "
_cQuery += " FROM " + RetSqlName("SF3") + " SF3 "
_cQuery += " 	LEFT JOIN " + RetSqlName("SA1")+ " SA1 ON SA1.D_E_L_E_T_ = '' "
_cQuery += " 		AND SF3.F3_CLIEFOR = SA1.A1_COD "
_cQuery += " 		AND SF3.F3_LOJA = SA1.A1_LOJA "
_cQuery += " 		AND SF3.F3_ESTADO = SA1.A1_EST "
_cQuery += " 	LEFT JOIN " + RetSqlName("SA2") + " SA2 ON SA2.D_E_L_E_T_ = '' "
_cQuery += " 		AND SF3.F3_CLIEFOR = SA2.A2_COD "
_cQuery += " 		AND SF3.F3_LOJA = SA2.A2_LOJA "
_cQuery += " 		AND SF3.F3_ESTADO = SA2.A2_EST "
_cQuery += " WHERE SF3.D_E_L_E_T_ = '' "
_cQuery += " 	AND F3_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
_cQuery += " 	AND F3_SERIE   BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
_cQuery += " 	AND F3_NFISCAL BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
_cQuery += " ORDER BY F3_EMISSAO, F3_NFISCAL, F3_SERIE "
TCQUERY _cQuery NEW ALIAS "TMPCTB002"

IF TMPCTB002->(!EOF())
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
        oFWMsExcel:AddColumn("NOTAS FISCAIS","NF","OBS",1)
              
        //Criando as Linhas... Enquanto não for fim da query
        WHILE TMPCTB002->(!EOF())
            oFWMsExcel:AddRow("NOTAS FISCAIS","NF",{;
							TMPCTB002->TIPO,;
							TMPCTB002->EMISSAO,;
							TMPCTB002->DIGITACAO,;
							TMPCTB002->DOC_FISCAL,;
							TMPCTB002->SERIE,;
							TMPCTB002->CFOP,;
							TMPCTB002->CLIENTE,;
							TMPCTB002->LOJA,;
							TMPCTB002->NOME,;
							TMPCTB002->ESTADO,;
							TMPCTB002->VALOR,;
							TMPCTB002->BASE_ICMS,;
							TMPCTB002->VALOR_ICMS,;
							TMPCTB002->ISENT_ICMS,;
							TMPCTB002->BASE_IPI,;
							TMPCTB002->VALOR_IPI,;
							TMPCTB002->ISENT_IPI,;														
							TMPCTB002->SUFRAMA,;
							TMPCTB002->OBS;
            })
            TMPCTB002->(dbSkip())
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
TMPCTB002->(dbCloseArea())

/*
EXPEXCEL("TMPCTB002")
If Select ("TMPCTB002") > 0
   TMPCTB002->(DBCLOSEAREA())
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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ExpExcel  º Autor ³Adriano Leonardo      º Data ³  18/06/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função responsável por exportar retorno de consultas(query)º±±
±±º          ³ diretamente para Excel.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

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

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg º Autor ³Adriano Leonardo      º Data ³  18/06/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função responsável pela inclusão de parâmetros na rotina.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
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

For i:=1 To Len(aRegs)
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
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
