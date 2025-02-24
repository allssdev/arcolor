#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCADHEAD  �Autor  �Anderson C. P. Coelho � Data �  22/04/15 ���
�������������������������������������������������������������������������͹��
���Desc.     � Os pontos de entrada PCADHEAD e PCADLINE se encontram na   ���
���          �fun��o MaComViewPC.                                         ���
���          � S�o usados para inserir colunas na consulta de ULTIMOS     ���
���          �PEDIDOS na op��o do bot�o HISTORICO DE PRODUTOS no Pedido de���
���          �compras,o PCADLINE acrescenta elementos no array dos dados, ���
���          �e o PCADHEAD acrescenta os t�tulos das colunas.             ���
���          �                                                            ���
���          � O retorno do ponto de entrada PCADHEAD dever� ser um array ���
���          �contendo os titulos dos campos que ser�o exibidos na tela.  ���
���          �                                                            ���
���          � O retorno do ponto de entrada PCADLINE dever� ser um array ���
���          �contendo o conte�do dos campos que ser�o exibidos na tela.  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arcolor.            ���
���          � FUNCIONA EM CONJUNTO COM OS PONTOS DE ENTRADA PCADLINE() e ���
���          � PCADCOLH().                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function PCADHEAD()

Local _aSavArea := GetArea()
Local _aSavSA2  := SA2->(GetArea())
Local _aSavSE4  := SE4->(GetArea())
Local _aDet     := {}		//ParamIxb

/*
_aDet := {	RetTitle('C7_NUM'    ) ,;
			RetTitle('C7_ITEM'   ) ,;
			RetTitle('A2_NOME'   ) ,;
			RetTitle('C7_QUANT'  ) ,;
			RetTitle('C7_PRECO'  ) ,;
			RetTitle('C7_QUJE'   ) ,;
			RetTitle('C7_DATPRF' ) ,;
			RetTitle('C7_ANTEPRO') ,;
			RetTitle('C7_COND'   ) ,;
			RetTitle('C7_RESIDUO') }
*/

_aDet := {	RetTitle('C7_NUM'    ) ,;
			RetTitle('C7_ITEM'   ) ,;
			RetTitle('A2_NOME'   ) ,;
			RetTitle('C7_QUANT'  ) ,;
			RetTitle('C7_PRECO'  ) ,;
			RetTitle('C7_QUJE'   ) ,;
			RetTitle('C7_DATPRF' ) ,;
			RetTitle('C7_COND'   ) ,;
			RetTitle('C7_RESIDUO') }

RestArea(_aSavSE4 )
RestArea(_aSavSA2 )
RestArea(_aSavArea)

Return(_aDet)
