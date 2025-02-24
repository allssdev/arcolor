#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} RCTBE002
@description Execblock utilizado para calcular o valor total por item do documento de entrada, conforme o TES Selecionado.
@obs Protheus11 - Específico para a empresa Arcolor. Utilizado na contabilização dos Documentos de Entrada (LP650).
@author Anderson C. P. Coelho (ALL System Solutions)
@since 08/12/2014
@version 1.0
@return _nRet, numérico, valor a ser contabilizado
@type function
/*/
user function RCTBE002()
//	Local _cRotina  := "RCTBE002"
	Local _aSavArea := GetArea()
	Local _aSavSA1  := SA1->(GetArea())
	Local _aSavSA2  := SA2->(GetArea())
	Local _aSavSD1  := SD1->(GetArea())
	Local _aSavSD2  := SD2->(GetArea())
	Local _aSavSF4  := SF4->(GetArea())
	Local _nRet     := 0
	if !SubStr(SD1->D1_CF,2,3)$"/910/911/918/" .AND. SF4->F4_DUPLIC<>"S" .AND. ExistBlock("RCTBE001")		//*SubStr(SD1->D1_CF,2,3)$"/910/914/"
		_nRet := U_RCTBE001("SD1->D1_CUSTO")
	endif
	if _nRet == 0
		_nRet := 	IIF(SD1->D1_QUANT>0.OR.(SD1->D1_TIPO=="C".AND.SF4->F4_DUPLIC=="S"),SD1->D1_TOTAL,0) + ;
					SD1->D1_VALFRE  + ;
					SD1->D1_SEGURO  + ;
					SD1->D1_DESPESA + ;
					IIF((SF4->F4_CREDIPI == "S".AND.!SubStr(SD1->D1_CF,2,3)$"116").OR.(SubStr(SD1->D1_CF,2,3)$"/551/556/910/911/"),SD1->D1_VALIPI,0) + ;
					IIF(!AllTrim(SF4->F4_AGRPIS)$"/2/D/",SD1->D1_VALIMP6,0) + ;
					IIF(!AllTrim(SF4->F4_AGRCOF)$"/2/D/",SD1->D1_VALIMP5,0) + ;
					IIF(SF4->F4_AGREG    == "I",SD1->D1_VALICM ,0) + ;
					IIF(SF4->F4_INCSOL   == "S",SD1->D1_ICMSRET,0)
		_nRet -= 	SD1->D1_VALDESC
	endif
	RestArea(_aSavSA1)
	RestArea(_aSavSA2)
	RestArea(_aSavSD1)
	RestArea(_aSavSD2)
	RestArea(_aSavSF4)
	RestArea(_aSavArea)
return _nRet