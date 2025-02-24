#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#DEFINE  DMPAPER_A4 9
/*/{Protheus.doc} RCOMR003
@description Imprime o Pedido de Compra personalizado solicitado pelo cliente.
@author Marcelo Evangelista
@since 05/04/2013
@version 1.0
@history 28/05/2013, Adriano Leonardo, Ajustes não identificados no cabeçalho do código fonte.
@history 15/07/2013, Adriano Leonardo, Ajustes não identificados no cabeçalho do código fonte.
@history 30/10/2013, Júlio Soares, Ajustes não identificados no cabeçalho do código fonte.
@history 20/02/2014, Júlio Soares, Ajustes não identificados no cabeçalho do código fonte.
@history 01/10/2019, Anderson Coelho, Eliminação da tela de impressão do SetPrint.
@history 25/01/2023, Diego Rodrigues, utilizar a descrição do pedido de compra, independente do parametro MV_PAR03 quando não houver registro na SA5.
@type function
@see https://allss.com.br
/*/
user function RCOMR003()
	//+--------------------------------------------------------------+
	//¦ Define Variaveis de ambiente                                 ¦                      
	//+--------------------------------------------------------------+
	Private	titulo		:= "Pedido de Compras Arcolor"
	Private	cDesc1		:= "Este programa imprimirá o Pedido de Compras Arcolor"
	Private	cDesc2		:= ""
	Private	cDesc3		:= ""
//	Private	tamanho		:= "M"
	Private	nomeprog 	:= "RCOMR003"
//	Private	wnrel		:= nomeprog
	Private	cPerg		:= nomeprog
//	Private	cString		:= "SC7"		//"SF1"
//	Private	_cObs 		:= ""  
	Private	_cNomeCien	:= ""
	Private _cSimbmoeda := "R$ "
//	Private	aReturn		:= { "Especial", 1,"Administracao", 1, 3, 1,"",1 }
//	Private	limite		:= 220
//	Private	nLastKey	:= 0
//	Private	lContinua	:= .T.
	Private	_lDadosTec	:= .T.

	//+-------------------------------------------------------------------------+
	//¦ Verifica as perguntas selecionadas.    								      ¦
	//+-------------------------------------------------------------------------+
	ValidPerg()
	If !Pergunte(cPerg,.T.)
		return
	EndIf
	//+--------------------------------------------------------------+
	//¦ Envia controle para a funcao SETPRINT                        ¦
	//+--------------------------------------------------------------+
	//wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,"",".T.","","",.F.)

	//If nLastKey == 27
	 //  return
	//EndIf
	//+--------------------------------------------------------------+
	//¦ Verifica Posicao do Formulario na Impressora                 ¦          
	//+--------------------------------------------------------------+
	//SetDefault(aReturn,cString)
	//If nLastKey == 27
	//	return
	//EndIf
	// - Alterado por Júlio Soares para imprimir a moeda de acordo com regra selecionada pelo usuário
	If MV_PAR04 == 1
		_cSimbmoeda := "R$ "
	Else
		_cSimbmoeda := GetMv("MV_SIMB"+Alltrim(STR(SC7->C7_MOEDA)))		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: GetMv("MV_SIMB"+Alltrim(STR(SC7->C7_MOEDA)))
	EndIf
	//+--------------------------------------------------------------+
	//¦ Inicio do Processamento do pedido de compras                 ¦
	//+--------------------------------------------------------------+
	//RptStatus( {|lEnd| ImprimeRel(@lEnd) },"Imprimindo Relatório. Aguarde...")
	Processa({|lEnd| ImprimeRel(@lEnd)},"["+nomeprog+"] "+titulo,"Imprimindo pedido(s) de compra(s). Aguarde...",.T.)
return
/*/{Protheus.doc} ImprimeRel
@description Rotina de processamento do relatório "RCOMR003".
@author Marcelo Evangelista
@since 11/04/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ImprimeRel(lEnd)
	
	Local   _cSC7Y := GetNextAlias()
	Local   _cSC7X := GetNextAlias()
	//Local 	_xProc := 0
	Local   nAvc   := 0
	Local   _x     := 0
	Local   i      := 0
	Local   aCol   := {	{0063,"Código"				 ,3},;
					 	{0278,"Descrição do Produto" ,3},;
					 	{0815,"Und"				     ,3},;
					 	{1035,"Quant."				 ,1},; 
					 	{1265,"Prc Unit."			 ,1},; // 1315
					 	{1360,"%IPI"			  	 ,1},; // 1410
					 	{1525,"Vlr IPI"			 	 ,1},;
					 	{1645,"%ICMS"				 ,1},;
			  		 	{1815,"Vlr ICMS"			 ,1},; 
					 	{1990,"Dt.Entrega"		 	 ,1},;
					 	{2190,"Vl.Desconto"			 ,1},;
					 	{2360,"Total"				 ,1} }
	Private oPrn        := TMSPrinter():New()
	Private oFont1      := TFont():New( "Arial",,11,,.T.,,,,   ,.F. )
	Private oFont11     := TFont():New( "Arial",,08,,.F.,,,,   ,.F. )
//	Private oFont6      := TFont():New( "Arial",,06,,.F.,,,,   ,.F. )
	Private oFont12     := TFont():New( "Arial",,10,,.T.,,,,   ,.F. ) 
	Private oFont2      := TFont():New( "Arial",,11,,.F.,,,,   ,.F. )
	Private oFont21     := TFont():New( "Arial",,09,,.T.,,,,   ,.F. )
//	Private oFont3      := TFont():New( "Arial",,13,,.T.,,,,   ,.F. )
	Private oFont4      := TFont():New( "Arial",,11,,.F.,,,,   ,.F. )
//	Private oFont41     := TFont():New( "Arial",,13,,.F.,,,,   ,.F. ) 
//	Private oFont5      := TFont():New( "Arial",,17,,.F.,,,,.T.,.F. )
//	Private oFont15     := TFont():New( "Arial",,15,,.T.,,,,.F.,.T. )
//	Private oFont7      := TFont():New( "Arial",,11,,.F.,,,,.F.,.F. ) 
	Private nLin        := 0
	Private _nNumPagina := 0
	Private _nPagTot    := 0
	Private _xProc      := 0
	Private	lImprime    := .F.
	Private _cObserItem := ""
	Private	cNumPed     := ""
	Private	cContato    := ""
	Private	cCodUsua    := ""
	Private	_cControle  := ""
	Private _mObserve   := ""
	Private	dDataEmis   := STOD("")
	Private	dPrazoEnt   := STOD("")
	Private _cMvPar06   := ""

	If AllTrim(FunName()) == "MATA490"
		MV_PAR06 := 2				//"Financeiro"
	ElseIf Empty(MV_PAR06)
		MV_PAR06 := 1				//"Compras"
	EndIf
	If Empty(MV_PAR02)				//Até Núm. Pedido
		MV_PAR02 := Replicate("Z",Len(MV_PAR02))
	EndIf
	If Empty(MV_PAR08)				//Até Emissão
		MV_PAR08 := Date()+365
	EndIf
	If !empty(MV_PAR06) 	
		_cMvPar06 := Iif (MV_PAR06 == 1 ,'C',iif(MV_PAR06==2, 'F',iif( MV_PAR06==3 , 'O' , '' )))
	EndIf
	oPrn:SetPaperSize(DMPAPER_A4)  //Ajusta o tamanho da página
	oPrn:SetPortRait()
	oPrn:Setup()
	oPrn:SetPortRait()
		if Select(_cSC7Y) > 0
			(_cSC7Y)->(dbCloseArea())
		endif
	BeginSql Alias _cSC7Y
		SELECT DISTINCT C7_FILIAL, C7_NUM
		FROM %table:SC7% SC7 (NOLOCK)
		WHERE SC7.C7_FILIAL         = %xFilial:SC7%
		  AND SC7.C7_NUM      BETWEEN %Exp:MV_PAR01%       AND %Exp:MV_PAR02%
		  AND SC7.C7_EMISSAO  BETWEEN %Exp:DTOS(MV_PAR07)% AND %Exp:DTOS(MV_PAR08)%
		  AND SC7.C7_DEPART         = %Exp:_cMvPar06% 
	  	  AND SC7.%NotDel%
		ORDER BY C7_FILIAL, C7_NUM
	EndSql
	for _xProc := MV_PAR09 to 2
		If _xProc == 2
			nAvc        := 0
			nLin        := 0
			_nPagTot    := _nNumPagina
			_nNumPagina := 0
			_cObserItem := ""
		EndIf
		dbSelectArea(_cSC7Y)
		(_cSC7Y)->(dbGoTop())
		while !(_cSC7Y)->(EOF()) .AND. !lEnd
			dbSelectArea("SC7")
			SC7->(dbSetOrder(1))
			SC7->(MsSeek((_cSC7Y)->C7_FILIAL+(_cSC7Y)->C7_NUM,.T.,.F.))
			//Observações Gerais do Pedido de Compras
			lImprime   := .F.
			cNumPed    := SC7->C7_NUM
			dDataEmis  := SC7->C7_EMISSAO
			cContato   := SC7->C7_CONTATO
			cCodUsua   := SC7->C7_USERINC
			dPrazoEnt  := SC7->C7_DATPRF 
			_cControle := SC7->C7_NUMPESN
			_mObserve  := SC7->C7_OBSERVE
			dbSelectArea("SA2")
			SA2->(dbSetOrder(1))
			SA2->(MsSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,.T.,.F.))
			dbSelectArea("SE4")
			SE4->(dbSetOrder(1))
			SE4->(MsSeek(xFilial("SE4")+SC7->C7_COND,.T.,.F.))
			If _xProc == 2
				//Início da impressão
				oPrn:EndPage()
				oPrn:StartPage()
			EndIf
			CabPed1()
			CabPed2()   
			If _xProc == 2
				oPrn:Box(nLin,0050,nLin+100,2380)
			EndIf
			nLin += 0030 
			If _xProc == 2
				for _x := 1 to len(aCol)
					oPrn:Say(nLin,aCol[_x,1],aCol[_x,2],oFont21,100,,,aCol[_x,3])
				next
			EndIf
			nLin += 0100
			MaFisIni(SA2->A2_COD,SA2->A2_LOJA,"F","N",'',NIL,,,"SB1","MATA103")
			nItem 		:= 0
			_nTotPro 	:= 0
			_nTotIpi 	:= 0
			_nTotDesc 	:= 0
			_nTotSt 	:= 0
			_nTotIcm 	:= 0
			//_nPeso 		:= 0 
			_nValfrete  := 0
			//_nTotFrete	:= 0
			_nValDesp   := 0
			_nNumPagina := 0
			lImprime    := .F.
			if Select(_cSC7X) > 0
				(_cSC7X)->(dbCloseArea())
			endif
			BeginSql Alias _cSC7X
				SELECT *
				FROM %table:SC7% SC7 (NOLOCK)
				WHERE SC7.C7_FILIAL  = %Exp:(_cSC7Y)->C7_FILIAL%
					AND SC7.C7_NUM   = %Exp:(_cSC7Y)->C7_NUM%
			  		AND SC7.%NotDel%
				ORDER BY C7_ITEM
			EndSql
			dbSelectArea(_cSC7X)
			ProcRegua((_cSC7X)->(RecCount()))
			(_cSC7X)->(dbGoTop())
		//	while !(_cSC7X)->(EOF())
				while !(_cSC7X)->(EOF()) .AND. !lEnd
					IncProc("Processando PC '"+(_cSC7X)->C7_NUM+"'...")
					_cEspecif   := ""
					//_cObserItem := ""
					If !Empty((_cSC7X)->C7_OBS)
						_cObserItem += IIF(Empty(_cObserItem),AllTrim((_cSC7X)->C7_PRODUTO) + ": " + AllTrim((_cSC7X)->C7_OBS), " / " + AllTrim((_cSC7X)->C7_PRODUTO)+ ": " + AllTrim((_cSC7X)->C7_OBS))
					EndIf
					dbSelectArea("SZE")
					SZE->(dbOrderNickName("ZE_CODIGO"))
					SZE->(dbGoTop())
					If SZE->(MsSeek(xFilial("SZE") + (_cSC7X)->C7_ESPECIF,.T.,.F.))
						_cEspecif := SZE->ZE_ESPECIF
					EndIf
					dbSelectArea("SB1")
					SB1->(dbSetOrder(1))
					SB1->(MsSeek(xFilial("SB1")+(_cSC7X)->C7_PRODUTO,.T.,.F.))
					dbSelectArea("SF4")
					SF4->(dbSetOrder(1))
					SF4->(MsSeek(xFilial("SF4")+(_cSC7X)->C7_TES,.T.,.F.))
					If _lDadosTec	==	.T.
						dbSelectArea("SB5")
						SB5->(dbSetOrder(1))
						SB5->(MsSeek(xFilial("SB5")+(_cSC7X)->C7_PRODUTO,.T.,.F.))
						_cNomeCien	:=	SB5->B5_CEME  
						_lDadosTec	:=	.F.
					EndIF
					dbSelectArea("SA5")
					SA5->(dbSetOrder(2))
					SA5->(MsSeek(xFilial("SA5")+(_cSC7X)->C7_PRODUTO + (_cSC7X)->C7_FORNECE,.T.,.F.))
					// - ALTERADO PARA TRATAR CONVERSÃO DE MOEDAS
						If (MV_PAR04) == 1
							If (_cSC7X)->C7_MOEDA == 1
							     _nMultiplic := 1
							Else
							     _nMultiplic := (_cSC7X)->C7_TXMOEDA
							EndIf
						Else 
							_nMultiplic := 1				
						EndIf
					// - \ALTERADO
					MaFisAdd((_cSC7X)->C7_PRODUTO,(_cSC7X)->C7_TES,(_cSC7X)->C7_QUANT,(_cSC7X)->C7_PRECO,(_cSC7X)->C7_VLDESC,,,,0,0,0,0,(_cSC7X)->(C7_TOTAL+C7_VLDESC),0,SB1->(Recno()),SF4->(Recno()))
					nItem        += 1
					_cCodProduto := AllTrim((_cSC7X)->C7_PRODUTO)
					nLinhas      := MlCount(_cCodProduto,18)
					nAvc         := 0
					for i := 1 to nLinhas
						If i == 1
							If _xProc == 2
								oPrn:Say(nLin      ,aCol[1,1],MemoLine(_cCodProduto,30,i),oFont11,100,,,3)
							EndIf
						Else
							nAvc += 0050
							If _xProc == 2
								oPrn:Say(nLin+nAvc ,aCol[1,1],MemoLine(_cCodProduto,30,i),oFont11,100,,,3)
							EndIf
						EndIf
					next
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Tratamento para utilizar o MemoLine, concatenando o conteudo da descricao do produto + descricao especifica ³
					//³e permitindo que seja selecionada qual descrição será impressa no Pedido de Compras							  ³			
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If mv_par03 == 1
						_cDescProduto := AllTrim(SB1->B1_DESC)
					Else
						If SA5->(MsSeek(xFilial("SA5")+(_cSC7X)->C7_PRODUTO + (_cSC7X)->C7_FORNECE,.T.,.F.))
							_cDescProduto := AllTrim(SA5->A5_NOMPROD)
						else
							_cDescProduto := AllTrim(SB1->B1_DESC)
						EndIF
					EndIf
					nLinhas := MlCount(_cDescProduto,30)
					nAvanco := 0
					for i := 1 to nLinhas
						If i == 1
							If _xProc == 2
								oPrn:Say(nLin,aCol[2,1],MemoLine(_cDescProduto,30,i)                           ,oFont11,100,,,3)
							EndIf
						Else
							nAvanco += 0050
							If _xProc == 2
								oPrn:Say(nLin+nAvanco,aCol[2,1],MemoLine(_cDescProduto,30,i)                   ,oFont11,100,,,3)
							EndIf
						EndIf
					next
					If _xProc == 2
						If SA2->A2_EST <> 'EX'
							_nTotIpi  += (_cSC7X)->C7_VALIPI *_nMultiplic
							_nTotIcm  += (_cSC7X)->C7_VALICM *_nMultiplic
							_nTotSt   += (_cSC7X)->C7_ICMSRET*_nMultiplic
						EndIf
						_nTotDesc += (_cSC7X)->C7_VLDESC*_nMultiplic
			            // - Implementado por Júlio Soares em 29/10/2013 para habilitar a opção da unidade de medida ao usuário.
						If mv_par05 == 1
							oPrn:Say(nLin,aCol[3,1],SB1->B1_UM                                                     ,oFont11,100,,,3)
							oPrn:Say(nLin,aCol[4,1],Transform((_cSC7X)->C7_QUANT ,"@E 999,999,999.99")                 ,oFont11,100,,,1)
							oPrn:Say(nLin,aCol[5,1],Transform((_cSC7X)->C7_PRECO*_nMultiplic ,"@E 999,999,999.999999") ,oFont11,100,,,1)
						Else
							oPrn:Say(nLin,aCol[3,1],SB1->B1_SEGUM                                                  ,oFont11,100,,,3)
							oPrn:Say(nLin,aCol[4,1],Transform((_cSC7X)->C7_QTSEGUM,"@E 999,999,999.99")                ,oFont11,100,,,1)
							oPrn:Say(nLin,aCol[5,1],Transform((_cSC7X)->C7_PRECO2*_nMultiplic ,"@E 999,999,999.999999"),oFont11,100,,,1)
						EndIf
						oPrn:Say(nLin,aCol[6,1],Transform((_cSC7X)->C7_IPI   ,"@E 99.9")                               ,oFont11,100,,,1)
						//_nTotIpi += MaFisRet(nItem,"IT_VALIPI")
						//_nTotIpi += (_cSC7X)->C7_VALIPI*_nMultiplic
						oPrn:Say(nLin,aCol[7,1],Transform((_cSC7X)->C7_VALIPI*_nMultiplic,"@E 999,999.99")             ,oFont11,100,,,1)
						oPrn:Say(nLin,aCol[8,1],Transform((_cSC7X)->C7_PICM  ,"@E 99.9")                               ,oFont11,100,,,1)
						//_nTotIcm += MaFisRet(nItem,"IT_VALICM")
						//_nTotIcm += (_cSC7X)->C7_VALICM*_nMultiplic
						oPrn:Say(nLin,aCol[9,1],Transform((_cSC7X)->C7_VALICM*_nMultiplic,"@E 999,999.99")             ,oFont11,100,,,1)
						//_nTotSt  += MaFisRet(nItem,"IT_VALSOL")
						//_nTotSt += (_cSC7X)->C7_ICMSRET*_nMultiplic
						If !Empty((_cSC7X)->C7_ANTEPRO)   
							oPrn:Say(nLin,aCol[10,1],DtoC(StoD((_cSC7X)->C7_ANTEPRO))                                       ,oFont11,100,,,1)
						Else
							oPrn:Say(nLin,aCol[10,1],DtoC(StoD((_cSC7X)->C7_DATPRF))                                       ,oFont11,100,,,1)
						EndIf
						oPrn:Say(nLin,aCol[11,1],Transform((_cSC7X)->C7_VLDESC*_nMultiplic ,"@E 999,999,999.9999")     ,oFont11,100,,,1)
						//_nTotDesc  += MaFisRet(nItem,"IT_VLDESC")
						//_nTotDesc  += (_cSC7X)->C7_VLDESC*_nMultiplic
						oPrn:Say(nLin,aCol[12,1],Transform((_cSC7X)->C7_TOTAL *_nMultiplic ,"@E 999,999,999.99"  )     ,oFont11,100,,,1)
					 	_nTotPro   += (_cSC7X)->C7_TOTAL*_nMultiplic
						_nFreteAux := IIF((_cSC7X)->C7_TPFRETE=='C',0,(_cSC7X)->C7_FRETE) //Avalia se o tipo de frete é CIF ou FOB
						_nTipoFrete:= (_cSC7X)->C7_TPFRETE
						// - Alterado por Júlio Soares em 24/01/2014 para implementar o valor do frete no relatório.
						// _nTotFrete += (_cSC7X)->C7_DESPESA*_nMultiplic
						_nValfrete += (_cSC7X)->C7_VALFRE
						// - Alterado por Arthur Silva em 07/08/2015 para implementar o valor de despesas acessórias no relatório.
						// _nTotFrete += ((_cSC7X)->C7_DESPESA*_nMultiplic)
						_nValDesp  += ((_cSC7X)->C7_DESPESA*_nMultiplic)
					EndIf
					If nAvc > nAvanco
						nLin += nAvc
					Else
						If nAvc < nAvanco
							nLin += nAvanco
						Else
							nLin += nAvanco
						EndIf
					EndIf
					If nLin > 3100	//2800
						//RodPe1()
						RodPe2()
						If _xProc == 2
							oPrn:EndPage()
							oPrn:StartPage()
						EndIf
						CabPed1()
					EndIf
					nLin += 0050
					dbSelectArea(_cSC7X)
					(_cSC7X)->(dbSkip())
				enddo
				if Select(_cSC7X) > 0
					(_cSC7X)->(dbCloseArea())
				endif
		//	enddo
			nLin    += 060
			nLinIni := nLin
			If nLin > 2800
				//RodPe1()
				RodPe2()
				If _xProc == 2
					oPrn:EndPage()
					oPrn:StartPage()
				EndIf
				CabPed1()  
			EndIf
			nAvanco	:= 0
			nLinIni := nLin
			If _xProc == 2
				oPrn:Say(nLin,aCol[1,1],"Condicao de Pagto:"                                                                       ,oFont1,100,,,3)
				oPrn:Say(nLin,aCol[2,1] + 170,"(" + AllTrim(SE4->E4_CODIGO) + ") " + AllTrim(SE4->E4_DESCRI)                       ,oFont1,100,,,3)
				oPrn:Say(nLin,1600,"SubTotal"                                                                                      ,oFont1,100,,,3)
				oPrn:Say(nLin,1980,": "+_cSimbmoeda                                                                                ,oFont1,100,,,3)
			//	oPrn:Say(nLin,aCol[12,1],"R$ "   + Transform(_nTotPro,"@E 999,999.99")                                             ,oFont1,100,,,1)
				oPrn:Say(nLin,aCol[12,1],Transform(_nTotPro,"@E 999,999.99")                                                       ,oFont1,100,,,1)
			EndIf
			nLin += 0070                                                                                             
			If _xProc == 2
				oPrn:Say(nLin,aCol[1,1],"Controle:"                                                                                ,oFont1,100,,,3)
			    // Corrigido por Júlio Soares em 06/11/2013 para ajustar layout do relatório
				//oPrn:Say(nLin,0280,(_cControle)                                                                                  ,oFont1,100,,,1)
				oPrn:Say(nLin,aCol[2,1] + 500,(_cControle)                                                                         ,oFont1,100,,,1)
				oPrn:Say(nLin,1600,"Valor IPI"                                                                                     ,oFont1,100,,,3)
			    oPrn:Say(nLin,1980,": "+_cSimbmoeda                                                                                ,oFont1,100,,,3)
			//	oPrn:Say(nLin,aCol[12,1],"R$ "   + Transform(_nTotIpi,"@E 999,999.99")                                             ,oFont1,100,,,1)
				oPrn:Say(nLin,aCol[12,1],Transform(_nTotIpi,"@E 999,999.99")                                                       ,oFont1,100,,,1)
			EndIf
			nLin += 0070
			If _xProc == 2
				oPrn:Say(nLin,1600,"Valor ICMS"                                                                                    ,oFont1,100,,,3)
				oPrn:Say(nLin,1980,": "+_cSimbmoeda                                                                                ,oFont1,100,,,3)
			//	oPrn:Say(nLin,aCol[12,1],"R$ "   + Transform(_nTotIcm,"@E 999,999.99")                                             ,oFont1,100,,,1)
				oPrn:Say(nLin,aCol[12,1],Transform(_nTotIcm,"@E 999,999.99")                                                       ,oFont1,100,,,1)
			EndIf
			nLin += 0070
			If _xProc == 2
				oPrn:Say(nLin,1600,"Valor ST"                                                                                      ,oFont1,100,,,3)
			    oPrn:Say(nLin,1980,": "+_cSimbmoeda                                                                                ,oFont1,100,,,3)
			//	oPrn:Say(nLin,aCol[12,1],"R$ "   + Transform(_nTotST,"@E 999,999.99")                                              ,oFont1,100,,,1)
				oPrn:Say(nLin,aCol[12,1],Transform(_nTotST,"@E 999,999.99")                                                        ,oFont1,100,,,1)
			EndIf
			nLin += 0070
			If _xProc == 2
				oPrn:Say(nLin,1600,"Vl.Desconto"                                                                                   ,oFont1,100,,,3)
			    oPrn:Say(nLin,1980,": "+_cSimbmoeda                                                                                ,oFont1,100,,,3)
			//	oPrn:Say(nLin,aCol[12,1],"R$ "   + Transform(_nTotDesc,"@E 999,999.99")                                            ,oFont1,100,,,1)
				oPrn:Say(nLin,aCol[12,1],Transform(_nTotDesc,"@E 999,999.99")                                                      ,oFont1,100,,,1)
			EndIf
			nLin += 0070
			If _xProc == 2
				oPrn:Say(nLin,1600,"Frete " + IIF(_nTipoFrete=="C","(CIF)", "(FOB)")                                               ,oFont1,100,,,3)
			    oPrn:Say(nLin,1980,": "+_cSimbmoeda                                                                                ,oFont1,100,,,3)
			//	oPrn:Say(nLin,aCol[12,1],"R$ "   + Transform(_nTotFrete,"@E 999,999.99")                                           ,oFont1,100,,,1)
			//	oPrn:Say(nLin,aCol[12,1],"R$ "   + Transform(_nValfrete+_nTotFrete,"@E 999,999.99")                                ,oFont1,100,,,1)
				oPrn:Say(nLin,aCol[12,1],Transform(_nValfrete,"@E 999,999.99")                                                     ,oFont1,100,,,1)	
			EndIf
			nLin += 0070
		// Incluído por Arthur Silva em 07/08/2015
			If _xProc == 2
				oPrn:Say(nLin,1600,"Despesas "                                                                                     ,oFont1,100,,,3)
			    oPrn:Say(nLin,1980,": "+_cSimbmoeda                                                                                ,oFont1,100,,,3)
				oPrn:Say(nLin,aCol[12,1],Transform(_nValDesp,"@E 999,999.99")                                                      ,oFont1,100,,,1)
			EndIf
			nLin += 0070
		// Fim da inclusão - Arthur Silva
			If _xProc == 2
				oPrn:Say(nLin,1600,"TOTAL DO PEDIDO"                                                                               ,oFont1,100,,,3)
			//	oPrn:Say(nLin,aCol[12,1],"R$ "   + Transform(_nTotPro+_nTotIpi+_nTotST-_nTotDesc+_nTotFrete-_nFreteAux,"@E 999,999.99"),oFont1,100,,,1) // comentado
			//	oPrn:Say(nLin,aCol[12,1],"R$ "   + Transform(_nTotPro+_nTotIpi+_nTotST-_nTotDesc+(_nValfrete+_nTotFrete)-_nFreteAux,"@E 999,999.99"),oFont1,100,,,1)
				oPrn:Say(nLin,1980,": "+_cSimbmoeda                                                                                ,oFont1,100,,,3)
			// - Alterado por Arthur Silva em 07/08/2015 para implementar o valor de despesas acessórias no relatório.
			//	oPrn:Say(nLin,aCol[12,1],Transform(_nTotPro+_nTotIpi+_nTotST-_nTotDesc+(_nValfrete+_nTotFrete)-_nFreteAux,"@E 999,999.99"),oFont1,100,,,1)
				oPrn:Say(nLin,aCol[12,1],Transform(_nTotPro+_nTotIpi+_nTotST-_nTotDesc+_nValfrete+_nValDesp-_nFreteAux,"@E 999,999.99"),oFont1,100,,,1)
			// - Fim da alteração - Arthur Silva
				oPrn:Box(nLinIni,0050,nLin,2380)
				oPrn:Say(nLin,aCol[1,1],"Dados Técnicos do Produto: "                                                              ,oFont12,100,,,3)
			EndIf
			nLin += 0070
			nLines := MLCOUNT(_cEspecif, 88)
			for _x := 1 to nLines
				If !(Empty(memoline(Alltrim(_cEspecif),88,_x)))
					If nLin > 2800
							//RodPe1()
							RodPe2()
							If _xProc == 2
								oPrn:EndPage()
								oPrn:StartPage()
							EndIf
							CabPed1()
					EndIf
					If _xProc == 2
					oPrn:Say(nLin,aCol[1,1],memoline(Alltrim(_cEspecif),88,_x)                                                             ,oFont12,100,,,3)
					EndIf
				nLin += 0070
				EndIf
			Next
			If nLin > 2800
				//RodPe1()
				RodPe2()
				If _xProc == 2
					oPrn:EndPage()
					oPrn:StartPage()
				EndIf
				CabPed1()
			EndIf
			/*
			If _xProc == 2
				oPrn:Say(nLin,aCol[1,1],SubStr(_cEspecif,089,168)                                                                  ,oFont12,100,,,3)
			EndIf
			nLin += 0070
			If nLin > 2800
				//RodPe1()
				RodPe2()
				If _xProc == 2
					oPrn:EndPage()
					oPrn:StartPage()
				EndIf
				CabPed1()
			EndIf
			If _xProc == 2
				oPrn:Say(nLin,aCol[1,1],SubStr(_cEspecif,169,244)                                                                  ,oFont12,100,,,3)
			EndIf
			nLin += 0070
			*/
		//	oPrn:Box(nLinIni,0050,nLin,2380)
			MaFisEnd()
			nLin += 0070
			_cObsAux := ""
			If !Empty(_cObserItem)
				_cObsAux += "Itens: "    + _cObserItem
			EndIf
			If !Empty(_mObserve)
				_cObsAux += " - Geral: " + _mObserve
			EndIf
			If !Empty(_cObsAux)
				_cObsAux := Upper(_cObsAux)
			EndIf
			If !Empty(_cObsAux)
				If nLin > 2800
					//RodPe1()
					RodPe2()
					If _xProc == 2
						oPrn:EndPage()
						oPrn:StartPage()
					EndIf
					CabPed1()
				EndIf
				If _xProc == 2
					oPrn:Say(nLin,aCol[1,1],"Observações: "                                                                        ,oFont1 ,100,,,3)
				EndIf
				nLin += 0070
				If nLin > 2800
					//RodPe1()
					RodPe2()
					If _xProc == 2
						oPrn:EndPage()
						oPrn:StartPage()
					EndIf
					CabPed1()
				EndIf
				for _x := 1 to len(memoline(_cObsAux,,))
					If !(Empty(memoline(Alltrim(_cObsAux),85,_x)))
						If nLin > 2800
							//RodPe1()
							RodPe2()
							If _xProc == 2
								oPrn:EndPage()
								oPrn:StartPage()
							EndIf
							CabPed1()
						EndIf
						If _xProc == 2
							oPrn:Say(nLin,0100,	memoline(Alltrim(_cObsAux),85,_x),oFont4,100,,,3)
					    EndIf
					    nLin+=0050
					EndIf
				next
		    EndIf
			//Reseto as variáveis auxiliares
			_cObserItem := ""
			_cEspecif   := ""
			_mObserve	:= ""
			RodPe1()
			RodPe2()
			If _xProc == 2
				oPrn:EndPage()
			EndIf
			dbSelectArea(_cSC7Y)
			(_cSC7Y)->(dbSkip())
		enddo
	next
	dbSelectArea(_cSC7Y)
	(_cSC7Y)->(dbCloseArea())
	oPrn:Preview()
	//MS_FLUSH()
return
/*/{Protheus.doc} CabPed1
@description Imprime os dados do cabeçalho 1 do relatório "RCOMR003".
@author Marcelo Evangelista
@since 11/04/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function CabPed1()
	nLin := 0120
	If _xProc == 2
		oPrn:Box(nLin,0050,nLin+0300,0700)
		oPrn:Box(nLin,0710,nLin+0300,1960)
		oPrn:Box(nLin,1970,nLin+0300,2380)
	EndIf
	nLin += 0305
	If _xProc == 2
		//Quadro para o Logotipo
		oPrn:SayBitmap(nLin-0285,0125,"LOGOTIPO.BMP",0500,1380/5.322033)
		//Quadro para os Dados da Empresa
		oPrn:Say(nLin-0300,0720,AllTrim(SM0->M0_NOMECOM)                                                                  ,oFont12,100,CLR_RED,,3)
		oPrn:Say(nLin-0250,0720,AllTrim(SM0->M0_ENDCOB)                                                                   ,oFont12,100,,,3)
		oPrn:Say(nLin-0250,1350,AllTrim(SM0->M0_BAIRCOB)                                                                  ,oFont12,100,,,3)
		oPrn:Say(nLin-0200,0720,AllTrim(SM0->M0_CIDCOB)+" - "+AllTrim(SM0->M0_ESTCOB)+" - Fone: "+AllTrim(SM0->M0_TEL)    ,oFont12,100,,,3)
		oPrn:Say(nLin-0150,0720,"E-mail: " + SuperGetMv("MV_MAILCOM",,"elaine.consoli@arcolor.com.br")                    ,oFont12,100,,,3)
		oPrn:Say(nLin-0100,0720,"CNPJ: "+Transform(SM0->M0_CGC ,"@R 99.999.999/9999-99")                                  ,oFont12,100,,,3)
		oPrn:Say(nLin-0100,1420,"IE: "  +Transform(SM0->M0_INSC,"@R 999.999.999.999"   )                                  ,oFont12,100,,,3)

		//Quadro para Descrição do Documento e Numero do Pedido de Compra
		oPrn:Say(nLin-0250,2140,"COMPRA"                                                                                  ,oFont12,100,CLR_RED,,2)
		oPrn:Say(nLin-0200,2140,"N.: " + AllTrim(cNumPed)                                                                 ,oFont12,100,,,2)
		oPrn:Say(nLin-0150,2135,DtoC(dDataEmis)                                                                           ,oFont12,100,,,2)

		//Quadro para impressão do código de barras
		MSBAR3("CODE128",2.8,17.5,AllTrim(cNumPed),oPrn,.F.,NIL,NIL,0.02,0.4,NIL,NIL,NIL,.F.) 
	EndIf
	nLin += 0045
return
/*/{Protheus.doc} CabPed2
@description Imprime os dados do cabeçalho 2 do relatório "RCOMR003".
@author Marcelo Evangelista
@since 11/04/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function CabPed2()
	Local _cNomeComp := ""

	dbSelectArea("SY1")
	SY1->(dbSetOrder(3))
	If SY1->(MsSeek(xFilial("SY1")+cCodUsua,.T.,.F.))
		_cNomeComp	:= SY1->Y1_NOME
	EndIf
	If _xProc == 2
		//Dados do Fornecedor
		oPrn:Say(nLin,0070,"DADOS DO FORNECEDOR:"                                                  ,oFont1,100,,,3)
	EndIf
	nLin += 0045
	If _xProc == 2
		oPrn:Say(nLin,0070,"Fornecedor:"                                                           ,oFont1,100,,,3)
		oPrn:Say(nLin,0375,SA2->A2_COD+"/"+SA2->A2_LOJA + " - " +SubStr(Alltrim(SA2->A2_NOME),1,45),oFont2,100,,,3)
	EndIf
	nLin += 0045
	If _xProc == 2
		oPrn:Say(nLin,0070,"Nome Fantasia:"                                                        ,oFont1,100,,,3)
		oPrn:Say(nLin,0375,SubStr(Alltrim(SA2->A2_NREDUZ),1,45)                                    ,oFont2,100,,,3)
	EndIf
	nLin += 0045
	If _xProc == 2
		oPrn:Say(nLin,0070,"Endereço:",																oFont1,100,,,3)
		oPrn:Say(nLin,0375,SubStr(Alltrim(SA2->A2_END),1,45),										oFont2,100,,,3)
	EndIf
	nLin += 0045
	If _xProc == 2
		oPrn:Say(nLin,0070,"Bairro:",																oFont1,100,,,3)
		oPrn:Say(nLin,0375,SubStr(Alltrim(SA2->A2_BAIRRO),1,20),									oFont2,100,,,3)
	EndIf
	nLin += 0045
	If _xProc == 2
		oPrn:Say(nLin,0070,"Cidade:",																oFont1,100,,,3)
		oPrn:Say(nLin,0375,SubStr(Alltrim(SA2->A2_MUN),1,20),										oFont2,100,,,3)
		oPrn:Say(nLin,2100,"UF:",																	oFont1,100,,,3)
		oPrn:Say(nLin,2200,Alltrim(SA2->A2_EST),													oFont2,100,,,3)
		oPrn:Say(nLin,1000,"CEP:",																	oFont1,100,,,3)
		oPrn:Say(nLin,1210,Alltrim(SA2->A2_CEP),													oFont2,100,,,3)
	EndIf
	nLin += 0045
	If _xProc == 2
		oPrn:Say(nLin,0070,"Telefone:",																oFont1,100,,,3)
		oPrn:Say(nLin,0375,Alltrim("("+SA2->A2_DDD + ")" +SA2->A2_TEL),                             oFont2,100,,,3)
		oPrn:Say(nLin,1000,"Fax:",																	oFont1,100,,,3)
		oPrn:Say(nLin,1210,Alltrim(If(!Empty(SA2->A2_FAX),"("+SA2->A2_DDD + ")" +SA2->A2_FAX,"")),	oFont2,100,,,3)
		oPrn:Say(nLin,1580,"Contato:",																oFont1,100,,,3)
		//oPrn:Say(nLin,1930,SubStr(AllTrim(cContato),1,20),											oFont2,100,,,3) 
		oPrn:Say(nLin,1930,SubStr(AllTrim(SA2->A2_CONTATO),1,20),									oFont2,100,,,3) 
	EndIf
	nLin += 0045
	If _xProc == 2
		oPrn:Say(nLin,0070,"CNPJ/CPF:",																oFont1,100,,,3)
		oPrn:Say(nLin,0375,IIF(SA2->A2_TIPO = "J",Transform(SA2->A2_CGC,"@R 99.999.999/9999-99"),Transform(SA2->A2_CGC,"@R 999.999.999-99")),oFont2,100,,,3)
		oPrn:Say(nLin,1000,"Insc. Est.:" 														   ,oFont1,100,,,3)
		oPrn:Say(nLin,1210,Alltrim(SA2->A2_INSCR) 												   ,oFont2,100,,,3)
	EndIf
	nLin += 0045
	If _xProc == 2
		oPrn:Say(nLin,0070,"Email:" 															   ,oFont1,100,,,3)
		oPrn:Say(nLin,0375,Lower(Alltrim(SA2->A2_EMAIL)) 										   ,oFont2,100,,,3)
		//oPrn:Say(nLin,0375,Lower(Alltrim(SA2->A2_EMAIL2))                                        ,oFont2,100,,,3)
	EndIf
	nLin += 0090
	If _xProc == 2
		//Dados do Comprador
		oPrn:Say(nLin,0070,"DADOS DO CONTATO:" 													   ,oFont1,100,,,3)
	EndIf
	nLin += 0045
	If _xProc == 2
		oPrn:Say(nLin,0070,"Contato:" 															   ,oFont1,100,,,3) 
		oPrn:Say(nLin,0400,AllTrim(cvaltochar(_cNomeComp)) 										   ,oFont1,100,,,3) 
		//oPrn:Say(nLin,1550,"Telefone:" 														   ,oFont1,100,,,3)
	EndIf
	//nLin += 0045
	//If _xProc == 2
		//oPrn:Say(nLin,0070,"Email:" 															   ,oFont1,100,,,3)
	//EndIf
	nLin += 0080
return
/*/{Protheus.doc} RodPe1
@description Imprime os dados do rodapé 1 do relatório "RCOMR003".
@author Adriano Leonardo
@since 11/10/2012
@version 1.0
@type function
@see https://allss.com.br
/*/
static function RodPe1()                                                            
	nLin := 2960
	If _xProc == 2
		nLin += 0160
		oPrn:Say(nLin,0065,"_________________________     _________________________     _________________________"		  ,oFont12,100,,,3)
		nLin += 0070
		oPrn:Say(nLin,0065,"COMPRADOR                               GERÊNCIA                                    DIRETORIA",oFont12,100,,,3)
	//	nLin += 0080
	EndIf
return
/*/{Protheus.doc} RodPe2
@description Imprime os dados do rodapé 2 do relatório "RCOMR003".
@author Adriano Leonardo
@since 11/10/2012
@version 1.0
@type function
@see https://allss.com.br
/*/
static function RodPe2()
	nLin := 3270
	_nNumPagina++
	If _xProc == 2
		oPrn:Box(nLin,0050,nLin+0075,2380)
		oPrn:Say(nLin+0015,0080,"Impresso em: " + DTOC(DATE()) + " - " + TIME() + " por " + AllTrim(cUserName),oFont2,100,,,3)
		oPrn:Say(nLin+0015,2000,"Página " + AllTrim(Str(_nNumPagina)) + IIF(_nPagTot>0, "/" + AllTrim(Str(_nPagTot)), "")  ,oFont2,100,,,3)
	EndIf
return
/*/{Protheus.doc} ValidPerg
@description Verifica/cria as perguntas de usuário na tabela SX1. (programa inicial: "RCOMR003").
@author Marcelo Evangelista
@since 05/04/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	local _aAlias    := GetArea()
	local aRegs     := {}
	local _aTam      := {}
	local _x         := 0
	local _y         := 0
	local _cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()

	if select(_cAliasSX1)>0
		(_cAliasSX1)->(dbCloseArea())
	endif
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))

	cPerg            := PADR(cPerg,len((_cAliasSX1)->X1_GRUPO))
	_aTam            := TamSx3("C7_NUM"    )
	AADD(aRegs,{cPerg,"01","De Pedido?"        ,"","","mv_ch1",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par01",""       ,"","","","",""                  ,"","","","",""      ,"","","","","","","","","","","","","","SC7",""})
	AADD(aRegs,{cPerg,"02","Ate Pedido?"       ,"","","mv_ch2",_aTam[3],_aTam[1],_aTam[2],0,"G","naovazio()","mv_par02",""       ,"","","","",""                  ,"","","","",""      ,"","","","","","","","","","","","","","SC7",""})
	_aTam            := {1,0,"N"}
	AADD(aRegs,{cPerg,"03","Descricao?"        ,"","","mv_ch3",_aTam[3],_aTam[1],_aTam[2],0,"C","naovazio()","mv_par03","Produto","","","","","ProdutoXFornecedor","","","","",""      ,"","","","","","","","","","","","","",""   ,""})
	AADD(aRegs,{cPerg,"04","Moeda?"            ,"","","mv_ch4",_aTam[3],_aTam[1],_aTam[2],0,"C","naovazio()","mv_par04","Real"   ,"","","","","Moeda Ped."        ,"","","","",""      ,"","","","","","","","","","","","","",""   ,""})
	AADD(aRegs,{cPerg,"05","Unidade de medida?","","","mv_ch5",_aTam[3],_aTam[1],_aTam[2],0,"C","naovazio()","mv_par05","1º UN"  ,"","","","","2º UN"             ,"","","","",""      ,"","","","","","","","","","","","","",""   ,""})
	AADD(aRegs,{cPerg,"06","Depto.?"           ,"","","mv_ch6",_aTam[3],_aTam[1],_aTam[2],0,"C","naovazio()","mv_par06","Compras","","","","","Financeiro"        ,"","","","","Outros","","","","","","","","","","","","","",""   ,""})
	_aTam            := TamSx3("C7_EMISSAO")
	AADD(aRegs,{cPerg,"07","Emitido de?"       ,"","","mv_ch7",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par07",""       ,"","","","",""                  ,"","","","",""      ,"","","","","","","","","","","","","",""   ,""})
	AADD(aRegs,{cPerg,"08","Emitido ate?"      ,"","","mv_ch8",_aTam[3],_aTam[1],_aTam[2],0,"G","naovazio()","mv_par08",""       ,"","","","",""                  ,"","","","",""      ,"","","","","","","","","","","","","",""   ,""})
	_aTam            := {1,0,"N"}
	AADD(aRegs,{cPerg,"09","Mostra tot.pagin.?","","","mv_ch9",_aTam[3],_aTam[1],_aTam[2],0,"C","naovazio()","mv_par09","Sim"    ,"","","","","Não"               ,"","","","",""      ,"","","","","","","","","","","","","",""   ,""})
	for _x := 1 To Len(aRegs)
		if !(_cAliasSX1)->(dbSeek(cPerg+aRegs[_x,2]))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				for _y := 1 to FCount()
					if _y <= len(aRegs[_x])
						FieldPut(_y,aRegs[_x,_y])
					else
						Exit
					endif
				next
			(_cAliasSX1)->(MsUnLock())
		endif
	next
	if select(_cAliasSX1)>0
		(_cAliasSX1)->(dbCloseArea())
	endif
	RestArea(_aAlias)
return
