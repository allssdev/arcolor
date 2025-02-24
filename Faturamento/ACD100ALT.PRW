#include "totvs.ch"
/*/{Protheus.doc} ACD100ALT()
@description Permite  incluir validações particulares referentes à alteração das órdens de separação. No final da função, após a gravação da alteração da Órdem de Separação.
@author  Adriano Leonardo
@since   01/10/2013
@version P12.1.25 - 1.00
@see https://allss.com.br
@history 10/09/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Criação de log para registro dos produtos que foram removidos da ordem de separação
@history 10/10/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Criação de validação para estornar os itens que foram excluidos da tabela SC9.

/*/

User Function ACD100ALT()	

Local nX        := 0
Local lRet      := .F. 
Local _aSavArea := GetArea()
Local _aSavSC5  := SC5->(GetArea())
Local _aSavSC6  := SC6->(GetArea())
Local _aSavSC9  := SC9->(GetArea())
Local _cLogx    := ""
Local _cLog     := ""
Local _lEnt     := CHR(13)+CHR(10)
Local nPosPed   := aScan(aHeader,{|x|Alltrim(x[2])=="CB8_PEDIDO"})
Local nPosCod  := aScan(aHeader,{|x|Alltrim(x[2])=="CB8_PROD"})
Local nPosQtd  := aScan(aHeader,{|x|Alltrim(x[2])=="CB8_QTDORI"})


for nX := 1 to len(aCols)
    lRet := aCols[nX][25]
    If lRet
    _cPedido := aCols[nX][nPosPed]
    _cProd   := aCols[nX][nPosCod]
    _nQtd    := aCols[nX][nPosQtd]
    
        dbSelectArea("SC5")
        SC5->(dbSetOrder(1))
        SC5->(MsSeek(xFilial("SC5") + _cPedido,.T.,.F.))

            _cLogx := "Qtde. cortada após ordem de separação gerada: " + Alltrim(_cProd) + " / " + cValtoChar(_nQTd) + " Unidades"
            SUA->(dbOrderNickName("UA_NUMSC5"))
            If SUA->(MsSeek(xFilial("SUA") + _cPedido,.T.,.F.))
                _cLog  := Alltrim(SUA->UA_LOGSTAT)
                If SUA->(FieldPos("UA_LOGSTAT"))>0
                    RecLock("SUA", .F.)
                        SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
                        UsrRetName(__cUserId) + _lEnt + _cLogx
                    SUA->(MsUnLock())
                EndIf
            EndIf
            dbSelectArea("SC5")
            SC5->(dbSetOrder(1))
            If SC5->(MsSeek(xFilial("SC5") + _cPedido,.T.,.F.))
                _cLog := Alltrim(SC5->C5_LOGSTAT)
                If SC5->(FieldPos("C5_LOGSTAT"))>0
                    RecLock("SC5",.F.)
                        SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
                        UsrRetName(__cUserId) + _lEnt + _cLogx
                    SC5->(MsUnLock())
                EndIf
            EndIf
        // Customizações do cliente
        //16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
        If ExistBlock("RFATL001")
            U_RFATL001(	SC5->C5_NUM,;
                        SUA->UA_NUM,;
                        _cLogx     ,;
                        _cRotina    )
        EndIf
   
//Função para estornar o registro da tabela SC9 após a exclusão de produto na administração da ordem de separação

    SC9->(DbSetOrder(15))
	cAliasSC9 := GetNextAlias()
	BeginSql Alias cAliasSC9
		SELECT C9_PEDIDO,C9_ITEM,C9_PRODUTO,C9_LOTECTL,C9_LOCAL, C9_QTDLIB, C9_ORDSEP
		FROM %table:SC9% SC9 (NOLOCK)
		WHERE C9_FILIAL  = %xFilial:SC9%
		 	AND C9_PEDIDO = %Exp:_cPedido%
			AND C9_NFISCAL = ''
            AND C9_PRODUTO = %Exp:_cProd%
            AND C9_ORDSEP = ''
		 	AND SC9.%NotDel%
		ORDER BY C9_PEDIDO,C9_ITEM,C9_PRODUTO
	EndSql	 

		(cAliasSC9)->(DbGotop())
		While (cAliasSC9)->(!EOF()) .and. (cAliasSC9)->C9_PEDIDO == _cPedido
			If SC9->(MsSeek(xFilial("SC9")+(cAliasSC9)->C9_PEDIDO+(cAliasSC9)->C9_ITEM))	
					//SDC->(dbGoTo((cAliasSC9)->SDCREC))
					//While SC9->(!EOF()) .and. (cAliasSC9)->C9_PRODUTO == SC9->C9_PRODUTO .and. cOrdSep == SC9->C9_ORDSEP
						dbSelectArea("SDC")//é dessa forma para refazer a SDC no estorno da SC9
						DBSetOrder(1) 
						If	dbSeek(xFilial("SDC") + (cAliasSC9)->C9_PRODUTO + (cAliasSC9)->C9_LOCAL + "SC6" + (cAliasSC9)->C9_PEDIDO + (cAliasSC9)->C9_ITEM)	
							RecLock("SDC",.F.)
								SDC->(dbDelete())
							SDC->(MsUnlock())
						EndIf
					
						DbSelectArea("SBF")
						SBF->(dbSetOrder(2)) //BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOTECTL+BF_NUMLOTE+BF_PRIOR+BF_LOCALIZ+BF_NUMSERI                                                                              
						SBF->(dbSeek(xFilial("SBF")+(cAliasSC9)->C9_PRODUTO + (cAliasSC9)->C9_LOCAL + (cAliasSC9)->C9_LOTECTL))
						If SBF->BF_LOTECTL = (cAliasSC9)->C9_LOTECTL
							Reclock("SBF",.F.)
								SBF->BF_EMPENHO := SBF->BF_EMPENHO - (cAliasSC9)->C9_QTDLIB
								If SBF->BF_EMPENHO < 0
									SBF->BF_EMPENHO := 0
								EndIf
							SBF->(MsUnlock())
						EndIF
						SBF->(Dbclosearea())
						
						SC9->(a460Estorna())
					//EndDo
			Endif
			(cAliasSC9)->(DbSkip())
		Enddo 
     EndIf
next nX
RestArea(_aSavSC9)
RestArea(_aSavSC6)
RestArea(_aSavSC5) 
RestArea(_aSavArea)

Return Nil
