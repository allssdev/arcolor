#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SELECAO  บAutor  ณAdriano L. de Souza บ Data ณ  20/12/13   บฑฑ
ฑฑบAlter     ณ          บAutor  ณJ๚lio Soares        บ Data ณ  19/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsแvel por montar MARKbrowse para escolha dos  บฑฑ
ฑฑบ          ณ produtos que serใo considerados no relat๓rio.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ Efetuado adapta็ใo para realizar a marca็ใo diretamente    บฑฑ
ฑฑบ          ณ via instru็ใo Update no banco para nใo gravar log de       บฑฑ
ฑฑบ          ณ usuแrio de altera็ใo nos cadastros.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico empresa ARCOLOR                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function RFATE046()

nOpc     := 2
bOk      := {||nOpc:=1,oDlgProd:End()}
bCancel  := {||nOpc:=2,oDlgProd:End()}

Private _oSelct
Private _oGet
Private _cGet := Space(TamSx3("A1_NOME")[01])


Private aCampos  := {}
Private _cRotina := "RFATE046"
Private aMarcados[2], nMarcado := 0
Private cMarca   := GetMARK(), lInverte := .F., oMARK
Public _lRetm    := .T.
aIndex   := {}

// - REALIZA A LIMPEZA DOS CAMPOS CONFORME O LOGIN DO USUมRIO.
_cQryUpd := "UPDATE " + RetSqlName("SA1") + " "
_cQryUpd += "SET A1_MARK = '', A1_RELFAT  = REPLACE(A1_RELFAT,'" + (Alltrim(__cUserId)) + "|" + "','') "
_cQryUpd += "WHERE A1_RELFAT LIKE '%" + (Alltrim(__cUserId)) + "|" +"%' "
_cQryUpd += "AND D_E_L_E_T_ = '' "
_cQryUpd += "AND A1_FILIAL  = '" + xFilial("SA1") + "' "
If TCSQLExec(_cQryUpd) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
	Return()
EndIf

Private bFiltraBrw 	:= {|| Nil}

_cInd:=CriaTrab(Nil,.F.)

IndRegua("SA1",_cInd,"A1_CGCCENT + A1_NOME + A1_CGC",,,"Criando ํndice temporario...")

// Altera็ใo - Fernando Bombardi - ALLSS - 02/03/2022
/*
aCampos := {{"A1_MARK"    ,," "               },;
			{"A1_CGCCENT" ,,"CNPJ CENTRAL"    },;
			{"A1_CGC"     ,,"CNPJ"            },;
			{"A1_NOME"    ,,"NOME CLIENTE"    },;
			{"A1_COD"     ,,"CODIGO CLIENTE"  },;
			{"A1_LOJA"    ,,"LOJA"            },;
			{"A1_VEND"    ,,"CODIGO VENDEDOR" }}
*/
aCampos := {{"A1_MARK"    ,," "               },;
			{"A1_CGCCENT" ,,"CNPJ CENTRAL"    },;
			{"A1_CGC"     ,,"CNPJ"            },;
			{"A1_NOME"    ,,"NOME CLIENTE"    },;
			{"A1_COD"     ,,"CODIGO CLIENTE"  },;
			{"A1_LOJA"    ,,"LOJA"            },;
			{"A1_VEND"    ,,"CODIGO REPRESENTANTE" }}
// Altera็ใo - Fernando Bombardi - ALLSS - 02/03/2022

			//{"A1_VENDESC" ,,"NOME VENDEDOR" }}

	Define MsDialog oDlgProd Title "Sele็ใo de clientes" From 8,0 To 53,185 Of oMainWnd
		DbSelectArea("SA1")
		DbGoTop()
		
	 	@ 9,10 Say "Marque os clientes que serใo considerados no relat๓rio" Size 232,10 Pixel Of oDlgProd
	 	oMARK := MsSelect():New("SA1","A1_MARK",,aCampos,lInverte,@cMarca,{18,3,305,720})
	 	oMARK:oBrowse:lHasMARK := .T.
		oMARK:oBrowse:lCanAllMARK:=.T.
		oMARK:oBrowse:bAllMARK := {|| MARKAll ("SA1", cMarca, @oDlgProd)}
        oMARK:bAval := {|| ChkMarca(oMARK,cMarca) }
        AddColMARK(oMARK,"A1_MARK")
	    @ 310,010 button "&Marcar Todos"          Size 045,015  Action MARKall()            Of oDlgProd                    Pixel
	    @ 310,070 button "&Desmarcar Todos"       Size 045,015  Action UnMARKAll()          Of oDlgProd                    Pixel
   	    @ 310,130 button "&CNPJ-Central"          Size 045,015  Action MARKCGC()            Of oDlgProd                    Pixel

		// Altera็ใo - Fernando Bombardi - ALLSS - 02/03/2022
   	    //@ 310,190 button "&Vendedor"              Size 045,015  Action MARKVend()           Of oDlgProd                    Pixel
   	    @ 310,190 button "&Representante"          Size 045,015  Action MARKVend()           Of oDlgProd                    Pixel
		// Fim - Fernando Bombardi - ALLSS - 02/03/2022

	    @ 310,250 MSGET _oGet VAR _cGet           Size 130,010                              Of oDlgProd COLORS 0, 16777215 Pixel
	    @ 310,390 BUTTON _oSelct PROMPT "&Buscar" Size 045,015  Action GetCGC()             Of oDlgProd                    Pixel
        Define SButton oBtnOk      From 310,460 Type 1          Action Eval(bOk)     Enable Of oDlgProd
        Define SButton oBtnCanc    From 310,490 Type 2          Action Eval(bCancel) Enable Of oDlgProd
	Activate MsDialog oDlgProd Centered        

	If nOpc==2
		_lRetm := .F.
	EndIf
Return(_lRetm)

	/* // - Trecho anterior
	Define MsDialog oDlgProd Title "Sele็ใo de clientes" From 8,0 To 28,80 Of oMainWnd
		DbSelectArea("SA1")
		DbGoTop()
	 	@ 9,10 Say "Marque os clientes que serใo considerados no relat๓rio" Size 232,10 Pixel Of oDlgProd
	 	oMARK := MsSelect():New("SA1","A1_MARK",,aCampos,lInverte,@cMarca,{18,3,125,312})
	 	oMARK:oBrowse:lHasMARK := .T.
		oMARK:oBrowse:lCanAllMARK:=.T.
		oMARK:oBrowse:bAllMARK := {|| MARKAll ("SA1", cMarca, @oDlgProd)}
        oMARK:bAval := {|| ChkMarca(oMARK,cMarca) }
        AddColMARK(oMARK,"A1_MARK")
	    @ 130,010 button "Marcar Todos"    Size 48,17 Action MARKall()            Of oDlgProd Pixel
	    @ 130,060 button "Desmarcar Todos" Size 48,17 Action UnMARKAll()          Of oDlgProd Pixel
        Define SButton oBtnOk     From 130,258 Type 1 Action Eval(bOk) Enable     Of oDlgProd
        Define SButton oBtnCanc   From 130,288 Type 2 Action Eval(bCancel) Enable Of oDlgProd
	Activate MsDialog oDlgProd Centered
	*/

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MARKAll  บAutor  ณAdriano L. de Souza บ Data ณ  20/12/13   บฑฑ
ฑฑบAlter     ณ          บAutor  ณJ๚lio Soares        บ Data ณ  19/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo criada para marcar todos os registros da tela de    บฑฑ
ฑฑบ          ณ diแlogo.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico empresa Arcolor                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function MARKAll()

_cQryUpd := "UPDATE " + RetSqlName("SA1") + " "
_cQryUpd += "SET A1_MARK = '" + (cMarca) + "' , A1_RELFAT  = '" + (AllTrim(SA1->A1_RELFAT)) +  (AllTrim(__cUserId)) + "|" + "' "
_cQryUpd += "WHERE D_E_L_E_T_ = '' "
_cQryUpd += "AND A1_FILIAL  = '" + xFilial("SA1") + "' "
If TCSQLExec(_cQryUpd) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
	Return()
EndIf

SA1->(DbGoTop())
oMARK:oBrowse:Refresh()

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ UnMARKAll บAutor ณAdriano L. de Souza บ Data ณ  20/12/13   บฑฑ
ฑฑบAlter     ณ          บAutor  ณJ๚lio Soares        บ Data ณ  19/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo criada para desmarcar todos os registros da tela de บฑฑ
ฑฑบ          ณ diแlogo.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico empresa Arcolor                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/


Static Function UnMARKAll()

_cQryUpd := "UPDATE " + RetSqlName("SA1") + " "
_cQryUpd += "SET A1_MARK = '', A1_RELFAT  = REPLACE(A1_RELFAT,'" + (Alltrim(__cUserId)) + "|" + "','') "
_cQryUpd += "WHERE A1_RELFAT LIKE '%" + (Alltrim(__cUserId)) + "|" +"%' "
_cQryUpd += "AND D_E_L_E_T_ = '' "
_cQryUpd += "AND A1_FILIAL  = '" + xFilial("SA1") + "' "
If TCSQLExec(_cQryUpd) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
	Return()
EndIf
SA1->(DbGoTop())
oMARK:oBrowse:Refresh()
	
Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ChkMarca บAutor  ณAdriano L. de Souza บ Data ณ  20/12/13   บฑฑ
ฑฑบAlter     ณ          บAutor  ณJ๚lio Soares        บ Data ณ  19/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo criada para permitir a sele็ใo de um registro para  บฑฑ
ฑฑบ          ณ definir quais produtos comporใo o relat๓rio.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณ Protheus11 - Especํfico empresa Arcolor                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
                                                                  
Static Function ChkMarca(oMARK,cMarca)

Local posicao

Begin Sequence
	If ! SA1->(Eof() .Or. Bof())
		// - DESMARCA
		If ! Empty (SA1->A1_MARK) .And. (Alltrim(__cUserId)) $ (SA1->(A1_RELFAT))
			_cQryUpd := "UPDATE " + RetSqlName("SA1") + " "
			_cQryUpd += "SET A1_MARK = '', A1_RELFAT  = REPLACE(A1_RELFAT,'" + (Alltrim(__cUserId)) + "|" + "','') "
			_cQryUpd += "WHERE A1_RELFAT LIKE '%" + (Alltrim(__cUserId)) + "|" +"%' "
			_cQryUpd += "AND D_E_L_E_T_ = '' "
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
			_cQryUpd += "SET A1_MARK = '" + (cMarca) + "', A1_RELFAT  = '" + (AllTrim(SA1->A1_RELFAT)) +  (AllTrim(__cUserId)) + "|" + "' "
			_cQryUpd += "WHERE D_E_L_E_T_ = '' "
			_cQryUpd += "AND A1_FILIAL  = '" + (xFilial("SA1")) + "' "
			_cQryUpd += "AND A1_COD     = '" + (SA1->A1_COD)  + "' "
			_cQryUpd += "AND A1_LOJA    = '" + (SA1->A1_LOJA) + "' "
			If TCSQLExec(_cQryUpd) < 0
				MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
				Return()
			EndIf
		EndIf
	oMARK:oBrowse:Refresh()
	EndIf
End Sequence

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MARKCGC    บAutor  ณJ๚lio Soares      บ Data ณ  19/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo criada para aglutinar os CNPJ's centrais            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณ Protheus11 - Especํfico empresa Arcolor                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function MARKCGC()

Begin Sequence
	If ! SA1->(Eof() .Or. Bof())
		// - MARCA TODOS OS CGC'S - CENTRAIS
		If ! Empty (SA1->A1_MARK) .And. (Alltrim(__cUserId)) $ (SA1->(A1_RELFAT))
			_cQryUpd := "UPDATE " + RetSqlName("SA1") + " "
			_cQryUpd += "SET A1_MARK = '', A1_RELFAT  = REPLACE(A1_RELFAT,'" + (Alltrim(__cUserId)) + "|" + "','') "
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
			_cQryUpd += "SET A1_MARK = '" + (cMarca) + "', A1_RELFAT  = '" + (AllTrim(SA1->A1_RELFAT)) +  (AllTrim(__cUserId)) + "|" + "' "
			_cQryUpd += "WHERE D_E_L_E_T_ = '' "
			_cQryUpd += "AND A1_FILIAL  = '" + xFilial("SA1") + "' "
			_cQryUpd += "AND A1_CGCCENT = '" + (SA1->A1_CGCCENT) + "' "
			If TCSQLExec(_cQryUpd) < 0
				MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
				Return()
			EndIf
		EndIf
		oMARK:oBrowse:Refresh()
	EndIf
End Sequence

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MARKVend   บAutor  ณJ๚lio Soares      บ Data ณ  19/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo criada para aglutinar os CNPJ's centrais            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณ Protheus11 - Especํfico empresa Arcolor                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function MARKVend()

Begin Sequence
	If ! SA1->(Eof() .Or. Bof())
		// - MARCA TODOS OS VENDEDORES
		If ! Empty (SA1->A1_MARK) .And. (Alltrim(__cUserId)) $ (SA1->(A1_RELFAT))
			_cQryUpd := "UPDATE " + RetSqlName("SA1") + " "
			_cQryUpd += "SET A1_MARK = '', A1_RELFAT  = REPLACE(A1_RELFAT,'" + (Alltrim(__cUserId)) + "|" + "','') "
			_cQryUpd += "WHERE D_E_L_E_T_ = '' "
			_cQryUpd += "AND A1_FILIAL  = '" + xFilial("SA1") + "' "
			_cQryUpd += "AND A1_VEND    = '" + (SA1->A1_VEND) + "' "
			If TCSQLExec(_cQryUpd) < 0
				MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
				Return()
			EndIf
		// - DESMARCA TODOS OS VENDEDORES
	    Else
			_cQryUpd := "UPDATE " + RetSqlName("SA1") + " "
			_cQryUpd += "SET A1_MARK = '" + (cMarca) + "', A1_RELFAT  = '" + (AllTrim(SA1->A1_RELFAT)) +  (AllTrim(__cUserId)) + "|" + "' "
			_cQryUpd += "WHERE D_E_L_E_T_ = '' "
			_cQryUpd += "AND A1_FILIAL  = '" + xFilial("SA1") + "' "
			_cQryUpd += "AND A1_VEND    = '" + (SA1->A1_VEND) + "' "
			If TCSQLExec(_cQryUpd) < 0
				MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
				Return()
			EndIf
		EndIf
		oMARK:oBrowse:Refresh()
	EndIf
End Sequence

Return(.T.)
                                                                                   

Static Function GetCGC()

_cQryGet := "SELECT A1_NOME[NOME],R_E_C_N_O_[REC]
_cQryGet += "FROM " + RetSqlName("SA1") + " SA1 " "
_cQryGet += "WHERE SA1.A1_NOME LIKE '%" + (Upper(Alltrim(_cGet))) + "%'
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQryGet),"TMPGET",.F.,.T.)
_cRet:= (TMPGET->(REC))
SA1->(DbGoTo(_cRet))
TMPGET->(dbCloseArea())

Return()
