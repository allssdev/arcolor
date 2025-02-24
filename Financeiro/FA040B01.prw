#INCLUDE 'Protheus.ch'
#INCLUDE 'Rwmake.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FA040B01 ºAutor  ³ Júlio Soares       º Data ³  03/02/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.TOTVS³ O ponto de entrada FA040B01 sera executado apos confirmar  º±±
±±º          ³ a exclusao e antes da gravação dos dados complementares.   º±±
±±º          ³ Se o retorno for .F., não se prosseguirá a deleção do      º±±
±±º          ³ título.                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Este ponto de entrada está sendo utilizado para filtrar os º±±
±±º          ³ usuários que tem autorização para realizar a exclusão de   º±±
±±º          ³ títulos do contas a receber.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico empresa ARCOLOR.                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FA040B01()

Local _aSE1 	:= SE1->(GetArea())
Local _cRotina 	:= "FA040B01"
Local _lRet 	:= .T.
Local cTipo		:= SuperGetMV("MV_XTIPFIN",,"RA/PA")

If !__cUserId $ SuperGetMV("MV_USRFINL",,"000000")
	MSGBOX("Somente usuários autorizados podem realizar a exclusão de títulos a receber.",_cRotina + "_001","STOP")
	_lRet := .F.
EndIf

If SE1->E1_EMISSAO <> ddatabase .and. ALLTRIM(SE1->E1_TIPO) $ cTipo
	MSGBOX("Data de emissão do titulo diferente da data atual do sistema",_cRotina + "_002","STOP")
	_lRet := .F.
Endif

RestArea(_aSE1)

Return(_lRet)
