#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATE061  �Autor  �Anderson C. P. Coelho � Data �  21/03/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Chamada da rotina de ajuste manual na libera��o de estoque ���
�������������������������������������������������������������������������͹��
���Uso       � MA455MNU - Especifico para a empresa Arcolor               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFATE061()

Local _cAlias   := Alias()
Local _nInd     := IndexOrd()
Local _nRecno   := Recno()
Local _cKey     := &(Alias()+"->("+IndexKey()+")")

A455LibAlt(_cAlias,_nRecno,0)

dbSelectArea(_cAlias)
(_cAlias)->(dbSetOrder(_nInd))
(_cAlias)->(dbGoTop())
Set SoftSeek ON
(_cAlias)->(dbSeek(_cKey))
Set SoftSeek OFF

Return