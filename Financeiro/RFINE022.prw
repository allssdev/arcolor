#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#DEFINE _cEnter CHR(13) + CHR(10)
/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa � RFINE022 �Autor  � Adriano L. de Souza � Data �  23/07/2014  ���
��������������������������������������������������������������������������͹��
���Desc.:  � Rotina respons�vel pela segunda etapa de remontagem de parce- ���
���        � las no faturamento, utilizando o v�nculo do pedido de vendas  ���
���        � com t�tulos de cr�dito (recebimento antecipado e/ou nota de   ���
���        � cr�dito).                                                     ���
��������������������������������������������������������������������������͹��
���Uso P11  � Uso espec�fico Arcolor                                       ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������ͱ����
����������������������������������������������������������������������������*/
User Function RFINE022(_cNumPed, _dDtNota, _aNFs)
	Local _cRotina		:= "RFINE022"
	Local _aSavArea		:= GetArea()
	Local _aSavSZH		:= SZH->(GetArea()) //Compensa��o de adiantamentos
	Local _aSavSF2		:= SF2->(GetArea())
	Local _aSavSE1		:= SE1->(GetArea())
	Local _aSavSX3		:= SX3->(GetArea())
	Local _nRecNF		:= 0
	Local _nRecZZ		:= 0
	Local _nTotPed		:= 0
	Local _cAliasSX3 := ""
	Private _nValor		:= 0
	Private _nQtdPZZ	:= 0
	Private _nQtdPNF	:= 0
	Private _cSerZZ		:= ""
	Private _cNumZZ		:= ""
	Private _cSerNF		:= ""
	Private _cNumNF		:= ""
	Private _aCpoSom	:= {} //Campos que dever�o ser somados para ser feita a propor��o com os t�tulos remontados
	Private _aValores	:= {}
	Private _aTitulo	:= {}
	Private _aDelSE1	:= {}
	Default _aNFs		:= {}
	Default _cNumPed	:= ""
	Default _dDtNota	:= STOD("")
	
	Private _cSERFATA := GetMV("MV_SERFATA")
	Private _cSERFATZ := GetMV("MV_SERFATZ")
	
	//Adiciono campos que dever�o ser somados inicializando a soma com zero
	//_aCposSom[1] = Nome do campo
	//_aCposSom[2] = Soma do campo em todos os t�tulos
	//_aCposSom[3] = Saldo da soma (rateio)
	AADD(_aCpoSom,{"E1_ISS"		,0,0})
	AADD(_aCpoSom,{"E1_IRRF"	,0,0})
	AADD(_aCpoSom,{"E1_INSS"	,0,0})
	AADD(_aCpoSom,{"E1_CSLL"	,0,0})
	AADD(_aCpoSom,{"E1_COFINS"	,0,0})
	AADD(_aCpoSom,{"E1_PIS"		,0,0})
	AADD(_aCpoSom,{"E1_ACRESC"	,0,0})
	AADD(_aCpoSom,{"E1_DECRESC"	,0,0})
	AADD(_aCpoSom,{"E1_FETHAB"	,0,0})
	AADD(_aCpoSom,{"E1_MDMULT"	,0,0})
	AADD(_aCpoSom,{"E1_MDBONI"	,0,0})
	AADD(_aCpoSom,{"E1_MDDESC"	,0,0})
	AADD(_aCpoSom,{"E1_RETCNTR"	,0,0})
	AADD(_aCpoSom,{"E1_VALCOM1"	,0,0})
	AADD(_aCpoSom,{"E1_BASCOM1"	,0,0})
	AADD(_aCpoSom,{"E1_VALCOM2"	,0,0})
	AADD(_aCpoSom,{"E1_BASCOM2"	,0,0})
	AADD(_aCpoSom,{"E1_VALCOM3"	,0,0})
	AADD(_aCpoSom,{"E1_BASCOM3"	,0,0})
	AADD(_aCpoSom,{"E1_VALCOM4"	,0,0})
	AADD(_aCpoSom,{"E1_BASCOM4"	,0,0})
	AADD(_aCpoSom,{"E1_VALCOM5"	,0,0})
	AADD(_aCpoSom,{"E1_BASCOM5"	,0,0})
	//Consulta para retornar os t�tulos de cr�dito vinculados ao pedido
	/*
	_cQry := "SELECT * FROM " + RetSqlName("SZH") + " SZH " + _cEnter
	_cQry += "WHERE SZH.ZH_FILIAL = '" + xFilial("SZH") + "' " + _cEnter
	_cQry += "  AND SZH.ZH_PEDIDO = '" + _cNumPed + "' " + _cEnter
	_cQry += "  AND SZH.ZH_SALDO  > 0 " + _cEnter
	_cQry += "  AND SZH.D_E_L_E_T_= '' " + _cEnter
	_cTabTmp := GetNextAlias() //Retorna o pr�ximo alias dispon�vel
	//Crio tabela tempor�ria com os t�tulos vinculados ao pedido
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cTabTmp,.F.,.T.)
	*/
	_cTabTmp := GetNextAlias() //Retorna o pr�ximo alias dispon�vel
	BeginSql Alias _cTabTmp
		SELECT *
		FROM %table:SZH% SZH
		WHERE SZH.ZH_FILIAL = %xFilial:SZH%
		  AND SZH.ZH_PEDIDO = %Exp:_cNumPed%
		  AND SZH.ZH_SALDO  > 0
		  AND SZH.%NotDel%
	EndSql
	dbSelectArea(_cTabTmp)
	//Verifico o valor a ser compensado
	While !(_cTabTmp)->(EOF())
		_nValor += (_cTabTmp)->ZH_SALDO
	    dbSelectArea(_cTabTmp)
	    (_cTabTmp)->(dbSkip())
	EndDo
	//Fecho a tabela tempor�ria
	dbSelectArea(_cTabTmp)
	(_cTabTmp)->(dbCloseArea())
	//Certifico que h� valor a ser compensado
	If _nValor > 0
		_nTotNf := 0
		_nTotZZ := 0
		_cFiltro:= ""
		//Verifico as notas geradas
		For _nCont := 1 To Len(_aNFs)
			dbSelectArea("SF2")
			SF2->(dbSetOrder(1))
			If SF2->(dbSeek(xFilial("SF2")+_aNFs[_nCont,1]+_aNFs[_nCont,2]))
				If !Empty(_cFiltro)
					_cFiltro += " OR "
				EndIf
				_cFiltro += "(SE1.E1_NUM='" + _aNFs[_nCont,1] + "' " + _cEnter
				_cFiltro += "AND SE1.E1_PREFIXO='" + _aNFs[_nCont,2] + "') " + _cEnter
				//Armazeno o total faturado das NFs
				If _aNFs[_nCont,2] == _cSERFATA //S�rie padr�o de faturamento		//SuperGetMV("MV_SERFATA",,"1")
					_nTotNf := SF2->F2_VALFAT
					//Armazeno a s�rie e n�mero da Nf
					If Empty(_cNumNF)
						_cNumNF := _aNFs[_nCont,1]
						_cSerNF := _aNFs[_nCont,2]
					EndIf
				Else
					_nTotZZ := SF2->F2_VALFAT
					//Armazeno a s�rie e n�mero do romaneio
					If Empty(_cNumZZ)
						_cNumZZ := _aNFs[_nCont,1]
						_cSerZZ := _aNFs[_nCont,2]
					EndIf
				EndIf
			EndIf
		Next

		If !Empty(_cFiltro)
			_cFiltro := "%AND "+_cFiltro+"%"
		Else
			_cFiltro := "%%"
		EndIf
		_cTabTmp2 := GetNextAlias() //Retorna o pr�ximo alias dispon�vel
		BeginSql Alias _cTabTmp2
			SELECT * 
			FROM %table:SE1% SE1
			WHERE SE1.E1_FILIAL = %xFilial:SE1%
			  AND SE1.E1_TIPO   = 'NF'
			  AND SE1.E1_PEDIDO = %Exp:_cNumPed%
			  AND SE1.E1_SALDO  > 0
			  AND SE1.%NotDel%
			  %Exp:_cFiltro%
			  ORDER BY SE1.E1_VENCTO ASC, SE1.E1_SERIE DESC
		EndSql
		_nQtdPar := 0 //Vari�vel com totalizador de parcelas
		_nQtdPNF := 0
		_nQtdPZZ := 0
		_aTitulo := {}
		_aDelSE1 := {}
		dbSelectArea(_cTabTmp2)
		While (_cTabTmp2)->(!EOF())
			_nQtdPar++							//Quantidade de parcelas
			_nTotPed+= (_cTabTmp2)->E1_VALOR	//Soma das duplicatas (utilizada para proporcionaliza��o dos campos de soma)
			_aAux	:= {}
			AAdd(_aAux,(_cTabTmp2)->E1_PREFIXO) //1-Prefixo
			AAdd(_aAux,(_cTabTmp2)->E1_NUM    ) //2-N�mero
			AAdd(_aAux,(_cTabTmp2)->E1_PARCELA) //3-Parcela
			AAdd(_aAux,(_cTabTmp2)->E1_SALDO  ) //4-Valor
			AAdd(_aAux,(_cTabTmp2)->E1_VENCTO ) //5-Vencimento
			AAdd(_aAux,(_cTabTmp2)->E1_VENCREA) //6-Vencimento real
			AAdd(_aAux,(_cTabTmp2)->R_E_C_N_O_) //7-Recno do registro
			//Preservo o recno da s�rie 1
			If _nRecNF==0 .And. (_cTabTmp2)->E1_PREFIXO == PadR(_cSERFATA,TamSx3("E1_PREFIXO")[01])		//SuperGetMV("MV_SERFATA",,"1"  )
				_nRecNF := (_cTabTmp2)->R_E_C_N_O_
			EndIf
			//Preservo o recno da s�rie Z
			If _nRecZZ==0 .And. (_cTabTmp2)->E1_PREFIXO == PadR(_cSERFATZ,TamSx3("E1_PREFIXO")[01])		//SuperGetMV("MV_SERFATZ",,"ZZZ")
				_nRecZZ := (_cTabTmp2)->R_E_C_N_O_
			EndIf
			AAdd(_aTitulo,_aAux)
			If (_cTabTmp2)->(E1_PREFIXO)==PadR(_cSERFATA,TamSx3("E1_PREFIXO")[01])						//SuperGetMV("MV_SERFATA",,"1"  )
				_nQtdPNF++
			Else
				_nQtdPZZ++
			EndIf
			//Fa�o a somat�ria dos campos definidos no array _aCpoSom (para proporcionaliza��o)
			For _nAux := 1 To Len(_aCpoSom)
				_aCpoSom[_nAux][2] += (_cTabTmp2)->(&(_aCpoSom[_nAux][1]))
				_aCpoSom[_nAux][3] += (_cTabTmp2)->(&(_aCpoSom[_nAux][1]))
			Next
			//Preservo o recno dos t�tulos que dever�o ser deletados para remontagem
			AAdd(_aDelSE1,(_cTabTmp2)->(R_E_C_N_O_))
			dbSelectArea(_cTabTmp2)
			(_cTabTmp2)->(dbSkip())
		EndDo
		//Fecho a tabela tempor�ria
		dbSelectArea(_cTabTmp2)
		(_cTabTmp2)->(dbCloseArea())
		_nQtdSer	:= Len(_aNotas) //Quantidade de notas geradas
		_nSldNf		:= _nTotNf
		_nSldZZ		:= _nTotZZ
		_nSldCmp	:= _nValor
		_nVlrAux	:= 0
		_nVlAuxZ	:= 0
		_nVlAuxN	:= 0
		_nParAdi	:= 0
		//In�cio da avalia��o do cen�rio para remontagem das parcelas
		_aValores := {}
		//Calculo o novo valor para cada parcela
		For _nCont2 := 1 To Len(_aTitulo)
			//Caso seja a primeira parcela, considero o valor do adiantamento
			If _nCont2 == 1
				If (_nSldNf+_nSldZZ) >= _nValor //Fa�o o tratamento para o caso do valor a ser compensado ser menor ou igual ao total das duplicatas
					If _aTitulo[_nCont2,1]==PadR(_cSERFATZ,TamSx3("E1_PREFIXO")[01])		//SuperGetMV("MV_SERFATZ",,"ZZZ")
						If _nValor > _nSldZZ //Avalio se o valor a ser compensado � superior ao total desta s�rie, nesse caso ser�o gerados dois t�tulos
							AAdd(_aValores,{'A',_nSldZZ			,1,_cSerZZ,_cNumZZ})
							_nParAdi++
							AAdd(_aValores,{'A',_nValor-_nSldZZ	,2,_cSerNF,_cNumNF})
							_nParAdi++
							//Atualizo o saldo a compensar por s�rie
							_nSldNf	:= _nTotNf - (_nValor-_nSldZZ)
							_nSldZZ := 0
						Else //Caso o valor a ser compensado se enquadre dentro do valor para a s�rie gero apenas uma parcela
							AAdd(_aValores,{'A',_nValor			,1,_cSerZZ,_cNumZZ})
							_nParAdi++
							_nSldZZ -= _nValor
							//Verifico se ficou saldo da s�rie e n�o h� mais parcelas para rateio do valor
							If _nQtdPZZ == 1 .And. _nSldZZ>0
								AAdd(_aValores,{'N',_nSldZZ			,1,_cSerZZ,_cNumZZ})
								_nParAdi++
								_nSldZZ := 0
							EndIf
						EndIf
					ElseIf _aTitulo[_nCont2,1]==PadR(_cSERFATA,TamSx3("E1_PREFIXO")[01])		//SuperGetMV("MV_SERFATA",,"1")
						If _nValor > _nSldNf //Avalio se o valor a ser compensado � superior ao total desta s�rie, nesse caso ser�o gerados dois t�tulos
							AAdd(_aValores,{'A',_nSldNf			,2,_cSerNF	,_cNumNF})
							_nParAdi++
							AAdd(_aValores,{'A',_nValor-_nSldNf	,3,Nil		,Nil	})
							_nParAdi++
							//Atualizo o saldo a compensar por s�rie
							_nSldNf := 0
						Else //Caso o valor a ser compensado se enquadre dentro do valor para a s�rie gero apenas uma parcela
							AAdd(_aValores,{'A',_nValor			,2,_cSerNF	,_cNumNF})
							_nParAdi++
							_nSldNf -= _nValor
							//Caso seja parcela �nica e ainda reste saldo para a s�rie, gero novo t�tulo com o saldo
							If _nQtdPNF==1 .And. _nSldNf>0
								AAdd(_aValores,{'N',_nSldNf			,2,_cSerNF	,_cNumNF})
								_nSldNf := 0
							EndIf
						EndIf
					EndIf
				Else  //Fa�o o tratamento para o caso do valor a ser compensado ser maior que o total das duplicatas
					//Certifico que h� algum valor no romaneio a ser compensado
					If _nSldZZ>0
						AAdd(_aValores,{'A',_nSldZZ		,1,_cSerZZ,_cNumZZ})
						_nParAdi++
					EndIf
					//Certifico que h� algum valor na NF a ser compensado
					If _nSldNF>0
						AAdd(_aValores,{'A',_nSldNf		,2,_cSerNF,_cNumNF})
						_nParAdi++
					EndIf
					_nSldCmp -= (_nSldZZ + _nSldNf)
					_nSldZZ := _nSldNf := 0 //Linha adicionada por Adriano Leonardo em 06/12/2014 para zerar o saldo a compensar das s�ries
				EndIf
			Else //Demais parcelas
				If _aTitulo[_nCont2,1]==PadR(_cSERFATZ,TamSx3("E1_PREFIXO")[01])		//SuperGetMV("MV_SERFATZ",,"ZZZ")
					If _nSldZZ >0
						If _nQtdSer == 1
							If _nCont2 == 2
								_nVlrAux := NoRound(_nSldZZ / (_nQtdPZZ-1),TamSX3("E1_VALOR")[02])
							EndIf
							//Se for a segunda parcela, considero o reparcelamento do saldo
							If _nCont2 == _nQtdPZZ
								AAdd(_aValores,{'N',_nSldZZ		,1,_cSerZZ,_cNumZZ})
								_nSldZZ  -= _nSldZZ
							Else
								AAdd(_aValores,{'N',_nVlrAux	,1,_cSerZZ,_cNumZZ})
								_nSldZZ  -= _nVlrAux
								_nVlrAux := 0
							EndIf
						Else
							//Considero o saldo da s�rie Z (se haver� reparcelamento do saldo nas parcelas da s�rie Z ou n�o)
							If _nCont2==2 .And. _nQtdPZZ>2
								_nVlAuxZ := _nSldZZ / (_nQtdPZZ-1)
							EndIf
							If _nVlAuxZ > 0
								AAdd(_aValores,{'N',_nVlAuxZ	,1,_cSerZZ,_cNumZZ})
								_nSldZZ  -= _nVlAuxZ
							Else
								AAdd(_aValores,{'N',_nSldZZ		,1,_cSerZZ,_cNumZZ})
								_nSldZZ := 0
							EndIf
						EndIf
					EndIf
				ElseIf _aTitulo[_nCont2,1]==PadR(_cSERFATA,TamSx3("E1_PREFIXO")[01])		//SuperGetMV("MV_SERFATA",,"1")
					If _nSldNf >0
						//Verifico se os t�tulos da Nf ser�o reparcelados ou n�o
						If _nParAdi==1 .And. _nQtdSer==2 .And. _nValor<>_nTotZZ
							AAdd(_aValores,{'N',_aTitulo[_nCont2,4]	,2,_cSerNF,_cNumNF})
							_nSldNf  -= _aTitulo[_nCont2,4]
						Else
							If _nVlrAux == 0
								If _nParAdi==2 .And. _nQtdPNf>1
									//Neste caso houve um adiantamento em ambas as s�ries
									_nVlrAux := NoRound(_nSldNF / (_nQtdPNf-1+_nParAdi),TamSX3("E1_VALOR")[02])
								ElseIf _nParAdi==1 .And. _nQtdSer==1
									//Neste caso existe apenas uma s�rie e houve um adiantamento na mesma
									_nVlrAux := NoRound(_nSldNF / (_nQtdPNf-1),TamSX3("E1_VALOR")[02])
								ElseIf _nQtdSer>1 .And. _nParAdi==1 .And. _nTotZZ==_nValor
									//Neste caso existe mais de uma s�rie e o adiantamento foi compensado totalmente na s�rie anterior
									_nVlrAux := NoRound(_nSldNF / (_nQtdPar-1),TamSX3("E1_VALOR")[02])
								EndIf
							EndIf
							If _nVlrAux > 0
								//Fa�o o reparcelamento do saldo da NF
								For _nCont3 := 1 To (_nQtdPar - 1)
									If _nCont3 == (_nQtdPar - 1)
										AAdd(_aValores,{'N',_nSldNf		,2,_cSerNF,_cNumNF})
										_nSldNf := 0
									Else
										AAdd(_aValores,{'N',_nVlrAux	,2,_cSerNF,_cNumNF})
										_nSldNf -= _nVlrAux
									EndIf
                                Next
							Else
								//AAdd(_aValores,{'N',_aTitulo[_nCont2,4]	,2,_cSerNF,_cNumNF})
								//_nSldNf -= _aTitulo[_nCont2,4]
								AAdd(_aValores,{'N',_nSldNf	,2,_cSerNF,_cNumNF})
								_nSldNf -= _nSldNf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			//Caso n�o exista mais saldo a compensar, saio do la�o de repeti��o para dispensar processamento desnecess�rio
        	If (_nSldNF + _nSldZZ)==0
        		Exit
        	EndIf
		Next
	EndIf
	//Total de parcelas
	If _nValor > 0
		_nParAux := (_nQtdPZZ + _nQtdPNf)
	EndIf
	//Defino os vencimentos dos t�tulos com base nos t�tulos originais
	For _nCont4 := Len(_aValores) To 1 Step -1
		aSize(_aValores[_nCont4],Len(_aValores[_nCont4])+2)//Adiciono mais duas colunas no array
		_aValores[_nCont4,Len(_aValores[_nCont4])-1] := _aTitulo[_nParAux,5] //Vencimento
		_aValores[_nCont4,Len(_aValores[_nCont4])  ] := _aTitulo[_nParAux,6] //Vencimento real
		//Verifico se j� encontrou o primeiro vencimento
		If _nParAux>1
			_nParAux--
		EndIf
	Next
	//In�cio o segundo processo de remontagem das parcelas
	_nParZZ := 1
	_nParNF := 1
	//Varro o array com os t�tulos a serem remontados para defini��o do n�mero de parcela
	For _nCont5 := 1 To Len(_aValores)
		aSize(_aValores[_nCont5],Len(_aValores[_nCont5])+1) //Adiciono nova coluna no array (parcela)
		If _aValores[_nCont5,3]	== 1
			_aValores[_nCont5,Len(_aValores[_nCont5])] := AllTrim(Str(_nParZZ))
			_nParZZ++
		Else
			_aValores[_nCont5,Len(_aValores[_nCont5])] := AllTrim(Str(_nParNF))
			_nParNF++
		EndIf
	Next
	_aTitTmp := {}
	_aTitNew := {}
	For _nCont6 := 1 To Len(_aValores)
		If _aValores[_nCont6,3]==3 //Saldo do adiantamento (maior que total do pedido)
			Loop
		EndIf
		dbSelectArea("SE1")
		//Posiciono o t�tulo base para remontagem
		If _aValores[_nCont6,3]==1
			SE1->(dbGoTo(_nRecZZ))
		ElseIf _aValores[_nCont6,3]==2
			SE1->(dbGoTo(_nRecNF))
		Else
			SE1->(dbGoTo(0))
		EndIf

		_cAliasSX3 := "SX3_"+GetNextAlias()
		OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
		dbSelectArea(_cAliasSX3)
		(_cAliasSX3)->(dbSetOrder(1))
		(_cAliasSX3)->(MsSeek("SE1"))
		While (_cAliasSX3)->(!EOF()) .AND. (_cAliasSX3)->X3_ARQUIVO == "SE1"
			If (_cAliasSX3)->X3_CONTEXT <> "V";
				.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_SALDO"  	;
				.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_VALOR"  	;
				.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_VENCTO" 	;
				.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_VENCREA"	;
				.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_PREFIXO"	;
				.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_VENCORI"	;
				.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_SERIE"  	;
				.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_NUM"    	;
				.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_PARCELA"	;
				.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_REMONTA"	;
				.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_VLCRUZ"	;
				.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_CARTEIR"	;
				.And. aScan( _aCpoSom,{|x| AllTrim(x[01])==AllTrim((_cAliasSX3)->X3_CAMPO)})<=0 //Certifico que o campo n�o est� no array _aCpoSom
				AADD(_aTitTmp, {AllTrim((_cAliasSX3)->X3_CAMPO), SE1->&((_cAliasSX3)->X3_CAMPO)})
			EndIf
			dbSelectArea(_cAliasSX3)
			(_cAliasSX3)->(dbSetOrder(1))
			(_cAliasSX3)->(dbSkip())
		EndDo		
		
		AADD(_aTitTmp, {"E1_SALDO"	, _aValores[_nCont6,2]		})
		AADD(_aTitTmp, {"E1_VALOR"	, _aValores[_nCont6,2]		})
		AADD(_aTitTmp, {"E1_VLCRUZ"	, _aValores[_nCont6,2]		})
		AADD(_aTitTmp, {"E1_PREFIXO", _aValores[_nCont6,4]		})
		AADD(_aTitTmp, {"E1_SERIE"	, _aValores[_nCont6,4]		})
		AADD(_aTitTmp, {"E1_NUM"	, _aValores[_nCont6,5]		})
		AADD(_aTitTmp, {"E1_PARCELA", _aValores[_nCont6,8]		})
		AADD(_aTitTmp, {"E1_REMONTA", "N"				  		})
		AADD(_aTitTmp, {"E1_VENCTO"	, STOD(_aValores[_nCont6,6])})
		AADD(_aTitTmp, {"E1_VENCORI", STOD(_aValores[_nCont6,6])})
		AADD(_aTitTmp, {"E1_VENCREA", STOD(_aValores[_nCont6,7])})
		//Para t�tulos antecipados gravo a carteira como "RA" para que n�o sejam impressos boletos de t�tulos j� pagos
		If _aValores[_nCont6,1]=="A"
			AADD(_aTitTmp,{"E1_CARTEIR","RA"			})
		Else
			AADD(_aTitTmp,{"E1_CARTEIR",SE1->E1_CARTEIR	})
		EndIf
		//Adiciono os campos que ser� feita propor��o com base na soma das duplicatas x valor do t�tulo remontado
		For _nCont10 := 1 To Len(_aCpoSom)
			//Garanto que na �ltima parcela ser� utilizado o saldo da propor��o, para eliminar poss�veis diferen�as por arredondamento nas parcelas anteriores
			If Len(_aValores)==_nCont6
				_nVlrProp := _aCpoSom[_nCont10][3]
			Else
				//Valor proporcional = (Valor do t�tulo (remontado) x soma do campo (todos as parcelas))/valor total de duplicatas
				_nVlrProp := NoRound((_aValores[_nCont6,2] * _aCpoSom[_nCont10,2])/_nTotPed,TamSx3(_aCpoSom[_nCont10,1])[02])
			EndIf
			_aCpoSom[_nCont10][3] -= _nVlrProp
			AADD(_aTitTmp, {_aCpoSom[_nCont10][1], _nVlrProp	})
		Next
		//Adiciono o array montado com a pr�via do novo t�tulo em array auxiliar
		AADD(_aTitNew,_aTitTmp)			
		_aTitTmp := {}
	Next
	//Deleto as parcelas que ser�o remontadas
	For _nCont7 := 1 To Len(_aDelSE1)
		dbSelectArea("SE1")
		SE1->(dbGoTo(_aDelSE1[_nCont7]))
		while !RecLock("SE1",.F.) ; enddo
			SE1->E1_TIPO := "DE2" //Preven��o de chave duplicada e rastreabilidade
			SE1->(dbDelete())
		SE1->(MsUnLock())
	Next
	//Insiro os novos t�tulos com base no array montado (remontagem)
	For _nCont8 := 1 To Len(_aTitNew)
		dbSelectArea("SE1")
		while !RecLock("SE1",.T.) ; enddo
			For _nCont9 := 1 To Len(_aTitNew[_nCont8])
				SE1->(&(_aTitNew[_nCont8][_nCont9][1])) := _aTitNew[_nCont8][_nCont9][2]
			Next
		SE1->(MsUnLock())
	Next
	//Restauro a �rea de trabalho original
	RestArea(_aSavSX3)
	RestArea(_aSavSE1)
	RestArea(_aSavSF2)
	RestArea(_aSavSZH)
	RestArea(_aSavArea)
Return()