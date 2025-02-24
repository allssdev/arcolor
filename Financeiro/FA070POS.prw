#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*                                     
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA070POS  �Autor  �Thiago S. De Almeida   � Data � 27/12/12 ���
���          �          �Autor  �J�lio Soares           � Data � 20/01/14 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada utilizado antes da montagem da tela de    ���
���          � baixa do contas a receber.                                 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada utilizado para que os valores de juros e  ���
���          � multa sejam zerados antes da montagem do box de baixa.     ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
*/

User Function FA070POS()

Local _aSavArea := GetArea()


// - Trecho inserida por J�lio Soares em 20/01/2014 para que os valores de juros e multas venham com o valor zerado.
//nMulta := 0
//nJuros := 0
// - TRECHO INSERIDO EM 23/07/2014 POR J�LIO SOARES PARA TRATAR UMA FALHA ENCONTRADA NA ROTINA ONDE AO ALTERAR O TIPO DE BAIXA O JUROS ZERADO � RETORNADO POR REFRESH DENTRO DA ROTINA
// - DESSA FORMA O PERCENTUAL DE JUROS � GRAVADO COM 0 DIRETO NO TITULO E RESTAURADO NO PONTO DE ENTRADA "FA070TIT".
/*
while !RecLock("SE1",.F.) ; enddo 
	SE1->E1_PORCJUR := 0
SE1->(MSUnlock())
*/
// - Fim da altera��o.

If MsSeek(xFilial("SZ3") + __cUserId,.T.,.F.)
	If __cUserId $ SZ3->Z3_USERREC
		_aParam1 := STRTOKARR(GETMV("MV_CXFIN"), '/') // Parametro padr�o que define a banco, agencia, conta padr�o para baixas no contas a receber.
		cBanco   := _aParam1[1]
		cAgencia := _aParam1[2]
		cConta   := _aParam1[3]
	EndIf
EndIf

RestArea(_aSavArea)

Return()