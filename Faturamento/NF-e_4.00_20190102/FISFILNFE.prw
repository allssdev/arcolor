#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FISFILNFE �Autor  �Anderson C. P. Coelho � Data �  14/05/15 ���
�������������������������������������������������������������������������͹��
���Desc.     � Este ponto de entrada foi disponibilizado a fim de permitir���
���          �altera��o no filtro do usu�rio administrador na SPEDNFE.    ���
���          �                                                            ���
���          � Neste caso, estamos utilizando esta rotina apenas para     ���
���          �preservar, na vari�vel p�blica "_cMV_01_NFE", o conte�do do ���
���          �par�metro 01 da rotina da NFe, para identifica��o do tipo de���
���          �nota fiscal a ser apresentada no Browse.                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FISFILNFE()

Public _cMV_01_NFE := MV_PAR01

Return(cCondicao)