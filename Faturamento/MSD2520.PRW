#INCLUDE 'Protheus.ch'
#INCLUDE 'RwMake.ch'


/*/{Protheus.doc} MSD2520
@description Esse ponto de entrada est� localizado na fun��o A520Dele(). � chamado antes da exclus�o do registro no SD2. 
@author  J�lio Soares
@since 15/08/16
@version 1.0
@type function
@see https://allss.com.br
/*/

user function MSD2520()
local _aSavArea  := GetArea()
local _aSavSF2	 := SF2->(GetArea())
local _aSavSD2	 := SD2->(GetArea())
local _cRotina   := 'MSD2520'

if SD2->D2_PEDIDO == '01'
	//gravar LOG de Cancelamento
	U_RFATL001(SD2->D2_PEDIDO,POSICIONE('SUA',8,xFilial('SUA')+SD2->D2_PEDIDO ,'UA_NUM'),'Nota Fiscal/S�rie - '+ SD2->D2_DOC + "/" + SD2->D2_SERIE + ' Cancelada.' ,"MSD2520",)
Endif

RestArea(_aSavSD2)
RestArea(_aSavSF2)
RestArea(_aSavArea)
return