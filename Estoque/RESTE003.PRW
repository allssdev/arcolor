#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} RESTE003
@description Rotina responsável por alterar a data dos movimentos internos, conforme parâmetros desde não tenha sido feito o fechamento de estoque para o período definido.
@obs É importante realizar o processo de recálculo dos saldos de estoque (todos relativos ao processo de fechamento, exceto a Virada de Saldo), para correção das posições de estoque.
@author Adriano Leonardo
@since 18/11/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RESTE003()
	Local   _aSavArea   := GetArea()
	Local   _aSavSD3    := SD3->(GetArea())

	Private _cRotina	:= "RESTE003"
	Private cPerg		:= _cRotina
	Private _nNumReg	:= 0

	MsgRun("Aguarde! Processando movimentos internos...",cCadastro,{ || _cCalc := AlteraSD3()}) //Chamada da rotina de processamento

	RestArea(_aSavSD3)
	RestArea(_aSavArea)
return   
/*/{Protheus.doc} ValidPerg
@description Valida se as perguntas já existem no arquivo SX1 e caso não encontre as cria no arquivo.
@author Adriano Leonardo
@since 18/11/2013
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
	_aTam            := TamSx3("D3_EMISSAO")
	AADD(aRegs,{cPerg,"01","Data de Destino    ?","","","mv_ch1",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
	_aTam            := TamSx3("D3_COD"    )
	AADD(aRegs,{cPerg,"02","Do Produto         ?","","","mv_ch2",_aTam[3],_aTam[1],_aTam[2],0,"G","          ","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
	AADD(aRegs,{cPerg,"03","Ao Produto         ?","","","mv_ch3",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
	_aTam            := TamSx3("D3_LOCAL"  )
	AADD(aRegs,{cPerg,"04","Do Armazém         ?","","","mv_ch4",_aTam[3],_aTam[1],_aTam[2],0,"G","          ","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
	AADD(aRegs,{cPerg,"05","Ao Armazém         ?","","","mv_ch5",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
	_aTam            := TamSx3("D3_DOC"    )
	AADD(aRegs,{cPerg,"06","Do Documento       ?","","","mv_ch6",_aTam[3],_aTam[1],_aTam[2],0,"G","          ","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
	AADD(aRegs,{cPerg,"07","Ao Documento       ?","","","mv_ch7",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
	_aTam            := TamSx3("D3_EMISSAO")
	AADD(aRegs,{cPerg,"08","Da Data Original   ?","","","mv_ch8",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
	AADD(aRegs,{cPerg,"09","Até a Data Original?","","","mv_ch9",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
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
/*/{Protheus.doc} AlteraSD3
@description Função responsável pelo processamento da rotina principal.
@author Adriano Leonardo
@since 18/11/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function AlteraSD3()
	local   _lSobresc := .F. //Variável de controle utilizada para definir se um movimento que já foi alterado poderá ser alterado novamente
	local   _lContin  := .T. //Variável auxiliar, por conta da função chamar a si própria há casos em que o return não fecha a função
	ValidPerg()
	If !Pergunte(cPerg,.T.)
		_lContin := .F.
		return
	EndIf
	If MV_PAR01 <= SuperGetMv("MV_ULMES",,"20130330") .Or. MV_PAR08 <= SuperGetMv("MV_ULMES",,"20130330") .Or. MV_PAR09 <= SuperGetMv("MV_ULMES",,"20130330") //Valida a data do último fechamento de estoque
		MsgInfo("Já foi realizado o fechamento de estoque para a data selecionada, as datas de origem e destino devem ser superiores a " + DtoC(SuperGetMv("MV_ULMES",,"20130330")) + "." ,_cRotina + "_001")
		AlteraSD3()
	EndIf
	If MV_PAR01 > dDataBase //Valida se a data de destino é superior a data base do sistema
		MsgInfo("A data de destino não pode ser superior a data base do sistema." ,_cRotina + "_002")
		AlteraSD3()
	EndIf
	If _lContin
		dbSelectArea("SD3")
		//SD3->(dbSetOrder(6)) //D3_FILIAL+DTOS(D3_EMISSAO)+D3_NUMSEQ+D3_CHAVE+D3_COD
		SD3->(dbOrderNickName("D3_EMISSAO")) //D3_FILIAL+DTOS(D3_EMISSAO)+D3_NUMSEQ+D3_CHAVE+D3_COD
		Set SoftSeek ON
			SD3->(dbSeek(xFilial("SD3")+DTOS(MV_PAR08)))
		Set SoftSeek OFF
		_nCont := 0
		While !SD3->(EOF()) .AND. SD3->D3_FILIAL==xFilial("SD3") .AND. SD3->D3_EMISSAO <= MV_PAR09
			//Verifica se a data do movimento já foi alterada alguma vez
			If !Empty(SD3->D3_DTORIGI)
				//Permite que o usuário defina se movimentos alterados serão reprocessados ou não
				If !_lSobresc .AND. _nCont==0
					_lSobresc := MsgYesNo("Atenção: Foi identificado que a data de alguns movimentos já haviam sido alteradas anteriormente, deseja alterá-las novamente? Só clique em SIM caso a alteração anterior tenha sido feita errada.", _cRotina+"_003")
					_nCont++
				EndIf
				//Verifica de acordo com a escolha do usuário se movimentos alterados serão reprocessados
				If !_lSobresc				
					//dbSelectArea("SD3")
					//SD3->(dbSetOrder(6)) //D3_FILIAL+DTOS(D3_EMISSAO)+D3_NUMSEQ+D3_CHAVE+D3_COD
					//SD3->(dbOrderNickName("D3_EMISSAO")) //D3_FILIAL+DTOS(D3_EMISSAO)+D3_NUMSEQ+D3_CHAVE+D3_COD
					SD3->(dbSkip())
					loop
				EndIf
			EndIf
			//Verifica se o documento está dentro do range definido pelo usuário
			If SD3->D3_DOC < MV_PAR06 .OR. SD3->D3_DOC > MV_PAR07
				//dbSelectArea("SD3")
				//SD3->(dbSetOrder(6)) //D3_FILIAL+DTOS(D3_EMISSAO)+D3_NUMSEQ+D3_CHAVE+D3_COD
				//SD3->(dbOrderNickName("D3_EMISSAO")) //D3_FILIAL+DTOS(D3_EMISSAO)+D3_NUMSEQ+D3_CHAVE+D3_COD
				SD3->(dbSkip())
				loop
			EndIf 
			//Verifica se o produto está dentro do range definido pelo usuário
			If SD3->D3_COD < MV_PAR02 .OR. SD3->D3_COD > MV_PAR03
				//dbSelectArea("SD3")
				//SD3->(dbSetOrder(6)) //D3_FILIAL+DTOS(D3_EMISSAO)+D3_NUMSEQ+D3_CHAVE+D3_COD
				//SD3->(dbOrderNickName("D3_EMISSAO")) //D3_FILIAL+DTOS(D3_EMISSAO)+D3_NUMSEQ+D3_CHAVE+D3_COD
				SD3->(dbSkip())
				loop
			EndIf
			//Verifica se o armazém está dentro do range definido pelo usuário
			If SD3->D3_LOCAL < MV_PAR04 .OR. SD3->D3_LOCAL > MV_PAR05
				//dbSelectArea("SD3")
				//SD3->(dbSetOrder(6)) //D3_FILIAL+DTOS(D3_EMISSAO)+D3_NUMSEQ+D3_CHAVE+D3_COD
				//SD3->(dbOrderNickName("D3_EMISSAO")) //D3_FILIAL+DTOS(D3_EMISSAO)+D3_NUMSEQ+D3_CHAVE+D3_COD
				SD3->(dbSkip())
				loop
			EndIf 
			//Por usar busca aproximada, verifica se a data do movimento é maior ou igual a data de origem inicial
			If SD3->D3_EMISSAO < MV_PAR08
				//dbSelectArea("SD3")
				//SD3->(dbSetOrder(6)) //D3_FILIAL+DTOS(D3_EMISSAO)+D3_NUMSEQ+D3_CHAVE+D3_COD
				//SD3->(dbOrderNickName("D3_EMISSAO")) //D3_FILIAL+DTOS(D3_EMISSAO)+D3_NUMSEQ+D3_CHAVE+D3_COD
				SD3->(dbSkip())
				loop
			EndIf
			_dDtEmis := SD3->D3_EMISSAO
			//Altera a data do movimento, armazenando a data original em campo flag para fins de histórico
			//Este trecho está utilizando RecLock para efeito de log de registro
			while !Reclock("SD3",.F.) ; enddo
				IF Empty(SD3->D3_DTORIGI)
					SD3->D3_DTORIGI := _dDtEmis //A data original nunca será sobrescrita em caso de reprocessamento
				EndIf
				SD3->D3_MARK := 'X' //Campo flag para ser utilizado no update posteriormente
				_nNumReg++
			SD3->(MsUnLock())
			dbSelectArea("SD3")
			//SD3->(dbSetOrder(6)) //D3_FILIAL+DTOS(D3_EMISSAO)+D3_NUMSEQ+D3_CHAVE+D3_COD
			SD3->(dbOrderNickName("D3_EMISSAO")) //D3_FILIAL+DTOS(D3_EMISSAO)+D3_NUMSEQ+D3_CHAVE+D3_COD
			SD3->(dbSkip())
		EndDo
		_cUpd := "UPDATE " + RetSqlName("SD3") + " SET D3_EMISSAO=" + DTOS(MV_PAR01) + ", D3_MARK='' WHERE D_E_L_E_T_='' AND D3_FILIAL='" + xFilial("SD3") + "' AND UPPER(D3_MARK)='X' AND D3_DTORIGI<>'' "
		If TCSQLExec(_cUpd) < 0
			MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_004")
			_cUpd2 := "UPDATE " + RetSqlName("SD3") + " SET D3_MARK='' WHERE D_E_L_E_T_='' AND D3_FILIAL='" + xFilial("SD3") + "' AND UPPER(D3_MARK)='X' AND D3_DTORIGI<>'' "
			TCSQLExec(_cUpd2) //Em caso de erro as flags são desfeitas
		Else
			If _nNumReg>1
				MsgInfo("Foram alterados " + AllTrim(Str(_nNumReg)) + " registros.", _cRotina + "_005")
			ElseIf _nNumReg==1
				MsgInfo("Foi alterado " + AllTrim(Str(_nNumReg)) + " registro.", _cRotina + "_006")
			Else
				MsgInfo("Não foi alterado nenhum registro.", _cRotina + "_007")
			EndIf
		EndIf
	EndIf
return