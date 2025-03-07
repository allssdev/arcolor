#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FILEIO.CH"

#DEFINE _lEnt CHR(13) + CHR(10)
/*/{Protheus.doc} FT100RNI
Ponto de Entrada que possibilita a continua��o da avalia��o dos itens da regra de neg�cios.
Rotina que realiza a valida��o da regra de desconto dos itens do pedido de vendas ou do Televendas checando os descontos nos itens e no cabe�alho (Desconto 1,2,3,4).
@author Adriano Leonardo
@since 12/02/2014
@version 1.0
@type function
@see https://allss.com.br
@history 09/01/2023, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Por conta de problemas no processo de avalia��o da regra de bloqueio (vers�o 1005 no SVN), retornamos a vers�o imediatamente anterior � ultima (vers�o 820 no SVN).
@history 06/02/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Ajuste na regra de negocio vinculada ao terceiro nivel, de forma a cascatear o desconto.
/*/
user function FT100RNI()
	Local _aSavArea		:= GetArea()
	Local _aSavSC5		:= SC5->(GetArea())
	Local _aSavSUA		:= SUA->(GetArea())
	Local _cLock        := ""
	Local _cSC6RTMP     := GetNextAlias()
	Local _lUA_STATSC9  := SUA->(FieldPos("UA_STATSC9"))>0
	Local _lUA_LOGSTAT  := SUA->(FieldPos("UA_LOGSTAT"))>0
	Local _lUA_OBSBLQ   := SUA->(FieldPos("UA_OBSBLQ" ))>0
	Local _lC5_LOGSTAT  := SC5->(FieldPos("C5_LOGSTAT"))>0
	Local _lC5_AVREGRA  := SC5->(FieldPos("C5_AVREGRA"))>0
	Local _lC5_CONTOBS  := SC5->(FieldPos("C5_CONTOBS"))>0
	Local _lC5_OBSBLQ   := SC5->(FieldPos("C5_OBSBLQ" ))>0

	Private _cRotina	:= "FT100RNI"
	Private _cAliSC5    := IIF((Type("M->C5_NUM")=="C" .AND. Type("INCLUI")=="L" .AND. INCLUI .AND. M->C5_NUM <> SC5->C5_NUM),"M","SC5")
	Private _nPosIte    := aScan(aHeader,{|x|Alltrim(x[2])=="C6_ITEM"   })
	Private _nPosPro    := aScan(aHeader,{|x|Alltrim(x[2])=="C6_PRODUTO"})
	Private _nPosQtd    := aScan(aHeader,{|x|Alltrim(x[2])=="C6_QTDVEN" })
	Private _nPosDesc   := aScan(aHeader,{|x|Alltrim(x[2])=="C6_DESCONT"})
//	Private _nPPrcV     := aScan(aHeader,{|x|Alltrim(x[2])=="C6_PRCVEN" })
//	Private _nPPLis     := aScan(aHeader,{|x|Alltrim(x[2])=="C6_PRUNIT" })
	Private cCodReg		:= ParamIXB[01] //C�digo da regra.
	Private cTabPreco	:= ParamIXB[02] //C�digo da tabela de pre�o.
	Private cCondPg		:= ParamIXB[03] //C�digo da condi��o de pagamento.
	Private cFormPg		:= ParamIXB[04] //C�digo da forma de pagamento.
	Private aProdutos	:= ParamIXB[05] //Array com o c�digo de produto.
	Private aProdDesc	:= ParamIXB[06] //Array com detalhe de descontos.Detalhamento em observa��es.
	Private _lBlRes     := .F.			//Pedido com elimina��o de res�duo.
	Private lContinua	:= .F.			//ParamIXB[07] //Indica se continua pesquisa, default .F. para ganho de desempenho a pesquisa das regras no padr�o n�o ser�o consideradas.
	Private lRetorno	:= ParamIXB[08] //Indica se regra ou exce��o.
	Private lContVerba	:= ParamIXB[09] //Indica se continua verba
	Private lExecao		:= ParamIXB[10] //Indica valida��o de opera��es de exce��o
	Private aRetPE		:= {aProdDesc,lContinua,lRetorno,lContVerba,lExecao}
	Private _cMsgCab	:= ""
	Private _cMsgIte	:= ""
	Private _nDescAux	:= 0
	Private _nDesProm	:= 0
	Private _nDesBase	:= 0
	Private _nDesPerm	:= 0
	Private _nDescMax	:= 0	//Desconto m�ximo permitido pela condi��o de pagamento
	Private _nFatCabe   := 0	//Fator de desconto calculado para o cabe�alho do pedido
	Private _cContObs	:= ""
	//Private _cBkpObs	:= ""
	//Private _cCamArq 	:=  GetSrvProfString("ROOTPATH","")+"\temp\" 	//Retorna o caminho do RootPath de acordo como arquivo .INI do AppServer
	//Private _cCamArq 	:= "C:\temp\" 									//Retorna o caminho do RootPath de acordo como arquivo .INI do AppServer
	Private _cCamArq 	:= ""//GetTempPath() 							//Retorna o caminho do tempor�rio do terminal do usu�rio
	Private _cArquivo	:= "Memo_" + AllTrim(&(_cAliSC5+"->C5_NUM")) + ".txt"
	Private _cLog  		:= ""
	Private _cLogx		:= ""
	Private _cMsgDCab   := ""
	Private _nDescDiv	:= 0
	Private _nDesCond   := 0
	Private _nDesItem	:= 0
	Private _cBlqFina	:= "O pedido possui TES que n�o gera financeiro"

	If AllTrim(FunName()) == "FATA300"
		return aRetPE
	EndIf
	If AllTrim(FunName()) == "TMKA271"
		If _nPosPro == 0 .OR. (Type("M->UA_NUMSC5")<>"U" .AND. Empty(M->UA_NUMSC5) .AND. Empty(SUA->UA_NUMSC5)) .OR. (Type("M->UA_OPER")<>"U" .AND. !AllTrim(M->UA_OPER)$("|"+SuperGetMv("MV_FATOPER",,"01|ZZ|9")+"|"))
			return aRetPE
		EndIf
	EndIf
	If Alltrim(FunName()) == "MATA415" .OR. AllTrim(FunName()) == "RTMKI001" .OR. AllTrim(FunName()) == "RPC" //.OR. _cAliSC5 == "M"
		return aRetPE
	EndIf
	if type("_cNumAten")=="U"
		private _cNumAten := ""
	endif
	_cCamArq 	:= "\\192.168.1.212\G$\planilhas12\Log_Regras_Negocios\" //Retorna o caminho do tempor�rio do terminal do usu�rio
	//	_cCamArq 	:= GetTempPath() //Retorna o caminho do tempor�rio do terminal do usu�rio
	_cLock      := _cCamArq+_cRotina+"_"+AllTrim(&(_cAliSC5+"->C5_NUM"))+cNumEmp+__cUserId+"_"+DTOS(Date())+".log"
	If _cAliSC5 == "SC5"
		If !SC5->(EOF()) // - CONDI��O INSERIDA EM 23/09/2014 POR J�LIO SOARES PARA CORRIGIR VALIDA��O
			dbSelectArea("SC5")
			If _lC5_AVREGRA
				while !RecLock("SC5",.F.) ; enddo
					SC5->C5_AVREGRA := "S" //Flag para gravar se o pedido foi avaliado por regra
				SC5->(MsUnLock())
			EndIf
		EndIf
	elseif _lC5_AVREGRA
		&(_cAliSC5+"->C5_AVREGRA") := "S" //Flag para gravar se o pedido foi avaliado por regra
	EndIf
	if _lC5_CONTOBS
		_cContObs := &(_cAliSC5+"->C5_CONTOBS")
	else
		_cContObs := ""
	endif
	If _cAliSC5 == "SC5"
		If !(SC5->(DBRLock())) .And. !SC5->(EOF())
			while !RecLock("SC5",.F.) ; enddo
		EndIf
		//Se houver algum item com elimina��o de res�duos, n�o avalio as regras de neg�cios
		/*
		_cQry := " SELECT COUNT(*) BLQS " + _lEnt
		_cQry += " FROM " + RetSqlName("SC6") + " SC6 " + _lEnt
		_cQry += " WHERE SC6.D_E_L_E_T_ = '' " + _lEnt
		_cQry += "   AND SC6.C6_FILIAL  = '" + xFilial("SC6") + "' " + _lEnt
		_cQry += "   AND SC6.C6_BLQ     = 'R' " + _lEnt
		_cQry += "   AND SC6.C6_NUM     = '" + SC5->C5_NUM    + "' " + _lEnt
		//If __cUserId == "000000"
		//		MemoWrite("\2.Memowrite\"+_cRotina+"_QRY_001.txt",_cQry)
		//EndIf
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"SC6RTMP",.F.,.F.)
		*/
		BeginSql Alias _cSC6RTMP
			SELECT TOP 1 'A' BLQS			//SELECT COUNT(*) BLQS
			FROM %table:SC6% SC6 (NOLOCK)
			WHERE SC6.C6_FILIAL  = %xFilial:SC6%
			  AND SC6.C6_NUM     = %Exp:SC5->C5_NUM%
			  //AND SC6.C6_NUM     = %Exp:&(_cAliSC5+"->C5_NUM")%
			  AND SC6.C6_BLQ     = %Exp:"R"%
			  AND SC6.%NotDel%
		EndSql
		if select(_cSC6RTMP) > 0
			dbSelectArea(_cSC6RTMP)
				_lBlRes := (_cSC6RTMP)->BLQS == 'A'		//(_cSC6RTMP)->BLQS > 0
			(_cSC6RTMP)->(dbCloseArea())
		endif
	EndIf
	//Avalio se todas as TES do pedido geram financeiro, caso contr�rio o pedido bloqueado
	If !(lRetorno         := lContVerba := AvGerFin())
		_cMsgIte          := _cBlqFina
		aProdDesc[01][07] := "02"
	//Avalio se h� regra cadastrada, caso n�o haja, bloqueia o pedido
	ElseIf Empty(cCodReg) .AND. Len(aProdDesc) == 1
		aProdDesc[01][07] := "02" //Cliente sem amarra��o a regra de neg�cios
		lRetorno          := lContVerba := .F.
	Else
		If !(lRetorno         := lContVerba := AvDesCab()) //Avalio o desconto do cabe�alho
			_cMsgIte          := _cMsgDCab
			aProdDesc[01][07] := "02"
	//IN�CIO DO TRECHO COM MAIOR RISCO/INCID�NCIA DE LENTID�O (Sub-Rotina AvDesIte)
		ElseIf !(lRetorno := lContVerba := AvDesIte(aProdDesc[01][02],aProdDesc[01][01])) .AND. Len(aProdDesc)==1 //Avalio o desconto dos itens
	//FIM DO DO TRECHO COM MAIOR RISCO/INCID�NCIA DE LENTID�O
			If Empty(_cMsgCab)
				//Monta o cabe�alho das observa��es de bloqueio
				_cMsgCab	:= Replicate("-",40)									+ _lEnt
				_cMsgCab	+= "C�digo da tabela de pre�o: " + Alltrim(cTabPreco)	+ _lEnt
				_cMsgCab	+= Replicate("-",40)					   				+ _lEnt
			EndIf
			//Monta a observa��o de bloqueio do item
			_cMsgIte	:= "C�digo do produto:  "					+ Alltrim(aProdDesc[01][01])      													+ _lEnt
			_cMsgIte	+= "Item do pedido de venda: "				+ Alltrim(aProdDesc[01][02])      													+ _lEnt
			_cMsgIte	+= "Pre�o de Venda: "						+ AllTrim(Transform(aProdDesc[01][03],PesqPict("SC6","C6_PRUNIT")))					+ _lEnt
			_cMsgIte	+= "Pre�o de Lista: "						+ AllTrim(Transform(aProdDesc[01][04],PesqPict("SC6","C6_PRUNIT")))					+ _lEnt
			_cMsgIte	+= "C�digo da regra: "						+ IIF(!Empty(cCodReg),Alltrim(cCodReg),"Regra n�o encontrada ou fora de vig�ncia")	+ _lEnt
			_cMsgIte	+= "% de desconto do pedido: "				+ Transform(aProdDesc[01][05],PesqPict("SC6","C6_DESCONT")) + "%" 					+ _lEnt
			If !Empty(cCodReg)
				_cCascata := " ("   + AllTrim(Transform(_nDesCond,PesqPict("SC6","C6_DESCONT"))) //Desconto da condi��o de pagamento
				_cCascata += "% + " + AllTrim(Transform(_nDescDiv,PesqPict("SC6","C6_DESCONT"))) //Desconto pelo tipo de divis�o do pedido
				_cCascata += "% + " + AllTrim(Transform(_nDesItem,PesqPict("SC6","C6_DESCONT"))) //Desconto pelo item (regra)
				_cCascata += "%"    + ")"
				_cMsgIte  += "% de desconto permitido pela regra: " 	+ Transform(_nDesPerm,PesqPict("SC6","C6_DESCONT")) + "%" + _cCascata	+ _lEnt
			EndIf
			_cMsgIte	+= "% de desconto do Promocional: "				+ Transform(_nDesBase,PesqPict("SC6","C6_DESCONT")) + "%" 						+ _lEnt
			_cMsgIte	+= "% de desconto ponderado permitido pela regra + Promocional: "	+ Transform(_nDesProm,PesqPict("SC6","C6_DESCONT")) + "%" 				+ _lEnt
			_cMsgIte	+= "C�digo do bloqueio: "                 	+ Alltrim(aProdDesc[01][07])      													+ _lEnt
		EndIf
	EndIf
	If _lBlRes
		lRetorno := lContVerba := .T.
		_cMsgIte := "*** PEDIDO COM ELIMINA��O DE RES�DUO, N�O AVALIADO! ***" + _lEnt + _cMsgIte + _lEnt
	EndIf

	RestArea(_aSavSUA)
	RestArea(_aSavSC5)
	RestArea(_aSavArea)

	aRetPE := {aProdDesc,lContinua,lRetorno,lContVerba,lExecao}

	//Verifico se o registro foi bloqueado para grava��o
	If _cAliSC5 == "SC5"
		If (SC5->(DBRLock())) .AND. !SC5->(EOF())
			dbSelectArea("SC5")
			/*
			//Por conta de problema t�cnico com a grava��o cumulativa
			//do campo memo, foi necess�rio ir concatenando as mensagens
			//em arquivo ".txt" e o conte�do deste � copiado para o campo memo
			//no final do processo.
			*/
			//Caso exista algum arquivo de observa��es antigo para o pedido em quest�o o mesmo � deletado antes de iniciar a nova grava��o
			If (Len(aProdDesc)>1 .And. Len(aCols)>1) .Or. (Len(aProdDesc)>1 .And. Len(aCols)==1) .Or. (Len(aProdDesc)==1 .And. Len(aCols)==1)
				If File(_cCamArq+_cArquivo)
					fErase(_cCamArq+_cArquivo)
				EndIf
			EndIf
			If (Len(aProdDesc)>1 .And. Len(aCols)>1) .Or. (Len(aProdDesc)>1 .And. Len(aCols)==1) .Or. (Len(aProdDesc)==1 .And. Empty(_cMsgIte))
				If _lC5_CONTOBS .AND. _lC5_OBSBLQ .AND. SC5->C5_OBSBLQ <> fLerTxt(_cArquivo)
					M->C5_CONTOBS := SC5->C5_CONTOBS := ""
				EndIf
				//Caso n�o haja bloqueio, limpo o campo de observa��es
				If _lC5_CONTOBS .AND. Empty(_cContObs) .And. Empty(fLerTxt(_cArquivo)) //Verifico se esta � a primeira observa��o do pedido
					M->C5_CONTOBS := SC5->C5_CONTOBS := ""
				elseif _lC5_CONTOBS .AND. _lC5_OBSBLQ
					M->C5_CONTOBS := SC5->C5_CONTOBS := "S"
					M->C5_OBSBLQ  := SC5->C5_OBSBLQ	 := fLerTxt(_cArquivo)
				EndIf
			ElseIf !Empty(_cMsgIte)  .AND. !Empty(aProdDesc[1][7])
				//Trecho inserido por J�lio Soares para atualiza��o da Tabela SUA
				//1 - Bloqueio de Regra
				//2 - Bloqueio de Cr�dito
				//3 - Bloqueio de Estoque
				//4 - Pedido em Separa��o
				//5 - Pedido expedido
				_cLogx := "Pedido de Vendas Bloqueado por Regras de Neg�cios."
				dbSelectArea("SUA")
				SUA->(dbOrderNickName("UA_NUMSC5"))
				If SUA->(MsSeek(xFilial("SUA") + SC5->C5_NUM,.T.,.F.))
					if _lUA_LOGSTAT
						_cLog   := Alltrim(SUA->UA_LOGSTAT)
					else
						_cLog   := ""
					endif
					_cNumAten   := SUA->UA_NUM
					while !RecLock("SUA",.F.) ; enddo
						if _lUA_STATSC9
							SUA->UA_STATSC9 := "01"
						endif
						If _lUA_LOGSTAT
							SUA->UA_LOGSTAT := (_cLog) + _lEnt + Replicate("-",50) + _lEnt + DTOC(Date()) + " - " + Time() + " - " + ;
							AllTrim(UsrRetName(__cUserId)) + _lEnt + _cLogx
						EndIf
					SUA->(MsUnLock())
				Else
					_cNumAten := ""
				EndIf
				dbSelectArea("SC5")
				SC5->(dbSetOrder(1))
				If SC5->(MsSeek(xFilial("SC5") + M->C5_NUM,.T.,.F.))
					If _lC5_LOGSTAT
						_cLog := Alltrim(SC5->C5_LOGSTAT)
						while !RecLock("SC5",.F.) ; enddo
							SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
												UsrRetName(__cUserId) + _lEnt + _cLogx
							SC5->C5_BLQ := aProdDesc[1][7]
						SC5->(MsUnLock())
					EndIf
				EndIf
				//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
	           	If ExistBlock("RFATL001")
					If !File(_cLock)
						U_RFATL001(	SC5->C5_NUM,;
									_cNumAten  ,;
									_cLogx     ,;
									_cRotina    )
						MemoWrite(_cLock,"")
					EndIf
				EndIf
				// Fim do trecho adicionado.
				//Verifico se o pedido foi gerado a partir do Call Center ou diretamente pelo Faturamento
				If .T.	//Empty(_cNumAten)
					If Empty(_cContObs) .And. Empty(fLerTxt(_cArquivo)) //Verifico se esta � a primeira observa��o do pedido
						fGravaTxt(_cMsgCab + _cMsgIte)
						if _lC5_CONTOBS .AND. _lC5_OBSBLQ
							while !RecLock("SC5",.F.) ; enddo
								M->C5_CONTOBS := SC5->C5_CONTOBS := "S"
								//M->C5_OBSBLQ  := SC5->C5_OBSBLQ	 := CriaVar("C5_OBSBLQ")
								M->C5_OBSBLQ  := SC5->C5_OBSBLQ	 := fLerTxt(_cArquivo)
							SC5->(MsUnLock())
						endif
					ElseIf !(_cMsgDCab $ fLerTxt(_cArquivo))
						_cAux := fLerTxt(_cArquivo)
						If !(("Item do pedido de venda: " + Alltrim(aProdDesc[01][02])) $ _cAux) .And. !(_cBlqFina $ _cAux)
							fGravaTxt(_lEnt + _cMsgIte)
							//In�cio- Trecho alterado por Arthur Silva em 26/08/2015
							if _lC5_CONTOBS .AND. _lC5_OBSBLQ
								while !RecLock("SC5",.F.) ; enddo
									M->C5_CONTOBS := SC5->C5_CONTOBS := "S"
									M->C5_OBSBLQ  := SC5->C5_OBSBLQ	 := fLerTxt(_cArquivo)
								SC5->(MsUnLock())
							endif
							//Final - Trecho alterado por Arthur Silva em 26/08/2015
						EndIf		
					EndIf			
				Elseif _lUA_OBSBLQ
					while !RecLock("SUA",.F.) ; enddo
						If Empty(_cContObs) //Verifico se esta � a primeira observa��o do pedido
							M->UA_OBSBLQ  := SUA->UA_OBSBLQ	 := _cMsgCab + _cMsgIte
						ElseIf !(_cMsgDCab $ SUA->UA_OBSBLQ) .And. !(_cBlqFina $ _cAux)
							_cConteudo	  := AllTrim(SUA->UA_OBSBLQ) + _lEnt + _cMsgIte
							M->UA_OBSBLQ  := SUA->UA_OBSBLQ	 := AllTrim(_cConteudo)
						EndIf
					SUA->(MsUnLock())
					if _lC5_CONTOBS .AND. _lC5_OBSBLQ
						while !RecLock("SC5",.F.) ; enddo
							M->C5_CONTOBS := SC5->C5_CONTOBS  := "S"
							//M->C5_OBSBLQ  := SC5->C5_OBSBLQ   := SUA->UA_OBSBLQ
							M->C5_OBSBLQ  := SC5->C5_OBSBLQ   :=AllTrim(_cConteudo)
						SC5->(MsUnLock())
					endif
				EndIf
				dbSelectArea("SUA")
				SUA->(dbOrderNickName("UA_NUMSC5"))
				If SUA->(MsSeek(xFilial("SUA")+SC5->C5_NUM,.T.,.F.)) .AND. _lUA_OBSBLQ
					while !RecLock("SUA",.F.) ; enddo
						SUA->UA_OBSBLQ += fLerTxt(_cArquivo)
					SUA->(MsUnLock())
				EndIf
			Else
				_cLogx := "PEDIDO DE VENDA SEM BLOQUEIO DE REGRAS DE NEG�CIO."
				If _lC5_LOGSTAT
					_cLog           := AllTrim(SC5->C5_LOGSTAT)
					while !RecLock("SC5",.F.) ; enddo
						SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
											UsrRetName(__cUserId) + _lEnt + _cLogx
					SC5->(MsUnLock())
				EndIf
				//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
				If ExistBlock("RFATL001")
					U_RFATL001(	SC5->C5_NUM,;
								_cNumAten  ,;
								_cLogx     ,;
								_cRotina    )
				EndIf
			EndIf
		EndIf
	Else
		//Por conta de problema t�cnico com a grava��o cumulativa
		//do campo memo, foi necess�rio ir concatenando as mensagens
		//em arquivo ".txt" e o conte�do deste � copiado para o campo memo
		//no final do processo.
		//Caso exista algum arquivo de observa��es antigo para o pedido em quest�o o mesmo � deletado antes de iniciar a nova grava��o
		If (Len(aProdDesc)>1 .And. Len(aCols)>1) .Or. (Len(aProdDesc)>1 .And. Len(aCols)==1) .Or. (Len(aProdDesc)==1 .And. Len(aCols)==1)
			If File(_cCamArq+_cArquivo)
				fErase(_cCamArq+_cArquivo)
			EndIf
		EndIf
		If (Len(aProdDesc)>1 .And. Len(aCols)>1) .Or. (Len(aProdDesc)>1 .And. Len(aCols)==1) .Or. (Len(aProdDesc)==1 .And. Empty(_cMsgIte))
			If _lC5_OBSBLQ .AND. &(_cAliSC5+"->C5_OBSBLQ") <> fLerTxt(_cArquivo)
				&(_cAliSC5+"->C5_OBSBLQ") := ""
			EndIf
			//Caso n�o haja bloqueio, limpo o campo de observa��es
			If _lC5_CONTOBS .AND. Empty(_cContObs) .And. Empty(fLerTxt(_cArquivo)) //Verifico se esta � a primeira observa��o do pedido
				&(_cAliSC5+"->C5_CONTOBS") := ""
			Elseif _lC5_CONTOBS .AND. _lC5_OBSBLQ
				&(_cAliSC5+"->C5_CONTOBS") := "S"
				&(_cAliSC5+"->C5_OBSBLQ")  := fLerTxt(_cArquivo)
			EndIf
		ElseIf !Empty(_cMsgIte) .AND. !Empty(aProdDesc[1][7])
			//Trecho inserido por J�lio Soares para atualiza��o da Tabela SUA
			//1 - Bloqueio de Regra
			//2 - Bloqueio de Cr�dito
			//3 - Bloqueio de Estoque
			//4 - Pedido em Separa��o
			//5 - Pedido expedido
			_cLogx := "Pedido de Vendas Bloqueado por Regras de Neg�cios."
			dbSelectArea("SUA")
			SUA->(dbOrderNickName("UA_NUMSC5"))
			If SUA->(MsSeek(xFilial("SUA") + &(_cAliSC5+"->C5_NUM"),.T.,.F.))
				if _lUA_LOGSTAT
					_cLog	  := Alltrim(SUA->UA_LOGSTAT)
				endif
				_cNumAten := SUA->UA_NUM
				while !RecLock("SUA",.F.) ; enddo
					if _lUA_STATSC9
						SUA->UA_STATSC9 := "01"
					endif
					If _lUA_LOGSTAT
						SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",50) + _lEnt + DTOC(Date()) + " - " + Time() + " - " + ;
											AllTrim(UsrRetName(__cUserId)) + _lEnt + _cLogx
					EndIf
				SUA->(MsUnlock())
			Else
				_cNumAten := ""
			EndIf
			If _lC5_LOGSTAT
				&(_cAliSC5+"->C5_LOGSTAT") := (_cLog) + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
											UsrRetName(__cUserId) + _lEnt + _cLogx
			EndIf
			//Fim do trecho adicionado.
			//Verifico se o pedido foi gerado a partir do Call Center ou diretamente pelo Faturamento
			If .T.		//Empty(_cNumAten)
				If Empty(_cContObs) .And. Empty(fLerTxt(_cArquivo)) //Verifico se esta � a primeira observa��o do pedido
					fGravaTxt(_cMsgCab + _cMsgIte)
					if _lC5_CONTOBS .AND. _lC5_OBSBLQ
						&(_cAliSC5+"->C5_CONTOBS") := "S"
						&(_cAliSC5+"->C5_OBSBLQ")  := fLerTxt(_cArquivo)
					endif
				ElseIf !(_cMsgDCab $ fLerTxt(_cArquivo))
					_cAux := fLerTxt(_cArquivo)
					If !(("Item do pedido de venda: " + Alltrim(aProdDesc[01][02])) $ _cAux) .And. !(_cBlqFina $ _cAux)
						fGravaTxt(_lEnt + _cMsgIte)
						//In�cio- Trecho alterado por Arthur Silva em 26/08/2015
						if _lC5_CONTOBS .AND. _lC5_OBSBLQ
							&(_cAliSC5+"->C5_CONTOBS") := "S"
							&(_cAliSC5+"->C5_OBSBLQ")  := fLerTxt(_cArquivo)
						endif
						//Final - Trecho alterado por Arthur Silva em 26/08/2015
					EndIf		
				EndIf			
			Else
				if _lUA_OBSBLQ
					while !RecLock("SUA",.F.) ; enddo
						If Empty(_cContObs) //Verifico se esta � a primeira observa��o do pedido
							M->UA_OBSBLQ  := SUA->UA_OBSBLQ	 := _cMsgCab + _cMsgIte
						ElseIf !(_cMsgDCab $ SUA->UA_OBSBLQ) .AND. !(_cBlqFina $ _cAux)
							_cConteudo	  := AllTrim(SUA->UA_OBSBLQ) + _lEnt + _cMsgIte
							M->UA_OBSBLQ  := SUA->UA_OBSBLQ	 := AllTrim(_cConteudo)
						EndIf
					SUA->(MsUnLock())
				endif
				if _lC5_CONTOBS .AND. _lC5_OBSBLQ
					&(_cAliSC5+"->C5_CONTOBS") := "S"
					&(_cAliSC5+"->C5_OBSBLQ")  := SUA->UA_OBSBLQ
				endif
			EndIf
			dbSelectArea("SUA")
			SUA->(dbOrderNickName("UA_NUMSC5"))
			If SUA->(dbSeek(xFilial("SUA")+&(_cAliSC5+"->C5_NUM"))) .AND. _lUA_OBSBLQ
				while !RecLock("SUA",.F.) ; enddo
					SUA->UA_OBSBLQ += fLerTxt(_cArquivo)
				SUA->(MsUnLock())
			EndIf
		Else
			_cLogx := "Pedido de Vendas sem bloqueio de regras de neg�cios."
			If _lC5_LOGSTAT
				_cLog                      := AllTrim(&(_cAliSC5+"->C5_LOGSTAT"))
				&(_cAliSC5+"->C5_LOGSTAT") := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
												UsrRetName(__cUserId) + _lEnt + _cLogx
			EndIf
		EndIf
		//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
		If ExistBlock("RFATL001")
			U_RFATL001(	&(_cAliSC5+"->C5_NUM"),;
						SUA->UA_NUM           ,;
						_cLogx                ,;
						_cRotina               )
		EndIf
	EndIf
	SC5->(MsUnLock())
return aRetPE
/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  ?AvDesCab  �Autor  ?Adriano Leonardo   ?Data ? 12/02/14       ��?
���������������������������������������������������������������������������ͱ�
���Desc.     ?Fun��o para validar se o desconto do cabe�alho ?maior que o  ��?
��?         ?permitido pela condi��o de pagamento.                         ��?
��������������������������������������������������������������������������͹��
���Uso       ?Programa Principal                                           ��?
���������������������������������������������������������������������������ͱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
static function AvDesCab()
	//Local _aSavAr      := GetArea()
	Local _aSavSE4     := SE4->(GetArea())
	Local _lE4_DESCMAX := SE4->(FieldPos("E4_DESCMAX"))>0
	Local _lC5_TPDIV   := SC5->(FieldPos("C5_TPDIV"  ))>0
	Local _lRetCab     := .T.	//Retorno .F. bloqueia o pedido por regra
	dbSelectArea("SE4")
	SE4->(dbSetOrder(1))
	If SE4->(MsSeek(xFilial("SE4")+cCondPg,.T.,.F.))
		If _lE4_DESCMAX
			_nDescMax := SE4->E4_DESCMAX
			_nDesCond := _nDescMax
		EndIf
	EndIf
	_nAux	  := 100
	//Varre o array com os campos de desconto para calcular o desconto em cascata
	_nCont    := 1
	_xTipDesc := 'Type(_cAliSC5+"->C5_DESC" + AllTrim(Str(_nCont)))'
	While &_xTipDesc <> "U"
		_cCpoDesc := _cAliSC5+"->C5_DESC" + AllTrim(Str(_nCont))
		If &_cCpoDesc > 0
			_nAux := _nAux - (_nAux * ((&_cCpoDesc)/100))
	 	EndIf
	 	_nFatCabe := (100 - _nAux)
		_nCont++
	EndDo
	//In�cio - Trecho adicionado por Adriano Leonardo - 12/09/2014
	//Selecionando o percentual de desconto por divis�o do cadastro do cliente, se o pedido possuir divis�o.
	//Inclu�da valida��o de exist�ncia do campo de mem�ria, para uso em rotinas autom�ticas - Anderson C. P. Coelho - 08/10/2014
	_nDescDiv := 0
	If _lC5_TPDIV .AND. Type(_cAliSC5+"->C5_TPDIV")<>"U"
		If !&(_cAliSC5+"->C5_TIPO")$"D/B" .AND. &(_cAliSC5+"->C5_TPDIV") <> '4' //100%
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			If SA1->(MsSeek(xFilial("SA1") + &(_cAliSC5+"->C5_CLIENTE") + &(_cAliSC5+"->C5_LOJACLI"),.T.,.F.))
				_nDescDiv := SA1->A1_DESCDIV
			EndIf
		EndIf
	EndIf
	//Final  - Trecho adicionado por Adriano Leonardo - 12/09/2014
	//Calculo o fator de desconto m�ximo do cabe�alho avaliando o desconto da condi��o de pagamento e do tipo de divis�o do pedido
	_nDescMax := 100-(100*(_nDescMax/100))
	_nDescMax := _nDescMax-(_nDescMax*(_nDescDiv/100))
	_nDescMax := 100 - _nDescMax
	If _nFatCabe > _nDescMax
		_cMsgDCab := "Desconto do cabe�alho superior ao permitido pela condi��o de pagamento" 	+ _lEnt
		_cMsgDCab += "% Desconto do cabe�alho do pedido: " 										+ AllTrim(Transform(_nFatCabe,PesqPict("SC6","C6_DESCONT"))) + "%" + _lEnt
		_cMsgDCab += "% Desconto m�ximo permitido pela condi��o de pagamento: " 				+ AllTrim(Transform(_nDescMax,PesqPict("SC6","C6_DESCONT"))) + "%" + " (" + AllTrim(Str(_nDesCond)) + "% + " + AllTrim(Str(_nDescDiv)) + "%)"
		_lRetCab  := .F.
	EndIf
	RestArea(_aSavSE4)
return(_lRetCab)
/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  ?AvDesIte  �Autor  ?Adriano Leonardo   ?Data ? 12/02/14   ��?
���������������������������������������������������������������������������ͱ�
���Desc.     ?Fun��o para validar se o desconto do cabe�alho ?maior que o��?
��?         ?permitido pela condi��o de pagamento.                       ��?
��������������������������������������������������������������������������͹��
���Uso       ?Programa Principal                                          ��?
���������������������������������������������������������������������������ͱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
static function AvDesIte(_cItem,_cProd)
	Local _aSavAr	  := GetArea()
	Local _lRet		  := .T.	//Retorno .F. bloqueia o pedido por regra
//	Local _cCondPg	  := ""
	Local _cQRYTMP    := GetNextAlias()
	Local _nLinha     := 0
	Local _nTamDesc   := TamSx3("ACN_DESCON")[02]
	Local _nPercVar	  := SuperGetMV("MV_XPERCVAR",,0.22)

	Private _cLog	  := ""
	Private _nQuant   := 0
//	Private _nDescont := 0
	Private _cProduto := _cProd

	_nLinha := aScan(aCols,{|x|x[_nPosIte]==_cItem .AND. x[_nPosPro]==_cProd}) //Localizo a linha do aCols com o produto a ser processado
	If _nLinha == 0 .OR. _nPosQtd == 0
		RestArea(_aSavAr)
		return(_lRet)
	EndIf
	_nQuant	:= aCols[_nLinha,_nPosQtd]

	//Query para selecionar o desconto permitido do produto, priorizando sempre por:
	//	- Cliente
	//	- Grupo de clientes
	//	- Cliente e grupo em branco
	//	- Produto
	//	- Grupo de produtos
	//Obs.: Retorna no m�ximo um registro

	//Consulta utilizada para selecionar a regra a ser avaliada no pedido
	//IMPORTANTE: Ao alterar essa query, atentar para que as mesmas altera��es sejam feitas na query do fonte RTMKE006
	if select(_cQRYTMP) > 0
		(_cQRYTMP)->(dbCloseArea())
	endif
	BeginSql Alias _cQRYTMP
		SELECT * 
		FROM ( 
		//AVALIO SE H� REGRA POR CLIENTE - NIVEL 1
			SELECT 1 AS [NIVEL], ACN_CODREG, ACN_CODPRO, ACN_DESCON, ACN_QUANTI, ACN_PROMOC 
			FROM %table:ACN% ACN  (NOLOCK)
				INNER JOIN %table:ACS% ACS  (NOLOCK)
					ON  ACS.ACS_FILIAL  = %xFilial:ACS% 
		 			AND ACS.ACS_CODCLI  = %Exp:&(_cAliSC5+"->C5_CLIENTE")% 
		 			AND ACS.ACS_LOJA    = %Exp:&(_cAliSC5+"->C5_LOJACLI")% 
					AND (ACS.ACS_DATATE = %Exp:''% OR ACS.ACS_DATDE  <= %Exp:DTOS(dDataBase)%) 
					AND (ACS.ACS_DATATE = %Exp:''% OR ACS.ACS_DATATE >= %Exp:DTOS(dDataBase)%) 
					AND ACS.ACS_CODREG  = ACN.ACN_CODREG 
		 			AND ACS.%NotDel% 
				INNER JOIN %table:SB1% SB1 (NOLOCK)
		 			 ON SB1.B1_FILIAL   = %xFilial:SB1%
		 			AND SB1.B1_COD      = %Exp:_cProduto% 
		 			AND (SB1.B1_COD     = ACN.ACN_CODPRO OR (SB1.B1_GRUPO <> %Exp:''% AND SB1.B1_GRUPO = ACN.ACN_GRPPRO)) 
		 			AND SB1.%NotDel% 
		 	WHERE ACN.ACN_FILIAL   = %xFilial:ACN%
			  AND (ACN.ACN_DATINI  = %Exp:''% OR ACN.ACN_DATINI <= %Exp:DTOS(dDataBase)%) 
			  AND (ACN.ACN_DATFIM  = %Exp:''% OR ACN.ACN_DATFIM >= %Exp:DTOS(dDataBase)%) 
		 	  AND ACN.ACN_QUANTI  >= %Exp:_nQuant% 
			  AND ACN.ACN_QUANTI   = (SELECT MIN(AUX.ACN_QUANTI) 
			                          FROM %table:ACN% AUX 
			                          WHERE AUX.ACN_FILIAL  = %xFilial:ACN% 
			                            AND AUX.ACN_QUANTI >= %Exp:_nQuant%
			                            AND AUX.ACN_CODREG  = ACN.ACN_CODREG 
			                            AND (AUX.ACN_CODPRO = ACN.ACN_CODPRO AND AUX.ACN_GRPPRO = ACN.ACN_GRPPRO) 
			                            AND AUX.%NotDel% 
			                         ) 
			  AND ACN.%NotDel% 
		UNION ALL /*
		//AVALIO SE H� REGRA POR GRUPO - NIVEL 2
			SELECT 2 AS [NIVEL], ACN_CODREG, ACN_CODPRO, ACN_DESCON, ACN_QUANTI, ACN_PROMOC 
			FROM %table:ACN% ACN (NOLOCK)
				INNER JOIN %table:ACS% ACS (NOLOCK)
					ON  ACS.ACS_FILIAL  = %xFilial:ACS% 
					AND (ACS.ACS_DATATE = %Exp:''% OR ACS.ACS_DATDE  <= %Exp:DTOS(dDataBase)%) 
					AND (ACS.ACS_DATATE = %Exp:''% OR ACS.ACS_DATATE >= %Exp:DTOS(dDataBase)%) 
					AND ACS.ACS_CODREG  = ACN.ACN_CODREG 
		 			AND ACS.%NotDel% 
				INNER JOIN %table:SB1% SB1 (NOLOCK)
		 			 ON SB1.B1_FILIAL   = %xFilial:SB1% 
		 			AND SB1.B1_COD      = %Exp:_cProduto% 
		 			AND (SB1.B1_COD     = ACN.ACN_CODPRO OR (SB1.B1_GRUPO <> '' AND SB1.B1_GRUPO = ACN.ACN_GRPPRO)) 
		 			AND SB1.%NotDel% 
				INNER JOIN %table:SA1% SA1 (NOLOCK)
		 			ON  SA1.A1_FILIAL  = %xFilial:SA1%
		 			AND SA1.A1_COD     = %Exp:&(_cAliSC5+"->C5_CLIENTE")%
		 			AND SA1.A1_LOJA    = %Exp:&(_cAliSC5+"->C5_LOJACLI")%
		 			AND SA1.A1_GRPVEN <> %Exp:''%
		 			AND SA1.A1_GRPVEN  = ACS.ACS_GRPVEN 
		 			AND SA1.%NotDel% 
		 	WHERE ACN.ACN_FILIAL   = %xFilial:ACN% 
			  AND (ACN.ACN_DATINI  = %Exp:''% OR ACN.ACN_DATINI <= %Exp:DTOS(dDataBase)%) 
			  AND (ACN.ACN_DATFIM  = %Exp:''% OR ACN.ACN_DATFIM >= %Exp:DTOS(dDataBase)%) 
		 	  AND ACN.ACN_QUANTI  >= %Exp:_nQuant%
			  AND ACN.ACN_QUANTI   = (SELECT MIN(AUX.ACN_QUANTI) 
			                          FROM %table:ACN% AUX 
			                          WHERE AUX.ACN_FILIAL  = %xFilial:ACN% 
			                            AND AUX.ACN_QUANTI >= %Exp:_nQuant%
			                            AND AUX.ACN_CODREG  = ACN.ACN_CODREG 
			                            AND (AUX.ACN_CODPRO = ACN.ACN_CODPRO AND AUX.ACN_GRPPRO = ACN.ACN_GRPPRO) 
			                            AND AUX.%NotDel% 
			                         )
			  AND ACN.%NotDel% 
		UNION ALL */
		//AVALIO SE H� REGRA PROMOCIONAL POR QUANTIDADE - NIVEL 3
			SELECT 3 AS [NIVEL], ACN_CODREG, ACN_CODPRO, ACN_DESCON, ACN_QUANTI, ACN_PROMOC 
			FROM %table:ACN% ACN (NOLOCK)
				INNER JOIN %table:ACS% ACS  (NOLOCK)
					ON  ACS.ACS_FILIAL  = %xFilial:ACS% 
					AND (ACS.ACS_DATATE = %Exp:''% OR ACS.ACS_DATDE  <= %Exp:DTOS(dDataBase)%) 
					AND (ACS.ACS_DATATE = %Exp:''% OR ACS.ACS_DATATE >= %Exp:DTOS(dDataBase)%) 
		 			AND ACS.ACS_CODCLI  = %Exp:''% 
		 			AND ACS.ACS_GRPVEN  = %Exp:''% 
					AND ACS.ACS_CODREG  = ACN.ACN_CODREG 
					AND ACS.%NotDel% 
				INNER JOIN %table:SB1% SB1  (NOLOCK)
		 			 ON SB1.B1_FILIAL   = %xFilial:SB1% 
		 			AND SB1.B1_COD      = %Exp:_cProduto% 
		 			AND (SB1.B1_COD     = ACN.ACN_CODPRO OR (SB1.B1_GRUPO <> '' AND SB1.B1_GRUPO = ACN.ACN_GRPPRO)) 
		 			AND SB1.%NotDel% 
		 	WHERE ACN.ACN_FILIAL   = %xFilial:ACN% 
			  AND (ACN.ACN_DATINI  = %Exp:''% OR ACN.ACN_DATINI <= %Exp:DTOS(dDataBase)%) 
			  AND (ACN.ACN_DATFIM  = %Exp:''% OR ACN.ACN_DATFIM >= %Exp:DTOS(dDataBase)%) 
		 	  AND ACN.ACN_QUANTI  >= %Exp:_nQuant%
			  AND ACN.ACN_DESCON  <> 0
			  AND ACN.ACN_PROMOC  <> "1"
			  AND ACN.ACN_QUANTI   = (SELECT MIN(AUX.ACN_QUANTI) 
			                          FROM %table:ACN% AUX 
			                          WHERE AUX.ACN_FILIAL  = %xFilial:ACN% 
			                            AND AUX.ACN_QUANTI >= %Exp:_nQuant%
			                            AND AUX.ACN_CODREG  = ACN.ACN_CODREG 
			                            AND (AUX.ACN_CODPRO = ACN.ACN_CODPRO AND AUX.ACN_GRPPRO = ACN.ACN_GRPPRO) 
			                            AND AUX.%NotDel% 
			                         ) 
			  AND ACN.%NotDel%
		UNION ALL 
		//AVALIO SE H� REGRA PROMOCIONAL TEMPORARIA - NIVEL 4
			SELECT 4 AS [NIVEL], ACN_CODREG, ACN_CODPRO, ACN_DESCON, ACN_QUANTI, ACN_PROMOC 
			FROM %table:ACN% ACN (NOLOCK)
				INNER JOIN %table:ACS% ACS  (NOLOCK)
					ON  ACS.ACS_FILIAL  = %xFilial:ACS% 
					AND (ACS.ACS_DATATE = %Exp:''% OR ACS.ACS_DATDE  <= %Exp:DTOS(dDataBase)%) 
					AND (ACS.ACS_DATATE = %Exp:''% OR ACS.ACS_DATATE >= %Exp:DTOS(dDataBase)%) 
		 			AND ACS.ACS_CODCLI  = %Exp:''% 
		 			AND ACS.ACS_GRPVEN  = %Exp:''% 
					AND ACS.ACS_CODREG  = ACN.ACN_CODREG 
					AND ACS.%NotDel% 
				INNER JOIN %table:SB1% SB1  (NOLOCK)
		 			 ON SB1.B1_FILIAL   = %xFilial:SB1% 
		 			AND SB1.B1_COD      = %Exp:_cProduto% 
		 			AND (SB1.B1_COD     = ACN.ACN_CODPRO OR (SB1.B1_GRUPO <> '' AND SB1.B1_GRUPO = ACN.ACN_GRPPRO)) 
		 			AND SB1.%NotDel% 
		 	WHERE ACN.ACN_FILIAL   = %xFilial:ACN% 
			  AND (ACN.ACN_DATINI  = %Exp:''% OR ACN.ACN_DATINI <= %Exp:DTOS(dDataBase)%) 
			  AND (ACN.ACN_DATFIM  = %Exp:''% OR ACN.ACN_DATFIM >= %Exp:DTOS(dDataBase)%) 
		 	  AND ACN.ACN_QUANTI  >= %Exp:_nQuant%
			  AND ACN.ACN_DESCON  <> 0
			  AND ACN.ACN_PROMOC  = "1"
			  AND ACN.ACN_QUANTI   = (SELECT MIN(AUX.ACN_QUANTI) 
			                          FROM %table:ACN% AUX 
			                          WHERE AUX.ACN_FILIAL  = %xFilial:ACN% 
			                            AND AUX.ACN_QUANTI >= %Exp:_nQuant%
			                            AND AUX.ACN_CODREG  = ACN.ACN_CODREG 
			                            AND (AUX.ACN_CODPRO = ACN.ACN_CODPRO AND AUX.ACN_GRPPRO = ACN.ACN_GRPPRO) 
			                            AND AUX.%NotDel% 
			                         ) 
			  AND ACN.%NotDel%
		) REGRAS 
		ORDER BY REGRAS.NIVEL,REGRAS.ACN_PROMOC
	EndSql

	//Gerando o arquivo de log
	MemoWrite("c:\relato\query_regra.txt", GetLastQuery()[02])
	dbSelectArea(_cQRYTMP)
	If (_cQRYTMP)->(EOF())
		cCodReg				:= ""
		aProdDesc[01][06] 	:= 0 //Regra n�o encontrada
		aProdDesc[01][07]	:= "02"
	Else
		If (_cQRYTMP)->NIVEL <> 4
		//cCodReg		:= (_cQRYTMP)->ACN_CODREG
		_nDescAux := Round((_cQRYTMP)->ACN_DESCON,_nTamDesc) //Desconto permitido selecionado
		EndiF
	EndIf

	While (_cQRYTMP)->(!EOF())
	If (_cQRYTMP)->NIVEL == 4 .and. (_cQRYTMP)->ACN_PROMOC=='1'
			_nDesBase	:= Round((_cQRYTMP)->ACN_DESCON,_nTamDesc) //Desconto promocional somado ao desconto por regra de cliente
			(_cQRYTMP)->(dbSkip())
		EndIf
		//(_cQRYTMP)->(dbSkip())

		If (_cQRYTMP)->NIVEL == 3 .and. (_cQRYTMP)->ACN_PROMOC=='2'
			_nDescAux	:= Round((_cQRYTMP)->ACN_DESCON,_nTamDesc) //Desconto promocional somado ao desconto por regra de cliente
			(_cQRYTMP)->(dbSkip())
		EndIf
	
	//While (_cQRYTMP)->(!EOF())
		If (Round((_cQRYTMP)->ACN_DESCON,_nTamDesc) > _nDescAux  .and.  (_cQRYTMP)->NIVEL <> 4 ) .and. ((_cQRYTMP)->ACN_PROMOC=='1'.and.  (_cQRYTMP)->NIVEL <> 4 )
			cCodReg		:= (_cQRYTMP)->ACN_CODREG
			_nDescAux	:= Round((_cQRYTMP)->ACN_DESCON,_nTamDesc) //Desconto permitido selecionado
			//Verifico se a regra em quest�o foi definida como priorit�ria, se sim, n�o avalio as demais
			If (_cQRYTMP)->ACN_PROMOC=='1'
				Exit
			EndIf
		EndIf
		(_cQRYTMP)->(dbSkip())
	//EndDo
	EndDo
	//Excluo a tabela tempor�ria
	if Select(_cQRYTMP) > 0
		(_cQRYTMP)->(dbCloseArea())
	endif
	If _nDescAux <> 0 
		aProdDesc[01][06] 	:= _nDescAux
		_nDesItem 			:= aProdDesc[01][06]
		_nDesPedi           := aProdDesc[01][05] //Desconto do pedido
		//Calculo o fator de desconto do item considerando o desconto m�ximo da condi��o de pagamento
		_nDesPerm           := 100 - (aProdDesc[01][06])
		_nDesPerm           := _nDesPerm - (_nDesPerm*(_nDescMax/100))
		_nDesPerm           := 100 - _nDesPerm
		//Manipulo o array aProdDesc com os percentuais de desconto do pedido e o permitido
		aProdDesc[01][05]   := Round(_nDesPedi,_nTamDesc)  //Desconto do pedido (item)
		aProdDesc[01][06]   := Round(_nDesPerm,_nTamDesc)  //Desconto permitido (item)
	EndIf
	If !Empty(_nDesBase)
		_nPrMax 		  := Round(aProdDesc[01][04] - (aProdDesc[01][04] * aProdDesc[01][06] / 100),_nTamDesc)
		_nPrPro 		  := Round(_nPrMax - (_nPrMax * _nDesBase /100),_nTamDesc)
		_nDesProm 		  := Round(100-(_nPrPro*100/aProdDesc[01][04]),0)
		aProdDesc[01][06] := Round(_nDesProm,_nTamDesc)
	Endif
	//Certifico que o resultado � positivo
	If aProdDesc[01][05] < 0
		aProdDesc[01][05] := 0
	EndIf
	//Certifico que o resultado � positivo
	If aProdDesc[01][06] < 0
		aProdDesc[01][06] := 0
	EndIf
	//Verifico se o desconto do pedido (item) � maior que o permitido
	If ((NoRound(aProdDesc[01][05],0) > NoRound(aProdDesc[01][06]+_nPercVar,0)) .and. (NoRound(aProdDesc[01][05],0) > NoRound(aProdDesc[01][06]-_nPercVar,0))) .Or. Empty(cCodReg)
		_lRet := .F.
		If !Empty(cCodReg)
			aProdDesc[01][07] := "01" //C�digo do bloqueio
		Else
			aProdDesc[01][07] := "02" //C�digo do bloqueio
		EndIf
	//ElseIf ((NoRound(aProdDesc[01][05],0) < NoRound(aProdDesc[01][06],0)) .and. (NoRound(aProdDesc[01][05],0) < NoRound(aProdDesc[01][06],0)))
	//	aProdDesc[01][07] := "03" //C�digo do bloqueio
	Else
		aProdDesc[01][07] := ""   //C�digo do bloqueio
	EndIf
	RestArea(_aSavAr)
return(_lRet)
/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �fGravaTxt �Autor  ?Adriano Leonardo   ?Data ? 17/02/14    ��?
���������������������������������������������������������������������������ͱ�
���Desc.     ?Fun��o para grava��o cumulativa de arquivo texto, para arma_��?
��?         ?zenar tempor�riamente as observa��es de bloqueio do pedido. ��?
��������������������������������������������������������������������������͹��
���Uso       ?Programa Principal                                          ��?
���������������������������������������������������������������������������ͱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
static function fGravaTxt(cInfo)
	Local _nArq 	:= 0
	Local _lRetGrv	:= .F.
	//Fa�o a confer�ncia para saber se a pasta para grava��o dos arquivos tempor�rios existe, caso contr�rio crio a mesma
	If !ExistDir(_cCamArq)
		_nCriaDir := MakeDir(_cCamArq)
		If _nCriaDir <> 0
			MsgAlert("N�o foi poss�vel criar a pasta " + AllTrim(_cCamArq) + " para grava��o das observa��es, informe ao Administrador do sistema!",_cRotina+"_001")
	  	EndIf
	EndIf
	If File(_cCamArq+_cArquivo)
		//Verifica a exist�ncia do arquivo
		_nArq := fOpen(_cCamArq+_cArquivo, FO_READWRITE + FO_SHARED)
		If _nArq > 0
	 		//Posiciona no final do arquivo
			fSeek(_nArq, 0, FS_END)
		EndIf
	Else
		//Cria o arquivo
		_nArq := fCreate(_cCamArq+_cArquivo)
	EndIf
	If _nArq <= 0
		MsgAlert("Falha na grava��o das observa��es de bloqueio do pedido, informe ao Administrador.",_cRotina + "_002")
		return(_lRetGrv)
	EndIf
	//Grava conte�do no arquivo ".txt"
	fWrite( _nArq, cInfo, Len(cInfo))
	//Fecha o arquivo
	fClose(_nArq)
	_lRetGrv := .T.
return(_lRetGrv)
/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  ?fLerTxt   �Autor  ?Adriano Leonardo   ?Data ? 17/02/14   ��?
���������������������������������������������������������������������������ͱ�
���Desc.     ?Fun��o para retornar o cont�udo de arquivo txt.             ��?
��������������������������������������������������������������������������͹��
���Uso       ?Programa Principal                                           ��?
���������������������������������������������������������������������������ͱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
static function fLerTxt(_cArquivo)
	Local _nArq 	:= 0
	Local _lRetGrv	:= .F.
	Local _cConteud	:= ""
	//Verifica a exist�ncia do arquivo
	If File(_cCamArq+_cArquivo)
		nHdl    := FOpen(_cCamArq + _cArquivo,FO_READWRITE)
		nTamTot := FSeek(nHdl, 0, 2)      // Tamanho total do arquivo em bytes (posicionamento no �ltimo registro do arquivo)
		FSeek(nHdl, 0, 0)                 // Posiciona no in�cio do arquivo
		FRead(nHdl, @_cConteud, nTamTot)  // L� conte�do do arquivo e armazena em vari�vel
		FClose(nHdl)                      // Fecha o arquivo
	EndIf
//Retorna o conte�do do arquivo txt
return(_cConteud)
/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  ?AvGerFin  �Autor  ?Adriano Leonardo   ?Data ? 07/03/14   ��?
���������������������������������������������������������������������������ͱ�
���Desc.     ?Fun��o para retornar se o pedido ser?bloqueado por conter  ��?
��?         ?alguma TES que n�o gere financeiro.                         ��?
��������������������������������������������������������������������������͹��
���Uso       ?Programa Principal                                          ��?
���������������������������������������������������������������������������ͱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
static function AvGerFin()
	Local _aSavSF4  := SF4->(GetArea())
	Local _cSC6TTMP := GetNextAlias()
	Local _lRet 	:= .T. // .F. - Bloqueia o pedido
//	Local _nPosTES  := IIF(Len(aHeader)>0, aScan(aHeader,{|x|Alltrim(x[2])=="C6_TES"}), 0)
	/*
	If _nPosTES > 0
		For _nItem := 1 To Len(aCols)
	    	_cCodTes := aCols[_nItem,_nPosTES]
		    If !aCols[_nItem, Len(aCols[_nItem])] //Certifico que a linha n�o est� deletada
			    dbSelectArea("SF4") //TES
			    SF4->(dbSetOrder(1)) 		//Filial + C�digo
			    If SF4->(MsSeek(xFilial("SF4")+_cCodTes))
			    	If AllTrim(Upper(SF4->F4_DUPLIC))=="N"
			    		_lRet := .F.
			    		Exit
			    	EndIf
			    EndIf
		    EndIf
		Next
	EndIf
	*/
	BeginSql Alias _cSC6TTMP
		SELECT TOP 1 'A' REG			//SELECT COUNT(*) REG
		FROM %table:SC6% SC6 (NOLOCK)
		      INNER JOIN %table:SF4% SF4 (NOLOCK) ON SF4.F4_FILIAL  = %xFilial:SF4%
										AND SF4.F4_DUPLIC  = %Exp:'N'%
										AND SF4.F4_CODIGO  = SC6.C6_TES
										AND SF4.%NotDel%
		WHERE SC6.C6_FILIAL  = %xFilial:SC6%
		  AND SC6.C6_NUM     = %Exp:&(_cAliSC5+"->C5_NUM")%
		  AND SC6.%NotDel%
	EndSql
	dbSelectArea(_cSC6TTMP)
		_lRet := empty((_cSC6TTMP)->REG)			//(_cSC6TTMP)->REG == 0
	(_cSC6TTMP)->(dbCloseArea())
	RestArea(_aSavSF4)
return _lRet
