#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F040URET  �Autor  �J�lio Soares        � Data �  03/07/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada utilizado para inserir a cor LARANJA para ���
���          � t�tulos ainda n�o autorizados.                             ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa ARCOLOR.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function F040URET()

Local aRet := {}                      

If AllTrim(FunName())=="FINA040" .OR. AllTrim(FunName())=="FINA740" //Contas a receber ou Fun��es contas a receber
	AADD(aRet,{"E1_FLUXO =='N' ","BR_LARANJA"})
EndIf

Return aRet