#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RFISR003 บAutor  ณ Microsiga          บ Data ณ  07/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico empresa ARCOLOR                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFISR003  บAutor  ณMicrosiga           บ Data ณ  08/07/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFISR003  บAutor  ณMicrosiga           บ Data ณ  08/07/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
aAdd( aHelpPor, "movimenta็๕es.                       " )
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
_cHelp    := "Informe a data inicial para gerar as movimenta็๕es." 
U_RGENA001(_cPerg, "01" ,"Da Data?" , "MV_PAR01", "mv_ch1", "D", 8, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

/* FB - RELEASE 12.1.23
aHelpPor :={} 
aHelpIng :={} 
aHelpEsp :={} 
aAdd( aHelpPor, "Informe a data final para gerar as " )
aAdd( aHelpPor, "movimenta็๕es.            			" )
aHelpIng := aHelpEsp := aHelpPor
cStringP := "At้ a Data"
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
_cHelp    := "Informe a data final para gerar as movimenta็๕es." 
U_RGENA001(_cPerg, "02" ,"At้ a Data?" , "MV_PAR02", "mv_ch2", "D", 8, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

/* FB - RELEASE 12.1.23
aHelpPor :={}           
aHelpIng :={} 
aHelpEsp :={} 
aAdd( aHelpPor, "Informe a opera็ใo para gerar as ")
aAdd( aHelpPor, "movimenta็๕es." )
aHelpIng := aHelpEsp := aHelpPor
cStringP := "Opera็ใo"
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
_cHelp    := "Informe a data final para gerar as movimenta็๕es." 
U_RGENA001(_cPerg, "03" ,"Opera็ใo?" , "MV_PAR03", "mv_ch3", "C", 1, 0, "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

Return()

//PutSX1 - Cria็ใo de pergunta no arquivo SX1 (<cGrupo>,<cOrdem>,<cPergunt>,<cPergSpa>,<cPergEng>,<cVar>,<cTipo>,<nTamanho>,[nDecimal],[nPreSel],<cGSC>,[cValid],[cF3],[cGrpSXG],[cPyme],<cVar01>,[cDef01],[cDefSpa1],[cDefEng1],[cCnt01],[cDef02],[cDefSpa2],[cDefEng2],[cDef03],[cDefSpa3],[cDefEng3],[cDef04],[cDefSpa4],[cDefEng4],[cDef05],[cDefSpa5],[cDefEng5],[aHelpPor],[aHelpEng],[aHelpSpa],[cHelp]) --> Nil
/*
cGrupo		Caracter	Nome do grupo de pergunta X	
cOrdem		Caracter	Ordem de apresenta็ใo das perguntas na tela	X	
cPergunt	Caracter	Texto da pergunta a ser apresentado na tela	X	
cPergSpa	Caracter	Texto em espanhol da pergunta a ser apresentado na tela.	X	
cPergEng	Caracter	Texto em ingl๊s da pergunta a ser apresentado na tela.	X	
cVar		Caracter	Variแvel do item	X	
cTipo		Caracter	Tipo do conte๚do de resposta da pergunta.	X	
nTamanho	Num้rico	Tamanho do campo para resposta	X	
nDecimal	Num้rico	N๚mero de casas decimais da resposta, se houver		
nPreSel		Num้rico	Valor que define qual o item do combo estarแ selecionado na apresenta็ใo da tela. Este parโmetro somente deverแ ser preenchido quando o parโmetro cGSC for preenchido com "C".		
cGSC		Caracter	Estilo de apresenta็ใo da pergunta na tela: - "G" - formato que permite editar o conte๚do da pergunta. - "S" - formato de texto que nใo permite altera็ใo. - "C" - formato que permite a sele็ใo de dados para a pergunta.	X	
cValid		Caracter	Valida็ใo do item de pergunta		
cF3			Caracter	Nome da consulta F3 que poderแ ser acionada pela pergunta.		
cGrpSXG		Caracter	C๓digo do grupo de campos relacionado a pergunta.		
cPyme		Caracter	Define se a pergunta poderแ ser apresentada em aplica็๕es do tipo Express.		
cVar01		Caracter	Nome do MV_PAR para a utiliza็ใo nos programas.	X	
cDef01		Caracter	Conte๚do em portugu๊s do primeiro item do objeto, caso seja do tipo Combo.		
cDefSpa1	Caracter	Conte๚do em espanhol do primeiro item do objeto, caso seja do tipo Combo.		
cDefEng1	Caracter	Conte๚do em ingl๊s do primeiro item do objeto, caso seja do tipo Combo.		
cCnt01		Caracter	Conte๚do padrใo da pergunta.		
cDef02		Caracter	Conte๚do em portugu๊s do segundo item do objeto, caso seja do tipo Combo.		
cDefSpa2	Caracter	Conte๚do em espanhol do segundo item do objeto, caso seja do tipo Combo.		
cDefEng2	Caracter	Conte๚do em ingl๊s do segundo item do objeto, caso seja do tipo Combo.		
cDef03		Caracter	Conte๚do em portugu๊s do terceiro item do objeto, caso seja do tipo Combo.		
cDefSpa3	Caracter	Conte๚do em espanhol do terceiro item do objeto, caso seja do tipo Combo.		
cDefEng3	Caracter	Conte๚do em ingl๊s do terceiro item do objeto, caso seja do tipo Combo.		
cDef04		Caracter	Conte๚do em portugu๊s do quarto item do objeto, caso seja do tipo Combo.		
cDefSpa4	Caracter	Conte๚do em espanhol do quarto item do objeto, caso seja do tipo Combo.		
cDefEng4	Caracter	Conte๚do em ingl๊s do quarto item do objeto, caso seja do tipo Combo.		
cDef05		Caracter	Conte๚do em portugu๊s do quinto item do objeto, caso seja do tipo Combo.		
cDefSpa5	Caracter	Conte๚do em espanhol do quinto item do objeto, caso seja do tipo Combo.		
cDefEng5	Caracter	Conte๚do em ingl๊s do quinto item do objeto, caso seja do tipo Combo.		
aHelpPor	Vetor		Help descritivo da pergunta em Portugu๊s.		
aHelpEng	Vetor		Help descritivo da pergunta em Ingl๊s.		
aHelpSpa	Vetor		Help descritivo da pergunta em Espanhol.		
cHelp		Caracter	Nome do help equivalente, caso jแ exista um no sistema.	
*/
Return()