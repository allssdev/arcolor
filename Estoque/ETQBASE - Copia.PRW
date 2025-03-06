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
user function ETQBASE() 
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
	Private cProduto := CriaVar("B1_COD")
	Private cDesc    := CriaVar("B1_DESC")
	Private cLote    := Criavar("B8_LOTECTL")
	Private dData    := CtoD("//")
	Private nNrEtiq  := Criavar("DT6_QTDVOL")
    Private nQuant  := Criavar("D4_QUANT")
	Private nImpr := 0
   


	DEFINE MSDIALOG oDlg TITLE ":::... Impressão de etiquetas Produtos Intermediarios ...:::" FROM 000, 000  TO 500, 700 COLORS 0, 16777215 PIXEL

	@ 008, 008 SAY oSay1 PROMPT "Etiqueta Produtos Intermediarios" SIZE 182, 017 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
	
	@ 040, 004 SAY oSay2 PROMPT "Ordem de Produção" SIZE 100, 010 OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
	@ 038, 100 MSGET oNF VAR _cOp Picture "@!" SIZE 60, 010 Valid PesqOP(_cOp) OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL

	@ 060, 004 SAY oSay2 PROMPT "Produto" SIZE 100, 010 OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
	@ 058, 100 MSGET oProduto VAR cProduto  SIZE 150, 010 OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL READONLY WHEN .F.

	@ 080, 004 SAY oSay3 PROMPT "Descrição" SIZE 100, 012 OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
	@ 078, 100 MSGET oDesc VAR cDesc SIZE 200, 010 OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL READONLY WHEN .F.

	@ 100, 004 SAY oSay3 PROMPT "Quantidade" SIZE 100, 010 OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
	@ 098, 100 MSGET oQuant VAR nQuant  SIZE 060, 010 OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL READONLY WHEN .F.

    @ 120, 004 SAY oSay3 PROMPT "Lote" SIZE 100, 010 OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
	@ 118, 100 MSGET oLote VAR cLote SIZE 060, 010 OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL READONLY WHEN .F.

	@ 140, 004 SAY oSay3 PROMPT "Qtd. Etiqueta" SIZE 100, 012 OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
	@ 138, 100 MSGET oNrEtq VAR nNrEtiq Picture "@E 9999" SIZE 060, 010 OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL


	@ 218, 004 BUTTON oButton2 PROMPT "Imprimir" SIZE 037, 012 OF oDlg Action MsgRun("Imprimindo...",, { || ImpEtqPI(cProduto,cLote,dData,_cOp,cDesc,nQuant,nNrEtiq) }) PIXEL
	oButton2:nClrPane := 0
	oButton2:nClrtext := 16777215
	@ 218, 100 BUTTON oButton3 PROMPT "Sair" SIZE 037, 012 OF oDlg Action oDlg:End() PIXEL
	oButton3:nClrPane := 0
	oButton3:nClrtext := 16777215

	ACTIVATE MSDIALOG oDlg CENTERED


Return

/*
Pesquisa informações da etiqueta baseado na Ordem de produção
*/

Static Function PesqOp(_cOp)
    
Local _aRet		:= {}       //Array do retorno da opcao selecionada
	Local _cTitulo  := "Lista de Bases da Ordem de Produção" 	 
	Local _aCombo	:=  {}
	Local oDlg                  //Objeto Janela
	Local oLbx                  //Objeto List box
	Local _pArea	:= GetArea()
	Private _cCod 	:= " "   
	Private _cLote  := " "
//If MsgYesNo("Deseja selecionar um produto especifico?")

	_aCombo := U_GerLista()
	If Len( _aCombo ) > 0

		DEFINE MSDIALOG oDlg TITLE _cTitulo FROM 0,0 TO 240,850 PIXEL
		
		@ 10,10 LISTBOX oLbx FIELDS HEADER "Código", "Descrição","Lote Base","Quant"  SIZE 390,95 OF oDlg PIXEL	 //"Campo"###"Titulo"

		{(_tAlias2)->D4_OP, (_tAlias2)->D4_PRODUTO, (_tAlias2)->D4_COD,(_tAlias2)->D4_LOTECTL, (_tAlias2)->D4_QUANT, (_tAlias2)->GF_XETQMOV, (_tAlias2)->C2_DATPRI })	
		
		oLbx:SetArray( _aCombo )
		oLbx:bLine     := {|| {_aCombo[oLbx:nAt,2], _aCombo[oLbx:nAt,3],oLbx:aArray[oLbx:nAt,4],oLbx:aArray[oLbx:nAt,5],oLbx:aArray[oLbx:nAt,6],oLbx:aArray[oLbx:nAt,7]}}
		oLbx:bLDblClick := {|| {oDlg:End(), _aRet := {oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3],oLbx:aArray[oLbx:nAt,4],oLbx:aArray[oLbx:nAt,5],oLbx:aArray[oLbx:nAt,6],oLbx:aArray[oLbx:nAt,7]}}} 	                   

		DEFINE SBUTTON FROM 107,160 TYPE 1 ACTION (oDlg:End(), _aRet := {oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3],oLbx:aArray[oLbx:nAt,4],oLbx:aArray[oLbx:nAt,5],oLbx:aArray[oLbx:nAt,6],oLbx:aArray[oLbx:nAt,7]})  ENABLE OF oDlg
		DEFINE SBUTTON FROM 107,200 TYPE 2 ACTION ( oDlg:End(), _aRet := {'','',''}) ENABLE OF oDlg  
		ACTIVATE MSDIALOG oDlg CENTER
		
		If len(_aRet)>0
			cProduto := _aRet[1]
			cComp	 := _aRet[2]
			cLote 	 := _aRet[3] 
			//cDtValid :=  "10 Dias"
			nQuant 	 := Alltrim(Transform( _aRet[4],"@E 99,999.999999"))
			dData	 := Dtos(POSICIONE("SC2",1,XFILIAL("SC2")+Substr(_cOp,1,6),"C2_DATPRF"))
			
			oProduto:cText := cProduto 
			oDesc:cText := Alltrim(cDesc)
			oQuant:cText:= nQuant

			oDesc:Refresh()
			oQuant:Refresh()
			oProduto:Refresh()
			oProduto:SetFocus()
		else
			_cCod := ""
			_cLote:= ""
		endIf
	EndIf	
RestArea(_pArea)
Return _aRet   

Return()

User Function GerLista()
	Local _aCombo	:={}
	Local _cQry 	:= " "
	Local _tAlias2	:=  "LISTA"
    Local  _aArea := GetArea()

	If SELECT (_tAlias2) > 0
		(_tAlias2)->(dbCloseArea())
	EndIf  

	If SELECT (_cAliasSGF) > 0
		(_cAliasSGF)->(dbCloseArea())
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
		ORDER BY GF_XETIQUE, D4_COD
	EndSql

	DbUseArea(.T., "TOPCONN ",TcGenQry(,,_cQry),_tAlias2,.T.,.F.)
	DbSelectArea(_tAlias2)
	ProcRegua(RecCount())
	(_tAlias2)->(dbGoTOP())
	While !(_tAlias2)->(EOF())	.and. !empty((_tAlias2)->DESC_PI)	
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
Static Function ImpEtqPI(cProduto,cLote,dData,_cOp,cDesc,nQuant,nNrEtiq)

	
	_cPorta   := "LPT1:"
	_aArq := {}
	cQuant := Alltrim(Transform(nQuant,"@E 999,9999,999"))

	MSCBPRINTER("ZEBRA",_cPorta,,210) //Seta tipo de impressora no padrao ZPL

	MSCBCHKStatus(.F.)
	MSCBBEGIN(1,4)
    MSCBSAY(015,010,Alltrim(cDesc), "N","C","60,0")
	MSCBSAY(015,025,'CODIGO:', "N","C","35,0")
	MSCBSAY(040,025,Alltrim(cProduto),"N","C","35,0",.T.)
	
	MSCBSAY(015,032,'LOTE ORIGEM:', "N","C","35,0")
	MSCBSAY(055,032,Alltrim(cLote),"N","C","35,0",.T.)
	MSCBLineH(010,037,100)

	MSCBSAY(015,039,'OP DESTINO:', "N","C","35,0")
	MSCBSAY(055,039,Alltrim(_cOp),"N","C","35,0",.T.)

	MSCBSAY(015,046,'DATA PRODUCAO', "N","C","35,0")
	MSCBSAY(058,046,Substr(dData,7,2)+"/"+Substr(dData,5,2)+"/"+Substr(dData,1,4),"N","C","35,0")

	MSCBSAY(015,053,"VALIDADE","N","C","35,0",.T.) 
	MSCBSAY(055,053,"10 DIAS","N","C","35,0",.T.) 

	MSCBSAY(015,060,"QUANTIDADE","N","C","35,0",.T.) 
	MSCBSAY(055,060,nQuant,"N","C","35,0",.T.) 

	MSCBSAY(010,080,"RESPONSAVEL:","N","C","35,0",.T.) 
	MSCBSAY(050,080,AllTrim(UsrRetName(RetCodUsr())),"N","C","30,0",.T.) 

	MSCBEND()
	MSCBCLOSEPRINTER()		
			
	cProduto := ""
    nQuant := 0
	cLote := ""
	dData := CtoD("//")
	nNrEtiq := 0
	
	oProduto:Refresh()
	oLote:Refresh()
    oQuant:Refresh()
	oNrEtq:Refresh()
	oProduto:SetFocus()

Return

