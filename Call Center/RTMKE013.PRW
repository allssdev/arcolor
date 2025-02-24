#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RTMKE013  ºAutor  ³Júlio Soares        º Data ³  29/08/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Execblock criado para atualizar o desconto final conforme asº±±
±±º          ³regras de desconto utilizada.                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico para a empresa Arcolor.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RTMKE013()

Local _aSavArea := GetArea()
Local _cRotina  := "RTMKE013"
Local _nAux     := 100
Local nDesc1    := aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCTV1"})
Local nDesc2    := aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCTV2"})
Local nDesc3    := aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCTV3"})
Local nDesc4    := aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCTV4"})

dbSelectArea("SUB")
_aSavSUB := SUB->(GetArea())

If (aCols[n][nDesc1]) > 0
	_nAux := _nAux - (_nAux * (aCols[n][nDesc1])/100) 
EndIf
_nFator := (100 - _nAux)

If (aCols[n][nDesc2]) > 0
	_nAux := _nAux - (_nAux * (aCols[n][nDesc2])/100) 
EndIf
_nFator := (100 - _nAux)

If (aCols[n][nDesc3]) > 0
	_nAux := _nAux - (_nAux * (aCols[n][nDesc3])/100) 
EndIf
_nFator := (100 - _nAux) 	

If (aCols[n][nDesc4]) > 0
	_nAux := _nAux - (_nAux * (aCols[n][nDesc4])/100) 
EndIf
_nFator := (100 - _nAux)

RestArea(_aSavSUB )
RestArea(_aSavArea)

Return(_nFator)