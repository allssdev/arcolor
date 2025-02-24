#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCADCOLH  �Autor  �Anderson C. P. Coelho � Data �  22/04/15 ���
�������������������������������������������������������������������������͹��
���Desc.     � O ponto de entrada PCADCOLH se encontra na fun��o          ���
���          �MaComViewPC.                                                ���
���          � Na montagem da tela de �ltimos pedidos, informa a descri��o���
���          �da �ltima coluna exibida pela rotina.                       ���
���          �                                                            ���
���          � Funciona em conjunto com os pontos de entrada PCADHEAD e���
���          �PCADLINE.                                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arcolor.            ���
���          � FUNCIONA EM CONJUNTO COM OS PONTOS DE ENTRADA PCADHEAD() e ���
���          �PCADLINE().                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function PCADCOLH()

Local _cDet     := RetTitle('C7_RESIDUO')		//ParamIxb

If ExistBlock("PCADHEAD")
	Return(U_PCADHEAD())
EndIf

Return(_cDet)