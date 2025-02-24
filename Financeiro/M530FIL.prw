#INCLUDE "RWMAKE.CH"
#include "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � M530FIL  �Autor  �Adriano Leonardo    � Data �  14/06/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada respons�vel por filtrar o processamento da���
���          � rotina Atualiza Pagamento de Comiss�o, para n�o considerar ���
���          � as comiss�se geradas sobre baixas parciais.                ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function M530FIL()	
	//Filtra os t�tulos com baixas parciais
	_cFiltro := "( ( (Posicione('SE1',1,xFilial('SE1') + SE3->E3_PREFIXO + SE3->E3_NUM + SE3->E3_PARCELA + SE3->E3_TIPO,'E1_SALDO')==0) .OR. SE3->E3_COMIS < 0 ) .AND. Posicione('SA3',1,xFilial('SA3') + SE3->E3_VEND,'A3_GERASE2')<>'P' )"
return(_cFiltro)