#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
/*/{Protheus.doc} RFATE027
@description Execblock chamado na rotna "SF2520E para a apresentação de uma tela onde será inserido o motivo pela qual a nota fiscal está sendo excluida                                         º±±
@author Júlio Soares
@since 26/04/2013
@version 1.0
@type function
@return _lRet, lógico, valida se será ou não permitida a exclusão do documento de saída.
@history 11/07/2019, Anderson Coelho, Rotina corrigida e organizada.
@history 05/05/2023, Livia Corte, Adequação da rotina para inserir o motivo na tabela SF3
@history 11/05/2023, Diego Rodrigues, Adequação da rotina para inserir o motivo na tabela SF2 devido a cancelamentos de romaneio.
@see https://allss.co
m.br
/*/
user function RFATE027()
	local   _aSavArea  := GetArea()
//	local   cTexto
	local   oMemo
//	local   cMemo
	local   oConfirma
	local   oCancela
	local   oSay1

	private _cRotina   := "RFATE027"
	private _cTexto    := ""
//	private _cMemo     := ""
	private _lRet      := .F.

	if SF2->(FieldPos("F2_MOTEXCL")) > 0 
		static  oDlg
		DEFINE MSDIALOG oDlg TITLE "SF2520E - "+_cRotina FROM 000, 000  TO 270, 400 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME // Inibe o botao "X" da tela
			oDlg:lEscClose := .F.//Não permite fechar a tela com o "Esc"
			@ 020, 002 GET    oMemo     VAR _cTexto OF oDlg MULTILINE				SIZE 197, 092  COLORS 0, 16777215 NO VSCROLL PIXEL
			@ 115, 145 BUTTON oConfirma PROMPT "Confirma"							SIZE 050, 015 OF oDlg ACTION Gravar()        PIXEL
			@ 115, 085 BUTTON oCancela  PROMPT "Cancela"							SIZE 050, 015 OF oDlg ACTION Cancelar()      PIXEL
			@ 005, 002 SAY    oSay1     PROMPT "MOTIVO DA EXCLUSÃO DA NOTA FISCAL"	SIZE 150, 012 OF oDlg COLORS 0, 16777215     PIXEL
		ACTIVATE MSDIALOG oDlg CENTERED
	endif
	RestArea(_aSavArea)
return _lRet
/*/{Protheus.doc} Cancelar
@description Sub-rotina de cancelamento (SEM USO NESTE PONTO DE ENTRADA), usada no fonte "RFATE027".
@author Júlio Soares
@since 31/01/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function Cancelar()
	if MsgBox("Deseja realmente cancelar?",_cRotina+"_001","YESNO")
		Close(oDlg)
	endif
return
/*/{Protheus.doc} Gravar
@description Sub-rotina de gravação, usada no fonte "RFATE027".
@author Júlio Soares
@since 31/01/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function Gravar()
	private _cPedCanc := ""
	private _cAtCanc  := ""
	dbSelectArea("SF2")
	SF2->(dbSetOrder(1))
	If SF2->(dbSeek(xFilial("SF2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
		if !empty(_cTexto)
			if !len(_cTexto) <=15
				while !RecLock("SF2",.F.) ; enddo
					SF2->F2_MOTEXCL := _cTexto
				SF2->(MsUnLock())
				_lRet := .T.
				if _lRet .And.  ExistBlock("RFATL001")
					_cLogx := "Documento Cancelado! Motivo:" +  _cTexto
					RetPedAt(SF2->F2_DOC,SF2->F2_SERIE)
					if _cAtCanc <> '' .AND. _cPedCanc <> ''	
						U_RFATL001(	_cPedCanc	,;
									_cAtCanc	,;
									_cLogx		,;
									_cRotina    )
					endif	
					Close(oDlg)
				endif
			else
				_lRet := .F.
				MsgBox("Descreva um motivo válido!",_cRotina+"_002","ALERT")
			endif			
		else
			_lRet := .F.
			MSGBOX("É necessário informar uma descrição para informar o motivo da exclusão da Nota Fiscal!",_cRotina+"_003","STOP")
		endif
	
	else
		_lRet := .F.
		MSGBOX("É necessário informar uma descrição para informar o motivo da exclusão da Nota Fiscal!",_cRotina+"_004","STOP")
	endif

return _lRet
static function RetPedAt(_cNota,_cSerie)
	local _cAtemp := GetNextAlias()	//"PedCancTemp"

	default _cNota  := ""
	default _cSerie := ""

	if !empty(_cNota+_cSerie)
		BeginSql Alias _cAtemp
			SELECT UA_NUMSC5, UA_NUM
			FROM %table:SUA% SUA (NOLOCK)
			WHERE SUA.UA_FILIAL   = %xFilial:SUA%
			  AND SUA.UA_DOC    = %Exp:_cNota%
			  AND SUA.UA_SERIE  = %Exp:_cSerie%
			  AND SUA.%NotDel%
		EndSql
		dbSelectArea(_cAtemp)
		(_cAtemp)->(dbGoTop())
		if (_cAtemp)->(!EOF())
			_cAtCanc  := (_cAtemp)->UA_NUM
			_cPedCanc := (_cAtemp)->UA_NUMSC5
		endif
	endif
return
