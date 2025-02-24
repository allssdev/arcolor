#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

User Function MT175TOK()

Local lRet := .T. 
Local _cTpLau := SUPERGETMV( "MV_XTPLAUD",.F.,"A")
/* AGUARDANDO DEFINIÇÃO DO CLIENTE PARA IMPLANTAÇÃO DO INSPEÇÃO DE PROCESSO.
DbSelectArea("QPK")
QPK->(dbSetOrder(3)) //QPK_FILIAL+QPK_XNUMSE
If QPK->(MsSeek(xFilial("QPK")+SD7->D7_NUMSEQ,.T.))
    If QPK->QPK_LAUDO $ _cTpLau
        lRet := .T.
    else   
        lRet := .F.
        MsgInfo("Não existe laudo cadastrado para esta Baixa do CQ.","Atenção")
    EndIF
Else
    lRet := .F.
    MsgInfo("Não existe Registro na tabela QPK. Favor verificar com o administrador do sistema.","Atenção")
endif
*/
return (lRet)  
