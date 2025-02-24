#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} F590CAN
Ponto de entrada após o cancelamento do Borderô, para incluir novamente as informações referente a Portador/Agencia/Conta
@author Diego Rodrigues
@since 24/01/2024
@version 1.0
@type function
/*/

User function F590CAN()

	//Local cTipo := ParamIxb[1]
	//Local cNumBor := ParamIxb[2]

    dbSelectArea("SA1")
    SA1->(dbSetOrder(1))
    If SA1->(MsSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA,.T.,.F.))    
        RecLock("SE1",.F.)   
        SE1->E1_PORTADO := SA1->A1_BCO1
        SE1->E1_AGEDEP	:= SA1->A1_AGENCIA
        SE1->E1_CONTA 	:= SA1->A1_BCCONT
        SE1->E1_OCORREN := "01"
        SE1->E1_INSTR1  := SA1->A1_INSTRU1
        SE1->E1_INSTR2  := SA1->A1_INSTRU2
        SE1->(MsUnLock())
    EndIf
Return
