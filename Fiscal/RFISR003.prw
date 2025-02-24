#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFISR003 �Autor  � Microsiga          � Data �  07/08/15   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa ARCOLOR                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFISR003()

Local _cQry := ""

// - Consulta


_cQry += " SELECT D2_EMISSAO,D2_DOC,D2_SERIE,D2_PEDIDO,D2_COD,FT_PRODUTO,FT_ORGPRD,D2_ITEMPV,D2_ITEM,FT_ITEM "
_cQry += " FROM SD2010 SD2 "
_cQry += " 	INNER JOIN "
_cQry += " 		(SELECT C5_NUM,C6_PRODUTO,C6_ITEM "
_cQry += " 		 FROM SC5010 SC5 "
_cQry += " 			INNER JOIN SC6010 SC6 "
_cQry += " 			ON SC6.D_E_L_E_T_ = '' "
_cQry += " 				--AND SC6.C6_FILIAL = '' "
_cQry += " 		   		AND SC6.C6_NUM    = SC5.C5_NUM "
_cQry += " 				AND SC6.C6_TPCALC = 'V' "
_cQry += " 		WHERE SC5.D_E_L_E_T_ = '' "
_cQry += " 		--AND SC5.C5_FILIAL    = '' "
_cQry += " 		AND (SC5.C5_TPDIV = '1' OR SC5.C5_TPDIV = '2' OR SC5.C5_TPDIV = '3') "
_cQry += " 		)SC5X "
_cQry += " 		ON SC5X.C5_NUM = SD2.D2_PEDIDO "
_cQry += " 		AND SC5X.C6_PRODUTO = SD2.D2_COD "
_cQry += " 		AND SC5X.C6_ITEM    = SD2.D2_ITEMPV "
_cQry += " 	LEFT JOIN SFT010 SFT "
_cQry += " 		ON SFT.D_E_L_E_T_ = '' "
_cQry += " 		--AND SFT.FT_FILIAL = '' "
_cQry += " 		AND SFT.FT_NFISCAL = SD2.D2_DOC "
_cQry += " 		AND SFT.FT_SERIE   = SD2.D2_SERIE "
_cQry += " 		AND SFT.FT_ITEM    = SD2.D2_ITEM "
_cQry += " WHERE SD2.D_E_L_E_T_ = '' "
_cQry += " AND SD2.D2_COD = FT_PRODUTO "
_cQry += " --AND SD2.D2_EMISSAO BETWEEN '20150101' AND '20150110' "
_cQry += " AND SD2.D2_DOC BETWEEN '000085166' AND '000085166' "
_cQry += " AND SD2.D2_SERIE BETWEEN '1' AND '1' "
_cQry += " ORDER BY SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_ITEM "
//CONOUT("Consulta finalizada") // grava mensagem de log

Return()


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFISR003  �Autor  �Microsiga           � Data �  08/07/15   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function GetXML(cIdEnt,aIdNFe,cModalidade)  

Local aRetorno		:= {}
Local aDados		:= {}
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
Local cModel		:= "55"
Local nZ			:= 0
Local nCount		:= 0
Local oWS

If Empty(cModalidade)    
	oWS := WsSpedCfgNFe():New()

	oWS:cUSERTOKEN  := "TOTVS"
	oWS:cID_ENT     := cIdEnt
	oWS:nModalidade := 0
	oWS:_URL        := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	oWS:cModelo     := cModel 
	If oWS:CFGModalidade()
		cModalidade    := SubStr(oWS:cCfgModalidadeResult,1,1)
	Else
		cModalidade    := ""
	EndIf  
EndIf  

oWs := Nil

For nZ := 1 To len(aIdNfe) 
    nCount++
	aDados := executeRetorna( aIdNfe[nZ], cIdEnt )
	If ( nCount == 10 )
		delClassIntF()
		nCount := 0
	Endif
	aAdd(aRetorno,aDados)
Next nZ

Return(aRetorno)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFISR003  �Autor  �Microsiga           � Data �  08/07/15   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function AjustaSX1()

#include "protheus.ch"
User Function FPutSx1()
Local aHelpPor 	:= {}
Local aHelpEsp 	:= {}              
Local aHelpIng 	:= {}
Local cPerg		:= "TESTX1"
Local cStringP   := ""  // texto em portugues
Local cStringE   := ""	// texto em espanhol
Local cStringI   := ""  // texto em ingles

//Prepare Environment Empresa "01" Filial "01" Modulo "FAT"// incluindo Pergunta do tipo Data
/* FB - RELEASE 12.1.23
aAdd( aHelpPor, "Informe a data inicial para gerar as " )
aAdd( aHelpPor, "movimenta��es.                       " )
aHelpIng := aHelpEsp := aHelpPor
cStringP := "Da Data"
cStringE := cStringP + " - ESP"
cStringI := cStringP + " - ING"
PutSx1(cPerg,"01",cStringP,cStringE,cStringI,;
		"mv_ch1","D",8,;
		0,0,"G",;
		"","","",;
		"","mv_par01","",;
		"","","",;
		"","","",;
		"","","",;
		"","","",;
		"","","",;
		aHelpPor,aHelpIng,aHelpEsp)
*/
_cPerg    := cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := ""
_cDef02   := ""
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Informe a data inicial para gerar as movimenta��es." 
U_RGENA001(_cPerg, "01" ,"Da Data?" , "MV_PAR01", "mv_ch1", "D", 8, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

/* FB - RELEASE 12.1.23
aHelpPor :={} 
aHelpIng :={} 
aHelpEsp :={} 
aAdd( aHelpPor, "Informe a data final para gerar as " )
aAdd( aHelpPor, "movimenta��es.            			" )
aHelpIng := aHelpEsp := aHelpPor
cStringP := "At� a Data"
cStringE := cStringP + " - ESP"
cStringI := cStringP + " - ING"
PutSx1(cPerg,"02",cStringP,cStringE,cStringI,;
		"mv_ch2","D",8,;
		0,0,"G",;
		"","","",;
		"","mv_par02","",;
		"","","",;
		"","","",;
		"","","",;
		"","","",;
		"","","",;
		aHelpPor,aHelpIng,aHelpEsp)// incluindo pergunta do tipo combo
*/
_cPerg    := cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := ""
_cDef02   := ""
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Informe a data final para gerar as movimenta��es." 
U_RGENA001(_cPerg, "02" ,"At� a Data?" , "MV_PAR02", "mv_ch2", "D", 8, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

/* FB - RELEASE 12.1.23
aHelpPor :={}           
aHelpIng :={} 
aHelpEsp :={} 
aAdd( aHelpPor, "Informe a opera��o para gerar as ")
aAdd( aHelpPor, "movimenta��es." )
aHelpIng := aHelpEsp := aHelpPor
cStringP := "Opera��o"
cStringE := cStringP + " - ESP"
cStringI := cStringP + " - ING"
PutSx1(cPerg,"03",cStringP,cStringE,cStringI,;
		"mv_ch3","C",1,;
		0,0,"C",;
		"","","",;
		"","mv_par03","Todas",;
		"Todas","Todas","1",;
		"Inserido","Inserido","Inserido",;
		"Alterado","Alterado","Alterado",;
		"Apagado","Apagado","Apagado",;
		"","","",;
		aHelpPor,aHelpIng,aHelpEsp)
*/
_cPerg    := cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := "Todas"
_cDef02   := "Inserido"
_cDef03   := "Alterado"
_cDef04   := "Apagado"
_cDef05   := ""
_cHelp    := "Informe a data final para gerar as movimenta��es." 
U_RGENA001(_cPerg, "03" ,"Opera��o?" , "MV_PAR03", "mv_ch3", "C", 1, 0, "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

Return()

//PutSX1 - Cria��o de pergunta no arquivo SX1 (<cGrupo>,<cOrdem>,<cPergunt>,<cPergSpa>,<cPergEng>,<cVar>,<cTipo>,<nTamanho>,[nDecimal],[nPreSel],<cGSC>,[cValid],[cF3],[cGrpSXG],[cPyme],<cVar01>,[cDef01],[cDefSpa1],[cDefEng1],[cCnt01],[cDef02],[cDefSpa2],[cDefEng2],[cDef03],[cDefSpa3],[cDefEng3],[cDef04],[cDefSpa4],[cDefEng4],[cDef05],[cDefSpa5],[cDefEng5],[aHelpPor],[aHelpEng],[aHelpSpa],[cHelp]) --> Nil
/*
cGrupo		Caracter	Nome do grupo de pergunta X	
cOrdem		Caracter	Ordem de apresenta��o das perguntas na tela	X	
cPergunt	Caracter	Texto da pergunta a ser apresentado na tela	X	
cPergSpa	Caracter	Texto em espanhol da pergunta a ser apresentado na tela.	X	
cPergEng	Caracter	Texto em ingl�s da pergunta a ser apresentado na tela.	X	
cVar		Caracter	Vari�vel do item	X	
cTipo		Caracter	Tipo do conte�do de resposta da pergunta.	X	
nTamanho	Num�rico	Tamanho do campo para resposta	X	
nDecimal	Num�rico	N�mero de casas decimais da resposta, se houver		
nPreSel		Num�rico	Valor que define qual o item do combo estar� selecionado na apresenta��o da tela. Este par�metro somente dever� ser preenchido quando o par�metro cGSC for preenchido com "C".		
cGSC		Caracter	Estilo de apresenta��o da pergunta na tela: - "G" - formato que permite editar o conte�do da pergunta. - "S" - formato de texto que n�o permite altera��o. - "C" - formato que permite a sele��o de dados para a pergunta.	X	
cValid		Caracter	Valida��o do item de pergunta		
cF3			Caracter	Nome da consulta F3 que poder� ser acionada pela pergunta.		
cGrpSXG		Caracter	C�digo do grupo de campos relacionado a pergunta.		
cPyme		Caracter	Define se a pergunta poder� ser apresentada em aplica��es do tipo Express.		
cVar01		Caracter	Nome do MV_PAR para a utiliza��o nos programas.	X	
cDef01		Caracter	Conte�do em portugu�s do primeiro item do objeto, caso seja do tipo Combo.		
cDefSpa1	Caracter	Conte�do em espanhol do primeiro item do objeto, caso seja do tipo Combo.		
cDefEng1	Caracter	Conte�do em ingl�s do primeiro item do objeto, caso seja do tipo Combo.		
cCnt01		Caracter	Conte�do padr�o da pergunta.		
cDef02		Caracter	Conte�do em portugu�s do segundo item do objeto, caso seja do tipo Combo.		
cDefSpa2	Caracter	Conte�do em espanhol do segundo item do objeto, caso seja do tipo Combo.		
cDefEng2	Caracter	Conte�do em ingl�s do segundo item do objeto, caso seja do tipo Combo.		
cDef03		Caracter	Conte�do em portugu�s do terceiro item do objeto, caso seja do tipo Combo.		
cDefSpa3	Caracter	Conte�do em espanhol do terceiro item do objeto, caso seja do tipo Combo.		
cDefEng3	Caracter	Conte�do em ingl�s do terceiro item do objeto, caso seja do tipo Combo.		
cDef04		Caracter	Conte�do em portugu�s do quarto item do objeto, caso seja do tipo Combo.		
cDefSpa4	Caracter	Conte�do em espanhol do quarto item do objeto, caso seja do tipo Combo.		
cDefEng4	Caracter	Conte�do em ingl�s do quarto item do objeto, caso seja do tipo Combo.		
cDef05		Caracter	Conte�do em portugu�s do quinto item do objeto, caso seja do tipo Combo.		
cDefSpa5	Caracter	Conte�do em espanhol do quinto item do objeto, caso seja do tipo Combo.		
cDefEng5	Caracter	Conte�do em ingl�s do quinto item do objeto, caso seja do tipo Combo.		
aHelpPor	Vetor		Help descritivo da pergunta em Portugu�s.		
aHelpEng	Vetor		Help descritivo da pergunta em Ingl�s.		
aHelpSpa	Vetor		Help descritivo da pergunta em Espanhol.		
cHelp		Caracter	Nome do help equivalente, caso j� exista um no sistema.	
*/
Return()