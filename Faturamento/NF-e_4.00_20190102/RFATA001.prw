#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "PROTHEUS.CH"
#DEFINE _CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} RAFTA001
@description Atualiza parametros de Cancelamento de Nfe
@author Livia Della Corte (ALL System Solutions)
@since 17/07/2019
@version 1.0
@return lógico, .T. - Trava os registros  /  .F. - Desativa a trava dos registros
@type function
@see https://allss.com.br
/*/

User Function RFATA001()                                      

Private oDlg
Private oButton1
Private oButton2
Private oSay1
Private oSay2
Private oSay3
Private oCombo1
Private oCombo2
Private oGroup1
Private oGroup2
Private _cRotina := "RFATA001"
Private nCombo1
Private nCombo2

Private aItens1    := {"1. Nfe - MV_CANCNFE","2. NFse - MV_CANNFSE "}
Private aItens2    := {"Sim","Não"}
Private _aParams := {"MV_CANCNFE","MV_CANNFSE"}


//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" FUNNAME _cRotina //tables "SXB", "SDA", "SDB", "CBJ"


  DEFINE MSDIALOG oDlg TITLE "Parametros de Cancelamento de NFE/NFSE" FROM 000, 000  TO 300, 500 COLORS 0, 16777215 PIXEL


    @ 007, 007  GROUP  oGroup1  TO 140,246  OF oDlg COLOR  0, 16777215          PIXEL
	@ 028, 014 SAY oSay2 PROMPT "Parametro .:" SIZE 200, 029 OF oDlg COLORS 0, 16777215 PIXEL
    @ 028, 074 MSCOMBOBOX oCombo1 VAR nCombo1 ITEMS aItens1 SIZE 150, 012 OF oDlg COLORS 0, 16777215 PIXEL
 
 	@ 052, 014 SAY oSay3 PROMPT "Bloquear ?" SIZE 200, 029 OF oDlg COLORS 0, 16777215 PIXEL
    @ 052, 074 MSCOMBOBOX oCombo2 VAR nCombo2 ITEMS aItens2 SIZE 150, 012 OF oDlg COLORS 0, 16777215 PIXEL
 
  
    @ 070, 074 BUTTON oButton1 PROMPT "Ok"       SIZE 045, 016 OF oDlg ACTION ( u_AtuMVPAR(nCombo1,nCombo2), oDlg:End() ) PIXEL
    @ 070, 125 BUTTON oButton2 PROMPT "Cancelar" SIZE 045, 016 OF oDlg ACTION oDlg:end() PIXEL
 
    @ 108, 021  GROUP  oGroup2  TO 060,210  OF oDlg COLOR  0, 16777215          PIXEL
     
    @ 113, 029 SAY oSay1 PROMPT "Bloqueio(Sim) ou Desbloqueio(Não) para Cancelamento via Job do TSS." SIZE 160, 029 OF oDlg COLORS 0, 16777215 PIXEL
     
  ACTIVATE MSDIALOG oDlg

Return


User Function AtuMVPAR(_cMVParam, _cBloq)
Local nI := val(substr(_cMVParam,1,1))
Local nBlq := iif(_cBloq == "Sim",".T.",".F.")
Default nBlq:= ".F."

_cAliasSX6 := "SX6_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX6,"SX6",,.F.)
dbSelectArea(_cAliasSX6)
(_cAliasSX6)->(dbSetOrder(1))

If (_cAliasSX6)->(dbSeek(xFilial(_cAliasSX6) + _aParams[nI]))	                                    
	(_cAliasSX6)->(Reclock(_cAliasSX6,.F.))	
 	(_cAliasSX6)->X6_CONTEUD  := nBlq
	(_cAliasSX6)->(MsUnlock()) 											        
Endif


MsgAlert("Parametro Atualizado!",_cRotina+"_001")

/*If MSGBOX("Data gravada com sucesso!Deseja atualizar novamente?",_cRotina+"_000","YESNO")
	ExecBlock("RFATA001")
Else*/
	Close(oDlg)
//EndIf 

Return .t.


