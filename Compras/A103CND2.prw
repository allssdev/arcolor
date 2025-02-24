#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � A103CND2  �Autor  � J�lio Soares      � Data �  03/08/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada utilizado para replicar a vari�vel aDuplic���
���          � para que ela possa ser utilizada no ponto de entrada       ���
���          � M103LSE2                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - espec�fico empresa ARCOLOR                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function A103CND2()

Local aDuplic   := PARAMIXB // - Manipula��es do usu�rio do array de duplicatas
Public _aDuplic := PARAMIXB

Return(aDuplic)