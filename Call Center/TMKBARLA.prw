#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������ɱ�
���Programa  �TMKBARLA	�Autor  �Adriano Leonardo      � Data �  02/01/13 ���
�������������������������������������������������������������������������ͺ��
���Descri��o � Ponto de entrada para colocar bot�es na tela de atendimento���
���			 � do CALL CENTER. Inclus�o de bot�o para valida��o do atendi-���
���			 � mento.        	  										  ���
��������������������������������������������������������������������������ɱ�
��������������������������������������������������������������������������ɱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function TMKBARLA()
	//Salvo a �rea ativa no momento
	Local _aSavAr  := GetArea()
	Local _aBotoes := {}
	//Adiciona bot�o na barra lateral do atendimento
	If ExistBlock("RFATE002")
		aAdd(_aBotoes,{"POSCLI"     , {|| U_RFATE002(.T.,"")} ,"Valida��o"   })
	EndIf
	If ExistBlock("RTMKR008")
		aAdd(_aBotoes,{"EMAIL", {|| U_RTMKR008(.T.,"")} ,"Envio de E-mail"})
	EndIf
	If ExistBlock("RFINE011")
		SetKey( K_CTRL_F11, { || })
		SetKey( K_CTRL_F11, { || U_RFINE011("F11")})
		aAdd(_aBotoes,{"BUDGETY"    , {|| U_RFINE011("F11")} ,"Ficha Financeira"  })
	EndIf
	//Restauro as �reas originais
	RestArea(_aSavAr)
return(_aBotoes)