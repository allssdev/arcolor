#Include 'Protheus.ch'
#include 'FWMVCDef.ch'

/*/{Protheus.doc} MT241TOK
@description RPonto de Entrada que Tem a finalidade de ser utilizado como validação da inclusão do movimento pelo usuário
@author  Diego Rodrigues
@since   09/03/2023
@version P12.1.2210 - 1.00
@see https://allss.com.br
@history 09/03/2023,  Diego Rodrigues (diego.rodrigues@allss.com.br), Validação se o produto controla lote não permitir o campo D3_LOTECTL EM BRANCO
/*/


User Function MT241TOK()

Local nX
Local _aSavArea := GetArea()
Local _aSavSB1  := SB1->(GetArea())
Local lRet := .T.
Local nPosCod  := aScan(aHeader,{|x|Alltrim(x[2])=="D3_COD"})
Local nPosLote  := aScan(aHeader,{|x|Alltrim(x[2])=="D3_LOTECTL"})
Local _cProd    := ""
Local _cLote    := ""
Local _UsaLote  := "N"

aCols:= asort(aCols, , , {|x, y| x[4] < y[4]})

for nX := 1 to len(aCols)
    _cProd    := aCols[nX][nPosCod]
    _cLote    := aCols[nX][nPosLote]
    DbSelectArea("SB1")
    DbSetOrder(1)
    If DbSeek(xFilial("SB1") + _cProd)
        If SB1->B1_RASTRO = "L"
            _UsaLote := "S"
        EndIf
    EndIf

    If  _UsaLote == "S" .AND. Empty(_cLote) // Condição de não validação do documento pelo usuário    
        MsgInfo("O produto "+Alltrim(_cProd) + " controla lote. Por gentileza informar o lote","Atenção")
        lRet := .F.
    EndIf
next nX
RestArea(_aSavSB1) 
RestArea(_aSavArea) 
Return lRet
