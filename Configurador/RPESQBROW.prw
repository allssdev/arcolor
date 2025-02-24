#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RPESQBROW บAutor  ณ J๚lio Soares     บ Data ณ  20/06/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina responsแvel pela sele็ใo dos dados na SX5 para      บฑฑ
ฑฑบ          ณ retorno das op็๕es.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RPESQBROW(_uVarRet	,;	//Variavel de Retorno
						_cTitCol	,;	//Titulo da Coluna com as opcoes
						_aOpcoes	,;	//Opcoes de Escolha (Array de Opcoes)
						_cOpcoes	,;	//String de Opcoes para Retorno
						_l1Elem		,;	//Se a Selecao sera de apenas 1 Elemento por vez, APRESENTA OU NรO OS BOTีES
						_nTam		,;	//Tamanho da Chave
						_nElmRet	,;	//Nฐ maximo de elementos na variavel de retorno
						_lMltSel	,;	//Inclui Botoes para Selecao de Multiplos Itens
						_lCmbBox	,;	//Se as opcoes serao montadas a partir de ComboBox de Campo (X3_CBOX)
						_cCampo		,;	//Qual o Campo para a Montagem do _aOpcoes
						_lNotOrd	,;	//Nao Permite a Ordenacao
						_lNotPsq	,;	//Nao Permite a Pesquisa
						_lRetArr	,;	//Forca o Retorno Como Array
						_cConsF3	;	//Consulta F3
					  )
                    	
Local _aLstBx		:= {}
Local _aSvKeys		:= GetKeys()
Local _aAdvSiz		:= {}
Local _aAdvSiz2		:= {}
Local _aAdvSiz3		:= {}
Local _aInfASiz		:= {}
Local _aInfASiz2	:= {}
Local _aInfASiz3	:= {}
Local _aObjCrds		:= {}
Local _aObjCrds2	:= {}
Local _aObjCrds3	:= {}
Local _aObjSize		:= {}
Local _aObjSiz2		:= {}
Local _aObjSiz3		:= {}
Local _aButtons		:= {}
Local _aX3Box		:= {}
Local bSvF3			:= SetKey(VK_F3,NIL)
Local bSetF3		:= {|| NIL}
Local bSet15		:= {|| NIL}
Local bSet24		:= {|| NIL}
Local bSetF4		:= {|| NIL}
Local bSetF5		:= {|| NIL}
Local bSetF6		:= {|| NIL}
Local bCapTrc		:= {|| NIL}
Local bDlgInit		:= {|| NIL}
Local bOrdena		:= {|| NIL}
Local bPesquisa		:= {|| NIL}
Local cCodOpc		:= ""
Local cDesOpc		:= ""
Local cCodDes		:= ""
Local cPict			:= "@E 999999"
Local cVarQ			:= ""
Local cReplicate	:= ""
Local cTypeRet		:= ""
Local lExistCod		:= .F.
Local lSepInCod		:= .F.
Local nOpcA			:= 0
Local nFor			:= 0
Local nAuxFor		:= 1
Local nOpcoes		:= 0
Local nListBox		:= 0
Local nElemSel		:= 0
Local nInitDesc		:= 1
Local nTamPlus1		:= 0
Local oDlg			:= NIL
Local oListbox		:= NIL
Local oElemSel      := NIL
Local oElemRet		:= NIL
Local oOpcoes		:= NIL
Local oFontNum		:= NIL
Local oFontTit		:= NIL
Local oBtnMarcTod	:= NIL
Local oBtnDesmTod	:= NIL
Local oBtnInverte	:= NIL
Local oGrpOpc		:= NIL
Local oGrpRet		:= NIL
Local oGrpSel		:= NIL
Local nXBox			:= 0
Local uRet			:= NIL
Local uRetF3		:= NIL
Default _uVarRet	:= &(ReadVar())
Default _cTitCol	:= OemToAnsi( "Escolha Padr๕es" )
Default _aOpcoes	:= {}
Default _cOpcoes	:= ""
Default _l1Elem		:= .F.
Default _lMltSel 	:= .T.
Default _lCmbBox	:= .F.
Default _cCampo		:= ""
Default _lNotOrd	:= .F.
Default _lNotPsq	:= .F.
Default _lRetArr	:= .F.

Begin Sequence
	uRet		:= _uVarRet
	cTypeVarRet	:= ValType( _uVarRet )
	cTypeRet	:= If( _lRetArr , "A" , ValType( uRet ) )
	_lMltSel 	:= !( _l1Elem ) //Inclui Botoes para Selecao de Multiplos Itens
	If !(_lCmbBox)
		Default _nTam := 1
		nTamPlus1 := (_nTam+1)
		If ((nOpcoes := Len(_aOpcoes))>0)
			For nFor := 1 To nOpcoes
			    If !Empty(_cOpcoes)
			    	lExistCod	:= .F.
			    	nInitDesc	:= AT( "- ",_aOpcoes[nFor])+2
				    cCodOpc := SubStr(_aOpcoes[nFor],1,AT( " -",_aOpcoes[nFor])-1)
				    cDesOpc := SubStr(_aOpcoes[nFor],AT( "- ",_aOpcoes[nFor])+2)
				    cCodDes := _aOpcoes[ nFor ]
				    aAdd(_aLstBx,{.F.,cCodDes,cCodOpc,cDesOpc})
				Else 
					aAdd( _aLstBx,{.F.,_aOpcoes[nFor],_aOpcoes[nFor],_aOpcoes[nFor]})
				EndIf	
				If ((cTypeVarRet == "C").and.(_aLstBx[nFor,03] $ _uVarRet))	
					_aLstBx[ nFor , 01 ] := .T.
				EndIf
			Next nFor
		Else
			//CursorArrow()
			MsgInfo("Nใo existem dados para consulta", If(Empty(_cTitCol),"Escolha Padr๕es",_cTitCol))
			Break
		EndIf	
	Else
		Default _nTam	:= ( TamSx3( _cCampo )[1] )
		_aLstBx := BoxRetArr( _cCampo , @_cTitCol )
		If ( ( nOpcoes := Len( _aLstBx ) ) > 0 )
			For nFor := 1 To nOpcoes
		    	If((cTypeVarRet == "C" ).and.( _aLstBx[ nFor , 03 ] $ _uVarRet))
		    	   	_aLstBx[ nFor , 01 ] := .T.
	    		EndIf
			Next nFor
		Else
		//CursorArrow()
			MsgInfo("Nใo existem dados para consulta" , If(Empty(_cTitCol),"Escolha Padr๕es",_cTitCol))
		EndIf
	EndIf
	// Inibe exibicao de item vazio
	nXBox	:= Ascan(_aLstBx,{|x| Empty(x[2])})
	If ( nXBox	> 0 )
		Do While ( nXBox <= LEN(_aLstBx) )
			If ( Empty(_aLstBx[nXBox , 2]) )
				aDel(_aLstBx , nXBox )
				aSize(_aLstBx , LEN(_aLstBx)-1 )
			Else
				nXBox++	
			EndIf
		EndDo
	EndIf
	// Define o Default do Maximo de Elementos que Podem ser Retorna
	Default _nElmRet := If ( ValType(&( ReadVar() )) <> 'U' , ( Len( &( ReadVar() ) ) / _nTam ) , 1 )
	// Define os numeros de Elementos que serao Mostrados
	nOpcoes		:= Len( _aLstBx )
	_nElmRet    := Min( _nElmRet , nOpcoes )
	_nElmRet	:= If( !( _lMltSel ) , 01 , _nElmRet )
	// Verifica os Elementos ja Selecionados
	aEval( _aLstBx , { |x| If( x[1] , ++nElemSel , NIL ) } )
	// Define Bloco e Botao para a Ordenacao das Opcoes
	If !( _lNotOrd )
		bOrdena		:= { || OrdOpcoes(oListBox,"F7 - Ordenar" ),SetKey(VK_F7,bOrdena)}
		aAdd(_aButtons,{"SDUORDER",bOrdena,"F7 - Ordenar","Ordenar"})
	EndIf
	// Define Bloco e  Botao para a Pesquisa
	If !( _lNotPsq )
		bPesquisa	:= { || PesqOpcoes(oListBox,"F8 - Pesquisar",_lNotOrd,_cConsF3,_aX3Box),SetKey(VK_F8,bPesquisa)}
		aAdd(_aButtons,{"PESQUISA",bPesquisa,"F8 - Pesquisar","Pesquisar"})
	EndIf
	// Define o Bloco para a InvertSel()						   ณ
	bCapTrc	:= { |cTipo,_lMltSel| 	_aLstBx := InvertSel(oListBox:nAt,@_aLstBx,_l1Elem,nOpcoes,_nElmRet,@nElemSel,_lMltSel,cTipo),;
									oListBox:nColPos := 1,;
									oListBox:Refresh(),;
									oElemSel:Refresh()}
	// Carrega as Dimensoes Disponiveis
	_aAdvSiz	:=	MsAdvSize(.T.,.T.)
	// Redimensiona
	_aAdvSiz[3] := 245
	_aAdvSiz[5] := 483
	// Monta as Dimensoes dos Objetos
	_aInfASiz	:= {_aAdvSiz[1],_aAdvSiz[2],_aAdvSiz[3],_aAdvSiz[4],3,3}
	aAdd( _aObjCrds,{020,070,.T.,.T.,.T.})
	aAdd( _aObjCrds,{000,020,.T.,.F.})
	aAdd( _aObjCrds,{000,020,.T.,.F.})
	_aObjSize	:= MsObjSize(_aInfASiz,_aObjCrds)

	_aAdvSiz2	:= aClone(_aObjSize[3])
	_aInfASiz2	:= {_aAdvSiz2[2],_aAdvSiz2[1],_aAdvSiz2[4],_aAdvSiz2[3],3,3}
	aAdd(_aObjCrds2,{000,020,.T.,.F.})	
	aAdd(_aObjCrds2,{000,020,.T.,.F.})
	aAdd(_aObjCrds2,{000,020,.T.,.F.})
	_aObjSiz2	:= MsObjSize(_aInfASiz2,_aObjCrds2,,.T.)
	
	_aAdvSiz3	:= aClone(_aObjSize[2])
	_aInfASiz3	:= {_aAdvSiz3[2],_aAdvSiz3[1],_aAdvSiz3[4],_aAdvSiz3[3],3,3}
	aAdd( _aObjCrds3,{000,020,.T.,.F.})
	aAdd( _aObjCrds3,{000,020,.T.,.F.})
	aAdd( _aObjCrds3,{000,020,.T.,.F.})
	_aObjSiz3	:= MsObjSize(_aInfASiz3,_aObjCrds3,,.T.)
	// Seta a consulta F3
	If !Empty( _cCampo )
		If !Empty( _cConsF3 )
			bSetF3 := { || PesqF3(_cConsF3,_cCampo,oListBox),SetKey(VK_F3,bSetF3)}
		Else
			_aX3Box := Sx3Box2Arr(_cCampo)
		EndIf	
	EndIf	
	// Caixa de dialogo para selecao
	DEFINE FONT oFontNum NAME "Arial" SIZE 000,-014 BOLD
	DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011 BOLD
	DEFINE MSDIALOG oDlg TITLE "Escolha Padr๕es" FROM _aAdvSiz[7],0 TO _aAdvSiz[6]+40,_aAdvSiz[5] OF GetWndDefault() PIXEL
		@ _aObjSize[1][1],_aObjSize[1][2] LISTBOX oListBox VAR cVarQ FIELDS HEADER "" , OemToAnsi(_cTitCol)  SIZE _aObjSize[1][3],_aObjSize[1][4] ON DBLCLICK Eval(bCapTrc) NOSCROLL PIXEL
		oListBox:SetArray( _aLstBx )
		oListBox:bLine := { || LineLstBox( oListBox,.T.)}
		If ( _lMltSel ) // Inclui Botoes para Selecao de Multiplos Itens
			// Define Bloco e o Botao para Marcar Todos
			bSetF4 := { || Eval(bCapTrc,"M",_lMltSel),SetKey(VK_F4,bSetF4)}
			@ _aObjSiz3[1][1],_aObjSiz3[1][2] BUTTON oBtnMarcTod PROMPT "F4 - Marca Todos" SIZE 75,13.50 OF oDlg PIXEL ACTION Eval(bSetF4)
			// Define Bloco e o Botao para Desmarcar Todos
			bSetF5 := { || Eval(bCapTrc,"D",_lMltSel),SetKey(VK_F5,bSetF5)}
			@ _aObjSiz3[2][1],_aObjSiz3[2][2] BUTTON oBtnDesmTod PROMPT "F5 - Desmarca Todos" SIZE 75,13.50 OF oDlg PIXEL ACTION Eval(bSetF5)
			// Define Bloco e o Botao para Inversao da Selecao
			bSetF6 := { || Eval(bCapTrc,"I",_lMltSel),SetKey(VK_F6,bSetF6)}
			@ _aObjSiz3[3][1],_aObjSiz3[3][2] BUTTON oBtnInverte PROMPT "F6 - Inverte Sele็ใo" SIZE 75,13.50 OF oDlg PIXEL ACTION Eval(bSetF6)
		EndIf
		// Numero de Elementos para Selecao
		@ _aObjSiz2[1][1],_aObjSiz2[1][2] GROUP oGrpOpc TO _aObjSiz2[1][3],_aObjSiz2[1][4]	OF oDlg LABEL "Nro. Elementos" PIXEL
		oGrpOpc:oFont := oFontTit
		@ _aObjSiz2[1][1]+10,_aObjSiz2[1][2]+20 SAY oOpcoes VAR Transform(nOpcoes,cPict) OF oDlg PIXEL FONT oFontNum
		// Maximo de Elementos que poderm Ser Selecionados
		@ _aObjSiz2[2][1],_aObjSiz2[2][2] GROUP oGrpRet	TO _aObjSiz2[2][3],_aObjSiz2[2][4]	OF oDlg LABEL "Mแx Elem. p/ Sele็ใo" PIXEL
		oGrpRet:oFont := oFontTit
		@ _aObjSiz2[2][1]+10,_aObjSiz2[2][2]+20 SAY oElemRet VAR Transform(_nElmRet,cPict) OF oDlg PIXEL FONT oFontNum
		// Numero de Elementos Selecionados
		@ _aObjSiz2[3][1],_aObjSiz2[3][2] GROUP oGrpSel	TO _aObjSiz2[3][3],_aObjSiz2[3][4]	OF oDlg LABEL "Elem. Selecionados" PIXEL
		oGrpSel:oFont := oFontTit
		@ _aObjSiz2[3][1]+10,_aObjSiz2[3][2]+20	SAY oElemSel VAR Transform(nElemSel,cPict) OF oDlg PIXEL FONT oFontNum
		// Define Bloco para a Tecla <CTRL-O>
	  	bSet15 := { || nOpcA := 1,GetKeys(),SetKey(VK_F3,NIL),oDlg:End()}
		// Define Bloco para a Tecla <CTRL-X>
		bSet24 := { || nOpcA := 0,GetKeys(),SetKey(VK_F3,NIL),oDlg:End()}
		// Define Bloco para o Init do Dialog
		bDlgInit := { || EnchoiceBar(oDlg,bSet15,bSet24,NIL,_aButtons),If(_lMltSel,(SetKey(VK_F3,bSetF3),SetKey(VK_F4,bSetF4),SetKey(VK_F5,bSetF5),SetKey(VK_F6,bSetF6)),NIL),SetKey(VK_F7,bOrdena),SetKey(VK_F8,bPesquisa)}

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( bDlgInit )
	// Retorna as Opcoes Selecionadas
	If (nOpcA == 1)
	    If (cTypeRet == "C")
		    uRet		:= ""
			cReplicate	:= Replicate("*",_nTam)
		    nListBox	:= Len(_aLstBx)
		    For nFor := 1 To nListBox
				If (_aLstBx[nFor,01])
					If !Empty(uRet)
						uRet += ';'
					EndIf
					uRet += _aLstBx[nFor,03]
		    	EndIf
		    Next nFor
		ElseIF (cTypeRet == "A" )
		    uRet	 	:= {}
		    nListBox	:= 0
		    While ((nFor := aScan(_aLstBx,{|x| x[1]},++nListBox))>0)
		    	nListBox := nFor
				aAdd(uRet,_aLstBx[nFor,03])
		    End While
		EndIf
	EndIf
	//Carrega Variavel com retorno por Referencia
	_uVarRet := uRet
End Sequence
//Restaura o Estado das Teclas de Atalho
RestKeys(_aSvKeys,.T.)
SetKey(VK_F3,bSvF3)
Return((nOpca == 1))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PesqF3 บAutor  ณ J๚lio Soares     บ Data ณ  20/06/2016     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua Pesquisa Via Tecla F3                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PesqF3(_cConsF3,_cCampo,oListBox)

Local cAlias
Local lConpad1
Local nAt
Local uRetF3

If FindFunction( "AliasCpo" )
	cAlias := AliasCpo( _cCampo )
	If (!Empty(cAlias).and.(Select(cAlias)>0))	
		lConpad1 := ConPad1(NIL,NIL,NIL,_cConsF3,NIL,NIL,.F.)
		If( lConpad1 )
			uRetF3	:= ( cAlias )->( FieldGet( FieldPos( _cCampo ) ) )
			nAt		:= aScan( oListBox:aArray , { |x| x[3] == uRetF3 } )
			If ( nAt > 0 )
				oListBox:nAt := nAt
				oListBox:Refresh()
			Else
				MsgInfo("C๓digo nใo encontrado")
			EndIf
		EndIf
	EndIf	
EndIf

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ InvertSel บAutor  ณ J๚lio Soares     บ Data ณ  20/06/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua a Troca da Selecao no ListBox da RPESQBROW()        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function InvertSel(	nAt		,;//Indice do ListBox de RPESQBROW()
							aArray	,;//Array do ListBox de RPESQBROW()
							_l1Elem	,;//Se Selecao apenas de 1 elemento
							nOpcoes	,;//Numero de Elementos disponiveis para Selecao
							_nElmRet,;//Numero de Elementos que podem ser Retornados
							nElemSel,;//Numero de Elementos Selecionados
							_lMltSel,;//Se Trata Multipla Selecao
							cTipo	 ;//Tipo da Multipla Selecao "M"arca Todos; "D"esmarca Todos; "I"nverte Selecao
						   )

Local nOpcao	:= 0

Default nAt		:= 1
Default aArray	:= {}
Default _l1Elem	:= .F.
Default nOpcoes	:= 0
Default _nElmRet:= 0
Default nElemSel:= 0
Default _lMltSel:= .F.
Default cTipo	:= "I"

// Coloca o Ponteiro do Cursor em Estado de Espera
CursorWait()
	If !Empty( aArray )
		If !( _l1Elem ) // Verifica se nใo deve marcar somente uma op็ใo.
			If !( _lMltSel ) // Inclui Botoes para Selecao de Multiplos Itens
				aArray[nAt,1] := !aArray[nAt,1] // Marca a sele็ใo.
				If !( aArray[nAt,1] )
					--nElemSel
				Else
					++nElemSel
				EndIf	
			ElseIF ( _lMltSel )
				If ( cTipo == "M" )
					nElemSel := 0
					aEval( aArray , { |x,y| aArray[y,1] := If((y<=_nElmRet),(++nElemSel,.T.),.F.)})
				ElseIF ( cTipo == "D" )
					aEval( aArray , { |x,y| aArray[y,1] := .F., --nElemSel})
				ElseIF ( cTipo == "I" )
					nElemSel := 0
					aEval( aArray,{ |x,y| If(aArray[y,1],aArray[y,1] := .F.,If(((++nElemSel)<=_nElmRet),aArray[y,1] := .T.,NIL))})
					nElemSel := Min(nElemSel,_nElmRet)
				EndIf
			EndIf
		Else
			For nOpcao := 1 To nOpcoes
				If ( nOpcao == nAt )
					aArray[nOpcao,1] := .T.
				Else
					aArray[nOpcao,1] := .F.
				EndIf
			Next nOpcao
			nElemSel := 01
		EndIf
	EndIf
// Restaura o Ponteiro do Cursor
CursorArrow()
	
If ( nElemSel > _nElmRet )
	aArray[nAt,1] := .F.
	nElemSel := _nElmRet
	MsgInfo("Excedeu o n๚mero de elementos permitidos para sele็ใo","Aten็ใo")
ElseIF ( nElemSel < 0 )
	nElemSel := 0
EndIf

Return(aArray)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OrdOpcoes บAutor  ณ J๚lio Soares      บ Data ณ 20/06/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ordenar as Opcoes em RPESQBROW                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function OrdOpcoes( oListBox , _cTitCol )

Local _aSvKeys	:= GetKeys()
Local _aAdvSiz	:= {}
Local _aInfASiz	:= {}
Local _aObjCrds	:= {}
Local _aObjSize	:= {}
Local bSort		:= { || NIL }
Local lbSet15	:= .F.
Local nOpcRad	:= 1
Local oFont		:= NIL
Local oDlg		:= NIL
Local oGroup	:= NIL
Local oRadio	:= NIL	

// Monta as Dimensoes dos Objetos
_aAdvSiz		:= MsAdvSize( .T. , .T. )

//Redimensiona
_aAdvSiz[3] -= 25
_aAdvSiz[4] -= 45
_aAdvSiz[5] -= 50
_aAdvSiz[6] -= 40
_aAdvSiz[7] += 50
_aInfASiz	:= {_aAdvSiz[1],_aAdvSiz[2],_aAdvSiz[3],_aAdvSiz[4],5,5}
aAdd(_aObjCrds,{000,000,.T.,.T.})
_aObjSize := MsObjSize(_aInfASiz,_aObjCrds)

// Define o Bloco para a Teclas <CTRL-O>  (Button OK da EnchoiceBar)
bSet15 := { || (lbSet15 := .T.,GetKeys(),oDlg:End())}
// Define o  Bloco  para a Teclas <CTRL-X> ( Button Cancel da EnchoiceBar)
bSet24 := { || GetKeys(),oDlg:End()}

//Monta Dialogo para a selecao do Periodo
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg TITLE OemToAnsi(_cTitCol) From _aAdvSiz[7],0 TO _aAdvSiz[6],_aAdvSiz[5] OF GetWndDefault() PIXEL
	@ _aObjSize[1,1],_aObjSize[1,2] GROUP oGroup TO _aObjSize[1,3],_aObjSize[1,4] LABEL "Ordena็ใo" OF oDlg PIXEL
	oGroup:oFont:= oFont
	@ (_aObjSize[1,1]+010),(_aObjSize[1,2]+005 ) SAY "Efetuar a Orden็ใo por:" SIZE 300,10 OF oDlg PIXEL FONT oFont
	@ (_aObjSize[1,1]+010),(_aObjSize[1,2]+100 ) RADIO oRadio VAR nOpcRad ITEMS "C๓digo",;
																				"Descri็ใo",;
																				"Item selecionado e c๓digo",;
																				"Item selecionado e descri็ใo",;
																				"Item nใo selecionado e c๓digo",;
																				"Item nใo selecionado e descri็ใo",	SIZE 115,010 OF oDlg PIXEL
	oRadio:oFont := oFont																						

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 )

If ( lbSet15 )
	Do Case
		Case ( nOpcRad == 1)
			bSort := { |x,y| x[3] < y[3]}
		Case ( nOpcRad == 2 )
			bSort := { |x,y| x[4] < y[4]}
		Case ( nOpcRad == 3 )
			bSort := { |x,y| (If(x[1],"A","Z") + x[3]) < (If( y[1],"A","Z")+ y[3])}
		Case ( nOpcRad == 4 )
			bSort := { |x,y| (If(x[1],"A","Z") + x[4]) < (If( y[1],"A","Z")+ y[4])}
		Case ( nOpcRad == 5 )
			bSort := { |x,y| (If(!x[1],"A","Z") + x[3]) < (If(!y[1],"A","Z")+ y[3])}
		Case ( nOpcRad == 6 )
			bSort := { |x,y| (If(!x[1],"A","Z") + x[4]) < (If(!y[1],"A","Z")+ y[4])}
	End Case
	aSort( oListBox:aArray , NIL , NIL , bSort )
	oListBox:nAt := 1
	oListBox:Refresh()
EndIf		
// Restaura as Teclas de Atalho
RestKeys(_aSvKeys,.T.)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PesqOpcoes บAutor  ณ J๚lio Soares      บ Data ณ 20/06/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pesquisar as Opcoes em RPESQBROW                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PesqOpcoes(oListBox,_cTitCol,_lNotOrd,_cConsF3,_aX3Box)

Local _aSvKeys	:= GetKeys()
Local _aAdvSiz	:= {}
Local _aInfASiz	:= {}
Local _aObjCrds	:= {}
Local _aObjSize	:= {}
Local aCloneArr	:= {}
Local bSort		:= { || NIL }
Local bAscan	:= { || NIL }
Local bSvF3		:= SetKey( VK_F3  , NIL )
Local cCodigo	:= Space( 20 )
Local cDescri	:= Space( 60 )
Local cMsg		:= ""
Local lbSet15	:= .F.
Local nOpcRad	:= 1
Local nAt		:= 0
Local oFont		:= NIL
Local oDlg		:= NIL
Local oGroup	:= NIL
Local oRadio	:= NIL
Local oCodigo	:= NIL

// Monta as Dimensoes dos Objetos
_aAdvSiz		:= MsAdvSize( .T. , .T. )
// Redimensiona
_aAdvSiz[3] -= 25
_aAdvSiz[4] -= 50
_aAdvSiz[5] -= 50
_aAdvSiz[6] -= 50
_aAdvSiz[7] += 50
_aInfASiz	:= {_aAdvSiz[1],_aAdvSiz[2],_aAdvSiz[3],_aAdvSiz[4],5,5}
aAdd( _aObjCrds,{000,030,.T.,.F.})
aAdd( _aObjCrds,{000,015,.T.,.F.})
aAdd( _aObjCrds,{000,015,.T.,.F.})
aAdd( _aObjCrds,{000,001,.T.,.F.})
_aObjSize		:= MsObjSize(_aInfASiz,_aObjCrds)

// Define o Bloco para a Teclas <CTRL-O> (Button OK da EnchoiceBar)
bSet15 := { || (lbSet15 := .T.,GetKeys(),oDlg:End())}
// Define o  Bloco  para a Teclas <CTRL-X> ( Button Cancel da EnchoiceBar)
bSet24 := { || GetKeys() , oDlg:End() }
// Monta Dialogo para a selecao do Periodo

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg TITLE OemToAnsi(_cTitCol) From _aAdvSiz[7],0 TO _aAdvSiz[6]+20,_aAdvSiz[5] OF GetWndDefault() PIXEL
	@ _aObjSize[1,1],_aObjSize[1,2] GROUP oGroup TO _aObjSize[4,3],_aObjSize[4,4] LABEL "Pesquisa" OF oDlg PIXEL
	oGroup:oFont:= oFont
	@ ( _aObjSize[1,1] + 010 ) , ( _aObjSize[1,2]+005 )	SAY "Efetuar Pesquisa por:"	SIZE 300,10 OF oDlg PIXEL FONT oFont
	@ ( _aObjSize[1,1] + 010 ) , ( _aObjSize[1,2]+100 )	RADIO oRadio VAR nOpcRad	ITEMS 	"C๓digo","Descri็ใo" SIZE 115,010 OF oDlg PIXEL
	oRadio:cToolTip := "Ap๓s selecionar pressione a tecla <TAB> para habilitar a digita็ใo"
	oRadio:oFont	:= oFont
	@ _aObjSize[2,1] , _aObjSize[2,2]+005 SAY "C๓digo: "					SIZE 100,10 OF oDlg PIXEL FONT oFont
	If Empty( _aX3Box )
		@ _aObjSize[2,1],_aObjSize[2,2]+70 MSGET oCodigo VAR cCodigo	SIZE 100,10 OF oDlg PIXEL FONT oFont WHEN (nOpcRad == 1)
		If !Empty( _cConsF3 )
			oCodigo:_cConsF3 := _cConsF3
		EndIf
	Else
		@ _aObjSize[2,1] , _aObjSize[2,2]+100 COMBOBOX oCodigo VAR cCodigo ITEMS _aX3Box SIZE 100,10 OF oDlg PIXEL FONT oFont WHEN (nOpcRad == 1)
	EndIf
	@ _aObjSize[3,1] , _aObjSize[3,2]+005	SAY "Descri็ใo: "	SIZE 100,10 OF oDlg PIXEL FONT oFont
	@ _aObjSize[3,1] , _aObjSize[3,2]+70	MSGET oCodigo VAR cDescri SIZE 190,10 OF oDlg PIXEL FONT oFont WHEN(nOpcRad == 2)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 )

If (lbSet15)
	Do Case
		Case (nOpcRad == 1)
			bSort	:= { |x,y| x[3] < y[3]}
			bAscan	:= { |x,y| Upper( AllTrim( cCodigo ) ) $ SubStr(Upper(AllTrim(x[3])),1,Len(AllTrim(cCodigo)))}
			cMsg	:= "C๓digo nใo encontrado"
		Case ( nOpcRad == 2 )
			bSort	:= { |x,y| x[4] < y[4]}
			bAscan	:= { |x,y| Upper( AllTrim(cDescri)) $ SubStr(Upper(AllTrim(x[4])),1,Len(AllTrim(cDescri)))}
			cMsg	:= "Descri็ใo nใo encontrada"
	End Case
	aCloneArr := aClone( oListBox:aArray)
	If !(_lNotOrd)
		aSort(oListBox:aArray,NIL,NIL,bSort)
	EndIf
	If (((nAt := aScan(oListBox:aArray,bAscan)))>0)
		oListBox:nAt := nAt
		oListBox:Refresh()
	Else
		MsgInfo(cMsg,_cTitCol)
		oListBox:aArray := aClone(aCloneArr)
		oListBox:Refresh()
	EndIf
EndIf		

// Restaura as Teclas de Atalho
RestKeys(_aSvKeys,.T.)
SetKey(VK_F3,bSvF3)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PesqSX5 บAutor  ณ J๚lio Soares      บ Data ณ  20/06/2016   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Selecionar Tabela com Base no SX5                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function PesqSX5(cTab,_nTam)
          
Local aBox		:= {}
Local _cTitCol	:= ""
Local MvParDef	:= ""
Local _cFilSX5	:= xFilial("SX5")
Local MvPar		:= &(Alltrim(ReadVar()))
Local MvRet		:= Alltrim(ReadVar())

If SX5->(dbSeek(_cFilSX5 + Padl(cTab,4,"0")))
   _cTitCol := SX5->(Alltrim(Left(X5Descri(),20)))
EndIf
If MsSeek(_cFilSX5 + cTab,.T.,.F.)
	While SX5->( !Eof() .and. X5_TABELA == cTab)
		aAdd(aBox,Left(SX5->X5_CHAVE,1) + " - " + Alltrim(SX5->(X5Descri())))
		MvParDef += Left(SX5->X5_CHAVE,1)
		SX5->(dbSkip())
	Enddo
Else          
	MsgAlert("Atencao tabela nao existe no SX5")
EndIf
If RPESQBROW(@MvPar,_cTitCol,@aBox,MvParDef,15,80,,_nTam)
	&(MvRet) := mvpar
EndIf

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SelSX3 บAutor  ณ J๚lio Soares      บ Data ณ  20/06/2016    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Selecionar Tabela com Base no X3_COMBO                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function SelSX3(_cCampo,_nTam,_cTitCol,_l1Elem,_nElmRet,_lMltSel,_lNotOrd,_lNotPsq)	
/*
_cCampo		- Campo para retorno do X3_CBOX
_nTam		- Tamanho das opcoes do X3_CBOX
_cTitCol	- Titulo da Coluna com as opcoes
_l1Elem		- No. elementos
_nElmRet	- No maximo de elementos na variavel de retorno
_lMltSel	- Inclui Botoes para Selecao de Multiplos Itens
_lNotOrd	- Nao Permite a Ordenacao
_lNotPsq	- Nao Permite a Pesquisa
*/

Local cReadVar		:= ReadVar()
Local cOpcRet		:= &( cReadVar )
                	
Default _nTam		:= ( TamSx3( _cCampo )[1] )
Default _l1Elem		:= .F.
Default _nElmRet    := ( Len( cOpcRet ) / _nTam )
Default _lMltSel	:= .T.
Default _lNotOrd	:= .F.
Default _lNotPsq	:= .F.

If RPESQBROW(@cOpcRet,_cTitCol,NIL,NIL,NIL,NIL,_l1Elem,_nTam,_nElmRet,_lMltSel,.T.,_cCampo,_lNotOrd,_lNotPsq )
/*
@cOpcRet	- Variavel de Retorno
_cTitCol	- Titulo da Coluna com as opcoes
NIL			- Opcoes de Escolha (Array de Opcoes)
NIL			- String de Opcoes para Retorno
NIL			- Linha - Superior Esquerdo  ( Parametro Reservado, sera redefinido na funcao )
NIL			- Coluna - Superior Esquerdo ( Parametro Reservado, sera redefinido na funcao )
_l1Elem		- Se a Selecao sera de apenas 1 Elemento por vez
_nTam		- Tamanho da Chave
_nElmRet	- No maximo de elementos na variavel de retorno
_lMltSel	- Inclui Botoes para Selecao de Multiplos Itens
.T.			- Se _aOpcoes Sera Montada a Partir de compo Box de Campo
_cCampo		- Qual o Campo para a Montagem do _aOpcoes
_lNotOrd	- Nao Permite a Ordenacao
_lNotPsq	- Nao Permite a Pesquisa
*/
	&(cReadVar) := cOpcRet
EndIf	

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BoxRetArr บAutor  ณ J๚lio Soares     บ Data ณ  20/06/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna array com ComboBox                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function BoxRetArr( _cCampo , _cTitCol )

Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->( GetArea() )
Local _aLstBx	:= {}
Local aSx3Info	:= PosAlias("SX3",_cCampo,NIL,{"//X3TITULO()","X3cBox()","X3_TAMANHO"},2,.F.)
Local nLoop
Local nLoops

If !Empty( aSx3Info )
	_cTitCol := aSx3Info[1]
	aX3cBox	:= RetSx3Box(aSx3Info[2],NIL,NIL,aSx3Info[3])
	nLoops  := Len(aX3cBox)
	For nLoop := 1 To nLoops
		aAdd(_aLstBx,{.F.,aX3cBox[nLoop,1],aX3cBox[nLoop,2],aX3cBox[nLoop,3]})
	Next nLoop
EndIf

RestArea(aAreaSX3)
RestArea(aArea)

Return(_aLstBx)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OpcClear  บAutor  ณ J๚lio Soares     บ Data ณ  20/06/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Limpa o conteudo de uma variavel do RPESQBROW.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function OpcClear(nTamCpo, cConteudo, _aOpcoes)
Local aConteudo	:= {}
Local nTamField 
Local nX
Local nTamOpc	:= Len( _aOpcoes[1] )

// Reve o tamanho da variavel do Campo 
nTamField:=	Min(nTamCpo, Len(_aOpcoes) * 2 )
// Limpa o conteudo do campo
cConteudo:= StrTran(cConteudo,"-","")
cConteudo:= StrTran(cConteudo,"*","")
// Converte a variavel em Array
For nX:=1 To Len(cConteudo)
	AADD(aConteudo,Substr(cConteudo,nX,nTamOpc) )
Next nX  
// Verifica as opcoes escolhidas e substitui as nao escolhidas por "*-"
cConteudo := ""
For nX:=1 To Len(_aOpcoes)
	If !Empty(Ascan(aConteudo,{|x| _aOpcoes[nX] == X}))
		cConteudo	+= _aOpcoes[nX]+"-"
	Else
	    cConteudo	+= "**"
	Endif 
Next nX

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RCordRet บAutor  ณ J๚lio Soares       บ Data ณ  20/06/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para gerar coordenadas de objetos virtuais.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RCordRet(nQtdObj,nQtdLin,nEspcoObj,uEspcoLin,nColunas,uEspcoCol,lAlinHor,nLinha,_aAdvSiz)

/*
nQtdObj   = Quantidade de Objetos por linha
nQtdLin   = Quantidade de linhas
nEspcoObj = Espa็o entre os objetos
uEspcoLin = Espa็o entre os linhas
nColunas  = Quantidade de Colunas na tela
uEspcoCol = Espa็o entre as Colunas
lAlinHor  = Alinhamento Horizontal
nLinha    = posi็ใo da linha inicial
AdvSize   = Array com as posi็๕es personalizadas
*/
Local _aInfASiz	:= {}
Local _aObjSize	:= {}
Local _aObjCrds	:= {}
Local aRet		:= {}
Local i
Local ix
Local nSpace	:= 0
Local nAuxCol	:= 2 
Local nCol		:= 1

Default lAlinHor	:= .T.
Default nQtdObj		:= 0
Default nQtdLin		:= 0
Default nLinha		:= 0
Default nColunas	:= 1
Default nEspcoObj	:= 0
Default uEspcoLin	:= 10
Default uEspcoCol	:= 10
Default _aAdvSiz	:= MsAdvSize()
	
If nLinha > 0
	_aInfASiz := {_aAdvSiz[1],nLinha     ,_aAdvSiz[3],_aAdvSiz[4],nEspcoObj,0,10,0 }
Else
	_aInfASiz := {_aAdvSiz[1],_aAdvSiz[2],_aAdvSiz[3],_aAdvSiz[4],nEspcoObj,0,10,10}
EndIf

For i:=1 To nQtdObj
If nColunas > 1
	If VALTYPE(uEspcoCol) == "N"
		If uEspcoCol > 0
			If i == nAuxCol
				aAdd(_aObjCrds,{uEspcoCol,100,.F.,.T.})
				nAuxCol += 2
			Else
				aAdd(_aObjCrds,{00,100,.F.,.T.})
			Endif 
		EndIf
	ElseIf VALTYPE(uEspcoCol) == "A"
		If Len(uEspcoCol) > 0 .and. nCol <= Len(uEspcoCol)
			If i == nAuxCol
				aAdd(_aObjCrds,{uEspcoCol[nCol],100,.F.,.T.})
				nAuxCol += 2
				nCol    += 1
			Else
				aAdd(_aObjCrds,{00,100,.F.,.T.})
			Endif
		EndIf		
	EndIf
Else 	
	aAdd( _aObjCrds,{00,100,.F.,.T.})
EndIf

Next i
_aObjSize := MsObjSize(_aInfASiz,_aObjCrds,.T.,lAlinHor)
For i:=1 to nQtdLin
	For ix:=1 to nQtdObj
		aAdd( aRet,{_aObjSize[ix][1]+nSpace,_aObjSize[ix][2],_aObjSize[ix][3],_aObjSize[ix][4]})
	Next ix
	If VALTYPE(uEspcoLin) == "N"
		nSpace +=uEspcoLin
	ElseIf VALTYPE(uEspcoLin) == "A"
		nSpace += iif(i>Len(uEspcoLin),0,uEspcoLin[i])
	EndIf
Next i

Return(aRet)

/*
User Function RPESQBROW(_uVarRet	,;	//Variavel de Retorno
						_cTitCol	,;	//Titulo da Coluna com as opcoes
						_aOpcoes	,;	//Opcoes de Escolha (Array de Opcoes)
						_cOpcoes	,;	//String de Opcoes para Retorno
						_nLin1		,;	//Nao Utilizado
						_nCol1		,;	//Nao Utilizado
						_l1Elem		,;	//Se a Selecao sera de apenas 1 Elemento por vez, APRESENTA OU NรO OS BOTีES
						_nTam		,;	//Tamanho da Chave
						_nElmRet	,;	//Nฐ maximo de elementos na variavel de retorno
						_lMltSel	,;	//Inclui Botoes para Selecao de Multiplos Itens
						_lCmbBox	,;	//Se as opcoes serao montadas a partir de ComboBox de Campo ( X3_CBOX )
						_cCampo		,;	//Qual o Campo para a Montagem do _aOpcoes
						_lNotOrd	,;	//Nao Permite a Ordenacao
						_lNotPsq	,;	//Nao Permite a Pesquisa	
						_lRetArr	,;	//Forca o Retorno Como Array
						_cConsF3	;	//Consulta F3	
					  )

*/

/*/
ฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟ
ณFuno    ณInGpexFunwExecณAutor ณMarinaldo de Jesus   ณ Data ณ24/08/2004ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤด
ณDescrio ณExecutar Funcoes Dentro de GPEXFUNW                          ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณSintaxe   ณInGpexFunwExec( cExecIn , aFormParam )						 ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณParametrosณ<Vide Parametros Formais>									 ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณRetorno   ณuRet                                                 	     ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณObservaoณ                                                      	     ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณUso       ณGenerico 													 ณ
ภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
/*
User Function InGpexFunwExec(cExecIn,aFormParam)
         
Local uRet

Default cExecIn		:= ""
Default aFormParam	:= {}

If !Empty( cExecIn )
	cExecIn	:= BldcExecInFun( cExecIn , aFormParam )
	uRet	:= &( cExecIn )
EndIf

Return( uRet )
*/