#include 'parmtype.ch'
#include "totvs.ch"
/*/{Protheus.doc} MA410MNU
@description Ponto de entrada para adicionar botões no browse do pedido de vendas. Utilizado para retirar o botão "Prep.Doc.Saida".
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 16/01/2013
@version 2.0
@history 25/09/2020, Anderson C. P. Coelho (ALLSS Soluções em Sistemas), aRotina mantido retornado para o padrão do sistema, mantendo-se somente a chamada da tecla de atalho CTRL+F9 já existente (inclive no aRotina), para consulta ao log do pedido.
@type function
@see https://allss.com.br
/*/
user function MA410MNU()
	local   _nPos    := 0
	local   _cRotina := "MA410MNU"
	if !empty(FunName())
		//Desativo a rotina "MA410PVNFS" e coloco a "RFATL001" no lugar
		if (_nPos := aScan(aRotina, {|x| valtype(x[2])=="C" .AND. AllTrim(UPPER(x[2])) == "MA410PVNFS"})) > 0
			//Ativo a rotina "RFATL001" de log dos pedidos de vendas, desativando a "Prep. Doc. Saída" ("MA410PVNFS").
			if ExistBlock("RFATL001")
				SetKey( K_CTRL_F9, { || })
				SetKey( K_CTRL_F9, { || U_RFATL001(SC5->C5_NUM,POSICIONE('SUA',8,xFilial('SUA')+SC5->C5_NUM,'UA_NUM'),'',"MA410MNU",)})
				aRotina[_nPos][1] := "Logs do Pedido"
				aRotina[_nPos][2] := "U_RFATL001(SC5->C5_NUM,POSICIONE('SUA',8,xFilial('SUA')+SC5->C5_NUM,'UA_NUM'),'','"+_cRotina+"',)"
				aRotina[_nPos][3] := 0
				aRotina[_nPos][4] := 6
				aRotina[_nPos][5] := 0
				aRotina[_nPos][6] := nil
			//Desativo a rotina "Prep. Doc. Saída" ("MA410PVNFS").
			else
				aRotina[_nPos][2] := ""
			endif
		//Ativo a rotina "RFATL001" de log dos pedidos de vendas.
		elseif ExistBlock("RFATL001")
			SetKey( K_CTRL_F9, { || })
			SetKey( K_CTRL_F9, { || U_RFATL001(SC5->C5_NUM,POSICIONE('SUA',8,xFilial('SUA')+SC5->C5_NUM,'UA_NUM'),'',"MA410MNU",)})
			AAdd(aRotina,{"Logs do Pedido","U_RFATL001(SC5->C5_NUM,POSICIONE('SUA',8,xFilial('SUA')+SC5->C5_NUM,'UA_NUM'),'','"+_cRotina+"',)" ,0,6,0 ,NIL})
		endif
		//Ativo a rotina "RFATE031" de alteração de clientes.
		if ExistBlock("RFATE031")
			AAdd(aRotina,{"Altera Cliente","U_RFATE031()" ,0,6,0 ,NIL})
		endif
	endif
return