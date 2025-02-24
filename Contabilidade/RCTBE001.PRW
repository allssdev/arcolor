#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RCTBE001  ºAutor  ³Anderson C. P. Coelho º Data ³  08/12/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Execblock utilizado para, quando o TES não atualizar       º±±
±±º          ³estoque, nos casos de devolução de vendas, que o sistema    º±±
±±º          ³busque o custo do documento original (de saída), amarrado a º±±
±±º          ³respectiva devolução.                                       º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico para a empresa Arcolor.            º±±
±±º          ³ Utilizado na contabilização dos Documentos de Entrada.     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RCTBE001(_cCpo)

Local _cRotina  := "RCTBE001"
Local _aSavArea := GetArea()
Local _aSavSD1  := {}
Local _aSavSD2  := {}
Local _aSavSF4  := {}
Local _nRet     := 0

Default _cCpo   := "SD1->D1_CUSTO"

dbSelectArea("SF4")
_aSavSF4 := SF4->(GetArea())
dbSelectArea("SD1")
_aSavSD1 := SD1->(GetArea())
dbSelectArea("SD2")
_aSavSD2 := SD2->(GetArea())
_nRet    := &(_cCpo)
If _nRet == 0
	dbSelectArea("SD2")
	SD2->(dbSetOrder(3))
	If SD2->(MsSeek(xFilial("SD2") + ;
					Padr(SD1->D1_NFORI  ,TamSx3("D2_DOC"    )[01]) + ;
					Padr(SD1->D1_SERIORI,TamSx3("D2_SERIE"  )[01]) + ;
					Padr(SD1->D1_FORNECE,TamSx3("D2_CLIENTE")[01]) + ;
					Padr(SD1->D1_LOJA   ,TamSx3("D2_LOJA"   )[01]) + ;
					Padr(SD1->D1_COD    ,TamSx3("D2_COD"    )[01]) + ;
					Padr(SD1->D1_ITEMORI,TamSx3("D2_ITEM"   )[01]), .T., .F.) )
		If AllTrim(_cCpo) == "SD1->D1_CUSTO"
			_nRet := (SD2->D2_CUSTO1 / SD2->D2_QUANT) * SD1->D1_QUANT
		Else
			_nRet := &(StrTran(_cCpo,"1","2"))
		EndIf
		If _nRet == 0 .AND. SubStr(SD1->D1_CF,2,3)$"/915/916/"
			_nRet := SD1->D1_TOTAL
		EndIf
	EndIf
EndIf

RestArea(_aSavSD1)
RestArea(_aSavSD2)
RestArea(_aSavSF4)
RestArea(_aSavArea)

Return(_nRet)
