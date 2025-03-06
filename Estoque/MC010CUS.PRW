#include 'totvs.ch'
#include 'parmtype.ch'

User Function MC010CUS()

Local cProd:= PARAMIXB[1]
Local nCusPad := PARAMIXB[2]
Local nRet := IIf(cArqMemo = "STANDARD",SB1->B1_CUSTD,SB1->B1_UPRC)

If cArqMemo = "PRECO_FUTURO"
    nRet := SB1->B1_FATLUC
Endif

Return(nRet)
