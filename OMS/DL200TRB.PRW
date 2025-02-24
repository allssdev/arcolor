#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DL200TRB  บAutor  ณJ๚lio Soares       บ Data ณ  08/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava็ใo do Arquivo Temporแrio da Carga.                   บฑฑ
ฑฑบ          ณ Ap๓s a  inclusใo dos campos que irใo gerar a estrutura do  บฑฑ
ฑฑบ          ณ arquivo temporแrio de pedidos na montagem de carga. Os     บฑฑ
ฑฑบ          ณ campos adicionais deverใo ter suas caracterํsticas         บฑฑ
ฑฑบ          ณ (DL200BRW) e suas respectivas grava็๕es (OM200GRV).        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico para a empresa Arcolor.            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//primeiro ponto a ser utilizado, monta o array com as colunas de nota e serie no _aCpo200
//User Function DL200TRB()Local aRet := PARAMIXBAADD(aRet,{"PED_QTLIB2" ,"N",14,2}) // Qtd Pedido 2a.U.M.Return aRet
user function DL200TRB()
	Local  _cRotina := 'DL200TRB'
	Public _aCpo200 := PARAMIXB
	AADD(_aCpo200,{"PED_SERIE","C",03,0})
	AADD(_aCpo200,{"PED_NOTA" ,"C",09,0})
	AADD(_aCpo200,{"PED_EMISS","D",08,0})
return _aCpo200