#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±º                                                                       º±±
±±º     ROTINA DESATIVDA - AGUARDANDO VALIDAÇÃO DO PROCESSO FINANCEIRO    º±±
±±º                                                                       º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FA050INC ºAutor  ³ Júlio Soares       º Data ³  02/07/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.TOTVS³ O ponto de entrada FA050INC - será executado na validação  º±±
±±º          ³ da Tudo Ok na inclusão do contas a pagar.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada sendo utilizado para validar o tipo do    º±±
±±º          ³ título que está sendo incluido, se for diferente de PA ou  º±±
±±º          ³ PR não permite a inclusão manual.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico empresa ARCOLOR                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FA050INC()

Local _lRet     := .T.
/*Local _aSavArea := GetArea()
Local _cRotina  := "FA050INC"
Local _cTpcp    := SuperGetMv("MV_TIPOSCP",,"PA/PR") // "PR/PA/DPV/TCN/CLN"



If !Empty(_cTpcp)
	If !Alltrim((M->E2_TIPO)) $ _cTpcp
		MSGBOX("Usuário sem permissão para incluir títulos a pagar no financeiro, apenas títulos do tipo PA (Pagamento Antecipado) e PR "+;
		" (Provisório) podem ser incluidos. " + CHR(10) + CHR(13) + "Informe o administrador do sistema",_cRotina+"_001","STOP")
		_lRet := .F.
	EndIf
Else
	MSGBOX("Usuário sem permissão para incluir títulos a pagar no financeiro, verifique o parâmetro 'MV_TIPOSPC' ou informe o Administrador do sistema. ",_cRotina+"_002","STOP")
	_lRet := .F.
EndIf


RestArea(_aSavArea)*/

Return(_lRet)