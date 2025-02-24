#include 'totvs.ch'
#include 'parmtype.ch'

User Function MC010CUS()

Local nRet := SB1->B1_CUSTD
Local cProd:= PARAMIXB[1]
Local nCusPad := PARAMIXB[2]

If cArqMemo = "PRECO_FUTURO"
    nRet := SB1->B1_FATLUC
Endif

Return(nRet)
