#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} RFINE002
@description Execblock utilizado para a apresentacao de uma tela p/ que o usuario possa selecionar o arquivo de retorno do CNAB do Contas a Receber.
@obs Para o correto funcionamento dessa rotina é necessário criar o campo EE_ARQUIVO contendo o nome dos arquivos com as extensões respectivos.
Criar também o campo EE_LOCAL contendo o local padrão do arquivo a ser processado por carteira.
Deve ser preenchido tembém o campo X1_VALID na tabela SX1 para os grupos e perguntas específicas de arquivo de entrada a função abaixo.
IIF(EXISTBLOCK("RFINE002"),U_RFINE002(cPerg),.T.)
OBS.: cPerg é o grupo de perguntas da SX1. Esta variável "cPerg" deverá conter os espaços necessários, conforme o tamanho total do campo "X1_GRUPO".
@author Anderson C. P. Coelho
@since 23/04/2013
@version 1.0
@param cPerg, characters, Pergunta, conforme o grupo de perguntas da tabela SX1 (deverá conter inclusive os espaços, complementando assim o tamanho total definido no campo "X1_GRUPO").
@history Julio Soares, 15/08/2014, Implementado trecho de validação do caminho do arquivo do CNAB para a execução de automatização do preenchimento automático dos parâmetros conforme informado no cadastro dos parâmetros de banco (SEE).
@type function
@see https://allss.com.br
/*/
user function RFINE002(cPerg)
	local   _cRotina  := 'RFINE002'
	local   _cRet     := &(__ReadVar)
	local   _aPosCpo  := {}
	local  _nTamPerg  := len(SX1->X1_GRUPO)
	local  _cCamDef   := UPPER(AllTrim(SuperGetMv("MV_XRETCNA",,"C:\BancoBrasil\BBTransf\Retorno\")))
	local  _x         := 0

	private cDrive, cDir, cNome, cExt
	private _cCnabTmp := GetNextAlias()

	default cPerg     := ""

	If !Empty(cPerg)
		cPerg := Padr(cPerg,_nTamPerg)
		// Alteração - Fernando Bombardi - 14/07/2023
		//If Padr(cPerg,_nTamPerg) == Padr("FIN650",_nTamPerg)
		If Padr(cPerg,_nTamPerg) == Padr("AFI650",_nTamPerg)
		// Fim Alteração - Fernando Bombardi - 14/07/2023
			_aPosCpo := {	{"ARQUIVO","MV_ARQENT" ,                   },;
							{"CONFIG" ,"MV_ARQCONF","(_cCnabTmp)->ARQV"},;
							{"ARQUIVO","MV_PAR01"  ,                   },;
							{"CONFIG" ,"MV_PAR02"  ,"(_cCnabTmp)->ARQV"},;
							{"BANCO"  ,"MV_PAR03"  ,"(_cCnabTmp)->BANK"},;
							{"AGENCIA","MV_PAR04"  ,"(_cCnabTmp)->AGEN"},;
							{"CONTA"  ,"MV_PAR05"  ,"(_cCnabTmp)->CONT"},;
							{"SUBCTA" ,"MV_PAR06"  ,"(_cCnabTmp)->SBCC"} }
		elseif Padr(cPerg,_nTamPerg) == Padr("FIN850",_nTamPerg)
			_aPosCpo := {	{"ARQUIVO","MV_ARQENT" ,                   },;
							{"CONFIG" ,"MV_ARQCONF","(_cCnabTmp)->ARQV"},;
							{"ARQUIVO","MV_PAR01"  ,                   },;
							{"CONFIG" ,"MV_PAR02"  ,"(_cCnabTmp)->ARQV"},;
							{"BANCO"  ,"MV_PAR03"  ,"(_cCnabTmp)->BANK"},;
							{"AGENCIA","MV_PAR04"  ,"(_cCnabTmp)->AGEN"},;
							{"CONTA"  ,"MV_PAR05"  ,"(_cCnabTmp)->CONT"},;
							{"SUBCTA" ,"MV_PAR06"  ,"(_cCnabTmp)->SBCC"} }
		elseif Padr(cPerg,_nTamPerg) == Padr("AFI200",_nTamPerg)
			_aPosCpo := {	{"ARQUIVO","MV_ARQENT" ,                   },;
							{"CONFIG" ,"MV_ARQCONF","(_cCnabTmp)->ARQV"},;
							{"BANCO"  ,"MV_BANCO"  ,"(_cCnabTmp)->BANK"},;
							{"ARQUIVO","MV_PAR04"  ,                   },;
							{"CONFIG" ,"MV_PAR05"  ,"(_cCnabTmp)->ARQV"},;
							{"BANCO"  ,"MV_PAR06"  ,"(_cCnabTmp)->BANK"},;
							{"AGENCIA","MV_PAR07"  ,"(_cCnabTmp)->AGEN"},;
							{"CONTA"  ,"MV_PAR08"  ,"(_cCnabTmp)->CONT"},;
							{"SUBCTA" ,"MV_PAR09"  ,"(_cCnabTmp)->SBCC"} }
		elseif Padr(cPerg,_nTamPerg) == Padr("AFI300",_nTamPerg)
			_aPosCpo := {	{"ARQUIVO","MV_ARQENT" ,                   },;
							{"CONFIG" ,"MV_ARQCONF","(_cCnabTmp)->ARQV"},;
							{"BANCO"  ,"MV_BANCO"  ,"(_cCnabTmp)->BANK"},;
							{"ARQUIVO","MV_PAR04"  ,                   },;
							{"CONFIG" ,"MV_PAR05"  ,"(_cCnabTmp)->ARQV"},;
							{"BANCO"  ,"MV_PAR06"  ,"(_cCnabTmp)->BANK"},;
							{"AGENCIA","MV_PAR07"  ,"(_cCnabTmp)->AGEN"},;
							{"CONTA"  ,"MV_PAR08"  ,"(_cCnabTmp)->CONT"},;
							{"SUBCTA" ,"MV_PAR09"  ,"(_cCnabTmp)->SBCC"} }
		elseif Padr(cPerg,_nTamPerg) == Padr("AFI430",_nTamPerg)
			_aPosCpo := {	{"ARQUIVO","MV_PAR03"  ,                   },;
							{"CONFIG" ,"MV_PAR04"  ,"(_cCnabTmp)->ARQV"},;
							{"BANCO"  ,"MV_PAR05"  ,"(_cCnabTmp)->BANK"},;
							{"AGENCIA","MV_PAR06"  ,"(_cCnabTmp)->AGEN"},;
							{"CONTA"  ,"MV_PAR07"  ,"(_cCnabTmp)->CONT"},;
							{"SUBCTA" ,"MV_PAR08"  ,"(_cCnabTmp)->SBCC"} }
		elseif Padr(cPerg,_nTamPerg) == Padr("AFI470",_nTamPerg)
			_aPosCpo := {	{"ARQUIVO","MV_PAR01"  ,                   },;
							{"CONFIG" ,"MV_PAR02"  ,"(_cCnabTmp)->ARQV"},;
							{"BANCO"  ,"MV_PAR03"  ,"(_cCnabTmp)->BANK"} }
		else
			MsgStop("Atenção! Esta rotina '" + _cRotina + "' somente poderá ser utilizada nas rotinas 'FINR650', 'FINA850', 'FINA200', 'FINA300', 'FINA430', 'FINA470' e 'FINA740'. Operação não permitida!",_cRotina+"_001")
			return _cRet
		endif
		_nPosArq := aScan(_aPosCpo,{|x| AllTrim(x[01]) == "ARQUIVO"})
		Pergunte(cPerg,.F.)
		if !Empty(&(_aPosCpo[_nPosArq][02]) := _cRet := &(__ReadVar) := cGetFile("RET | *.RET","Retorno de CNAB",0,_cCamDef,.F.,GETF_NETWORKDRIVE+GETF_LOCALHARD,.F.,.F.))
			SplitPath(_cRet, @cDrive, @cDir, @cNome, @cExt)
			if Select(_cCnabTmp) > 0
				(_cCnabTmp)->(dbCloseArea())
			endif
			BeginSql Alias _cCnabTmp
				SELECT DISTINCT EE_CODIGO [BANK], EE_AGENCIA [AGEN], EE_CONTA [CONT]
							  , EE_CARTEIR [CART], EE_SUBCTA [SBCC], EE_ARQUIVO [ARQV], EE_LOCAL [LOCAL]
				FROM %table:SEE% SEE (NOLOCK)
				WHERE SEE.EE_FILIAL  = %xFilial:SEE%
				  AND SEE.EE_LOCAL   = %Exp:Alltrim(UPPER(cDrive+cDir))%
				  AND SEE.%NotDel%
			EndSql
			dbSelectArea(_cCnabTmp)
			(_cCnabTmp)->(dbGoTop())
			for _x := 1 to len(_aPosCpo)
				if ValType(_aPosCpo[_x][03])<>"U"
					&(_aPosCpo[_x][02]) := &(_aPosCpo[_x][03])
				endif
			next
			if Select(_cCnabTmp) > 0
				(_cCnabTmp)->(dbCloseArea())
			endif
		endif
	endif
return .T.
