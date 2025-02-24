#INCLUDE 'Protheus.ch'
#INCLUDE 'Rwmake.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATE053  ºAutor  ³Júlio Soares        º Data ³  07/30/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina responsável pela replicação das regras de comissão  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico empresa - ARCOLOR                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFATE053()

Private _cRotina := 'RFATE053'
Private _cGet01
Private _cGet02
Private _cGet03
Private _cGet04
Private _cProd01
Private _cProd02

Private oGrp01
Private oGrp02
Private oGet01 := SZ6->(Z6_GRPPRO)
Private oGet02 := SZ6->(Z6_DESCGR)
Private oGet03 := SZ6->(Z6_PRODUT)
Private oGet04 := SZ6->(Z6_DESCPR)
Private oButton1
Private oButton2

Private _cMark1                := 'xx'/*GetMARK()*/, lInverte := .F., _oMARK1
Private aMarcados[2], nMarcado := 0
Private _aCpos              := {}
Private aCampos             := {}
Private _lEnt := CHR(13) + CHR(10)

// - CABEÇALHO - MONTO A ESTRUTURA DO ARRAY
AADD(_aCpos,{"Z6_OK"     ,"C",02                       ,0                      })
AADD(_aCpos,{"Z6_REPRES" ,"C",(TamSx3("Z6_REPRES")[01]),0                      })
AADD(_aCpos,{"Z6_NOMERE" ,"C",(TamSx3("Z6_NOMERE")[01]),0                      })
AADD(_aCpos,{"Z6_GRPPRO" ,"C",(TamSx3("Z6_GRPPRO")[01]),0                      })
AADD(_aCpos,{"Z6_DESCGR" ,"C",(TamSx3("Z6_DESCGR")[01]),0                      })
AADD(_aCpos,{"Z6_PRODUT" ,"C",(TamSx3("Z6_PRODUT")[01]),0                      })
AADD(_aCpos,{"Z6_DESCPR" ,"C",(TamSx3("Z6_DESCPR")[01]),0                      })
AADD(_aCpos,{"Z6_PERC"   ,"N",(TamSx3("Z6_PERC")[01])  ,(TamSx3("Z6_PERC")[02])})
AADD(_aCpos,{"Z6_DTINI"  ,"D",08                       ,0                      })
AADD(_aCpos,{"Z6_DTFIM"  ,"D",08                       ,0                      })
//AADD(_aCpos,{"R_E_C_N_O_","N",99                       ,0                      })

/*
_cInd1 := CriaTrab(_aCpos,.T.)

dbUseArea(.T.,,_cInd1,"SZ6TRA",.T.,.F.)
IndRegua("SZ6TRA",_cInd1,"Z6_REPRES + Z6_GRPPRO + Z6_PRODUT",,,"Criando índice temporario...")
*/

//-------------------
//Criacao do objeto
//-------------------
oTempTable := FWTemporaryTable():New( "SZ6TRA" )
	
oTemptable:SetFields( _aCpos )
oTempTable:AddIndex("indice1", {"Z6_REPRES","Z6_GRPPRO","Z6_PRODUT"} )

//------------------
//Criacao da tabela
//------------------
oTempTable:Create()

// - FORMACAO DA QUERY
_cQryCel := " SELECT SZ6AUX.Z6_REPRES, SZ6AUX.Z6_NOMERE, "                        + _lEnt
_cQryCel += " ISNULL(Z6_GRPPRO,'')[Z6_GRPPRO],ISNULL(Z6_DESCGR,'')[Z6_DESCGR], "  + _lEnt
_cQryCel += " ISNULL(Z6_PRODUT,'')[Z6_PRODUT], ISNULL(Z6_DESCPR,'')[Z6_DESCPR], " + _lEnt
_cQryCel += " ISNULL(Z6_PERC,0)[Z6_PERC], "                                       + _lEnt
_cQryCel += " ISNULL(Z6_DTINI,'')[Z6_DTINI],ISNULL(Z6_DTFIM,'')[Z6_DTFIM], "      + _lEnt
_cQryCel += " ISNULL(SZ6.R_E_C_N_O_,'')[R_E_C_N_O_] "                             + _lEnt
_cQryCel += " FROM  "                                                             + _lEnt
_cQryCel += " 	(SELECT SZ6.Z6_REPRES,SZ6.Z6_NOMERE "                             + _lEnt
_cQryCel += " 	 FROM " + RetSqlName("SZ6") + " SZ6 "                             + _lEnt
_cQryCel += " 	 WHERE SZ6.D_E_L_E_T_ = '' "                                      + _lEnt
_cQryCel += " 	 AND SZ6.Z6_FILIAL = '" + xFilial("SZ6") + "' "                   + _lEnt
_cQryCel += " 	 GROUP BY SZ6.Z6_REPRES,SZ6.Z6_NOMERE "                           + _lEnt
_cQryCel += " 	)SZ6AUX "                                                         + _lEnt
_cQryCel += " 	LEFT JOIN " + RetSqlName("SZ6") + " SZ6 "                         + _lEnt
_cQryCel += " 		ON SZ6.D_E_L_E_T_ = '' "                                      + _lEnt
_cQryCel += " 		AND SZ6.Z6_FILIAL = '" + xFilial("SZ6") + "' "                + _lEnt
_cQryCel += " 		AND SZ6.Z6_REPRES = SZ6AUX.Z6_REPRES "                        + _lEnt
_cQryCel += " 		AND SZ6.Z6_GRPPRO = '" + SZ6->(Z6_GRPPRO) + "' "              + _lEnt
_cQryCel += " 		AND SZ6.Z6_PRODUT = '" + SZ6->(Z6_PRODUT) + "' "              + _lEnt
_cQryCel += " INNER JOIN " + RetSqlName("SA3") + " SA3 "                          + _lEnt
_cQryCel += " 	ON SA3.D_E_L_E_T_ = '' "                                          + _lEnt
_cQryCel += " 	AND SA3.A3_FILIAL = '" + xFilial("SA3") + "' "                    + _lEnt
_cQryCel += " 	AND SA3.A3_COD = SZ6AUX.Z6_REPRES "                               + _lEnt
_cQryCel += " 	AND SA3.A3_MSBLQL <> '1' "                                        + _lEnt
	
//MemoWrite("\2.MemoWrite\"+_cRotina+"_001.TXT",_cQryCel)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQryCel),"TRASZ6",.F.,.T.)

// - INSERE NA ESTRUTURA JA CRIADA O CONTEÚDO DOS CAMPOS
dbSelectArea("TRASZ6")//TEMPORARIA
TRASZ6->(dbGoTop())
While ! TRASZ6->(EOF())
	RecLock("SZ6TRA",.T.)
		Z6_OK      := "  "
		Z6_REPRES  := TRASZ6->(Z6_REPRES)
		Z6_NOMERE  := TRASZ6->(Z6_NOMERE)
		Z6_GRPPRO  := TRASZ6->(Z6_GRPPRO)
		Z6_DESCGR  := TRASZ6->(Z6_DESCGR)
		Z6_PRODUT  := TRASZ6->(Z6_PRODUT)
		Z6_DESCPR  := TRASZ6->(Z6_DESCPR)
		Z6_PERC    := TRASZ6->(Z6_PERC)
		Z6_DTINI   := STOD(TRASZ6->(Z6_DTINI))
		Z6_DTFIM   := STOD(TRASZ6->(Z6_DTFIM))
		R_E_C_N_O_ := TRASZ6->(R_E_C_N_O_)
	TRASZ6->(MsUnlock())
	TRASZ6->(dbSkip())
EndDo

dbSelectArea("TRASZ6")
TRASZ6->(dbGotop())
// - CRIO A GET COM BASE NO ARRAY JÁ POPULADO
AADD(aCampos,{"Z6_OK"      ,"" ,"OK"             ,"" })
AADD(aCampos,{"Z6_REPRES"  ,"" ,"COD REPRES"     ,"" })
AADD(aCampos,{"Z6_NOMERE"  ,"" ,"NOME  REPRES"   ,"" })
AADD(aCampos,{"Z6_GRPPRO"  ,"" ,"COD GRUPO"      ,"" })
AADD(aCampos,{"Z6_DESCGR"  ,"" ,"DESCRI GRUPO"   ,"" })
AADD(aCampos,{"Z6_PRODUT"  ,"" ,"COD PRODUTO"    ,"" })
AADD(aCampos,{"Z6_DESCPR"  ,"" ,"DESCRI PRODUTO" ,"" })
AADD(aCampos,{"Z6_PERC"    ,"" ,"PERCENTUAL"     ,"" })
AADD(aCampos,{"Z6_DTINI"   ,"" ,"INI VIGENC"     ,"" })
AADD(aCampos,{"Z6_DTFIM"   ,"" ,"FIM VIGENC"     ,"" })
//AADD(aCampos,{"R_E_C_N_O_" ,"" ,"RECNO"          ,"" })

// - MONTA A TELA DCOM A GET
Static oDlg

  DEFINE MSDIALOG oDlg TITLE " Replica comissões nas demais regras" FROM 000, 000  TO 600, 1350 COLORS 0, 16777215 PIXEL

    @ 005, 007 GROUP oGrp01 TO 036, 615 PROMPT "Seleção do produto"                                OF oDlg COLOR  0, 16777215 PIXEL
    @ 041, 008 GROUP oGrp02 TO 280, 615 PROMPT "Seleção dos representantes"                        OF oDlg COLOR  0, 16777215 PIXEL
    @ 015, 011 SAY   _cProd01           PROMPT "Grupo de Produto" SIZE 057, 010                    OF oDlg COLORS 0, 16777215 PIXEL
    @ 015, 070 MSGET _cGet01            VAR oGet01                SIZE 042, 013                    OF oDlg COLORS 0, 16777215 WHEN .F. READONLY PIXEL
    @ 015, 119 MSGET _cGet02            VAR oGet02                SIZE 080, 012                    OF oDlg COLORS 0, 16777215 WHEN .F. READONLY PIXEL
    @ 015, 204 SAY   _cProd02           PROMPT "Produto"          SIZE 030, 010                    OF oDlg COLORS 0, 16777215 PIXEL
    @ 015, 231 MSGET _cGet03            VAR oGet03                SIZE 057, 012                    OF oDlg COLORS 0, 16777215 WHEN .F. READONLY PIXEL
    @ 015, 300 MSGET _cGet04            VAR oGet04                SIZE 107, 014                    OF oDlg COLORS 0, 16777215 WHEN .F. READONLY PIXEL

	dbSelectArea("SZ6TRA")
	SZ6TRA->(dbGoTop())
	_oMARK1 := MsSelect():New("SZ6TRA","Z6_OK",,aCampos,lInverte,@_cMark1,{50,10,275,600})
//	AddColMARK(_oMARK1,"Z6_OK")
 	_oMARK1:oBrowse:lHasMARK    := .T.
	_oMARK1:oBrowse:lCanAllMARK := .T.
	_oMARK1:oBrowse:bAllMARK    := {|| marktds ("SZ6TRA",_cMark1, @oDlg)}
	
	_oMARK1:bAval               := {|| ChkMarca1(_oMARK1,_cMark1) }


    @ 283, 360 BUTTON oButton1          PROMPT "&Confirmar"       SIZE 055, 015 Action _oConfirm() OF oDlg PIXEL
    @ 283, 300 BUTTON oButton2          PROMPT "&Cancelar"        SIZE 055, 015 Action _oCalcel()  OF oDlg PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

dbSelectArea("SZ6TRA")
SZ6TRA->(dbCloseArea())

dbSelectArea("TRASZ6")
TRASZ6->(dbCloseArea())

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATE053  ºAutor  ³Júlio Soares        º Data ³  07/30/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza a marcação da alterações.                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico empresa - ARCOLOR                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ChkMarca1(_oMARK1,_cMark1)

Local _nReg := SZ6TRA->(R_E_C_N_O_)

dbSelectArea("SZ6TRA")
//SZ6TRA->(dbSetOrder(IndexOrd(_cInd1)))
SZ6TRA->(dbSetOrder(1))
If SZ6TRA->(Z6_OK) == _cMark1
//	dbSelectArea("SZ6TRA")
//	dbSetOrder(IndexOrd(_cInd1))
	If dbseek(SZ6TRA->(Z6_REPRES)+SZ6TRA->(Z6_GRPPRO)+SZ6TRA->(Z6_PRODUT))
		RecLock("SZ6TRA",.F.)
			SZ6TRA->(Z6_OK) := ''
		SZ6TRA->(MsUnLock())
	EndIf
Else
	If _nReg == 0
		CriaPerc()
	Else
		AlterPerc()
	EndIf
// - VERIFICAR SE PRECISA REALMENTE ZERAR AS VARIÁVEIS
cGet1 := ''
cGet2 := ''
cGet3 := ''
cGet4 := ''
nGet5 := 0
dGet6 := ''
dGet7 := ''
EndIf
//Inclusão - Fernando Bombardi - 14/04/23
_oMARK1:oBrowse:Refresh()
//Fim Inclusão - Fernando Bombardi - 14/04/23
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATE053  ºAutor  ³Júlio Soares        º Data ³  07/30/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria a tela para criação da comissão.                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico empresa - ARCOLOR                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

// - CRIAÇÃO DO PERCENTUAL DE COMISSÃO
Static Function CriaPerc()                        

Private Cancelar
Private Confirmar
Private oGet1
Private oGet2
Private oGet3
Private oGet4
Private oGet5
Private oGet6
Private oGet7
Private oGroup1
Private oGroup2
Private oGroup3
Private oPerc
Private oDate1
Private oDate2

Private cGet1 := Transform(TRASZ6->(Z6_GRPPRO),PesqPict("SZ6","Z6_GRPPRO"))
Private cGet2 := Transform(TRASZ6->(Z6_DESCGR),PesqPict("SZ6","Z6_DESCGR"))
Private cGet3 := Transform(TRASZ6->(Z6_PRODUT),PesqPict("SZ6","Z6_PRODUT"))
Private cGet4 := Transform(TRASZ6->(Z6_DESCPR),PesqPict("SZ6","Z6_DESCPR"))
Private nGet5 := 0
Private dGet6 := Date()
Private dGet7 := STOD("20491231") //Date() //Linha alterada por Adriano Leonardo em 01/09/2014 por solicitação do Sr. Mário

Static oDlgPer

  DEFINE MSDIALOG oDlgPer TITLE "Atualiza percentual de comissão" FROM 000, 000  TO 175, 550 COLORS 0, 16777215 PIXEL

    @ 005, 005 GROUP oGroup1    TO 030, 127 PROMPT "Grupo de produtos"                            OF oDlgPer COLOR  0, 16777215 PIXEL            
    @ 012, 007 MSGET oGet1      VAR cGet1                        SIZE 040, 012                    OF oDlgPer COLORS 0, 16777215 WHEN .F. READONLY PIXEL
    @ 012, 050 MSGET oGet2      VAR cGet2                        SIZE 075, 012                    OF oDlgPer COLORS 0, 16777215 WHEN .F. READONLY PIXEL

    @ 005, 130 GROUP oGroup2    TO 030, 267 PROMPT "Produto"                                      OF oDlgPer COLOR  0, 16777215 PIXEL
    @ 012, 132 MSGET oGet3      VAR cGet3                        SIZE 040, 012                    OF oDlgPer COLORS 0, 16777215 WHEN .F. READONLY PIXEL
    @ 012, 177 MSGET oGet4      VAR cGet4                        SIZE 087, 012                    OF oDlgPer COLORS 0, 16777215 WHEN .F. READONLY PIXEL

    @ 034, 005 GROUP oGroup3    TO 064, 267 PROMPT "Comissao / Vigência"                          OF oDlgPer COLOR  0, 16777215 PIXEL
    @ 045, 007 SAY oPerc                    PROMPT "Percentual"  SIZE 037, 012                    OF oDlgPer COLORS 0, 16777215 PIXEL
    @ 045, 047 MSGET oGet5      VAR nGet5                        SIZE 025, 012                    OF oDlgPer COLORS 0, 16777215 PICTURE "@E 99.99" PIXEL
    @ 045, 086 SAY oDate1                   PROMPT "Datainicial" SIZE 037, 012                    OF oDlgPer COLORS 0, 16777215 PIXEL
    @ 045, 125 MSGET oGet6      VAR dGet6                        SIZE 040, 012                    OF oDlgPer COLORS 0, 16777215 PIXEL
    @ 045, 169 SAY oDate2                   PROMPT "Datafinal"   SIZE 037, 012                    OF oDlgPer COLORS 0, 16777215 PIXEL
    @ 045, 207 MSGET oGet7      VAR dGet7                        SIZE 040, 012                    OF oDlgPer COLORS 0, 16777215 PIXEL
    @ 070, 225 BUTTON Confirmar             PROMPT "Confirmar"   SIZE 037, 012 Action Confirmar() OF oDlgPer PIXEL
    @ 070, 175 BUTTON Cancelar              PROMPT "Cancelar"    SIZE 037, 012 Action Cancelar()  OF oDlgPer PIXEL

  ACTIVATE MSDIALOG oDlgPer CENTERED

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATE053  ºAutor  ³Júlio Soares        º Data ³  07/30/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Confirma a alteração                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico empresa - ARCOLOR                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Confirmar()

dbSelectArea("SZ6TRA")
//dbSetOrder(IndexOrd(_cInd1))
dbSetOrder(1)
_cRepre := (SZ6TRA->(Z6_REPRES))
_cNomRe := (SZ6TRA->(Z6_NOMERE))
RecLock("SZ6TRA",.T.)
	SZ6TRA->(Z6_OK)     := 'xx'
	SZ6TRA->(Z6_REPRES) := _cRepre
	SZ6TRA->(Z6_NOMERE) := _cNomRe
	SZ6TRA->(Z6_GRPPRO) := SZ6->(Z6_GRPPRO)
	SZ6TRA->(Z6_DESCGR) := SZ6->(Z6_DESCGR)
	SZ6TRA->(Z6_PRODUT) := SZ6->(Z6_PRODUT)
	SZ6TRA->(Z6_DESCPR) := SZ6->(Z6_DESCPR)
	SZ6TRA->(Z6_PERC)   := (nGet5)
	SZ6TRA->(Z6_DTINI)  := (dGet6)
	SZ6TRA->(Z6_DTFIM)  := (dGet7)
SZ6TRA->(MsUnlock())
Close(oDlgPer)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATE053  ºAutor  ³Júlio Soares        º Data ³  07/30/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cancela                                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico empresa - ARCOLOR                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// - CANCELAMENTO DA ALTERAÇÃO
Static Function Cancelar()
	Close(oDlgPer)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATE053  ºAutor  ³Júlio Soares        º Data ³  07/30/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela a ser apresentada para alteração do percentual de     º±±
±±º          ³ comissão.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico empresa - ARCOLOR                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

// - ALTERAÇÃO DO PERCENTUAL DE COMISSÃO                             
Static Function AlterPerc()

Private Cancela
Private Confirma
Private oGet1
Private oGet2
Private oGet3
Private oGet4
Private oGet5
Private oGet6
Private oGet7
Private oGroup1
Private oGroup2
Private oGroup3
Private oPerc
Private oDate1
Private oDate2

Private cGet1 := Transform(TRASZ6->(Z6_GRPPRO),PesqPict("SZ6","Z6_GRPPRO"))
Private cGet2 := Transform(TRASZ6->(Z6_DESCGR),PesqPict("SZ6","Z6_DESCGR"))
Private cGet3 := Transform(TRASZ6->(Z6_PRODUT),PesqPict("SZ6","Z6_PRODUT"))
Private cGet4 := Transform(TRASZ6->(Z6_DESCPR),PesqPict("SZ6","Z6_DESCPR"))
/*
Private nGet5 := TRASZ6->(Z6_PERC)
Private dGet6 := STOD(TRASZ6->(Z6_DTINI))
Private dGet7 := STOD(TRASZ6->(Z6_DTFIM))
*/
Private nGet5 := SZ6TRA->(Z6_PERC)
Private dGet6 := SZ6TRA->(Z6_DTINI)
Private dGet7 := STOD("20491231")//SZ6TRA->(Z6_DTFIM) //Linha alterada por Adriano Leonardo em 01/09/2014 por solicitação do Sr. Mário

Static oDlgPer

  DEFINE MSDIALOG oDlgPer TITLE "Atualiza percentual de comissão" FROM 000, 000  TO 175, 550 COLORS 0, 16777215 PIXEL

    @ 005, 005 GROUP oGroup1   TO 030, 127 PROMPT "Grupo de produtos"                               OF oDlgPer COLOR  0, 16777215 PIXEL
    @ 012, 007 MSGET oGet1     VAR cGet1                          SIZE 040, 012                     OF oDlgPer COLORS 0, 16777215 WHEN .F. READONLY PIXEL
    @ 012, 050 MSGET oGet2     VAR cGet2                          SIZE 075, 012                     OF oDlgPer COLORS 0, 16777215 WHEN .F. READONLY PIXEL
    @ 005, 130 GROUP oGroup2   TO 030, 267 PROMPT "Produto"                                         OF oDlgPer COLOR  0, 16777215 PIXEL
    @ 012, 132 MSGET oGet3     VAR cGet3                          SIZE 040, 012                     OF oDlgPer COLORS 0, 16777215 WHEN .F. READONLY PIXEL
    @ 012, 177 MSGET oGet4     VAR cGet4                          SIZE 087, 012                     OF oDlgPer COLORS 0, 16777215 WHEN .F. READONLY PIXEL

    @ 034, 005 GROUP oGroup3   TO 064, 267 PROMPT "Comissao / Vigência"                             OF oDlgPer COLOR  0, 16777215 PIXEL
    @ 045, 007 SAY oPerc                   PROMPT "Percentual"    SIZE 037, 012                     OF oDlgPer COLORS 0, 16777215 PIXEL
    @ 045, 047 MSGET oGet5     VAR nGet5                          SIZE 025, 012                     OF oDlgPer COLORS 0, 16777215 PICTURE "@E 99.99" PIXEL
    @ 045, 086 SAY oDate1                  PROMPT "Datainicial"   SIZE 037, 012                     OF oDlgPer COLORS 0, 16777215 PIXEL
    @ 045, 125 MSGET oGet6     VAR dGet6                          SIZE 040, 012                     OF oDlgPer COLORS 0, 16777215 PIXEL
    @ 045, 169 SAY oDate2                  PROMPT "Datafinal"     SIZE 037, 012                     OF oDlgPer COLORS 0, 16777215 PIXEL
    @ 045, 207 MSGET oGet7     VAR dGet7                          SIZE 040, 012                     OF oDlgPer COLORS 0, 16777215 PIXEL
    @ 070, 225 BUTTON Confirma             PROMPT "Confirmar"     SIZE 037, 012 Action Confirma()   OF oDlgPer                    PIXEL
    @ 070, 175 BUTTON Cancela              PROMPT "Cancelar"      SIZE 037, 012 Action Cancela()    OF oDlgPer                    PIXEL

  ACTIVATE MSDIALOG oDlgPer CENTERED

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATE053  ºAutor  ³Júlio Soares        º Data ³  07/30/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Confirma a alteração                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico empresa - ARCOLOR                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Confirma()

dbSelectArea("SZ6TRA")
//dbSetOrder(IndexOrd(_cInd1))
dbSetOrder(1)
If dbseek(SZ6TRA->(Z6_REPRES)+SZ6TRA->(Z6_GRPPRO)+SZ6TRA->(Z6_PRODUT))
	_cRepre := (SZ6TRA->(Z6_REPRES))
	_cNomRe := (SZ6TRA->(Z6_NOMERE))
	RecLock("SZ6TRA",.F.)
		SZ6TRA->(Z6_OK)     := _cMark1
		SZ6TRA->(Z6_REPRES) := _cRepre
		SZ6TRA->(Z6_NOMERE) := _cNomRe
		SZ6TRA->(Z6_GRPPRO) := SZ6->(Z6_GRPPRO)
		SZ6TRA->(Z6_DESCGR) := SZ6->(Z6_DESCGR)
		SZ6TRA->(Z6_PRODUT) := SZ6->(Z6_PRODUT)
		SZ6TRA->(Z6_DESCPR) := SZ6->(Z6_DESCPR)
		SZ6TRA->(Z6_PERC)   := (nGet5)
		SZ6TRA->(Z6_DTINI)  := (dGet6)
		SZ6TRA->(Z6_DTFIM)  := (dGet7)
	SZ6TRA->(MsUnlock())
EndIf
Close(oDlgPer)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATE053  ºAutor  ³Júlio Soares        º Data ³  07/30/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cancela a alteração                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico empresa - ARCOLOR                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

// - CANCELAMENTO DA ALTERAÇÃO
Static Function Cancela()
	Close(oDlgPer)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATE053  ºAutor  ³Júlio Soares        º Data ³  07/30/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina criada para realizar a gravação condicional das     º±±
±±º          ³ regras selecionadas na get.                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico empresa - ARCOLOR                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function _oConfirm()

Local _nCont1 := 0
Local _nCont2 := 0

dbSelectArea("SZ6TRA")
//dbSetOrder(IndexOrd(_cInd1))
dbSetOrder(1)
SZ6TRA->(dbGoTop())
While !(SZ6TRA->(EOF()))
	If !Empty(SZ6TRA->(Z6_OK))
		_cOk     := SZ6TRA->(Z6_OK)
		_cRepres := SZ6TRA->(Z6_REPRES)
		_cNomre  := SZ6TRA->(Z6_NOMERE)
		_cGrppro := SZ6TRA->(Z6_GRPPRO)
		_cDescgr := SZ6TRA->(Z6_DESCGR)
		_cProdut := SZ6TRA->(Z6_PRODUT)
		_cDescpr := SZ6TRA->(Z6_DESCPR)
		_nPerc   := SZ6TRA->(Z6_PERC)
		_dDtini  := SZ6TRA->(Z6_DTINI)
		_dDtfim  := SZ6TRA->(Z6_DTFIM)
		dbSelectArea("SZ6")
		dbSetOrder(1)
		If dbSeek(xFilial("SZ6")+_cRepres+_cGrppro+_cProdut) .And. !Empty(_cOk)
			RecLock("SZ6",.F.)
				SZ6->(Z6_REPRES) := _cRepres
				SZ6->(Z6_NOMERE) := _cNomre
				SZ6->(Z6_GRPPRO) := _cGrppro
				SZ6->(Z6_DESCGR) := _cDescgr
				SZ6->(Z6_PRODUT) := _cProdut
				SZ6->(Z6_DESCPR) := _cDescpr
				SZ6->(Z6_PERC)   := _nPerc
				SZ6->(Z6_DTINI)  := _dDtini
				SZ6->(Z6_DTFIM)  := _dDtfim
			SZ6->(MsUnlock())
			_nCont1 ++
		ElseIf !Empty(_cOk)
			RecLock("SZ6",.T.)
				SZ6->(Z6_REPRES) := _cRepres
				SZ6->(Z6_NOMERE) := _cNomre
				SZ6->(Z6_GRPPRO) := _cGrppro
				SZ6->(Z6_DESCGR) := _cDescgr
				SZ6->(Z6_PRODUT) := _cProdut
				SZ6->(Z6_DESCPR) := _cDescpr
				SZ6->(Z6_PERC)   := _nPerc
				SZ6->(Z6_DTINI)  := _dDtini
				SZ6->(Z6_DTFIM)  := _dDtfim
			SZ6->(MsUnlock())
			_nCont2 ++
		EndIf
		SZ6TRA->(dbSkip())
	Else 
		SZ6TRA->(dbSkip())
	EndIf
EndDo
Close(oDlg)
MSGBOX("FORAM ALTERADOS [" + cValtoChar(_nCont1) + "] CADASTROS E INCLUIDOS [" + cValtoChar(_nCont2) + "] CADASTROS",_cRotina + '_003','INFO')
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATE053  ºAutor  ³Júlio Soares        º Data ³  07/30/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina e cancelamento                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico empresa - ARCOLOR                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function _oCalcel()
	Close(oDlg)
Return()

Static Function marktds(cMarca)


dbSelectArea("SZ6TRA")
while !SZ6TRA->(EOF())

if empty(_cMark1)
	RecLock("SZ6TRA", .F.)
	SZ6TRA->Z6_OK :="xx"
	SZ6TRA->(MsUnLock())
	SZ6TRA->(dbSkip())

Else

	RecLock("SZ6TRA", .F.)
	SZ6TRA->Z6_OK :=""
	SZ6TRA->(MsUnLock())
	SZ6TRA->(dbSkip())

Endif 
	
lOOP
EndDo
SZ6TRA->(dbGoTop())
//oMark1:Refresh()

//Inclusão - Fernando Bombardi - 14/04/23
_oMARK1:oBrowse:Refresh()
//Fim Inclusão - Fernando Bombardi - 14/04/23
Return(.T.)
