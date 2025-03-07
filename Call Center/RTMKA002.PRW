#include "totvs.ch"
/*/{Protheus.doc} RTMKA002
@description Rotina para a chamar a rotina padr�o do sistema, de acordo com a op��o selecionada pelo usu�rio (Telemarketing, Televendas ou o que estiver cadastrado no cadastro de operadores.
@author J�lio Soares
@since 21/12/2015
@version 1.0
@type function
@history 29/07/2020, Anderson C. P. Coelho (ALLSS Soluc��es em Sistemas), Retirada a telinha de sele��o entre as op��es "Telemarketing", "Televendas" e "Telecobran�a", sendo definida a rotina fixa "Televendas", pois foi definido como regra de neg�cio nesta oportunidade junto ao Sr. Marco Antonio que os usu�rios que tiverem esta rotina no menu, acessar�o o Televendas, independente de sua permiss�o definida no cadastro de operadores. As demais rotinas dever�o ser configuradas e acessadas pelo referido cadastro, no modelo padr�o do Protheus.
@see https://allss.com.br
/*/
user function RTMKA002()  
	Local _aAlias	 := GetArea()
	//29/07/2020 - Anderson C. P. Coelho (ALLSS Soluc��es em Sistemas) - Vari�veis comentadas por n�o estarem mais em uso.
	//Local oButOk
	//Local oButCl
	//Local oGroup1
	//Local oRadOpc

	Private _cRotina := "RTMKA002"
	Private _nOpc    := 2				//29/07/2020 - Anderson C. P. Coelho (ALLSS Soluc��es em Sistemas) - Alterado de 1 para 2, para desviar a rotina para que n�o apresente a telinha de selecao, mas entre direto no teleatendimento (opcao 2)

	//29/07/2020 - Anderson C. P. Coelho (ALLSS Soluc��es em Sistemas) - Incluido para desviar a rotina para que n�o apresente a telinha de selecao, mas entre direto no teleatendimento (opcao 2). Sendo assim, a telinha foi comentada!
	Confirm()
	/*
	static oDlg

	  DEFINE MSDIALOG oDlg TITLE "RTMKA002" FROM 000, 000  TO 145, 170 COLORS 0, 16777215 PIXEL
	    @ 005, 005 GROUP oGroup1 TO 052, 080 PROMPT "Selecione o atendimento" OF oDlg COLOR 0, 16777215 PIXEL
	    @ 017, 015 RADIO oRadOpc VAR _nOpc ITEMS "TeleMarketing"," TeleVendas"," TeleCobran�a" SIZE 050, 025 OF oDlg COLOR 0, 16777215 PIXEL
	    @ 057, 020 BUTTON oButOK PROMPT "Cancelar" 	SIZE 030, 010 OF oDlg ACTION Cancelr() PIXEL
	    @ 057, 052 BUTTON oButCl PROMPT "Confirmar"	SIZE 030, 010 OF oDlg ACTION Confirm() PIXEL
	  ACTIVATE MSDIALOG oDlg CENTERED
	  */
	  RestArea(_aAlias)
return
/*/{Protheus.doc} Confirm (RTMKA002)
@description Sub-fun��o de altera��o do tipo de acesso a rotina de Televendas no cadastro do operador logado.
@author J�lio Soares
@since 16/05/2016
@version 1.0
@type function
@history 29/07/2020, Anderson C. P. Coelho (ALLSS Soluc��es em Sistemas), Rotina ajustada para atender as altera��es realizadas nesta data.
@see https://allss.com.br
/*/
static function Confirm()
	private _cCodUsr := ""
	PswOrder(1)
	if PswSeek(__cUserId)
		_cCodUsr := PswRet()[1][1]
	endif
	dbSelectArea("SU7")
	SU7->(dbSetOrder(4))// U7_FILIAL+U7_CODUSU
	if SU7->(MsSeek(xFilial("SU7") + _cCodUsr,.T.,.F.))
		_cTpAt := SU7->U7_TIPOATE // Salvo a configura��o do campo para ser restaurada ap�s a rotina.
		// 1 = Telemarketing
		// 2 = Televendas
		// 3 = Telecobran�a
		while !RecLock("SU7",.F.) ; enddo
			SU7->U7_TIPOATE := cValToChar(_nOpc)
		SU7->(MsUnLock())
		// Seta a fun��o padr�o
		SetFunName("TMKA271")
		// Chama a rotina padr�o do sistema
		TMKA271()
		// Restaura o conte�do salvo anteriormente para o campo SU7->U7_TIPOATE
		SetFunName(_cRotina)
		dbSelectArea("SU7")
		SU7->(dbSetOrder(4))// U7_FILIAL+U7_CODUSU
		if SU7->(MsSeek(xFilial("SU7") + _cCodUsr,.T.,.F.))
			while !RecLock("SU7",.F.) ; enddo
				SU7->U7_TIPOATE := _cTpAt
			SU7->(MsUnLock())
		endif
		//29/07/2020 - Anderson C. P. Coelho (ALLSS Soluc��es em Sistemas) - Inibido em decorr�ncia das altera��es realizadas nesta data.
		//CLOSE(oDlg)
	else
		MSGBOX('Usu�rio n�o encontrado no cadastro de operadores. A rotina ser� encerrada',_cRotina+'_001','ALERT')
		//29/07/2020 - Anderson C. P. Coelho (ALLSS Soluc��es em Sistemas) - Inibido em decorr�ncia das altera��es realizadas nesta data.
		//CLOSE(oDlg)
		return .F.
	endif
return .T.
/*/{Protheus.doc} Cancel (RTMKA002)
@description Sub-fun��o de cancelamento.
@author J�lio Soares
@since 16/05/2016
@version 1.0
@type function
@history 29/07/2020, Anderson C. P. Coelho (ALLSS Soluc��es em Sistemas), Rotina inibida, em decorr�ncia das altera��es realizadas nesta data.
@see https://allss.com.br
/*/
/*
Static Function Cancelr()
	CLOSE(oDlg)
Return(.F.)
*/
