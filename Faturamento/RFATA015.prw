#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ RFATA015 ºAutor  ³ Adriano L. de Souza º Data ³  09/05/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   ³ Execblock responsável pela inclusão da amarração produto x    º±±
±±ºDesc.   ³ cliente.                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso P11  ³ Uso específico Arcolor                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±Í±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function RFATA015()

Local _cRotina 		:= "RFATA015"
Local _aSavArea		:= GetArea()
Local _aSavSA7		:= SA7->(GetArea())
Local _nPosProd		:= aScan(oGetD3:aHeader,{|x|AllTrim(x[02])==("ACN_CODPRO")})
Local _lRet			:= .T.

Private _aProduto 	:= {}
Private _cCliente 	:= M->ACS_CODCLI
Private _cLojaCli 	:= M->ACS_LOJA
Private _cGrpVen	:= M->ACS_GRPVEN
Private _lDesativ	:= .T.

//Rotina desativada (processo abortado)
If _lDesativ
	Return(_lRet)
EndIf

//Avalio se a regra é promocional ou se a posição do produto no aCols não foi localizada
If _nPosProd == 0 .Or. (Empty(_cCliente) .And. Empty(_cLojaCli) .And. Empty(_cGrpVen))
	Return(_lRet)
EndIf
For _nCont := 1 To Len(oGetD3:aCols)
	If aScan(_aProduto,oGetD3:aCols[_nCont][_nPosProd])==0
		AAdd(_aProduto,oGetD3:aCols[_nCont][_nPosProd])
	EndIf
Next
//Avalio se a regra é por cliente, grupo ou geral
If !Empty(_cCliente) .And. !Empty(_cLojaCli)
	For _nCont2 := 1 To Len(_aProduto)
		dbSelectArea("SA7")
		SA7->(dbSetOrder(1))
		If !SA7->(dbSeek(xFilial("SA7") + _cCliente + _cLojaCli + _aProduto[_nCont2]))
			IncluirSA7(_aProduto[_nCont2])
		EndIf
	Next
ElseIf !Empty(_cGrpVen)
	dbSelectArea("SA1")
	SA1->(dbSetOrder(6)) //Filial + Grupo de Vendas
	If SA1->(MsSeek(xFilial("SA1")+_cGrpVen,.T.,.F.))
		While SA1->(!EOF()) .And. xFilial("SA1")==SA1->A1_FILIAL .And. SA1->A1_GRPVEN==_cGrpVen
			_cCliente := SA1->A1_COD
			_cLojaCli := SA1->A1_LOJA
			For _nCont3 := 1 To Len(_aProduto)
				dbSelectArea("SA7")
				SA7->(dbSetOrder(1))
				If !SA7->(dbSeek(xFilial("SA7") + _cCliente + _cLojaCli + _aProduto[_nCont3]))
					IncluirSA7(_aProduto[_nCont3])
				EndIf
			Next
			dbSelectArea("SA1")
			SA1->(dbSetOrder(6))
			SA1->(dbSkip())
		EndDo
	EndIf
EndIf

RestArea(_aSavSA7)
RestArea(_aSavArea)

Return(_lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ RFATA015 ºAutor  ³ Adriano L. de Souza º Data ³  09/05/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   ³ Função responsável pela inclusão de registros na SA7 (produto º±±
±±ºDesc.   ³ x cliente).                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso P11  ³ Uso específico Arcolor                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±Í±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function IncluirSA7(_cCodProd)

Local _aSavTmp := SA7->(GetArea())

dbSelectArea("SA7")
while !RecLock("SA7",.T.) ; enddo
	SA7->A7_FILIAL 	:= xFilial("SA7")
	SA7->A7_CLIENTE := _cCliente
	SA7->A7_LOJA	:= _cLojaCli
	SA7->A7_PRODUTO := _cCodProd
	SA7->A7_AUTORIZ := SuperGetMV("MV_AUTORSA7",,"S") //Comercialização do produto autorizada?
SA7->(MsUnlock())

RestArea(_aSavTmp)

Return()