#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � M520QRY   �Autor  �J�lio Soares        � Data �  11/05/13  ���
�������������������������������������������������������������������������͹��
��� TOTVS    � O ponto de entrada M520QRY ser� acionado ao acessar a      ���
���          � rotina Exclus�o de Doc. de Saida. Utilizado para           ���
���          � possibilitar o usu�rio inserir elementos na query do       ���
���          � filtro inicial.                                            ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada utilizado para incluir na Query o filtro  ���
���          � por carteira                                               ���
�������������������������������������������������������������������������͹��
���Uso       �Protheus 11 - Espec�fico para a empresa Arcolor.(CD Control)���
�������������������������������������������������������������������������ͼ��
���Rela��o   � Essa rotina tem rela��o com o Execblock RFATE028, RFATE029,���
���          � e os pontos de entrada M520QRY, M520FIL e M520BROW.        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function M520QRY()

Local _aSavArea := GetArea()
Local _cRotina  := "M520QRY"
Local _cQry     := ParamIXB[1]
Local _nPar2    := ParamIXB[2]
Local _cNota    := ""

If (FWCodEmp()+FWCodFil()) <> '0202' //.And. __cUserId <> '000000'
	/*
	��������������������������������������������������
	��������������������������������������������������
	��� MV_PAR01 := 1           //Marca��o/Sele��o ���
	��� MV_PAR02 := 1           //Seleciona Itens  ���
	��� MV_PAR03 := _dData1     //De Emissao       ���
	��� MV_PAR04 := _dData2     //Ate Emissao      ���
	��� MV_PAR05 := ""          //De Serie         ���
	��� MV_PAR06 := "ZZZ"       //Ate Serie        ���
	��� MV_PAR07 := ""          //De Documento     ���
	��� MV_PAR08 := "ZZZZZZZZZ" //Ate Documento    ���
	����������������������������������������������ͼ��
	��������������������������������������������������
	��������������������������������������������������
	_dData1 := MV_PAR03
	_dData2 := MV_PAR04
	*/

	//�����������������������������������������������������������������������������������������������Ŀ
	//�Execblock chamado para apresentar a tela onde ser� realizada a busca das NF's atrav�s do pedido�
	//�������������������������������������������������������������������������������������������������
	If ExistBlock("RFATE028")
		//_cNota := U_RFATE028(2)[2]
		_cNota := U_RFATE028(1)[2]
	EndIf
	If Type("_cNota")<>"C" .OR. Empty(_cNota)
		_cNota := "000000000000"
	EndIf
	If !Empty(_cNota)
		_cNota := FormatIn(_cNota,'/')
		_cQry  := "     F2_FILIAL          = '" + xFilial("SF2") + "' "
		_cQry  += " AND F2_EMISSAO   BETWEEN '" + DTOS(_dData1) + "' AND '" + DTOS(_dData2) + "' "
		_cQry  += " AND F2_SCOA            = '' "
		_cQry  += " AND D_E_L_E_T_         = '' "
		_cQry  += " AND (F2_DOC+F2_SERIE) IN "  + _cNota

		//Os campos F2_FIMP e F2_ESPECIE est�o sendo manipulados para os documentos nao fiscais, para que seja poss�vel passarem pela valida��o
		//definida no par�metro MV_SPEDEXC, que � padr�o, mas voltada apenas para os documentos de esp�cie SPED
		_cQueU := " UPDATE " + RetSqlName("SF2")
		_cQueU += " SET F2_FIMP       = (CASE WHEN F2_ESPECIE = 'SPED' THEN F2_FIMP ELSE 'T' END), "
		_cQueU += "     F2_ESPECIE    = 'SPED' "
		_cQueU += " WHERE F2_ESPECIE <> 'SPED' "
		_cQueU += "   AND " + _cQry
//		MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_002.TXT",_cQueU)
		If TCSQLExec(_cQueU) < 0
			TCSQLError()
			MsgStop("Aten��o!!! Problemas no ajuste da esp�cie dos romaneios para fins de valida��o de exclus�o conforme o seu prazo permitido!",_cRotina+"_002")
			Return()
		EndIf
		dbSelectArea("SF2")
		//_aSvF2Upd := SF2->(GetArea())
		//SF2->(dbGoBottom())
		//SF2->(dbGoTop())
		//RestArea(_aSvF2Upd)
		TCRefresh("SF2")
	EndIf
	//RestArea(_aSavArea)
EndIf

Return(_cQry)