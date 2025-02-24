#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} User Function nomeFunction
    (long_description)
    @type  Function
    @author Fernando Bombardi
    @since 12/12/2023
    /*/
User Function P145NumOP()
    
    Local aChaves    := {}
    Local aRetorno   := Array(5)
    Local cChaveGbl  := ""
    Local _cRetNroOp := ""
/*
    CONOUT("[P145NumOP_001] - Inicio - Numeracao de Documento - ThreadID: " + cValtoChar(ThreadID()))

    _cRetNroOp := GETSX8NUM("ZA0","ZA0_NUM")
    ConfirmSx8()
    CONOUT("[P145NumOP_666] - GetSX8Num: " + _cRetNroOp)

    CONOUT("[P145NumOP_008] - Reclock ZA0")
    dbSelectArea("ZA0")
    while !RecLock("ZA0",.T.) ; enddo
    ZA0->ZA0_FILIAL := FWXFilial("ZA0")
    ZA0->ZA0_NUM  := _cRetNroOp
    ZA0->ZA0_DATA := dDataBase
    ZA0->(MsUnlock())
    CONOUT("[P145NumOP_008] - MsUnlock ZA0")

    CONOUT("[P145NumOP_009] - Fim - Numeracao de Documento")

    aRetorno[1] := _cRetNroOp     //ZA0_NUM
    aRetorno[2] := "01"           //C2_ITEM
    aRetorno[3] := "001"          //C2_SEQUEN
    aRetorno[4] := "   "          //C2_ITEMGRD
    aRetorno[5] := " "            //C2_GRADE
 
    // Monta chave global
    cChaveGbl := "NUM_OP" + aRetorno[1] + aRetorno[2]

    // Guarda a sequencia na global para incrementar depois
    PutGlbValue(cChaveGbl, aRetorno[3])
 
    While !GlbNmLock("CHAVES_P145NUMOP")
        Sleep(100)
    End
 
    // Salva as chaves para limpar no fim do processamento
    If GetGlbVars("CHAVES_P145NUMOP", @aChaves)
        aAdd(aChaves, cChaveGbl)
        PutGlbVars("CHAVES_P145NUMOP", aChaves)
    Else
        PutGlbVars("CHAVES_P145NUMOP", {cChaveGbl})
    EndIf
 
    GlbNmUnlock("CHAVES_P145NUMOP")
*/
Return aRetorno
 

