#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ M290QSD3 บAutor  ณAdriano Leonardo      บ Data ณ  15/10/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada localizado no recแlculo do lote econ๔mico บฑฑ
ฑฑบ          ณ responsแvel por incluir filtros nos tipos de movimentos queบฑฑ
ฑฑบ          ณ deverใo ser considerados no consumo m้dio do produto, com  บฑฑ
ฑฑบ          ณ base no cadastro de movimenta็๕es (SF5 - campo F5_CONSUMO).บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณProtheus 11 - Especํfico para empresa Arcolor.              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function M290QSD3()

//Salvo a แrea de trabalho atual
Local _aSavArea  := GetArea()
//Variแveis auxiliares
Local _cRotina	 := "M290QSD3"
Local _lRotAtiva := .T. //AllTrim(__cUserId)=='000000' //Rotina ativa?
Local _lRet		 := ""  //Retorno default
Local _cQuery 	 := ""

//Adiciona filtro a query utilizada no processamento do recแlculo de lote econ๔mico
_cQuery	:= " AND ISNULL((SELECT F5_CONSUMO FROM " + RetSqlName("SF5") + "(NOLOCK)"
_cQuery	+= " SF5 WHERE SF5.F5_CODIGO=SD3.D3_TM AND SF5.D_E_L_E_T_='' "
_cQuery	+= "AND SF5.F5_FILIAL= '" + xFilial("SF5") + "'),'S')<>'N' "
_cQuery += " AND SD3.D3_ESTORNO<>'S' "
If !Empty(_cQuery) .And. _lRotAtiva
	_lRet := _cQuery
EndIf

//Restauro a แrea salva anteriormente
RestArea(_aSavArea)
	
Return(_lRet)
