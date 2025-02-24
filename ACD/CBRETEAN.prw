#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'
#Include 'TOTVS.ch'
#Include 'topconn.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � CBRETEAN	� Autor � Arthur Silva			 � Data �28/08/17 ���
��a����������������� �����������������������������������������������������ı�
���Descricao � O Ponto de Entrada � chamado no momento da leitura de      ���
���				etiquetas quando n�o utilizado o par�metro MV_ACDCB0.	  ���
��a����������������������������������������������������������������������Ĵ��
��a����������������������������������������������������������������������Ĵ��
��� Uso      � Protheus 11    -   Espec�fico Arcolor                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
// Retorno devera ser um array conforme abaixo:
// {codigo do produto,quantidade,lote,data de validade, numero de serie}
User Function CBRETEAN()

Local _aSavArea  := GetArea()
Local _aSavSB1   := SB1->(GetArea())
Local _aSavSB5   := SB5->(GetArea())
Local _aSavSLK   := SLK->(GetArea())

Local _aRet      := {}
Local _nQE       := 0
Local _cLote     := ''
Local _dValid    := ctod('')
Local _cNumSerie := Space(20)
Local _cCodBar   := Paramixb[01]
Local _cQrySB1 := GetNextAlias()

//10/06/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Adequa��o do fonte para buscar somente produtos desbloqueados.
BeginSql Alias _cQrySB1
	SELECT
		B1_COD, B1_CODBAR
	FROM SB1010 SB1
	WHERE SB1.%NotDel%
		AND B1_MSBLQL <> '1'
		AND B1_CODBAR = %Exp:_cCodBar%
EndSql

DbSelectArea(_cQrySB1)
(_cQrySB1)->(dbGoTop())
If Len(Alltrim(_cCodBar)) == 8 .OR. Len(Alltrim(_cCodBar)) == 13 .OR. Len(Alltrim(_cCodBar)) == 14
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(xFilial("SB1")+(_cQrySB1)->B1_COD,.T.,.F.))
		dbSelectArea("SB5")
		SB5->(dbSetOrder(1))
		If SB5->(MsSeek(xFilial("SB5")+(_cQrySB1)->B1_COD,.T.,.F.)) .AND. SB5->B5_TIPUNIT <> '0' //produtos com controle unit�rio
			_nQE := CBQEmb()
		Else
			_nQE := 1
		EndIf
		_aRet    := {(_cQrySB1)->B1_COD,_nQE,Padr(_cLote,TamSX3("CB8_LOTECT")[1]),_dValid,Padr(_cNumSerie,TamSX3("CB8_NUMSER")[1])}
	Else
		dbSelectArea("SLK")
		SLK->( dbSetOrder(1) )
		//If SLK->( MsSeek(xFilial("SLK")+Padr(_cCodBar,TamSX3("LK_CODBAR")[1]),.T.,.F.) )
		If  SLK->( MsSeek(xFilial("SLK")+_cCodBar))
			_aRet := {LK_CODIGO, LK_QUANT,Padr(_cLote,TamSX3("CB8_LOTECT")[1]),_dValid,Padr(_cNumSerie,TamSX3("CB8_NUMSER")[1])}
		EndIf
	EndIf
EndIf   
/*
If Len(Alltrim(_cCodBar)) == 8 .OR. Len(Alltrim(_cCodBar)) == 13 .OR. Len(Alltrim(_cCodBar)) == 14
	dbSelectArea("SB1")
	SB1->(dbSetOrder(5))
	If SB1->(MsSeek(xFilial("SB1")+Padr(_cCodBar,TamSX3("B1_CODBAR")[1]),.T.,.F.))
		dbSelectArea("SB5")
		SB5->(dbSetOrder(1))
		If SB5->(MsSeek(xFilial("SB5")+SB1->B1_COD,.T.,.F.)) .AND. SB5->B5_TIPUNIT <> '0' //produtos com controle unit�rio
			_nQE := CBQEmb()
		Else
			_nQE := 1
		EndIf
		_aRet    := {SB1->B1_COD,_nQE,Padr(_cLote,TamSX3("CB8_LOTECT")[1]),_dValid,Padr(_cNumSerie,TamSX3("CB8_NUMSER")[1])}
	Else
		dbSelectArea("SLK")
		SLK->( dbSetOrder(1) )
		//If SLK->( MsSeek(xFilial("SLK")+Padr(_cCodBar,TamSX3("LK_CODBAR")[1]),.T.,.F.) )
		If  SLK->( MsSeek(xFilial("SLK")+_cCodBar))
			_aRet := {LK_CODIGO, LK_QUANT,Padr(_cLote,TamSX3("CB8_LOTECT")[1]),_dValid,Padr(_cNumSerie,TamSX3("CB8_NUMSER")[1])}
		EndIf
	EndIf
EndIf                                        
*/
RestArea(_aSavSB1)
RestArea(_aSavSB5)
RestArea(_aSavSLK)
RestArea(_aSavArea)

Return _aRet
