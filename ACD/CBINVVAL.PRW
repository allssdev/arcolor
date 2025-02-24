User function CBINVVAL()


Local _aArea    := GetArea()
Local _aAreaSB1 := SB1->(GetArea())
Local _lRet      := .T.
//Local _cEtiqprod := cEtiqprod //variavel da etiqueta lida
//aprodend[1][1] - varialvel do produto lido
//cTipID: EAN8OU13 - tipo do codigo de barras
//cLocalAux - variavel do armazem

dbSelectArea("SB1")
SB1->(dbSetOrder(5)) //B1_FILIAL+B1_CODBAR
If !SB1->(MsSeek(xFilial("SB1")+cEtiqprod,.T.,.F.))
    VTAlert("Utilize o código barras unitário","Alerta",.T.)
    _lRet  := .F.
endif

RestArea(_aAreaSB1)
RestArea(_aArea)

Return _lRet
