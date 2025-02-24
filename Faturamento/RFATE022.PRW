#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATE022  º Autor ³Anderson C. P. Coelho º Data ³  19/03/13 º±±
±±º           Alteração º Autor ³Adriano Leonardo      º Data ³  07/06/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Execblock utilizado para calcular o fator do desconto      º±±
±±º          ³líquido a ser aplicado nas regras de desconto do sistema.   º±±
±±º          ³Utilizado por meio de gatilho.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RFATE022()

Local _nAux	   := 100
/*
Local _nDesc1  := aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCTV1"})
Local _nDesc2  := aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCTV2"})
Local _nDesc3  := aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCTV3"})
Local _nDesc4  := aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCTV4"})
*/
//Trecho original
For _x := 1 To 4
	If &("M->ZA_DESC"+cValToChar(_x)) > 0
		_nAux := _nAux - (_nAux * (&("M->ZA_DESC"+cValToChar(_x))/100))
 	EndIf
 	_nFator := (100 - _nAux)
Next

Return(_nFator)

// - Return(_nFator)

/*
--Trecho comentado por Adriano Leonardo em 07/06/2013 - correção de erro
Local _nPreco  := _nPrcFim := 1

For _x := 1 To 4
	If &("M->ZA_DESC"+cValToChar(_x)) > 0
		_nPrcFim := NoRound(_nPrcFim * (1-(&("M->ZA_DESC"+cValToChar(_x))/100)),TamSx3("D2_DESCONT")[02])
	EndIf
Next
_nFator := (1 - (_nPrcFim/_nPreco)) * 100
*/           

/*
_nDesc1 := (_nPreco * (M->ZA_DESC1/100))
_nDesc2 := ((_nPreco-_nDesc1) * (M->ZA_DESC2/100))
_nDesc3 := ((_nPreco-_nDesc1-_nDesc2) * (M->ZA_DESC3/100))
_nDesc4 := ((_nPreco-_nDesc1-_nDesc2-_nDesc3) * (M->ZA_DESC4/100))
_nFator := (_nDesc1+_nDesc2+_nDesc3+_nDesc4) / _nPreco

Return(_nFator)
*/