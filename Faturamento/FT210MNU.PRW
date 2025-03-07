#INCLUDE "RWMAKE.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FT210MNU  �Autor  �Renan Felipe        � Data �  28/02/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para adicionar a op��o recusar na libera��o de regras���
���          � incluindo um evento para gera��o de e-mail para o vendedor ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FT210MNU()

Local _aSavArea := GetArea()
Local _lRet     := .T.

/*
1. Nome a aparecer no cabe�alho
2. Nome da rotina associada
3. Reservado
4. Tipo de transa��o a ser efetuada:
1 - Pesquisa e posiciona em um banco de dados
2 - Apenas mostra os campos
3 - Inclui registros no bancos de dados
4 - Altera o registro corrente
5 - Remove o registro corrente do banco de dados
5. N�vel de acesso
6. Habilita Menu Funcional
*/

aadd(aRotina,{'Recusar','U_RFAT210R()', 0 ,4,0,NIL}) //sendo:Par�metros do array da rotina:

RestArea(_aSavArea)

Return(_lRet)    

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFAT210R  �Autor  �Renan Felipe        � Data �  28/02/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para adicionar a op��o recusar na libera��o de regras���
���          � incluindo um evento para gera��o de e-mail para o vendedor ���
�������������������������������������������������������������������������͹��
���Uso       � Ponto de Entrada FT210MNU - Espec�fico p/ a empresa Arcolor���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

EventInsert("002","001","ZU2",1,"","PEDIDO "+SC5->C5_NUM+" RECUSADO NA AVALIA��O DE REGRAS DO NEGOCIO ","PEDIDO RECUSADO") 

_cPedido := SC5->C5_NUM
EnvEmail()

RestArea(_aSavArea)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFAT210R  �Autor  �Renan Felipe        � Data �  28/02/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina de envio de e-mail com a recusa da avalia��o das     ���
���          �regras de neg�cios.                                         ���
�������������������������������������������������������������������������͹��
���Uso       � User Function RFAT210R localizada no P.E. FT210MNU         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function EnvEmail()

Local _aSvAr     := GetArea()
Local cPara      := ""
Local _cMensagem := ""
Local cServer    := AllTrim(SuperGetMv("MV_RELSERV",,""))
Local cDe        := AllTrim(SuperGetMv("MV_RELFROM",,""))
Local cCC        := AllTrim(SuperGetMv("MV_RELFROM",,""))
Local _cSenha    := AllTrim(SuperGetMv("MV_RELPSW" ,,""))
Local cAssunto   := "Pedido RECUSADO por viola��o de Regras no pedido " + _cPedido
Local lConectou  := .F.
Local lEnviado   := .F.
Local _nVend     := 5				//N�mero de vendedores que receber�o o e-mail
Local xx         := 0

PswOrder(1)							//Ordem: por c�digo de usu�rio
If PswSeek(__cUserId, .T.)			//Retorna o c�digo do usu�rio logado.
	If !Empty(PswRet()[01][14])		//E-mail do usu�rio logado
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
//Neste trecho � montado o formato do e-mail.
_cMensagem += '<html>'
_cMensagem += '<head>'
_cMensagem += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />'
_cMensagem += '<title>Untitled Document</title>'
_cMensagem += '<style type="text/css">'
_cMensagem += '<!--	.style2 {font-family: "Times New Roman", Times, serif; color: #000066;}'
_cMensagem += '		.style3 {font-family: "Times New Roman", Times, serif; color: #000066; font-weight: bold; }-->'
_cMensagem += '</style></head><body>'
_cMensagem += '<p class="style3">Prezado (s)</p>'
_cMensagem += '<p class="style3">O pedido abaixo foi recusado por viola��o de Regras do Negocio:</p>'
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
	MsgAlert("E-mail n�o enviado. N�o foram encontradas contas de e-mail para destino!",_cRotina+"_002")
	RestArea(_aSavSA3)
	RestArea(_aSvAr)
	Return
EndIf
While !lConectou
	CONNECT SMTP SERVER cServer ACCOUNT cDe PASSWORD _cSenha Result lConectou
	xx += 1
	If xx > 20 // Tenta 20 vezes
		MsgAlert("Falha na conex�o para o envio do e-mail de recusa. E-mail n�o enviado!",_cRotina+"_003")
		RestArea(_aSavSA3)
		RestArea(_aSvAr)
		Return
	EndIf
EndDo
If !MailAuth(cDe,_cSenha)
	MsgBox("E-mail n�o enviado. Conta de e-mail n�o autenticada!",_cRotina+"_004","ALERT")
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