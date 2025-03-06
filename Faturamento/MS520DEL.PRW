#include "totvs.ch"
/*/{Protheus.doc} MS520DEL
    @description Ponto de Entrada na Exclusão do Documento de Saída
    @author Fernando Bombardi (ALLSS Soluções em Sistemas)
    @since 06/02/2020
    @version 1.0
    @type Function
    @see https://allss.com.br
/*/
user function MS520DEL()
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
	local   oMS520DEL   :=  nil
	if SRK->(FieldPos("RK_XDOC")) > 0 .AND. SRK->(FieldPos("RK_XSERIE")) > 0 .AND. SRK->(FieldPos("RK_XPARC")) > 0
		oMS520DEL       :=  MS520DEL():NEW()
		oMS520DEL:ExcluirValoresFuturos()
	endif
    oMS520DEL           :=  nil
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
return
/*/{Protheus.doc} MS520DEL
	@description Classe para manipulacao de dados na exclusao do faturamento
    @author Fernando Bombardi (ALLSS Soluções em Sistemas)
    @since 06/02/2020
    @version 1.0
    @type class
    @see https://allss.com.br
/*/
class MS520DEL
    data _cRotina    as string
	data _nSeq       as numeric
	data _nStart     as numeric

    Method New() CONSTRUCTOR
    Method ExcluirValoresFuturos()
endclass
/*/{Protheus.doc} New
    @description Metodo construtor 
    @author Fernando Bombardi (ALLSS Soluções em Sistemas)
    @since 06/02/2020
    @version 1.0
    @type method
    @see https://allss.com.br
/*/
method New() class MS520DEL
	::_cRotina   := "MS520DEL"
	::_nSeq      := 1
	::_nStart    := Seconds()
return
/*/{Protheus.doc} IncluirValoresFuturos
    @description Metodo para exclusao dos Valores Futuros para venda a funcionarios
    @author Fernando Bombardi (ALLSS Soluções em Sistemas)
    @since 06/02/2020
    @version 1.0
    @type method
    @see https://allss.com.br
/*/
Method ExcluirValoresFuturos() class MS520DEL
	local   _aCab       := {}
	local   _aItens     := {}
	local   _aLinha     := {}
	local   _cSRK       := GetNextAlias()
	local   _cVERBA     := PadR(SuperGetMV("MV_XVERBAVF",,"505"      ),TamSx3("RV_COD"    )[1])

	private lMsErroAuto := .F.

	if Select(_cSRK) > 0
		(_cSRK)->(dbCloseArea())
	endif
	BEGINSQL ALIAS _cSRK
		%noparser%
		SELECT RK_FILIAL,RK_MAT,RK_PD,RK_VALORTO,RK_PARCELA,RK_DOCUMEN,RK_DTVENC
		FROM %table:SRK% SRK (NOLOCK)
		WHERE RK_FILIAL = %xFilial:SRK% 
		  AND RK_XDOC   = %exp:SF2->F2_DOC%
		  AND RK_XSERIE = %exp:SF2->F2_SERIE%
		  AND SRK.%notDel%
	ENDSQL
	dbSelectArea(_cSRK)
	if !(_cSRK)->(EOF())
		Aadd(_aCab, {"RA_MAT"   , (_cSRK)->RK_MAT    , NIL })
		Aadd(_aCab, {"RA_FILIAL", (_cSRK)->RK_FILIAL , NIL })
		while !(_cSRK)->(EOF())
			_aLinha := {}
			if ALLTRIM(_cVERBA) == ALLTRIM((_cSRK)->RK_PD)
				aadd(_aLinha,{"LINPOS","RK_PD+RK_DOCUMEN", (_cSRK)->RK_PD,(_cSRK)->RK_DOCUMEN })
				aadd(_aLinha,{"AUTDELETA","S",Nil})
			endif 
		//	Aadd(_aLinha,{ "RK_PD"     , (_cSRK)->RK_PD            , NIL})
			Aadd(_aLinha,{ "RK_PD"     , (_cSRK)->RK_PD            , NIL})
			Aadd(_aLinha,{ "RK_VALORTO", (_cSRK)->RK_VALORTO       , NIL})
			Aadd(_aLinha,{ "RK_PARCELA", (_cSRK)->RK_PARCELA       , NIL})
			Aadd(_aLinha,{ "RK_DTVENC" , STOD((_cSRK)->RK_DTVENC)  , NIL})
			Aadd(_aLinha,{ "RK_DOCUMEN", (_cSRK)->RK_DOCUMEN       , NIL})
			Aadd(_aItens,_aLinha)
			(_cSRK)->(dbSkip())
		enddo
		MSExecAuto({|a, b, c| GPEA110(a, b, c) }, 5, _aCab, _aItens)
		if !lMsErroAuto
			FwLogMsg(	"INFO",;
						nil,;					//cTransactionId
						::_cRotina,;
						::_cRotina+"_LOG",;
						::_cRotina+"_LOG_"+StrZero(::_nSeq),;
						StrZero(::_nSeq),;
						("### Valor Futuro eliminado com sucesso. Documento: " + SF2->F2_SERIE + " - " + SF2->F2_DOC),;
						0,;
						(Seconds()-::_nStart),;
						{} ) ; ::_nSeq++
		else
			MostraErro()
			FwLogMsg(	"ERROR",;
						nil,;					//cTransactionId
						::_cRotina,;
						::_cRotina+"_LOG",;
						::_cRotina+"_LOG_"+StrZero(::_nSeq),;
						StrZero(::_nSeq),;
						("### Erro na exclusão do Valor Futuro. Documento: " + SF2->F2_SERIE + " - " + SF2->F2_DOC),;
						0,;
						(Seconds()-::_nStart),;
						{} ) ; ::_nSeq++
		endif
	endif
	if Select(_cSRK) > 0
		(_cSRK)->(dbCloseArea())
	endif 
return
