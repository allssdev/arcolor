#include "protheus.ch"
#include "rwmake.ch"
#include "font.ch"
#include "colors.ch"
#include "totvs.ch"
#include "topconn.ch"
/*/{Protheus.doc} MTA455SLD
Ponto de entrada após o fechamento da transação da liberação de estoque através do fonte RFATE057
Remonta as liberações de estoque de acordo com as regras especificas do cliente.
@author Diego Rodrigues (diego.rodrigues@allss.com.br)
@since 24/11/2024
@version P12.1.2310
@type Function
@obs Sem observações até o momento.
@see https://allss.com.br/
/*/
user function MTA455SLD()
local aAreaSC5  := SC5->(GetArea())
local aAreaSC6  := SC6->(GetArea())
Local aLib       := {.T.,.T.,.F.,.F.}
local lSelLote  := GetNewPar('MV_SELLOTE','2') == "1"
local lLote     := SuperGetMV('MV_SELPLOT',.F.,"2") == "1"
local lUsaVenc  := ""
local lVldDtLote:= SuperGetMV('MV_VLDLOTE',.F.,.T.)
local lInfoWms  := ""
local nQtdNew   := 0
local aSldLote  := {}
local aCompleto := {}
local aQuebrado := {}
local aSldCpl   := {}
local aSldQbr   := {}
local aSaldos   := {}
Local aEmpPronto := {}
local nQtdCxs   := 0
local nCompleto := 0
local nSaldo    := 0
local nQtdQue   := 0
local nX        := 0
local cProduto  := ""
local cLocal    := ""
local cLoteCtl  := ""
local cNumLote  := ""
local cPedido   := ""
Local _cASC9    := ""
Local _cOper    := SuperGetMV('MV_XOPELIB',.F.,"VC")
//Local _lRet     := .T.

IF _cRotina=='RFATE057' .and. !SC5->C5_TPOPER$_cOper

    _cASC9 := GetNextAlias()
	BeginSql Alias _cASC9
        SELECT C9_PEDIDO,C9_ITEM,C9_PRODUTO,C9_LOCAL,C9_SERVIC,B1_VOSEC,SUM(C9_QTDLIB) C9_QTDLIB
        FROM %table:SC9% SC9 (NOLOCK)
        INNER JOIN SB1010 SB1 (NOLOCK) ON SB1.D_E_L_E_T_ = '' AND B1_COD = C9_PRODUTO
        WHERE C9_FILIAL  = %xFilial:SC9%
                AND C9_PEDIDO  = %Exp:SC5->C5_NUM%
                AND C9_BLEST = ''
                AND SC9.%NotDel%
        GROUP BY C9_PEDIDO,C9_ITEM,C9_PRODUTO,C9_LOCAL,C9_SERVIC,B1_VOSEC
        ORDER BY C9_PEDIDO, C9_ITEM, C9_PRODUTO
	EndSql	 

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Estorna a liberacao atual                                    ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    begin transaction
    (_cASC9)->(DbGotop())
    If (_cASC9)->(!EOF()) .and. (_cASC9)->C9_PEDIDO == SC5->C5_NUM
        dbSelectArea("SC9")
        SC9->(dbSetOrder(1))
        SC9->(dbSeek(xFilial("SC9") + (_cASC9)->C9_PEDIDO))
        While SC9->(!EOF()) .AND. SC9->C9_PEDIDO == (_cASC9)->C9_PEDIDO 
                    nVlrCred    := 0
                    SC9->(A460Estorna(/*lMata410*/,/*lAtuEmp*/,@nVlrCred))
            dbSelectArea("SC9")
            SC9->(dbSkip())
        EndDo
    EndIF
    end transaction
    (_cASC9)->(DbGotop())
    While (_cASC9)->(!EOF()) .and. (_cASC9)->C9_PEDIDO == SC5->C5_NUM
        dbSelectArea("SC6")
        SC6->(dbSetOrder(1))
        SC6->(dbSeek(xFilial("SC6") + (_cASC9)->C9_PEDIDO + (_cASC9)->C9_ITEM ))
        dbSelectArea("SB1")
        SB1->(dbSetOrder(1))
        SB1->(dbSeek(xFilial("SB1") + (_cASC9)->C9_PRODUTO))
        aSldLote            := {}
        aCompleto           := {}
        aSldCpl             := {}
        aQuebrado           := {}
        aSldQbr             := {}
        aSaldos             := {}
        nQtdCxs             := 0
        nCompleto           := 0
        nSaldo              := 0
        nQtdTotal           := 0
        nX                  := 0    
        cProduto            := (_cASC9)->C9_PRODUTO
        cLocal              := (_cASC9)->C9_LOCAL
        cLoteCtl            := ""
        cNumLote            := ""
        cPedido             := (_cASC9)->C9_PEDIDO
        lUsaVenc            := SuperGetMv('MV_LOTVENC') == 'S'
        lInfoWms            := (IntDL((_cASC9)->C9_PRODUTO) .And. !Empty((_cASC9)->C9_SERVIC))
        nQtdNew             := (_cASC9)->C9_QTDLIB
        dbSelectArea("SB2")
        SB2->(dbSetOrder(1))
        SB2->(dbSeek(xFilial("SB2") + (_cASC9)->C9_PRODUTO + (_cASC9)->C9_LOCAL))
        dbSelectArea("NNR")
        NNR->(dbSetOrder(1))
        NNR->(dbSeek(xFilial("NNR") + (_cASC9)->C9_LOCAL))
        if SB1->B1_RASTRO == "L" .AND. SB1->B1_LOCALIZ == "S" //.AND. SB1->B1_VOSEC > 0  
                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³ Levanta os saldos por lote x endereço disponíveis            ³
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    aSldLote        := SldPorLote(cProduto,cLocal,SaldoSB2(nil,.F.),0,iif(lLote,Nil,cLoteCtl),iif(lLote,Nil,cNumLote),SC6->C6_LOCALIZ,SC6->C6_NUMSERI,Nil,Nil,Nil,lUsaVenc,,,iif(lVldDtLote,dDataBase,Nil),lInfoWms)
                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³ Separa pallets completos dos incompletos                     ³
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    nQtdCxs         := SB1->B1_VOSEC
                    //nQtdCxs         := nQtdNew/nQtdCxs
                    for nX := 1 to Len(aSldLote)
                        nQtdTotal += aSldLote[nX,5]
                    Next
                    If nQtdNew >= SB1->B1_VOSEC
                        if Len(aSldLote) > 0
                            for nX := 1 to Len(aSldLote)
                                if aSldLote[nX,5] >= nQtdCxs
                                    AADD(aCompleto,{    aSldLote[nX,1],;
                                                        aSldLote[nX,2],;
                                                        aSldLote[nX,3],;
                                                        aSldLote[nX,4],;
                                                        aSldLote[nX,5],;
                                                        aSldLote[nX,6],;
                                                        aSldLote[nX,7],;
                                                        aSldLote[nX,8],;
                                                        aSldLote[nX,9],;
                                                        aSldLote[nX,11],;
                                                        aSldLote[nX,12],;
                                                        aSldLote[nX,13]})
                                ElseIf nQtdTotal = nQtdNew
                                    AADD(aQuebrado,{    aSldLote[nX,1],;
                                                        aSldLote[nX,2],;
                                                        aSldLote[nX,3],;
                                                        aSldLote[nX,4],;
                                                        aSldLote[nX,5],;
                                                        aSldLote[nX,6],;
                                                        aSldLote[nX,7],;
                                                        aSldLote[nX,8],;
                                                        aSldLote[nX,9],;
                                                        aSldLote[nX,11],;
                                                        aSldLote[nX,12],;
                                                        aSldLote[nX,13]})
                                endif
                            next nX    
                        endif
                    Else //If nQtdNew < SB1->B1_VOSEC .OR. SB1->B1_VOSEC = 0
                        if Len(aSldLote) > 0
                            for nX := 1 to Len(aSldLote)
                                AADD(aQuebrado,{    aSldLote[nX,1],;
                                                    aSldLote[nX,2],;
                                                    aSldLote[nX,3],;
                                                    aSldLote[nX,4],;
                                                    aSldLote[nX,5],;
                                                    aSldLote[nX,6],;
                                                    aSldLote[nX,7],;
                                                    aSldLote[nX,8],;
                                                    aSldLote[nX,9],;
                                                    aSldLote[nX,11],;
                                                    aSldLote[nX,12],;
                                                    aSldLote[nX,13]})
                            next nX    
                        endif
                    EndIf
                    
                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³ Ordenando de acordo com a prioridade de endereçamento        ³
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    //aSort(aCompleto,,,{|x,y| x[12] + AllTrim(x[3]) > y[12] + AllTrim(y[3])})
                    //aSort(aQuebrado,,,{|x,y| x[12] + AllTrim(x[3]) > y[12] + AllTrim(y[3])})
                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³ Apanhando pallets completos                                  ³
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    nCompleto		:= Int(nQtdNew / nQtdCxs)
                    nSaldo          := nQtdNew
                    if nCompleto > 0
                        if Len(aCompleto) > 0
                            if nCompleto > Len(aCompleto)
                                nCompleto := Len(aCompleto)
                            endif
                            for nX := 1 to nCompleto
                                If nSaldo > 0
                                    AADD(aSldCpl,{  aCompleto[nX,1],;
                                                    aCompleto[nX,2],;
                                                    aCompleto[nX,3],;
                                                    aCompleto[nX,4],;
                                                    aCompleto[nX,5],;
                                                    aCompleto[nX,6],;
                                                    aCompleto[nX,7],;
                                                    aCompleto[nX,8],;
                                                    aCompleto[nX,9],;
                                                    aCompleto[nX,10],;
                                                    aCompleto[nX,11],;
                                                    aCompleto[nX,12]})
                                    nSaldo := nSaldo - Int(aCompleto[nX][5] / nQtdCxs)*nQtdCxs
                                EndIf
                            next nX
                        endif
                    endif
                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³ Apanhando lotes menores que o multiplo                      ³
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    if nSaldo > 0
                        for nX := 1 to Len(aQuebrado)
                            If nSaldo > 0 //.and. nSaldo < SB1->B1_VOSEC
                                AADD(aSldCpl,{  aQuebrado[nX,1],;
                                                aQuebrado[nX,2],;
                                                aQuebrado[nX,3],;
                                                aQuebrado[nX,4],;
                                                aQuebrado[nX,5],;
                                                aQuebrado[nX,6],;
                                                aQuebrado[nX,7],;
                                                aQuebrado[nX,8],;
                                                aQuebrado[nX,9],;
                                                aQuebrado[nX,10],;
                                                aQuebrado[nX,11],;
                                                aQuebrado[nX,12]})
                                nSaldo := nSaldo - aQuebrado[nX][5]
                            EndIf
                        next nX
                    endif

                    //±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
                    // FIM
                    //±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                  
        endif
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Libera novamente de acordo com o levantamento acima realizado³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            if Len(aSldCpl) > 0
                if lSelLote
                    begin transaction
                        nVlrCred    := 0
                        nQtdAnt     := nQtdNew
                        if Len(aSldCpl) > 0
                            for nX := 1 to Len(aSldCpl)
                            aEmpPronto := {}
                                if nQtdNew > 0
                                    If aSldCpl[nX][5] > nQtdAnt
                                        AADD(aEmpPronto,{  aSldCpl[nX,1],;
                                                        aSldCpl[nX,2],;
                                                        aSldCpl[nX,3],;
                                                        aSldCpl[nX,4],;
                                                        nQtdAnt,;
                                                        ConvUM(SB1->B1_COD,nQtdAnt,0,2),;
                                                        aSldCpl[nX,7],;
                                                        ,;
                                                        ,;
                                                        ,;
                                                        aSldCpl[nX,10],;
                                                        aSldCpl[nX,11]})
                                        MaLibDoFat(SC6->(RecNo()),Min(aSldCpl[nX][5],nQtdAnt),aLib[1],aLib[2],aLib[3],aLib[4],.F.,.F.,/*aEmpenho*/,/*bBlock*/,aEmpPronto,/*lTrocaLot*/,/*lOkExpedicao*/,@nVlrCred,/*nQtdalib2*/)
                                        nQtdNew -= aSldCpl[nX][5]
                                    ElseIf aSldCpl[nX][5] <= nQtdAnt
                                        nQtdQue := If(Int(aSldCpl[nX][5] / nQtdCxs) = 0,aSldCpl[nX][5],Int(aSldCpl[nX][5] / nQtdCxs)*nQtdCxs )
                                        nQtdAnt := nQtdNew - nQtdQue
                                         AADD(aEmpPronto,{  aSldCpl[nX,1],;
                                                        aSldCpl[nX,2],;
                                                        aSldCpl[nX,3],;
                                                        aSldCpl[nX,4],;
                                                        nQtdQue,;
                                                        ConvUM(SB1->B1_COD,Int(aSldCpl[nX][5] / nQtdCxs)*nQtdCxs,0,2),;
                                                        aSldCpl[nX,7],;
                                                        ,;
                                                        ,;
                                                        ,;
                                                        aSldCpl[nX,10],;
                                                        aSldCpl[nX,11]})
                                        MaLibDoFat(SC6->(RecNo()),Min(aSldCpl[nX][5],aSldCpl[nX][5]),aLib[1],aLib[2],aLib[3],aLib[4],.F.,.F.,/*aEmpenho*/,/*bBlock*/,aEmpPronto,/*lTrocaLot*/,/*lOkExpedicao*/,@nVlrCred,/*nQtdalib2*/)
                                        nQtdNew -= nQtdQue
                                    EndIf
                                endif
                            next nX
                        else
                            MaLibDoFat(SC6->(Recno()),@nQtdNew,aLib[1],aLib[2],aLib[3],aLib[4],.F.,.F.,/*aEmpenho*/,/*bBlock*/,/*aEmpPronto*/,/*lTrocaLot*/,/*lOkExpedicao*/,@nVlrCred,/*nQtdalib2*/)
                        endif
                        if SuperGetMv("MV_GRVBLQ2",.F.,.F.) .AND. nQtdAnt > 0
                            MaLibDoFat(SC6->(Recno()),@nQtdAnt,.T.,.F.,lBlqRes,.F.,.F.,.F.,/*aEmpenho*/,/*bBlock*/,/*aEmpPronto*/,/*lTrocaLot*/,/*lOkExpedicao*/,@nVlrCred,/*nQtdalib2*/)
                        endif
                        SC6->(MaLiberOk({cPedido},.F.))
                    end transaction
                endif
            endif
        (_cASC9)->(DbSkip())
    enddo
    (_cASC9)->(DbCloseArea())
//Rotina para validar os itens do pedido de venda versus itens liberados
    VALIDPED()
//Fim Rotina para validar os itens do pedido de venda versus itens liberados
EndIf
RestArea(aAreaSC6)
RestArea(aAreaSC5)
MsUnLockAll()
return

Static Function VALIDPED()

Local _cPedido := SC5->C5_NUM
Local _cSC6PED := GetNextAlias()
Local _cSC9PED := GetNextAlias()
Local _aSepDivg := {}

//BLOCO QUE VALIDA AS QUANTIDADES DO PEDIDO DE VENDA VERSUS LIBERADO DO ESTOQUE
    if Select(_cSC6PED) > 0
        (_cSC6PED)->(dbCloseArea())
    EndIF

    BeginSql Alias _cSC6PED
        SELECT
            SC6X.C6_NUM, SC6X.C6_ITEM, SC6X.C6_PRODUTO, SC6X.C6_QTDVEN, SC9X.C9_PEDIDO, SC9X.C9_ITEM, SC9X.C9_ITEM, SC9X.C9_QTDLIB
        FROM
        (
            SELECT
            C6_NUM,C6_ITEM,C6_PRODUTO, C6_QTDVEN
            FROM %table:SC6% SC6 (NOLOCK)
            WHERE SC6.D_E_L_E_T_ = ''
            AND C6_NUM = %Exp:_cPedido%
        )SC6X
        ,
        (	SELECT	
            C9_PEDIDO, C9_ITEM, C9_PRODUTO, SUM(C9_QTDLIB) C9_QTDLIB
            FROM %table:SC9% SC9 (NOLOCK)
            WHERE SC9.D_E_L_E_T_ = ''
            AND SC9.C9_PEDIDO = %Exp:_cPedido%
            GROUP BY C9_PEDIDO, C9_ITEM, C9_PRODUTO
        )SC9X
        WHERE SC6X.C6_NUM = SC9X.C9_PEDIDO
        AND SC6X.C6_PRODUTO = SC9X.C9_PRODUTO
        AND SC6X.C6_ITEM = SC9X.C9_ITEM
        AND SC6X.C6_QTDVEN <> SC9X.C9_QTDLIB
        ORDER BY SC6X.C6_NUM, SC6X.C6_ITEM
	EndSql	 

    	dbSelectArea(_cSC6PED)
		(_cSC6PED)->(dbGoTop())
		While !(_cSC6PED)->(EOF())	.and. (_cSC6PED)->C9_QTDLIB <> (_cSC6PED)->C6_QTDVEN  //Se retornar .T., significa que algum item do processo que está com saldo maior
			AADD(_aSepDivg,{(_cSC6PED)->C6_PRODUTO,(_cSC6PED)->C6_QTDVEN,(_cSC6PED)->C9_QTDLIB})
			(_cSC6PED)->(dbSkip())
		EndDo

        If Len(_aSepDivg) > 0
				TELAERRO(_aSepDivg,1)
		EndIf
    If Select(_cSC6PED) > 0
	    (_cSC6PED)->(dbCloseArea())
    endif	
//FIM BLOCO QUE VALIDA AS QUANTIDADES DO PEDIDO DE VENDA VERSUS LIBERADO DO ESTOQUE

//BLOCO QUE VALIDA OS PRODUTOS QUE FORAM CORTADOS DO PEDIDO OU PRODUTOS QUE FORAM REMOVIDOS PELA ROTINA(CASO OCORRA).
    if Select(_cSC9PED) > 0
        (_cSC9PED)->(dbCloseArea())
    EndIF
        _aSepDivg := {}
    BeginSql Alias _cSC9PED
        SELECT
            C6_NUM,C6_ITEM,C6_PRODUTO, C6_QTDVEN
        FROM %table:SC6% SC6 (NOLOCK)
        WHERE   SC6.D_E_L_E_T_ = ''
                AND C6_BLOQUEI = ''
                AND C6_NUM = %Exp:_cPedido%
                AND C6_QTDENT = 0
                AND NOT EXISTS ( SELECT	
                                    TOP 1 1
                                    FROM %table:SC9% SC9 (NOLOCK)
                                    WHERE SC9.D_E_L_E_T_ = ''
                                    AND C9_PEDIDO = C6_NUM
                                    AND C9_ITEM = C6_ITEM
                                    AND C9_PRODUTO = C6_PRODUTO
                                    )
        ORDER BY C6_NUM,C6_ITEM
	EndSql	 

    	dbSelectArea(_cSC9PED)
		(_cSC9PED)->(dbGoTop())
		While !(_cSC9PED)->(EOF())	 //Se retornar .T., significa que algum item do processo que está com saldo maior
			AADD(_aSepDivg,{(_cSC9PED)->C6_PRODUTO,(_cSC9PED)->C6_QTDVEN,0})
			(_cSC9PED)->(dbSkip())
		EndDo

        If Len(_aSepDivg) > 0
				TELAERRO(_aSepDivg,2)
		EndIf
    If Select(_cSC9PED) > 0
	    (_cSC9PED)->(dbCloseArea())
    endif	
//FIM BLOCO QUE VALIDA OS PRODUTOS QUE FORAM CORTADOS DO PEDIDO OU PRODUTOS QUE FORAM REMOVIDOS PELA ROTINA(CASO OCORRA).

Return

Static Function TELAERRO(_aSepDivg,_nTipo)
Private oDlgError
Private oBrowse

//Monta o array de campos
aCpoCom := {"Produto", "Qtd Pedido", "Qtd. Liberada"}

Define MsDialog oDlgError From 000,000 To 500,750 Title "[MTA455SLD] - Produtos que não constam no pedido de venda" Pixel

If _nTipo == 1
    //Monta a barra de botões
    Define ButtonBar oBar size 20,20 3D TOP of oDlgError
    Define Button Resource "CANCEL" Of oBar Action (::End()) //Prompt "Fechar" ToolTip "Fecha a Tela" 
    oBar:bRClicked:={ || AllwaysTrue() }

    @ 025,005 Say "Os produtos abaixo estão com quantida diferente ao pedido : " Pixel Of oDlgError

    oBrowse := TWBrowse():New(3.0, 0.5, 370, 190,, aCpoCom, {50,250,50,50}, oDlgError,,,,,,,,,,,, .T.)
    oBrowse:SetArray(_aSepDivg)
    oBrowse:bLine := {||{ _aSepDivg[oBrowse:nAt,01],;
    _aSepDivg[oBrowse:nAt,02],;
    _aSepDivg[oBrowse:nAt,03]} }
    oBrowse:Refresh()

    Activate MsDialog oDlgError Centered

//MsgInfo("Devido as quantidades dos itens descritos. Avise o administrador do Sistema.","[RFATA007_091] - Aviso ")
Elseif _nTipo ==2

    //Monta a barra de botões
    Define ButtonBar oBar size 20,20 3D TOP of oDlgError
    Define Button Resource "CANCEL" Of oBar Action (::End()) //Prompt "Fechar" ToolTip "Fecha a Tela" 
    oBar:bRClicked:={ || AllwaysTrue() }

    @ 025,005 Say "Os produtos abaixo cortados na liberação de estoque : " Pixel Of oDlgError

    oBrowse := TWBrowse():New(3.0, 0.5, 370, 190,, aCpoCom, {50,250,50,50}, oDlgError,,,,,,,,,,,, .T.)
    oBrowse:SetArray(_aSepDivg)
    oBrowse:bLine := {||{ _aSepDivg[oBrowse:nAt,01],;
    _aSepDivg[oBrowse:nAt,02],;
    _aSepDivg[oBrowse:nAt,03]} }
    oBrowse:Refresh()

    Activate MsDialog oDlgError Centered
EndIf

Return()

        /*
		SELECT
		    SC9X.C9_PEDIDO,SC9X.C9_ITEM,SC9X.C9_PRODUTO,SC9X.C9_LOCAL,SC9X.C9_SERVIC,SC9X.B1_VOSEC,SC9X.C9_QTDLIB, SB8X.SALDO
		FROM
		(
            SELECT C9_PEDIDO,C9_ITEM,C9_PRODUTO,C9_LOCAL,C9_SERVIC,B1_VOSEC,SUM(C9_QTDLIB) C9_QTDLIB
            FROM %table:SC9% SC9 (NOLOCK)
            INNER JOIN SB1010 SB1 (NOLOCK) ON SB1.D_E_L_E_T_ = '' AND B1_COD = C9_PRODUTO
            WHERE C9_FILIAL  = %xFilial:SC9%
                AND C9_PEDIDO  = %Exp:SC5->C5_NUM%
                AND C9_BLEST = ''
                AND SC9.%NotDel%
            GROUP BY C9_PEDIDO,C9_ITEM,C9_PRODUTO,C9_LOCAL,C9_SERVIC,B1_VOSEC
		)SC9X
        ,
		(
			SELECT B8_PRODUTO, SUM(B8_SALDO - B8_EMPENHO) SALDO
			FROM SB8010 SB8 (NOLOCK)
			WHERE SB8.D_E_L_E_T_ = ''
			GROUP BY B8_PRODUTO
		)SB8X
		WHERE  SC9X.C9_PRODUTO = SB8X.B8_PRODUTO
              //--AND SC9X.C9_QTDLIB >= SC9X.B1_VOSEC 
              //--AND SB8X.SALDO > SC9X.C9_QTDLIB
		ORDER BY SC9X.C9_PEDIDO,SC9X.C9_ITEM,SC9X.C9_PRODUTO
        */
