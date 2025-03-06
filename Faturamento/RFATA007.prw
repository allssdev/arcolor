#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} RFATA007
@description Rotina de Chamada de gravacao das Ordens de Separacao
@author Anderson C. P. Coelho (ALL System Solutions)
@since 29/03/2013
@version 1.0
@param _cOrigem, caracter, Indica de onde a rotina foi chamada.
@type function
@see https://allss.com.br
@history 06/03/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Revisão para adequação dda rastreabilidade.
/*/

User Function RFATA007(_cOrigem)

Local _aSavArea  := GetArea()
Local _cRotina   := "RFATA007"
Local _cFNamBkp  := FunName()
Local _Ret       := NIL

Private nPreSep 

Default _cOrigem := ""

SetFunName("ACDA100")
	_Ret := ACDA100_Grava()		//ACDA100Gr()
SetFunName(_cFNamBkp)

If ExistBlock("RFATR013")
	If MsgBox("Deseja imprimir o relatório?", _cRotina+"_001", "YESNO")
		U_RFATR013(_cOrigem)
	EndIf
EndIf

RestArea(_aSavArea)

Return(_Ret)



//DAQUI PARA BAIXO, SE TRATA DA ROTINA PADRÃO, PARA QUE TENHAMOS CONTROLE DE DEPURAÇÃO SOBRE A MESMA. CASO SEJA NECESSÁRIO, PODERÁ SER AVALIADA A ALTERNATIVA DE CONSTRUÇÃO DE ROTINA AUTONOMA PARA TAL.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ACDA100_Grava ³ Autor ³ Eduardo Motta    ³ Data ³ 06/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao das ordens de separacao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

static function ACDA100_Grava(cAlias,cCampo,nOpcE,cMarca,lInverte,lNoDupl)
If nOrigExp==1
	Processa( { || GeraOSepPedido( cMarca, lInverte ) } )
ElseIf nOrigExp==2
	Processa( { || GeraOSepNota( cMarca, lInverte ) } )
ElseIf nOrigExp==3
	Processa( { || GeraOSepProducao( cMarca, lInverte ) } )
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GeraOSepPedido³ Autor ³ Eduardo Motta     ³ Data ³ 06/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera as ordens de separacao a partir dos itens da MarkBrowse³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GeraOrdSep( ExpC1, ExpL1 )                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Marca da MarkBrowse / ExpL1 -> lInverte MarkBrowse³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PCHA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

STATIC Function GeraOSepPedido( cMarca, lInverte, cPedidoPar)
Local nI
Local cCodOpe
Local aRecSC9	:= {}
Local aOrdSep	:= {}
Local _aTesEst	:= {}
Local _aSepEst	:= {}

Local cArm		:= Space(Tamsx3("B1_LOCPAD")[1])
Local cPedido	:= Space(Tamsx3("C9_PEDIDO")[1])
Local cCliente	:= Space(Tamsx3("C6_CLI")[1])
Local cLoja		:= Space(Tamsx3("C6_LOJA")[1])
Local cCondPag	:= Space(Tamsx3("C5_CONDPAG")[1])
Local cLojaEnt	:= Space(Tamsx3("C5_LOJAENT")[1])
Local cAgreg	:= Space(Tamsx3("C9_AGREG")[1])
Local cOrdSep	:= Space(Tamsx3("CB7_ORDSEP")[1])

Local cTipExp	:= ""
Local nPos      := 0
Local nMaxItens	:= GETMV("MV_NUMITEN")			//Numero maximo de itens por nota (neste caso por ordem de separacao)- by Erike
Local lConsNumIt:= SuperGetMV("MV_CBCNITE",.F.,.T.) //Parametro que indica se deve ou nao considerar o conteudo do MV_NUMITEN
Local lFilItens	:= ExistBlock("ACDA100I")  //Ponto de Entrada para filtrar o processamento dos itens selecionados
Local lLocOrdSep:= .F.
Local lA100CABE := ExistBlock("A100CABE")
Local lACD100GI := ExistBlock("ACD100GI")
Local lACDA100F := ExistBlock("ACDA100F")
Local _cSC6TMP  := GetNextAlias() 
Local _cTpOper := "%" + FormatIn(SUPERGETMV( "MV_XTPOVLD",.F.,"VC"),"/")+ "%"

Private aLogOS	:= {}
nMaxItens := If(Empty(nMaxItens),99,nMaxItens)

// analisar a pergunta '00-Separacao,01-Separacao/Embalagem,02-Embalagem,03-Gera Nota,04-Imp.Nota,05-Imp.Volume,06-embarque,07-Aglutina Pedido,08-Aglutina Local,09-Pre-Separacao'
If nEmbSimul == 1 // Separacao com Embalagem Simultanea
	cTipExp := "01*"
Else
	cTipExp := "00*" // Separacao Simples
EndIF
If nEmbalagem == 1 // Embalagem
	cTipExp += "02*"
EndIF
If nGeraNota == 1 // Gera Nota
	cTipExp += "03*"
EndIF
If nImpNota == 1 // Imprime Nota
	cTipExp += "04*"
EndIF
If nImpEtVol == 1 // Imprime Etiquetas Oficiais de Volume
	cTipExp += "05*"
EndIF
If nEmbarque == 1 // Embarque
	cTipExp += "06*"
EndIF
If nAglutPed == 1 // Aglutina pedido
	cTipExp +="11*"
EndIf
If nAglutArm == 1 // Aglutina armazem
	cTipExp +="08*"
EndIf
If nPreSep == 1 // pre-separacao - Trocar MV_PAR10 para nPreSep
	cTipExp +="09*"
EndIf
If nConfLote == 1 // confere lote
	cTipExp +="10*"
EndIf

/*Ponto de entrada, permite que o usuário realize o processamento conforme suas particularidades.*/
If	ExistBlock("ACD100VG")
	If ! ExecBlock("ACD100VG",.F.,.F.,)
		Return
	EndIf		
EndIf

//AllSystem - 13/09/2023 - Diego Rodrigues - Melhoria para validação se a TES movimenta estoque antes da geração da ordem de separação
		if Select(_cSC6TMP) > 0
			(_cSC6TMP)->(dbCloseArea())
		endif	

		BeginSql Alias _cSC6TMP
			SELECT
				C6_NUM, C6_TES, F4_TEXTO, F4_ESTOQUE
			FROM %table:SC6% SC6 (NOLOCK)
			INNER JOIN %table:SC5% SC5 (NOLOCK) ON SC5.C5_NUM = SC6.C6_NUM AND C5_TPOPER NOT IN %Exp:_cTpOper% 
			INNER JOIN %table:SF4% SF4 (NOLOCK) ON SF4.%NotDel% AND SF4.F4_CODIGO = SC6.C6_TES 
										   AND SF4.F4_ESTOQUE = 'N'
			WHERE SC6.%NotDel%
			AND SC6.C6_NUM = %Exp:SC9->C9_PEDIDO%
		EndSql	

		dbSelectArea(_cSC6TMP)
		(_cSC6TMP)->(dbGoTop())
		While !(_cSC6TMP)->(EOF())	//Se retornar .T., significa que algum item do processo deixará o estoque negativo
			AADD(_aTesEst,{(_cSC6TMP)->C6_NUM,(_cSC6TMP)->C6_TES,(_cSC6TMP)->F4_TEXTO,(_cSC6TMP)->F4_ESTOQUE})
			(_cSC6TMP)->(dbSkip())
		EndDo
		if Select(_cSC6TMP) > 0
			(_cSC6TMP)->(dbCloseArea())
		endif	

		If Len(_aTesEst) > 0
				TELAERRO(_aTesEst)
				return NIL	
		EndIf
//Fim da Melhoria
ProcRegua( SC9->( LastRec() ), "oook" )
cCodOpe	 := cSeparador

SC5->(DbSetOrder(1))
SC6->(DbSetOrder(1))
SDC->(DbSetOrder(1))
CB7->(DbSetOrder(2))
CB8->(DbSetOrder(2))

SC9->(dbGoTop())
While !SC9->(Eof())
	If ! SC9->(IsMark("C9_OK",ThisMark(),ThisInv()))
		SC9->(DbSkip())
		IncProc()
		Loop
	EndIf
	If !Empty(SC9->(C9_BLEST+C9_BLCRED+C9_BLOQUEI))
		SC9->(DbSkip())
		IncProc()
		Loop
	EndIf
	If lFilItens
		If !ExecBlock("ACDA100I",.F.,.F.)
			SC9->(DbSkip())
			IncProc()
			Loop
		Endif
	Endif
	//pesquisa se este item tem saldo a separar, caso tenha, nao gera ordem de separacao
	If CB8->(DbSeek(xFilial('CB8')+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN+SC9->C9_PRODUTO)) .and. CB8->CB8_SALDOS > 0
		//Grava o historico das geracoes:
		aadd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_LOCAL,"Existe saldo a separar deste item","NAO_GEROU_OS"})
		SC9->(DbSkip())
		IncProc()
		Loop
	EndIf

	If ! SC5->(DbSeek(xFilial('SC5')+SC9->C9_PEDIDO))
		// neste caso a base tem sc9 e nao tem sc5, problema de incosistencia de base
		//Grava o historico das geracoes:
		aadd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_LOCAL,"Inconsistencia de base (SC5 x SC9)","NAO_GEROU_OS"})
		SC9->(DbSkip())
		IncProc()
		Loop
	EndIf
	If ! SC6->(DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO))
		// neste caso a base tem sc9,sc5 e nao tem sc6,, problema de incosistencia de base
		//Grava o historico das geracoes:
		aadd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_LOCAL,"Inconsistencia de base (SC6 x SC9)","NAO_GEROU_OS"})
		SC9->(DbSkip())
		IncProc()
		Loop
	EndIf

	If !("08*" $ cTipExp)  // gera ordem de separacao por armazem
		cArm :=SC6->C6_LOCAL
	Else  // gera ordem de separa com todos os armazens
		cArm :=Space(Tamsx3("B1_LOCPAD")[1])
	EndIf
	If "11*" $ cTipExp //AGLUTINA TODOS OS PEDIDOS DE UM MESMO CLIENTE
		cPedido := Space(Tamsx3("C9_PEDIDO")[1])
	Else   // Nao AGLUTINA POR PEDIDO
		cPedido := SC9->C9_PEDIDO
	EndIf
	If "09*" $ cTipExp // AGLUTINA PARA PRE-SEPARACAO
		cPedido  := Space(Tamsx3("C9_PEDIDO")[1]) // CASO SEJA PRE-SEPARACAO TEM QUE CONSIDERAR TODOS OS PEDIDOS
		cCliente := Space(Tamsx3("C6_CLI")[1])
		cLoja    := Space(Tamsx3("C6_LOJA")[1])
		cCondPag := Space(Tamsx3("C5_CONDPAG")[1])
		cLojaEnt := Space(Tamsx3("C5_LOJAENT")[1])
		cAgreg   := Space(Tamsx3("C9_AGREG")[1])
	Else   // NAO AGLUTINA PARA PRE-SEPARACAO
		cCliente := SC6->C6_CLI
		cLoja    := SC6->C6_LOJA
		cCondPag := SC5->C5_CONDPAG
		cLojaEnt := SC5->C5_LOJAENT
		cAgreg   := SC9->C9_AGREG
	EndIf

	lLocOrdSep := .F.
	If CB7->(DbSeek(xFilial("CB7")+cPedido+cArm+" "+cCliente+cLoja+cCondPag+cLojaEnt+cAgreg))
		While CB7->(!Eof() .and. CB7_FILIAL+CB7_PEDIDO+CB7_LOCAL+CB7_STATUS+CB7_CLIENT+CB7_LOJA+CB7_COND+CB7_LOJENT+CB7_AGREG==;
								xFilial("CB7")+cPedido+cArm+" "+cCliente+cLoja+cCondPag+cLojaEnt+cAgreg)
			If Ascan(aOrdSep, CB7->CB7_ORDSEP) > 0			
				lLocOrdSep := .T.
				Exit
			EndIf
			CB7->(DbSkip())
		EndDo
	EndIf
	
	If Localiza(SC9->C9_PRODUTO)
		If ! SDC->( dbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN))
			// neste caso nao existe composicao de empenho
			//Grava o historico das geracoes:
			aadd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_LOCAL,"Nao existe composicao de empenho (SDC)","NAO_GEROU_OS"})
			SC9->(DbSkip())
			IncProc()
			Loop
		EndIf
	EndIf
	
	If !lLocOrdSep .or. (("03*" $ cTipExp) .and. !("09*" $ cTipExp) .and. lConsNumIt .And. CB7->CB7_NUMITE >=nMaxItens)

		cOrdSep := CB_SXESXF("CB7","CB7_ORDSEP",,1)
		ConfirmSX8()

		CB7->(RecLock( "CB7",.T.))
		CB7->CB7_FILIAL := xFilial( "CB7" )
		CB7->CB7_ORDSEP := cOrdSep
		CB7->CB7_PEDIDO := cPedido
		CB7->CB7_CLIENT := cCliente
		CB7->CB7_LOJA   := cLoja
		CB7->CB7_COND   := cCondPag
		CB7->CB7_LOJENT := cLojaEnt
		CB7->CB7_LOCAL  := cArm
		CB7->CB7_DTEMIS := dDataBase
		CB7->CB7_HREMIS := Time()
		CB7->CB7_STATUS := " "
		CB7->CB7_CODOPE := cCodOpe
		CB7->CB7_PRIORI := "1"
		CB7->CB7_ORIGEM := "1"
		CB7->CB7_TIPEXP := cTipExp
		CB7->CB7_TRANSP := SC5->C5_TRANSP
		CB7->CB7_AGREG  := cAgreg 
		If	lA100CABE
			ExecBlock("A100CABE",.F.,.F.)
		EndIf
		CB7->(MsUnlock())

		aadd(aOrdSep,CB7->CB7_ORDSEP)
	EndIf
	//Grava o historico das geracoes:
	nPos := Ascan(aLogOS,{|x| x[01]+x[02]+x[03]+x[04]+x[05]+x[10] == ("1"+"Pedido"+SC9->(C9_PEDIDO+C9_CLIENTE+C9_LOJA)+CB7->CB7_ORDSEP)})
	If nPos == 0
		aadd(aLogOS,{"1","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,"","",cArm,"",CB7->CB7_ORDSEP})
	Endif

	If Localiza(SC9->C9_PRODUTO)
		While SDC->(! Eof() .and. DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+;
			DC_ITEM+DC_SEQ==xFilial("SDC")+SC9->(C9_PRODUTO+C9_LOCAL+"SC6"+C9_PEDIDO+C9_ITEM+C9_SEQUEN))

			SB1->(DBSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+SDC->DC_PRODUTO)) .And. IsProdMOD(SDC->DC_PRODUTO)
				SDC->(DbSkip())
				Loop
			Endif

			CB8->(RecLock("CB8",.T.))
			CB8->CB8_FILIAL := xFilial("CB8")
			CB8->CB8_ORDSEP := CB7->CB7_ORDSEP
			CB8->CB8_ITEM   := SC9->C9_ITEM
			CB8->CB8_PEDIDO := SC9->C9_PEDIDO
			CB8->CB8_PROD   := SDC->DC_PRODUTO
			CB8->CB8_LOCAL  := SDC->DC_LOCAL
			CB8->CB8_QTDORI := SDC->DC_QUANT
			If "09*" $ cTipExp
				CB8->CB8_SLDPRE := SDC->DC_QUANT
			EndIf
			CB8->CB8_SALDOS := SDC->DC_QUANT
			If ! "09*" $ cTipExp .AND. nEmbalagem == 1
				CB8->CB8_SALDOE := SDC->DC_QUANT
			EndIf
			CB8->CB8_LCALIZ := SDC->DC_LOCALIZ
			CB8->CB8_NUMSER := SDC->DC_NUMSERI
			CB8->CB8_SEQUEN := SC9->C9_SEQUEN
			CB8->CB8_LOTECT := SC9->C9_LOTECTL
			CB8->CB8_NUMLOT := SC9->C9_NUMLOTE
			CB8->CB8_CFLOTE := If("10*" $ cTipExp,"1","2")
			CB8->CB8_TIPSEP := If("09*" $ cTipExp,"1"," ")
			If	lACD100GI
				ExecBlock("ACD100GI",.F.,.F.)
			EndIf
			CB8->(MsUnLock())
			//Atualizacao do controle do numero de itens a serem impressos
			RecLock("CB7",.F.)
			CB7->CB7_NUMITE++
			CB7->(MsUnLock())
			SDC->( dbSkip() )
		EndDo
		
	Else 
		CB8->(RecLock("CB8",.T.))
		CB8->CB8_FILIAL := xFilial("CB8")
		CB8->CB8_ORDSEP := CB7->CB7_ORDSEP
		CB8->CB8_ITEM   := SC9->C9_ITEM
		CB8->CB8_PEDIDO := SC9->C9_PEDIDO
		CB8->CB8_PROD   := SC9->C9_PRODUTO
		CB8->CB8_LOCAL  := SC9->C9_LOCAL
		CB8->CB8_QTDORI := SC9->C9_QTDLIB
		If "09*" $ cTipExp
			CB8->CB8_SLDPRE := SC9->C9_QTDLIB 
		EndIf
		CB8->CB8_SALDOS := SC9->C9_QTDLIB
		If ! "09*" $ cTipExp .AND. nEmbalagem == 1
			CB8->CB8_SALDOE := SC9->C9_QTDLIB
		EndIf
		dbSelectArea("CBJ")
        CBJ->(dbSetOrder(1))
        if CBJ->(dbSeek(FwFilial("CBJ") + SC9->C9_PRODUTO + SC9->C9_LOCAL)) //CBJ_FILIAL+CBJ_CODPRO+CBJ_ARMAZ+CBJ_ENDERE
		   CB8->CB8_LCALIZ := CBJ->CBJ_ENDERE
        endif
		CB8->CB8_NUMSER := SC9->C9_NUMSERI
		CB8->CB8_SEQUEN := SC9->C9_SEQUEN
		CB8->CB8_LOTECT := SC9->C9_LOTECTL
		CB8->CB8_NUMLOT := SC9->C9_NUMLOTE
		CB8->CB8_CFLOTE := If("10*" $ cTipExp,"1","2")
		CB8->CB8_TIPSEP := If("09*" $ cTipExp,"1"," ")
		If	lACD100GI
			ExecBlock("ACD100GI",.F.,.F.)
		EndIf
		CB8->(MsUnLock())

		//Atualizacao do controle do numero de itens a serem impressos
		RecLock("CB7",.F.)
		CB7->CB7_NUMITE++
		CB7->(MsUnLock())
	EndIf
	aadd(aRecSC9,{SC9->(Recno()),CB7->CB7_ORDSEP})
	IncProc()
	SC9->( dbSkip() )
EndDo

CB7->(DbSetOrder(1))
For nI := 1 to len(aOrdSep)
	CB7->(DbSeek(xFilial("CB7")+aOrdSep[nI]))
	CB7->(RecLock("CB7"))
	CB7->CB7_STATUS := "0"  // nao iniciado
	CB7->(MsUnlock())
	If	lACDA100F
		ExecBlock("ACDA100F",.F.,.F.,{aOrdSep[nI]})
	EndIf
Next
For nI := 1 to len(aRecSC9)
	SC9->(DbGoto(aRecSC9[nI,1]))
	SC9->(RecLock("SC9"))
	SC9->C9_ORDSEP := aRecSC9[nI,2]
	SC9->(MsUnlock())
Next
If !Empty(aLogOS)
	LogACDA100()
Endif

//AllSystem - 11/12/2024 - Diego Rodrigues - Melhoria para validação se algum item ativo na SC9 não foi gerado na ordem de separação
		if Select(_cSC6TMP) > 0
			(_cSC6TMP)->(dbCloseArea())
		endif	

		BeginSql Alias _cSC6TMP
			SELECT
				C9_PEDIDO,C9_ITEM,C9_PRODUTO, C9_QTDLIB
			FROM %table:SC9% SC9 (NOLOCK)
			WHERE   SC9.D_E_L_E_T_ = ''
					AND C9_PEDIDO = %Exp:SC9->C9_PEDIDO%
					AND C9_BLEST = ''
					AND C9_BLCRED = ''
					AND NOT EXISTS ( SELECT	
										TOP 1 1
										FROM %table:CB8% CB8 (NOLOCK)
										WHERE CB8.D_E_L_E_T_ = ''
										AND C9_PEDIDO = CB8_PEDIDO
										AND C9_ITEM = CB8_ITEM
										AND C9_SEQUEN = CB8_SEQUEN
										AND C9_PRODUTO = CB8_PROD
										)
			ORDER BY C9_PEDIDO, C9_ITEM
		EndSql	

		dbSelectArea(_cSC6TMP)
		(_cSC6TMP)->(dbGoTop())
		While !(_cSC6TMP)->(EOF())	//Se retornar .T., significa que algum item do processo deixará o estoque negativo
			AADD(_aSepEst,{(_cSC6TMP)->C9_PRODUTO,(_cSC6TMP)->C9_QTDLIB,0})
			(_cSC6TMP)->(dbSkip())
		EndDo
		if Select(_cSC6TMP) > 0
			(_cSC6TMP)->(dbCloseArea())
		endif	

		If Len(_aSepEst) > 0
			TELAERRO2(_aSepEst)
			return NIL	
		EndIf
//Fim da Melhoria

Return

STATIC Function GeraOSepNota( cMarca, lInverte, cNotaSerie)
Local cChaveDB
Local cTipExp
Local nI
Local cCodOpe
Local aRecSD2 := {}
Local aOrdSep := {}
Local lFilItens  := ExistBlock("ACDA100I")  //Ponto de Entrada para filtrar o processamento dos itens selecionados
Local lA100CABE := ExistBlock("A100CABE")
Local lACD100GI := ExistBlock("ACD100GI")
Local lACDA100F := ExistBlock("ACDA100F")

Private aLogOS:= {}

// analisar a pergunta '00-Separcao,01-Separacao/Embalagem,02-Embalagem,03-Gera Nota,04-Imp.Nota,05-Imp.Volume,06-embarque'
If nEmbSimuNF == 1
	cTipExp := "01*"
Else
	cTipExp := "00*"
EndIF
If nEmbalagNF == 1
	cTipExp += "02*"
EndIF
If nImpNotaNF == 1
	cTipExp += "04*"
EndIF
If nImpVolNF == 1
	cTipExp += "05*"
EndIF
If nEmbarqNF == 1
	cTipExp += "06*"
EndIF
/*Ponto de entrada, permite que o usuário realize o processamento conforme suas particularidades.*/
If	ExistBlock("ACD100VG")
	If ! ExecBlock("ACD100VG",.F.,.F.,)
		Return
	EndIf		
EndIf

SF2->(DbSetOrder(1))
SD2->(DbSetOrder(3))
SD2->( dbGoTop() )

If cNotaSerie == Nil
	ProcRegua( SD2->( LastRec() ), "oook" )
	cCodOpe	 := cSeparador
Else
	SD2->(DbSetOrder(3))
	SD2->(DbSeek(xFilial("SD2")+cNotaSerie))
	cCodOpe := Space(06)
EndIf

ProcRegua( SD2->( LastRec() ), "oook" )
cCodOpe := cSeparador

While !SD2->( Eof() ) .and. (cNotaSerie == Nil .or. cNotaSerie == SD2->(D2_DOC+D2_SERIE))
	If (cNotaSerie==NIL) .and. ! (SD2->(IsMark("D2_OK",ThisMark(),ThisInv())))
		SD2->( dbSkip() )
		IncProc()
		Loop
	EndIf
	If lFilItens
		If !ExecBlock("ACDA100I",.F.,.F.)
			SD2->(DbSkip())
			IncProc()
			Loop
		Endif
	Endif
	cChaveDB :=xFilial("SDB")+SD2->(D2_COD+D2_LOCAL+D2_NUMSEQ+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)
	If Localiza(SD2->D2_COD)
		SDB->(dbSetOrder(1))
		If ! SDB->(dbSeek( cChaveDB ))
			// neste caso nao existe composicao de empenho
			//Grava o historico das geracoes:
			aadd(aLogOS,{"2","Nota",SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_CLIENTE,SD2->D2_LOJA,"Inconsistencia de base, nao existe registro de movimento (SDB)","NAO_GEROU_OS"})
			SD2->(DbSkip())
			If cNotaSerie==Nil
				IncProc()
			EndIf
			Loop
		EndIf
	EndIf

	CB7->(DbSetOrder(4))
	If ! CB7->(DbSeek(xFilial("CB7")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_LOCAL+" "))
		CB7->(RecLock( "CB7", .T. ))
		CB7->CB7_FILIAL := xFilial( "CB7" )
		CB7->CB7_ORDSEP := GetSX8Num( "CB7", "CB7_ORDSEP" )
		CB7->CB7_NOTA   := SD2->D2_DOC
		//CB7->CB7_SERIE  := SD2->D2_SERIE
		SerieNfId ("CB7",1,"CB7_SERIE",,,,SD2->D2_SERIE)
		CB7->CB7_CLIENT := SD2->D2_CLIENTE
		CB7->CB7_LOJA   := SD2->D2_LOJA
		CB7->CB7_LOCAL  := SD2->D2_LOCAL
		CB7->CB7_DTEMIS := dDataBase
		CB7->CB7_HREMIS := Time()
		CB7->CB7_STATUS := " "   // gravar STATUS de nao iniciada somente depois do processo
		CB7->CB7_CODOPE := cCodOpe
		CB7->CB7_PRIORI := "1"
		CB7->CB7_ORIGEM := "2"
		CB7->CB7_TIPEXP := cTipExp
		If SF2->(DbSeek(xFilial("SF2")+SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)))
			CB7->CB7_TRANSP := SF2->F2_TRANSP
		EndIf   
		If	lA100CABE
			ExecBlock("A100CABE",.F.,.F.)
		EndIf
		CB7->(MsUnLock())
		ConfirmSX8()
		//Grava o historico das geracoes:
		aadd(aLogOS,{"1","Nota",SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_CLIENTE,SD2->D2_LOJA,"",CB7->CB7_ORDSEP})
		aadd(aOrdSep,CB7->CB7_ORDSEP)
	EndIf
	If Localiza(SD2->D2_COD)
		While SDB->(!Eof() .And. cChaveDB == DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA)
			If SDB->DB_ESTORNO == "S"
				SDB->(dbSkip())
				Loop
			EndIf
			CB8->(DbSetorder(4))
			If ! CB8->(DbSeek(xFilial("CB8")+CB7->CB7_ORDSEP+SD2->(D2_ITEM+D2_COD+D2_LOCAL+SDB->DB_LOCALIZ+D2_LOTECTL+D2_NUMLOTE+D2_NUMSERI)))
				CB8->(RecLock( "CB8", .T. ))
				CB8->CB8_FILIAL := xFilial( "CB8" )
				CB8->CB8_ORDSEP := CB7->CB7_ORDSEP
				CB8->CB8_ITEM   := SD2->D2_ITEM
				CB8->CB8_PEDIDO := SD2->D2_PEDIDO
				CB8->CB8_NOTA   := SD2->D2_DOC
				//CB8->CB8_SERIE  := SD2->D2_SERIE
				SerieNfId ("CB8",1,"CB8_SERIE",,,,SD2->D2_SERIE)
				CB8->CB8_PROD   := SD2->D2_COD
				CB8->CB8_LOCAL  := SD2->D2_LOCAL
				CB8->CB8_LCALIZ := SDB->DB_LOCALIZ
				CB8->CB8_SEQUEN := SDB->DB_ITEM
				CB8->CB8_LOTECT := SD2->D2_LOTECTL
				CB8->CB8_NUMLOT := SD2->D2_NUMLOTE
				CB8->CB8_NUMSER := SD2->D2_NUMSERI
				CB8->CB8_CFLOTE := "1"
				aadd(aRecSD2,{SD2->(Recno()),CB7->CB7_ORDSEP})
			Else
				CB8->(RecLock( "CB8", .f. ))
			EndIf
			CB8->CB8_QTDORI += SDB->DB_QUANT
			CB8->CB8_SALDOS += SDB->DB_QUANT
			If nEmbalagem == 1
				CB8->CB8_SALDOE += SDB->DB_QUANT
			EndIf
			If	lACD100GI
				ExecBlock("ACD100GI",.F.,.F.)
			EndIf
			CB8->(MsUnLock())
			SDB->(dbSkip())
		Enddo
	Else
		CB8->(DbSetorder(4))
		If ! CB8->(DbSeek(xFilial("CB8")+CB7->CB7_ORDSEP+SD2->(D2_ITEM+D2_COD+D2_LOCAL+Space(15)+D2_LOTECTL+D2_NUMLOTE+D2_NUMSERI)))
			CB8->(RecLock( "CB8", .T. ))
			CB8->CB8_FILIAL := xFilial( "CB8" )
			CB8->CB8_ORDSEP := CB7->CB7_ORDSEP
			CB8->CB8_ITEM   := SD2->D2_ITEM
			CB8->CB8_PEDIDO := SD2->D2_PEDIDO
			CB8->CB8_NOTA   := SD2->D2_DOC
			//CB8->CB8_SERIE  := SD2->D2_SERIE
			SerieNfId ("CB8",1,"CB8_SERIE",,,,SD2->D2_SERIE)				
			CB8->CB8_PROD   := SD2->D2_COD
			CB8->CB8_LOCAL  := SD2->D2_LOCAL
			CB8->CB8_LCALIZ := Space(15)
			CB8->CB8_SEQUEN := SD2->D2_ITEM
			CB8->CB8_LOTECT := SD2->D2_LOTECTL
			CB8->CB8_NUMLOT := SD2->D2_NUMLOTE
			CB8->CB8_NUMSER := SD2->D2_NUMSERI
			CB8->CB8_CFLOTE := "1"
			aadd(aRecSD2,{SD2->(Recno()),CB7->CB7_ORDSEP})
		Else
			CB8->(RecLock( "CB8", .f. ))
		EndIf
		CB8->CB8_QTDORI += SD2->D2_QUANT
		CB8->CB8_SALDOS += SD2->D2_QUANT
		If nEmbalagem == 1
			CB8->CB8_SALDOE += SD2->D2_QUANT
	    EndIf
		If	lACD100GI
			ExecBlock("ACD100GI",.F.,.F.)
		EndIf
		CB8->(MsUnLock())
	EndIf

	If cNotaSerie==Nil
		IncProc()
	EndIf
	SD2->( dbSkip() )
EndDo

CB7->(DbSetOrder(1))
For nI := 1 to len(aOrdSep)
	CB7->(DbSeek(xFilial("CB7")+aOrdSep[nI]))
	CB7->(RecLock("CB7"))
	CB7->CB7_STATUS := "0"  // nao iniciado
	CB7->(MsUnlock())
	If	lACDA100F
		ExecBlock("ACDA100F",.F.,.F.,{aOrdSep[nI]})
	EndIf
Next
For nI := 1 to len(aRecSD2)
	SD2->(DbGoto(aRecSD2[nI,1]))
	SD2->(RecLock("SD2",.F.))
	SD2->D2_ORDSEP := aRecSD2[nI,2]
	SD2->(MsUnlock())
Next
If !Empty(aLogOS)
	LogACDA100()
Endif
Return


STATIC Function GeraOSepProducao( cMarca, lInverte )
Local cOrdSep,aOrdSep := {},nI
Local cCodOpe
Local aRecSC2   := {}
Local cTipExp
Local aItemCB8  := {}
Local lSai      := .f.
Local cArm      := Space(Tamsx3("B1_LOCPAD")[1])
Local lFilItens := ExistBlock("ACDA100I")  //Ponto de Entrada para filtrar o processamento dos itens selecionados
Local cTM	    := GetMV("MV_CBREQD3")
Local lConsEst  := SuperGetMV("MV_CBRQEST",,.F.)  //Considera a Estrutura do Produto x Saldo na geracao da Ordem de Separacao
Local lParcial  := SuperGetMV("MV_CBOSPRC",,.F.)  //Permite ou nao gerar Ordens de Separacoes parciais
Local lGera		:= .T.
Local lA100CABE := ExistBlock("A100CABE")
Local lACD100GI := ExistBlock("ACD100GI")
Local lACDA100F := ExistBlock("ACDA100F")
Local lExtACDEMP := ExistBlock("ACD100EMP")
Local nSalTotIt := 0
Local nSaldoEmp := 0
Local aSaldoSBF := {}
Local aSaldoSDC := {}
Local nSldGrv   := 0
Local nRetSldEnd:= 0
Local nRetSldSDC:= 0
Local nSldAtu   := 0
Local nQtdEmpOS := 0
Local nPosEmp    
Local nX
Private aLogOS := {}
Private aEmp   := {}

// analisar a pergunta '00-Separcao,01-Separacao/Embalagem,02-Embalagem,03-Gera Nota,04-Imp.Nota,05-Imp.Volume,06-embarque,07-Requisita'
cTipExp := "00*"

If nReqMatOP == 1
	cTipExp += "07*" //Requisicao
EndIf

If nAglutArmOP == 1 // Aglutina armazem
	cTipExp +="08*"
EndIf

If nPreSep == 1 // Pre-Separacao
	cTipExp +="09*"
EndIf
/*Ponto de entrada, permite que o usuário realize o processamento conforme suas particularidades.*/
If	ExistBlock("ACD100VG")
	If ! ExecBlock("ACD100VG",.F.,.F.,)
		Return
	EndIf		
EndIf

SC2->( dbGoTop() )
ProcRegua( SC2->( LastRec() ), "oook" )
cCodOpe	 := cSeparador

SB2->(DbSetOrder(1))
SD4->(DbSetOrder(2))
SDC->(dbSetOrder(2))
CB7->(DbSetOrder(1))
While !SC2->( Eof() )

	If ! SC2->(IsMark("C2_OK",ThisMark(),ThisInv()))
		IncProc()
		SC2->(dbSkip())
		Loop
	EndIf

	If lFilItens
		If !ExecBlock("ACDA100I",.F.,.F.)
			SC2->(DbSkip())
			IncProc()
			Loop
		Endif
	Endif

	CB8->(DbSetOrder(6))
	If CB8->(DbSeek(xFilial("CB8")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN))
		If CB7->(DbSeek(xFilial("CB7")+CB8->CB8_ORDSEP)) .and. CB7->CB7_STATUS # "9" // Ordem em aberto
			//Grava o historico das geracoes:
			aadd(aLogOS,{"2","OP",SC2->(C2_NUM+C2_ITEM+C2_SEQUEN),"","","Existe uma Ordem de Separacao em aberto para esta Ordem de Producao","NAO_GEROU_OS"})
			IncProc()
			SC2->(dbSkip())
			Loop
		Endif
	EndIf
	lSai := .f.
	aEmp := {}
	SD4->(DbSeek(xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN))
	While SD4->(! Eof() .And. D4_FILIAL+Left(D4_OP,11) == xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)
		If Empty(SD4->D4_QUANT)
			SD4->(DbSkip())
			Loop
		Endif
		If lParcial .And. Localiza(SD4->D4_COD)// Se permitir parcial, controlar localização e nao existir composição de empenho, passa para o proximo.   
			If !CBArmProc(SD4->D4_COD,cTM)
				aSaldoSDC := RetSldSDC(SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_OP,.F.,"","",SD4->D4_TRT)
				If Empty(aSaldoSDC)
				    SD4->(DbSkip())
	             EndIf
			Else
				aSaldoSBF := RetSldEnd(SD4->D4_COD,.f.)
				If Empty(aSaldoSBF)
					SD4->(DbSkip())
				EndIf
			EndIf  
	    EndIf
		SB1->(DBSetOrder(1))
		If SB1->(DbSeek(xFilial("SB1")+SD4->D4_COD)) .And. IsProdMOD(SD4->D4_COD)
			SD4->(DbSkip())
			Loop
		Endif
		If lExtACDEMP
			lACD100EMP := ExecBlock("ACD100EMP",.F.,.F.,{SD4->D4_OP,SD4->D4_COD,SD4->D4_QUANT})
			lACD100EMP := If(ValType(lACD100EMP)=="L",lACD100EMP,.T.)
			If !lACD100EMP
				SD4->(DbSkip())
				Loop
			Endif
		Endif
		If !Localiza(SD4->D4_COD) // Nao controla endereco
			SB2->(DbSeek(xFilial("SB2")+SD4->(D4_COD+D4_LOCAL)))
			nSldAtu := If(CBArmProc(SD4->D4_COD,cTM),SB2->B2_QATU,SaldoSB2())
			nPosEmp := Ascan(aEmp,{|x| x[02] == SD4->D4_COD})
			If nPosEmp == 0
				aadd(aEmp,{SD4->D4_OP,SD4->D4_COD,SD4->D4_QUANT,nSldAtu,0,0,0})
			Else
				aEmp[nPosEmp,03] += SD4->D4_QUANT
			Endif
			SD4->(DbSkip())
			Loop
		Endif
		If !CBArmProc(SD4->D4_COD,cTM) .AND. If(!lParcial,(SD4->D4_QUANT > (nRetSldSDC := RetSldSDC(SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_OP,.t.,"","",SD4->D4_TRT))),.F.) .AND. !lConsEst  
			//Grava o historico das geracoes:
			aadd(aLogOS,{"2","OP",SD4->D4_OP,SD4->D4_COD,"","O produto "+Alltrim(SD4->D4_COD)+" nao encontra-se empenhado (SD4 x SDC)","NAO_GEROU_OS"})
			lSai := .t.
		ElseIf CBArmProc(SD4->D4_COD,cTM) .AND. If(!lParcial,(SD4->D4_QUANT > (nRetSldEnd := RetSldEnd(SD4->D4_COD,.t.))),.F.) .AND. !lConsEst
			//Grava o historico das geracoes:
			aadd(aLogOS,{"2","OP",SD4->D4_OP,SD4->D4_COD,"","O produto "+Alltrim(SD4->D4_COD)+" nao possui saldo enderecado suficiente."+CHR(13)+CHR(10)+"        (ou existem Ordens de Separacao ainda nao requisitadas)","NAO_GEROU_OS"})
			lSai := .t.
		EndIf
		nPosEmp := Ascan(aEmp,{|x| x[02] == SD4->D4_COD})
		If nPosEmp == 0
			aadd(aEmp,{SD4->D4_OP,SD4->D4_COD,SD4->D4_QUANT,If(CBArmProc(SD4->D4_COD,cTM),nRetSldEnd,nRetSldSDC),0,0,0})
		Else
			aEmp[nPosEmp,03] += SD4->D4_QUANT
		Endif
		SD4->(DbSkip())
	EndDo
	If lConsEst  //Considera a Estrutura do Produto x Saldo na geracao da Ordem de Separacao
		If SemSldOS()
			//Grava o historico das geracoes:
			aadd(aLogOS,{"2","OP",SD4->D4_OP,SD4->D4_COD,"","Os itens empenhados nao possuem saldo em estoque suficiente para a producao de uma unidade do produto da OP","NAO_GEROU_OS"})
			lSai := .t.
		Endif
	Endif
	If lSai
		IncProc()
		SC2->(dbSkip())
		Loop
	EndIf

	SD4->(DbSeek(xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN))
	While SD4->(!Eof() .And. D4_FILIAL+Left(D4_OP,11) == xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)
		If Empty(SD4->D4_QUANT)
			SD4->(DbSkip())
			Loop
		EndIf  
		If lParcial .And. Localiza(SD4->D4_COD)// Se permitir parcial, controlar localização e nao existir composição de empenho, passa para o proximo.   
			If !CBArmProc(SD4->D4_COD,cTM)
				aSaldoSDC := RetSldSDC(SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_OP,.F.,SD4->D4_LOTECTL,SD4->D4_NUMLOTE,SD4->D4_TRT)
				If Empty(aSaldoSDC)
					aadd(aLogOS,{"2","OP",SD4->D4_OP,SD4->D4_COD,"","O produto "+Alltrim(SD4->D4_COD)+" nao encontra-se empenhado (SD4 x SDC)","NAO_GEROU_OS"})
				    SD4->(DbSkip())
				    Loop
	             EndIf
			Else
				aSaldoSBF := RetSldEnd(SD4->D4_COD,.f.)
				If Empty(aSaldoSBF)
					aadd(aLogOS,{"2","OP",SD4->D4_OP,SD4->D4_COD,"","O produto "+Alltrim(SD4->D4_COD)+" nao possui saldo enderecado suficiente."+CHR(13)+CHR(10)+"        (ou existem Ordens de Separacao ainda nao requisitadas)","NAO_GEROU_OS"})
					SD4->(DbSkip())
					Loop
				EndIf
			EndIf  
	    EndIf
		SB1->(DBSetOrder(1))
		If SB1->(DbSeek(xFilial("SB1")+SD4->D4_COD)) .And. IsProdMOD(SD4->D4_COD)
			SD4->(DbSkip())
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada na Geração das Ordens de Separação.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lExtACDEMP
			lACD100EMP := ExecBlock("ACD100EMP",.F.,.F.,{SD4->D4_OP,SD4->D4_COD,SD4->D4_QUANT})
			lACD100EMP := If(ValType(lACD100EMP)=="L",lACD100EMP,.T.)
			If !lACD100EMP
				SD4->(DbSkip())
				Loop
			Endif
		Endif
		
		If !("08*" $ cTipExp)  // gera ordem de separacao por armazem
			cArm :=If(CBArmProc(SD4->D4_COD,cTM),SB1->B1_LOCPAD,SD4->D4_LOCAL)
		Else  // gera ordem de separa com todos os armazens
			cArm :=Space(Tamsx3("B1_LOCPAD")[1])
		EndIf
		If "09*" $ cTipExp // AGLUTINA PARA PRE-SEPARACAO
			cOP:= Space(Len(SD4->D4_OP))
		Else
			cOP:= SD4->D4_OP
		Endif
			CB7->(DbSetOrder(5))
		If ! CB7->(DbSeek(xFilial("CB7")+cOP+cArm+" "))
			cOrdSep   := GetSX8Num( "CB7", "CB7_ORDSEP" )
			CB7->(RecLock( "CB7", .T. ))
			CB7->CB7_FILIAL := xFilial( "CB7" )
			CB7->CB7_ORDSEP := cOrdSep
			CB7->CB7_OP     := cOP
			CB7->CB7_LOCAL  := cArm
			CB7->CB7_DTEMIS := dDataBase
			CB7->CB7_HREMIS := Time()
			CB7->CB7_STATUS := " "   // gravar STATUS de nao iniciada somente depois do processo
			CB7->CB7_CODOPE := cCodOpe
			CB7->CB7_PRIORI := "1"
			CB7->CB7_ORIGEM := "3"
			CB7->CB7_TIPEXP := cTipExp 
			If	lA100CABE
				ExecBlock("A100CABE",.F.,.F.)
			EndIf
			ConfirmSX8()
			//Grava o historico das geracoes:
			aadd(aLogOS,{"1","OP",SD4->D4_OP,"",cArm,"",CB7->CB7_ORDSEP})
			aadd(aOrdSep,cOrdSep)
		EndIf

		If Localiza(SD4->D4_COD) //controla endereco

			If !CBArmProc(SD4->D4_COD,cTM)
				aSaldoSDC := RetSldSDC(SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_OP,.F.,SD4->D4_LOTECTL,SD4->D4_NUMLOTE,SD4->D4_TRT)
				nSalTotIt := 0
				For nX:=1 to Len(aSaldoSDC)
					nSalTotIt+=aSaldoSDC[nX,7]
				Next
 			    If lConsEst
	 			    nSaldoEmp := RetEmpOS(lConsEst,SD4->D4_COD,SD4->D4_QUANT)
 			    EndIf
 			    
				// Separacoes sao geradas conf. empenhos nos enderecos (SDC)
				For nX:=1 to Len(aSaldoSDC)
					lGera := .T.
	 			    If !lConsEst
	 				    nSaldoEmp := RetEmpOS(lConsEst,SD4->D4_COD,aSaldoSDC[nX,7])
                    EndIf
					If (!lConsEst .And. !lParcial) .And. SD4->D4_QTDEORI <> nSalTotIt
						Exit
					ElseIf lConsEst .And. nSaldoEmp == 0
						lGera := .F.
					Else
						nSldGrv   := aSaldoSDC[nX,7]
						nSaldoEmp -= aSaldoSDC[nX,7]
					EndIf
					If lGera
						cOrdSep := CB7->CB7_ORDSEP
						CB8->(RecLock( "CB8", .T. ))
						CB8->CB8_FILIAL := xFilial( "CB8" )
						CB8->CB8_ORDSEP := cOrdSep
						CB8->CB8_OP     := SD4->D4_OP
						CB8->CB8_ITEM   := RetItemCB8(cOrdSep,aItemCB8)
						CB8->CB8_PROD   := SD4->D4_COD
						CB8->CB8_LOCAL  := aSaldoSDC[nX,2]
						CB8->CB8_QTDORI := nSldGrv
						CB8->CB8_SALDOS := nSldGrv
						If nEmbalagem == 1
							CB8->CB8_SALDOE := nSldGrv
						EndIf
						CB8->CB8_LCALIZ := aSaldoSDC[nX,3]
						CB8->CB8_SEQUEN := ""
						CB8->CB8_LOTECT := aSaldoSDC[nX,4]
						CB8->CB8_NUMLOT := aSaldoSDC[nX,5]
						CB8->CB8_NUMSER := aSaldoSDC[nX,6]
						CB8->CB8_CFLOTE := "1"
						If "09*" $ cTipExp
							CB8->CB8_SLDPRE := nSldGrv
						EndIf
						If	lACD100GI
							ExecBlock("ACD100GI",.F.,.F.)
						EndIf
						CB8->(MsUnLock())
					EndIf
				Next
				SD4->(DbSkip())	
			Else
				aSaldoSBF := RetSldEnd(SD4->D4_COD,.f.)
 			    If lConsEst
	 			    nSaldoEmp := RetEmpOS(lConsEst,SD4->D4_COD,SD4->D4_QUANT)
 			    EndIf	
				For nX:=1 to Len(aSaldoSBF)
	 			    If !lConsEst
	 				    nSaldoEmp := RetEmpOS(lConsEst,SD4->D4_COD,SD4->D4_QUANT)
                    EndIf
					If lConsEst .And. nSaldoEmp == 0
						SD4->(DbSkip())
						Exit
						nSaldoEmp -= aSaldoSDC[nX,7]
					EndIf
					cOrdSep := CB7->CB7_ORDSEP
					CB8->(RecLock( "CB8", .T. ))
					CB8->CB8_FILIAL := xFilial( "CB8" )
					CB8->CB8_ORDSEP := cOrdSep
					CB8->CB8_OP     := SD4->D4_OP
					CB8->CB8_ITEM   := RetItemCB8(cOrdSep,aItemCB8)
					CB8->CB8_PROD   := SD4->D4_COD
					CB8->CB8_LOCAL  := aSaldoSBF[nX,2]
					CB8->CB8_QTDORI := SD4->D4_QTDEORI
					CB8->CB8_SALDOS := nSaldoEmp
					If nEmbalagem == 1
						CB8->CB8_SALDOE := nSaldoEmp
	                EndIf
					CB8->CB8_LCALIZ := aSaldoSBF[nX,3]
					CB8->CB8_SEQUEN := ""
					CB8->CB8_LOTECT := aSaldoSBF[nX,4]
					CB8->CB8_NUMLOT := aSaldoSBF[nX,5]
					CB8->CB8_NUMSER := aSaldoSBF[nX,6]
					CB8->CB8_CFLOTE := "1"
					If "09*" $ cTipExp
						CB8->CB8_SLDPRE := nSaldoEmp
					EndIf
					If	lACD100GI
						ExecBlock("ACD100GI",.F.,.F.)
					EndIf
					CB8->(MsUnLock())
					SD4->(DbSkip())					
				Next Nx
			Endif
		Else
			cOrdSep   := CB7->CB7_ORDSEP
			nQtdEmpOS := RetEmpOS(lConsEst,SD4->D4_COD,SD4->D4_QUANT)
			CB8->(RecLock( "CB8", .T. ))
			CB8->CB8_FILIAL := xFilial( "CB8" )
			CB8->CB8_ORDSEP := cOrdSep
			CB8->CB8_OP     := SD4->D4_OP
			CB8->CB8_ITEM   := RetItemCB8(cOrdSep,aItemCB8)
			CB8->CB8_PROD   := SD4->D4_COD
			CB8->CB8_LOCAL  := If(CBArmProc(SD4->D4_COD,cTM),SB1->B1_LOCPAD,SD4->D4_LOCAL)
			CB8->CB8_QTDORI := nQtdEmpOS
			CB8->CB8_SALDOS := nQtdEmpOS
			If nEmbalagem == 1
				CB8->CB8_SALDOE := nQtdEmpOS
			EndIf
			CB8->CB8_LCALIZ := Space(15)
			CB8->CB8_SEQUEN := ""
			CB8->CB8_LOTECT := SD4->D4_LOTECTL
			CB8->CB8_NUMLOT := SD4->D4_NUMLOTE
			CB8->CB8_CFLOTE := "1"
			If "09*" $ cTipExp
				CB8->CB8_SLDPRE := nQtdEmpOS
			EndIf
			If	lACD100GI
				ExecBlock("ACD100GI",.F.,.F.)
			EndIf
			CB8->(MsUnLock())
			SD4->(DbSkip())
		Endif
	EndDo
	aadd(aRecSC2,SC2->(Recno()))
	IncProc()
	SC2->( dbSkip() )
EndDo

CB7->(DbSetOrder(1))
For nI := 1 to len(aOrdSep)
	CB7->(DbSeek(xFilial("CB7")+aOrdSep[nI]))
	CB7->(RecLock("CB7"))
	CB7->CB7_STATUS := "0"  // nao iniciado
	CB7->(MsUnlock())
	If	lACDA100F
		ExecBlock("ACDA100F",.F.,.F.,{aOrdSep[nI]})
	EndIf
Next
For nI := 1 to len(aRecSC2)
	SC2->(DbGoto(aRecSC2[nI]))
	SC2->(RecLock("SC2"))
	SC2->C2_ORDSEP := cOrdSep
	SC2->(MsUnlock())
Next

If lParcial .and. Empty(aOrdSep) .and. !Empty(aLogOS) // Quando permitir parcial somente gera log se nao existir nenhuma item na OS
	LogACDA100()
Elseif !lparcial .and.!Empty(aLogOS)
	LogACDA100()
EndIf

Return

Static Function RetItemCB8(cOrdSep,aItemCB8)

Local nPos := Ascan(aItemCB8,{|x| x[1] == cOrdSep})
Local cItem :=' '

If Empty(nPos )
	AAdd(aItemCB8,{cOrdSep,'00'})
	nPos := len(aItemCB8)
EndIF

cItem := Soma1(aItemcb8[nPos,2])
aItemcb8[nPos,2]:= cItem

Return cItem

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LogACDA100³ Autor ³ Henrique Gomes Oikawa ³ Data ³ 23/09/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibicao do log das geracoes das Ordens de Separacao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Apos a geracao das OS sao exibidas todas as informacoes que³±±
±±³          ³ ocorreram durante o processo                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function LogACDA100()
Local i, j, k
Local cChaveAtu, cPedCli, cOPAtual

//Cabecalho do Log de processamento:
AutoGRLog(Replicate("=",75))
AutoGRLog("                         I N F O R M A T I V O")
AutoGRLog("               H I S T O R I C O   D A S   G E R A C O E S")

//Detalhes do Log de processamento:
AutoGRLog(Replicate("=",75))
AutoGRLog("I T E N S   P R O C E S S A D O S :")
AutoGRLog(Replicate("=",75))
If aLogOS[1,2] == "Pedido"
	aLogOS := aSort(aLogOS,,,{|x,y| x[01]+x[10]+x[03]+x[04]+x[05]+x[06]+x[07]+x[08]<y[01]+y[10]+y[03]+y[04]+y[05]+y[06]+y[07]+y[08]})
	// Status Ord.Sep(1=Gerou;2=Nao Gerou) + Ordem Separacao + Pedido + Cliente + Loja + Item + Produto + Local
	cChaveAtu := ""
	cPedCli   := ""
	For i:=1 to len(aLogOs)
		If aLogOs[i,10] <> cChaveAtu .OR. (aLogOs[i,03]+aLogOs[i,04] <> cPedCli)
			If !Empty(cChaveAtu)
				AutoGRLog(Replicate("-",75))
			Endif
			j:=0
			k:=i  //Armazena o conteudo do contador do laco logico principal (i) pois o "For" j altera o valor de i;
			cChaveAtu := aLogOs[i,10]
			For j:=k to len(aLogOs)
				If aLogOs[j,10] <> cChaveAtu
					Exit
				Endif
				If Empty(aLogOs[j,08]) //Aglutina Armazem
					AutoGRLog("Pedido: "+aLogOs[j,03]+" - Cliente: "+aLogOs[j,04]+"-"+aLogOs[j,05])
				Else
					AutoGRLog("Pedido: "+aLogOs[j,03]+" - Cliente: "+aLogOs[j,04]+"-"+aLogOs[j,05]+" - Local: "+aLogOs[j,08])
				Endif
				cPedCli := aLogOs[j,03]+aLogOs[j,04]
				If aLogOs[j,10] == "NAO_GEROU_OS"
					Exit
				Endif
				i:=j
			Next
			AutoGRLog("Ordem de Separacao: "+If(aLogOs[i,01]=="1",aLogOs[i,10],"N A O  G E R A D A"))
			If aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
				AutoGRLog("Motivo: ")
			Endif
		Endif
		If aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
			AutoGRLog("Item: "+aLogOs[i,06]+" - Produto: "+AllTrim(aLogOs[i,07])+" - Local: "+aLogOs[i,08]+" ---> "+aLogOs[i,09])
		Endif
	Next
Elseif aLogOS[1,2] == "Nota"
	aLogOS := aSort(aLogOS,,,{|x,y| x[01]+x[08]+x[03]+x[04]+x[05]+x[06]<y[01]+y[08]+y[03]+y[04]+y[05]+y[06]})
	// Status Ord.Sep(1=Gerou;2=Nao Gerou) + Ordem Separacao + Nota + Serie + Cliente + Loja
	cChaveAtu := ""
	For i:=1 to len(aLogOs)
		If aLogOs[i,08] <> cChaveAtu
			If !Empty(cChaveAtu)
				AutoGRLog(Replicate("-",75))
			Endif
			cChaveAtu := aLogOs[i,08]
			AutoGRLog("Nota: "+aLogOs[i,3]+"/"+aLogOs[i,04]+" - Cliente: "+aLogOs[i,05]+"-"+aLogOs[i,06])
			AutoGRLog("Ordem de Separacao: "+If(aLogOs[i,01]=="1",aLogOs[i,08],"N A O  G E R A D A"))
			If aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
				AutoGRLog("Motivo: ")
			Endif
		Endif
	Next
Else  //Ordem de Producao
	aLogOS := aSort(aLogOS,,,{|x,y| x[01]+x[07]+x[03]+x[04]<y[01]+y[07]+y[03]+y[04]})
	// Status Ord.Sep(1=Gerou;2=Nao Gerou) + Ordem Separacao + Ordem Producao + Produto
	cChaveAtu := ""
	cOPAtual  := ""
	For i:=1 to len(aLogOs)
		If aLogOs[i,07] <> cChaveAtu .OR. aLogOs[i,03] <> cOPAtual
			If !Empty(cChaveAtu)
				AutoGRLog(Replicate("-",75) )
			Endif
			j:=0
			k:=i  //Armazena o conteudo do contador do laco logico principal (i) pois o "For" j altera o valor de i;
			cChaveAtu := aLogOs[i,07]
			For j:=k to len(aLogOs)
				If aLogOs[j,07] <> cChaveAtu
					Exit
				Endif
				If Empty(aLogOs[j,05]) //Aglutina Armazem
					AutoGRLog("Ordem de Producao: "+aLogOs[i,03])
				Else
					AutoGRLog("Ordem de Producao: "+aLogOs[i,03]+" - Local: "+aLogOs[j,05])
				Endif
				cOPAtual := aLogOs[j,03]
				If aLogOs[j,07] == "NAO_GEROU_OS"
					Exit
				Endif
				i:=j
			Next
			AutoGRLog("Ordem de Separacao: "+If(aLogOs[i,01]=="1",aLogOs[i,07],"N A O  G E R A D A"))
			If aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
				AutoGRLog("Motivo: ")
			Endif
		Endif
		If aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
			AutoGRLog(" ---> "+aLogOs[i,06])
		Endif
	Next
Endif
MostraParam(aLogOS[1,2])
MostraErro()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MostraParam ³ Autor ³ Henrique Gomes Oikawa ³ Data ³ 28/09/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibicao dos parametros da geracao da Ordem de Separacao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MostraParam(cTipGer)
Local cPergParam  := ""
Local cPergConfig := ""
Local cDescTipGer := ""
Local nTamSX1     := 0 //Len(SX1->X1_GRUPO)
Local aPerg       := {}
Local aParam      := {}
Local ni          := 0
Local ci          := 0
Local aLogs       := {}

_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
dbSelectArea(_cAliasSX1)
(_cAliasSX1)->(dbSetOrder(1))

nTamSX1     := Len((_cAliasSX1)->X1_GRUPO)

If cTipGer == "Pedido"
	cPergParam  := PADR('AIA102',nTamSX1)
	cPergConfig := PADR('AIA106',nTamSX1)
	cDescTipGer := 'PEDIDO DE VENDA'
	aAdd(aParam,nConfLote)
	aAdd(aParam,nEmbSimul)
	aAdd(aParam,nEmbalagem)
	If cPaisLoc == "BRA"
		aAdd(aParam,nGeraNota)
		aAdd(aParam,nImpNota)
	EndIf
	aAdd(aParam,nImpEtVol)
	aAdd(aParam,nEmbarque)
	aAdd(aParam,nAglutPed)
	aAdd(aParam,nAglutArm)
	aAdd(aParam,nPreSep)
Elseif cTipGer == "Nota"
	cPergParam  := PADR('AIA103',nTamSX1)
	cPergConfig := PADR('AIA107',nTamSX1)
	cDescTipGer := 'NOTA FISCAL'
	aAdd(aParam,nEmbSimuNF)
	aAdd(aParam,nEmbalagNF)
	aAdd(aParam,nImpNotaNF)
	aAdd(aParam,nImpVolNF)
	aAdd(aParam,nEmbarqNF)
Else //OP
	cPergParam  := PADR('AIA104',nTamSX1)
	cPergConfig := PADR('AIA108',nTamSX1)
	cDescTipGer := 'ORDEM DE PRODUCAO'
	aAdd(aParam,nReqMatOP)
	aAdd(aParam,nAglutArmOP)
Endif

aAdd(aPerg,{"P A R A M E T R O S : "+cDescTipGer,cPergParam})
aAdd(aPerg,{"C O N F I G U R A C O E S : "+cDescTipGer,cPergConfig})
//-- Carrega parametros SX1
//SX1->(DbSetOrder(1))
For ni := 1 To Len(aPerg)
	ci := 1
	aAdd(aLogs,{aPerg[ni,2],{}})
	(_cAliasSX1)->(DbSeek(aPerg[ni,2]))
	While (_cAliasSX1)->(!Eof() .AND. X1_GRUPO == aPerg[ni,2])
		If	(_cAliasSX1)->X1_GSC == 'G'
			cTexto := (_cAliasSX1)->("Pergunta "+X1_ORDEM+": "+X1_PERGUNT+Alltrim(X1_CNT01))
		Else
			If	ni == 1
				cTexto := (_cAliasSX1)->("Pergunta "+X1_ORDEM+": "+X1_PERGUNT+If(X1_PRESEL==1,"Sim","Nao"))
			Else
				cTexto := (_cAliasSX1)->("Pergunta "+X1_ORDEM+": "+X1_PERGUNT+If(aParam[ci++]==1,"Sim","Nao"))
			EndIf
		EndIf
		aAdd(aLogs[ni,2],cTexto)
		(_cAliasSX1)->(dbSkip())
	EndDo
Next
//-- Gera Log
For ni := 1 To Len(aPerg)
	AutoGRLog(Replicate("=",75))
	AutoGRLog(aPerg[ni,1])
	AutoGRLog(Replicate("=",75))
	For ci := 1 To Len(aLogs[ni,2])
		AutoGRLog(aLogs[ni,2,ci])
	Next
Next
AutoGRLog(Replicate("=",75))
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TELAERRO    ºAutor  ³Diego Rodrigues º Data ³  11/08/2023   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Sub-Rotina para demonstrar os lotes sem saldo na tela      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function TELAERRO(_aTesEst)
Private oDlgError
Private oBrowse

//Monta o array de campos
aCpoCom := {"Pedido", "TES", "Descrição TEs", "Mov. Estoque"}

Define MsDialog oDlgError From 000,000 To 500,750 Title "Tes sem movimentação de estoque" Pixel

//Monta a barra de botões
Define ButtonBar oBar size 20,20 3D TOP of oDlgError
Define Button Resource "CANCEL" Of oBar Action (::End()) //Prompt "Fechar" ToolTip "Fecha a Tela" 
oBar:bRClicked:={ || AllwaysTrue() }

@ 025,005 Say "As TES listadas abaixo não movimentam estoque, favor avisar o responsavel na contabilidade. " Pixel Of oDlgError

oBrowse := TWBrowse():New(3.0, 0.5, 370, 190,, aCpoCom, {50,50,150,50}, oDlgError,,,,,,,,,,,, .T.)
oBrowse:SetArray(_aTesEst)
oBrowse:bLine := {||{ _aTesEst[oBrowse:nAt,01],;
_aTesEst[oBrowse:nAt,02],;
_aTesEst[oBrowse:nAt,03],;
_aTesEst[oBrowse:nAt,04] } }
oBrowse:Refresh()

Activate MsDialog oDlgError Centered

MsgInfo("Devido a problemas relacionados com a TES a Ordem de separação não será gerada. Avise o departamento contabil. IMPORTANTE: Estonar as liberações de estoque após os devidos ajustes.","[RFATA007_090] - Aviso ")

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TELAERRO    ºAutor  ³Diego Rodrigues º Data ³  11/08/2023   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Sub-Rotina para demonstrar os lotes sem saldo na tela      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function TELAERRO2(_aSepEst)
Private oDlgError
Private oBrowse

//Monta o array de campos
aCpoCom := {"Produto", "Qtd Pedido", "Qtd. Liberada"}

Define MsDialog oDlgError From 000,000 To 500,750 Title "[MTA455SLD] - Produtos que não constam na ordem de separação" Pixel

//Monta a barra de botões
Define ButtonBar oBar size 20,20 3D TOP of oDlgError
Define Button Resource "CANCEL" Of oBar Action (::End()) //Prompt "Fechar" ToolTip "Fecha a Tela" 
oBar:bRClicked:={ || AllwaysTrue() }

@ 025,005 Say "Os produtos abaixo cortados na liberação de estoque : " Pixel Of oDlgError

oBrowse := TWBrowse():New(3.0, 0.5, 370, 190,, aCpoCom, {50,50,150,50}, oDlgError,,,,,,,,,,,, .T.)
 oBrowse:SetArray(_aSepEst)
oBrowse:bLine := {||{ _aSepEst[oBrowse:nAt,01],;
_aSepEst[oBrowse:nAt,02],;
_aSepEst[oBrowse:nAt,03]} }
oBrowse:Refresh()

Activate MsDialog oDlgError Centered

MsgInfo("Devido a problemas com os itens na ordem de separação. Avise o administrador do Sistema.","[RFATA007_091] - Aviso ")
Return()


