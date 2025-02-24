#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RFATE047  ºAutor  ³ Júlio Soares       º Data ³  27/05/14  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Execblock utilizado para preencher automaticamente o nome  º±±
±±º          ³ central referente ao CNPJ central.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico ARCOLOR                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFATE047()

Local _cNome := ""

_cSel := " SELECT A1_CGCCENT,A1_NOMECGC[NOMECGC],SUBSTRING(A1_NOME,1,45)[NOME] "
_cSel += " FROM " + RetSqlName("SA1") + " SA1 "
_cSel += " WHERE SA1.D_E_L_E_T_ = '' "
_cSel += " AND SA1.A1_FILIAL  = '" + xFilial("SA1") + "' "
_cSel += " AND SA1.A1_CGCCENT = '" + (M->A1_CGCCENT) + "' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cSel),"TMPCGC",.F.,.T.)

dbSelectArea("TMPCGC")

If TMPCGC->(!EOF())
	If !Empty (TMPCGC->(NOMECGC))
		_cNome := (ALLTRIM(TMPCGC->(NOMECGC)))
	Else
		_cNome := (ALLTRIM(TMPCGC->(NOME)))
	EndIf
EndIf

dbSelectArea("TMPCGC")
dbCloseArea()

Return(_cNome)