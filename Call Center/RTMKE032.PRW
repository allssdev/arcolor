#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RTMKE032  ºAutor  ³Anderson C. P. Coelho º Data ³  21/10/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina utilizada para que o código do fator e o próprio    º±±
±±º          ³fator (tabela SZA) sejam alimentados quando da digitação dosº±±
±±º          ³descontos 1, 2, 3 e 4 nos itens do pedido Call Center.      º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico para a empresa Arcolor.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RTMKE032()

Local _cRotina  := "RTMKE032"
Local _aSavArea := GetArea()
Local _lValid   := .T.
Local _cRvBkp   := __ReadVar
Local _ContRvBk := &(__ReadVar)
Local _cRet     := ""
Local _cDesc    := ""
Local _nPDesc1  := aScan(aHeader, { |x| AllTrim(x[02]) == "UB_DESCTV1" })
Local _nPDesc2  := aScan(aHeader, { |x| AllTrim(x[02]) == "UB_DESCTV2" })
Local _nPDesc3  := aScan(aHeader, { |x| AllTrim(x[02]) == "UB_DESCTV3" })
Local _nPDesc4  := aScan(aHeader, { |x| AllTrim(x[02]) == "UB_DESCTV4" })
Local _nPCFat   := aScan(aHeader, { |x| AllTrim(x[02]) == "UB_CODFATR" })
Local _nPFator  := aScan(aHeader, { |x| AllTrim(x[02]) == "UB_FATOR"   })
Local _nPDesc   := aScan(aHeader, { |x| AllTrim(x[02]) == "UB_DESC"    })

dbSelectArea("SZA")
SZA->(dbOrderNickName("ZA_DESC1"))		//ZA_FILIAL+STR(ZA_DESC1)+STR(ZA_DESC2)+STR(ZA_DESC3)+STR(ZA_DESC4)+ZA_MSBLQL
If SZA->(MsSeek(xFilial("SZA") + Padr(AllTrim(Str(aCols[n][_nPDesc1])),TamSx3("ZA_DESC1")[01]) + Padr(AllTrim(Str(aCols[n][_nPDesc2])),TamSx3("ZA_DESC2")[01]) + Padr(AllTrim(Str(aCols[n][_nPDesc3])),TamSx3("ZA_DESC3")[01]) + Padr(AllTrim(Str(aCols[n][_nPDesc4])),TamSx3("ZA_DESC4")[01]) + "2"))
	aCols[n][_nPCFat ] := _cRet             := SZA->ZA_CODIGO
	aCols[n][_nPFator] := aCols[n][_nPDesc] := SZA->ZA_FATOR
ElseIf SZA->(MsSeek(xFilial("SZA") + Padr(AllTrim(Str(aCols[n][_nPDesc1])),TamSx3("ZA_DESC1")[01]) + Padr(AllTrim(Str(aCols[n][_nPDesc2])),TamSx3("ZA_DESC2")[01]) + Padr(AllTrim(Str(aCols[n][_nPDesc3])),TamSx3("ZA_DESC3")[01]) + Padr(AllTrim(Str(aCols[n][_nPDesc4])),TamSx3("ZA_DESC4")[01]) + " "))
	aCols[n][_nPCFat ] := _cRet             := SZA->ZA_CODIGO
	aCols[n][_nPFator] := aCols[n][_nPDesc] := SZA->ZA_FATOR
Else
	aCols[n][_nPCFat ] := _cRet             := CriaVar("UB_CODFATR")
	aCols[n][_nPFator] := aCols[n][_nPDesc] := 0
EndIf
If ExistBlock("RTMKE010")
	ExecBlock("RTMKE010")
EndIf

__ReadVar    := _cRvBkp
&(__ReadVar) := _ContRvBk

RestArea(_aSavArea)

Return(_cRet)
