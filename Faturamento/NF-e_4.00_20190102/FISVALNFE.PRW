#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "parmtype.ch"
#INCLUDE 'totvs.ch'
#INCLUDE 'topconn.ch'

/*/{Protheus.doc} FISVALNFE
Este ponto de entrada foi disponibilizado a fim de permitir a validação da transmissão  das Notas Fiscais pela rotina SPEDNFE.
@author Diego Rodrigues (diego.rodrigues@allss.com.br)
@since 17/08/2023
@version 1.00 (P12.1.25)
@type Function
@obs Sem observações
@see https://allss.com.br/
/*/ 

User Function FISVALNFE()	

Local lTran		:=.T.	
//Local cTipo		:=PARAMIXB[1]	
//Local cFil		:=PARAMIXB[2]	
//Local cEmissao	:=PARAMIXB[3]	
Local cNota		:=PARAMIXB[4]	
Local cSerie	:=PARAMIXB[5]	
Local cClieFor	:=PARAMIXB[6]	
Local cLoja		:=PARAMIXB[7]	
//Local cEspec	:=PARAMIXB[8]	
//Local cFormul	:=PARAMIXB[9]	
Local _aSepDivg := {}
Local _cOrdSep   := ""
Local _cPedido   := ""
Local _cCB9NOTA := GetNextAlias()
Local _cSC6NOTA := GetNextAlias()

//Bloco para buscar a informação da ordem de separação na SC9, necessário porque não temos a informação na SF2 OU SD2.
dbSelectArea("SC9")	
dbSetOrder(6) //C9_FILIAL+C9_SERIENF+C9_NFISCAL+C9_CARGA+C9_SEQCAR			
If SC9->(MsSeek(xFilial("SC9")+cSerie+cNota))
        _cOrdSep := SC9->C9_ORDSEP
EndIf

//Bloco para buscar a informação do pedido
dbSelectArea("SD2")	
dbSetOrder(3)			
IF SD2->(MsSeek(xFilial("SD2")+cNota+cSerie+cClieFor+cLoja))
        _cPedido := SD2->D2_PEDIDO
EndIf

//Bloco para analise comparativa do que efetivamente foi separado na tabela CB9 e o que está emitida na nota fiscal SD2.
    if Select(_cCB9NOTA) > 0
        (_cCB9NOTA)->(dbCloseArea())
    EndIF

    BeginSql Alias _cCB9NOTA
		SELECT
            CB9_PEDIDO, CB9_PROD, CB9_LOTECT,SUM(CB9_QTESEP) QTDSEP
        FROM CB9010 CB9 (NOLOCK)
        WHERE CB9.%NotDel%
              AND CB9_PEDIDO = %Exp:_cPedido%
              AND CB9_ORDSEP = %Exp:_cOrdSep%
        GROUP BY CB9_ORDSEP, CB9_PEDIDO, CB9_PROD, CB9_LOTECT
        EXCEPT
        SELECT
            D2_PEDIDO, D2_COD, D2_LOTECTL, SUM(D2_QUANT) QTDNOTA
        FROM SD2010 SD2 (NOLOCK)
        INNER JOIN SC9010 SC9 (NOLOCK) ON SC9.%NotDel% AND C9_PEDIDO = D2_PEDIDO AND 
            C9_PRODUTO = D2_COD AND C9_LOTECTL = D2_LOTECTL AND C9_ORDSEP = %Exp:_cOrdSep%
        WHERE SD2.%NotDel%
              AND D2_PEDIDO = %Exp:_cPedido%
              AND D2_DOC = %Exp:cNota%
        GROUP BY D2_PEDIDO, D2_COD, D2_LOTECTL
	EndSql	 

    	dbSelectArea(_cCB9NOTA)
		(_cCB9NOTA)->(dbGoTop()) 
		While !(_cCB9NOTA)->(EOF())	//Se retornar .T., significa que algum item do processo que está com divergencia
			AADD(_aSepDivg,{(_cCB9NOTA)->CB9_PROD,(_cCB9NOTA)->CB9_LOTECT,(_cCB9NOTA)->QTDSEP})
			(_cCB9NOTA)->(dbSkip())
		EndDo

        If Len(_aSepDivg) > 0
				TELAERRO(_aSepDivg)
			lTran := .F.	
		EndIf
    If Select(_cCB9NOTA) > 0
	    (_cCB9NOTA)->(dbCloseArea())
    endif	

//Bloco para analise comparativa das quantidades emitidas na SD2 estão maiores que as quantidades no pedido de venda, caso sim bloqueia a transmissão
    if Select(_cSC6NOTA) > 0
        (_cSC6NOTA)->(dbCloseArea())
    EndIF

    _aSepDivg := {}

    BeginSql Alias _cSC6NOTA
	    SELECT
            C6_NUM, C6_PRODUTO, C6_QTDVEN, D2_QUANT
        FROM
            (SELECT
            C6_NUM, C6_PRODUTO, SUM(C6_QTDVEN) C6_QTDVEN, SUM(C6_QTDENT) C6_QTDENT
            FROM SC6010 SC6 (NOLOCK)
            WHERE SC6.D_E_L_E_T_ = ''
            AND C6_NUM = %Exp:_cPedido%
            GROUP BY C6_NUM, C6_PRODUTO) SC6X
            ,
            (SELECT
            D2_PEDIDO, D2_COD, SUM(D2_QUANT) D2_QUANT
            FROM SD2010 SD2 (NOLOCK)
            WHERE SD2.D_E_L_E_T_ = ''
            AND D2_PEDIDO = %Exp:_cPedido%
            AND D2_DOC = %Exp:cNota%
            GROUP BY D2_PEDIDO, D2_COD)SD2X
        WHERE
            SC6X.C6_NUM = SD2X.D2_PEDIDO
            AND SC6X.C6_PRODUTO = SD2X.D2_COD
            AND (SD2X.D2_QUANT > SC6X.C6_QTDVEN  OR SC6X.C6_QTDENT > SC6X.C6_QTDVEN)
	EndSql	 

    	dbSelectArea(_cSC6NOTA)
		(_cSC6NOTA)->(dbGoTop())
		While !(_cSC6NOTA)->(EOF())	.and. (_cSC6NOTA)->D2_QUANT > (_cSC6NOTA)->C6_QTDVEN  //Se retornar .T., significa que algum item do processo que está com saldo maior
			AADD(_aSepDivg,{(_cSC6NOTA)->C6_PRODUTO,(_cSC6NOTA)->C6_QTDVEN,(_cSC6NOTA)->D2_QUANT})
			(_cSC6NOTA)->(dbSkip())
		EndDo

        If Len(_aSepDivg) > 0
				TELAERRO(_aSepDivg)
			lTran := .F.	
		EndIf
    If Select(_cSC6NOTA) > 0
	    (_cSC6NOTA)->(dbCloseArea())
    endif	

Return  lTran


Static Function TELAERRO(_aSepDivg)
Private oDlgError
Private oBrowse

//Monta o array de campos
aCpoCom := {"Produto", "Lote/Qtd Pedido", "Qtd. Separada/QtdNota"}

Define MsDialog oDlgError From 000,000 To 500,750 Title "[FISVALNFE] - Produtos que não constam na nota fiscal" Pixel

//Monta a barra de botões
Define ButtonBar oBar size 20,20 3D TOP of oDlgError
Define Button Resource "CANCEL" Of oBar Action (::End()) //Prompt "Fechar" ToolTip "Fecha a Tela" 
oBar:bRClicked:={ || AllwaysTrue() }

@ 025,005 Say "Os produtos abaixo estão com quantida superior ao pedido ou foram cortados da nota fiscal indevidamente : " Pixel Of oDlgError

oBrowse := TWBrowse():New(3.0, 0.5, 370, 190,, aCpoCom, {50,250,50,50}, oDlgError,,,,,,,,,,,, .T.)
oBrowse:SetArray(_aSepDivg)
oBrowse:bLine := {||{ _aSepDivg[oBrowse:nAt,01],;
_aSepDivg[oBrowse:nAt,02],;
_aSepDivg[oBrowse:nAt,03]} }
oBrowse:Refresh()

Activate MsDialog oDlgError Centered

Return()



/* FONTE ANTIGO POSSUIA O BLOCO ABAIXO COMENTADO.
User Function FISVALNFE()	
Local lTran		:=.T.	
Local cTipo		:=PARAMIXB[1]	
Local cFil      :=PARAMIXB[2]	
Local cEmissao	:=PARAMIXB[3]	
Local cNota		:=PARAMIXB[4]	
Local cSerie	:=PARAMIXB[5]
Local cClieFor	:=PARAMIXB[6]	
Local cLoja		:=PARAMIXB[7]	
Local cEspec	:=PARAMIXB[8]	
Local cFormul   :=PARAMIXB[9]		

dbSelectArea("SD2")	
dbSetOrder(3)			
dbseek(cFil+cNota+cSerie+cClieFor+cLoja)		
	While !EOF() .AND. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == cFil+cNota+cSerie+cClieFor+cLoja				
		If VAL(SD2->D2_TES) <> 502 lRetorna:=.F.			
	Exit		
	EndIf		
dbSkip()	
End 
Return  (lTran)*/
