#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณMC030ARR  บAutor  ณAnderson C. P. Coelho บ Data ณ  21/05/15 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ LOCALIZAวรO :  Function  AddArray - Fun็ใo da Consulta do  บฑฑ
ฑฑบ          ณKardex responsแvel pela grava็ใo do array com os dados a    บฑฑ
ฑฑบ          ณserem apresentados na consulta.                             บฑฑ
ฑฑบ          ณ EM QUE PONTO:  Antes de adicionar no array principal os    บฑฑ
ฑฑบ          ณdados da tabela corrente (SD3). Este ponto de entrada       บฑฑ
ฑฑบ          ณpossibilita manipular os dados apresentados na consulta.    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Neste caso, estamos utilizando apenas para zerar os campos บฑฑ
ฑฑบ          ณde custo da consulta do Kardex padrใo do sistema.           บฑฑ
ฑฑบ          ณ Rotinas envolvidas:                                        บฑฑ
ฑฑบ          ณ * RMATC030;                                                บฑฑ
ฑฑบ          ณ * MC050BUT;                                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico para a empresa Arcolor.            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MC030ARR()

Local _cRotina  := "MC030ARR"
Local _aExpA1   := PARAMIXB[1]		//Itens da tela de consulta do Kardex
Local _cExpC2 := PARAMIXB[2]		//Alias que estแ sendo processado

If !("#"+__cUserId+"#")$SuperGetMv("MV_CUSKARD",,"#000000#000019#000045#000046#000047#000023#")
	nTotvEnt := nTotvSda := aSalAtu[02] := aSalAtu[09] := aSalAtu[10] := _aExpA1[09] := _aExpA1[10] := 0
	_aExpA1  := {}
//	aTrbp := aTrbTmp := {}
//	MsgStop("Processo nใo permitido. Acesse o Kardex/Dia Quant.!",_cRotina+"_001")
EndIf

Return(_aExpA1,_cExpC2)
