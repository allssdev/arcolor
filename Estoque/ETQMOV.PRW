#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"

/*/{Protheus.doc} 
@description Etiqueta da produção para identificar as bases de produtos (produtos intemediarios)
@author		Diego Rodrigues Pereira email: diego.rodrigues@allss.com.br
@since 		20/02/2025
@version 	1.01
@see 		https://allss.com.br
/*/
user function ETQMOV() 
	Local oButton3
	Local oButton2
	Local oFont1 := TFont():New("MS Sans Serif",,026,,.T.,,,,,.F.,.F.) 
	Local oFont2 := TFont():New("MS Sans Serif",,022,,.T.,,,,,.F.,.F.)
	Local oFont3 := TFont():New("MS Sans Serif",,024,,.T.,,,,,.F.,.F.)
	Local oSay1
	Local oSay2
	Local oSay3
	Static oDlg

	Private oProduto
    Private oDesc
    Private oCor
	Private oMod
	Private oLote
    Private oQUant
	Private oPeso
	Private oData
	Private oDtValid
	Private oNrEtq
	Private oOP
    Private oChk

	Private _cOp  := Criavar("D4_OP")
	Private _cUnica := 'S'
	Private cProduto := CriaVar("B1_COD")
	Private cDesc    := CriaVar("B1_DESC")
	Private cLote    := Criavar("B8_LOTECTL")
	Private dData    := CtoD("//")
	Private nNrEtiq  := Criavar("DT6_QTDVOL")
    Private nQuant  := Criavar("D4_QUANT")
	Private nImpr := 0
	Private _aItens	:= {}
  


	DEFINE MSDIALOG oDlg TITLE ":::... Impressão de etiquetas Produtos Intermediarios ...:::" FROM 000, 000  TO 500, 700 PIXEL//COLORS 0, 16777215 PIXEL

	@ 008, 008 SAY oSay1 PROMPT "Etiqueta Produtos Intermediarios" SIZE 182, 017 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
	
	@ 040, 004 SAY oSay2 PROMPT "Etiqueta Automatica" SIZE 100, 010 OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
	@ 038, 100 MSGET oNF VAR _cUnica Picture "@!" SIZE 20, 010 OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL

	@ 060, 004 SAY oSay2 PROMPT "Ordem de Produção" SIZE 100, 010 OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
	@ 058, 100 MSGET oNF VAR _cOp Picture "@!" SIZE 080, 010 Valid PesqOP(_cOp,_cUnica) OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL

	@ 080, 004 SAY oSay3 PROMPT "Qtd. Etiqueta" SIZE 100, 012 OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
	@ 078, 100 MSGET oNrEtq VAR nNrEtiq Picture "@E 9999" SIZE 080, 010 OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL


	@ 140, 004 BUTTON oButton2 PROMPT "Imprimir" SIZE 037, 012 OF oDlg Action MsgRun("Imprimindo...",, { || ImpEtqPI(_cOP,nNrEtiq) }) PIXEL
	//oButton2:nClrPane := 0
	//oButton2:nClrtext := 16777215
	@ 140, 100 BUTTON oButton3 PROMPT "Sair" SIZE 037, 012 OF oDlg Action oDlg:End() PIXEL
	//oButton3:nClrPane := 0
	//oButton3:nClrtext := 16777215

	ACTIVATE MSDIALOG oDlg CENTERED


Return

/*
Pesquisa informações da etiqueta baseado na Ordem de produção
*/
Static Function PesqOP(_cOp,_cUnica)
	Local  _aArea 		:= GetArea()
	Local _cTitulo  	:= "Lista de Bases da Ordem de Produção" 
	Local _cAliasSGF	:=  GetNextAlias()
	Local _aCombo		:=  {}
	Local _aRet			:= {}  
	Local _nJ 			:= 0
	Local oDlg                  //Objeto Janela
	Local oLbx                  //Objeto List box

	If _cUnica = 'S'
		If SELECT (_cAliasSGF) > 0
			(_cAliasSGF)->(dbCloseArea())
		EndIf  
		
		BeginSql Alias _cAliasSGF

			SELECT
				D4_OP,D4_PRODUTO, D4_COD, D4_LOTECTL, D4_QUANT, GF_XETQMOV, C2_DATPRI 
			FROM SD4010 SD4 (NOLOCK)
			INNER JOIN SC2010 SC2 (NOLOCK) ON SC2.D_E_L_E_T_ = '' AND C2_NUM+C2_ITEM+C2_SEQUEN = D4_OP
			INNER JOIN SB1010 SB1 (NOLOCK) ON SB1.D_E_L_E_T_ = '' AND B1_COD = D4_COD AND B1_TIPO NOT IN ('EM')
			INNER JOIN SGF010 SGF (NOLOCK) ON SGF.D_E_L_E_T_ = '' AND GF_PRODUTO = D4_PRODUTO AND GF_COMP = D4_COD
			WHERE SD4.D_E_L_E_T_ = ''
			AND SD4.D4_OP = %Exp:_cOp%
			ORDER BY GF_XETQMOV, D4_COD
		EndSql
		
		DbSelectArea(_cAliasSGF)
		ProcRegua(RecCount())
		(_cAliasSGF)->(dbGoTOP())
		While !(_cAliasSGF)->(EOF()) 
			aAdd(_aItens, {(_cAliasSGF)->D4_OP, (_cAliasSGF)->D4_PRODUTO, (_cAliasSGF)->D4_COD,(_cAliasSGF)->D4_LOTECTL,(_cAliasSGF)->D4_QUANT,(_cAliasSGF)->GF_XETQMOV,(_cAliasSGF)->C2_DATPRI})	
			DbSelectArea(_cAliasSGF)
			(_cAliasSGF)->(DbSkip())
		EndDo
		(_cAliasSGF)->(DbCloseArea())
	ElseIf _cUnica = 'N'
		_aCombo := U_GerLista()
		If Len( _aCombo ) > 0

			DEFINE MSDIALOG oDlg TITLE _cTitulo FROM 0,0 TO 240,850 PIXEL
			
			@ 10,10 LISTBOX oLbx FIELDS HEADER "Código", "Descrição","Lote Base","Quant"  SIZE 390,95 OF oDlg PIXEL	 //"Campo"###"Titulo"

			oLbx:SetArray( _aCombo )
			oLbx:bLine     := {|| {_aCombo[oLbx:nAt,2], _aCombo[oLbx:nAt,3],oLbx:aArray[oLbx:nAt,4],oLbx:aArray[oLbx:nAt,5],oLbx:aArray[oLbx:nAt,6],oLbx:aArray[oLbx:nAt,7]}}
			oLbx:bLDblClick := {|| {oDlg:End(), _aRet := {oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3],oLbx:aArray[oLbx:nAt,4],oLbx:aArray[oLbx:nAt,5],oLbx:aArray[oLbx:nAt,6],oLbx:aArray[oLbx:nAt,7]}}} 	                   

			DEFINE SBUTTON FROM 107,160 TYPE 1 ACTION (oDlg:End(), _aRet := {oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3],oLbx:aArray[oLbx:nAt,4],oLbx:aArray[oLbx:nAt,5],oLbx:aArray[oLbx:nAt,6],oLbx:aArray[oLbx:nAt,7]})  ENABLE OF oDlg
			DEFINE SBUTTON FROM 107,200 TYPE 2 ACTION ( oDlg:End(), _aRet := {'','','','','',''}) ENABLE OF oDlg  
			ACTIVATE MSDIALOG oDlg CENTER
			
			If len(_aRet)>0 .and. _aRet[5] == 'A1'
				For _nJ := 1 to Len(_aCombo)
					If _aCombo[_nJ][6] == 'A1'
						aAdd(_aItens, { _aCombo[_nJ][1], _aCombo[_nJ][2],_aCombo[_nJ][3],_aCombo[_nJ][4],_aCombo[_nJ][5],_aCombo[_nJ][6],_aCombo[_nJ][7]})
					EndIf	
				Next
			ElseIf len(_aRet)>0 .and. _aRet[5] <> 'A1'
				aAdd(_aItens, { _cOp, _aRet[1],_aRet[2],_aRet[3],_aRet[4],_aRet[5],_aRet[6]})
			else
				_aItens	:= {}
			endIf
		EndIf	
	EndIf
	RestArea(_aArea)
Return (_aItens)

User Function GerLista()
	Local  _aArea 		:= GetArea()
	Local _aCombo		:={}
	Local _tAlias2		:=  GetNextAlias()
    
	If SELECT (_tAlias2) > 0
		(_tAlias2)->(dbCloseArea())
	EndIf  

	BeginSql Alias _tAlias2

		SELECT
			D4_OP,D4_PRODUTO, D4_COD, D4_LOTECTL, D4_QUANT, GF_XETQMOV, C2_DATPRI 
		FROM SD4010 SD4 (NOLOCK)
		INNER JOIN SC2010 SC2 (NOLOCK) ON SC2.D_E_L_E_T_ = '' AND C2_NUM+C2_ITEM+C2_SEQUEN = D4_OP
		INNER JOIN SB1010 SB1 (NOLOCK) ON SB1.D_E_L_E_T_ = '' AND B1_COD = D4_COD AND B1_TIPO NOT IN ('EM')
		INNER JOIN SGF010 SGF (NOLOCK) ON SGF.D_E_L_E_T_ = '' AND GF_PRODUTO = D4_PRODUTO AND GF_COMP = D4_COD
		WHERE SD4.D_E_L_E_T_ = ''
		AND SD4.D4_OP = %Exp:_cOp%
		ORDER BY  D4_COD
	EndSql

	DbSelectArea(_tAlias2)
	ProcRegua(RecCount())
	(_tAlias2)->(dbGoTOP())
	While !(_tAlias2)->(EOF())
		aAdd(_aCombo, {(_tAlias2)->D4_OP, (_tAlias2)->D4_PRODUTO, (_tAlias2)->D4_COD,(_tAlias2)->D4_LOTECTL, (_tAlias2)->D4_QUANT, (_tAlias2)->GF_XETQMOV, (_tAlias2)->C2_DATPRI })	
		DbSelectArea(_tAlias2)
		(_tAlias2)->(DbSkip())
	EndDo
	(_tAlias2)->(DbCloseArea())
	RestArea(_aArea)
Return _aCombo


/*
Imprime etiqueta termica
*/
Static Function ImpEtqPI(_cOP,nNrEtiq)

	Local _lRet := .T.
	Local _nX := 0
	Local _nL := 0
	Local _nY := 0
	_cPorta   := "LPT1:"
	_aArq := {}
	cQuant := Alltrim(Transform(nQuant,"@E 999,9999,999"))

	For _nX := 1 to Len(_aItens)
		If _aItens[_nX][6] == 'A1' .and. _lRet .and. _nY == 0
			For _nL := 1 to nNrEtiq 
				_nY := 0
				cDesc := Posicione("SB1",1,xFilial("SB1")+_aItens[_nX][2],"B1_DESC")
				MSCBPRINTER("ZEBRA",_cPorta,,210) //Seta tipo de impressora no padrao ZPL

				MSCBCHKStatus(.F.)
				MSCBBEGIN(1,4)
				MSCBSAY(010,010,Alltrim(cDesc), "N","C","40,0")
				MSCBLineH(010,018,100)
				//MSCBSAY(015,025,'CODIGO:', "N","C","35,0")
				//MSCBSAY(040,025,Alltrim(cProduto),"N","C","35,0",.T.)
				MSCBSAY(015,020,'OP DESTINO:', "N","C","35,0")
				MSCBSAY(055,020,Alltrim(_cOp),"N","C","35,0",.T.)

				MSCBSAY(015,026,'DATA PRODUCAO', "N","C","35,0")
				MSCBSAY(058,026,Substr(_aItens[_nX][7],7,2)+"/"+Substr(_aItens[_nX][7],5,2)+"/"+Substr(_aItens[_nX][7],1,4),"N","C","35,0")

				MSCBSAY(015,032,"VALIDADE","N","C","35,0",.T.) 
				MSCBSAY(055,032,"10 DIAS","N","C","35,0",.T.) 
				MSCBLineH(010,037,100)
				MSCBSAY(010,038,'COMPONENTES', "N","C","30,0")
				MSCBSAY(060,038,"LOTE","N","C","35,0",.T.) 

				_nLInha := 044
				For _nY := 1 to Len(_aItens)
					If _aItens[_nY][6] == 'A1'
						MSCBSAY(010,_nLInha,Alltrim(_aItens[_nY][3])+ "- ","N","C","35,0",.T.)
						//MSCBSAY(020,_nLInha,Alltrim(Posicione("SB1",1,xFilial("SB1")+_aItens[_nY][3],"B1_DESC")),"N","C","20,0",.T.)
						MSCBSAY(060,_nLInha,Alltrim(_aItens[_nY][4]),"N","C","35,0",.T.)
						//MSCBSAY(070,_nLInha,_aItens[_nY][5]/nNrEtiq,"N","C","20,0",.T.) 
						_nLInha += 005
					EndIf
				Next
				MSCBSAY(010,085,"RESPONSAVEL:","N","C","35,0",.T.) 
				MSCBSAY(050,085,AllTrim(UsrFullName(RetCodUsr())),"N","C","30,0",.T.) 

				MSCBEND()
				MSCBCLOSEPRINTER()		
			Next
		ElseIf !_aItens[_nX][6]$'A1/N/'
			For _nL := 1 to nNrEtiq 
				MSCBPRINTER("ZEBRA",_cPorta,,210) //Seta tipo de impressora no padrao ZPL

				MSCBCHKStatus(.F.)
				MSCBBEGIN(1,4)
				MSCBSAY(015,010,Alltrim(Posicione("SB1",1,xFilial("SB1")+_aItens[_nX][3],"B1_DESC")), "N","C","40,0")
				MSCBLineH(010,018,100)
				MSCBSAY(015,025,'CODIGO:', "N","C","35,0")
				MSCBSAY(040,025,Alltrim(_aItens[_nX][3]),"N","C","35,0",.T.)
				
				MSCBSAY(015,032,'LOTE ORIGEM:', "N","C","35,0")
				MSCBSAY(055,032,Alltrim(_aItens[_nX][4]),"N","C","35,0",.T.)
				MSCBLineH(010,037,100)

				MSCBSAY(015,039,'OP DESTINO:', "N","C","35,0")
				MSCBSAY(055,039,Alltrim(_cOp),"N","C","35,0",.T.)

				MSCBSAY(015,046,'DATA PRODUCAO', "N","C","35,0")
				MSCBSAY(058,046,Substr(_aItens[_nX][7],7,2)+"/"+Substr(_aItens[_nX][7],5,2)+"/"+Substr(_aItens[_nX][7],1,4),"N","C","35,0")

				MSCBSAY(015,053,"VALIDADE","N","C","35,0",.T.) 
				MSCBSAY(055,053,"10 DIAS","N","C","35,0",.T.) 

				//MSCBSAY(015,060,"QUANTIDADE","N","C","35,0",.T.) 
				//MSCBSAY(055,060,cValtoChar(_aItens[_nX][5]/nNrEtiq),"N","C","35,0",.T.) 
				//MSCBSAY(055,060,Alltrim(Transform(_aItens[_nX][5]/nNrEtiq,"@E 999,9999.999999")),"N","C","35,0",.T.) 

				MSCBSAY(010,080,"RESPONSAVEL:","N","C","35,0",.T.) 
				MSCBSAY(050,080,AllTrim(UsrRetName(RetCodUsr())),"N","C","30,0",.T.) 

				MSCBEND()
				MSCBCLOSEPRINTER()		
						
			Next
		EndIf
		_lRet := .F.
	Next
	nNrEtiq := 0
	_aItens	:= {}
	oNrEtq:Refresh()
Return





