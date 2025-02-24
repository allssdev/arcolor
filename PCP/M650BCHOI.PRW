#include 'totvs.ch'
#include "FWEVENTVIEWCONSTS.CH"
#include "COLORS.CH"
#DEFINE _lEnt CHR(13)+CHR(10)
/*/{Protheus.doc} M650BCHOI
@description Ponto de Entrada para inserção das observações de alterações do histórico de alterações das estruturas de produtos no apontamento das OPs.
@author  Lívia Della Corte (ALLSS Soluções em Sistemas)
@since   01/08/2019
@version P12.1.25 - 1.00
@see https://allss.com.br
/*/
user function M650BCHOI()
	local _aSavArea  := GetArea()
	local   _lAlt    := iiF( AllTrim(UPPER(FUNNAME()))== "A650DELETA",.T.,.F.)
	local   cBitMap  := 'RELATORIO'
	local   cHint    := 'Hist. Alt.'
	local   aButtons := {}
	if _lAlt
		aButtons:= {{cBitMap,{||xHisto()},cHint}} // Monta array com BITMAP, FUNCAO e HINT
	endif
	restarea(_aSavArea)
return aButtons
/*/{Protheus.doc} xHisto
@description Sub-rotina de apresentação do histórico/observações das estruras de produtos.
@author  Lívia Della Corte (ALLSS Soluções em Sistemas)
@since   01/08/2019
@version P12.1.25 - 1.00
@see https://allss.com.br
/*/
static function xHisto()
	private oDlg
	private _oGet2
	private _cC2_XOBSHIS
	private aRadio       := {} 
	private aRetorOpc    := {}
	private _nTam        := TamSX3("C2_XOBSHIS")
	private _nTam1       := _nTam[1]
	private _cQUpd2      := ""
	//+-------------------------------------
	//| Definição da janela e seus conteúdos
	//+-------------------------------------
	DEFINE MSDIALOG oDlg TITLE "Histórico de Alteração da Produção" FROM 0,0 TO 280,552 OF oDlg PIXEL
		@ 06,06 TO 106,271 LABEL "Histórico de Alteração" OF oDlg PIXEL
		 _cC2_XOBSHIS	:= Space(500) 
		@ 25, 12  GET _oGet2  VAR _cC2_XOBSHIS OF oDlg MULTILINE SIZE 248, 060 PIXEL COLORS 0, 16777215 HSCROLL 
		//+-------------------
		//| Botoes da MSDialog
		//+-------------------
		@ 113,235 BUTTON "&Ok"       SIZE 36,16 PIXEL ACTION EVAL( {|| VldObsH(_cC2_XOBSHIS,_oGet2,oDlg) , oDlg:End() })
		@ 113,185 BUTTON "&Cancelar" SIZE 36,16 PIXEL ACTION oDlg:End()
	ACTIVATE MSDIALOG oDlg CENTER
return
/*/{Protheus.doc} VldObsH (MA200BUT)
@description Sub-rotina de validação.
@author  Lívia Della Corte (ALLSS Soluções em Sistemas)
@since   01/08/2019
@version P12.1.25 - 1.00

@param _cC2_XOBSHIS, caracter, Observações
@param _oGet2, objeto, Objeto do campo de observações
@param ODlg, objeto, Objeto da janela

@return .T., boolean, Verdadeiro fixo.

@see https://allss.com.br
/*/
static function VldObsH(_cC2_XOBSHIS,_oGet2,oDlg)
	__ReadVar := "M->C2_XOBSHIS"
	if Empty(M->C2_XOBSHIS)
		M->C2_XOBSHIS	:= "("+DtOc(date())+ " " +time()+ ") "+AllTrim(_cC2_XOBSHIS)
	else
		M->C2_XOBSHIS	:= AllTrim(M->C2_XOBSHIS) + CHR(13)+CHR(10) + "("+DtOc(date())+ " " +time()+ ") " + AllTrim(_cC2_XOBSHIS)
	endif
	oDlg:Refresh()
return .T.
