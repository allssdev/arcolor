#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFATE051  บAutor  ณ J๚lio Soares       บ Data ณ  07/14/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fonte utilizado na rotina do master data.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico empresa ARCOLOR                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RFATE051()

nOpc                           := 2
bOk                            := {||nOpc:=1,oDlgProd:End()}
bCancel                        := {||nOpc:=2,oDlgProd:End()}

Private _oSelct
Private _oGetGrp
Private _cGetGrp               := Space(TamSx3("BM_DESC")[01])
Private _oGetProd
Private _cGetProd              := Space(TamSx3("B1_DESC")[01])
Private _cRotina               := "RFATE051"
Private _aCpoEst               := {}
Private _aCpoVend              := {}
Private _aCpoCli               := {}

Private _cMark1                := 'xx'/*GetMARK()*/, lInverte := .F., _oMARK1
Private _cMark2                := 'xx'/*GetMARK()*/, lInverte := .F., _oMARK2
Private _cMark3                := 'xx'/*GetMARK()*/, lInverte := .F., _oMARK3
Private aMarcados[2], nMarcado := 0

Public _lRetm                  := .T.

aIndex                         := {}

// - FAZ A LIMPEZA DAS MARCAวีES DA TABELA DOS GRUPOS DE PRODUTOS
_cQryUpd3 := "UPDATE " + RetSqlName("SBM") + " "
_cQryUpd3 += "SET BM_MARK = '', BM_RELFAT  = REPLACE(BM_RELFAT,'" + ALLTRIM(__cUserId) + "|" + "','')"
_cQryUpd3 += "WHERE BM_RELFAT LIKE '%" + ALLTRIM(__cUserId) + "|" +"%'"
_cQryUpd3 += "AND D_E_L_E_T_ = ''"
_cQryUpd3 += "AND BM_FILIAL  = '" + xFilial("SBM") + "' "
If TCSQLExec(_cQryUpd3) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
EndIf

// - FAZ A LIMPEZA DAS MARCAวีES DA TABELA DOS PRODUTOS
_cQryUpd4 := "UPDATE " + RetSqlName("SB1") + " "
_cQryUpd4 += "SET B1_MARK = '', B1_RELFAT  = REPLACE(B1_RELFAT,'" + (Alltrim(__cUserId)) + "|" + "','') "
_cQryUpd4 += "WHERE B1_RELFAT LIKE '%" + (Alltrim(__cUserId)) + "|" +"%' "
_cQryUpd4 += "AND D_E_L_E_T_ = '' "
_cQryUpd4 += "AND B1_FILIAL  = '" + xFilial("SB1") + "' "
If TCSQLExec(_cQryUpd4) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
EndIf

//Private bFiltraBrw 	:= {|| Nil}

_cInd2              := CriaTrab(Nil,.F.)
_cInd3              := CriaTrab(Nil,.F.)
_aCpos              := {}
_aStru1             := {}
aCampos             := {}

AADD(_aCpos,{"X5_OK"  ,"C",02,0})
AADD(_aCpos,{"X5_COD" ,"C",06,0})
AADD(_aCpos,{"X5_NOME","C",50,0})

/*
_cInd1 := CriaTrab(_aCpos,.T.)

dbUseArea(.T.,,_cInd1,"SX5TRB",.T.,.F.)
IndRegua("SX5TRB",_cInd1,"X5_COD",,,"Criando ํndice temporario...")
*/

//-------------------
//Criacao do objeto
//-------------------
oTempTable := FWTemporaryTable():New( "SX5TRB" )
	
oTemptable:SetFields( _aCpos )
oTempTable:AddIndex("indice1", {"X5_COD"} )

//------------------
//Criacao da tabela
//------------------
oTempTable:Create()

// - FORMACAO DA QUERY PARA VERIFICAR A TABELA X5-02
_cQryCel := " SELECT ' '[X5_MARK],X5_CHAVE,X5_DESCRI "
_cQryCel += " FROM " + RetSqlName("SX5") + " SX5 "
_cQryCel += " WHERE SX5.X5_TABELA = '02' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQryCel),"TRBSX5",.F.,.T.)

// - INSERE EM TABELA TEMPORARIA AS OPวีES SELECIONADAS
dbSelectArea("TRBSX5")//TEMPORARIA
dbGoTop()
While ! TRBSX5->(EOF())
	RecLock("SX5TRB",.T.)
		X5_OK      := "  "
		X5_COD     := TRBSX5->(X5_CHAVE)
		X5_NOME    := TRBSX5->(X5_DESCRI)
	TRBSX5->(MsUnlock())
	TRBSX5->(dbSkip())
EndDo

dbSelectArea("TRBSX5")
//dbSetOrder(1)
TRBSX5->(dbGotop())

AADD(aCampos,{"X5_OK"  ,"" ,"OK"       ,"" })
AADD(aCampos,{"X5_COD" ,"" ,"TIPO"     ,"" })
AADD(aCampos,{"X5_NOME","" ,"DESCRICAO","" })

IndRegua("SBM",_cInd2,"BM_GRUPO + BM_DESC",,,"Criando ํndice temporario...")
_aCpoVend:= {{"BM_MARK" ,," "         },;
			 {"BM_GRUPO",,"GRUPO"     },;
			 {"BM_DESC" ,,"DESCRICAO" }}


IndRegua("SB1",_cInd3,"B1_COD + B1_DESC",,,"Criando ํndice temporario...")
_aCpoCli := {{"B1_MARK" ,," "         },;
			 {"B1_COD"  ,,"CODIGO"    },;
			 {"B1_DESC" ,,"DESCRICAO" }}

	Define MsDialog oDlgProd Title "Sele็ใo de produtos" From 5,0 To 53,200 Of oMainWnd

		// - TIPO
		dbSelectArea("SX5TRB")
		SX5TRB->(dbGoTop())
		@ 9,10 Say "Marque o(s) tipo(s)" Size 232,10 Pixel Of oDlgProd
	 	_oMARK1 := MsSelect():New("SX5TRB","X5_OK",,aCampos,lInverte,@_cMark1,{18,5,315,105})
	 	_oMARK1:oBrowse:lHasMARK    := .T.
		_oMARK1:oBrowse:lCanAllMARK := .T.
		//_oMARK1:oBrowse:bAllMARK    := {|| MARKAll1("SX5TRB", _cMark1, @oDlgProd)}
        _oMARK1:bAval               := {|| ChkMarca1(_oMARK1,_cMark1) }
        AddColMARK(_oMARK1,"X5_OK")

        // - FAMILIA
		dbSelectArea("SBM")
		SA3->(dbGoTop())
	 	@ 9,110 Say "Marque o(s) grupo(s) que deverใo ser considerado(s) no relat๓rio" Size 232,15 Pixel Of oDlgProd
	 	_oMARK2 := MsSelect():New("SBM","BM_MARK",,_aCpoVend,lInverte,@_cMark2,{18,110,315,305})
	 	_oMARK2:oBrowse:lHasMARK    := .T.
		_oMARK2:oBrowse:lCanAllMARK :=.T.
		//_oMARK2:oBrowse:bAllMARK    := {|| MARKAll2("SBM", _cMark2, @oDlgProd)}
        _oMARK2:bAval               := {|| ChkMarca2(_oMARK2,_cMark2) }
        AddColMARK(_oMARK2,"BM_MARK")

		// - PRODUTO  
		dbSelectArea("SB1")
		SB1->(dbGoTop())
	 	@ 9,310 Say "Marque o(s) cliente(s) que deverใo ser considerado(s) no relat๓rio" Size 232,300 Pixel Of oDlgProd
	 	_oMARK3 := MsSelect():New("SB1","B1_MARK",,_aCpoCli,lInverte,@_cMark3,{18,310,315,775})
	 	_oMARK3:oBrowse:lHasMARK    := .T.
		_oMARK3:oBrowse:lCanAllMARK := .T.
		//_oMARK3:oBrowse:bAllMARK    := {|| MARKAll3 ("SB1", _cMark3, @oDlgProd)}
		_oMARK3:oBrowse:bAllMARK    := {|| MARKAll("SB1", _cMark3, @oDlgProd)}
        _oMARK3:bAval               := {|| ChkMarca3(_oMARK3,_cMark3) }
        AddColMARK(_oMARK3,"B1_MARK")
		
		// - EXECUTA A BUSCA DA FAMILIA
	    @ 320,115 MSGET  _oGetGrp   VAR _cGetGrp     Size 130,010                              Of oDlgProd COLORS 0, 16777215 Pixel
	    @ 320,260 BUTTON _oSelct PROMPT "&Buscar"    Size 045,015  Action GetNameGrp()         Of oDlgProd                    Pixel

		// - EXECUTA A BUSCA DO PRODUTO
		@ 320,315 button "&Marcar Todos"             Size 045,015  Action MARKall()            Of oDlgProd                    Pixel
	    @ 320,365 button "&Desmarcar Todos"          Size 045,015  Action UnMARKall()          Of oDlgProd                    Pixel
	    @ 320,470 MSGET  _oGetProd VAR _cGetProd     Size 130,010                              Of oDlgProd COLORS 0, 16777215 Pixel
	    @ 320,640 BUTTON _oSelct PROMPT "&Buscar"    Size 045,015  Action GetNameProd()        Of oDlgProd                    Pixel

        Define SButton oBtnOk      From 320,710 Type 1             Action Eval(bOk) .And. Close(oDlgProd)   Enable Of oDlgProd
        Define SButton oBtnCanc    From 320,740 Type 2             Action Eval(bCancel)  Enable Of oDlgProd

	Activate MsDialog oDlgProd Centered        

	If nOpc==2                                                       
		_lRetm := .F.
	EndIf

dbSelectArea("TRBSX5")
TRBSX5->(dbCloseArea())

dbSelectArea("SX5TRB")
SX5TRB->(dbCloseArea())

Return(_lRetm)

////////////////////////////////////////////////////////////////////////////////////
// - MARCA/DESMARCA O TIPO COM ATUALIZAวรO NO PRODUTO                             //
////////////////////////////////////////////////////////////////////////////////////

Static Function ChkMarca1(_oMARK1,_cMark1)
Local _nReg := Recno()

dbSelectArea("SX5TRB")
If SX5TRB->(X5_OK) == _cMark1
	RecLock("SX5TRB",.F.)
		SX5TRB->(X5_OK) := " "
	SX5TRB->(MsUnLock())
	_cQryUpd := "UPDATE " + RetSqlName("SB1") + " "
	_cQryUpd += "SET B1_MARK = '', B1_RELFAT  = REPLACE(B1_RELFAT,'" + (Alltrim(__cUserId)) + "|" + "','') "
	_cQryUpd += "WHERE D_E_L_E_T_ = '' "
	_cQryUpd += "AND B1_FILIAL  = '" + xFilial("SB1") + "' "
	_cQryUpd += "AND B1_TIPO    = '" + (SX5TRB->(X5_COD)) + "' "
	If TCSQLExec(_cQryUpd) < 0
		MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
		Return()
	EndIf
Else
	RecLock("SX5TRB",.F.)
		SX5TRB->(X5_OK) := _cMark1
	SX5TRB->(MsUnLock())
	_cQryUpd := "UPDATE " + RetSqlName("SB1") + " "
	_cQryUpd += "SET B1_MARK = '" + (_cMark2) + "', B1_RELFAT  = '" + (AllTrim(SB1->B1_RELFAT)) +  (AllTrim(__cUserId)) + "|" + "' "
	_cQryUpd += "WHERE D_E_L_E_T_ = '' "
	_cQryUpd += "AND B1_FILIAL  = '" + xFilial("SB1") + "' "
	_cQryUpd += "AND B1_TIPO    = '" + (SX5TRB->(X5_COD)) + "' "
	If TCSQLExec(_cQryUpd) < 0
		MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
		Return()
	EndIf
EndIf
_oMARK1:oBrowse:Refresh()
_oMARK3:oBrowse:Refresh()

Return NIL

////////////////////////////////////////////////////////////////////////////////////
// - MARCA/DESMARCA FAMILIA ATUALIZANDO O PRODUTO                                 //
////////////////////////////////////////////////////////////////////////////////////

Static Function ChkMarca2(_oMARK2,_cMark2)

Begin Sequence
	If ! SBM->(Eof() .Or. Bof())
		// - DESMARCA
		If ! Empty (SBM->BM_MARK) .And. (Alltrim(__cUserId)) $ (SBM->(BM_RELFAT))
			_cQryUpd := "UPDATE " + RetSqlName("SBM") + " "
			_cQryUpd += "SET BM_MARK = ' ', BM_RELFAT = REPLACE(BM_RELFAT,'" + (Alltrim(__cUserId)) + "|" + "','') "
			_cQryUpd += "WHERE BM_RELFAT LIKE '%" + (Alltrim(__cUserId)) + "|" +"%' "
			_cQryUpd += "AND D_E_L_E_T_ = '' "
			_cQryUpd += "AND BM_FILIAL  = '" + xFilial("SBM") + "' "
			_cQryUpd += "AND BM_GRUPO   = '" + (SBM->BM_GRUPO)  + "' "
			_cGrp := (SBM->(BM_GRUPO))			
			If TCSQLExec(_cQryUpd) < 0
				MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
				Return()
			EndIf
			_cQryUpd := "UPDATE " + RetSqlName("SB1") + " "
			_cQryUpd += "SET B1_MARK = '', B1_RELFAT  = REPLACE(B1_RELFAT,'" + (Alltrim(__cUserId)) + "|" + "','') "
			_cQryUpd += "WHERE D_E_L_E_T_ = '' "
			_cQryUpd += "AND B1_FILIAL  = '" + xFilial("SB1") + "' "
			_cQryUpd += "AND B1_GRUPO   = '" + (_cGrp) + "' "
			If TCSQLExec(_cQryUpd) < 0
				MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
				Return()
			EndIf
		// - MARCA
		Else
			_cQryUpd := "UPDATE " + RetSqlName("SBM") + " "
			_cQryUpd += "SET BM_MARK = '" + (_cMark2) + "', BM_RELFAT  = '" + (AllTrim(SBM->BM_RELFAT)) +  (AllTrim(__cUserId)) + "|" + "' "
			_cQryUpd += "WHERE D_E_L_E_T_ = '' "
			_cQryUpd += "AND BM_FILIAL  = '" + (xFilial("SBM")) + "' "
			_cQryUpd += "AND BM_GRUPO   = '" + (SBM->BM_GRUPO)  + "' "
			_cGrp := (SBM->(BM_GRUPO))
			If TCSQLExec(_cQryUpd) < 0
				MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
				Return()
			EndIf
			_cQryUpd := "UPDATE " + RetSqlName("SB1") + " "
			_cQryUpd += "SET B1_MARK = '" + (_cMark2) + "', B1_RELFAT  = '" + (AllTrim(SB1->B1_RELFAT)) +  (AllTrim(__cUserId)) + "|" + "' "
			_cQryUpd += "WHERE D_E_L_E_T_ = '' "
			_cQryUpd += "AND B1_FILIAL  = '" + xFilial("SB1") + "' "
			_cQryUpd += "AND B1_GRUPO   = '" + (_cGrp) + "' "
			If TCSQLExec(_cQryUpd) < 0
				MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
				Return()
			EndIf
		EndIf
	_oMARK2:oBrowse:Refresh()
	_oMARK3:oBrowse:Refresh()
	EndIf
End Sequence

Return(Nil)

////////////////////////////////////////////////////////////////////////////////////
// - MARCA/DESMARCA PRODUTO                                                       //
////////////////////////////////////////////////////////////////////////////////////

Static Function ChkMarca3(_oMARK3,_cMark3)

Begin Sequence
	If ! SB1->(Eof() .Or. Bof())
		// - DESMARCA
		If ! Empty (SB1->B1_MARK) .And. (Alltrim(__cUserId)) $ (SB1->(B1_RELFAT))
			_cQryUpd := "UPDATE " + RetSqlName("SB1") + " "
			_cQryUpd += "SET B1_MARK = '', B1_RELFAT  = REPLACE(B1_RELFAT,'" + (Alltrim(__cUserId)) + "|" + "','') "
			_cQryUpd += "WHERE B1_RELFAT LIKE '%" + (Alltrim(__cUserId)) + "|" +"%' "
			_cQryUpd += "AND D_E_L_E_T_ = '' "
			_cQryUpd += "AND B1_FILIAL  = '" + xFilial("SB1") + "' "
			_cQryUpd += "AND B1_COD     = '" + (SB1->B1_COD)  + "' "
			If TCSQLExec(_cQryUpd) < 0
				MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
				Return()
			EndIf
		// - MARCA
		Else
			_cQryUpd := "UPDATE " + RetSqlName("SB1") + " "
			_cQryUpd += "SET B1_MARK = '" + (_cMark2) + "', B1_RELFAT  = '" + (AllTrim(SB1->B1_RELFAT)) +  (AllTrim(__cUserId)) + "|" + "' "
			_cQryUpd += "WHERE D_E_L_E_T_ = '' "
			_cQryUpd += "AND B1_FILIAL  = '" + (xFilial("SB1")) + "' "
			_cQryUpd += "AND B1_COD     = '" + (SB1->B1_COD)  + "' "
			If TCSQLExec(_cQryUpd) < 0
				MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
				Return()
			EndIf
		EndIf
	_oMARK3:oBrowse:Refresh()
	EndIf
End Sequence

Return(Nil)

////////////////////////////////////////////////////////////////////////////////////
// - MARCA TODOS OS CLIENTES                                                      //
////////////////////////////////////////////////////////////////////////////////////

Static Function MARKall()

_cQryUpd := "UPDATE " + RetSqlName("SB1") + " "
_cQryUpd += "SET B1_MARK = '" + (_cMark3) + "' , B1_RELFAT  = '" + (AllTrim(SB1->B1_RELFAT)) +  (AllTrim(__cUserId)) + "|" + "' "
_cQryUpd += "WHERE D_E_L_E_T_ = '' "
_cQryUpd += "AND B1_FILIAL  = '" + xFilial("SB1") + "' "
If TCSQLExec(_cQryUpd) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
	Return()
EndIf

SB1->(DbGoTop())
_oMARK3:oBrowse:Refresh()

Return(.T.)

////////////////////////////////////////////////////////////////////////////////////
// - DESMARCA TODOS OS CLIENTES                                                   //
////////////////////////////////////////////////////////////////////////////////////

Static Function UnMARKall()

_cQryUpd := "UPDATE " + RetSqlName("SB1") + " "
_cQryUpd += "SET B1_MARK = '', B1_RELFAT  = REPLACE(B1_RELFAT,'" + (Alltrim(__cUserId)) + "|" + "','') "
_cQryUpd += "WHERE B1_RELFAT LIKE '%" + (Alltrim(__cUserId)) + "|" +"%' "
_cQryUpd += "AND D_E_L_E_T_ = '' "
_cQryUpd += "AND B1_FILIAL  = '" + xFilial("SB1") + "' "
If TCSQLExec(_cQryUpd) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
	Return()
EndIf
SB1->(DbGoTop())
_oMARK3:oBrowse:Refresh()
	
Return(.T.)

////////////////////////////////////////////////////////////////////////////////////
// - EXECUTA PESQUISA DE PRODUTO CONFORME PARTE DA STRING                         //
////////////////////////////////////////////////////////////////////////////////////
Static Function GetNameProd()

_cQryGet := "SELECT B1_DESC[NOME],R_E_C_N_O_[REC]
_cQryGet += "FROM " + RetSqlName("SB1") + " SB1 " "
_cQryGet += "WHERE SB1.B1_DESC LIKE '%" + (Upper(Alltrim(_cGetProd))) + "%' "
_cQryGet += " OR SB1.B1_COD LIKE '%" + (Upper(Alltrim(_cGetProd))) + "%' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQryGet),"TMPGET",.F.,.T.)
_cRet:= (TMPGET->(REC))
SB1->(DbGoTo(_cRet))
TMPGET->(dbCloseArea())

Return()

////////////////////////////////////////////////////////////////////////////////////
// - EXECUTA PESQUISA DE GRUPO CONFORME PARTE DA STRING                           //
////////////////////////////////////////////////////////////////////////////////////
Static Function GetNameGrp()

_cQryGet := "SELECT BM_DESC[NOME],R_E_C_N_O_[REC]
_cQryGet += "FROM " + RetSqlName("SBM") + " SBM "
_cQryGet += "WHERE SBM.BM_DESC LIKE '%" + (Upper(Alltrim(_cGetGrp))) + "%' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQryGet),"TMPGET",.F.,.T.)
_cRet:= (TMPGET->(REC))
SBM->(DbGoTo(_cRet))
TMPGET->(dbCloseArea())

Return()
