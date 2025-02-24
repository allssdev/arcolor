#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MTA120E  � Autor �Anderson C. P. Coelho � Data �  17/04/17 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada na exclus�o do pedido de compra, utilizado���
���          � para reverter o processo de gera��o das comiss�es.         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arcolor  .          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
user function MTA120E()
	Local _aSavArea := GetArea()
	Local _aSavSE3  := {}
	Local _aRecSE3  := {}
	Local _cRotina	:= "MTA120E"
	Local _lRet		:= .F.
	dbSelectArea("SE3")
	SE3->(dbGoTop())
	If SE3->(dbOrderNickName("E3_PEDCOM")) //Filial + Pedido de compra
		//If SE3->(MsSeek(xFilial("SE3")+SC7->C7_NUM,.T.,.F.))
			While SE3->(MsSeek(xFilial("SE3")+SC7->C7_NUM,.T.,.F.)) .AND. !SE3->(EOF())	//SE3->E3_FILIAL == xFilial("SE3") .AND. SE3->E3_PEDCOM == SC7->C7_NUM
				_lRet := .T.
				RecLock("SE3",.F.)
					SE3->E3_DATA    := STOD("")
					SE3->E3_PEDCOM  := ""
					SE3->E3_DEMONST := ""
				SE3->(MSUNLOCK())
				dbSelectArea("SE3")
				//SE3->(dbOrderNickName("E3_PEDCOM")) //Filial + Pedido de compra
				//SE3->(dbSkip())
			EndDo
			If _lRet
				MsgInfo("Processo de comiss�es estornado com sucesso. Informe o departamento financeiro!",_cRotina+"_001")
			EndIf
		//EndIf
	Else
		MsgAlert("Aten��o! Problemas foram encontrados no sistema. Reporte a seguinte mensagem ao Administrador (sua opera��o ocorrer� sem preocupa��es): "+_cRotina+"_002",_cRotina+"_002")
	EndIf
	//RestArea(_aSavSE3) - REMOVIDO POIS ESTAVA APRESENTANDO ERRO AO EXCLUIR PEDIDO DE COMPRAS
	RestArea(_aSavArea)
return(.T.)