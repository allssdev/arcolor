#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RTMKE030 ºAutor  ³ Adriano Leonardo    º Data ³ 15/09/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina responsável por disparar o gatilho da TES nos itens º±±
±±º          ³ do atendimento do Call Center, ao se editar os descontos.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor 			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function RTMKE030()
	
Local _aSavArea := GetArea()
Local _aSavSB1	:= SB1->(GetArea())
//Local _aSavSX3	:= (_cAliasSX3)->(GetArea())	
Local __RVarBkp := __ReadVar  //M->UB_CODFATR
Local _cRVarBkp := &(__ReadVar)
Local _cCpoIte	:= IIF(AllTrim(FUNNAME())=="MATA410".OR.AllTrim(FUNNAME())=="RFATA012","C6_","UB_")
Local _nPProd  	:= aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte+"PRODUTO")})
Local _nPTES	:= aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte+"TES"    )})
Local _nPItem	:= aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte+"ITEM"   )})
Local _lRet		:= .T.

Private _cRotina:= "RTMKE030"

__ReadVar := "M->"+_cCpoIte+"TES"
If Empty(aCols[n][_nPTES])
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(xFilial("SB1")+aCols[n][_nPProd],.T.,.F.))
		IF Empty(SB1->B1_TS)
			&(__ReadVar) := aCols[n][_nPTES] := AllTrim(SuperGetMV("MV_TESPAD1",,"999"))
		Else 
			&(__ReadVar) := aCols[n][_nPTES] := SB1->B1_TS
		EndIf
	EndIf
Else 
	&(__ReadVar) := aCols[n][_nPTES]
EndIf

_cAliasSX3 := "SX3_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
dbSelectArea(_cAliasSX3)
(_cAliasSX3)->(dbSetOrder(2))
If (_cAliasSX3)->(MsSeek(AllTrim(SubStr(__ReadVar,AT(">",__ReadVar)+1)),.T.,.F.))
	_cValid := AllTrim((_cAliasSX3)->X3_VALID + IIF(!Empty((_cAliasSX3)->X3_VALID).AND.!Empty((_cAliasSX3)->X3_VLDUSER),".AND."," ") + (_cAliasSX3)->X3_VLDUSER)
	If !Empty(_cValid)
		&_cValid
	EndIf
EndIf
If _lRet .AND. ExistTrigger(AllTrim(SubStr(__ReadVar,AT(">",__ReadVar)+1)))
	RunTrigger(2,n)
	EvalTrigger()
EndIf

__ReadVar    := __RVarBkp
&(__ReadVar) := _cRVarBkp

(_cAliasSX3)->(dbCloseArea())

RestArea(_aSavSB1)
RestArea(_aSavArea)

Return(aCols[n,_nPItem])