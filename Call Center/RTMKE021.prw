#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RTMKE021 º Autor ³Adriano Leonardo      º Data ³  06/02/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Execblock utilizado para calcular o fator do desconto com  º±±
±±º          ³ base nos descontos 1, 2, 3 e 4 do cabeçalho do atendimento.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RTMKE021()

Local _aSavArea := GetArea()
Local _cRotina 	:= "RTMKE021"
Local _nAux	    := 100
Local _nQtdDesc := 4 			//Quantidade de descontos do cabeçalho
Local _lRet		:= .T.
Local _cCampo	:= ""
Local _nDescDiv := 0

If AllTrim(FunName())=="TMKA271" .OR. AllTrim(FunName())=="RTMKI001" .OR. AllTrim(FunName()) == "RPC"
	_cCampo := "M->UA_DESC"
Else
	_cCampo := "M->C5_DESC"
EndIf
//Varre os campos de desconto para calcular o fator de desconto em cascata
For _nCont := 1 To _nQtdDesc
	_cMacro := _cCampo + AllTrim(Str(_nCont))
	//Avalia se o valor do desconto é maior que zero
	If SUA->(FieldPos(SubStr(_cMacro,AT("->",_cMacro)+2)))<>0 .AND. &_cMacro > 0
		_nAux := _nAux - (_nAux * ((&_cMacro)/100))
 	EndIf
 	_nFator := (100 - _nAux)
Next
//Grava o fator de desconto do cabeçalho
If AllTrim(FunName())=="TMKA271" .OR. AllTrim(FunName())=="RTMKI001" .OR. AllTrim(FunName())=="RPC"
	M->UA_FATOR := _nFator
	_cChave := "M->UA_CONDPG"
Else
	_cChave := "M->C5_CONDPAG"
EndIf
dbSelectArea("SE4")
SE4->(dbSetOrder(1))
If SE4->(MsSeek(xFilial("SE4") + &_cChave,.T.,.F.))
	If AllTrim(FunName())=="TMKA271" .OR. AllTrim(FunName())=="RTMKI001" .OR. AllTrim(FunName())=="RPC"
		//Início - Trecho adicionado por Adriano Leonardo - 19/09/2014
		//Selecionando o percentual de desconto por divisão do cadastro do cliente
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1") + M->UA_CLIENTE + M->UA_LOJA,.T.,.F.))
			_nDescDiv := SA1->A1_DESCDIV
		Else
			_nDescDiv := 0
		EndIf
		//Final  - Trecho adicionado por Adriano Leonardo - 19/09/2014
	Else
		//Início - Trecho adicionado por Adriano Leonardo - 19/09/2014
		//Selecionando o percentual de desconto por divisão do cadastro do cliente
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI,.T.,.F.))
			_nDescDiv := SA1->A1_DESCDIV
		Else
			_nDescDiv := 0
		EndIf
		//Final  - Trecho adicionado por Adriano Leonardo - 19/09/2014
	EndIf
	//Calculo o fator de desconto máximo do cabeçalho avaliando o desconto da condição de pagamento e do tipo de de divisão do pedido
	_nDescMax := 100-(100*(SE4->E4_DESCMAX/100))
	_nDescMax := _nDescMax-(_nDescMax*(_nDescDiv/100))
	_nDescMax := 100 - _nDescMax
	If _nFator > _nDescMax
		//_lRet := .F.
		MsgAlert("O fator de desconto informado ultrapassa o permitido para esta Condição de Pagamento x Tipo de Divisão. O pedido será gerado, porém bloqueado por regra!",_cRotina + "_001")
	Else
		//Função padrão que avalia o desconto do cabeçalho
		If AllTrim(FunName())=="TMKA271" .OR. AllTrim(FunName())=="RTMKI001" .OR. AllTrim(FunName())=="RPC"
			TK273DesCab()
		Else
			a410Recalc()
		EndIf
	EndIf
EndIf

RestArea(_aSavArea)

Return(_lRet)