#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �OS200ES2  �Autor  � J�lio Soares       � Data �  11/06/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada utilizado para apagar os campos de Carga e���
���          � Data da Carga nas tabelas do atendimento(SUA), pedidos de  ���
���          � venda(SC5) e cabe�alho dos Documentos de sa�da(SF2) ap�s o ���
���          � estorno da carga montada.                                  ���
�������������������������������������������������������������������������͹��
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa ARCOLOR.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function OS200ES2()

Local _aSavAr  := GetArea()
Local _cRotina := "OS200ES2"
Local _cCarga  := PARAMIXB[01]	//DAK->DAK_COD
Local _cSqCar  := PARAMIXB[02]	//DAK->DAK_SEQCAR

_cQUpd1 := "UPDATE " + RetSqlName("SUA") + " "
_cQUpd1 += "SET UA_DTCARGA   = '', UA_CARGA = '' "
_cQUpd1 += "WHERE D_E_L_E_T_ = '' "
_cQUpd1 += "  AND UA_FILIAL  = '" + xFilial("SUA") + "' "
_cQUpd1 += "  AND UA_CARGA   = '" + _cCarga        + "' "
If TCSQLExec(_cQUpd1) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_001")
EndIf
_cQUpd2 := "UPDATE " + RetSqlName("SC5") + " "
_cQUpd2 += "SET C5_DTCARGA   = '', C5_CARGA = '' "
_cQUpd2 += "WHERE D_E_L_E_T_ = '' "
_cQUpd2 += "AND C5_FILIAL    = '" + xFilial("SC5") + "' "
_cQUpd2 += "AND C5_CARGA     = '" + _cCarga + "' "
If TCSQLExec(_cQUpd2) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_002")
EndIf
_cQUpd3 := "UPDATE " + RetSqlName("SF2") + " "
_cQUpd3 += "SET F2_DTCARGA   = '', F2_CARGA = '' , F2_SEQCAR = '' "
_cQUpd3 += "WHERE D_E_L_E_T_ = '' "
_cQUpd3 += "AND F2_FILIAL    = '" + xFilial("SF2") + "' "
_cQUpd3 += "AND F2_CARGA     = '" + _cCarga + "' "
_cQUpd3 += "AND F2_SEQCAR    = '" + _cSqCar + "' "
If TCSQLExec(_cQUpd3) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_003")
EndIf
_cQUpd4 := "UPDATE " + RetSqlName("SE1") + " "
_cQUpd4 += "SET E1_CODCARG   = '' "
_cQUpd4 += "WHERE D_E_L_E_T_ = '' "
_cQUpd4 += "AND E1_FILIAL    = '" + xFilial("SE1") + "' "
_cQUpd4 += "AND E1_CODCARG   = '" + _cCarga + "' "
If TCSQLExec(_cQUpd4) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_004")
EndIf
_cQUpd5 := "UPDATE " + RetSqlName("SC9") + " "
_cQUpd5 += "SET C9_CARGA     = '', C9_SEQCAR = '' "
_cQUpd5 += "WHERE D_E_L_E_T_ = '' "
_cQUpd5 += "AND C9_FILIAL    = '" + xFilial("SC9") + "' "
_cQUpd5 += "AND C9_CARGA     = '" + _cCarga + "' "
_cQUpd5 += "AND C9_SEQCAR    = '" + _cSqCar + "' "
If TCSQLExec(_cQUpd5) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_005")
EndIf

RestArea(_aSavAr)

Return()