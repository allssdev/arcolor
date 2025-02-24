#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"


/*/{Protheus.doc} 
@description Ponto de Entrada que possibilita a adição de rotinas no array aRotina do programa de atualizações de resultados (QIEA215).
@author		Livia Della Corte email: livia.dcorte@allss.com.br
@since 		18/06/2023
@version 	1.01
@see 		https://allss.com.br
/*/

User Function QE215ROT()	

	AAdd(aRotina,{"Imprime Etiqueta" , "U_RQIEA001(1)", 0 , 9, 0, Nil})

Return .T.
