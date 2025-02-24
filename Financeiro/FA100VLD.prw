#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"

User Function FA100VLD()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FA100VLD  �Autor  � J�lio Soares       � Data �  06/29/15  ���
�������������������������������������������������������������������������͹��
���Desc.TOTVS� O ponto de entrada FA100VLD permite ao usu�rio criar       ���
���          � valida��es quanto ao acesso para exclus�o e cancelamento   ���
���          � de movimento banc�rio.                                     ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada utilizado para validar a exclus�o do      ���
���          � movimento quando esse for da natureza "DESP BANC".         ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa ARCOLOR                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Local _lRet    := .T.
Local _lExclui := Paramixb[1]

// - Faz a valida��o se � exclus�o
If _lExclui
	// - Verifica o par�metro para despesas banc�rias
	_cVald := SuperGetMV("MV_NATDPBC",,"DESP BANC",)
	If MSGBOX('Tem certeza que deseja excluir o movimento banc�rio '+Alltrim(SE5->(E5_NUMERO))+' no valor de R$ ' +;
		cValToChar(SE5->(E5_VALOR)) + ' ?','FA100VLD_001','YESNO')
		// - Faz a valida��o do tipo de natureza, n�o tirar as aspas pois o par�metro est� como caracter.
		If '"'+Alltrim(SE5->(E5_NATUREZ))+'"' == _cVald
			If (SE5->(E5_TIPODOC)) == "DB"
				while !RecLock("SE5",.F.) ; enddo
					// - Grava o campo em branco para permitir a exclus�o
					SE5->(E5_TIPODOC) := ""
				SE5->(MsUnlock())
				_lRet := .T.
			EndIf
		EndIf
		If _lRet == .F.
			MSGBOX('N�o � permitido excluir despesas banc�rias inseridas automaticamente pelo sistema. Informe o Administrador do sistema.','FA100VLD_002','ALERT')
		EndIf
	EndIf
EndIf

Return(_lRet)