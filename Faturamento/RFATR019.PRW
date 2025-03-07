#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CENT CHR(13) + CHR(10)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATR019  � Autor �J�lio Soares          � Data �  04/10/13 ���
�������������������������������������������������������������������������͹��
���Descricao � Relat�rio de rela��o de faturamento totalizado por produto,���
���          � por cliente, por vendedor, por estado e por emiss�o        ���
���          � conforme informa��es dos par�metros solicitados.           ���
���          � O nome do relat�rio no menu � "Posi��o Comercial (excel)".���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFATR019()

Local   _aSavArea  := GetArea()

Private _cRotina   := "RFATR019"
Private cPerg      := _cRotina
Private cDirDocs   := MsDocPath()
Private cNomeArq   := CriaTrab(,.F.)
Private _cExtArq   := GetDBExtension()
Private _cExtInd   := OrdBagExt()
Private _aTpOper   := {}

ValidPerg()
If !Pergunte(cPerg,.T.) .OR. Len(_aTpOper := aClone(U_SELMARQ())) == 0
	Return
EndIf
If !(SubStr(cAcesso,160,1) == "S" .AND. SubStr(cAcesso,168,1) == "S" .AND. SubStr(cAcesso,170,1) == "S")
	MsgStop('Usu�rio sem permiss�o para exportar dados para Excel, informe o Administrador!',_cRotina +"001")
	Return(Nil)
EndIf
If !ApOleClient('MsExcel')
	MsgStop('Excel n�o instalado!',_cRotina +"002")
	Return(Nil)
EndIf
Processa( {|lEnd| SelDados(@lEnd)},"Posi��o dos pedidos","Gerando dados em Excel. AGUARDE . .. ...",.F.)

RestArea(_aSavArea)

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SelDados  � Autor �J�lio Soares         � Data �  04/10/13 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o respons�vel pela sele��o dos dados a partir da      ���
���          �  consulta .                                                ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Programa principal                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function SelDados(lEnd)
Local oFWMsExcel
Local oExcel
Local cArquivo    := GetTempPath()+"RFATR019_"+DTOS(dDataBase)+".xml"

cAliasTop1       := GetNextAlias()

// -- �rea para constru��o da Query
_cQuery := " SELECT SC5.C5_EMISSAO AS EMISSAO,SC5.C5_NUM AS PEDIDO,SC5.C5_VEND1 AS VENDEDOR,SC5.C5_CLIENTE AS CLIENTE,SC5.C5_LOJACLI AS LOJA,SC5.C5_NOMCLI AS NOME " + CENT
// ---- VENDIDO --
_cQuery += " ,ISNULL((SELECT SUM(SC6V.C6_QTDVEN * SC6V.C6_PRCVEN) " + CENT
_cQuery += " 		FROM " + RetSqlName("SC6") + " SC6V " + CENT
_cQuery += " 		WHERE SC6V.D_E_L_E_T_ = '' " + CENT
_cQuery += " 		AND SC6V.C6_FILIAL    = '" + xFilial("SC6") + "' " + CENT
_cQuery += " 		AND SC6V.C6_NUM       = SC5.C5_NUM " + CENT
//_cQuery += " 		AND SC6V.C6_CLI       = SC5.C5_CLIENTE " + CENT
//_cQuery += " 		AND SC6V.C6_LOJA      = SC5.C5_LOJACLI " + CENT
//_cQuery += " 		AND SC6V.C6_EMISSAO   = SC5.C5_EMISSAO " + CENT
//_cQuery += " 		AND SC6V.C6_QTDENT    < SC6V.C6_QTDVEN " + CENT
//_cQuery += " 		GROUP BY SC6V.C6_EMISSAO,SC6V.C6_NUM,SC6V.C6_CLI,SC6V.C6_LOJA" + CENT
_cQuery += " 		),0) AS VENDIDO " + CENT
// ---- PENDENTE -- "
_cQuery += " ,ISNULL( (SELECT SUM((SC6P.C6_QTDVEN - SC6P.C6_QTDENT) * SC6P.C6_PRCVEN) " + CENT
_cQuery += " 		FROM " + RetSqlName("SC6") + " SC6P " + CENT
_cQuery += " 		WHERE SC6P.D_E_L_E_T_ = '' " + CENT
_cQuery += " 		AND SC6P.C6_FILIAL    = '" + xFilial("SC6") + "' " + CENT
_cQuery += " 		AND SC6P.C6_NUM       = SC5.C5_NUM " + CENT
//_cQuery += " 		AND SC6P.C6_CLI       = SC5.C5_CLIENTE " + CENT
//_cQuery += " 		AND SC6P.C6_LOJA      = SC5.C5_LOJACLI " + CENT
//_cQuery += " 		AND SC6P.C6_EMISSAO   = SC5.C5_EMISSAO " + CENT
//_cQuery += " 		AND SC6P.C6_QTDENT    < SC6P.C6_QTDVEN " + CENT
_cQuery += " 		AND SC6P.C6_BLQ      <> 'R' " + CENT
_cQuery += " 		AND SC6P.C6_QTDENT    = 0 " + CENT
//_cQuery += " 		GROUP BY SC6P.C6_EMISSAO,SC6P.C6_NUM,SC6P.C6_CLI,SC6P.C6_LOJA" + CENT
_cQuery += " 		),0) AS PENDENTE " + CENT
// ---- SALDO -- "
_cQuery += " ,ISNULL((SELECT SUM((SC6S.C6_QTDVEN - SC6S.C6_QTDENT) * SC6S.C6_PRCVEN) " + CENT
_cQuery += " 		FROM " + RetSqlName("SC6") + " SC6S " + CENT
_cQuery += " 		WHERE SC6S.D_E_L_E_T_ = '' " + CENT
_cQuery += " 		AND SC6S.C6_FILIAL    = '" + xFilial("SC6") + "' " + CENT
_cQuery += " 		AND SC6S.C6_NUM       = SC5.C5_NUM " + CENT
//_cQuery += " 		AND SC6S.C6_CLI       = SC5.C5_CLIENTE " + CENT
//_cQuery += " 		AND SC6S.C6_LOJA      = SC5.C5_LOJACLI " + CENT
//_cQuery += " 		AND SC6S.C6_EMISSAO   = SC5.C5_EMISSAO " + CENT
//_cQuery += " 		AND SC6S.C6_QTDENT    < SC6S.C6_QTDVEN " + CENT
_cQuery += " 		AND SC6S.C6_BLQ      <> 'R' " + CENT
_cQuery += " 		AND SC6S.C6_QTDENT    > 0 " + CENT
//_cQuery += " 		GROUP BY SC6S.C6_EMISSAO,SC6S.C6_NUM,SC6S.C6_CLI,SC6S.C6_LOJA" + CENT
_cQuery += " 		),0) AS SALDO " + CENT
// ---- FATURADO ---- "
_cQuery += " ,ISNULL((SELECT SUM(SC6F.C6_QTDENT * SC6F.C6_PRCVEN) " + CENT
_cQuery += " 		FROM " + RetSqlName("SC6") + " SC6F " + CENT
_cQuery += " 		WHERE SC6F.D_E_L_E_T_ = '' " + CENT
_cQuery += " 		AND SC6F.C6_FILIAL    = '" + xFilial("SC6") + "' " + CENT
_cQuery += " 		AND SC6F.C6_NUM       = SC5.C5_NUM " + CENT
//_cQuery += " 		AND SC6F.C6_CLI       = SC5.C5_CLIENTE " + CENT
//_cQuery += " 		AND SC6F.C6_LOJA      = SC5.C5_LOJACLI " + CENT
//_cQuery += " 		AND SC6F.C6_EMISSAO   = SC5.C5_EMISSAO " + CENT
//_cQuery += " 		AND SC6F.C6_QTDENT    < SC6F.C6_QTDVEN " + CENT
_cQuery += " 		AND SC6F.C6_QTDENT    > 0 " + CENT
//_cQuery += " 		GROUP BY SC6F.C6_EMISSAO,SC6F.C6_NUM,SC6F.C6_CLI,SC6F.C6_LOJA" + CENT
_cQuery += " 		),0) AS FATURADO " + CENT
// ---- RESIDUO ---- "
_cQuery += " ,ISNULL((SELECT SUM((C6_QTDVEN - C6_QTDENT)*C6_PRCVEN) " + CENT
_cQuery += " 		FROM " + RetSqlName("SC6") + " SC6R " + CENT
_cQuery += " 		WHERE SC6R.D_E_L_E_T_ = '' " + CENT
_cQuery += " 		AND SC6R.C6_FILIAL    = '" + xFilial("SC6") + "' " + CENT
_cQuery += " 		AND SC6R.C6_NUM       = SC5.C5_NUM " + CENT
//_cQuery += " 		AND SC6R.C6_CLI       = SC5.C5_CLIENTE " + CENT
//_cQuery += " 		AND SC6R.C6_LOJA      = SC5.C5_LOJACLI " + CENT
//_cQuery += " 		AND SC6R.C6_EMISSAO   = SC5.C5_EMISSAO " + CENT
_cQuery += " 		AND SC6R.C6_BLQ       = 'R' " + CENT
//_cQuery += " 		AND SC6R.C6_QTDENT    < SC6R.C6_QTDVEN " + CENT
//_cQuery += " 		GROUP BY SC6R.C6_EMISSAO,SC6R.C6_NUM,SC6R.C6_CLI,SC6R.C6_LOJA" + CENT
_cQuery += " 		),0) AS CANCELADO " + CENT
_cQuery += " FROM " + RetSqlName("SC5") + " SC5 " + CENT
/*
_cQuery += " 	INNER JOIN " + RetSqlName("SC6") + " SC6 ON SC6.D_E_L_E_T_ = '' " + CENT
_cQuery += " 		AND SC5.C5_FILIAL  = SC6.C6_FILIAL " + CENT
_cQuery += " 		AND SC5.C5_CLIENTE = SC6.C6_CLI " + CENT
_cQuery += " 		AND SC5.C5_LOJACLI = SC6.C6_LOJA " + CENT
_cQuery += " 		AND SC5.C5_EMISSAO = SC6.C6_EMISSAO " + CENT
*/
_cQuery += " WHERE SC5.D_E_L_E_T_ = '' " + CENT
_cQuery += "   AND SC5.C5_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' " + CENT
_cQuery += "   AND SC5.C5_VEND1   BETWEEN '" + (MV_PAR03)     + "' AND '" + (MV_PAR04)     + "' " + CENT
_cQuery += "   AND SC5.C5_CLIENTE BETWEEN '" + (MV_PAR05)     + "' AND '" + (MV_PAR07)     + "' " + CENT
_cQuery += "   AND SC5.C5_LOJACLI BETWEEN '" + (MV_PAR06)     + "' AND '" + (MV_PAR08)     + "' " + CENT
_cQuery += "   AND SC5.C5_CGCCENT BETWEEN '" + (MV_PAR09)     + "' AND '" + (MV_PAR10)     + "' " + CENT
_cQuery += "   AND (SC5.C5_TIPO = 'N' OR SC5.C5_TIPO = 'P') " + CENT
_cQuery += "   AND SC5.C5_TPOPER IN ('"
For _x := 1 To Len(_aTpOper)
	If _x > 1
		_cQuery += "','"
	EndIf
	_cQuery += _aTpOper[_x]
Next
_cQuery += "')" + CENT
_cQuery += " GROUP BY SC5.C5_EMISSAO,SC5.C5_NUM,SC5.C5_VEND1,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC5.C5_NOMCLI " + CENT
_cQuery += " ORDER BY SC5.C5_EMISSAO,SC5.C5_NUM "

/*
If __cUserId == "000000"
	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",_cQuery)
EndIf
*/
If TCSQLExec(_cQuery) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_003")
	Return(Nil)
EndIf	
//  FIM DA QUERY PARA FORMA��O DA TABELA TEMPORARIA   //

TCQUERY _cQuery NEW ALIAS "TMPSB1"
TCSetField('TMPSB1','EMISSAO','D')

IF TMPSB1->(!EOF())
    //Criando o objeto que ir� gerar o conte�do do Excel
    oFWMsExcel := FWMSExcel():New()
     
    //Aba 01
    oFWMsExcel:AddworkSheet("RELACAO FATURAMENTO")

        //Criando a Tabela
        oFWMsExcel:AddTable("RELACAO FATURAMENTO","FATURAMENTO")
        oFWMsExcel:AddColumn("RELACAO FATURAMENTO","FATURAMENTO","EMISSAO",1)
        oFWMsExcel:AddColumn("RELACAO FATURAMENTO","FATURAMENTO","PEDIDO",1)

		// Altera��o - Fernando Bombardi - ALLSS - 02/03/2022
        //oFWMsExcel:AddColumn("RELACAO FATURAMENTO","FATURAMENTO","VENDEDOR",1)
        oFWMsExcel:AddColumn("RELACAO FATURAMENTO","FATURAMENTO","REPRESENTANTE",1)
		// Fim - Fernando Bombardi - ALLSS - 02/03/2022

        oFWMsExcel:AddColumn("RELACAO FATURAMENTO","FATURAMENTO","CLIENTE",1)        
        oFWMsExcel:AddColumn("RELACAO FATURAMENTO","FATURAMENTO","LOJA",1)
        oFWMsExcel:AddColumn("RELACAO FATURAMENTO","FATURAMENTO","NOME",1)
        oFWMsExcel:AddColumn("RELACAO FATURAMENTO","FATURAMENTO","VENDIDO",1)
        oFWMsExcel:AddColumn("RELACAO FATURAMENTO","FATURAMENTO","PENDENTE",1)
        oFWMsExcel:AddColumn("RELACAO FATURAMENTO","FATURAMENTO","SALDO",1)
        oFWMsExcel:AddColumn("RELACAO FATURAMENTO","FATURAMENTO","FATURADO",1)
        oFWMsExcel:AddColumn("RELACAO FATURAMENTO","FATURAMENTO","CANCELADO",1)
              
        //Criando as Linhas... Enquanto n�o for fim da query
        WHILE TMPSB1->(!EOF())
            oFWMsExcel:AddRow("RELACAO FATURAMENTO","FATURAMENTO",{;
					TMPSB1->EMISSAO    ,;
					TMPSB1->PEDIDO     ,;
					TMPSB1->VENDEDOR   ,;
					TMPSB1->CLIENTE    ,;
					TMPSB1->LOJA       ,;
					TMPSB1->NOME       ,;
					TMPSB1->VENDIDO    ,;
					TMPSB1->PENDENTE   ,;
					TMPSB1->SALDO      ,;
					TMPSB1->FATURADO   ,;
					TMPSB1->CANCELADO;
            })
            TMPSB1->(dbSkip())
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
TMPSB1->(dbCloseArea())

/*
EXPEXCEL("TMPSB1")
If Select("TMPSB1") > 0
   TMPSB1->(DBCLOSEAREA())
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
���Programa  �EXPEXCEL  � Autor �J�lio Soares          � Data �  04/10/13 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o respons�vel por exportar retorno de consultas(query)���
���          � diretamente para Excel.                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Programa principal                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function EXPEXCEL(_cAREA)

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

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValidPerg � Autor �J�lio Soares          � Data �  04/10/13 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o respons�vel pela inclus�o de par�metros na rotina.  ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ValidPerg()

Local _x
Local _y
Local _cAlias := GetArea()
Local aRegs   := {}

cPerg         := PADR(cPerg,10)

AADD(aRegs,{cPerg,"01","De Data?"         ,"","","mv_ch1","D",08,0,0,"G","NaoVazio()","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{cPerg,"02","At� Data?"        ,"","","mv_ch2","D",08,0,0,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","","",""})

// Altera��o - Fernando Bombardi - ALLSS - 02/03/2022
//AADD(aRegs,{cPerg,"03","De Vendedor?"     ,"","","mv_ch3","C",06,0,0,"G",""          ,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA3","","","",""})
//AADD(aRegs,{cPerg,"04","At� Vendedor?"    ,"","","mv_ch4","C",06,0,0,"G","NaoVazio()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SA3","","","",""})

AADD(aRegs,{cPerg,"03","De Representante?"     ,"","","mv_ch3","C",06,0,0,"G",""          ,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA3","","","",""})
AADD(aRegs,{cPerg,"04","At� Representante?"    ,"","","mv_ch4","C",06,0,0,"G","NaoVazio()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SA3","","","",""})
// Fim - Fernando Bombardi - ALLSS - 02/03/2022

AADD(aRegs,{cPerg,"05","De Cliente?"      ,"","","mv_ch5","C",06,0,0,"G",""          ,"mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","",""})
AADD(aRegs,{cPerg,"06","De Loja?"         ,"","","mv_ch6","C",02,0,0,"G",""          ,"mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{cPerg,"07","At� Cliente?"     ,"","","mv_ch7","C",06,0,0,"G","NaoVazio()","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","",""})
AADD(aRegs,{cPerg,"08","At� Loja?"        ,"","","mv_ch8","C",02,0,0,"G","NaoVazio()","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{cPerg,"09","Do CNPJ Central?" ,"","","mv_ch9","C",14,0,0,"G",""			 ,"mv_par09","","","","","","","","","","","","","","","","","","","","","","","","",""	  ,"","","",""})
AADD(aRegs,{cPerg,"10","Ao CNPJ Central?" ,"","","mv_ch10","C",14,0,0,"G","NaoVazio()","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","",""  ,"","","",""})

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
		MsUnlock()
	EndIf
Next

RestArea(_cAlias)

Return()
