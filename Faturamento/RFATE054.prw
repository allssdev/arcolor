#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RFATE054 บAutor  ณAdriano L. de Souza บ Data ณ  01/08/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsแvel por inserir um produto/grupo em m๚lti-  บฑฑ
ฑฑบ          ณ plas regras de neg๓cios simultaneamente.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico empresa ARCOLOR                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function RFATE054()

Local btnCancel
Local btnOk
Local lblCodProd
Local lblDesc
Local lblGrupo
Local oGet1
Local oGet2
Local oGet3
Local oGet4
Local oGetDesc1
Local oGetDesc2
Local oGetDesc3
Local oGetDesc4
Local oGetQtdIni
Local oGetQtdFim
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Local oRadMenu1
Local txtCodProd
Private _nRadMenu1	:= 1       
Private _cRotina	:= "RFATE054"
Private _cCodProd	:= Space(TamSX3("B1_COD")[01])
Private _cGrpProd	:= Space(TamSX3("B1_GRUPO")[01])
Private _cDescri	:= Space(TamSX3("B1_DESC" )[01])
Private _nDescSug	:= 0
Private _nDesc1		:= 0
Private _nDesc2		:= 0
Private _nDesc3		:= 0
Private _nDesc4		:= 0
Private _nVolSug	:= 0
Private _nVolIni	:= 0
Private _nVolFim	:= 0
Private aHeader 	:= {}
Private aCols 		:= {}
Private _aSize		:= MsAdvSize() //Retorna o tamanho da tela em pixels, utilizado para cแlculo das posi็๕es dos objetos
Private _nTamMark	:= 2
Private _cTabTmp	:= ""
Private _aSavArea	:= GetArea()
Private _aSavSX3	:= SX3->(GetArea())
Private _aSavACN	:= ACN->(GetArea())
Private _cEnter		:= CHR(13) + CHR(10)
Private _nBkpVolI	:= 0
Private _nBkpVolF	:= 0
Private _cBkpProd	:= Space(TamSX3("B1_COD")[01])
Private _cBkpGrup	:= Space(TamSX3("B1_DESC" )[01])
Private _lForca		:= .T.

/*-------------------------------------
      Posi็๕es do array _ASIZE
---------------------------------------
[1] Linha inicial แrea trabalho
[2] Coluna inicial แrea trabalho
[3] Linha final แrea trabalho
[4] Coluna final แrea trabalho
[5] Coluna final dialog (janela)
[6] Linha final dialog (janela)
[7] Linha inicial dialog (janela)
-------------------------------------*/

Private _nMargem	:= 3
Private _nTamBut	:= 47
Private _nAltBut	:= 12
Static oDlg

  DEFINE MSDIALOG oDlg TITLE "Inclusใo M๚ltiplas Regras" FROM _aSize[1], _aSize[1]  TO _aSize[6], _aSize[5] COLORS 0, 16777215 PIXEL
  
  	//Crio array com as coordenadas dos objetos na tela
  	_aPosObj := {}
  	
	AAdd(_aPosObj,{_aSize[1]+015		,	_aSize[1]+_nMargem+10								,048		,007		}) //Label	 - C๓digo do produto
	AAdd(_aPosObj,{_aSize[1]+014		,	_aSize[1]+052+10									,100		,010		}) //TextBox - C๓digo do produto
	AAdd(_aPosObj,{(_aSize[6]*0.5)-015	,	(_aSize[5]*0.5)-((_nMargem+_nTamBut)*2)				,_nTamBut	,_nAltBut	}) //Botใo   - Confirmar
	AAdd(_aPosObj,{(_aSize[6]*0.5)-015	,	(_aSize[5]*0.5)-_nMargem-_nTamBut					,_nTamBut	,_nAltBut	}) //Botใo   - Cancelar
	AAdd(_aPosObj,{_aSize[1]+015		,	_aSize[1]+171+10									,017		,007		}) //Label   - Grupo de produtos
	AAdd(_aPosObj,{_aSize[1]+014		,	_aSize[1]+189+10									,100		,010		}) //TextBox - Grupo de produtos
	AAdd(_aPosObj,{_aSize[1]+030		,	_aSize[1]+023+10									,025		,007		}) //Label   - Descri็ใo
	AAdd(_aPosObj,{_aSize[1]+029		,	_aSize[1]+052+10									,284		,010		}) //TextBox - Descri็ใo
	AAdd(_aPosObj,{_aSize[1]+059		,	_aSize[1]+052+10									,060		,010		}) //TextBox - Limite (Volume)
	AAdd(_aPosObj,{_aSize[1]+059		,	_aSize[1]+179+10									,060		,010		}) //TextBox - Desconto
	AAdd(_aPosObj,{_aSize[1]+060		,	_aSize[1]+011+10									,053		,014		}) //Label   - Limite (Volume)
	AAdd(_aPosObj,{_aSize[1]+060		,	_aSize[1]+140+10									,063		,014		}) //Label   - Desconto	
	AAdd(_aPosObj,{_aSize[1]+044		,	_aSize[1]+052+10									,060		,010		}) //TextBox - Desconto 1
	AAdd(_aPosObj,{_aSize[1]+044		,	_aSize[1]+179+10									,060		,010		}) //TextBox - Desconto 2
	AAdd(_aPosObj,{_aSize[1]+044		,	_aSize[1]+316+10									,060		,010		}) //TextBox - Desconto 3
	AAdd(_aPosObj,{_aSize[1]+044		,	_aSize[1]+453+10									,060		,010		}) //TextBox - Desconto 4
 	
	AAdd(_aPosObj,{_aSize[1]+045		,	_aSize[1]+020+10									,060		,010		}) //Label - Desconto 1
	AAdd(_aPosObj,{_aSize[1]+045		,	_aSize[1]+147+10									,060		,010		}) //Label - Desconto 2
	AAdd(_aPosObj,{_aSize[1]+045		,	_aSize[1]+284+10									,060		,010		}) //Label - Desconto 3
	AAdd(_aPosObj,{_aSize[1]+045		,	_aSize[1]+421+10									,060		,010		}) //Label - Desconto 4

	AAdd(_aPosObj,{_aSize[1]+014		,	_aSize[1]+316+50									,060		,010		})
	AAdd(_aPosObj,{_aSize[1]+014		,	_aSize[1]+453+10									,060		,010		})
	
	AAdd(_aPosObj,{_aSize[1]+015		,	_aSize[1]+284+50									,060		,010		}) //Label - De volume
	AAdd(_aPosObj,{_aSize[1]+015		,	_aSize[1]+421+10									,060		,010		}) //Label - At้ volume
			
	@ _aPosObj[01,01], _aPosObj[01,02] SAY 		lblCodProd 	PROMPT 	"C๓digo do Produto:"  	SIZE _aPosObj[01,03], _aPosObj[01,04] 																OF oDlg COLORS 0, 16777215 						PIXEL
	@ _aPosObj[02,01], _aPosObj[02,02] MSGET 	txtCodProd 	VAR 	_cCodProd 				SIZE _aPosObj[02,03], _aPosObj[02,04] VALID  ValidProd() 											OF oDlg COLORS 0, 16777215 F3 "SB1"				PIXEL
	@ _aPosObj[05,01], _aPosObj[05,02] SAY 		lblGrupo 	PROMPT 	"Grupo:" 				SIZE _aPosObj[05,03], _aPosObj[05,04] 																OF oDlg COLORS 0, 16777215						PIXEL
	@ _aPosObj[06,01], _aPosObj[06,02] MSGET 	oGet1 		VAR 	_cGrpProd				SIZE _aPosObj[06,03], _aPosObj[06,04] VALID  ValidGrup() 											OF oDlg COLORS 0, 16777215 F3 "SBM"				PIXEL
	@ _aPosObj[23,01], _aPosObj[23,02] SAY 		oSay7 		PROMPT 	"De volume:" 			SIZE _aPosObj[23,03], _aPosObj[23,04] 						 										OF oDlg COLORS 0, 16777215						PIXEL
	@ _aPosObj[24,01], _aPosObj[24,02] SAY 		oSay8 		PROMPT 	"At้ volume:"			SIZE _aPosObj[24,03], _aPosObj[24,04] 						 										OF oDlg COLORS 0, 16777215						PIXEL
	@ _aPosObj[21,01], _aPosObj[21,02] MSGET 	oGetQtdIni	VAR 	_nVolIni				SIZE _aPosObj[21,03], _aPosObj[21,04]  VALID  Seleciona()	PICTURE PesqPict("ACN","ACN_QUANTI")	OF oDlg COLORS 0, 16777215						PIXEL
	@ _aPosObj[22,01], _aPosObj[22,02] MSGET 	oGetQtdFim	VAR 	_nVolFim				SIZE _aPosObj[22,03], _aPosObj[22,04]  VALID  Seleciona()	PICTURE PesqPict("ACN","ACN_QUANTI")	OF oDlg COLORS 0, 16777215						PIXEL	
	@ _aPosObj[07,01], _aPosObj[07,02] SAY 		oSay1 		PROMPT 	"Descri็ใo:" 			SIZE _aPosObj[07,03], _aPosObj[07,04] 																OF oDlg COLORS 0, 16777215						PIXEL
	@ _aPosObj[08,01], _aPosObj[08,02] MSGET 	oGet2 		VAR 	_cDescri				SIZE _aPosObj[08,03], _aPosObj[08,04] 																OF oDlg COLORS 0, 16777215			READONLY	PIXEL	
	@ _aPosObj[13,01], _aPosObj[13,02] MSGET 	oGetDesc1	VAR 	_nDesc1					SIZE _aPosObj[13,03], _aPosObj[13,04] VALID  CalcFator()	PICTURE PesqPict("ACN","ACN_DESCON")	OF oDlg COLORS 0, 16777215						PIXEL
	@ _aPosObj[14,01], _aPosObj[14,02] MSGET 	oGetDesc2	VAR 	_nDesc2					SIZE _aPosObj[14,03], _aPosObj[14,04] VALID  CalcFator()	PICTURE PesqPict("ACN","ACN_DESCON")	OF oDlg COLORS 0, 16777215						PIXEL
	@ _aPosObj[15,01], _aPosObj[15,02] MSGET 	oGetDesc3	VAR 	_nDesc3					SIZE _aPosObj[15,03], _aPosObj[15,04] VALID  CalcFator()	PICTURE PesqPict("ACN","ACN_DESCON")	OF oDlg COLORS 0, 16777215						PIXEL
	@ _aPosObj[16,01], _aPosObj[16,02] MSGET 	oGetDesc4	VAR 	_nDesc4					SIZE _aPosObj[16,03], _aPosObj[16,04] VALID  CalcFator()	PICTURE PesqPict("ACN","ACN_DESCON")	OF oDlg COLORS 0, 16777215						PIXEL
	
	@ _aPosObj[17,01], _aPosObj[17,02] SAY 		oSay3 		PROMPT 	"Desconto 1:" 			SIZE _aPosObj[17,03], _aPosObj[17,04] 						 										OF oDlg COLORS 0, 16777215						PIXEL
	@ _aPosObj[18,01], _aPosObj[18,02] SAY 		oSay4 		PROMPT 	"Desconto 2:" 			SIZE _aPosObj[18,03], _aPosObj[18,04] 						 										OF oDlg COLORS 0, 16777215						PIXEL	
	@ _aPosObj[19,01], _aPosObj[19,02] SAY 		oSay5 		PROMPT 	"Desconto 3:" 			SIZE _aPosObj[19,03], _aPosObj[19,04] 						 										OF oDlg COLORS 0, 16777215						PIXEL
	@ _aPosObj[20,01], _aPosObj[20,02] SAY 		oSay6 		PROMPT 	"Desconto 4:" 			SIZE _aPosObj[20,03], _aPosObj[20,04] 						 										OF oDlg COLORS 0, 16777215						PIXEL

	@ _aPosObj[11,01], _aPosObj[11,02] SAY 		lblDesc 	PROMPT 	"Fator calculado:" 		SIZE _aPosObj[11,03], _aPosObj[11,04] 						 										OF oDlg COLORS 0, 16777215						PIXEL
	@ _aPosObj[12,01], _aPosObj[12,02] SAY 		oSay2 		PROMPT 	"Sugerir Limite:" 		SIZE _aPosObj[12,03], _aPosObj[12,04] 						 										OF oDlg COLORS 0, 16777215						PIXEL
	@ _aPosObj[10,01], _aPosObj[10,02] MSGET 	oGet4 		VAR 	_nVolSug				SIZE _aPosObj[10,03], _aPosObj[10,04] VALID  CalcFator()	PICTURE PesqPict("ACN","ACN_QUANTI")	OF oDlg COLORS 0, 16777215						PIXEL
	@ _aPosObj[09,01], _aPosObj[09,02] MSGET 	oGet3 		VAR 	_nDescSug				SIZE _aPosObj[09,03], _aPosObj[09,04] VALID  Seleciona()	PICTURE PesqPict("ACN","ACN_DESCON")	OF oDlg COLORS 0, 16777215			READONLY	PIXEL
	Seleciona()
	_lForca := .F.
	@ _aPosObj[03,01], _aPosObj[03,02] BUTTON 	btnOk 		PROMPT 	"Confirmar" 			SIZE _aPosObj[03,03], _aPosObj[03,04] 																OF oDlg ACTION Confirmar()						PIXEL
	@ _aPosObj[04,01], _aPosObj[04,02] BUTTON	btnCancel 	PROMPT 	"Cancelar" 				SIZE _aPosObj[04,03], _aPosObj[04,04] 																OF oDlg ACTION Fechar()							PIXEL

    @ 055, _aSize[1]+284+10 RADIO oRadMenu1 VAR _nRadMenu1 ITEMS "Regras novas","Todas as regras" SIZE 071, 018 OF oDlg COLOR 0, 16777215 PIXEL	
	
  ACTIVATE MSDIALOG oDlg CENTERED

//Fecho a tabela temporแria
dbSelectArea(_cTabTmp)
dbCloseArea()
	
//Restauro a แrea de trabalho original
RestArea(_aSavACN)
RestArea(_aSavSX3)
RestArea(_aSavArea)
	
Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RFATE054 บAutor  ณAdriano L. de Souza บ Data ณ  05/08/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsแvel por montar a getDados na tela (aCols).  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico empresa ARCOLOR                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

//------------------------------------------------ 
Static Function fMSNewGe1()
//------------------------------------------------ 
Local nX
Local aFieldFill 	:= {}
Local aFields 		:= {"NOUSER"}
Local aAlterFields 	:= {}
Static oMSNewGe1

Private _dDATFIM := SuperGetMv("MV_DATFIM",,StoD("20491231"))

aHeader 			:= {}
aCols 				:= {}

//Defino as colunas que serใo editแveis
Aadd(aAlterFields,"TP_CODFAT")	
Aadd(aAlterFields,"TP_DESCV1")
Aadd(aAlterFields,"TP_DESCV2")
Aadd(aAlterFields,"TP_DESCV3")
Aadd(aAlterFields,"TP_DESCV4")
Aadd(aAlterFields,"TP_CODFAT")
Aadd(aAlterFields,"TP_QUANTI")
Aadd(aAlterFields,"TP_PROMOC")
Aadd(aAlterFields,"TP_DATINI")
Aadd(aAlterFields,"TP_DATFIM")

//Defino as colunas e propriedades dos campos utilizados para montar a getDados
  	
//	AADD(aHeader,{"titulo","campo","picture","tamanho","decimal","valid","usado","tipo","f3","context","combo","relacao"})
AADD(aHeader,{"C๓d. Regra"		,"TP_CODREG"	,PesqPict("ACS","ACS_CODREG")	,TamSx3("ACS_CODREG")[01]	,TamSx3("ACS_CODREG")[02]	,""				,"S","C",""		,"",""				,""})
AADD(aHeader,{"Descri็ใo"		,"TP_DESCRI"	,PesqPict("ACS","ACS_DESCRI")	,TamSx3("ACS_DESCRI")[01]	,TamSx3("ACS_DESCRI")[02]	,""				,"S","C",""		,"",""				,""})
AADD(aHeader,{"Grp. Venda"		,"TP_GRPVEN"	,PesqPict("ACS","ACS_GRPVEN")	,TamSx3("ACS_GRPVEN")[01]	,TamSx3("ACS_GRPVEN")[02]	,""				,"S","C",""		,"",""				,""})
AADD(aHeader,{"Cliente"			,"TP_CODCLI"	,PesqPict("ACS","ACS_CODCLI")	,TamSx3("ACS_CODCLI")[01]	,TamSx3("ACS_CODCLI")[02]	,""				,"S","C",""		,"",""				,""})
AADD(aHeader,{"Loja"			,"TP_LOJA"		,PesqPict("ACS","ACS_LOJA"	)	,TamSx3("ACS_LOJA"	)[01]	,TamSx3("ACS_LOJA"	)[02]	,""				,"S","C",""		,"",""				,""})
AADD(aHeader,{"Item"			,"TP_ITEM"		,PesqPict("ACN","ACN_ITEM"	)	,TamSx3("ACN_ITEM"	)[01]	,TamSx3("ACN_ITEM"	)[02]	,""				,"S","C",""		,"",""				,""})
AADD(aHeader,{"Grp Produto"		,"TP_GRPPRO"	,PesqPict("ACN","ACN_GRPPRO")	,TamSx3("ACN_GRPPRO")[01]	,TamSx3("ACN_GRPPRO")[02]	,""				,"S","C",""		,"",""				,""})
AADD(aHeader,{"Descr. Item"		,"TP_DESCIT"	,PesqPict("SB1","B1_COD"	)	,TamSx3("B1_COD"	)[01]	,TamSx3("B1_COD"	)[02]	,""				,"S","C",""		,"",""				,""})
AADD(aHeader,{"C๓d. Fator"		,"TP_CODFAT"	,PesqPict("ACN","ACN_CODFAT")	,TamSx3("ACN_CODFAT")[01]	,TamSx3("ACN_CODFAT")[02]	,""				,"S","C","SZA"	,"",""				,""})
AADD(aHeader,{"Desconto 1"		,"TP_DESCV1"	,PesqPict("ACN","ACN_DESCV1")	,TamSx3("ACN_DESCV1")[01]	,TamSx3("ACN_DESCV1")[02]	,"U_CalcDescIt()"	,"S","N",""		,"",""				,""})
AADD(aHeader,{"Desconto 2"		,"TP_DESCV2"	,PesqPict("ACN","ACN_DESCV2")	,TamSx3("ACN_DESCV2")[01]	,TamSx3("ACN_DESCV2")[02]	,"U_CalcDescIt()"	,"S","N",""		,"",""				,""})
AADD(aHeader,{"Desconto 3"		,"TP_DESCV3"	,PesqPict("ACN","ACN_DESCV3")	,TamSx3("ACN_DESCV3")[01]	,TamSx3("ACN_DESCV3")[02]	,"U_CalcDescIt()"	,"S","N",""		,"",""				,""})
AADD(aHeader,{"Desconto 4"		,"TP_DESCV4"	,PesqPict("ACN","ACN_DESCV4")	,TamSx3("ACN_DESCV4")[01]	,TamSx3("ACN_DESCV4")[02]	,"U_CalcDescIt()"	,"S","N",""		,"",""				,""})
AADD(aHeader,{"% Desconto At้"	,"TP_DESCON"	,PesqPict("ACN","ACN_DESCON")	,TamSx3("ACN_DESCON")[01]	,TamSx3("ACN_DESCON")[02]	,""				,"S","N",""		,"",""				,""})
AADD(aHeader,{"Item Grade"		,"TP_ITEMGR"	,PesqPict("ACN","ACN_ITEMGR")	,TamSx3("ACN_ITEMGR")[01]	,TamSx3("ACN_ITEMGR")[02]	,""				,"S","C",""		,"",""				,""})
AADD(aHeader,{"At้ Quantidade"	,"TP_QUANTI"	,PesqPict("ACN","ACN_QUANTI")	,TamSx3("ACN_QUANTI")[01]	,TamSx3("ACN_QUANTI")[02]	,""				,"S","N",""		,"",""				,""})
AADD(aHeader,{"Usr. Inclusใo"	,"TP_USRINC"	,PesqPict("ACN","ACN_USRINC")	,TamSx3("ACN_USRINC")[01]	,TamSx3("ACN_USRINC")[02]	,""				,"S","C",""		,"",""				,""})
AADD(aHeader,{"Dt. Inclusใo"	,"TP_DTINCL"	,PesqPict("ACN","ACN_DTINCL")	,TamSx3("ACN_DTINCL")[01]	,TamSx3("ACN_DTINCL")[02]	,""				,"S","D",""		,"",""				,""})
AADD(aHeader,{"Usr. Altera็ใo"	,"TP_USRALT"	,PesqPict("ACN","ACN_USRALT")	,TamSx3("ACN_USRALT")[01]	,TamSx3("ACN_USRALT")[02]	,""				,"S","C",""		,"",""				,""})
AADD(aHeader,{"Prioriza"		,"TP_PROMOC"	,PesqPict("ACN","ACN_PROMOC")	,TamSx3("ACN_PROMOC")[01]	,TamSx3("ACN_PROMOC")[02]	,""				,"S","C",""		,"","1=Sim;2=Nao"	,""})
AADD(aHeader,{"Data Inicial"	,"TP_DATINI"	,PesqPict("ACN","ACN_DATINI")	,TamSx3("ACN_DATINI")[01]	,TamSx3("ACN_DATINI")[02]	,""				,"S","D",""		,"",""				,""})
AADD(aHeader,{"Data Final"		,"TP_DATFIM"	,PesqPict("ACN","ACN_DATFIM")	,TamSx3("ACN_DATFIM")[01]	,TamSx3("ACN_DATFIM")[02]	,""				,"S","D",""		,"",""				,""})
AADD(aHeader,{"Alias"			,"TP_ALIAS"		,""								,3							,0							,""				,"S","C",""		,"",""				,""})
AADD(aHeader,{"Recno"			,"TP_RECNO"		,""								,17							,0							,""				,"S","N",""		,"",""				,""})

	aIndex		:= {}
	
	Private bFiltraBrw 	:= {|| Nil}
	
	_cInd1		:= CriaTrab(Nil,.F.)
	_aCpos		:= {}
	_aStruct	:= {}
	_aCampos	:= {}
	_cTabTmp	:= GetNextAlias()
	
	//Monto estrutura para tabela temporแria que serแ utilizada para compor a getDados
	For _nCont := 1 To Len(aHeader)
		AAdd(_aCpos,{aHeader[_nCont,2],aHeader[_nCont,8],aHeader[_nCont,4],aHeader[_nCont,5]})
	Next
	/*
	_cInd1 := CriaTrab(_aCpos,.T.)
	
	//Crio tabela temporแria para uso com getDados
	dbUseArea(.T.,,_cInd1,_cTabTmp,.T.,.F.)
	IndRegua(_cTabTmp,_cInd1,"TP_DESCRI + TP_CODREG + STR(TP_QUANTI)",,,"Criando ํndice temporแrio...")
	*/
	
	//-------------------
	//Criacao do objeto
	//-------------------
	_cTabTmp   := GetNextAlias()
	oTempTable := FWTemporaryTable():New( _cTabTmp )
		
	oTemptable:SetFields( _aCpos )
	oTempTable:AddIndex("indice1", {"TP_DESCRI","TP_CODREG","TP_QUANTI"} )
	
	//------------------
	//Criacao da tabela
	//------------------
	oTempTable:Create()
	
	//Query para retornar as regras de neg๓cios com base no produto/grupo de produto definido pelo usuแrio
	_cQry := "SELECT * FROM ( " + _cEnter
	_cQry += "SELECT ACS.ACS_CODCLI, ACS.ACS_LOJA, ACS.ACS_GRPVEN,ACS.ACS_DESCRI, ACS.ACS_CODREG, ACN.* FROM " + RetSqlName("ACS") +" ACS " + _cEnter
	_cQry += "INNER JOIN " + RetSqlName("ACN") +" ACN " + _cEnter
	_cQry += "ON ACS.ACS_FILIAL='" + xFilial("ACS") + "' " + _cEnter
	_cQry += "AND ACS.D_E_L_E_T_='' " + _cEnter
	_cQry += "AND ACN.ACN_FILIAL='" + xFilial("ACN") + "' " + _cEnter
	_cQry += "AND ACN.D_E_L_E_T_='' " + _cEnter
	_cQry += "AND ACN.ACN_CODREG=ACS.ACS_CODREG " + _cEnter
	//Verifico se o filtro serแ feito por produto ou por grupo de produtos
	If Empty(_cGrpProd)
		_cQry += "AND ACN.ACN_CODPRO='" + _cCodProd + "' " + _cEnter
	Else
		_cQry += "AND ACN.ACN_GRPPRO='" + _cGrpProd + "' " + _cEnter
	EndIf
	_cQry += " AND ACN.ACN_QUANTI>0 " + _cEnter	
	_cQry += " AND ACN.ACN_QUANTI BETWEEN " + AllTrim(Str(_nVolIni)) + " AND " + AllTrim(Str(_nVolFim)) + " " + _cEnter
	_cQry += " UNION ALL " + _cEnter

	_cQry += " SELECT ACS.ACS_CODCLI, ACS.ACS_LOJA, ACS.ACS_GRPVEN,ACS.ACS_DESCRI, ACS.ACS_CODREG,ACN.* FROM " + RetSqlName("ACS") + " ACS " + _cEnter
	_cQry += "  LEFT JOIN " + RetSqlName("ACN") + " ACN " + _cEnter
	_cQry += "  ON ACS.ACS_CODREG=ACN.ACN_CODREG " + _cEnter
	//Verifico se o filtro serแ feito por produto ou por grupo de produtos
	If Empty(_cGrpProd)
		_cQry += "AND ACN.ACN_CODPRO='" + _cCodProd + "' " + _cEnter
	Else
		_cQry += "AND ACN.ACN_GRPPRO='" + _cGrpProd + "' " + _cEnter
	EndIf	
	_cQry += "  AND ACN.ACN_QUANTI>0  " + _cEnter
	_cQry += " AND ACN.ACN_QUANTI BETWEEN " + AllTrim(Str(_nVolIni)) + " AND " + AllTrim(Str(_nVolFim)) + " " + _cEnter
	_cQry += "  WHERE ACS.D_E_L_E_T_='' " + _cEnter
	_cQry += "  AND ACS.ACS_FILIAL='" + xFilial("ACS") + "' " + _cEnter
	_cQry += "  AND ACN.ACN_FILIAL IS NULL " + _cEnter
	_cQry += "  AND ('" + _cCodProd + "'<>'' OR '" + _cGrpProd + "'<>'') " + _cEnter
	_cQry += "  AND " + AllTrim(Str(_nVolFim)) + ">0 " + _cEnter
	_cQry += ") TMP "
	
	_cQTemp := GetNextAlias()
	
	//Crio tabela temporแria com as regras que cont้m o produto/grupo e pr้-inclui o produto/grupo em regras em que o mesmo nใo existe, neste caso serใo sugeridos como deletados
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cQTemp,.F.,.T.)
	
	//Gravo a tabela temporแria com base no resultado da query acima
	dbSelectArea(_cQTemp) //Tabela temporแria com resultado da query
	dbGoTop()
	While (_cQTemp)->(!EOF())
		while !RecLock(_cTabTmp,.T.) ; enddo
			TP_CODREG	:= (_cQTemp)->(ACS_CODREG)
			TP_DESCRI	:= (_cQTemp)->(ACS_DESCRI)
			TP_GRPVEN	:= (_cQTemp)->(ACS_GRPVEN)
			TP_CODCLI	:= (_cQTemp)->(ACS_CODCLI)
			TP_LOJA		:= (_cQTemp)->(ACS_LOJA)
			TP_ITEM		:= (_cQTemp)->(ACN_ITEM)
			TP_GRPPRO	:= (_cQTemp)->(ACN_GRPPRO)
			TP_DESCIT	:= ""
			TP_CODFAT	:= (_cQTemp)->(ACN_CODFAT)
			TP_DESCV1	:= IIF((_cQTemp)->(R_E_C_N_O_)==0,_nDescSug,(_cQTemp)->(ACN_DESCV1))
			TP_DESCV2	:= (_cQTemp)->(ACN_DESCV2)
			TP_DESCV3	:= (_cQTemp)->(ACN_DESCV3)
			TP_DESCV4	:= (_cQTemp)->(ACN_DESCV4)
			TP_DESCON	:= IIF((_cQTemp)->(R_E_C_N_O_)==0,_nDescSug,(_cQTemp)->(ACN_DESCON))
			TP_ITEMGR	:= (_cQTemp)->(ACN_ITEMGR)
			TP_QUANTI	:= IIF((_cQTemp)->(R_E_C_N_O_)==0,_nVolSug ,(_cQTemp)->(ACN_QUANTI))
			TP_USRIN	:= (_cQTemp)->(ACN_USRINC)
			TP_DTINCL	:= IIF((_cQTemp)->(R_E_C_N_O_)==0,CriaVar("ACN_DTINCL"),StoD((_cQTemp)->(ACN_DTINCL)))
			TP_USRALT	:= (_cQTemp)->(ACN_USRALT)
			TP_PROMOC	:= IIF((_cQTemp)->(R_E_C_N_O_)==0,CriaVar("ACN_PROMOC"),(_cQTemp)->(ACN_PROMOC))
			TP_DATINI	:= IIF((_cQTemp)->(R_E_C_N_O_)==0,CriaVar("ACN_DATINI"),StoD((_cQTemp)->(ACN_DATINI)))
			TP_DATFIM	:= IIF((_cQTemp)->(R_E_C_N_O_)==0,_dDATFIM,StoD((_cQTemp)->(ACN_DATFIM)))
			TP_ALIAS	:= "ACN"
			TP_RECNO	:= (_cQTemp)->(R_E_C_N_O_)
		(_cQTemp)->(MsUnlock())
		
		dbSelectArea(_cQTemp)
		(_cQTemp)->(dbSkip())
	EndDo
	
	dbSelectArea(_cQTemp)
	(_cQTemp)->(dbCloseArea()) //Fecho a tabela temporแria com base no resultado da query

dbSelectArea(_cTabTmp)
dbGoTop()

While (_cTabTmp)->(!EOF())
	
	// Define field values
 	For _nCont2 := 1 To Len(aHeader)
		Aadd(aFieldFill, &(aHeader[_nCont2,2]))
	Next
	
	Aadd(aFieldFill,.F.) //Flag de registro deletado
	
	Aadd(aCols, aFieldFill)
	aFieldFill := {}
	
	dbSelectArea(_cTabTmp)
	dbSkip()
EndDo

//Marco as regras inexistentes como deletadas para que o usuแrio decida quais serใo criadas
For _nCont3 := 1 To Len(aCols)
	If aCols[_nCont3,Len(aCols[_nCont3])-1]==0
		aCols[_nCont3,Len(aCols[_nCont3])] := .T. //Marco como deletado
	EndIf
Next
	
oMSNewGe1 := MsNewGetDados():New( _aSize[1]+075, _aSize[1]+_nMargem, (_aSize[6]*0.50)-((_nMargem+_nAltBut)*2), _aSize[3]-_nMargem, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 16959, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeader, aCols)
oMSNewGe1:Refresh()

CalcFator()

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RFATE054 บAutor  ณAdriano L. de Souza บ Data ณ  05/08/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsแvel gravar as altera็๕es feitas pelo usuแrioบฑฑ
ฑฑบ          ณ alterando ou incluindo novas regras.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico empresa ARCOLOR                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function Confirmar()

If MsgYesNo("Deseja salvar as altera็๕es feitas?",_cRotina+"_001")
	dbSelectArea("ACN")
	For _nCont4 := 1 To Len(aCols)

		//Certifico que a linha nใo estแ deletada
		If !oMSNewGe1:aCols[_nCont4,Len(aCols[_nCont4])]
			
			_nPosRec := aScan(aHeader,{|x|AllTrim(x[02])=="TP_RECNO"})
			
			//Avalio se o registro deverแ ser atualizado ou incluํdo na regra de neg๓cios
			If oMSNewGe1:aCols[_nCont4,_nPosRec]>0
				If oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_QUANTI"})]>0
					dbSelectArea("ACN")
					dbGoTo(oMSNewGe1:aCols[_nCont4,_nPosRec])
			  		while !RecLock("ACN",.F.) ; enddo
						ACN->ACN_CODFAT := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_CODFAT"})]
						ACN->ACN_DESCV1 := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_DESCV1"})]
						ACN->ACN_DESCV2 := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_DESCV2"})]
						ACN->ACN_DESCV3 := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_DESCV3"})]
						ACN->ACN_DESCV4 := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_DESCV4"})]
						ACN->ACN_DESCON := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_DESCON"})]
						ACN->ACN_ITEMGR := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_ITEMGR"})]
						ACN->ACN_QUANTI := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_QUANTI"})]
						ACN->ACN_USRALT := __cUserId
						ACN->ACN_PROMOC := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_PROMOC"})]
						ACN->ACN_DATINI := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_DATINI"})]
						ACN->ACN_DATFIM := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_DATFIM"})]					
					ACN->(MsUnlock())
				EndIf
			ElseIf !oMSNewGe1:aCols[_nCont4,Len(aCols[_nCont4])] .And. oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_QUANTI"})]>0//Verifico se a linha estแ ativa
				while !RecLock("ACN",.T.) ; enddo
					ACN->ACN_FILIAL	:= xFilial("ACN")
					ACN->ACN_CODREG := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_CODREG"})]
					ACN->ACN_ITEM   := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_ITEM"  })]
					ACN->ACN_CODPRO := _cCodProd
					ACN->ACN_GRPPRO := _cGrpProd
					ACN->ACN_CODFAT := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_CODFAT"})]
					ACN->ACN_DESCV1 := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_DESCV1"})]
					ACN->ACN_DESCV2 := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_DESCV2"})]
					ACN->ACN_DESCV3 := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_DESCV3"})]
					ACN->ACN_DESCV4 := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_DESCV4"})]
					ACN->ACN_DESCON := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_DESCON"})]
					ACN->ACN_ITEMGR := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_ITEMGR"})]
					ACN->ACN_QUANTI := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_QUANTI"})]
					ACN->ACN_USRINC := __cUserId
					ACN->ACN_DTINCL := dDataBase
					ACN->ACN_PROMOC := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_PROMOC"})]
					ACN->ACN_DATINI := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_DATINI"})]
					ACN->ACN_DATFIM := oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_DATFIM"})]
		  			ACN->ACN_ITEM	:= Sequencia(oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_CODREG"})])
				ACN->(MsUnlock())
			EndIf
		ElseIf oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_RECNO"})]>0
			
			//Avalio se o registro deverแ ser deletado
			If oMSNewGe1:aCols[_nCont4,aScan(aHeader,{|x|AllTrim(x[02])=="TP_RECNO"})]>0
				_nPosRec := aScan(aHeader,{|x|AllTrim(x[02])=="TP_RECNO"})
				dbSelectArea("ACN")
				dbGoTo(oMSNewGe1:aCols[_nCont4,_nPosRec])
				
				while !RecLock("ACN",.F.) ; enddo
					Delete
				ACN->(MsUnlock())
			EndIf
		EndIf
	Next
EndIf

MsgInfo("Dados gravados com sucesso!",_cRotina+"_003")
_lForca := .T.
Seleciona()

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RFATE054 บAutor  ณAdriano L. de Souza บ Data ณ  05/08/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsแvel restaurar a แrea de trabalho original e บฑฑ
ฑฑบ          ณ fechar a tela de inclusใo de regras.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico empresa ARCOLOR                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function Fechar()

//Restauro a แrea de trabalho original
RestArea(_aSavACN)
RestArea(_aSavSX3)
RestArea(_aSavArea)

//Fecho a tabela no final do processo
Close(oDlg)

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RFATE054 บAutor  ณAdriano L. de Souza บ Data ณ  05/08/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsแvel validar o produto e atualizar as infor- บฑฑ
ฑฑบ          ณ ma็๕es na tela.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico empresa ARCOLOR                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function ValidProd()
	_lRet := .T.

	If !Empty(_cCodProd)
		_lRet 		:= Empty(_cCodProd) .Or. ExistCpo("SB1",_cCodProd)
		_cGrpProd	:= Space(TamSX3("B1_GRUPO")[01])
		If _lRet
			_cDescri:= Posicione("SB1",1,xFilial("SB1")+_cCodProd,"B1_DESC")
			Seleciona()
		EndIf
	EndIf
Return(_lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RFATE054 บAutor  ณAdriano L. de Souza บ Data ณ  05/08/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsแvel validar o grupo de produtos e atualizar บฑฑ
ฑฑบ          ณ as informa็๕es na tela.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico empresa ARCOLOR                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function ValidGrup()
	
	_lRet := .T.
	
	If !Empty(_cGrpProd)
		_lRet 		:= Empty(_cGrpProd) .Or. ExistCpo("SBM",_cGrpProd)
		_cCodProd	:= Space(TamSX3("B1_COD")[01])
		If _lRet
			_cDescri:= Posicione("SBM",1,xFilial("SBM")+_cGrpProd,"BM_DESC")
			Seleciona()
		EndIf
	EndIf
Return(_lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RFATE054 บAutor  ณAdriano L. de Souza บ Data ณ  05/08/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsแvel retornar a sequ๊ncia do item na regra   บฑฑ
ฑฑบ          ณ especificada.                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico empresa ARCOLOR                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function Sequencia(_cCodReg)

	_cSequ := ""
	_cTabS := GetNextAlias()
	_cQry2 := "SELECT MAX(ACN_ITEM) AS [MAXSEQ] FROM " + RetSqlName("ACN") + " WHERE D_E_L_E_T_='' AND ACN_FILIAL='" + xFilial("ACN") + "' AND ACN_CODREG='" + _cCodReg + "' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry2),_cTabS,.F.,.T.)
	
	dbSelectArea(_cTabS)
	
    If (_cTabS)->(!EOF())
    	_cSequ := (_cTabS)->(MAXSEQ)
    Else
	    _cSequ := StrZero(0,TamSx3("ACN_ITEM")[01])
    EndIf
	
	dbSelectArea(_cTabS)	
	(_cTabS)->(dbCloseArea())
	
	_cSequ := Soma1(_cSequ)
	
Return(_cSequ)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RFATE054 บAutor  ณAdriano L. de Souza บ Data ณ  05/08/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsแvel por retornar o fator dos descontos em   บฑฑ
ฑฑบ          ณ cascata.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico empresa ARCOLOR                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function CalcFator()
   
	_nFator := 100-_nDesc1
	_nFator -= _nFator*(_nDesc2/100)
	_nFator -= _nFator*(_nDesc3/100)
	_nFator -= _nFator*(_nDesc4/100)
	_nFator := 100-_nFator
	
	_nDescSug := _nFator
	
	_nPosRec := aScan(aHeader,{|x|AllTrim(x[02])=="TP_RECNO"})
	
	For _nCont5 := 1 To Len(oMSNewGe1:aCols)
		If oMSNewGe1:aCols[_nCont5,_nPosRec]==0 .Or. _nRadMenu1==2
			oMSNewGe1:aCols[_nCont5,aScan(aHeader,{|x|AllTrim(x[02])=="TP_DESCV1"})] := _nDesc1
			oMSNewGe1:aCols[_nCont5,aScan(aHeader,{|x|AllTrim(x[02])=="TP_DESCV2"})] := _nDesc2
			oMSNewGe1:aCols[_nCont5,aScan(aHeader,{|x|AllTrim(x[02])=="TP_DESCV3"})] := _nDesc3
			oMSNewGe1:aCols[_nCont5,aScan(aHeader,{|x|AllTrim(x[02])=="TP_DESCV4"})] := _nDesc4
			oMSNewGe1:aCols[_nCont5,aScan(aHeader,{|x|AllTrim(x[02])=="TP_DESCON"})] := _nDescSug
			oMSNewGe1:aCols[_nCont5,aScan(aHeader,{|x|AllTrim(x[02])=="TP_QUANTI"})] := _nVolSug
		EndIf
	Next
	
	oMSNewGe1:Refresh()
Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RFATE054 บAutor  ณAdriano L. de Souza บ Data ณ  05/08/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsแvel por montar a grid com registros das re- บฑฑ
ฑฑบ          ณ gras (aCols).                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico empresa ARCOLOR                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function Seleciona()
	
	If 	_nBkpVolI <> _nVolIni .Or. _nBkpVolF <> _nVolFim .Or. _cBkpProd <> _cCodProd .Or. _cBkpGrup <> _cGrpProd .Or. _lForca
		MsgRun("Aguarde... Selecionando dados...",_cRotina+"_002",{ || _cCalc := fMSNewGe1() })
	EndIf
	
	_nBkpVolI := _nVolIni
	_nBkpVolF := _nVolFim
	_cBkpProd := _cCodProd
	_cBkpGrup := _cGrpProd
Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RFATE054 บAutor  ณAdriano L. de Souza บ Data ณ  05/08/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsแvel por calcular o fator dos descontos nos  บฑฑ
ฑฑบ          ณ itens (desconto em cascata).                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico empresa ARCOLOR                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function CalcDescIt()

	_lRet := .T.
	
	If Len(aCols)>0
		If "TP_DESCV1" $ ReadVar()
			_nDescAux1 := &(ReadVar())
		Else
			_nDescAux1 := oMSNewGe1:aCols[n,aScan(oMSNewGe1:aHeader,{|x|AllTrim(x[02])=="TP_DESCV1"})]
		EndIf
		
		If "TP_DESCV2" $ ReadVar()
			_nDescAux2 := &(ReadVar())
		Else
			_nDescAux2 := oMSNewGe1:aCols[n,aScan(oMSNewGe1:aHeader,{|x|AllTrim(x[02])=="TP_DESCV2"})]
		EndIf
		
		If "TP_DESCV3" $ ReadVar()
			_nDescAux3 := &(ReadVar())
		Else
			_nDescAux3 := oMSNewGe1:aCols[n,aScan(oMSNewGe1:aHeader,{|x|AllTrim(x[02])=="TP_DESCV3"})]
		EndIf
		
		If "TP_DESCV4" $ ReadVar()
			_nDescAux4 := &(ReadVar())
		Else
			_nDescAux4 := oMSNewGe1:aCols[n,aScan(oMSNewGe1:aHeader,{|x|AllTrim(x[02])=="TP_DESCV4"})]
		EndIf
		
		_nDescAux  := oMSNewGe1:aCols[n,aScan(oMSNewGe1:aHeader,{|x|AllTrim(x[02])=="TP_DESCON"})]
		
		_nFator := 100-_nDescAux1
		_nFator -= _nFator*(_nDescAux2/100)
		_nFator -= _nFator*(_nDescAux3/100)
		_nFator -= _nFator*(_nDescAux4/100)
		_nFator := 100-_nFator
		
		oMSNewGe1:aCols[n,aScan(oMSNewGe1:aHeader,{|x|AllTrim(x[02])=="TP_DESCON"})] := _nFator
		oMSNewGe1:Refresh()
	EndIf
	
Return(_lRet)