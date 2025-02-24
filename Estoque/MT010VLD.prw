#INCLUDE 'protheus.ch'
#INCLUDE 'rwmake.ch'
#DEFINE _lEnt CHR(10) + CHR(13)
/*/{Protheus.doc} MT010VLD
@description Ponto de entrada localizado na função A010Copia, chamado no inicio da função da copia do produto, utilizado para verificar se a copia do produto está apta para utilização.
@author Júlio Soares (ALL System Solutions)
@since 14/06/2016
@version 1.0
@history 20/05/2019, Anderson Coelho, Rotina documentada no padrão PDoc. A mesma também foi documentada. Além disso, foi inserida uma regra para gravar, na tabela 'AIF' (Histórico de Alterações para Produtos, Cliente, Fornecedores e/ou Transportadoras), as eventuais alterações nos campos do cadastro de produtos.
@return _lRet, lógico, Confirma ou não o formulário de inclusão/alteração/exclusão do cadastro de produtos.
@type function
@see https://allss.com.br
/*/
user function MT010VLD()
	Local   _aSavArea  := GetArea()
	Local   _aSavSB1   := SB1->(GetArea())
//	Local   _aSavAIF   := AIF->(GetArea())
	Local   _cRotina   := 'MT010VLD'
//	Local   _cAliasSX3 := GetNextAlias()
//	Local   uConteudo  := ""
//	Local   cTipo      := ""
//	Local   _nPCodPro  := AIF->(FieldPos("AIF_CODPRO"))
//	Local   _nPTransp  := AIF->(FieldPos("AIF_TRANSP"))
	Local   _lRet      := .T.

	Public  _lCpyVld   := .F.

	if MSGBOX('Deseja prosseguir com a cópia do seguinte produto?'+_lEnt+''+Alltrim(SB1->B1_COD)+' - '+Alltrim(SB1->B1_DESC),_cRotina+"_001","YESNO")
		_lCpyVld := .T.
	endif
	/*
	//OpenSxs(	<oParam1 >, ;		//Compatibilidade
	//			<oParam2 >, ;		//Compatibilidade
	//			<oParam3 >, ;		//Compatibilidade
	//			<oParam4 >, ;		//Compatibilidade
	//			<cEmpresa >, ;		//Empresa que se deseja abrir o dicionário, se não informado utilizada a empresa atual (cEmpAnt) 
	//			<cAliasSX >, ;		// Alias que será utilizado para abrir a tabela 
	//			<cTypeSX >, ;		// Tabela que será aberta 
	//			<oParam8 >, ;		//Compatibilidade
	//			<lFinal >, ;		// Indica se deve chamar a função FINAL caso a tabela não exista (.T.)
	//			<oParam10 >, ;		//Compatibilidade
	//			<lShared >, ;		// Indica se a tabela deve ser aberta em modo compartilhado ou exclusivo (.T.)
	//			<lCreate >) 		// Indica se deve criar a tabela, caso ela não exista
	OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
	if Select(_cAliasSX3) > 0
		dbSelectArea(_cAliasSX3)
		(_cAliasSX3)->(dbSetOrder(1))
		if (_cAliasSX3)->(MsSeek("SB1",.T.,.F.))
			while !(_cAliasSX3)->(EOF()) .AND. AllTrim((_cAliasSX3)->X3_ARQUIVO) == "SB1"
				if AllTrim((_cAliasSX3)->X3_CONTEXT) <> "V" .AND. X3USO((_cAliasSX3)->X3_USADO) .AND. cNivel >= (_cAliasSX3)->X3_NIVEL
					if &("SB1->"+(AllTrim((_cAliasSX3)->X3_CAMPO))) <> &("M->"+(AllTrim((_cAliasSX3)->X3_CAMPO)))
						//MSGrvHist(cFilAIF, cFilTab, cTabela, cCodigo, cLoja, cCampo, uConteudo, dData, cHora, cProduto, cTransp)
						//MSGrvHist(	xFilial("AIF"), ;											//cFilAIF
						//			xFilial("SB1"), ;											//cFilTab
						//			"SB1", ;													//cTabela
						//			"", ;														//cCodigo
						//			"", ;														//cLoja
						//			(_cAliasSX3)->X3_CAMPO, ;									//cCampo
						//			&("SB1->"+(AllTrim((_cAliasSX3)->X3_CAMPO))), ;				//uConteudo
						//			Date(), ;													//dData
						//			Time(), ;													//cHora
						//			SB1->B1_COD, ;												//cProduto
						//			"")															//cTransp
						uConteudo := &("SB1->"+(AllTrim((_cAliasSX3)->X3_CAMPO)))
						cTipo     := TamSX3((_cAliasSX3)->X3_CAMPO)[03]
						If cTipo == "C" .AND. ValType(uConteudo) == cTipo
							uConteudo := uConteudo
						ElseIf cTipo == "N" .AND. ValType(uConteudo) == cTipo
							uConteudo := AllTrim(Str(uConteudo))
						ElseIf cTipo == "D" .AND. ValType(uConteudo) == cTipo
							uConteudo := DtoC(uConteudo)
						ElseIf cTipo == "L" .AND. ValType(uConteudo) == cTipo
							uConteudo := IIf(uConteudo, ".T.", ".F.")
						EndIf
						while !RecLock("AIF", .T.) ; enddo
							AIF->AIF_FILIAL := xFilial("AIF")
							AIF->AIF_FILTAB := xFilial("SB1")
							AIF->AIF_TABELA := "SB1"
							AIF->AIF_CAMPO  := (_cAliasSX3)->X3_CAMPO
							AIF->AIF_CONTEU := uConteudo
							AIF->AIF_DATA   := Date()
							AIF->AIF_HORA   := Time()
							If _nPCodPro > 0
								AIF->AIF_CODPRO := M->B1_COD
							EndIf
							AIF->AIF_CODIGO := ""
							AIF->AIF_LOJA   := ""
							if _nPTransp > 0
								AIF->AIF_TRANSP := ""
							endif
						AIF->(MsUnLock())
					endif
				endif
				dbSelectArea(_cAliasSX3)
				(_cAliasSX3)->(dbSetOrder(1))
				(_cAliasSX3)->(dbSkip())
			enddo
		endif
		(_cAliasSX3)->(dbCloseArea())
	endif
	RestArea(_aSavAIF)
	*/
	RestArea(_aSavSB1)
	RestArea(_aSavArea)
return _lRet