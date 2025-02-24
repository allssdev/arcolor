#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} User Function nomeFunction
    Ponto de entrada executado no final da geração de documentos
    @type  Function
    @author Fernando Bombardi   
    @since 15/12/2023
    /*/
User Function PA145GER()
   /* Local nTotal := 0
    Local nIndex := 0
    Local cChave := ""
    Local aChaves := {}
 
    // Recupera as chaves utilizadas no processamento do ponto de entrada P145NumOP
    If GetGlbVars("CHAVES_P145NUMOP", @aChaves)
        nTotal  := Len(aChaves)
         
        // Percorre as chaves limpando as globais
        For nIndex := 1 To nTotal
            cChave := aChaves[nIndex]
            ClearGlbValue(cChave)
        Next
    EndIf
    */
    U_RPCPA006()
 
Return Nil
