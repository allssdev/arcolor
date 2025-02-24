#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RGPEE003  ºAutor  ³Microsiga          º Data ³  06/07/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Execblock criado para atualizar automaticamente os campos  º±±
±±º          ³ do cadastro de fornecedor com base e informações do        º±±
±±º          ³ funcionário.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico empresa ARCOLOR                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RGPEE003(_var)

Local _aSavArea := GetArea()
Local _aSavSRA  := SRA->(GetArea())
Local _cRet     := ""

dbSelectArea("SRA")
dbSetOrder(1)
If MsSeek(xFilial("SRA")+ M->(A2_MATFUNC),.F.,.T.)
	If _Var == "CPF"                       	
		_cRet := SRA->(RA_CIC)
	ElseIf _Var == "END"
		_cRet := Alltrim(SRA->(RA_ENDEREC)) + ", " + SRA->(RA_NUMERO)
	ElseIf _Var == "RAZ"
		_cRet := Alltrim(SRA->(RA_NOME))
	ElseIf _Var == "BAI"
		_cRet := Alltrim(SRA->(RA_BAIRRO))
	ElseIf _Var == "EST"
		_cRet := Alltrim(SRA->(RA_ESTADO))
	ElseIf _Var == "CMN"
		_cRet := SRA->(RA_CODMUN)
	ElseIf _Var == "MUN"
		_cRet := Alltrim(SRA->(RA_MUNICIP))
	ElseIf _Var == "CID"
		_cRet := Alltrim(SRA->(RA_NOME))
	ElseIf _Var == "PAI"
		_cRet := SRA->(RA_CPAISOR)
	ElseIf _Var == "CEP"
		_cRet := SRA->(RA_CEP)
	ElseIf _Var == "TEL"
		_cRet := SRA->(RA_TELEFON)
	EndIf
Else
	MSGBOX("Matricula do funcionário não encontrado. Verifique.","RGPEE003_001","ALERT")
EndIf

RestArea(_aSavSRA)
RestArea(_aSavArea)

Return(_cRet)