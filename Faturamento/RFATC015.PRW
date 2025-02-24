#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "VKEY.CH"
#INCLUDE "TBICONN.CH

#define _clrf CHR(13) + CHR(10)

/*/{Protheus.doc} RFATC011
@description Rotina de consulta de Devolução por Cliente.
@author Livia Della Corte (ALL System Solutions)
@since 20/12/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RFATC015()
	Local   _aSavArea := GetArea()
	Local   oButton1
	Local   oGroup1, oGroup2, oGroup3, oGroup4, oGroup5,oGroup6
	Local   oGet1
	Local   oGet2
	Local   oGet3
	Local   oSay1
	Local   oSay2
	Local   oSay3
	Private _aSize    := MsAdvSize()
	If Type("cFilAnt")=="U"
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" FUNNAME "RFATC015"		
		_aSize[1]:= 400
		_aSize[5]:= 1900
		_aSize[6]:= 1300
	EndIf
	Private oGet4
	Private oSay4
	Private oSay5
	Private oGet5
	Private _nOrd     := 1		//Ordem dos registros na Grid2
	Private INCLUI    := .F.
	Private ALTERA    := .F.
	Private _lSeekApr := .F.
	Private aAux1     := {}
	Private aAux2     := {}
	Private aFields1  := {"D1_EMISSAO","D1_DOC"}
	Private aFields2  := {	"D1_EMISSAO",;
							"D1_DOC"    ,;
							"D1_SERIE"  ,;
							"D1_COD"	,;
							"D1_DESCR" 	,;
							"D1_NFORI"  ,;
							"D1_SERIORI",;
							"D2_PEDIDO"	,;								
							"D2_QTDEDEV",;
							"D1_TOTAL"  ,;
							"D2_EMISSAO","C6_EMISSAO", "C6_QTDENT",;
							"D2_QUANT" ,;
							"E1_VENCTO",;
							"E1_SALDO",;
							"E1_PARCELA"}
   
	Private cGet1     := IIF(FUNNAME()=="TMKA271".AND.!SUA->UA_PROSPEC,SUA->UA_CLIENTE,Space(TamSx3("A1_COD" )[01]))
	Private cGet2     := IIF(FUNNAME()=="TMKA271".AND.!SUA->UA_PROSPEC,SUA->UA_LOJA   ,Space(TamSx3("A1_LOJA")[01]))
	Private cGet3     := IIF(FUNNAME()=="TMKA271".AND.!SUA->UA_PROSPEC,SUA->UA_NOMECLI,Space(TamSx3("A1_NOME")[01]))
	Private cSay4     := SPACE(len(SB1->B1_COD))
	Private cGet4     := SPACE(len(SB1->B1_COD))
	Private cGet7     := SPACE(len(SB1->B1_DESC))
	Private cGet5     := SPACE(30)
	
	Private oSay8, oSay9,oSay10,oSay11,oSay12,oSay13,oSay14,oSay15,oSay16,oSay17,oSay18,oSay19,oSay20,oSay21,oSay22,oSay23,oSay24,oSay25,oSay26,oSay27,oSay28,oSay29,oSay30,oSay31,oSay32,oSay33,oSay34,oSay35,oSay36,oSay37,oSay38,oSay39,oSay40,oSay41,oSay42,oSay43,oSay44,oSay45,oSay46,oSay47,oSay48,oSay49,oSay50
	Private oGet8, oGet9,oGet10,oGet11,oGet12, oGet13, oGet14, oGet15, oGet16, oGet17,cGet18,oGet19, oGet20, oGet21, oGet22, oGet23, oGet24, oGet25, oGet26, oGet27,oGet28,oGet29, oGet30 , oGet31, oGet32, oGet33, oGet34, oGet35, oGet36, oGet37,oGet38,oGet39, oGet40
	Private cGet8, cGet9,cGet10,cGet11,cGet12, cGet13, cGet14, cGet15, cGet16, cGet17,cGet18,cGet19, cGet20, cGet21, cGet22, cGet23, cGet24, cGet25, cGet26, cGet27,cGet28,cGet29, cGet30 , cGet31, cGet32, cGet33, cGet34, cGet35, cGet36, cGet37,cGet38,cGet39, cGet40     := SPACE(30)
	
	//Private _aSize    := MsAdvSize()
	Private _cRotina  := "RFATC015"
	Private cCadastro := "Consulta de Devolução de Vendas por Cliente"

	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	SA1->(dbGoTop())

	static oDlg
	DEFINE MSDIALOG oDlg TITLE "Consulta de Devolução de Venda por Cliente/Produto"    FROM _aSize[1],_aSize[1] TO _aSize[6],_aSize[5]         COLORS 0, 16777215          PIXEL
@ _aSize[1]+003, _aSize[1]+003 GROUP       oGroup1  TO _aSize[6]*0.5/*272*/, _aSize[5]*0.5/*472*/ PROMPT " CONSULTA "                                      OF oDlg COLOR  0, 16777215          PIXEL

@ _aSize[1]+009, _aSize[1]+345  SAY       oSay3                PROMPT " F11- Busca Por Produto  "     SIZE 300, 020 OF oDlg COLORS 8404992, 16777215          PIXEL
@ _aSize[1]+023, _aSize[1]+010  SAY         oSay1                PROMPT "Cliente:"                          SIZE 020, 007 OF oDlg COLORS 0, 16777215          PIXEL
@ _aSize[1]+019, _aSize[1]+030  MSGET       oGet1                VAR    cGet1     VALID VAZIO() .OR. AtuGe1() F3 "SA1"   SIZE 050, 010 OF oDlg COLORS 0, 16777215          PIXEL
@ _aSize[1]+023, _aSize[1]+085  SAY         oSay2                PROMPT "Loja:"                             SIZE 020, 007 OF oDlg COLORS 0, 16777215          PIXEL
@ _aSize[1]+019, _aSize[1]+105  MSGET       oGet2                VAR    cGet2     VALID VAZIO() .OR. AtuGe1() SIZE 030, 010 OF oDlg COLORS 0, 16777215          PIXEL
@ _aSize[1]+023, _aSize[1]+145  SAY         oSay3                PROMPT "Nome:"                             SIZE 020, 007 OF oDlg COLORS 0, 16777215          PIXEL
@ _aSize[1]+019, _aSize[1]+165 MSGET       oGet3                VAR    cGet3     WHEN .F.                  SIZE 150, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL


@ _aSize[1]+039, _aSize[1]+009 GROUP       oGroup2  TO  _aSize[6]/5.47 , _aSize[5]/6.25 PROMPT  "   CLIENTE   " OF oDlg COLOR  0, 16777215          PIXEL

@ _aSize[1]+050, _aSize[1]+017 SAY    oGet26      VAR     cGet26                      SIZE 250, 010 OF oDlg COLORS 0, 16777215   PIXEL
@ _aSize[1]+067, _aSize[1]+025 SAY      oSay10      PROMPT "Maior Compra:"         SIZE 060, 087 OF oDlg COLORS 0, 16777215  PIXEL
@ _aSize[1]+064, _aSize[1]+083 MSGET    oGet10      VAR     Transform(cGet10, "@E 999,999,999,999.99")                       SIZE 050, 010 OF oDlg COLORS 0, 16777215  READONLY PIXEL
@ _aSize[1]+087, _aSize[1]+025 SAY      oSay11      PROMPT "Media Compra:"           SIZE 060, 087 OF oDlg COLORS 0, 16777215  PIXEL
@ _aSize[1]+083, _aSize[1]+083 MSGET    oGet11      VAR     Transform(cGet11, "@E 999,999,999,999.99")                      SIZE 050, 010 OF oDlg COLORS 0, 16777215  READONLY PIXEL
@ _aSize[1]+107, _aSize[1]+025 SAY      oSay12      PROMPT "Ultima Compra:"    SIZE 060, 087 OF oDlg COLORS 0, 16777215  PIXEL   
@ _aSize[1]+103, _aSize[1]+083 MSGET    oGet12      VAR     cGet12                     SIZE 050, 010 OF oDlg COLORS 0, 16777215 READONLY  PIXEL
@ _aSize[1]+127, _aSize[1]+025 SAY      oSay13      PROMPT "Saldo de Títulos:"             SIZE 060, 087 OF oDlg COLORS 0, 16777215  PIXEL   
@ _aSize[1]+123, _aSize[1]+083 MSGET    oGet13      VAR     Transform(cGet13, "@E 999,999,999,999.99")                      SIZE 050, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
@ _aSize[1]+147, _aSize[1]+025 SAY      oSay14      PROMPT "Titulos Vencidos:"             SIZE 060, 087 OF oDlg COLORS 0, 16777215  PIXEL   
@ _aSize[1]+143, _aSize[1]+083 MSGET    oGet14      VAR     Transform(cGet14, "@E 999,999,999,999.99")                     SIZE 050, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
@ _aSize[1]+067, _aSize[1]+149 SAY      oSay15      PROMPT "Média 12 meses:"         SIZE 060, 087 OF oDlg COLORS 0, 16777215  PIXEL
@ _aSize[1]+063, _aSize[1]+195 MSGET    oGet15      VAR     Transform(cGet15, "@E 999,999,999,999.99")                       SIZE 050, 010 OF oDlg COLORS 0, 16777215  READONLY PIXEL
@ _aSize[1]+087, _aSize[1]+149 SAY      oSay16      PROMPT "Média 24 meses:"           SIZE 060, 087 OF oDlg COLORS 0, 16777215  PIXEL
@ _aSize[1]+083, _aSize[1]+195 MSGET    oGet16      VAR     Transform(cGet16, "@E 999,999,999,999.99")                      SIZE 050, 010 OF oDlg COLORS 0, 16777215  READONLY PIXEL

			 
	 
@ _aSize[1]+039, _aSize[1]+279 GROUP    oGroup3  TO  160 , 547 PROMPT  "   CENTRALIZADOR   " OF oDlg COLOR  0, 16777215          PIXEL
@ _aSize[1]+050, _aSize[1]+286 SAY    oGet27      VAR     cGet27                      SIZE 250, 010 OF oDlg COLORS 0, 16777215   PIXEL

@ _aSize[1]+067, _aSize[1]+299 SAY      oSay18      PROMPT "Maior Compra:"         SIZE 060, 087 OF oDlg COLORS 0, 16777215  PIXEL
@ _aSize[1]+064, _aSize[1]+357 MSGET    oGet18      VAR     Transform(cGet18, "@E 999,999,999,999.99")                       SIZE 050, 010 OF oDlg COLORS 0, 16777215  READONLY PIXEL
@ _aSize[1]+087, _aSize[1]+299 SAY      oSay19      PROMPT "Media Compra:"           SIZE 060, 087 OF oDlg COLORS 0, 16777215  PIXEL
@ _aSize[1]+083, _aSize[1]+357 MSGET    oGet19      VAR     Transform(cGet19, "@E 999,999,999,999.99")                      SIZE 050, 010 OF oDlg COLORS 0, 16777215  READONLY PIXEL
@ _aSize[1]+107, _aSize[1]+299 SAY      oSay20      PROMPT "Ultima Compra:"    SIZE 060, 087 OF oDlg COLORS 0, 16777215  PIXEL   
@ _aSize[1]+103, _aSize[1]+357 MSGET    oGet20      VAR     cGet20                     SIZE 050, 010 OF oDlg COLORS 0, 16777215 READONLY  PIXEL
@ _aSize[1]+127, _aSize[1]+299 SAY      oSay21      PROMPT "Saldo de Títulos:"          SIZE 060, 087 OF oDlg COLORS 0, 16777215  PIXEL   
@ _aSize[1]+123, _aSize[1]+357 MSGET    oGet21      VAR     Transform(cGet21, "@E 999,999,999,999.99")                       SIZE 050, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
@ _aSize[1]+147, _aSize[1]+299 SAY      oSay22      PROMPT "Titulos Vencidos:"             SIZE 060, 087 OF oDlg COLORS 0, 16777215  PIXEL   
@ _aSize[1]+143, _aSize[1]+357 MSGET    oGet22      VAR     Transform(cGet22, "@E 999,999,999,999.99")                     SIZE 050, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
@ _aSize[1]+067, _aSize[1]+423 SAY      oSay23      PROMPT "Média 12 meses:"         SIZE 060, 087 OF oDlg COLORS 0, 16777215  PIXEL
@ _aSize[1]+063, _aSize[1]+469 MSGET    oGet23      VAR     Transform(cGet23, "@E 999,999,999,999.99")                       SIZE 050, 010 OF oDlg COLORS 0, 16777215  READONLY PIXEL
@ _aSize[1]+087, _aSize[1]+423 SAY      oSay24      PROMPT "Média 24 meses:"           SIZE 060, 087 OF oDlg COLORS 0, 16777215  PIXEL
@ _aSize[1]+083, _aSize[1]+469 MSGET    oGet24      VAR     Transform(cGet24, "@E 999,999,999,999.99")                      SIZE 050, 010 OF oDlg COLORS 0, 16777215  READONLY PIXEL

@ _aSize[1]+039, _aSize[1]+560 GROUP    oGroup4  TO  160 , 819 PROMPT   "GRUPO " OF oDlg COLOR  0, 16777215          PIXEL


/*
@ _aSize[1]+041, _aSize[1]+550 GROUP    oGroup4  TO  153 , 537*1.5 PROMPT "  Dados do Grupo   "  OF oDlg COLOR  0, 16777215          PIXEL
@ _aSize[1]+057, _aSize[1]+570 SAY      oSay25      PROMPT "Maior Compra:"         SIZE 060, 087 OF oDlg COLORS 0, 16777215  PIXEL
@ _aSize[1]+054, _aSize[1]+628 MSGET    oGet25      VAR     Transform(cGet25, "@E 999,999,999,999.99")                       SIZE 050, 010 OF oDlg COLORS 0, 16777215  READONLY PIXEL
@ _aSize[1]+077, _aSize[1]+570 SAY      oSay26      PROMPT "Media Compra:"           SIZE 060, 087 OF oDlg COLORS 0, 16777215  PIXEL
@ _aSize[1]+073, _aSize[1]+628 MSGET    oGet26      VAR     Transform(cGet26, "@E 999,999,999,999.99")                      SIZE 050, 010 OF oDlg COLORS 0, 16777215  READONLY PIXEL
@ _aSize[1]+097, _aSize[1]+570 SAY      oSay27      PROMPT "Media Faturamento:"    SIZE 060, 087 OF oDlg COLORS 0, 16777215  PIXEL   
@ _aSize[1]+093, _aSize[1]+628 MSGET    oGet27      VAR     Transform(cGet27, "@E 999,999,999,999.99")                      SIZE 050, 010 OF oDlg COLORS 0, 16777215 READONLY  PIXEL
@ _aSize[1]+117, _aSize[1]+570 SAY      oSay28     PROMPT "Ultima Compra:"             SIZE 060, 087 OF oDlg COLORS 0, 16777215  PIXEL   
@ _aSize[1]+113, _aSize[1]+628 MSGET    oGet28      VAR     cGet28                    SIZE 050, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
@ _aSize[1]+137, _aSize[1]+570 SAY      oSay29      PROMPT "Duplicatas em Aberto:"             SIZE 060, 087 OF oDlg COLORS 0, 16777215  PIXEL   
@ _aSize[1]+133, _aSize[1]+628 MSGET    oGet29      VAR     Transform(cGet29 , "@E 999,999,999,999.99")                      SIZE 050, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
@ _aSize[1]+057, _aSize[1]+694 SAY      oSay30      PROMPT "Média 12 meses:"         SIZE 060, 087 OF oDlg COLORS 0, 16777215  PIXEL
@ _aSize[1]+053, _aSize[1]+740 MSGET    oGet30      VAR     Transform(cGet30, "@E 999,999,999,999.99")                       SIZE 050, 010 OF oDlg COLORS 0, 16777215  READONLY PIXEL
@ _aSize[1]+077, _aSize[1]+694 SAY      oSay31      PROMPT "Média 24 meses:"           SIZE 060, 087 OF oDlg COLORS 0, 16777215  PIXEL
@ _aSize[1]+073, _aSize[1]+740 MSGET    oGet31      VAR     Transform(cGet31, "@E 999,999,999,999.99")                      SIZE 050, 010 OF oDlg COLORS 0, 16777215  READONLY PIXEL
*/
	  //  @ _aSize[1]+173, _aSize[1]+110  SAY    oSay25                PROMPT "   NOTA .:"     SIZE 300, 020 OF oDlg COLORS 0, 16777215          PIXEL
	 //   @ _aSize[1]+173, _aSize[1]+133  SAY    oGet25                var  cGet25             SIZE 040, 010 OF oDlg COLORS 0, 16777215          PIXEL


	  //  @ _aSize[1]+173, _aSize[1]+169  SAY    oSay5                PROMPT "   Total Devolvido.:"     SIZE 300, 020 OF oDlg COLORS 0, 16777215          PIXEL
	  //  @ _aSize[1]+173, _aSize[1]+209  SAY    oGet5                var  Transform(cGet5 , "@E 999,999,999,999.99")            SIZE 040, 010 OF oDlg COLORS 0, 16777215          PIXEL
 
	  	@ _aSize[1]+173, _aSize[1]+110  SAY    oGet5                PROMPT cGet5     SIZE 300, 020 OF oDlg COLORS 0, 16777215          PIXEL
 	    @ _aSize[1]+017, (_aSize[5]*0.5)-045  BUTTON oButton1      PROMPT "&Sair"    ACTION Close(oDlg)        SIZE 037, 012 OF oDlg                             PIXEL

 
	    fMSNewGe1()  
	    SetKey(VK_F11,{|| })
	    SetKey(VK_F11,{ || PesqPrd()  } )
	    
	    if !Empty(cGet1) .AND. !Empty(cGet2)
			AtuGe1()
		endif
	ACTIVATE MSDIALOG oDlg CENTERED

	RestArea(_aSavArea)
return
/*/{Protheus.doc} fMSNewGe1
@description Sub-rotina de Montagem da GetDados 1 da rotina RFATC011.
@author Livia Della Corte (ALL System Solutions)
@since 16/12/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function fMSNewGe1()
	local   nX
	local   aColsEx      := {}
	local   aHeaderEx    := {}
	local   aFieldFill   := {}
	local   aAlterFields := {}
	local   _cAliasSX3   := "SX3_"+GetNextAlias()

	static oMSNewGe1

		OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)		//OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.T.,,.F.,.F.)
		if Select(_cAliasSX3) > 0
			dbSelectArea(_cAliasSX3)
			(_cAliasSX3)->(dbSetOrder(2))
			for nX := 1 to len(aFields1)
				if (_cAliasSX3)->(MsSeek(aFields1[nX],.T.,.F.))
					Aadd(aHeaderEx, {AllTrim((_cAliasSX3)->X3_TITULO),(_cAliasSX3)->X3_CAMPO,(_cAliasSX3)->X3_PICTURE,(_cAliasSX3)->X3_TAMANHO,(_cAliasSX3)->X3_DECIMAL,(_cAliasSX3)->X3_VALID,;
										(_cAliasSX3)->X3_USADO,(_cAliasSX3)->X3_TIPO,(_cAliasSX3)->X3_F3,(_cAliasSX3)->X3_CONTEXT,(_cAliasSX3)->X3_CBOX,(_cAliasSX3)->X3_RELACAO})
					if AllTrim((_cAliasSX3)->X3_CAMPO) == "D1_DOC"
						Aadd(aFieldFill, Space(06)             )
					else
						Aadd(aFieldFill, CriaVar((_cAliasSX3)->X3_CAMPO))
					endif
				endif
			next nX
			Aadd(aFieldFill, .F.)
			Aadd(aColsEx, aFieldFill)
			aAux1     := aClone(aColsEx)
			oMSNewGe1 := MsNewGetDados():New( _aSize[7]+190, _aSize[2]-019, (_aSize[6]*0.50)-020, ((_aSize[5]-010)*0.075)-(_aSize[2]-012), /*GD_UPDATE*/, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 9999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
			oMSNewGe1:bChange := {|| AtuGe2() }
		endif
		(_cAliasSX3)->(dbCloseArea())
return
/*/{Protheus.doc} fMSNewGe2
@description Sub-rotina de Montagem da GetDados 2 da rotina RFATC011.
@author Livia Della Corte (ALL System Solutions)
@since 16/12/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function fMSNewGe2()
	local   nX
	local   aColsEx      := {}
	local   aHeaderEx    := {}
	local   aFieldFill   := {}
	local   aAlterFields := {}
	local   _cAliasSX3   := "SX3_"+GetNextAlias()

	static oMSNewGe2
		OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)		//OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.T.,,.F.,.F.)
		if Select(_cAliasSX3) > 0
			dbSelectArea(_cAliasSX3)
			(_cAliasSX3)->(dbSetOrder(2))
			For nX := 1 To Len(aFields2)
				if (_cAliasSX3)->(MsSeek(aFields2[nX],.T.,.F.))
					Aadd(aHeaderEx, {AllTrim((_cAliasSX3)->X3_TITULO),(_cAliasSX3)->X3_CAMPO,(_cAliasSX3)->X3_PICTURE,(_cAliasSX3)->X3_TAMANHO,(_cAliasSX3)->X3_DECIMAL,(_cAliasSX3)->X3_VALID,;
										(_cAliasSX3)->X3_USADO,(_cAliasSX3)->X3_TIPO,(_cAliasSX3)->X3_F3,(_cAliasSX3)->X3_CONTEXT,(_cAliasSX3)->X3_CBOX,(_cAliasSX3)->X3_RELACAO})
					Aadd(aFieldFill, CriaVar((_cAliasSX3)->X3_CAMPO))
				endif
			next nX
			Aadd(aFieldFill, .F.)
			Aadd(aColsEx, aFieldFill)
			aAux2     := aClone(aColsEx)
			oMSNewGe2 := MsNewGetDados():New( _aSize[7]+190, ((_aSize[5]-0010)*0.075)-(_aSize[2]-012)+002, (_aSize[6]*0.50)-020, (_aSize[5]*0.50)-002, /*GD_INSERT+GD_DELETE+GD_UPDATE*/, "AllwaysTrue", "AllwaysTrue", "+ZA_ITEM", aAlterFields,, 9999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
		endif
		(_cAliasSX3)->(dbCloseArea())
return
/*/{Protheus.doc} AtuGe1
@description Sub-rotina responsavel por atualizar o GetDados 1.
@author Livia Della Corte (ALL System Solutions)
@since 16/12/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function AtuGe1()
	local   _lRet := !Empty(cGet1)
	local 	cQry:= ""
	local   _cTRTMP1  := GetNextAlias()
	local   _cTRTMP2  := GetNextAlias()
	if _lRet
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		if empty(cGet2)
			//Set SoftSeek ON
			SA1->(MsSeek(xFilial("SA1") + cGet1,.F.,.F.))
			//Set SoftSeek OFF
			cGet2     := SA1->A1_LOJA
		else
			SA1->(MsSeek(xFilial("SA1") + cGet1 + cGet2,.F.,.F.))
		endif
		//_lRet   := ExistCpo("SA1",cGet1+cGet2,1) // Comentado por Arthur Silva devido a problemas aprensentado no retorno da função.
		if _lRet .AND. SA1->(Found())
			 cGet3  := SA1->A1_NOME
			 cGet10 := SA1->A1_MCOMPRA    			 
			 cGet11 := SA1->A1_MEDCOMP
			 cGet12 := SA1->A1_ULTCOM 
			 cGet13 := SA1->A1_SALDUP
			 cGet14 := SA1->A1_ATR
			 cGet15 := SA1->A1_MEDFATR 
			 cGet16 := SA1->A1_MEDFATA 	 
			 cGet26:= 	SA1->A1_COD +" / " +	SA1->A1_LOJA +"  -  " +	ALLTRIM(SA1->A1_NOME) + "  -  CNPJ: " + 	ALLTRIM(SA1->A1_CGC) 
			cGet28:= SA1->A1_CGCCENT 
				AtuGet1()
				AtuGet2()
				AtuGet3()
				AtuGet4(cGet28)

		else
			//cGet1 := Space(TamSx3("A1_COD" )[01])
			cGet2 := Space(TamSx3("A1_LOJA")[01])
			cGet3 := Space(TamSx3("A1_NOME")[01])
		endif
	else
		cGet1 := Space(TamSx3("A1_COD" )[01])
		cGet2 := Space(TamSx3("A1_LOJA")[01])
		cGet3 := Space(TamSx3("A1_NOME")[01])
	endif
return _lRet
/*/{Protheus.doc} AtuGet1
@description Sub-rotina de atualização do Get Dados 1.
@author Livia Della Corte (ALL System Solutions)
@since 16/12/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function AtuGet1()
	local   _x        := 0
	local   nSD1      := 0
	local   _cTR1TMP  := GetNextAlias()
	local   cQry      := ""
	oMSNewGe1:aCols   := {}

	dbSelectArea("SD1")
	SD1->(dbSetOrder(1))
	SD1->(dbGoTop())
	aStruSD1 := SD1->(dbStruct())

	cQry := " SELECT "
	for _x := 1 to len(aFields1)
		if _x > 1
			cQry += ", "
		endif
		cQry += aFields1[_x]
	next
	cQry += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) "                                                 + _clrf
	cQry += "  INNER JOIN " + RetSqlName("SA1") + " SA1 (NOLOCK) ON SA1.A1_FILIAL  = '"+xFilial("SA1")+"' " + _clrf
	cQry += "                                                   AND SA1.A1_COD     = SD1.D1_FORNECE "       + _clrf
	cQry += "                                                   AND SA1.A1_LOJA    = SD1.D1_LOJA "       + _clrf
	cQry += "                                                   AND SA1.D_E_L_E_T_ = '' "                   + _clrf
	cQry += "  INNER JOIN " + RetSqlName("SD2") + " SD2 (NOLOCK) ON SD2.D2_FILIAL  = SD1.D1_FILIAL "        + _clrf
	cQry += "                                                   AND SD2.D2_DOC     = SD1.D1_NFORI "         + _clrf
	cQry += "                                                   AND SD2.D2_SERIE    = SD1.D1_SERIORI "        + _clrf
	cQry += "                                                   AND SD2.D2_COD     = SD1.D1_COD "           + _clrf
	cQry += "                                                   AND SD2.D_E_L_E_T_ = '' "                   + _clrf
	cQry += " WHERE SD1.D1_FILIAL  = '" + xFilial("SD1") + "' " + _clrf
	cQry += "   AND SD1.D1_FORNECE = '" + cGet1          + "' " + _clrf
	cQry += "   AND SD1.D1_LOJA = '" + cGet2          + "' " + _clrf
	cQry += "   AND SD1.D1_TIPO  IN  ('D','B') "                + _clrf
	if !empty(cGet4)
		if _lSeekApr
			cQry += "                                           AND SD1.D1_COD LIKE '" + AllTrim(cGet4) + "%' " + _clrf
		else
			cQry += "                                           AND SD1.D1_COD    = '" + cGet4          + "'  " + _clrf
		endif
	endif	
	cQry += "   AND SD1.D_E_L_E_T_ = '' "                       + _clrf
	cQry += " GROUP BY D1_EMISSAO, D1_DOC "                     + _clrf
	cQry += " ORDER BY D1_EMISSAO DESC, D1_DOC DESC "           + _clrf
	if Select(_cTR1TMP) > 0
		(_cTR1TMP)->(dbCloseArea())
	endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),_cTR1TMP,.T.,.F.)
	for nSD1 := 1 To Len(aStruSD1)
		if aStruSD1[nSD1][2] <> "C" .AND.  FieldPos(aStruSD1[nSD1][1]) > 0
			TcSetField(_cTR1TMP,aStruSD1[nSD1][1],aStruSD1[nSD1][2],aStruSD1[nSD1][3],aStruSD1[nSD1][4])
		endif
	next nSD1
	dbSelectArea(_cTR1TMP)
	(_cTR1TMP)->(dbGoTop())
	While !(_cTR1TMP)->(EOF())
		_aCpos1 := {}
		for _x  := 1 To Len(aFields1)
			AADD(_aCpos1,&(_cTR1TMP+"->"+aFields1[_x]))
		next
		AADD(_aCpos1,.F.)
		AADD(oMSNewGe1:aCols,_aCpos1)
		(_cTR1TMP)->(dbSkip())
	enddo
	if Select(_cTR1TMP) > 0
		(_cTR1TMP)->(dbCloseArea())
	endif
	if empty(oMSNewGe1:aCols)
		oMSNewGe1:aCols := aClone(aAux1)
	endif
	oMSNewGe1:Refresh()
return .T.
/*/{Protheus.doc} AtuGe2
@description Sub-rotina responsavel por atualizar o GetDados 2.
@author Livia Della Corte (ALL System Solutions)
@since 16/12/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function AtuGe2()
	AtuGet2()
	AtuGet3()
	//AtuGet4()
return .T.
/*/{Protheus.doc} AtuGet2
@description Sub-rotina de atualização do Get Dados 2.
@author Livia Della Corte (ALL System Solutions)
@since 16/12/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function AtuGet2()
	local   _x        := 0
	local   nSD1      := 0
	local   nSD2      := 0
	local   _cTR2TMP  := GetNextAlias()
	local   cQry      := ""
	Local   nItem 	  := 1
	private cPrdAnt := ""
	cQry := " SELECT "
	for _x := 1 To Len(aFields2)
		if _x > 1
			cQry += ", "
		endif
		cQry += aFields2[_x]
	next
	cQry += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) "                                                               + _clrf
	cQry += "  INNER JOIN " + RetSqlName("SD2") + " SD2 (NOLOCK) ON SD2.D2_FILIAL  = SD1.D1_FILIAL "        + _clrf
	cQry += "                                                   AND SD2.D2_DOC     = SD1.D1_NFORI "         + _clrf
	cQry += "                                                   AND SD2.D2_SERIE    = SD1.D1_SERIORI "        + _clrf
	cQry += "                                                   AND SD2.D2_COD     = SD1.D1_COD "           + _clrf
	cQry += "                                                   AND SD2.D_E_L_E_T_ = '' "                   + _clrf
		cQry += "  INNER JOIN " + RetSqlName("SE1") + " SE1 (NOLOCK) ON SD2.D2_FILIAL  = SE1.E1_FILIAL "        + _clrf
	cQry += "                                                   AND SD2.D2_DOC      = SE1.E1_NUM "         + _clrf
	cQry += "                                                   AND SD2.D2_SERIE    = SE1.E1_PREFIXO "       + _clrf
	cQry += "                                                   AND  SE1.E1_TIPO = 'NF'              "       + _clrf	
	cQry += "                                                   AND SD2.D_E_L_E_T_ = '' "                 + _clrf
		cQry += "  INNER JOIN " + RetSqlName("SC6") + " SC6 (NOLOCK) ON SD2.D2_FILIAL  = SC6.C6_FILIAL "        + _clrf
	cQry += "                                                   AND SD2.D2_PEDIDO     = SC6.C6_NUM "         + _clrf
	cQry += "                                                   AND SD2.D2_COD    = SC6.C6_PRODUTO "       + _clrf	
	cQry += "                                                   AND SC6.D_E_L_E_T_ = '' "                 + _clrf

	cQry += " WHERE SD1.D1_FILIAL  = '" + xFilial("SD1") + "' "                                                           + _clrf
	cQry += "   AND SD1.D1_DOC     = '" + oMSNewGe1:aCols[oMSNewGe1:nAT,aScan(aFields1,{|x|AllTrim(x)=="D1_DOC"})] + "' " + _clrf
	cQry += "   AND SD1.D1_FORNECE = '" + cGet1          + "' " + _clrf
	cQry += "   AND SD1.D1_LOJA = '" + cGet2          + "' " + _clrf
	if !empty(cGet4)
		if _lSeekApr
			cQry += "   AND SD1.D1_PRODUTO LIKE '" + AllTrim(cGet4) + "%' "   + _clrf
		else
			cQry += "   AND SD1.D1_PRODUTO    = '" + cGet4          + "'  "   + _clrf
		endif
	endif
	cQry += "   AND SD1.D_E_L_E_T_ = '' "                                                                                 + _clrf
	cQry += "ORDER BY D2_EMISSAO DESC, D2_DOC DESC, D2_ITEM ASC, E1_PARCELA asc " + _clrf	
	if Select(_cTR2TMP) > 0
		(_cTR2TMP)->(dbCloseArea())
	endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),_cTR2TMP,.T.,.F.)
	dbSelectArea(_cTR2TMP)
	(_cTR2TMP)->(dbGoTop())

	if !(_cTR2TMP)->(EOF())
		oTree := DbTree():New( _aSize[7]+190,((_aSize[5]-0010)*0.075)-(_aSize[2]-012)+002 ,(_aSize[6]*0.50)-020,(_aSize[5]*0.50)-002 ,oDlg,/*{|| TreeChange()}*/,,.T.)  
		oTree:BeginUpdate()
		oTree:SetScroll(1,.T.)
		while !(_cTR2TMP)->(EOF())
		If  ALLTRIM((_cTR2TMP)->D1_COD) <>   cPrdAnt
	    	oTree:AddItem("Produto:  " + ALLTRIM((_cTR2TMP)->D1_COD) + "  -  " + ALLTRIM((_cTR2TMP)->D1_DESCR) + "   Qtd Devolvida: " + cValtoChar((_cTR2TMP)->D2_QTDEDEV) , ALLTRIM((_cTR2TMP)->D1_COD) , "FOLDER10" ,,,,1)    
		   	If oTree:TreeSeek(ALLTRIM((_cTR2TMP)->D1_COD))
  				oTree:AddItem("Pedido:  " + ALLTRIM((_cTR2TMP)->D2_PEDIDO) +  " Emissão " +  DTOC(STOD((_cTR2TMP)->C6_EMISSAO))  + " Qtd:" + cValtoChar((_cTR2TMP)->C6_QTDENT) ,ALLTRIM((_cTR2TMP)->D2_PEDIDO), "FINANCEIRO",,,,2) 					 				
		    	oTree:AddItem("Nota de Saída:  " + ALLTRIM((_cTR2TMP)->D1_NFORI) + "/" + (_cTR2TMP)->D1_SERIORI + "   Emissão: " + DTOC(STOD((_cTR2TMP)->D2_EMISSAO)) + "   Qtd Original: " + cValtoChar((_cTR2TMP)->D2_QUANT)  ,ALLTRIM((_cTR2TMP)->D1_COD), "FINANCEIRO",,,,3)	     	    			  		
		    	oTree:AddItem("Títulos:    " ,ALLTRIM((_cTR2TMP)->E1_PARCELA), "PARCELA",,,,3)
		    	oTree:AddItem("Parcela " +  ALLTRIM((_cTR2TMP)->E1_PARCELA) +   " -  Vencimento "+  DTOC(STOD((_cTR2TMP)->E1_VENCTO)) + IIF((_cTR2TMP)->E1_SALDO>0," Em aberto:  R$" + ALLTRIM((_cTR2TMP)->E1_SALDO), " - PAGO" ),ALLTRIM((_cTR2TMP)->E1_PARCELA), "PARCELA",,,,4)   				   			  
			Endif	   	
	   	Else
		   	oTree:AddItem("Parcela " +  ALLTRIM((_cTR2TMP)->E1_PARCELA) +   " -  Vencimento "+  DTOC(STOD((_cTR2TMP)->E1_VENCTO)) + IIF((_cTR2TMP)->E1_SALDO>0," Em aberto:  R$" + ALLTRIM((_cTR2TMP)->E1_SALDO), " - PAGO"  ),ALLTRIM((_cTR2TMP)->E1_PARCELA), "PARCELA",,,,4)   				   			  
	   	EndIf
 	   		cPrdAnt :=  ALLTRIM((_cTR2TMP)->D1_COD)
 	   		(_cTR2TMP)->(dbSkip())   
		enddo
		oTree:EndUpdate()
	Endif

	AtuGet3()
	oGet5:Refresh()
	

return .T.


/*/{Protheus.doc} OpenPV
@description Sub-rotina utilizada para abrir o pedido de vendas posicionado.
@author Livia Della Corte (ALL System Solutions)
@since 19/12/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function OpenPV()
	local _aSvAr   := GetArea()
	local _aSvArC5 := SC5->(GetArea())
	local _cPedVen := ""

	if ValType(oMSNewGe1:aCols)=="A"
		_cPedVen := oMSNewGe1:aCols[oMSNewGe1:nAT,aScan(aFields1,{|x|AllTrim(x)=="C5_NUM"})]
		if !empty(_cPedVen)
			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))
			if SC5->(MsSeek(xFilial("SC5") + _cPedVen,.T.,.F.))
				aRotina2  := {	{ "Incluir"			,"A410Barra"	,0,3},;
								{ "Alterar"			,"A410Barra"	,0,4}}
								
				aRotina3  := {	{ "Excluir"			,"A410Deleta"	,0,5,21,NIL},;
								{ "Residuo"			,"Ma410Resid"	,0,2, 0,NIL}}
								
				aRotina   := {	{ "Pesquisar"		,"AxPesqui"		,0,1,0 ,.F.},;
								{ "Visualizar"		,"A410Visual"	,0,2,0 ,NIL},;
								{ "Legenda"			,"A410Legend"	,0,3,0 ,.F.},;
								{ "Cliente"			,"U_RFATE031"	,0,6,0 ,NIL},;
								{ "Conhecimento"	,"MsDocument"	,0,4,0 ,NIL} }
				if ExistBlock("MA410MNU")
					U_MA410MNU()
				endif
			    SetKey(VK_F7 , { ||  } )
			    SetKey(VK_F8 , { ||  } )
			    SetKey(VK_F12, { ||  } )
				_lInclui := INCLUI
				_lAltera := ALTERA
				A410Visual("SC5",SC5->(Recno()),2)
				INCLUI   := _lInclui
				ALTERA   := _lAltera
			    SetKey(VK_F7 , { || OpenPV() } )
			    SetKey(VK_F8 , { || AltCli() } )
			    SetKey(VK_F12, { || Reord()  } )
			else
				MsgAlert("Pedido " + _cPedVen + " não encontrado!",_cRotina+"_001")
			endif
		endif
	endif
	RestArea(_aSvArC5)
	RestArea(_aSvAr)
return
/*/{Protheus.doc} Reord
@description Sub-rotina utilizada para reordenar grid 2 (itens).
@author Livia Della Corte (ALL System Solutions)
@since 19/12/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function Reord()
	local oGrp1
	local oCboBo1
	local oSBut1
	local _aSvAr    := GetArea()
	local _aItens   := {}
	local _j        := 0

	if len(oMSNewGe2:aHeader) > 0 .AND. len(oMSNewGe2:aCols) > 0
		for _j := 1 to len(oMSNewGe2:aHeader)
			AADD(_aItens,oMSNewGe2:aHeader[_j][01])
		next
		//Forço a primeira ordenação por produto
		if (_nColPrd := aScan(oMSNewGe2:aHeader,{|x| AllTrim(x[02])=="C6_PRODUTO"})) > 0
			_nOrd := _nColPrd
		endif
		static oDlg2
		DEFINE MSDIALOG oDlg2 TITLE " Reordenação dos Registros (itens) " FROM 000, 000  TO 150, 350 COLORS 0, 16777215 PIXEL
			@ 007, 004 GROUP      oGrp1   TO 059, 171 OF oDlg2 COLOR 0, 16777215 PIXEL
			@ 023, 010 MSCOMBOBOX oCboBo1 VAR _nOrd ITEMS _aItens SIZE 156, 010 OF oDlg2 COLORS 0, 16777215 PIXEL
			DEFINE SBUTTON oSBut1 FROM 041, 137 TYPE 01 OF oDlg2 ENABLE ACTION Close(oDlg2)
		ACTIVATE MSDIALOG oDlg2 CENTERED
		if ValType(_nOrd) == "C"
			_nOrd := aScan(_aItens,_nOrd)
		endif
		oMSNewGe2:aCols := aSort( oMSNewGe2:aCols, , , { |x,y| x[_nOrd] < y[_nOrd] } )
		oMSNewGe2:oBrowse:Refresh()
	endif
	RestArea(_aSvAr)
return
/*/{Protheus.doc} AltCli
@description Sub-rotina utilizada para alterar o cliente selecionado.
@author Livia Della Corte (ALL System Solutions)
@since 22/05/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function AltCli()
	local _aSvAr := GetArea()
	if !empty(cGet1) .AND. !Empty(cGet2)
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		if SA1->(MsSeek(xFilial("SA1") + cGet1 + cGet2,.T.,.F.))
		    SetKey(VK_F7 , { ||  } )
		    SetKey(VK_F8 , { ||  } )
		    SetKey(VK_F12, { ||  } )
	   	    AROTAUTO  := NIL
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			A030Altera("SA1",SA1->(RECNO()),4)
		    SetKey(VK_F7 , { || OpenPV() } )
		    SetKey(VK_F8 , { || AltCli() } )
		    SetKey(VK_F12, { || Reord()  } )
		endif
	endif
	RestArea(_aSvAr)
return
/*/{Protheus.doc} AtuGet3
@description Sub-rotina de atualização do Get Dados 5.
@author  (ALL System Solutions)
@since 16/12/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function AtuGet3()
	//////////////////////////////////////////
	//DEVERÁ HAVER O SAVAREA x RESTAREA?????//
	//////////////////////////////////////////
	local   _cATR3TMP := GetNextAlias()
	local   aStruSD1  := {}
	local   _cDE      := oMSNewGe1:aCols[oMSNewGe1:nAT,aScan(aFields1,{|x|AllTrim(x)=="D1_DOC"})]
	dbSelectArea("SD1")
	SD1->(dbSetOrder(1))
	SD1->(dbGoTop())
	aStruSD1 := SD1->(dbStruct())
	BeginSql Alias _cATR3TMP
		SELECT SUM(SD1.D1_TOTAL) D1_TOTAL
		FROM %table:SD1% SD1 (NOLOCK)

		WHERE SD1.D1_FILIAL  = %xFilial:SD1%
		  AND SD1.D1_DOC     = %Exp:_cDE%			//Total do DOC DE DEVOLUCAO
		  AND SD1.%NotDel%
	EndSql
	dbSelectArea(_cATR3TMP)
	(_cATR3TMP)->(dbGoTop())
	if !(_cATR3TMP)->(EOF())
		while !(_cATR3TMP)->(EOF())
			cGet25 :=_cDE
			cGet5  :=  "Nota => "+ _cDE + "         Total Devolvido.: R$ " +Transform(ROUND((_cATR3TMP)->D1_TOTAL, TamSx3("D1_TOTAL")[02]) , "@E 999,999,999,999.99") 
			(_cATR3TMP)->(dbSkip())
		enddo
	endif
	if Select(_cATR3TMP) > 0
		dbSelectArea(_cATR3TMP)
		(_cATR3TMP)->(dbCloseArea())
	endif
	oMSNewGe1:oBrowse:Refresh()
//	oMSNewGe2:oBrowse:Refresh()
return cGet5
/*/{Protheus.doc} PesqPrd
@description Sub-rotina de pesquisa por Produto.
@author  (ALL System Solutions)
@since 19/12/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function PesqPrd()
	local oGrp2
	local oSBut2
//	local _aItens   := {}
//	local _aSvAr    := GetArea()
	private oSay6
	private oGet6
	private cGet6 := Space(len(SB1->B1_COD))

	_lSeekApr     := .F.

	static oDlg3
	DEFINE MSDIALOG oDlg3 TITLE " Pesquisa Por Produto " FROM 000, 000  TO 150, 350 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME
		oDlg3:lEscClose := .F.
		@ 007, 004 GROUP  oGrp2                                         TO 059, 171                                      OF oDlg3 COLOR  0, 16777215 PIXEL
		@ 023, 010 SAY    oSay6   PROMPT "Produto: "                                                       SIZE 020, 007 OF oDlg3 COLORS 0, 16777215 PIXEL
		@ 023, 050 MSGET  oGet6   VAR    cGet6    F3 "SB1" /*VALID (VAZIO() .OR. ExistCpo("SB1",cGet6))*/  SIZE 080, 010 OF oDlg3 COLORS 0, 16777215 PIXEL
		DEFINE SBUTTON oSBut2 FROM 041, 137 TYPE 01 OF oDlg3 ENABLE ACTION IIF(valtype(oDlg3)=="O",Close(oDlg3),nil)
	ACTIVATE MSDIALOG oDlg3 CENTERED
	if !empty(cGet6)
		dbselectArea("SB1")
		SB1->(dbSetOrder(1))
		if !SB1->(MsSeek(xFilial("SB1") + cGet6,.T.,.F.))
			SB1->(MsSeek(xFilial("SB1") + AllTrim(cGet6),.F.,.F.))	//Busca aproximada
			_lSeekApr := .T.
		endif
	endif
	if !empty(cGet6) .AND. SubStr(SB1->B1_COD,1,len(AllTrim(cGet6))) == AllTrim(cGet6)
		cDescSB1 := SB1->B1_DESC
		cSay4    := "Produto: "
		oSay4:Refresh()
		cGet4    := cGet6
		oGet4:Refresh()
		if _lSeekApr
			cGet7    :=  " - PRODUTOS INICIADOS COM ESTE CÓDIGO"
			oGet7:Refresh()
		else
			cGet7    :=  " - " + cDescSB1
			oGet7:Refresh()
		endif
	else
		cSay4 := SPACE(len(SB1->B1_COD ))
		oSay4:Refresh()
		cGet4 := SPACE(len(SB1->B1_COD ))
		oGet4:Refresh()
		cGet7 := SPACE(len(SB1->B1_DESC))
		oGet7:Refresh()
	endif
	atuGet1()
	atuGet2()
	atuGet3()
return .T.                    
     
 static function fMSNewGe3()
	local   nX
	local   aColsEx      := {}
	local   aHeaderEx    := {}
	local   aFieldFill   := {}
	local   aAlterFields := {}
	local   _cAliasSX3   := "SX3_"+GetNextAlias()

	static oMSNewGe3
		OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)		//OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.T.,,.F.,.F.)
		if Select(_cAliasSX3) > 0
			dbSelectArea(_cAliasSX3)
			(_cAliasSX3)->(dbSetOrder(2))
			For nX := 1 To Len(aFields2)
				if (_cAliasSX3)->(MsSeek(aFields2[nX],.T.,.F.))
					Aadd(aHeaderEx, {AllTrim((_cAliasSX3)->X3_TITULO),(_cAliasSX3)->X3_CAMPO,(_cAliasSX3)->X3_PICTURE,(_cAliasSX3)->X3_TAMANHO,(_cAliasSX3)->X3_DECIMAL,(_cAliasSX3)->X3_VALID,;
										(_cAliasSX3)->X3_USADO,(_cAliasSX3)->X3_TIPO,(_cAliasSX3)->X3_F3,(_cAliasSX3)->X3_CONTEXT,(_cAliasSX3)->X3_CBOX,(_cAliasSX3)->X3_RELACAO})
					Aadd(aFieldFill, CriaVar((_cAliasSX3)->X3_CAMPO))
				endif
			next nX
			Aadd(aFieldFill, .F.)
			Aadd(aColsEx, aFieldFill)
			aAux2     := aClone(aColsEx)
			oMSNewGe3 := MsNewGetDados():New( _aSize[7]+040, ((_aSize[5]-0010)*0.075)-(_aSize[2]-012)+002, (_aSize[6]*0.50)-020, (_aSize[5]*0.50)-002, /*GD_INSERT+GD_DELETE+GD_UPDATE*/, "AllwaysTrue", "AllwaysTrue", "+ZA_ITEM", aAlterFields,, 9999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
		endif
		(_cAliasSX3)->(dbCloseArea())
return
 
 
static function ATUGET4(_cCentral)
local   _lRet := !Empty(cGet1)
local 	cQry:= ""
local   _cTRTMP1  := GetNextAlias()
local   cCliAnt:= ""
local   _cTRTMP3  := GetNextAlias()

 cQry += " Select	top 1 A1_NOME, A1_COD, A1_LOJA, A1_CGC, A1_ULTCOM,  SUM(A1_MCOMPRA) A1_MCOMPRA ,  SUM(A1_MEDCOMP) A1_MEDCOMP " + _clrf
 cQry +=  " ,  SUM(A1_MEDFATR) A1_MEDFATR,  SUM(A1_ATR) A1_ATR,  SUM(A1_MEDFATA) A1_MEDFATA, SUM(A1_SALDUP) A1_SALDUP " + _clrf
 cQry += "	FROM " + RetSqlName("SA1") + " SA1 (NOLOCK) " + _clrf
 cQry += " WHERE SA1.A1_CGC  = '" + _cCentral + "' " + _clrf
 cQry += " GROUP BY A1_NOME, A1_COD, A1_LOJA, A1_CGC, A1_ULTCOM"
 cQry += " Order BY A1_COD, A1_LOJA, A1_CGC"
 
 if Select(_cTRTMP1) > 0
 		(_cTRTMP1)->(dbCloseArea())
 endif
 dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),_cTRTMP1,.T.,.F.)
 	dbSelectArea(_cTRTMP1)
 	(_cTRTMP1)->(dbGoTop())
	 cGet17 := "   Centralizador: " +  (_cTRTMP1)->A1_NOME
	 cGet18 := (_cTRTMP1)->A1_MCOMPRA    			 
	 cGet19 := (_cTRTMP1)->A1_MEDCOMP
	 cGet20 := stod((_cTRTMP1)->A1_ULTCOM)  
	 cGet21 := (_cTRTMP1)->A1_SALDUP
	 cGet22 := (_cTRTMP1)->A1_ATR
	 cGet23 := (_cTRTMP1)->A1_MEDFATR 
	 cGet24 := (_cTRTMP1)->A1_MEDFATA 
	 cGet27 := (_cTRTMP1)->A1_COD +" / " + (_cTRTMP1)->A1_LOJA +"  -  " + ALLTRIM((_cTRTMP1)->A1_NOME) + "  -  CNPJ: " + ALLTRIM((_cTRTMP1)->A1_CGC)
	 
	 	 
 if Select(_cTRTMP1) > 0
 	(_cTRTMP1)->(dbCloseArea())
 endif
 if Select(_cTRTMP3) > 0
 	(_cTRTMP3)->(dbCloseArea())
 endif
 cQry:= ""
 cQry += " Select	  A1_NOME, A1_COD, A1_LOJA, A1_CGC, A1_ULTCOM,  SUM(A1_MCOMPRA) A1_MCOMPRA ,  SUM(A1_MEDCOMP) A1_MEDCOMP " + _clrf
 cQry +=  " ,  SUM(A1_MEDFATR) A1_MEDFATR,  SUM(A1_ATR) A1_ATR,  SUM(A1_MEDFATA) A1_MEDFATA, SUM(A1_SALDUP) A1_SALDUP " + _clrf
 cQry += "	FROM " + RetSqlName("SA1") + " SA1 (NOLOCK) " + _clrf
 cQry += " WHERE SA1.A1_CGCCENT  = '" + _cCentral + "' " + _clrf
 cQry += " GROUP BY A1_NOME, A1_COD, A1_LOJA, A1_CGC, A1_ULTCOM"
 cQry += " order BY  A1_COD, A1_LOJA, A1_CGC"
 if Select(_cTRTMP3) > 0
 		(_cTRTMP3)->(dbCloseArea())
 endif
 dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),_cTRTMP3,.T.,.F.)
 dbSelectArea(_cTRTMP3)
 (_cTRTMP3)->(dbGoTop())
if !(_cTRTMP3)->(EOF()) //.and. (_cTRTMP3)->QTD >1
	oTree3 := DbTree():New(050, 570 ,150 , 809 ,oDlg,/*{|| TreeChange()}*/,,.T.)  
	oTree3:BeginUpdate()
	oTree3:SetScroll(1,.T.)

	while !(_cTRTMP3)->(EOF())	
		If  ALLTRIM((_cTRTMP3)->A1_COD)+ALLTRIM((_cTRTMP3)->A1_LOJA) <>   cCliAnt
			oTree3:AddItem( ALLTRIM((_cTRTMP3)->A1_COD) + "  - Loja  " + ALLTRIM((_cTRTMP3)->A1_LOJA) + " - "+ ALLTRIM((_cTRTMP3)->A1_NOME)  , ALLTRIM((_cTRTMP3)->A1_COD)+ALLTRIM((_cTRTMP3)->A1_LOJA) , "FOLDER10" ,,,,1)    
		   	If oTree3:TreeSeek( ALLTRIM((_cTRTMP3)->A1_COD)+ALLTRIM((_cTRTMP3)->A1_LOJA))
				oTree3:AddItem("Média de Faturamento: " + cvaltochar((_cTRTMP3)->A1_MEDFATA)  ,ALLTRIM((_cTRTMP3)->A1_COD)+ ALLTRIM((_cTRTMP3)->A1_LOJA) , "TITULO",,,,2) 					 				
		    	oTree3:AddItem("Saldo de Títulos: " + cvaltochar((_cTRTMP3)->A1_SALDUP) ,ALLTRIM((_cTRTMP3)->A1_COD)+ALLTRIM((_cTRTMP3)->A1_LOJA) , "TITULO",,,,2)	     	    			  		
		    	oTree3:AddItem("Títulos Vencidos: "+cvaltochar((_cTRTMP3)->A1_ATR), ALLTRIM((_cTRTMP3)->A1_COD)+ALLTRIM((_cTRTMP3)->A1_LOJA), "TITULO",,,,2)
			Endif	   	
		 EndIf
		cCliAnt :=  ALLTRIM((_cTRTMP3)->A1_COD)+ALLTRIM((_cTRTMP3)->A1_LOJA)
		(_cTRTMP3)->(dbSkip())   
	enddo
	oTree3:EndUpdate()
Endif
  
 
return .t.