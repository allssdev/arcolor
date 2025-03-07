#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
 
User Function RPCPA008()
    Local oParam := Nil
 
    PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL cFilAnt MODULO "PCP"
     
    oParam := P712Param(.T.)  // Par�metros Padr�es
 
    /* ---- Par�metros Obrigat�rios ---- */
    oParam["cEmpAnt"] := cEmpAnt
    oParam["cFilAnt"] := cFilAnt
    oParam["user"]    := "000000"
 
    /* ---- Par�metros Adicionais ---- */
    oParam["TELA_1"]["HW2_CODIGO"]          := ""
    oParam["TELA_1"]["HW2_DESCRI"]          := ""
    oParam["demandStartDate"]               := Date()
    oParam["demandEndDate"]                 := Date() + 60
    oParam["demandsProcessed"]              := .T.
    oParam["eventLog"]                      := .T.
    oParam["lGeraDoc"]                      := .T.
    oParam["lRastreiaEntradas"]             := .F.
    oParam["periodType"]                    := "2"
    oParam["numberOfPeriods"]               := "4"
    oParam["leadTime"]                      := "3"
    oParam["firmHorizon"]                   := 2
    oParam["consignedIn"]                   := "2"
    oParam["consignedOut"]                  := "2"
    oParam["rejectedQuality"]               := "2"
    oParam["blockedLot"]                    := "1"
    oParam["safetyStock"]                   := "1"
    oParam["orderPoint"]                    := "1"
    oParam["purchaseRequestNumber"]         := "2"
    oParam["consolidatePurchaseRequest"]    := "3"
    oParam["consolidateProductionOrder"]    := "2"
    oParam["productionOrderType"]           := "1"
    oParam["productionOrderNumber"]         := "2"
    oParam["allocationSuggestion"]          := "2"
    oParam["demandCodes"]["LISTA"]          := "|003|"
    oParam["documents"]["LISTA"]            := ""
    oParam["products"]["LISTA"]             := ""
    oParam["productTypes"]["LISTA"]         := ""
    oParam["productGroups"]["LISTA"]        := ""
    oParam["demandType"]["EMP_PROJETO"]     := .T.
    oParam["demandType"]["MANUAL"]          := .T.
    oParam["demandType"]["PEDIDO_VENDA"]    := .T.
    oParam["demandType"]["PLANO_MESTRE"]    := .T.
    oParam["demandType"]["PREV_VENDAS"]     := .T.
    oParam["documentType"]["PREVISTOS"]     := "2"
    oParam["documentType"]["SACRAMENTADOS"] := .T.
    oParam["documentType"]["SUSPENSOS"]     := .T.
  
    If PCPA712(oParam, .T., .T.)
        ConOut(" -------- Concluido com Sucesso! -------- ")
    Else
        aHelp := GetHelpPCP("Execu��o do MRP n�o foi concluida com sucesso!") //Mensagem padr�o que ser� assumida como problema, caso n�o encontrar um help.
        //Essa fun��o retornar� um array com as informa��es do help, onde:
        //aHelp[1] - C�digo do help
        //aHelp[2] - Problema do help (se estiver vazio, retorna a mensagem padr�o)
        //aHelp[3] - Solu��o do help
        ConOut(" ----- N�o Foi Concluido com Sucesso! -----")
    EndIf
 
    RESET ENVIRONMENT
 
Return
