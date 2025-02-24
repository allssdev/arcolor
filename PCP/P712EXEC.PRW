#INCLUDE "PROTHEUS.CH"   
  
User Function P712EXEC()
    Local cTicket   := PARAMIXB
     
    _cSC2  := "UPDATE SC2010 SET D_E_L_E_T_= '*'"
	_cSC2  += " FROM SC2010 SC2 (NOLOCK) "
	_cSC2  += " WHERE SC2.D_E_L_E_T_= ''"
    _cSC2  += " AND C2_TPOP = 'P' "
    _cSC2  += " AND SUBSTRING(C2_NUM,1,1) = 'Z' "

     TCSQLExec(_cSC2)

    _cSD4  := "UPDATE SD4010 SET D_E_L_E_T_= '*'"
	_cSD4  += " FROM SD4010 SD4 (NOLOCK) "
	_cSD4  += " WHERE SD4.D_E_L_E_T_= ''"
    _cSD4  += " AND SUBSTRING(D4_OP,1,1) = 'Z' "

     TCSQLExec(_cSD4)
  
Return Nil  
