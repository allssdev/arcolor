#include "totvs.ch"
#include "fweventviewconsts.ch"
#include "colors.ch"
/*/{Protheus.doc} MA200BUT
@description Ponto de Entrada para inser��o das observa��es de altera��es do hist�rico de altera��es das estruturas de produtos.
@author  L�via Della Corte (ALLSS Solu��es em Sistemas)
@since   01/08/2019
@version P12.1.25 - 1.00
@see https://allss.com.br
/*/
user function MA200BUT()
	local _aSavArea := GetArea()
	local cBitMap 	:= 'RELATORIO'
	local cHint   	:= 'Hist. Alt.'
	local aButtons 	:= {{cBitMap,{||xHisto()},cHint}} // Monta array com BITMAP, FUNCAO e HINT
	restarea(_aSavArea)
return aButtons
/*/{Protheus.doc} xHisto (MA200BUT)
@description Sub-rotina de apresenta��o do hist�rico/observa��es das estruras de produtos.
@author  L�via Della Corte (ALLSS Solu��es em Sistemas)
@since   01/08/2019
@version P12.1.25 - 1.00
@see https://allss.com.br
/*/
static function xHisto()
	private _oGet2
	private oDlg
	private _cG1_XOBSHIS
	private aRadio       := {} 
	private aRetorOpc    := {}
	private _nTam        := TamSX3("G1_XOBSHIS")
	private _nTam1       := _nTam[1]
	//+-------------------------------------
	//| Defini��o da janela e seus conte�dos
	//+-------------------------------------
	DEFINE MSDIALOG oDlg TITLE "Hist�rico de Altera��o da Produ��o" FROM 0,0 TO 280,552 OF oDlg PIXEL
		@ 06,06 TO 106,271 LABEL "Hist�rico de Altera��o" OF oDlg PIXEL
		_cG1_XOBSHIS	:= Space(500) 
		@ 25, 12  GET _oGet2  VAR _cG1_XOBSHIS OF oDlg MULTILINE SIZE 248, 060 PIXEL COLORS 0, 16777215 HSCROLL 
		//+-------------------
		//| Botoes da MSDialog
		//+-------------------
		@ 113,235 BUTTON "&Ok"       SIZE 36,16 PIXEL ACTION EVAL( {|| VldObsH(_cG1_XOBSHIS,_oGet2,oDlg) , oDlg:End() })
		@ 113,185 BUTTON "&Cancelar" SIZE 36,16 PIXEL ACTION oDlg:End()
	ACTIVATE MSDIALOG oDlg CENTER
return
/*/{Protheus.doc} VldObsH (MA200BUT)
@description Sub-rotina de valida��o.
@author  L�via Della Corte (ALLSS Solu��es em Sistemas)
@since   01/08/2019
@version P12.1.25 - 1.00

@param _cG1_XOBSHIS, caracter, Observa��es
@param _oGet2, objeto, Objeto do campo de observa��es
@param ODlg, objeto, Objeto da janela

@return .T., boolean, Verdadeiro fixo.

@see https://allss.com.br
/*/
static function VldObsH(_cG1_XOBSHIS,_oGet2,oDlg)
	__ReadVar := "M->G1_XOBSHIS"
	if Empty(M->G1_XOBSHIS)
		M->G1_XOBSHIS	:= "("+DtOc(date())+ " " +time()+ ") "+AllTrim(_cG1_XOBSHIS)
	else
		M->G1_XOBSHIS	:= AllTrim(M->G1_XOBSHIS) + CHR(13)+CHR(10) + "("+DtOc(date())+ " " +time()+ ") " + AllTrim(_cG1_XOBSHIS)
	endif
	oDlg:Refresh()
return .T.
