#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MC050BUT  �Autor  �Anderson C. P. Coelho � Data �  21/05/15 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada para adi��o de bot�es na Consulta do      ���
���          �Kardex acessada na consulta do produto.                     ���
���          � LOCALIZA��O : Function MC050Con- Fun��o que monta a tela da���
���          �consulta de Produtos. O objetivo deste ponto de entrada �   ���
���          �permitir a inclus�o de bot�es de usu�rio na barra de        ���
���          �ferramentas da consulta de produtos.                        ���
���          � EM QUE PONTO: No inicio da Fun��o, antes de montar a       ���
���          �ToolBar da consulta; Deve ser usado para adicionar bot�es do���
���          �usuario na toolbar da consulta de produtos, atrav�s do      ���
���          �retorno de um Array com a estrutura do bot�o a adicionar.   ���
���          � Rotinas Envolvidas:                                        ���
���          � * MC030ARR;                                                ���
���          � * RMATC030;                                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MC050BUT()

Local aButtons

If ExistBlock("Mc030Con")
	aButtons := {{'GRAF3D', {|| U_Mc030Con("PE")}, OemtoAnsi("Kardex/Dia Quant."),"Kardex/Dia Quant."}}
EndIf

Return(aButtons)
