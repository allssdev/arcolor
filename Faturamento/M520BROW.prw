#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณM520BROW  บAutor  ณAnderson C. P. Coelho บ Data ณ  23/02/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณPonto de Entrada chamado antes da montagem do browse da telaบฑฑ
ฑฑบ          ณde exclusao dos documentos de saida, utilizado para refazer บฑฑ
ฑฑบ          ณa rotina chamada pela tecla F12 (parametros da rotina).     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณProtheus 11 - Especํfico para a empresa Arcolor.(CD Control)บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบRela็ใo   ณ Essa rotina tem rela็ใo com o Execblock RFATE028, RFATE029,บฑฑ
ฑฑบ          ณ e os pontos de entrada M520QRY, M520FIL e M520BROW.        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function M520BROW()

Local   _aSavArea := GetArea()
Local   _cMsg     := ""
Local   _cNota	  := ""

Private _cRotina  := "M520BROW"
Private _lEnt     := CHR(13) + CHR(10)

If (FWCodEmp()+ FWCodFil()) <> '0202'
	_cMsg := ">>>>> ATENวรO!!! <<<<<" + _lEnt
	_cMsg += "Por quest๕es de integridade dos processos internos, quando for excluir um documento de saํda, atente as seguintes considera็๕es: " + _lEnt
	//_cMsg += " * Os pedidos nใo podem retornar direto a estarem aptos a faturar. Precisarใo necessariamente ir para CARTEIRA (parโmetro '04' na tecla F12)! " + _lEnt
	_cMsg += "* SEMPRE exclua todos os documentos faturados em um mesmo dia, vinculados a um mesmo pedido de vendas (independente de sua s้rie)." + _lEnt + _lEnt
	_cMsg += "Em caso de d๚vidas entre em contato com o Administrador do sistema."
	MsgBox(_cMsg,_cRotina+"_001","ALERT")
//	Processa({|lEnd| AtuF2_OK()},"["+_cRotina+"] Integridade F2_OK","Readequando a marca็ใo dos registros para garantia de integridade...",.F.)
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
			MsgStop("Aten็ใo!!! Problemas no ajuste da esp้cie dos romaneios para fins de valida็ใo de exclusใo conforme o seu prazo permitido!",_cRotina+"_002")
			Return()
		EndIf
		dbSelectArea("SF2")
		TCRefresh("SF2")
		*/
	EndIf
EndIf

Return()