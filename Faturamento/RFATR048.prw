#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "PROTHEUS.CH"


/*/
@author Livia Della Corte
@since 22/07/2019
@version 1.0
@type function
@see https://allss.com.br
/*/

User Function RFATR048()

Local _aSavArea	   := GetArea()
Local   _lProc    := type("cFilAnt")=="U"

Private _cRotina   := "RFATR048"
Private cDirDocs   := "MsDocPath()"
Private cNomeArq   := "CriaTrab(,.F.)"
Private _cExtArq   := "GetDBExtension()"
Private _cExtInd   := "OrdBagExt()"


If _lProc
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" FUNNAME _cRotina tables "SA1", "SA3", "SF2"
Endif
//ValidPerg()
If !Pergunte(_cRotina,.T.)
	Return()
EndIf

If !ApOleClient('MsExcel')
	MsgStop('Excel não instalado!',_cRotina +"002")
	Return(Nil)
EndIf
Processa( {|lEnd| SelDados(@lEnd) }, "Relatório de 	Ultimas Compras", "Processando informações...",.T.)
        
RestArea(_aSavArea)

Return()

/*/
@author Livia Della Corte
@since 22/07/2019
@version 1.0
@type function
@see https://allss.com.br
/*/
Static Function SelDados(lEnd)
Local oFWMsExcel
Local oExcel
Local cArquivo    := GetTempPath()+"RFATR048_"+DTOS(dDataBase)+"_"+StrTran(Time(),":","")+".xml"


cAliasTop1 := GetNextAlias()
    
_cQuery := " SELECT " 
_cQuery += "  A3_NOME 
_cQuery += " , substring(A1_ULTCOM, 7,2) + '/' + substring(A1_ULTCOM,5,2) + '/' + substring(A1_ULTCOM,1,4) A1_ULT "
_cQuery += " , F2_VALFAT  "
_cQuery += " , SA1.* "
_cQuery += " FROM    " + RetSqlName("SA1") + " SA1 (NOLOCK) " 
_cQuery += " 	JOIN " + RetSqlName("SF2") + " SF2 (NOLOCK) ON F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA AND A1_ULTCOM = F2_EMISSAO AND SF2.D_E_L_E_T_ = '' " 
_cQuery += " 	JOIN " + RetSqlName("SA3") + " SA3 (NOLOCK) ON A1_VEND = A3_COD AND SA3.D_E_L_E_T_ = '' "
_cQuery += " where A1_ULTCOM > = '20170101'"
_cQuery += " and SA1.D_E_L_E_T_ = '' "

_cQuery += " AND A1_VEND   >= '"+ mv_par01       +"' AND A1_VEND <='"   + mv_par02       +"' "
_cQuery += " AND A1_ULTCOM >= '"+ dtos(mv_par03) +"' AND A1_ULTCOM <='" + dtos(mv_par04) +"' "
_cQuery += " AND A1_COD    >= '"+ mv_par05       +"' AND A1_COD <='"    + mv_par07 		 +"' "
_cQuery += " AND A1_LOJA   >= '"+ mv_par06       +"' AND A1_LOJA <='"   + mv_par08 		 +"' "
If mv_par09 == 1
 _cQuery += " AND A1_MSBLQL = 1"
ElseIf   mv_par09 == 2
 _cQuery += " AND A1_MSBLQL = 2"
EndIF
 
 
 _cQuery += "  order by A1_ULT desc   "

TCQUERY _cQuery NEW ALIAS "RFATR048"

IF RFATR048->(!EOF())
    //Criando o objeto que irá gerar o conteúdo do Excel
    oFWMsExcel := FWMSExcel():New()
     
    //Aba 01
    oFWMsExcel:AddworkSheet("Ultima Compra")
        //Criando a Tabela
        oFWMsExcel:AddTable("Ultima Compra","Ultima Compra")

    	// Alteração - Fernando Bombardi - ALLSS - 03/03/2022
        //oFWMsExcel:AddColumn("Ultima Compra","Ultima Compra","Código Vendedor",1)
        oFWMsExcel:AddColumn("Ultima Compra","Ultima Compra","Código Representante",1)
        //oFWMsExcel:AddColumn("Ultima Compra","Ultima Compra","Nome Vendedor",1)
        oFWMsExcel:AddColumn("Ultima Compra","Ultima Compra","Nome Representante",1)
    	// Fim - Fernando Bombardi - ALLSS - 03/03/2022

        oFWMsExcel:AddColumn("Ultima Compra","Ultima Compra","Código Cliente",1)
        oFWMsExcel:AddColumn("Ultima Compra","Ultima Compra","Nome Cliente",1)
        oFWMsExcel:AddColumn("Ultima Compra","Ultima Compra","CGC",1)
        oFWMsExcel:AddColumn("Ultima Compra","Ultima Compra","CGC Centralizador",1) 
        oFWMsExcel:AddColumn("Ultima Compra","Ultima Compra","DDD",1)
        oFWMsExcel:AddColumn("Ultima Compra","Ultima Compra","Telefone",1)
        oFWMsExcel:AddColumn("Ultima Compra","Ultima Compra","Estado",1)       
        oFWMsExcel:AddColumn("Ultima Compra","Ultima Compra","Município",1)  
        oFWMsExcel:AddColumn("Ultima Compra","Ultima Compra","Bairro",1)          
        oFWMsExcel:AddColumn("Ultima Compra","Ultima Compra","E-mail",1)
        oFWMsExcel:AddColumn("Ultima Compra","Ultima Compra","Dt. Ultm. Compra",1)
        oFWMsExcel:AddColumn("Ultima Compra","Ultima Compra","Vl. Ultm. Compra",1)
        oFWMsExcel:AddColumn("Ultima Compra","Ultima Compra","Media 12 Meses",1)       
         oFWMsExcel:AddColumn("Ultima Compra","Ultima Compra","Media 12 Centralizador",1)           
        oFWMsExcel:AddColumn("Ultima Compra","Ultima Compra","Ativo",1)            
         
        //Criando as Linhas... Enquanto não for fim da query
        WHILE RFATR048->(!EOF())
            oFWMsExcel:AddRow("Ultima Compra","Ultima Compra",{;
							RFATR048->A1_VEND,;
							RFATR048->A3_NOME,;
							RFATR048->A1_COD,;
							RFATR048->A1_NOME,;
							RFATR048->A1_CGC,;
							RFATR048->A1_CGCCENT,;
							RFATR048->A1_DDD,;
							RFATR048->A1_TEL,;
							RFATR048->A1_EST,;
							RFATR048->A1_MUN,;
							RFATR048->A1_BAIRRO,;
							RFATR048->A1_EMAIL,;
							RFATR048->A1_ULT,;
							RFATR048->F2_VALFAT,;
							RFATR048->A1_MEDFATA,;
							RFATR048->A1_MEDCCEN,;
							IIF(RFATR048->A1_MSBLQL=="2","Sim","Não");
            })
            RFATR048->(dbSkip())
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
RFATR048->(dbCloseArea())


Return(Nil)


/*/
@author Livia Della Corte
@since 22/07/2019
@version 1.0
@type function Função responsável por exportar retorno de consultas(query) diretamente para Excel.   
@see https://allss.com.br
/*/


Static Function ExpExcel(_cArea)

Local oExcelApp
Local cPath    := AllTrim(GetTempPath())
Local cArquivo := cNomeArq

dbSelectArea(cAreaTemp)

__X := cDirDocs+"\"+cArquivo+_cExtArq
COPY TO &__X VIA "DBFCDX"
CpyS2T( cDirDocs+"\"+cArquivo+_cExtArq,cPath,.T.)
oExcelApp := MsExcel():New()
oExcelApp:WorkBooks:Open(cPath+cArquivo+_cExtArq)
oExcelApp:SetVisible(.T.)

Return(Nil)

Static Function ValidPerg()

Local _sAlias := GetArea()
Local aRegs   := {}

Local _cDef01   := "Sim"
Local _cDef02   := "Nao"

cPerg := PADR(_cRotina,10)

// Alteração - Fernando Bombardi - ALLSS - 03/03/2022
//U_RGENA001(cPerg,"01","De Vendedor?" 	  		,"mv_par01","mv_ch1","C",06,0,"G",""          ,"","","","")
//U_RGENA001(cPerg,"02","Até Vendedor?"	  		,"mv_par02","mv_ch2","C",06,0,"G","NaoVazio()","","","","")

U_RGENA001(cPerg,"01","De Representante?" 	  		,"mv_par01","mv_ch1","C",06,0,"G",""          ,"","","","")
U_RGENA001(cPerg,"02","Até Representante?"	  		,"mv_par02","mv_ch2","C",06,0,"G","NaoVazio()","","","","")
// Fim - Fernando Bombardi - ALLSS - 03/03/2022

U_RGENA001(cPerg,"03","De Data?" 	  		    ,"mv_par03","mv_ch3","D",08,0,"G",""          ,"","","","")
U_RGENA001(cPerg,"04","Até Data?"	  		    ,"mv_par04","mv_ch4","D",08,0,"G","NaoVazio()","","","","")
U_RGENA001(cPerg,"05","De Cliente?" 	  		,"mv_par05","mv_ch5","C",06,0,"G",""          ,"","","","")
U_RGENA001(cPerg,"06","Da Loja?"    	  		,"mv_par06","mv_ch6","C",02,0,"G",""          ,"","","","")
U_RGENA001(cPerg,"07","Até Cliente?"	  		,"mv_par07","mv_ch7","C",06,0,"G","NaoVazio()","","","","")
U_RGENA001(cPerg,"08","Até Loja?"   	  		,"mv_par08","mv_ch8","C",02,0,"G","NaoVazio()","","","","")
U_RGENA001(cPerg,"09","ATIVO?"   	  		    ,"mv_par09","mv_ch9","C",01,0,"C","","","",_cDef01,_cDef02)
	


RestArea(_sAlias)

Return
