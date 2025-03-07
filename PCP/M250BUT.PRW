#include 'totvs.ch'
#include "FWEVENTVIEWCONSTS.CH"
#include "COLORS.CH"
#DEFINE _lEnt CHR(13)+CHR(10)
/*/{Protheus.doc} M250BUT
@description Ponto de Entrada para inser��o das observa��es de altera��es do hist�rico de altera��es das estruturas de produtos no abetura das OPs.
@author  L�via Della Corte (ALLSS Solu��es em Sistemas)
@since   01/08/2019
@version P12.1.25 - 1.00
@see https://allss.com.br
/*/
user function M250BUT()
	local _aSavArea := GetArea()
	local cBitMap 	:= 'RELATORIO'
	local cHint   	:= 'Hist. Alt.'
	local aButtons 	:= {{cBitMap,{||xHisto()},cHint}} // Monta array com BITMAP, FUNCAO e HINT
	restarea(_aSavArea)
return aButtons
/*/{Protheus.doc} xHisto
@description Sub-rotina de apresenta��o do hist�rico/observa��es das estruras de produtos.
@author  L�via Della Corte (ALLSS Solu��es em Sistemas)
@since   01/08/2019
@version P12.1.25 - 1.00
@see https://allss.com.br
/*/
static function xHisto()
	//+-------------------------
	//| Declara��es das var�veis
	//+-------------------------
	private oDlg
	private _oGet2
	private _cD3_XOBSHIS
	private aRadio       := {} 
	private aRetorOpc    := {}
	private _nTam        := TamSX3("D3_XOBSHIS")
	private _nTam1       := _nTam[1]
	//+-------------------------------------
	//| Defini��o da janela e seus conte�dos
	//+-------------------------------------
	DEFINE MSDIALOG oDlg TITLE "Hist�rico de Altera��o da Produ��o" FROM 0,0 TO 280,552 OF oDlg PIXEL
		@ 06,06 TO 106,271 LABEL "Hist�rico de Altera��o" OF oDlg PIXEL
		_cD3_XOBSHIS	:= Space(500) 
		@ 25, 12  GET _oGet2  VAR _cD3_XOBSHIS OF oDlg MULTILINE SIZE 248, 060 PIXEL COLORS 0, 16777215 HSCROLL 
		//+-------------------
		//| Botoes da MSDialog
		//+-------------------
		@ 113,235 BUTTON "&Ok"       SIZE 36,16 PIXEL ACTION EVAL( {|| VldObsH(_cD3_XOBSHIS,_oGet2,oDlg) , oDlg:End() })
		@ 113,185 BUTTON "&Cancelar" SIZE 36,16 PIXEL ACTION oDlg:End()
	ACTIVATE MSDIALOG oDlg CENTER
return
/*/{Protheus.doc} VldObsH (MA200BUT)
@description Sub-rotina de valida��o.
@author  L�via Della Corte (ALLSS Solu��es em Sistemas)
@since   01/08/2019
@version P12.1.25 - 1.00

@param _cD3_XOBSHIS, caracter, Observa��es
@param _oGet2, objeto, Objeto do campo de observa��es
@param ODlg, objeto, Objeto da janela

@return .T., boolean, Verdadeiro fixo.

@see https://allss.com.br
/*/
static function VldObsH(_cD3_XOBSHIS,_oGet2,oDlg)
	__ReadVar := "M->D3_XOBSHIS"
	if Empty(M->D3_XOBSHIS)
		M->D3_XOBSHIS	:= "("+DtOc(date())+ " " +time()+ ") "+AllTrim(_cD3_XOBSHIS)
	else
		M->D3_XOBSHIS	:= AllTrim(M->D3_XOBSHIS) + CHR(13)+CHR(10) + "("+DtOc(date())+ " " +time()+ ") " + AllTrim(_cD3_XOBSHIS)
	endif
	oDlg:Refresh()
return .T.
