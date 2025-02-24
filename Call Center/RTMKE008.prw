#INCLUDE "RWMAKE.CH"
#include "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RTMKE008  �Autor  �Alessandro Villar   � Data � 02/01/12    ���
���          �          �Autor  �J�lio Soares        � Data � 24/07/14    ���
�������������������������������������������������������������������������͹��
���Desc.     � EXECBLOCK  para que n�o seja permitida a digita��o de      ���
���          � quantidade que esteja fora do m�ltiplo definido no referido���
���          � campo no cadastro de produtos.                             ���
�������������������������������������������������������������������������͹��
���          � Melhoria da rotina implementada na valida��o do tipo de    ���
���          � opera��o.                                                  ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RTMKE008()

//���������������������������������������������������������������������Ŀ
//� Declara��o de Vari�veis                                             �
//�����������������������������������������������������������������������
Local _aSavAr  := GetArea()
Local _nMultip := 0
Local _lRet    := .T.
Local _nPQtde  := aScan(aHeader,{|x|AllTrim(x[02])==IIF(AllTrim(FUNNAME())=="MATA410","C6_QTDVEN" ,"UB_QUANT"  )})
Local _nPProd  := aScan(aHeader,{|x|AllTrim(x[02])==IIF(AllTrim(FUNNAME())=="MATA410","C6_PRODUTO","UB_PRODUTO")})
Local _cRotina := "RTMKE008"
Local _cTpOper := AllTrim(SuperGetMV("MV_FATOPER",,"01|ZZ|9")) // - Informa os tipos de opera��es que compoe o faturamento

//���������������������������������������������������������������������Ŀ
//� In�cio da Rotina                                                    �
//�����������������������������������������������������������������������
dbSelectArea("SB1")
_aSavSB1 := SB1->(GetArea())
SB1->(dbSetOrder(1))
If M->UA_TPOPER $ ("|"+_cTpOper+"|")
	If MsSeek(xFilial("SB1") + aCols[n][_nPProd],.T.,.F.)
		_nMultip := SB1->B1_QTMULT
		If (aCols[n][_nPQtde] % _nMultip)<>0	// Retorna o resto da divis�o do valor _cProd pelo _nMultip
			MsgAlert("Valor n�o � m�ltiplo, verifique no cadastro! O multiplo para o produto " + aCols[n][_nPProd] + " � de " + cValToChar(_nMultip) + ".",_cRotina+"_01 [B1_QTMULT]")
			_lRet:= .F.
		EndIf
	EndIf
EndIf

RestArea(_aSavSB1)
RestArea(_aSavAr)

Return(_lRet)