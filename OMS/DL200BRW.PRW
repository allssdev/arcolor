#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DL200BRW  �Autor  �J�lio Soares        � Data �  08/08/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada com objetivo de incluir caracteristicas   ���
���          � de campos especificos no arquivo temporario de pedidos     ���
���          � na montagem de carga.                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function DL200BRW()
	Local  _cRotina := 'DL200BRW'
	Public _aCpoBrw := PARAMIXB
	AADD(_aCpoBrw,{"PED_SERIE",,"Serie"     })
	AADD(_aCpoBrw,{"PED_NOTA" ,,"Doc.Saida" })
	AADD(_aCpoBrw,{"PED_EMISS",,"Dt.Emissao"})
return _aCpoBrw