#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ROMSE001     �Autor  �RENAN SANTOS     � Data �  09/19/16   ���
�������������������������������������������������������������������������͹��
���Desc.     � PE Para  Valida��o da rotina de manuten��o de cargas       ���
���          � Deleta os registros ZZZ e depois recupera os pedidos que   ���
���          � nao foram deletado.                                        ���
�������������������������������������������������������������������������͹��
���Uso       � AP11 - ARCOLOR                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function ROMSE001(cAlias,nRecno,nOpc)
	Local _aSvA    := GetArea()
	Local _aSvADAI := DAI->(GetArea())
	Local _aSvADAK := DAK->(GetArea())
	Local _aCodPed :={}
	Local _aSecCar :={}
	Local _aSequen :={}
	local _aRecno  :={}
	Local _cCarga  := DAK_COD
	Local _nRecno  := DAK->(RECNO())
	Local i        := 0
	Local _lAlter  := nOpc == 4
 
	dbselectArea("DAI")
	DAI->(dbSetOrder(1))
	DAI->(dbSeek(xFilial("DAI")+_cCarga))
	While !DAI->(EOF()) .AND. DAI->DAI_FILIAL == xFilial("DAI") .AND. DAI->DAI_COD == _cCarga
		//Alert(DAI->DAI_COD+" - "+ DAI->DAI_PEDIDO + " - "+ DAI->DAI_SEQUEN)
		If DAI->DAI_SERIE $ "ZZZ"
			AADD(_aCodPed,DAI->DAI_PEDIDO)
			AADD(_aSecCar,DAI->DAI_SEQCAR)
			AADD(_aSequen,DAI->DAI_SEQUEN)
			AADD(_aRecno,DAI->(RECNO()))		
			while !RecLock("DAI",.F.) ; enddo
				DAI->DAI_EXCMAN := "ROMSE001"
				DAI->(dbDelete()) // Efetua a exclus�o l�gica do registro posicionado. 
			//	DAI->DAI_SEQCAR := "ZZ"
	     	DAI->(MsUnLock()) // Confirma e finaliza a opera��o
	    EndIf
	    dbselectArea("DAI")
	    DAI->(dbSetOrder(1))
	    DAI->(dbSkip())
	EndDo

	dbselectArea("DAI")
	DAI->(dbSetOrder(1))
	DAI->(dbSeek(xFilial("DAI")+_cCarga))
	RestArea(_aSvADAK)
	OS200manut("DAK",_nRecno,4)

	If Len(_aCodPed) > 0
		dbselectArea("DAI")
		DAI->(dbSetOrder(1))
		DAI->(dbSeek(xFilial("DAI")+_cCarga))
		While !DAI->(EOF()) .AND. DAI->DAI_FILIAL == xFilial("DAI") .AND. DAI->DAI_COD == _cCarga
			_nRecno := DAI->(RECNO())//Salva o registro corrente
			for i   := 1 TO Len(_aCodPed) 
				If DAI->DAI_PEDIDO $ _aCodPed[i] .and. DAI->DAI_SERIE <> "ZZZ" 	
					DAI->(dbGoTo(DAI->(_aRecno[i])))//Posiciono no registro deletado
		  			while !RecLock("DAI",.F.) ; enddo
			  			DAI->(DBRECALL())//Recupero o registro deletado
			  			DAI->DAI_EXCMAN := ""
		  			DAI->(MsUnLock()) 
		     	    DAI->(dbGoTo(DAI->(_nRecno))) //RESTAURO a ordem DO WHILE PARA CONTINUA��O 	
		    	EndIf
		    next	 
			dbselectArea("DAI")
			DAI->(dbSetOrder(1))
		    DAI->(dbSkip())
		Enddo 
	EndIf
	RestArea(_aSvADAI)
	RestArea(_aSvADAK)
	RestArea(_aSvA)
return