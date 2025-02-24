#include "totvs.ch"
/*/{Protheus.doc} A682CPO
@description Rotina responsavel por montar a enchoice da horas improdutivas
@author  Diego Rodrigues
@since   01/03/2021
@version P12.1.25 - 1.00
@see https://allss.com.br
/*/
//ACD025GR
user function A682CPO()
 
 Local _aSavArea	:= GetArea()
 Local aCampos := PARAMIXB
 Local _aCampos := PARAMIXB

 
If FunName() == "MATA682"
	AADD(_aCampos,"H6_XOP")
	AADD(_aCampos,"H6_XPRODUT")
	AADD(_aCampos,"H6_XDESCRI")
Else
	_aCampos := aCampos // Rotina MATA122 (Autorização Entrega)
EndIf

RestArea(_aSavArea)
return(_aCampos)
