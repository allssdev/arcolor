#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'

#define CLRF CHR(13)+CHR(10)
 
User Function RESTE014(_cPedido,nOpca)
 
Local aArea     := GetArea() //Armazena o ambiente ativo para restaurar ao fim do processo
//Local _cPedido  := SC9->C9_PEDIDO
Local _aQtdDivg := {}
local _cMail          := ""
local _cAnexo         := ""
local _cCC 	          := ""
local _cBCC           := ""
local _cHtml          := ""
local _cAssunto       := ""
local _cFromOri       := "naoresponda@arcolor.com.br"
local _lExcAnex       := .F.
local _lAlert         := .T.
local _lHtmlOk        := .F.

    BeginSql Alias "SC9QTD"
	    SELECT
            C6_NUM, C6_PRODUTO, C6_QTDVEN, C9_QUANT
        FROM
            (SELECT
            C6_NUM, C6_PRODUTO, SUM(C6_QTDVEN) C6_QTDVEN, SUM(C6_QTDENT) C6_QTDENT
            FROM SC6010 SC6 (NOLOCK)
            WHERE SC6.D_E_L_E_T_ = ''
            AND C6_NUM = %Exp:_cPedido%
            GROUP BY C6_NUM, C6_PRODUTO) SC6X
            ,
            (SELECT
            C9_PEDIDO, C9_PRODUTO, SUM(C9_QTDLIB) C9_QUANT
            FROM SC9010 SC9 (NOLOCK)
            WHERE SC9.D_E_L_E_T_ = ''
                AND C9_PEDIDO = %Exp:_cPedido%
            GROUP BY C9_PEDIDO, C9_PRODUTO)SC9X     
        WHERE
            SC6X.C6_NUM = SC9X.C9_PEDIDO
            AND SC6X.C6_PRODUTO = SC9X.C9_PRODUTO
            AND (SC9X.C9_QUANT > SC6X.C6_QTDVEN  OR SC6X.C6_QTDENT > SC6X.C6_QTDVEN)
	EndSql	 

		SC9QTD->(dbGoTop())
		While !SC9QTD->(EOF())	.and. SC9QTD->C9_QUANT > SC9QTD->C6_QTDVEN  //Se retornar .T., significa que algum item do processo que está com saldo maior
			AADD(_aQtdDivg,{SC9QTD->C6_PRODUTO,SC9QTD->C6_QTDVEN,SC9QTD->C9_QUANT})
			SC9QTD->(dbSkip())
		EndDo

        If Len(_aQtdDivg) > 0
				IF nOpca == 2
                    _cMail          := 'diego.rodrigues@allss.com.br'
                    _cAssunto       := "[Arcolor] - Pedido Duplicado na geração da ordem de separação"
                    _cHtml          := "<h2> Pedido de Venda " + _cPedido + " - duplicado avaliar </h2>" + CLRF
                    _cHtml          += "<br><br>" 
                ElseIf nOpca == 3
                    _cMail          := 'diego.rodrigues@allss.com.br'
                    _cAssunto       := "[Arcolor] - Pedido Duplicado no fonte MA440VLD"
                    _cHtml          := "<h2> Pedido de Venda " + _cPedido + " - duplicado avaliar </h2>" + CLRF
                    _cHtml          += "<br><br>" 

                ElseIf nOpca == 4
                    _cMail          := 'diego.rodrigues@allss.com.br'
                    _cAssunto       := "[Arcolor] - Pedido Duplicado no fonte MT440AT"
                    _cHtml          := "<h2> Pedido de Venda " + _cPedido + " - duplicado avaliar </h2>" + CLRF
                    _cHtml          += "<br><br>" 
                ElseIf nOpca == 5
                    _cMail          := 'diego.rodrigues@allss.com.br'
                    _cAssunto       := "[Arcolor] - Pedido Duplicado no fonte MT440GR"
                    _cHtml          := "<h2> Pedido de Venda " + _cPedido + " - duplicado avaliar </h2>" + CLRF
                    _cHtml          += "<br><br>" 
                 ElseIf nOpca == 6
                    _cMail          := 'diego.rodrigues@allss.com.br'
                    _cAssunto       := "[Arcolor] - Pedido Duplicado no fonte M440STTS"
                    _cHtml          := "<h2> Pedido de Venda " + _cPedido + " - duplicado avaliar </h2>" + CLRF
                    _cHtml          += "<br><br>" 
                Else 
                    _cMail          := 'diego.rodrigues@allss.com.br'
                    _cAssunto       := "[Arcolor] - Pedido Duplicado na liberação de estoque"
                    _cHtml          := "<h2> Pedido de Venda " + _cPedido + " - duplicado avaliar </h2>" + CLRF
                    _cHtml          += "<br><br>" 
                EndIf
                lRetMail := U_RCFGM001(/*cTitulo*/"",_cHtml,_cMail,_cAnexo,_cFromOri,_cBCC,_cAssunto,_lExcAnex,_lAlert,_lHtmlOk,_cCC)
		        //TELAERRO(_aSepDivg)
                MSGINFO("AVISE O ADMNISTRADOR DO SISTEMA! Pedido possui produtos duplicados!","ATENÇÃO")
            nOpca := 2
        Else
            nOpca := 1
        EndIf
	    SC9QTD->(dbCloseArea())

RestArea(aArea) //Restaura o ambiente ativo no início da chamada
 
Return(nOpca) //Retorna a variável numérica nOpca contendo a opção 1 ou 2
