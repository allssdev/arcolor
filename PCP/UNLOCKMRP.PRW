#INCLUDE "TOTVS.CH"
#INCLUDE 'FILEIO.CH'

User Function UNLOCKMRP()
    /*//Habilitando o semáforo
    If ! LockByName("ZSEMAFORO", .T., .F.)
        MsgStop("Semáforo já existente, função não pode ser executada!", "Atenção")
        Return
    EndIf
     */
    //Comandos
     
    //Desabilitando o semáforo
    UnLockByName("PCP_Lock_" + AllTrim("PCPA145"), .F. /*lEmpresa*/, .F. /*lFilial*/)
    UnLockByName("PCP_Lock_" + AllTrim("PCPA145INT"), .F. /*lEmpresa*/, .F. /*lFilial*/)
    UnLockByName("PCP_Lock_" + AllTrim("PCPA146"), .F. /*lEmpresa*/, .F. /*lFilial*/)
    UnLockByName("PCP_Lock_" + AllTrim("PCPA712"), .F. /*lEmpresa*/, .F. /*lFilial*/)
    UnLockByName("PCP_Lock_" + AllTrim("PCPA151"), .F. /*lEmpresa*/, .F. /*lFilial*/)


    MsgInfo("Semáforo liberado", "Atenção")
Return
