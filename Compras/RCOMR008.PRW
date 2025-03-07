#include 'totvs.ch'
#include 'protheus.ch'
#include 'fwprintsetup.ch'
#include 'rptdef.ch'
#define DMPAPER_A4 9

/*/{Protheus.doc} RCOMR008
Rotina para impress�o das etiquetas de identifica��o das entradas
@author Livia Della Corte
@since 06/06/2023
@version 1.0
@type function
@see https://allss.com.br
/*/

user function RCOMR008()

	Local _SavArea		:= GetArea()
	Local _nY
	Local _cCadastro	:= OemtoAnsi("Etiqueta de Identifica��o Entradas")
	Local _aMensagem	:={}
	Local _aBotoes   	:={}
	local lImp:= .f.
	//Local nPos		:= 0
	//Local cCRLF     	:= (chr(13) + chr(10) )
	Private _cRotina  	:= "RCOMR008"
	Private _aCombo		:= {}
	Private _cPerg   	:= "RCOMR008"
	Private _nTipo 		:= 9999
	PRIVATE _cDirRel    :=  AllTrim(SuperGetMv("MV_DIREST8",,"C:\Etiqueta_Entrada\"))  
	PRIVATE _cNota		:= ""
	PRIVATE _cSerie		:= ""
	PRIVATE _cFornece	:= ""
	PRIVATE _cLoja 		:= ""
	Private _cProd 		:=""
	PRIVATE _cLote		:="(Sem Lote definido)"
	Private _cCodBar 	:= ""
	Private _cAlerge 	:= ""
	//Private _nOpc 		:= 1

	default _nOpc 		:= 1
	U_ValPerg()
	If _nOpc ==1 .and. (SF1->F1_DOC != Nil .AND. !EMPTY(SF1->F1_DOC)) .AND. (SF1->F1_SERIE != Nil  )  .AND. (SF1->F1_FORNECE != Nil .and. !EMPTY(SF1->F1_FORNECE) ) .AND. (SF1->F1_LOJA != Nil .and. !EMPTY(SF1->F1_LOJA) )
		_cNota	 :=  MV_PAR01 := alltrim(SF1->F1_DOC)
		_cSerie	 :=  MV_PAR02 := alltrim(SF1->F1_SERIE)
		_cFornece :=  MV_PAR03 := alltrim(SF1->F1_FORNECE)
		_cLoja	 :=  MV_PAR04 := alltrim(SF1->F1_LOJA)				
	endIf

	If _nOpc==1 
		AADD(_aMensagem,OemToAnsi("Etiqueta de Identifica��o Entradas, para nota selecionada no Browse") ) 
		AADD(_aMensagem,OemToAnsi("Nota: "+ alltrim(SF1->F1_DOC) + " S�rie: " + alltrim(SF1->F1_SERIE)+"." ))
		AADD(_aMensagem,OemToAnsi(" "))
		AADD(_aMensagem,OemToAnsi(" "))
		AADD(_aMensagem,OemToAnsi(" "))
		AADD(_aMensagem,OemToAnsi("Acesse o botao de parametros, caso queira alterar."))
		AADD(_aBotoes, { 5,.T.,{||  Pergunte(_cPerg,.T. ) }})
		//AADD(_aBotoes, { 6,.T.,{|o|  _cProd:= u_PesqPrd(),FechaBatch()}})
		AADD(_aBotoes, { 6,.T.,{|o|FechaBatch() }})
		AADD(_aBotoes, { 2,.T.,{|o|FechaBatch() }} )
		FormBatch( _cCadastro, _aMensagem, _aBotoes )
	Else
		Pergunte(_cPerg,.T. )
		AADD(_aMensagem,OemToAnsi("Defina a NF/Serie/Fornecedor para Gera��o da Etiqueta!") ) 
		AADD(_aMensagem,OemToAnsi(" "))
		AADD(_aMensagem,OemToAnsi(" "))
		AADD(_aMensagem,OemToAnsi(" "))
		//AADD(_aBotoes, { 5,.T.,{||  Pergunte(_cPerg,.T. ), _cProd:= U_PesqPrd()}})
		AADD(_aBotoes, { 5,.T.,{||  Pergunte(_cPerg,.T. )}})
		AADD(_aBotoes, { 6,.T.,{|o| _nOpc := 1,FechaBatch()}})
		AADD(_aBotoes, { 2,.T.,{|o| FechaBatch() }} )
		FormBatch( _cCadastro, _aMensagem, _aBotoes )
	endIf

	If !ExistDir(_cDirRel)
		If MakeDir(_cDirRel) == 0
			MakeDir(_cDirRel)
		ENDIF
	EndIf

	If !EMPTY(MV_PAR01) .and. _nOpc<>1 
		_cNota:= alltrim(MV_PAR01)
		_cSerie:= alltrim(MV_PAR02)
		_cFornece:= alltrim(MV_PAR03)	
		_cLoja:= alltrim(MV_PAR04)	
	EndIf

	If !EMPTY(_cNota)
		_aCombo:=U_GerComBo()
		For _nY:=1 to Len(_aCombo)	
			_aProd:= u_PesqPrd()
			If Empty(_aProd)
				RETURN()
			Else
				lImp:= U_fQuery(_aProd)
				if lImp
					MsgAlert( "Arquivos Salvos em: " +_cDirRel )
				endIf
			EndIf
		next
	else	
		MsgAlert( "Defina a nota nos parametro!" )	
		Pergunte("MTA140",.F.)
		Return()
	endIf

RestArea(_SavArea)
Pergunte("MTA140",.F.)
Return

User Function fQuery(_aProd)
	Local _cQry   	:= " "
	Local _tAlias 	:=  "RCOMR008"
	Local _faArea   := GetArea()
	Local _nItem   	:= 1
	Local _nTot   	:= 1
	Local _cPrdExc 	:= SUPERGETMV( "MV_XPRDEXS",,"2295")
	Local _cInfFat 	:= Space(254)
	local _lF       := .t.
	Local oDlg1	   	:= Nil
	Local oInfFat  	:= Nil

	If SELECT (_tAlias) > 0
		(_tAlias)->(dbCloseArea())
	EndIf  


	if len(_aProd)>0
			_cProd  := _aProd[1]
			_cLote := iif(!empty(_aProd[3]),_aProd[3]	,)
	endIf

    _cQry :=  " SELECT D1_COD D1_COD"
    _cQry +=  " , B1_DESC B1_DESC"
    _cQry +=  " , B1_UM B1_UM"
	_cQry +=  " , B1_CODBAR B1_CODBAR"
	_cQry +=  " , B5_XALERGE B5_XALERGE"
    _cQry +=  " , SUM(D1_QUANT) D1_QUANT"
    _cQry +=  " , D1_LOTECTL D1_LOTECTL"
	_cQry +=  " , D1_LOTEFOR D1_LOTEFOR"
    _cQry +=  " , D1_DTDIGIT D1_DTDIGIT"
    _cQry +=  " , D1_FORNECE + ' - ' + D1_LOJA D1_FORNECE"
	_cQry +=  " , A2_NOME A2_NOME"
    _cQry +=  " , D1_DTVALID D1_DTVALID"
	_cQry +=  " ,  (SELECT count(distinct D1_COD) from SD1010    "
	_cQry +=  "			 where D1_DOC = '" 		+ AllTrim(_cNota) + "' "
	_cQry +=  " 				AND D1_SERIE = '"	+ AllTrim(_cSerie) + "' "
	_cQry +=  "  				AND D1_FORNECE = '"	+ AllTrim(_cFornece) + "' "
	If !empty(_cProd)
		_cQry +=  "  	AND D1_COD = '"	+ AllTrim(_cProd) + "' "
		If !empty(_cLote) .and. _cLote <> "(Sem Lote definido)"
			_cQry +=  "  	AND D1_LOTECTL = '"	+ AllTrim(_cLote) + "' "
		EndIf
	EndIf
    _cQry +=  "  				AND D1_LOJA = '"	+ AllTrim(_cLoja) + "' ) CONTADOR "
    _cQry +=  " from " + RetSqlName("SD1") + " SD1 (NOLOCK) "
    _cQry +=  " INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK)  ON B1_COD = D1_COD AND SB1.D_E_L_E_T_ = '' "
    _cQry +=  " INNER JOIN " + RetSqlName("SA2") + " SA2 (NOLOCK)  ON  A2_COD = D1_FORNECE AND A2_LOJA = D1_LOJA AND SA2.D_E_L_E_T_ = '' " 
	_cQry +=  " LEFT JOIN " + RetSqlName("SB5") + " SB5 (NOLOCK)  ON B5_COD = D1_COD AND SB5.D_E_L_E_T_ = '' "
    _cQry +=  " where D1_DOC = '" 		+ AllTrim(_cNota) + "' "
	_cQry +=  " 	AND D1_SERIE = '"	+ AllTrim(_cSerie) + "' "
	_cQry +=  "  	AND D1_FORNECE = '"	+ AllTrim(_cFornece) + "' "
    _cQry +=  "  	AND D1_LOJA = '"	+ AllTrim(_cLoja) + "' "
	_cQry +=  "     AND SD1.D_E_L_E_T_ = '' " 
	If !empty(_cProd)
	    _cQry +=  "  	AND D1_COD = '"	+ AllTrim(_cProd) + "' "
		If !empty(_cLote) .and. _cLote <> "(Sem Lote definido)"
			_cQry +=  "  	AND D1_LOTECTL = '"	+ AllTrim(_cLote) + "' "
		EndIf
	EndIf
    _cQry +=  "GROUP BY D1_COD , B1_DESC, B1_UM, B1_CODBAR,B5_XALERGE, D1_LOTECTL, D1_LOTEFOR, D1_DTDIGIT, D1_DTVALID, D1_FORNECE + ' - ' + D1_LOJA, A2_NOME"
	dbUseArea(.T., "TOPCONN ",TcGenQry(,,_cQry),_tAlias,.T.,.F.)

	dbSELECTArea(_tAlias)
	ProcRegua(RecCount())
	(_tAlias)->(dbGoTOP())
	 _nTot :=(_tAlias)->CONTADOR

	If _nTot > 0
		While !(_tAlias)->(EOF()) .and. _nItem <= _nTot
			_cTot        	:= (_tAlias)->CONTADOR
			_cProduto		:= alltrim((_tAlias)->D1_COD)
			_cDescricao		:= alltrim((_tAlias)->B1_DESC)
			_cQuant			:= ROUND((_tAlias)->D1_QUANT,2)
			_cCodCli		:= alltrim((_tAlias)->D1_FORNECE)
			_cNomeCli		:= alltrim((_tAlias)->A2_NOME)
			_cEntrada		:=  iif((_tAlias)->D1_DTDIGIT<> " ",Substr((_tAlias)->D1_DTDIGIT,7,2)+"/"+Substr((_tAlias)->D1_DTDIGIT,5,2)+"/"+Substr((_tAlias)->D1_DTDIGIT,1,4),"")
			_cValidade		:= iif((_tAlias)->D1_DTVALID<> " ", Substr((_tAlias)->D1_DTVALID,7,2)+"/"+Substr((_tAlias)->D1_DTVALID,5,2)+"/"+Substr((_tAlias)->D1_DTVALID,1,4),"")
			_cLote	    	:= alltrim((_tAlias)->D1_LOTECTL)
			_cLoteFor		:= alltrim((_tAlias)->D1_LOTEFOR)
			_cUnid       	:= (_tAlias)->B1_UM		
			_cCodBar		:= (_tAlias)->B1_CODBAR
			_cAlerge		:= (_tAlias)->B5_XALERGE
	
			DEFINE MSDIALOG oDlg1 TITLE "Informe a Quantidade da Etiqueta" FROM 000,000 TO 150,550 PIXEL
			@012,015 SAY "    Produto:   " + _cProduto+" - " +_cDescricao  PIXEL
			@020,015 SAY "       LOTE:   "+ _cLote PIXEL
			@030,015 SAY "Qtd da NOTA:   "+ cvaltochar(_cQuant) PIXEL
			@040,015 SAY "Informe OU mantenha a Quantidade:  " PIXEL
			_cInfFat:= _cQuant
			@040,120 MSGET oInfFat VAR _cInfFat SIZE 050,08 OF oDlg1 PICTURE "@E 999,999,999.99" PIXEL 
			@058,120 BUTTON "Ok" SIZE 40,10 PIXEL ACTION (_lF:=.t.,oDlg1:End())
			@058,180 BUTTON "Cancelar" SIZE 40,10 PIXEL ACTION (_lF:=.f.,oDlg1:End())
			ACTIVATE DIALOG oDlg1 CENTERED
			if _lF
			//Processa({|| u_ImpEtqEnt(_cProduto,_cDescricao,IIf(_cQuant<_cInfFat,_cQuant,_cInfFat),_cCodCli,_cNomeCli,_cEntrada,_cValidade,_cLote,_cUnid) },"Imprimindo Item: "+cvaltochar(_nItem)+" de " +cvaltochar(_cTot))
				 Processa({||_lF:=u_ImpEtqEnt(_cProduto,_cDescricao,IIF(_cProduto$_cPrdExc,_cInfFat,IIf(_cQuant<_cInfFat,_cQuant,_cInfFat)),_cCodCli,_cNomeCli,_cEntrada,_cValidade,_cLote,_cUnid) },"Imprimindo Item: "+cvaltochar(_nItem)+" de " +cvaltochar(_cTot))
			else
				(_tAlias)->(dbCloseArea())
				return(_lF)
			endif

			_nItem++

			DbSELECTArea(_tAlias)
			(_tAlias)->(DbSkip())
		EndDo
		(_tAlias)->(dbCloseArea())
	else		
		MsgAlert( "Nenhuma Nota encontrada. Verifique os par�metros!" )		
	Endif
	
    RestArea(_faArea)
	
Return (_lF)
 
User Function ImpEtqEnt(_cProduto,_cDescricao,_cQuant,_cCodCli,_cNomeCli,_cEntrada,_cValidade,_cLote,_cUnid)
	local _IaArea   := GetArea()
	//Local nInc
	Local lAdjustToLegacy 	:= .F.
	Local lDisableSetup   	:= .T.
	//Local nRegs           := 0
	//Local cBTM         	:= "\qualidade\emanalise.bmp"
	Local nFlags		  	:= PD_ISTOTVSPRINTER + PD_DISABLEORIENTATION
	Local cSession	   		:= GetPrinterSession()
	Local cDevice      		:= fwGetProfString(cSession,"PRINTTYPE"	,"SPOOL"	,.T.)
	Local cDestino	   		:= fwGetProfString(cSession,"DEFAULT"	,"C:\Etiqueta_Entrada\"	,.T.)

	//Local cName           := _cRotina
	//Local cLgoAr          := FisxLogo("1")
	Private _DtHr 	   		:= DTOS(Date())+"_" +StrTran(Time(),":","") 
	Private _cSpool     	:= _cDirRel
	Private _cPDF       	:= ""
	Private oFont52    		:= TFont():New("Arial" ,,52,,.T.,,,,,.F.)
	Private oFont140   		:= TFont():New("Arial" ,,140,,.T.,,,,,.F.)
	Private oFont170   		:= TFont():New("Arial" ,,170,,.T.,,,,,.F.)
	Private oFont180   		:= TFont():New("Arial" ,,180,,.T.,,,,,.F.)
	Private oFont110   		:= TFont():New("Arial" ,,110,,.T.,,,,,.F.)
	Private oFont80    		:= TFont():New("Arial" ,,80,,.t.,,,,,.F.)
	Private oFont30    		:= TFont():New("Arial" ,,30,,.t.,,,,,.F.)
	Private oFont20    		:= TFont():New("Arial" ,,20,,.F.,,,,,.F.)
	Private oFont14    		:= TFont():New("Arial" ,,14,,.F.,,,,,.F.)
	Private oFont16    		:= TFont():New("Arial" ,,16,,.F.,,,,,.F.)
	Private oFont14T   		:= TFont():New("Arial" ,,14,,.t.,,,,,.F.)
	Private oFont12    		:= TFont():New("Arial" ,,12,,.T.,,,,,.F.)   
	private oPrintSetup as Object
	private oPrinter 	as Object
	private aDevice
	Default _cLote			:= "Produto sem lote" 

	_cPDF := "etiqueta_produto_" + alltrim(_cProduto) +"_"+ alltrim(_cNota)+"_"+ alltrim(_cLote) +"_"+_DtHr+".pdf"

	aDevice := {}
	//�������������������������������������Ŀ
	//�Define os Tipos de Impressao validos �
	//���������������������������������������
	AADD(aDevice,"DISCO")
	AADD(aDevice,"SPOOL")
	AADD(aDevice,"EMAIL")
	AADD(aDevice,"EXCEL")
	AADD(aDevice,"HTML" )
	AADD(aDevice,"PDF"  )
	nPrintType 							:= aScan(aDevice,{|x| x == cDevice})
	nLocal     							:= iif(fWGetProfString(cSession,"LOCAL","SERVER",.T.) == "SERVER",1,2)		
	oSetup 								:= FWPrintSetup():New(nFlags,'Impress�o da Ficha Pallet')
	oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
	oSetup:SetPropert(PD_ORIENTATION , 1) 
	oSetup:SetPropert(PD_DESTINATION , nLocal)
	oSetup:SetPropert(PD_MARGIN      , {10,10,10,10})
	oSetup:SetPropert(PD_PAPERSIZE   , 2)
	oSetup:SetPropert(PD_PREVIEW	 , .F.)
	if cDevice == "PDF"
		oSetup:aOptions[PD_VALUETYPE] 	:= cDestino
	endif
	oPrinter 							:= FWMSPrinter():New(_cPDF,nPrintType,lAdjustToLegacy,,lDisableSetup,.T.,@oSetup,,,,.F.,)
	if !(oSetup:Activate() == PD_OK)
		oPrinter:Deactivate() 
		Aviso('TOTVS','Relat�rio cancelado pelo usu�rio',{'&OK'},3)
		return .F.
	endif
	oPrinter:lServer 					:= oSetup:GetProperty(PD_DESTINATION) == AMB_SERVER                      
	oPrinter:SetResolution(75)
	if oSetup:GetProperty(PD_ORIENTATION) == 2
		oPrinter:SetLandsCape()
	else
		oPrinter:SetPortRait()
	endif
	oPrinter:SetPaperSize(oSetup:GetProperty(PD_PAPERSIZE))
	fwWriteProfString(cSession,"LOCAL"		,iif(oSetup:GetProperty(PD_DESTINATION) == 1,"SERVER","LOCAL"),.T.)
	fwWriteProfString(cSession,"PRINTTYPE"	,aDevice[oSetup:GetProperty(PD_PRINTTYPE)],.T.)
	if oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
		oPrinter:nDevice 				:= IMP_SPOOL
		fwWriteProfString(cSession,"DEFAULT",oSetup:aOptions[PD_VALUETYPE],.T.)
		oPrinter:cPrinter 				:= oSetup:aOptions[PD_VALUETYPE]
	elseif oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
		oPrinter:nDevice 				:= IMP_PDF
		fwWriteProfString(cSession,"DEFAULT",oSetup:aOptions[PD_VALUETYPE],.T.)	
		oPrinter:cPathPDF 				:= oSetup:aOptions[PD_VALUETYPE]
	endif



	oPrinter:StartPage()

	oPrinter:Say(015,210, "CODIGO DO PRODUTO", oFont20)
	oPrinter:Line(037,010,037,600) 
	oPrinter:Say(0131,170, ALLTRIM(_cProduto), oFont180) 
	oPrinter:Line(160,010,160,600) 

	oPrinter:Code128(060/*nRow*/ ,030 /*nCol*/,Alltrim(_cCodBar)/*cCode*/,1/*nWidth*/,35/*nHeigth*/,.F./*lSay*/,,)
		
	oPrinter:Say(160,035, ALLTRIM(_cDescricao), oFont20) 
	oPrinter:Line(188,010,188,600) 

	oPrinter:Say(183,300, "QTDE", oFont20) 
	oPrinter:Line(205,010,205,600) 
	oPrinter:Say(290,030, Alltrim(Transform( _cQuant,"@E 999,999,999.99")), oFont140)
	//oPrinter:Say(290,015, cvaltochar(_cQuant), oFont140)
	oPrinter:Line(0320,010,320,600) 

	if empty(_cValidade)
		_cValidade:= '(N�o informado na entrada)'
		oPrinter:Say(369,60, _cValidade, oFont52) 
	Else
		oPrinter:Say(369,85, _cValidade, oFont110) 
	endIf	
	oPrinter:Line(400,010,400,600) 
	oPrinter:Say(340,035, "DATA DE ", oFont12)
	oPrinter:Say(355,035, "VALIDADE", oFont12) 
	
	oPrinter:Say(435,035, _cEntrada, oFont52) 
	oPrinter:Say(465,035, "DATA DE ENTRADA", oFont20)
	oPrinter:Line(495,010,495,350) 

	//oPrinter:Say(350,035, _cCodCli, oFont52) 
	oPrinter:Say(515,035, _cNota+" /"+_cSerie, oFont52) 
	oPrinter:Say(542,035, "NOTA FISCAL", oFont20)
	oPrinter:Line(575,10,575,350) 
	//oPrinter:Say(365,420, _cUnid, oFont80) 
	oPrinter:Line(585,010,585,350) 
	oPrinter:Say(585,035, _cCodCli+" - "+_cNomeCli, oFont20) 
	oPrinter:Line(610,010,610,350) 

	oPrinter:Say(617,035, _cLoteFor, oFont30) 
	oPrinter:Say(645,035, "LOTE FORNECEDOR", oFont20)
	oPrinter:Line(670,010,670,350) 
	

	oPrinter:Say(755,030, ALLTRIM(_cLote), oFont170) 
	oPrinter:Line(780,010,780,600) 
	oPrinter:Say(775,55, "LOTE INTERNO", oFont20) 
	//oPrinter:Line(790,010,790,600) 

	oPrinter:Code128(700/*nRow*/ ,520/*nCol*/,ALLTRIM(_cLote)/*cCode*/,1/*nWidth*/,35/*nHeigth*/,.F./*lSay*/,,)
	
	If _cAlerge == "1"
	oPrinter:Say(775,300, "|| ATEN��O! PRODUTO ALERGENICO", oFont20) 
	EndIf
	
	oPrinter:Box(0400,0340,0670,0600)

	oPrinter:Say(455,450, "EM", oFont52) 
	oPrinter:Say(490,390, "ANALISE", oFont52) 
	
	//oPrinter:SayBitmap( 490, 310, cBTM ) 
	//oPrinter:Line(0336,0010,0336,0230)  
	//oPrinter:Line(0394,0010,0394,0230) 
	oPrinter:EndPage()
	//oPrinter:Print()
	oPrinter:Preview()

 RestArea(_IaArea)
Return.t.
 
User function PesqPrd()

	Local _aRet		:= {}       //Array do retorno da opcao selecionada
	Local _cTitulo  := "Produto(s) da Nota Fiscal" 	 
	Local _aCombo	:=  {}
	Local oDlg                  //Objeto Janela
	Local oLbx                  //Objeto List box
	Local _pArea		:= GetArea()
	Private _cCod 	:= " "   
	Private _cLote  := " "
//If MsgYesNo("Deseja selecionar um produto especifico?")

	_aCombo:=U_GerComBo()
	If Len( _aCombo ) > 0

		DEFINE MSDIALOG oDlg TITLE _cTitulo FROM 0,0 TO 240,850 PIXEL
		
		@ 10,10 LISTBOX oLbx FIELDS HEADER "C�digo", "Descri��o","Lote Interno","Pedido"  SIZE 390,95 OF oDlg PIXEL	 //"Campo"###"Titulo"
		
		oLbx:SetArray( _aCombo )
		oLbx:bLine     := {|| {_aCombo[oLbx:nAt,1], _aCombo[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3],,oLbx:aArray[oLbx:nAt,4]}}
		oLbx:bLDblClick := {|| {oDlg:End(), _aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3],oLbx:aArray[oLbx:nAt,4]}}} 	                   

		DEFINE SBUTTON FROM 107,160 TYPE 1 ACTION (oDlg:End(), _aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3],oLbx:aArray[oLbx:nAt,4]})  ENABLE OF oDlg
		DEFINE SBUTTON FROM 107,200 TYPE 2 ACTION ( oDlg:End(), _aRet := {'','',''}) ENABLE OF oDlg  
		ACTIVATE MSDIALOG oDlg CENTER
		
		If len(_aRet)>0
			_cCod  := _aRet[1]
			_cLote := _aRet[3]
		else
			_cCod := ""
			_cLote:= ""
		endIf
		
	EndIf	

RestArea(_pArea)
Return _aRet   

User Function GerComBo()
	Local _aCombo	:={}
	Local _cQry 	:= " "
	Local _tAlias2	:=  "COMBO"
    Local  _gaArea := GetArea()

	If SELECT (_tAlias2) > 0
		(_tAlias2)->(dbCloseArea())
	EndIf  

	_cQry :=  " SELECT DISTINCT rtrim(ltrim(B1_DESC)) DESCRICAO"
	_cQry +=  " ,	 rtrim(ltrim(D1_COD)) D1_COD"
	_cQry +=  " ,	 rtrim(ltrim(D1_LOTECTL)) D1_LOTECTL"
	_cQry +=  " ,	 rtrim(ltrim(D1_LOTEFOR)) D1_LOTEFOR"
	_cQry +=  " ,	 rtrim(ltrim(D1_PEDIDO)) D1_PEDIDO"
	_cQry +=  " from " + RetSqlName("SD1") + " (NOLOCK) "
	_cQry +=  " INNER JOIN " + RetSqlName("SB1") + " (NOLOCK)  ON B1_COD = D1_COD "
	_cQry +=  " INNER JOIN " + RetSqlName("SA2") + " (NOLOCK)  ON  A2_COD = D1_FORNECE AND A2_LOJA = D1_LOJA " 
	_cQry +=  " where D1_DOC = '" 		+ AllTrim(_cNota) + "' "
	_cQry +=  " 	AND D1_SERIE = '"	+ AllTrim(_cSerie) + "' "
	_cQry +=  "  	AND D1_FORNECE = '"	+ AllTrim(_cFornece) + "' "
	_cQry +=  "  	AND D1_LOJA = '"	+ AllTrim(_cLoja) + "' and SD1010.D_E_L_E_T_ = ''  "

	dbUseArea(.T., "TOPCONN ",TcGenQry(,,_cQry),_tAlias2,.T.,.F.)
	dbSELECTArea(_tAlias2)
	ProcRegua(RecCount())
	(_tAlias2)->(dbGoTOP())
	While !(_tAlias2)->(EOF())	.and. !empty((_tAlias2)->DESCRICAO)	
		aAdd(_aCombo, {(_tAlias2)->D1_COD, (_tAlias2)->DESCRICAO , (_tAlias2)->D1_LOTECTL, (_tAlias2)->D1_PEDIDO })	
		DbSELECTArea(_tAlias2)
		(_tAlias2)->(DbSkip())
	EndDo
	(_tAlias2)->(dbCloseArea())
	RestArea(_gaArea)
Pergunte("MTA140",.F.)
Return _aCombo
/*
User Function AjustaSx1()
	//Local aArea := GetArea()

	PutSx1(_cPerg,"01","Nota","","","mv_ch1","C",15,0,0,"G","","","","","mv_par01")
	PutSx1(_cPerg,"02","Serie","","","mv_ch2","C",03,0,0,"G","","","","","mv_par02")
	PutSX1(_cPerg,"03","Fornecedor","","","mv_ch3","C",06,0,0,"C","","","","","mv_par03","", "", "", "","")
	PutSX1(_cPerg,"04","Loja","","","mv_ch4","C",02,0,0,"C","","","","","mv_par04","", "", "", "","")
	//RestArea(aArea)
Return
*/
/*/{Protheus.doc} ValPerg
@description Verifica as perguntas no dicion�rio SX1, as criando, caso n�o existam.
@author Diego Rodrigues Pereira (ALLSS Solu��es em Sistemas)
@since 22/06/2021
@type function
@version 1.00
@see https://allss.com.br
/*/
User function ValPerg()
	local _VaArea     := GetArea()
	local _aTam      := {}
	local _aRegs     := {}
	local i          := 0
	local j          := 0
	local _cQrySX1 := "SX1"

	OpenSxs(,,,,FWCodEmp(),_cQrySX1,"SX1",,.F.)
	dbSELECTArea(_cQrySX1)
	(_cQrySX1)->(dbSetOrder(1))
		
		_cPerg := PADR(_cPerg,len((_cQrySX1)->X1_GRUPO))
		_aTam  := TamSX3("F1_DOC")
		AADD(_aRegs,{_cPerg,"01","Nota			","","","mv_ch1",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
		_aTam  := TamSX3("F1_SERIE")
		AADD(_aRegs,{_cPerg,"02","Serie			","","","mv_ch2",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
		_aTam  := TamSX3("F1_FORNECE")
		AADD(_aRegs,{_cPerg,"03","Fornecedor	","","","mv_ch3",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
		_aTam  := TamSX3("F1_LOJA")
		AADD(_aRegs,{_cPerg,"04","Loja			","","","mv_ch4",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
	for i := 1 to len(_aRegs)
		if !(_cQrySX1)->(dbSeek(_cPerg+_aRegs[i,2]))
			while !RecLock(_cQrySX1,.T.) ; enddo
				for j := 1 to FCount()
					if j <= Len(_aRegs[i])
						FieldPut(j,_aRegs[i,j])
					else
						Exit
					endif
				next
			(_cQrySX1)->(MsUnLock())
		endif
	next
	RestArea(_VaArea)
	
return
