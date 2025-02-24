/*/{Protheus.doc} MA270TOK
O ponto de entrada 'MA270TOK' é executado no final da função TUDOOK(), permitido validar os dados informados pelo usuário, quando executado o botão de confirmação.
@author Diego Rodrigues Pereira
@since 08/06/2023
@version 1.0
@type function
@see https://allss.com.br
/*/

User Function MA270TOK

Local lRet := .F.
Local _cDocinv := SuperGetMV("MV_XDOCINV",,"240205")

/*If Funname() == 'ACDV035'
    lRet := .F.
ElseIf  substr(M->B7_DOC,1,3) == '000'
    M->B7_DOC := _cDocinv 
    lRet := .T.
ElseIf Funname()=="MATA270"
    lRet := .T.
EndIf*/

If substr(M->B7_DOC,1,3) == 'ACDV035'
    lRet := .F.
ElseIf  Alltrim(M->B7_TIPO) == 'PA'
    M->B7_DOC := "IPA"+Alltrim(_cDocinv) 
    lRet := .T.
ElseIf  Alltrim(M->B7_TIPO) == 'PI'
    M->B7_DOC := "IPI"+Alltrim(_cDocinv)
    lRet := .T.
ElseIf  Alltrim(M->B7_TIPO) == 'MP'
    M->B7_DOC := "IMP"+Alltrim(_cDocinv)
    lRet := .T.
ElseIf  Alltrim(M->B7_TIPO) == 'EM'
    M->B7_DOC := "IEM"+Alltrim(_cDocinv)
    lRet := .T.
ElseIf Funname()=="MATA270"
    lRet := .T.
EndIf


Return lRet
