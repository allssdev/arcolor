#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RPCPR002  � Autor �Adriano Leonardo      � Data �  05/12/13 ���
�������������������������������������������������������������������������͹��
���Descricao � Exporta para excel relat�rio de autoria das estruturas de  ���
���          � produtos, considerando a soma das MPs das bases (PI).      ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RPCPR002()

Local _aSavArea	   := GetArea()
Private _cRotina   := "RPCPR002"
Private cDirDocs   := MsDocPath()
Private cNomeArq   := CriaTrab(,.F.)
Private _cExtArq   := GetDBExtension()
Private _cExtInd   := OrdBagExt()

//ValidPerg()
If !Pergunte(_cRotina,.T.)
	Return()
EndIf
If !(SubStr(cAcesso,160,1) == "S" .AND. SubStr(cAcesso,168,1) == "S" .AND. SubStr(cAcesso,170,1) == "S")
	MsgStop('Usu�rio sem permiss�o para exportar dados para Excel, informe o Administrador!',_cRotina +"001")
	Return(Nil)
EndIf
/*If !ApOleClient('MsExcel')
	MsgStop('Excel n�o instalado!',_cRotina +"002")
	Return(Nil)
EndIf*/
Processa( {|lEnd| SelDados(@lEnd) }, "Relat�rio de auditoria das estruturas de produtos", "Processando informa��es...",.T.)
        
RestArea(_aSavArea)

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SelDados  � Autor �Adriano Leonardo      � Data �  18/06/13 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o respons�vel pela sele��o dos dados.                 ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function SelDados(lEnd)
Local oFWMsExcel
Local oExcel
Local cArquivo    := GetTempPath()+"RPCPR002_"+DTOS(dDataBase)+".xml"


cAliasTop1 := GetNextAlias()
    
_cQuery := " SELECT G1_COD AS PRODUTO, "
_cQuery += " SB1.B1_DESC AS DESCRICAO, "
_cQuery += " SUM(G1_QUANT) AS SOMA "
_cQuery += " FROM " + RetSqlName("SG1") + " SG1 (NOLOCK) "
_cQuery += "   INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.D_E_L_E_T_  = '' "
_cQuery += "						AND SB1.B1_FILIAL   = '" + xFilial("SB1") + "' "
//_cQuery += "						AND SB1.B1_TIPO     = 'PI' " //Linha comentada em 05/12/2013 a pedido do Sr. Marco
//_cQuery += "						AND SB1.B1_UM       = 'KG' "
_cQuery += "						AND SB1.B1_COD      = SG1.G1_COD "
_cQuery += "   INNER JOIN " + RetSqlName("SB1") + " SB1B ON SB1B.D_E_L_E_T_ = '' "
_cQuery += "						AND SB1B.B1_FILIAL   = '" + xFilial("SB1") + "' "
_cQuery += "						AND SB1B.B1_UM       = 'KG' "
_cQuery += "						AND SB1B.B1_COD      = SG1.G1_COMP "
_cQuery += " WHERE SG1.D_E_L_E_T_ = '' "
_cQuery += "  AND SG1.G1_FILIAL  = '" + xFilial("SG1") + "' "
_cQuery += "  GROUP BY SG1.G1_COD, SB1.B1_DESC "
//_cQuery += "  HAVING ROUND(SUM(SG1.G1_QUANT),6)<>1 "
_cQuery += " ORDER BY G1_COD "
TCQUERY _cQuery NEW ALIAS "TMPPCP002"

IF TMPPCP002->(!EOF())
    //Criando o objeto que ir� gerar o conte�do do Excel
    oFWMsExcel := FWMSExcel():New()
     
    //Aba 01
    oFWMsExcel:AddworkSheet("ESTRUTURA PRODUTOS")
        //Criando a Tabela
        oFWMsExcel:AddTable("ESTRUTURA PRODUTOS","ESTRUTURA")
        oFWMsExcel:AddColumn("ESTRUTURA PRODUTOS","ESTRUTURA","PRODUTO",1)
        oFWMsExcel:AddColumn("ESTRUTURA PRODUTOS","ESTRUTURA","DESCRICAO",1)
        oFWMsExcel:AddColumn("ESTRUTURA PRODUTOS","ESTRUTURA","SOMA",1)
       
        //Criando as Linhas... Enquanto n�o for fim da query
        WHILE TMPPCP002->(!EOF())
            oFWMsExcel:AddRow("ESTRUTURA PRODUTOS","ESTRUTURA",{;
							TMPPCP002->PRODUTO,;
							TMPPCP002->DESCRICAO,;
							TMPPCP002->SOMA;
            })
            TMPPCP002->(dbSkip())
        ENDDO
     
    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
         
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()           //Abre uma nova conex�o com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)              //Visualiza a planilha
    oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas

ENDIF
TMPPCP002->(dbCloseArea())

/*
EXPEXCEL("TMPPCP002")
If Select ("TMPPCP002") > 0
   TMPPCP002->(DBCLOSEAREA())
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ExpExcel  � Autor �Adriano Leonardo      � Data �  18/06/13 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o respons�vel por exportar retorno de consultas(query)���
���          � diretamente para Excel.                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ExpExcel(_cAREA)

Local oExcelApp
Local cPath    := AllTrim(GetTempPath())
Local cArquivo := cNomeArq

dbSelectArea(_cAREATmp)
/*
__X := cDirDocs+"\"+cArquivo+".DBF"
COPY TO &__X VIA "DBFCDXADS"
CpyS2T( cDirDocs+"\"+cArquivo+".DBF",cPath,.T.)
oExcelApp := MsExcel():New()
oExcelApp:WorkBooks:Open(cPath+cArquivo+".DBF")
oExcelApp:SetVisible(.T.)
*/
/*
DBFCDX...: RDD indicada no arquivo de configura��o (.INI) do Server do Protheus pela chave LocalFiles
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
