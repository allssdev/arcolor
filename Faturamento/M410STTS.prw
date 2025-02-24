#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} M410STTS
TODO Este ponto de entrada pertence � rotina de pedidos de venda MATA410(). Est� em todas as rotinas de altera��o, inclus�o, exclus�o e devolu��o de compras. Executado ap�s todas as altera��es no arquivo de pedidos terem sido feitas.
@description Ponto de Entrada ap�s a grava��o do pedido, utilizado para gravar as observa��es de bloqueio das regras de neg�cios do cabe�alho do pedido para o cabe�alho do atendimento.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 19/11/2013
@version 1.0
@type function
@history 22/10/2019, Anderson C. P. Coelho (ALL System Solutions), Retirado o lock customizado do registro que minimizava os riscos na libera��o dos pedidos de vendas pois, conforme relatado pela consultora L�via, o risco foi praticamente eliminado p�s migra��o do release P12.1.17 para o P12.1.25.
@see https://allss.com.br
/*/
user function M410STTS()
	local _aSavArea := GetArea()
	local _aSavSC5  := SC5->(GetArea())
	local _aSavSC6  := SC6->(GetArea())
	local _aSavSUA  := SUA->(GetArea())
	local _aSavSUB  := SUB->(GetArea())
//	local _cRotina  := "M410STTS"
//	local _cLockR   := "PEDIDO_"+SC5->C5_NUM+"_"+DTOS(Date())
	local _cLock    := GetTempPath()+"FT100RNI_"+AllTrim(SC5->C5_NUM)+cNumEmp+__cUserId+"_"+DTOS(Date())+".log"
	//private _cCamArq 	:= "D:\P11Valid\Protheus_Data\temp\"
	//private _cArquivo	:= "Memo_" + AllTrim(SC5->C5_NUM) + ".txt"
	dbSelectArea("SC6")
	SC6->(dbSetOrder(1))
	if SC6->(FieldPos("C6_EMISSAO"))<>0 .AND. SC6->(dbSeek(xFilial("SC6") + SC5->C5_NUM))
		while !SC6->(EOF()) .AND. SC6->C6_FILIAL == xFilial("SC6") .AND. SC6->C6_NUM == SC5->C5_NUM
			if SC6->C6_EMISSAO <> SC5->C5_EMISSAO .OR. SC6->C6_PRCVEN <> ROUND(SC6->C6_PRCVEN,2)
				while !RecLock("SC6",.F.) ; enddo
					SC6->C6_EMISSAO := SC5->C5_EMISSAO
					SC6->C6_PRCVEN := ROUND(SC6->C6_PRCVEN,2)
				SC6->(MSUNLOCK())
			endif
			dbSelectArea("SC6")
			SC6->(dbSetOrder(1))
			SC6->(dbSkip())
		enddo
	endif
	RestArea(_aSavSC6)
	//In�cio - Trecho adicionado por Adriano Leonardo em 17/02/2014
	//if File(_cCamArq+_cArquivo)
	//	if FErase(_cCamArq+_cArquivo) == -1
	//		MsgStop("N�o foi poss�vel excluir o arquivo tempor�rio " + _cArquivo + ", informe ao Administrador!",_cRotina+"_001")
	//	endif
	//endif
	//Final  - Trecho adicionado por Adriano Leonardo em 17/02/2014
	//if !empty(SC5->C5_OBSBLQ)
		dbSelectArea("SUB")
		SUB->(dbSetOrder(3))
		if MsSeek(xFilial("SUB") + SC5->C5_NUM,.T.,.F.)
			dbSelectArea("SUA")
			SUA->(dbSetOrder(1))
			if SUA->(MsSeek(xFilial("SUB") + SUB->UB_NUM,.T.,.F.))
				while !RecLock("SUA",.F.) ; enddo
					SUA->UA_OBSBLQ := SC5->C5_OBSBLQ
					//Atualizo a legenda do atendimento, caso o pedido seja enquadrado na regra ap�s altera��o
					if empty(SC5->C5_BLQ) .And. SUA->UA_STATSC9=="01"
						SUA->UA_STATSC9 := ""
					endif
				SUA->(MsUnLock())
			endif
		endif
	//endif
	//Ponto Adicionado para limpeza do campo C5_FLAGRN, referente aos logs das regras de neg�cios.
	if File(_cLock)
		FErase(_cLock)
	endif

	//Bloqueio realizado pelos P.E.s MA440VLD e MT410ACE e Desbloqueio realizado pelos P.E.s MT440GR, M410STTS e M410ABN
	//UnLockByName(_cLockR)
	//Leave1Code(_cLockR)

	RestArea(_aSavSUB)
	RestArea(_aSavSUA)
	RestArea(_aSavSC6)
	RestArea(_aSavSC5)
	RestArea(_aSavArea)
return
