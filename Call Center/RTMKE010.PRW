#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RTMKE010  �Autor  �Alessandro Villar   � Data �  26/03/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Execblock utilizado em gatilho para atualizar o campo de    ���
���          �desconto padr�o do sistema atraves do resultado do fator    ���
���          �descontos.                                                  ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RTMKE010()

Local _aSavArea := GetArea()
Local _nPFator  := aScan(aHeader,{|x|AllTrim(x[02])=="UB_FATOR"}) // 14
Local _nFator   := aCols[n][_nPFator]
Local __RVarBkp := __ReadVar  //M->UB_CODFATR
Local _cRVarBkp := &(__ReadVar)
Local _lValid   := .T.

__ReadVar    := "M->UB_DESC"
&(__ReadVar) := _nFator

_cAliasSX3 := "SX3_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
dbSelectArea(_cAliasSX3)
(_cAliasSX3)->(dbSetOrder(2))
If (_cAliasSX3)->(MsSeek(AllTrim(SubStr(__ReadVar,4)),.T.,.F.))
	If !Empty((_cAliasSX3)->X3_VALID + " " + (_cAliasSX3)->X3_VLDUSER)
		_lValid := &((_cAliasSX3)->X3_VALID + IIF(!Empty((_cAliasSX3)->X3_VALID).AND.!Empty((_cAliasSX3)->X3_VLDUSER),".AND."," ") + (_cAliasSX3)->X3_VLDUSER) //Valida��o do campo
	EndIf
EndIf
If _lValid .AND. ExistTrigger(SubStr(__ReadVar,4))
//	RunTrigger(2,_nLinha) // - Linha comentada em 16/09/2014 por J�lio Soares para corrigir problemas no gatilho.
	RunTrigger(2,n)
	EvalTrigger()
EndIf
(_cAliasSX3)->(dbCloseArea())

If ExistBlock("RTMKE037")
	ExecBlock("RTMKE037")
EndIf
__ReadVar    := __RVarBkp
&(__ReadVar) := _cRVarBkp

RestArea(_aSavArea)

Return(_nFator)
