#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M520BROW  �Autor  �Anderson C. P. Coelho � Data �  23/02/13 ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de Entrada chamado antes da montagem do browse da tela���
���          �de exclusao dos documentos de saida, utilizado para refazer ���
���          �a rotina chamada pela tecla F12 (parametros da rotina).     ���
�������������������������������������������������������������������������͹��
���Uso       �Protheus 11 - Espec�fico para a empresa Arcolor.(CD Control)���
�������������������������������������������������������������������������ͼ��
���Rela��o   � Essa rotina tem rela��o com o Execblock RFATE028, RFATE029,���
���          � e os pontos de entrada M520QRY, M520FIL e M520BROW.        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function M520BROW()

Local   _aSavArea := GetArea()
Local   _cMsg     := ""
Local   _cNota	  := ""

Private _cRotina  := "M520BROW"
Private _lEnt     := CHR(13) + CHR(10)

If (FWCodEmp()+ FWCodFil()) <> '0202'
	_cMsg := ">>>>> ATEN��O!!! <<<<<" + _lEnt
	_cMsg += "Por quest�es de integridade dos processos internos, quando for excluir um documento de sa�da, atente as seguintes considera��es: " + _lEnt
	//_cMsg += " * Os pedidos n�o podem retornar direto a estarem aptos a faturar. Precisar�o necessariamente ir para CARTEIRA (par�metro '04' na tecla F12)! " + _lEnt
	_cMsg += "* SEMPRE exclua todos os documentos faturados em um mesmo dia, vinculados a um mesmo pedido de vendas (independente de sua s�rie)." + _lEnt + _lEnt
	_cMsg += "Em caso de d�vidas entre em contato com o Administrador do sistema."
	MsgBox(_cMsg,_cRotina+"_001","ALERT")
//	Processa({|lEnd| AtuF2_OK()},"["+_cRotina+"] Integridade F2_OK","Readequando a marca��o dos registros para garantia de integridade...",.F.)
EndIf

Return()

Static Function AtuF2_OK()

Local _nCount := 0
Local _nTotCn := 0

If ExistBlock("RFATE028")
	_cNota := U_RFATE028(2)[2]
	If Type("_cNota")=="C" .AND. !Empty(_cNota)
		dbSelectArea("SF2")
		_nTotCn := RecCount()
		ProcRegua(_nTotCn)
		SF2->(dbGoTop())
		While !SF2->(EOF())
			_nCount++
			IncProc("Processando "+cValToChar(ROUND(_nCount/_nTotCn*100,0))+"%...")
			If !Empty(SF2->F2_OK) .AND. !SF2->(F2_DOC+F2_SERIE)$_cNota
				while !RecLock("SF2",.F.) ; enddo
					SF2->F2_OK := Space(Len(SF2->F2_OK))
				SF2->(MSUNLOCK())
			EndIf
			SF2->(dbSkip())
		EndDo
		SF2->(dbGoTop())
		/*
		_cNota := FormatIn(_cNota,'/')
		_cQueU := " UPDATE " + RetSqlName("SF2") + " SET F2_OK = '' WHERE (F2_DOC+F2_SERIE) NOT IN "  + _cNota
		MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",_cQueU)
		If TCSQLExec(_cQueU) < 0
			TCSQLError()
			MsgStop("Aten��o!!! Problemas no ajuste da esp�cie dos romaneios para fins de valida��o de exclus�o conforme o seu prazo permitido!",_cRotina+"_002")
			Return()
		EndIf
		dbSelectArea("SF2")
		TCRefresh("SF2")
		*/
	EndIf
EndIf

Return()