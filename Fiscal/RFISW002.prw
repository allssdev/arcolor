#include 'rwmake.ch'
#include 'protheus.ch'
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "ap5mail.ch"
#include "msgraphi.ch" 
#include "rptdef.ch"
#include "fwprintsetup.ch"                           
#include "jpeg.CH"
#include "avprint.ch"
#include "font.ch"
#include "msole.ch"
#include "vkey.ch"
#include "apwebsrv.ch"
#include "totvs.ch"
/*/{Protheus.doc} RFISW002
@description Classe para o cálculo de impostos pelas rotinas MAFIS...
@author      Anderson C. P. Coelho (ALL System Solutions)
@since       12/07/2019
@version     1.0
@see         https://allss.com.br
/*/
	class RFISW002 
		//Declaração das Propriedades da Classe
		data _aSavArea
		data _aSavSA1
		data _aSavSA2
		data _aSavSB1
		data _aSavSF4
		data _aSavSC5
		data _aSavSC6
		data _aSavSC9
		data _aSavSF2
		data _aSavSD2
		data _cCodCliFor
		data _cLojaCliFor
		data _cCliFor
		data _cTipoNF
		data _cTipoCliFor
		data _cProduto
		data _cTES
		data _nQuantidade
		data _nPreco
		data _cRotina
		data _lCalculou

		data _nValTotal
		data _nValMercadorias
		data _nValICMSST
		data _nValIPI
		data _nValICMS
		data _nValPIS
		data _nValCOFINS

		//Declaração dos Métodos da Classe
		method new() constructor
		method SalvaAmbiente()
		method RestauraAmbiente()
		method CalculaImpostos()
		method RetTotal()
		method RetValSol()
		method RetValIPI()
	endclass
/*/{Protheus.doc} new
@description Metodo construtor da classe, utizado para o cálculo dos impostos por meio da função MAFIS....
@author      Anderson C. P. Coelho (ALL System Solutions)
@since       12/07/2019
@version     1.0
@see         https://allss.com.br
/*/
	method new(_cCodCliFor, _cLojaCliFor, _cCliFor, _cTipoNF, _cTipoCliFor, _cProduto, _cTES, _nQuantidade, _nPreco, _cTipoNF) class RFISW002
		::_aSavArea        := GetArea()
		::_aSavSA1         := SA1->(GetArea())
		::_aSavSA2         := SA1->(GetArea())
		::_aSavSB1         := SA1->(GetArea())
		::_aSavSF4         := SA1->(GetArea())
		::_aSavSC5         := SA1->(GetArea())
		::_aSavSC6         := SA1->(GetArea())
		::_aSavSC9         := SA1->(GetArea())
		::_aSavSF2         := SA1->(GetArea())
		::_aSavSD2         := SA1->(GetArea())
		::_cCodCliFor      := _cCodCliFor
		::_cLojaCliFor     := _cLojaCliFor
		::_cCliFor         := _cCliFor
		::_cTipoCliFor     := _cTipoCliFor
		::_cProduto        := _cProduto
		::_cTES            := _cTES
		::_nQuantidade     := _nQuantidade
		::_nPreco          := _nPreco
		::_cTipoNF         := _cTipoNF
		::_cRotina         := FunName()
		::_lCalculou       := .F.

		::_nValTotal       := 0
		::_nValMercadorias := 0
		::_nValICMSST      := 0
		::_nValIPI         := 0
		::_nValICMS        := 0
		::_nValPIS         := 0
		::_nValCOFINS      := 0

		::SalvaAmbiente()
		::CalculaImpostos()
		::RestauraAmbiente()
	return
/*/{Protheus.doc} SalvaAmbiente
@description Salva o ambiente completo.
@author      Anderson C. P. Coelho (ALL System Solutions)
@since       12/07/2019
@version     1.0
@see         https://allss.com.br
/*/
	method SalvaAmbiente() class RFISW002
		::_aSavArea    := GetArea()
		::_aSavSA1     := SA1->(GetArea())
		::_aSavSA2     := SA1->(GetArea())
		::_aSavSB1     := SA1->(GetArea())
		::_aSavSF4     := SA1->(GetArea())
		::_aSavSC5     := SA1->(GetArea())
		::_aSavSC6     := SA1->(GetArea())
		::_aSavSC9     := SA1->(GetArea())
		::_aSavSF2     := SA1->(GetArea())
		::_aSavSD2     := SA1->(GetArea())
		MaFisSave()
	return
/*/{Protheus.doc} RestauraAmbiente
@description Restaura o ambiente completo.
@author      Anderson C. P. Coelho (ALL System Solutions)
@since       12/07/2019
@version     1.0
@see         https://allss.com.br
/*/
	method RestauraAmbiente() class RFISW002
		RestArea(::_aSavSA1)
		RestArea(::_aSavSA2)
		RestArea(::_aSavSB1)
		RestArea(::_aSavSF4)
		RestArea(::_aSavSC5)
		RestArea(::_aSavSC6)
		RestArea(::_aSavSC9)
		RestArea(::_aSavSF2)
		RestArea(::_aSavSD2)
		RestArea(::_aSavArea)
		MaFisEnd()
		MaFisRestore()
	return
/*/{Protheus.doc} CalculaImpostos
@description Metodo para o cálculo dos impostos pelas funções MAFIS
@author      Anderson C. P. Coelho (ALL System Solutions)
@since       12/07/2019
@version     1.0
@see         https://allss.com.br
/*/
	method CalculaImpostos() class RFISW002
		local   _lRet      := .T.
		MaFisEnd()
		if ::_cCliFor == "C"
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			if !SA1->(MsSeek(xFilial("SA1") + ::_cCodCliFor + ::_cLojaCliFor,.T.,.F.))
				_lRet := .F.
			endif
		elseif ::_cCliFor == "F"
			dbSelectArea("SA2")
			SA2->(dbSetOrder(1))
			if !SA2->(MsSeek(xFilial("SA2") + ::_cCodCliFor + ::_cLojaCliFor,.T.,.F.))
				_lRet := .F.
			endif
		else
			_lRet := .F.
		endif
		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		if _lRet .AND. !SB1->(MsSeek(xFilial("SB1") + ::_cProduto,.T.,.F.))
			_lRet := .F.
		endif
		if _lRet .AND. empty(::_cTES)
			::_cTES := SB1->B1_TS
		endif
		dbSelectArea("SF4")
		SF4->(dbSetOrder(1))
		if _lRet .AND. (empty(::_cTES) .OR. !SF4->(MsSeek(xFilial("SF4") + ::_cTES,.T.,.F.)))
			_lRet := .F.
		endif
		if _lRet
			MaFisIni(	::_cCodCliFor,;
						::_cLojaCliFor,;
						::_cCliFor,;
						::_cTipoNF,;
						::_cTipoCliFor,;
						MaFisRelImp("MTR700",{"SC5","SC6"}),;
						,;
						,;
						"SB1",;
						::_cRotina)
			MaFisAdd(	::_cProduto,;
						::_cTES,;
						::_nQuantidade,;
						::_nPreco,;
						0,;
						"",;
						"",;
						0,;
						0,;
						0,;
						0,;
						0,;
						(::_nQuantidade*::_nPreco),;
						0,;
						SB1->(Recno()) ,;
						SF4->(Recno()) )
			_lCalculou := .T.
			::_nValTotal       := MaFisRet(,"NF_TOTAL")
			::_nValMercadorias := MaFisRet(,"NF_VALMERC")
			::_nValICMSST      := MaFisRet(,"NF_VALSOL")
			::_nValIPI         := MaFisRet(,"NF_VALIPI")
			::_nValICMS        := MaFisRet(,"NF_VALICM")
			::_nValPIS         := MaFisRet(,"NF_VALIMP6")
			::_nValCOFINS      := MaFisRet(,"NF_VALIMP5")
		endif
	return _lRet