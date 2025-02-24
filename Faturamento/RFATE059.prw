#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} RFATE059
@description Rotina de valida��o campo A1_TABELA, para n�o deixar selecionar Tabelas fora de vig�ncia.
@author Arthur Silva
@since 26/10/2015
@version 1.0

@param _cTab, caracter, C�digo da Tabela de Pre�os

@return _lRet, L�gico, Valida��o da tabela de pre�os selecionada.

@history 01/04/2016, J�lio Soares, Inserido valida��o de usu�rio para permitir altera��o de tabela, mediante permiss�o definida no par�metro "MV_USRVLFT" (Vari�vel lAut).

@type function

@see https://allss.com.br
/*/
user function RFATE059(_cTab)
	local   _aSavArea := GetArea()
	local   _aSavDA0  := DA0->(GetArea())
	local   _aSavDA1  := DA1->(GetArea())
	local   _cRotina  := "RFATE059"
	local   _lRet     := .F.
	local   _lAut     := __cUserId $ (SuperGetMv("MV_USRVLFT",,"000000/000019"))

	default _cTab     := ""

	if !Empty(_cTab)
		dbSelectArea("DA0")
		DA0->(dbSetOrder(1))
		if DA0->(MsSeek(xFilial("DA0") + _cTab,.T.,.F.))
			if INCLUI
				if DA0->DA0_ATIVO == "1" .AND. (DTOS(DA0->DA0_DATATE)+DA0->DA0_HORATE) >= (DTOS(Date())+ SubStr(Time(),1,5))
					_lRet := .T.
				else
					MsgStop('Tabela fora da vig�ncia. Selecione uma tabela Ativa!',_cRotina+'_001')
				endif
			elseif ALTERA .AND. _lAut
				if DA0->DA0_ATIVO == "1" .AND. (DTOS(DA0->DA0_DATATE)+DA0->DA0_HORATE) >= (DTOS(Date())+ SubStr(Time(),1,5))
					_lRet := .T.
				else
					MsgStop('Usu�rio sem autoriza��o para alterar a tabela de pre�os!',_cRotina+'_002')
				endif
			endif
		else
			MsgStop('Tabela de pre�os n�o encontrada!',_cRotina+'_003')
		endif
	endif
	RestArea(_aSavDA1)
	RestArea(_aSavDA0)
	RestArea(_aSavArea)
return _lRet