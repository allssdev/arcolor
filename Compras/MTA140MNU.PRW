/*/{Protheus.doc} MTA140MNU 
Ponto de entrada Adicionar bot�es ao Menu Principal atrav�s do array aRotina.
@author Diego Rodrigues Pereira
@since 06/06/2023
@version 1.0
@type function
@see https://allss.com.br
@history 06/06/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Ponto de entrada para incluir a chama para impress�o da etiqueta de identifica��o das entradas
/*/


User Function MTA140MNU 

aAdd(aRotina,{ "Etiqueta Entrada", "U_RCOMR008()", 0 , 2, 0, .F.}) 
aAdd(aRotina,{ "Importar XML", "U_PreNotaXML()", 0 , 2, 0, .F.})

Return
