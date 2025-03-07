#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} MTA455NL
@description O ponto de entrada MTA455E pertence a rotina Libera��o de Estoque (MATA455) e � acionado pelo bot�o "+Autom�tica".
Sua finalidade � permitir a inclus�o de valida��es para as libera��es executadas pelo op��o "+Autom�tica".
@author Diego Rodrigues Pereira (ALLSS Solu��es em Sistemas)
@since 01/10/2024
@version 1.0
@type function
@see https://allss.com.br
/*/
 
User Function MTA455E()
 
Local aArea     := GetArea() //Armazena o ambiente ativo para restaurar ao fim do processo
Local nOpca     := PARAMIXB[1] //Vari�vel nOpca recebe valor = 1 na confirma��o e valor = 2 no cancelamento
Local _cPedido  := SC9->C9_PEDIDO
//Local _aQtdDivg := {}
 
If nOpca == 1
    //Pergunte('LIBAT2',.F.) //Carrega o pergunte da libera��o autom�tica
    U_RESTE014(_cPedido,nOpca)
Else
    MsgAlert("Opera��o cancelada") 
EndIf           
 
RestArea(aArea) //Restaura o ambiente ativo no in�cio da chamada
 
Return(nOpca) //Retorna a vari�vel num�rica nOpca contendo a op��o 1 ou 2
