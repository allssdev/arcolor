#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa � FT100MNU �Autor  � Adriano L. de Souza � Data �  18/02/2014  ���
��������������������������������������������������������������������������͹��
���Desc.   � Ponto de entrada utilizado para inclus�o de bot�es na tela de ���
���Desc.   � regras de neg�cios.                                           ���
��������������������������������������������������������������������������͹��
���Uso P11  � Uso espec�fico Arcolor                                       ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������ͱ����
����������������������������������������������������������������������������*/

User Function FT100MNU()

Local _aSavArea := GetArea()

If ExistBlock("RFATA014")
	Aadd(aRotina,{'Incluir Padr�o'				,'U_RFATA014()' , 0 , 3,0,NIL})
EndIf

//In�cio - Trecho adicionado por Adriano Leonardo em 07/08/2014, para adi��o de bot�o na tela de regras de neg�cios
If ExistBlock("RFATE054")
	Aadd(aRotina,{'Manuten��o Produto/Grupo'	,'U_RFATE054()' , 0 , 3,0,NIL})
EndIf
//Final  - Trecho adicionado por Adriano Leonardo em 07/08/2014, para adi��o de bot�o na tela de regras de neg�cios

RestArea(_aSavArea)

Return()