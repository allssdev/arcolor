#include "protheus.ch"
#include "rwmake.ch"
#include "font.ch"
#include "colors.ch"
#include "totvs.ch"
#include "topconn.ch"
/*/{Protheus.doc} RFATA501
Função de usuário para corte na liberação de pedidos de venda.
Remonta as liberações de estoque de acordo com as regras especificas do cliente.
@author Rodrigo Telecio - ALLSS Soluções em Sistemas (rodrigo.telecio@allss.com.br)
@since 08/12/2021
@version 1.00 (P12.1.25)
@type Function	
@obs Sem observações até o momento. 
@see https://allss.com.br/
@history 08/12/2021, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Desenvolvimento da primeira versão do programa.
/*/
user function RFATA501(_cNum,_nPerc,_nChamada)
local _aAreaSC5  := SC5->(GetArea())
local _aAreaSC6  := SC6->(GetArea())
local _cPedido   := ''
local _lQuant    := .T.
local _lCalcula  := .T.
local _aLib      := {.T.,.T.,.T.,.T.}
local _cLogx     := ''
local _cRotina   := FunName()
local _nVlrCred  := 0
local _nFator    := ((100 - _nPerc) / 100)
default _nChamada:= 1
if _nChamada <> 1 //chamada via menu ou por meio de outra rotina
    dbSelectArea("SC5")
    SC5->(dbSetOrder(1))
    SC5->(dbSeek(FWFilial("SC5") + _cNum))
endif
if _nPerc > 0
    if Aviso('TOTVS - ' + AllTrim(_cRotina) + ' - Atenção','Deseja efetivar a liberação de estoque cortando ' + AllTrim(Str(_nPerc)) + '% das quantidades do pedido ' + AllTrim(SC5->C5_NUM) + '?',{"&Sim","&Não"},2,"Corte na liberação de pedidos") == 1
        if SC5->C5_TIPO $ "DB"
            dbSelectArea("SA2")
            SA2->(dbSetOrder(1))
            SA2->(dbSeek(FWFilial("SA2") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
        else
            dbSelectArea("SA1")
            SA1->(dbSetOrder(1))
            SA1->(dbSeek(FWFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
        endif
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Descomentar as linhas abaixo para aplicação no ambiente da   ³
        //³ ARCOLOR                                                      ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        dbSelectArea("SUA")
        SUA->(dbOrderNickName("UA_NUMSC5"))
        SUA->(MsSeek(xFilial("SUA") + SC5->C5_NUM,.T.,.F.))
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        dbSelectArea("SC6")
        SC6->(dbSetOrder(1))
        SC6->(dbSeek(FWFilial("SC6") + SC5->C5_NUM))
        while SC6->(!EOF()) .AND. SC6->C6_NUM == SC5->C5_NUM
            dbSelectArea("SC9")
            SC9->(dbSetOrder(1))
            SC9->(dbSeek(FWFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM))
            dbSelectArea("SB1")
            SB1->(dbSetOrder(1))
            SB1->(dbSeek(FWFilial("SB1") + SC6->C6_PRODUTO))
            _cPedido            := SC6->C6_NUM
            dbSelectArea("SB2")
            SB2->(dbSetOrder(1))
            SB2->(dbSeek(FWFilial("SB2") + SC6->C6_PRODUTO + SC6->C6_LOCAL))
            dbSelectArea("NNR")
            NNR->(dbSetOrder(1))
            NNR->(dbSeek(FWFilial("NNR") + SC6->C6_LOCAL))
            if _lCalcula
                if _nFator == 0
                    _nFator := 1
                endif
                _nQuant  := iif(SC9->C9_QTDLIB == 0,SC6->C6_QTDVEN,SC9->C9_QTDLIB)
                _nQuantA := 0
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Estorna a liberacao atual, caso exista algo liberado (SC9)   ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                if SC9->(!EOF())
                    begin transaction
                        _nVlrCred    := 0
                        SC9->(A460Estorna(/*lMata410*/,/*lAtuEmp*/,@_nVlrCred))
                    end transaction
                endif
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                if _lQuant
                    _nQuantA := Round(_nQuant * _nFator,0)
                    if SB1->(FieldPos("B1_VOSEC")) > 0 .AND. Type("SB1->B1_VOSEC") == "N" .AND. SB1->B1_VOSEC > 0
                        if mod(_nQuantA,SB1->B1_VOSEC) > 0
                            _nQuantA := Round((int(_nQuantA / SB1->B1_VOSEC) * SB1->B1_VOSEC),0)
                        endif
                    else
                        Aviso('TOTVS - ' + AllTrim(_cRotina) + ' - Atenção','O campo "B1_VOSEC" (volume secundário) não existe ou está com conteúdo zerado no cadastro do produto ' + AllTrim(SC6->C6_PRODUTO) + ' no pedido ' + AllTrim(SC6->C6_NUM) + '. Para liberação deste item, será assumida a quantidade total do item do pedido.',{"&Ok"},3,"Corte na liberação de pedidos")
                        _nQuantA := _nQuant                    
                    endif                            
                    if _nQuantA <= 0
                        _nQuantA := _nQuant
                    endif
                    MaLibDoFat(SC6->(Recno()),@_nQuantA,_aLib[1],_aLib[2],_aLib[3],_aLib[4],.F.,.F.,/*aEmpenho*/,/*bBlock*/,/*aEmpPronto*/,/*lTrocaLot*/,/*lOkExpedicao*/,@_nVlrCred,/*nQtdalib2*/)
                    SC6->(MaLiberOk({_cPedido},.F.))
                endif
            endif
            dbSelectArea("SC6")
            SC6->(dbSkip())
        enddo
        if ExistBlock("RFATL001")
            _cLogx      := 'Liberação/remontagem da liberação do pedido de venda cortando ' + AllTrim(Str(_nPerc)) + '% das quantidades deste pedido.'
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Trocar as linhas abaixo para aplicação no ambiente da        ³
            //³ ARCOLOR                                                      ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            U_RFATL001(SC5->C5_NUM,SUA->UA_NUM,_cLogx,_cRotina)
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            //U_RFATL001(SC5->C5_NUM,"",_cLogx,_cRotina)
        else
            Aviso('TOTVS - ' + AllTrim(_cRotina) + ' - Atenção','A função "RFATL001" não foi aplicada no repositório de objetos. Avise o administrador do sistema com esta mensagem para prosseguir com as devidas tratativas.',{"&Ok"},3,"Corte na liberação de pedidos")
        endif
    endif
else
    Aviso('TOTVS - ' + AllTrim(_cRotina) + ' - Atenção','Não foi informada quantidade de corte de liberação para o pedido ' + AllTrim(SC5->C5_NUM) + '. Nada será feito com tal pedido.',{'&OK'},3,'Falha de processamento')
endif
RestArea(_aAreaSC6)
RestArea(_aAreaSC5)
MsUnLockAll()
return
