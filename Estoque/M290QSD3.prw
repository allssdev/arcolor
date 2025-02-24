#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � M290QSD3 �Autor  �Adriano Leonardo      � Data �  15/10/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada localizado no rec�lculo do lote econ�mico ���
���          � respons�vel por incluir filtros nos tipos de movimentos que���
���          � dever�o ser considerados no consumo m�dio do produto, com  ���
���          � base no cadastro de movimenta��es (SF5 - campo F5_CONSUMO).���
�������������������������������������������������������������������������͹��
���Uso       �Protheus 11 - Espec�fico para empresa Arcolor.              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function M290QSD3()

//Salvo a �rea de trabalho atual
Local _aSavArea  := GetArea()
//Vari�veis auxiliares
Local _cRotina	 := "M290QSD3"
Local _lRotAtiva := .T. //AllTrim(__cUserId)=='000000' //Rotina ativa?
Local _lRet		 := ""  //Retorno default
Local _cQuery 	 := ""

//Adiciona filtro a query utilizada no processamento do rec�lculo de lote econ�mico
_cQuery	:= " AND ISNULL((SELECT F5_CONSUMO FROM " + RetSqlName("SF5") + "(NOLOCK)"
_cQuery	+= " SF5 WHERE SF5.F5_CODIGO=SD3.D3_TM AND SF5.D_E_L_E_T_='' "
_cQuery	+= "AND SF5.F5_FILIAL= '" + xFilial("SF5") + "'),'S')<>'N' "
_cQuery += " AND SD3.D3_ESTORNO<>'S' "
If !Empty(_cQuery) .And. _lRotAtiva
	_lRet := _cQuery
EndIf

//Restauro a �rea salva anteriormente
RestArea(_aSavArea)
	
Return(_lRet)
