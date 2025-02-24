#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
/*/{Protheus.doc} RESTA004
@description Atualiza/Consulta a Data e Documento do inventario, conforme parametros.
@author Julio Soares (ALL System Solutions)
@since 14/11/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RESTA004()
	Local   _aSavArea := GetArea()
	Local   _aSB7     := SB7->(GetArea())
	Local   _cRotina  := 'RESTA004'
	Private cPerg     := _cRotina

	ValidPerg()
	If !Pergunte(cPerg,.T.)
		return
	EndIf
	//Update()
	MsgStop("Rotina desativada!",_cRotina+"_001")
	RestArea(_aSB7)
	RestArea(_aSavArea)
return
/*/{Protheus.doc} ValidPerg
@description Valida se as perguntas já existem no arquivo SX1 e caso não encontre as cria no arquivo.
@author Julio Soares (ALL System Solutions)
@since 14/11/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	local _aAlias    := GetArea()
	local aRegs     := {}
	local _aTam      := {}
	local _x         := 0
	local _y         := 0
	local _cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()

	if select(_cAliasSX1)>0
		(_cAliasSX1)->(dbCloseArea())
	endif
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))

	_cPerg           := PADR(_cPerg,len((_cAliasSX1)->X1_GRUPO))
	_aTam            := TamSx3("B7_DATA"   )
	AADD(aRegs,{cPerg,"01","Data inicial do Inventário?","","","mv_ch1",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","","",""})
	_aTam            := TamSx3("B7_DOC"    )
	AADD(aRegs,{cPerg,"02","Documento do Inventário?"   ,"","","mv_ch2",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB7","","","",""})
	_aTam            := TamSx3("B7_DATA"   )
	AADD(aRegs,{cPerg,"03","Data final do inventário?"  ,"","","mv_ch3",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","","",""})
	for _x := 1 To Len(aRegs)
		if !(_cAliasSX1)->(dbSeek(cPerg+aRegs[_x,2],.T.,.F.))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				for _y := 1 to FCount()
					if _y <= len(aRegs[_x])
						FieldPut(_y,aRegs[_x,_y])
					else
						Exit
					endif
				next
			(_cAliasSX1)->(MsUnLock())
		endif
	next
	if select(_cAliasSX1)>0
		(_cAliasSX1)->(dbCloseArea())
	endif
	RestArea(_aAlias)
return
/*/{Protheus.doc} Update
@description Rotina de atualizacao.
@author Julio Soares (ALL System Solutions)
@since 14/11/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
/*
static function Update()
	_cQuery := " SELECT B7_DATA,B7_DOC,B7_DTVALID "
	//_cQuery := " UPDATE '" + RetSqlName("SB7") + "' SET B7_DATA = '" + MV_PAR03 + "' "
	_cQuery += " FROM '" + RetSqlName("SB7") + "' SB7 "
	_cQuery += " WHERE SB7.D_E_L_E_T_ = '' "
	_cQuery += "   AND B7_DOC  = '" + MV_PAR02 + "' "
	_cQuery += "   AND B7_DATA = '" + MV_PAR01 + "' "
	If TcSqlExec(_cQuery) < 0
		MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_001")
		Return
	EndIf
return
*/