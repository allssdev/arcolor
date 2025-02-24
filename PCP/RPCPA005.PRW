#INCLUDE "totvs.ch"

/*/{Protheus.doc} RPCPA005
    Rastreabilidade - Rotina para Recall
    @type  Function
    @author Fernando Bombardi
    @since 23/10/2023
    @version 1.0
    /*/
User Function RPCPA005()
/*Private _aPergs  := {}
Private _cLote   := Space(TamSX3('D3_LOTECTL')[01])
Private _cProdDe := Space(TamSX3('B1_COD')[01])
Private _nTipo   := 1
Private oRPCPC002 := RPCPC002():NEW()
 
aAdd(_aPergs,{1, "Lote"   , _cLote  , "", ".T.", "",    ".T.", 80, .T.})
aAdd(_aPergs,{1, "Produto", _cProdDe, "", ".T.", "SB1", ".T.", 80,  .F.})
aAdd(_aPergs,{2, "Tipo"   , _nTipo  , {"PA", "PI", "MP\EM"}, 80, ".T.", .F.})
aAdd(_aPergs,{11,"Causa"  , "", ".T.", ".T.", .T.})
aAdd(_aPergs,{11,"Efeito" , "", ".T.", ".T.", .T.})

If ParamBox(_aPergs, "Informe os parâmetros")

    oRPCPC002:ConsultaLote(_cLote, _cProdDe, _nTipo, MV_PAR04, MV_PAR05)

EndIf
*/
Private _oDlg As Object
Private _cLote   := Space(TamSX3('D3_LOTECTL')[01]) As String
Private _cProdDe := Space(TamSX3('B1_COD')[01]) As String
Private _aItem   := {"PA", "PI", "MP\EM"} As Array

oFont := TFont():New('Courier new',,-18,.T.)

_oDlg :=TDialog():New(180,180,780,1300,'',,,,,CLR_BLACK,CLR_WHITE,,,.T.)

	otMultiBtn := tMultiBtn():New( 10,10,'Recall de Produtos',_oDlg,,520,150, 'AVG_EMBTO',0,'Mensagem',3 )
	otMultiBtn:SetFonts('Tahoma',16,'Tahoma',10)
	otMultiBtn:AddButton('&Confirmar')
	otMultiBtn:AddButton('&Sair')
	otMultiBtn:bAction := {|x,y| DefinirMenu(y) }

    oSay1  := TSay():New(50,10,{||'Lote:'},_oDlg,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
    oTGet1 := TGet():New(50,50,{||_cLote},_oDlg,096,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F./*lReadOnly*/,.F.,,_cLote,,,, ,,,)

    oSay2  := TSay():New(50,190,{||'Produto:'},_oDlg,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
    oTGet2 := TGet():New(50,250,{||_cProdDe},_oDlg,096,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F./*lReadOnly*/,.F.,,_cProdDe,,,, ,,,)

    oSay3  := TSay():New(50,395,{||'Tipo:'},_oDlg,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
    _cCombo1:= _aItem[1]
    oCombo1 := TComboBox():New(50,451,{|u|if(PCount()>0,_cCombo1:=u,_cCombo1)},;
    _aItem,100,10,_oDlg,,{|| };
    ,,,,.T.,,,,,,,,,'_cCombo1')

    oSay4  := TSay():New(80,10,{||'1- INFORMAÇÕES INICIAIS E-MAIL:'},_oDlg,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
    cTexto1 := ""
    oTMultget1 := tMultiget():new( 90, 10, {| u | if( pCount() > 0, cTexto1 := u, cTexto1 ) }, ;
    _oDlg, 260, 92, , , , , , .T. )

    oSay5  := TSay():New(80,290,{||'2- MOTIVO DO RECOLHIMENTO:'},_oDlg,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
    cTexto2 := ""
    oTMultget2 := tMultiget():new( 90, 290, {| u | if( pCount() > 0, cTexto2 := u, cTexto2 ) }, ;
    _oDlg, 260, 92, , , , , , .T. )          

    oSay6  := TSay():New(190,10,{||'3- RISCO E AGRAVO À SAUDE DOS CONSUMIDORES:'},_oDlg,,oFont,,,,.T.,CLR_RED,CLR_WHITE,230,20)
    cTexto3 := ""
    oTMultget1 := tMultiget():new( 200, 10, {| u | if( pCount() > 0, cTexto3 := u, cTexto3 ) }, ;
    _oDlg, 260, 92, , , , , , .T. )

    oSay7  := TSay():New(190,290,{||'4- ORIENTAÇÕES AOS CONSUMIDORES:'},_oDlg,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
    cTexto4 := ""
    oTMultget2 := tMultiget():new( 200, 290, {| u | if( pCount() > 0, cTexto4 := u, cTexto4 ) }, ;
    _oDlg, 260, 92, , , , , , .T. )          

_oDlg:Activate()

Return

/*/{Protheus.doc} ::DefinirMenu
//TODO Rotina para Menu definição botões rotina.
@author Fernando Bombardi (ALLSS)
@since 27/10/2023
@version 1

@type function 
/*/
Static Function DefinirMenu(_nBtSel)

	DO CASE
		CASE _nBtSel == 1
            oRPCPC002 := RPCPC002():NEW() 
            oRPCPC002:ConsultaLote(_cLote, _cProdDe, _nTipo, MV_PAR04, MV_PAR05)
        OTHERWISE
            _oDlg:End()
	END CASE

Return

