#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RTMKE011  ºAutor  ³Alessandro Villar   º Data ³  26/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Execblock utilizado em gatilho para atualizar o campo de    º±±
±±º          ³desconto padrão do sistema atraves do resultado do fator    º±±
±±º          ³descontos.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico para a empresa Arcolor.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RTMKE011()

Local _aSavArea := GetArea()
Local _nPFator  := aScan(aHeader,{|x|AllTrim(x[02])=="UA_FATOR"}) // 14
Local __RVarBkp := __ReadVar  //M->UB_CODFATR
Local _cRVarBkp := &(__ReadVar)
Local _lValid   := .T.

__ReadVar    := "M->UA_DESC"
&(__ReadVar) := aCols[n][_nPFator]
_nFator      := aCols[n][_nPFator]


_cAliasSX3 := "SX3_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
dbSelectArea(_cAliasSX3)
(_cAliasSX3)->(dbSetOrder(2))
If (_cAliasSX3)->(MsSeek(AllTrim(SubStr(__ReadVar,4)),.T.,.F.))
	_lValid := .T.
	If !Empty((_cAliasSX3)->X3_VALID + " " + (_cAliasSX3)->X3_VLDUSER)
		_lValid := &(AllTrim((_cAliasSX3)->X3_VALID)+IIF(!Empty((_cAliasSX3)->X3_VALID).AND.!Empty((_cAliasSX3)->X3_VLDUSER),".AND.","")+AllTrim((_cAliasSX3)->X3_VLDUSER)) //Validação do campo
	EndIf
EndIf
If _lValid .AND. ExistTrigger(SubStr(__ReadVar,4))
	RunTrigger(2,n)
	EvalTrigger()
EndIf
(_cAliasSX3)->(dbCloseArea())
__ReadVar    := __RVarBkp
&(__ReadVar) := _cRVarBkp

RestArea(_aSavArea)

Return(_nFator)