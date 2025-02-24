#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

user function RESTE012()
Local _aSavArea   := GetArea()
Local _cDadosAux  := "GETSDD"
Local _cRet   	  := ""
Local _cQry 	  := ""

_cQry 	  := " SELECT  "
_cQry 	  += " CASE WHEN LEN(MAX(SUBSTRING(DD_DOC,4,3))+1) > 2 THEN 'AUT'+CONVERT(NVARCHAR(4),MAX(SUBSTRING(DD_DOC,4,3))+1 )"
_cQry 	  += " ELSE 'AUT0'+CONVERT(NVARCHAR(4),MAX(SUBSTRING(DD_DOC,4,3))+1 ) END AS DD_DOC "
_cQry 	  += " FROM SDD010 SDD (NOLOCK) "
_cQry 	  += "WHERE SUBSTRING(DD_DOC,1,3) = 'AUT'"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cDadosAux,.F.,.T.)
dbSelectArea(_cDadosAux)

_cRet := AllTrim((_cDadosAux)->DD_DOC)
(_cDadosAux)->(dbCloseArea())

RestArea(_aSavArea)

return(_cRet)
