#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFINEBBD  �Autor  �Anderson C. P. Coelho � Data �  20/12/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock para o retorno do desconto / dia para o CNAB     ���
���          �e boleto a receber do Banco do Brasil.                      ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFINEBBD(_cTipo)

Local _aSavArea  := GetArea()
Local _xRet      := IIF(EXISTBLOCK("RFINEBBV"),U_RFINEBBV(),SE1->(E1_SALDO-E1_SDDECRE+E1_SDACRES))*(SE1->E1_DESCFIN/100)
Local _nTpDat    := IIF(ValType(SEE->EE_TIPODAT)=="N",SEE->EE_TIPODAT,VAL(SEE->EE_TIPODAT))

Default _cTipo   := "V"		//V=Valor;D=Data

//Desconto calculado
_xRet := IIF(EXISTBLOCK("RFINEBBV"),U_RFINEBBV(),SE1->(E1_SALDO-E1_SDDECRE+E1_SDACRES))*(SE1->E1_DESCFIN/100)

If _cTipo == "D"
	//Muda para retorno da data (caracter) quando a chamada for pelo campo de data
	If _xRet > 0
		_xRet := GravaData(SE1->(E1_VENCTO-E1_DIADESC),.F.,_nTpDat)
	Else
		If _nTpDat <= 4
			_xRet := StrZero(0,6)
		Else
			_xRet := StrZero(0,8)
		EndIf
	EndIf
EndIf

RestArea(_aSavArea)

Return(_xRet)