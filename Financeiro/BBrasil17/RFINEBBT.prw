#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFINEBBT  �Autor  �Anderson C. P. Coelho � Data �  20/12/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock para o retorno do n�mero do t�tulo para o CNAB   ���
���          �a receber do Banco do Brasil.                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFINEBBT()

Local _aSavArea := GetArea()
//Local _cRet     := LEFT(SE1->E1_PREFIXO,1,1)+RIGHT(SE1->E1_NUM,8)+LEFT(SE1->E1_PARCELA,1)
Local _cRet     := SUBSTR(SE1->E1_NUM,Len(SE1->E1_PARCELA),10-Len(SE1->E1_PARCELA))+SE1->E1_PARCELA
// - Inserido em 03/12/2015 por J�lio Soares para ajustar o n�mero do t�tulo no arquivo CNAB
//Local _cRet     := SUBSTR(SE1->E1_NUM,Len(Alltrim(SE1->E1_PARCELA)),10-Len(Alltrim(SE1->E1_PARCELA)))+(Alltrim(SE1->E1_PARCELA))

RestArea(_aSavArea)

Return(_cRet)