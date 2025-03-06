#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � A010TOK   �Autor  �Arthur F. da Silva	� Data � 04/09/17 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada chamado No in�cio das valida��es ap�s a   ���
���				confirma��o da inclus�o ou altera��o, antes da grava��o do���
���				Produto; deve ser utilizado para valida��es adicionais para��
���				a INCLUS�O ou ALTERA��O do Produto.						  ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function A010TOK()
	Local   _aSavSB1   := SB1->(GetArea())
	Local   _aSavSB5   := SB5->(GetArea())
	Local _cRotina  := "A010TOK"
	Local _cProduto := M->B1_COD

	Local _nQuant   := M->B1_VOSEC
	Local _nUnit   := M->B1_VOPRIN
	Local _cCodBar  := M->B1_CODBAR2
	Local _cCodBarU  := M->B1_CODBAR
	Local _lRet		:= .T.

	If M->B1_TIPO == 'PA' .and. M->B1_UM <> 'BB' .and. Empty(M->B5_XCORETQ)
			MsgInfo("As informa��es referente as etiquetas na aba ACD do complemento do produto est�o em branco. Favor preencher os campos 'Desc Etiqueta', 'Cor Etiqueta', 'Mod Etiqueta'","ATEN��O")
			_lRet		:= .F.
	EndIf
	


	if M->B1_MSBLQL <> '1' .AND. M->B1_TIPO = 'PA' .and. _nQuant <> 0 .and. !Empty(_cProduto)
			dbSelectArea("SLK")
			SLK ->(dbSetOrder(2))
			if !SLK->(MsSeek(xFilial("SLK") + _cProduto + _cCodBar ,.T.,.F.))
					//dbSelectArea("SLK")
					//SLK ->(dbSetOrder(1))
					//if !SLK->(MsSeek(xFilial("SLK") + _cCodBar,.T.,.F.))
						If !EMPTY(_cCodBar)
							while !RecLock("SLK",.T.) ; enddo
								SLK->LK_FILIAL  := xFilial("SLK")
								SLK->LK_CODBAR  := _cCodBar
								SLK->LK_CODIGO  := _cProduto
								SLK->LK_QUANT   := _nQuant
							SLK->(MSUNLOCK())
						EndIf
					//EndIf	
			else
				//if SLK->LK_CODBAR <> _cCodBar	 
				If SLK->(MsSeek(xFilial("SLK") + _cProduto + _cCodBar ,.T.,.F.)) 
					//deleto o existente
					while !RecLock("SLK",.F.) ; enddo
					dbDelete()
					SLK->(MSUNLOCK())
					
					//incluo a altera��o
					while !RecLock("SLK",.T.) ; enddo
							SLK->LK_FILIAL  := xFilial("SLK")
							SLK->LK_CODBAR  := _cCodBar
							SLK->LK_CODIGO  := _cProduto
							SLK->LK_QUANT   := _nQuant
					SLK->(MSUNLOCK())
					
				EndIf
			endif
		
			dbSelectArea("SLK")
			SLK ->(dbSetOrder(2))
			if !SLK->(MsSeek(xFilial("SLK") + _cProduto + _cCodBarU ,.T.,.F.))
					//dbSelectArea("SLK")
					//SLK ->(dbSetOrder(1))
					//if !SLK->(MsSeek(xFilial("SLK") + _cCodBar,.T.,.F.))
					If !EMPTY(_cCodBar)
						while !RecLock("SLK",.T.) ; enddo
							SLK->LK_FILIAL  := xFilial("SLK")
							SLK->LK_CODBAR  := _cCodBarU
							SLK->LK_CODIGO  := _cProduto
							SLK->LK_QUANT   := _nUnit
						SLK->(MSUNLOCK())
					Endif
					//EndIf	
			else
				//if SLK->LK_CODBAR <> _cCodBar	 
				If SLK->(MsSeek(xFilial("SLK") + _cProduto + _cCodBarU ,.T.,.F.)) 
					//deleto o existente
					//while !RecLock("SLK",.F.) ; enddo
					//dbDelete()
					//SLK->(MSUNLOCK())
					
					//incluo a altera��o
					RecLock("SLK",.F.) 
						SLK->LK_FILIAL  := xFilial("SLK")
						SLK->LK_CODBAR  := _cCodBarU
						SLK->LK_CODIGO  := _cProduto
						SLK->LK_QUANT   := _nUnit
					SLK->(MSUNLOCK())
				EndIf
			endif
	endif
	
	RestArea(_aSavSB1)
	RestArea(_aSavSB5)
return _lRet
