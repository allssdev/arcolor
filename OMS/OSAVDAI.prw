#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OSAVDAI   ºAutor  ³Júlio Soares        º Data ³  02/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Este Ponto de Entrada permite validar a gravação de dados   º±±
±±º          ³dentro das tabelas DAK, DAI, SC9 e SF2, de  acordo com o    º±±
±±º          ³evento solicitado.Localizado dentro da função OsAvalDAI().  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Especifico para a empresa Arcolor.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function OSAVDAI()

Local _aSavArea := GetArea()
Local _aSavSF2  := SF2->(GetArea())
Local _aSavSC9  := SC9->(GetArea())
Local _aSavDAI  := DAI->(GetArea())
Local _aSavDAK  := DAK->(GetArea())
Local lRet      := .T.
Local nEvento   := PARAMIXB[1]
Local _cRotina  := 'OSAVDAI'
Local _cDoc     := ''
Local _cSerie   := ''

//MSGBOX('* ALERT *',_cRotina,'ALERT')

//DAI->(dbSetOrder(4)) // - DAI_FILIAL + DAI_PEDIDO + DAI_COD + DAI_SEQCAR
//If (DAI->(DAI_PEDIDO)) + (DAI->(DAI_COD)) + (DAI->(DAI_SEQCAR)) == (SC9->(C9_PEDIDO)) + (SC9->(C9_CARGA)) + (SC9->(C9_SEQCAR))

/*
_cQuery := " SELECT E1_PEDIDO,E1_EMISSAO,SUM(E1_VALOR)[E1_VALOR] "
_cQuery += " FROM SE1010 SE1 "
_cQuery += " WHERE SE1.D_E_L_E_T_ = '' "
_cQuery += " AND SE1.E1_PEDIDO = '" + (SC9->(C9_PEDIDO)) + "' "
_cQuery += " GROUP BY E1_PEDIDO,E1_EMISSAO "
*/
//Alert(cvaltochar(nEvento)) 

// 
//Alert(SC9->C9_NFISCAL)

if DAI->(DAI_SERIE) = "ZZZ"
 lRet      := .F.
eNDIF
 
 
	dbSelectArea("SF2")
	SF2->(dbSetOrder(2))
	//If SF2->(MsSeek(xFilial("SF2")+SC9->C9_CLIENTE+SC9->C9_LOJA+SC9->C9_NFISCAL+SC9->C9_SERIENF,.T.,.F.)) 
	If SF2->(dbSeek(xFilial("SF2")+SC9->C9_CLIENTE+SC9->C9_LOJA+SC9->C9_NFISCAL+SC9->C9_SERIENF)) 
		_nPeso  := SF2->F2_PBRUTO
		_nVol   := SF2->F2_VOLUME1
		_nValor := SF2->F2_VALBRUT
		_cSerie := SF2->F2_SERIE
		_cDoc   := SF2->F2_DOC
//		If (_cDoc + _cSerie) <> (SC9->(C9_NFISCAL)+SC9->(C9_SERIENF))
			dbSelectArea("DAI")
			DAI->(dbSetOrder(3))
			If DAI->(DBSeek(xFilial("DAI")+SC9->C9_NFISCAL+SC9->C9_SERIENF+SC9->C9_CLIENTE +SC9->C9_LOJA)) 
				RecLock("DAI",.F.)
					DAI->DAI_NFISC2 := _cDoc//SC9->(C9_NFISCAL)
					DAI->DAI_SERIE2 := _cSerie//SC9->(C9_SERIENF)
					DAI->DAI_PESO2  := _nPeso //POSICIONE("SF2",1,xFilial("SF2")+(SC9->(C9_NFISCAL))+(SC9->(C9_SERIENF)),"F2_PBRUTO")
					DAI->DAI_VALOR2 := _nValor
					DAI->DAI_VOLUM2 := _nVol
				DAI->(MsUnlock())
			ENDIF
//		EndIf
	EndIf



RestArea(_aSavSF2)
RestArea(_aSavSC9)
RestArea(_aSavDAI)
RestArea(_aSavDAK)
RestArea(_aSavArea)

Return(lRet)