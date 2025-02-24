#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TOPCONN.ch"
#INCLUDE "FWPrintSetup.ch"

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  Ё ImpXML   ╨ Autor ЁMilton J.dos Santos ╨ Data Ё  01/04/2014 ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Geracao da DANFE a partir de um XML qualquer               ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
User Function ALLR001(cTipo,cArquivo,cPathFile)

Private oDanfe
Private nConsNeg := 0.4
Private nConsTex := 0.5

lNF:=.F.
If ALLTRIM(cTipo)=="NF"
	lNF:=.T.
Endif

If !lNf
	Msgbox("Este XML nЦo corresponde a uma Nota Fiscal de Entrada!")
	Return
Endif

nFolha:=1
nTotit:=0

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Criacao de tabelas temporarias										Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aCampos:= {{"VENCTO","D",8,0 },;
           {"VALOR","N",18,2 }}

cArqTrab2  := CriaTrab(aCampos)
dbUseArea( .T.,, cArqTrab2, "COBR", if(.F. .OR. .F., !.F., NIL), .F. )
IndRegua("COBR",cArqTrab2,"VENCTO",,,)
dbSetIndex( cArqTrab2 +OrdBagExt())
dbSelectArea("COBR")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁInicializacao do objeto grafico                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If oDanfe == Nil
	lPreview := .T.
	oDanfe   := FWMSPrinter():New(cArquivo,6,.F.,,.T.)
	oDanfe:SetResolution(78)
	oDanfe:SetPortrait()
	oDanfe:SetPaperSize(DMPAPER_A4)
	oDanfe:SetMargin(60,60,60,60)
	oDanfe:SetViewPDF(.T.)
EndIf

Private PixelX := oDanfe:nLogPixelX()
Private PixelY := oDanfe:nLogPixelY()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFontes Utilizadas													   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oFont10N   := TFontEx():New(oDanfe,"Times New Roman",08,08,.T.,.T.,.F.)// 1
oFont07    := TFontEx():New(oDanfe,"Times New Roman",06,06,.F.,.T.,.F.)// 3
oFont08    := TFontEx():New(oDanfe,"Times New Roman",07,07,.F.,.T.,.F.)// 4
oFont08N   := TFontEx():New(oDanfe,"Times New Roman",06,06,.T.,.T.,.F.)// 5
oFont18N   := TFontEx():New(oDanfe,"Arial Black",18,18,.T.,.T.,.F.)// 12
OFONT12N   := TFontEx():New(oDanfe,"Times New Roman",11,11,.T.,.T.,.F.)// 12

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVariaveis															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
_cSerie:=_cMensag:=_cEmpresa:=_cEndEmp:=_cBairEmp:=_cCEPEmp:=_cCidEmp:=_cTelEmp:=_cInscr:=_cInscrST:=_cCNPJ:=_cNFiscal:=_cChave:=_cNatureza:=""
_dEmissao:=_cDestinatario:=_cCNPJ2:=_cEndereco:=_cBairro:=_cCEP:=_cCidade:=_cUF:=_cTelefone:=_cInscr2:=_dEmissao:=""
_nBaseICM:=_nVlrICM:=_nBaseST:=_nVlrST:=_nTotal:=_nFrete:=_nSeguro:=_nDesconto:=_nOutras:=_nIPI:=_nTotNF:=0
_cTransp:=_cCodATT:=_cPlaca:=_cUFTra:=_cCNPJTra:=_cEndTra:=_cCidTra:=_cInscrTra:=""
_nQuant:=_nPesoB:=_nPesoL:=0
_nFaturas:=0

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁLeitura do arquivo xml												   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DANFEXML(cArquivo,cPathFile)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁCalculos de folhas													   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nCalcFol:=(nTotit/22)

If nCalcFol<=1;nTotFol:=1;Endif
If nCalcFol>1 .AND. nCalcFol<=2;nTotFol:=2;Endif
If nCalcFol>2 .AND. nCalcFol<=3;nTotFol:=3;Endif
If nCalcFol>3 .AND. nCalcFol<=4;nTotFol:=4;Endif
If nCalcFol>4 .AND. nCalcFol<=5;nTotFol:=5;Endif
If nCalcFol>5 .AND. nCalcFol<=6;nTotFol:=6;Endif
If nCalcFol>6 .AND. nCalcFol<=7;nTotFol:=7;Endif
If nCalcFol>7 .AND. nCalcFol<=8;nTotFol:=8;Endif
If nCalcFol>8 .AND. nCalcFol<=9;nTotFol:=9;Endif
If nCalcFol>9 .AND. nCalcFol<=10;nTotFol:=10;Endif
If nCalcFol>10 .AND. nCalcFol<=11;nTotFol:=11;Endif
If nCalcFol>11 .AND. nCalcFol<=12;nTotFol:=12;Endif
If nCalcFol>12 .AND. nCalcFol<=13;nTotFol:=13;Endif

For w:=1 to nTotFol
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁInicio da Pagina														   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oDanfe:StartPage()
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁCabecalho da DANFE													   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oDanfe:Box(000,000,010,501)
	oDanfe:Say(006, 002, "RECEBEMOS DE "+_cEmpresa+" OS PRODUTOS CONSTANTES NA NOTA FISCAL AO LADO", oFont08:oFont)
	oDanfe:Box(009,000,037,101)
	oDanfe:Say(017, 002, "DATA DE RECEBIMENTO", oFont08:oFont)
	oDanfe:Box(009,100,037,500)
	oDanfe:Say(017, 102, "IDENTIFICAгцO E ASSINATURA DO RECEBEDOR", oFont08:oFont)
	oDanfe:Box(000,500,037,603)
	oDanfe:Say(007, 542, "NF-e", oFont08:oFont)
	oDanfe:Say(017, 510, "N. "+_cNFiscal, oFont08:oFont)
	oDanfe:Say(027, 510, "SиRIE "+_cSerie, oFont08:oFont)
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁIdentificacao do Emitente											   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oDanfe:Box(042,000,137,250)
	oDanfe:Say(052,098, "IdentificaГЦo do Emitente",oFont12N:oFont)
	oDanfe:Say(065,098,_cEmpresa,oFont12N:oFont )
	oDanfe:Say(075,098,_cEndEmp,oFont08N:oFont)
	oDanfe:Say(085,098,_cBairEmp,oFont08N:oFont)
	oDanfe:Say(095,098,transform(_cCepEmp,"@r 99.999-999"),oFont08N:oFont)
	oDanfe:Say(105,098,_cCidEmp,oFont08N:oFont)
	oDanfe:Say(115,098,_cTelEmp,oFont08N:oFont)
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁQuadro 1                                                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oDanfe:Box(042,248,137,351)
	oDanfe:Say(055,275, "DANFE",oFont18N:oFont)
	oDanfe:Say(065,258, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
	oDanfe:Say(075,258, "NOTA FISCAL ELETRтNICA",oFont07:oFont)
	oDanfe:Say(085,266, "0-ENTRADA",oFont08:oFont)
	oDanfe:Say(095,266, "1-SAмDA"  ,oFont08:oFont)
	oDanfe:Box(078,315,095,325)
	oDanfe:Say(089,318, "0",oFont08N:oFont)
	oDanfe:Say(110,255,"N. "+_cNFiscal,oFont10N:oFont)
	oDanfe:Say(120,255,"SиRIE "+_cSerie,oFont10N:oFont)
	oDanfe:Say(130,255,"FOLHA "+strzero(w,2)+"/"+strzero(nTotFol,2),oFont10N:oFont)
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁCodigo de Barras														   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oDanfe:Box(042,350,088,603)
	oDanfe:Box(075,350,110,603)
	oDanfe:Say(095,355,TransForm(_cChave,"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont12N:oFont)
	oDanfe:Box(105,350,137,603)
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁChave de Acesso														   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oDanfe:Say(085,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
	nFontSize := 28
	oDanfe:Code128C(072,370,_cChave, nFontSize )

	oDanfe:Say(117,355,"Consulta de autenticidade no portal nacional da NF-e",oFont10N:oFont)
	oDanfe:Say(127,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont08N:oFont)

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁEmitente																   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oDanfe:Box(139,000,162,603)
	oDanfe:Box(139,000,162,350)
	oDanfe:Say(148,002,"NATUREZA DA OPERAгцO",oFont08N:oFont)
	oDanfe:Say(148,352,"PROTOCOLO DE AUTORIZAгцO DE USO",oFont08N:oFont)	
	oDanfe:Say(158,002,_cNatureza,oFont08:oFont)
	
	
	oDanfe:Box(164,000,187,603)
	oDanfe:Box(164,000,187,200)
	oDanfe:Box(164,200,187,400)
	oDanfe:Box(164,400,187,603)
	oDanfe:Say(172,002,"INSCRIгцO ESTADUAL",oFont08N:oFont)
	oDanfe:Say(180,002,_cInscr,oFont08:oFont)
	oDanfe:Say(172,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
	oDanfe:Say(180,205,_cInscrST,oFont08:oFont)
	oDanfe:Say(172,405,"CNPJ",oFont08N:oFont)
	
	If Len(ALLTRIM(_cCNPJ))==14
		oDanfe:Say(180,405,Transform(_cCNPJ,"@r 99.999.999/9999-99"),oFont08:oFont)
	Else
		oDanfe:Say(180,405,Transform(_cCNPJ,"@r 999.999.999-99"),oFont08:oFont)
	Endif
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁDestinatario															   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oDanfe:Say(195,002,"DESTINATARIO/REMETENTE",oFont08N:oFont)
	oDanfe:Box(197,000,217,450)
	oDanfe:Say(205,002, "NOME/RAZцO SOCIAL",oFont08N:oFont)
	oDanfe:Say(215,002,_cDestinatario,oFont08:oFont)
	oDanfe:Box(197,280,217,500)
	oDanfe:Say(205,283,"CNPJ/CPF",oFont08N:oFont)
	
	If Len(ALLTRIM(_cCNPJ2))==14
		oDanfe:Say(215,283,Transform(_cCNPJ2,"@r 99.999.999/9999-99"),oFont08:oFont)
	Else
		oDanfe:Say(215,283,Transform(_cCNPJ2,"@r 999.999.999-99"),oFont08:oFont)
	Endif
	
	oDanfe:Box(217,000,237,500)
	oDanfe:Box(217,000,237,260)
	oDanfe:Say(224,002,"ENDEREгO",oFont08N:oFont)
	oDanfe:Say(234,002,_cEndereco,oFont08:oFont)
	oDanfe:Box(217,230,237,380)
	oDanfe:Say(224,232,"BAIRRO/DISTRITO",oFont08N:oFont)
	oDanfe:Say(234,232,_cBairro,oFont08:oFont)
	oDanfe:Box(217,380,237,500)
	oDanfe:Say(224,382,"CEP",oFont08N:oFont)
	oDanfe:Say(234,382,transform(_cCep,"@r 99.999-999"),oFont08:oFont)
	
	oDanfe:Box(236,000,257,500)
	oDanfe:Box(236,000,257,180)
	oDanfe:Say(245,002,"MUNICIPIO",oFont08N:oFont)
	oDanfe:Say(255,002,_cCidade,oFont08:oFont)
	oDanfe:Box(236,150,257,256)
	oDanfe:Say(245,152,"FONE/FAX",oFont08N:oFont)
	oDanfe:Say(255,152,_cTelefone,oFont08:oFont)
	oDanfe:Box(236,255,257,341)
	oDanfe:Say(245,257,"UF",oFont08N:oFont)
	oDanfe:Say(255,257,_cUF,oFont08:oFont)
	oDanfe:Box(236,340,257,500)
	oDanfe:Say(245,342,"INSCRIгцO ESTADUAL",oFont08N:oFont)
	oDanfe:Say(255,342,_cInscr2,oFont08:oFont)
	
	oDanfe:Box(197,502,217,603)
	oDanfe:Say(205,504,"DATA DE EMISSцO",oFont08N:oFont)
	oDanfe:Say(215,504,DTOC(_dEmissao),oFont08:oFont)
	oDanfe:Box(217,502,237,603)
	oDanfe:Say(224,504,"DATA ENTRADA/SAмDA",oFont08N:oFont)
	oDanfe:Say(233,504,DTOC(_dEmissao),oFont08:oFont) //Guarato
	oDanfe:Box(236,502,257,603)
	oDanfe:Say(243,503,"HORA ENTRADA/SAмDA",oFont08N:oFont)
	oDanfe:Say(252,503,PADR(TIME(),5),oFont08:oFont)
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁDuplicatas															   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oDanfe:Say(263,002,"DUPLICATAS",oFont08N:oFont)
	oDanfe:Box(265,000,296,068)
	oDanfe:Box(265,067,296,134)
	oDanfe:Box(265,134,296,202)
	oDanfe:Box(265,201,296,268)
	oDanfe:Box(265,268,296,335)
	oDanfe:Box(265,335,296,403)
	oDanfe:Box(265,402,296,469)
	oDanfe:Box(265,469,296,537)
	oDanfe:Box(265,536,296,603)
	
	If _nFaturas>0
		nColuna := 002
		DbSelectarea("COBR")
		DbSetorder(1)
		Dbgotop()
		While !Eof()
			oDanfe:Say(273,nColuna,DTOC(COBR->VENCTO),oFont08:oFont)
			oDanfe:Say(285,nColuna,Transform(COBR->VALOR,"@E 999,999.99"),oFont08:oFont)
			nColuna:= nColuna+67
			Dbskip()
		End
	Endif
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁImpostos																   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oDanfe:Say(305,002,"CALCULO DO IMPOSTO",oFont08N:oFont)
	oDanfe:Box(307,000,330,121)
	oDanfe:Say(316,002,"BASE DE CALCULO DO ICMS",oFont08N:oFont)
	If nFolha==1
		oDanfe:Say(326,002,transform(_nBaseICM,"@ze 999,999.99"),oFont08:oFont)
	Endif
	oDanfe:Box(307,120,330,200)
	oDanfe:Say(316,125,"VALOR DO ICMS",oFont08N:oFont)
	If nFolha==1
		oDanfe:Say(326,125,transform(_nVlrICM,"@ze 999,999.99"),oFont08:oFont)
	Endif
	oDanfe:Box(307,199,330,360)
	oDanfe:Say(316,200,"BASE DE CALCULO DO ICMS SUBSTITUIгцO",oFont08N:oFont)
	If nFolha==1
		oDanfe:Say(326,202,transform(_nBaseST,"@ze 999,999.99"),oFont08:oFont)
	Endif
	oDanfe:Box(307,360,330,490)
	oDanfe:Say(316,363,"VALOR DO ICMS SUBSTITUIгцO",oFont08N:oFont)
	If nFolha==1
		oDanfe:Say(326,363,transform(_nVlrST,"@ze 999,999.99"),oFont08:oFont)
	Endif
	oDanfe:Box(307,490,330,603)
	oDanfe:Say(316,491,"VALOR TOTAL DOS PRODUTOS",oFont08N:oFont)
	If nFolha==1
		oDanfe:Say(327,491,transform(_nTotal,"@ze 999,999.99"),oFont08:oFont)
	Endif
	oDanfe:Box(330,000,353,110)
	oDanfe:Say(339,002,"VALOR DO FRETE",oFont08N:oFont)
	If nFolha==1
		oDanfe:Say(349,002,transform(_nFrete,"@ze 999,999.99"),oFont08:oFont)
	Endif
	oDanfe:Box(330,100,353,190)
	oDanfe:Say(339,102,"VALOR DO SEGURO",oFont08N:oFont)
	If nFolha==1
		oDanfe:Say(349,102,transform(_nSeguro,"@ze 999,999.99"),oFont08:oFont)
	Endif
	oDanfe:Box(330,190,353,290)
	oDanfe:Say(339,194,"DESCONTO",oFont08N:oFont)
	If nFolha==1
		oDanfe:Say(349,194,transform(_nDesconto,"@ze 999,999.99"),oFont08:oFont)
	Endif
	oDanfe:Box(330,290,353,415)
	oDanfe:Say(339,295,"OUTRAS DESPESAS ACESSсRIAS",oFont08N:oFont)
	If nFolha==1
		oDanfe:Say(349,295,transform(_nOutras,"@ze 999,999.99"),oFont08:oFont)
	Endif
	oDanfe:Box(330,414,353,500)
	oDanfe:Say(339,420,"VALOR DO IPI",oFont08N:oFont)
	If nFolha==1
		oDanfe:Say(349,420,transform(_nIPI,"@ze 999,999.99"),oFont08:oFont)
	Endif
	oDanfe:Box(330,500,353,603)
	oDanfe:Say(339,506,"VALOR TOTAL DA NOTA",oFont08N:oFont)
	If nFolha==1
		oDanfe:Say(349,506,transform(_nTotNF,"@ze 999,999.99"),oFont08:oFont)
	Endif
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁTransportador/Volumes transportados                                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oDanfe:Say(361,002,"TRANSPORTADOR/VOLUMES TRANSPORTADOS",oFont08N:oFont)
	oDanfe:Box(363,000,386,603)
	oDanfe:Say(372,002,"RAZцO SOCIAL",oFont08N:oFont)
	If nFolha==1
		oDanfe:Say(382,002,_cTransp,oFont08:oFont)
	Endif
	oDanfe:Box(363,245,386,315)
	oDanfe:Say(372,247,"FRETE POR CONTA",oFont08N:oFont)
	oDanfe:Say(382,247,"",oFont08:oFont)
	
	oDanfe:Box(363,315,386,370)
	oDanfe:Say(372,317,"CсDIGO ANTT",oFont08N:oFont)
	If nFolha==1
		oDanfe:Say(382,319,_cCodATT,oFont08:oFont)
	Endif
	oDanfe:Box(363,370,386,490)
	oDanfe:Say(372,375,"PLACA DO VEмCULO",oFont08N:oFont)
	If nFolha==1
		oDanfe:Say(382,375,_cPlaca,oFont08:oFont)
	Endif
	oDanfe:Box(363,450,386,510)
	oDanfe:Say(372,452,"UF",oFont08N:oFont)
	If nFolha==1
		oDanfe:Say(382,452,_cUFTra,oFont08:oFont)
	Endif
	oDanfe:Box(363,510,386,603)
	oDanfe:Say(372,512,"CNPJ/CPF",oFont08N:oFont)
	
	If nFolha==1
		If Len(ALLTRIM(_cCNPJTra))==14
			oDanfe:Say(382,512,Transform(_cCNPJTra,"@r 99.999.999/9999-99"),oFont08:oFont)
		Else
			oDanfe:Say(382,512,Transform(_cCNPJTra,"@r 999.999.999-99"),oFont08:oFont)
		Endif
	Endif
	
	oDanfe:Box(385,000,409,603)
	oDanfe:Box(385,000,409,241)
	oDanfe:Say(393,002,"ENDEREгO",oFont08N:oFont)
	If nFolha==1
		oDanfe:Say(404,002,_cEndTra,oFont08:oFont)
	Endif
	oDanfe:Box(385,240,409,341)
	oDanfe:Say(393,242,"MUNICIPIO",oFont08N:oFont)
	If nFolha==1
		oDanfe:Say(404,242,_cCidTra,oFont08:oFont)
	Endif
	oDanfe:Box(385,340,409,440)
	oDanfe:Say(393,342,"UF",oFont08N:oFont)
	If nFolha==1
		oDanfe:Say(404,342,_cUFTra,oFont08:oFont)
	Endif
	oDanfe:Box(385,440,409,603)
	oDanfe:Say(393,442,"INSCRIгцO ESTADUAL",oFont08N:oFont)
	If nFolha==1
		oDanfe:Say(404,442,_cInscrTra,oFont08:oFont)
	Endif
	
	oDanfe:Box(408,000,432,603)
	oDanfe:Box(408,000,432,101)
	oDanfe:Say(418,002,"QUANTIDADE",oFont08N:oFont)
	If nFolha==1
		oDanfe:Say(428,002,Transform(_nQuant,"@E 99999"),oFont08:oFont)
	Endif
	oDanfe:Box(408,100,432,200)
	oDanfe:Say(418,102,"ESPECIE",oFont08N:oFont)
	oDanfe:Say(428,102,"",oFont08:oFont)
	oDanfe:Box(408,200,432,301)
	oDanfe:Say(418,202,"MARCA",oFont08N:oFont)
	oDanfe:Say(428,202,"",oFont08:oFont)
	oDanfe:Box(408,300,432,400)
	oDanfe:Say(418,302,"NUMERAгцO",oFont08N:oFont)
	oDanfe:Say(428,302,"",oFont08:oFont)
	oDanfe:Box(408,400,432,501)
	oDanfe:Say(418,402,"PESO BRUTO",oFont08N:oFont)
	If nFolha==1
		oDanfe:Say(428,402,Transform(_nPesoB,"@E 99,999.999"),oFont08:oFont) //Guarato
	Endif
	oDanfe:Box(408,500,432,603)
	oDanfe:Say(418,502,"PESO LIQUIDO",oFont08N:oFont)
	If nFolha==1
		oDanfe:Say(428,502,Transform(_nPesoL,"@E 99,999.999"),oFont08:oFont) // Guarato
	Endif
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁProdutos da Nota Fiscal												   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aTamCol:=43
	oDanfe:Say(440,002,"DADOS DO PRODUTO / SERVIгO",oFont08N:oFont)
	oDanfe:Box(442,000,678,603)
	nAuxH := 0
	oDanfe:Box(442, nAuxH, 678, nAuxH + 55)
	oDanfe:Say(450, nAuxH + 2, "COD. PROD",oFont08N:oFont)
	nAuxH += 55
	oDanfe:Box(442, nAuxH, 678, nAuxH + 130)
	oDanfe:Say(450, nAuxH + 2, "DESCRIгцO DO PROD./SERV.", oFont08N:oFont)
	nAuxH += 130
	oDanfe:Box(442, nAuxH, 678, nAuxH + 35)
	oDanfe:Say(450, nAuxH + 2, "NCM/SH", oFont08N:oFont)
	nAuxH += 35
	oDanfe:Box(442, nAuxH, 678, nAuxH + 35)
	oDanfe:Say(450, nAuxH + 2, "", oFont08N:oFont) //CST
	nAuxH += 35
	oDanfe:Box(442, nAuxH, 678, nAuxH + 35)
	oDanfe:Say(450, nAuxH + 2, "CFOP", oFont08N:oFont)
	nAuxH += 35
	oDanfe:Box(442, nAuxH, 678, nAuxH + 35)
	oDanfe:Say(450, nAuxH + 2, "UN", oFont08N:oFont)
	nAuxH += 35
	oDanfe:Box(442, nAuxH, 678, nAuxH + 35)
	oDanfe:Say(450, nAuxH + 2, "QUANT.", oFont08N:oFont)
	nAuxH += 35
	oDanfe:Box(442, nAuxH, 678, nAuxH + 35)
	oDanfe:Say(450, nAuxH + 2, "V.UNIT.", oFont08N:oFont)
	nAuxH += 35
	oDanfe:Box(442, nAuxH, 678, nAuxH + 35)
	oDanfe:Say(450, nAuxH + 2, "V.TOTAL", oFont08N:oFont)
	nAuxH += 35
	oDanfe:Box(442, nAuxH, 678, nAuxH + 35)
	oDanfe:Say(450, nAuxH + 2, "BC.ICMS", oFont08N:oFont)
	nAuxH += 35
	oDanfe:Box(442, nAuxH, 678, nAuxH + 35)
	oDanfe:Say(450, nAuxH + 2, "V.ICMS", oFont08N:oFont)
	nAuxH += 35
	oDanfe:Box(442, nAuxH, 678, nAuxH + 35)
	oDanfe:Say(450, nAuxH + 2, "V.IPI", oFont08N:oFont)
	nAuxH += 35
	oDanfe:Box(442, nAuxH, 678, nAuxH + 35)
	oDanfe:Say(450, nAuxH + 2, "A.ICMS", oFont08N:oFont)
	nAuxH += 35
	oDanfe:Box(442, nAuxH, 678, nAuxH + 35)
	oDanfe:Say(450, nAuxH + 2, "A.IPI", oFont08N:oFont)
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁProdutos																   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nLin:=465
	nCol:=2
	
	DbSelectarea("NFEXML")
	DbSetorder(1)
	Dbgotop()
	While !Eof()
		If NFEXML->FOLHA==nFolha
			oDanfe:Say(nLin,nCol,NFEXML->PRODUTO,oFont08N:oFont)
			nCol:=nCol+55
			oDanfe:Say(nLin,nCol,UPPER(NFEXML->DESCRICAO),oFont08N:oFont)
			nCol:=nCol+130
			oDanfe:Say(nLin,nCol,NFEXML->NCM,oFont08N:oFont)
			nCol:=nCol+35
			oDanfe:Say(nLin,nCol,NFEXML->CST,oFont08N:oFont)
			nCol:=nCol+35
			oDanfe:Say(nLin,nCol,NFEXML->CFOP,oFont08N:oFont)
			nCol:=nCol+35
			oDanfe:Say(nLin,nCol,NFEXML->UM,oFont08N:oFont)
			nCol:=nCol+35
			oDanfe:Say(nLin,nCol,Transform(NFEXML->QUANT,"@E 99,999.99"),oFont08N:oFont)
			nCol:=nCol+35
			oDanfe:Say(nLin,nCol,Transform(NFEXML->VALOR,"@E 99,999.99"),oFont08N:oFont)
			nCol:=nCol+35
			oDanfe:Say(nLin,nCol,Transform(NFEXML->TOTAL,"@E 99,999.99"),oFont08N:oFont)
			nCol:=nCol+35
			oDanfe:Say(nLin,nCol,Transform(NFEXML->BCICM,"@E 99,999.99"),oFont08N:oFont)
			nCol:=nCol+35
			oDanfe:Say(nLin,nCol,Transform(NFEXML->VLRICM,"@E 99,999.99"),oFont08N:oFont)
			nCol:=nCol+35
			oDanfe:Say(nLin,nCol,Transform(NFEXML->IPI,"@E 9,999.99"),oFont08N:oFont)
			nCol:=nCol+35
			oDanfe:Say(nLin,nCol,Transform(NFEXML->ALQICM,"@E 999.99"),oFont08N:oFont)
			nCol:=nCol+35
			oDanfe:Say(nLin,nCol,Transform(NFEXML->ALQIPI,"@E 999.99"),oFont08N:oFont)
			nLin:=nLin+10
			nCol:=2
		Endif
		Dbskip()
	End
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁCalculo do ISSQN                                                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oDanfe:Say(686,000,"CALCULO DO ISSQN",oFont08N:oFont)
	oDanfe:Box(688,000,711,151)
	oDanfe:Say(696,002,"INSCRIгцO MUNICIPAL",oFont08N:oFont)
	oDanfe:Say(706,002,"",oFont08:oFont)
	oDanfe:Box(688,150,711,301)
	oDanfe:Say(696,152,"VALOR TOTAL DOS SERVIгOS",oFont08N:oFont)
	oDanfe:Say(706,152,"",oFont08:oFont)
	oDanfe:Box(688,300,711,451)
	oDanfe:Say(696,302,"BASE DE CаLCULO DO ISSQN",oFont08N:oFont)
	oDanfe:Say(706,302,"",oFont08:oFont)
	oDanfe:Box(688,450,711,603)
	oDanfe:Say(696,452,"VALOR DO ISSQN",oFont08N:oFont)
	oDanfe:Say(706,452,"",oFont08:oFont)
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁDados Adicionais                                                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oDanfe:Say(719,000,"DADOS ADICIONAIS",oFont08N:oFont)
	oDanfe:Box(721,000,865,351)
	oDanfe:Say(729,002,"INFORMAгуES COMPLEMENTARES",oFont08N:oFont)
	
	If nFolha==1
		oDanfe:Say(741,002,SUBSTR(_cMensag,001,80),oFont08:oFont)
		oDanfe:Say(751,002,SUBSTR(_cMensag,081,80),oFont08:oFont)
		oDanfe:Say(761,002,SUBSTR(_cMensag,161,80),oFont08:oFont)
		oDanfe:Say(771,002,SUBSTR(_cMensag,241,80),oFont08:oFont)
		oDanfe:Say(781,002,SUBSTR(_cMensag,321,80),oFont08:oFont)
		oDanfe:Say(791,002,SUBSTR(_cMensag,401,80),oFont08:oFont)
		oDanfe:Say(801,002,SUBSTR(_cMensag,481,80),oFont08:oFont)
		oDanfe:Say(811,002,SUBSTR(_cMensag,561,80),oFont08:oFont)
		oDanfe:Say(821,002,SUBSTR(_cMensag,641,80),oFont08:oFont)
		oDanfe:Say(831,002,SUBSTR(_cMensag,721,80),oFont08:oFont)
	Endif
	
	oDanfe:Box(721,350,865,603)
	oDanfe:Say(729,352,"RESERVADO AO FISCO",oFont08N:oFont)
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁFim de Impressao														   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oDanfe:EndPage()
	nFolha:=nFolha+1
Next

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVisualiza Impressao													   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lPreview
	oDanfe:Preview()
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁLibera Objeto														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
FreeObj(oDanfe)
oDanfe := Nil

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁApagando tabela temporaria											   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Dbselectarea("NFEXML")
dbCloseArea("NFEXML")
If Found(cArqTrab+".DTC")
	fErase(cArqTrab+".DTC")
Endif
If Found(cArqTrab+".DBF")
	fErase(cArqTrab+".DBF")
Endif
fErase(cArqTrab+OrdBagExt())

Dbselectarea("COBR")
dbCloseArea("COBR")
If Found(cArqTrab2+".DTC")
	fErase(cArqTrab2+".DTC")
Endif
If Found(cArqTrab2+".DBF")
	fErase(cArqTrab2+".DBF")
Endif
fErase(cArqTrab2+OrdBagExt())
Return(.T.)


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processando arquivos												Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function DANFEXML(cArquivo,cPathFile)

Private oXml :=NIL
Private cError:=''
Private cWarning:=''

oXml :=NIL
cFile:=cPathFile+lower(ALLTRIM(cArquivo))
oXml := XmlParserFile(cFile,"_",@cError, @cWarning )
aCols:={}
aCob:={}

lTipo:=1
If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE"))=="O"
	lTipo:=2
	aCols:=aClone(oXml:_NFEPROC:_NFE:_INFNFE:_DET)
	If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP")) $ "O/A"
		aCob:=aClone(oXml:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP)
	Endif
	If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_COBR:_FAT")) $ "O/A"
		aCob:=aClone(oXml:_NFEPROC:_NFE:_INFNFE:_COBR:_FAT)
	Endif
Endif
If ALLTRIM(TYPE("oxml:_NFE:_INFNFE"))=="O"
	lTipo:=3
	aCols:=aClone(oXml:_NFE:_INFNFE:_DET)
	If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_COBR:_DUP")) $ "O/A"
		aCob:=aClone(oXml:_NFE:_INFNFE:_COBR:_DUP)
	Endif
	If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_COBR:_FAT")) $ "O/A"
		aCob:=aClone(oXml:_NFE:_INFNFE:_COBR:_FAT)
	Endif
Endif

_cCNPJ:=''
_cCNPJ2:=''
_cNFiscal:=''
_cSerie:=''
_cChave:=''
_dEmissao:=''
_dVenc:=''
_nVlrDup:=0

If Empty(@cError) .AND. lTipo<>1
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Criacao de tabelas temporarias										Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aCampos:= {{"FOLHA","N",2,0 },;
	{"PRODUTO","C",20,0 },;
	{"DESCRICAO","C",35,0 },;
	{"NCM","C",8,0 },;
	{"CST","C",3,0 },;
	{"CFOP","C",4,0 },;
	{"UM","C",2,0 },;
	{"QUANT","N",12,2 },;
	{"VALOR","N",12,2 },;
	{"TOTAL","N",12,2 },;
	{"BCICM","N",12,2 },;
	{"VLRICM","N",12,2 },;
	{"IPI","N",12,2 },;
	{"ALQICM","N",12,2 },;
	{"ALQIPI","N",12,2 }}
	
	cArqTrab  := CriaTrab(aCampos)
	dbUseArea( .T.,, cArqTrab, "NFEXML", if(.F. .OR. .F., !.F., NIL), .F. )
	IndRegua("NFEXML",cArqTrab,"DESCRICAO",,,)
	dbSetIndex( cArqTrab +OrdBagExt())
	dbSelectArea("NFEXML")
	
	If lTipo==2
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁEmitente																   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:TEXT"))=="C"
			_cEmpresa:=UPPER(ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:TEXT))
		Endif
		If 	ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XLGR:TEXT"))=="C"
			_cEndEmp:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XLGR:TEXT)
			_cEndEmp:=ALLTRIM(_cEndEmp)+","+ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_NRO:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XBAIRRO:TEXT"))=="C"
			_cBairEmp:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XBAIRRO:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CEP:TEXT"))=="C"
			_cCEPEmp:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CEP:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XMUN:TEXT"))=="C"
			_cCidEmp:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XMUN:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_FONE:TEXT"))=="C"
			_cTelEmp:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_FONE:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_IE:TEXT"))=="C"
			_cInscr:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_IE:TEXT)
			_cInscrST:=""
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT"))=="C"
			_cCNPJ:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT)
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁNota Fiscal															   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT"))=="C"
			_cNFiscal:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT"))=="C"
			_cSerie:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT)
		Endif
		_cChave:=ALLTRIM(SUBSTR(oxml:_NFEPROC:_NFE:_INFNFE:_ID:TEXT,4,200))
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NATOP:TEXT"))=="C"
			_cNatureza:=UPPER(ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NATOP:TEXT))
		Endif
		//If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_DEMI:TEXT"))=="C"
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT"))=="C"
			//_dEmissao:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_DEMI:TEXT
			_dEmissao := STOD(StrTran(Substr(oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT,1,10),"-",""))
			//_dEmissao:=STOD(SUBSTR(_dEmissao,1,4)+SUBSTR(_dEmissao,6,2)+SUBSTR(_dEmissao,9,2))
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁDestinatario															   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_XNOME:TEXT"))=="C"
			_cDestinatario:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_XNOME:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT"))=="C"
			_cCNPJ2:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_XLGR:TEXT"))=="C"
			_cEndereco:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_XLGR:TEXT)
			_cEndereco:=ALLTRIM(_cEndereco)+","+ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_NRO:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_XBAIRRO:TEXT"))=="C"
			_cBairro:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_XBAIRRO:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_CEP:TEXT"))=="C"
			_cCEP:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_CEP:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_XMUN:TEXT"))=="C"
			_cCidade:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_XMUN:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_UF:TEXT"))=="C"
			_cUF:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_UF:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_FONE:TEXT"))=="C"
			_cTelefone:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_FONE:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_IE:TEXT"))=="C"
			_cInscr2:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_IE:TEXT)
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁTransporte															   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_XNOME:TEXT"))=="C"
			_cTransp:=oxml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_XNOME:TEXT
		Endif
		_cCodATT:=""
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_VEICTRANSP:_PLACA:TEXT"))=="C"
			_cPlaca:=oxml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_VEICTRANSP:_PLACA:TEXT
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_UF:TEXT"))=="C"
			_cUFTra:=oxml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_UF:TEXT
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_CNPJ:TEXT"))=="C"
			_cCNPJTra:=oxml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_CNPJ:TEXT
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_XENDER:TEXT"))=="C"
			_cEndTra:=oxml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_XENDER:TEXT
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_XMUN:TEXT"))=="C"
			_cCidTra:=oxml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_XMUN:TEXT
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_IE:TEXT"))=="C"
			_cInscrTra:=oxml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_IE:TEXT
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_VOL:_QVOL:TEXT"))=="C"
			_nQuant:=VAL(oxml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_VOL:_QVOL:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_VOL:_PESOB:TEXT"))=="C"
			_nPesoB:=VAL(oxml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_VOL:_PESOB:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_VOL:_PESOL:TEXT"))=="C"
			_nPesoL:=VAL(oxml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_VOL:_PESOL:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT"))=="C"
			_cMensag:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT)
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁDuplicatas															   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If aCob==NIL
			nItens:=0
			_nFaturas:=0
		Else
			nItens:=LEN(aCob)
			_nFaturas:=LEN(aCob)
		Endif
		
		For i:=1 to nItens
			If nItens>0
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP[i]:_DVENC:TEXT"))=="C"
					_dVenc:=oxml:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP[i]:_DVENC:TEXT
					_dVenc:=STOD(SUBSTR(_dVenc,1,4)+SUBSTR(_dVenc,6,2)+SUBSTR(_dVenc,9,2))
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP[i]:_VDUP:TEXT"))=="C"
					_nVlrDup:=VAL(oxml:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP[i]:_VDUP:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_COBR:_FAT[i]:_VORIG:TEXT"))=="C"
					_dVenc:=DDATABASE
					_nVlrDup:=VAL(oxml:_NFEPROC:_NFE:_INFNFE:_COBR:_FAT[i]:_VORIG:TEXT)
				Endif
				DbSelectarea("COBR")
				Reclock("COBR",.T.)
				COBR->VENCTO:=_dVenc
				COBR->VALOR:=_nVlrDup
				MsUnlock()
			Else
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP:_DVENC:TEXT"))=="C"
					_dVenc:=oxml:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP:_DVENC:TEXT
					_dVenc:=STOD(SUBSTR(_dVenc,1,4)+SUBSTR(_dVenc,6,2)+SUBSTR(_dVenc,9,2))
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP:_VDUP:TEXT"))=="C"
					_nVlrDup:=VAL(oxml:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP:_VDUP:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_COBR:_FAT:_VORIG:TEXT"))=="C"
					_dVenc:=DDATABASE
					_nVlrDup:=VAL(oxml:_NFEPROC:_NFE:_INFNFE:_COBR:_FAT:_VORIG:TEXT)
				Endif
				
				DbSelectarea("COBR")
				Reclock("COBR",.T.)
				COBR->VENCTO:=_dVenc
				COBR->VALOR:=_nVlrDup
				MsUnlock()
			Endif
		Next
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁImpostos																   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VBC:TEXT"))=="C"
			_nBaseICM:=VAL(oxml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VBC:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT"))=="C"
			_nVlrICM:=VAL(oxml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VBCST:TEXT"))=="C"
			_nBaseST:=VAL(oxml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VBCST:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:TEXT"))=="C"
			_nVlrST:=VAL(oxml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:TEXT"))=="C"
			_nTotal:=VAL(oxml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VFRETE:TEXT"))=="C"
			_nFrete:=VAL(oxml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VFRETE:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VSEG:TEXT"))=="C"
			_nSeguro:=VAL(oxml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VSEG:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VDESC:TEXT"))=="C"
			_nDesconto:=VAL(oxml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VDESC:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VOUTROS:TEXT"))=="C"
			_nOutras:=VAL(oxml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VOUTROS:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VIPI:TEXT"))=="C"
			_nIPI:=VAL(oxml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VIPI:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT"))=="C"
			_nTotNF:=VAL(oxml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT)
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁProdutos																   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If aCols==NIL
			nItens:=1
		Else
			nItens:=LEN(aCols)
		Endif
		nSeqFol:=1
		nIt:=0
		
		For i:=1 to nItens
			If nItens>1
				DbSelectarea("NFEXML")
				Reclock("NFEXML",.T.)
				NFEXML->FOLHA:=nSeqFol
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_CPROD:TEXT"))=="C"
					NFEXML->PRODUTO:=oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_CPROD:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_XPROD:TEXT"))=="C"
					NFEXML->DESCRICAO:=oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_XPROD:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_NCM:TEXT"))=="C"
					NFEXML->NCM:=oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_NCM:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_ICMS:_ICMS10:_CST:TEXT"))=="C"
					NFEXML->CST:=oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_ICMS:_ICMS10:_CST:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_CFOP:TEXT"))=="C"
					NFEXML->CFOP:=oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_CFOP:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_UTRIB:TEXT"))=="C"
					NFEXML->UM:=oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_UTRIB:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_QCOM:TEXT"))=="C"
					NFEXML->QUANT:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_QCOM:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_VUNTRIB:TEXT"))=="C"
					NFEXML->VALOR:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_VUNTRIB:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_VPROD:TEXT"))=="C"
					NFEXML->TOTAL:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_VPROD:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_ICMS:_ICMS10:_VBC:TEXT"))=="C"
					NFEXML->BCICM:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_ICMS:_ICMS10:_VBC:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_ICMS:_ICMS10:_VICMS:TEXT"))=="C"
					NFEXML->VLRICM:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_ICMS:_ICMS10:_VICMS:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_ICMS:_ICMS10:_PICMS:TEXT"))=="C"
					NFEXML->ALQICM:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_ICMS:_ICMS10:_PICMS:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT"))=="C"
					NFEXML->IPI:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT"))=="C"
					NFEXML->ALQIPI:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT)
				Endif
				MsUnlock()
				nIt:=nIt+1
				
				If nIt>21
					nSeqFol:=nSeqFol+1
					nIt:=0
				Endif
			Else
				DbSelectarea("NFEXML")
				Reclock("NFEXML",.T.)
				NFEXML->FOLHA:=1
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CPROD:TEXT"))=="C"
					NFEXML->PRODUTO:=oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CPROD:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_XPROD:TEXT"))=="C"
					NFEXML->DESCRICAO:=oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_XPROD:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_NCM:TEXT"))=="C"
					NFEXML->NCM:=oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_NCM:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_CST:TEXT"))=="C"
					NFEXML->CST:=oxml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_CST:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT"))=="C"
					NFEXML->CFOP:=oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_UTRIB:TEXT"))=="C"
					NFEXML->UM:=oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_UTRIB:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_QCOM:TEXT"))=="C"
					NFEXML->QUANT:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_QCOM:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_VUNTRIB:TEXT"))=="C"
					NFEXML->VALOR:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_VUNTRIB:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_VPROD:TEXT"))=="C"
					NFEXML->TOTAL:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_VPROD:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_VBC:TEXT"))=="C"
					NFEXML->BCICM:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_VBC:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_VICMS:TEXT"))=="C"
					NFEXML->VLRICM:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_VICMS:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_PICMS:TEXT"))=="C"
					NFEXML->ALQICM:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_PICMS:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT"))=="C"
					NFEXML->IPI:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT"))=="C"
					NFEXML->ALQIPI:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT)
				Endif
				MsUnlock()
			Endif
		Next
	Else
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁEmitente																   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If ALLTRIM(TYPE("oxml: _NFE:_INFNFE:_EMIT:_XNOME:TEXT"))=="C"
			_cEmpresa:=UPPER(ALLTRIM(oxml:_NFE:_INFNFE:_EMIT:_XNOME:TEXT))
		Endif
		If 	ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XLGR:TEXT"))=="C"
			_cEndEmp:=ALLTRIM(oxml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XLGR:TEXT)
			_cEndEmp:=ALLTRIM(_cEndEmp)+","+ALLTRIM(oxml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_NRO:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XBAIRRO:TEXT"))=="C"
			_cBairEmp:=ALLTRIM(oxml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XBAIRRO:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CEP:TEXT"))=="C"
			_cCEPEmp:=ALLTRIM(oxml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CEP:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XMUN:TEXT"))=="C"
			_cCidEmp:=ALLTRIM(oxml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XMUN:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_FONE:TEXT"))=="C"
			_cTelEmp:=ALLTRIM(oxml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_FONE:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_EMIT:_IE:TEXT"))=="C"
			_cInscr:=ALLTRIM(oxml:_NFE:_INFNFE:_EMIT:_IE:TEXT)
			_cInscrST:=""
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT"))=="C"
			_cCNPJ:=ALLTRIM(oxml:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT)
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁNota Fiscal															   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_IDE:_NNF:TEXT"))=="C"
			_cNFiscal:=ALLTRIM(oxml:_NFE:_INFNFE:_IDE:_NNF:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_IDE:_SERIE:TEXT"))=="C"
			_cSerie:=ALLTRIM(oxml:_NFE:_INFNFE:_IDE:_SERIE:TEXT)
		Endif
		_cChave:=ALLTRIM(SUBSTR(oxml:_NFE:_INFNFE:_ID:TEXT,4,200))
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_IDE:_NATOP:TEXT"))=="C"
			_cNatureza:=UPPER(ALLTRIM(oxml:_NFE:_INFNFE:_IDE:_NATOP:TEXT))
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_IDE:_DEMI:TEXT"))=="C"
			_dEmissao:=oxml:_NFE:_INFNFE:_IDE:_DEMI:TEXT
			_dEmissao:=STOD(SUBSTR(_dEmissao,1,4)+SUBSTR(_dEmissao,6,2)+SUBSTR(_dEmissao,9,2))
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁDestinatario															   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DEST:_XNOME:TEXT"))=="C"
			_cDestinatario:=ALLTRIM(oxml:_NFE:_INFNFE:_DEST:_XNOME:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT"))=="C"
			_cCNPJ2:=ALLTRIM(oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DEST:_ENDERDEST:_XLGR:TEXT"))=="C"
			_cEndereco:=ALLTRIM(oxml:_NFE:_INFNFE:_DEST:_ENDERDEST:_XLGR:TEXT)
			_cEndereco:=ALLTRIM(_cEndereco)+","+ALLTRIM(oxml:_NFE:_INFNFE:_DEST:_ENDERDEST:_NRO:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DEST:_ENDERDEST:_XBAIRRO:TEXT"))=="C"
			_cBairro:=ALLTRIM(oxml:_NFE:_INFNFE:_DEST:_ENDERDEST:_XBAIRRO:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DEST:_ENDERDEST:_CEP:TEXT"))=="C"
			_cCEP:=ALLTRIM(oxml:_NFE:_INFNFE:_DEST:_ENDERDEST:_CEP:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DEST:_ENDERDEST:_XMUN:TEXT"))=="C"
			_cCidade:=ALLTRIM(oxml:_NFE:_INFNFE:_DEST:_ENDERDEST:_XMUN:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DEST:_ENDERDEST:_UF:TEXT"))=="C"
			_cUF:=ALLTRIM(oxml:_NFE:_INFNFE:_DEST:_ENDERDEST:_UF:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DEST:_ENDERDEST:_FONE:TEXT"))=="C"
			_cTelefone:=ALLTRIM(oxml:_NFE:_INFNFE:_DEST:_ENDERDEST:_FONE:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DEST:_IE:TEXT"))=="C"
			_cInscr2:=ALLTRIM(oxml:_NFE:_INFNFE:_DEST:_IE:TEXT)
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁTransporte															   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_XNOME:TEXT"))=="C"
			_cTransp:=oxml:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_XNOME:TEXT
		Endif
		_cCodATT:=""
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_TRANSP:_VEICTRANSP:_PLACA:TEXT"))=="C"
			_cPlaca:=oxml:_NFE:_INFNFE:_TRANSP:_VEICTRANSP:_PLACA:TEXT
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_UF:TEXT"))=="C"
			_cUFTra:=oxml:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_UF:TEXT
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_CNPJ:TEXT"))=="C"
			_cCNPJTra:=oxml:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_CNPJ:TEXT
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_XENDER:TEXT"))=="C"
			_cEndTra:=oxml:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_XENDER:TEXT
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_XMUN:TEXT"))=="C"
			_cCidTra:=oxml:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_XMUN:TEXT
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_IE:TEXT"))=="C"
			_cInscrTra:=oxml:_NFE:_INFNFE:_TRANSP:_TRANSPORTA:_IE:TEXT
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_TRANSP:_VOL:_QVOL:TEXT"))=="C"
			_nQuant:=VAL(oxml:_NFE:_INFNFE:_TRANSP:_VOL:_QVOL:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_TRANSP:_VOL:_PESOB:TEXT"))=="C"
			_nPesoB:=VAL(oxml:_NFE:_INFNFE:_TRANSP:_VOL:_PESOB:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_TRANSP:_VOL:_PESOL:TEXT"))=="C"
			_nPesoL:=VAL(oxml:_NFE:_INFNFE:_TRANSP:_VOL:_PESOL:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT"))=="C"
			_cMensag:=ALLTRIM(oxml:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT)
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁDuplicatas															   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If aCob==NIL
			nItens:=0
			_nFaturas:=0
		Else
			nItens:=LEN(aCob)
			_nFaturas:=LEN(aCob)
		Endif
		
		For i:=1 to nItens
			If nItens>0
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_COBR:_DUP[i]:_DVENC:TEXT"))=="C"
					_dVenc:=oxml:_NFE:_INFNFE:_COBR:_DUP[i]:_DVENC:TEXT
					_dVenc:=STOD(SUBSTR(_dVenc,1,4)+SUBSTR(_dVenc,6,2)+SUBSTR(_dVenc,9,2))
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_COBR:_DUP[i]:_VDUP:TEXT"))=="C"
					_nVlrDup:=VAL(oxml:_NFE:_INFNFE:_COBR:_DUP[i]:_VDUP:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_COBR:_FAT[i]:_VORIG:TEXT"))=="C"
					_dVenc:=DDATABASE
					_nVlrDup:=VAL(oxml:_NFE:_INFNFE:_COBR:_FAT[i]:_VORIG:TEXT)
				Endif
				DbSelectarea("COBR")
				Reclock("COBR",.T.)
				COBR->VENCTO:=_dVenc
				COBR->VALOR:=_nVlrDup
				MsUnlock()
			Else
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_COBR:_DUP:_DVENC:TEXT"))=="C"
					_dVenc:=oxml:_NFE:_INFNFE:_COBR:_DUP:_DVENC:TEXT
					_dVenc:=STOD(SUBSTR(_dVenc,1,4)+SUBSTR(_dVenc,6,2)+SUBSTR(_dVenc,9,2))
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_COBR:_DUP:_VDUP:TEXT"))=="C"
					_nVlrDup:=VAL(oxml:_NFE:_INFNFE:_COBR:_DUP:_VDUP:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_COBR:_FAT:_VORIG:TEXT"))=="C"
					_dVenc:=DDATABASE
					_nVlrDup:=VAL(oxml:_NFE:_INFNFE:_COBR:_FAT:_VORIG:TEXT)
				Endif
				
				DbSelectarea("COBR")
				Reclock("COBR",.T.)
				COBR->VENCTO:=_dVenc
				COBR->VALOR:=_nVlrDup
				MsUnlock()
			Endif
		Next
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁImpostos																   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VBC:TEXT"))=="C"
			_nBaseICM:=VAL(oxml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VBC:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT"))=="C"
			_nVlrICM:=VAL(oxml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VBCST:TEXT"))=="C"
			_nBaseST:=VAL(oxml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VBCST:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:TEXT"))=="C"
			_nVlrST:=VAL(oxml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:TEXT"))=="C"
			_nTotal:=VAL(oxml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VFRETE:TEXT"))=="C"
			_nFrete:=VAL(oxml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VFRETE:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VSEG:TEXT"))=="C"
			_nSeguro:=VAL(oxml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VSEG:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VDESC:TEXT"))=="C"
			_nDesconto:=VAL(oxml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VDESC:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VOUTROS:TEXT"))=="C"
			_nOutras:=VAL(oxml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VOUTROS:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VIPI:TEXT"))=="C"
			_nIPI:=VAL(oxml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VIPI:TEXT)
		Endif
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT"))=="C"
			_nTotNF:=VAL(oxml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT)
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁProdutos																   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If aCols==NIL
			nItens:=1
		Else
			nItens:=LEN(aCols)
		Endif
		nSeqFol:=1
		nIt:=0
		
		For i:=1 to nItens
			If nItens>1
				DbSelectarea("NFEXML")
				Reclock("NFEXML",.T.)
				NFEXML->FOLHA:=nSeqFol
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_PROD:_CPROD:TEXT"))=="C"
					NFEXML->PRODUTO:=oxml:_NFE:_INFNFE:_DET[i]:_PROD:_CPROD:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_PROD:_XPROD:TEXT"))=="C"
					NFEXML->DESCRICAO:=oxml:_NFE:_INFNFE:_DET[i]:_PROD:_XPROD:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_PROD:_NCM:TEXT"))=="C"
					NFEXML->NCM:=oxml:_NFE:_INFNFE:_DET[i]:_PROD:_NCM:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_ICMS:_ICMS10:_CST:TEXT"))=="C"
					NFEXML->CST:=oxml:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_ICMS:_ICMS10:_CST:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_PROD:_CFOP:TEXT"))=="C"
					NFEXML->CFOP:=oxml:_NFE:_INFNFE:_DET[i]:_PROD:_CFOP:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_PROD:_UTRIB:TEXT"))=="C"
					NFEXML->UM:=oxml:_NFE:_INFNFE:_DET[i]:_PROD:_UTRIB:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_PROD:_QCOM:TEXT"))=="C"
					NFEXML->QUANT:=val(oxml:_NFE:_INFNFE:_DET[i]:_PROD:_QCOM:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_PROD:_VUNTRIB:TEXT"))=="C"
					NFEXML->VALOR:=val(oxml:_NFE:_INFNFE:_DET[i]:_PROD:_VUNTRIB:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_PROD:_VPROD:TEXT"))=="C"
					NFEXML->TOTAL:=val(oxml:_NFE:_INFNFE:_DET[i]:_PROD:_VPROD:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_ICMS:_ICMS10:_VBC:TEXT"))=="C"
					NFEXML->BCICM:=val(oxml:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_ICMS:_ICMS10:_VBC:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_ICMS:_ICMS10:_VICMS:TEXT"))=="C"
					NFEXML->VLRICM:=val(oxml:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_ICMS:_ICMS10:_VICMS:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_ICMS:_ICMS10:_PICMS:TEXT"))=="C"
					NFEXML->ALQICM:=val(oxml:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_ICMS:_ICMS10:_PICMS:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT"))=="C"
					NFEXML->IPI:=val(oxml:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT"))=="C"
					NFEXML->ALQIPI:=val(oxml:_NFE:_INFNFE:_DET[i]:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT)
				Endif
				MsUnlock()
				nIt:=nIt+1
				
				If nIt>21
					nSeqFol:=nSeqFol+1
					nIt:=0
				Endif
			Else
				DbSelectarea("NFEXML")
				Reclock("NFEXML",.T.)
				NFEXML->FOLHA:=1
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET:_PROD:_CPROD:TEXT"))=="C"
					NFEXML->PRODUTO:=oxml:_NFE:_INFNFE:_DET:_PROD:_CPROD:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET:_PROD:_XPROD:TEXT"))=="C"
					NFEXML->DESCRICAO:=oxml:_NFE:_INFNFE:_DET:_PROD:_XPROD:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET:_PROD:_NCM:TEXT"))=="C"
					NFEXML->NCM:=oxml:_NFE:_INFNFE:_DET:_PROD:_NCM:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_CST:TEXT"))=="C"
					NFEXML->CST:=oxml:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_CST:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT"))=="C"
					NFEXML->CFOP:=oxml:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET:_PROD:_UTRIB:TEXT"))=="C"
					NFEXML->UM:=oxml:_NFE:_INFNFE:_DET:_PROD:_UTRIB:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET:_PROD:_QCOM:TEXT"))=="C"
					NFEXML->QUANT:=val(oxml:_NFE:_INFNFE:_DET:_PROD:_QCOM:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET:_PROD:_VUNTRIB:TEXT"))=="C"
					NFEXML->VALOR:=val(oxml:_NFE:_INFNFE:_DET:_PROD:_VUNTRIB:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET:_PROD:_VPROD:TEXT"))=="C"
					NFEXML->TOTAL:=val(oxml:_NFE:_INFNFE:_DET:_PROD:_VPROD:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_VBC:TEXT"))=="C"
					NFEXML->BCICM:=val(oxml:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_VBC:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_VICMS:TEXT"))=="C"
					NFEXML->VLRICM:=val(oxml:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_VICMS:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_PICMS:TEXT"))=="C"
					NFEXML->ALQICM:=val(oxml:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_PICMS:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT"))=="C"
					NFEXML->IPI:=val(oxml:_NFE:_INFNFE:_DET:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT"))=="C"
					NFEXML->ALQIPI:=val(oxml:_NFE:_INFNFE:_DET:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT)
				Endif
				MsUnlock()
			Endif
		Next
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁQuantidade de Itens													   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectarea("NFEXML")
	DbGotop()
	While !Eof()
		nTotit:=nTotit+1
		Dbskip()
	End
Endif
Return .T.