#INCLUDE "RWMAKE.CH"
#include "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RTMKE008  ºAutor  ³Alessandro Villar   º Data ³ 02/01/12    º±±
±±º          ³          ºAutor  ³Júlio Soares        º Data ³ 24/07/14    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ EXECBLOCK  para que não seja permitida a digitação de      º±±
±±º          ³ quantidade que esteja fora do múltiplo definido no referidoº±±
±±º          ³ campo no cadastro de produtos.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Melhoria da rotina implementada na validação do tipo de    º±±
±±º          ³ operação.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RTMKE008()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de Variáveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _aSavAr  := GetArea()
Local _nMultip := 0
Local _lRet    := .T.
Local _nPQtde  := aScan(aHeader,{|x|AllTrim(x[02])==IIF(AllTrim(FUNNAME())=="MATA410","C6_QTDVEN" ,"UB_QUANT"  )})
Local _nPProd  := aScan(aHeader,{|x|AllTrim(x[02])==IIF(AllTrim(FUNNAME())=="MATA410","C6_PRODUTO","UB_PRODUTO")})
Local _cRotina := "RTMKE008"
Local _cTpOper := AllTrim(SuperGetMV("MV_FATOPER",,"01|ZZ|9")) // - Informa os tipos de operações que compoe o faturamento

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Início da Rotina                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB1")
_aSavSB1 := SB1->(GetArea())
SB1->(dbSetOrder(1))
If M->UA_TPOPER $ ("|"+_cTpOper+"|")
	If MsSeek(xFilial("SB1") + aCols[n][_nPProd],.T.,.F.)
		_nMultip := SB1->B1_QTMULT
		If (aCols[n][_nPQtde] % _nMultip)<>0	// Retorna o resto da divisão do valor _cProd pelo _nMultip
			MsgAlert("Valor não é múltiplo, verifique no cadastro! O multiplo para o produto " + aCols[n][_nPProd] + " é de " + cValToChar(_nMultip) + ".",_cRotina+"_01 [B1_QTMULT]")
			_lRet:= .F.
		EndIf
	EndIf
EndIf

RestArea(_aSavSB1)
RestArea(_aSavAr)

Return(_lRet)