#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FILEIO.CH"

#DEFINE _lEnt CHR(13) + CHR(10)

User Function FT100RNI()
	// Declaração de variáveis
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

Local aRegras := ObterRegras()

Private _cRotina		:= "FT100RNI"
Private _cAliSC5    := IIF((Type("M->C5_NUM")=="C" .AND. Type("INCLUI")=="L" .AND. INCLUI .AND. M->C5_NUM <> SC5->C5_NUM),"M","SC5")
Private _nPosIte    := aScan(aHeader,{|x|Alltrim(x[2])=="C6_ITEM"   })
Private _nPosPro    := aScan(aHeader,{|x|Alltrim(x[2])=="C6_PRODUTO"})
Private _nPosQtd    := aScan(aHeader,{|x|Alltrim(x[2])=="C6_QTDVEN" })
Private _nPosDesc   := aScan(aHeader,{|x|Alltrim(x[2])=="C6_DESCONT"})
Private _nDescPedido 	:= 0
Private _nDescRegra 	:= 0
Private _nDescMini 		:= 0
Private _nDescPromo		:= 0
Private cCodReg		:= ParamIXB[01] //Código da regra.
Private cTabPreco	:= ParamIXB[02] //Código da tabela de preço.
Private cCondPg		:= ParamIXB[03] //Código da condição de pagamento.
Private cFormPg		:= ParamIXB[04] //Código da forma de pagamento.
Private aProdutos	:= ParamIXB[05] //Array com o código de produto.
Private aProdDesc	:= ParamIXB[06] //Array com detalhe de descontos.Detalhamento em observações.
Private _lBlRes     := .F.			//Pedido com eliminação de resíduo.
Private lContinua	:= .F.			//ParamIXB[07] //Indica se continua pesquisa, default .F. para ganho de desempenho a pesquisa das regras no padrão não serão consideradas.
Private lRetorno	:= ParamIXB[08] //Indica se regra ou exceção.
Private lContVerba	:= ParamIXB[09] //Indica se continua verba
Private lExecao		:= ParamIXB[10] //Indica validação de operações de exceção
Private aRetPE		:= {aProdDesc,lContinua,lRetorno,lContVerba,lExecao}
Private _cBlqFina	:= "O pedido possui TES que não gera financeiro"
Private _cArquivo		:= "Memo_" + AllTrim(&(_cAliSC5+"->C5_NUM")) + ".txt"


If AllTrim(FunName()) == "FATA300"
	Return aRetPE
EndIf
If AllTrim(FunName()) == "TMKA271"
	If _nPosPro == 0 .OR. (Type("M->UA_NUMSC5")<>"U" .AND. Empty(M->UA_NUMSC5) .AND. Empty(SUA->UA_NUMSC5)) .OR. (Type("M->UA_OPER")<>"U" .AND. !AllTrim(M->UA_OPER)$("|"+SuperGetMv("MV_FATOPER",,"01|ZZ|9")+"|"))
		Return aRetPE
	EndIf
EndIf
If Alltrim(FunName()) == "MATA415" .OR. AllTrim(FunName()) == "RTMKI001" .OR. AllTrim(FunName()) == "RPC" //.OR. _cAliSC5 == "M"
	Return aRetPE
EndIf
if type("_cNumAten")=="U"
	private _cNumAten := ""
endif

_cCamArq 	:= "\\192.168.1.212\G$\planilhas12\Log_Regras_Negocios\" //Retorna o caminho do temporário do terminal do usuário
//	_cCamArq 	:= GetTempPath() //Retorna o caminho do temporário do terminal do usuário
_cLock      := _cCamArq+_cRotina+"_"+AllTrim(&(_cAliSC5+"->C5_NUM"))+cNumEmp+__cUserId+"_"+DTOS(Date())+".log"

If _cAliSC5 == "SC5"
	If !SC5->(EOF()) // - CONDIÇÃO INSERIDA EM 23/09/2014 POR JÚLIO SOARES PARA CORRIGIR VALIDAÇÃO
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

//Avalio se todas as TES do pedido geram financeiro, caso contrário o pedido bloqueado
If !(lRetorno         := lContVerba := AvGerFin())
	_cMsgIte          := _cBlqFina
	aProdDesc[01][07] := "02"
//Avalio se há regra cadastrada, caso não haja, bloqueia o pedido
ElseIf Empty(cCodReg) .AND. Len(aProdDesc) == 1
	aProdDesc[01][07] := "02" //Cliente sem amarração a regra de negócios
	lRetorno          := lContVerba := .F.
Else

        _nDesPed 	:= aProdDesc[01][05]
        _nDesRegra 	:= DescCliente(aProdDesc[01][02],aProdDesc[01][01])
		_nDesQuant 	:= DescQuant(aProdDesc[01][02],aProdDesc[01][01])
		_nDesProm  	:= Descpromo(aProdDesc[01][02],aProdDesc[01][01])

		_nDescFator := FatorDesc(IIf(_nDesQuant > 0, _nDesQuant,_nDesRegra),_nDesProm)
        // Verificação de descontos
		If _nDesRegra > 0
        	IF _nDesPed == _nDesRegra
				aProdDesc[01][06] :=_nDesRegra
				aProdDesc[01][07] := "" //Cliente Liberado
				//_cMsgIte := "Liberado regra Cliente: "
			ElseIf _nDesPed == _nDesQuant
				aProdDesc[01][06] := _nDesQuant
				aProdDesc[01][07] := "" //Cliente Liberado
				//_cMsgIte := "Liberado regra Quantidade: "
			ElseIf _nDesPed == _nDescFator
				aProdDesc[01][06] := _nDescFator
				aProdDesc[01][07] := "" //Cliente Liberado
				//_cMsgIte := "Liberado desconto grupo "  
			Else
				aProdDesc[01][07] := "02" //Cliente Bloqueado
				
				_cMsgIte	:= "Código do produto:  "					+ Alltrim(aProdDesc[01][01])      													+ _lEnt
				_cMsgIte	+= "Item do pedido de venda: "				+ Alltrim(aProdDesc[01][02])      													+ _lEnt
				_cMsgIte	+= "Preço de Venda: "						+ AllTrim(Transform(aProdDesc[01][03],PesqPict("SC6","C6_PRUNIT")))					+ _lEnt
				_cMsgIte	+= "Preço de Lista: "						+ AllTrim(Transform(aProdDesc[01][04],PesqPict("SC6","C6_PRUNIT")))					+ _lEnt
				_cMsgIte	+= "Código da regra: "						+ IIF(!Empty(cCodReg),Alltrim(cCodReg),"Regra não encontrada ou fora de vigência")	+ _lEnt
				_cMsgIte	+= "% de desconto do pedido: "				+ Transform(_nDesPed,PesqPict("SC6","C6_DESCONT")) + "%" 					+ _lEnt
				If !Empty(cCodReg)
					_cCascata := " ("   + AllTrim(Transform(_nDesCond,PesqPict("SC6","C6_DESCONT"))) //Desconto da condição de pagamento
					_cCascata += "% + " + AllTrim(Transform(_nDesQuant,PesqPict("SC6","C6_DESCONT"))) //Desconto pelo tipo de divisão do pedido
					_cCascata += "% + " + AllTrim(Transform(_nDesProm,PesqPict("SC6","C6_DESCONT"))) //Desconto pelo item (regra)
					_cCascata += "%"    + ")"
					_cMsgIte  += "% de desconto permitido pela regra: " 	+ Transform(_nDesRegra,PesqPict("SC6","C6_DESCONT")) + "%" + _cCascata	+ _lEnt
				EndIf
				_cMsgIte	+= "% de desconto do Promocional: "				+ Transform(_nDesProm,PesqPict("SC6","C6_DESCONT")) + "%" 						+ _lEnt
				_cMsgIte	+= "% de desconto ponderado permitido pela regra + Promocional: "	+ Transform(_nDescFator,PesqPict("SC6","C6_DESCONT")) + "%" 				+ _lEnt
				_cMsgIte	+= "Código do bloqueio: "                 	+ Alltrim(aProdDesc[01][07])   
			Endif
        Else
			_nDesGrp  := DescGrpProd(aProdDesc[01][02],aProdDesc[01][01])
			If _nDesPed == _nDesGrp
				aProdDesc[01][07] := "" //Cliente Liberado
				InseriProd(cCodReg,aProdDesc[01][01],_nDesGrp)

				_cMsgIte := "Liberado por deconsto do grupo"  
				_cMsgIte	+= "Código da regra: "				+ IIF(!Empty(cCodReg),Alltrim(cCodReg),"Regra não encontrada ou fora de vigência")	+ _lEnt
				_cMsgIte	+= "Inserido Automaticamente: "		+ Alltrim(aProdDesc[01][01]) + _lEnt
            Else
               aProdDesc[01][07] := "02" //Cliente Bloqueado

				_cMsgIte	:= "Código do produto:  "					+ Alltrim(aProdDesc[01][01])      													+ _lEnt
				_cMsgIte	+= "Item do pedido de venda: "				+ Alltrim(aProdDesc[01][02])      													+ _lEnt
				_cMsgIte	+= "Preço de Venda: "						+ AllTrim(Transform(aProdDesc[01][03],PesqPict("SC6","C6_PRUNIT")))					+ _lEnt
				_cMsgIte	+= "Preço de Lista: "						+ AllTrim(Transform(aProdDesc[01][04],PesqPict("SC6","C6_PRUNIT")))					+ _lEnt
				_cMsgIte	+= "Código da regra: "						+ IIF(!Empty(cCodReg),Alltrim(cCodReg),"Regra não encontrada ou fora de vigência")	+ _lEnt
				_cMsgIte	+= "% de desconto do pedido: "				+ Transform(_nDesPed,PesqPict("SC6","C6_DESCONT")) + "%" 					+ _lEnt
				If !Empty(cCodReg)
					_cCascata := " ("   + AllTrim(Transform(_nDesCond,PesqPict("SC6","C6_DESCONT"))) //Desconto da condição de pagamento
					_cCascata += "% + " + AllTrim(Transform(_nDesQuant,PesqPict("SC6","C6_DESCONT"))) //Desconto pelo tipo de divisão do pedido
					_cCascata += "% + " + AllTrim(Transform(_nDesProm,PesqPict("SC6","C6_DESCONT"))) //Desconto pelo item (regra)
					_cCascata += "%"    + ")"
					_cMsgIte  += "% de desconto permitido pela regra: " 	+ Transform(_nDesRegra,PesqPict("SC6","C6_DESCONT")) + "%" + _cCascata	+ _lEnt
				EndIf
				_cMsgIte	+= "% de desconto do Promocional: "				+ Transform(_nDesProm,PesqPict("SC6","C6_DESCONT")) + "%" 						+ _lEnt
				_cMsgIte	+= "% de desconto ponderado permitido pela regra + Promocional: "	+ Transform(_nDescFator,PesqPict("SC6","C6_DESCONT")) + "%" 				+ _lEnt
				_cMsgIte	+= "Código do bloqueio: "                 	+ Alltrim(aProdDesc[01][07])     
            EndIf
        Endif
EndIf

If _lBlRes
	lRetorno := lContVerba := .T.
	_cMsgIte := "*** PEDIDO COM ELIMINAÇÃO DE RESÍDUO, NÃO AVALIADO! ***" + _lEnt + _cMsgIte + _lEnt
EndIf

//Verifico se o registro foi bloqueado para gravação
If _cAliSC5 == "SC5"
	If (SC5->(DBRLock())) .AND. !SC5->(EOF())
		dbSelectArea("SC5")
		/*
		//Por conta de problema técnico com a gravação cumulativa
		//do campo memo, foi necessário ir concatenando as mensagens
		//em arquivo ".txt" e o conteúdo deste é copiado para o campo memo
		//no final do processo.
		*/
		//Caso exista algum arquivo de observações antigo para o pedido em questão o mesmo é deletado antes de iniciar a nova gravação
		If (Len(aProdDesc)>1 .And. Len(aCols)>1) .Or. (Len(aProdDesc)>1 .And. Len(aCols)==1) .Or. (Len(aProdDesc)==1 .And. Len(aCols)==1)
			If File(_cCamArq+_cArquivo)
				fErase(_cCamArq+_cArquivo)
			EndIf
		EndIf
		If (Len(aProdDesc)>1 .And. Len(aCols)>1) .Or. (Len(aProdDesc)>1 .And. Len(aCols)==1) .Or. (Len(aProdDesc)==1 .And. Empty(_cMsgIte))
			If _lC5_CONTOBS .AND. _lC5_OBSBLQ .AND. SC5->C5_OBSBLQ <> fLerTxt(_cArquivo)
				M->C5_CONTOBS := SC5->C5_CONTOBS := ""
			EndIf
			//Caso não haja bloqueio, limpo o campo de observações
			If _lC5_CONTOBS .AND. Empty(_cContObs) .And. Empty(fLerTxt(_cArquivo)) //Verifico se esta é a primeira observação do pedido
				M->C5_CONTOBS := SC5->C5_CONTOBS := ""
			elseif _lC5_CONTOBS .AND. _lC5_OBSBLQ
				M->C5_CONTOBS := SC5->C5_CONTOBS := "S"
				M->C5_OBSBLQ  := SC5->C5_OBSBLQ	 := fLerTxt(_cArquivo)
			EndIf
		ElseIf !Empty(_cMsgIte)  .AND. !Empty(aProdDesc[1][7])
			//Trecho inserido por Júlio Soares para atualização da Tabela SUA
			//1 - Bloqueio de Regra
			//2 - Bloqueio de Crédito
			//3 - Bloqueio de Estoque
			//4 - Pedido em Separação
			//5 - Pedido expedido
			_cLogx := "Pedido de Vendas Bloqueado por Regras de Negócios."
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
			If _lC5_LOGSTAT
				_cLog := Alltrim(SC5->C5_LOGSTAT)
				while !RecLock("SC5",.F.) ; enddo
					SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
										UsrRetName(__cUserId) + _lEnt + _cLogx
					SC5->C5_BLQ := aProdDesc[1][7]
				SC5->(MsUnLock())
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
				If Empty(_cContObs) .And. Empty(fLerTxt(_cArquivo)) //Verifico se esta é a primeira observação do pedido
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
						//Início- Trecho alterado por Arthur Silva em 26/08/2015
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
					If Empty(_cContObs) //Verifico se esta é a primeira observação do pedido
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
			_cLogx := "PEDIDO DE VENDA SEM BLOQUEIO DE REGRAS DE NEGÓCIO."
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
	//Por conta de problema técnico com a gravação cumulativa
	//do campo memo, foi necessário ir concatenando as mensagens
	//em arquivo ".txt" e o conteúdo deste é copiado para o campo memo
	//no final do processo.
	//Caso exista algum arquivo de observações antigo para o pedido em questão o mesmo é deletado antes de iniciar a nova gravação
	If (Len(aProdDesc)>1 .And. Len(aCols)>1) .Or. (Len(aProdDesc)>1 .And. Len(aCols)==1) .Or. (Len(aProdDesc)==1 .And. Len(aCols)==1)
		If File(_cCamArq+_cArquivo)
			fErase(_cCamArq+_cArquivo)
		EndIf
	EndIf
	If (Len(aProdDesc)>1 .And. Len(aCols)>1) .Or. (Len(aProdDesc)>1 .And. Len(aCols)==1) .Or. (Len(aProdDesc)==1 .And. Empty(_cMsgIte))
		If _lC5_OBSBLQ .AND. &(_cAliSC5+"->C5_OBSBLQ") <> fLerTxt(_cArquivo)
			&(_cAliSC5+"->C5_OBSBLQ") := ""
		EndIf
		//Caso não haja bloqueio, limpo o campo de observações
		If _lC5_CONTOBS .AND. Empty(_cContObs) .And. Empty(fLerTxt(_cArquivo)) //Verifico se esta é a primeira observação do pedido
			&(_cAliSC5+"->C5_CONTOBS") := ""
		Elseif _lC5_CONTOBS .AND. _lC5_OBSBLQ
			&(_cAliSC5+"->C5_CONTOBS") := "S"
			&(_cAliSC5+"->C5_OBSBLQ")  := fLerTxt(_cArquivo)
		EndIf
	ElseIf !Empty(_cMsgIte) .AND. !Empty(aProdDesc[1][7])
		//Trecho inserido por Júlio Soares para atualização da Tabela SUA
		//1 - Bloqueio de Regra
		//2 - Bloqueio de Crédito
		//3 - Bloqueio de Estoque
		//4 - Pedido em Separação
		//5 - Pedido expedido
		_cLogx := "Pedido de Vendas Bloqueado por Regras de Negócios."
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
			If Empty(_cContObs) .And. Empty(fLerTxt(_cArquivo)) //Verifico se esta é a primeira observação do pedido
				fGravaTxt(_cMsgCab + _cMsgIte)
				if _lC5_CONTOBS .AND. _lC5_OBSBLQ
					&(_cAliSC5+"->C5_CONTOBS") := "S"
					&(_cAliSC5+"->C5_OBSBLQ")  := fLerTxt(_cArquivo)
				endif
			ElseIf !(_cMsgDCab $ fLerTxt(_cArquivo))
				_cAux := fLerTxt(_cArquivo)
				If !(("Item do pedido de venda: " + Alltrim(aProdDesc[01][02])) $ _cAux) .And. !(_cBlqFina $ _cAux)
					fGravaTxt(_lEnt + _cMsgIte)
					//Início- Trecho alterado por Arthur Silva em 26/08/2015
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
					If Empty(_cContObs) //Verifico se esta é a primeira observação do pedido
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
		_cLogx := "Pedido de Vendas sem bloqueio de regras de negócios."
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

Return

static function AvGerFin()
	Local _aSavSF4  := SF4->(GetArea())
	Local _cSC6TTMP := GetNextAlias()
	Local _lRet 	:= .T. // .F. - Bloqueia o pedido

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
Return _lRet


// Lógica para gerar o fator de desconto do pedido
Static Function FatorDesc(_nDesc1,_nDesc2,_nDesc3,_nDesc4)
    Local _nFator := 0
	Local _nAux	  := 100
	Local _nCont  := 0
	
	AAdd(_aDesc,_nDesc1)
	AAdd(_aDesc,_nDesc2)
	//AAdd(_aDesc,_nDesc3)
	//AAdd(_aDesc,_nDesc4)
	//Varre o array com os campos de desconto para calcular o desconto em cascata
	For _nCont := 1 To Len(_aDesc)
		If aCols[n,_aDesc[_nCont]] > 0
			_nAux := _nAux - (_nAux * ((aCols[n,_aDesc[_nCont]])/100))
		EndIf
		_nFator   := (100 - _nAux)
	Next
Return _nfator

//Função para buscar o desconto por Cliente
Static Function DescCliente(_cItem,_cProd)

	Local _aSavAr	  := GetArea()
	Local _lRet		  := .T.	//Retorno .F. bloqueia o pedido por regra
//	Local _cCondPg	  := ""
	Local _cQRYTMP    := GetNextAlias()
	Local _nLinha     := 0
	Local _nTamDesc   := TamSx3("ACN_DESCON")[02]
	Local _nPercVar	  := SuperGetMV("MV_XPERCVAR",,0.22)
	Local _aDescCli	  := {}
	Local _cCodReg	  := ""
	Local _nDescCli	  := 0

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


	if select(_cQRYTMP) > 0
		(_cQRYTMP)->(dbCloseArea())
	endif
	BeginSql Alias _cQRYTMP
		SELECT * 
		FROM ( 
		//AVALIO SE HÁ REGRA POR CLIENTE - NIVEL 1
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
			  ) REGRAS 
		ORDER BY REGRAS.NIVEL,REGRAS.ACN_PROMOC
	EndSql

	MemoWrite("c:\relato\query_regra_cliente.txt", GetLastQuery()[02])
	dbSelectArea(_cQRYTMP)
	If (_cQRYTMP)->(EOF())
		cCodReg				:= ""
		aProdDesc[01][06] 	:= 0 //Regra não encontrada
		aProdDesc[01][07]	:= "02"
	Else
		_cCodReg		:= (_cQRYTMP)->ACN_CODREG
		_nDescCli := Round((_cQRYTMP)->ACN_DESCON,_nTamDesc) //Desconto permitido selecionado
	EndIf

	//Excluo a tabela temporária
	if Select(_cQRYTMP) > 0
		(_cQRYTMP)->(dbCloseArea())
	endif

Return(_nDescCli)

//Função para buscar o desconto por grupo
Static Function DescGrpProd(_cItem,_cProd)

	Local _aSavAr	  := GetArea()
	Local _lRet		  := .T.	//Retorno .F. bloqueia o pedido por regra
//	Local _cCondPg	  := ""
	Local _cQRYTMP    := GetNextAlias()
	Local _nLinha     := 0
	Local _nTamDesc   := TamSx3("ACN_DESCON")[02]
	Local _nPercVar	  := SuperGetMV("MV_XPERCVAR",,0.22)
	Local _aDescCli	  := {}
	Local _cCodReg	  := ""
	Local _nDescGrp	  := 0

	Private _cLog	  := ""
	Private _nQuant   := 0
//	Private _nDescont := 0
	Private _cProduto := SubStr(_cProd,1,4)

	_nLinha := aScan(aCols,{|x|x[_nPosIte]==_cItem .AND. x[_nPosPro]==_cProd}) //Localizo a linha do aCols com o produto a ser processado
	If _nLinha == 0 .OR. _nPosQtd == 0
		RestArea(_aSavAr)
		return(_lRet)
	EndIf
	_nQuant	:= aCols[_nLinha,_nPosQtd]


	if select(_cQRYTMP) > 0
		(_cQRYTMP)->(dbCloseArea())
	endif
	BeginSql Alias _cQRYTMP
		SELECT ACN_CODREG, MIN(ACN_DESCON)
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
		 			AND SUBSTRING(SB1.B1_COD,1,4)  = %Exp:_cProduto% 
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
			  GROUP BY ACN_CODREG
		ORDER BY ACN_CODREG
	EndSql

	MemoWrite("c:\relato\query_regra_grupo.txt", GetLastQuery()[02])
	dbSelectArea(_cQRYTMP)
	If (_cQRYTMP)->(EOF())
		cCodReg				:= ""
		aProdDesc[01][06] 	:= 0 //Regra não encontrada
		aProdDesc[01][07]	:= "02"
	Else
		_cCodReg		:= (_cQRYTMP)->ACN_CODREG
		_nDescGrp := Round((_cQRYTMP)->ACN_DESCON,_nTamDesc) //Desconto permitido selecionado
	EndIf

	//Excluo a tabela temporária
	if Select(_cQRYTMP) > 0
		(_cQRYTMP)->(dbCloseArea())
	endif

Return(_nDescGrp)

//Função para buscar o desconto por grupo
Static Function DescQuant(_cItem,_cProd)

	Local _aSavAr	  := GetArea()
	Local _lRet		  := .T.	//Retorno .F. bloqueia o pedido por regra
//	Local _cCondPg	  := ""
	Local _cQRYTMP    := GetNextAlias()
	Local _nLinha     := 0
	Local _nTamDesc   := TamSx3("ACN_DESCON")[02]
	Local _nPercVar	  := SuperGetMV("MV_XPERCVAR",,0.22)
	Local _aDescCli	  := {}
	Local _cCodReg	  := ""
	Local _nDescQuant	  := 0

	Private _cLog	  := ""
	Private _nQuant   := 0
//	Private _nDescont := 0
	Private _cProduto := SubStr(_cProd,1,4)

	_nLinha := aScan(aCols,{|x|x[_nPosIte]==_cItem .AND. x[_nPosPro]==_cProd}) //Localizo a linha do aCols com o produto a ser processado
	If _nLinha == 0 .OR. _nPosQtd == 0
		RestArea(_aSavAr)
		return(_lRet)
	EndIf
	_nQuant	:= aCols[_nLinha,_nPosQtd]


	if select(_cQRYTMP) > 0
		(_cQRYTMP)->(dbCloseArea())
	endif
	BeginSql Alias _cQRYTMP
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
		ORDER BY ACN_CODREG
	EndSql

	MemoWrite("c:\relato\query_regra_quant.txt", GetLastQuery()[02])
	dbSelectArea(_cQRYTMP)
	If (_cQRYTMP)->(EOF())
		cCodReg				:= ""
		aProdDesc[01][06] 	:= 0 //Regra não encontrada
		aProdDesc[01][07]	:= "02"
	Else
		_cCodReg		:= (_cQRYTMP)->ACN_CODREG
		_nDescQuant := Round((_cQRYTMP)->ACN_DESCON,_nTamDesc) //Desconto permitido selecionado
	EndIf

	//Excluo a tabela temporária
	if Select(_cQRYTMP) > 0
		(_cQRYTMP)->(dbCloseArea())
	endif

Return(_nDescQuant)

//Função para buscar o desconto por grupo
Static Function Descpromo(_cItem,_cProd)

	Local _aSavAr	  := GetArea()
	Local _lRet		  := .T.	//Retorno .F. bloqueia o pedido por regra
//	Local _cCondPg	  := ""
	Local _cQRYTMP    := GetNextAlias()
	Local _nLinha     := 0
	Local _nTamDesc   := TamSx3("ACN_DESCON")[02]
	Local _nPercVar	  := SuperGetMV("MV_XPERCVAR",,0.22)
	Local _aDescCli	  := {}
	Local _cCodReg	  := ""
	Local _nDescProm	  := 0

	Private _cLog	  := ""
	Private _nQuant   := 0
//	Private _nDescont := 0
	Private _cProduto := SubStr(_cProd,1,4)

	_nLinha := aScan(aCols,{|x|x[_nPosIte]==_cItem .AND. x[_nPosPro]==_cProd}) //Localizo a linha do aCols com o produto a ser processado
	If _nLinha == 0 .OR. _nPosQtd == 0
		RestArea(_aSavAr)
		return(_lRet)
	EndIf
	_nQuant	:= aCols[_nLinha,_nPosQtd]


	if select(_cQRYTMP) > 0
		(_cQRYTMP)->(dbCloseArea())
	endif
	BeginSql Alias _cQRYTMP
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
		ORDER BY ACN_CODREG
	EndSql

	MemoWrite("c:\relato\query_regra_promo.txt", GetLastQuery()[02])
	dbSelectArea(_cQRYTMP)
	If (_cQRYTMP)->(EOF())
		cCodReg				:= ""
		aProdDesc[01][06] 	:= 0 //Regra não encontrada
		aProdDesc[01][07]	:= "02"
	Else
		_cCodReg		:= (_cQRYTMP)->ACN_CODREG
		_nDescProm := Round((_cQRYTMP)->ACN_DESCON,_nTamDesc) //Desconto permitido selecionado
	EndIf

	//Excluo a tabela temporária
	if Select(_cQRYTMP) > 0
		(_cQRYTMP)->(dbCloseArea())
	endif

Return(_nDescProm)

//Função para buscar o desconto por grupo
Static Function InseriProd(cCodReg,_cProd,_nDesconto)
 Local _cAliasACN := GetNextAlias()

	if select(_cAliasACN) > 0
		(_cAliasACN)->(dbCloseArea())
	endif
	BeginSql Alias _cAliasACN
		SELECT MAX(ACN_ITEM)+1 AS NEW_ITEM
		FROM ACN010 ACN (NOLOCK)
		WHERE ACN_CODREG = %Exp:cCodReg%
	EndSql
	DbSelectArea("ACN")
	ACN->(dbSetOrder(1))
	If ACN->(MsSeek(xFilial("ACN") + cCodReg,.T.,.F.))
		RecLock("SC5",.F.)
			ACN->ACN_CODREG  	:= cCodReg
			ACN->ACN_CODITEM 	:= (_cAliasACN)->NEW_ITEM
			ACN->ACN_CODPRO 	:= _cProd
			ACN->ACN_DESCV1 	:= _nDesconto
			ACN->ACN_DESCON 	:= _nDesconto
			ACN->ACN_DTINCL 	:= Dtos(dDataBase)
			ACN->ACN_USRINC 	:= "000000"
			ACN->ACN_PROMO  	:= "2"
			ACN->ACN_DATINI		:= Dtos(dDataBase)
			ACN->ACN_DATFIM 	:= "20491231"
		ACN->(MsUnLock())
	EndIf
	//Excluo a tabela temporária
	if Select(_cAliasACN) > 0
		(_cAliasACN)->(dbCloseArea())
	endif
	
Return()



