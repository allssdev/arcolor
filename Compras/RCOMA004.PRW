#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RCOMA004  ºAutor  ³Arthur Silva		   º Data ³  07/05/18 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina Desenvolvida para alteração da data de entrega do   º±±
±±º          ³Pedido Compras.									          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 12 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RCOMA004()

Local _aSavArea := GetArea()
Local _aSavSC7  := SC7->(GetArea())
Local _cPedido  := SC7->C7_NUM
Local _cItem    := SC7->C7_ITEM
Local _cProduto := SC7->C7_PRODUTO
Local oGetv1
Local oGroupv1
Local oSayv1
Local oSButtonv1
Local oSButtonv2

Private _dData 	 := STOD("")
Private _cRotina := "RCOMA004"

static oDlgv

  DEFINE MSDIALOG oDlgv TITLE "NOVA DATA ENTREGA"          FROM 000, 000 TO 130, 240                                             COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME

    @ 007, 003 GROUP   oGroupv1 TO 058, 116 PROMPT " Informe a Nova Data de Entrega" OF oDlgv                             	COLOR  0, 16777215 PIXEL
    @ 021, 005   SAY   oSayv1 				PROMPT "Data Entrega:"   SIZE 037, 007 OF oDlgv                                                	COLORS 0, 16777215 PIXEL
    @ 019, 045 MSGET   oGetv1   VAR _dData  SIZE 070, 010 OF oDlgv PICTURE PesqPict("SC7","C7_ANTEPRO")           VALID NAOVAZIO()  COLORS 0, 16777215 PIXEL

//    DEFINE SBUTTON oSButtonv1 PROMPT 	"OK"   		FROM 039, 048 TYPE 01 OF oDlgv ENABLE ACTION IIF(MsgYesNo("Confirma a Data? " + _dData ,_cRotina+"_001"),Close(oDlgv),NIL)
//    DEFINE SBUTTON oSButtonv2 PROMPT 	"Cancelar"  FROM 045, 053 TYPE 01 OF oDlgv ENABLE ACTION Close(oDlgv) OF oDlgv 								PIXEL

	    DEFINE SBUTTON oSButtonv1 FROM 040, 025 TYPE 01 OF oDlgv ENABLE Action EVAL({|| _lRet := .T., oDlgv:End()})
	    DEFINE SBUTTON oSButtonv2 FROM 040, 070 TYPE 02 OF oDlgv ENABLE Action EVAL({|| _lRet := .F., oDlgv:End()})

  ACTIVATE MSDIALOG oDlgv CENTERED
  
If !Empty(_dData) .and. _lRet 
	If MsgYesNo("Deseja realmente alterar a Data de Entrega para : "+DTOC(_dData)+" ?",_cRotina+"_001")
		dbSelectArea("SC7")
		SC7->(dbSetOrder(4))
		If	SC7->(MsSeek(xFilial("SC7") + _cProduto+_cPedido+_cItem,.T.,.F.)) //C7_FILIAL+C7_PRODUTO+C7_NUM+C7_ITEM+C7_SEQUEN
				RecLock("SC7",.F.)
					C7_ANTEPRO := _dData
				SC7->(MsUnLock())
			MsgInfo("Ajuste Realizado com Sucesso!!!",_cRotina+"_002")
		EndIf
	EndIf
EndIf


RestArea(_aSavSC7)
RestArea(_aSavArea)

Return