#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT120TEL
@description Ponto de entrada utilizado para inclusão de campos customizado no cabeçalho do pedido de compras
@author  Adriano Leonardo
@since   11/07/2013
@version P12.1.25 - 1.00
@see https://allss.com.br
@history 03/02/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Adequação do fonte devido a rotina se comportar diferente na release 12.1.2210
/*/

User Function MT120TEL()

Local _aSavArea		:= GetArea()
Local _aSavSC7 		:= SC7->(GetArea())
Local _cRotina		:= "MT120TEL"
Local oNewDialog 	:= PARAMIXB[1]
Local aPosGet 	  	:= PARAMIXB[2]
Local aObj 			:= PARAMIXB[3]
Local nOpcx 		:= PARAMIXB[4]
Local _cAliasSX3    := GetNextAlias()
Public _cTabela		:= "SZE" //Especificações técnicas
Public _cCampo		:= "C7_ESPECIF"
Public _cEspecif	:= Space(TamSx3(_cCampo )[01])
Public _cCampo2		:= "C7_DEPART"
Public _cDepart		:= Space(TamSx3(_cCampo2)[01])


If !INCLUI .or. nOpcx == 6 
	_cEspecif := &("SC7->"+_cCampo)
	_cDepart  := &("SC7->"+_cCampo2)	
Else
	_aSavSY1 := SY1->(GetArea())
	_cDepart := "O" //Default
	dbSelectArea("SY1") //Compradores
	SY1->(dbSetOrder(3))  		//Filial + Usuario
	If SY1->(dbSeek(xFilial("SY1")+__cUserId))
		If SY1->Y1_DEPART=="C"
			_cDepart := "C" //Departamento de compras
		Else
			_cDepart := "O" //Outros departamentos
		EndIf
	EndIf
	RestArea(_aSavSY1)
EndIf

//Início - Trecho adicionado por Adriano Leonardo em 20/03/2014 para adição de novo campo no cabeçalho do pedido de compra
OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)		//OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.T.,,.F.,.F.)		
if Select(_cAliasSX3) <= 0
_aSavSX3 := SX3->(GetArea())
	(_cAliasSX3)->(dbSetOrder(2))
	If (_cAliasSX3)->(MsSeek(_cCampo2,.T.,.F.)) //Verifico a existência do campo
		@ 053,aPosGet[2,1]+550 SAY "Depto." OF oNewDialog PIXEL SIZE 060,006
		If Empty(X3CBOX()) //Verifico o contéudo de opções do campo para definir se é GET ou COMBOBOX
			@ 051,aPosGet[2,2]+525 MSGET _cDepart PICTURE PesqPict("SC7",_cCampo2) ;
				WHEN (Inclui .Or. Altera) .And. VisualSX3(_cCampo2) ;
				OF oNewDialog PIXEL SIZE 040,006
		Else
			@ 051,aPosGet[2,2]+525 MSCOMBOBOX aObj[11] VAR _cDepart ITEMS Separa(X3CBOX(),";") ;
				WHEN (Inclui .Or. Altera) .And. VisualSX3(_cCampo2) SIZE 045,050 ;
				OF oNewDialog PIXEL SIZE 040,006
		EndIf
		If !Inclui
			_cUserName := Upper(UsrRetName(SC7->C7_USERINC)) //Retorna o nome do usuário que incluiu o pedido
			//Exibe o nome do usuário que incluiu o pedido de compra
			If !Empty(_cUserName)
				@ 068,(aPosGet[2,1]+570) SAY "Resp.: " OF oNewDialog PIXEL SIZE 060,006
				@ 068,(aPosGet[2,2]+525) SAY UsrRetName(SC7->C7_USERINC) OF oNewDialog PIXEL SIZE 060,006
			EndIf
		EndIf
	EndIf
	RestArea(_aSavSX3)
EndIf

//Final  - Trecho adicionado por Adriano Leonardo em 20/03/2014 para adição de novo campo no cabeçalho do pedido de compra
@ 065,aPosGet[2,1]+450 SAY "Esp.Tecn." OF oNewDialog PIXEL SIZE 060,006
@ 062,(aPosGet[2,1]+500) MSGET _cEspecif PICTURE PesqPict("SC7",_cCampo) F3 CpoRetF3(_cCampo,_cTabela) ;
	WHEN (INCLUI .OR. ALTERA) .AND. VisualSX3(_cCampo) ;
	VALID ValidaCampo() ;
	OF oNewDialog PIXEL SIZE 040,006
//Adiciona novo folder no rodapé do pedido


AAdd(aTitles, 'Observacoes')

RestArea(_aSavSC7)
RestArea(_aSavArea)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidaCampoºAutor  ³Adriano Leonardo    º Data ³ 11/07/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função utilizada para validar o código de especificação    º±±
±±º          ³ técnica do produto.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ValidaCampo(_cCpoAux)

Local _aSavArea := GetArea()
Local _aAreaSZE := (_cTabela)->(GetArea())
Local _lRet 	:= .T.

dbSelectArea(_cTabela)
(_cTabela)->(dbOrderNickName("ZE_CODIGO"))
_lRet :=  (Empty(_cEspecif) .OR. (_cTabela)->(MsSeek(xFilial("SZE")+_cEspecif,.T.,.F.)))

RestArea(_aAreaSZE)
RestArea(_aSavArea)

Return(_lRet)
