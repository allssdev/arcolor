#include "PROTHEUS.CH"
#include "RWMAKE.ch"
#include "Colors.ch"
#include "Font.ch"
#Include "HBUTTON.CH"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE 'parmtype.ch'
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH
#INCLUDE "SHELL.CH
/*/{Protheus.doc} PreNotaXML
@description Função para importação de arquivo XML
@obs Sem observações no momento
@author Livia Della Corte (ALLSS Soluções em Sistemas)
@since 07/04/2017
@version 1.0
@type function
@see https://allss.com.br
@history 31/08/2021, Rodrigo Telecio (rodrigo.telecio@allss.com.br),  Alteração por conta de erro na importação de XML após a atualização acumulada do Fiscal e Faturamento em 29/08/2021.
/*/
user function PreNotaXML()
	Private _cRotina := "PRENOTA"
	if Type("cFilAnt")=="U"
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" FUNNAME _cRotina
	endif
	Private _oDlg
	Private aTipo    := {'N','B','D'}
	Private cFile    := Space(10)
	Private cCgc     := ""
	Private _nNum    := "0"
	Private CPERG    := "NOTAXML"
	Private Caminho  := "\XML\"  
	Private aFields  := {}
	Private aFields2 := {}
	Private lPcNfe   := .f.
	Private cArq
	Private cArq2
	private _lCte := .F.
	private _lok:= .F.
	Private _cNfeori := ""
	private _cTes:= ""	
	private cProduto:= ""
	Private _cMarca  := GetMark()
	private cNCM
	private _cCdPg:= SuperGetMV("MV_XPAGNFE",.F.,"524")
	nTipo := 1
	cCodCHV := Space(100)	
	DEFINE FONT oFontTit NAME "Arial" SIZE 000,-012 BOLD
	DEFINE MSDIALOG _oPT00005 FROM   (377),(392) TO (709),(1229) TITLE OemToAnsi('Importação XML - NF-e/CT-e Entrada') PIXEL  FONT oFontTit
		DEFINE FONT oFontNum NAME "Arial" SIZE 000,-011

		@ 008,009 TO 072,396 LABEL "  Defina o Tipo Nota Entrada  "  PIXEL OF _oPT00005 
		@ 025,019 RADIO oTipo VAR nTipo ITEMS "NF-e Normal","NF-e Beneficiamento","NF-e Devolução","CT-e" SIZE 70,10 OF _oPT00005	//FONT oFontNum 
		oTipo:oFont	   := oFontNum
		oTipo:cToolTip := "Definir pelo XML qual tipo/modelo de nota a ser importada"
	
		@ 075,009 TO 128,396 LABEL " Defina o Meio de Importação  " PIXEL OF _oPT00005 
		@ 089,019 Say OemToAnsi("Arquivo") Size 090,030 	
		@ 100,019 Button OemToAnsi("Buscar") Size 057,016 Action (GetArq(@cCodCHV),_oPT00005:End())		
		@ 100,116 Say OemToAnsi("ou") Size 040,030 
		@ 089,169 Say OemToAnsi("Chave") Size 090,030 
		@ 100,169 Get cCodCHV  Picture "@!S80" Valid (iif(nTipo> 0,AchaFile(@cCodCHV,@nTipo),.f.),If(!Empty(cCodCHV),_oPT00005:End(),.t.))  Size 160,030

		@ 135,280 Button OemToAnsi("Sair")   Size 057,016 Action Fecha()
		@ 135,342 Button OemToAnsi("Ok")  Size 057,016 Action (_oPT00005:End())
	Activate Dialog _oPT00005 CENTERED
	MV_PAR01 := nTipo
    cFile    := cCodCHV    
	If MV_PAR01 = 1
		cTipo := "N"
	ElseIF MV_PAR01 = 2
		cTipo := "B"
	ElseIF MV_PAR01 = 3
		cTipo := "D"
	ElseIF MV_PAR01 = 4
		cTipo := "N"	
		_lCte := .T. 
	Endif	
	If !File(cFile) .and. !Empty(cFile)
		MsgAlert("Arquivo Não Encontrado no Local de Origem Indicado!",_cRotina+"_001")
		PutMV("MV_PCNFE",lPcNfe)
		Return
	Endif
	Private nHdl := fOpen(cFile,0)
	aCamposPE:={}
	If nHdl == -1
		If !Empty(cFile)
			MsgAlert("O arquivo de nome "+cFile+" nao pode ser aberto! Verifique os parametros.","Atencao!",_cRotina+"_002")
		Endif
		PutMV("MV_PCNFE",lPcNfe)
		Return nil
	Endif
	nTamFile := fSeek(nHdl,0,2)
	fSeek(nHdl,0,0)
	cBuffer  := Space(nTamFile)                // Variavel para criacao da linha do registro para leitura
	nBtLidos := fRead(nHdl,@cBuffer,nTamFile)  // Leitura  do arquivo XML
	fClose(nHdl)
	cAviso := ""
	cErro  := ""
	oNfe   := XmlParser(cBuffer,"_",@cAviso,@cErro)
	Private oNF
	Private oNFChv	
	if _lCte .And. ( Type("oNFe:_CteProc")== "U" .or. type("oNFe:_Cte")== "U" )
		U_PreNotaCTE(,,cFile)
	else						
		if type("oNFe:_NfeProc")<> "U"
			oNF := oNFe:_NFeProc:_NFe
		else
			oNF := oNFe:_NFe  
		endif
		oNFChv := oNFe:_NFeProc:_protNFe
		Private oEmitente  := oNF:_InfNfe:_Emit
		Private oIdent     := oNF:_InfNfe:_IDE
		Private oDestino   := oNF:_InfNfe:_Dest
		Private oTotal     := oNF:_InfNfe:_Total
		Private oTransp    := oNF:_InfNfe:_Transp
		Private oDet       := oNF:_InfNfe:_Det
		Private cChvNfe    := oNFChv:_INFPROT:_CHNFE:TEXT
		private oICM       := nil
		Private oFatura    := IIf(Type("oNF:_InfNfe:_Cobr")=="U",Nil,oNF:_InfNfe:_Cobr)
		Private oNfRef	   := IIf(Type("OIdent:_NFREF:_REFNFE")=="U",OIdent:_NFREF,OIdent:_NFREF:_REFNFE)
		Private cEdit1	   := space(15)
		Private _DESCdigit := space(55)
		Private _NCMdigit  := space(8)
		If Type("oNF:_InfNfe:_ICMS") <> "U"
			oICM := oNF:_InfNfe:_ICMS
		Endif
		IncProc('Processando...') 
		oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
		cCgc := AllTrim(IIf(Type("oEmitente:_CPF")=="U",oEmitente:_CNPJ:TEXT,oEmitente:_CPF:TEXT))
		If MV_PAR01 = 1 // Nota Normal Fornecedor
			If !SA2->(dbSetOrder(3), dbSeek(xFilial("SA2")+cCgc))
				MsgAlert("CNPJ Origem Não Localizado - Verifique " + cCgc ,_cRotina+"_005")
				PutMV("MV_PCNFE",lPcNfe)
				Return
			Endif
		Else
			If !SA1->(dbSetOrder(3), dbSeek(xFilial("SA1")+cCgc))
				MsgAlert("CNPJ Origem Não Localizado - Verifique " + cCgc,_cRotina+"_006")
				PutMV("MV_PCNFE",lPcNfe)
				Return
			Endif
		Endif
		If SF1->( dbSetOrder(8), DbSeek(XFilial("SF1")+ cChvNfe) )
			MsgAlert("Chave de NF-e: " + cChvNfe + " do arquivo selecionado já consta no Sistema!",_cRotina + "_007")
		 	return
		EndIf 
		If  OIdent:_finNFe:TEXT <>"4" .and. MV_PAR01==3
			MsgAlert("XML não tem Finalidade de Devolução",_cRotina+"_009")
			PutMV("MV_PCNFE",lPcNfe)
			return 
		EndIf
		If SF1->(DbSeek(XFilial("SF1")+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),TamSx3("F1_DOC")[1])+Right("000"+Alltrim(OIdent:_serie:TEXT),3)+SA2->A2_COD+SA2->A2_LOJA)) .OR.;
			SF1->(DbSeek(XFilial("SF1")+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),TamSx3("F1_DOC")[1])+Right("   "+Alltrim(OIdent:_serie:TEXT),3)+SA2->A2_COD+SA2->A2_LOJA))
			MsgAlert("Nota No.: "+Right("000000000"+Alltrim(OIdent:_nCt:TEXT),TamSx3("F1_DOC")[1])+"/"+Right("000"+Alltrim(OIdent:_serie:TEXT),3)+" do Fornec. "+SA2->A2_COD+"/"+SA2->A2_LOJA+" Ja Existe. A Importacao sera interrompida",_cRotina+"_004")
			PutMV("MV_PCNFE",lPcNfe)
			return 
		EndIf		
		_nNum := Right("000000000"+Alltrim(OIdent:_nNF:TEXT),TamSx3("F1_DOC")[1])
		aCabec := {}
		aItens := {}
		aadd(aCabec,{"F1_TIPO"   ,If(MV_PAR01==1 .Or. MV_PAR01==4,"N",If(MV_PAR01==3  .Or. OIdent:_finNFe:TEXT =="4" ,'D','B')),Nil,Nil})
		aadd(aCabec,{"F1_FORMUL" ,"N",Nil,Nil})
		aadd(aCabec,{"F1_DOC"    , _nNum ,Nil,Nil})	
		aadd(aCabec,{"F1_SERIE"  ,OIdent:_serie:TEXT,Nil,Nil})

		cData := substr(Alltrim(OIdent:_dhEmi:TEXT),1,10)
		dData := CTOD(Right(cData,2)+'/'+Substr(cData,6,2)+'/'+Left(cData,4))
		aadd(aCabec,{"F1_EMISSAO",dData,Nil,Nil})

		aadd(aCabec,{"F1_FORNECE",If(MV_PAR01=1,SA2->A2_COD,SA1->A1_COD),Nil,Nil})
		aadd(aCabec,{"F1_LOJA"   ,If(MV_PAR01=1,SA2->A2_LOJA,SA1->A1_LOJA),Nil,Nil})
		aadd(aCabec,{"F1_COND",_cCdPg,Nil,Nil})	

		aadd(aCabec,{"F1_ESPECIE","SPED ",Nil,Nil})	
		aadd(aCabec,{"F1_VALMERC",val(oTotal:_ICMSTOT:_vProd:TEXT),Nil,Nil})	
		aadd(aCabec,{"F1_VALBRUT",val(oTotal:_ICMSTOT:_vNF:TEXT),Nil,Nil})	
	
		// Primeiro Processamento
		// Busca de Informações para Pedidos de Compras
		cProds  := ''
		aPedIte := {}
		
		For nX := 1 To Len(oDet)// PAINEL DE PROCESSAMENTO
			cEdit1     := space(15)
			_DESCdigit := space(55)
			_NCMdigit  := space(8)		
							
			If MV_PAR01 = 1 // se conter pedido entra neste IF
				cProduto:=PadR(AllTrim(oDet[nX]:_Prod:_cProd:TEXT),TamSx3("A5_CODPRF")[1])
				xProduto:=cProduto
				
				cNCM:=IIF(Type("oDet[nX]:_Prod:_NCM")=="U",space(12),oDet[nX]:_Prod:_NCM:TEXT)
				Chkproc=.F.	
				SA5->(dbSetOrder(3))   
				If !SA5->(dbSeek(xFilial("SA5")+SA2->A2_COD+SA2->A2_LOJA+cProduto))   //se o produto nao estiver amarrado no produto x fornecedor entra neste IF
					If MsgYesNo ("Produto Cod.: "+alltrim(cProduto)+" Nao Encontrado. Digita Codigo de Substituicao?")
						fAdPrdCli("f",cProduto,SA2->A2_COD,SA2->A2_LOJA,Val(oDet[nX]:_Prod:_qTrib:TEXT))
					Else
						PutMV("MV_PCNFE",lPcNfe)
						Return Nil
					Endif
				Endif
			Else
				cProduto := PadR(AllTrim(oDet[nX]:_Prod:_cProd:TEXT),TamSx3("A7_CODCLI")[1])
				xProduto := cProduto
				
				cNCM    := IIF(Type("oDet[nX]:_Prod:_NCM")=="U",space(12),oDet[nX]:_Prod:_NCM:TEXT)
				Chkproc := .F.

				SA7->(dbSetOrder(3))   // FILIAL + FORNECEDOR + LOJA + CODIGO PRODUTO NO FORNECEDOR
				
				If !SA7->(dbSeek(xFilial("SA7")+SA1->A1_COD+SA1->A1_LOJA+cProduto))
					If MsgYesNo ("Produto Cod.: "+ALLTRIM(cProduto)+" Nao Encontrado. Digita Codigo de Substituicao?")
						fAdPrdCli("C",cProduto,SA1->A1_COD,SA1->A1_LOJA,Val(oDet[nX]:_Prod:_qTrib:TEXT))
					Else	
						PutMV("MV_PCNFE",lPcNfe)
						Return Nil
					Endif
				Endif
			Endif
			SB1->(dbSetOrder(1))
			cProds += ALLTRIM(SB1->B1_COD)+'/'
			AAdd(aPedIte,{SB1->B1_COD,Val(oDet[nX]:_Prod:_qTrib:TEXT),Round(Val(oDet[nX]:_Prod:_vProd:TEXT)/Val(oDet[nX]:_Prod:_qCom:TEXT),6),Val(oDet[nX]:_Prod:_vProd:TEXT)})
		Next nX		
		// Retira a Ultima "/" da Variavel cProds
		cProds   := Left(cProds,Len(cProds)-1)				
		aCampos  := {}
		aCampos2 := {}			
		AADD(aCampos,{'T9_OK'			,'#','@!','2','0'})
		_aTamX    := TamSx3("C7_NUM")
		AADD(aCampos,{'T9_PEDIDO'		,'Pedido',PesqPict("SC7","C7_NUM"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX    := TamSx3("C7_ITEM")
		AADD(aCampos,{'T9_ITEM'			,'Item',PesqPict("SC7","C7_ITEM"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX    := TamSx3("C7_PRODUTO")
		AADD(aCampos,{'T9_PRODUTO'		,'PRODUTO',PesqPict("SC7","C7_PRODUTO"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX    := TamSx3("B1_DESC")
		AADD(aCampos,{'T9_DESC'			,'Descrição',PesqPict("SB1","B1_DESC"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX    := TamSx3("C7_UM")
		AADD(aCampos,{'T9_UM'			,'Un',PesqPict("SC7","C7_UM"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX    := TamSx3("C7_QUANT")
		AADD(aCampos,{'T9_QTDE'			,'Qtde',PesqPict("SC7","C7_QUANT"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX    := TamSx3("C7_PRECO")
		AADD(aCampos,{'T9_UNIT'			,'Unitario',PesqPict("SC7","C7_PRECO"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX    := TamSx3("C7_TOTAL")
		AADD(aCampos,{'T9_TOTAL'		,'Total',PesqPict("SC7","C7_TOTAL"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX    := TamSx3("C7_DATPRF")
		AADD(aCampos,{'T9_DTPRV'		,'Dt.Prev',PesqPict("SC7","C7_DATPRF"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX    := TamSx3("C7_LOCAL")
		AADD(aCampos,{'T9_ALMOX'		,'Alm',PesqPict("SC7","C7_LOCAL"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX    := TamSx3("C7_OBS")
		AADD(aCampos,{'T9_OBSERV'		,'Observação',PesqPict("SC7","C7_OBS"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX    := TamSx3("C7_CC")
		AADD(aCampos,{'T9_CCUSTO'		,'C.Custo',PesqPict("SC7","C7_CC"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX    := TamSx3("D1_DOC")
		AADD(aCampos2,{'T8_NOTA'		,'N.Fiscal',PesqPict("SD1","D1_DOC"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX    := TamSx3("D1_SERIE")
		AADD(aCampos2,{'T8_SERIE'		,'Serie',PesqPict("SD1","D1_SERIE"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX    := TamSx3("D1_COD")
		AADD(aCampos2,{'T8_PRODUTO'		,'PRODUTO',PesqPict("SD1","D1_COD"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX    := TamSx3("B1_DESC")
		AADD(aCampos2,{'T8_DESC'		,'Descrição',PesqPict("SB1","B1_DESC"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX    := TamSx3("D1_UM")
		AADD(aCampos2,{'T8_UM'			,'Un',PesqPict("SD1","D1_UM"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX    := TamSx3("D1_QUANT")
		AADD(aCampos2,{'T8_QTDE'		,'Qtde',PesqPict("SD1","D1_QUANT"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX    := TamSx3("D1_VUNIT")
		AADD(aCampos2,{'T8_UNIT'		,'Unitario',PesqPict("SD1","D1_VUNIT"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX    := TamSx3("D1_TOTAL")
		AADD(aCampos2,{'T8_TOTAL'		,'Total',PesqPict("SD1","D1_TOTAL"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})

		Cria_TC9()

		For ni := 1 To Len(aPedIte)
			RecLock("TC8",.T.)
				TC8->T8_NOTA 	:= Right("000000000"+_nNum,TamSx3("F1_DOC")[1])
				TC8->T8_SERIE 	:= OIdent:_serie:TEXT
				TC8->T8_PRODUTO := aPedIte[nI,1]
				TC8->T8_DESC	:= Posicione("SB1",1,xFilial("SB1")+aPedIte[nI,1],"B1_DESC")
				TC8->T8_UM		:= SB1->B1_UM
				TC8->T8_QTDE	:= aPedIte[nI,2]
				TC8->T8_UNIT	:= aPedIte[nI,3]
				TC8->T8_TOTAL	:= aPedIte[nI,4]
			TC8->(msUnlock())
		Next
		TC8->(dbGoTop())

		Monta_TC9()

		lOk  := .F.
		lOut := .F.
		if !Empty(TC9->(RecCount()))	
			DbSelectArea('TC9')
			@ 100,005 TO 500,750 DIALOG oDlgPedidos TITLE "Pedidos de Compras Associados ao XML selecionado!"
				@ 006,005 TO 100,325 BROWSE "TC9" MARK "T9_OK" FIELDS aCampos Object _oBrwPed
				@ 066,330 BUTTON "Marcar"         SIZE 40,15 ACTION MsAguarde({||MarcarTudo()},'Marcando Registros...')
				@ 086,330 BUTTON "Desmarcar"      SIZE 40,15 ACTION MsAguarde({||DesMarcaTudo()},'Desmarcando Registros...')
				@ 106,330 BUTTON "Processar"	  SIZE 40,15 ACTION MsAguarde({|| lOk := .t. , Close(oDlgPedidos)},'Gerando e Enviando Arquivo...')
				@ 183,330 BUTTON "Sair"			  SIZE 40,15 ACTION MsAguarde({|| lOut := .t., Close(oDlgPedidos)},'Saindo do Sistema')
				DbSelectArea('TC8')
				@ 100,005 TO 190,325 BROWSE "TC8" FIELDS aCampos2 Object _oBrwPed2
			DbSelectArea('TC9')
			_oBrwPed:bMark := {|| Marcar()}
			ACTIVATE DIALOG oDlgPedidos CENTERED
		endif
		//Verifica se o usuário clicou no botão para sair, anteriormente se ele clicasse para sair o sistema ainda fazia a inserçao dos dados, agora não.
		if lOut
			return
		endif
		// Verifica se o usuario selecionou algum pedido de compra
		dbSelectArea("TC9")
		dbGoTop()
		ProcRegua(Reccount())
		lMarcou := .f.
		while !TC9->(Eof()) .And. lOk
			IncProc()
			if TC9->T9_OK  <> _cMarca
					dbSelectArea("TC9")
					TC9->(dbSkip(1));Loop
			else
				lMarcou := .t.
				Exit
			endif
			TC9->(dbSkip(1))
		enddo
		for nX := 1 to len(oDet)	
			// Validacao: Produto Existe no SB1 ?
			// Se não existir, abrir janela c/ codigo da NF e descricao para digitacao do cod. substituicao.
			// Deixar opção para cancelar o processamento //  Descricao: oDet[nX]:_Prod:_xProd:TEXT
			aLinha := {}
			cProduto:= Right(AllTrim(oDet[nX]:_Prod:_cProd:TEXT),15)//verificar retorno de valor
			xProduto:= cProduto
			
			cNCM:=IIF(Type("oDet[nX]:_Prod:_NCM")=="U",space(12),oDet[nX]:_Prod:_NCM:TEXT)
			Chkproc=.F.
			cEdit1:= ""
			If empty(cEdit1)
				If MV_PAR01 == 1
					SA5->(dbSetOrder(3)) 
					SA5->(dbSeek(xFilial("SA5")+SA2->A2_COD+SA2->A2_LOJA+cProduto))
					iF SB1->(dbSetOrder(1) , dbSeek(xFilial("SB1")+SA5->A5_PRODUTO))
						cEdit1:= SB1->B1_COD	
					Else
						MSGALERT(" Produto:" + alltrim(cProduto) + " Sem Amarração!",_cRotina+"_012")
						return 							
					EndIf
				Else
					SA7->(dbSetOrder(3))
					SA7->(dbSeek(xFilial("SA7")+SA1->A1_COD+SA1->A1_LOJA+cProduto))
					If SB1->(dbSetOrder(1) , dbSeek(xFilial("SB1")+SA7->A7_PRODUTO))
						cEdit1:= SB1->B1_COD
					Else
						MSGALERT(" Produto:" + alltrim(cProduto) + " Sem Amarração!",_cRotina+"_013")
						return 
					EndIf
				Endif	
			EndIf	
			aadd(aLinha,{"D1_COD",cEdit1,Nil,Nil})
						
			If Val(oDet[nX]:_Prod:_qTrib:TEXT) != 0
				aadd(aLinha,{"D1_QUANT",Val(oDet[nX]:_Prod:_qTrib:TEXT),Nil,Nil})
				aadd(aLinha,{"D1_VUNIT",Round(Val(oDet[nX]:_Prod:_vProd:TEXT)/Val(oDet[nX]:_Prod:_qTrib:TEXT),6),Nil,Nil})
			Else
				aadd(aLinha,{"D1_QUANT",Val(oDet[nX]:_Prod:_qCom:TEXT),Nil,Nil})
				aadd(aLinha,{"D1_VUNIT",Round(Val(oDet[nX]:_Prod:_vProd:TEXT)/Val(oDet[nX]:_Prod:_qCom:TEXT),6),Nil,Nil})
			Endif
			aadd(aLinha,{"D1_TOTAL",Val(oDet[nX]:_Prod:_vProd:TEXT),Nil,Nil})
			_cfop:=oDet[nX]:_Prod:_CFOP:TEXT
			If Left(Alltrim(_cfop),1)="5"
				_cfop:=Stuff(_cfop,1,1,"1")
			Else
				_cfop:=Stuff(_cfop,1,1,"2")
			Endif
			If Type("oDet[nX]:_Prod:_vDesc")<> "U"
	            aadd(aLinha,{"D1_VALDESC",Val(oDet[nX]:_Prod:_vDesc:TEXT),Nil,Nil})
	        Else 
	            aadd(aLinha,{"D1_VALDESC",0,Nil,Nil})            
	        Endif
			Do Case
				Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS00")<> "U"
					oICM := oDet[nX]:_Imposto:_ICMS:_ICMS00
				Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS10")<> "U"
					oICM := oDet[nX]:_Imposto:_ICMS:_ICMS10
				Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS20")<> "U"
					oICM := oDet[nX]:_Imposto:_ICMS:_ICMS20
				Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS30")<> "U"
					oICM := oDet[nX]:_Imposto:_ICMS:_ICMS30
				Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS40")<> "U"
					oICM := oDet[nX]:_Imposto:_ICMS:_ICMS40
				Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS51")<> "U"
					oICM := oDet[nX]:_Imposto:_ICMS:_ICMS51
				Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS60")<> "U"
					oICM := oDet[nX]:_Imposto:_ICMS:_ICMS60
				Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS70")<> "U"
					oICM := oDet[nX]:_Imposto:_ICMS:_ICMS70
				Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS90")<> "U"
					oICM := oDet[nX]:_Imposto:_ICMS:_ICMS90
			EndCase
			If Type("oICM:_orig:TEXT")<> "U" .And. Type("oICM:_CST:TEXT")<> "U"
				CST_Aux := Alltrim(oICM:_orig:TEXT)+Alltrim(oICM:_CST:TEXT)
				aadd(aLinha,{"D1_CLASFIS",CST_Aux,Nil,Nil})
			Endif
			If lMarcou
				aadd(aLinha,{"D1_PEDIDO",'',Nil,Nil})
				aadd(aLinha,{"D1_ITEMPC",'',Nil,Nil})
			Endif
			If  cTipo == "N"
		    	aadd(aLinha,{"D1_TESACLA",_cTES,Nil,Nil})
		    ElseIf cTipo$"B/D" 
		    	_lok:= .F.
		    	_cTES:= ""
		    	//27/04/21 - Diego Rodrigues - Allss ajuste no linha de comparativo para buscar a tes no arquivo de importação
				IF  TYPE("oNfRef")=="O"
		    		_cTES:= Iif(empty(_cNfeori ) .and. !_lok .and. valtype(oNfRef:TEXT)<> "C",NfeChvOri(oNfRef:_REFNFE:TEXT,cEdit1,"TES") , NfeChvOri(oNfRef:TEXT,cEdit1,"TES"))	
					//Iif(empty(_cTES ) .and. !_lok ,NfeChvOri(oNfRef:_REFNFE:TEXT,cEdit1,"TES"), _cTES)
		    	Elseif TYPE("oNfRef")=="A"
			    	For nY := 1 To Len(oNfRef)
			     	 	_cTES:= Iif(empty(_cTES ) .and. !_lok ,NfeChvOri(oNfRef[nY]:_REFNFE:TEXT,cEdit1,"TES"), _cTES)
			     	Next nY
		     	EndIf
		     	aadd(aLinha,{"D1_TES",_cTES,Nil,Nil})
				aadd(aLinha,{"D1_CF",_cfop,Nil,Nil})
				aadd(aLinha,{"D1_TESACLA",_cTES,Nil,Nil})     //TES de Devolução de acordo com a TES de Saída    	
		  	Else
		    	aadd(aLinha,{"D1_TES",_cTES,Nil,Nil})
				aadd(aLinha,{"D1_CF",_cfop,Nil,Nil})  
				aadd(aLinha,{"D1_TESACLA",_cTES,Nil,Nil}) 
			EndIf
			if cTipo$"B/D"
				_lok:= .F.
				_cNfeori:= ""
				IF  TYPE("oNfRef")=="O"
		    		_cNfeori := Iif(empty(_cNfeori ) .and. !_lok .and. valtype(oNfRef:TEXT)<> "C",NfeChvOri(oNfRef:_REFNFE:TEXT,cEdit1,"NF") , NfeChvOri(oNfRef:TEXT,cEdit1,"NF"))		
		    	Elseif TYPE("oNfRef")=="A" 
			    	For nY := 1 To Len(oNfRef)
			    		_cNfeori := Iif(empty(_cNfeori ) .and. !_lok ,NfeChvOri(oNfRef[nY]:_REFNFE:TEXT,cEdit1,"NF") , _cNfeori)	    				 	     			 			          	    
					Next nY
		     	EndIf				
				If empty(_cNfeori)
					If msgYesNo("O Produto " + ALLTRIM(cEdit1) + " não Consta na NF-e de Origem do XML!Deseja selecionar outra NF-e de Saída?")
						_cNfeori:= SelOriGem(SA1->A1_COD,SA1->A1_LOJA,cEdit1,Val(oDet[nX]:_Prod:_qCom:TEXT))						
						If empty(_cNfeori) .and. SA7->(dbSetOrder(1),dbSeek(xFilial("SA7")+SA1->A1_COD+SA1->A1_LOJA+cEdit1))
							If msgYesNo("Deseja refazer a Amarração Produto Cliente:  "+ SA7->A7_CODCLI+ " X Produto Arcolor: " + ALLTRIM(cEdit1) +"?")
								fAdPrdCli("C",cEdit1,SA1->A1_COD,SA1->A1_LOJA,Val(oDet[nX]:_Prod:_qTrib:TEXT))
								IF  TYPE("oNfRef")=="O"
									_cNfeori := Iif(empty(_cNfeori ) .and. !_lok .and. valtype(oNfRef:TEXT)<> "C",NfeChvOri(oNfRef:_REFNFE:TEXT,cEdit1,"NF") , NfeChvOri(oNfRef:TEXT,cEdit1,"NF"))		
								Elseif TYPE("oNfRef")=="A" 
							    	For nY := 1 To Len(oNfRef)
							    		_cNfeori := Iif(empty(_cNfeori ) .and. !_lok ,NfeChvOri(oNfRef[nY]:_REFNFE:TEXT,cEdit1,"NF") , _cNfeori)								    				 	     			 			          	    
									Next nY
								EndIf										
								If empty(_cNfeori) 
									IF  msgYesNo("O Produto " + ALLTRIM(cEdit1) + " não Consta na NF-e de Origem do XML!Deseja selecionar outra NF-e de Saída?")
										_cNfeori:= SelOriGem(SA1->A1_COD,SA1->A1_LOJA,cEdit1,Val(oDet[nX]:_Prod:_qCom:TEXT))						
									Else
										return()
									EndIf 
								Endif	 																												
							Else
								Return()
							EndIf
						EndIf					
					Else
						If msgYesNo("Deseja refazer a Amarração Produto Cliente:  "+ SA7->A7_CODCLI+ " X Produto Arcolor: " + ALLTRIM(cEdit1) +"?")
							fAdPrdCli("C",cEdit1,SA1->A1_COD,SA1->A1_LOJA,Val(oDet[nX]:_Prod:_qTrib:TEXT))
							IF  TYPE("oNfRef")=="O"
								_cNfeori := Iif(empty(_cNfeori ) .and. !_lok .and. valtype(oNfRef:TEXT)<> "C",NfeChvOri(oNfRef:_REFNFE:TEXT,cEdit1,"NF") , NfeChvOri(oNfRef:TEXT,cEdit1,"NF"))		
							Elseif TYPE("oNfRef")=="A" 
							   	For nY := 1 To Len(oNfRef)
							   		_cNfeori := Iif(empty(_cNfeori ) .and. !_lok ,NfeChvOri(oNfRef[nY]:_REFNFE:TEXT,cEdit1,"NF") , _cNfeori)								    				 	     			 			          	    
								Next nY
							EndIf										
							If empty(_cNfeori) 
								IF  msgYesNo("O Produto " + ALLTRIM(cEdit1) + " não Consta na NF-e de Origem do XML!Deseja selecionar outra NF-e de Saída?")
									_cNfeori:= SelOriGem(SA1->A1_COD,SA1->A1_LOJA,cEdit1,Val(oDet[nX]:_Prod:_qCom:TEXT))						
								Else
									return
								EndIf 
							Endif	 																															
						Else
							return
						EndIf							
					EndIf	
				EndIf
				//REAVALIAR ESTAS CONTAGENS
				aadd(aLinha,{"D1_SERIORI",substr(_cNfeori,11,TamSx3("D1_SERIE")[1]),Nil,Nil})
				aadd(aLinha,{"D1_NFORI",substr(_cNfeori,1,TamSx3("D1_DOC")[1]),Nil,Nil})	
				aadd(aLinha,{"D1_ITEMORI",substr(_cNfeori,15,TamSx3("D1_ITEMORI")[1]),Nil,Nil})				
			EndIf
			aadd(aItens,aLinha)
		Next nX
	
		If lMarcou		
			dbSelectArea("TC9")
			TC9->(dbGoTop())
			ProcRegua(Reccount())
			While !TC9->(Eof()) .And. lOk
				IncProc()
				If TC9->T9_OK  <> _cMarca
					dbSelectArea("TC9")
					TC9->(dbSkip(1));Loop
				Endif
				For nItem := 1 To Len(aItens)
					If AllTrim(aItens[nItem,1,2]) == AllTrim(TC9->T9_PRODUTO) .And. Empty(aItens[nItem,7,2])
						If !Empty(TC9->T9_QTDE)
							aItens[nItem,7,2] := TC9->T9_PEDIDO //foi alterado de [nItem,6,2] por carlos daniel
							aItens[nItem,8,2] := TC9->T9_ITEM //foi alterado de [nItem,7,2] por carlos daniel
							If RecLock('TC9',.f.)
								If (TC9->T9_QTDE-aItens[nItem,2,2]) < 0
									TC9->T9_QTDE := 0
								Else
									TC9->T9_QTDE := (TC9->T9_QTDE - aItens[nItem,2,2])
								Endif
								TC9->(MsUnlock())
							Endif
						Endif
					Endif
				Next
				TC9->(dbSkip(1))
			Enddo
			TC8->(dbCloseArea())
		    TC9->(dbCloseArea())
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Teste de Inclusao                                            |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cx=1                             
		If Len(aItens) > 0
			Private lMsErroAuto := .f.
			Private lMsHelpAuto := .T.
			
			SB1->( dbSetOrder(1) )
			SA2->( dbSetOrder(1) )
			
			nModulo := 4  //ESTOQUE
	 		IncProc('Incluido Documento No Sistema...' ) 
	 		
	 		lPcNfe   := PutMV("MV_PCNFE",.f.)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| ARCOLOR - Alteração por conta de erro na importação de XML   |
			//| após a atualização acumulada do Fiscal e Faturamento em      |
			//| 29/08/2021												     |
			//| Rodrigo Telecio em 31/08/2021
			//| INICIO         											     |			
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//MsAguarde({|| MSExecAuto({|x,y,z|Mata140(x,y,z)},aCabec,aItens,3)}, "Importando XML", "Processando Registros...")
			MsAguarde({|| MSExecAuto({|x,y,z,a,b| MATA140(x,y,z,a,b)},aCabec,aItens,3,,)}, "Importando XML", "Processando Registros...")
			//| FIM	          											     |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF lMsErroAuto     				
				Cpyt2s(cFile,"\XML\Erro\",.F.)
				xFile := STRTRAN(Upper(cFile),"XML\", "XML\ERRO\")				
				COPY FILE &cFile TO &xFile				
				MSGALERT("ERRO NO PROCESSO")
				MostraErro()
			Else
				If Alltrim(SF1->F1_DOC) == _nNum				
					ConfirmSX8()                
					Cpyt2s(cFile,"\XML\Processados\",.F.)					
					xFile := STRTRAN(Upper(cFile),"XML\", "XML\PROCESSADOS\")   					
					COPY FILE &cFile TO &xFile						
					MSGALERT(Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2])+" - Pré Nota Gerada Com Sucesso!",_cRotina+"_014")
					If SF1->(FieldPos("F1_PLUSER")) > 0 .AND. SF1->F1_PLUSER <> __cUserId
						while !Reclock("SF1",.F.) ; enddo
						SF1->F1_PLUSER := __cUserId
					EndIf					
				Else
					MSGALERT(Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2])+" - Pré Nota não Gerada - Tente Novamente !",_cRotina+"_015")  // para aqui apos ja ter gravado a nota
				EndIf
			EndIf
		Endif
	Endif			
	PutMV("MV_PCNFE",lPcNfe)
Return
static function C(nTam)
	local   nHRes := iif(valtype(oMainWnd)=="O",oMainWnd:nClientWidth,800)	// Resolucao horizontal do monitor
	if nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	elseif (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
		nTam *= 1
	else	// Resolucao 1024x768 e acima
		nTam *= 1.28
	endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para tema "Flat"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if "MP8" $ oApp:cVersion
		if (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		endif
	endif
return Int(nTam)
static function ValProd()
	_DESCdigit=Alltrim(GetAdvFVal("SB1","B1_DESC",XFilial("SB1")+cEdit1,1,""))
	_NCMdigit=GetAdvFVal("SB1","B1_POSIPI",XFilial("SB1")+cEdit1,1,"")
return ExistCpo("SB1")
/*
static function Troca() //NUNCA USAR ISSO
	Chkproc=.T.
	cProduto=cEdit1
	//if Empty(SB1->B1_POSIPI) .and. !Empty(cNCM) .and. cNCM != '00000000'
	//	RecLock("SB1",.F.)
	//		Replace B1_POSIPI with cNCM
	//	MSUnLock()
	//endif
	Close(_oDlg)
return
*/
user function Chk_F(cTxt, cVar_MV, lChkExiste)
	local lExiste  := File(&cVar_MV)
	local cTipo    := "Arquivos XML   (*.XML)  | *.XML | Todos os Arquivos (*.*)    | *.* "
	local cArquivo := ""
	//Verifica se arquivo não existe
	if lExiste == .F. .or. !lChkExiste
		cArquivo := cGetFile( cTipo,OemToAnsi(cTxt))
		if !Empty(cArquivo)
			lExiste := .T.
			&cVar_Mv := cArquivo
		endif
	endif
return (lExiste .or. !lChkExiste)
static function MarcarTudo()
	DbSelectArea('TC9')
	TC9->(dbGoTop())
	while !TC9->(Eof())
		MsProcTxt('Aguarde...')
		RecLock('TC9',.F.)
			TC9->T9_OK := _cMarca
		TC9->(MsUnlock())
		DbSkip()
	enddo
	TC9->(DbGoTop())
	DlgRefresh(oDlgPedidos)
	SysRefresh()
return .T.
static function DesmarcaTudo()
	DbSelectArea('TC9')
	TC9->(dbGoTop())
	while !TC9->(Eof())
		MsProcTxt('Aguarde...')
		RecLock('TC9',.F.)
			TC9->T9_OK := ThisMark()
		TC9->(MsUnlock())
		TC9->(DbSkip())
	enddo
	TC9->(DbGoTop())
	DlgRefresh(oDlgPedidos)
	SysRefresh()
return .T.
static function Marcar()
	DbSelectArea('TC9')
	RecLock('TC9',.F.)
		If Empty(TC9->T9_OK)
			TC9->T9_OK := _cMarca
		Endif
	TC9->(MsUnlock())
	SysRefresh()
return .T.
static function Cria_TC9()
	local   _aTamX  := {}
	if Select("TC9") <> 0
		TC9->(dbCloseArea())
	endif
	if Select("TC8") <> 0
		TC8->(dbCloseArea())
	endif
	aFields   := {}
	AADD(aFields,{"T9_OK"     ,"C",02,0})
	_aTamX    := TamSx3("C7_NUM")
	AADD(aFields,{"T9_PEDIDO" ,_aTamX[3],_aTamX[1],_aTamX[2]})
	_aTamX    := TamSx3("C7_ITEM")
	AADD(aFields,{"T9_ITEM"   ,_aTamX[3],_aTamX[1],_aTamX[2]})
	_aTamX    := TamSx3("C7_PRODUTO")
	AADD(aFields,{"T9_PRODUTO",_aTamX[3],_aTamX[1],_aTamX[2]})
	_aTamX    := TamSx3("B1_DESC")
	AADD(aFields,{"T9_DESC"   ,_aTamX[3],_aTamX[1],_aTamX[2]})
	_aTamX    := TamSx3("B1_UM")
	AADD(aFields,{"T9_UM"     ,_aTamX[3],_aTamX[1],_aTamX[2]})
	_aTamX    := TamSx3("C7_QUANT")
	AADD(aFields,{"T9_QTDE"   ,_aTamX[3],_aTamX[1],_aTamX[2]})
	_aTamX    := TamSx3("C7_PRECO")
	AADD(aFields,{"T9_UNIT"   ,_aTamX[3],_aTamX[1],_aTamX[2]})
	_aTamX    := TamSx3("C7_TOTAL")
	AADD(aFields,{"T9_TOTAL"  ,_aTamX[3],_aTamX[1],_aTamX[2]})
	_aTamX    := TamSx3("C7_DATPRF")
	AADD(aFields,{"T9_DTPRV"  ,_aTamX[3],_aTamX[1],_aTamX[2]})
	_aTamX    := TamSx3("C7_LOCAL")
	AADD(aFields,{"T9_ALMOX"  ,_aTamX[3],_aTamX[1],_aTamX[2]})
	_aTamX    := TamSx3("C7_OBS")
	AADD(aFields,{"T9_OBSERV" ,_aTamX[3],_aTamX[1],_aTamX[2]})
	_aTamX    := TamSx3("C7_CC")
	AADD(aFields,{"T9_CCUSTO" ,_aTamX[3],_aTamX[1],_aTamX[2]})
	AADD(aFields,{"T9_REG"    ,"N",10,0})
	cArq := Criatrab(aFields,.T.)
	DBUSEAREA(.t.,,cArq,"TC9")
	aFields2  := {}
	_aTamX    := TamSx3("D1_DOC")
	AADD(aFields2,{"T8_NOTA"   ,_aTamX[3],_aTamX[1],_aTamX[2]})
	_aTamX    := TamSx3("D1_SERIE")
	AADD(aFields2,{"T8_SERIE"  ,_aTamX[3],_aTamX[1],_aTamX[2]})
	_aTamX    := TamSx3("D1_COD")
	AADD(aFields2,{"T8_PRODUTO",_aTamX[3],_aTamX[1],_aTamX[2]})
	_aTamX    := TamSx3("B1_DESC")
	AADD(aFields2,{"T8_DESC"   ,_aTamX[3],_aTamX[1],_aTamX[2]})
	_aTamX    := TamSx3("D1_UM")
	AADD(aFields2,{"T8_UM"     ,_aTamX[3],_aTamX[1],_aTamX[2]})
	_aTamX    := TamSx3("D1_QUANT")
	AADD(aFields2,{"T8_QTDE"   ,_aTamX[3],_aTamX[1],_aTamX[2]})
	_aTamX    := TamSx3("D1_VUNIT")
	AADD(aFields2,{"T8_UNIT"   ,_aTamX[3],_aTamX[1],_aTamX[2]})
	_aTamX    := TamSx3("D1_TOTAL")
	AADD(aFields2,{"T8_TOTAL"  ,_aTamX[3],_aTamX[1],_aTamX[2]})
	cArq2 := Criatrab(aFields2,.T.)
	DBUSEAREA(.T.,,cArq2,"TC8")
return
static function Monta_TC9()
	// Irá efetuar a checagem de pedidos de compras
	// em aberto para este fornecedor e os itens desta nota fiscal a ser importa
	// será demonstrado ao usuário se o pedido de compra deverá ser associado
	// a entrada desta nota fiscal
	cQuery := ""
	cQuery += " SELECT  C7_NUM T9_PEDIDO,     "
	cQuery += " 		C7_ITEM T9_ITEM,      "
	cQuery += " 	    C7_PRODUTO T9_PRODUTO,"
	cQuery += " 		B1_DESC T9_DESC,      "
	cQuery += " 		B1_UM T9_UM,		  "
	cQuery += " 		C7_QUANT T9_QTDE,     "
	cQuery += " 		C7_PRECO T9_UNIT,     "
	cQuery += " 		C7_TOTAL T9_TOTAL,    "
	cQuery += " 		C7_DATPRF T9_DTPRV,   "
	cQuery += " 		C7_LOCAL T9_ALMOX,    "
	cQuery += " 		C7_OBS T9_OBSERV,     "
	cQuery += " 		C7_CC T9_CCUSTO,      "
	cQuery += " 		SC7.R_E_C_N_O_ T9_REG "
	cQuery += " FROM " + RetSqlName("SC7") + " SC7 (NOLOCK), " + RetSqlName("SB1") + " SB1 (NOLOCK) "
	cQuery += " WHERE C7_FILIAL = '" + xFilial("SC7") + "' "
	cQuery += " AND B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery += " AND SC7.D_E_L_E_T_ = ' ' "
	cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " AND C7_QUANT > C7_QUJE  "
	cQuery += " AND C7_RESIDUO = ' '  "
	cQuery += " AND C7_CONAPRO <> 'B'  "
	cQuery += " AND C7_ENCER = ' ' "
	cQuery += " AND C7_PRODUTO = B1_COD "
	cQuery += " AND C7_FORNECE = '" + SA2->A2_COD + "' "
	cQuery += " AND C7_LOJA = '" + SA2->A2_LOJA + "' "
	cQuery += " AND C7_PRODUTO IN" + FormatIn( cProds, "/")
	if MV_PAR01 <> 1
		cQuery += " AND 1 > 1 "
	endif
	cQuery += " ORDER BY C7_NUM, C7_ITEM, C7_PRODUTO "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CAD",.T.,.T.)
	TcSetField("CAD","T9_DTPRV","D",8,0)
	Dbselectarea("CAD")
	while !CAD->(EOF())
		RecLock("TC9",.T.)
			for _nX := 1 to len(aFields)
				if !(aFields[_nX,1] $ 'T9_OK')
					if aFields[_nX,2] = 'C'
						_cX := 'TC9->'+aFields[_nX,1]+' := Alltrim(CAD->'+aFields[_nX,1]+')'
					else
						_cX := 'TC9->'+aFields[_nX,1]+' := CAD->'+aFields[_nX,1]
					endif
					_cX := &_cX
				endif
			next
			TC9->T9_OK := _cMarca //ThisMark()
		TC9->(MsUnLock())
		DbSelectArea('CAD')
		CAD->(dBSkip())
	enddo
	dbSelectArea("CAD")
	CAD->(DbCloseArea())
	Dbselectarea("TC9")
	TC9->(DbGoTop())
	_cIndex := Criatrab(Nil,.F.)
	_cChave := "T9_PEDIDO"
	Indregua("TC9",_cIndex,_cChave,,,"Ordenando registros selecionados...")
	DbSetIndex(_cIndex+ordbagext())
	SysRefresh()
return
static function GetArq(cFile)
	cFile:= cGetFile( "Arquivo NFe (*.xml) | *.xml", "Selecione o Arquivo de Nota Fiscal XML",,'C:\XmlNfe',.F.,nOr(GETF_LOCALHARD,GETF_NETWORKDRIVE) ) //Exerga Unidade Mapeadas - Poliester
return cFile
statiC function Fecha()
	Close(_oPT00005)
return
static function AchaFile(cCodCHV,nTipo)
//	local   oNf
//	local   oNfe
//	local   aCompl   := {}
	local   aFiles   := {}
	local   lOk      := .F.

	private cDirINN   := SuperGetMV("MV_NGINN",.F.,"\XML\NGINN\")+ Iif(nTipo==4, 'CTE\', 'NFE\')
	private cDirERRO  := SuperGetMV("MV_NGERRO",.F.,"\XML\ERRO\")
	private cDirLIDOS := SuperGetMV("MV_NGLIDOS",.F.,"\XML\LIDOS\")+Iif(nTipo==4, 'CTE\', 'NFE\')

	if empty(cCodCHV)
		return .T.
	endif
	aFiles   := Directory(cDirINN+"\*.XML", "D")
	for nArq := 1 to len(aFiles)
		cFile    := AllTrim(cDirINN+aFiles[nArq,1])
		nHdl     := fOpen(cFile,0)
		nTamFile := fSeek(nHdl,0,2)
		fSeek(nHdl,0,0)
		cBuffer  := Space(nTamFile)                // Variavel para criacao da linha do registro para leitura
		nBtLidos := fRead(nHdl,@cBuffer,nTamFile)  // Leitura  do arquivo XML
		fClose(nHdl)
		if AT(AllTrim(cCodCHV),AllTrim(cBuffer)) > 0
			cCodCHV := cFile
			lOk     := .T.
			Exit
		endif
	next
	if !lOk
		aFiles := {}
		aFiles := Directory(cDirERRO+"\*.XML", "D")
		for nArq := 1 to len(aFiles)
			cFile := AllTrim(cDirERRO+aFiles[nArq,1])	
			nHdl    := fOpen(cFile,0)
			nTamFile := fSeek(nHdl,0,2)
			fSeek(nHdl,0,0)
			cBuffer  := Space(nTamFile)                // Variavel para criacao da linha do registro para leitura
			nBtLidos := fRead(nHdl,@cBuffer,nTamFile)  // Leitura  do arquivo XML
			fClose(nHdl)
			if AT(AllTrim(cCodCHV),AllTrim(cBuffer)) > 0
				cCodCHV := cFile
				lOk     := .T.
				Exit
			endif
		next
	endif
	if !lOk
		aFiles := {}
		aFiles := Directory(cDirERRO+"\*.XML", "D")
		for nArq := 1 to len(aFiles)
			cFile    := AllTrim(cDirERRO+aFiles[nArq,1])	
			nHdl     := fOpen(cFile,0)
			nTamFile := fSeek(nHdl,0,2)
			fSeek(nHdl,0,0)
			cBuffer  := Space(nTamFile)                // Variavel para criacao da linha do registro para leitura
			nBtLidos := fRead(nHdl,@cBuffer,nTamFile)  // Leitura  do arquivo XML
			fClose(nHdl)
			if AT(AllTrim(cCodCHV),AllTrim(cBuffer)) > 0
				cCodCHV := cFile	
				lOk := .t.
				Exit
			endif
		next
	endif
	if !lOk
		Alert("Nenhum Arquivo Encontrado, Por Favor Selecione a Opção Arquivo e Faça a Busca na Arvore de Diretórios!",_cRotina+"_016")
	endif
return cFiLe
// Funcao de envio de email sobre inclusão de PRe Nota
user function EnvMailN(_cSubject, _cBody, _cMailTo, _cCC, _cAnexo, _cConta, _cSenha)
	local _cMailS		:= GetMv("MV_RELSERV")
	local _cAccount		:= GetMV("MV_RELACNT")
	local _cPass		:= GetMV("MV_RELFROM")
	local _cSenha2		:= GetMV("MV_RELPSW")
	local _cUsuario2	:= GetMV("MV_RELACNT")
	local lAuth			:= GetMv("MV_RELAUTH",,.F.)
	Connect Smtp Server _cMailS Account _cAccount Password _cPass RESULT lResult
		if lAuth		// Autenticacao da conta de e-mail
			lResult := MailAuth(_cUsuario2, _cSenha2)
			if !lResult
				Alert("Não foi possivel autenticar a conta - " + _cUsuario2,_cRotina+"_017")	//É melhor a mensagem aparecer para o usuário do que no console ou no log.txt - Poliester
				return
			endif
		endif
		_xx     := 0
		lResult := .F.
		while !lResult
			if !Empty(_cAnexo)
				Send Mail From _cAccount To _cMailTo CC _cCC Subject _cSubject Body _cBody ATTACHMENT _cAnexo RESULT lResult
			else
				Send Mail From _cAccount To _cMailTo CC _cCC Subject _cSubject Body _cBody RESULT lResult
			endif
			_xx++
			if _xx > 2
				Exit
			else
				Get Mail Error cErrorMsg
				ConOut(cErrorMsg)
			endif
		enddo
return
static function NfeChvOri(cChvOri,_cDevProd,cTp)
//	local   cNfori    := ""
	local   _cQry     := ""
	local   _cAlias   := "F2CHV"
	local   cRet      := ""
	default _cDevProd := ""
	_cQry += " SELECT DISTINCT F2_DOC +'/'+ F2_SERIE+'/'+D2_ITEM   DOCSERIEITEM , F4_TESDV F4_TESDV "
	_cQry += " FROM " + RetSqlName("SF2") + " SF2 (NOLOCK) "
	_cQry += "  LEFT JOIN " + RetSqlName("SD2") + " SD2 (NOLOCK) ON D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND F2_SERIE = D2_SERIE "
	_cQry += "       JOIN " + RetSqlName("SF4") + " SF4 (NOLOCK) ON F4_CODIGO = D2_TES "
	_cQry += " WHERE SF2.F2_CHVNFE = '"	 + cChvOri 	 + "' "
	_cQry += "   AND SD2.D2_COD   = '"	 + _cDevProd + "'     "
	_cQry := ChangeQuery(_cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cAlias,.T.,.F.)
	cRet  := ""
	dbSelectArea(_cAlias)
	(_cAlias)->(dbGoTop())
	while !(_cAlias)->(EOF())
		if !_lOk
		 	if cTp== "TES"
		 		cRet := (_cAlias)->F4_TESDV
		 		_lOk:= .T.
		 	else
		 		cRet := (_cAlias)->DOCSERIEITEM
		 		_lOk:= .T.
		 	endif
		endif
		(_cAlias)->(dbSkip())
	enddo
	(_cAlias)->(DBCLOSEAREA())
return cRet
static Function fAdPrdCli(cTp,cProduto,cCli,cLoja,cQtd)
	private aFields := {}
	private aCampos := {}

	lOk  := .F.
	lOut := .F.

	DEFINE FONT oFontTit NAME "Arial" SIZE 000,-013 BOLD
	DEFINE FONT oFontGrp NAME "Arial" SIZE 000,-012 BOLD
	DEFINE FONT oFontNum NAME "Arial" SIZE 000,-012 
	DEFINE MSDIALOG _oDlg TITLE " Cadastro de Amarração" FROM C(377),C(720) TO C(1059),C(1629) PIXEL  FONT oFontTit
		if cTp =="C"
			@ C(002),C(011) TO C(328),C(445) LABEL  "   Produto Cliente  X Produto  Arcolor "  PIXEL OF _oDlg
			@ C(018),C(018) TO C(048),C(430) LABEL "  Cliente  " PIXEL OF _oDlg 
		else
			@ C(001),C(015) TO C(198),C(445) LABEL  "   Produto Forncedor  X Produto  Arcolor "  PIXEL OF _oDlg
			@ C(018),C(018) TO C(048),C(430) LABEL "  Forncedor  " PIXEL OF _oDlg 
		endif
		@ C(033),C(030) Say "Produto: " Size C(060),C(008) PIXEL OF _oDlg
		@ C(033),C(061) Say alltrim(cProduto)  Size C(045),C(008)  PIXEL OF _oDlg FONT oFontNum
		@ C(033),C(120) Say "Descrição: " Size C(030),C(008)  PIXEL OF _oDlg  	 			
		@ C(033),C(179) Say alltrim(oDet[nX]:_Prod:_xProd:TEXT) Size C(150),C(008)  PIXEL OF _oDlg	FONT oFontNum			
		@ C(033),C(370) Say "NCM:"  Size C(025),C(008)PIXEL OF _oDlg 
		@ C(033),C(388) Say cNCM Size C(030),C(008)  PIXEL OF _oDlg  FONT oFontNum	
		@ C(059),C(018) TO C(088),C(430) LABEL "  Arcolor  " PIXEL OF _oDlg
		@ C(072),C(030) Say "Produto : " Size C(060),C(008) PIXEL OF _oDlg  
		@ C(072),C(061) Say alltrim(cEdit1)  Size C(045),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg FONT oFontNum
		@ C(072),C(120) Say "Descrição: " Size C(150),C(008)  PIXEL OF _oDlg					
		@ C(072),C(179) Say _DESCdigit Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg FONT oFontNum						
		@ C(072),C(370) Say "NCM:"  Size C(025),C(008)PIXEL OF _oDlg 
		@ C(072),C(388) Say _NCMdigit  Size C(020),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg FONT oFontNum
		if cTp =="C"	 
			fGridProd("PRD",cProduto,cCli,cLoja,cQtd)
		else
			@ C(102),C(018) MsGet oEdit1 Var cEdit1  F3 "SB1" Valid(ValProd()) Size C(340),C(009) COLOR CLR_HBLUE PIXEL OF _oDlg  FONT oFontNum	
			@ C(102),C(380) Button "Buscar" Size C(047),C(012) PIXEL OF _oDlg Action(_oDlg:End())
			oEdit1:SetFocus()
		endif
		@ C(305),C(323) Button "OK" Size C(047),C(012) PIXEL OF _oDlg Action(_oDlg:End())
		@ C(305),C(380) Button "Cancelar" Size C(047),C(012) PIXEL OF _oDlg Action(_oDlg:End())
	ACTIVATE MSDIALOG _oDlg CENTERED
	if Chkproc != .T.
		MsgAlert("Produto Cod.: "+ALLTRIM(cProduto)+" Nao Encontrado. A Importacao sera interrompida",_cRotina+"_011")
		PutMV("MV_PCNFE",lPcNfe)
		return Nil
	else
		if cTp == "C"
			if SA7->(dbSetOrder(1), dbSeek(xFilial("SA7")+SA1->A1_COD+SA1->A1_LOJA+cEdit1))
				RecLock("SA7",.F.)
			else
				Reclock("SA7",.T.)
			endif	
				SA7->A7_FILIAL  := xFilial("SA7")
				SA7->A7_CLIENTE := SA1->A1_COD
				SA7->A7_LOJA 	:= SA1->A1_LOJA
				SA7->A7_DESCCLI := oDet[nX]:_Prod:_xProd:TEXT
				SA7->A7_PRODUTO := cEdit1 //SB1->B1_COD
				SA7->A7_CODCLI  := xProduto
			SA7->(MsUnlock())
		else
			if SA5->(dbSetOrder(1), dbSeek(xFilial("SA5")+SA2->A2_COD+SA2->A2_LOJA+cEdit1))
				RecLock("SA5",.F.)
			else
				Reclock("SA5",.T.)
			endif	
				SA5->A5_FILIAL  := xFilial("SA5")
				SA5->A5_FORNECE := SA2->A2_COD
				SA5->A5_LOJA 	:= SA2->A2_LOJA
				SA5->A5_NOMEFOR := SA2->A2_NOME
				SA5->A5_PRODUTO := cEdit1 //SB1->B1_COD
				SA5->A5_NOMPROD := oDet[nX]:_Prod:_xProd:TEXT
				SA5->A5_CODPRF  := xProduto
			SA5->(MsUnLock())
		endif
	endif
return
/*
static function MTudo()
	DbSelectArea('TEMP')
	TEMP->(dbGoTop())
	While !TEMP->(EOF())
		MsProcTxt('Aguarde...')
		RecLock('TEMP',.F.)
			TEMP->OK := _cMarca
		TEMP->(MsUnlock())
		TEMP->(DbSkip())
	EndDo
	DbGoTop()
	DlgRefresh(_oBrw)
	SysRefresh()
return .T.
*/
static function DTudo()
	DbSelectArea('TEMP')
	TEMP->(dbGoTop())
	while !TEMP->(EOF())
		RecLock('TEMP',.F.)
			TEMP->OK := ThisMark()
		TEMP->(MsUnlock())
		TEMP->(DbSkip())
	enddo
	TEMP->(DbGoTop())
	DlgRefresh(_oBrw)
	SysRefresh()
return .T.
static function MarK(cTp)
//	local cNfori:= ""
	DbSelectArea('TEMP')
	RecLock('TEMP',.F.)
		If Empty(TEMP->OK)
			TEMP->OK := getMark()
		//	DlgRefresh(_oBrw)
		Endif
	TEMP->(MsUnLock())
	SysRefresh()
	if !Empty(TEMP->OK)
		if cTp== "PRD" 
			cEdit1 	   := TEMP->PRODUTO
			_DESCdigit := TEMP->DESCRICAO
			_NCMdigit  := TEMP->NCM	
			DlgRefresh(_oDlg)
			SysRefresh()
			If  MsgYesNo("Associar produto do Cliente "  + ALLTRIM(cProduto) + " ao produto Arcolor " + ALLTRIM(TEMP->PRODUTO) + " ?")	
				Chkproc:= .T.
			Else
				Chkproc:= .F.
				_oDlg:End()
				return
			EndIf	
			//_oDlg:End()
		ElseIf cTp== "NF"
			_cNfeori := TEMP->NF+"/"+TEMP->SERIE+"/"+TEMP->ITEM
		Else
			DbSelectArea('TEMP')
			RecLock('TEMP',.F.)
				TEMP->OK := ThisMark()
			TEMP->(MsUnLock())
			DlgRefresh(_oBrw)
			SysRefresh()		
		endif
	endif
return
static function Cria_TEMP(cTp)
	local   _aTamX := {}
	if Select("TEMP") <> 0
		TEMP->(dbCloseArea())
	endif
	aFields := {}
	if cTp =="PRD"
		AADD(aFields,{"OK"       ,"C",02,0})
		_aTamX  := TamSx3("B1_COD")
		AADD(aFields,{"PRODUTO"  ,_aTamX[3],_aTamX[1],_aTamX[2]})
		_aTamX  := TamSx3("B1_DESC")
		AADD(aFields,{"DESCRICAO",_aTamX[3],_aTamX[1],_aTamX[2]})
		_aTamX  := TamSx3("B1_POSIPI")
		AADD(aFields,{"NCM"      ,_aTamX[3],_aTamX[1],_aTamX[2]})
	elseif cTp == "NF"
		AADD(aFields,{"OK"       ,"C",02,0})
		_aTamX  := TamSx3("F2_DOC")
		AADD(aFields,{"NF"       ,_aTamX[3],_aTamX[1],_aTamX[2]})
		_aTamX  := TamSx3("F2_SERIE")
		AADD(aFields,{"SERIE"    ,_aTamX[3],_aTamX[1],_aTamX[2]})
		_aTamX  := TamSx3("F2_EMISSAO")
		AADD(aFields,{"EMISSAO"  ,_aTamX[3],_aTamX[1],_aTamX[2]})
		_aTamX  := TamSx3("D2_ITEM")
		AADD(aFields,{"ITEM"     ,_aTamX[3],_aTamX[1],_aTamX[2]})
		_aTamX  := TamSx3("D2_QUANT")
		AADD(aFields,{"QTDE"     ,_aTamX[3],_aTamX[1],_aTamX[2]})
		_aTamX  := TamSx3("F2_EMISSAO")
		AADD(aFields,{"EMISSAO2" ,_aTamX[3],_aTamX[1],_aTamX[2]})
	endif
	cArq := Criatrab(aFields,.T.)
	DBUSEAREA(.T.,,cArq,"TEMP")
return
static function Monta_TEMP(cCliente,cLoja,cQtDev,cTp,cProduto,cCmp1,cCmp2,cCmp3)
	local   _cQry := ""
	private _cX   := ""
	private _nX   := ""
	if cTp =="PRD"
		_cQry += "SELECT DISTINCT B1_COD PRODUTO, B1_DESC DESCRICAO, B1_POSIPI NCM "
		_cQry += " FROM " + RetSqlName("SF2") + " SF2 (NOLOCK) "
		_cQry += "  LEFT JOIN " + RetSqlName("SD2") + " SD2 (NOLOCK) ON D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND F2_SERIE = D2_SERIE "
		_cQry += "  LEFT JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON B1_COD = D2_COD AND B1_MSBLQL = 2 "
		_cQry += " WHERE SF2.F2_CLIENTE = '"	 + cCliente 	 + "' AND SF2.F2_LOJA = '"+  cLoja 	+ "'"
		if !empty(cCmp1) .or. !empty(cCmp2) .or. !empty(cCmp3) 
			_cQry += " AND ( "
			if !empty(cCmp1)
				_cQry +=  " B1_COD LIKE '%" + cCmp1 + "%'  "
				if !empty(cCmp2) .Or. !empty(cCmp3)
					_cQry +=  " OR "
				endif
			endif
			if !empty(cCmp2)
				_cQry +=  "  B1_DESC LIKE '%" + cCmp2 + "%'  "
				if !empty(cCmp3)
					_cQry +=  " OR "
				endif
			endif	
			if !empty(cCmp3)
				_cQry +=  " B1_POSIPI LIKE '%"  + cCmp3 + "%'"
			endif
			_cQry += ")"
		endif
		_cQry += "  ORDER BY  B1_COD "
	elseif cTp =="NF"
		//_cQry += " SELECT F2_DOC NF, F2_SERIE SERIE, D2_ITEM ITEM, SUBSTRING(D2_EMISSAO,7,2) + '/' +  SUBSTRING(D2_EMISSAO,5,2) + '/' + SUBSTRING(D2_EMISSAO,1,4) EMISSAO , SUM(D2_QUANT-D2_QTDEDEV) QTDE , D2_EMISSAO EMISSAO2 "
		_cQry += " SELECT F2_DOC NF, F2_SERIE SERIE, D2_ITEM ITEM, D2_EMISSAO EMISSAO, SUM(D2_QUANT-D2_QTDEDEV) QTDE, D2_EMISSAO EMISSAO2 "
		_cQry += " FROM " + RetSqlName("SF2") + " SF2 (NOLOCK) "
		_cQry += "    LEFT JOIN " + RetSqlName("SD2") + " SD2 (NOLOCK) ON D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND F2_SERIE = D2_SERIE "
		_cQry += " WHERE SF2.F2_CLIENTE = '"	 + cCliente 	 + "' AND SF2.F2_LOJA = '"+  cLoja 	+ "'" 
		_cQry += "   AND SD2.D2_COD     = '"	 + cProduto + "'  " 
		_cQry += "   AND D2_QTDEDEV + " + cValtochar(cQtDev) + " <  D2_QUANT"	
		_cQry += " GROUP BY F2_DOC , F2_SERIE, D2_ITEM,  SUBSTRING(D2_EMISSAO,7,2) + '/' +  SUBSTRING(D2_EMISSAO,5,2) + '/' +  SUBSTRING(D2_EMISSAO,1,4) , D2_EMISSAO "
		_cQry += " ORDER BY D2_EMISSAO  DESC "
	endif
	_cQry := ChangeQuery(_cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"CAD",.T.,.T.)
	TcSetField("CAD","EMISSAO" ,"D",8,0)
	TcSetField("CAD","EMISSAO2","D",8,0)
	Dbselectarea("CAD")
	While CAD->(!EOF())
		RecLock("TEMP",.T.)
		For _nX := 1 To Len(aFields)
			If !(aFields[_nX,1] $ 'OK')
				If aFields[_nX,2] = 'C'
					_cX := 'TEMP->'+aFields[_nX,1]+' := Alltrim(CAD->'+aFields[_nX,1]+')'
				Else
					_cX := 'TEMP->'+aFields[_nX,1]+' := CAD->'+aFields[_nX,1]
				Endif
				_cX := &_cX
			Endif
		Next
		TEMP->OK := ThisMark()
		TEMP->(MsUnLock())	
		DbSelectArea('CAD')
		CAD->(dBSkip())
	EndDo
	Dbselectarea("CAD")
	DbCloseArea()
	Dbselectarea("TEMP")
	DbGoTop()
	_cIndex := Criatrab(Nil,.F.)
	_cChave := IIF(cTp =="NF","EMISSAO2" ,"PRODUTO")
	Indregua("TEMP",_cIndex,_cChave,,,"Ordenando registros selecionados...")
	DbSetIndex(_cIndex+ordbagext())
return
static function SELORIGEM(cCliente, cLoja,cProduto,cQtDev)
	local   _aTamX := {}
	private cTp    := "NF"

	DEFINE MSDIALOG _oDlg TITLE "  Produto X  NF-e de Saída  " FROM C(377),C(720) TO C(1059),C(1629) PIXEL  FONT oFontTit
		@ C(003),C(015) TO C(328),C(445) LABEL  "   Notas de Saída com o Produto: " + alltrim(cProduto)   PIXEL OF _oDlg
		aCampos := {}
		AADD(aCampos,{'OK'	   ,'#','@!','2','0'})
		_aTamX  := TamSx3("F2_DOC")
		AADD(aCampos,{'NF'   ,'Nota Fiscal',PesqPict("SF2","F2_DOC"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX  := TamSx3("F2_SERIE")
		AADD(aCampos,{'SERIE'  ,'Série',PesqPict("SF2","F2_SERIE"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX  := TamSx3("F2_EMISSAO")
		AADD(aCampos,{'EMISSAO','Emissão',PesqPict("SF2","F2_EMISSAO"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX  := TamSx3("D2_ITEM")
		AADD(aCampos,{'ITEM'   ,'Item',PesqPict("SD2","D2_ITEM"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		_aTamX  := TamSx3("D2_QUANT")
		//AADD(aCampos,{'QTDE'   ,'Qtd. Disp. para Devolução','@EZ 999,999.9999',cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		AADD(aCampos,{'QTDE'   ,'Qtd. Disp. para Devolução',PesqPict("SD2","D2_QUANT"),cValToChar(_aTamX[1]),cValToChar(_aTamX[2])})
		Cria_TEMP("NF")
		Monta_TEMP(cCliente,cLoja,0,"NF",cProduto)
		If !Empty(TEMP->(RecCount()))	
			DbSelectArea('TEMP')					
			@ C(022),C(019) TO C(290),C(430) BROWSE "TEMP" MARK "OK" FIELDS aCampos Object _oBrw  
			DTudo()
			DbSelectArea('TEMP')		
			_oBrw:bMark := {|| MarK("NF"),_oDlg:End()}
		EndIf
		@ C(305),C(323) Button "OK" Size C(047),C(012) PIXEL OF _oDlg Action(_oDlg:End())
		@ C(305),C(380) Button "Cancelar" Size C(047),C(012) PIXEL OF _oDlg Action(_oDlg:End())
	ACTIVATE MSDIALOG _oDlg CENTERED
return _cNfeori
static function fGridProd(cTp,cProduto,cCli,cLoja,cQtd,cCmp1,cCmp2,cCmp3)
	aCampos := {}
	AADD(aCampos,{'OK'			,'#','@!','2','0'})
	AADD(aCampos,{'PRODUTO'	,'PRODUTO','@!','15','0'})
	AADD(aCampos,{'DESCRICAO'	,'Descrição','@!','60','0'})
	AADD(aCampos,{'NCM'		,'NCM','@!','15','0'})
//	AADD(aCampos,{'QTDE'	,'Qtde','@EZ 999,999.9999','10','4'})
	Cria_TEMP("PRD")
	//Monta_TEMP(cCli,cLoja,0     ,"PRD",cProduto,,cCmp1,cCmp2,cCmp3)
	Monta_TEMP(cCli,cLoja,0     ,"PRD",cProduto,cCmp1,cCmp2,cCmp3)
	if !Empty(TEMP->(RecCount()))	
		DbSelectArea('TEMP')
			@ C(102),C(018) TO C(290),C(430) BROWSE "TEMP" MARK "OK" FIELDS aCampos Object _oBrw  
		DTudo()
		DbSelectArea('TEMP')		
		_oBrw:bMark := {|| MarK("PRD"),_oDlg:End()}	
	endif
return
