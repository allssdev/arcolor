#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FC010BTN º Autor ³Anderson C. P. Coelho º Data ³  20/04/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Incluir um novo botao para retornar informacoes de         º±±
±±º          ³ Títulos a Receber e Recebidos. - Ficha Financeira          º±±
±±º          ³ Este botão é apresentado na tela da Posição do Cliente.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function FC010BTN()

Local _aArea    := GetArea()
Local _aSE1     := SE1->(GetArea())
Local _aSA1     := SA1->(GetArea())
Local _aSA2     := SA2->(GetArea())
Local _cRotina  := 'FC010BTN'
Local aStruSE1  := SE1->(dbStruct())
Local aDados    := {}
Local cAliasTop := "SE110"
Local cCliente  := SA1->A1_COD
Local cLoja     := SA1->A1_LOJA
Local _cLegen   := ""
Local cNFOrig   := ""
Local cQuery    := ""
Local nX, nPos
Local oDlg
Local oLbx

//Private aHeader := {}
Private _o00 := LoadBitmap( GetResources(), "BR_MARROM"  )
Private _o01 := LoadBitmap( GetResources(), "BR_VERDE"   )
Private _o02 := LoadBitmap( GetResources(), "BR_BRANCO"  )
Private _o03 := LoadBitmap( GetResources(), "BR_AZUL"    )
Private _o04 := LoadBitmap( GetResources(), "BR_VERMELHO")
Private _o05 := LoadBitmap( GetResources(), "BR_PRETO"   )
Private _o06 := LoadBitmap( GetResources(), "BR_AMARELO" )

//MSGBOX(cCliente+cLoja,_cRotina + '_02','INFO')
If Type("cFilAux")=="U"
	Public cFilAux := xFilial()
EndIf
//_lAux := Type("paramixb")<>"U"
If Paramixb[1] == 1	
	// Deve retornar o nome a ser exibido no botao
	Return "Ficha Financ."
ElseIf Paramixb[1] == 2
	// Deve retornar a mensagem do botao
	Return "Exibe a Ficha Financeira do Cliente"
Else
	If ExistBlock("RFINE011")
		ExecBlock("RFINE011")
	Else
	MSGBOX('Rotina RFINE011 NÃO ENCONTRADO. Por favor informe o Administrador do sistema.',_cRotina + '_01','STOP')
		//Rotina desabilitada por ter sido substituida pelo Execblock RFINE011.
		/*
		dbSelectArea("SE1")
		dbSetOrder(1)
		cQuery := " SELECT *, R_E_C_N_O_ RECSE1 "
		cQuery += " FROM " + RetSqlName("SE1")+ " SE1 "
		cQuery += " WHERE SE1.D_E_L_E_T_  = '' "
		cQuery += "   AND SE1.E1_CLIENTE  = '" + cCliente + "' "
		cQuery += "   AND SE1.E1_LOJA     = '" + cLoja    + "' "
		cQuery += "   AND SE1.E1_EMISSAO BETWEEN '"+ DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
		cQuery += "   AND SE1.E1_VENCREA BETWEEN '"+ DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
		If MV_PAR05 == 2
			cQuery += "   AND SE1.E1_TIPO <> 'PR' "
		EndIf
		cQuery += "   AND SE1.E1_PREFIXO BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' "
		If MV_PAR11 == 2
			cQuery += "   AND SE1.E1_NUMLIQ = '' AND SE1.E1_TIPOLIQ = '' "
		EndIf
		cQuery += " ORDER BY E1_VENCTO DESC, E1_EMISSAO DESC, E1_PREFIXO, E1_NUM, E1_PARCELA "
		cQuery := ChangeQuery(cQuery)
	
		MsAguarde({|| dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasTop,.F.,.T.)},"Aguarde...","Processando Títulos...")
	
		For nX := 1 To Len(aStruSE1)
			If aStruSE1[nX][2] <> "C" .And. FieldPos(aStruSE1[nX][1]) <> 0
				TcSetField(cAliasTop,aStruSE1[nX][1],aStruSE1[nX][2],aStruSE1[nX][3],aStruSE1[nX][4])
			EndIf
		Next nX
	
		dbSelectArea(cAliasTop)
		dbGoTop()
		If (cAliasTop)->(EOF())
			Aviso("ATENÇÃO !","Não existem títulos para este cliente.",{" <- &Voltar"},2,"Não Há Títulos!")
			(cAliasTop)->(dbCloseArea())
		Else
			While !(cAliasTop)->(EOF())
				_cLeg := "00"
				If (cAliasTop)->E1_SALDO == (cAliasTop)->E1_VALOR .AND. Empty((cAliasTop)->E1_BAIXA) .AND. !AllTrim((cAliasTop)->E1_TIPO) $ "RA/NCC"
					_cLeg := "01"		//VERDE    - Título em Aberto
				ElseIf (cAliasTop)->E1_SALDO == (cAliasTop)->E1_VALOR .AND. Empty((cAliasTop)->E1_BAIXA) .AND. AllTrim((cAliasTop)->E1_TIPO) $ "RA/NCC"
					_cLeg := "02"		//BRANCO   - Título do tipo NCC ou RA, em aberto
				ElseIf (cAliasTop)->E1_SALDO > 0 .AND. (cAliasTop)->E1_SALDO < (cAliasTop)->E1_VALOR
					_cLeg := "03"		//AZUL     - Título baixado parcialmente
				ElseIf (cAliasTop)->E1_SALDO == 0 .AND. !AllTrim((cAliasTop)->E1_TIPO) $ "RA/NCC"
					_cLeg := "04"		//VERMELHO - Titulo totalmente baixado
				ElseIf (cAliasTop)->E1_SALDO == 0 .AND. AllTrim((cAliasTop)->E1_TIPO) $ "RA/NCC"
					_cLeg := "05"		//PRETO    - Título a receber com baixa total por compensação com um NCC ou o próprio título do tipo NCC que encontra-se totalmente baixado (resolvido).
				/*ElseIf (cAliasTop)->E1_SALDO == 0
					_cLeg := "06"		//AMARELO   - Título pago com cheque.
				EndIf
				// Alterado em 16/07/2013 por Júlio Soares na inclusão da coluna que apresenta a informação se o Vendedor é ou não responsável pela venda.
				aAdd(aDados,{	_cLeg                             , ;
								(cAliasTop)->(AllTrim(E1_PREFIXO)), ;
								(cAliasTop)->(AllTrim(E1_NUM))    , ;
								(cAliasTop)->(AllTrim(E1_PARCELA)), ;
								(cAliasTop)->(AllTrim(E1_TIPO))   , ;
								(cAliasTop)->(AllTrim(E1_CARTEIR)), ;
								(cAliasTop)->E1_EMISSAO           , ;
								(cAliasTop)->E1_PEDIDO            , ;
								(cAliasTop)->E1_VALOR             , ;
								(cAliasTop)->E1_SALDO             , ;
								(cAliasTop)->E1_VENDRES           , ;							
								(cAliasTop)->E1_VENCTO            , ;
								(cAliasTop)->(IIF(E1_SALDO == 0,E1_BAIXA,STOD(""))), ;
								(cAliasTop)->E1_NUMBCO            , ;
								(cAliasTop)->E1_OBSTIT            , ;
								(cAliasTop)->E1_CLIENTE           , ;
								(cAliasTop)->E1_LOJA              , ;
								(cAliasTop)->E1_NOMCLI            , ;
								(cAliasTop)->RECSE1 } )
				(cAliasTop)->(dbSkip())
			EndDo
			(cAliasTop)->(dbCloseArea())
	
			Define MsDialog oDlg Title "Ficha Financeira - (Período de " + DtoC(mv_par01) + " a " + DtoC(mv_par02) + ")" From  0, 0 To 500,1200 Colors 0, 16777215 Pixel
	
			// Alterado em 16/07/2013 por Júlio Soares na inclusão da coluna que apresenta a informação se o Vendedor é ou não responsável pela venda.											
			@ 1, 1 ListBox oLbx Fields Header	"  ",;
												OemToAnsi("Prfx"       ),;
												OemToAnsi("Titulo"     ),;
												OemToAnsi("Parc"       ),;
												OemToAnsi("Tipo"       ),;
												OemToAnsi("Cart"       ),;
												OemToAnsi("Emiss"      ),;
												OemToAnsi("Pedido"     ),;												
												OemToAnsi("Valor Orig."),;
												OemToAnsi("Saldo"      ),;
												OemToAnsi("Vend. Resp."),;
												OemToAnsi("Vencimento" ),;
												OemToAnsi("Dt Pagto"   ),;
												OemToAnsi("Nosso Num"  ),;
												OemToAnsi("Observações"),;
												OemToAnsi("Cliente"    ),;
												OemToAnsi("Loja"       ),;
												OemToAnsi("Nome"       )   Size 600,235 Pixel
	
	//		@ 195, 020 Say "Qtde de NF´s " + Transform(_nQtNf,"@E 999,999") 	Size 200,40 Of oDlg Pixel
	//		@ 195, 100 Say "Total Devolvido -   R$" + Transform(_nTOTDEV,"@E 99,999,999.99") 	Size 200,40 Of oDlg Pixel
	  		oLbx:SetArray(aDados)
	
			// Alterado em 16/07/2013 por Júlio Soares na inclusão da coluna que apresenta a informação se o Vendedor é ou não responsável pela venda.							
			oLbx:bLine := {|| { &("_o"+AllTrim(aDados[oLbx:nAT,01])), ;
								(aDados[oLbx:nAT,02]), ;
								(aDados[oLbx:nAT,03]), ;
								(aDados[oLbx:nAT,04]), ;
								(aDados[oLbx:nAT,05]), ;							
								(aDados[oLbx:nAT,06]), ;
							DTOC(aDados[oLbx:nAt,07]), ;
								(aDados[oLbx:nAT,08]), ;
				  Padl(Transform(aDados[oLbx:nAT,09],"@E 999,999,999.99"),TamSx3("E1_VALOR")[01]), ;
				  Padl(Transform(aDados[oLbx:nAT,10],"@E 999,999,999.99"),TamSx3("E1_SALDO")[01]), ;
				  				(aDados[oLbx:nAT,11]), ;
							DTOC(aDados[oLbx:nAT,12]), ;
							DTOC(aDados[oLbx:nAT,13]), ;
								(aDados[oLbx:nAT,14]), ;
								(aDados[oLbx:nAT,15]), ;
								(aDados[oLbx:nAT,16]), ;
								(aDados[oLbx:nAT,17]), ;
								(aDados[oLbx:nAT,18]), ;
								(aDados[oLbx:nAT,19]) } }
			//Fa040Legenda("SE1")
			Define SButton From 237,280 Type 15 Enable Of oDlg Action {||SE1->(dbGoTo(aDados[oLbx:nAT,19])),FC040Con()}
			Define SButton From 237,310 Type 01 Enable Of oDlg Action ( oDlg:End() )
			//Trecho utilizado para reduzir o tamanho das colunas da Ficha Financeira de acordo com o tamanho do conteúdo.
			oLbx:ACOLSIZES := ARRAY(LEN(oLbx:AARRAY[01]))
			For _nTm := 1 To Len(oLbx:ACOLSIZES)
				oLbx:ACOLSIZES[_nTm] := 1
			Next 
			Activate MsDialog oDlg Centered
		EndIf
		*/
	EndIf
EndIf

RestArea(_aSA1)
RestArea(_aSA2)
RestArea(_aSE1)
RestArea(_aArea)

Return(.T.)