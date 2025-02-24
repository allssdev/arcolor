#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

#DEFINE CENT CHR(13) + CHR(10)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATE049  �Autor  �J�lio Soares        � Data �  02/07/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � ExecBlock utilizado para alterar o risco do cliente ap�s   ���
���          � a altera��o do tipo de divis�o ou c�digo da carteira.      ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa ARCOLOR                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFATE049()

Local _aSavArea := GetArea()
Local _cRisc    := SA1->A1_RISCO
Local _cObs     := Alltrim(SA1->A1_OBSGENR)

If AllTrim(M->A1_CDCART) == '17' .AND. AllTrim(M->A1_TPDIV) <> '4'
	_cRisc := 'E'
	M->A1_OBSGENR := _cObs + CENT + DTOC(Date()) + ' - ' + Time() +' - Usu�rio: ' + __cUserId + ' - Risco anterior: ' + _cRisc + CENT + "O TIPO DE DIVIS�O N�O � COMPAT�VEL COM A CARTEIRA 17."
Else
	_cRisc := SA1->A1_RISCO
EndIf

RestArea(_aSavArea)

Return(_cRisc)