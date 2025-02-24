#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA410LEG  �Autor  �J�lio Soares        � Data �  19/02/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada para alterar as descri��es das legendas    ���
���          �para as cores alteradas pelo ponto de entrada MA410COR      ���
���          �conforme solicita��o do cliente                             ���
�������������������������������������������������������������������������͹��
���Uso       � Espec�fico - ARCOLOR                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MA410LEG()

Local _aCores 	:= {}

If AllTrim(FWCodEmp()) == '01'
// Alterado por J�lio Soares em 10/12/2013 para adequar a nova legenda de expedi��o.
	_aCores 	:= {{'BR_CANCEL'   ,'Pedido cancelado'             },;
					{'ENABLE'      ,'Pedido em aberto'             },;
					{'BR_AMARELO'  ,'Pedido liberado'              },;
					{'BR_PINK'     ,'Pedido parcialmente faturado' },;
		 			{'DISABLE'     ,'Pedido totalmente faturado'   },;
					{'BR_LARANJA'  ,'Pedido expedido'              },;
					{'BR_PRETO'    ,'Bloqueado por regra'          },;
					{'BR_CINZA'    ,'Bloqueado por cr�dito'        }}
ElseIf AllTrim(FWCodEmp()) == '02'
	_aCores 	:= {{'ENABLE'      ,'Pedido em aberto'             },;
					{'BR_AMARELO'  ,'Pedido liberado'              },;
					{'BR_PINK'     ,'Pedido parcialmente expedido' },;
		 			{'BR_LARANJA'  ,'Pedido totalmente expedido'   },;
					{'BR_CANCEL'   ,'Pedido cancelado'             },;
					{'BR_CINZA'    ,'Pedido Bloqueado por cr�dito' },;
					{'BR_PRETO'    ,'Pedido Bloqueado por regra'   }}
EndIf

Return(_aCores)
/*
// _aCores original
Local _aCores 	:= {{'ENABLE'     ,'Pedido em aberto'             },;
		 			{'DISABLE'    ,'Pedido totalmente faturado'   },;
					{'BR_AMARELO' ,'Pedido liberado'              },;
					{'BR_AZUL'    ,'Bloqueado por regra'          },;
		 			{'BR_LARANJA' ,'Bloqueado por cr�dito'        },;
					{'BR_PINK'    ,'Pedido faturado parcialmente' },;
					{'BR_CANCEL'  ,'Pedido cancelado'             }}
					
*/