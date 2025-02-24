#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณMT100TOK  บAutor  ณAnderson C. P. Coelho บ Data ณ  03/06/13 บฑฑ
ฑฑบPrograma  ณMT100TOK  บAutor  ณJ๚lio Soares          บ Data ณ  05/07/13 บฑฑ
ฑฑบPrograma  ณMT100TOK  บAutor  ณJ๚lio Soares          บ Data ณ  13/07/15 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de Entrada para a valida็ao do campo chave NFE no    บฑฑ
ฑฑบ          ณ Documento de Entrada.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDesc      ณ Implementado trecho par valida็ใo do documento de entrada  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especifico para a empresa Arcolor.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MT100TOK()

Local _aArea   := GetArea()
Local _cRotina := "MT100TOK"
Local _lRet    := .T.
Local _TpTES   := SuperGetMV("MV_TDESD1",,"402|403")
Local _cMsg    := ""
Local _nVez    := 0
Local _lEnt    := CHR(10) + CHR(13)
Public _nfOrig := ''
Public _srOrig := ''

// Linha incluida por J๚lio Soares em 05/07/2013 para validar o ponto de entrada apenas no documento de entrada e solucionar
// error log na inutiliza็ใo da nota que informa a falta da variแvel cEspecie.
If Upper(AllTrim(FunName()))=="MATA103" 
	// Validacao de preenchimento da chave NFE (aNFEDanfe[13]), para notas de especie SPED, quando nao se tratar de formulario
	// pr๓prio.
	If (AllTrim(cEspecie) == "SPED" .AND. UPPER(AllTrim(cFormul)) == "N") .AND. Empty(aNFEDanfe[13])
		_cMsg += IIF(!Empty(_cMsg),;
		_lEnt + "Para notas fiscais eletr๔nicas, informe a chave de acesso do documento.",;
		"Para notas fiscais eletr๔nicas, informe a chave de acesso do documento.")
		_lRet := .F.
	EndIf
	// Implementado valida็ใo para uso de TES especํficas.
	For _x := 1 To Len(aCols)
		If (acols[_x][aScan(aHeader,{|x|Alltrim(x[2]) == "D1_TES"})]) $ (_TpTES)
			If (cSerie) <> "ZZZ"
				_cMsg += IIF(!Empty(_cMsg),;
				_lEnt + "Verifique a s้rie do documento para uso do TES utilizado no item "+;
				(acols[_x][aScan(aHeader,{|x|Alltrim(x[2]) == "D1_ITEM"})]),;
				"Verifique a s้rie do documento para uso do TES utilizado no item "+;
				(acols[_x][aScan(aHeader,{|x|Alltrim(x[2]) == "D1_ITEM"})]))
				_lSerie := .F.
			EndIf
			If (cEspecie) <> "NFE"
				_cMsg += IIF(!Empty(_cMsg),_lEnt +;
				"Verifique a esp้cie do documento para uso do TES utilizado no item "+;
				(acols[_x][aScan(aHeader,{|x|Alltrim(x[2]) == "D1_ITEM"})]),;
				"Verifique a esp้cie do documento para uso do TES utilizado no item "+;
				(acols[_x][aScan(aHeader,{|x|Alltrim(x[2]) == "D1_ITEM"})]))
				_lEspec := .F.
			EndIf
		EndIf
	Next
	If !Empty(_cMsg)
		MSGBOX(_cMsg,_cRotina + "_001","ALERT")
		_lRet := .F.
	EndIf

EndIf
// validar condi็ใo de pagamento.
RestArea(_aArea)

Return(_lRet)