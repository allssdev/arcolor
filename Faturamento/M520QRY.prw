#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ M520QRY   บAutor  ณJ๚lio Soares        บ Data ณ  11/05/13  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ TOTVS    ณ O ponto de entrada M520QRY serแ acionado ao acessar a      บฑฑ
ฑฑบ          ณ rotina Exclusใo de Doc. de Saida. Utilizado para           บฑฑ
ฑฑบ          ณ possibilitar o usuแrio inserir elementos na query do       บฑฑ
ฑฑบ          ณ filtro inicial.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada utilizado para incluir na Query o filtro  บฑฑ
ฑฑบ          ณ por carteira                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณProtheus 11 - Especํfico para a empresa Arcolor.(CD Control)บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบRela็ใo   ณ Essa rotina tem rela็ใo com o Execblock RFATE028, RFATE029,บฑฑ
ฑฑบ          ณ e os pontos de entrada M520QRY, M520FIL e M520BROW.        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function M520QRY()

Local _aSavArea := GetArea()
Local _cRotina  := "M520QRY"
Local _cQry     := ParamIXB[1]
Local _nPar2    := ParamIXB[2]
Local _cNota    := ""

If (FWCodEmp()+FWCodFil()) <> '0202' //.And. __cUserId <> '000000'
	/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	ฑฑบ MV_PAR01 := 1           //Marca็ใo/Sele็ใo บฑฑ
	ฑฑบ MV_PAR02 := 1           //Seleciona Itens  บฑฑ
	ฑฑบ MV_PAR03 := _dData1     //De Emissao       บฑฑ
	ฑฑบ MV_PAR04 := _dData2     //Ate Emissao      บฑฑ
	ฑฑบ MV_PAR05 := ""          //De Serie         บฑฑ
	ฑฑบ MV_PAR06 := "ZZZ"       //Ate Serie        บฑฑ
	ฑฑบ MV_PAR07 := ""          //De Documento     บฑฑ
	ฑฑบ MV_PAR08 := "ZZZZZZZZZ" //Ate Documento    บฑฑ
	ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออผฑฑ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
	_dData1 := MV_PAR03
	_dData2 := MV_PAR04
	*/

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExecblock chamado para apresentar a tela onde serแ realizada a busca das NF's atrav้s do pedidoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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

		//Os campos F2_FIMP e F2_ESPECIE estใo sendo manipulados para os documentos nao fiscais, para que seja possํvel passarem pela valida็ใo
		//definida no parโmetro MV_SPEDEXC, que ้ padrใo, mas voltada apenas para os documentos de esp้cie SPED
		_cQueU := " UPDATE " + RetSqlName("SF2")
		_cQueU += " SET F2_FIMP       = (CASE WHEN F2_ESPECIE = 'SPED' THEN F2_FIMP ELSE 'T' END), "
		_cQueU += "     F2_ESPECIE    = 'SPED' "
		_cQueU += " WHERE F2_ESPECIE <> 'SPED' "
		_cQueU += "   AND " + _cQry
//		MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_002.TXT",_cQueU)
		If TCSQLExec(_cQueU) < 0
			TCSQLError()
			MsgStop("Aten็ใo!!! Problemas no ajuste da esp้cie dos romaneios para fins de valida็ใo de exclusใo conforme o seu prazo permitido!",_cRotina+"_002")
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