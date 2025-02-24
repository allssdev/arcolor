#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE _CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} RCFGASX1
@description Atualiza respostas das perguntas no SX1 e no Profile do usuário.
@author Robert Kotch
@since 13/02/2002
@version 1.0
@param _sGrupo, caracter, Grupo de perguntas a atualizar/pesquisar no arquivo SX1.
@param _sPerg , caracter, Codigo (ordem) da pergunta.
@param _xValor, null    , Dado a ser gravado, podendo ter conteúdo de tipo variado. 
@type function
@history 01/09/2005, Robert Kotch                                , Ajustes para trabalhar com profile de usuario (versao 8.11)
@history 16/02/2006, Robert Kotch                                , Melhorias gerais
@history 12/12/2006, Robert Kotch                                , Sempre grava numerico no X1_PRESEL
@history 11/09/2007, Robert Kotch                                , Parametros tipo 'combo' podem receber informacao numerica ou caracter. Testa existencia da variavel __cUserId
@history 02/04/2008, Robert Kotch                                , Mostra mensagem quando tipo de dados for incompativel. Melhoria geral nas mensagens.
@history 03/06/2009, Robert Kotch                                , Tratamento para aumento de tamanho do X1_GRUPO no Protheus10
@history 26/01/2010, Robert Kotch                                , Chamadas da msgalert trocadas por msgalert.
@history 29/07/2010, Robert Kotch                                , Soh trabalhava com profile de usuario na versao 8.
@history 14/05/2015, Anderson C. P. Coelho (ALL System Solutions), Formatação da rotina e padronização de nomenclaturas. Revisão e testes no Protheus 11.8
@history 12/07/2019, Anderson C. P. Coelho (ALL System Solutions), Readequação dos fontes, passando a utilização da função OpenSxs, para funcionamento a partir da versão 12.1.023 do Protheus. Além disso, foi realizada uma redocumentação do fonte para o padrão do PDoc (Protheus Document).
@see https://allss.com.br
/*/
user function RCFGASX1(_sGrupo,_sPerg,_xValor)
	local   _aAreaAnt  := GetArea()
	local   _aLinhas   := {}
	local   _nLinha    := 0
//	local   _nTamanho  := 0
	local   _sUserName := ""
	local   _cChvUsr   := ""
	local   _sMemoProf := ""
	local   _lContinua := .T.

	private _cRotina   := "RCFGASX1"
	private _cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()

	if Select(_cAliasSX1) > 0
		(_cAliasSX1)->(dbCloseArea())
	endif
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	// A partir da versao Protheus10, o tamanho das perguntas aumentou.
	_sGrupo := Padr(_sGrupo,Len((_cAliasSX1)->X1_GRUPO)," ")
	if _lContinua
		if !(_cAliasSX1)->(MsSeek(_sGrupo + _sPerg,.T.,.F.))
			MsgAlert("Programa " + ProcName() + ": Grupo/Pergunta '" + _sGrupo + "/" + _sPerg + "' não encontrado no arquivo SX1." + _PCham (),_cRotina+"_001")
			_lContinua := .F.
		endif
	endif
	if _lContinua
		// Atualizarei sempre no SX1. Depois vou ver se tem profile de usuario.
		do case
			case (_cAliasSX1)->X1_GSC == "C"
				while !RecLock(_cAliasSX1, .F.) ; enddo
					(_cAliasSX1)->X1_PRESEL := VAL(cValToChar(_xValor))
					(_cAliasSX1)->X1_CNT01  := ""
				(_cAliasSX1)->(MsUnLock())
			case (_cAliasSX1)->X1_GSC == "G"
				if Valtype(_xValor) != (_cAliasSX1)->X1_TIPO
					MsgAlert("Programa " + ProcName() + ": Incompatibilidade de tipos: o parametro '" + _sPerg + "' do grupo de perguntas '" + _sGrupo + "' é do tipo '" + (_cAliasSX1)->X1_TIPO + "', mas o valor recebido é do tipo '" + Valtype(_xValor) + "'." + _PCham (),_cRotina+"_002")
					_lContinua := .F.
				else
					while !Reclock(_cAliasSX1, .F.) ; enddo
						(_cAliasSX1)->X1_PRESEL := 0
						if (_cAliasSX1)->X1_TIPO == "D"
							(_cAliasSX1)->X1_CNT01 :=  DTOC(_xValor)
						elseif (_cAliasSX1)->X1_TIPO == "N"
							(_cAliasSX1)->X1_CNT01 := Str(_xValor, (_cAliasSX1)->X1_TAMANHO, (_cAliasSX1)->X1_DECIMAL)
						elseif (_cAliasSX1)->X1_TIPO == "C"
							(_cAliasSX1)->X1_CNT01 := _xValor
						endif
					(_cAliasSX1)->(MsUnLock())
				endif
			otherwise
				MsgAlert("Programa " + ProcName() + ": Tratamento para X1_GSC = '" + (_cAliasSX1)->X1_GSC + "' ainda não implementado." + _PCham (),_cRotina+"_003")
				_lContinua := .F.
		endcase
	endif
	if _lContinua
		// Antes da versão 8.11 não havia Profile de usuário (para o P10 ainda não testei).
		// if "MP8.11" $ cVersao .and. type ("__cUserId") == "C" .AND. ! empty (__cUserId)
		if type("__cUserId") == "C" .AND. !empty(__cUserId)
			Psworder(1) // Ordena arquivo de senhas por ID do usuario
			PswSeek(__cUserID) // Pesquisa usuario corrente
			_sUserName := PswRet(1)[1][2]
			// Encontra e atualiza profile deste usuario para a rotina / pergunta atual.
			// Enquanto o usuario nao alterar nenhuma pergunta, ficarah usando do SX1 e
			// seu profile nao serah criado.
			_cChvUsr := _sUserName
			if !FindProfDef(_cChvUsr, _sGrupo, "PERGUNTE", "MV_PAR")
				_cChvUsr := SubStr(cNumEmp,1,2)+_sUserName
				if !FindProfDef(_cChvUsr, _sGrupo, "PERGUNTE", "MV_PAR")
					_cChvUsr := cNumEmp+_sUserName
					if !FindProfDef(_cChvUsr, _sGrupo, "PERGUNTE", "MV_PAR")
						_cChvUsr := ""
					endif
				endif
			endif
			if !empty(_cChvUsr)
				// Carrega memo com o Profile do usuário (o Profile fica gravado em um campo memo)
				_sMemoProf  := RetProfDef(_cChvUsr, _sGrupo, "PERGUNTE", "MV_PAR")
				// Monta array com as linhas do memo (tem uma pergunta por linha)
				_aLinhas    := {}
				for _nLinha := 1 to MLCount(_sMemoProf)
					AADD(_aLinhas, AllTrim(MemoLine(_sMemoProf,, _nLinha)) + _CRLF)
				next
				// Monta uma linha com o novo conteudo do parametro atual.
				// Pos 1 = tipo (numerico/data/caracter...)
				// Pos 2 = '#'
				// Pos 3 = GSC
				// Pos 4 = '#'
				// Pos 5 em diante = conteudo.
				_sLinha := (_cAliasSX1)->X1_TIPO + "#" + (_cAliasSX1)->X1_GSC + "#" + IIF((_cAliasSX1)->X1_GSC == "C",cValToChar((_cAliasSX1)->X1_PRESEL),(_cAliasSX1)->X1_CNT01) + _CRLF
				// Se foi passada uma pergunta que não consta no profile, deve tratar-se
				// de uma pergunta nova, pois jah encontrei-a no SX1. Então vou criar uma
				// linha para ela na array. Senao, basta regravar na array.
				if Val(_sPerg) > len(_aLinhas)
					AADD(_aLinhas, _sLinha)
				else
					// Grava a linha de volta na array de linhas
					_aLinhas [VAL(_sPerg)] := _sLinha
				endif
				// Remonta memo para gravar no Profile
				_sMemoProf  := ""
				for _nLinha := 1 to len(_aLinhas)
					_sMemoProf += _aLinhas[_nLinha]
				next
				// Grava o memo no Profile
				WriteProfDef(	_cChvUsr, _sGrupo, "PERGUNTE", "MV_PAR", ; // Chave antiga
								_cChvUsr, _sGrupo, "PERGUNTE", "MV_PAR", ; // Chave nova
								_sMemoProf                               ) // Novo conteudo do memo.
			endif
		endif
	endif
	if Select(_cAliasSX1) > 0
		(_cAliasSX1)->(dbCloseArea())
	endif
	RestArea(_aAreaAnt)
return .T.
/*/{Protheus.doc} _PCham
@description Descreve a pilha de chamadas para apresentação ao usuário.
@author Robert Kotch
@since 13/02/2002
@version 1.0
@type function
@return _sPilha, caracter, Pilha de chamadas para apresentação nos Alerts, ao usuário.
@history 14/05/2015, Anderson C. P. Coelho (ALL System Solutions), Formatação da rotina e padronização de nomenclaturas. Revisão e testes no Protheus 11.8
@history 12/07/2019, Anderson C. P. Coelho (ALL System Solutions), Readequação dos fontes, passando a utilização da função OpenSxs, para funcionamento a partir da versão 12.1.023 do Protheus. Além disso, foi realizada uma redocumentação do fonte para o padrão do PDoc (Protheus Document).
@see https://allss.com.br
/*/
static function _PCham()
	local _i      := 0
	local _sPilha := _CRLF+_CRLF+"Pilha de chamadas:"

	while ProcName(_i) != ""
		_sPilha += _CRLF+ProcName(_i)
		_i++
	enddo
return _sPilha