#Include "Rwmake.ch"
#Include "Protheus.Ch"
#Include "TOTVS.Ch"
/*/{Protheus.doc} RFATG001
@description Rotina de gatilhos utilizados na tela de  conferência das ordens de separação em tela (Específico para a empresa Arcolor - CD Control).
@author Diego Rodrigues Pereira (ALL System Solutions)
@since 22/02/2023
@version 1.0
@type function
@see https://allss.com.br
/*/


//Gatilho para preenchimento do campo B1_DESC(Descrição)
User Function RFATG001()

Local aArea		:= GetArea()  
Local nPosDesc  := ""
Local _cProd	:= ""
Local _cRet     := .T.
    If funname() == "RFATA002"
        nPosDesc  := aScan(aHeader,{|x|Alltrim(x[2])=="CB9_PROD"})
        _cProd	:= ACOLS[N][1]
        _cRet     := .T.

            DbSelectArea("SB1")
            SB1->(dbSetOrder(1))
            SB1->(dbSeek(xFilial("SB1")+_cProd))
            If Found()
                M->B1_DESC  := SB1->B1_DESC
            Endif
    EndIF
RestArea(aArea)
Return(_cRet)

//Gatilho para preenchimento do campo CB9_LOCAL(Armazem)
User Function RFATG002()

Local aArea		:= GetArea()  

Local nPosDesc  := aScan(aHeader,{|x|Alltrim(x[2])=="CB9_PROD"})
Local _cProd	:= ACOLS[N][nPosDesc]
Local _cRet     := .T.
If funname() == "RFATA002"
    DbSelectArea("SB2")
	SB2->(dbSetOrder(1))
	SB2->(dbSeek(xFilial("SB2")+_cProd))
    If Found()
        M->CB9_LOCAL  := "01"
    Endif
EndIF
RestArea(aArea)
Return(_cRet)

//Gatilho para preenchimento do campo CB9_LOCAL(Endereço)
User Function RFATG003()

Local aArea		:= GetArea()  

Local nPosDesc  := aScan(aHeader,{|x|Alltrim(x[2])=="CB9_PROD"})
Local _cProd	:= ACOLS[N][nPosDesc]
Local _cRet     := .T.
If funname() == "RFATA002"
    DbSelectArea("CBJ")
	CBJ->(dbSetOrder(1))
	CBJ->(dbSeek(xFilial("CBJ")+_cProd))
    If Found()
        M->CB9_LCALIZ  := CBJ->CBJ_ENDERE
    Endif
EndIF
RestArea(aArea)
Return(_cRet)
