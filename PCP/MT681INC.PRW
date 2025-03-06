#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

User Function MT681INC     
Local   _aSavArea := GetArea()
Local   _aSavSD4  := SD4->(GetArea())
Local   _aSavSB1  := SB1->(GetArea())
Local   _aSavSD3  := SD3->(GetArea())
Local   _aSavSH6  := SH6->(GetArea())
Local   _aSavSC2  := SC2->(GetArea())
Local   _cLisOper := SuperGetMv("MV_XLOPEPR",,"E1/E2")
Local   _cUsrProd := SuperGetMV("MV_XUSRPROD",,"000000")
Private _cNficha  := ""

    //Fazer aqui a analise/alteração
    //Diego Rodrigues - 10/02/2025 - Ponto para ativar a impressão das fichas automaticamente ao concluir o apontamento
    if Upper(AllTrim(FunName())) == "MATA681" .and. SD3->D3_TIPO == 'PA' .and. SD3->D3_QUANT > 0 //.AND. Upper(AllTrim(__cUserId)) $ _aUsrPcp
        _cNficha := U_RPCPE015(SD3->D3_OP)
        //Atualiza o numero da ficha pallet na tabela SD3
        RecLock("SD3",.F.)
        SD3->D3_XNRFICH := _cNficha
        SD3->(MsUnLock()) 
        //Fim da atualização da ficha pallet
        U_RESTR006()
    //Diego Rodrigues - 10/02/2025 - Ponto para ativar a impressão das fichas do apontamento dos roteiros intermediarios
    ElseIf Upper(AllTrim(FunName())) == "MATA681" .and. SD3->D3_TIPO =='PI' .and. SD3->D3_QUANT > 0 //.AND. Upper(AllTrim(__cUserId)) $ _aUsrPcp
        U_RESTR007()
    ElseIf Upper(AllTrim(FunName())) == "MATA681" .and. SH6->H6_OPERAC$_cLisOper
        U_RESTR009()
    EndIf

    //Restauro os parametros originais da Rotina MATA681
    MV_PAR01 := 2
    MV_PAR02 := 2
    MV_PAR03 := 1
    MV_PAR04 := 2
    MV_PAR05 := 1
    MV_PAR06 := IIF(!__cUserId$_cUsrProd,2,1)
    MV_PAR08 := 1
    //Fim da restauração dos parametros
RestArea(_aSavSC2)
RestArea(_aSavSD3)
RestArea(_aSavSH6)
RestArea(_aSavSB1)
RestArea(_aSavSD4)
RestArea(_aSavArea)
Return
