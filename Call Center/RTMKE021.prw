#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RTMKE021 � Autor �Adriano Leonardo      � Data �  06/02/14 ���
�������������������������������������������������������������������������͹��
���Descricao � Execblock utilizado para calcular o fator do desconto com  ���
���          � base nos descontos 1, 2, 3 e 4 do cabe�alho do atendimento.���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function RTMKE021()

Local _aSavArea := GetArea()
Local _cRotina 	:= "RTMKE021"
Local _nAux	    := 100
Local _nQtdDesc := 4 			//Quantidade de descontos do cabe�alho
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
	//Avalia se o valor do desconto � maior que zero
	If SUA->(FieldPos(SubStr(_cMacro,AT("->",_cMacro)+2)))<>0 .AND. &_cMacro > 0
		_nAux := _nAux - (_nAux * ((&_cMacro)/100))
 	EndIf
 	_nFator := (100 - _nAux)
Next
//Grava o fator de desconto do cabe�alho
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
		//In�cio - Trecho adicionado por Adriano Leonardo - 19/09/2014
		//Selecionando o percentual de desconto por divis�o do cadastro do cliente
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1") + M->UA_CLIENTE + M->UA_LOJA,.T.,.F.))
			_nDescDiv := SA1->A1_DESCDIV
		Else
			_nDescDiv := 0
		EndIf
		//Final  - Trecho adicionado por Adriano Leonardo - 19/09/2014
	Else
		//In�cio - Trecho adicionado por Adriano Leonardo - 19/09/2014
		//Selecionando o percentual de desconto por divis�o do cadastro do cliente
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI,.T.,.F.))
			_nDescDiv := SA1->A1_DESCDIV
		Else
			_nDescDiv := 0
		EndIf
		//Final  - Trecho adicionado por Adriano Leonardo - 19/09/2014
	EndIf
	//Calculo o fator de desconto m�ximo do cabe�alho avaliando o desconto da condi��o de pagamento e do tipo de de divis�o do pedido
	_nDescMax := 100-(100*(SE4->E4_DESCMAX/100))
	_nDescMax := _nDescMax-(_nDescMax*(_nDescDiv/100))
	_nDescMax := 100 - _nDescMax
	If _nFator > _nDescMax
		//_lRet := .F.
		MsgAlert("O fator de desconto informado ultrapassa o permitido para esta Condi��o de Pagamento x Tipo de Divis�o. O pedido ser� gerado, por�m bloqueado por regra!",_cRotina + "_001")
	Else
		//Fun��o padr�o que avalia o desconto do cabe�alho
		If AllTrim(FunName())=="TMKA271" .OR. AllTrim(FunName())=="RTMKI001" .OR. AllTrim(FunName())=="RPC"
			TK273DesCab()
		Else
			a410Recalc()
		EndIf
	EndIf
EndIf

RestArea(_aSavArea)

Return(_lRet)