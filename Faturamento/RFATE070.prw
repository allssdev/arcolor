#include 'totvs.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} RFATE070
@description Execblock para trazer o nome do motorista no campo virtual F2_XMOTORI, relacionado a carga.
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 30/09/2020
@version 1.0
@return _cNome, caracter, Nome do Motorista
@type function
@see https://allss.com.br
/*/
user function RFATE070()
	local   _aSavArea := GetArea()
	local   _aSavSF2  := SF2->(GetArea())
	local   _aSavDAK  := DAK->(GetArea())
	local   _aSavDA4  := DA4->(GetArea())
	local   _cNome    := ""
	if !empty(SF2->F2_CARGA)
		dbSelectArea("DAK")
		DAK->(dbSetOrder(1))		//DAK_FILIAL+DAK_COD+DAK_SEQCAR
		if DAK->(MsSeek(FWFilial("DAK") + SF2->(F2_CARGA+F2_SEQCAR),.T.,.F.)) .AND. !empty(DAK->DAK_MOTORI)
			dbSelectArea("DA4")
			DA4->(dbSetOrder(1))	//DA4_FILIAL+DA4_COD
			if DA4->(MsSeek(FWFilial("DA4") + DAK->DAK_MOTORI,.T.,.F.)) .AND. !empty(DA4->DA4_NOME)
				_cNome := DA4->DA4_NOME
			endif
		endif
	endif
	RestArea(_aSavDA4)
	RestArea(_aSavDAK)
	RestArea(_aSavSF2)
	RestArea(_aSavArea)
return _cNome