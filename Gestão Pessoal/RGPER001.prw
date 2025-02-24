#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RGPER001  � Autor �Adriano Leonardo      � Data �  18/06/13 ���
�������������������������������������������������������������������������͹��
���Descricao � Exporta para excel a rela��o de t�tulos a receber de       ���
���          � pedidos de funcion�rios.                                   ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function RGPER001()

Local _aSavArea	   := GetArea()

Private _cRotina   := "RGPER001"
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
	MsgStop('Usu�rio sem permiss�o para exportar dados para Excel, informe o Administrador!',_cRotina +"001")
	Return(Nil)
EndIf
/*If !ApOleClient('MsExcel')
	MsgStop('Excel n�o instalado!',_cRotina +"002")
	Return(Nil)
EndIf*/
//SelDados()
Processa( {|lEnd| SelDados(@lEnd) }, "Relat�rio de t�tulos a receber de funcion�rios", "Processando informa��es...",.T.)

RestArea(_aSavArea)

Return()

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SelDados  � Autor �Adriano Leonardo      � Data �  18/06/13 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o respons�vel pela sele��o dos dados.                 ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal.                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function SelDados()
Local oFWMsExcel
Local oExcel
Local cArquivo    := GetTempPath()+"RGPER001_"+DTOS(dDataBase)+".xml"

//Aten��o o nome das colunas n�o pode conter mais que 10 caracteres    
_cQuery := "SELECT RA_MAT AS [MATRICULA],E1_PEDIDO AS [PEDIDO], E1_PREFIXO AS [PREFIXO], E1_NUM AS [NUMERO], E1_PARCELA AS [PARCELA], E1_TIPO AS [TIPO], E1_NOMERAZ AS [NOME], E1_VALOR AS [VALOR], E1_SALDO AS [SALDO], (SUBSTRING(E1_EMISSAO,7,2) + '/' + SUBSTRING(E1_EMISSAO,5,2) + '/' + SUBSTRING(E1_EMISSAO,1,4)) AS [EMISSAO], (SUBSTRING(E1_VENCTO,7,2) + '/' + SUBSTRING(E1_VENCTO,5,2) + '/' + SUBSTRING(E1_VENCTO,1,4)) AS [VENCIMENTO] "
_cQuery += "FROM " + RetSqlName("SE1") + " SE1 "
_cQuery += "INNER JOIN "  + RetSqlName("SRA") + " SRA ON SRA.D_E_L_E_T_       = '' "
_cQuery += "                                         AND SRA.RA_FILIAL        = '"+xFilial("SRA")+"' "
_cQuery += "                                         AND SRA.RA_MAT     BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
_cQuery += "                                         AND SRA.RA_CLIENTE       = SE1.E1_CLIENTE "
_cQuery += "                                         AND SRA.RA_LOJACLI       = SE1.E1_LOJA "
_cQuery += "WHERE SE1.D_E_L_E_T_       = '' "
_cQuery += "  AND SE1.E1_FILIAL        = '"+xFilial("SE1")+"' "
_cQuery += "  AND SE1.E1_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' "
_cQuery += "  AND SE1.E1_VENCTO  BETWEEN '" + DtoS(MV_PAR03) + "' AND '" + DtoS(MV_PAR04) + "' "
If MV_PAR07 == 1
	_cQuery += "  AND SE1.E1_SALDO         > 0 "
Else
	_cQuery += "  AND SE1.E1_SALDO         = 0 "
EndIf
_cQuery += "ORDER BY E1_EMISSAO "
TCQUERY _cQuery NEW ALIAS "TMPGPE001"

IF TMPGPE001->(!EOF())
    //Criando o objeto que ir� gerar o conte�do do Excel
    oFWMsExcel := FWMSExcel():New()
     
    //Aba 01
    oFWMsExcel:AddworkSheet("TITULOS FUNCIONARIO")
        //Criando a Tabela
        oFWMsExcel:AddTable("TITULOS FUNCIONARIO","TITULOS")
        oFWMsExcel:AddColumn("TITULOS FUNCIONARIO","TITULOS","MATRICULA",1)
        oFWMsExcel:AddColumn("TITULOS FUNCIONARIO","TITULOS","PEDIDO",1)
        oFWMsExcel:AddColumn("TITULOS FUNCIONARIO","TITULOS","PREFIXO",1)
        oFWMsExcel:AddColumn("TITULOS FUNCIONARIO","TITULOS","NUMERO",1)
        oFWMsExcel:AddColumn("TITULOS FUNCIONARIO","TITULOS","PARCELA",1)
        oFWMsExcel:AddColumn("TITULOS FUNCIONARIO","TITULOS","TIPO",1)
        oFWMsExcel:AddColumn("TITULOS FUNCIONARIO","TITULOS","NOME",1)        
        oFWMsExcel:AddColumn("TITULOS FUNCIONARIO","TITULOS","VALOR",1)
        oFWMsExcel:AddColumn("TITULOS FUNCIONARIO","TITULOS","SALDO",1)
        oFWMsExcel:AddColumn("TITULOS FUNCIONARIO","TITULOS","EMISSAO",1)        
        oFWMsExcel:AddColumn("TITULOS FUNCIONARIO","TITULOS","VENCIMENTO",1)
        
        //Criando as Linhas... Enquanto n�o for fim da query
        WHILE TMPGPE001->(!EOF())
            oFWMsExcel:AddRow("TITULOS FUNCIONARIO","TITULOS",{;
							TMPGPE001->MATRICULA,;
							TMPGPE001->PEDIDO,;
							TMPGPE001->PREFIXO,;
							TMPGPE001->NUMERO,;
							TMPGPE001->PARCELA,;
							TMPGPE001->TIPO,;
							TMPGPE001->NOME,;
							TMPGPE001->VALOR,;
							TMPGPE001->SALDO,;
							TMPGPE001->EMISSAO,;
							TMPGPE001->VENCIMENTO;
            })
            TMPGPE001->(dbSkip())
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
TMPGPE001->(dbCloseArea())

/*
EXPEXCEL("TMPGPE001")
If Select ("TMPGPE001") > 0
   TMPGPE001->(DBCLOSEAREA())
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

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ExpExcel  � Autor �Adriano Leonardo      � Data �  18/06/13 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o respons�vel por exportar retorno de consultas(query)���
���          � diretamente para Excel.                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function ExpExcel(_cArea)

Local cPath    := AllTrim(GetTempPath())
Local oExcelApp
Local cArquivo := cNomeArq
/*
dbSelectArea(_cArea)
__X := cDirDocs+"\"+cArquivo+".DBF"
COPY TO &__X VIA "DBFCDXADS"
CpyS2T( cDirDocs+"\"+cArquivo+".DBF",cPath,.T.)
oExcelApp := MsExcel():New()
oExcelApp:WorkBooks:Open(cPath+cArquivo+".DBF")
oExcelApp:SetVisible(.T.)
*/

__X := cDirDocs+"\"+cArquivo+_cExtArq
COPY TO &__X VIA "DBFCDX"
CpyS2T( cDirDocs+"\"+cArquivo+_cExtArq,cPath,.T.)
oExcelApp := MsExcel():New()
oExcelApp:WorkBooks:Open(cPath+cArquivo+_cExtArq)
oExcelApp:SetVisible(.T.)

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

cPerg         := PADR(cPerg,10)

AADD(aRegs,{cPerg,"01","De Emiss�o?" 	  		    ,"","","mv_ch1","D",08,0,0,"G","NaoVazio()"	,"mv_par01",""       ,"","","20130401"	,""        ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"02","At� Emiss�o?"	  		    ,"","","mv_ch2","D",08,0,0,"G","NaoVazio()"	,"mv_par02",""       ,"","","20491231"	,""        ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"03","De Vencimento?"	  		    ,"","","mv_ch3","D",08,0,0,"G","NaoVazio()"	,"mv_par03",""       ,"","","20491231"	,""        ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"04","At� Vencimento?"  		    ,"","","mv_ch4","D",08,0,0,"G","NaoVazio()"	,"mv_par04",""       ,"","","20491231"	,""        ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"05","De Matr�cula?"  		    ,"","","mv_ch5","C",06,0,0,"G",""			,"mv_par05",""       ,"","",""			,""        ,"","","","","","","","","","","","","","","","","","","SRA","",""})
AADD(aRegs,{cPerg,"06","At� Matr�cula?"  		    ,"","","mv_ch6","C",06,0,0,"G","NaoVazio()"	,"mv_par06",""       ,"","","ZZZZZZ"	,""        ,"","","","","","","","","","","","","","","","","","","SRA","",""})
AADD(aRegs,{cPerg,"07","Situa��o?"      		    ,"","","mv_ch7","N",01,0,0,"C","NaoVazio()"	,"mv_par07","Abertos","","",""	        ,"Baixados","","","","","","","","","","","","","","","","","","",""   ,"",""})
For i := 1 To Len(aRegs)

_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
dbSelectArea(_cAliasSX1)
(_cAliasSX1)->(dbSetOrder(1))

	If !(_cAliasSX1)->(dbSeek(cPerg+aRegs[i,2]))
		RecLock(_cAliasSX1,.T.)
		For j:=1 To FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Else
				Exit
			EndIf
		Next
		(_cAliasSX1)->(MsUnlock())
	EndIf
Next

RestArea(_sAlias)

Return()
