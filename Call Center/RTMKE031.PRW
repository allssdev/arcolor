#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RTMKE031  �Autor  �Anderson C. P. Coelho � Data �  15/10/14 ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock utilizado para validar a digita��o dos descontos ���
���          �nos campos espec�ficos do Atendimento Call Center:          ���
���          � * UB_DESCTV1, conforme o par�metro MV_MAXDES1              ���
���          � * UB_DESCTV2, conforme o par�metro MV_MAXDES2              ���
���          � * UB_DESCTV3, conforme o par�metro MV_MAXDES3              ���
���          � * UB_DESCTV4, conforme o par�metro MV_MAXDES4              ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function RTMKE031()
	local _aSvAr   := GetArea()
	local _cRotina := "RTMKE031"
	local _lRet    := .T.

	if "M->UB_DESCTV"$__ReadVar .AND. AllTrim(FunName()) <> "RTMKI001" 
		if !(_lRet := &(__ReadVar)<=SuperGetMv("MV_MAXDES"+SubStr(__ReadVar,13,1),,15))
			MsgStop("ATEN��O! O desconto digitado est� fora do m�ximo permitido!",_cRotina+"_001")
		endif
	endif
	RestArea(_aSvAr)
return _lRet