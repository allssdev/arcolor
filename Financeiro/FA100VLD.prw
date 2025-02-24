#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"

User Function FA100VLD()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FA100VLD  ºAutor  ³ Júlio Soares       º Data ³  06/29/15  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.TOTVS³ O ponto de entrada FA100VLD permite ao usuário criar       º±±
±±º          ³ validações quanto ao acesso para exclusão e cancelamento   º±±
±±º          ³ de movimento bancário.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada utilizado para validar a exclusão do      º±±
±±º          ³ movimento quando esse for da natureza "DESP BANC".         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico empresa ARCOLOR                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Local _lRet    := .T.
Local _lExclui := Paramixb[1]

// - Faz a validação se é exclusão
If _lExclui
	// - Verifica o parâmetro para despesas bancárias
	_cVald := SuperGetMV("MV_NATDPBC",,"DESP BANC",)
	If MSGBOX('Tem certeza que deseja excluir o movimento bancário '+Alltrim(SE5->(E5_NUMERO))+' no valor de R$ ' +;
		cValToChar(SE5->(E5_VALOR)) + ' ?','FA100VLD_001','YESNO')
		// - Faz a validação do tipo de natureza, não tirar as aspas pois o parâmetro está como caracter.
		If '"'+Alltrim(SE5->(E5_NATUREZ))+'"' == _cVald
			If (SE5->(E5_TIPODOC)) == "DB"
				while !RecLock("SE5",.F.) ; enddo
					// - Grava o campo em branco para permitir a exclusão
					SE5->(E5_TIPODOC) := ""
				SE5->(MsUnlock())
				_lRet := .T.
			EndIf
		EndIf
		If _lRet == .F.
			MSGBOX('Não é permitido excluir despesas bancárias inseridas automaticamente pelo sistema. Informe o Administrador do sistema.','FA100VLD_002','ALERT')
		EndIf
	EndIf
EndIf

Return(_lRet)