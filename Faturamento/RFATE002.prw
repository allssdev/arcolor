#include "totvs.ch"
/*/{Protheus.doc} RFATE002
@description Rotina responsável pela validação dos atendimentos no Call Center x Pedidos de Vendas no Faturamento.
@author Adriano Leonardo
@since 06/12/2012
@version 1.0
@param _lParAle, logico, .T. = Apresenta alertas
@param _cParPed, caracter, Número do pedido a ser validado
@return _lVali, logico, .T. = pedido de vendas pode ser liberado.
@type function
@obs Por uma questão de flexibilidade a rotina foi desenvolvida considerando uma tabela SZ1 (Validações):
		ROTEIRO PARA IMPLANTAÇÃO:
		CRIAR TABELA SZ1
			CAMPOS:
		 		Z1_NUMERO  -- Número do item
		 		Z1_TABELA  -- Tabela do campo que será validado
		 		Z1_CAMPOS  -- Campo que será validado
		 		Z1_FORMULA -- Formula utilizada para validação
		 		Z1_VALID1  -- (s/n) Verifica se vazio
		 		Z1_MENSAG  -- Mensagem para validação 1
		 		Z1_FUNC1   -- Identica o escopo da validação (FAT/TMK ou ambos)
		 		Z1_VALID2  -- (s/n) Verifica se campo contém caracter especial
		 		Z1_MENSAG2 -- Mensagem para validação 2
		 		Z1_FUNC2   -- Identica o escopo da validação (FAT/TMK ou ambos)
		 		Z1_VALID3  -- (s/n) Verifica se campo contém . - ou /
		 		Z1_MENSAG3 -- Mensagem para validação 3
		 		Z1_FUNC3   -- Identica o escopo da validação (FAT/TMK ou ambos)
		 		Z1_CHAVE   -- Chave utilizada para busca do campo na tabela definida
		 		Z1_INDICE  -- Indice de ordenação utilizado na busca		
		 		Z1_OBRIG1  -- Validação 1 é obrigatória
		 		Z1_OBRIG2  -- Validação 2 é obrigatória
		 		Z1_OBRIG3  -- Validação 3 é obrigatória
		 		Z1_CHAVE2  -- Campo chave do Call Center                       
		 		Z1_VALID4  -- (s/n) Verifica se campo contém caracter especial
		 		Z1_MENSAG4 -- Mensagem para validação 4
		 		Z1_FUNC4   -- Identica o escopo da validação (FAT/TMK ou ambos)
		 		Z1_OBRIG4  -- Validação 4 é obrigatória
		 	INDICE:
		 		Z1_FILIAL+Z1_NUM -- Posição (1)	
		 	CRIAR CAMPO:
			 	C5_SITUAC -- Situação do pedido de vendas (se validado ou não) -- deixar como - não usado
			  	C5_DATAAL -- Data da última alteração
			  	C5_USUARIO -- Último usuário que executou a validação do pedido
			  	C5_HORAAL -- Armaza a hora da alteração
			  	UA_SITUAC -- Situação do atendimento (se validado ou não) -- deixar como - não usado
			  	UA_DATAAL -- Data da última alteração
			  	UA_USUARIO -- Último usuário que executou a validação do atendimento
			  	UA_HORAALT -- Armazena a hora da alteração
@see https://allss.com.br
/*/
user function RFATE002(_lParAle,_cParPed) //Parametro lógico para definir se exibe ou não mensagens de alerta durante o processamento
	//Variável utilizada para concatenar as mensagens
	Local   _aArea    := GetArea()
	Local   _aSvSB1   := SB1->(GetArea())
	Local   _aSvSA1   := SA1->(GetArea())
	Local   _aSvSF4   := SF4->(GetArea())
	Local   _aSvSC9   := SC9->(GetArea())
	Local   _aSvSUS   := SUS->(GetArea())
	Local   _aSvSUA   := SUA->(GetArea())
	Local   _aSvSUB   := SUB->(GetArea())
	Local   _aSvSC5   := SC5->(GetArea())
	Local   _aSvSC6   := SC6->(GetArea())
	Local   _aSvSZ1   := SZ1->(GetArea())
	Local   _aAreaSC6 := {}
	Local   _cMens    := ""
	Local   _cModulo  := ""
	Local   _cTpAlias := "->"
	Local   _nCont    := 0
	Local   _lVali    := .T.

	Private _lAlert   := _lParAle
	Private _cNumPed  := _cParPed
	Private _cRotina  := "RFATE002"

	dbSelectArea("SZ1")
	//Idenficação do módulo
	If Upper(AllTrim(FunName())) == "MATA410" .OR. Upper(AllTrim(FunName())) == "MATA440" 
		_cModulo := "FAT"
	ElseIf Upper(AllTrim(FunName())) == "TMKA271" .OR. AllTrim(FunName()) == "RTMKI001" .OR. AllTrim(FunName()) == "RPC"
		_cModulo := "TMK"	
	EndIf
	//Preventivamente confirma se o módulo atual está previsto na rotina
	If !Empty(_cModulo)
		dbSelectArea("SZ1") // Tabela de validações
		SZ1->(dbSetOrder(0))
		SZ1->(dbGoTop())
		While SZ1->(!EOF())
			If SZ1->Z1_FILIAL <> xFilial("SZ1") .OR. SZ1->Z1_MSBLQL == "1"
				dbSelectArea("SZ1")
				SZ1->(dbSetOrder(0))
				SZ1->(dbSkip())
				loop
			EndIf
			_cMens   := ""
			//Variável auxiliar para utilização com macro substituição
			_cTabAtu := "M"
			_cAux    := AllTrim(SZ1->Z1_TABELA) + "->" + AllTrim(SZ1->Z1_CAMPOS)
			If Upper(AllTrim(FunName())) == "MATA410" .OR. Upper(AllTrim(FunName())) == "MATA440"
				_cAuxMac := SZ1->Z1_CHAVE
				_cTabAtu := "SC5"
			ElseIf Upper(AllTrim(FunName())) == "TMKA271" .OR. AllTrim(FunName()) == "RTMKI001" .OR. AllTrim(FunName()) == "RPC"
				_cAuxMac := SZ1->Z1_CHAVE2
				_cTabAtu := "SUA"
			EndIf
			_nPosCpo := 0
			_nForAt  := 1
			If !AllTrim(SZ1->Z1_TABELA) $ "SUB/SC6/SB1/SF4/SB5"
				If !Empty(_cAuxMac)
					_cAuxMac := _cTabAtu + _cTpAlias + AllTrim(_cAuxMac)
				EndIf
			ElseIf _lAlert .OR. Upper(AllTrim(FunName())) == "MATA410" .OR. Upper(AllTrim(FunName())) == "MATA440" .OR. Upper(AllTrim(FunName())) == "TMKA271"
				_nForAt  := Len(aCols)  
				If AllTrim(SZ1->Z1_TABELA) $ "SB1/SF4/SB5"
					If Upper(AllTrim(FunName())) == "MATA410" .OR. Upper(AllTrim(FunName())) == "MATA440"
						_nPosCpo := aScan(aHeader,{|x| AllTrim(x[02]) == AllTrim(SZ1->Z1_CHAVE )})
					Else 
						_nPosCpo := aScan(aHeader,{|x| AllTrim(x[02]) == AllTrim(SZ1->Z1_CHAVE2)})
					EndIf
				Else
					_nPosCpo := aScan(aHeader,{|x| AllTrim(x[02]) == AllTrim(SZ1->Z1_CAMPOS)})
				EndIf
			Else
				_cAuxMac := _cTabAtu + _cTpAlias + AllTrim(_cAuxMac)
				dbSelectArea("SC6")
				SC6->(dbSetOrder(1))
				If SC6->(dbSeek(xFilial("SC6") + _cNumPed))
					while !SC6->(EOF()) .AND. xFilial("SC6") == SC6->C6_FILIAL .AND. SC6->C6_NUM ==_cNumPed
						_aAreaSC6 := GetArea()
						dbSelectArea(AllTrim(SZ1->Z1_TABELA))
						(AllTrim(SZ1->Z1_TABELA))->(dbSetOrder(SZ1->Z1_INDICE))
						If (AllTrim(SZ1->Z1_TABELA))->(MsSeek(xFilial(AllTrim(SZ1->Z1_TABELA)) + _cAuxMac,.T.,.F.))	//Posiciona no registro a ser validado
							//Verifica se o campo está vazio
							If Upper(SZ1->Z1_VALID1) == 'S' .AND. (_cModulo == Upper(AllTrim(SZ1->Z1_FUNC1)) .OR. Upper(AllTrim(SZ1->Z1_FUNC1)) == "AMB")
								If Empty(&_cAux)
									_cCamp := SZ1->Z1_CAMPOS
									If AllTrim(SZ1->Z1_TABELA) $ "SC6" .AND. _lAlert
										_nPosPro := aScan(aHeader,{|x| AllTrim(x[02]) == "C6_PRODUTO"})
										_nPosIte := aScan(aHeader,{|x| AllTrim(x[02]) == "C6_ITEM"})
										_cMens += "Item: " + aCols[_x][_nPosIte] + " - Produto: " + aCols[_x][_nPosPro] + Chr(13) + Chr(10)
									ElseIf AllTrim(SZ1->Z1_TABELA) $ "SUB" .AND. _lAlert
										_nPosPro := aScan(aHeader,{|x| AllTrim(x[02]) == "UB_PRODUTO"})
										_nPosIte := aScan(aHeader,{|x| AllTrim(x[02]) == "UB_ITEM"})
										_cMens += "Item: " + aCols[_x][_nPosIte] + " - Produto: " + aCols[_x][_nPosPro] + Chr(13) + Chr(10)
									
									ElseIf AllTrim(SZ1->Z1_TABELA) $ "SB5" .AND. _lAlert
										dbSelectArea(AllTrim(SZ1->Z1_TABELA))
										(AllTrim(SZ1->Z1_TABELA))->(dbSetOrder(SZ1->Z1_INDICE))
										If (AllTrim(SZ1->Z1_TABELA))->(MsSeek(xFilial(AllTrim(SZ1->Z1_TABELA)) + SC6->C6_PRODUTO,.T.,.F.))	//Posiciona no registro a ser validado
											_cMens+= SZ1->Z1_MENSAG
										Endif
									EndIf 
									_cMens += AllTrim(SZ1->Z1_MENSAG)
									_nCont++
									If SZ1->Z1_OBRIG1 == 'S'
										_lVali := .F.
										_cMens += " (Obrigatório) "
									EndIf
								EndIf
							EndIf
							//Verifica se campo contém caracteres especiais
							If Upper(SZ1->Z1_VALID2) == 'S' .AND. (_cModulo == Upper(AllTrim(SZ1->Z1_FUNC2)) .OR. Upper(AllTrim(SZ1->Z1_FUNC2)) == "AMB")
								If AllTrim(&_cAux) <> AllTrim(RemoEsp(&_cAux))
									_cCamp := SZ1->Z1_CAMPOS
									_cMens += AllTrim(SZ1->Z1_MENSAG2)
									_nCont++
									If SZ1->Z1_OBRIG2 == 'S'
										_lVali := .F.
										_cMens += " (Obrigatório) "
									EndIf
								EndIf
							EndIf
							//Verifica se campo possui campos de máscara (. / -)
							If Upper(SZ1->Z1_VALID3) == 'S'  .AND. (_cModulo == Upper(AllTrim(SZ1->Z1_FUNC3)) .OR. Upper(AllTrim(SZ1->Z1_FUNC3)) == "AMB")
								If AllTrim(&_cAux) <> AllTrim(StrTran((&_cAux),"."))
									_cCamp := SZ1->Z1_CAMPOS
									_cMens += AllTrim(SZ1->Z1_MENSAG3)
									_nCont++
									If SZ1->Z1_OBRIG3 == 'S'
										_lVali := .F.
										_cMens += " (Obrigatório) "
									EndIf
								EndIf
							EndIf
							//Verifica se campo fórmula foi preenchido
							If !Empty(SZ1->Z1_FORMULA)
								_cFormula := SZ1->Z1_FORMULA
								//Executa a função de validação do usuário
								If _lVali
									If SZ1->(FieldPos("Z1_CTALERT"))<>0
										If SZ1->Z1_CTALERT == "S"
											If !(_lVali := &_cFormula)
												_nCont++
											EndIf
										Else
											_lVali := IIF(ValType(&_cFormula) == "L",&_cFormula == .T.,.T.)
										EndIf
									Else
										_lVali := IIF(ValType(&_cFormula) == "L",&_cFormula == .T.,.T.)
									EndIf
								Else
									If !&_cFormula
										_nCont++
									EndIf
								EndIf
							EndIf
							//Verifica se o cadastro está dentro do prazo de validade do mesmo
							If Upper(SZ1->Z1_VALID4) == 'S' .AND. (_cModulo == Upper(AllTrim(SZ1->Z1_FUNC4)) .OR. Upper(AllTrim(SZ1->Z1_FUNC4)) == "AMB")
								If DToS(&_cAux) < DToS(dDataBase)
									_cCamp := SZ1->Z1_CAMPOS
									_cMens += AllTrim(SZ1->Z1_MENSAG4)
									_nCont++
									If SZ1->Z1_OBRIG4 == 'S'
										_lVali := .F.
										_cMens += " (Obrigatório) "
									EndIf
								EndIf
							EndIf
						EndIf
						//Exibe a mensagem de alerta
						If !Empty(_cMens) .AND. _lAlert
							MsgStop(AllTrim(_cMens),_cRotina+"_001")
						EndIf
						//Restaura a área do início do While por conta do desposicionamento causado durante o processo de validação
						RestArea(_aSvSB1)
						RestArea(_aSvSA1)
						RestArea(_aSvSF4)
						RestArea(_aSvSC9)
						RestArea(_aSvSUS)
						RestArea(_aSvSUA)
						RestArea(_aSvSUB)
						RestArea(_aSvSC5)
						RestArea(_aSvSC6)
						RestArea(_aSvSZ1)
						RestArea(_aArea )
						dbSelectArea("SC6")
						SC6->(dbSetOrder(1))
						SC6->(dbSkip())
					EndDo
				EndIf
			EndIf                                                      
			_cAuxMacA := _cAuxMac   //Armazena conteúdo antes da macrosubstituição
			for _x := 1 to _nForAt
				If AllTrim(SZ1->Z1_TABELA) $ "SUB/SC6/SB1/SF4/SB5" .AND. _lAlert
					If _nPosCpo == 0
						Exit
					EndIf
					_cTabAtu := AllTrim(SZ1->Z1_TABELA)
					_cAuxMac := aCols[_x][_nPosCpo] //Conteúdo do campo
				EndIf
				dbSelectArea(AllTrim(SZ1->Z1_TABELA))
				(AllTrim(SZ1->Z1_TABELA))->(dbSetOrder(SZ1->Z1_INDICE))
				If (AllTrim(SZ1->Z1_TABELA))->(MsSeek(xFilial(AllTrim(SZ1->Z1_TABELA)) + _cAuxMac,.T.,.F.))	//Posiciona no registro a ser validado
					If AllTrim(SZ1->Z1_TABELA) $ "/SB1/SF4/"
						_cAux := _cTabAtu + "->" + AllTrim(SZ1->Z1_CAMPOS)
					EndIf                         
					_cFilMac1 := AllTrim(SZ1->Z1_COND1)
					If IIF(Empty(_cFilMac1),.T.,&(_cFilMac1))
						//Verifica se campo está vazio
						If Upper(SZ1->Z1_VALID1) == 'S' .AND. (_cModulo == Upper(AllTrim(SZ1->Z1_FUNC1)) .OR. Upper(AllTrim(SZ1->Z1_FUNC1)) == "AMB")
							If Empty(&_cAux)
								_cCamp := SZ1->Z1_CAMPOS
								If AllTrim(SZ1->Z1_TABELA) $ "/SC6/" .AND. _lAlert
									_nPosPro := aScan(aHeader,{|x| AllTrim(x[02]) == "C6_PRODUTO"})
									_nPosIte := aScan(aHeader,{|x| AllTrim(x[02]) == "C6_ITEM"   })
									_cMens += "Item: " + aCols[_x][_nPosIte] + " - Produto: " + aCols[_x][_nPosPro] + Chr(13) + Chr(10)
								ElseIf AllTrim(SZ1->Z1_TABELA) $ "/SUB/" .AND. _lAlert
									_nPosPro := aScan(aHeader,{|x| AllTrim(x[02]) == "UB_PRODUTO"})
									_nPosIte := aScan(aHeader,{|x| AllTrim(x[02]) == "UB_ITEM"   })
									_cMens += "Item: " + aCols[_x][_nPosIte] + " - Produto: " + aCols[_x][_nPosPro] + Chr(13) + Chr(10)
								ElseIf AllTrim(SZ1->Z1_TABELA) $ "/SB1/"
									If Upper(AllTrim(FunName())) == "MATA410" .OR. Upper(AllTrim(FunName())) == "MATA440"
										_nPosPro := aScan(aHeader,{|x| AllTrim(x[02]) == "C6_PRODUTO"})
										_nPosIte := aScan(aHeader,{|x| AllTrim(x[02]) == "C6_ITEM"   })
									Else
										_nPosPro := aScan(aHeader,{|x| AllTrim(x[02]) == "UB_PRODUTO"})
										_nPosIte := aScan(aHeader,{|x| AllTrim(x[02]) == "UB_ITEM"   })
									EndIf
									_cMens += "Revise o cadastro do produto: " + aCols[_x][_nPosPro] + Chr(13) + Chr(10)
								ElseIf AllTrim(SZ1->Z1_TABELA) $ "/SF4/"
									If Upper(AllTrim(FunName())) == "MATA410" .OR. Upper(AllTrim(FunName())) == "MATA440"
										_nPosPro := aScan(aHeader,{|x| AllTrim(x[02]) == "C6_PRODUTO"})
										_nPosIte := aScan(aHeader,{|x| AllTrim(x[02]) == "C6_ITEM"})
									Else
										_nPosPro := aScan(aHeader,{|x| AllTrim(x[02]) == "UB_PRODUTO"})
										_nPosIte := aScan(aHeader,{|x| AllTrim(x[02]) == "UB_ITEM"})
									EndIf
									_cMens += "Revise o cadastro de tipos de entradas/saídas: " + SC6->C6_TES + Chr(13) + Chr(10)
								EndIf
								_cMens += AllTrim(SZ1->Z1_MENSAG)
								_nCont++
								If SZ1->Z1_OBRIG1 == 'S'
									_lVali := .F.
									_cMens += " (Obrigatório) "
								EndIf
							EndIf
						EndIf
					EndIf
					_cFilMac2 := AllTrim(SZ1->Z1_COND2)
					If IIF(Empty(_cFilMac2),.T.,&(_cFilMac2))
						//Verifica se campo contém caracteres especiais
						If Upper(SZ1->Z1_VALID2) == 'S' .AND. (_cModulo == Upper(AllTrim(SZ1->Z1_FUNC2)) .OR. Upper(AllTrim(SZ1->Z1_FUNC2)) == "AMB")
							If AllTrim(&_cAux)<>AllTrim(RemoEsp(&_cAux))
								_cCamp := SZ1->Z1_CAMPOS
								_cMens += AllTrim(SZ1->Z1_MENSAG2)
								_nCont++
								If SZ1->Z1_OBRIG2 == 'S'
									_lVali := .F.
									_cMens += " (Obrigatório) "
								EndIf
							EndIf
						EndIf                                           
					EndIf
					_cFilMac3 := AllTrim(SZ1->Z1_COND3)
					If IIF(Empty(_cFilMac3),.T.,&(_cFilMac3))
						//Verifica se campo possui campos de máscara (. / -)
						If Upper(SZ1->Z1_VALID3) == 'S'  .AND. (_cModulo == Upper(AllTrim(SZ1->Z1_FUNC3)) .OR. Upper(AllTrim(SZ1->Z1_FUNC3)) == "AMB")
							If AllTrim(&_cAux) <> AllTrim(StrTran((&_cAux),"."))
								_cCamp := SZ1->Z1_CAMPOS
								_cMens += AllTrim(SZ1->Z1_MENSAG3)
								_nCont++
								If SZ1->Z1_OBRIG3 == 'S'
									_lVali := .F.
									_cMens += " (Obrigatório) "
								EndIf
							EndIf
						EndIf
					EndIf
					//Verifica se campo fórmula foi preenchido
					If !Empty(SZ1->Z1_FORMULA)
						_cFormula := SZ1->Z1_FORMULA
						//Executa a função de validação do usuário
						If _lVali
							If SZ1->(FieldPos("Z1_CTALERT"))<>0
								If SZ1->Z1_CTALERT == 'S'
									If !(_lVali := &_cFormula)
										_nCont++
									EndIf
								Else
									If !(_lVali := IIF(ValType(&_cFormula) == "L",&_cFormula == .T.,.T.))
										_nCont++
									EndIf
								EndIf
							Else
								If !(_lVali := IIF(ValType(&_cFormula) == "L",&_cFormula == .T.,.T.))
									_nCont++
								EndIf
							EndIf
						Else
							If !(_lVali := IIF(ValType(&_cFormula) == "L",&_cFormula == .T.,.T.)) //!&_cFormula
								_nCont++
							EndIf
						EndIf
					EndIf
					//Verifica se o cadastro está dentro do prazo de validade do mesmo
					//Início - Trecho adicionado por Adriano Leonardo em 25/10/2013 para melhoria na rotina
						_cFilMac4 := AllTrim(SZ1->Z1_COND4)
						If IIF(Empty(_cFilMac4),.T.,&(_cFilMac4))
							_lValida := .T.
						Else
							_lValida := .F.
						EndIf
					//Final - Trecho adicionado por Adriano Leonardo em 25/10/2013 para melhoria na rotina
					//If Upper(SZ1->Z1_VALID4) == 'S' .AND. (_cModulo == Upper(AllTrim(SZ1->Z1_FUNC4)) .OR. Upper(AllTrim(SZ1->Z1_FUNC4)) == "AMB") // Linha comentada por Adriano Leonardo em 25/10/2013 para melhoria na rotina
					If Upper(SZ1->Z1_VALID4) == 'S' .AND. (_cModulo == Upper(AllTrim(SZ1->Z1_FUNC4)) .OR. Upper(AllTrim(SZ1->Z1_FUNC4)) == "AMB") .AND. _lValida //Linha adicionada por Adriano Leonardo em 25/10/2013 para melhoria na rotina
						If DToS(&_cAux) < DToS(dDataBase)
							_cCamp := SZ1->Z1_CAMPOS
							_cMens += AllTrim(SZ1->Z1_MENSAG4)
							_nCont++
							If SZ1->Z1_OBRIG4 == 'S'
								_lVali := .F.
								_cMens += " (Obrigatório) "
							EndIf
						EndIf
					EndIf
				EndIf
				//Exibe a mensagem de alerta
				If !Empty(_cMens) .AND. _lAlert
					MsgStop(AllTrim(_cMens),_cRotina+"_001")
					_cMens := "" //Reseta a variável
				EndIf
			next
			dbSelectArea("SZ1")
			SZ1->(dbSetOrder(0))
			SZ1->(dbSkip())
		EndDo
	EndIf
	RestArea(_aSvSB1)
	RestArea(_aSvSA1)
	RestArea(_aSvSF4)
	RestArea(_aSvSC9)
	RestArea(_aSvSUS)
	RestArea(_aSvSUA)
	RestArea(_aSvSUB)
	RestArea(_aSvSC5)
	RestArea(_aSvSC6)
	RestArea(_aSvSZ1)
	RestArea(_aArea )
	//Verifica se há algum campo inválido
	If _nCont > 0 .AND. !_lVali .AND. !Empty(_cModulo)
		//Exibe a quantidade de informações inválidas
		If !Empty(_cModulo) .AND. _lAlert
			If _nCont > 1
				MsgStop("Existem " + AllTrim(Str(_nCont)) + " campos inválidos!",_cRotina+"_002")
			ElseIf _lAlert
				MsgStop("Existe " + AllTrim(Str(_nCont)) + " campo inválido!",_cRotina+"_003")
			EndIf
		EndIf
		//Se o pedido não estiver apto grava a situação como "2"
		If Upper(AllTrim(FunName())) == "MATA410" .OR. Upper(AllTrim(FunName())) == "MATA440"
			while !RecLock("SC5",.F.) ; enddo
				SC5->C5_SITUAC  := "2"
			SC5->(MsUnLock())
		ElseIf Upper(AllTrim(FunName())) == "TMKA271" .OR. AllTrim(FunName()) == "RTMKI001" .OR. AllTrim(FunName()) == "RPC"
			while !RecLock("SUA",.F.) ; enddo
				SUA->UA_SITUAC  := "2"
			SUA->(MsUnLock())
		EndIf
	Else
		//Caso todos os itens tenham sido validos, exibe mensagem de alerta e grava situação do pedido
		If (Upper(AllTrim(FunName())) == "MATA410" .OR. Upper(AllTrim(FunName())) == "MATA440")  .AND. _lAlert
			while !RecLock("SC5",.F.) ; enddo
				SC5->C5_SITUAC  := "1"
				SC5->C5_DATAALT := dDataBase
				SC5->C5_USUARIO := __cUserId
				SC5->C5_HORAALT := Time()
			SC5->(MsUnLock())
			MsgInfo("Pedido validado com sucesso!",_cRotina+"_004")		    
		ElseIf Upper(AllTrim(FunName())) == "TMKA271" .AND. _lAlert
			 while !RecLock("SUA",.F.) ; enddo
				SUA->UA_SITUAC  := "1"
				SUA->UA_DATAAL  := dDataBase
				SUA->UA_USUARI  := __cUserId
				SUA->UA_HORAAL  := Time()
			SUA->(MsUnLock())
			MsgInfo("Atendimento validado com sucesso!",_cRotina+"_005")
		EndIf
	EndIf
	//Caso alguma fórmula não tenha o retorno o default é .T.
	If valtype(_lVali) <> "L"
		_lVali := .T.
	EndIf
	RestArea(_aSvSB1)
	RestArea(_aSvSA1)
	RestArea(_aSvSF4)
	RestArea(_aSvSC9)
	RestArea(_aSvSUS)
	RestArea(_aSvSUA)
	RestArea(_aSvSUB)
	RestArea(_aSvSC5)
	RestArea(_aSvSC6)
	RestArea(_aSvSZ1)
	RestArea(_aArea )
return _lVali
/*/{Protheus.doc} RemoEsp
@description Execblock utilizado para adequar os caracteres recebidos, retornando uma informaçao sem caracteres especiais.
@author Adriano Leonardo
@since 06/12/2012
@version 1.0
@param _cTextoIn, caracter, Texto a ser tratado.
@return _cTextoOut, caracter, Texto tratado.
@type function
@see https://allss.com.br
/*/
static function RemoEsp(_cTextoIn)
	_cTextoOut  := NoAcento(_cTextoIn)
	_cTextoOut  := StrTran(_cTextoOut,'Á'                    ,'A' )
	_cTextoOut  := StrTran(_cTextoOut,'À'                    ,'A' )
	_cTextoOut  := StrTran(_cTextoOut,'Â'                    ,'A' )
	_cTextoOut  := StrTran(_cTextoOut,'Ã'                    ,'A' )
	_cTextoOut  := StrTran(_cTextoOut,'¤'                    ,'A' )
	_cTextoOut  := StrTran(_cTextoOut,'µ'                    ,'A' )
	_cTextoOut  := StrTran(_cTextoOut,'á'                    ,'A' )
	_cTextoOut  := StrTran(_cTextoOut,'à'                    ,'A' )
	_cTextoOut  := StrTran(_cTextoOut,'â'                    ,'A' )
	_cTextoOut  := StrTran(_cTextoOut,'ã'                    ,'A' )
	//_cTextoOut:= StrTran(_cTextoOut,'&'                    ,'E' )
	_cTextoOut  := StrTran(_cTextoOut,'É'                    ,'E' )
	_cTextoOut  := StrTran(_cTextoOut,'È'                    ,'E' )
	_cTextoOut  := StrTran(_cTextoOut,'Ê'                    ,'E' )
	_cTextoOut  := StrTran(_cTextoOut,'é'                    ,'E' )
	_cTextoOut  := StrTran(_cTextoOut,'è'                    ,'E' )
	_cTextoOut  := StrTran(_cTextoOut,'ê'                    ,'E' )
	_cTextoOut  := StrTran(_cTextoOut,'Í'                    ,'I' )
	_cTextoOut  := StrTran(_cTextoOut,'Ì'                    ,'I' )
	_cTextoOut  := StrTran(_cTextoOut,'í'                    ,'I' )
	_cTextoOut  := StrTran(_cTextoOut,'ì'                    ,'I' )
	_cTextoOut  := StrTran(_cTextoOut,'å'                    ,'O' )
	_cTextoOut  := StrTran(_cTextoOut,'Ó'                    ,'O' )
	_cTextoOut  := StrTran(_cTextoOut,'Ò'                    ,'O' )
	_cTextoOut  := StrTran(_cTextoOut,'Ô'                    ,'O' )
	_cTextoOut  := StrTran(_cTextoOut,'Õ'                    ,'O' )
	_cTextoOut  := StrTran(_cTextoOut,'ó'                    ,'O' )
	_cTextoOut  := StrTran(_cTextoOut,'ò'                    ,'O' )
	_cTextoOut  := StrTran(_cTextoOut,'ô'                    ,'O' )
	_cTextoOut  := StrTran(_cTextoOut,'õ'                    ,'O' )
	_cTextoOut  := StrTran(_cTextoOut,'Ú'                    ,'U' )
	_cTextoOut  := StrTran(_cTextoOut,'Ù'                    ,'U' )
	_cTextoOut  := StrTran(_cTextoOut,'Û'                    ,'U' )
	_cTextoOut  := StrTran(_cTextoOut,'Ü'                    ,'U' )
	_cTextoOut  := StrTran(_cTextoOut,'ú'                    ,'U' )
	_cTextoOut  := StrTran(_cTextoOut,'ù'                    ,'U' )
	_cTextoOut  := StrTran(_cTextoOut,'ü'                    ,'U' )
	_cTextoOut  := StrTran(_cTextoOut,'$'                    ,'S' )
	_cTextoOut  := StrTran(_cTextoOut,'"'                    ,''  )
	_cTextoOut  := StrTran(_cTextoOut,CHR(13)                ,''  )
	_cTextoOut  := StrTran(_cTextoOut,CHR(10)                ,' ' )
	_cTextoOut  := StrTran(_cTextoOut,CHR(65533)             ,' ' )
	_cTextoOut  := StrTran(_cTextoOut,"§"                    ,' ' )
	_cTextoOut  := StrTran(_cTextoOut,'#'                    ,'-' )
	_cTextoOut  := StrTran(_cTextoOut,'|'                    ,'/' )
	_cTextoOut  := StrTran(_cTextoOut,('º'+CHR(167)+CHR(176)),'.' )
	_cTextoOut  := StrTran(_cTextoOut,('ª'+CHR(166))         ,'A.')
	_cTextoOut  := StrTran(_cTextoOut,'  '                  ,' ' )
	_cTextoOut  := AllTrim(_cTextoOut)
return _cTextoOut