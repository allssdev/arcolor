#INCLUDE "RWMAKE.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FT210MNU  ºAutor  ³Renan Felipe        º Data ³  28/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para adicionar a opção recusar na liberação de regrasº±±
±±º          ³ incluindo um evento para geração de e-mail para o vendedor º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FT210MNU()

Local _aSavArea := GetArea()
Local _lRet     := .T.

/*
1. Nome a aparecer no cabeçalho
2. Nome da rotina associada
3. Reservado
4. Tipo de transação a ser efetuada:
1 - Pesquisa e posiciona em um banco de dados
2 - Apenas mostra os campos
3 - Inclui registros no bancos de dados
4 - Altera o registro corrente
5 - Remove o registro corrente do banco de dados
5. Nível de acesso
6. Habilita Menu Funcional
*/

aadd(aRotina,{'Recusar','U_RFAT210R()', 0 ,4,0,NIL}) //sendo:Parâmetros do array da rotina:

RestArea(_aSavArea)

Return(_lRet)    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFAT210R  ºAutor  ³Renan Felipe        º Data ³  28/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para adicionar a opção recusar na liberação de regrasº±±
±±º          ³ incluindo um evento para geração de e-mail para o vendedor º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ponto de Entrada FT210MNU - Específico p/ a empresa Arcolorº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFAT210R()

Local _aSavArea  := GetArea()

Private _cPedido := ""
Private _cRotina := "RFAT210R"

MsgAlert("PEDIDO RECUSADO!",_cRotina+"_001")
dbSelectArea("SC5")
If AllTrim(SC5->C5_RECUSA) <> "S"
	while !RecLock("SC5",.F.) ; enddo
		SC5->C5_RECUSA := "S"
	SC5->(MsUnlock())
EndIf

EventInsert("002","001","ZU2",1,"","PEDIDO "+SC5->C5_NUM+" RECUSADO NA AVALIAÇÃO DE REGRAS DO NEGOCIO ","PEDIDO RECUSADO") 

_cPedido := SC5->C5_NUM
EnvEmail()

RestArea(_aSavArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFAT210R  ºAutor  ³Renan Felipe        º Data ³  28/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de envio de e-mail com a recusa da avaliação das     º±±
±±º          ³regras de negócios.                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ User Function RFAT210R localizada no P.E. FT210MNU         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function EnvEmail()

Local _aSvAr     := GetArea()
Local cPara      := ""
Local _cMensagem := ""
Local cServer    := AllTrim(SuperGetMv("MV_RELSERV",,""))
Local cDe        := AllTrim(SuperGetMv("MV_RELFROM",,""))
Local cCC        := AllTrim(SuperGetMv("MV_RELFROM",,""))
Local _cSenha    := AllTrim(SuperGetMv("MV_RELPSW" ,,""))
Local cAssunto   := "Pedido RECUSADO por violação de Regras no pedido " + _cPedido
Local lConectou  := .F.
Local lEnviado   := .F.
Local _nVend     := 5				//Número de vendedores que receberão o e-mail
Local xx         := 0

PswOrder(1)							//Ordem: por código de usuário
If PswSeek(__cUserId, .T.)			//Retorna o código do usuário logado.
	If !Empty(PswRet()[01][14])		//E-mail do usuário logado
		cDe := PswRet()[01][14]
		If !Empty(cCC)
			cCC += ";"
		EndIf
		cCC += AllTrim(PswRet()[01][14])
	EndIf
EndIf
dbselectarea("SA3")
_aSavSA3 := SA3->(GetArea())
SA3->(dbSetOrder(1))
For _vd := 1 To _nVend
	If SA3->(MsSeek(xFilial("SA3") + &("SC5->C5_VEND"+cValToChar(_vd)),.T.,.F.)) .AND. !Empty(SA3->A3_EMAIL)
		If !Empty(cPara)
			cPara += ";"
		EndIf
		cPara += AllTrim(SA3->A3_EMAIL)
	EndIf
Next
//Neste trecho é montado o formato do e-mail.
_cMensagem += '<html>'
_cMensagem += '<head>'
_cMensagem += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />'
_cMensagem += '<title>Untitled Document</title>'
_cMensagem += '<style type="text/css">'
_cMensagem += '<!--	.style2 {font-family: "Times New Roman", Times, serif; color: #000066;}'
_cMensagem += '		.style3 {font-family: "Times New Roman", Times, serif; color: #000066; font-weight: bold; }-->'
_cMensagem += '</style></head><body>'
_cMensagem += '<p class="style3">Prezado (s)</p>'
_cMensagem += '<p class="style3">O pedido abaixo foi recusado por violação de Regras do Negocio:</p>'
_cMensagem += '<p class="style3">Dados:</p>'
_cMensagem += '<table width="760" border="1">'
_cMensagem += '<tr><td width="86"><strong class="style3">Pedido:</strong></td>'
_cMensagem += '<td width="464"><span class="style2">' + _cPedido+ '</span></td></tr>'
_cMensagem += '<tr><td><span class="style2"><strong>Data:</strong></span></td>
_cMensagem += '<td><span class="style2">' + Dtoc(dDataBase) + '</span></td></tr>'
_cMensagem += '</table><p class="style2">&nbsp; </p><p>&nbsp;</p></body>'
_cMensagem += '<p class="style3">Contato:</p>'
_cMensagem += '<p class="style3">Setor Comercial</p>'
_cMensagem += '<p class="style3">Fone:(11) XXXX-XXXX Ramal: XXXX </p>'
_cMensagem += '</html>'

If Empty(cPara)
	MsgAlert("E-mail não enviado. Não foram encontradas contas de e-mail para destino!",_cRotina+"_002")
	RestArea(_aSavSA3)
	RestArea(_aSvAr)
	Return
EndIf
While !lConectou
	CONNECT SMTP SERVER cServer ACCOUNT cDe PASSWORD _cSenha Result lConectou
	xx += 1
	If xx > 20 // Tenta 20 vezes
		MsgAlert("Falha na conexão para o envio do e-mail de recusa. E-mail não enviado!",_cRotina+"_003")
		RestArea(_aSavSA3)
		RestArea(_aSvAr)
		Return
	EndIf
EndDo
If !MailAuth(cDe,_cSenha)
	MsgBox("E-mail não enviado. Conta de e-mail não autenticada!",_cRotina+"_004","ALERT")
	RestArea(_aSavSA3)
	RestArea(_aSvAr)
	Return
Endif
xx := 0
While !lEnviado
	SEND MAIL FROM cDe TO cPara CC cCC SUBJECT cAssunto BODY _cMensagem RESULT lEnviado
	xx += 1
	If xx > 20 // Tenta 20 vezes
		MsgAlert("Falha no envio do e-mail de recusa!",_cRotina+"_005")
		RestArea(_aSavSA3)
		RestArea(_aSvAr)
		Return
	EndIf
Enddo

DISCONNECT SMTP SERVER

If lConectou .AND. lEnviado
	MsgInfo("OK! E-mail enviado com sucesso para o(s) vendedor(es)!",_cRotina+"_005")
Else
	MsgAlert("Erro - E-mail nao enviado ! Contate o Administrador !",_cRotina+"_006")
	GET MAIL ERROR cError
	MsgAlert(cError,,_cRotina+"_007")
EndIf

RestArea(_aSavSA3)
RestArea(_aSvAr)

Return