#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

User Function MT175TOK()

Local lRet := .T. 
Local _cTpLau := SUPERGETMV( "MV_XTPLAUD",.F.,"A")
/* AGUARDANDO DEFINI��O DO CLIENTE PARA IMPLANTA��O DO INSPE��O DE PROCESSO.
DbSelectArea("QPK")
QPK->(dbSetOrder(3)) //QPK_FILIAL+QPK_XNUMSE
If QPK->(MsSeek(xFilial("QPK")+SD7->D7_NUMSEQ,.T.))
    If QPK->QPK_LAUDO $ _cTpLau
        lRet := .T.
    else   
        lRet := .F.
        MsgInfo("N�o existe laudo cadastrado para esta Baixa do CQ.","Aten��o")
    EndIF
Else
    lRet := .F.
    MsgInfo("N�o existe Registro na tabela QPK. Favor verificar com o administrador do sistema.","Aten��o")
endif
*/
return (lRet)  
