#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RPCPE002  �Autor  �Adriano Leonardo    � Data � 15/04/13    ���
�������������������������������������������������������������������������͹��
���Desc. � Rotina utilizada para retornar o numero sequencial das ordens  ���
���      � produ��o.                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���06/09/2021� Fernando B.   � Impress�o OP pela Gest�o OP Prevista       ���
��������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������͹��                  
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor 			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function RPCPE002()
Local _aSavArea   := GetArea()
Local _cDadosAux  := "GETSC2"
Local _cRet   	  := ""
Local _cQry 	  := ""

_cQry 	  := " SELECT MAX(C2_NUM)+1 AS [C2_NUM] "
_cQry 	  += " FROM " + RetSqlName("SC2") + " (NOLOCK) "
_cQry 	  += " WHERE C2_EMISSAO > '20130403' "
_cQry 	  += "   AND C2_FILIAL  = '" + xFilial("SC2") + "' "
_cQry 	  += "   AND UPPER(C2_NUM) NOT LIKE ('%A%') AND UPPER(C2_NUM) NOT LIKE ('%Z%')"
_cQry 	  += "   AND (CASE WHEN SUBSTRING(C2_NUM,1,1) = '9' THEN '0' ELSE '1' END ) = '1' "
//_cQry 	  += "   AND D_E_L_E_T_ = '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cDadosAux,.F.,.T.)
dbSelectArea(_cDadosAux)

_cRet := AllTrim(Str((_cDadosAux)->C2_NUM))
(_cDadosAux)->(dbCloseArea())

RestArea(_aSavArea)

return(_cRet)
