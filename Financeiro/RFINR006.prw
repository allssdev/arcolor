#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE _CLRF CHR(13) + CHR(10)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFINR006  � Autor �Adriano Leonardo      � Data �  18/06/13 ���
���Programa  �          � Autor � J�lio Soares         � Data �  08/01/16 ���
�������������������������������������������������������������������������͹��
���Descricao � Exporta para excel a rela��o de t�tulos a receber de       ���
���          � pedidos de funcion�rios.                                   ���
�������������������������������������������������������������������������͹��
���          � Alterado a forma de exporta��o para planilha em Excel ap�s ���
���          � o sistema perder ser atualizado para cTree.                ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function RFINR006()

Local _aSavArea	   := GetArea()

Private _cRotina   := "RFINR006"
Private cPerg      := _cRotina
Private cDirDocs   := MsDocPath()
Private cNomeArq   := CriaTrab(,.F.)
Private _cExtArq   := GetDBExtension()
Private _cExtInd   := OrdBagExt()
Private SF1aStru   := SF1->(dbStruct())

ValidPerg()
If !Pergunte(cPerg,.T.)
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
Processa( {|lEnd| SelDados(@lEnd) }, "Relat�rio de auditoria das devolu��es de vendas", "Processando informa��es...",.T.)
        
RestArea(_aSavArea)

Return()

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SelDados  � Autor �Adriano Leonardo      � Data �  18/06/13 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o respons�vel pela sele��o dos dados.                 ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal.                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function SelDados(lEnd)

Private _aCabec  := {}
Private _aItens  := {}

cAliasTop1 := GetNextAlias()

//Aten��o o nome das colunas n�o pode conter mais que 10 caracteres    
_cQuery := "SELECT SUBSTRING(F1_EMISSAO,7,2) + '/' + SUBSTRING(F1_EMISSAO,5,2) + '/' + SUBSTRING(F1_EMISSAO,1,4) AS [EMISSAO]" + _CLRF
_cQuery += "     , SUBSTRING(F1_DTDIGIT,7,2) + '/' + SUBSTRING(F1_DTDIGIT,5,2) + '/' + SUBSTRING(F1_DTDIGIT,1,4) AS [DTDIGIT]" + _CLRF
_cQuery += "     , F1_DOC AS [DOCUMENTO], F1_SERIE AS [SERIE], F1_FORNECE AS [CLIENTE], F1_LOJA AS [LOJA]" + _CLRF
_cQuery += "     , SA1.A1_NOME AS [NOME], F1_VALBRUT [TOTAL], F1_VEND1 [VENDEDOR] " + _CLRF
_cQuery += "     , ISNULL((SELECT SUM(E1_SALDO) " + _CLRF
_cQuery += "               FROM " + RetSqlName("SE1") + " SE1 " + _CLRF
_cQuery += "               WHERE SE1.E1_FILIAL  = '" + xFilial("SE1") + "' " + _CLRF
_cQuery += "                 AND SE1.E1_CLIENTE = SA1.A1_COD " + _CLRF
_cQuery += "                 AND SE1.E1_LOJA    = SA1.A1_LOJA" + _CLRF
_cQuery += "                 AND SE1.E1_TIPO    = 'NCC' " + _CLRF
_cQuery += "                 AND SE1.D_E_L_E_T_ = '' " + _CLRF
_cQuery += "              ),0) AS [CREDITOS] " + _CLRF
_cQuery += "FROM " + RetSqlName("SF1") + " SF1 " + _CLRF
_cQuery += "             INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_FILIAL       = '" + xFilial("SA1") + "' " + _CLRF
_cQuery += "                           AND SA1.A1_COD    BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " + _CLRF
_cQuery += "                           AND SA1.A1_LOJA   BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " + _CLRF
_cQuery += "                           AND SA1.A1_COD          = SF1.F1_FORNECE " + _CLRF
_cQuery += "                           AND SA1.A1_LOJA         = SF1.F1_LOJA " + _CLRF
_cQuery += "                           AND SA1.D_E_L_E_T_ = '' " + _CLRF
_cQuery += "WHERE SF1.F1_FILIAL        = '" + xFilial("SF1") + "' " + _CLRF
_cQuery += "  AND SF1.F1_TIPO          = 'D' " + _CLRF
_cQuery += "  AND SF1.F1_DTDIGIT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' " + _CLRF
_cQuery += "  AND SF1.F1_VEND1   BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' " + _CLRF
_cQuery += "  AND SF1.D_E_L_E_T_       = '' " + _CLRF
_cQuery += "ORDER BY SA1.A1_COD, SA1.A1_LOJA, SF1.F1_DTDIGIT, SF1.F1_EMISSAO " + _CLRF

//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",_cQuery)  

// - INSERIDO J�LIO
cQuery  := ChangeQuery(_cQuery)

dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),'TMPDEV', .F., .T.)
For nI  := 1 To Len(SF1aStru)
	TCSetField('TMPDEV',SF1aStru[nI,1], SF1aStru[nI,2],SF1aStru[nI,3],SF1aStru[nI,4])
Next

// Altera��o - Fernando Bombardi - ALLSS - 03/03/2022
/*
_aCabec := {"EMISSAO"    ,;
			"DIGITACAO"  ,;
			"DOCUMENTO"  ,;
			"SERIE"      ,;
			"CLIENTE"    ,;
			"LOJA"       ,;
			"NOME"       ,;
			"TOTAL"      ,;
			"VENDEDOR"   ,;
			"CREDITOS"   }
*/
_aCabec := {"EMISSAO"    ,;
			"DIGITACAO"  ,;
			"DOCUMENTO"  ,;
			"SERIE"      ,;
			"CLIENTE"    ,;
			"LOJA"       ,;
			"NOME"       ,;
			"TOTAL"      ,;
			"REPRESENTANTE"   ,;
			"CREDITOS"   }			
dbSelectArea("TMPDEV")
// Fim - Fernando Bombardi - ALLSS - 03/03/2022

TMPDEV->(dbGoTop())
	While !TMPDEV->(EOF())
		AADD(_aItens,{	TMPDEV->EMISSAO    ,;
						TMPDEV->DTDIGIT    ,;
						TMPDEV->DOCUMENTO  ,;
						TMPDEV->SERIE      ,;
						TMPDEV->CLIENTE    ,;
						TMPDEV->LOJA       ,;
						TMPDEV->NOME       ,;
						TMPDEV->TOTAL      ,;
						TMPDEV->VENDEDOR   ,;
						TMPDEV->CREDITOS   })
	dbSelectArea("TMPDEV")
	TMPDEV->(dbSkip())
EndDo
If Len(_aItens) > 0
	MsgRun("Exportando informa��es para o Excel","Aguarde.....",{|| DlgToExcel({{'ARRAY','Rela��o de documentos fiscais',_aCabec,_aItens}})})	
EndIf
If Select("TMPDEV") > 0
	TMPDEV->(DBCLOSEAREA())
EndIf
If File(cDirDocs+"\"+cNomeArq+_cExtArq)
	FErase(cDirDocs+"\"+cNomeArq+_cExtArq)
EndIf
If File(cDirDocs+"\"+cNomeArq+_cExtInd)
	FErase(cDirDocs+"\"+cNomeArq+_cExtInd)
EndIf

Return(Nil)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ExpExcel  � Autor �Adriano Leonardo      � Data �  18/06/13 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o respons�vel por exportar retorno de consultas(query)���
���          � diretamente para Excel.                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal.                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function ExpExcel(_cAREATmp)

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
/* FB - RELEASE 12.1.23
__X := cDirDocs+"\"+cArquivo+_cExtArq
COPY TO &__X VIA "DBFCDX"
CpyS2T( cDirDocs+"\"+cArquivo+_cExtArq,cPath,.T.)
oExcelApp := MsExcel():New()
oExcelApp:WorkBooks:Open(cPath+cArquivo+_cExtArq)
oExcelApp:SetVisible(.T.)
*/
Return(Nil)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValidPerg � Autor �Adriano Leonardo      � Data �  18/06/13 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o respons�vel pela inclus�o de par�metros na rotina.  ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function ValidPerg()

Local _sAlias := GetArea()
Local aRegs   := {}

cPerg := PADR(cPerg,10)

AADD(aRegs,{cPerg,"01","De Emiss�o?" 	,"","","mv_ch1","D",08,0,0,"G","NaoVazio()"	,"mv_par01","","","",""        	,"","","","","","","","","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"02","At� Emiss�o?"	,"","","mv_ch2","D",08,0,0,"G","NaoVazio()"	,"mv_par02","","","",""        	,"","","","","","","","","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"03","De Cliente?"  	,"","","mv_ch3","C",06,0,0,"G",""			,"mv_par03","","","",""			,"","","","","","","","","","","","","","","","","","","","","SA1",""})
AADD(aRegs,{cPerg,"04","At� Cliente?"  	,"","","mv_ch4","C",06,0,0,"G","NaoVazio()"	,"mv_par04","","","",""      	,"","","","","","","","","","","","","","","","","","","","","SA1",""})
AADD(aRegs,{cPerg,"05","De Loja?"  	  	,"","","mv_ch5","C",02,0,0,"G",""			,"mv_par05","","","",""			,"","","","","","","","","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"06","At� Loja?"  	,"","","mv_ch6","C",02,0,0,"G","NaoVazio()"	,"mv_par06","","","",""  		,"","","","","","","","","","","","","","","","","","","","",""   ,""})

// Altera��o - Fernando Bombardi - ALLSS - 03/03/2022
//AADD(aRegs,{cPerg,"07","De Vendedor?"  	,"","","mv_ch7","C",06,0,0,"G",""			,"mv_par07","","","",""			,"","","","","","","","","","","","","","","","","","","","","SA3",""})
//AADD(aRegs,{cPerg,"08","At� Vendedor?" 	,"","","mv_ch8","C",06,0,0,"G","NaoVazio()"	,"mv_par08","","","",""      	,"","","","","","","","","","","","","","","","","","","","","SA3",""})
AADD(aRegs,{cPerg,"07","De Representante?"  	,"","","mv_ch7","C",06,0,0,"G",""			,"mv_par07","","","",""			,"","","","","","","","","","","","","","","","","","","","","SA3",""})
AADD(aRegs,{cPerg,"08","At� Representante?" 	,"","","mv_ch8","C",06,0,0,"G","NaoVazio()"	,"mv_par08","","","",""      	,"","","","","","","","","","","","","","","","","","","","","SA3",""})
// Fim - Fernando Bombardi - ALLSS - 03/03/2022

dbSelectArea("SX1")
SX1->(dbSetOrder(1))
For i := 1 To Len(aRegs)
	If !SX1->(dbSeek(cPerg+aRegs[i,2]))
		RecLock("SX1",.T.)
		For j := 1 To FCount()
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
