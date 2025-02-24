#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FT100MRN  �Autor  �Anderson C. P. Coelho � Data �  27/12/12 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada para a inclus�o de bot�es na tela de regra���
���          �neg�cios.                                                   ���
���          � Neste caso, este Ponto de Entrada foi escolhido por ser    ���
���          �chamado logo ap�s a montagem dos GetDados da rotina e, com  ���
���          �isso, � utilizada para manipular o objeto oGetD3:BLINHAOK,  ���
���          �que cont�m a valida��o das linhas da terceira aba das regras���
���          �de neg�cios, para substitui��o da rotina padr�o Ft100LOk3   ���
���          �pela rotina RFATE010.                                       ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FT100MRN()

Local _aSavArea := GetArea()

If Type("oGetD3:BLINHAOK")=="B"
	oGetD3:BLINHAOK := {|x| IIF(ExistBlock("RFATE010"),ExecBlock("RFATE010"),Ft100LOk3())}
EndIf

RestArea(_aSavArea)

Return NIL