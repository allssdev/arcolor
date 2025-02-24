#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'
#Include 'TOTVS.ch'
#Include 'topconn.ch'
/*/{Protheus.doc} ACD170VE
@description Ponto de Entrada para a manipulação dos dados da etiqueta coletada
@author Anderson C. P. Coelho
@since 06/09/2017
@version P11.8 - 001

@type function
@param aEtiqueta, array, Dados da etiqueta coletada
@return array, Dados da etiqueta coletada

@see https://allss.com.br
/*/
user function ACD170VE()

Local _aEtiq    := PARAMIXB
Local _aAreaCB8 := GetArea()
	
	If !Localiza(CB8->CB8_PROD)
		dbSelectArea("CB7")
		while !RecLock("CB7",.F.) ; enddo
			CB7->CB7_ORIGEM := "2"
		CB7->(MSUNLOCK())
	EndIf
	
RestArea(_aAreaCB8)	

return _aEtiq