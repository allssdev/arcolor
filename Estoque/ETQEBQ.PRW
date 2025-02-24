#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"

/*/{Protheus.doc} 
@description Etiqueta da produção para embarque
@author		Diego Rodrigues Pereira email: diego.rodrigues@allss.com.br
@since 		16/08/2022
@version 	1.01
@see 		https://allss.com.br
@History 	Data 01/11/2022 - Inclusão de melhorias na montagem das informações da etiqueta, criação de mensagems de alerta,
@History 	Data 13/02/2023 - Ajustes no posicionamento da etiqueta 
@History 	Data 16/04/2023 - Arrendondamento do numero de etiquetas a serem impressas.

/*/
user function ETQEBQ() 
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

	Private cOp  := Criavar("C2_NUM")
	Private cProduto := CriaVar("B1_COD")
	Private cDesc    := CriaVar("B5_XDESCET")
    Private cCor   := CriaVar("B5_XCORETQ")
	Private cUniMed  := CriaVar("B1_UM")
	Private cLote    := Criavar("B8_LOTECTL")
	Private nPeso    := Criavar("B1_PESO")
	Private dData    := CtoD("//")
	Private dDtValid := "       "
	Private nNrEtiq  := Criavar("DT6_QTDVOL")
	Private cCodBar  := Criavar("B1_CODBAR")
	Private cQrCode := Criavar("C2_XLOTE")
    Private nQuant  := Criavar("C2_QUJE")
    Private cMod  := Criavar("B5_XMODETQ")
	Private nVolume := Criavar("B1_CONV") 
	Private nImpr := 0
   


	DEFINE MSDIALOG oDlg TITLE ":::... Impressão de etiquetas de embarque ...:::" FROM 000, 000  TO 500, 700 COLORS 0, 16777215 PIXEL

	@ 008, 008 SAY oSay1 PROMPT "Etiqueta Embarque" SIZE 182, 017 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
	
	@ 040, 004 SAY oSay2 PROMPT "Ordem de Produção" SIZE 100, 010 OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
	@ 038, 100 MSGET oNF VAR cOp Picture "@!" SIZE 60, 010 Valid PesqOP(cOP) OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL

	@ 060, 004 SAY oSay2 PROMPT "Produto" SIZE 100, 010 OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
	@ 058, 100 MSGET oProduto VAR cProduto  SIZE 150, 010 OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL READONLY WHEN .F.

	@ 080, 004 SAY oSay3 PROMPT "Descrição" SIZE 100, 012 OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
	@ 078, 100 MSGET oDesc VAR cDesc SIZE 200, 010 OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL READONLY WHEN .F.

	@ 100, 004 SAY oSay3 PROMPT "Volume" SIZE 100, 010 OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
	@ 098, 100 MSGET oQuant VAR nVolume  SIZE 060, 010 OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL READONLY WHEN .F.

    @ 120, 004 SAY oSay3 PROMPT "Lote" SIZE 100, 010 OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
	@ 118, 100 MSGET oLote VAR cLote SIZE 060, 010 OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL READONLY WHEN .F.

   	@ 120, 170 SAY oSay3 PROMPT "Cor/Sabor" SIZE 100, 010 OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
	@ 118, 220 MSGET oCor VAR cCor  SIZE 100, 010 OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL READONLY WHEN .F.

	@ 140, 004 SAY oSay3 PROMPT "Validade" SIZE 100, 010 OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
	@ 138, 100 MSGET oDtValid VAR dDtValid SIZE 070, 010 OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL READONLY WHEN .F.

	@ 140, 170 SAY oSay3 PROMPT "Mod. Etiqueta" SIZE 100, 010 OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL 
	@ 138, 235 MSGET oMod VAR cMod  SIZE 075, 010 OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL READONLY WHEN .F.

    @ 160, 180 SAY oSay3 PROMPT "Peso" SIZE 100, 010 OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
	@ 158, 200 MSGET oPeso VAR nPeso  SIZE 060, 010 OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL READONLY WHEN .F.

	@ 180, 004 SAY oSay3 PROMPT "Qtd. Etiqueta" SIZE 100, 012 OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
	@ 178, 100 MSGET oNrEtq VAR nNrEtiq Picture "@E 9999" SIZE 060, 010 OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL


	@ 238, 004 BUTTON oButton2 PROMPT "Imprimir" SIZE 037, 012 OF oDlg Action MsgRun("Imprimindo...",, { || ImpEtqEBQ(cProduto,cLote,dData,dDtValid,cMod,cOp,cDesc,cUniMed,cCodBar,cQrCode,nQuant,nPeso,cCor,nVolume,nNrEtiq) }) PIXEL
	oButton2:nClrPane := 0
	oButton2:nClrtext := 16777215
	@ 238, 100 BUTTON oButton3 PROMPT "Sair" SIZE 037, 012 OF oDlg Action oDlg:End() PIXEL
	oButton3:nClrPane := 0
	oButton3:nClrtext := 16777215

	ACTIVATE MSDIALOG oDlg CENTERED


Return

/*
Imprime etiqueta termica
*/
Static Function ImpEtqEBQ(cProduto,cLote,dData,dDtValid,cMod,cOp,cDesc,cUniMed,cCodBar,cQrCode,nQuant,nPeso,cCor,nVolume,nNrEtiq)

	Local nL := 0
	//Local cVolume := nVolume
	
	_cPorta   := "LPT1:"
	_aArq := {}
	cQuant := Alltrim(Transform(nVolume,"@E 999,9999,999"))
	If AT( ".",cvaltochar(nPeso))+1 == 1
		cPeso := Alltrim(Transform(nPeso,"@E 999"))
	Else
		cPeso := Alltrim(Transform(nPeso,"@E 999.9"))
    Endif
	DbSelectArea("SB5")
	DbSetOrder(1)
	If DbSeek(xFilial("SB5") + cProduto)
		cMod := SB5->B5_XMODETQ
	EndIf

	MSCBPRINTER("ZEBRA",_cPorta,,210) //Seta tipo de impressora no padrao ZPL

	If Substr(cMod,1,1) == "1"
		For nL := 1 to nNrEtiq 

			MSCBCHKStatus(.F.)
			MSCBBEGIN(1,4)

			//MSCBBOX(15,03,87,208)
			//MSCBBOX(74,03,87,208,100)
			MSCBSAY(022,002,Alltrim(cDesc),"R","C","43,0",.T.) 
			//MSCBSAY(016,018,Alltrim(cCor),"R","C","030,0",.T.)
			MSCBSAY(018,002,Alltrim(cCor),"R","C","27.5,0",.T.) 
			MSCBSAY(015,002,'CONTEM ' + Alltrim(cQuant) + ' UNIDADES ' + Alltrim(cPeso) +" "+ Alltrim(cUniMed) ,"R","C","26,0")

			MSCBSAYBAR(007,002,ALLTRIM(cCodBar),"R","MB07",7.36,.F.,.F.,.F.,,2,1)
            MSCBSAY(004,002,Alltrim(cCodBAr),"R","C","010,0")
			
			MSCBSAYBAR(002,053,ALLTRIM(cLote),"N","MB07",3.36,.F.,.F.,.F.,,1.5,0.5) 
			MSCBSAY(002,057,'Lote: '+ Alltrim(cLote),"N","C","010,0")
			//MSCBSAY(001,002,'Val: ' + Substr(Alltrim(dDtValid),5,2)+'/'+Substr(Alltrim(dDtValid),1,4),"R","C","010,0")
			MSCBSAY(001,002,'Val: ' + dDtValid,"R","C","010,0")
			
			MSCBEND()
			

	
		Next nL
		MSCBCLOSEPRINTER()
		
	ElseIf Substr(cMod,1,1) == "2"
		For nL := 1 to nNrEtiq

			MSCBCHKStatus(.F.)
			MSCBBEGIN(1,4)

			//MSCBBOX(15,03,87,208)
			//MSCBBOX(74,03,87,208,100)
			MSCBSAY(027,005,Alltrim(cDesc),"R","C","44,0",.T.)
			//MSCBSAY(021,030,Alltrim(cCor),"R","B","035,0",.T.)
			MSCBSAY(021,005,Alltrim(cCor),"R","C","30,0",.T.)
			MSCBSAY(016,005,'CONTEM ' + Alltrim(cQuant) + ' UNIDADES ' + Alltrim(cPeso) +" "+ Alltrim(cUniMed) ,"R","C","27,0")

			MSCBSAYBAR(007,005,ALLTRIM(cCodBar),"R","MB07",8.36,.F.,.F.,.F.,,2,1)
            MSCBSAY(004,005,Alltrim(cCodBAr),"R","C","015,0")
			
			MSCBSAYBAR(007,060,ALLTRIM(cLote),"R","MB07",5.36,.F.,.F.,.F.,,2,1)
			MSCBSAY(004,060,'Lote: '+ Alltrim(cLote),"R","C","015,0")
			//MSCBSAY(001,005,'Val: ' + Substr(Alltrim(dDtValid),5,2)+'/'+Substr(Alltrim(dDtValid),1,4),"R","C","015,0")
			MSCBSAY(001,005,'Val: ' + dDtValid,"R","C","010,0")
			
			MSCBEND()

		Next nL
		MSCBCLOSEPRINTER()
	
	EndIf

	nImpr := nImpr+1

	DbSelectArea("SC2")
	DbSetOrder(1)
	If DbSeek(xFilial("SC2") + cOp)
		Reclock("SC2",.F.)
		SC2->C2_XNIMPR := nImpr
		MsUnlock()
	EndIf

	cProduto := ""
    nQuant := 0
	cLote := ""
	dData := CtoD("//")
	dDtValid := CtoD("/")
	nNrEtiq := 0
	
	oProduto:Refresh()
	oLote:Refresh()
    oQuant:Refresh()
	//oData:Refresh()
	oDtValid:Refresh()
	oNrEtq:Refresh()
	oProduto:SetFocus()

	

Return

/*
Pesquisa informações da etiqueta baseado na Ordem de produção
*/

Static Function PesqOp(cOp)
    
    Local cQry := GetNextAlias()
    cDesc := ""
	cCodProd := ""
	aProdSelec := {""}
	cOP := cOp

    BeginSql Alias cQry
		SELECT
			C2_NUM 	 ,C2_QUANT   ,C2_EMISSAO
			,B1_COD  ,B5_XDESCET ,B5_XCORETQ
			,C2_XLOTE,C2_XDTVALI ,B1_CODBAR
			,B1_CODBAR2 ,B1_CONV ,B1_UM
			,B5_XMODETQ	,B5_XUMETQ,B5_XEANETQ
			,B1_PESO
			,RTRIM(REPLACE(CAST(DATEADD(DAY,(B1_PRVALID),C2_EMISSAO) AS DATE),'-','')) VALIDADE
			//,SUBSTRING(B8_DTVALID,7,2) + "/" + SUBSTRING(B8_DTVALID,5,2) + "/" + SUBSTRING(B8_DTVALID,1,4) as DTVALID
		FROM
			%Table:SC2% SC2 (NOLOCK)
			INNER JOIN %Table:SB5% SB5 (NOLOCK) ON SC2.C2_PRODUTO = SB5.B5_COD AND SB5.%NotDel%
			INNER JOIN %Table:SB1% SB1 (NOLOCK) ON SC2.C2_PRODUTO = SB1.B1_COD AND SB1.B1_TIPO = 'PA' AND SB1.%NotDel%
		WHERE
			SC2.C2_FILIAL = %Xfilial:SC2%
			AND SC2.C2_NUM = %Exp:cOP%
			AND SC2.%NotDel%
	
	EndSql

	DbSelectArea("SC2")
	DbSetOrder(1)
	If DbSeek(xFilial("SC2") + cOP)
	    
        cProduto := Alltrim(SC2->C2_PRODUTO)
		cDesc := Alltrim((cQry)->B5_XDESCET)
        cCor := Alltrim((cQry)->B5_XCORETQ)
		cLote := (cQry)->C2_XLOTE
		cCodBar := IIf ((cQry)->B5_XEANETQ = '1',(cQry)->B1_CODBAR2,(cQry)->B1_CODBAR)
		dDtValid := AnoMes(C2_XDTVALID)
		dDtValid := Substr(Alltrim(dDtValid),5,2)+'/'+Substr(Alltrim(dDtValid),1,4) //dDtValid := DAYSUM(SC2->C2_DATPRF,POSICIONE("SB1",1,xFilial("SB1") + SC2->C2_PRODUTO,"B1_PRVALID")) 
		cQrCode	 := (cQry)->C2_XLOTE
		nVolume	 := (cQry)->B1_CONV
		cMod	 := (cQry)->B5_XMODETQ 
        nQuant := (cQry)->C2_QUANT
		dData := SC2->C2_DATPRF
        cUniMed := (cQry)->B5_XUMETQ
        nPeso := (cQry)->B1_PESO
		nNrEtiq := Ceiling((cQry)->C2_QUANT / (cQry)->B1_CONV)
		nImpr := SC2->C2_XNIMPR
		
		oProduto:cText := cProduto 
		oDesc:cText := Alltrim(cDesc)
		oQuant:cText:= nVolume
		oPeso:cText:=nPeso
		oCor:cText := Alltrim(cCor)
		oDtValid:cText := dDtValid
		
		If SC2->C2_XNIMPR >= 1
			oNrEtq:cText:= 0
		Else
			oNrEtq:cText:=nNrEtiq
		EndIf
		
		DbSelectArea("SB5")
		DbSetOrder(1)
		If DbSeek(xFilial("SB5") + cProduto)
			cMod := SB5->B5_XMODETQ
		EndIf

		If cMod = "1"
			cMod := "1=Mod 2145-P"
		Else
			cMod := "2=Mod 0990-G"
		EndIf

		If nPeso < 1
			nPeso := nPeso*1000 
		EndiF

		If nImpr >= 1 
		Msginfo("A ordem de produção "+cOP+ " já foi impressa " +Alltrim(Transform(nImpr,"@E 99"))+ " vezes","Aviso")
		EndIf

		If Empty(cLote)
		Msginfo("A ordem de produção "+cOP+ " está com o lote em branco","ATENÇÃO")
		EndIf
	EndIf

	
	oDesc:Refresh()
    oQuant:Refresh()
	oDtValid:Refresh()
	oNrEtq:Refresh()
	oProduto:Refresh()
	oProduto:SetFocus()

Return()

/*
Valida data de validade
*/
Static Function ValDt(dDtValid)
	Local lRet := .T.

	If dDtValid <= dDataBase
		lRet := .F.
	EndIf
Return(lRet)

