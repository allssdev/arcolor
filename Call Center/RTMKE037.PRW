#include "totvs.ch"
/*/{Protheus.doc} RTMKE037
EXECBLOCK  para ajustar os valores totais no atendimento.
@author Diego Rodrigues
@since 18/02/2025
@version P12.1.2410
@type function
@see https://allss.com.br
@history 18/02/2025, Diego Rodrigues (diego.rodrigues@allss.com.br), Ajustes nas informações de valores para arrendondamento em 2 casas decimais.
/*/
user function RTMKE037()
	//No Início da rotina, salvar o ReadVar:
	Local _aSavAr  		:= GetArea()
	Local _aSavSUA      := SUA->(GetArea())
	Local _aSavSUB      := SUB->(GetArea())
	Local _cRVarBkp		:= __ReadVar
	Local _cContBkp		:= &(_cRVarBkp)
	Local _cRotina 		:= "RTMKE037"
	Local _cFName       := UPPER(AllTrim(FunName()))
	Local _cCpoIte 		:= iif(_cFName=="MATA410".OR._cFName=="MATA440".OR._cFName=="RFATA012","C6_","UB_")
	Local _nBkp    		:= n
	Local _nPProd  		:= aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte+"PRODUTO"                   )})
	Local _nQuant  		:= aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte+"QUANT"                     )})
	Local _nVlrUnit		:= aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte+"VRUNIT"                    )})
	Local _nVlrTota		:= aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte+"VLRITEM"                   )})
	Local _nVlrTab		:= aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte+"PRCTAB"   	               )})
	Local _nVlrDesc		:= aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte+"VALDESC"                   )})
	Local _nPDesc  		:= aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte+"DESC"                      )})
	Local _lRet    		:= .T.

	Private _nDescAux 	:= 0

	if _cFName=="TMKA271" .OR. _cFName=="RTMKI001" .OR. _cFName=="RPC"
		if !empty(aCols[n][_nPProd]) .AND. aCols[n][_nPDesc ] > 0
			//Início - Trecho adicionado por Diego Rodrigues em 05/02/2025 para forçar o arredondamento em 2 casas decimais na atualização de valores
			//aCols[n][_nVlrUnit] := Ceiling(aCols[n][_nVlrUnit] * 100 ) / 100 //Arredondamento para cima
			aCols[n][_nVlrUnit] := Round(aCols[n][_nVlrUnit],2)
			aCols[n][_nVlrTota] := Round(aCols[n][_nVlrUnit],2) * aCols[n][_nQuant]
			aCols[n][_nVlrDesc] := Round(Round(aCols[n][_nVlrTab],2) * aCols[n][_nQuant],2) - Round(aCols[n][_nVlrTota],2)
			//FIm - Trecho adicionado por Diego Rodrigues em 05/02/2025 para forçar o arredondamento em 2 casas decimais na atualização de valores
        EndIf
    EndIf
//	_cLog += "[008] Início dos refresh na GetDados: " + DTOC(Date()) + " " + Time() + CRLF
	if (_cFName=="MATA410" .OR. _cFName=="RFATA012") .AND. Type('oBrowse')<>"U"
		oBrowse:Refresh()
	endif
	if (_cFName=="MATA410" .OR. _cFName=="RFATA012") .AND. Type('oGetDb:oBrowse')<>"U"
		oGetDb:oBrowse:Refresh()
	endif
	if (_cFName=="MATA410" .OR. _cFName=="RFATA012") .AND. Type('oGetPV')<>"U"
		oGetPV:Refresh()
	endif
	if (_cFName=="MATA410" .OR. _cFName=="RFATA012") .AND. Type('oGetDad:oBrowse')<>"U"
		oGetDad:oBrowse:Refresh()
		Ma410Rodap()
	endif
	if (_cFName=="TMKA271" .OR. _cFName=="RTMKI001" .OR. _cFName=="RPC") .AND. Type('oGetTlv:oBrowse')<>"U"
		oGetTlv:oBrowse:Refresh(.T.)
	endif

	//No Final da rotina, restaure o ReadVar
	n            := _nBkp
	__ReadVar    := _cRVarBkp
	&(__ReadVar) := _cContBkp

	RestArea(_aSavSUA)
	RestArea(_aSavSUB)
	RestArea(_aSavAr)
return _lRet
