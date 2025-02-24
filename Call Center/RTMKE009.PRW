#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RTMKE009  ºAutor  ³Anderson C. P. Coelho º Data ³  22/03/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Execblock utilizado para validar se um item já foi         º±±
±±º          ³informado no atendimento ou não.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RTMKE009()

Local _aSavArea := GetArea()
Local _cRotina  := "RTMKE009"
Local _nPItem   := aScan(aHeader,{|x|AllTrim(x[02])=="UB_ITEM"   })
Local _nPProd   := aScan(aHeader,{|x|AllTrim(x[02])=="UB_PRODUTO"})
Local _nPTes    := aScan(aHeader,{|x|AllTrim(x[02])=="UB_TES"    })
Local _cProd    := IIF(__ReadVar=="M->UB_PRODUTO",M->UB_PRODUTO,aCols[n][_nPProd])
Local _nLItem   := aScan(aCols,{|x| x[_nPProd] == _cProd .AND. x[_nPItem] <> aCols[n][_nPItem] .AND. !x[Len(aHeader)+1]})	//Os itens deletados estão sendo considerados nesta validação! Se esta validação foi ativada, deverá ser analisado o caso de desdeleção manual do item.
Local _nLTes    := aScan(aCols,{|x| x[_nPProd] == _cProd .AND. x[_nPTes ] <> aCols[n][_nPTes ] .AND. !x[Len(aHeader)+1]})
Local _lRet     := aCols[n][Len(aHeader)+1] .OR. (_nLItem == 0 .And. _nLTes==0)

If !_lRet
	MsgAlert("Atenção! O produto " + AllTrim(_cProd) + " selecionado já foi informado neste atendimento no item '" + aCols[_nLItem][_nPItem] + "'. Operação não permitida!",_cRotina+"_001")
EndIf

RestArea(_aSavArea)

Return(_lRet)