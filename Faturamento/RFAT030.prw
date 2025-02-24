#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFAT030   ºAutor  ³Júlio Soares        º Data ³  24/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Execblock utilizado para testar gatilhos por acols         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico para empresa - ARCOLOR                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
//Exemlos de integridade de rotina
Local _aSavArea := GetArea ()
Local _cAlias   := Alias   ()
Local _nIndex   := IndexOrd()

Local _aSavSF2  := SF2->(GetArea ())
Local _cAlSF2   := SF2->(Alias   ())
Local _nRcSF2   := SF2->(RECNO   ())
Local _nInSF2   := SF2->(IndexOrd())

SF2->(dbSetOrder  (_nInSF2))
SF2->(DBGOTO      (_nRcSF2))
SF2->(dbSelectArea(_cAlSF2))
RestArea          (_aSavSF2)
    

dbSetOrder  (_nIndex)
dbSelectArea(_cAlias)
RestArea    (_aSavArea)
*/

User Function RFATE030()

Local _aSavArea := GetArea()
Local _cRotina  := "RFATE030"
Local _cCdfat   := aScan(aHeader,{|x|AllTrim(x[02])=="UB_CODFATR"})
Local _nDesc1   := aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCTV1"})
Local _nDesc2   := aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCTV2"})
Local _nDesc3   := aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCTV3"})
Local _nDesc4   := aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCTV4"})
Local _cFator   := aScan(aHeader,{|x|AllTrim(x[02])=="UB_FATOR"  })
Local _nDesct   := aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESC"   })
Local _lRet     := ""
Local _nAux	    := 100

For _x := 1 To Len(aCols)
	If !Empty (aCols[_x][_cCdfat])
		If !aCols[_x][Len(aHeader)+1] // Não traz a linha deletada.
        _acCdFat := (aCols[_x][_cCdfat])
        _anDesc1 := (aCols[_x][_nDesc1])
        _anDesc2 := (aCols[_x][_nDesc2])
        _anDesc3 := (aCols[_x][_nDesc3])
        _anDesc4 := (aCols[_x][_nDesc4])
        _acFator := (aCols[_x][_cFator])
        _anDesct := (aCols[_x][_nDesct])                
   /*	If &("M->ZA_DESC"+cValToChar(_x)) > 0
		_nAux := _nAux - (_nAux * (&("M->ZA_DESC"+cValToChar(_x))/100))
 	EndIf*/
			If (_nDesct) > 0
				_nAux := (_anDesct - (_anDesct * (_anDesc4/100)))
				//D-(D*(D4/100))
		 	EndIf
		 	_lRet := (100 - _nAux)
		EndIf
	Else
		MSGALERT("INFORME O FATOR DE DESCONTO")
	EndIf 
Next
RestArea(_aSavArea)

Return(_lRet)