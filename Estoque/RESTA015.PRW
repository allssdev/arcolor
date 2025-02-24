#include "rwmake.ch"
#include "Protheus.ch"


/*/{Protheus.doc} RESTA015
@description Atualiza parametro do tipo de produto no mestre de inventário, parametro utilizado na rotina ACDA030VP
@author Diego Rodrigues (ALL System Solutions)
@since 06/03/2024
@version 1.0
@return lógico, .T. - Trava os registros  /  .F. - Desativa a trava dos registros
@type function
@see https://allss.com.br
/*/

User Function RESTA015()                                      

Private oDlg
Private oButton1
Private oButton2
Private oSay1
Private oSay2
Private oSay3
Private oCombo
Private oGroup1
Private oGroup2
Private _cRotina := "RESTA015"
Private nCombo
Private _cTipo	:= Space(2) 
Private aItens    := {"1. Tipo Prod_Inv - MV_XTIPINV "}
Private _aParams := {"MV_XTIPINV"}

  DEFINE MSDIALOG oDlg TITLE "Alteração do Tipo de Produto Mestre de Inventário" FROM 000, 000  TO 300, 500 COLORS 0, 16777215 PIXEL


    @ 007, 007  GROUP  oGroup1  TO 140,246  OF oDlg COLOR  0, 16777215          PIXEL
	@ 028, 014 SAY oSay2 PROMPT "Parametro .:" SIZE 200, 029 OF oDlg COLORS 0, 16777215 PIXEL
    @ 028, 074 MSCOMBOBOX oCombo VAR nCombo ITEMS aItens SIZE 150, 012 OF oDlg COLORS 0, 16777215 PIXEL
 
    @ 050, 014 SAY    oSay3       PROMPT "Tipo .:" SIZE 045, 016  of oDlg Pixel
    @ 050, 074 MSGET _cTipo PICTURE "@!"    SIZE 045, 016 OF oDlg Pixel

    @ 070, 074 BUTTON oButton1 PROMPT "Ok"       SIZE 045, 016 OF oDlg ACTION ( U_MTGRV1(_cTipo,nCombo), oDlg:End() ) PIXEL
    @ 070, 125 BUTTON oButton2 PROMPT "Cancelar" SIZE 045, 016 OF oDlg ACTION oDlg:end() PIXEL
 
    @ 108, 021  GROUP  oGroup2  TO 060,210  OF oDlg COLOR  0, 16777215          PIXEL
     
    @ 113, 029 SAY oSay1 PROMPT "Defina o Tipo de produto do(s) parametro(s) listado(s)." SIZE 160, 029 OF oDlg COLORS 0, 16777215 PIXEL
    
  ACTIVATE MSDIALOG oDlg

Return


User Function MTGRV1(_cTipo, _cMVParam)
Local nI := val(substr(_cMVParam,1,1))

	_cAliasSX6 := "SX6_"+GetNextAlias()
	OpenSxs(,,,,FWCodEmp(),_cAliasSX6,"SX6",,.F.)
	dbSelectArea(_cAliasSX6)
	(_cAliasSX6)->(dbSetOrder(1))
	If (_cAliasSX6)->(dbSeek(xFilial(_cAliasSX6) + _aParams[nI]))	                                    
		(_cAliasSX6)->(Reclock(_cAliasSX6,.F.))	
	 	(_cAliasSX6)->X6_CONTEUD  := _cTipo
		(_cAliasSX6)->(MsUnlock()) 										
		U_GrvLogP(_aParams[nI], _cTipo )		        
	Endif

If MSGBOX("Tipo gravado com sucesso! Deseja atualizar novamente?",_cRotina+"_000","YESNO")
	ExecBlock("RESTA015")
Else
	Close(oDlg)
EndIf 

Return

User Function GrvLogP( _cParam, _cTipo)
Local _cUserID := RetCodUsr()
Local _cUserName := ""

Psworder(1) // Ordena arquivo de senhas por ID do usuario
PswSeek(__cUserID) // Pesquisa usuario corrent 
_cUserName := PswRet(1)[1][2]

	Reclock("SZL",.T.)
	SZL->ZL_FILIAL	:= '01'
	SZL->ZL_NUM		:= '000000'
	SZL->ZL_ATEND	:= '000000'
	SZL->ZL_DATA	:= date()
	SZL->ZL_HORA	:= time()
	SZL->ZL_LOG		:= _cParam + " - " + _cTipo
	SZL->ZL_FUNNAME	:= _cRoTina
	SZL->ZL_ALIAS	:= "SX6"
	SZL->ZL_USER	:= _cUserID
	SZL->ZL_NOMEUSR	:= _cUserName
	SZL->(MsUnlock())  

return.T.

