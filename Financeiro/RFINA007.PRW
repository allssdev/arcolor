#include "rwmake.ch"
#include "Protheus.ch"


/*/{Protheus.doc} RFINA007
@description Atualiza parametros de bloqueio de movimentação
@author Livia Della Corte (ALL System Solutions)
@since 08/01/2019
@version 1.0
@return lógico, .T. - Trava os registros  /  .F. - Desativa a trava dos registros
@type function
@see https://allss.com.br
/*/

User Function RFINA007()                                      

Private oDlg
Private oButton1
Private oButton2
Private oSay1
Private oSay2
Private oSay3
Private oCombo
Private oGroup1
Private oGroup2
Private _cRotina := "RFINA007"
Private nCombo
Private _dDtbloqueio	:= ctod("") 
Private aItens    := {"1. Fiscal - MV_DATAFIS ","2. Financeiro - MV_DATAFIN ","3. Estoque - MV_ULMES ","4. Todos "}
Private _aParams := {"MV_DATAFIS","MV_DATAFIN","MV_ULMES"}

  DEFINE MSDIALOG oDlg TITLE "Bloqueio de Lançamentos - FINANCEIRO * FISCAL * ESTOQUE" FROM 000, 000  TO 300, 500 COLORS 0, 16777215 PIXEL


    @ 007, 007  GROUP  oGroup1  TO 140,246  OF oDlg COLOR  0, 16777215          PIXEL
	@ 028, 014 SAY oSay2 PROMPT "Parametro .:" SIZE 200, 029 OF oDlg COLORS 0, 16777215 PIXEL
    @ 028, 074 MSCOMBOBOX oCombo VAR nCombo ITEMS aItens SIZE 150, 012 OF oDlg COLORS 0, 16777215 PIXEL
 
    @ 050, 014 SAY    oSay3       PROMPT "Data .:" SIZE 045, 016  of oDlg Pixel
    @ 050, 074 MSGET _dDtbloqueio PICTURE "@D"    SIZE 045, 016 OF oDlg Pixel

    @ 070, 074 BUTTON oButton1 PROMPT "Ok"       SIZE 045, 016 OF oDlg ACTION ( u_MTGRV(_dDtbloqueio,nCombo), oDlg:End() ) PIXEL
    @ 070, 125 BUTTON oButton2 PROMPT "Cancelar" SIZE 045, 016 OF oDlg ACTION oDlg:end() PIXEL
 
    @ 108, 021  GROUP  oGroup2  TO 060,210  OF oDlg COLOR  0, 16777215          PIXEL
     
    @ 113, 029 SAY oSay1 PROMPT "Defina a data limite para operações para do(s) parametro(s) listado(s)." SIZE 160, 029 OF oDlg COLORS 0, 16777215 PIXEL
    
  
  
  ACTIVATE MSDIALOG oDlg

Return


User Function MTGRV(_dDtbloqueio, _cMVParam)
Local nI := val(substr(_cMVParam,1,1))

If nI == 4
     For i := 1 to len(_aParams)
		_cAliasSX6 := "SX6_"+GetNextAlias()
		OpenSxs(,,,,FWCodEmp(),_cAliasSX6,"SX6",,.F.)
		dbSelectArea(_cAliasSX6)
		(_cAliasSX6)->(dbSetOrder(1))
		If (_cAliasSX6)->(dbSeek(xFilial(_cAliasSX6) + _aParams[i]))	                                    
			(_cAliasSX6)->(Reclock(_cAliasSX6,.F.))	
		 	(_cAliasSX6)->X6_CONTEUD 		:= dtos(_dDtbloqueio)
			(_cAliasSX6)->(MsUnlock()) 
			u_grvLogSZL(_aParams[i], dtos(_dDtbloqueio))			  
		Endif
	next
Else
	_cAliasSX6 := "SX6_"+GetNextAlias()
	OpenSxs(,,,,FWCodEmp(),_cAliasSX6,"SX6",,.F.)
	dbSelectArea(_cAliasSX6)
	(_cAliasSX6)->(dbSetOrder(1))
	If (_cAliasSX6)->(dbSeek(xFilial(_cAliasSX6) + _aParams[nI]))	                                    
		(_cAliasSX6)->(Reclock(_cAliasSX6,.F.))	
	 	(_cAliasSX6)->X6_CONTEUD  := dtos(_dDtbloqueio)
		(_cAliasSX6)->(MsUnlock()) 										
		u_GrvLogSZL(_aParams[nI], dtos(_dDtbloqueio) )		        
	Endif
EndIf

If MSGBOX("Data gravada com sucesso!Deseja atualizar novamente?",_cRotina+"_000","YESNO")
	ExecBlock("RFINA007")
Else
	Close(oDlg)
EndIf 

Return

User Function GrvLogSZL( _cParam, _dDtbloqueio)
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
	SZL->ZL_LOG		:= _cParam + " - " + _dDtbloqueio
	SZL->ZL_FUNNAME	:= _cRoTina
	SZL->ZL_ALIAS	:= "SX6"
	SZL->ZL_USER	:= _cUserID
	SZL->ZL_NOMEUSR	:= _cUserName
	SZL->(MsUnlock())  

return.T.

