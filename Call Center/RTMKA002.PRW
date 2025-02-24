#include "totvs.ch"
/*/{Protheus.doc} RTMKA002
@description Rotina para a chamar a rotina padrão do sistema, de acordo com a opção selecionada pelo usuário (Telemarketing, Televendas ou o que estiver cadastrado no cadastro de operadores.
@author Júlio Soares
@since 21/12/2015
@version 1.0
@type function
@history 29/07/2020, Anderson C. P. Coelho (ALLSS Solucções em Sistemas), Retirada a telinha de seleção entre as opções "Telemarketing", "Televendas" e "Telecobrança", sendo definida a rotina fixa "Televendas", pois foi definido como regra de negócio nesta oportunidade junto ao Sr. Marco Antonio que os usuários que tiverem esta rotina no menu, acessarão o Televendas, independente de sua permissão definida no cadastro de operadores. As demais rotinas deverão ser configuradas e acessadas pelo referido cadastro, no modelo padrão do Protheus.
@see https://allss.com.br
/*/
user function RTMKA002()  
	Local _aAlias	 := GetArea()
	//29/07/2020 - Anderson C. P. Coelho (ALLSS Solucções em Sistemas) - Variáveis comentadas por não estarem mais em uso.
	//Local oButOk
	//Local oButCl
	//Local oGroup1
	//Local oRadOpc

	Private _cRotina := "RTMKA002"
	Private _nOpc    := 2				//29/07/2020 - Anderson C. P. Coelho (ALLSS Solucções em Sistemas) - Alterado de 1 para 2, para desviar a rotina para que não apresente a telinha de selecao, mas entre direto no teleatendimento (opcao 2)

	//29/07/2020 - Anderson C. P. Coelho (ALLSS Solucções em Sistemas) - Incluido para desviar a rotina para que não apresente a telinha de selecao, mas entre direto no teleatendimento (opcao 2). Sendo assim, a telinha foi comentada!
	Confirm()
	/*
	static oDlg

	  DEFINE MSDIALOG oDlg TITLE "RTMKA002" FROM 000, 000  TO 145, 170 COLORS 0, 16777215 PIXEL
	    @ 005, 005 GROUP oGroup1 TO 052, 080 PROMPT "Selecione o atendimento" OF oDlg COLOR 0, 16777215 PIXEL
	    @ 017, 015 RADIO oRadOpc VAR _nOpc ITEMS "TeleMarketing"," TeleVendas"," TeleCobrança" SIZE 050, 025 OF oDlg COLOR 0, 16777215 PIXEL
	    @ 057, 020 BUTTON oButOK PROMPT "Cancelar" 	SIZE 030, 010 OF oDlg ACTION Cancelr() PIXEL
	    @ 057, 052 BUTTON oButCl PROMPT "Confirmar"	SIZE 030, 010 OF oDlg ACTION Confirm() PIXEL
	  ACTIVATE MSDIALOG oDlg CENTERED
	  */
	  RestArea(_aAlias)
return
/*/{Protheus.doc} Confirm (RTMKA002)
@description Sub-função de alteração do tipo de acesso a rotina de Televendas no cadastro do operador logado.
@author Júlio Soares
@since 16/05/2016
@version 1.0
@type function
@history 29/07/2020, Anderson C. P. Coelho (ALLSS Solucções em Sistemas), Rotina ajustada para atender as alterações realizadas nesta data.
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
		_cTpAt := SU7->U7_TIPOATE // Salvo a configuração do campo para ser restaurada após a rotina.
		// 1 = Telemarketing
		// 2 = Televendas
		// 3 = Telecobrança
		while !RecLock("SU7",.F.) ; enddo
			SU7->U7_TIPOATE := cValToChar(_nOpc)
		SU7->(MsUnLock())
		// Seta a função padrão
		SetFunName("TMKA271")
		// Chama a rotina padrão do sistema
		TMKA271()
		// Restaura o conteúdo salvo anteriormente para o campo SU7->U7_TIPOATE
		SetFunName(_cRotina)
		dbSelectArea("SU7")
		SU7->(dbSetOrder(4))// U7_FILIAL+U7_CODUSU
		if SU7->(MsSeek(xFilial("SU7") + _cCodUsr,.T.,.F.))
			while !RecLock("SU7",.F.) ; enddo
				SU7->U7_TIPOATE := _cTpAt
			SU7->(MsUnLock())
		endif
		//29/07/2020 - Anderson C. P. Coelho (ALLSS Solucções em Sistemas) - Inibido em decorrência das alterações realizadas nesta data.
		//CLOSE(oDlg)
	else
		MSGBOX('Usuário não encontrado no cadastro de operadores. A rotina será encerrada',_cRotina+'_001','ALERT')
		//29/07/2020 - Anderson C. P. Coelho (ALLSS Solucções em Sistemas) - Inibido em decorrência das alterações realizadas nesta data.
		//CLOSE(oDlg)
		return .F.
	endif
return .T.
/*/{Protheus.doc} Cancel (RTMKA002)
@description Sub-função de cancelamento.
@author Júlio Soares
@since 16/05/2016
@version 1.0
@type function
@history 29/07/2020, Anderson C. P. Coelho (ALLSS Solucções em Sistemas), Rotina inibida, em decorrência das alterações realizadas nesta data.
@see https://allss.com.br
/*/
/*
Static Function Cancelr()
	CLOSE(oDlg)
Return(.F.)
*/
