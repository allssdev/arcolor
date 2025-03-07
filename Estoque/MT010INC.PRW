#INCLUDE 'Protheus.ch'
#INCLUDE 'RwMake.ch'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MT010INC  �Autor  � J�lio Soares    � Data �  14/06/2016   ���
�������������������������������������������������������������������������͹��
���Desc.TOTVS� Est� localizado na fun��o A010Inclui.                      ���
���          � � chamado ap�s incluir o produto, este PE nem confirma nem ���
���          � cancela a opera��o, deve ser utilizado para gravar         ���
���          � arquivos/campos do usu�rio,complementando a inclus�o.      ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus - espec�fico empresa ARCOLOR                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function MT010INC()
	Private _cRotina  := 'MT010INC'
	Private _aSavArea := GetArea()
	Private _aSavSB1  := SB1->(GetArea())
//	Private _aSavAIF  := AIF->(GetArea())
	if Type("_lCpyVld") == "L" // Verifica a vari�vel criada por outro PE para validar se � c�pia.
		if _lCpyVld
			while !RecLock("SB1",.F.) ; enddo
				// - Campos de valida��o engenharia
				If SB1->(FieldPos("B1_DATVENG")) <> 0
					SB1->B1_DATVENG := dDatabase
				endif
				If SB1->(FieldPos("B1_NOMVENG")) <> 0
					SB1->B1_NOMVENG := RetCodUsr()+"-"+cUserName
		    	endif
				If SB1->(FieldPos("B1_DTATENG")) <> 0
					SB1->B1_DTATENG := dDatabase
		    	endif
				If SB1->(FieldPos("B1_HRATENG")) <> 0
					SB1->B1_HRATENG := time()
		    	endif
				// - Campos de valida��o cont�bil
				If SB1->(FieldPos("B1_DATVCTB")) <> 0
					SB1->B1_DATVCTB := CtoD("")
		    	endif
				If SB1->(FieldPos("B1_NOMVCTB")) <> 0
					SB1->B1_NOMVCTB := ""
		    	endif
				If SB1->(FieldPos("B1_DTATCTB")) <> 0
					SB1->B1_DTATCTB := CtoD("")
		    	endif
				If SB1->(FieldPos("B1_HRATCTB")) <> 0
					SB1->B1_HRATCTB := ""
		    	endif
				// - Campos de valida��o comercial
				If SB1->(FieldPos("B1_DATVCOM")) <> 0
					SB1->B1_DATVCOM := CtoD("")
		    	endif
				If SB1->(FieldPos("B1_NOMVCOM")) <> 0
					SB1->B1_NOMVCOM := ""
		    	endif
				If SB1->(FieldPos("B1_DTATCOM")) <> 0
					SB1->B1_DTATCOM := CtoD("")
		    	endif
				If SB1->(FieldPos("B1_HRATCOM")) <> 0
					SB1->B1_HRATCOM := ""
				endif
			SB1->(MsUnLock())
			_lCpyVld := .F.
		endif
	endif
	//14/08/2024 - Diego Rodrigues - Envio de mensagens para os responsaveis informando que houve um cadastro de novo produto
	If SB1->B1_TIPO $ 'MP/EM'
		U_RESTE013(Alltrim(SB1->B1_COD),Alltrim(SB1->B1_DESC))
	EndIf

//	RestArea(_aSavAIF) removido tambem restarea por errolog na inclusao de produto
	RestArea(_aSavSB1)
	RestArea(_aSavArea)
return
