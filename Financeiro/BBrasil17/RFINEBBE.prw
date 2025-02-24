#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFINEBBE  �Autor  �Anderson C. P. Coelho � Data �  20/12/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock para o retorno da esp�cie do t�tulo para o banco,���
���          �conforme o t�po do t�tulo. Esta informa��o est� relacionada ���
���          �no par�metro 'MV_ESPTIT1' criado, conforme o exemplo abaixo:���
���          �  {{"NF","01"},{"DP","01"},{"RC","05"},{"CH","10"}}         ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFINEBBE()

Local _aSavArea := GetArea()
Local _aEspTit  := &(SuperGetMv('MV_ESTTIT1',,'{{"NF","01"},{"DP","01"},{"NP","02"},{"RC","05"},{"CH","10"},{"NDF","13"}}'))
Local _nPEsp    := aScan(_aEspTit,{|x|AllTrim(x[01])==AllTrim(SE1->E1_TIPO)})
Local _cRet     := StrZero(VAL(IIF(_nPEsp>0,_aEspTit[_nPEsp][02],"01")),2)

RestArea(_aSavArea)

Return(_cRet)