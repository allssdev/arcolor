#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณRFATE019  บAutor  ณAnderson C. P. Coelho บ Data ณ  25/02/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณRotina chamada na tecla F12 da tela de exclusao do documentoบฑฑ
ฑฑบ          ณde saida (chamada pelo Ponto de Entrada M520BROW e na       บฑฑ
ฑฑบ          ณvalidacao da pergunta '04' do grupo de perguntar MTA521 da  บฑฑ
ฑฑบ          ณtabela SX1), utilizada para nao permitir que o parametro 4  บฑฑ
ฑฑบ          ณda rotina seja configurado com conteudo diferente de '1'    บฑฑ
ฑฑบ          ณ(quando o docto.de saida for excluido, fara com que o pedidoบฑฑ
ฑฑบ          ณvolte a ficar em carteira, obrigatoriamente.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especifico para a empresa Arcolor.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RFATE019(_cChamada)

Local _cRotina    := "RFATE019"
Local _lRet       := .T.

Default _cChamada := ""

If ! __cUserId $ '000000'
	If _cChamada<>"VLDSX1"
		If !Pergunte("MTA521",.T.)
			_lRet := .F.
			Return(_lRet)
		EndIf
		aRotina[4][2] := "Ma521MarkB"
	EndIf
	If MV_PAR04<>1
		_lRet    := .F.
		MV_PAR04 := 1
		If _cChamada<>"VLDSX1"
			
			_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
			OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
			dbSelectArea(_cAliasSX1)
			(_cAliasSX1)->(dbSetOrder(1))
			If (_cAliasSX1)->(MsSeek("MTA521    04",.T.,.F.))
				RecLock(_cAliasSX1,.F.)
				(_cAliasSX1)->X1_PRESEL := MV_PAR04
				(_cAliasSX1)->(MSUNLOCK())
			EndIf
			If ExistBlock("RCFGASX1")
				U_RCFGASX1("MTA521    ","04",MV_PAR04)
			EndIf
			MsgAlert("Por questoes de integridade, a pergunta '4' foi fixada para permitir que os pedidos voltem sempre para carteira!",_cRotina+"_001")
		Else
			MsgAlert("Por questoes de integridade, a pergunta '4' nao podera ser configurada com conteudo diferente de '1' (Carteira)!",_cRotina+"_002")
		EndIf
	EndIf
EndIf

Return(_lRet)