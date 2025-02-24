#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#Include "Xmlxfun.ch"
#INCLUDE "ap5mail.ch"
#INCLUDE "shell.ch"
#DEFINE ENTER CHR(13)+CHR(10)

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммкмммммммяммммммммммммммммммммкммммммямммммммммммм╩╠╠
╠╠╨Programa  Ё PainelXML ╨ Autor ЁMilton J.dos Santos ╨ Data Ё 01/04/2014 ╨╠╠
╠╠лммммммммммьмммммммммммймммммммоммммммммммммммммммммйммммммомммммммммммм╧╠╠
╠╠╨Desc.     Ё Painel de Controle sobre a importacao de arquivo XML de    ╨╠╠
╠╠╨          Ё NF-e (Nota Fiscal Eletronica)                              ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
User Function ALLA001()

//Variaveis para que fosse possivel usar a funcao padrao do sistema A120Pedido()

Private cXml        := '',oXml
Private INCLUI      := .F.
Private ALTERA      := .F.
Private nTipoPed    := 1
Private cCadastro   := "SeleГЦo dos Pedidos de Compra..."
Private l120Auto    := .F.
Private _cNFREF     := ""
Private _cTIPONF    := ""

aRotina   := {{"Pesquisar","AxPesqui",0,1},;
			  {"Comprar","U_PR_COM()",0,8}}

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fontes do windows usadas											Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE FONT oFont1 NAME "Arial Black" SIZE 6,17
DEFINE FONT oFont2 NAME "Courier New" SIZE 8,14
DEFINE FONT oFont3 NAME "Arial Black" SIZE 13,20
DEFINE FONT oFont4 NAME "Arial Black" SIZE 13,15
DEFINE FONT oFont5 NAME "Arial Black" SIZE 7,17
DEFINE FONT oFont6 NAME "Courier New" SIZE 6,20
DEFINE FONT oFont7 NAME "Courier New" SIZE 7,20
DEFINE FONT oFont8 NAME "Courier New" SIZE 14,15

_cUsuario := ALLTRIM(UPPER(SUBSTR(CUSUARIO,7,15)))
_cEmpresa := SM0->M0_CODIGO
_cCorrente:= SM0->M0_CODFIL
cArqTxt   := CriaPasta() + "\config\CONFIG.INI"
lCheck2   := .F.
cNCM      := ''
cDecQtd   := 2
cDecUni   := 7
XEMAILREC := ""
lRefaz    := .F.

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Criando parametro do programa										Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSelectArea("SX6")
DbSetorder(1)
DbgoTop()
Dbseek(xFilial("SD1")+"MV_GRVPEDI")
If !Found()
	Reclock("SX6",.T.)
	SX6->X6_FIL     := xFilial("SD1")
	SX6->X6_VAR     := "MV_GRVPEDI"
	SX6->X6_TIPO    := "C"
	SX6->X6_DESCRIC := "Controle de gravacao pedidos de compras"
	MsUnlock()
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificando se o usuario ficou preco na ultima gravacao do pedido	Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
_lGrava := ALLTRIM(UPPER(Getmv("MV_GRVPEDI")))
If _lGrava == _cUsuario
	DbSelectArea("SX6")
	DbgoTop()
	While ! eof()
		If ALLTRIM(SX6->X6_VAR)=="MV_GRVPEDI" .and. SX6->X6_FIL==xFilial("SC7")
			RecLock("SX6",.F.)
			SX6->X6_CONTEUD:=""
			MsUnlock()
		Endif
		DbSkip()
	End
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se existe o arquivo de configuraГЦo                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ! File(cArqTxt)
	If _cUsuario == "ADMINISTRADOR"
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Manipulando arquivo de configuracao									Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If .not. CONFARQ()
			Return
		Endif
	Else
		Msgbox("O programa estА sem o arquivo CONFIG.INI. Entre com o usuario ADMINISTRADOR para configurar o sistema")
		Return
	Endif
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Filtros de XML														Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cResp := msgbox("Deseja realizar um filtro dos arquivos?","CNPJ:"+SM0->M0_CGC,"YESNO")

cPerg   := "LERXML"
lFiltro := .F.
If cResp
	lFiltro := .T.
	VALIDPERG(cPerg)
	Pergunte(cPerg,.t.)
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Filial e empresa atual												Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSelectarea("SM0")
Dbsetorder(1)
Dbgotop()
Dbseek(_cEmpresa + _cCorrente)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Lendo o arquivo de configuracao										Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cArqTxt := CriaPasta() + "\config\CONFIG.INI"
cBuffer := ""

cSerie   := ''
cEspecie := ''
cAlmox   := ''
cUnidades:= ''
cPedCom  := .F.
cNDF     := .F.
cAlmoPed := space(02)
_cURL    := space(500)
cZeros   := .F.
cZerosP  := .F.
cDecUni  := 7
cDecQtd  := 2
_lNCM    := .F.
_lPRDBLQ := .F.

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Analisando configuracoes da rotina									Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If File(cArqTxt)
	FT_FUSE(cArqTxt)
	FT_FGOTOP()
	ProcRegua(FT_FLASTREC())
	
	While !FT_FEOF()
		cBuffer := FT_FREADLN()
		
		If UPPER(SUBSTR(cBuffer,1,9)) == "EMAIL"+SM0->M0_CODIGO+SM0->M0_CODFIL
			xEMAILREC := lower(ALLTRIM(SUBSTR(cBuffer,11,400)))
		Endif
		If UPPER(SUBSTR(cBuffer,1,3)) == "POP"
			xPOP     := lower(ALLTRIM(SUBSTR(cBuffer,5,400)))
		Endif
		If UPPER(SUBSTR(cBuffer,1,5)) == "CONTA"
			xCONTA   := lower(ALLTRIM(SUBSTR(cBuffer,7,400)))
		Endif
		If UPPER(SUBSTR(cBuffer,1,5)) == "SENHA"
			xSENHA   := ALLTRIM(SUBSTR(cBuffer,7,400))
		Endif
		If UPPER(SUBSTR(cBuffer,1,4)) == SM0->M0_CODIGO+SM0->M0_CODFIL
			cSerie   := UPPER(SUBSTR(cBuffer,6,3))
		Endif
		If UPPER(SUBSTR(cBuffer,1,7)) == "ESP"+SM0->M0_CODIGO+SM0->M0_CODFIL
			cEspecie := UPPER(SUBSTR(cBuffer,9,5))
		Endif
		If UPPER(SUBSTR(cBuffer,1,10)) == "DECQTD"+SM0->M0_CODIGO+SM0->M0_CODFIL
			If !Empty(UPPER(SUBSTR(cBuffer,12,2)))
				cDecQtd := UPPER(SUBSTR(cBuffer,12,2))
			Endif
		Endif
		If UPPER(SUBSTR(cBuffer,1,10)) == "DECUNI"+SM0->M0_CODIGO+SM0->M0_CODFIL
			If !Empty(UPPER(SUBSTR(cBuffer,12,2)))
				cDecUni := UPPER(SUBSTR(cBuffer,12,2))
			Endif
		Endif
		If UPPER(SUBSTR(cBuffer,1,5)) == "S"+SM0->M0_CODIGO+SM0->M0_CODFIL
			cAlmox := UPPER(SUBSTR(cBuffer,7,2))
		Endif
		If UPPER(SUBSTR(cBuffer,1,2)) == "UM"
			cUnidades := ALLTRIM(UPPER(SUBSTR(cBuffer,4,400)))
		Endif
		If UPPER(SUBSTR(cBuffer,1,4)) == "LOGO"
			cLogo := ALLTRIM(UPPER(SUBSTR(cBuffer,6,200)))+space(200)
		Endif
		If UPPER(SUBSTR(cBuffer,1,5)) == "P"+SM0->M0_CODIGO+SM0->M0_CODFIL
			cAlmoPed := ALLTRIM(UPPER(SUBSTR(cBuffer,7,2)))
		Endif
		If UPPER(SUBSTR(cBuffer,1,6)) == "PEDIDO"
			cPedCom := .T.
		Endif
		If UPPER(SUBSTR(cBuffer,1,3)) == "NDF"
			cNDF    := .T.
		Endif
		If UPPER(SUBSTR(cBuffer,1,3)) == "NCM"
			_lNCM    := .T.
		Endif
		If UPPER(SUBSTR(cBuffer,1,11)) == "NFZEROS=SIM"
			cZeros  := .T.
		Endif
		If UPPER(SUBSTR(cBuffer,1,11)) == "NFZEROS=PER"
			cZerosP := .T.
		Endif
		If UPPER(SUBSTR(cBuffer,1,11)) == "PEDPROD=SIM"
			lCheck2 := .T.
		Endif
		If UPPER(SUBSTR(cBuffer,1,3)) == "URL"
			_cURL   := ALLTRIM(UPPER(SUBSTR(cBuffer,5,500)))
		Endif
		FT_FSKIP()
	EndDo
	FT_FUSE()
Else
	Msgbox("Arquivo de configuracao CONFIG.INI nЦo encontrado no diretСrio " + cStartPath + "\CONFIG")
	Return
Endif

cDecUni := val(cDecUni)
cDecQtd := val(cDecQtd)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de numeracao do numero da nota fiscal						Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If cZerosP
	cResp:=msgbox("NumeraГЦo da Nota Fiscal com 9 DМgitos?","AtenГЦo...","YESNO")
	
	If cResp
		cZeros:=.T.
	Endif
Endif

cSerieNF:=ALLTRIM(cSerie)

If Empty(cUnidades)
	Msgbox("Favor informar as Unidades de medidas fracionadas!")
	Return
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Recebendo emails dos fornecedores									Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
MsgRun("Verificando mensagens pendentes no servidor " + ALLTRIM(xCONTA),,{||POPEMAIL()})

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Apagando arquivos diferentes de XML									Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aXML:={}
ADir("\xml\*.*",aXML)

For i:=1 to LEN(aXML)
	If !"XML" $ UPPER(ALLTRIM(aXML[i]))
		ferase("\xml\" + lower(ALLTRIM(aXML[i])))
	Else
		_cFileOri:="\xml\" + lower(ALLTRIM(aXML[i]))
		FRename(_cFileOri,lower(_cFileOri))
	Endif
Next

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Resolucao da tela													Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	_nSize:=560

	aSize   := MsAdvSize(,.F.,400)
	aObjects := {}
	AAdd( aObjects, { 0,    41, .T., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 0,    75, .T., .F. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	aPosGet := MsObjGetPos(aSize[3]-aSize[1],305,;
		{{10,40,105,140,200,234,275,200,225,260,285,265},;
		If(cPaisLoc<>"PTG",{10,40,105,140,200,234,63},{10,40,101,120,175,205,63,250,270}),;
		Iif(cPaisLoc<>"PTG",{5,70,160,205,295},{5,50,120,145,205,245,293}),;
		{6,34,200,215},;
		{6,34,80,113,160,185},;
		{6,34,245,268,260},;
		{10,50,150,190},;
		{273,130,190},;
		{8,45,80,103,139,173,200,235,270},;
		{133,190,144,190,289,293},;
		{142,293,140},;
		{9,47,188,148,9,146} } )

IF MsgYesNo("Deseja importar algum arquivo XML que esteja local?","[ALLA001_001] - AtenГЦo")
	_cTipo := "Arquivos Excel do tipo XML | *.XML"
	_cArqOri     := cGetFile(_cTipo, "Selecione o arquivo a ser importado ",0,"C:\",.T.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY)	
	IF !EMPTY(_cArqOri)
		_lRet := CpyT2S( _cArqOri ,"\XML" ,.F. )
		IF !_lRet
			MsgAlert("Ocorreram erros na copia do arquivo.","[ALLA_002]")
		ENDIF
	ENDIF
ENDIF

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Lista dos XML dos fornecedores										Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aXML:={}
ADir("\xml\*.xml",aXML)

If LEN(aXml)==0
	Msgbox("NЦo existem arquivos para serem importados no momento...","AtenГЦo...294","INFO")
	Return
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Produto alterados													Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aCampos5:= {{"PRODUTO","C",15,0 }}

cArqTrab5  := CriaTrab(aCampos5)
dbUseArea( .T.,, cArqTrab5, "LS5", if(.F. .OR. .F., !.F., NIL), .F. )
IndRegua("LS5",cArqTrab5,"PRODUTO",,,)
dbSetIndex( cArqTrab5 +OrdBagExt())
dbSelectArea("LS5")

aCampos	:= {{"SEQ","N",5,0 },;
{"OK","C",1,0 },;
{"CODBAR","C",15,0 },;
{"PRODUTO","C",15,0 },;
{"PRODFOR","C",15,0 },;
{"DESCRICAO","C",50,0 },;
{"DESCORI","C",50,0 },;
{"UM","C",2,0 },;
{"QE","N",6,0 },;
{"CAIXAS","N",11,cDecQtd },;
{"NCM","C",10,0 },;
{"QUANTIDADE","N",11,cDecQtd},;
{"PRECO","N",18,cDecUni },;
{"CUSTO","N",9,2 },;
{"PRECOFOR","N",18,cDecUni},;
{"TOTAL","N",14,2 },;
{"DESCONTO","N",12,2 },;
{"EMISSAO","C",8,0 },;
{"PEDIDO","C",6,0 },;
{"ITEM","C",4,0 },;
{"TES","C",3,0 },;
{"ALMOX","C",2,0 },;
{"ALTERADO","C",1,0 },;
{"NOME","C",35,0 },;
{"NOTA","C",9,0 },;
{"TOTALNF","N",12,2 }}

cArqTrab := CriaTrab(aCampos)
dbUseArea( .T.,, cArqTrab, "LS1", if(.F. .OR. .F., !.F., NIL), .F. )
IndRegua("LS1",cArqTrab,"SEQ",,,)
dbSetIndex( cArqTrab +OrdBagExt())
dbSelectArea("LS1")

aCampos3:= {{"EMISSAO","D",8,0 },;
{"FORNEC","C",6,0 },;
{"LOJA","C",2,0 },;
{"NOTA","C",9,0 },;
{"NOME","C",35,0 },;
{"VENDEDOR","C",30,0 },;
{"TELEFONE","C",20,0 },;
{"XML","C",150,0 },;
{"CHAVE","C",44,0 },;
{"NFREF","C",44,0 },;
{"NFORI","C",9,0 },;
{"SERIEORI","C",3,0 }}

cArqTrab3  := CriaTrab(aCampos3)
dbUseArea( .T.,, cArqTrab3, "LS3", if(.F. .OR. .F., !.F., NIL), .F. )
IndRegua("LS3",cArqTrab3,"NOME+NOTA",,,)
dbSetIndex( cArqTrab3 +OrdBagExt())
dbSelectArea("LS3")

_cCNPJ:=''
_cCNPJ2:=''
lAchou:=.F.

#IFDEF WINDOWS
	Processa({|| XMLFOUND()})
	Return
	Static Function XMLFOUND()
#ENDIF

aCampos4:= {{"NOTA","C",9,0 },;
{"FORNECEDOR","C",6,0 },;
{"LOJA","C",2,0 }}

cArqTrab4  := CriaTrab(aCampos4)
dbUseArea( .T.,, cArqTrab4, "LS4", if(.F. .OR. .F., !.F., NIL), .F. )
IndRegua("LS4",cArqTrab4,"FORNECEDOR+LOJA+NOTA",,,)
dbSetIndex( cArqTrab4 +OrdBagExt())
dbSelectArea("LS4")

cNota:=''
cEmissao:=''
cChave:=''
_cOpcao:=''

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processando XML														Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Procregua(LEN(aXML))

For i:=1 to LEN(aXML)
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Recebendo dados do XML												Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	XML()

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica o tipo de nota												Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	IF !EMPTY(_cNFREF)
		_cTIPONF := ALLA01T(_cNFREF)
	ENDIF

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Fornecedor															Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !Empty(_cCNPJ)
		IF EMPTY(_cNFREF) .OR. (!EMPTY(_cNFREF) .AND. _cTIPONF == "B")
			DbSelectarea("SA2") 
			DbSetorder(3)
			Dbgotop()
			Dbseek(xFilial("SA2")+_cCNPJ)
			If Found()
	
				lFornec:=.T.
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Filtros da Rotina													Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Pergunte(cPerg,.F.)
				iF lFiltro
					If !Empty(MV_PAR01) .and. !Empty(MV_PAR02) .and. (SA2->A2_COD<>MV_PAR01 .OR. SA2->A2_LOJA<>MV_PAR02)
						lFornec:=.F.
					Endif
					If !Empty(MV_PAR03) .AND. !Empty(MV_PAR04) .and. (STOD(cEmissao)<MV_PAR03 .OR. STOD(cEmissao)>MV_PAR04)
						lFornec:=.F.
					Endif
					If !Empty(MV_PAR05) .AND. !Empty(MV_PAR06) .and. (strzero(val(cNota),9)<strzero(val(MV_PAR05),9) .OR. strzero(val(cNota),9)>strzero(val(MV_PAR06),9))
						lFornec:=.F.
					Endif
				Endif
			Else
				lFornec:=.F.
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Gravando XML encontrados											Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lFornec
				Incproc(SA2->A2_NREDUZ)
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verifico arquivos XML duplicados									Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				DbSelectarea("LS4")
				DbSetorder(1)
				Dbgotop()
				dbseek(SA2->A2_COD+SA2->A2_LOJA+cNota)
				If !Found()
					Reclock("LS4",.T.)
					LS4->NOTA       := cNota
					LS4->FORNECEDOR := SA2->A2_COD
					LS4->LOJA       := SA2->A2_LOJA
					MsUnlock()
					
					Reclock("LS3",.T.)
					LS3->EMISSAO  := STOD(cEmissao)
					LS3->FORNEC   := SA2->A2_COD
					LS3->LOJA     := SA2->A2_LOJA
					LS3->VENDEDOR := SUBSTR(SA2->A2_REPRES,1,30)
					LS3->TELEFONE := ALLTRIM(SA2->A2_DDD)+" "+ALLTRIM(SUBSTR(SA2->A2_TEL,1,20))
					LS3->NOME     := SA2->A2_NREDUZ
					LS3->XML      := UPPER(aXML[i])
					LS3->NOTA     := cNota
					LS3->CHAVE    := cChave
					LS3->NFREF    := _cNFREF
					LS3->SERIEORI    := cValToChar(VAL(SUBSTR(_CNFREF,23,3)))
					LS3->NFORI := SUBSTR(_CNFREF,26,9)
					MsUnlock()
					_cNFREF       := ""
					lAchou:=.T.
				Else
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Nomeclatura dos arquivos											Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					_cFileOri:="\xml\" + lower(ALLTRIM(aXML[i]))
					_cFileNew:="\xml\" + ALLTRIM(_cCNPJ)+"-nf"+ALLTRIM(cNota)+"-"+ALLTRIM(cChave)+".xml.dup"
					
					FRename(_cFileOri,_cFileNew)
					__CopyFile("\xml\*.dup","\xml\duplicado\")
					ferase(_cFileNew)
				Endif
			Endif
		ELSE
			DbSelectarea("SA1")
			DbSetorder(3)
			Dbgotop()
			IF Dbseek(xFilial("SA1")+_cCNPJ)
	
				lFornec:=.T.
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Filtros da Rotina													Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Pergunte(cPerg,.F.)
				iF lFiltro
					If !Empty(MV_PAR07) .and. !Empty(MV_PAR08) .and. (SA1->A1_COD<>MV_PAR07 .OR. SA1->A1_LOJA<>MV_PAR08)
						lFornec:=.F.
					Endif
					If !Empty(MV_PAR03) .AND. !Empty(MV_PAR04) .and. (STOD(cEmissao)<MV_PAR03 .OR. STOD(cEmissao)>MV_PAR04)
						lFornec:=.F.
					Endif
					If !Empty(MV_PAR05) .AND. !Empty(MV_PAR06) .and. (strzero(val(cNota),9)<strzero(val(MV_PAR05),9) .OR. strzero(val(cNota),9)>strzero(val(MV_PAR06),9))
						lFornec:=.F.
					Endif
				Endif
			Else
				lFornec:=.F.
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Gravando XML encontrados											Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lFornec
				Incproc(SA1->A1_NREDUZ)
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verifico arquivos XML duplicados									Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				DbSelectarea("LS4")
				DbSetorder(1)
				Dbgotop()
				IF !dbseek(SA1->A1_COD+SA1->A1_LOJA+cNota)
					Reclock("LS4",.T.)
					LS4->NOTA       := cNota
					LS4->FORNECEDOR := SA1->A1_COD
					LS4->LOJA       := SA1->A1_LOJA
					MsUnlock()
					
					Reclock("LS3",.T.)
					LS3->EMISSAO  := STOD(cEmissao)
					LS3->FORNEC   := SA1->A1_COD
					LS3->LOJA     := SA1->A1_LOJA
					LS3->VENDEDOR := SUBSTR(POSICIONE("SA3",1,XFILIAL("SA3")+SA1->A1_VEND,"A3_NOME"),1,30)
					LS3->TELEFONE := ALLTRIM(SA1->A1_DDD)+" "+ALLTRIM(SUBSTR(SA1->A1_TEL,1,20))
					LS3->NOME     := SA1->A1_NREDUZ
					LS3->XML      := UPPER(aXML[i])
					LS3->NOTA     := cNota
					LS3->CHAVE    := cChave
					LS3->NFREF    := _cNFREF
					LS3->SERIEORI := cValToChar(VAL(SUBSTR(_CNFREF,23,3)))
					LS3->NFORI    := SUBSTR(_CNFREF,26,9)
					MsUnlock()
					_cNFREF       := ""
					lAchou:=.T.
				Else
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Nomeclatura dos arquivos											Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					_cFileOri:="\xml\" + lower(ALLTRIM(aXML[i]))
					_cFileNew:="\xml\" + ALLTRIM(_cCNPJ)+"-nf"+ALLTRIM(cNota)+"-"+ALLTRIM(cChave)+".xml.dup"
					
					FRename(_cFileOri,_cFileNew)
					__CopyFile("\xml\*.dup","\xml\duplicado\")
					ferase(_cFileNew)
				Endif
			Endif		
		ENDIF
	Endif
Next

Dbselectarea("LS4")
dbCloseArea("LS4")
fErase( cArqTrab4+".DTC")
fErase( cArqTrab4+ OrdBagExt() )

If lAchou==.F.
	Msgbox("NЦo existem arquivos para serem importados no momento...519","AtenГЦo...","ALERT")
	Dbselectarea("LS1")
	dbCloseArea("LS1")
	fErase( cArqTrab+".DTC")
	fErase( cArqTrab+ OrdBagExt() )
	
	Dbselectarea("LS5")
	dbCloseArea("LS5")
	fErase( cArqTrab5+".DTC")
	fErase( cArqTrab5+ OrdBagExt() )
	
	Dbselectarea("LS3")
	dbCloseArea("LS3")
	fErase( cArqTrab3+".DTC")
	fErase( cArqTrab3+ OrdBagExt() )
	Return
Endif

cNota        := space(09)
cNatOp       := ''
_cCNPJ       := space(18)
_cMensag     := ''
nTotalNF     := 0
nTotIt       := 0
_dVencto     := ''
_cFornecedor := ''
_cTelefone   := ''
_cInscr      := ''
_cEnd        := ''
_cCidade     := ''
_cEmissao    := ''
cUm          := ''
nDescont     := 0

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё aHeaders 															Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cPict1 := "@E 99,999."
For w:=1 to cDecQtd
	cPict1 := ALLTRIM(cPict1)+"9"
Next
cPict2 := "@E 99,999."
For w:=1 to cDecUni
	cPict2 := ALLTRIM(cPict2)+"9"
Next

DbSelectarea("LS3")
Dbgotop()

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё legenda de cores													Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aCores := {{ 'LS1->OK=="X" ', 'BR_VERMELHO'  },;
{ 'EMPTY(LS1->OK) ', 'BR_VERDE'  },;
{ 'LS1->OK=="O" ', 'BR_AZUL'  }}

cMarca   := GetMark()
linverte := .F.
aTitulo  := {}
aTituloX := {}

bColor := &("{||IIF(LS1->OK == 'O',"+Str(CLR_HBLUE)+","+Str(CLR_BLACK)+")}")
cIdEnt := U_IDENTCLI()

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tela principal da rotina											Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE MSDIALOG oTela TITLE "ImportaГЦo Nota Fiscal EletrТnica - VersЦo 1.0" FROM aSize[7],0 TO aSize[6],aSize[5] of oMainWnd PIXEL

@ 004,005 BITMAP ResName "OPEN" OF oTela Size 15,15 ON CLICK (MsgRun("Importando Nota Fiscal...",,{||IMPORTA()})) NoBorder  Pixel
@ 004,305 Say  "[ Empresa/Filial: " + SM0->M0_CODIGO + "/" + SM0->M0_CODFIL + "-" + SM0->M0_FILIAL + "]" FONT oFont6 OF oTela PIXEL
@ 005,025 BUTTON "Recusar Recebimento"   SIZE 65,10 ACTION RECUSAR()
@ 005,095 BUTTON "Re_fazer Nota Fiscal"  SIZE 65,10 ACTION MsgRun("Restaurando informaГУes originais..."     ,,{||REFAZER()})
@ 005,165 BUTTON "Excluir IdentificaГЦo" SIZE 65,10 ACTION EXCAMA()
@ 005,235 BUTTON "Validar NF-e"          SIZE 65,10 ACTION MsgRun("Verificando se a NFE И vАlida na SEFAZ...",,{||SEFAZ(1)})
//@ 005,305 BUTTON "Sobre"                 SIZE 65,10 ACTION MsgRun("InformaГУes sobre o programa..."          ,,{||SOBRE() })

@ 017,025 BUTTON "Site SEFAZ" SIZE 65,10 ACTION MsgRun("Abrindo o site da SEFAZ...",,{||SEFAZ(2)})
@ 017,095 BUTTON "Elimina NF-e/Canceladas" SIZE 65,10 ACTION MsgRun("Eliminando NFE Canceladas na SEFAZ...",,{||SEFAZ(3)})
@ 017,165 BUTTON "HistСrico" SIZE 65,10 ACTION MsgRun("Processando histСrico do fornecedor...",,{||HISTFOR()})
@ 017,235 BUTTON "Recuperar XML" SIZE 65,10 ACTION RECUPXML()
@ 017,305 BUTTON "Gerar DANFE" SIZE 65,10 ACTION MsgRun("Gerando DANFE em PDF...",,{||U_ALLR001("NF",LS3->XML,"\xml\")})

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Principal 															Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ 030,005 TO 110,aPosObj[2,4] BROWSE "LS3" OBJECT OBRWP FIELDS aTituloX
OBRWP:oBrowse:BCHANGE := {||PROCESS()}
OBRWP:oBrowse:oFont := TFont():New ("Arial", 05, 18)

OBRWP:oBrowse:AddColumn(TCColumn():New("EmissЦo",   {||LS3->EMISSAO},"@D 99/99/9999",,,"LEFT",10))
OBRWP:oBrowse:AddColumn(TCColumn():New("Fornecedor",{||LS3->FORNEC},,,,"LEFT",10))
OBRWP:oBrowse:AddColumn(TCColumn():New("Loja",      {||LS3->LOJA},,,,"LEFT",15))
OBRWP:oBrowse:AddColumn(TCColumn():New("Nome",      {||LS3->NOME},,,,"LEFT",60))
OBRWP:oBrowse:AddColumn(TCColumn():New("Vendedor",  {||LS3->VENDEDOR},"@!",,,"LEFT",90))
OBRWP:oBrowse:AddColumn(TCColumn():New("Telefone",  {||LS3->TELEFONE},"@!",,,"LEFT",60))
OBRWP:oBrowse:AddColumn(TCColumn():New("Nota Fiscal EletrТnica",{||LS3->CHAVE},"@!",,,"LEFT",10))
OBRWP:oBrowse:AddColumn(TCColumn():New("Arquivo XML" ,{||LS3->XML},"@!",,,"LEFT",10))
OBRWP:oBrowse:AddColumn(TCColumn():New("XML NF Origem",{||LS3->NFREF},"@!",,,"LEFT",140))
OBRWP:oBrowse:AddColumn(TCColumn():New("Nro NF Origem",{||LS3->NFORI},"@!",,,"LEFT",60))
OBRWP:oBrowse:AddColumn(TCColumn():New("SИrie NF Origem",{||LS3->SERIEORI},"@!",,,"LEFT",60))

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Secundaria															Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
OBRWI:=MsSelect():New("LS1","","",aTitulo,@lInverte,@cMarca,{137,005,240,aPosObj[2,4]},,,,,aCores)
OBRWI:oBrowse:bLDblClick := {||CORRIGE()}
OBRWI:oBrowse:oFont := TFont():New ("Arial", 05, 18)

OBRWI:oBrowse:AddColumn(TCColumn():New("CСd.For." ,{||LS1->PRODFOR},,,,"LEFT", 25))
OBRWI:oBrowse:AddColumn(TCColumn():New("Produto"  ,{||LS1->PRODUTO},,,,"LEFT", 25))
OBRWI:oBrowse:AddColumn(TCColumn():New("DescriГЦo",{||LS1->DESCRICAO},,,,"LEFT",150))
OBRWI:oBrowse:AddColumn(TCColumn():New("UM"       ,{||LS1->UM},,,,"LEFT", 25))
/* FB
OBRWI:oBrowse:AddColumn(TCColumn():New("Emb."     ,{||LS1->QE},"@E 999999",,,"LEFT", 25))
OBRWI:oBrowse:AddColumn(TCColumn():New("Caixas"   ,{||LS1->CAIXAS},cPict1,,,"RIGHT", 25)) 
*/
OBRWI:oBrowse:AddColumn(TCColumn():New("Quant."   ,{||LS1->QUANTIDADE},cPict1,,,"RIGHT", 45))
OBRWI:oBrowse:AddColumn(TCColumn():New("PreГo R$" ,{||LS1->PRECO},cPict2,,,"RIGHT", 45))
OBRWI:oBrowse:AddColumn(TCColumn():New("Custo R$" ,{||LS1->CUSTO},"@E 9,999.99",,,"RIGHT", 45))
OBRWI:oBrowse:AddColumn(TCColumn():New("Desc.R$"  ,{||LS1->DESCONTO},"@E 99,999.99",,,"RIGHT", 45))
OBRWI:oBrowse:AddColumn(TCColumn():New("Total-Desconto R$",{||LS1->TOTAL},"@E 99,999.99",,,"RIGHT", 70))
OBRWI:oBrowse:SetBlkColor(bColor)

If lCheck2
	OBRWI:oBrowse:AddColumn(TCColumn():New("Pedido",{||LS1->PEDIDO},,,,"LEFT", 30))
	OBRWI:oBrowse:AddColumn(TCColumn():New("Item",{||LS1->ITEM},,,,"LEFT", 30))
Endif

@ 245,003 TO 315,235
@ 250,005 say "FORNECEDOR" SIZE 150,40 FONT oFont4 OF oTela PIXEL COLOR CLR_GREEN
@ 260,005 say _cFornecedor size 200,20 FONT oFont3 OF oTela PIXEL COLOR CLR_HBLUE
@ 270,005 say "CNPJ" FONT oFont1 OF oTela PIXEL
@ 270,040 say _cCNPJ size 80,20 size 50,20 FONT oFont2 OF oTela PIXEL
@ 280,005 say "EndereГo" FONT oFont1 OF oTela PIXEL
@ 280,040 say _cEnd size 170,20 FONT oFont2 OF oTela PIXEL
@ 300,005 say "Cidade/UF" FONT oFont1 OF oTela PIXEL
@ 300,040 say _cCidade size 150,20 size 100,20 FONT oFont2 OF oTela PIXEL

@ 245,240 TO 315,435
@ 250,250 say "NOTA FISCAL" FONT oFont4 OF oTela PIXEL COLOR CLR_GREEN
@ 260,250 say "EmissЦo" FONT oFont1 OF oTela PIXEL
@ 260,290 say _cEmissao size 80,40 picture "@D 99/99/9999" FONT oFont3 OF oTela PIXEL
@ 270,250 say "Total-Desconto R$" FONT oFont1 OF oTela PIXEL
@ 270,300 say nTotalNF size 80,40 picture "@E 99,999.99" FONT oFont3 OF oTela PIXEL

@ 270,360 say "Vencimento" FONT oFont1 OF oTela PIXEL
@ 271,395 say _dVencto size 80,40 picture "@D 99/99/99" FONT oFont2 OF oTela PIXEL COLOR CLR_HRED

@ 280,250 say "Qtd.Itens" FONT oFont1 OF oTela PIXEL
@ 280,290 say nTotIt size 40,40 picture "@E 9999" FONT oFont3 OF oTela PIXEL
@ 290,250 say "Nat.OperaГЦo" FONT oFont1 OF oTela PIXEL
@ 290,290 say SUBSTR(ALLTRIM(cNatOP),1,32) size 180,40 picture "@!" FONT oFont2 OF oTela PIXEL COLOR CLR_HRED
@ 300,250 say "SИrie/Nota Fiscal" FONT oFont1 OF oTela PIXEL
@ 300,310 say ALLTRIM(cSerie)+"-"+cNota size 95,40 picture "@!" FONT oFont3 OF oTela PIXEL COLOR CLR_MAGENTA

@ 112,025 BUTTON "_HistСrico" SIZE 65,10 ACTION VIEWPROD(LS1->PRODUTO)
@ 112,095 BUTTON "CСd.Barras" SIZE 65,10 ACTION CODBAR()
@ 112,165 BUTTON "_Mensagem Nota" SIZE 65,10 ACTION MSGNF(_cMensag)
@ 112,235 BUTTON "Refa_z Desconto" SIZE 65,10 ACTION REFDESC()

@ 124,025 BUTTON "Legenda" SIZE 65,10 ACTION LEGENDA()
If lCheck2
	@ 124,095 BUTTON "_Selecionar Pedido" SIZE 65,10 ACTION PROCPED()
	@ 124,165 BUTTON "_Eliminar Pedido do item" SIZE 65,10 ACTION ELIMPED()
	@ 124,235 BUTTON "Eliminar _Todos Pedidos" SIZE 65,10 ACTION ELIMPEDT()
Endif
If aSize[5] >=1220
	@ 018,055 BITMAP SIZE 110,110 FILE "LogoNFE.BMP" NOBORDER
	@ 018,065 BITMAP SIZE 110,110 FILE ALLTRIM(cLogo)+".BMP" NOBORDER
Endif

ACTIVATE MSDIALOG oTela CENTERED

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Apagando arquivos temporarios										Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Dbselectarea("LS1")
dbCloseArea("LS1")
fErase( cArqTrab+".DTC")
fErase( cArqTrab+ OrdBagExt() )

Dbselectarea("LS5")
dbCloseArea("LS5")
fErase( cArqTrab5+".DTC")
fErase( cArqTrab5+ OrdBagExt() )

Dbselectarea("LS3")
dbCloseArea("LS3")
fErase( cArqTrab3+".DTC")
fErase( cArqTrab3+ OrdBagExt() )
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Gerando pre nota													Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function IMPORTA()

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifico se existe a nota fiscal									Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
IF !file("\xml\"+lower(LS3->XML))
	msgbox("Este arquivo jА foi processado por outro usuАrio!","AtenГЦo...","ALERT")
	Reclock("LS3",.F.)
	dbdelete()
	MsUnlock()
	
	DbSelectarea("LS3")
	Dbgotop()
	PROCESS()
	Return
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificando se todas as variaveis foram preenchidas					Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(cNota)
	Msgbox("Numero de nota fiscal nЦo encontrada!")
	Return
Endif
If Empty(_cCNPJ)
	Msgbox("Dados do fornecedor nЦo encontradosNumero de nota fiscal nЦo encontrada!")
	Return
Endif
If nTotIt<=0
	Msgbox("Nota fiscal nЦo contem itens!")
	Return
Endif
If nTotalNF<=0
	Msgbox("Nota fiscal sem valores das mercadorias!")
	Return
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificando se todos os produtos foram identificados				Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
lIdent:=.F.
DbSelectarea("LS1")
Dbgotop()
While !Eof()
	IF LS1->OK=="X"
		lIdent:=.T.
	Endif
	Dbskip()
End
Dbgotop()

If lIdent
	Msgbox("Existem produtos nЦo identificados, corrija primeiro!","AtenГЦo...","ALERT")
	Return
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificando a segunda unidade medida x unidade medida item nota fiscal  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
_lErroSeg := .F.
_cMsg     := ""
DbSelectarea("LS1")
Dbgotop()
While !Eof()
	dbSelectArea("SB1")
	dbSetOrder(1)
	IF dbSeek(XFILIAL("SB1")+PADR(LS1->PRODUTO,TAMSX3("B1_COD")[1]))
		IF ALLTRIM(LS1->UM) <> ALLTRIM(SB1->B1_UM)
			IF !EMPTY(SB1->B1_SEGUM)
				IF ALLTRIM(SB1->B1_SEGUM) <> ALLTRIM(LS1->UM)
					_cMsg += "- "+ALLTRIM(SB1->B1_COD)+" - Segunda Unidade: "+ALLTRIM(SB1->B1_SEGUM)+" esta diferente da Unidade do item no XML: "+ALLTRIM(LS1->UM)+chr(13)+chr(10)
					_lErroSeg := .T.
				ENDIF
			ELSE
				_cMsg += "- "+ALLTRIM(SB1->B1_COD)+" - Unidade: "+ALLTRIM(SB1->B1_UM)+" esta diferente da Unidade do item no XML: "+ALLTRIM(LS1->UM)+chr(13)+chr(10)
				_lErroSeg := .T.				
			ENDIF
		ENDIF
	ENDIF
	LS1->(Dbskip())
End
Dbgotop()

If _lErroSeg
	Msgbox("Existem produtos com problema na segunda unidade de medida, corrija primeiro!"+chr(13)+chr(10)+;
	_cMsg,"AtenГЦo...","ALERT")
	Return
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificando se o pedido foi feito por item							Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If cPedCom .AND. EMPTY(LS3->NFREF)
	lItem:=.F.
	DbSelectarea("LS1")
	Dbgotop()
	While !Eof()
		IF !Empty(LS1->PEDIDO)
			lItem:=.T.
		Endif
		Dbskip()
	End
	
	If lItem
		DbSelectarea("LS1")
		Dbgotop()
		While !Eof()
			IF Empty(LS1->PEDIDO)
				Dbgotop()
				Msgbox("Existem produtos sem o pedido de compras, favor corrigi-los primeiro!","AtenГЦo...","ALERT")
				Return
			Endif
			Dbskip()
		End
	Endif
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Gerar pedido itens sem pedidos de compras							Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	lSemPed:=.F.
	If lItem
		DbSelectarea("LS1")
		Dbgotop()
		While !Eof()
			IF ALLTRIM(LS1->PEDIDO)=="CRIAR"
				lSemPed:=.T.
			Endif
			Dbskip()
		End
	Endif
	
	If lSemped
		cResp := msgbox("Deseja gerar o pedido para os itens que nЦo tem pedido de compra?","AtenГЦo...","YESNO")
		If cResp
			NEWPED2()
		Else
			DbSelectarea("LS1")
			dbgotop()
			Return
		Endif
	Endif
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verificando se os produtos existem saldos no pedidos				Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lItem .and. !lSemPed
		DbSelectarea("LS1")
		Dbgotop()
		While !Eof()
			IF !Empty(LS1->PEDIDO)
				aProdutos	:= {{"PRODUTO","C",15,0 },;
				{"DESCRICAO","C",50,0 },;
				{"QUANTIDADE","N",12,3 },;
				{"PEDIDO","C",6,0 },;
				{"ITEM","C",4,0 },;
				{"PRECO","N",18,7 }}
				
				cArqTrabp  := CriaTrab(aProdutos)
				dbUseArea( .T.,, cArqTrabp, "PRO", if(.F. .OR. .F., !.F., NIL), .F. )
				IndRegua("PRO",cArqTrabp,"PEDIDO+PRODUTO+ITEM",,,)
				dbSetIndex( cArqTrabp +OrdBagExt())
				dbSelectArea("PRO")
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Aglutinando produtos iguais											Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				DbSelectarea("LS1")
				Dbsetorder(1)
				Dbgotop()
				While !Eof()
					DbSelectarea("PRO")
					DbSetorder(1)
					Dbgotop()
					Dbseek(LS1->PEDIDO+LS1->PRODUTO+LS1->ITEM)
					If !Found()
						Reclock("PRO",.T.)
						PRO->PRODUTO:=LS1->PRODUTO
						PRO->QUANTIDADE:=LS1->QUANTIDADE
						PRO->DESCRICAO:=LS1->DESCRICAO
						PRO->PRECO:=LS1->PRECO
						PRO->PEDIDO:=LS1->PEDIDO
						PRO->ITEM:=LS1->ITEM
						MsUnlock()
					Else
						Reclock("PRO",.F.)
						PRO->QUANTIDADE:=(PRO->QUANTIDADE+LS1->QUANTIDADE)
						MsUnlock()
					Endif
					DbSelectarea("LS1")
					Dbskip()
				End
			Endif
			DbSelectarea("LS1")
			Dbskip()
		End
		
		cMsg:=''
		DbSelectArea("PRO")
		Dbgotop()
		While !Eof()
			cQuery:=" SELECT (C7_QUANT-C7_QUJE-C7_QTDACLA) QUANT FROM SC7"+SM0->M0_CODIGO+"0 WHERE C7_FILIAL='"+xFilial("SC7")+"' "
			cQuery:=cQuery + " AND C7_NUM='"+PRO->PEDIDO+"' "
			cQuery:=cQuery + " AND C7_PRODUTO='"+PRO->PRODUTO+"' "
			cQuery:=cQuery + " AND C7_ITEM='"+PRO->ITEM+"' "
			cQuery:=cQuery + " AND C7_RESIDUO<>'S' "
			cQuery:=cQuery + " AND (C7_QUANT-C7_QUJE-C7_QTDACLA>0) "
			cQuery:=cQuery + " AND C7_ENCER<>'E' "
			cQuery:=cQuery + " AND D_E_L_E_T_<>'*' "
			cQuery:=cQuery + " ORDER BY C7_EMISSAO DESC "
			TCQUERY cQuery NEW ALIAS "TCQ"
			DbSelectarea("TCQ")
			IF PRO->QUANTIDADE>TCQ->QUANT
				cMsg:=cMsg+PRO->PEDIDO+"   "+PRO->ITEM+"   "+ALLTRIM(PRO->PRODUTO)+"   "+PRO->DESCRICAO+ENTER
			Endif
			Dbclosearea("TCQ")
			DbSelectArea("PRO")
			Dbskip()
		End
		Dbselectarea("PRO")
		dbCloseArea("PRO")
		fErase( cArqTrabp+".DTC")
		fErase( cArqTrabp+ OrdBagExt() )
		
		If !Empty(cMsg)
			DEFINE MSDIALOG oProdd FROM 0,0 TO 300,420 PIXEL TITLE "Produtos sem Saldos Disponiveis no pedido..."
			@ 005,005 say " Pedido       Item       Produto    DescriГЦo" SIZE 150,40 FONT oFont1 OF oProdd PIXEL COLOR CLR_HBLUE
			@ 015,005 GET oMemo VAR cMsg MEMO SIZE 200,135 FONT oFont6 PIXEL OF oProdd
			ACTIVATE MSDIALOG oProdd CENTER
			DbSelectarea("LS1")
			Dbgotop()
			Return
		Endif
	Endif
Endif

/* FB
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Valida se o preco esta proximo do correto							Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

cMsg:=''
DbSelectarea("LS1")
Dbgotop()
While !Eof()
	IF LS1->CUSTO>0
		IF 100-((LS1->PRECO/LS1->CUSTO)*100)>10 .OR. 100-((LS1->PRECO/LS1->CUSTO)*100)<-10
			cMsg:=cMsg+ALLTRIM(LS1->PRODUTO)+"  "+SUBSTR(LS1->DESCRICAO,1,35)+ENTER
			cMsg:=cMsg+"PreГo Nota R$ "+transform(LS1->PRECO,"@E 9,999.99")+"   Custo Anterior R$"+transform(LS1->CUSTO,"@E 9,999.99")+ENTER
			cMsg:=cMsg+ENTER
			
			Reclock("LS1",.F.)
			LS1->OK:="O"
			MsUnlock()
		Endif
	Endif
	Dbskip()
End
Dbgotop()

If !Empty(cMsg)
	lSaida:=.F.
	DEFINE MSDIALOG oProdd FROM 0,0 TO 330,420 PIXEL TITLE "Produtos com 10% de DivergЙncia de preГos..."
	@ 005,005 GET oMemo VAR cMsg MEMO SIZE 200,135 FONT oFont6 PIXEL OF oProdd
	@ 150,005 BUTTON "<< Voltar" SIZE 55,10 ACTION oProdd:end()
	@ 150,070 BUTTON "Continuar >>" SIZE 55,10 ACTION (lsaida:=.T.,oProdd:end())
	ACTIVATE MSDIALOG oProdd CENTER
	
	If lSaida==.F.
		Return
	Endif
Endif
*/
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controla pedidos de compras											Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If cPedCom .AND. EMPTY(LS3->NFREF)
	
	If !lItem
		
		aProdutos	:= {{"PRODUTO","C",15,0 },;
		{"DESCRICAO","C",50,0 },;
		{"QUANTIDADE","N",12,3 },;
		{"PRECO","N",18,7 }}
		
		cArqTrabp  := CriaTrab(aProdutos)
		dbUseArea( .T.,, cArqTrabp, "PRO", if(.F. .OR. .F., !.F., NIL), .F. )
		IndRegua("PRO",cArqTrabp,"PRODUTO",,,)
		dbSetIndex( cArqTrabp +OrdBagExt())
		dbSelectArea("PRO")
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Aglutinando produtos iguais											Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		DbSelectarea("LS1")
		Dbsetorder(1)
		Dbgotop()
		While !Eof()
			DbSelectarea("PRO")
			DbSetorder(1)
			Dbgotop()
			Dbseek(LS1->PRODUTO)
			If !Found()
				Reclock("PRO",.T.)
				PRO->PRODUTO    := LS1->PRODUTO
				PRO->QUANTIDADE := LS1->QUANTIDADE
				PRO->DESCRICAO  := LS1->DESCRICAO
				PRO->PRECO      := LS1->PRECO
				MsUnlock()
			Else
				Reclock("PRO",.F.)
				PRO->QUANTIDADE:=(PRO->QUANTIDADE+LS1->QUANTIDADE)
				MsUnlock()
			Endif
			DbSelectarea("LS1")
			Dbskip()
		End
		
		aCampos2	:= {{"OK","C",1,0 },;
		{"EMISSAO","D",8,0 },;
		{"PEDIDO","C",6,0 },;
		{"LOJA","C",2,0 },;
		{"ITENS","N",5,0 },;
		{"ENTREGA","D",8,0 },;
		{"QTDIT","N",5,0 },;
		{"VALIDO","N",5,0 }}
		
		cArqTrab2  := CriaTrab(aCampos2)
		cIndice:="Descend(DTOS(EMISSAO))"
		dbUseArea( .T.,, cArqTrab2, "LS2", if(.F. .OR. .F., !.F., NIL), .F. )
		IndRegua("LS2",cArqTrab2,cIndice,,,)
		dbSetIndex( cArqTrab2 +OrdBagExt())
		dbSelectArea("LS2")
		
		lAchou:=.f.
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verificando pedidos em aberto										Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cQuery:=" SELECT C7_EMISSAO EMISSAO,C7_LOJA LOJA,C7_NUM PEDIDO,MAX(C7_DATPRF) ENTREGA,COUNT(*) QTD FROM SC7"+SM0->M0_CODIGO+"0 WHERE C7_FILIAL='"+xFilial("SC7")+"' "
		cQuery:=cQuery + " AND C7_FORNECE='"+LS3->FORNEC+"' "
		cQuery:=cQuery + " AND C7_EMISSAO>='"+DTOS(DDATABASE-60)+"' "
		cQuery:=cQuery + " AND (C7_QUANT-C7_QUJE-C7_QTDACLA>0) "
		cQuery:=cQuery + " AND C7_ENCER<>'E' "
		cQuery:=cQuery + " AND D_E_L_E_T_<>'*' "
		cQuery:=cQuery + " AND C7_RESIDUO<>'S' "
		cQuery:=cQuery + " GROUP BY C7_EMISSAO,C7_NUM,C7_LOJA "
		cQuery:=cQuery + " ORDER BY C7_EMISSAO DESC "
		TCQUERY cQuery NEW ALIAS "TCQ"
		DbSelectarea("TCQ")
		While !Eof()
			Reclock("LS2",.T.)
			LS2->EMISSAO := STOD(TCQ->EMISSAO)
			LS2->PEDIDO  := TCQ->PEDIDO
			LS2->LOJA    := TCQ->LOJA
			LS2->ITENS   := TCQ->QTD
			LS2->ENTREGA := STOD(TCQ->ENTREGA)
			Msunlock()
			lAchou:=.T.
			DbSelectarea("TCQ")
			Dbskip()
		End
		DbClosearea("TCQ")
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifico quantidade de itens do pedidos e usados					Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		DbSelectarea("LS2")
		Dbgotop()
		While !Eof()
			cQuery:=" SELECT COUNT(*) QTD FROM SC7"+SM0->M0_CODIGO+"0 WHERE C7_FILIAL='"+xFilial("SC7")+"' AND C7_NUM='"+LS2->PEDIDO+"' "
			cQuery:=cQuery + " AND D_E_L_E_T_<>'*' "
			TCQUERY cQuery NEW ALIAS "TCQ"
			DbSelectarea("TCQ")
			_nUsados:=TCQ->QTD
			DbClosearea("TCQ")
			
			DbSelectarea("LS2")
			Reclock("LS2",.F.)
			LS2->QTDIT:=_nUsados
			MsUnlock()
			Dbskip()
		End
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifico Itens validos												Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		DbSelectarea("LS2")
		Dbgotop()
		While !Eof()
			_nItem:=0
			Dbselectarea("PRO")
			Dbgotop()
			While !Eof()
				DbSelectarea("SC7")
				DbSetorder(4)
				Dbgotop()
				Dbseek(xFilial("SC7")+PRO->PRODUTO+LS2->PEDIDO)
				If Found() .and. (SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA>0) .AND. (SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA>=PRO->QUANTIDADE) .AND. SC7->C7_RESIDUO<>"S"
					_nItem:=_nItem+1
				Endif
				Dbselectarea("PRO")
				Dbskip()
			End
			
			DbSelectarea("LS2")
			Reclock("LS2",.F.)
			IF _nItem==nTotIt
				LS2->OK:="X"
			Endif
			LS2->VALIDO:=_nItem
			MsUnlock()
			Dbskip()
		End
		Dbselectarea("LS1")
		Dbgotop()
		
		Dbselectarea("LS2")
		Dbgotop()
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё aHeader dos pedidos													Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aTitulo2 := {}
		AADD(aTitulo2,{"EMISSAO","EmissЦo"})
		AADD(aTitulo2,{"PEDIDO","Pedido"})
		AADD(aTitulo2,{"LOJA","Lj"})
		AADD(aTitulo2,{"QTDIT","Itens","@E 9999"})
		AADD(aTitulo2,{"ITENS","Abertos","@E 9999"})
		AADD(aTitulo2,{"VALIDO","VАlidos","@E 9999"})
		AADD(aTitulo2,{"ENTREGA","Dt.Entrega"})
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Tela dos pedidos em aberto											Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lAchou
			@ 120,040 TO 400,590 DIALOG oPedido TITLE "Pedidos em aberto..."
			@ 005,005 BITMAP ResName "CHECKED" OF oPedido Size 15,15 ON CLICK (VALIDA())  NoBorder  Pixel
			@ 005,035 BUTTON "A_tualizar Pedido" SIZE 55,10 ACTION PEDIDOS()
			@ 005,095 BUTTON "_Abrir Pedido" SIZE 55,10 ACTION F030PCVIS(xFilial("SC7"),LS2->PEDIDO)
			@ 005,155 BUTTON "_DivergЙncias" SIZE 55,10 ACTION DIVERG()
			@ 005,215 BUTTON "_Eliminar" SIZE 55,10 ACTION ELIMINAR()
			@ 020,005 TO 140,275 BROWSE "LS2" ENABLE " LS2->OK<>'X' " OBJECT OBRWT FIELDS aTitulo2
			OBRWT:oBrowse:oFont := TFont():New ("Arial", 05, 18)
			ACTIVATE DIALOG oPedido CENTER
		Else
			Msgbox("NЦo existem pedidos em aberto para este fornecedor!")
			/* FB 
			cResp:=Msgbox("Deseja gerar um pedido automaticamente para esta nota eletrТnica?","AtenГЦo...","YESNO")
			If cResp
				NEWPED()
			Endif
			*/
		Endif
		
		Dbselectarea("PRO")
		dbCloseArea("PRO")
		fErase( cArqTrabp+".DTC")
		fErase( cArqTrabp+ OrdBagExt() )
		
		Dbselectarea("LS2")
		dbCloseArea("LS2")
		fErase( cArqTrab2+".DTC")
		fErase( cArqTrab2+ OrdBagExt() )
	Else
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Gerar pre nota														Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		VALIDA()
	Endif
Else
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Nao controla pedidos de compras										Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cRet:=.T.
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Manipulando numero da nota fiscal									Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If cZeros
		cNota:=strzero(val(cNota),9)
	Endif
	cSpaco:=9-LEN(ALLTRIM(cNota))
	
	cResp := msgbox("Deseja gerar a prИ-nota fiscal "+cNota+" agora?","AtenГЦo...","YESNO")
	
	If cResp
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifico se a pre nota ja existe									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		dbSelectArea("SF1")
		DbSetorder(2)
		Dbgotop()
		Dbseek(xFilial("SF1")+LS3->FORNEC+LS3->LOJA+ALLTRIM(cNota)+Space(cSpaco))
		If Found() .and. SF1->F1_TIPO=="N"
			
			Msgbox("Nota fiscal jА existe!","AtenГЦo...","ALERT")
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Dados do fornecedor													Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			DbSelectarea("SA2")
			DbSetorder(1)
			Dbgotop()
			Dbseek(xFilial("SA2")+LS3->FORNEC+LS3->LOJA)
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Nomeclatura dos arquivos											Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			_cFileOri:="\xml\"+ALLTRIM(LS3->XML)
			_cFileNew:="\xml\"+ALLTRIM(SA2->A2_CGC)+"-nf"+ALLTRIM(LS3->NOTA)+"-"+ALLTRIM(LS3->CHAVE)+".xml.imp"
			
			FRename(_cFileOri,_cFileNew)
			__CopyFile("\xml\*.imp","\xml\importado\")
			ferase(_cFileNew)
			
			Reclock("LS3",.F.)
			dbdelete()
			MsUnlock()
			
			DbSelectarea("LS3")
			Dbgotop()
			
			DbSelectarea("LS1")
			Dbsetorder(1)
			Dbgotop()
			While !Eof()
				Reclock("LS1",.F.)
				dbdelete()
				MsUnlock()
				Dbskip()
			End
			
			DbSelectarea("LS5")
			Dbsetorder(1)
			Dbgotop()
			While !Eof()
				Reclock("LS5",.F.)
				dbdelete()
				MsUnlock()
				Dbskip()
			End
			
			PROCESS()
			Return
		Endif
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Gravando pre nota entrada											Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		MsgRun("Gerando prИ nota entrada No.:"+cNota,,{|| cRet := PRENOTA()})
		cNotaAtu:=cNota
		
		If cRet
			DbSelectarea("LS1")
			Dbsetorder(1)
			Dbgotop()
			While !Eof()

				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Atualizando NCM do produto de acordo com o XML do fornecedor		Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				IF !Empty(LS1->NCM) .AND. _lNCM 
					DbSelectarea("SB1")
					DbSetorder(1)
					Dbgotop()
					IF Dbseek(xFilial("SB1")+LS1->PRODUTO)
						Reclock("SB1",.F.)
						SB1->B1_POSIPI:=LS1->NCM
						MsUnlock()
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Caso nao possua codigo de barras e feita a gravacao					Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If Empty(SB1->B1_CODBAR) .AND. !Empty(LS1->CODBAR)
							Reclock("SB1",.F.)
							SB1->B1_CODBAR:=ALLTRIM(LS1->CODBAR)
							MsUnlock()
						Endif
					Endif
				Endif
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Gravando amarracao produto x fornecedor								Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If !Empty(LS1->PRODFOR)
					IF EMPTY(LS3->NFREF) .OR. (!EMPTY(LS3->NFREF) .AND. _cTIPONF == "B")
						DbSelectarea("SA5")
						DbSetorder(1) //A5_FILIAL, A5_FORNECE, A5_LOJA, A5_PRODUTO, A5_FABR, A5_FALOJA, R_E_C_N_O_, D_E_L_E_T_
						Dbgotop()
						If !Dbseek(xFilial("SA5")+PADR(LS3->FORNEC,TAMSX3("A5_FORNECE")[1])+PADR(LS3->LOJA,TAMSX3("A5_LOJA")[1])+PADR(LS1->PRODUTO,TAMSX3("A5_PRODUTO")[1]))
							Reclock("SA5",.T.)
							SA5->A5_FILIAL:=xFilial("SA5")
							SA5->A5_FORNECE:=LS3->FORNEC
							SA5->A5_LOJA:=LS3->LOJA
							SA5->A5_CODPRF:=LS1->PRODFOR
							SA5->A5_PRODUTO:=LS1->PRODUTO
							SA5->A5_NOMPROD:=SUBSTR(POSICIONE("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_DESC"),1,30)
							SA5->A5_NOMEFOR:=POSICIONE("SA2",1,xFilial("SA2")+LS3->FORNEC+LS3->LOJA,"A2_NREDUZ")
							MsUnlock()
						Else
							Reclock("SA5",.F.)
							SA5->A5_CODPRF:=LS1->PRODFOR
							MsUnlock()
						Endif
					ELSE
						
						DbSelectarea("SA7")
						DbSetorder(1) //A7_FILIAL, A7_CLIENTE, A7_LOJA, A7_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
						If !Dbseek(xFilial("SA7")+PADR(LS3->FORNEC,TAMSX3("A7_CLIENTE")[1])+PADR(LS3->LOJA,TAMSX3("A7_LOJA")[1])+PADR(LS1->PRODUTO,TAMSX3("A7_PRODUTO")[1]))
							Reclock("SA7",.T.)
							SA7->A7_FILIAL  := xFilial("SA7")
							SA7->A7_CLIENTE := LS3->FORNEC
							SA7->A7_LOJA    := LS3->LOJA
							SA7->A7_CODCLI  := LS1->PRODFOR
							SA7->A7_PRODUTO := LS1->PRODUTO
							SA7->A7_DESCCLI := LS1->DESCRICAO
							SA7->(MsUnlock())
						Else
							Reclock("SA7",.F.)
							SA7->A7_CODCLI := LS1->PRODFOR
							SA7->(MsUnlock())
						Endif
											
					ENDIF
				Endif
				DbSelectarea("LS1")
				Dbskip()
			End
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Apagando dados da tabela temporaria									Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			DbSelectarea("LS1")
			Dbsetorder(1)
			Dbgotop()
			While !Eof()
				Reclock("LS1",.F.)
				dbdelete()
				MsUnlock()
				Dbskip()
			End
			
			DbSelectarea("LS3")
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Dados do fornecedor													Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			DbSelectarea("SA2")
			DbSetorder(1)
			Dbgotop()
			Dbseek(xFilial("SA2")+LS3->FORNEC+LS3->LOJA)
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Nomeclatura dos arquivos											Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			_cFileOri:="\xml\"+ALLTRIM(LS3->XML)
			_cFileNew:="\xml\"+ALLTRIM(SA2->A2_CGC)+"-nf"+ALLTRIM(LS3->NOTA)+"-"+ALLTRIM(LS3->CHAVE)+".xml.imp"
			
			FRename(_cFileOri,_cFileNew)
			__CopyFile("\xml\*.imp","\xml\importado\")
			ferase(_cFileNew)
			
			Reclock("LS3",.F.)
			dbdelete()
			MsUnlock()
			
			DbSelectarea("LS3")
			Dbgotop()
			Msgbox("PrИ-Nota "+cNotaAtu+" gerada com sucesso!","AtenГЦo...","INFO")
			PROCESS()
		Endif
	Endif
Endif
Dbselectarea("LS1")
Dbgotop()
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Valida pedido														Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function VALIDA()

iF !lItem
	If LS2->OK<>"X"
		Msgbox("Este pedido nЦo atende as necessidades da nota fiscal!")
		Return
	Endif
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Validando o Pedido													Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Dbselectarea("LS1")
Dbgotop()
While !Eof()
	cQuery:=" SELECT C7_NUM PEDIDO,C7_LOCAL ALMOX,C7_TES TES,C7_ITEM ITEM,(C7_QUANT-C7_QUJE-C7_QTDACLA) QUANT FROM SC7"+SM0->M0_CODIGO+"0 WHERE C7_FILIAL='"+xFilial("SC7")+"' "
	IF !lItem
		cQuery:=cQuery + " AND C7_NUM='"+LS2->PEDIDO+"' "
	Else
		cQuery:=cQuery + " AND C7_NUM='"+LS1->PEDIDO+"' "
		cQuery:=cQuery + " AND C7_ITEM='"+LS1->ITEM+"' "
	Endif
	cQuery:=cQuery + " AND C7_PRODUTO='"+LS1->PRODUTO+"' "
	cQuery:=cQuery + " AND (C7_QUANT-C7_QUJE-C7_QTDACLA>0) "
	cQuery:=cQuery + " AND C7_ENCER<>'E' "
	cQuery:=cQuery + " AND C7_RESIDUO<>'S' "
	cQuery:=cQuery + " AND D_E_L_E_T_<>'*' "
	TCQUERY cQuery NEW ALIAS "TCQ"
	DbSelectarea("TCQ")
	While !Eof()
		IF (TCQ->QUANT >= LS1->QUANTIDADE) .AND. TCQ->QUANT > 0 .AND. LS1->QUANTIDADE > 0
			Reclock("LS1",.F.)
			LS1->PEDIDO := TCQ->PEDIDO
			LS1->ITEM   := TCQ->ITEM
			LS1->TES    := TCQ->TES
			LS1->ALMOX  := TCQ->ALMOX
			MsUnlock()
		Endif
		DbSelectarea("TCQ")
		Dbskip()
	End
	DbClosearea("TCQ")
	Dbselectarea("LS1")
	Dbskip()
End

lEntrou:=.f.
DbSelectarea("LS1")
Dbgotop()
While !Eof()
	IF Empty(LS1->PEDIDO) .or. Empty(LS1->ITEM)
		Msgbox("O Produto "+ALLTRIM(LS1->PRODUTO)+" nЦo possui pedido/Item!")
		lEntrou:=.T.
	Endif
	Dbskip()
End

If lEntrou
	Msgbox("Existem produtos sem o pedido/item!")
	Return
Endif

cRet:=.F.

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Manipulando numero da nota fiscal									Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If cZeros
	cNota:=strzero(val(cNota),9)
Endif
cSpaco:=9-LEN(ALLTRIM(cNota))

cResp:=msgbox("Deseja gerar a prИ-nota fiscal "+cNota+" agora?","AtenГЦo...","YESNO")

If cResp
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifico se a pre nota ja existe									Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("SF1")
	DbSetorder(2)
	Dbgotop()
	Dbseek(xFilial("SF1")+LS3->FORNEC+LS3->LOJA+ALLTRIM(cNota)+Space(cSpaco))
	If Found() .and. SF1->F1_TIPO=="N"
		
		Msgbox("Nota fiscal jА existe!","AtenГЦo...","ALERT")
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Dados do fornecedor													Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		DbSelectarea("SA2")
		DbSetorder(1)
		Dbgotop()
		Dbseek(xFilial("SA2")+LS3->FORNEC+LS3->LOJA)
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Nomeclatura dos arquivos											Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		_cFileOri:="\xml\"+ALLTRIM(LS3->XML)
		_cFileNew:="\xml\"+ALLTRIM(SA2->A2_CGC)+"-nf"+ALLTRIM(LS3->NOTA)+"-"+ALLTRIM(LS3->CHAVE)+".xml.imp"
		
		FRename(_cFileOri,_cFileNew)
		__CopyFile("\xml\*.imp","\xml\importado\")
		ferase(_cFileNew)
		
		Reclock("LS3",.F.)
		dbdelete()
		MsUnlock()
		
		DbSelectarea("LS3")
		Dbgotop()
		
		DbSelectarea("LS1")
		Dbsetorder(1)
		Dbgotop()
		While !Eof()
			Reclock("LS1",.F.)
			dbdelete()
			MsUnlock()
			Dbskip()
		End
		
		DbSelectarea("LS5")
		Dbsetorder(1)
		Dbgotop()
		While !Eof()
			Reclock("LS5",.F.)
			dbdelete()
			MsUnlock()
			Dbskip()
		End
		
		PROCESS()
		oPedido:end()
		Return
	Endif
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Gravando pre nota entrada											Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	MsgRun("Gerando prИ nota entrada No.:"+cNota,,{||PRENOTA()})
	cNotaAtu:=cNota
	
	If cRet
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Gravando amarracao produto x fornecedor								Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		DbSelectarea("LS1")
		Dbsetorder(1)
		Dbgotop()
		While !Eof()
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Atualizando NCM do produto de acordo com o XML do fornecedor		Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			IF !Empty(LS1->NCM) .AND. _lNCM
				DbSelectarea("SB1")
				DbSetorder(1)
				Dbgotop()
				Dbseek(xFilial("SB1")+LS1->PRODUTO)
				If Found()
					Reclock("SB1",.F.)
					SB1->B1_POSIPI:=LS1->NCM
					MsUnlock()
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Gravando amarracao produto x fornecedor								Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If !Empty(LS1->PRODFOR)
					IF EMPTY(LS3->NFREF) .OR. (!EMPTY(LS3->NFREF) .AND. _cTIPONF == "B")
						DbSelectarea("SA5")
						DbSetorder(1) //A5_FILIAL, A5_FORNECE, A5_LOJA, A5_PRODUTO, A5_FABR, A5_FALOJA, R_E_C_N_O_, D_E_L_E_T_
						Dbgotop()
						If !Dbseek(xFilial("SA5")+PADR(LS3->FORNEC,TAMSX3("A5_FORNECE")[1])+PADR(LS3->LOJA,TAMSX3("A5_LOJA")[1])+PADR(LS1->PRODUTO,TAMSX3("A5_PRODUTO")[1]))
							Reclock("SA5",.T.)
							SA5->A5_FILIAL:=xFilial("SA5")
							SA5->A5_FORNECE:=LS3->FORNEC
							SA5->A5_LOJA:=LS3->LOJA
							SA5->A5_CODPRF:=LS1->PRODFOR
							SA5->A5_PRODUTO:=LS1->PRODUTO
							SA5->A5_NOMPROD:=SUBSTR(POSICIONE("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_DESC"),1,30)
							SA5->A5_NOMEFOR:=POSICIONE("SA2",1,xFilial("SA2")+LS3->FORNEC+LS3->LOJA,"A2_NREDUZ")
							MsUnlock()
						Else
							Reclock("SA5",.F.)
							SA5->A5_CODPRF:=LS1->PRODFOR
							MsUnlock()
						Endif

					ELSE
						
						DbSelectarea("SA7")
						DbSetorder(1) //A7_FILIAL, A7_CLIENTE, A7_LOJA, A7_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
						If !Dbseek(xFilial("SA7")+PADR(LS3->FORNEC,TAMSX3("A7_CLIENTE")[1])+PADR(LS3->LOJA,TAMSX3("A7_LOJA")[1])+PADR(LS1->PRODUTO,TAMSX3("A7_PRODUTO")[1]))
							Reclock("SA7",.T.)
							SA7->A7_FILIAL  := xFilial("SA7")
							SA7->A7_CLIENTE := LS3->FORNEC
							SA7->A7_LOJA    := LS3->LOJA
							SA7->A7_CODCLI  := LS1->PRODFOR
							SA7->A7_PRODUTO := LS1->PRODUTO
							SA7->A7_DESCCLI := LS1->DESCRICAO
							SA7->(MsUnlock())
						Else
							Reclock("SA7",.F.)
							SA7->A7_CODCLI := LS1->PRODFOR
							SA7->(MsUnlock())
						Endif
											
					ENDIF
			Endif

			DbSelectarea("LS1")
			Dbskip()
		End
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Apagando dados da tabela temporaria									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		DbSelectarea("LS1")
		Dbsetorder(1)
		Dbgotop()
		While !Eof()
			Reclock("LS1",.F.)
			dbdelete()
			MsUnlock()
			Dbskip()
		End
		
		DbSelectarea("LS3")
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Dados do fornecedor													Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		DbSelectarea("SA2")
		DbSetorder(1)
		Dbgotop()
		Dbseek(xFilial("SA2")+LS3->FORNEC+LS3->LOJA)
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Nomeclatura dos arquivos											Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		_cFileOri:="\xml\"+ALLTRIM(LS3->XML)
		_cFileNew:="\xml\"+ALLTRIM(SA2->A2_CGC)+"-nf"+ALLTRIM(LS3->NOTA)+"-"+ALLTRIM(LS3->CHAVE)+".xml.imp"
		
		FRename(_cFileOri,_cFileNew)
		__CopyFile("\xml\*.imp","\xml\importado\")
		ferase(_cFileNew)
		
		
		Reclock("LS3",.F.)
		dbdelete()
		MsUnlock()
		
		DbSelectarea("LS3")
		Dbgotop()
		
		If !lItem
			oPedido:end()
		Endif
		
		Msgbox("PrИ-Nota "+cNotaAtu+" gerada com sucesso!","AtenГЦo...","INFO")
		
		PROCESS()
	Endif
Endif
DbSelectarea("LS1")
Dbgotop()
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Corrigir produto													Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function CORRIGE()

nSeek:=LS1->SEQ

If LS1->OK=="X"
	aCampos6:= {{"PRODUTO","C",15,0 },;
	{"DESCRICAO","C",45,0 },;
	{"QE","N",8,2 },;
	{"SALDO","N",12,2 },;
	{"PEDIDO","C",3,0 },;
	{"BLQ","C",5,0 }}
	
	cArqTrab6  := CriaTrab(aCampos6)
	dbUseArea( .T.,, cArqTrab6, "LS4", if(.F. .OR. .F., !.F., NIL), .F. )
	IndRegua("LS4",cArqTrab6,"DESCRICAO",,,)
	dbSetIndex( cArqTrab6 +OrdBagExt())
	dbSelectArea("LS4")
	
	lTem:=.F.
	cQuery:=" SELECT B1_MSBLQL BLQ,B1_CODBAR CODBAR,B1_COD PRODUTO,B1_DESC DESCRICAO FROM SB1"+SM0->M0_CODIGO+"0 "
	cQuery:=cQuery + " WHERE B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery:=cQuery + " AND B1_DESC LIKE '"+'%'+SUBSTR(LS1->DESCRICAO,1,4)+'%'+"' "
	cQuery:=cQuery + " AND B1_PROC = '"+LS3->FORNEC+"' "
	IF !_lPRDBLQ
		cQuery:=cQuery + " AND B1_MSBLQL = '2' "	
	ENDIF
	cQuery:=cQuery + " AND D_E_L_E_T_<>'*' "
	TCQUERY cQuery NEW ALIAS "TCQ"
	DbSelectarea("TCQ")
	While !Eof()
		If Empty(cAlmox)
			cAlmox:=Posicione("SB1",1,xFilial("SB1")+TCQ->PRODUTO,"B1_LOCPAD")
		Endif
		
		Reclock("LS4",.T.)
		LS4->PRODUTO:=TCQ->PRODUTO
		IF "SAIU" $ TCQ->DESCRICAO
			LS4->DESCRICAO:=SUBSTR(TCQ->DESCRICAO,6,45)
		Else
			LS4->DESCRICAO:=TCQ->DESCRICAO
		Endif
		LS4->SALDO:=POSICIONE("SB2",2,xFilial("SB2")+cAlmox+TCQ->PRODUTO,"B2_QATU-B2_RESERVA-B2_QEMP")
		LS4->QE:=POSICIONE("SB1",1,xFilial("SB1")+TCQ->PRODUTO,"B1_QE")
		LS4->PEDIDO:=TEMPED(TCQ->PRODUTO)
		LS4->BLQ:=IIF(TCQ->BLQ=="1","Bloq.","Ativo")
		MsUnlock()
		DbSelectarea("TCQ")
		Dbskip()
	End
	DbClosearea("TCQ")
	
	_cProduto:=Space(15)
	
	aTitulo6 := {}
	AADD(aTitulo6,{"BLQ","Sit."})
	AADD(aTitulo6,{"PRODUTO","Produto"})
	AADD(aTitulo6,{"DESCRICAO","DescriГЦo"})
	AADD(aTitulo6,{"QE","Qtd.Emb.","@E 999999"})
	AADD(aTitulo6,{"SALDO","Saldo Atual","@E 999,999,999.99"})
	AADD(aTitulo6,{"PEDIDO","Possui Pedido?"})
	
	DbSelectarea("LS4")
	Dbgotop()
	
	_cFiltrox:=SUBSTR(LS1->DESCRICAO,1,4)+space(30)
	lCheck1:=.F.
	
	@ 120,040 TO 450,880 DIALOG oAmarra TITLE "Produto do fornecedor..."
	@ 005,005 say LS1->DESCRICAO SIZE 200,40 FONT oFont1 OF oAmarra PIXEL
	@ 020,005 TO 140,417 BROWSE "LS4" OBJECT OBRWX FIELDS aTitulo6
	OBRWX:OBROWSE:bLDblClick   := {|| SELECIONA(LS4->PRODUTO,2) }
	OBRWX:oBrowse:oFont := TFont():New ("Arial", 07, 18)
	
	@ 005,210 say "Filtro" SIZE 200,40 FONT oFont1 OF oAmarra PIXEL COLOR CLR_HRED
	@ 005,230 get _cFiltrox SIZE 70,20 Picture "@!"
	@ 005,300 BUTTON "_Filtrar" SIZE 35,10 ACTION MsgRun("Processando produtos...",,{||FILTRE()})
	If cPedCom
		@ 005,340 CHECKBOX "Somente com Pedidos" VAR lCheck1
	Endif
	IF _lPRDBLQ
		@ 150,010 BUTTON "Reativar Produto" SIZE 60,12 ACTION DESBLOQ()
	ENDIF
	ACTIVATE DIALOG oAmarra CENTER
	
	Dbselectarea("LS4")
	dbCloseArea("LS4")
	fErase( cArqTrab6+".DTC")
	fErase( cArqTrab6+ OrdBagExt() )
	Return
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Corrigir produtos encontrados automaticamente						Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(LS1->OK) .OR. LS1->OK=="O"
	SELECIONA(LS1->PRODUTO,1)
Endif
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processando arquivos												Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function XML()

Private _oXml    := NIL
Private cError    := ''
Private cWarning := ''
nXmlStatus := XMLError()
cFile:="\xml\"+lower(ALLTRIM(aXML[i]))
oXml := XmlParserFile(cFile,"_",@cError, @cWarning )
lTipo:=3

If ALLTRIM(TYPE("oxml:_NFE:_INFNFE"))=="O"
	lTipo:=1
Endif
If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE"))=="O"
	lTipo:=2
Endif

_cCNPJ:=''
_cCNPJ2:=''

If Empty(@cError) .and. lTipo<>3
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Com _NFEPROC														Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lTipo==2
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT"))=="C"
			_cCNPJ2:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
		Endif
		_cCNPJ:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT)
		cNota:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT
		If Empty(cSerieNF)
			cSerie:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT
		Endif
		cNatOp:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NATOP:TEXT
		cEmissao := StrTran(Substr(oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT,1,10),"-","")
		cChave:=ALLTRIM(SUBSTR(oxml:_NFEPROC:_NFE:_INFNFE:_ID:TEXT,4,200))

		IF TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFNFE:TEXT") == "C"
			_cNFREF := oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFNFE:TEXT
		ENDIF

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Manipulando numero da nota fiscal									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If LEN(ALLTRIM(cNota))<=6
			cNota:=strzero(val(cNota),6)
		Endif
		If cZeros
			cNota:=strzero(val(cNota),9)
		Endif
		nTam:=LEN(ALLTRIM(cNota))
		cSpaco:=(9-nTam)
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Empresa atual														Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If ALLTRIM(_cCNPJ2)<>ALLTRIM(SM0->M0_CGC)
			_cCNPJ:=''
		Endif

	Else
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Sem _NFEPROC															Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT"))=="C"
			_cCNPJ2:=ALLTRIM(oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
		Endif
		_cCNPJ:=ALLTRIM(oxml:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT)
		cEmissao:=SUBSTR(oxml:_NFE:_INFNFE:_IDE:_DEMI:TEXT,1,10)
		cEmissao:=SUBSTR(cEmissao,1,4)+SUBSTR(cEmissao,6,2)+SUBSTR(cEmissao,9,2)
		cNota:=oxml:_NFE:_INFNFE:_IDE:_NNF:TEXT
		If Empty(cSerieNF)
			cSerie:=oxml:_NFE:_INFNFE:_IDE:_SERIE:TEXT
		Endif
		cNatOp:=oxml:_NFE:_INFNFE:_IDE:_NATOP:TEXT
		cChave:=ALLTRIM(SUBSTR(oxml:_NFE:_INFNFE:_ID:TEXT,4,200))
		
		IF TYPE("oxml:_NFE:_INFNFE:_IDE:_NFREF:_REFNFE:TEXT") == "C"
			_cNFREF := oxml:_NFE:_INFNFE:_IDE:_NFREF:_REFNFE:TEXT
		ENDIF
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Manipulando numero da nota fiscal									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If LEN(ALLTRIM(cNota))<=6
			cNota:=strzero(val(cNota),6)
		Endif
		If cZeros
			cNota:=strzero(val(cNota),9)
		Endif
		nTam:=LEN(ALLTRIM(cNota))
		cSpaco:=(9-nTam)
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Empresa atual														Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If ALLTRIM(_cCNPJ2)<>ALLTRIM(SM0->M0_CGC)
			_cCNPJ:=''
		Endif
	Endif
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifico se a nota ja existe no sistema								Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !Empty(_cCNPJ)
		DbSelectarea("SA2")
		DbSetorder(3)
		Dbgotop()
		Dbseek(xFilial("SA2")+_cCNPJ)
		If Found()
			dbSelectArea("SF1")
			DbSetorder(2)
			Dbgotop()
			Dbseek(xFilial("SF1")+SA2->A2_COD+SA2->A2_LOJA+ALLTRIM(cNota)+Space(cSpaco))
			If Found() .and. SF1->F1_TIPO=="N"
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Nomeclatura dos arquivos											Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				_cFileOri:="\xml\"+lower(ALLTRIM(aXML[i]))
				_cFileNew:="\xml\"+ALLTRIM(_cCNPJ)+"-nf"+ALLTRIM(cNota)+"-"+ALLTRIM(cChave)+".xml.imp"
				FRename(_cFileOri,_cFileNew)
				__CopyFile("\xml\*.imp","\xml\importado\")
				ferase(_cFileNew)
				_cCNPJ:=''
			Endif
		Endif
	Endif
Else
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Nomeclatura dos arquivos											Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	_cFileOri:="\xml\"+lower(ALLTRIM(aXML[i]))
	_cFileNew:="\xml\"+lower(ALLTRIM(aXML[i]))+".err"
	
	FRename(_cFileOri,_cFileNew)
	__CopyFile("\xml\*.err","\xml\corrompido\")
	ferase(_cFileNew)
Endif
Return

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//| Pre nota entrada											 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function PRENOTA()
Local _aLinha       := {}
Private lMsErroAuto := .F.
Private _aSERV      := {}
Private _cTIPNF     := ALLA01T(LS3->NFREF)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//| Verificando integridade dos pedidos de compras				 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
lNao:=.F.
DbSelectarea("LS1")
DbSetorder(1)
Dbgotop()
While !Eof()
	If !Empty(LS1->PEDIDO)
		DbSelectarea("SC7")
		DbSetorder(4)
		Dbgotop()
		Dbseek(xFilial("SC7")+LS1->PRODUTO+LS1->PEDIDO+LS1->ITEM)
		If !Found()
			Msgbox("Problema ao encontrar o Pedido "+LS1->PEDIDO+" Item:"+LS1->ITEM+" impossivel continuar!")
			lNao:=.T.
		Else
			If (SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA)<LS1->QUANTIDADE
				Msgbox("Pedido "+LS1->PEDIDO+" Item:"+LS1->ITEM+" com saldo insuficiente!")
				lNao:=.T.
			Endif
		Endif
	Endif
	DbSelectarea("LS1")
	Dbskip()
End
If lNao
	Return
Endif

cRet:=.F.
DbSelectarea("LS1")
dbgotop()
_dEmissao:=STOD(LS1->EMISSAO)

/* FB
If cPedCom .and. !lItem
	cQuere:=" UPDATE SC7"+SM0->M0_CODIGO+"0 SET C7_LOJA='"+LS3->LOJA+"' WHERE C7_FILIAL='"+xFilial("SC7")+"' AND C7_NUM='"+LS2->PEDIDO+"' AND D_E_L_E_T_<>'*' "
	TCSQLEXEC(cQuere)
Endif
*/

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//| Grava status no fornecedor que manda o XML					 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
_cEST := ""
IF EMPTY(LS3->NFREF)
	DbSelectarea("SA2")
	DbSetorder(1)
	Dbgotop()
	IF Dbseek(xFilial("SA2")+LS3->FORNEC+LS3->LOJA)
		_cEST := SA2->A2_EST
		Reclock("SA2",.F.)
		SA2->A2_STATUS:="1"
		MsUnlock()
	Endif
ELSE
	DbSelectarea("SA1")
	DbSetorder(1)
	Dbgotop()
	IF Dbseek(xFilial("SA1")+LS3->FORNEC+LS3->LOJA)
		_cEST := SA1->A1_EST
	Endif
ENDIF
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//| Apago se ja existir por queda de energia					 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
/* FB
cQuere:=" DELETE FROM SF1"+SM0->M0_CODIGO+"0 WHERE F1_FILIAL='"+xFilial("SF1")+"' AND F1_DOC='"+cNota+"' AND F1_SERIE='"+cSerie+"' AND F1_FORNECE='"+LS3->FORNEC+"' AND F1_LOJA='"+LS3->LOJA+"' AND F1_VALBRUT=0 "
TCSQLEXEC(cQuere)

cQuere:=" DELETE FROM SD1"+SM0->M0_CODIGO+"0 WHERE D1_FILIAL='"+xFilial("SD1")+"' AND D1_DOC='"+cNota+"' AND D1_SERIE='"+cSerie+"' AND D1_FORNECE='"+LS3->FORNEC+"' AND D1_LOJA='"+LS3->LOJA+"' AND D1_TES=' ' "
TCSQLEXEC(cQuere)
*/

lExist := .F.
DbSelectarea("SX3")
DbSetorder(2)
Dbgotop()
Dbseek("D1_DESCRIC")
If Found()
	lExist := .T.
Endif

lGrava := .F.
_nIt   := 1
lBloq  := .F.

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//| Gerando Pre-nota 											 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSelectarea("LS1")
DbSetorder(1)
Dbgotop()
While !Eof()
	DbSelectarea("SB1")
	DbSetorder(1)
	Dbgotop()
	DbSeek(xFilial("SB1")+LS1->PRODUTO)
	If Found()
		/* FB
		DbSelectarea("SD1")
		Reclock("SD1",.T.)
		SD1->D1_FILIAL:=xFilial("SD1")
		SD1->D1_ITEM:=strzero(_nIt,4)
		SD1->D1_TIPO:="N"
		If lExist
			SD1->D1_DESCRIC:=SUBSTR(SB1->B1_DESC,1,30)
		Endif
		SD1->D1_COD:=LS1->PRODUTO
		SD1->D1_QUANT:=LS1->QUANTIDADE
		SD1->D1_VUNIT:=LS1->PRECO
		SD1->D1_TOTAL:=LS1->TOTAL
		SD1->D1_UM:=SB1->B1_UM
		SD1->D1_SEGUM:=SB1->B1_SEGUM
		SD1->D1_PICM:=SB1->B1_PICM
		SD1->D1_CONTA:=SB1->B1_CONTA
		SD1->D1_CC:=SB1->B1_CC
		SD1->D1_FORNECE:=LS3->FORNEC
		SD1->D1_LOJA:=LS3->LOJA
		SD1->D1_DOC:=cNota
		SD1->D1_SERIE:=cSerie
		SD1->D1_EMISSAO:=_dEmissao
		SD1->D1_DTDIGIT:=DDATABASE
		SD1->D1_GRUPO:=SB1->B1_GRUPO
		SD1->D1_TP:=SB1->B1_TIPO
		SD1->D1_VALDESC:=LS1->DESCONTO
		SD1->D1_LOCAL:=LS1->ALMOX
		SD1->D1_PEDIDO:=LS1->PEDIDO
		SD1->D1_ITEMPC:=LS1->ITEM
		MsUnlock()
		*/

		aItens := {}		
		aAdd(aItens,{'D1_COD' ,IIF(SUBSTR(LS1->PRODFOR,1,2) == "SE" ,LS1->PRODFOR,LS1->PRODUTO) ,NIL})

		//Verifica se unidades de medida sao diferentes
		// FB - 17/05/2019
		IF ALLTRIM(LS1->UM) <> ALLTRIM(SB1->B1_UM)
			IF !EMPTY(SB1->B1_SEGUM)
				IF ALLTRIM(SB1->B1_SEGUM) == ALLTRIM(LS1->UM)

					IF SB1->B1_TIPCONV == "M" //MULTIPLICADOR
						_nQTDCONV := LS1->QUANTIDADE / SB1->B1_CONV
					ELSE //DIVISOR
						_nQTDCONV := LS1->QUANTIDADE * SB1->B1_CONV					
					ENDIF
					_nVUNIT := ROUND(LS1->TOTAL / _nQTDCONV,TAMSX3("D1_VUNIT")[2])

					aAdd(aItens,{'D1_QUANT'  ,_nQTDCONV                                         ,NIL})
					aAdd(aItens,{'D1_VUNIT'  ,_nVUNIT                                           ,NIL})
					aAdd(aItens,{'D1_TOTAL'  ,ROUND(_nVUNIT * _nQTDCONV ,TAMSX3("D1_TOTAL")[2]) ,NIL})
					aAdd(aItens,{'D1_UM'     ,SB1->B1_UM                                        ,NIL})
					aAdd(aItens,{'D1_SEGUM'  ,SB1->B1_SEGUM                                     ,NIL})
					
					IF SUBSTR(LS1->PRODFOR,1,2) == "SE"
						_cOP := ALLA01O(SB1->B1_COD,_nQTDCONV)
						IF !EMPTY(_cOP)
							aAdd(aItens,{'D1_OP'  , _cOP ,NIL})
						ENDIF
					ENDIF
					
				ELSE
					MsgAlert("Problema na segunda unidade de medida","[ALLA001_003] - AtenГЦo")	
				ENDIF
			ELSE
				MsgAlert("Problema na segunda unidade de medida","[ALLA001_004] - AtenГЦo")
			ENDIF
		ELSE
		
			aAdd(aItens,{'D1_QUANT'  ,LS1->QUANTIDADE,NIL})
			aAdd(aItens,{'D1_VUNIT'  ,LS1->PRECO     ,NIL})
			aAdd(aItens,{'D1_TOTAL'  ,LS1->TOTAL     ,NIL})
			aAdd(aItens,{'D1_UM'     ,SB1->B1_UM     ,NIL})
			aAdd(aItens,{'D1_SEGUM'  ,SB1->B1_SEGUM  ,NIL})

			IF SUBSTR(LS1->PRODFOR,1,2) == "SE"
				_cOP := ALLA01O(SB1->B1_COD,LS1->QUANTIDADE)
				IF !EMPTY(_cOP)
					aAdd(aItens,{'D1_OP'  , _cOP ,NIL})
				ENDIF
			ENDIF
			
		ENDIF
		
		aAdd(aItens,{'D1_PICM'   ,SB1->B1_PICM   ,NIL})
		aAdd(aItens,{'D1_CONTA'  ,SB1->B1_CONTA  ,NIL})
		aAdd(aItens,{'D1_CC'     ,SB1->B1_CC     ,NIL})
		aAdd(aItens,{'D1_FORNECE',LS3->FORNEC    ,NIL})
		aAdd(aItens,{'D1_LOJA'   ,LS3->LOJA      ,NIL})
		aAdd(aItens,{'D1_DOC'    ,cNota          ,NIL})		
		aAdd(aItens,{'D1_SERIE'  ,cSerie         ,NIL})
		aAdd(aItens,{'D1_EMISSAO',_dEmissao      ,NIL})
		aAdd(aItens,{'D1_DTDIGIT',DDATABASE      ,NIL})		
		aAdd(aItens,{'D1_GRUPO'  ,SB1->B1_GRUPO  ,NIL})
		aAdd(aItens,{'D1_TP'     ,SB1->B1_TIPO   ,NIL})		
		aAdd(aItens,{'D1_VALDESC',LS1->DESCONTO  ,NIL})
		aAdd(aItens,{'D1_LOCAL'  ,SB1->B1_LOCPAD ,NIL})

		IF !EMPTY(LS1->PEDIDO)
			aAdd(aItens,{'D1_PEDIDO' ,LS1->PEDIDO    ,NIL})		
			aAdd(aItens,{'D1_ITEMPC' ,LS1->ITEM      ,NIL})
		ENDIF

		_aRETORI := ALLA01P(LS1->PRODUTO,LS3->NFREF)
		IF LEN(_aRETORI) > 0 .AND. !SUBSTR(LS1->PRODFOR,1,2) == "SE"
			aAdd(aItens,{'D1_NFORI'   ,_aRETORI[1][1] ,NIL})		
			aAdd(aItens,{'D1_SERIORI' ,_aRETORI[1][2] ,NIL})
			aAdd(aItens,{'D1_ITEMORI' ,_aRETORI[1][3] ,NIL})			
		ENDIF

		aAdd(_aLinha,aItens)
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//| Aprovacao Pedido											 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !Empty(LS1->PEDIDO)
			
			_nVlrProd := LS1->PRECO
			
			DbSelectarea("AIC")
			DbSetorder(2)
			Dbgotop()
			IF Dbseek(xFilial("AIC")+LS3->FORNEC+LS3->LOJA)
				_nPerc := AIC->AIC_PPRECO
				Dbselectarea("SC7")
				DbSetorder(1)
				Dbgotop()
				Dbseek(xFilial("SC7")+LS1->PEDIDO+LS1->ITEM)
				If Found()
					IF _nVlrProd > (SC7->C7_PRECO+((SC7->C7_PRECO*_nPerc)/100))
						lBloq := .T.
					Endif
				Endif
			Endif
			DbSelectarea("LS1")
		Endif
		lGrava:=.T.
		_nIt := (_nIt+1)
	Endif
	DbSelectarea("LS1")
	Dbskip()
End

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Caso gravou corretamente a pre nota									Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lGrava
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//| Cabecalho Pre Nota - SF1									 |
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	/* FB
	DbSelectarea("SF1")
	Reclock("SF1",.T.)
	SF1->F1_FILIAL:=xFilial("SF1")
	SF1->F1_FORMUL:="N"
	SF1->F1_TIPO:="N"
	SF1->F1_DOC:=cNota
	SF1->F1_SERIE:=cSerie
	SF1->F1_FORNECE:=LS3->FORNEC
	SF1->F1_LOJA:=LS3->LOJA
	SF1->F1_EMISSAO:=_dEmissao
	SF1->F1_DTDIGIT:=DDATABASE
	SF1->F1_RECBMTO:=DDATABASE
	SF1->F1_EST:=SA2->A2_EST
	SF1->F1_ESPECIE:=cEspecie
	If lBloq
		SF1->F1_STATUS:="B"
		SF1->F1_APROV:="000001"
	Endif
	SF1->F1_HORA:=LEFT(TIME(),5)
	SF1->F1_CHVNFE:=ALLTRIM(LS3->CHAVE)
	MsUnlock()
	*/

	_aCabec := {}
	IF EMPTY(LS3->NFREF)
		aAdd(_aCabec,{'F1_TIPO'   ,'N'        ,NIL})
	    aAdd(_aCabec,{'F1_FORMUL' ,'N'        ,NIL})
    ELSE
    	IF ALLTRIM(_cTIPNF) <> "B"
			aAdd(_aCabec,{'F1_TIPO'   ,'D'        ,NIL})
		    aAdd(_aCabec,{'F1_FORMUL' ,' '        ,NIL}) 
		ELSE
			aAdd(_aCabec,{'F1_TIPO'   ,'N'        ,NIL})
		    aAdd(_aCabec,{'F1_FORMUL' ,' '        ,NIL}) 
		ENDIF   
    ENDIF
    aAdd(_aCabec,{'F1_DOC'    ,cNota      ,NIL})
    aAdd(_aCabec,{"F1_SERIE"  ,cSerie     ,NIL})
    aAdd(_aCabec,{'F1_FORNECE',LS3->FORNEC,NIL})
    aAdd(_aCabec,{'F1_LOJA'   ,LS3->LOJA  ,NIL})
    aAdd(_aCabec,{"F1_EMISSAO",_dEmissao  ,NIL})
    aAdd(_aCabec,{"F1_DTDIGIT",dDataBase  ,NIL})
    aAdd(_aCabec,{"F1_RECBMTO",dDataBase  ,NIL})
    aAdd(_aCabec,{"F1_EST"    ,_cEST      ,NIL})
    aAdd(_aCabec,{"F1_ESPECIE",cEspecie   ,NIL})
	If lBloq
		aAdd(_aCabec,{"F1_STATUS","B"     ,NIL})
		aAdd(_aCabec,{"F1_APROV" ,"000001",NIL})
	Endif
    aAdd(_aCabec,{"F1_HORA"  ,LEFT(TIME(),5)    ,NIL})
    aAdd(_aCabec,{"F1_CHVNFE",ALLTRIM(LS3->CHAVE),NIL})

    MSExecAuto({|x,y,z,a,b| MATA140(x,y,z,a,b)}, _aCabec, _aLinha, 3,,)
      
    If lMsErroAuto
        mostraerro()
        Return(.F.)
    EndIf

	
	cNota:=SF1->F1_DOC
	cSerie:=SF1->F1_SERIE
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualizando Pedido de compras										Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	/* FB
	DbSelectarea("LS1")
	DbSetorder(1)
	Dbgotop()
	While !Eof()
		DbSelectarea("SC7")
		DbSetorder(4)
		Dbgotop()
		DbSeek(xFilial("SC7")+LS1->PRODUTO+LS1->PEDIDO+LS1->ITEM)
		If Found()
			Reclock("SC7",.F.)
			SC7->C7_QTDACLA:=(SC7->C7_QTDACLA+LS1->QUANTIDADE)
			MsUnlock()
		Endif
		DbSelectarea("LS1")
		Dbskip()
	End
	*/
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Liberacao de Documentos												Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	/* FB
	If lBloq
		Dbselectarea("SAL")
		DbSetorder(1)
		Dbgotop()
		While !Eof()
			If ALLTRIM(SAL->AL_NIVEL)=="09"
				Reclock("SCR",.T.)
				SCR->CR_FILIAL:=xFilial("SCR")
				SCR->CR_NUM:=(cNota+cSerie+LS3->FORNEC+LS3->LOJA)
				SCR->CR_TIPO:="NF"
				SCR->CR_USER:=SAL->AL_USER
				SCR->CR_APROV:=SAL->AL_APROV
				SCR->CR_NIVEL:="09"
				SCR->CR_STATUS:="02"
				SCR->CR_EMISSAO:=DDATABASE
				MsUnlock()
			Endif
			Dbselectarea("SAL")
			Dbskip()
		End
	Endif
	*/
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Gerando NDF para o fornecedor do valor excedido						Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	/* FB
	If cNDF .and. cPedCom
		_nExcedido:=VALORNDF()
		
		If _nExcedido>0
			cResp:=msgbox("Deseja gerar a NDF para o fornecedor no valor de R$ "+Transform(_nExcedido,"@E 99,999.99"),"AtenГЦo...","YESNO")
			If cResp
				NDF()
				Msgbox("NDF "+cNota+" gerada com sucesso!","AtenГЦo...","INFO")
			Endif
		Endif
	Endif
	*/
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Calculando o total do item na nota									Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	/* FB
	cQuere:=" UPDATE SD1"+SM0->M0_CODIGO+"0 SET D1_TOTAL=(D1_QUANT*D1_VUNIT) WHERE D1_FILIAL='"+xFilial("SD1")+"' AND D1_DOC='"+cNota+"' AND D1_FORNECE='"+LS3->FORNEC+"' AND D1_LOJA='"+LS3->LOJA+"' AND D1_SERIE='"+cSerie+"' "
	TCSQLEXEC(cQuere)
	*/
	cRet:=.T.
Endif
Return(cRet)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//| Alterar Pedido												 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function PEDIDOS()

If LS2->OK=="X"
	Msgbox("NЦo И necessАrio atualizar este pedido!","AtenГЦo...","ALERT")
	Return
Endif

cPedido:=LS2->PEDIDO
cLoja:=LS2->LOJA

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//| Verifica se algum pedido ainda nao foi usado				 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSelectarea("LS2")
Dbgotop()
While !Eof()
	IF 	LS2->OK=="X"
		Msgbox("Favor usar o Pedido "+LS2->PEDIDO,"Sem necessidade...","INFO")
		DbSelectarea("LS2")
		Dbgotop()
		Return
	Endif
	Dbskip()
End


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ajustando o pedido com a nota										Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
/*
cResp:=msgbox("Deseja atualizar o pedido "+cPedido+" com os itens faltantes?","AtenГЦo...","YESNO")

If cResp
	
	lEntrou:=.F.
	_nQtdIt:=0
	
	Dbselectarea("PRO")
	DbSetorder(1)
	Dbgotop()
	While !Eof()
		DbSelectarea("SC7")
		DbSetorder(4)
		Dbgotop()
		Dbseek(xFilial("SC7")+PRO->PRODUTO+cPedido)
		If !Found()
			Dbselectarea("SB1")
			DbSetorder(1)
			Dbgotop()
			Dbseek(xFilial("SB1")+PRO->PRODUTO)
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//| Dados do pedido												 |
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cQuery:=" SELECT C7_EMISSAO EMISSAO,C7_COND COND,MAX(C7_ITEM) ITEM FROM SC7"+SM0->M0_CODIGO+"0 WHERE C7_FILIAL='"+xFilial("SC7")+"' AND C7_NUM='"+cPedido+"' AND D_E_L_E_T_<>'*' GROUP BY C7_EMISSAO,C7_COND "
			TCQUERY cQuery NEW ALIAS "PED"
			DbSelectArea("PED")
			nItem:=strzero(val(PED->ITEM)+1,4)
			_cCond:=PED->COND
			_dEmiss:=STOD(PED->EMISSAO)
			DbCloseArea("PED")
			
			Reclock("SC7",.T.)
			SC7->C7_FILIAL := xFilial("SC7")
			SC7->C7_TIPO   := 1
			SC7->C7_NUM    := cPedido
			SC7->C7_EMISSAO:= _dEmiss
			SC7->C7_FORNECE:= LS3->FORNEC
			SC7->C7_LOJA   := cLoja
			SC7->C7_CONTATO:= Posicione("SA2",1,xFilial("SA2")+LS3->FORNEC+cLoja,"A2_CONTATO")
			SC7->C7_COND   := _cCond
			SC7->C7_FILENT := xFilial("SC7")
			SC7->C7_ITEM   := nItem
			SC7->C7_PRODUTO:= PRO->PRODUTO
			SC7->C7_UM     := SB1->B1_UM
			SC7->C7_SEGUM  := SB1->B1_SEGUM
			SC7->C7_DESCRI := SUBSTR(SB1->B1_DESC,1,30)
			SC7->C7_QUANT  := PRO->QUANTIDADE
			SC7->C7_QTSEGUM:= (PRO->QUANTIDADE/SB1->B1_QE)
			SC7->C7_PRECO  := PRO->PRECO
			SC7->C7_TOTAL  := (PRO->QUANTIDADE*PRO->PRECO)
			SC7->C7_DATPRF := _dEmiss
			SC7->C7_TES    := SB1->B1_TE
			SC7->C7_IPIBRUT:= "B"
			SC7->C7_FLUXO  := "S"
			SC7->C7_USER   := __CUSERID
			SC7->C7_TPOP   := "F"
			SC7->C7_CONAPRO:= "L"
			SC7->C7_MOEDA  := 1
			SC7->C7_TPFRETE:= "C"
			SC7->C7_OBS    := "INCLUIDO NF-ELETRONICA"
			SC7->C7_PENDEN := "N"
			SC7->C7_POLREPR:= "N"
			If Empty(cAlmoPed)
				SC7->C7_LOCAL:=Posicione("SB1",1,xFilial("SB1")+PRO->PRODUTO,"B1_LOCPAD")
			Else
				SC7->C7_LOCAL:=cAlmoPed
			Endif
			MsUnlock()
			
			_nQtdIt:=_nQtdIt+1
			
			If Empty(cAlmox)
				cAlmox:=Posicione("SB1",1,xFilial("SB1")+PRO->PRODUTO,"B1_LOCPAD")
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Atualizado SB2 saldo de pedidos										Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			DbSelectarea("SB2")
			DbSetorder(2)
			Dbgotop()
			Dbseek(xFilial("SB2")+cAlmox+PRO->PRODUTO)
			If Found()
				Reclock("SB2",.F.)
				SB2->B2_SALPEDI:=(SB2->B2_SALPEDI+PRO->QUANTIDADE)
				MsUnlock()
			Endif
			lEntrou:=.T.
		Else
			If (SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA)<PRO->QUANTIDADE
				_nTotal:=PRO->QUANTIDADE-(SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA)
				
				Reclock("SC7",.F.)
				SC7->C7_QUANT:=(SC7->C7_QUANT+_nTotal)
				SC7->C7_OBS:="ALTERADO NF-ELETRONICA"
				MsUnlock()
				
				Reclock("SC7",.F.)
				SC7->C7_TOTAL:=(SC7->C7_QUANT*SC7->C7_PRECO)
				MsUnlock()
				
				If Empty(cAlmox)
					cAlmox:=Posicione("SB1",1,xFilial("SB1")+PRO->PRODUTO,"B1_LOCPAD")
				Endif
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Atualizado SB2 saldo de pedidos										Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				DbSelectarea("SB2")
				DbSetorder(2)
				Dbgotop()
				Dbseek(xFilial("SB2")+cAlmox+PRO->PRODUTO)
				If Found()
					Reclock("SB2",.F.)
					SB2->B2_SALPEDI:=(SB2->B2_SALPEDI+_nTotal)
					MsUnlock()
				Endif
				lEntrou:=.T.
			Endif
		Endif
		Dbselectarea("PRO")
		Dbskip()
	End
	
	If lEntrou
		Msgbox("Pedido atualizado com sucesso!","AtenГЦo...","INFO")
	Endif
	
	DbSelectarea("LS2")
	Dbgotop()
	While !Eof()
		IF LS2->PEDIDO==cPedido
			Reclock("LS2",.F.)
			LS2->VALIDO:=nTotIt
			LS2->OK:="X"
			LS2->QTDIT:=(LS2->QTDIT+_nQtdIt)
			LS2->ITENS:=(LS2->ITENS+_nQtdIt)
			Msunlock()
		Endif
		Dbskip()
	End

Endif
*/
DbSelectarea("LS2")
Dbgotop()
Return

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//| Novo Pedido													 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function NEWPED()

Local aCab2 :={}
Local aItem2:={}
PRIVATE lMsErroAuto := .F.
lAchei:=.F.
nOpc:=3

_nItens:=0
_cCond:=POSICIONE("SA2",1,xFilial("SA2")+LS3->FORNEC+LS3->LOJA,"A2_COND")
If Empty(_cCond)
	_cCond:="001"
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificar Status da Gravacao										Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
_lGrava:=Getmv("MV_GRVPEDI")

If !Empty(ALLTRIM(_lGrava))
	ALERT("Atencao!!!, O Usuario "+_lGrava+" Esta concretizando um Pedido de Compra, Aguarde...")
	Return
Else
	DbSelectArea("SX6")
	DbgoTop()
	While ! eof()
		If ALLTRIM(SX6->X6_VAR)=="MV_GRVPEDI" .and. SX6->X6_FIL==xFilial("SC7")
			RecLock("SX6",.F.)
			SX6->X6_CONTEUD:="NF-ELETRONICA-"+_cUsuario
			MsUnlock()
		Endif
		DbSkip()
	End
Endif

cNumPed:=GETSXENUM("SC7","C7_NUM")
ConfirmSX8()

DbSelectarea("LS1")
Dbgotop()
While !Eof()
	If Empty(cAlmoPed)
		_cAlmoxPed:=Posicione("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_LOCPAD")
	Else
		_cAlmoxPed:=cAlmoPed
	Endif
	
	aCab2:={{"C7_NUM",cNumPed,Nil},;
	{"C7_EMISSAO" ,dDataBase,Nil},;
	{"C7_FORNECE" ,LS3->FORNEC,Nil},;
	{"C7_LOJA"    ,LS3->LOJA,Nil},;
	{"C7_CONTATO" ,Posicione("SA2",1,xFilial("SA2")+LS3->FORNEC+LS3->LOJA,"A2_CONTATO"),Nil},;
	{"C7_COND"    ,_cCond,Nil},;
	{"C7_FILENT"  ,xFilial("SC7"),Nil}}
	
	aItem3:={}
	aItem3:={{"C7_ITEM",Strzero(_nItens+1,4),Nil},;
	{"C7_PRODUTO",LS1->PRODUTO,Nil},;
	{"C7_QUANT"  ,LS1->QUANTIDADE,Nil},;
	{"C7_PRECO"  ,LS1->PRECO,Nil},;
	{"C7_TOTAL"  ,LS1->TOTAL,Nil},;
	{"C7_DATPRF" ,dDataBase,Nil},;
	{"C7_TES"    ,POSICIONE("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_TE"),Nil},;
	{"C7_FLUXO"  ,"S",Nil},;
	{"C7_USER"   ,__CUSERID,Nil},;
	{"C7_OBS"    ,"NF-ELETRONICA",Nil},;
	{"C7_LOCAL"  ,_cAlmoxPed,Nil}}
	
	DbSelectarea("LS1")
	Reclock("LS1",.F.)
	LS1->PEDIDO:=cNumPed
	LS1->ITEM:=Strzero(_nItens+1,4)
	MsUnlock()
	
	aadd(aItem2,aItem3)
	_nItens:=_nItens+1
	DbSelectarea("LS1")
	Dbskip()
End
DbSelectarea("SC7")
If LEN(aItem2)>0 .and. LEN(aCab2)>0
	MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab2,aItem2,nOpc)
Endif

If lMsErroAuto
	mostraerro()
Else
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Liberando a Gravacao de um pedido para outro usuario				Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectArea("SX6")
	DbgoTop()
	While ! eof()
		If ALLTRIM(SX6->X6_VAR)=="MV_GRVPEDI" .and. SX6->X6_FIL==xFilial("SC7")
			RecLock("SX6",.F.)
			SX6->X6_CONTEUD:=""
			MsUnlock()
		Endif
		DbSkip()
	End
	Msgbox("Pedido "+cNumped+" Gerado com sucesso!","AtenГЦo...","INFO")
EndIf
DbSelectarea("LS1")
Dbgotop()
Return

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//| Novo Pedido por item										 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function NEWPED2()

Local aCab2  := {}
Local aItem2 := {}

PRIVATE lMsErroAuto := .F.
PRIVATE lAchei      := .F.
PRIVATE nOpc        := 3
PRIVATE _nItens     := 0
PRIVATE _cCond      := POSICIONE("SA2",1,xFilial("SA2")+LS3->FORNEC+LS3->LOJA,"A2_COND")

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificar Status da Gravacao										Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE _lGrava := Getmv("MV_GRVPEDI")

If Empty(_cCond)
	_cCond := "001"
Endif

If !Empty(ALLTRIM(_lGrava))
	ALERT("Atencao!!!, O Usuario "+_lGrava+" Esta concretizando um Pedido de Compra, Aguarde...")
	Return
Else
	DbSelectArea("SX6")
	DbgoTop()
	While ! eof()
		If ALLTRIM(SX6->X6_VAR)=="MV_GRVPEDI" .and. SX6->X6_FIL==xFilial("SC7")
			RecLock("SX6",.F.)
			SX6->X6_CONTEUD:="NF-ELETRONICA-"+_cUsuario
			MsUnlock()
		Endif
		DbSkip()
	End
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Numero do Pedido de compra											Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cNumPed := GETSXENUM("SC7","C7_NUM")

ConfirmSX8()

DbSelectarea("LS1")
Dbgotop()
While !Eof()
	IF ALLTRIM(LS1->PEDIDO)=="CRIAR"
		If Empty(cAlmoPed)
			_cAlmoxPed:=Posicione("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_LOCPAD")
		Else
			_cAlmoxPed:=cAlmoPed
		Endif
		
		aCab2:={{"C7_NUM",cNumPed,Nil},;
		{"C7_EMISSAO" ,dDataBase,Nil},;
		{"C7_FORNECE" ,LS3->FORNEC,Nil},;
		{"C7_LOJA"    ,LS3->LOJA,Nil},;
		{"C7_CONTATO" ,Posicione("SA2",1,xFilial("SA2")+LS3->FORNEC+LS3->LOJA,"A2_CONTATO"),Nil},;
		{"C7_COND"    ,_cCond,Nil},;
		{"C7_FILENT" ,xFilial("SC7"),Nil}}
		
		aItem3:={}
		aItem3:={{"C7_ITEM",Strzero(_nItens+1,4),Nil},;
		{"C7_PRODUTO",LS1->PRODUTO,Nil},;
		{"C7_QUANT" ,LS1->QUANTIDADE,Nil},;
		{"C7_PRECO" ,LS1->PRECO,Nil},;
		{"C7_TOTAL" ,LS1->TOTAL,Nil},;
		{"C7_DATPRF" ,dDataBase,Nil},;
		{"C7_TES"    ,POSICIONE("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_TE"),Nil},;
		{"C7_FLUXO" ,"S",Nil},;
		{"C7_USER" ,__CUSERID,Nil},;
		{"C7_OBS"  ,"NF-ELETRONICA",Nil},;
		{"C7_LOCAL",_cAlmoxPed,Nil}}
		aadd(aItem2,aItem3)
		
		DbSelectarea("LS1")
		Reclock("LS1",.F.)
		LS1->PEDIDO:=cNumPed
		LS1->ITEM:=Strzero(_nItens+1,4)
		MsUnlock()
		_nItens:=_nItens+1
	Endif
	DbSelectarea("LS1")
	Dbskip()
End
DbSelectarea("SC7")
If LEN(aItem2)>0 .and. LEN(aCab2)>0
	MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab2,aItem2,nOpc)
Endif

If lMsErroAuto
	mostraerro()
Else
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Liberando a Gravacao de um pedido para outro usuario				Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectArea("SX6")
	DbgoTop()
	While ! eof()
		If ALLTRIM(SX6->X6_VAR)=="MV_GRVPEDI" .and. SX6->X6_FIL==xFilial("SC7")
			RecLock("SX6",.F.)
			SX6->X6_CONTEUD:=""
			MsUnlock()
		Endif
		DbSkip()
	End
	Msgbox("Pedido "+cNumped+" Gerado com sucesso!","AtenГЦo...","INFO")
EndIf
DbSelectarea("LS1")
Dbgotop()
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processando arquivo													Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function PROCESS()

private _oXml    := NIL
private cError   := ''
private cWarning := ''

lRefaz := .F.

DbSelectarea("LS3")
If LS3->(eof())
	msgbox("NЦo existem notas fiscais eletrТnicas para serem importadas!")
	OBRWI:obrowse:refresh()
	OBRWP:obrowse:refresh()
	OBRWI:obrowse:setfocus()
	OBRWP:obrowse:setfocus()
	ObjectMethod(oTela,"Refresh()")
	Return
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifico se existe a nota fiscal									Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
IF !file("\xml\"+lower(LS3->XML))
	msgbox("Este arquivo jА foi processado por outro usuАrio!","AtenГЦo...","ALERT")
	Reclock("LS3",.F.)
	dbdelete()
	MsUnlock()
	
	DbSelectarea("LS3")
	Dbgotop()
	PROCESS()
	Return
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifico se foi alterado algum item									Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
lAltera:=.F.
DbSelectarea("LS1")
Dbgotop()
While !Eof()
	IF LS1->ALTERADO=="S"
		_cChave:=LS1->NOME+LS1->NOTA
		lAltera:=.T.
	Endif
	Dbskip()
End

IF lAltera
	cResp:=msgbox("Deseja perder todas as alteraГУes realizadas?","AtenГЦo...","YESNO")
	
	If cResp==.F.
		DbSelectarea("LS3")
		Dbsetorder(1)
		dbgotop()
		Dbseek(_cChave)
		
		DbSelectarea("LS1")
		Dbgotop()
		OBRWI:obrowse:refresh()
		OBRWP:obrowse:refresh()
		OBRWI:obrowse:setfocus()
		OBRWP:obrowse:setfocus()
		ObjectMethod(oTela,"Refresh()")
		Return
	Endif
Endif

nXmlStatus := XMLError()
cFile:="\xml\"+lower(ALLTRIM(LS3->XML))

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Apagando dados da tabela temporaria									Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSelectarea("LS1")
Dbsetorder(1)
Dbgotop()
While !Eof()
	Reclock("LS1",.F.)
	dbdelete()
	MsUnlock()
	Dbskip()
End

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Apagando produtos temporarios										Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSelectarea("LS5")
Dbsetorder(1)
Dbgotop()
While !Eof()
	Reclock("LS5",.F.)
	dbdelete()
	MsUnlock()
	Dbskip()
End

oXml := XmlParserFile(cFile,"_",@cError, @cWarning )
aCols:={}
nTotIt:=0
nTotalNF:=0
_dVencto:=''

IF ALLTRIM(TYPE("oxml:_NFE:_INFNFE"))=="O"
	lTipo:=1
Else
	lTipo:=2
Endif
_cCNPJ:=''

If ( nXmlStatus == XERROR_SUCCESS )
	
	If lTipo==2
		aCols:=aClone(oXml:_NFEPROC:_NFE:_INFNFE:_DET)
	Else
		aCols:=aClone(oXml:_NFE:_INFNFE:_DET)
	Endif
	
	If aCols==NIL
		nItens:=1
	Else
		nItens:=LEN(aCols)
	Endif
	
	For i:=1 to nItens
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Com _NFEPROC														Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lTipo==2
			
			If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT"))=="C"
				_cMensag:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT)
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Vencimento Duplicata												Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP:_DVENC:TEXT"))=="C"
				_dVencto:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP:_DVENC:TEXT)
				_dVencto:=STOD(SUBSTR(_dVencto,1,4)+SUBSTR(_dVencto,6,2)+SUBSTR(_dVencto,9,2))
			Endif
			
			If nItens>1
				
				cCodbar :=oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_CEAN:TEXT
				cProdFor:=oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_CPROD:TEXT
				nQuant	:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_QCOM:TEXT)
				xDesc	:=oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_XPROD:TEXT
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_NCM:TEXT"))=="C"
					cNCM	:=oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_NCM:TEXT
				Endif
				nPreco	:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_VUNCOM:TEXT)
				nDescont:=0
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_VDESC:TEXT"))=="C"
					nDescont:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_VDESC:TEXT)
				Endif
				nTotal	:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_VPROD:TEXT)
				cNota	:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT
				If Empty(cSerieNF)
					cSerie  :=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT
				Endif
				cNatOp  :=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NATOP:TEXT
				cUM		:=oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_UCOM:TEXT
				cEmissao:=SUBSTR(oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT,1,10)
				
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT"))=="C"
					_cCNPJ	:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
					_cEmpresa:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT"))=="C"
					_cCNPJ	:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT)
					_cEmpresa:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT)
				Endif
				
				cEmissao:=SUBSTR(cEmissao,1,4)+SUBSTR(cEmissao,6,2)+SUBSTR(cEmissao,9,2)
				cProd:=''
			Else
				cCodbar :=oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CEAN:TEXT
				cProdFor:=oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CPROD:TEXT
				nQuant	:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_QCOM:TEXT)
				nDescont:=0
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_VDESC:TEXT"))=="C"
					nDescont:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_VDESC:TEXT)
				Endif
				xDesc	:=oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_XPROD:TEXT
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_NCM:TEXT"))=="C"
					cNCM	:=oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_NCM:TEXT
				Endif
				nPreco	:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_VUNCOM:TEXT)
				nTotal	:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_VPROD:TEXT)
				cNota	:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT
				If Empty(cSerieNF)
					cSerie  :=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT
				Endif
				cNatOP	:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NATOP:TEXT
				cEmissao:=SUBSTR(oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT,1,10)
				cUM		:=oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_UCOM:TEXT
				
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT"))=="C"
					_cCNPJ	:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
					_cEmpresa:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT"))=="C"
					_cCNPJ	:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT)
					_cEmpresa:=ALLTRIM(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT)
				Endif
				cEmissao:=SUBSTR(cEmissao,1,4)+SUBSTR(cEmissao,6,2)+SUBSTR(cEmissao,9,2)
				cProd:=''
			Endif
		Else
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Sem _NFEPROC														Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT"))=="C"
				_cMensag:=ALLTRIM(oxml:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT)
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Vencimento Duplicata												Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_COBR:_DUP:_DVENC:TEXT"))=="C"
				_dVencto:=ALLTRIM(oxml:_NFE:_INFNFE:_COBR:_DUP:_DVENC:TEXT)
				_dVencto:=STOD(SUBSTR(_dVencto,1,4)+SUBSTR(_dVencto,6,2)+SUBSTR(_dVencto,9,2))
			Endif
			
			If nItens>1
				cCodbar :=oxml:_NFE:_INFNFE:_DET[i]:_PROD:_CEAN:TEXT
				cProdFor:=oxml:_NFE:_INFNFE:_DET[i]:_PROD:_CPROD:TEXT
				nQuant	:=val(oxml:_NFE:_INFNFE:_DET[i]:_PROD:_QCOM:TEXT)
				xDesc	:=oxml:_NFE:_INFNFE:_DET[i]:_PROD:_XPROD:TEXT
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_PROD:_NCM:TEXT"))=="C"
					cNCM	:=oxml:_NFE:_INFNFE:_DET[i]:_PROD:_NCM:TEXT
				Endif
				cUM		:=oxml:_NFE:_INFNFE:_DET[i]:_PROD:_UCOM:TEXT
				nDescont:=0
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_PROD:_VDESC:TEXT"))=="C"
					nDescont:=val(oxml:_NFE:_INFNFE:_DET[i]:_PROD:_VDESC:TEXT)
				Endif
				nPreco	:=val(oxml:_NFE:_INFNFE:_DET[i]:_PROD:_VUNCOM:TEXT)
				nTotal	:=val(oxml:_NFE:_INFNFE:_DET[i]:_PROD:_VPROD:TEXT)
				cNota	:=oxml:_NFE:_INFNFE:_IDE:_NNF:TEXT
				If Empty(cSerieNF)
					cSerie  :=oxml:_NFE:_INFNFE:_IDE:_SERIE:TEXT
				Endif
				cNatOP	:=oxml:_NFE:_INFNFE:_IDE:_NATOP:TEXT
				cEmissao:=SUBSTR(oxml:_NFE:_INFNFE:_IDE:_DEMI:TEXT,1,10)
				
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT"))=="C"
					_cCNPJ	:=ALLTRIM(oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
					_cEmpresa:=ALLTRIM(oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DEST:_CPF:TEXT"))=="C"
					_cCNPJ	:=ALLTRIM(oxml:_NFE:_INFNFE:_DEST:_CPF:TEXT)
					_cEmpresa:=ALLTRIM(oxml:_NFE:_INFNFE:_DEST:_CPF:TEXT)
				Endif
				cEmissao:=SUBSTR(cEmissao,1,4)+SUBSTR(cEmissao,6,2)+SUBSTR(cEmissao,9,2)
				cProd:=''
			Else
				cCodbar :=oxml:_NFE:_INFNFE:_DET:_PROD:_CEAN:TEXT
				cProdFor:=oxml:_NFE:_INFNFE:_DET:_PROD:_CPROD:TEXT
				nQuant	:=val(oxml:_NFE:_INFNFE:_DET:_PROD:_QCOM:TEXT)
				xDesc	:=oxml:_NFE:_INFNFE:_DET:_PROD:_XPROD:TEXT
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET:_PROD:_NCM:TEXT"))=="C"
					cNCM	:=oxml:_NFE:_INFNFE:_DET:_PROD:_NCM:TEXT
				Endif
				nDescont:=0
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET:_PROD:_VDESC:TEXT"))=="C"
					nDescont:=val(oxml:_NFE:_INFNFE:_DET:_PROD:_VDESC:TEXT)
				Endif
				cUM		:=oxml:_NFE:_INFNFE:_DET:_PROD:_UCOM:TEXT
				nPreco	:=val(oxml:_NFE:_INFNFE:_DET:_PROD:_VUNCOM:TEXT)
				nTotal	:=val(oxml:_NFE:_INFNFE:_DET:_PROD:_VPROD:TEXT)
				cNota	:=oxml:_NFE:_INFNFE:_IDE:_NNF:TEXT
				If Empty(cSerieNF)
					cSerie  :=oxml:_NFE:_INFNFE:_IDE:_SERIE:TEXT
				Endif
				cNatOP	:=oxml:_NFE:_INFNFE:_IDE:_NATOP:TEXT
				cEmissao:=SUBSTR(oxml:_NFE:_INFNFE:_IDE:_DEMI:TEXT,1,10)
				
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT"))=="C"
					_cCNPJ	:=ALLTRIM(oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
					_cEmpresa:=ALLTRIM(oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DEST:_CPF:TEXT"))=="C"
					_cCNPJ	:=ALLTRIM(oxml:_NFE:_INFNFE:_DEST:_CPF:TEXT)
					_cEmpresa:=ALLTRIM(oxml:_NFE:_INFNFE:_DEST:_CPF:TEXT)
				Endif
				cEmissao:=SUBSTR(cEmissao,1,4)+SUBSTR(cEmissao,6,2)+SUBSTR(cEmissao,9,2)
				cProd:=''
			Endif
		Endif
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё codigo barras														Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !Empty(cCodbar) .and. SUBSTR(cCodbar,1,8)<>"00000000" .AND. !ALLTRIM(cCodbar) $ ALLTRIM("SEM GTIN")
			DbSelectarea("SB1")
			DbSetorder(5)
			Dbgotop()
			Dbseek(xFilial("SB1")+cCodbar,.t.)
			If Found() .and. SB1->B1_MSBLQL<>"1"
				cProd:=SB1->B1_COD
			Endif
			If Empty(cProd)
				DbSelectarea("SLK")
				DbSetorder(1)
				Dbgotop()
				Dbseek(xFilial("SLK")+cCodbar,.t.)
				If Found()
					cProd:=SLK->LK_CODIGO
					
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Verifico se esta bloqueado											Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					DbSelectarea("SB1")
					DbSetorder(1)
					Dbgotop()
					Dbseek(xFilial("SB1")+cProd,.t.)
					If Found() .and. SB1->B1_MSBLQL=="1"
						cProd:=''
					Endif
				Endif
			Endif
		Endif
		/*
		If LEN(ALLTRIM(cProdfor))<=5
			cProdFor:=strzero(val(cProdfor),6)
		Endif
		*/
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Codigo do fornecedor												Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If LEN(ALLTRIM(cProdfor))>15
			nTam:=LEN(ALLTRIM(cProdfor))
			cProdFor:=SUBSTR(cProdfor,(nTam-15)+1,15)
		Endif
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Amarracao produto x fornecedor										Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Empty(cCodbar) .or. Empty(cProd)
			IF EMPTY(LS3->NFREF) .OR. (!EMPTY(LS3->NFREF) .AND. _cTIPONF == "B")
				/* FB
				DbSelectarea("SA5")
				DbSetorder(13)
				Dbgotop()
				Dbseek(xFilial("SA5")+cProdFor)
				While !Eof() .AND. ALLTRIM(SA5->A5_CODPRF)==ALLTRIM(cProdFor)
					IF SA5->A5_FORNECE==LS3->FORNEC .AND. SA5->A5_LOJA==LS3->LOJA
						cProd:=SA5->A5_PRODUTO
						
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Verifico se esta bloqueado											Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						DbSelectarea("SB1")
						DbSetorder(1)
						Dbgotop()
						Dbseek(xFilial("SB1")+cProd,.t.)
						If Found() .and. SB1->B1_MSBLQL=="1"
							cProd:=''
						Endif
						If !Empty(cProd)
							If Empty(cCodbar)
								cCodbar:=POSICIONE("SB1",1,xFilial("SB1")+cProd,"B1_CODBAR")
							Endif
						Endif
					Endif
					DbSelectarea("SA5")
					Dbskip()
				End
				*/
				DbSelectarea("SA5")
				DbSetorder(14) //A5_FILIAL, A5_FORNECE, A5_LOJA, A5_CODPRF, R_E_C_N_O_, D_E_L_E_T_
				IF Dbseek(xFilial("SA5")+PADR(LS3->FORNEC,TAMSX3("A5_FORNECE")[1])+PADR(LS3->LOJA,TAMSX3("A5_LOJA")[1])+PADR(cProdFor,TAMSX3("A5_CODPRF")[1]))
					cProd:=SA5->A5_PRODUTO
						
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Verifico se esta bloqueado											Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					DbSelectarea("SB1")
					DbSetorder(1)
					Dbgotop()
					Dbseek(xFilial("SB1")+cProd,.t.)
					If Found() .and. SB1->B1_MSBLQL=="1"
							cProd:=''
					Endif
					If !Empty(cProd)
						If Empty(cCodbar)
							cCodbar:=POSICIONE("SB1",1,xFilial("SB1")+cProd,"B1_CODBAR")
						Endif
					Endif
				EndIf
			ELSE
				DbSelectarea("SA7")
				DbSetorder(3) //A7_FILIAL, A7_CLIENTE, A7_LOJA, A7_CODCLI, R_E_C_N_O_, D_E_L_E_T_
				IF Dbseek(xFilial("SA7")+PADR(LS3->FORNEC,TAMSX3("A7_CLIENTE")[1])+PADR(LS3->LOJA,TAMSX3("A7_LOJA")[1])+PADR(cProdFor,TAMSX3("A7_PRODUTO")[1]))
					cProd := SA7->A7_PRODUTO
							
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Verifico se esta bloqueado											Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					DbSelectarea("SB1")
					DbSetorder(1)
					IF Dbseek(xFilial("SB1")+cProd,.t.)
						If SB1->B1_MSBLQL == "1"
							cProd := ''
						Endif
						If !Empty(cProd)
							If Empty(cCodbar)
								cCodbar := POSICIONE("SB1",1,xFilial("SB1")+cProd,"B1_CODBAR")
							Endif
						Endif
					ENDIF
				ENDIF			
			ENDIF
		Endif
		
		_nQE:=1
		
		If Empty(cProd)
			cProd:="999999"
			_cDescricao:=xDesc
		Else
			_cDescricao := POSICIONE("SB1",1,xFilial("SB1")+cProd,"B1_DESC")
			//_nQE        := POSICIONE("SB1",1,xFilial("SB1")+cProd,"B1_QE")
		Endif
		/*
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Unidade de medidas unitarias										Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		IF cUM $ cUnidades
			_nQE:=1
		Endif
		*/
		If ALLTRIM(cProd)<>"999999"
			DbSelectarea("LS5")
			DbSetorder(1)
			Dbgotop()
			Dbseek(cProd)
			if !Found()
				Reclock("LS5",.T.)
				LS5->PRODUTO:=cProd
				MsUnlock()
			Endif
		Endif
		
		IF ALLTRIM(cProd)<>"999999"
			_nCusto:=ULTPED(cProd)
		Else
			_nCusto:=0
		Endif
		
		_nPreco:=((nTotal-nDescont)/(nQuant*_nQE))
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Gravando produtos do XML											Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		_cCodFor:=''
		For w:=1 to LEN(ALLTRIM(cProdFor))
			IF SUBSTR(UPPER(cProdFor),w,1) $ "A/B/C/D/E/F/G/H/I/J/K/L/M/N/O/P/Q/R/S/T/U/V/X/Z/W/Y/0/1/2/3/4/5/6/7/8/9"
				_cCodFor:=ALLTRIM(_cCodFor)+SUBSTR(UPPER(cProdFor),w,1)
			Endif
		Next
		cProdFor:=_cCodFor
		
		Reclock("LS1",.T.)
		LS1->SEQ:=nTotIt
		LS1->CODBAR:=cCodbar
		LS1->PRODUTO:=cProd
		LS1->PRODFOR:=cProdFor
		LS1->DESCRICAO:=UPPER(_cDescricao)
		LS1->DESCORI:=UPPER(xDesc)
		LS1->QUANTIDADE:=(nQuant*_nQE)
		LS1->PRECO:=_nPreco
		LS1->CUSTO:=_nCusto
		LS1->NCM:=IIF(LEN(ALLTRIM(cNCM))>=8,SUBSTR(cNCM,1,10),"")
		LS1->PRECOFOR:=(nTotal/(nQuant*_nQE))
		LS1->TOTAL:=(nTotal-nDescont)
		IF ALLTRIM(cProd)=="999999"
			LS1->OK:="X"
		Else
			IF 100-((_nPreco/_nCusto)*100)>10 .OR. 100-((_nPreco/_nCusto)*100)<-10
				LS1->OK:="O"
			Endif
		Endif
		LS1->EMISSAO:=cEmissao
		LS1->ALTERADO:="N"
		LS1->DESCONTO:=nDescont
		LS1->UM:=UPPER(cUM)
		LS1->NOTA:=LS3->NOTA
		LS1->NOME:=LS3->NOME
		LS1->QE:=_nQE
		LS1->CAIXAS:=nQuant
		LS1->TOTALNF:=nTotal
		
		MsUnlock()
		nTotIt:=nTotIt+1
		nTotalNF:=nTotalNF+(nTotal-nDescont)
	Next
Else
	Msgbox("Problema ao abrir o arquivo XML!","AtenГЦo...","ALERT")
Endif

If nTotalNF==0
	Msgbox("Problema ao abrir o arquivo XML!","AtenГЦo...","ALERT")
Endif

IF EMPTY(LS3->NFREF)
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Fornecedor															Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectarea("SA2")
	DbSetorder(1)
	Dbgotop()
	Dbseek(xFilial("SA2")+LS3->FORNEC+LS3->LOJA)
	If Found()
		_cFornecedor:=SUBSTR(SA2->A2_NREDUZ,1,25)
		_cEnd:=ALLTRIM(SA2->A2_END)+" - "+SA2->A2_BAIRRO
		_cCidade:=ALLTRIM(SA2->A2_MUN)+"/"+SA2->A2_EST
		_cEmissao:=dtoc(stod(LS1->EMISSAO))
		_cCNPJ:=SA2->A2_CGC
		_cTelefone:=SA2->A2_TEL
	Endif
ELSE
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Cliente     														Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectarea("SA1")
	DbSetorder(1)
	Dbgotop()
	Dbseek(xFilial("SA1")+LS3->FORNEC+LS3->LOJA)
	If Found()
		_cFornecedor:=SUBSTR(SA1->A1_NREDUZ,1,25)
		_cEnd:=ALLTRIM(SA1->A1_END)+" - "+SA1->A1_BAIRRO
		_cCidade:=ALLTRIM(SA1->A1_MUN)+"/"+SA1->A1_EST
		_cEmissao:=dtoc(stod(LS1->EMISSAO))
		_cCNPJ:=SA1->A1_CGC
		_cTelefone:=SA1->A1_TEL
	Endif
ENDIF

If LEN(ALLTRIM(cNota))<=5
	cNota:=strzero(val(cNota),6)
Endif
If cZeros
	cNota:=strzero(val(cNota),9)
Endif

DbSelectarea("LS3")
DbSelectarea("LS1")
Dbsetorder(1)
Dbgotop()
OBRWI:obrowse:refresh()
OBRWP:obrowse:refresh()
OBRWI:obrowse:setfocus()
OBRWP:obrowse:setfocus()
ObjectMethod(oTela,"Refresh()")
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fornecedor															Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function ABREPED()
DbSelectarea("SC7")
SET FILTER TO C7_FILIAL==xFilial("SC7") .AND. C7_NUM==LS2->PEDIDO
MATA121()
DbSelectarea("SC7")
SET FILTER TO
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Confirma produto													Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function RECUSAR()

cResp:=msgbox("Deseja recusar o recebimento da nota fiscal "+cNota+" ?","AtenГЦo...","YESNO")

If cResp
	
	_cSenha:=Space(06)
	
	@ 0,0 TO 100,235 DIALOG oSenha TITLE "Informe a Senha para acesso..."
	@ 10,10 SAY "Senha "  FONT oFont1 OF oSenha PIXEL
	@ 10,40 Get _cSenha Picture "@!" Size 20,20  Valid .T.  PASSWORD
	@ 30,40 BUTTON "Confirma" SIZE 35,12 ACTION Close(oSenha)
	ACTIVATE DIALOG oSenha CENTER
	
	If Empty(_cSenha)
		Return
	Endif
	
	If ALLTRIM(_cSenha)<>SUBSTR(DTOC(M->DDATABASE),1,2)+SUBSTR(DTOC(M->DDATABASE),4,2)+SUBSTR(DTOC(M->DDATABASE),7,2)
		Msgbox("Senha invАlida!")
		Return
	Endif
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se foi cadastrado os email de recusa 								Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !Empty(xEMAILREC)
		cResp:=msgbox("Deseja enviar um email para ficar documentado esta recusa?","AtenГЦo...","YESNO")
		If cResp
			EMAIL()
		Endif
	Endif
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Dados do fornecedor													Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectarea("SA2")
	DbSetorder(1)
	Dbgotop()
	Dbseek(xFilial("SA2")+LS3->FORNEC+LS3->LOJA)
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Nomeclatura dos arquivos											Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	_cFileOri:="\xml\" + ALLTRIM(LS3->XML)
	_cFileNew:="\xml\" + ALLTRIM(SA2->A2_CGC)+"-nf"+ALLTRIM(LS3->NOTA)+"-"+ALLTRIM(LS3->CHAVE)+".xml.rec"
	
	FRename(_cFileOri,_cFileNew)
	__CopyFile("\xml\*.rec","\xml\recusado\")
	ferase(_cFileNew)
	
	Msgbox("Nota Fiscal recusada com sucesso!","AtenГЦo...","INFO")
	
	Reclock("LS3",.F.)
	dbdelete()
	MsUnlock()
	
	DbSelectarea("LS3")
	Dbgotop()
	
	DbSelectarea("LS1")
	Dbsetorder(1)
	Dbgotop()
	While !Eof()
		Reclock("LS1",.F.)
		dbdelete()
		MsUnlock()
		Dbskip()
	End
	
	DbSelectarea("LS5")
	Dbsetorder(1)
	Dbgotop()
	While !Eof()
		Reclock("LS5",.F.)
		dbdelete()
		MsUnlock()
		Dbskip()
	End
	PROCESS()
Endif
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Divergencias														Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function DIVERG()

aCampos4:= {{"FLAG","C",1,0 },;
{"OK","C",15,0 },;
{"PRODUTO","C",15,0 },;
{"DESCRICAO","C",50,0 },;
{"PRCPED","N",9,2 },;
{"PRCNFE","N",9,2 },;
{"QTDPED","N",9,2 },;
{"QTDNFE","N",9,2 }}

cArqTrab4  := CriaTrab(aCampos4)
dbUseArea( .T.,, cArqTrab4, "LS4", if(.F. .OR. .F., !.F., NIL), .F. )
IndRegua("LS4",cArqTrab4,"DESCRICAO",,,)
dbSetIndex( cArqTrab4 +OrdBagExt())
dbSelectArea("LS4")
_nMaior:=0

Dbselectarea("PRO")
DbSetorder(1)
Dbgotop()
While !Eof()
	
	cQuery:=" SELECT COUNT(*) QTD,AVG(C7_PRECO) PRECO,SUM(C7_QUANT-C7_QUJE-C7_QTDACLA) QUANT FROM SC7"+SM0->M0_CODIGO+"0 WHERE C7_FILIAL='"+xFilial("SC7")+"' "
	If !lItem
		cQuery:=cQuery + " AND C7_NUM='"+LS2->PEDIDO+"' "
	Else
		cQuery:=cQuery + " AND C7_NUM='"+PRO->PEDIDO+"' "
		cQuery:=cQuery + " AND C7_ITEM='"+PRO->ITEM+"' "
	Endif
	cQuery:=cQuery + " AND C7_PRODUTO='"+PRO->PRODUTO+"' "
	If lItem
	Endif
	cQuery:=cQuery + " AND C7_RESIDUO<>'S' "
	cQuery:=cQuery + " AND C7_ENCER<>'E' "
	cQuery:=cQuery + " AND D_E_L_E_T_<>'*' "
	TCQUERY cQuery NEW ALIAS "TCQ"
	DbSelectarea("TCQ")
	While !Eof()
		IF TCQ->QTD==0
			Reclock("LS4",.T.)
			LS4->PRODUTO:=PRO->PRODUTO
			LS4->DESCRICAO:=PRO->DESCRICAO
			LS4->PRCNFE:=round(PRO->PRECO,2)
			LS4->OK:="Nao Existe"
			MsUnlock()
			DbSelectarea("TCQ")
			Dbskip()
			Loop
		Endif
		
		If (TCQ->QUANT<PRO->QUANTIDADE .AND. TCQ->QUANT>0)
			Reclock("LS4",.T.)
			LS4->PRODUTO:=PRO->PRODUTO
			LS4->DESCRICAO:=PRO->DESCRICAO
			LS4->QTDPED:=TCQ->QUANT
			LS4->QTDNFE:=PRO->QUANTIDADE
			LS4->PRCPED:=round(TCQ->PRECO,2)
			LS4->PRCNFE:=round(PRO->PRECO,2)
			LS4->OK:="Quantidade"
			MsUnlock()
			If (round(PRO->PRECO,2)>round(TCQ->PRECO,2)) .AND. round(TCQ->PRECO,2)>0
				_nMaior:=_nMaior+(PRO->QUANTIDADE*(round(PRO->PRECO,2)-round(TCQ->PRECO,2)))
			Endif
			DbSelectarea("TCQ")
			DbSkip()
			Loop
		Endif
		If (round(PRO->PRECO,2)>round(TCQ->PRECO,2)) .AND. round(TCQ->PRECO,2)>0 .AND. TCQ->QUANT>0
			Reclock("LS4",.T.)
			LS4->PRODUTO:=PRO->PRODUTO
			LS4->DESCRICAO:=PRO->DESCRICAO
			LS4->PRCPED:=round(TCQ->PRECO,2)
			LS4->PRCNFE:=round(PRO->PRECO,2)
			LS4->QTDPED:=TCQ->QUANT
			LS4->QTDNFE:=PRO->QUANTIDADE
			LS4->OK:="Preco"
			MsUnlock()
			_nMaior:=_nMaior+(PRO->QUANTIDADE*(round(PRO->PRECO,2)-round(TCQ->PRECO,2)))
			DbSelectarea("TCQ")
			DbSkip()
			Loop
		Endif
		
		Reclock("LS4",.T.)
		LS4->PRODUTO:=PRO->PRODUTO
		LS4->DESCRICAO:=PRO->DESCRICAO
		LS4->PRCPED:=round(TCQ->PRECO,2)
		LS4->PRCNFE:=round(PRO->PRECO,2)
		LS4->QTDPED:=TCQ->QUANT
		LS4->QTDNFE:=PRO->QUANTIDADE
		If TCQ->QUANT>=PRO->QUANTIDADE
			LS4->FLAG:="X"
			LS4->OK:="Identificado"
		Else
			LS4->OK:="Sem saldo!"
		Endif
		MsUnlock()
		DbSelectarea("TCQ")
		Dbskip()
	End
	DbClosearea("TCQ")
	Dbselectarea("PRO")
	Dbskip()
End

DbSelectarea("LS4")
Dbgotop()

aTitulo4 := {}
AADD(aTitulo4,{"OK","DivergЙncia"})
AADD(aTitulo4,{"PRODUTO","Produto"})
AADD(aTitulo4,{"DESCRICAO","DescriГЦo"})
AADD(aTitulo4,{"PRCPED","R$ Pedido","@E 99,999.99"})
AADD(aTitulo4,{"PRCNFE","R$ Nota","@E 99,999.99"})
AADD(aTitulo4,{"QTDPED","Qtd.Pedido","@E 99,999.99"})
AADD(aTitulo4,{"QTDNFE","Qtd.Nota","@E 99,999.99"})

If !LS4->(eof())
	@ 120,040 TO 400,880 DIALOG oAmar TITLE "DivergЙncias encontradas..."
	@ 005,005 BUTTON "Sair" SIZE 55,10 ACTION oAmar:end()
	If _nMaior>0
		@ 005,100 say "Valor Total Excedido R$ "+Transform(_nMaior,"@E 99,999.99") FONT oFont1 OF oAmar PIXEL COLOR CLR_HRED
	Endif
	@ 020,005 TO 140,417 BROWSE "LS4" ENABLE " LS4->FLAG<>'X' " OBJECT OBRWA FIELDS aTitulo4
	ACTIVATE DIALOG oAmar CENTER
Else
	Msgbox("NЦo foram encontradas nenhuma divergЙncia!","AtenГЦo...","ALERT")
Endif
Dbselectarea("LS4")
dbCloseArea("LS4")
fErase( cArqTrab4+".DTC")
fErase( cArqTrab4+ OrdBagExt() )
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Envia email de nota recusada										Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function EMAIL()

Local cSubject  := "Nota fiscal "+cNota+" recusado o recebimento..."
Local cMsg      := ""
Local cAttach   := ""
Local aMsg      := {}
Local aUsrMail  := {}
Local lConectou := .f.
LOCAL cACCOUNT  := ALLTRIM(getmv("MV_RELACNT"))
LOCAL cPASSWORD := ALLTRIM(getmv("MV_RELPSW"))
LOCAL cSERVER   := ALLTRIM(getmv("MV_RELSERV"))

If Empty(XEMAILREC)
	Msgbox("Favor cadastrar os E-Mails que serЦo enviados a mensagem de recusa!")
	Msgbox("Use o configurador da rotina - Senha do Administrador...")
	Return
Endif

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lConectou

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Requer autenticacao													Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If getmv("MV_RELAUTH") == .T.
	MAILAUTh(cAccount,cPassword)
Endif

cMensagem := "Nota fiscal "+cNota+" recusado o recebimento devido algumas divergЙncias encontradas pelo comprador"+ ENTER
cMensagem := cMensagem+ " Fornecedor:"+_cFornecedor +"               CNPJ:"+_cCNPJ+ ENTER
cMensagem := cMensagem+ " Data EmissЦo:"+_cEmissao+ ENTER
cMensagem := cMensagem+ " Total da Nota Fiscal R$  "+ALLTRIM(STR(nTotalNF,12,2))+ ENTER
cMensagem := cMensagem+ ENTER
cMensagem := cMensagem+ ENTER
cMensagem := cMensagem+ "Caso tenha alguma dЗvida, entrar em contato com o comprador "+_cUsuario+ ENTER
cMensagem := cMensagem+ ENTER
cMensagem := cMensagem+ ENTER
cMensagem := cMensagem+ "NOTA FISCAL DO "+SM0->M0_FILIAL+ENTER
cMensagem := cMensagem+ ENTER
cMensagem := cMensagem+ "EMAIL AUTOMаTICO ENVIADO PELO SISTEMA,FAVOR NцO RESPONDй-LO"

SEND MAIL FROM cACCOUNT TO xEMAILREC SUBJECT cSubject BODY cMensagem RESULT lEnviado

If !lEnviado
	cMensagem := ""
	GET MAIL ERROR cMensagem
	Alert(cMensagem)
Endif
DISCONNECT SMTP SERVER Result lDesConectou
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Seleciona produto													Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function SELECIONA(_cProduto,lOpcao)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifico se o produto esta bloqueado para uso						Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Dbselectarea("SB1")
DbSetorder(1)
Dbgotop()
Dbseek(xFilial("SB1")+_cProduto)
If Found() .and. SB1->B1_MSBLQL=="1"
	msgbox("Produto bloqueado para uso!","AtenГЦo...","ALERT")
	return
Endif

_nQE:=LS1->QE
cMemo:=''

_nQuantPed:=0
_nVlrPed:=0

If cPedCom
	cQuery:=" SELECT C7_EMISSAO EMISSAO,C7_PRECO PRECO,C7_LOJA LOJA,C7_NUM PEDIDO,(C7_QUANT-C7_QUJE-C7_QTDACLA) QUANT FROM SC7"+SM0->M0_CODIGO+"0 WHERE C7_FILIAL='"+xFilial("SC7")+"' "
	cQuery:=cQuery + " AND C7_PRODUTO='"+ALLTRIM(_cProduto)+"' "
	cQuery:=cQuery + " AND C7_FORNECE='"+LS3->FORNEC+"' "
	cQuery:=cQuery + " AND (C7_QUANT-C7_QUJE-C7_QTDACLA)>0 "
	cQuery:=cQuery + " AND C7_RESIDUO<>'S' "
	cQuery:=cQuery + " AND C7_ENCER<>'E' "
	cQuery:=cQuery + " AND D_E_L_E_T_<>'*' "
	cQuery:=cQuery + " ORDER BY R_E_C_N_O_ DESC "
	TCQUERY cQuery NEW ALIAS "TCQ"
	DbSelectarea("TCQ")
	While !Eof()
		cMemo:=cMemo+DTOC(STOD(TCQ->EMISSAO))+"   "+TCQ->PEDIDO+"   "+TCQ->LOJA+"   "+ALLTRIM(STR(TCQ->QUANT,12,2))+"       "+transform(TCQ->PRECO,"@E 9,999.99")+ENTER
		If _nQuantPed==0
			_nQuantPed:=TCQ->QUANT
			_nVlrPed:=TCQ->PRECO
		Endif
		Dbskip()
	End
	DbClosearea("TCQ")
Endif

If Empty(cMemo)
	cmemo:="NЦo existe nenhum pedido com este produto..."
Endif


_nCaixas:=LS1->CAIXAS
_nQuant:=(_nQE*_nCaixas)
_nTotal:=LS1->TOTAL
_nPreco:=(LS1->TOTAL/(_nQE*_nCaixas))
_nQuantNF:=LS1->QUANTIDADE

If _nCaixas==0
	_nQuant:=_nQuantNF
	_nPreco:=(_nTotal/_nQuant)
Else
	_nQuant:=(_nQE*_nCaixas)
	_nPreco:=(_nTotal/_nQuant)
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tela de parametros													Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
lGravou:=.F.

cPict1:="@E 99,999."
For w:=1 to cDecQtd
	cPict1:=ALLTRIM(cPict1)+"9"
Next

cPict2:="@E 99,999."
For w:=1 to cDecUni
	cPict2:=ALLTRIM(cPict2)+"9"
Next

@ 120,040 TO 450,370 DIALOG oDef TITLE "Produto "+_cProduto
/*
@ 005,005 say "Qtd.Emb."  FONT oFont1 OF oDef PIXEL
@ 015,005 get _nQE size 20,20 Picture "@E 999999" valid CALCULA()
@ 005,040 say "Cx.Nota"  FONT oFont1 OF oDef PIXEL
@ 015,040 get _nCaixas when .f. size 50,40 Picture cPict1
@ 005,100 say "Quantidade"  FONT oFont1 OF oDef PIXEL COLOR CLR_GREEN
@ 015,100 get _nQuant size 50,40 when .f. Picture cPict1

@ 025,005 say "PreГo R$"  FONT oFont1 OF oDef PIXEL COLOR CLR_GREEN
@ 035,005 get _nPreco size 50,40 WHEN .F. Picture cPict2
@ 025,055 say "Total R$"  FONT oFont1 OF oDef PIXEL
@ 035,055 get _nTotal when .f. size 50,40 Picture "@E 99,999.99"
*/

@ 005,005 say "Quantidade NF"  FONT oFont1 OF oDef PIXEL COLOR CLR_GREEN
@ 015,005 get _nQuant size 50,40 when .f. Picture cPict1
@ 005,060 say "PreГo R$"  FONT oFont1 OF oDef PIXEL COLOR CLR_GREEN
@ 015,060 get _nPreco size 50,40 WHEN .F. Picture cPict2
@ 005,115 say "Total R$"  FONT oFont1 OF oDef PIXEL
@ 015,115 get _nTotal when .f. size 50,40 Picture "@E 99,999.99"
/*
_nQuant2 := 0
_cSegUn  := ""
@ 025,005 say "Quant. 2 UN"  FONT oFont1 OF oDef PIXEL COLOR CLR_GREEN
@ 035,005 get _nQuant2 size 50,40 when .f. Picture cPict1
@ 025,060 say "2 UN"  FONT oFont1 OF oDef PIXEL COLOR CLR_GREEN
@ 035,060 get _cSegUn when .f. size 50,40 Picture "@E 99,999.99"
*/
@ 060,005 say "Pedidos em aberto"  FONT oFont1 OF oDef PIXEL COLOR CLR_HBLUE
@ 070,005 say "EmissЦo    Pedido   Lj  Quantidade  PreГo Unid."  FONT oFont1 OF oDef PIXEL COLOR CLR_HRED
@ 080,005 GET oMemo VAR cMemo MEMO SIZE 160,55 when .f. PIXEL OF oDef
@ 145,005 BUTTON "Confirmar" SIZE 50,10 ACTION GRAVANDO(lOpcao)
@ 145,060 BUTTON "Sair" SIZE 50,10 ACTION oDef:end()
ACTIVATE DIALOG oDef CENTER

If lGravou .and. lOpcao==2
	oAmarra:end()
Endif
Return


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Gravando produto...													Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static function GRAVANDO(lOpcao)

lDifer:=.F.
If _nQuantPed>0
	If _nQuant<>_nQuantPed
		Msgbox("Quantidade da Nota fiscal, diferente da quantidade do ultimo pedido!")
		lDifer:=.T.
	Endif
	
	If _nPreco>=(_nVlrPed+0.01)
		Msgbox("PreГo unitАrio da Nota fiscal, diferente do preГo do ultimo pedido!")
		lDifer:=.T.
	Endif
	
	If (_nPreco)>(_nVlrPed+1)
		Msgbox("PreГo da nota fiscal, muito maior que do ultimo pedido!")
		lDifer:=.T.
	Endif
Endif

If lDifer
	cResp:=Msgbox("Deseja gravar o produto mesmo assim?","AtenГЦo...","YESNO")
	If cResp==.F.
		Return
	Endif
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifico se o codigo de barras existe								Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lOpcao==2
	_cProduto:=LS4->PRODUTO
Else
	_cProduto:=LS1->PRODUTO
Endif

_cCodBarras:=''
DbSelectarea("SB1")
DbSetorder(1)
Dbgotop()
Dbseek(xFilial("SB1")+_cProduto)
If Found()
	_cCodBarras:=SB1->B1_CODBAR
Endif

_nCusto:=ULTPED(_cProduto)
_nPrecoA:=(LS1->TOTAL/_nQuant)

If lOpcao==2
	DbSelectarea("LS1")
	Reclock("LS1",.F.)
	IF 100-((_nPrecoA/_nCusto)*100)>10 .OR. 100-((_nPrecoA/_nCusto)*100)<-10
		LS1->OK:="O"
	Else
		LS1->OK:=""
	Endif
	LS1->PRODUTO:=_cProduto
	LS1->DESCRICAO:=LS4->DESCRICAO
	LS1->ALTERADO:="S"
	LS1->CAIXAS:=_nCaixas
	LS1->QUANTIDADE:=_nQuant
	LS1->PRECOFOR:=_nPreco
	LS1->PRECO:=(LS1->TOTAL/_nQuant)
	LS1->CUSTO:=_nCusto
	LS1->QE:=_nQE
	MsUnlock()
	
	DbSelectarea("LS5")
	Reclock("LS5",.T.)
	LS5->PRODUTO:=_cProduto
	MsUnlock()
Else
	DbSelectarea("LS1")
	Reclock("LS1",.F.)
	LS1->ALTERADO:="S"
	IF 100-((_nPrecoA/_nCusto)*100)>10 .OR. 100-((_nPrecoA/_nCusto)*100)<-10
		LS1->OK:="O"
	Else
		LS1->OK:=""
	Endif
	LS1->CAIXAS:=_nCaixas
	LS1->QUANTIDADE:=_nQuant
	LS1->PRECOFOR:=_nPreco
	LS1->PRECO:=(LS1->TOTAL/_nQuant)
	LS1->CUSTO:=ULTPED(LS1->PRODUTO)
	LS1->QE:=_nQE
	MsUnlock()
Endif

OBRWI:obrowse:refresh()
OBRWP:obrowse:refresh()
ObjectMethod(oTela,"Refresh()")

DbSelectarea("LS1")
DbSetorder(1)
Dbgotop()
Dbseek(nSeek)

lGravou:=.T.
oDef:end()
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Filtrar produtos													Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function FILTRE()

If LEN(ALLTRIM(_cFiltrox))>2
	Dbselectarea("LS4")
	Dbgotop()
	While !Eof()
		Reclock("LS4",.F.)
		dbdelete()
		MsUnlock()
		Dbskip()
	End
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁVerifica se a pesquisa do produto foi sub-dividida			Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	_cDesc1:=''
	_cDesc2:=''
	_cDesc3:=''
	
	For w:=1 to LEN(ALLTRIM(_cFiltrox))
		If SUBSTR(ALLTRIM(_cFiltrox),w,1) $ ";/,"
			cont2:=(w-1)
			_cDesc1:=SUBSTR(_cFiltrox,1,cont2)
			w:=100
		Endif
	Next
	
	If !Empty(_cDesc1)
		_nInicio:=(cont2+2)
		_cString:=SUBSTR(ALLTRIM(_cFiltrox),_nInicio,50)
		If !empty(_cString)
			For w:=1 to LEN(ALLTRIM(_cString))
				If SUBSTR(ALLTRIM(_cString),w,1) $ ";/,"
					cont2:=(w-1)
					_cDesc2:=SUBSTR(_cString,1,cont2)
					w:=100
				Endif
			Next
			
			If Empty(_cDesc2)
				_cDesc2:=ALLTRIM(_cString)
			Endif
		Endif
	Endif
	
	If !Empty(_cDesc2)
		_nInicio:=(cont2+2)
		_cString2:=SUBSTR(ALLTRIM(_cString),_nInicio,50)
		If !empty(_cString2)
			For w:=1 to LEN(ALLTRIM(_cString2))
				If SUBSTR(ALLTRIM(_cString2),w,1) $ ";/,"
					cont2:=(w-1)
					_cDesc3:=SUBSTR(_cString2,1,cont2)
					w:=100
				Endif
			Next
			
			If Empty(_cDesc3)
				_cDesc3:=ALLTRIM(_cString2)
			Endif
		Endif
	Endif
	
	If Empty(_cDesc1)
		_cDescp1:="%"+ALLTRIM(_cFiltrox)+"%"
	Else
		_cDescp1:="%"+ALLTRIM(_cDesc1)+"%"
		_cDescp2:="%"+ALLTRIM(_cDesc2)+"%"
		_cDescp3:="%"+ALLTRIM(_cDesc3)+"%"
	Endif
	
	cQuery:=" SELECT B1_MSBLQL BLQ,B1_CODBAR CODBAR,B1_COD PRODUTO,B1_DESC DESCRICAO FROM SB1"+SM0->M0_CODIGO+"0 "
	cQuery:=cQuery + " 	WHERE B1_FILIAL='"+xFilial("SB1")+"' AND (B1_DESC LIKE '"+_cDescp1+"' OR B1_COD LIKE '"+ALLTRIM(_cDescp1)+"') "
	IF !Empty(_cDesc2)
		cQuery:=cQuery + " AND B1_DESC LIKE '"+_cDescp2+"' "
	Endif
	IF !Empty(_cDesc3)
		cQuery:=cQuery + " AND B1_DESC LIKE '"+_cDescp3+"' "
	Endif
	cQuery:=cQuery + " AND D_E_L_E_T_<>'*' "
	TCQUERY cQuery NEW ALIAS "TCQ"
	DbSelectarea("TCQ")
	While !Eof()
		If cPedCom
			lPedido:=TEMPED(TCQ->PRODUTO)
		Else
			lPedido:="NЦo"
		Endif
		If (lCheck1 .and. lPedido=="Sim" .or. lCheck1==.F.)
			
			DbSelectarea("SB1")
			DbSetorder(1)
			Dbgotop()
			Dbseek(xFilial("SB1")+TCQ->PRODUTO)
			
			If Empty(cAlmox)
				cAlmox:=SB1->B1_LOCPAD
			Endif
			
			Reclock("LS4",.T.)
			LS4->PRODUTO:=TCQ->PRODUTO
			IF "SAIU" $ TCQ->DESCRICAO
				LS4->DESCRICAO:=SUBSTR(TCQ->DESCRICAO,6,45)
			Else
				LS4->DESCRICAO:=TCQ->DESCRICAO
			Endif
			LS4->SALDO:=POSICIONE("SB2",2,xFilial("SB2")+cAlmox+TCQ->PRODUTO,"B2_QATU-B2_RESERVA-B2_QEMP")
			LS4->QE:=SB1->B1_QE
			LS4->PEDIDO:=lPedido
			LS4->BLQ:=IIF(TCQ->BLQ=="1","Bloq.","Ativo")
			MsUnlock()
		Endif
		DbSelectarea("TCQ")
		Dbskip()
	End
	DbClosearea("TCQ")
	
	Dbselectarea("LS4")
	Dbgotop()
Endif
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Calcula produto														Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function CALCULA()

If _nCaixas==0
	_nQuant:=_nQuantNF
	_nPreco:=(_nTotal/_nQuant)
Else
	_nQuant:=(_nQE*_nCaixas)
	_nPreco:=(_nTotal/_nQuant)
Endif
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Calcula produto														Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function TEMPED(_cProduto)

cQuery:=" SELECT COUNT(*) QTD FROM SC7"+SM0->M0_CODIGO+"0 WHERE C7_FILIAL='"+xFilial("SC7")+"' "
cQuery:=cQuery + " AND C7_PRODUTO='"+ALLTRIM(TCQ->PRODUTO)+"' "
cQuery:=cQuery + " AND C7_FORNECE='"+LS3->FORNEC+"' "
cQuery:=cQuery + " AND (C7_QUANT-C7_QUJE-C7_QTDACLA)>0 "
cQuery:=cQuery + " AND C7_RESIDUO<>'S' "
cQuery:=cQuery + " AND C7_ENCER<>'E' "
cQuery:=cQuery + " AND D_E_L_E_T_<>'*' "
TCQUERY cQuery NEW ALIAS "PED"
DbSelectarea("PED")
lPedido:=PED->QTD
DbClosearea("PED")

If lPedido>0
	_cTem:="Sim"
Else
	_cTem:="NЦo"
Endif
Return(_cTem)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Refazer Nota fiscal													Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function REFAZER()

cResp:=msgbox("Deseja refazer toda a nota fiscal?","AtenГЦo...","YESNO")

If cResp
	PROCESS()
Endif
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Recebendo email automaticamente										Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function POPEMAIL()

Local oMessage
Local oPopServer
Local aAttInfo
Local nPortPop    := IIF("GMAIL" $ UPPER(xCONTA) .OR. "HOTMAIL" $ UPPER(xCONTA),995,110)
Local nPopResult  := 0
Local nMessages   := 0
Local nMessage    := 0
Local lMessageDown:= .F.
Local nCount      := 0
Local nAtach      := 0
Local nMessageDown:= 0

//xPOP   := "pop.gmail.com"
//xCONTA := "importador.allss@gmail.com"
//xSENHA := "Importador2019" 

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Path para salvar anexos												Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cRootPath := ALLTRIM(GetSrvProfString("Rootpath",""))+"\xml\"
cRootPath2:= ALLTRIM(GetSrvProfString("Rootpath",""))+"\xml\arquivado\"

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Cria Objeto															Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oPopServer := TMailManager():New()
If "GMAIL" $ UPPER(xCONTA) .OR. "HOTMAIL" $ UPPER(xCONTA)
	oPopServer:setUseSSL(.T.) //Usa conexЦo segura
Endif
nErro := oPopServer:Init( xPOP,"",xCONTA,xSENHA, nPortPop, 995 )
If nErro != 0
    sErro := oMailManager:GetErrorString( nErro )
    Alert( sErro )
    Return .F.
EndIf 

nNaoImp    :=0

If ((nPopResult := oPopServer:PopConnect()) == 0)
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Total de Mensagens na caixa de entrada								Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oPopServer:GetNumMsgs(@nMessages)
	
	If nMessages > 0
		If msgbox("Existem " + Transform(nMessages,"@E ###,###") + " mensagens pendentes. Deseja baixА-las agora ?","AtenГЦo...","YESNO")
			If nMessages > 500
				Msgbox("O programa irА baixar 500 mensagens neste momento...","AtenГЦo...","ALERT")
				nMessages := 500
			Endif
		Else
			nMessages := 0
		Endif
		nNaoImp := nMessages
	Endif
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Leitura das Mensagens												Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If( nMessages > 0 )
		oMessage := TMailMessage():New()
		
		For nMessage := 1 To nMessages
			oMessage:Clear()
			nPopResult := oMessage:Receive( oPopServer, nMessage)
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Recebendo mensagem													Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If (nPopResult == 0 )
				nCount := 0
				lMessageDown := .F.
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Lendo todos anexos da mensagem										Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				lSalvou:=.F.
				For nAtach := 1 to oMessage:getAttachCount()
					aAttInfo:= oMessage:getAttachInfo(nAtach)
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Salvando anexos - somente XML										Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If ".XML" $ UPPER(aAttInfo[1])
						lSave := oMessage:SaveAttach(nAtach,cRootPath+aAttInfo[1])
						
						If File("\xml\arquivado")
							lSave2 := oMessage:SaveAttach(nAtach,cRootPath2+aAttInfo[1])						
						Endif
						
						If lSave
							lSalvou:=.T.
						Endif
					Endif
				Next
			Endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Apagando mensagem da caixa de entrada								Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lSalvou
				oPopServer:DeleteMsg(nMessage)
				nNaoImp:=(nNaoImp-1)
			Endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Leitura da proxima mensagem											Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lMessageDown
				nMessageDown++
			EndIf
		Next
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Desconectando do servidor											Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oPopServer:PopDisconnect()
	
	If nNaoImp>0
		Msgbox("NЦo foi possivel receber "+ALLTRIM(str(nNaoImp,5,0))+" mensagens...","AtenГЦo...","ALERT")
	Endif
Else

	Alert( oPopServer:GetErrorString( nPopResult ) )

EndIf
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Excluir amarracao													Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function EXCAMA()

If Empty(LS1->OK) .OR. LS1->OK=="O"
	cResp := msgbox("Deseja excluir a amarraГЦo do produto?","AtenГЦo...","YESNO")
	
	If cResp
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Excluindo da tabela de produtos identificados						Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		DbSelectarea("LS5")
		DbSetorder(1)
		Dbgotop()
		Dbseek(LS1->PRODUTO)
		If Found()
			Reclock("LS5",.F.)
			dbdelete()
			MsUnlock()
		Endif
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Excluindo da tabela amarracao produto x fornecedor					Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		DbSelectarea("SA5")
		DbSetorder(1)
		Dbgotop()
		Dbseek(xFilial("SA5")+LS3->FORNEC+LS3->LOJA+LS1->PRODUTO)
		If Found()
			Reclock("SA5",.F.)
			dbdelete()
			MsUnlock()
		Endif
		
		Reclock("LS1",.F.)
		LS1->DESCRICAO:=LS1->DESCORI
		LS1->PRODUTO:="999999"
		LS1->OK:="X"
		MsUnlock()
	Endif
Else
	Msgbox("NЦo existe amarraГЦo para este produto!")
Endif
*/
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ultimo preco de pedido												Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function ULTPED(_cProduto)
_nPedido:=0
_nQtd:=1

cQuery:=" SELECT C7_PRECO PRECO FROM SC7"+SM0->M0_CODIGO+"0 WHERE C7_FILIAL='"+xFilial("SC7")+"' AND C7_PRODUTO='"+ALLTRIM(_cProduto)+"' AND C7_FORNECE='"+LS3->FORNEC+"' AND C7_PRECO>0 AND D_E_L_E_T_<>'*' ORDER BY C7_EMISSAO DESC "
TCQUERY cQuery NEW ALIAS "TCQ"
DbSelectarea("TCQ")
While !Eof() .and. _nQtd==1
	_nPedido:=TCQ->PRECO
	_nQtd:=2
	Dbskip()
End
Dbclosearea("TCQ")

If _nPedido<=0
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Caso nao encontre, ultimo preco de entrada							Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	_nPedido:=POSICIONE("SB1",1,xFilial("SB1")+_cProduto,"B1_UPRC")
Endif
Return(_nPedido)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Eliminar pedido														Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function ELIMINAR()

IF (DDATABASE-LS2->EMISSAO)<=30
	msgbox("O pedido tem que ter mais de 30 dias de vencimento!")
	Return
Endif

IF LS2->OK<>"X"
	cResp:=msgbox("Deseja eliminar o resМduo do pedido "+LS2->PEDIDO+"?","AtenГЦo...","YESNO")
	
	If cResp
		lEntrou:=.F.
		DbSelectarea("SC7")
		DbSetorder(1)
		dbgotop()
		Dbseek(xFilial("SC7")+LS2->PEDIDO)
		While !Eof() .and. ALLTRIM(SC7->C7_NUM)==ALLTRIM(LS2->PEDIDO)
			IF SC7->C7_QTDACLA<=0
				IF SC7->C7_RESIDUO<>"S" .and. (SC7->C7_QUANT-SC7->C7_QUJE)>0
					Reclock("SC7",.F.)
					SC7->C7_RESIDUO:="S"
					MsUnlock()
					lEntrou:=.T.
					
					DbSelectarea("SB2")
					DbSetorder(2)
					Dbgotop()
					Dbseek(xFilial("SB2")+SC7->C7_LOCAL+SC7->C7_PRODUTO)
					If Found()
						Reclock("SB2",.F.)
						SB2->B2_SALPEDI:=(SB2->B2_SALPEDI-(SC7->C7_QUANT-SC7->C7_QUJE))
						MsUnlock()
					Endif
				Endif
			Endif
			DbSelectarea("SC7")
			Dbskip()
		End
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Apagando pedido do browse											Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lEntrou
			DbSelectarea("LS2")
			Reclock("LS2",.F.)
			dbdelete()
			MsUnlock()
			dbgobottom()
			Msgbox("Pedido eliminado com sucesso!","AtenГЦo...","INFO")
		Endif
	Endif
Else
	Msgbox("Este pedido nЦo pode ser eliminado!","AtenГЦo...","ALERT")
Endif
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Mensagem nota fiscal												Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function MSGNF(_cMensag)

If !Empty(_cMensag)
	DEFINE MSDIALOG oMensNF FROM 0,0 TO 290,415 PIXEL TITLE "Mensagem da Nota Fiscal"
	@ 005,005 GET oMemo VAR _cMensag MEMO SIZE 200,135 FONT oFont2 PIXEL OF oMensNF
	ACTIVATE MSDIALOG oMensNF CENTER
Endif
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Funcao Legenda														Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function LEGENDA()
_cLegenda := "Legenda dos produtos"

aCorLegen := { 	{ 'BR_VERDE'   ,"Identificado" },;
{ 'BR_VERMELHO',"Sem identificaГЦo" },;
{ 'BR_AZUL',"PreГo diferente em 10%" }}
BrwLegenda(_cLegenda,"Status do Produto",aCorLegen)
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Funcao Consulta SEFAZ												Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function SEFAZ(cOpc)

If cOpc==1 .OR. cOpc==3
	If cOpc==3
		cResp:=msgbox("Deseja Eliminar todas as NFE canceladas na SEFAZ?","AtenГЦo...","YESNO")
		If !cResp
			Return
		Endif
	Endif
	ConsNFeChave(LS3->CHAVE,cIdEnt,cOpc)
Else
	cChave:=lower(_cURL)+LS3->CHAVE
	ShellExecute("open",cChave,"","",0)
Endif
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza informacoes arquivo de configuracao						Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function ATUCFG()

_lAlmox:=LS1->ALMOX
_lSerie:=LS1->SERIE
_lEmail:=LS1->EMAIL
_lPedido:=LS1->PEDIDO
_lEspecie:=LS1->ESPECIE
_lDecQtd:=LS1->DECQTD
_lDecUni:=LS1->DECUNI

DEFINE MSDIALOG oAtuCfg TITLE "Informe os parametros..." From 9,0 To 30,50 OF oMainWnd
@002,004 TO 140,195
@005,006 Say "Almox.p/ saldos            (Branco-Local PadrЦo)" FONT oFont6 PIXEL COLOR CLR_HBLUE
@005,060 Get _lAlmox SIZE 20,10 Picture "@!"
@025,006 Say "Almox.p/ Pedidos           (Branco-Local PadrЦo) " FONT oFont6 PIXEL COLOR CLR_HBLUE
@025,060 Get _lPedido SIZE 20,10 Picture "@!"
@045,006 Say "SИria da Nota              (Branco-SИrie Fornec.) " FONT oFont6 PIXEL COLOR CLR_HBLUE
@045,060 Get _lSerie SIZE 20,10 Picture "@!"
@065,006 Say "Emails  " FONT oFont6 PIXEL COLOR CLR_HBLUE
@065,060 Get _lEmail SIZE 125,10 Picture "@"
@085,006 Say "EspИcie NF " FONT oFont6 PIXEL COLOR CLR_HBLUE
@085,060 Get _lEspecie SIZE 125,10 Picture "@"
@105,006 Say "Decimais Quantidade " FONT oFont6 PIXEL COLOR CLR_HBLUE
@105,070 Get _lDecQtd SIZE 30,10 Picture "99"
@125,006 Say "Decimais PreГo Unit." FONT oFont6 PIXEL COLOR CLR_HBLUE
@125,070 Get _lDecUni SIZE 30,10 Picture "99"
@145,006 BUTTON "Gravar" SIZE 40,10 ACTION 	oAtuCfg:end()
ACTIVATE MSDIALOG oAtuCfg CENTERED

If Empty(_lDecQtd) .or. _lDecQtd==0
	_lDecQtd:=2
Endif
If Empty(_lDecUni) .or. _lDecUni==0
	_lDecUni:=7
Endif

Reclock("LS1",.F.)
LS1->ALMOX:=_lAlmox
LS1->SERIE:=_lSerie
LS1->EMAIL:=_lEmail
LS1->PEDIDO:=_lPedido
LS1->ESPECIE:=_lEspecie
LS1->DECQTD:=_lDecQtd
LS1->DECUNI:=_lDecUni
MsUnlock()
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Geracao NDF fornecedor												Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function NDF()
RecLock("SE2",.T.)
SE2->E2_FILIAL  :=xFilial("SE2")
SE2->E2_PREFIXO :="XML"
SE2->E2_NUM     :=cNota
SE2->E2_PARCELA :=""
SE2->E2_TIPO	:="NDF"
SE2->E2_EMISSAO :=ddatabase
SE2->E2_NATUREZ :=POSICIONE("SA2",1,xFilial("SA2")+LS3->FORNEC+LS2->LOJA,"A2_NATUREZ")
SE2->E2_VENCREA :=ddatabase+30
SE2->E2_VENCTO  :=ddatabase+30
SE2->E2_VENCORI :=ddatabase+30
SE2->E2_MOEDA   :=1
SE2->E2_EMIS1   :=dDataBase
SE2->E2_FORNECE :=LS3->FORNEC
SE2->E2_LOJA    :=LS3->LOJA
SE2->E2_VALOR   :=_nExcedido
SE2->E2_SALDO   :=_nExcedido
SE2->E2_VLCRUZ  :=_nExcedido
If !lItem
	SE2->E2_NOMFOR :=POSICIONE("SA2",1,xFilial("SA2")+LS3->FORNEC+LS2->LOJA,"A2_NREDUZ")
Else
	SE2->E2_NOMFOR :=POSICIONE("SA2",1,xFilial("SA2")+LS3->FORNEC+LS3->LOJA,"A2_NREDUZ")
Endif
SE2->E2_ORIGEM  := "LERXML"
MsUnlock()
Return


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Valor NDF do fornecedor												Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function VALORNDF()

_nExcedido:=0
Dbselectarea("LS1")
DbSetorder(1)
Dbgotop()
While !Eof()
	cQuery:=" SELECT COUNT(*) QTD,AVG(C7_PRECO) PRECO,SUM(C7_QUANT-C7_QUJE-C7_QTDACLA) QUANT FROM SC7"+SM0->M0_CODIGO+"0 WHERE C7_FILIAL='"+xFilial("SC7")+"' "
	If !lItem
		cQuery:=cQuery + " AND C7_NUM='"+LS2->PEDIDO+"' "
	Else
		cQuery:=cQuery + " AND C7_NUM='"+LS1->PEDIDO+"' "
		cQuery:=cQuery + " AND C7_ITEM='"+LS1->ITEM+"' "
	Endif
	cQuery:=cQuery + " AND C7_PRODUTO='"+LS1->PRODUTO+"' "
	cQuery:=cQuery + " AND C7_RESIDUO<>'S' "
	cQuery:=cQuery + " AND C7_ENCER<>'E' "
	cQuery:=cQuery + " AND D_E_L_E_T_<>'*' "
	TCQUERY cQuery NEW ALIAS "TCQ"
	DbSelectarea("TCQ")
	While !Eof()
		If (round(LS1->PRECO,2)>TCQ->PRECO) .AND. Round(TCQ->PRECO,2)>0
			_nExcedido:=_nExcedido+(LS1->QUANTIDADE*(round(LS1->PRECO,2)-Round(TCQ->PRECO,2)))
		Endif
		DbSelectarea("TCQ")
		Dbskip()
	End
	DbClosearea("TCQ")
	Dbselectarea("LS1")
	Dbskip()
End
Return(_nExcedido)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Manipulando arquivo de configuracao									Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function CONFARQ()

Local _lPOP    := GetMV("MV_RELSERV")
Local _lConta  := GetMV("MV_RELACNT")
Local _lSenha  := GetMV("MV_RELPSW")
Local _lUM     := space(100)
Local _lLogo   := space(20)
Local _lPed    := "NЦo"
Local _lPRDBLQ := "NЦo"
Local _lZeros  := "NЦo"
Local _cURL    := space(500)
Local Lok      := .T.
Local _cNCM    := "NЦo"
 
Local cStartPath := GetSrvProfString("Rootpath","") + "\xml\"

If Empty(_lPOP)
	_lPOP   := space(100)
	_lConta := space(100)
	_lSenha := space(20)
Endif


cResp := msgbox("Deseja configurar os parametros da rotina?","AtenГЦo...","YESNO")

If cResp

	CriaPasta()

	cBuffer   := ""
	If File(cArqTxt)
		FT_FUSE(cArqTxt)
		FT_FGOTOP()
		ProcRegua(FT_FLASTREC())
		
		While !FT_FEOF()
			cBuffer := FT_FREADLN()
			If UPPER(SUBSTR(cBuffer,1,3))=="POP"
				_lPOP:=lower(ALLTRIM(SUBSTR(cBuffer,5,400)))+space(200)
			Endif
			If UPPER(SUBSTR(cBuffer,1,5)) == "CONTA"
				_lConta := lower(ALLTRIM(SUBSTR(cBuffer,7,400)))+space(200)
			Endif
			If UPPER(SUBSTR(cBuffer,1,5)) == "SENHA"
				_lSenha := lower(ALLTRIM(SUBSTR(cBuffer,7,400)))+space(200)
			Endif
			If UPPER(SUBSTR(cBuffer,1,2)) == "UM"
				_lUM := ALLTRIM(UPPER(SUBSTR(cBuffer,4,400)))+space(200)
			Endif
			If UPPER(SUBSTR(cBuffer,1,4)) == "LOGO"
				_lLogo := ALLTRIM(UPPER(SUBSTR(cBuffer,6,200)))+space(200)
			Endif
			If UPPER(SUBSTR(cBuffer,1,6)) == "PEDIDO"
				_lPed := "Sim"
			Endif
			If UPPER(SUBSTR(cBuffer,1,3)) == "NCM"
				_cNCM := "Sim"
			Endif			
			If UPPER(SUBSTR(cBuffer,1,3)) == "PRDBLQ"
				_lPRDBLQ := "Sim"
			Endif
			If UPPER(SUBSTR(cBuffer,1,11)) == "NFZEROS=SIM"
				_lZeros := "Sim"
			Endif
			If UPPER(SUBSTR(cBuffer,1,11)) == "NFZEROS=PER"
				_lZeros := "Perguntar"
			Endif
			If UPPER(SUBSTR(cBuffer,1,11)) == "PEDPROD=SIM"
				lCheck2 := .T.
			Endif
			If UPPER(SUBSTR(cBuffer,1,3)) == "URL"
				_cURL := ALLTRIM(UPPER(SUBSTR(cBuffer,5,500)))
			Endif
			FT_FSKIP()
		EndDo
		FT_FUSE()
	Endif
	
	aCampos	:= {{"EMPRESA","C",2,0 },;
	{"FILIAL","C",2,0 },;
	{"NOME","C",20,0 },;
	{"ALMOX","C",2,0 },;
	{"PEDIDO","C",2,0 },;
	{"SERIE","C",3,0 },;
	{"ESPECIE","C",5,0 },;
	{"DECQTD","N",2,0 },;
	{"DECUNI","N",2,0 },;
	{"EMAIL","C",300,0 }}
	
	cArqTrab  := CriaTrab(aCampos)
	dbUseArea( .T.,, cArqTrab, "LS1", if(.F. .OR. .F., !.F., NIL), .F. )
	IndRegua("LS1",cArqTrab,"EMPRESA+FILIAL",,,)
	dbSetIndex( cArqTrab +OrdBagExt())
	dbSelectArea("LS1")
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Empresas/Filiais - SIGAMAT											Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectarea("SM0")
	Dbsetorder(1)
	Dbgotop()
	While !Eof()
		
		_lSerie   := space(03)
		_lAlmox   := space(02)
		_lEmail   := space(300)
		_lPedido  := space(02)
		_lEspecie :="NF   "
		_lDecQtd  := 2
		_lDecUni  := 7
		
		If File(cArqTxt)
			FT_FUSE(cArqTxt)
			FT_FGOTOP()
			ProcRegua(FT_FLASTREC())
			
			While !FT_FEOF()
				cBuffer := FT_FREADLN()
				If UPPER(SUBSTR(cBuffer,1,4))==SM0->M0_CODIGO+SM0->M0_CODFIL
					_lSerie:=ALLTRIM(SUBSTR(cBuffer,6,3))
				Endif
				If UPPER(SUBSTR(cBuffer,1,5))=="S"+SM0->M0_CODIGO+SM0->M0_CODFIL
					_lAlmox:=ALLTRIM(SUBSTR(cBuffer,7,2))
				Endif
				If UPPER(SUBSTR(cBuffer,1,9))=="EMAIL"+SM0->M0_CODIGO+SM0->M0_CODFIL
					_lEmail:=ALLTRIM(SUBSTR(cBuffer,11,300))
				Endif
				If UPPER(SUBSTR(cBuffer,1,5))=="P"+SM0->M0_CODIGO+SM0->M0_CODFIL
					_lPedido:=ALLTRIM(SUBSTR(cBuffer,7,2))
				Endif
				If UPPER(SUBSTR(cBuffer,1,7))=="ESP"+SM0->M0_CODIGO+SM0->M0_CODFIL
					_lEspecie:=ALLTRIM(SUBSTR(cBuffer,9,5))
				Endif
				If UPPER(SUBSTR(cBuffer,1,10))=="DECQTD"+SM0->M0_CODIGO+SM0->M0_CODFIL
					_lDecQtd:=val(ALLTRIM(SUBSTR(cBuffer,12,5)))
				Endif
				If UPPER(SUBSTR(cBuffer,1,10))=="DECUNI"+SM0->M0_CODIGO+SM0->M0_CODFIL
					_lDecUni:=val(ALLTRIM(SUBSTR(cBuffer,12,5)))
				Endif
				FT_FSKIP()
			EndDo
			FT_FUSE()
		Endif
		
		Reclock("LS1",.T.)
		LS1->EMPRESA:=SM0->M0_CODIGO
		LS1->FILIAL:=SM0->M0_CODFIL
		LS1->NOME:=UPPER(SM0->M0_FILIAL)
		LS1->SERIE:=_lSerie
		LS1->ESPECIE:=_lEspecie
		LS1->ALMOX:=_lAlmox
		LS1->EMAIL:=_lEmail
		LS1->PEDIDO:=_lPedido
		LS1->DECQTD:=_lDecQtd
		LS1->DECUNI:=_lDecUni
		MsUnlock()
		DbSelectarea("SM0")
		Dbskip()
	End
	
	aTitulo := {}
	AADD(aTitulo,{"EMPRESA","Empresa"})
	AADD(aTitulo,{"FILIAL","Filial"})
	AADD(aTitulo,{"NOME","Nome"})
	AADD(aTitulo,{"ESPECIE","EspИcie"})
	AADD(aTitulo,{"SERIE","SИrie"})
	AADD(aTitulo,{"ALMOX","Saldos"})
	AADD(aTitulo,{"PEDIDO","Pedidos"})
	AADD(aTitulo,{"EMAIL","Emails para notas fiscais - Recusadas ( ; para separar )"})
	
	DbSelectarea("LS1")
	Dbgotop()
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Opcoes COMBOBOX														Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aPedidos:={}
	AADD(aPedidos,"Sim")
	AADD(aPedidos,"NЦo")

	_aNCM:={}
	AADD(_aNCM,"Sim")
	AADD(_aNCM,"NЦo")	
	
	aPRDBLQ:={}
	AADD(aPRDBLQ,"Sim")
	AADD(aPRDBLQ,"NЦo")
	
	aZeros:={}
	AADD(aZeros,"Sim")
	AADD(aZeros,"NЦo")
	AADD(aZeros,"Perguntar")
	
	If Empty(_cURL)
		_cURL:="http://www.nfe.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=completa&tipoConteudo=XbSeqxE8pl8="+space(100)
	Else
		_cURL:=_cURL+space(500-LEN(_cURL))
	Endif
	_cURL:=lower(_cURL)
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Apagando arquivo anterior										z	Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Ferase(cArqTxt)
	
	DEFINE MSDIALOG oConfig FROM 0,0 TO 525,400 PIXEL TITLE "ConfiguraГЦo do Importador XML"
	@ 005,005 say "Servidor POP " SIZE 150,40 FONT oFont6 OF oConfig PIXEL
	@ 015,005 get _lPOP size 190,20
	@ 030,005 say "Email do XML" SIZE 70,40 FONT oFont6 OF oConfig PIXEL
	@ 040,005 get _lConta size 130,20
	@ 055,005 say "Senha " SIZE 150,40 FONT oFont6 OF oConfig PIXEL
	@ 065,005 get _lSenha size 60,20 valid .t. PASSWORD

	@ 055,070 say "Logo (BMP)" SIZE 150,40 FONT oFont6 OF oConfig PIXEL
	@ 065,070 get _lLogo size 40,20 picture "@!"
	@ 055,135 say "Ped.Compras?" SIZE 150,40 FONT oFont6 OF oConfig PIXEL COLOR CLR_HRED
	@ 065,135 COMBOBOX _lPed ITEMS aPedidos SIZE 60,17
	@ 080,005 say "UM-UnitАrias - Ex.: UN/PC/LT" SIZE 150,40 FONT oFont6 OF oConfig PIXEL
	@ 090,005 get _lUM size 100,20 picture "@!"

	@ 100,005 say "Atualizar NCM?" SIZE 150,40 FONT oFont6 OF oConfig PIXEL COLOR CLR_HRED
	@ 110,005 COMBOBOX _cNCM ITEMS _aNCM SIZE 30,17
	@ 100,050 say "Exibe produtos bloqueados?" SIZE 150,40 FONT oFont6 OF oConfig PIXEL COLOR CLR_HRED
	@ 110,050 COMBOBOX _lPRDBLQ ITEMS aPRDBLQ SIZE 30,17

	@ 080,135 say "Nota (9 DМgitos)?" SIZE 150,40 FONT oFont6 OF oConfig PIXEL COLOR CLR_HRED
	@ 090,135 COMBOBOX _lZeros ITEMS aZeros SIZE 60,20
	@ 105,135 CHECKBOX "Pedido por Produto?" VAR lCheck2

	@ 130,005 say "Empresas/Filiais" SIZE 150,40 FONT oFont5 OF oConfig PIXEL COLOR CLR_HBLUE
	@ 140,005 TO 220,195 BROWSE "LS1" OBJECT OBRWP FIELDS aTitulo

	@ 225,005 say "URL Consulta NF-e SEFAZ" SIZE 150,40 FONT oFont6 OF oConfig PIXEL COLOR CLR_HRED
	@ 235,005 get _cURL size 190,25
	
	OBRWP:OBROWSE:bLDblClick   := {||ATUCFG()}
	OBRWP:oBrowse:oFont := TFont():New ("Courier New", 06, 16)
	@ 250,005 BUTTON "Salvar" SIZE 60,10 ACTION oConfig:end()
	ACTIVATE MSDIALOG oConfig CENTER
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Criando novo arquivo												Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cr      := ENTER
	_nDiv   := 0
	_cDados := {}
	
	AADD( _cDados,"POP="+ALLTRIM(_lPOP))
	AADD( _cDados,"CONTA="+ALLTRIM(_lConta))
	AADD( _cDados,"SENHA="+ALLTRIM(_lSenha))
	AADD( _cDados,"UM="+ALLTRIM(_lUM))
	AADD( _cDados,"LOGO="+ALLTRIM(_lLogo))
	If lCheck2
		AADD( _cDados,"PEDPROD=SIM")
	Endif
	
	DbSelectarea("LS1")
	Dbgotop()
	While !Eof()
		IF !Empty(LS1->SERIE)
			AADD( _cDados,LS1->EMPRESA+LS1->FILIAL+"="+LS1->SERIE)
		Endif
		If !Empty(LS1->ALMOX)
			AADD(_cDados,"S"+LS1->EMPRESA+LS1->FILIAL+"="+LS1->ALMOX)
		Endif
		If !Empty(LS1->EMAIL)
			AADD(_cDados,"EMAIL"+LS1->EMPRESA+LS1->FILIAL+"="+LS1->EMAIL)
		Endif
		If !Empty(LS1->PEDIDO)
			AADD(_cDados,"P"+LS1->EMPRESA+LS1->FILIAL+"="+LS1->PEDIDO)
		Endif
		If Empty(LS1->ESPECIE)
			AADD(_cDados,"ESP"+LS1->EMPRESA+LS1->FILIAL+"=NF")
		Else
			AADD(_cDados,"ESP"+LS1->EMPRESA+LS1->FILIAL+"="+LS1->ESPECIE)
		Endif
		If !Empty(LS1->DECUNI)
			AADD(_cDados,"DECUNI"+LS1->EMPRESA+LS1->FILIAL+"="+ALLTRIM(STR(LS1->DECUNI)))
		Else
			AADD(_cDados,"DECUNI"+LS1->EMPRESA+LS1->FILIAL+"=2")
		Endif
		If !Empty(LS1->DECQTD)
			AADD(_cDados,"DECQTD"+LS1->EMPRESA+LS1->FILIAL+"="+ALLTRIM(STR(LS1->DECQTD)))
		Else
			AADD(_cDados,"DECUNI"+LS1->EMPRESA+LS1->FILIAL+"=2")
		Endif
		Dbskip()
	End
	
	If ALLTRIM(_lPed)=="Sim"
		AADD( _cDados,"PEDIDO=SIM")
	Endif
	If ALLTRIM(_cNCM)=="Sim"
		AADD( _cDados,"NCM=SIM")
	Endif	
	If ALLTRIM(_lPRDBLQ)=="Sim"
		AADD( _cDados,"PRDBLQ=SIM")
	Endif
	If ALLTRIM(_lZeros)=="Sim"
		AADD( _cDados,"NFZEROS=SIM")
	Endif
	If ALLTRIM(_lZeros)=="Perguntar"
		AADD( _cDados,"NFZEROS=PER")
	Endif
	AADD( _cDados,"URL="+ALLTRIM(_cURL))
	
	hnda:=Fcreate(cArqTxt,0)
	for x := 1 TO LEN( _cDados )
		dados := _cDados[x]
		Fwrite(hnda,dados+cr)
	next
	Fclose(hnda)
	FClose(cArqTxt)
	Dbselectarea("LS1")
	dbCloseArea("LS1")
	fErase( cArqTrab+".DTC")
	fErase( cArqTrab+ OrdBagExt() )
	IF File(cArqTxt)
		Msgbox("ConfiguraГУes salvas com sucesso!","AtenГЦo...","INFO")
	Else
		Msgbox("NЦo conseguiu salvar as configuraГУes. Verifique o direitos da pasta no servidor.","AtenГЦo...","INFO")
		Lok := .F.
	Endif
Endif
Return (lOK)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Codigo de barra														Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function CODBAR()

cCodbar:=''

If !Empty(LS1->CODBAR)
	cCodbar:=ALLTRIM(cCodbar)+"CсDIGO BARRA DO XML"+ENTER
	cCodbar:=ALLTRIM(cCodbar)+ALLTRIM(LS1->CODBAR)+ENTER
	cCodbar:=ALLTRIM(cCodbar)+ENTER
Endif

If ALLTRIM(LS1->PRODUTO)<>"999999"
	DbSelectarea("SB1")
	DbSetorder(1)
	Dbgotop()
	Dbseek(xFilial("SB1")+LS1->PRODUTO,.t.)
	If Found()
		cCodbar:=ALLTRIM(cCodbar)+"CADASTRO DE PRODUTO"+ENTER
		cCodbar:=ALLTRIM(cCodbar)+ALLTRIM(SB1->B1_CODBAR)+ENTER
		cCodbar:=ALLTRIM(cCodbar)+ENTER
	Endif
	
	DbSelectarea("SLK")
	DbSetorder(2)
	Dbgotop()
	Dbseek(xFilial("SLK")+LS1->PRODUTO,.t.)
	If Found()
		cCodbar:=ALLTRIM(cCodbar)+"CADASTRO ALTERNATIVO"+ENTER
		DbSelectarea("SLK")
		DbSetorder(2)
		Dbgotop()
		Dbseek(xFilial("SLK")+LS1->PRODUTO,.t.)
		While !Eof() .and. ALLTRIM(SLK->LK_CODIGO)==ALLTRIM(LS1->PRODUTO)
			cCodbar:=ALLTRIM(cCodbar)+ALLTRIM(SLK->LK_CODBAR)+ENTER
			Dbskip()
		End
	Endif
Endif

If !Empty(cCodbar)
	Msgbox(cCodbar,"AtenГЦo...","INFO")
Endif
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Desbloquear															Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function DESBLOQ()

If UPPER(ALLTRIM(LS4->BLQ))=="ATIVO"
	Msgbox("O Produto jА estА ativo!","AtenГЦo...","ALERT")
	Return
Endif

cResp:=msgbox("Deseja DESBLOQUEAR o produto novamente?","AtenГЦo...","YESNO")

If cResp
	DbSelectarea("LS4")
	Reclock("LS4",.F.)
	LS4->BLQ:="Ativo"
	MsUnlock()
	
	Dbselectarea("SB1")
	DbSetorder(1)
	Dbgotop()
	Dbseek(xFilial("SB1")+LS4->PRODUTO)
	If Found()
		Reclock("SB1",.F.)
		SB1->B1_MSBLQL:="2"
		IF "SAIU" $ ALLTRIM(SB1->B1_DESC)
			SB1->B1_DESC:=SUBSTR(SB1->B1_DESC,6,45)
		Endif
		MsUnlock()
	End
	msgbox("O Produto foi reativado com sucesso!","AtenГЦo...","INFO")
Endif
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Historico do fornecedor												Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function HISTFOR()

cCadastro :='Historico Fornecedor'
aRotina   := {{"Pesquisar","AxPesqui",0,1},;
{"Comprar","U_PR_COM()",0,8}}

Pergunte("FIC030",.T.)
ALTERA:=.T.
INCLUI:=.F.
NVLGERALNF:=0
LF030TITAB:=.F.
LF030TITPG:=.F.
LF030TITCOM:=.F.
LF030TITFAT:=.F.
FC030CON(LS3->FORNEC,LS3->LOJA)
Return


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Procura pedido por item												Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function PROCPED()

If ALLTRIM(LS1->PRODUTO)=="999999"
	Msgbox("Favor identificar o produto primeiro!","AtenГЦo...","ALERT")
	OBRWI:obrowse:refresh()
	OBRWI:obrowse:setfocus()
	ObjectMethod(oTela,"Refresh()")
	Return
Endif

If !Empty(LS1->PEDIDO) .and. ALLTRIM(LS1->PEDIDO)<>"CRIAR"
	Msgbox("Favor eliminar o pedido primeiro!","AtenГЦo...","ALERT")
	OBRWI:obrowse:refresh()
	OBRWI:obrowse:setfocus()
	ObjectMethod(oTela,"Refresh()")
	Return
Endif

aCampos2	:= {{"OK","C",1,0 },;
{"EMISSAO","D",8,0 },;
{"PEDIDO","C",6,0 },;
{"ITEM","C",4,0 },;
{"QUANTIDADE","N",12,3 },;
{"PRECO","N",18,2 },;
{"ENTREGA","D",8,0 },;
{"OBS","C",40,0 }}

cArqTrab2  := CriaTrab(aCampos2)
cIndice:="Descend(DTOS(EMISSAO))"
dbUseArea( .T.,, cArqTrab2, "LS2", if(.F. .OR. .F., !.F., NIL), .F. )
IndRegua("LS2",cArqTrab2,cIndice,,,)
dbSetIndex( cArqTrab2 +OrdBagExt())
dbSelectArea("LS2")

lAchou:=.f.
_nQuantXml:=LS1->QUANTIDADE

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificando pedidos em aberto										Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSeq:=LS1->SEQ
cQuery:=" SELECT C7_EMISSAO EMISSAO,C7_PRECO PRECO,C7_ITEM ITEM,C7_NUM PEDIDO,(C7_QUANT-C7_QUJE-C7_QTDACLA) QUANTIDADE,C7_DATPRF ENTREGA,C7_OBS OBS FROM SC7"+SM0->M0_CODIGO+"0 WHERE C7_FILIAL='"+xFilial("SC7")+"' "
cQuery:=cQuery + " AND C7_FORNECE='"+LS3->FORNEC+"' "
cQuery:=cQuery + " AND C7_LOJA='"+LS3->LOJA+"' "
cQuery:=cQuery + " AND C7_PRODUTO='"+LS1->PRODUTO+"' "
cQuery:=cQuery + " AND (C7_QUANT-C7_QUJE-C7_QTDACLA>0) "
cQuery:=cQuery + " AND D_E_L_E_T_<>'*' "
cQuery:=cQuery + " AND C7_ENCER<>'E' "
cQuery:=cQuery + " AND C7_RESIDUO<>'S' "
cQuery:=cQuery + " ORDER BY C7_EMISSAO DESC "
TCQUERY cQuery NEW ALIAS "TCQ"
DbSelectarea("TCQ")
While !Eof()
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verificando saldos de produtos em uso								Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	_nUsados:=0
	DbSelectarea("LS1")
	Dbgotop()
	While !Eof()
		IF ALLTRIM(LS1->PEDIDO)==TCQ->PEDIDO .AND. ALLTRIM(LS1->ITEM)==TCQ->ITEM
			_nUsados:=(_nUsados+LS1->QUANTIDADE)
		Endif
		DbSelectarea("LS1")
		Dbskip()
	End
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Gravando pedidos em aberto											Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If (TCQ->QUANTIDADE-_nUsados)>0
		Reclock("LS2",.T.)
		IF (TCQ->QUANTIDADE-_nUsados)>=_nQuantXml
			LS2->OK:="X"
		Endif
		LS2->EMISSAO:=STOD(TCQ->EMISSAO)
		LS2->PEDIDO:=TCQ->PEDIDO
		LS2->ITEM:=TCQ->ITEM
		LS2->PRECO:=TCQ->PRECO
		LS2->QUANTIDADE:=(TCQ->QUANTIDADE-_nUsados)
		LS2->ENTREGA:=STOD(TCQ->ENTREGA)
		LS2->OBS:=TCQ->OBS
		Msunlock()
		lAchou:=.T.
	Endif
	DbSelectarea("TCQ")
	Dbskip()
End
DbClosearea("TCQ")

DbSelectarea("LS1")
Dbgotop()
DbSeek(cSeq)

Dbselectarea("LS2")
Dbgotop()

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё aHeader dos pedidos													Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aTitulo2 := {}
AADD(aTitulo2,{"EMISSAO","EmissЦo"})
AADD(aTitulo2,{"PEDIDO","Pedido"})
AADD(aTitulo2,{"ITEM","Item"})
AADD(aTitulo2,{"QUANTIDADE","DisponМvel","@E 999,999.999"})
AADD(aTitulo2,{"PRECO","PreГo R$","@E 999,999.99"})
AADD(aTitulo2,{"ENTREGA","Dt.Entrega"})
AADD(aTitulo2,{"OBS","ObservaГЦo"})

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tela dos itens														Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lAchou
	@ 120,040 TO 440,550 DIALOG oPedido TITLE "Pedidos em aberto para o produto..."
	@ 005,005 say "Quantidade NecessАria "+Transform(LS1->QUANTIDADE,"@E 99,999.99")+"      PreГo R$ "+Transform(LS1->PRECO,"@E 99,999.99") FONT oFont1 OF oPedido PIXEL COLOR CLR_HRED
	@ 015,005 TO 140,255 BROWSE "LS2" ENABLE " LS2->OK<>'X' " OBJECT OBRWT FIELDS aTitulo2
	OBRWT:oBrowse:oFont := TFont():New ("Arial", 05, 18)
	OBRWT:OBROWSE:bLDblClick   := {||CONFPED()}
	@ 145,005 BUTTON "Atualizar Pedido" SIZE 65,10 ACTION ATUPED()
	@ 145,075 BUTTON "Eliminar do pedido" SIZE 65,10 ACTION ELIRPRO()
	ACTIVATE DIALOG oPedido CENTER
Else
	Msgbox("NЦo existem pedidos em aberto para este produto!","AtenГЦo...","ALERT")
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Gravando CRIAR nos produtos sem pedidos de compras em aberto		Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	SEMPED()
Endif
Dbselectarea("LS2")
dbCloseArea("LS2")
fErase( cArqTrab2+".DTC")
fErase( cArqTrab2+ OrdBagExt() )

OBRWI:obrowse:refresh()
OBRWI:obrowse:setfocus()
ObjectMethod(oTela,"Refresh()")
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Confirma Pedido 													Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function CONFPED()

If (LS1->QUANTIDADE>LS2->QUANTIDADE)
	Msgbox("NЦo existe saldo suficiente para atender este produto!","AtenГЦo...","ALERT")
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Gravando CRIAR nos produtos sem pedidos de compras em aberto		Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	SEMPED()
	oPedido:end()
	Return
Endif

Reclock("LS1",.F.)
LS1->PEDIDO:=LS2->PEDIDO
LS1->ITEM:=LS2->ITEM
LS1->ALTERADO:="S"
MsUnlock()

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Gravando o mesmo pedido para os outros itens						Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSeqori:=LS1->SEQ

DbSelectarea("LS1")
Dbgotop()
While !Eof()
	cSeq:=LS1->SEQ
	IF Empty(LS1->PEDIDO)
		cQuery:=" SELECT C7_ITEM ITEM,(C7_QUANT-C7_QUJE-C7_QTDACLA) QUANT FROM SC7"+SM0->M0_CODIGO+"0 WHERE C7_FILIAL='"+xFilial("SC7")+"' "
		cQuery:=cQuery + " AND C7_NUM='"+LS2->PEDIDO+"' "
		cQuery:=cQuery + " AND C7_PRODUTO='"+LS1->PRODUTO+"' "
		cQuery:=cQuery + " AND (C7_QUANT-C7_QUJE-C7_QTDACLA>0) "
		cQuery:=cQuery + " AND D_E_L_E_T_<>'*' "
		cQuery:=cQuery + " AND C7_RESIDUO<>'S' "
		cQuery:=cQuery + " AND C7_ENCER<>'E' "
		cQuery:=cQuery + " ORDER BY C7_EMISSAO DESC "
		TCQUERY cQuery NEW ALIAS "TCQ"
		DbSelectarea("TCQ")
		While !Eof()
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verificando saldos de produtos em uso								Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			_nUsados:=0
			DbSelectarea("LS1")
			Dbgotop()
			While !Eof()
				IF ALLTRIM(LS1->PEDIDO)==ALLTRIM(LS2->PEDIDO) .AND. ALLTRIM(LS1->ITEM)==ALLTRIM(TCQ->ITEM)
					_nUsados:=(_nUsados+LS1->QUANTIDADE)
				Endif
				DbSelectarea("LS1")
				Dbskip()
			End
			
			DbSelectarea("LS1")
			Dbgotop()
			DbSeek(cSeq)
			
			IF (LS1->QUANTIDADE<=(TCQ->QUANT-_nUsados))
				Reclock("LS1",.F.)
				LS1->PEDIDO:=LS2->PEDIDO
				LS1->ITEM:=TCQ->ITEM
				LS1->ALTERADO:="S"
				MsUnlock()
			Endif
			DbSelectarea("TCQ")
			Dbskip()
		End
		DbClosearea("TCQ")
	Endif
	DbSelectarea("LS1")
	Dbskip()
End

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Gravando CRIAR nos produtos sem pedidos de compras em aberto		Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSelectarea("LS1")
Dbgotop()
DbSeek(cSeqOri)
SEMPED()
oPedido:end()
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Eliminar pedido														Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function ELIMPED()

Reclock("LS1",.F.)
LS1->PEDIDO:=""
LS1->ITEM:=""
LS1->ALTERADO:=""
MsUnlock()

OBRWI:obrowse:refresh()
OBRWI:obrowse:setfocus()
ObjectMethod(oTela,"Refresh()")
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Eliminar Todos														Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function ELIMPEDT()

cResp:=Msgbox("Deseja Limpar todas as referЙncias de pedidos dos produtos da nota fiscal?","AtenГЦo...","YESNO")

If cResp
	DbSelectarea("LS1")
	Dbgotop()
	While !Eof()
		IF !Empty(LS1->PEDIDO)
			Reclock("LS1",.F.)
			LS1->PEDIDO:=""
			LS1->ITEM:=""
			LS1->ALTERADO:=""
			MsUnlock()
		Endif
		Dbskip()
	End
	DbSelectarea("LS1")
	Dbgotop()
Endif

OBRWI:obrowse:refresh()
OBRWI:obrowse:setfocus()
ObjectMethod(oTela,"Refresh()")
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Eliminar pedido														Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function ELIRPRO()

cResp:=msgbox("Deseja eliminar o resМduo deste item do pedido "+LS2->PEDIDO+"?","AtenГЦo...","YESNO")

If cResp
	DbSelectarea("SC7")
	DbSetorder(1)
	dbgotop()
	Dbseek(xFilial("SC7")+LS2->PEDIDO)
	While !Eof() .and. ALLTRIM(SC7->C7_NUM)==ALLTRIM(LS2->PEDIDO)
		IF ALLTRIM(SC7->C7_PRODUTO)==ALLTRIM(LS1->PRODUTO) .AND. LS2->ITEM==SC7->C7_ITEM
			IF SC7->C7_QTDACLA>0
				Msgbox("Este produto estА sendo usado em prИ nota fiscal!","AtenГЦo...","ALERT")
				Return
			Endif
			
			IF SC7->C7_RESIDUO<>"S" .and. (SC7->C7_QUANT-SC7->C7_QUJE)>0
				Reclock("SC7",.F.)
				SC7->C7_RESIDUO:="S"
				MsUnlock()
				
				DbSelectarea("SB2")
				DbSetorder(2)
				Dbgotop()
				Dbseek(xFilial("SB2")+SC7->C7_LOCAL+SC7->C7_PRODUTO)
				If Found()
					Reclock("SB2",.F.)
					SB2->B2_SALPEDI:=(SB2->B2_SALPEDI-(SC7->C7_QUANT-SC7->C7_QUJE))
					MsUnlock()
				Endif
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Apagando pedido do browse											Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				DbSelectarea("LS2")
				Reclock("LS2",.F.)
				dbdelete()
				MsUnlock()
				dbgotop()
				Msgbox("ResМduo eliminado com sucesso!","AtenГЦo...","INFO")
			Endif
		Endif
		DbSelectarea("SC7")
		Dbskip()
	End
Endif
Return

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//| Alterar Pedido												 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function ATUPED()

IF LS1->QUANTIDADE<=LS2->QUANTIDADE
	Msgbox("NЦo И necessАrio atualizar este pedido!","AtenГЦo...","ALERT")
	Return
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ajustando o pedido com a nota										Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cResp:=msgbox("Deseja atualizar o pedido "+LS2->PEDIDO+" com a quantidade que falta?","AtenГЦo...","YESNO")

If cResp
	lEntrou:=.F.
	_nQtdIt:=0
	
	DbSelectarea("SC7")
	DbSetorder(4)
	Dbgotop()
	Dbseek(xFilial("SC7")+LS1->PRODUTO+LS2->PEDIDO+LS2->ITEM)
	If Found() .AND. (SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA)<LS1->QUANTIDADE
		_nTotal:=LS1->QUANTIDADE-(SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA)
		
		Reclock("SC7",.F.)
		SC7->C7_QUANT:=(SC7->C7_QUANT+_nTotal)
		SC7->C7_OBS:="ALTERADO NF-ELETRONICA"
		MsUnlock()
		
		Reclock("SC7",.F.)
		SC7->C7_TOTAL:=(SC7->C7_QUANT*SC7->C7_PRECO)
		MsUnlock()
		
		If Empty(cAlmox)
			cAlmox:=Posicione("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_LOCPAD")
		Endif
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Atualizado SB2 saldo de pedidos										Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		DbSelectarea("SB2")
		DbSetorder(2)
		Dbgotop()
		Dbseek(xFilial("SB2")+cAlmox+LS1->PRODUTO)
		If Found()
			Reclock("SB2",.F.)
			SB2->B2_SALPEDI:=(SB2->B2_SALPEDI+_nTotal)
			MsUnlock()
		Endif
		lEntrou:=.T.
	Endif
	
	If lEntrou
		Msgbox("Pedido atualizado com sucesso!","AtenГЦo...","INFO")
		Reclock("LS2",.F.)
		LS2->QUANTIDADE:=LS1->QUANTIDADE
		LS2->OK:="X"
		Msunlock()
	Endif
Endif
DbSelectarea("LS2")
Return

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//| Verificando produto sem pedido de compras da nota			 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function SEMPED()

cSeqori:=LS1->SEQ

DbSelectarea("LS1")
Dbgotop()
While !Eof()
	cSeq:=LS1->SEQ
	
	IF (Empty(LS1->PEDIDO) .AND. ALLTRIM(LS1->PRODUTO)<>"999999")
		lEntrou:=.F.
		cQuery:=" SELECT C7_NUM PEDIDO,C7_ITEM ITEM,(C7_QUANT-C7_QUJE-C7_QTDACLA) QUANT FROM SC7"+SM0->M0_CODIGO+"0 WHERE C7_FILIAL='"+xFilial("SC7")+"' "
		cQuery:=cQuery + " AND C7_FORNECE='"+LS3->FORNEC+"' "
		cQuery:=cQuery + " AND C7_LOJA='"+LS3->LOJA+"' "
		cQuery:=cQuery + " AND C7_PRODUTO='"+LS1->PRODUTO+"' "
		cQuery:=cQuery + " AND C7_ENCER<>'E' "
		cQuery:=cQuery + " AND (C7_QUANT-C7_QUJE-C7_QTDACLA>0) "
		cQuery:=cQuery + " AND D_E_L_E_T_<>'*' "
		cQuery:=cQuery + " AND C7_RESIDUO<>'S' "
		cQuery:=cQuery + " ORDER BY C7_EMISSAO DESC "
		TCQUERY cQuery NEW ALIAS "TCQ"
		DbSelectarea("TCQ")
		While !Eof() .and. lEntrou==.F.
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verificando saldos de produtos em uso								Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			_nUsados:=0
			DbSelectarea("LS1")
			Dbgotop()
			While !Eof()
				IF ALLTRIM(LS1->PEDIDO)==ALLTRIM(TCQ->PEDIDO) .AND. ALLTRIM(LS1->ITEM)==TCQ->ITEM
					_nUsados:=(_nUsados+LS1->QUANTIDADE)
				Endif
				DbSelectarea("LS1")
				Dbskip()
			End
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Se o saldo do pedido atende ao produto da nota fiscal				Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			DbSelectarea("LS1")
			Dbgotop()
			DbSeek(cSeq)
			
			IF (LS1->QUANTIDADE<=(TCQ->QUANT-_nUsados)) .OR. (TCQ->QUANT-_nUsados)>0
				lEntrou:=.T.
			Endif
			DbSelectarea("TCQ")
			Dbskip()
		End
		DbClosearea("TCQ")
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Se nao encontrou nenhum pedido de compra com saldo suficiente		Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lEntrou==.F.
			DbSelectarea("LS1")
			Reclock("LS1",.F.)
			LS1->PEDIDO:="CRIAR"
			LS1->ALTERADO:="S"
			MsUnlock()
		Endif
	Endif
	DbSelectarea("LS1")
	Dbskip()
End
DbSelectarea("LS1")
Dbgotop()
DbSeek(cSeqori)
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Consulta dados do produto											Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function VIEWPROD()

If !AtIsRotina("MACOMVIEW")
	aRotina   := {{"Pesquisar","AxPesqui",0,1},;
	{"Comprar","U_PR_COM()",0,8}}
	
	MACOMVIEW(LS1->PRODUTO)
EndIf
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Refaz desconto														Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function REFDESC()

DbSelectarea("LS1")
Dbgotop()
While !Eof()
	If LS1->DESCONTO>0
		If lRefaz
			Reclock("LS1",.F.)
			LS1->PRECO:=(LS1->TOTALNF-LS1->DESCONTO)/LS1->QUANTIDADE
			LS1->TOTAL:=(LS1->TOTALNF-LS1->DESCONTO)
			MsUnlock()
		Else
			Reclock("LS1",.F.)
			LS1->PRECO:=(LS1->TOTALNF/LS1->QUANTIDADE)
			LS1->TOTAL:=LS1->TOTALNF
			MsUnlock()
		Endif
	Endif
	Dbskip()
End

If lRefaz
	lRefaz:=.F.
	Msgbox("O Total do produto estА com o desconto!","AtenГЦo...","INFO")
Else
	lRefaz:=.T.
	Msgbox("O Total do produto estА sem o desconto!","AtenГЦo...","ALERT")
Endif
DbSelectarea("LS1")
Dbgotop()
OBRWI:obrowse:refresh()
OBRWI:obrowse:setfocus()
ObjectMethod(oTela,"Refresh()")
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Validas perguntas usadas no filtro dos registros					Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function VALIDPERG(cPerg)
aRegs := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,7)+"   "

aAdd(aRegs,{cPerg,"01","Fornecedor ?","","","mv_ch1","C",6,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SA2",""})
aAdd(aRegs,{cPerg,"02","Loja ?","","","mv_ch2","C",2,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Emissao de ??","","","mv_ch3","D",8,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Emissao Ate?","","","mv_ch4","D",8,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","N.Fiscal de?","","","mv_ch5","C",9,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","N.Fiscal Ate?","","","mv_ch6","C",9,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Cliente ?","","","mv_ch7","C",6,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","SA1",""})
aAdd(aRegs,{cPerg,"08","Loja ?","","","mv_ch8","C",2,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","",""})


For i:=1 to LEN(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= LEN(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next
Return

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVisualiza Pedido de compra									Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function F030PCVis(xFilial,cNumPC)

Local aArea			:= GetArea()
Local aAreaSC7		:= SC7->(GetArea())
Local nSavNF		:= MaFisSave()
Local cSavCadastro	:= cCadastro
PRIVATE nTipoPed	:= 1
PRIVATE cCadastro	:= "Consulta ao Pedido de Compra"
PRIVATE l120Auto	:= .F.
PRIVATE aBackSC7	:= {}

cFilAtual:=xFilial("SD1")
cFilAnt:=xFilial

SaveInter()

If !Empty(cNumPC)
	MaFisEnd()
	dbSelectArea("SC7")
	dbSetOrder(1)
	dbSeek(xFilial+cNumPC)
	A120Pedido(Alias(),RecNo(),2)
EndIf

cFilAnt:=cFilAtual
RestInter()
cCadastro	:= cSavCadastro
MaFisRestore(nSavNF)
RestArea(aAreaSC7)
RestArea(aArea)
Return .T.

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Consulta Status na Sefaz									Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function ConsNFeChave(cChaveNFe,cIdEnt,cOpc)

Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cMensagem:= ""
Local lErro := .F.
Local oWs

lWeb := .F.

oWs:= WsNFeSBra():New()
oWs:cUserToken := "TOTVS"
oWs:cID_ENT    := cIdEnt
ows:cCHVNFE	   := cChaveNFe
oWs:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"

If cOpc==1 //Pesquisa por NFe
	If oWs:ConsultaChaveNFE()
		cMensagem := ""
		If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cVERSAO)
			cMensagem += "VersЦo da Mensagem"+": "+oWs:oWSCONSULTACHAVENFERESULT:cVERSAO+CRLF
		EndIf
		cMensagem += "Ambiente"+": "+IIf(oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1,"ProduГЦo","HomologaГЦo")+CRLF
		cMensagem += "Cod.Ret.NFe"+": "+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF
		cMensagem += "Msg.Ret.NFe"+": "+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF
		If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
			cMensagem += "Protocolo"+": "+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF
		EndIf
		If oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE # "100"
			lErro := .T.
		EndIf
		
		If !lWeb
			Aviso("Consulta da Nota Fiscal",cMensagem,{"Ok"},3)
			
			If lErro
				cResp:=Msgbox("Deseja Eliminar a NFE do browser?","AtenГЦo...","YESNO")
				
				If cResp
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Dados do fornecedor													Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					DbSelectarea("SA2")
					DbSetorder(1)
					Dbgotop()
					Dbseek(xFilial("SA2")+LS3->FORNEC+LS3->LOJA)
					
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Nomeclatura dos arquivos											Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					_cFileOri:="\xml\"+ALLTRIM(LS3->XML)
					_cFileNew:="\xml\"+ALLTRIM(SA2->A2_CGC)+"-nf"+ALLTRIM(LS3->NOTA)+"-"+ALLTRIM(LS3->CHAVE)+".xml.canc"
					
					FRename(_cFileOri,_cFileNew)
					__CopyFile("\xml\*.canc","\xml\cancelado\")
					ferase(_cFileNew)
					
					Reclock("LS3",.F.)
					dbdelete()
					MsUnlock()
					
					DbSelectarea("LS3")
					Dbgotop()
					
					DbSelectarea("LS1")
					Dbsetorder(1)
					Dbgotop()
					While !Eof()
						Reclock("LS1",.F.)
						dbdelete()
						MsUnlock()
						Dbskip()
					End
					DbSelectarea("LS5")
					Dbsetorder(1)
					Dbgotop()
					While !Eof()
						Reclock("LS5",.F.)
						dbdelete()
						MsUnlock()
						Dbskip()
					End
					PROCESS()
				Endif
			Endif
		Endif
	Endif
Else //Eliminar Todas Canceladas
	DbSelectarea("LS3")
	Dbgotop()
	While !Eof()
		oWs:= WsNFeSBra():New()
		oWs:cUserToken := "TOTVS"
		oWs:cID_ENT    := cIdEnt
		ows:cCHVNFE	   := ALLTRIM(LS3->CHAVE)
		oWs:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
		
		If oWs:ConsultaChaveNFE()
			If oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE # "100"
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Dados do fornecedor													Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				DbSelectarea("SA2")
				DbSetorder(1)
				Dbgotop()
				Dbseek(xFilial("SA2")+LS3->FORNEC+LS3->LOJA)
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Nomeclatura dos arquivos											Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				_cFileOri:="\xml\"+ALLTRIM(LS3->XML)
				_cFileNew:="\xml\"+ALLTRIM(SA2->A2_CGC)+"-nf"+ALLTRIM(LS3->NOTA)+"-"+ALLTRIM(LS3->CHAVE)+".xml.canc"
				
				FRename(_cFileOri,_cFileNew)
				__CopyFile("\xml\*.canc","\xml\cancelado\")
				ferase(_cFileNew)
				
				Reclock("LS3",.F.)
				dbdelete()
				MsUnlock()
				
				DbSelectarea("LS1")
				Dbsetorder(1)
				Dbgotop()
				While !Eof()
					Reclock("LS1",.F.)
					dbdelete()
					MsUnlock()
					Dbskip()
				End
				DbSelectarea("LS5")
				Dbsetorder(1)
				Dbgotop()
				While !Eof()
					Reclock("LS5",.F.)
					dbdelete()
					MsUnlock()
					Dbskip()
				End
			EndIf
		Endif
		DbSelectarea("LS3")
		Dbskip()
	End
	DbSelectarea("LS3")
	Dbgotop()
	PROCESS()
Endif
Return

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁEntidade																   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
User Function IDENTCLI()

Local aArea  := GetArea()
Local cIdEnt := ""
Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWs
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁObtem o codigo da entidade                                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oWS := WsSPEDAdm():New()
oWS:cUSERTOKEN := "TOTVS"

oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM
oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
oWS:oWSEMPRESA:cCEP_CP     := Nil
oWS:oWSEMPRESA:cCP         := Nil
oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
oWS:oWSEMPRESA:cINDSITESP  := ""
oWS:oWSEMPRESA:cID_MATRIZ  := ""
oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
If oWs:ADMEMPRESAS()
	cIdEnt  := oWs:cADMEMPRESASRESULT
Else
	Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
EndIf
RestArea(aArea)
Return(cIdEnt)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁRecuperar XML														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function RECUPXML()

_cFornec:=Space(06)
_cLoja:="01"
_cNota:=Space(09)

@ 070,070 TO 235,200 dialog oRecXml title "Parametros..."
@ 005,005 SAY "Fornecedor"
@ 015,005 Get _cFornec Picture "@!" size 40,40 VALID .T. F3 "SA2"
@ 025,005 SAY "Loja"
@ 035,005 Get _cLoja Picture "@!"
@ 045,005 SAY "Nota Fiscal"
@ 055,005 Get _cNota Picture "@!"
@ 070,005 BUTTON "Pesquisar" SIZE 40,10 ACTION oRecXml:end()
Activate Dialog oRecXml CENTERED

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁProcessando XML														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !Empty(_cFornec) .OR. !Empty(_cNota)
	
	aCamposX	:= {{"ARQ","C",200,0 }}
	
	cArqXML  := CriaTrab(aCamposX)
	dbUseArea( .T.,, cArqXML, "XML", if(.F. .OR. .F., !.F., NIL), .F. )
	IndRegua("XML",cArqXML,"ARQ",,,)
	dbSetIndex( cArqXML +OrdBagExt())
	dbSelectArea("XML")
	
	aXML:={}
	ADir("\xml\importado\*.*",aXML)
	
	DbSelectarea("SA2")
	DbSetorder(1)
	Dbgotop()
	Dbseek(xFilial("SA2")+_cFornec+_cLoja)
	
	For i:=1 to LEN(aXML)
		If !Empty(_cFornec) .AND. !Empty(_cNota)
			If ALLTRIM(SA2->A2_CGC) $ UPPER(ALLTRIM(aXML[i])) .AND. ALLTRIM(_cNota) $ UPPER(ALLTRIM(aXML[i]))
				Reclock("XML",.T.)
				XML->ARQ:=Lower(ALLTRIM(aXML[i]))
				MsUnlock()
			Endif
		Endif
		If Empty(_cFornec) .AND. !Empty(_cNota)
			If ALLTRIM(_cNota) $ UPPER(ALLTRIM(aXML[i]))
				Reclock("XML",.T.)
				XML->ARQ:=Lower(ALLTRIM(aXML[i]))
				MsUnlock()
			Endif
		Endif
		If !Empty(_cFornec) .AND. Empty(_cNota)
			If ALLTRIM(SA2->A2_CGC) $ UPPER(ALLTRIM(aXML[i]))
				Reclock("XML",.T.)
				XML->ARQ:=Lower(ALLTRIM(aXML[i]))
				MsUnlock()
			Endif
		Endif
	Next
	
	aXMLTit := {}
	AADD(aXMLTit,{"ARQ","Arquivo XML"})
	
	DbSelectarea("XML")
	Dbgotop()
	
	@ 120,040 TO 440,550 DIALOG oPedido TITLE "XMLs Encontrados..."
	@ 005,005 TO 140,255 BROWSE "XML" OBJECT OBRWT FIELDS aXMLTit
	OBRWT:oBrowse:oFont := TFont():New ("Arial", 05, 18)
	@ 145,005 BUTTON "Recuperar" SIZE 65,10 ACTION RECUP()
	ACTIVATE DIALOG oPedido CENTER
	
	Dbselectarea("XML")
	dbCloseArea("XML")
	fErase( cArqXML+".DTC")
	fErase( cArqXML+ OrdBagExt() )
Else
	Msgbox("Parametros invАlidos!")
Endif
Return

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁRecuperando XML														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function RECUP()

_cArqRec:=SUBSTR(lower(ALLTRIM(XML->ARQ)),1,LEN(lower(ALLTRIM(XML->ARQ)))-4)
__CopyFile("\xml\importado\"+lower(ALLTRIM(XML->ARQ)),"\xml\"+_cArqRec)

Msgbox("XML recuperado com sucesso!","Atencao...","INFO")
Msgbox("Favor Realizar a ExclusЦo da PrИ-Nota!","Atencao...","ALERT")
Msgbox("Feche o programa e abra novamente!","Atencao...","ALERT")
oPedido:End()
Return

/*
Static Function Sobre
Local lOk	  := .F.

DEFINE MSDIALOG oDlg TITLE "InformaГУes sobre o Produto" FROM 0,0 TO 520,640 OF oDlg PIXEL

@  06,010 SAY "ImportaГЦo de XML"  SIZE  100, 8 PIXEL OF oFld:aDialogs[1]

//Botoes
@ 213,265 BUTTON "&Ok"       SIZE 46,16 PIXEL ACTION (lOk := .T., oDlg:End())

ACTIVATE MSDIALOG oDlg CENTER 

Return(lOk)
*/

Static Function CriaPasta
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё RootPath															Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cStartPath := GetSrvProfString("Rootpath","") + "\xml\"
cStartPath := "\xml"

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Criando Diretorios													Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
IF ! File(cStartPath)
	MakeDir(Trim(cStartPath))
Endif
IF !File(cStartPath + "\config")
	MakeDir(Trim(cStartPath) + "\config")
Endif
IF !File(cStartPath + "\importado")
	MakeDir(Trim(cStartPath) + "\importado")
Endif
IF !File(cStartPath + "\duplicado")
	MakeDir(Trim(cStartPath) + "\duplicado")
Endif
IF !File(cStartPath + "\cancelado")
	MakeDir(Trim(cStartPath) + "\cancelado")
Endif
IF !File(cStartPath + "\recusado")
	MakeDir(Trim(cStartPath) + "\recusado")
Endif
IF !File(cStartPath + "\corrompido")
	MakeDir(Trim(cStartPath) + "\corrompido")
Endif
Return(cStartPath)


/*/{Protheus.doc} ALLA01P
//TODO DescriГЦo auto-gerada.
@author Administrador
@since 16/05/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ALLA01P(_cPRODUTO, _cNFREF)
Local _aArea  := GetArea()
Local _cSERIE := cValToChar(VAL(SUBSTR(_CNFREF,23,3)))
Local _cNF    := SUBSTR(_CNFREF,26,9)
Local _aRET   := {}

BeginSQL alias "ORIGEM"
	SELECT D2_DOC,D2_SERIE,D2_ITEM
	FROM %table:SD2% SD2
	WHERE
		SD2.D2_FILIAL =  %xFilial:SD2%
		AND SD2.D2_DOC = %Exp:_cNF%
		AND SD2.D2_SERIE = %Exp:_cSERIE%
		AND SD2.D2_COD = %Exp:_cPRODUTO%
		AND SD2.%NotDel%
EndSQL
IF ORIGEM->(!EOF())
	aADD(_aRET,{ORIGEM->D2_DOC,ORIGEM->D2_SERIE,ORIGEM->D2_ITEM})
END
ORIGEM->(dbCloseArea())

RestArea(_aArea)
Return(_aRET)

/*/{Protheus.doc} Tmata650
//TODO Gera ordem de producao se o produto for do tipo servico e nota fiscal de devolucao.
@author Fernando Bombardi
@since 23/05/2019
@version 1.0

@type function
/*/
Static Function ALLA01O(_cPROD,_nQTDE)
Local _lRet := .T.
Local aMATA650 := {} //-Array com os campos
LOCAL DDATABASE := dDataBase

//здддддддддддддддддд©
//Ё 3 - Inclusao Ё
//Ё 4 - Alteracao Ё
//Ё 5 - Exclusao Ё
//юдддддддддддддддддды
Local nOpc := 3
Private lMsErroAuto := .F.

//_cPROD := SUBSTR(_cPROD,3,TAMSX3("B1_COD")[1])
 
aMATA650 := { {'C2_FILIAL' ,XFILIAL("SC2") ,NIL},;
	{'C2_PRODUTO' ,_cPROD                                                        ,NIL},;
	{'C2_LOCAL'   ,POSICIONE("SB1",1,XFILIAL("SB1")+ALLTRIM(_cPROD),"B1_LOCPAD") ,NIL},;
	{'C2_QUANT'   ,_nQTDE                                                        ,NIL},;
	{'C2_DATPRI'  ,DDATABASE                                                     ,NIL},;
	{'C2_DATPRF'  ,DDATABASE+1                                                   ,NIL},;
	{'AUTEXPLODE' ,"S"                                                           ,NIL}}

_cOP := "" 
msExecAuto({|x,Y| Mata650(x,Y)},aMata650,nOpc)
IF lMsErroAuto
	MostraErro()
	_lRet := .F.
ELSE
	_cOP :=  SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
ENDIF
 
Return(_cOP)

/*/{Protheus.doc} ALLA01T
//TODO Verifica o tipo da nota fical de origem.
@author Fernando Bombardi
@since 27/05/2019
@version 1.0

@type function
/*/
Static Function ALLA01T(_cNFREF)
Local _aArea  := GetArea()
Local _cSERIE := cValToChar(VAL(SUBSTR(_CNFREF,23,3)))
Local _cNF    := SUBSTR(_CNFREF,26,9)
Local _cRET   := ""

BeginSQL alias "ORIGEM"
	SELECT F2_TIPO
	FROM %table:SF2% SF2
	WHERE
		SF2.F2_FILIAL =  %xFilial:SF2%
		AND SF2.F2_DOC = %Exp:_cNF%
		AND SF2.F2_SERIE = %Exp:_cSERIE%
		AND SF2.%NotDel%
EndSQL
IF ORIGEM->(!EOF())
	_cRET := ORIGEM->F2_TIPO
END
ORIGEM->(dbCloseArea())

RestArea(_aArea)
Return(_cRET)