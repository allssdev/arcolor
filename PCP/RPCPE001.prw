#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RPCPE001  �Autor  �Alessandro Villar   � Data � 15/01/13    ���
�������������������������������������������������������������������������͹��
���Desc. � EXECBLOCK  para que quando o tipo de movimenta��o selecionada  ���
���      � contiver o parametro "Envia p/CQ" como sim, que n�o permita a  ���
���      � modifica��o do armazem no apontamento de produ��o.             ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor 			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RPCPE001()

Local _lRet    := .T.
Local _cRotina := "RPCPE001"
//Local _cTpMov := ""
//Local _cArm   := ""

//���������������������������������������������������������������������Ŀ
//� In�cio da Rotina                                                    �
//�����������������������������������������������������������������������
dbSelectArea("SF5")
SF5->(dbSetOrder(1)) //CHAVE FILIAL + CODIGO
If SF5->(MsSeek(xFilial("SF5") + SD3->D3_TM,.T.,.F.))
	If SF5->F5_ENVCQPR == "S"
		If M->D3_LOCAL <> Supergetmv("MV_CQ",,"98")
			MsgStop("Armaz�m digitado est� fora do definido no campo!",_cRotina+"_001")
            _lRet := .F.
        EndIf
    EndIf
EndIf

Return(_lRet)