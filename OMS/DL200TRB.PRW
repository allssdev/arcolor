#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � DL200TRB  �Autor  �J�lio Soares       � Data �  08/08/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Grava��o do Arquivo Tempor�rio da Carga.                   ���
���          � Ap�s a  inclus�o dos campos que ir�o gerar a estrutura do  ���
���          � arquivo tempor�rio de pedidos na montagem de carga. Os     ���
���          � campos adicionais dever�o ter suas caracter�sticas         ���
���          � (DL200BRW) e suas respectivas grava��es (OM200GRV).        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
//primeiro ponto a ser utilizado, monta o array com as colunas de nota e serie no _aCpo200
//User Function DL200TRB()Local aRet := PARAMIXBAADD(aRet,{"PED_QTLIB2" ,"N",14,2}) // Qtd Pedido 2a.U.M.Return aRet
user function DL200TRB()
	Local  _cRotina := 'DL200TRB'
	Public _aCpo200 := PARAMIXB
	AADD(_aCpo200,{"PED_SERIE","C",03,0})
	AADD(_aCpo200,{"PED_NOTA" ,"C",09,0})
	AADD(_aCpo200,{"PED_EMISS","D",08,0})
return _aCpo200