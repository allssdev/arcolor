#INCLUDE 'Protheus.ch'
#INCLUDE 'RwMake.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT010INC  ºAutor  ³ Júlio Soares    º Data ³  14/06/2016   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.TOTVS³ Está localizado na função A010Inclui.                      º±±
±±º          ³ É chamado após incluir o produto, este PE nem confirma nem º±±
±±º          ³ cancela a operação, deve ser utilizado para gravar         º±±
±±º          ³ arquivos/campos do usuário,complementando a inclusão.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus - específico empresa ARCOLOR                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function MT010INC()
	Private _cRotina  := 'MT010INC'
	Private _aSavArea := GetArea()
	Private _aSavSB1  := SB1->(GetArea())
//	Private _aSavAIF  := AIF->(GetArea())
	if Type("_lCpyVld") == "L" // Verifica a variável criada por outro PE para validar se é cópia.
		if _lCpyVld
			while !RecLock("SB1",.F.) ; enddo
				// - Campos de validação engenharia
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
				// - Campos de validação contábil
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
				// - Campos de validação comercial
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
