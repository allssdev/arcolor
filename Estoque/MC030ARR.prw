#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MC030ARR  �Autor  �Anderson C. P. Coelho � Data �  21/05/15 ���
�������������������������������������������������������������������������͹��
���Desc.     � LOCALIZA��O :  Function  AddArray - Fun��o da Consulta do  ���
���          �Kardex respons�vel pela grava��o do array com os dados a    ���
���          �serem apresentados na consulta.                             ���
���          � EM QUE PONTO:  Antes de adicionar no array principal os    ���
���          �dados da tabela corrente (SD3). Este ponto de entrada       ���
���          �possibilita manipular os dados apresentados na consulta.    ���
���          �                                                            ���
���          � Neste caso, estamos utilizando apenas para zerar os campos ���
���          �de custo da consulta do Kardex padr�o do sistema.           ���
���          � Rotinas envolvidas:                                        ���
���          � * RMATC030;                                                ���
���          � * MC050BUT;                                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MC030ARR()

Local _cRotina  := "MC030ARR"
Local _aExpA1   := PARAMIXB[1]		//Itens da tela de consulta do Kardex
Local _cExpC2 := PARAMIXB[2]		//Alias que est� sendo processado

If !("#"+__cUserId+"#")$SuperGetMv("MV_CUSKARD",,"#000000#000019#000045#000046#000047#000023#")
	nTotvEnt := nTotvSda := aSalAtu[02] := aSalAtu[09] := aSalAtu[10] := _aExpA1[09] := _aExpA1[10] := 0
	_aExpA1  := {}
//	aTrbp := aTrbTmp := {}
//	MsgStop("Processo n�o permitido. Acesse o Kardex/Dia Quant.!",_cRotina+"_001")
EndIf

Return(_aExpA1,_cExpC2)
