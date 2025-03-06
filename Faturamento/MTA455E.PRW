#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} MTA455NL
@description O ponto de entrada MTA455E pertence a rotina Liberação de Estoque (MATA455) e é acionado pelo botão "+Automática".
Sua finalidade é permitir a inclusão de validações para as liberações executadas pelo opção "+Automática".
@author Diego Rodrigues Pereira (ALLSS Soluções em Sistemas)
@since 01/10/2024
@version 1.0
@type function
@see https://allss.com.br
/*/
 
User Function MTA455E()
 
Local aArea     := GetArea() //Armazena o ambiente ativo para restaurar ao fim do processo
Local nOpca     := PARAMIXB[1] //Variável nOpca recebe valor = 1 na confirmação e valor = 2 no cancelamento
Local _cPedido  := SC9->C9_PEDIDO
//Local _aQtdDivg := {}
 
If nOpca == 1
    //Pergunte('LIBAT2',.F.) //Carrega o pergunte da liberação automática
    U_RESTE014(_cPedido,nOpca)
Else
    MsgAlert("Operação cancelada") 
EndIf           
 
RestArea(aArea) //Restaura o ambiente ativo no início da chamada
 
Return(nOpca) //Retorna a variável numérica nOpca contendo a opção 1 ou 2
