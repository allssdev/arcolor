#include "totvs.ch"
/*/{Protheus.doc} MS520VLD
    Esse ponto de entrada é chamado para validar ou não a exclusão da nota na rotina MATA521.
    @author Fernando Bombardi (ALLSS Soluções em Sistemas)
    @since 07/02/2020
    @version 1.0
    @type Function
    @see https://allss.com.br
/*/
user function MS520VLD()
	local   _aSvArea    :=  GetArea()
	local   _aSvSF2     :=  SF2->(GetArea())
	local   _aSvSD2     :=  SD2->(GetArea())
	local   _aSvSA1     :=  SA1->(GetArea())
	local   _aSvSA2     :=  SA2->(GetArea())
	local   _aSvSE1     :=  SE1->(GetArea())
	local   _aSvSC5     :=  SC5->(GetArea())
	local   _aSvSC6     :=  SC6->(GetArea())
	local   _aSvSC9     :=  SC9->(GetArea())
	local   _aSvSRK     :=  SRK->(GetArea())
	local   oMS520VLD   :=  nil
	local   _lRET       :=  .T.
	if SRK->(FieldPos("RK_XDOC")) > 0 .AND. SRK->(FieldPos("RK_XSERIE")) > 0 .AND. SRK->(FieldPos("RK_XPARC")) > 0
		oMS520VLD       :=  MS520VLD():NEW()
		_lRET           :=  oMS520VLD:ValidarExclusaoValoresFuturos()
	endif
	oMS520VLD           :=  nil
	RestArea(_aSvSF2)
	RestArea(_aSvSD2)
	RestArea(_aSvSA1)
	RestArea(_aSvSA2)
	RestArea(_aSvSE1)
	RestArea(_aSvSRK)
	RestArea(_aSvSC5)
	RestArea(_aSvSC6)
	RestArea(_aSvSC9)
	RestArea(_aSvArea)
return _lRET
/*/{Protheus.doc} MS520VLD
	@description Classe para validacao de dados na exclusao do faturamento.
    @author Fernando Bombardi (ALLSS Soluções em Sistemas)
    @since 07/02/2020
    @version 1.0
    @type class
    @see https://allss.com.br
/*/
class MS520VLD
    data _cRotina    as string
	data _nSeq       as numeric
	data _nStart     as numeric

    Method New() CONSTRUCTOR
    Method ValidarExclusaoValoresFuturos()   
endclass
/*/{Protheus.doc} New
    @description Metodo construtor 
    @author Fernando Bombardi (ALLSS Soluções em Sistemas)
    @since 07/02/2020
    @version 1.0
    @type method
    @see https://allss.com.br
/*/
method New() class MS520VLD
	::_cRotina   := "MS520VLD"
	::_nSeq      := 1
	::_nStart    := Seconds()
return
/*/{Protheus.doc} ValidarExclusaoValoresFuturos
    @description Método de validação de exclusão de valores futuros
    @author Fernando Bombardi (ALLSS Soluções em Sistemas)
    @since 07/02/2020
    @version 1.0
    @type method
    @see https://allss.com.br
/*/
Method ValidarExclusaoValoresFuturos() class MS520VLD
	local   _cFUNC      :=  GetNextAlias()
	local   _cSRK       :=  GetNextAlias()
	local   _cVERBA     :=  PadR(SuperGetMV("MV_XVERBAVF",,"505"      ),TamSx3("RV_COD"    )[1])
	local   _lRET       :=  .T.

	if Select(_cFUNC) > 0
		(_cFUNC)->(dbCloseArea())
	endif
	BEGINSQL ALIAS _cFUNC
		%noparser%
		SELECT RA_SITFOLH
		FROM %table:SRA% SRA (NOLOCK)
		WHERE RA_FILIAL  = %xFilial:SRA% 
		  AND RA_CLIENTE = %exp:SF2->F2_CLIENTE%
		  AND RA_LOJACLI = %exp:SF2->F2_LOJA%
		  AND SRA.%notDel%
	ENDSQL
	dbSelectArea(_cFUNC)
	if !(_cFUNC)->(EOF())
		_lRET := !((_cFUNC)->RA_SITFOLH == "D") //demitido
	endif
	if Select(_cFUNC) > 0
		(_cFUNC)->(dbCloseArea())
	endif
	if _lRET
		BEGINSQL ALIAS _cSRK
			%noparser%
			SELECT RK_VLRPAGO,RK_STATUS
			FROM %table:SRK% SRK (NOLOCK)
			WHERE RK_FILIAL = %xFilial:SRK% 
			  AND RK_PD     = %exp:_cVERBA%
			  AND RK_XDOC   = %exp:SF2->F2_DOC%
			  AND RK_XSERIE = %exp:SF2->F2_SERIE%
			  AND SRK.%notDel%
		ENDSQL
		dbSelectArea(_cSRK)
		if !(_cSRK)->(EOF())
			_lRET := !((_cSRK)->RK_VLRPAGO > 0 .OR. (_cSRK)->RK_STATUS <> "2")
		endif
		if Select(_cSRK) > 0
			(_cSRK)->(dbCloseArea())
		endif 
	endif
return _lRET