#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} RFATE059
@description Rotina de validação campo A1_TABELA, para não deixar selecionar Tabelas fora de vigência.
@author Arthur Silva
@since 26/10/2015
@version 1.0

@param _cTab, caracter, Código da Tabela de Preços

@return _lRet, Lógico, Validação da tabela de preços selecionada.

@history 01/04/2016, Júlio Soares, Inserido validação de usuário para permitir alteração de tabela, mediante permissão definida no parâmetro "MV_USRVLFT" (Variável lAut).

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
					MsgStop('Tabela fora da vigência. Selecione uma tabela Ativa!',_cRotina+'_001')
				endif
			elseif ALTERA .AND. _lAut
				if DA0->DA0_ATIVO == "1" .AND. (DTOS(DA0->DA0_DATATE)+DA0->DA0_HORATE) >= (DTOS(Date())+ SubStr(Time(),1,5))
					_lRet := .T.
				else
					MsgStop('Usuário sem autorização para alterar a tabela de preços!',_cRotina+'_002')
				endif
			endif
		else
			MsgStop('Tabela de preços não encontrada!',_cRotina+'_003')
		endif
	endif
	RestArea(_aSavDA1)
	RestArea(_aSavDA0)
	RestArea(_aSavArea)
return _lRet