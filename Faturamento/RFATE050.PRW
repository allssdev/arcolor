#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} RFATE050
@description Função responsável por montar MARKbrowse para escolha dos produtos que serão considerados no relatório.
@obs Efetuado adaptação para realizar a marcação diretamente via instrução Update no banco para não gravar log de usuário de alteração nos cadastros.
@author Júlio Soares
@since 19/05/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RFATE050()
	local oBtnOk, oBtnCanc
	nOpc    := 2
	bOk     := {||nOpc:=1,oDlg:End()}
	bCancel := {||nOpc:=2,oDlg:End()}

	Private _oSelct
	Private _oGetCli
	Private _cGetCli               := Space(TamSx3("A1_NOME")[01])
	Private _oGetVend
	Private _cGetVend              := Space(TamSx3("A3_NOME")[01])
	Private _cRotina               := "RFATE050"
	Private _aCpoEst               := {}
	Private _aCpoVend              := {}
	Private _aCpoCli               := {}
	Private cMark1                 := 'xx'/*GetMARK()*/, lInverte := .F., oMARK1
	Private cMark2                 := 'xx'/*GetMARK()*/, lInverte := .F., oMARK2
	Private cMark3                 := 'xx'/*GetMARK()*/, lInverte := .F., oMARK3
	Private aMarcados[2], nMarcado := 0
	Private _aSize                 := {}
	Private _cSX5TRA               := GetNextAlias()
	Private _cTMPSX5               := GetNextAlias()
	Public _lRetm                  := .T.

	_aSize := MsAdvSize(.T.,.F.)

	if Select(_cTMPSX5) > 0
		(_cTMPSX5)->(dbCloseArea())
	endif
	if Select(_cSX5TRA) > 0
		(_cSX5TRA)->(dbCloseArea())
	endif

	// - FAZ A LIMPEZA DAS MARCAÇÕES DA TABELA DOS VENDEDORES
	_cQryUpd1 := "UPDATE " + RetSqlName("SA3") + " "
	_cQryUpd1 += "SET   A3_MARK    = '' "
	If SA3->(FieldPos("A3_RELFAT"))<>0
		_cQryUpd1 += ", A3_RELFAT  = REPLACE(A3_RELFAT,'" + ALLTRIM(__cUserId) + "|" + "','')"
		_cQryUpd1 += "WHERE A3_RELFAT LIKE '%" + ALLTRIM(__cUserId) + "|" +"%'"
		_cQryUpd1 += "AND D_E_L_E_T_ = ''"
	Else
		_cQryUpd1 += "WHERE D_E_L_E_T_ = ''"
	EndIf
	_cQryUpd1 += "AND A3_FILIAL  = '" + xFilial("SA3") + "' "
	If TCSQLExec(_cQryUpd1) < 0
		MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
	EndIf

	// - FAZ A LIMPEZA DAS MARCAÇÕES DA TABELA DOS CLIENTES
	_cQryUpd2 := "UPDATE " + RetSqlName("SA1") + " "
	_cQryUpd2 += "SET   A1_MARK    = '' "
	If SA1->(FieldPos("A1_RELFAT"))<>0
		_cQryUpd2 += ", A1_RELFAT  = REPLACE(A1_RELFAT,'" + ALLTRIM(__cUserId) + "|" + "','')"
		_cQryUpd2 += "WHERE A1_RELFAT LIKE '%" + ALLTRIM(__cUserId) + "|" +"%'"
		_cQryUpd2 += "AND D_E_L_E_T_ = ''"
	Else
		_cQryUpd2 += "WHERE D_E_L_E_T_ = ''"
	EndIf
	_cQryUpd2 += "AND A1_FILIAL  = '" + xFilial("SA1") + "' "
	If TCSQLExec(_cQryUpd2) < 0
		MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
	EndIf

	aIndex             := {}
//	Private bFiltraBrw := {|| Nil}
	_cInd2             := CriaTrab(Nil,.F.)
	_cInd3             := CriaTrab(Nil,.F.)
	_aCpos             := {}
	_aStru1            := {}
	aCampos            := {}

	AADD(_aCpos,{"X5_OK"  ,"C",02,0})
	AADD(_aCpos,{"X5_COD" ,"C",06,0})
	AADD(_aCpos,{"X5_NOME","C",50,0})        	
	//-------------------
	//Criacao do objeto
	//-------------------
	oTempTable := FWTemporaryTable():New( _cSX5TRA )
	oTemptable:SetFields( _aCpos )
	oTempTable:AddIndex("indice1", {"X5_COD"} )
	//------------------
	//Criacao da tabela
	//------------------
	oTempTable:Create()
	// - FORMACAO DA QUERY PARA VERIFICAR A TABELA X5-12
	BeginSql Alias _cTMPSX5
		SELECT ' ' [X5_MARK], X5_CHAVE, X5_DESCRI
		FROM %table:SX5% SX5 (NOLOCK)
		WHERE SX5.X5_TABELA = '12' AND SX5.%NotDel%
	EndSql
	// - INSERE EM TABELA TEMPORARIA AS OPÇÕES SELECIONADAS
	dbSelectArea(_cTMPSX5)	//TEMPORARIA
	(_cTMPSX5)->(dbGoTop())
	While !(_cTMPSX5)->(EOF())
		while !RecLock(_cSX5TRA,.T.) ; enddo
			X5_OK      := "  "
			X5_COD     := (_cTMPSX5)->(X5_CHAVE)
			X5_NOME    := (_cTMPSX5)->(X5_DESCRI)
		(_cTMPSX5)->(MsUnLock())
		(_cTMPSX5)->(dbSkip())
	EndDo
	dbSelectArea(_cTMPSX5)
	(_cTMPSX5)->(dbGotop())

	AADD(aCampos,{"X5_OK"  ,"" ,"OK"       ,"" })
	AADD(aCampos,{"X5_COD" ,"" ,"ESTADO"   ,"" })
	AADD(aCampos,{"X5_NOME","" ,"DESCRICAO","" })

	IndRegua("SA3",_cInd2,"A3_COD + A3_NOME",,,"Criando índice temporario...")

	// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
	/*
	_aCpoVend:= {{"A3_MARK" ,," "             },;
				 {"A3_COD"  ,,"VENDEDOR"      },;
				 {"A3_NOME" ,,"NOME VENDEDOR" }}
	*/

	_aCpoVend:= {{"A3_MARK" ,," "             },;
				 {"A3_COD"  ,,"REPRESENTANTE"      },;
				 {"A3_NOME" ,,"NOME REPRESENTANTE" }}
	// Fim - Fernando Bombardi - ALLSS - 02/03/2022

	IndRegua("SA1",_cInd3,"A1_CGCCENT + A1_NOME + A1_CGC",,,"Criando índice temporario...")
	_aCpoCli := {{"A1_MARK"    ,," "               },;
				 {"A1_CGCCENT" ,,"CNPJ CENTRAL"    },;
				 {"A1_NOMECGC" ,,"NOME CENTRAL"    },;
				 {"A1_COD"     ,,"CODIGO CLIENTE"  },;
				 {"A1_LOJA"    ,,"LOJA DO CLIENTE" },;
				 {"A1_NOME"    ,,"NOME CLIENTE"    },;
				 {"A1_CGC"     ,,"CNPJ"            }}
	Static oDlg
	Define MsDialog oDlg Title "Seleção de clientes" From 5,0 To 53,200 Of oMainWnd
//	Define MsDialog oDlg Title "Seleção de clientes" From 5,0 To 42,163 Of oMainWnd // - TESTE DE ADEQUAÇÃO EM TELAS
		// - ESTADO
		dbSelectArea(_cSX5TRA)
		(_cSX5TRA)->(dbGoTop())
		@  9,10 Say "Marque o(s) estado(s)" Size 232,10 Pixel Of oDlg                                 
//		@ (_aSize[1]+9),(_aSize[2]+10) Say "Marque o(s) estado(s)" Size (_aSize[3]-628.5),(_aSize[4]-415.5) Pixel Of oDlg

	 	oMARK1 := MsSelect():New(_cSX5TRA,"X5_OK",,aCampos,lInverte,@cMark1,{18,5,315,105})
//	 	oMARK1 := MsSelect():New(_cSX5TRA,"X5_OK",,aCampos,lInverte,@cMark1,{(_aSize[1]+18),(_aSize[2]+5),(_aSize[3]-623,5),(_aSize[4]-320.5)})
	 	oMARK1:oBrowse:lHasMARK    := .T.
		oMARK1:oBrowse:lCanAllMARK := .T.
		//oMARK1:oBrowse:bAllMARK    := {|| MARKAll1 (_cSX5TRA, cMark1, @oMark1)}
        oMARK1:bAval               := {|| ChkMarca1(oMARK1,cMark1) }
        AddColMARK(oMARK1,"X5_OK")

        // - VENDEDOR
		dbSelectArea("SA3")
		SA3->(dbGoTop())

		// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
	 	//@ 9,110 Say "Marque o(s) vendedor(es) que deverão ser considerado(s) no relatório" Size 232,15 Pixel Of oDlg
	 	@ 9,110 Say "Marque os Representantes que deverão ser considerado(s) no relatório" Size 232,15 Pixel Of oDlg
		// Fim - Fernando Bombardi - ALLSS - 02/03/2022

//	 	@ (_aSize[1]+9),(_aSize[2]+110) Say "Marque o(s) vendedor(es) que deverão ser considerado(s) no relatório" Size (_aSize[3]-696.5),(_aSize[4]-410.5) Pixel Of oDlg
	 	oMARK2 := MsSelect():New("SA3","A3_MARK",,_aCpoVend,lInverte,@cMark2,{18,110,315,305})
//	 	oMARK2 := MsSelect():New("SA3","A3_MARK",,_aCpoVend,lInverte,@cMark2,{(_aSize[1]+18),(_aSize[2]+110),(_aSize[3]-613.5),(_aSize[4]-120.5)})
	 	oMARK2:oBrowse:lHasMARK    := .T.
		oMARK2:oBrowse:lCanAllMARK :=.T.
		//oMARK2:oBrowse:bAllMARK    := {|| MARKALL2("SA3", cMark2, @oMark2)}
        oMARK2:bAval               := {|| ChkMarca2(oMARK2,cMark2) }
        AddColMARK(oMARK2,"A3_MARK")

		// - CLIENTE        
		dbSelectArea("SA1")
		SA1->(dbGoTop())
	 	@ 9,310 Say "Marque o(s) cliente(s) que deverão ser considerado(s) no relatório" Size 232,300 Pixel Of oDlg
	 	oMARK3 := MsSelect():New("SA1","A1_MARK",,_aCpoCli,lInverte,@cMark3,{18,310,315,775})
	 	oMARK3:oBrowse:lHasMARK    := .T.
		oMARK3:oBrowse:lCanAllMARK := .T.
		//oMARK3:oBrowse:bAllMARK    := {|| MARKAll3("SA1", cMark3, @oMark3)}
		oMARK3:oBrowse:bAllMARK    := {|| MARKAll("SA1", cMark3, @oMark3)}
        oMARK3:bAval               := {|| ChkMarca3(oMARK3,cMark3) }
        AddColMARK(oMARK3,"A1_MARK")

		// - EXECUTA A BUSCA POR VENDEDOR
	    @ 320,115 MSGET  _oGetVend VAR    _cGetVend  Valid  GetNameVend() Size 130,010  Of oDlg COLORS 0, 16777215 Pixel
	    @ 320,260 BUTTON _oSelct   PROMPT "&Buscar"   Size 045,015  Action GetNameVend()   Of oDlg                    Pixel

		// - EXECUTA A BUSCA POR CLIENTE
		@ 320,315 button "&Marcar Todos"              Size 045,015  Action MARKall()       Of oDlg                    Pixel
	    @ 320,365 button "&Desmarcar Todos"           Size 045,015  Action UnMARKall()     Of oDlg                    Pixel
   	    @ 320,415 button "&CNPJ-Central"              Size 045,015  Action MARKCGC()       Of oDlg                    Pixel
	    @ 320,470 MSGET  _oGetCli  VAR    _cGetCli    Size 130,010                         Of oDlg COLORS 0, 16777215 Pixel
	    @ 320,640 BUTTON _oSelct   PROMPT "&Buscar"   Size 045,015  Action GetNameCli()    Of oDlg                    Pixel

        Define SButton oBtnOk      From 320,710 Type 1              Action Eval(bOk) .And. Close(oDlg) Enable Of oDlg
        Define SButton oBtnCanc    From 320,740 Type 2              Action Eval(bCancel)   Enable Of oDlg
	Activate MsDialog oDlg Centered        
	If nOpc==2
		_lRetm := .F.
	EndIf
	if Select(_cTMPSX5) > 0
		(_cTMPSX5)->(dbCloseArea())
	endif
	if Select(_cSX5TRA) > 0
		(_cSX5TRA)->(dbCloseArea())
	endif
return _lRetm
/*/{Protheus.doc} ChkMarca1 (RFATE050)
@description MARCA/DESMARCA O ESTADO COM ATUALIZAÇÃO NO CLIENTE.
@author Júlio Soares
@since 13/08/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ChkMarca1(oMARK1,cMark1)
	Local _nReg := Recno()
	dbSelectArea(_cSX5TRA)
	If (_cSX5TRA)->(X5_OK) == cMark1
		while !RecLock(_cSX5TRA,.F.) ; enddo
			(_cSX5TRA)->X5_OK := " "
		(_cSX5TRA)->(MsUnLock())
		_cQryUpd := "UPDATE " + RetSqlName("SA1") + " "
		_cQryUpd += "SET A1_MARK = '' "
		If SA1->(FieldPos("A1_RELFAT"))<>0
			_cQryUpd += ", A1_RELFAT  = REPLACE(A1_RELFAT,'" + Alltrim(__cUserId) + "|" + "','') "
		EndIf
		_cQryUpd += "WHERE D_E_L_E_T_ = '' "
		_cQryUpd += "AND A1_FILIAL    = '" + xFilial("SA1") + "'     "
		_cQryUpd += "AND A1_EST       = '" + (_cSX5TRA)->X5_COD + "' "
		If TCSQLExec(_cQryUpd) < 0
			MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_005")
			return
		EndIf
	Else
		while !RecLock(_cSX5TRA,.F.) ; enddo
			(_cSX5TRA)->X5_OK := cMark1
		(_cSX5TRA)->(MsUnLock())
		_cQryUpd := "UPDATE " + RetSqlName("SA1") + " "
		_cQryUpd += "SET   A1_MARK    = '" + (cMark2) + "' "
		If SA1->(FieldPos("A1_RELFAT"))<>0
			_cQryUpd += ", A1_RELFAT  = '" + AllTrim(SA1->A1_RELFAT) + AllTrim(__cUserId) + "|" + "' "
		EndIf
		_cQryUpd += "WHERE D_E_L_E_T_ = '' "
		_cQryUpd += "AND A1_FILIAL    = '" + xFilial("SA1") + "' "
		_cQryUpd += "AND A1_EST       = '" + (_cSX5TRA)->X5_COD + "' "
		If TCSQLExec(_cQryUpd) < 0
			MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_006")
			return
		EndIf
	EndIf
	oMARK1:oBrowse:Refresh()
	oMARK3:oBrowse:Refresh()
return nil
/*/{Protheus.doc} ChkMarca2 (RFATE050)
@description MARCA/DESMARCA VENDEDOR ATUALIZANDO O CLIENTE.
@author Júlio Soares
@since 13/08/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ChkMarca2(oMARK2,cMark2)
	Begin Sequence
		If !SA3->(Eof() .Or. Bof())
			// - DESMARCA
			If ! Empty(SA3->A3_MARK) .And. IIF(SA3->(FieldPos("A3_RELFAT"))<>0, (Alltrim(__cUserId)) $ (SA3->(A3_RELFAT)), .T.)
				_cQryUpd := "UPDATE " + RetSqlName("SA3") + " "
				_cQryUpd += "SET   A3_MARK   = ' ' "
				If SA3->(FieldPos("A3_RELFAT"))<>0
					_cQryUpd += ", A3_RELFAT = REPLACE(A3_RELFAT,'" + (Alltrim(__cUserId)) + "|" + "','') "
					_cQryUpd += "WHERE A3_RELFAT LIKE '%" + (Alltrim(__cUserId)) + "|" +"%' "
					_cQryUpd += "AND D_E_L_E_T_ = '' "
				Else
					_cQryUpd += "WHERE D_E_L_E_T_ = '' "
				EndIf
				_cQryUpd += "AND A3_FILIAL  = '" + xFilial("SA3") + "' "
				_cQryUpd += "AND A3_COD     = '" + (SA3->A3_COD)  + "' "
				_cVend := (SA3->(A3_COD))			
				If TCSQLExec(_cQryUpd) < 0
					MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
					return
				EndIf
				_cQryUpd := "UPDATE " + RetSqlName("SA1") + " "
				_cQryUpd += "SET A1_MARK = '' "
				If SA1->(FieldPos("A1_RELFAT"))<>0
					_cQryUpd += ", A1_RELFAT  = REPLACE(A1_RELFAT,'" + (Alltrim(__cUserId)) + "|" + "','') "
				EndIf
				_cQryUpd += "WHERE D_E_L_E_T_ = '' "
				_cQryUpd += "AND A1_FILIAL  = '" + xFilial("SA1") + "' "
				_cQryUpd += "AND A1_VEND    = '" + (_cVend) + "' "
				If TCSQLExec(_cQryUpd) < 0
					MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
					return
				EndIf
			// - MARCA
			Else
				_cQryUpd := "UPDATE " + RetSqlName("SA3") + " "
				_cQryUpd += "SET   A3_MARK    = '" + (cMark2) + "' "
				If SA3->(FieldPos("A3_RELFAT"))<>0
					_cQryUpd += ", A3_RELFAT  = '" + (AllTrim(SA3->A3_RELFAT)) +  (AllTrim(__cUserId)) + "|" + "' "
				EndIf
				_cQryUpd += "WHERE D_E_L_E_T_ = '' "
				_cQryUpd += "AND A3_FILIAL  = '" + (xFilial("SA3")) + "' "
				_cQryUpd += "AND A3_COD     = '" + (SA3->A3_COD)  + "' "
				_cVend := (SA3->(A3_COD))
				If TCSQLExec(_cQryUpd) < 0
					MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
					return
				EndIf
				_cQryUpd := "UPDATE " + RetSqlName("SA1") + " "
				_cQryUpd += "SET   A1_MARK    = '" + (cMark2) + "' "
				If SA1->(FieldPos("A1_RELFAT"))<>0
					_cQryUpd += ", A1_RELFAT  = '" + (AllTrim(SA1->A1_RELFAT)) +  (AllTrim(__cUserId)) + "|" + "' "
				EndIf
				_cQryUpd += "WHERE D_E_L_E_T_ = '' "
				_cQryUpd += "AND A1_FILIAL  = '" + xFilial("SA1") + "' "
				_cQryUpd += "AND A1_VEND    = '" + (_cVend) + "' "
				If TCSQLExec(_cQryUpd) < 0
					MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
					return
				EndIf
			EndIf
			oMARK2:oBrowse:Refresh()
			oMARK3:oBrowse:Refresh()
		EndIf
	End Sequence
return nil
/*/{Protheus.doc} ChkMarca3 (RFATE050)
@description MARCA/DESMARCA CLIENTE.
@author Júlio Soares
@since 13/08/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ChkMarca3(oMARK3,cMark3)
	Begin Sequence
		If ! SA1->(Eof() .Or. Bof())
			// - DESMARCA
			If ! Empty (SA1->A1_MARK) .And. IIF(SA1->(FieldPos("A1_RELFAT"))<>0, (Alltrim(__cUserId)) $ (SA1->(A1_RELFAT)), .T.)
				_cQryUpd := "UPDATE " + RetSqlName("SA1") + " "
				_cQryUpd += "SET   A1_MARK    = '' "
				If SA1->(FieldPos("A1_RELFAT"))<>0
					_cQryUpd += ", A1_RELFAT  = REPLACE(A1_RELFAT,'" + (Alltrim(__cUserId)) + "|" + "','') "
					_cQryUpd += "WHERE A1_RELFAT LIKE '%" + (Alltrim(__cUserId)) + "|" +"%' "
					_cQryUpd += "AND D_E_L_E_T_ = '' "
				Else
					_cQryUpd += "WHERE D_E_L_E_T_ = '' "
				EndIf
				_cQryUpd += "AND A1_FILIAL  = '" + xFilial("SA1") + "' "
				_cQryUpd += "AND A1_COD     = '" + (SA1->A1_COD)  + "' "
				_cQryUpd += "AND A1_LOJA    = '" + (SA1->A1_LOJA) + "' "
				If TCSQLExec(_cQryUpd) < 0
					MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
					Return()
				EndIf
			// - MARCA
			Else
				_cQryUpd := "UPDATE " + RetSqlName("SA1") + " "
				_cQryUpd += "SET A1_MARK = '" + (cMark2) + "' "
				If SA1->(FieldPos("A1_RELFAT"))<>0
					_cQryUpd += ", A1_RELFAT  = '" + (AllTrim(SA1->A1_RELFAT)) +  (AllTrim(__cUserId)) + "|" + "' "
				EndIf
				_cQryUpd += "WHERE D_E_L_E_T_ = '' "
				_cQryUpd += "AND A1_FILIAL  = '" + (xFilial("SA1")) + "' "
				_cQryUpd += "AND A1_COD     = '" + (SA1->A1_COD)  + "' "
				_cQryUpd += "AND A1_LOJA    = '" + (SA1->A1_LOJA) + "' "
				If TCSQLExec(_cQryUpd) < 0
					MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
					Return()
				EndIf
			EndIf
			oMARK3:oBrowse:Refresh()
		EndIf
	End Sequence
return nil
/*/{Protheus.doc} MARKall (RFATE050)
@description MARCA TODOS OS CLIENTES.
@author Júlio Soares
@since 13/08/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function MARKall()
	_cQryUpd := "UPDATE " + RetSqlName("SA1") + " "
	_cQryUpd += "SET   A1_MARK    = '" + (cMark3) + "' "
	If SA1->(FieldPos("A1_RELFAT"))<>0
		_cQryUpd += ", A1_RELFAT  = '" + (AllTrim(SA1->A1_RELFAT)) +  (AllTrim(__cUserId)) + "|" + "' "
	EndIf
	_cQryUpd += "WHERE D_E_L_E_T_ = '' "
	_cQryUpd += "AND A1_FILIAL  = '" + xFilial("SA1") + "' "
	If TCSQLExec(_cQryUpd) < 0
		MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
		return
	EndIf
	SA1->(dbGoTop())
	oMARK3:oBrowse:Refresh()
return .T.
/*/{Protheus.doc} UnMARKall (RFATE050)
@description DESMARCA TODOS OS CLIENTES.
@author Júlio Soares
@since 13/08/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function UnMARKall()
	_cQryUpd := "UPDATE " + RetSqlName("SA1") + " "
	_cQryUpd += "SET A1_MARK = '' "
	If SA1->(FieldPos("A1_RELFAT"))<>0
		_cQryUpd += ", A1_RELFAT  = REPLACE(A1_RELFAT,'" + (Alltrim(__cUserId)) + "|" + "','') "
		_cQryUpd += "WHERE A1_RELFAT LIKE '%" + (Alltrim(__cUserId)) + "|" +"%' "
		_cQryUpd += "AND D_E_L_E_T_ = '' "
	Else
		_cQryUpd += "WHERE D_E_L_E_T_ = '' "
	EndIf
	_cQryUpd += "AND A1_FILIAL  = '" + xFilial("SA1") + "' "
	If TCSQLExec(_cQryUpd) < 0
		MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
		Return()
	EndIf
	SA1->(dbGoTop())
	oMARK3:oBrowse:Refresh()
return .T.
/*/{Protheus.doc} MARKCGC (RFATE050)
@description MARCA/DESMARCA TODOS OS CLIENTES COM MESMO CNPJ CENTRAL.
@author Júlio Soares
@since 13/08/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function MARKCGC()
	Begin Sequence
		If ! SA1->(Eof() .Or. Bof())
			// - MARCA TODOS OS CGC'S - CENTRAIS
			If ! Empty (SA1->A1_MARK) .And. IIF(SA1->(FieldPos("A1_RELFAT"))<>0, (Alltrim(__cUserId)) $ (SA1->(A1_RELFAT)), .T.)
				_cQryUpd := "UPDATE " + RetSqlName("SA1") + " "
				_cQryUpd += "SET A1_MARK = '' "
				If SA1->(FieldPos("A1_RELFAT"))<>0
					_cQryUpd += ", A1_RELFAT  = REPLACE(A1_RELFAT,'" + (Alltrim(__cUserId)) + "|" + "','') "
				EndIf
				_cQryUpd += "WHERE D_E_L_E_T_ = '' "
				_cQryUpd += "AND A1_FILIAL  = '" + xFilial("SA1") + "' "
				_cQryUpd += "AND A1_CGCCENT = '" + (SA1->A1_CGCCENT) + "' "
				If TCSQLExec(_cQryUpd) < 0
					MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
					Return()
				EndIf
			// - DESMARCA TODOS OS CGC'S - CENTRAIS
			Else
				_cQryUpd := "UPDATE " + RetSqlName("SA1") + " "
				_cQryUpd += "SET A1_MARK = '" + (cMark3) + "' "
				If SA1->(FieldPos("A1_RELFAT"))<>0
					_cQryUpd += ", A1_RELFAT  = '" + (AllTrim(SA1->A1_RELFAT)) +  (AllTrim(__cUserId)) + "|" + "' "
				EndIf
				_cQryUpd += "WHERE D_E_L_E_T_ = '' "
				_cQryUpd += "AND A1_FILIAL  = '" + xFilial("SA1")  + "' "
				_cQryUpd += "AND A1_CGCCENT = '" + SA1->A1_CGCCENT + "' "
				If TCSQLExec(_cQryUpd) < 0
					MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
					Return()
				EndIf
			EndIf
			oMARK3:oBrowse:Refresh()
		EndIf
	End Sequence
return .T.
/*/{Protheus.doc} GetNameCli (RFATE050)
@description EXECUTA PESQUISA DE CLIENTE CONFORME PARTE DA STRING.
@author Júlio Soares
@since 13/08/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function GetNameCli()
	local _cTMPGET := GetNextAlias()
	_cQryGet := "SELECT A1_NOME[NOME],R_E_C_N_O_[REC]
	_cQryGet += "FROM " + RetSqlName("SA1") + " SA1 (NOLOCK) "
	_cQryGet += "WHERE SA1.A1_NOME LIKE '%" + (Upper(Alltrim(_cGetCli))) + "%' "
	_cQryGet += "OR SA1.A1_NOMECGC LIKE '%" + (Upper(Alltrim(_cGetCli))) + "%' "
	_cQryGet += "OR SA1.A1_COD     LIKE '%" + (Upper(Alltrim(_cGetCli))) + "%' "
	_cQryGet += "OR SA1.A1_CGCCENT LIKE '%" + (Upper(Alltrim(_cGetCli))) + "%' "
	if Select(_cTMPGET) > 0
		(_cTMPGET)->(dbCloseArea())
	endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQryGet),_cTMPGET,.F.,.T.)
	SA1->(dbGoTo((_cTMPGET)->REC))
	if Select(_cTMPGET) > 0
		(_cTMPGET)->(dbCloseArea())
	endif
return nil
/*/{Protheus.doc} GetNameVend (RFATE050)
@description EXECUTA PESQUISA DE VENDEDOR CONFORME PARTE DA STRING.
@author Júlio Soares
@since 13/08/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function GetNameVend()
	local _cTMPGET := GetNextAlias()
	_cQryGet := "SELECT A3_NOME[NOME],R_E_C_N_O_[REC]
	_cQryGet += "FROM " + RetSqlName("SA3") + " SA3 "
	_cQryGet += "WHERE SA3.A3_NOME LIKE '%" + (Upper(Alltrim(_cGetVend))) + "%' "
	_cQryGet += "OR SA3.A3_COD LIKE '%" + (Upper(Alltrim(_cGetVend))) + "%' "
	if Select(_cTMPGET) > 0
		(_cTMPGET)->(dbCloseArea())
	endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQryGet),_cTMPGET,.F.,.T.)
	SA3->(dbGoTo((_cTMPGET)->REC))
	if Select(_cTMPGET) > 0
		(_cTMPGET)->(dbCloseArea())
	endif
return .T.
