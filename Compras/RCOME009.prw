#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          º Autor ³ Adriano Leonardo   º Data ³  21/01/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Execblock utilizado para disparar os gatilhos do campo     º±±
±±º          ³ C7_PRECO (preço unitário do pedido de compras), quando for º±±
±±º          ³ utilizado o preço unitário na segunda unidade de medida.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function RCOME009()

//Salvo a àrea atual
Local _aSavArea := GetArea()  
Local _aSavSX3	:= SX3->(GetArea())
Local _cAliasSX3    := GetNextAlias()
//Resgato as posições dos campos no aCols
Local _nPreco    := aScan(aHeader,{|x|AllTrim(Upper(x[02]))=="C7_PRECO" })
Local _nPreco2   := aScan(aHeader,{|x|AllTrim(Upper(x[02]))=="C7_PRECO2"})

//Armazedo o backup do __ReadVar
Local _cReadVBk := ReadVar()
Local _cContBk  := &(ReadVar())

//Disparo os gatilhos do campo C7_PRECO, lembrando que neste momento o campo já foi preenchido por gatilho no campo C7_PRECO2
__ReadVar     := "M->C7_PRECO"
&(__ReadVar)  := aCols[n][_nPreco]
If ExistTrigger(SubStr(__ReadVar,4))

OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)		//OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.T.,,.F.,.F.)		
dbSelectArea(_cAliasSX3)
if Select(_cAliasSX3) <= 0
	SX3->(dbSetOrder(2))
	If SX3->(MsSeek("C7_PRECO",.T.,.F.))
		RunTrigger(2,n)
		EvalTrigger()
	EndIf
EndIf
EndIf

//Atualiza o aCols com o conteúdo da variável de memória
aCols[n,_nPreco ] := M->C7_PRECO
aCols[n,_nPreco2] := M->C7_PRECO2

//Restauro o __ReadVar original
__ReadVar         := _cReadVBk
&(__ReadVar)      := _cContBk

//Restauro as áreas selecionadas
RestArea(_aSavSX3)
RestArea(_aSavArea)

Return()