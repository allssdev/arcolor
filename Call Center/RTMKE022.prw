#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE DS_MODALFRAME   128

/*/{Protheus.doc} RTMKE022
@description Rotina criada para permitir busca avançada (por parte do nome) em todas as telas do sistema.
 A rotina foi adicionada através da tecla de atalho CTRL +F5 através dos pontos de entrada:
      * SIGAFIN()- Financeiro
      * SIGAFAT()- Faturamento
      * SIGAEST()- Estoque
      * SIGACOM()- Compras
      * SIGATMK()- Call Center
      * SIGAPCP()- Planejamento e Controle da Produção
      * SIGAFIS()- Fiscal
      * SIGACTB()- Contabilidade
      * SIGAGPE()- Gestão Pessoal
      * SIGAPON()- Ponto Eletrônico
      * SIGAOMS()- Gestão de Distribuição
@obs Inserir o trecho abaixo no ponto de entrada do módulo desejado:
	/////////////////////////////////////////////////////////////////////////////
		local _aSavArea := GetArea()
		if ExistBlock("RTMKE022")
		    //Defino tecla de atalho para chamada da rotina de busca avançada
		    SetKey(K_CTRL_F5,{|| })
			SetKey(K_CTRL_F5,{|| U_RTMKE022() })
		endif
		RestArea(_aSavArea)
	/////////////////////////////////////////////////////////////////////////////
@author Adriano Leonardo
@since 17/03/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RTMKE022()
	local oCboCampo
	local oCboTipo 
	local oBtnOk
	local oBtnCancel
	local oSay1
	local oTxtTexto

	private _cRotina	:= "RTMKE022"
	private _nCboCampo 	:= ""
	private _nCboTipo  	:= ""
	private _cConteudo 	:= ""
	private cFiltra		:= ""
	private _cChave		:= ""
	private _cAlias		:= Alias()
	private _nIndex  	:= IndexOrd()
	private _nOpc		:= 0
	private _aCampos 	:= {}
	private _aCpoSX3 	:= {} //Posições do array - 1: Titulo, 2: Campo , 3: Tipo, 4: Tamanho, 5: Decimal
	private aIndex 		:= {}
	private _cAliasSX3  := "SX3_"+GetNextAlias()
	private oDlgSeek

	if Select(_cAliasSX3) > 0
		(_cAliasSX3)->(dbCloseArea())
	endif
	OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
	dbSelectArea(_cAliasSX3)
	(_cAliasSX3)->(dbSetOrder(1))

	//Inibe a tecla de atalho para prevenir duplicidade da abertura da janela
	SetKey(K_CTRL_F5,{|| })

  	DEFINE MSDIALOG oDlgSeek TITLE "Busca Avançada" FROM 000, 000  to 170, 600 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME // Cria Dialog sem o botão de Fechar.
		(_cAlias)->(dbClearFilter())
		dbSelectArea(_cAlias)
		(_cAlias)->(dbSetOrder(_nIndex))
		(_cAlias)->(dbGoBottom())
		(_cAlias)->(dbGoTop())
		TcRefresh(_cAlias)

		//Atualizo o objeto da mBrowse, para ativar o filtro
		_oObj := GetObjBrow()
	//	_oObj:Default()
		if type("_oObj")=="O"
			_oObj:Refresh()
		endif
	
		ListCpos() //Chamada de função para listar os campos passíveis de filtro com base na SX3
		CpoDef() //Chamada de função para retornar o campo principal do índice selecionado no momento

		//Verifico se o campo principal do índice está disponível na relação de campos a serem filtrados
		if aScan(_aCampos,_cChave)>0
			_nCboCampo := _cChave
		endif
	
	    @ 016, 004 MSCOMBOBOX oCboCampo VAR _nCboCampo ITEMS _aCampos SIZE 289, 010 OF oDlgSeek COLORS 0, 16777215 PIXEL
	    @ 036, 004 MSGET oTxtTexto VAR _cConteudo SIZE 289, 010 OF oDlgSeek COLORS 0, 16777215 PIXEL
	    @ 055, 047 MSCOMBOBOX oCboTipo VAR _nCboTipo ITEMS {"Exata","Parcial"} SIZE 072, 010 OF oDlgSeek COLORS 0, 16777215 PIXEL
	    @ 052, 182 BUTTON oBtnOk PROMPT "Buscar" SIZE 050, 012 OF oDlgSeek ACTION Eval({||_nOpc:=1,Close(oDlgSeek)}) PIXEL
	    @ 057, 004 SAY oSay1 PROMPT "Tipo de busca:" SIZE 037, 007 OF oDlgSeek COLORS 0, 16777215 PIXEL
	    @ 052, 242 BUTTON oBtnCancel PROMPT "Cancelar" SIZE 050, 012 OF oDlgSeek ACTION Eval({||_nOpc:=0,Limpar()}) PIXEL
	
    	_nCboTipo := "Parcial"
	ACTIVATE MSDIALOG oDlgSeek CENTERED
	if _nOpc==0
		Limpar()
	else
		Filtrar()
	endif
	if Select(_cAliasSX3) > 0
		(_cAliasSX3)->(dbCloseArea())
	endif
	//Restaura a tecla de atalho ao fechar a janela de busca
	SetKey(K_CTRL_F5,{|| })
	SetKey(K_CTRL_F5,{|| U_RTMKE022() })
return
/*/{Protheus.doc} Fechar
@description Sub-Função responsável por fechar a tela de busca avançada e restaurar a tecla de atalho (F5), pertencente a rotina "RTMKE022".
@author Adriano Leonardo
@since 18/03/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function Fechar()
	//Restaura a tecla de atalho ao fechar a janela de busca
	SetKey(K_CTRL_F5,{|| })
	if ExistBlock("RTMKE022")
		SetKey(K_CTRL_F5,{|| U_RTMKE022() })
	endif
return
/*/{Protheus.doc} ListCpos
@description Sub-Função responsável por selecionar quais campos serão disponibilizados para edição do filtro pelo usuário, pertencente a rotina "RTMKE022".
@author Adriano Leonardo
@since 18/03/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ListCpos()
	(_cAliasSX3)->(dbSetOrder(1))
	if (_cAliasSX3)->(MsSeek(_cAlias,.T.,.F.))
		while !(_cAliasSX3)->(EOF()) .AND. (_cAliasSX3)->X3_ARQUIVO==_cAlias
			//Certifico que o campo é real e esteja disponível no browse
			if (_cAliasSX3)->X3_CONTEXT<>"V" .And. (_cAliasSX3)->X3_BROWSE=="S"
				if empty(_cConteudo)
					_cConteudo := space(50)//space((_cAliasSX3)->X3_TAMANHO)
				endif
				if empty(_nCboTipo)
					_nCboTipo  := "Exata"
				endif
				if __Language=="ENGLISH"
					_cMacro := "(_cAliasSX3)->X3_TITENG"
				elseif __Language=="SPANISH"
					_cMacro := "(_cAliasSX3)->X3_TITESP"			
				else
					_cMacro := "(_cAliasSX3)->X3_TITULO"			
				endif
				if empty(_nCboCampo)
					_nCboCampo := &_cMacro
				endif
				AAdd(_aCampos,&_cMacro)
				AAdd(_aCpoSX3,{&_cMacro,(_cAliasSX3)->X3_CAMPO,(_cAliasSX3)->X3_TIPO, (_cAliasSX3)->X3_TAMANHO, (_cAliasSX3)->X3_DECIMAL})
			endif
			(_cAliasSX3)->(dbSetOrder(1))
			(_cAliasSX3)->(dbSkip())
		enddo
	endif
	if len(_aCampos) == 0
		Eval({||_nOpc := 0, Limpar()})
	endif
	dbSelectArea(_cAlias)
	(_cAlias)->(dbSetOrder(_nIndex))
return
/*/{Protheus.doc} Filtrar
@description Sub-Função responsável por aplicar o filtro do usuário na tela do atendimento do Call Center, pertencente a rotina "RTMKE022".
@author Adriano Leonardo
@since 18/03/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function Filtrar()
	dbSelectArea(_cAlias)
	aIndex   := {}
	cFiltra  := ""
	_nPosArr := aScan(_aCpoSX3,{|x|AllTrim(x[01])==AllTrim(_nCboCampo)})
	cFiltra  := "AllTrim(" + _cAlias + "->" + AllTrim(_aCpoSx3[_nPosArr,2]) + ")"
	if _aCpoSx3[_nPosArr,3]=="D"
		cFiltra := "DTOC(" + _cAlias + "->" + AllTrim(_aCpoSx3[_nPosArr,2]) + ")"
	endif
	//Posições do array - 1: Titulo, 2: Campo , 3: Tipo, 4: Tamanho, 5: Decimal
	if _aCpoSx3[_nPosArr,3]=="C"
		if _nCboTipo=="Parcial"
			cFiltra := "'" + AllTrim(Upper(_cConteudo)) + "' $ " + Upper(cFiltra)
		else
			cFiltra += " == " + "'" + AllTrim(Upper(_cConteudo)) + "'"
		endif
	elseif _aCpoSx3[_nPosArr,3]=="N"
		if _nCboTipo=="Parcial"
			cFiltra := _cConteudo + " $ " + cFiltra
		else
			cFiltra += " == " + "" + _cConteudo + ""
		endif
	elseif _aCpoSx3[_nPosArr,3]=="D"
		_cAux  := CTOD(_cConteudo)
		_cType := type("_cAux")
		if _cType == "D" .And. !empty(_cAux) .And. !empty(_cConteudo)
			if _nCboTipo=="Parcial"
				cFiltra := "'" + AllTrim(_cConteudo) + "' $ " + cFiltra
			else
				cFiltra += " == " + "'" + AllTrim(_cConteudo) + "'"
			endif
		elseif _cType <> "D" .Or. (empty(_cAux) .And. !empty(_cConteudo))
			MsgAlert("Formato inválido, para campo do tipo data utilize o seguinte formato DD/MM/AAAA!",_cRotina+"_001")
			cFiltra := ""
		endif
	endif

	Fechar() //Chama a função responsável por fechar a janela de consulta avançada

	//Verifico se o filtro está em formato condizente com o esperado
	if valtype(cFiltra) == "C"
		//Aplico o filtro no browse
		bFiltraBrw 	:= {|| FilBrowse( _cAlias, @aIndex, @cFiltra )}
		Eval(bFiltraBrw)
		if ((_cAlias)->(Eof()))
			HELP(" ",1,"RECNO")
		endif
		dbSelectArea(_cAlias)
		(_cAlias)->(dbSetOrder(_nIndex))
		(_cAlias)->(dbGoBottom())
		(_cAlias)->(dbGoTop())
		TcRefresh(_cAlias)
		//Atualizo o objeto da mBrowse, para ativar o filtro
		_oObj := GetObjBrow()
		//_oObj:Default()
		if type("_oObj")=="O"
			_oObj:Refresh()
		endif
	endif

	Fechar() //Chama a função responsável por fechar a janela de consulta avançada

	//Restauro a área de trabalho original
	//RestArea(_aSavSx3)
	dbSelectArea(_cAlias)
	(_cAlias)->(dbSetOrder(_nIndex))
	(_cAlias)->(dbGoBottom())
	(_cAlias)->(dbGoTop())
	TcRefresh(_cAlias)
return
/*/{Protheus.doc} CpoDef
@description Sub-Função desenvolvida para retorna o campo principal do índice de busca selecionado no momento, pertencente a rotina "RTMKE022".
@author Adriano Leonardo
@since 06/06/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function CpoDef()
	local _aSavTMP   := GetArea()
	local _cAliasSIX := ""
	local _nCont     := 0
	//Posiciono a tabela de índices do sistema no registro referente ao índice escolhido pelo usuário
	_cAliasSIX := "SIX_"+GetNextAlias()
	if select(_cAliasSIX) > 0
		(_cAliasSIX)->(dbCloseArea())
	endif
	OpenSxs(,,,,FWCodEmp(),_cAliasSIX,"SIX",,.F.)
	dbSelectArea(_cAliasSIX)
	(_cAliasSIX)->(dbSetOrder(1))
	if (_cAliasSIX)->(MsSeek(_cAlias + RETASC(_nIndex,1,.T.),.T.,.F.))
		_cChave := (_cAliasSIX)->CHAVE
		_aCposInd := Separa(_cChave,"+")
		//Seleciono o primeiro campo diferente de FILIAL como o campo default a ser aplicado na busca avançada
		for _nCont := 1 to len(_aCposInd)
			if !("FILIAL" $ Upper(_aCposInd[_nCont]))
				_cChave := _aCposInd[_nCont]
				Exit
			endif
		next
	endif
	if select(_cAliasSIX) > 0
		(_cAliasSIX)->(dbCloseArea())
	endif
	//Localizo o título do campo chave com o respectivo idioma do sistema logado
	(_cAliasSX3)->(dbSetOrder(2))
	if (_cAliasSX3)->(MsSeek(_cChave,.T.,.F.))
		if __Language=="ENGLISH"
			_cChave := (_cAliasSX3)->X3_TITENG
		elseif __Language=="SPANISH"
			_cChave := (_cAliasSX3)->X3_TITESP
		else //Default português
			_cChave := (_cAliasSX3)->X3_TITULO
		endif
	endif
	RestArea(_aSavTMP)
return _cChave
/*/{Protheus.doc} Limpar
@description Sub-Função desenvolvida para limpar o filtro de busca, pertencente a rotina "RTMKE022".
@author Adriano Leonardo
@since @since 06/06/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function Limpar()
	cFiltra := ""
	if type("_cAlias")=="U"
		_cAlias := Alias()
	endif
	if valtype(cFiltra) == "C"
		//Aplico o filtro no browse
		bFiltraBrw 	:= {|| FilBrowse( _cAlias, @aIndex, @cFiltra )}
		Eval(bFiltraBrw)
		if ((_cAlias)->(Eof()))
			HELP(" ",1,"RECNO")
		endif
		dbSelectArea(_cAlias)
		(_cAlias)->(dbSetOrder(_nIndex))
		(_cAlias)->(dbGoBottom())
		(_cAlias)->(dbGoTop())
		TcRefresh(_cAlias)
		//Atualizo o objeto da mBrowse, para ativar o filtro
		_oObj := GetObjBrow()
		//_oObj:Default()
		if type("_oObj")=="O"
			_oObj:Refresh()
		endif
	endif
	if type("oDlgSeek")=="O"
		Close(oDlgSeek)
	endif
	dbSelectArea(_cAlias)
	(_cAlias)->(dbSetOrder(_nIndex))
	(_cAlias)->(dbGoBottom())
	(_cAlias)->(dbGoTop())
	TcRefresh(_cAlias)
return