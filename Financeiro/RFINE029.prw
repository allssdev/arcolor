#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*/{Protheus.doc} RFINE029
@description Execblock criado para que, se a condição de pagamento for alterado no pedido, pergunta se essa alteração deverá também ser replicado ao cadastro do cliente. Execblock chamado por meio de gatilho, pois o campo que dispara a informação é virtual.  COND - CONDICAO - PAG - PAGAMENTO - PAGTO.
@author Júlio Soares
@since 30/06/2016
@version 1.0
@return _cRet, caracter, Retorna a Condição de pagamento
@type function
@see https://allss.com.br
/*/
user function RFINE029()
	Local _aSavArea := GetArea()
	Local _aSavSA1  := SA1->(GetArea())
	Local _aSavSC5  := SC5->(GetArea())
	Local _aSavSC6  := SC6->(GetArea())
	Local _cRotina	:= 'RFINE029'
	Local _cRet		:= M->C5_CONDPG2

	// Verifica se é alteração
	If !M->C5_TIPO$"D/B"
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1")+M->(C5_CLIENTE + C5_LOJACLI),.T.,.F.))
			If SA1->(A1_COND) <> M->C5_CONDPG2
				If MSGBOX('Deseja alterar a condição de pagamento também no cadastro do cliente '+(Alltrim(SA1->A1_NOME))+' ?',_cRotina+'_001','YESNO');
				.And. __cUserId $ SuperGetMV("MV_USRFINL",,"000000")
					while !RecLock("SA1",.F.) ; enddo
						SA1->A1_COND := M->C5_CONDPG2
					SA1->(MsUnlock())
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea(_aSavSC6)
	RestArea(_aSavSC5)
	RestArea(_aSavSA1)
	RestArea(_aSavArea)
return _cRet