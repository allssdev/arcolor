#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} RFATE009
@description Cadastros para Finalização do processo de Separação nas Ordens de Separação.
@author Alessandro Villar
@since 11/01/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RFATE009()
	Local _lRet    := .T.
//	Local _cNOMOP2 := ""
	Local _cRotina := "RFATE009"

	Private cPerg  := _cRotina

	//Verifica as perguntas selecionadas
	ValidPerg()
	Pergunte(cPerg,.F.)
	MV_PAR01 := ""
	_bPerg   := "Pergunte(cPerg,.T.)"
	If AllTrim(CB7->CB7_STATUS) == "0" .AND. AllTrim(CB7->CB7_STATPA) <>"1"
	   If MsgYesNo("Deseja encerrar o processo de separação neste momento?",_cRotina+"_001")
	   		_lRet := Empty(CB7->CB7_HRFIN) .AND. Empty(CB7->CB7_DTFIN) //!EMPTY = NAO VAZIO
	      	If !_lRet
	     		_lRet := MsgYesNo("Processo de separação já foi finalizado"+chr(13)+chr(10)+"Deseja sobrepor esta informação?",_cRotina+"_002")
			EndIf
			While Empty(MV_PAR01)
				If !&(_bPerg)
					return 
				EndIf
				If Empty(MV_PAR01)
					MsgAlert("Conferente não preenchido!",_cRotina+"_004")
				Else
					dbSelectArea("CBN")
					CBN->(dbOrderNickName("CBN_COD"))		//dbSetOrder(1) //Filial + Código do operador  
					If !MsSeek(xFilial("CBN") + MV_PAR01,.T.,.F.)
						MsgAlert("Conferente não existe!",_cRotina+"_005")
						MV_PAR01 := ""
					EndIf
				EndIf
			EndDo
			If _lRet
				dbSelectArea("CB7")
				while !RecLock("CB7",.F.) ; enddo
					CB7->CB7_HRFIN  := Left(Time(),5) // Se o Campo Estiver com Tamanho 5 Precisa trocar para Left(Time(),5)
					CB7->CB7_DTFIN  := Date()
					CB7->CB7_CODOP2 := MV_PAR01
					CB7->CB7_NOMOP2 := CBN->CBN_NOME
					CB7->CB7_STATUS := "8"
				CB7->(MSUNLOCK())
				MsgInfo("Processo de separação foi finalizado com sucesso!!","Operação finalizada com sucesso!!!",_cRotina+"_003")
			EndIf
		EndIf
	EndIf
return  
/*/{Protheus.doc} ValidPerg
@description Verifica a existencia das perguntas criando-as caso seja necessario (caso nao existam).
@author Alessandro Villar
@since 11/01/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	local _sArea     := GetArea()
	local aRegs      := {}
	local _aTam      := {}
	local i          := 0
	local j          := 0
	local _cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()

	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	cPerg  := PADR(cPerg,len((_cAliasSX1)->X1_GRUPO))
	_aTam  := TamSx3("CB7_CODOP2")
	AADD(aRegs,{cPerg,"01","Conferente: ","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","CBN",""})
	for i := 1 to len(aRegs)
		if !(_cAliasSX1)->(dbSeek(cPerg+aRegs[i,2]))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				for j := 1 to FCount()
					if j <= len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					else
						Exit
					endif
				next
			(_cAliasSX1)->(MsUnLock())
		endif
	next
	RestArea(_sArea)
return
