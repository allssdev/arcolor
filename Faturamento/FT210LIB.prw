#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "tbiconn.ch"
#define  _lEnt CHR(13) + CHR(10)
/*/{Protheus.doc} FT210LIB
@TODO Este ponto de entrada � executado ap�s a libera��o do pedido de venda bloqueado por regra de neg�cio. Somente o pedido de venda esta posicionado no momento da execu��o do ponto de entrada e na mesma transa��o da opera��o do sistema.
@description Ponto de entrada para realizar valida��o de permissao dos usu�rios conforme cadastro efetuado na tabela SZ2. Utilizado tamb�m para gravar as regras de neg�cios neste momento.
@author Renan Felipe
@since 29/12/2012
@version 1.0
@history 05/02/2014, J�lio Soares, Ajustes
@history 02/05/2014, Adriano Leonardo, Ajustes
@history 16/11/2016, Anderson Coelho (ALL System Solutions), Implementa��o do Novo Log para os Pedidos Liberados nas Regras
@history 29/04/2019, Anderson Coelho (ALL System Solutions), Trecho alterado para melhoria de perfomance. Conte�do anterior: SuperGetMV("MV_FIMREG",,STOD('20491231'))
@history 03/12/2019, Anderson Coelho (ALL System Solutions), N�mero do pedido alterado nas mensagens de sequencia "006" e "008", a pedido do Sr. Marco Antonio.
@type function
@see https://allss.com.br
/*/
user function FT210LIB()
//	local   _aSavArea := GetArea()
//	local   _aSavSC5  := SC5->(GetArea())
	local   _aSavSC6  := SC6->(GetArea())
	local   _aSavSUA  := SUA->(GetArea())
	local   _aIndSC5  := {}
	local   _cMsgLbRg := ""
	local   _cLogx    := ""
	local   _cAlias   := ""
//	local   _cFilter  := " (C5_BLQ == '1' .OR. C5_BLQ == '2') "		//SC5->(dbFilter())
//	local   _bFilSC5  := {|| FilBrowse("SC5",@_aIndSC5,@_cFilter) }
//	local   _oObj     := nil

	private _lRet     := .T.
	private _cRotina  := "FT210LIB"
	private _cNumPv   := SC5->C5_NUM

	dbSelectArea("SZ2")
	SZ2->(dbSetOrder(1))
	if SZ2->(MsSeek(xFilial("SZ2")+__cUserID,.T.,.F.))
		_nValmax  := SZ2->Z2_VALMAX
		_nDescMax := SZ2->Z2_PERCENT
		_cAlias   := GetNextAlias()
		BeginSql Alias _cAlias
			SELECT SUM(SC6.C6_VALOR) AS VALMAX
			FROM %table:SC6% SC6 (NOLOCK)
			WHERE SC6.C6_FILIAL = %xFilial:SC6%
			  AND SC6.C6_NUM    = %Exp:_cNumPv%
			  AND SC6.C6_BLQ   <> %Exp:'R'%
			  AND SC6.%NotDel%
		EndSql
		dbSelectArea(_cAlias)
		if !(_cAlias)->(EOF())
			if (_cAlias)->VALMAX > _nValmax
				MsgAlert("Valor do pedido '"+_cNumPv+"' superior ao permitido para libera��o!",_cRotina+"_001")
				dbSelectArea("SC5")
				while !Reclock("SC5",.F.) ; enddo
					SC5->C5_BLQ := "1"
				SC5->(MsUnLock())
			endif
			dbSelectArea("SC6")
			SC6->(dbSetOrder(1))
			if SC6->(MsSeek(xFilial("SC6")+_cNumPv,.T.,.F.))
				_nDescont := 0
				while !SC6->(EOF()) .AND. SC6->C6_FILIAL == xFilial("SC6") .AND. SC6->C6_NUM == _cNumPv
					if SC6->C6_BLQ == "R"
						if !(SC6->C6_ITEM +" - "+ SC6->C6_PRODUTO)$_cMsgLbRg
							_cMsgLbRg += _lEnt + Space(10) + SC6->C6_ITEM +" - "+ SC6->C6_PRODUTO + " - " + SC6->C6_DESCRI + " - R E S I D U O"
						endif
						dbSelectArea("SC6")
						SC6->(dbSetOrder(1))
						SC6->(dbSkip())
						Loop
					endif
					_nDescont := IIF( SC6->C6_PRUNIT > 0, (1 - (SC6->C6_PRCVEN / SC6->C6_PRUNIT) ) * 100, SC6->C6_DESCONT)
					if _nDescont > _nDescMax
						if !(SC6->C6_ITEM +" - "+ SC6->C6_PRODUTO)$_cMsgLbRg
							_cMsgLbRg += _lEnt + Space(10) + SC6->C6_ITEM +" - "+ SC6->C6_PRODUTO + " - " + SC6->C6_DESCRI
						endif
						if SC5->C5_BLQ <> "1"
							dbSelectArea("SC5")
							while !Reclock("SC5",.F.) ; enddo
								SC5->C5_BLQ := "1"
							SC5->(MsUnlock())
						endif
					endif
					dbSelectArea("SC6")
					SC6->(dbSetOrder(1))
					SC6->(dbSkip())
				enddo
				// - INSERIDO VALIDA��O DE ATUALIZA��O NA LIBERA��O DO PEDIDO
				if SuperGetMV("MV_INCREGR",,.F.) //Linha adicionada por Adriano Leonardo 25/02/2014 para inibir o cadastramento autom�tico das regras via par�metro
					if MSGBOX('Deseja atualizar os descontos do pedido "'+_cNumPv+'" liberado nas regras de neg�cios deste cliente, neste momento?',_cRotina+'_002','YESNO')
						/*
						dbClearAllFilter()
						dbSelectArea("SC5")
						SC5->(RetIndex("SC5"))
						SC5->(dbClearFilter())
						SC5->(TcRefresh("SC5"))
						SC5->(dbGoTop())
						RestArea(_aSavSC5)
						*/
						Atudesc()
						/*
						//_bFilSC5 := {|| FilBrowse("SC5",@_aIndSC5,@_cFilter,.T.) }
						//EVAL(_bFilSC5)
						dbSelectArea("SC5")
						Set Filter To 
						dbFilter()
						Set Filter To _cFilter
						SC5->(dbFilter())
						dbSelectArea("SC5")
						SC5->(dbSetOrder(1))
						//Set SoftSeek ON
						SC5->(dbSeek(xFilial("SC5") + _cNumPV))
						//Set SoftSeek OFF
						SC5->(dbGoTop())
						*/
					endif
				endif
			else
				MSGBOX("Itens do pedido n�o encontrados. Informe ao administrador do sistema!",_cRotina+"_003",'ALERT')
			endif
		endif
		dbSelectArea(_cAlias)
		(_cAlias)->(dbCloseArea())
		_cLogx := "Regra de neg�cio liberada manualmente."
		dbSelectArea("SC5")
		while !Reclock("SC5",.F.) ; enddo
			if SC5->(FieldPos("C5_LOGLIBR"))<>0
				SC5->C5_LOGLIBR := DTOC(Date()) + " - " + Time() + " - " + __cUserId + " - " + cUserName
			endif
			if SC5->(FieldPos("C5_LOGSTAT"))<>0
				_cLog           := Alltrim(SC5->C5_LOGSTAT)
				SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + ;
									" - " + UsrRetName(__cUserId) + _lEnt + _cLogx
			endif
		SC5->(MsUnLock())
		dbSelectArea("SUA")
		SUA->(dbOrderNickName("UA_NUMSC5"))
		if SUA->(MsSeek(xFilial("SUA") + _cNumPv,.T.,.F.))
			while !RecLock("SUA",.F.) ; enddo
				if SUA->(FieldPos("UA_STATSC9"))<>0
					SUA->UA_STATSC9 := ""
				endif
				if SUA->(FieldPos("UA_LOGSTAT"))<>0
					_cLog           := Alltrim(SUA->UA_LOGSTAT)
					SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt  + DTOC(Date()) + " - " + Time() + ;
										" - " + UsrRetName(__cUserId) +_lEnt  + _cLogx
				endif
			SUA->(MSUNLOCK())
		endif
	else
		_cLogx := "Tentativa de libera��o de regras frustrada: Usu�rio sem permissao para realizar a libera��o de regras de negocio!"
		MSGBOX(_cLogx,_cRotina+"_004",'ALERT')
		if AllTrim(SC5->C5_BLQ) <> "1"
			dbSelectArea("SC5")
			while !RecLock("SC5",.F.) ; enddo
				SC5->C5_BLQ := "1"
			SC5->(MsUnLock())
		endif
		dbSelectArea("SUA")
		SUA->(dbOrderNickName("UA_NUMSC5"))
		SUA->(MsSeek(xFilial("SUA") + _cNumPv,.T.,.F.))
	endif
	//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
	if ExistBlock("RFATL001")
		U_RFATL001(	_cNumPv,;
					SUA->UA_NUM,;
					_cLogx     ,;
					_cRotina    )
	endif
	if !Empty(_cMsgLbRg)
		_cMsgLbRg := "Percentual do Desconto dos itens abaixo, superior ao limite m�ximo permitido!" + _cMsgLbRg
		MSGBOX(_cMsgLbRg,_cRotina+"_005",'INFO')
	endif
	//dbClearAllFilter()
	//dbSelectArea("SC5")
	//SC5->(RetIndex("SC5"))
	//SC5->(dbClearFilter())
	//SC5->(TcRefresh("SC5"))
	//SC5->(dbGoTop())
	//_bFilSC5 := {|| FilBrowse("SC5",@_aIndSC5,@_cFilter,.T.) }
	//EVAL(_bFilSC5)
	//Set Filter To _cFilter
	//SC5->(dbFilter())
	//_oObj    := GetObjBrow()
	//_oObj:Default()
	//_oObj:Refresh()
	//RestArea(_aSavSC5)
	RestArea(_aSavSUA)
	RestArea(_aSavSC6)
	//RestArea(_aSavArea)
return _lRet
/*/{Protheus.doc} Atudesc (FT210LIB)
@description Rotina para a grava��o das regras de neg�cios a partir da tela de libera��o de regras.
@author Adriano Leonardo
@since 02/05/2014
@version 1.0
@history 21/11/2019, Anderson Coelho, Ajustes nas mensagens de alerta da rotina, a pedido do Sr. Marco Antonio.
@type function
@see https://allss.com.br
/*/
static function Atudesc()
	local   _cAliasTmp  := ""
	local   _dMV_FIMREG := SuperGetMV("MV_FIMREG",,STOD('20491231'))		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Vari�vel declarada para uso dentro do while para melhoria de perfomance, evitando assim que, no meio do loop, o sistema n�o tenha de ficar consultando o conte�do do par�metro.
	local   _cCodReg := ""
	if !AllTrim(SC5->C5_TIPO) $ "/D/B/"
		_cCli  := SC5->C5_CLIENTE
		_cLoja := SC5->C5_LOJACLI
		_cNum  := _cNumPv
		dbSelectArea("ACS")
		ACS->(dbOrderNickName("ACS_CODCLI")) //ACO_FILIAL+ACO_CODCLI+ACO_LOJA //Foi criado um indice de cliente + loja para tratamento da rotina na tabela.
		//if !MsSeek(xFilial("ACS") + Padr(_cCLi,TamSx3("ACS_CODCLI")[01]) + Padr(_cLoja,TamSx3("ACS_LOJA")[01]),.T.,.F.)
		if !ACS->(dbSeek(xFilial("ACS") + Padr(_cCLi,TamSx3("ACS_CODCLI")[01]) + Padr(_cLoja,TamSx3("ACS_LOJA")[01])))
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			if SA1->(MsSeek(xFilial("SA1") + _cCLi+_cLoja,.T.,.F.))
				_cCdRg := GetSx8Num("ACS","ACS_CODREG")
				ConfirmSX8()   // Confirma se a numera��o do cadastro (SX8)
				while !RecLock("ACS",.T.) ; enddo
					ACS->ACS_FILIAL := xFilial("ACS")
					ACS->ACS_CODREG := _cCdRg
					ACS->ACS_DESCRI := SA1->A1_NOME
					ACS->ACS_CODCLI := _cCli
					ACS->ACS_LOJA   := _cLoja
					ACS->ACS_TPHORA := "1"
					ACS->ACS_HORDE  := "00:00"
					ACS->ACS_HORATE := "23:59"
					ACS->ACS_DATDE  := dDataBase
					ACS->ACS_DATATE := STOD("20491231")
				ACS->(MSUNLOCK())
			else
				MsgStop("Aten��o! O cliente " + (_cCLi+_cLoja) + " n�o foi encontrado. Portanto, as Regras de Neg�cios n�o ser�o gravadas!",_cRotina+"_010")
				_lRet := .F.
				return(_lRet)
			endif
		endif
		_cCodReg   := ACS->ACS_CODREG
		_cAliasTmp := GetNextAlias()
		BeginSql Alias _cAliasTmp
			SELECT ISNULL(MAX(ACN_ITEM),'000') AS [ACN_ITEM]
			FROM %table:ACN% ACN (NOLOCK)
			WHERE ACN_FILIAL     = %xFilial:ACN%
			  AND ACN_CODREG     = %Exp:_cCodReg%
			  AND ACN.%NotDel%
		EndSql
		dbSelectArea(_cAliasTmp)
		if (_cAliasTmp)->(!EOF())
			_cMaxItem := (_cAliasTmp)->ACN_ITEM
		endif
		dbSelectArea(_cAliasTmp)
		(_cAliasTmp)->(dbCloseArea())
		if !Empty(_cCodReg)
			dbSelectArea("SC6")
			SC6->(dbSetOrder(1))
			if SC6->(MsSeek(xFilial("SC6") + Padr(_cNum,TamSx3("C6_NUM")[01]),.T.,.F.))
				while !(SC6->(EOF())) .AND. SC6->C6_FILIAL == xFilial("SC6") .AND. SC6->C6_NUM == Padr(_cNum,Len(SC6->C6_NUM))
					if SC6->C6_DESCONT == 0 .OR. !("Item do pedido de venda: "+AllTrim(SC6->C6_ITEM))$SC5->C5_OBSBLQ
						dbSelectArea("SC6")
						SC6->(dbSetOrder(1))
						SC6->(dbSkip())
						Loop
					endif
					_cPProd    := SC6->C6_PRODUTO
					_cPDescr   := SC6->C6_DESCRI
				  	_nPDesc1   := SC6->C6_DESCTV1
					_nPDesc2   := SC6->C6_DESCTV2
					_nPDesc3   := SC6->C6_DESCTV3
					_nPDesc4   := SC6->C6_DESCTV4
					_nPDesc    := SC6->C6_DESCONT
					dbSelectArea("ACN")
					ACN->(dbOrderNickName("ACN_CODREG"))
					//if ACN->(MsSeek(xFilial("ACN") + Padr(_cCodReg,Len(ACN->ACN_CODREG)) + Padr(_cPProd,Len(ACN->ACN_CODPRO)),.T.,.F.))
					if ACN->(dbSeek(xFilial("ACN") + Padr(_cCodReg,TamSx3("ACN_CODREG")[01]) + Padr(_cPProd,TamSx3("ACN_CODPRO")[01])))
						_nDescAnt := ACN->ACN_DESCON
						//03/12/2019, Anderson Coelho (ALL System Solutions), N�mero do pedido alterado nas mensagens de sequencia "006" e "008", a pedido do Sr. Marco Antonio.
						/*
						if _nPDesc > _nDescAnt .AND. MSGBOX('Deseja ALTERAR o desconto do produto ' +Alltrim(_cPProd) + ' - ' + Alltrim(_cPDescr) + ' de '+ ;
															Alltrim(STR(_nDescAnt)) + '% para ' + Alltrim(STR(_nPDesc)) + '%, relativo ao pedido de vendas "'+;
															_cNumPv+'", neste momento?',_cRotina+"_006","YESNO")
						*/
						if _nPDesc > _nDescAnt .AND. MSGBOX('Deseja ALTERAR o desconto do produto ' +Alltrim(_cPProd) + ' - ' + Alltrim(_cPDescr) + ' de '+ ;
															Alltrim(STR(_nDescAnt)) + '% para ' + Alltrim(STR(_nPDesc)) + '%?',_cRotina+"_006","YESNO")
							while !RecLock("ACN",.F.) ; enddo
								ACN->ACN_DESCON := _nPDesc
								ACN->ACN_DESCV1 := _nPDesc1
								ACN->ACN_DESCV2 := _nPDesc2
								ACN->ACN_DESCV3 := _nPDesc3
								ACN->ACN_DESCV4 := _nPDesc4
								ACN->ACN_USRALT := UsrRetName(__cUserId)
								ACN->ACN_DTALTR := DATE()
							ACN->(MsUnLock())
							//MSGBOX('Desconto alterado',_cRotina+'_07','INFO')
						endif
					else
					//03/12/2019, Anderson Coelho (ALL System Solutions), N�mero do pedido alterado nas mensagens de sequencia "006" e "008", a pedido do Sr. Marco Antonio.
					//	if _nPDesc > 0 .AND. MSGBOX('Deseja INCLUIR o desconto do produto ' + Alltrim(_cPProd) + ' - ' + Alltrim(_cPDescr) + ' para ' + Alltrim(STR(_nPDesc)) + '%, relativo ao pedido de vendas "'+_cNumPv+'", neste momento?',_cRotina+"_008","YESNO")
						If _nPDesc > 0 .AND. MSGBOX('Deseja INCLUIR o desconto do produto ' + Alltrim(_cPProd) + ' - ' + Alltrim(_cPDescr) + ' para ' + Alltrim(STR(_nPDesc)) + '%?',_cRotina+"_008","YESNO")
							while !RecLock("ACN",.T.) ; enddo
								_cMaxItem       := Soma1(_cMaxItem)
								ACN->ACN_FILIAL	:= xFilial("ACN")
								ACN->ACN_CODREG	:= Padr(_cCodReg,Len(ACN->ACN_CODREG))
								ACN->ACN_ITEM	:= _cMaxItem
								ACN->ACN_CODPRO	:= _cPProd
								ACN->ACN_DESCON := _nPDesc
								ACN->ACN_DESCV1 := _nPDesc1
								ACN->ACN_DESCV2 := _nPDesc2
								ACN->ACN_DESCV3 := _nPDesc3
								ACN->ACN_DESCV4 := _nPDesc4
								ACN->ACN_USRINC := __cUserId
								ACN->ACN_DTINCL := DATE()
								ACN->ACN_PROMOC := CriaVar("ACN_PROMOC")
								ACN->ACN_QUANTI	:= 999999.99			// A regra � inserida sempre com volume m�ximo
								ACN->ACN_DATINI := dDataBase
								ACN->ACN_DATFIM := _dMV_FIMREG			//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conte�do anterior: SuperGetMV("MV_FIMREG",,STOD('20491231'))
							ACN->(MsUnLock())
						endif
					endif
					dbSelectArea("SC6")
					SC6->(dbSkip())
					SC6->(dbSetOrder(1))
				enddo
			endif
		else
			MSGBOX('Produto ' + Alltrim(_cPProd) + " - " + Alltrim(_cPDescr) + ' n�o encontrado!',_cRotina+'_009','INFO')
		endif
	endif
return _lRet