#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} MTA440C9
@description  Ponto de entrada que grava a hora de liberacao do pedido.
Utilizamos esse ponto de entrada parea ajuste do preço de venda na tabela SC9 através da rotina RACDV166
@author Diego Rodrigues(ALL System Solutions)
@since 18/01/2023
@version 1.0
@type function
@see https://allss.com.br
/*/             

User Function MTA440C9()

If AllTrim(FunName()) == "ACDV166" .OR. AllTrim(FunName()) == "U_RACDV166"
    SC9->C9_PRCVEN:= SC6->C6_PRCVEN
ENDIF

Return ()
