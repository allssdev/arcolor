#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} RFATA005
@description Rotina de validação das informações dos itens liberados, para a chamada da rotina de geração das Ordens de Separação, baseado nos pedidos de vendas. Rotina chamada por botão no Ponto de Entrada "MA455MNU" (BASE: ACDA100GR()).
@author Anderson C. P. Coelho (ALL System Solutions)
@since 21/03/2013
@version 1.0
@param _cOrigem, caracter, Indica de onde a rotina foi chamada.
@type function
@see https://allss.com.br
@history 06/03/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Revisão para adequação dda rastreabilidade.
/*/
user function RFATA005(_cOrigem)
	local _aSavArea    := GetArea()
	local _aSavSC9     := SC9->(GetArea())
	local _aSavSC5     := SC5->(GetArea())
	local _aRotBkp     := {}
	local aNewFil      := {}
	local _cRotina     := "RFATA005"
	local cArqInd      := ""
	local cChaveInd    := ""
	local cCondicao    := ""
	local cFilSC9      := ".T."
	local cFilSD2      := ".T."
	local cFilSC2      := ".T."
	local lMark        := .T.

	private nConfLote
	private nEmbSimul
	private nEmbalagem
	private nGeraNota
	private nImpNota
	private nImpEtVol
	private nEmbarque
	private nAglutPed
	private nAglutArm
	private nEmbSimuNF
	private nEmbalagNF
	private nImpNotaNF
	private nImpVolNF
	private nEmbarqNF
	private nReqMatOP
	private nAglutArmOP
	private nIndice    := 0
	private nOrigExp   := ""
	private cSeparador := Space(6)	//variavel utilizada para armazenar o separador da pergunte AIA102, pois o mesmo estava sendo sobreposto por outra pergunte, ao precionar F12 na tela de geracao
	private _cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
	private _cSC9TMP   := GetNextAlias()
	private cPerg      := ""

	default aRotina    := {}
	default _cOrigem   := ""

	_aRotBkp           := aClone(aRotina)

	if Select(_cAliasSX1) > 0
		(_cAliasSX1)->(dbCloseArea())
	endif
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))

	cPerg := Padr("AIA102",len((_cAliasSX1)->X1_GRUPO))
	//Perguntas da liberação de estoque
	Pergunte(Padr("AIA101",len((_cAliasSX1)->X1_GRUPO)),.F.)
	nOrigExp := MV_PAR01 := 1
	AtivaF12(nOrigExp) // carrega os valores das perguntes relacionados a configuracoes

	Pergunte(cPerg,.F.)
	if AllTrim(FunName())=="RFATA006"
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		SC5->(MsSeek(xFilial("SC5") + TRBTMP->C9_PEDIDO,.T.,.F.))
		if (_cAliasSX1)->(MsSeek(cPerg+"02",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_CNT01 := MV_PAR02 := SC5->C5_NUM
			(_cAliasSX1)->(MSUNLOCK())
		endif
		if (_cAliasSX1)->(MsSeek(cPerg+"03",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_CNT01 := MV_PAR03 := SC5->C5_NUM
			(_cAliasSX1)->(MSUNLOCK())
		endif
		if (_cAliasSX1)->(MsSeek(cPerg+"04",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_CNT01 := MV_PAR04 := Replicate(Space(01),TamSx3("A1_COD" )[01])
			(_cAliasSX1)->(MSUNLOCK())
		endif
		if (_cAliasSX1)->(MsSeek(cPerg+"05",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_CNT01 := MV_PAR05 := Replicate(Space(01),TamSx3("A1_LOJA")[01])
			(_cAliasSX1)->(MSUNLOCK())
		endif
		if (_cAliasSX1)->(MsSeek(cPerg+"06",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_CNT01 := MV_PAR06 := Replicate("Z",TamSx3("A1_COD" )[01])
			(_cAliasSX1)->(MSUNLOCK())
		endif
		if (_cAliasSX1)->(MsSeek(cPerg+"07",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_CNT01 := MV_PAR07 := Replicate("Z",TamSx3("A1_LOJA")[01])
			(_cAliasSX1)->(MSUNLOCK())
		endif
		if (_cAliasSX1)->(MsSeek(cPerg+"08",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_CNT01 := MV_PAR08 := "19900101"
			(_cAliasSX1)->(MSUNLOCK())
		endif
		if (_cAliasSX1)->(MsSeek(cPerg+"09",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_CNT01 := MV_PAR09 := "20491231"
			(_cAliasSX1)->(MSUNLOCK())
		endif
		if (_cAliasSX1)->(MsSeek(cPerg+"10",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_PRESEL := MV_PAR10 := 2
			(_cAliasSX1)->(MSUNLOCK())
		endif
	elseif AllTrim(FunName())=="MATA455" .OR. AllTrim(FunName())== "RFATA026"
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		SC5->(MsSeek(xFilial("SC5") + SC9->C9_PEDIDO,.T.,.F.))
		if (_cAliasSX1)->(MsSeek(cPerg+"02",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_CNT01 := MV_PAR02 := SC9->C9_PEDIDO
			(_cAliasSX1)->(MSUNLOCK())
		endif
		if (_cAliasSX1)->(MsSeek(cPerg+"03",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_CNT01 := MV_PAR03 := SC9->C9_PEDIDO
			(_cAliasSX1)->(MSUNLOCK())
		endif
		if (_cAliasSX1)->(MsSeek(cPerg+"04",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_CNT01 := MV_PAR04 := Replicate(Space(01),TamSx3("A1_COD" )[01])
			(_cAliasSX1)->(MSUNLOCK())
		endif
		if (_cAliasSX1)->(MsSeek(cPerg+"05",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_CNT01 := MV_PAR05 := Replicate(Space(01),TamSx3("A1_LOJA")[01])
			(_cAliasSX1)->(MSUNLOCK())
		endif
		if (_cAliasSX1)->(MsSeek(cPerg+"06",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_CNT01 := MV_PAR06 := Replicate("Z",TamSx3("A1_COD" )[01])
			(_cAliasSX1)->(MSUNLOCK())
		endif
		if (_cAliasSX1)->(MsSeek(cPerg+"07",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_CNT01 := MV_PAR07 := Replicate("Z",TamSx3("A1_LOJA")[01])
			(_cAliasSX1)->(MSUNLOCK())
		endif
		if (_cAliasSX1)->(MsSeek(cPerg+"08",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_CNT01 := "19900101"
			(_cAliasSX1)->(MSUNLOCK())
			MV_PAR08 := STOD((_cAliasSX1)->X1_CNT01)
		endif
		if (_cAliasSX1)->(MsSeek(cPerg+"09",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_CNT01 := "20491231"
			(_cAliasSX1)->(MSUNLOCK())
			MV_PAR09 := STOD((_cAliasSX1)->X1_CNT01)
		endif
		if (_cAliasSX1)->(MsSeek(cPerg+"10",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_PRESEL := MV_PAR10 := 2
			(_cAliasSX1)->(MSUNLOCK())
		endif
	endif

	if ExistBlock("RCFGASX1")
		U_RCFGASX1(cPerg,"02",MV_PAR02)
		U_RCFGASX1(cPerg,"03",MV_PAR03)
		U_RCFGASX1(cPerg,"04",MV_PAR04)
		U_RCFGASX1(cPerg,"05",MV_PAR05)
		U_RCFGASX1(cPerg,"06",MV_PAR06)
		U_RCFGASX1(cPerg,"07",MV_PAR07)
		U_RCFGASX1(cPerg,"08",MV_PAR08)
		U_RCFGASX1(cPerg,"09",MV_PAR09)
		U_RCFGASX1(cPerg,"10",MV_PAR10)
	endif
	if Pergunte(cPerg,.T.)
		if Existblock("RFATA007")
			aRotina    := { {"&Gerar","U_RFATA007('"+_cOrigem+"')" ,0,1} }
		else
			aRotina    := { {"&Gerar","ACDA100_Grava",0,1} }
		endif
		cSeparador := MV_PAR01
		nPreSep    := MV_PAR10
		if Select(_cSC9TMP)
			(_cSC9TMP)->(dbCloseArea())
		endif
		BeginSql Alias _cSC9TMP
			SELECT DISTINCT C9_FILIAL, C9_PEDIDO
			FROM %table:SC9% SC9 (NOLOCK)
			WHERE SC9.C9_FILIAL        = %xFilial:SC9%
			  AND SC9.C9_BLEST         = %Exp:''%
			  AND SC9.C9_BLCRED        = %Exp:''%
			  AND SC9.C9_BLOQUEI       = %Exp:''%
			  AND SC9.C9_ORDSEP        = %Exp:''%
			  AND SC9.C9_PEDIDO  BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR03%
			  AND SC9.C9_CLIENTE BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR06%
			  AND SC9.C9_LOJA    BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR07%
			  AND NOT EXISTS (
	                             SELECT TOP 1 1
	                             FROM %table:SC9% SC9X (NOLOCK)
	                             WHERE SC9X.C9_FILIAL        = %xFilial:SC9%
	                               AND SC9X.C9_PEDIDO        = SC9.C9_PEDIDO
	                               AND SC9X.C9_NFISCAL       = %Exp:''%
	                               AND SC9X.C9_CLIENTE       = SC9.C9_CLIENTE
	                               AND SC9X.C9_LOJA          = SC9.C9_LOJA
	                               AND (SC9X.C9_BLEST+SC9X.C9_BLCRED) <> %Exp:''%
	                               AND SC9X.%NotDel%
	                             )
			  AND SC9.%NotDel%
			ORDER BY C9_FILIAL, C9_PEDIDO
		EndSql
		//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",GetLastQuery()[02])
		dbSelectArea(_cSC9TMP)
		if !(_cSC9TMP)->(EOF())
			dbSelectArea("SC9")
			SC9->(dbSetOrder(1))
			cArqInd   := CriaTrab(, .F.)
			cChaveInd := IndexKey()
	/*
			cCondicao := "C9_PEDIDO  >='"+mv_par02+"'.And.C9_PEDIDO <='"+mv_par03+"'.And."
			cCondicao += "C9_CLIENTE >='"+mv_par04+"'.And.C9_CLIENTE<='"+mv_par06+"'.And."
			cCondicao += "C9_LOJA    >='"+mv_par05+"'.And.C9_LOJA   <='"+mv_par07+"'.And."
			cCondicao += "DTOS(C9_DATALIB)>='"+DTOS(mv_par08)+"'.And.DTOS(C9_DATALIB)<='"+DTOS(mv_par09)+"'.And."
			cCondicao += "Empty(C9_ORDSEP) .And."
			cCondicao += cFilSC9 + " .AND. "
	*/
			cCondicao := 'C9_PEDIDO  >="'+mv_par02+'".And.C9_PEDIDO <="'+mv_par03+'".And.'
			cCondicao += 'C9_CLIENTE >="'+mv_par04+'".And.C9_CLIENTE<="'+mv_par06+'".And.'
			cCondicao += 'C9_LOJA    >="'+mv_par05+'".And.C9_LOJA   <="'+mv_par07+'".And.'
			cCondicao += 'DTOS(C9_DATALIB)>="'+DTOS(mv_par08)+'".AND.DTOS(C9_DATALIB)<="'+DTOS(mv_par09)+'".AND.'
			cCondicao += 'Empty(C9_ORDSEP) .AND.'
			cCondicao += ' C9_FILIAL = xFilial("SC9").AND.'
			cCondicao += cFilSC9
			cCondicao += " .AND. C9_PEDIDO $ '/"
			dbSelectArea(_cSC9TMP)
			while !(_cSC9TMP)->(EOF())
				cCondicao += (_cSC9TMP)->C9_PEDIDO + "/"
				(_cSC9TMP)->(dbSkip())
			enddo
			cCondicao += "'"
			IndRegua("SC9", cArqInd, cChaveInd, , cCondicao, "Criando indice de trabalho" )
			nIndice   := RetIndex("SC9") + 1
			#IFNDEF TOP
				dbSetIndex(cArqInd + OrdBagExt())
			#ENDIF
			dbSetOrder(nIndice)
			SC9->(MsSeek(xFilial("SC9"),.T.,.F.))
	//		MarkBrow("SC9","C9_OK","SC9->C9_BLEST+SC9->C9_BLCRED", ,lMark,GetMark(,"SC9","C9_OK") )
			MarkBrow("SC9","C9_OK","SC9->C9_BLEST+SC9->C9_BLCRED", ,lMark,GetMark(,"SC9","C9_OK"),,,,,,,,,,,,cCondicao )
			SC9->(dbClearFil())
			RetIndex("SC9")
		else
			MsgAlert("Nenhum pedido apto a gerar Ordem de Separação (conforme a parametrização informada)!",_cRotina+"_001")
		endif
		if Select(_cSC9TMP) > 0
			(_cSC9TMP)->(dbCloseArea())
		endif
	endif
	if Select(_cAliasSX1) > 0
		(_cAliasSX1)->(dbCloseArea())
	endif

	aRotina := aClone(_aRotBkp)

	RestArea(_aSavSC5)
	RestArea(_aSavSC9)
	RestArea(_aSavArea)
return
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
if nOrigExp==1
	Processa( { || GeraOSepPedido( cMarca, lInverte ) } )
elseif nOrigExp==2
	Processa( { || GeraOSepNota( cMarca, lInverte ) } )
elseif nOrigExp==3
	Processa( { || GeraOSepProducao( cMarca, lInverte ) } )
endif
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
local nI
local cCodOpe
local aRecSC9	:= {}
local aOrdSep	:= {}

local cArm		:= Space(Tamsx3("B1_LOCPAD")[1])
local cPedido	:= Space(Tamsx3("C9_PEDIDO")[1])
local cCliente	:= Space(Tamsx3("C6_CLI")[1])
local cLoja		:= Space(Tamsx3("C6_LOJA")[1])
local cCondPag	:= Space(Tamsx3("C5_CONDPAG")[1])
local cLojaEnt	:= Space(Tamsx3("C5_LOJAENT")[1])
local cAgreg	:= Space(Tamsx3("C9_AGREG")[1])
local cOrdSep	:= Space(Tamsx3("CB7_ORDSEP")[1])

local cTipExp	:= ""
local nPos      := 0
local nMaxItens	:= GETMV("MV_NUMITEN")			//Numero maximo de itens por nota (neste caso por ordem de separacao)- by Erike
local lConsNumIt:= SuperGetMV("MV_CBCNITE",.F.,.T.) //Parametro que indica se deve ou nao considerar o conteudo do MV_NUMITEN
local lFilItens	:= ExistBlock("ACDA100I")  //Ponto de Entrada para filtrar o processamento dos itens selecionados
local lLocOrdSep:= .F.
local lA100CABE := ExistBlock("A100CABE")
local lACD100GI := ExistBlock("ACD100GI")
local lACDA100F := ExistBlock("ACDA100F")

private aLogOS	:= {}
nMaxItens := If(Empty(nMaxItens),99,nMaxItens)

// analisar a pergunta '00-Separacao,01-Separacao/Embalagem,02-Embalagem,03-Gera Nota,04-Imp.Nota,05-Imp.Volume,06-embarque,07-Aglutina Pedido,08-Aglutina Local,09-Pre-Separacao'
if nEmbSimul == 1 // Separacao com Embalagem Simultanea
	cTipExp := "01*"
else
	cTipExp := "00*" // Separacao Simples
endif
if nEmbalagem == 1 // Embalagem
	cTipExp += "02*"
endif
if nGeraNota == 1 // Gera Nota
	cTipExp += "03*"
endif
if nImpNota == 1 // Imprime Nota
	cTipExp += "04*"
endif
if nImpEtVol == 1 // Imprime Etiquetas Oficiais de Volume
	cTipExp += "05*"
endif
if nEmbarque == 1 // Embarque
	cTipExp += "06*"
endif
if nAglutPed == 1 // Aglutina pedido
	cTipExp +="11*"
endif
if nAglutArm == 1 // Aglutina armazem
	cTipExp +="08*"
endif
if nPreSep == 1 // pre-separacao - Trocar MV_PAR10 para nPreSep
	cTipExp +="09*"
endif
if nConfLote == 1 // confere lote
	cTipExp +="10*"
endif

/*Ponto de entrada, permite que o usuário realize o processamento conforme suas particularidades.*/
if ExistBlock("ACD100VG")
	if ! ExecBlock("ACD100VG",.F.,.F.,)
		Return
	endif 	
endif

ProcRegua( SC9->( LastRec() ), "oook" )
cCodOpe	 := cSeparador

SC5->(DbSetOrder(1))
SC6->(DbSetOrder(1))
SDC->(DbSetOrder(1))
CB7->(DbSetOrder(2))
CB8->(DbSetOrder(2))

SC9->(dbGoTop())
while !SC9->(Eof())
	if ! SC9->(IsMark("C9_OK",ThisMark(),ThisInv()))
		SC9->(DbSkip())
		IncProc()
		Loop
	endif
	if !Empty(SC9->(C9_BLEST+C9_BLCRED+C9_BLOQUEI))
		SC9->(DbSkip())
		IncProc()
		Loop
	endif
	if lFilItens
		if !ExecBlock("ACDA100I",.F.,.F.)
			SC9->(DbSkip())
			IncProc()
			Loop
		endif
	endif
	//pesquisa se este item tem saldo a separar, caso tenha, nao gera ordem de separacao
	if CB8->(DbSeek(xFilial('CB8')+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN+SC9->C9_PRODUTO)) .and. CB8->CB8_SALDOS > 0
		//Grava o historico das geracoes:
		aadd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_LOCAL,"Existe saldo a separar deste item","NAO_GEROU_OS"})
		SC9->(DbSkip())
		IncProc()
		Loop
	endif

	if ! SC5->(DbSeek(xFilial('SC5')+SC9->C9_PEDIDO))
		// neste caso a base tem sc9 e nao tem sc5, problema de incosistencia de base
		//Grava o historico das geracoes:
		aadd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_LOCAL,"Inconsistencia de base (SC5 x SC9)","NAO_GEROU_OS"})
		SC9->(DbSkip())
		IncProc()
		Loop
	endif
	if ! SC6->(DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO))
		// neste caso a base tem sc9,sc5 e nao tem sc6,, problema de incosistencia de base
		//Grava o historico das geracoes:
		aadd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_LOCAL,"Inconsistencia de base (SC6 x SC9)","NAO_GEROU_OS"})
		SC9->(DbSkip())
		IncProc()
		Loop
	endif

	if !("08*" $ cTipExp)  // gera ordem de separacao por armazem
		cArm :=SC6->C6_LOCAL
	else  // gera ordem de separa com todos os armazens
		cArm :=Space(Tamsx3("B1_LOCPAD")[1])
	endif
	if "11*" $ cTipExp //AGLUTINA TODOS OS PEDIDOS DE UM MESMO CLIENTE
		cPedido := Space(Tamsx3("C9_PEDIDO")[1])
	else   // Nao AGLUTINA POR PEDIDO
		cPedido := SC9->C9_PEDIDO
	endif
	if "09*" $ cTipExp // AGLUTINA PARA PRE-SEPARACAO
		cPedido  := Space(Tamsx3("C9_PEDIDO")[1]) // CASO SEJA PRE-SEPARACAO TEM QUE CONSIDERAR TODOS OS PEDIDOS
		cCliente := Space(Tamsx3("C6_CLI")[1])
		cLoja    := Space(Tamsx3("C6_LOJA")[1])
		cCondPag := Space(Tamsx3("C5_CONDPAG")[1])
		cLojaEnt := Space(Tamsx3("C5_LOJAENT")[1])
		cAgreg   := Space(Tamsx3("C9_AGREG")[1])
	else   // NAO AGLUTINA PARA PRE-SEPARACAO
		cCliente := SC6->C6_CLI
		cLoja    := SC6->C6_LOJA
		cCondPag := SC5->C5_CONDPAG
		cLojaEnt := SC5->C5_LOJAENT
		cAgreg   := SC9->C9_AGREG
	endif

	lLocOrdSep := .F.
	if CB7->(DbSeek(xFilial("CB7")+cPedido+cArm+" "+cCliente+cLoja+cCondPag+cLojaEnt+cAgreg))
		while CB7->(!Eof() .and. CB7_FILIAL+CB7_PEDIDO+CB7_LOCAL+CB7_STATUS+CB7_CLIENT+CB7_LOJA+CB7_COND+CB7_LOJENT+CB7_AGREG==;
								xFilial("CB7")+cPedido+cArm+" "+cCliente+cLoja+cCondPag+cLojaEnt+cAgreg)
			if Ascan(aOrdSep, CB7->CB7_ORDSEP) > 0			
				lLocOrdSep := .T.
				Exit
			endif
			CB7->(DbSkip())
		enddo
	endif
	/*
	if Localiza(SC9->C9_PRODUTO)
		if ! SDC->( dbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN))
			// neste caso nao existe composicao de empenho
			//Grava o historico das geracoes:
			aadd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_LOCAL,"Nao existe composicao de empenho (SDC)","NAO_GEROU_OS"})
			SC9->(DbSkip())
			IncProc()
			Loop
		endif
	endif
	*/
	if !lLocOrdSep .or. (("03*" $ cTipExp) .and. !("09*" $ cTipExp) .and. lConsNumIt .And. CB7->CB7_NUMITE >=nMaxItens)

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
		CB7->CB7_local  := cArm
		CB7->CB7_DTEMIS := dDataBase
		CB7->CB7_HREMIS := Time()
		CB7->CB7_STATUS := " "
		CB7->CB7_CODOPE := cCodOpe
		CB7->CB7_PRIORI := "1"
		CB7->CB7_ORIGEM := "1"
		CB7->CB7_TIPEXP := cTipExp
		CB7->CB7_TRANSP := SC5->C5_TRANSP
		CB7->CB7_AGREG  := cAgreg 
		if lA100CABE
			ExecBlock("A100CABE",.F.,.F.)
		endif
		CB7->(MsUnlock())

		aadd(aOrdSep,CB7->CB7_ORDSEP)
	endif
	//Grava o historico das geracoes:
	nPos := Ascan(aLogOS,{|x| x[01]+x[02]+x[03]+x[04]+x[05]+x[10] == ("1"+"Pedido"+SC9->(C9_PEDIDO+C9_CLIENTE+C9_LOJA)+CB7->CB7_ORDSEP)})
	if nPos == 0
		aadd(aLogOS,{"1","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,"","",cArm,"",CB7->CB7_ORDSEP})
	endif

	if Localiza(SC9->C9_PRODUTO)
		while SDC->(! Eof() .and. DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+;
			DC_ITEM+DC_SEQ==xFilial("SDC")+SC9->(C9_PRODUTO+C9_LOCAL+"SC6"+C9_PEDIDO+C9_ITEM+C9_SEQUEN))

			SB1->(DBSetOrder(1))
			if SB1->(DbSeek(xFilial("SB1")+SDC->DC_PRODUTO)) .And. IsProdMOD(SDC->DC_PRODUTO)
				SDC->(DbSkip())
				Loop
			endif

			CB8->(RecLock("CB8",.T.))
			CB8->CB8_FILIAL := xFilial("CB8")
			CB8->CB8_ORDSEP := CB7->CB7_ORDSEP
			CB8->CB8_ITEM   := SC9->C9_ITEM
			CB8->CB8_PEDIDO := SC9->C9_PEDIDO
			CB8->CB8_PROD   := SDC->DC_PRODUTO
			CB8->CB8_local  := SDC->DC_LOCAL
			CB8->CB8_QTDORI := SDC->DC_QUANT
			if "09*" $ cTipExp
				CB8->CB8_SLDPRE := SDC->DC_QUANT
			endif
			CB8->CB8_SALDOS := SDC->DC_QUANT
			if ! "09*" $ cTipExp .AND. nEmbalagem == 1
				CB8->CB8_SALDOE := SDC->DC_QUANT
			endif
			CB8->CB8_LCALIZ := SDC->DC_LOCALIZ
			CB8->CB8_NUMSER := SDC->DC_NUMSERI
			CB8->CB8_SEQUEN := SC9->C9_SEQUEN
			CB8->CB8_LOTECT := SC9->C9_LOTECTL
			CB8->CB8_NUMLOT := SC9->C9_NUMLOTE
			CB8->CB8_CFLOTE := If("10*" $ cTipExp,"1","2")
			CB8->CB8_TIPSEP := If("09*" $ cTipExp,"1"," ")
			if lACD100GI
				ExecBlock("ACD100GI",.F.,.F.)
			endif
			CB8->(MsUnLock())
			//Atualizacao do controle do numero de itens a serem impressos
			RecLock("CB7",.F.)
			CB7->CB7_NUMITE++
			CB7->(MsUnLock())
			SDC->( dbSkip() )
		enddo
	else 
		CB8->(RecLock("CB8",.T.))
		CB8->CB8_FILIAL := xFilial("CB8")
		CB8->CB8_ORDSEP := CB7->CB7_ORDSEP
		CB8->CB8_ITEM   := SC9->C9_ITEM
		CB8->CB8_PEDIDO := SC9->C9_PEDIDO
		CB8->CB8_PROD   := SC9->C9_PRODUTO
		CB8->CB8_local  := SC9->C9_LOCAL
		CB8->CB8_QTDORI := SC9->C9_QTDLIB
		if "09*" $ cTipExp
			CB8->CB8_SLDPRE := SC9->C9_QTDLIB
		endif
		CB8->CB8_SALDOS := SC9->C9_QTDLIB
		if !"09*" $ cTipExp .AND. nEmbalagem == 1
			CB8->CB8_SALDOE := SC9->C9_QTDLIB 
		endif
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
		if lACD100GI
			ExecBlock("ACD100GI",.F.,.F.)
		endif
		CB8->(MsUnLock())

		//Atualizacao do controle do numero de itens a serem impressos
		RecLock("CB7",.F.)
		CB7->CB7_NUMITE++
		CB7->(MsUnLock())
	endif
	aadd(aRecSC9,{SC9->(Recno()),CB7->CB7_ORDSEP})
	IncProc()
	SC9->( dbSkip() )
enddo

CB7->(DbSetOrder(1))
for nI := 1 to len(aOrdSep)
	CB7->(DbSeek(xFilial("CB7")+aOrdSep[nI]))
	CB7->(RecLock("CB7"))
	CB7->CB7_STATUS := "0"  // nao iniciado
	CB7->(MsUnlock())
	if lACDA100F
		ExecBlock("ACDA100F",.F.,.F.,{aOrdSep[nI]})
	endif
next
for nI := 1 to len(aRecSC9)
	SC9->(DbGoto(aRecSC9[nI,1]))
	SC9->(RecLock("SC9"))
	SC9->C9_ORDSEP := aRecSC9[nI,2]
	SC9->(MsUnlock())
next
if !Empty(aLogOS)
	LogACDA100()
endif
Return

STATIC Function GeraOSepNota( cMarca, lInverte, cNotaSerie)
local cChaveDB
local cTipExp
local nI
local cCodOpe
local aRecSD2 := {}
local aOrdSep := {}
local lFilItens  := ExistBlock("ACDA100I")  //Ponto de Entrada para filtrar o processamento dos itens selecionados
local lA100CABE := ExistBlock("A100CABE")
local lACD100GI := ExistBlock("ACD100GI")
local lACDA100F := ExistBlock("ACDA100F")

private aLogOS:= {}

// analisar a pergunta '00-Separcao,01-Separacao/Embalagem,02-Embalagem,03-Gera Nota,04-Imp.Nota,05-Imp.Volume,06-embarque'
if nEmbSimuNF == 1
	cTipExp := "01*"
else
	cTipExp := "00*"
endif
if nEmbalagNF == 1
	cTipExp += "02*"
endif
if nImpNotaNF == 1
	cTipExp += "04*"
endif
if nImpVolNF == 1
	cTipExp += "05*"
endif
if nEmbarqNF == 1
	cTipExp += "06*"
endif
/*Ponto de entrada, permite que o usuário realize o processamento conforme suas particularidades.*/
if ExistBlock("ACD100VG")
	if ! ExecBlock("ACD100VG",.F.,.F.,)
		Return
	endif 	
endif

SF2->(DbSetOrder(1))
SD2->(DbSetOrder(3))
SD2->( dbGoTop() )

if cNotaSerie == Nil
	ProcRegua( SD2->( LastRec() ), "oook" )
	cCodOpe	 := cSeparador
else
	SD2->(DbSetOrder(3))
	SD2->(DbSeek(xFilial("SD2")+cNotaSerie))
	cCodOpe := Space(06)
endif

ProcRegua( SD2->( LastRec() ), "oook" )
cCodOpe := cSeparador

while !SD2->( Eof() ) .and. (cNotaSerie == Nil .or. cNotaSerie == SD2->(D2_DOC+D2_SERIE))
	if (cNotaSerie==NIL) .and. ! (SD2->(IsMark("D2_OK",ThisMark(),ThisInv())))
		SD2->( dbSkip() )
		IncProc()
		Loop
	endif
	if lFilItens
		if !ExecBlock("ACDA100I",.F.,.F.)
			SD2->(DbSkip())
			IncProc()
			Loop
		endif
	endif
	cChaveDB :=xFilial("SDB")+SD2->(D2_COD+D2_LOCAL+D2_NUMSEQ+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)
	if Localiza(SD2->D2_COD)
		SDB->(dbSetOrder(1))
		if ! SDB->(dbSeek( cChaveDB ))
			// neste caso nao existe composicao de empenho
			//Grava o historico das geracoes:
			aadd(aLogOS,{"2","Nota",SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_CLIENTE,SD2->D2_LOJA,"Inconsistencia de base, nao existe registro de movimento (SDB)","NAO_GEROU_OS"})
			SD2->(DbSkip())
			if cNotaSerie==Nil
				IncProc()
			endif
			Loop
		endif
	endif

	CB7->(DbSetOrder(4))
	if ! CB7->(DbSeek(xFilial("CB7")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_LOCAL+" "))
		CB7->(RecLock( "CB7", .T. ))
		CB7->CB7_FILIAL := xFilial( "CB7" )
		CB7->CB7_ORDSEP := GetSX8Num( "CB7", "CB7_ORDSEP" )
		CB7->CB7_NOTA   := SD2->D2_DOC
		//CB7->CB7_SERIE  := SD2->D2_SERIE
		SerieNfId ("CB7",1,"CB7_SERIE",,,,SD2->D2_SERIE)
		CB7->CB7_CLIENT := SD2->D2_CLIENTE
		CB7->CB7_LOJA   := SD2->D2_LOJA
		CB7->CB7_local  := SD2->D2_LOCAL
		CB7->CB7_DTEMIS := dDataBase
		CB7->CB7_HREMIS := Time()
		CB7->CB7_STATUS := " "   // gravar STATUS de nao iniciada somente depois do processo
		CB7->CB7_CODOPE := cCodOpe
		CB7->CB7_PRIORI := "1"
		CB7->CB7_ORIGEM := "2"
		CB7->CB7_TIPEXP := cTipExp
		if SF2->(DbSeek(xFilial("SF2")+SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)))
			CB7->CB7_TRANSP := SF2->F2_TRANSP
		endif   
		if lA100CABE
			ExecBlock("A100CABE",.F.,.F.)
		endif
		CB7->(MsUnLock())
		ConfirmSX8()
		//Grava o historico das geracoes:
		aadd(aLogOS,{"1","Nota",SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_CLIENTE,SD2->D2_LOJA,"",CB7->CB7_ORDSEP})
		aadd(aOrdSep,CB7->CB7_ORDSEP)
	endif
	if Localiza(SD2->D2_COD)
		while SDB->(!Eof() .And. cChaveDB == DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA)
			if SDB->DB_ESTORNO == "S"
				SDB->(dbSkip())
				Loop
			endif
			CB8->(DbSetorder(4))
			if ! CB8->(DbSeek(xFilial("CB8")+CB7->CB7_ORDSEP+SD2->(D2_ITEM+D2_COD+D2_LOCAL+SDB->DB_LOCALIZ+D2_LOTECTL+D2_NUMLOTE+D2_NUMSERI)))
				CB8->(RecLock( "CB8", .T. ))
				CB8->CB8_FILIAL := xFilial( "CB8" )
				CB8->CB8_ORDSEP := CB7->CB7_ORDSEP
				CB8->CB8_ITEM   := SD2->D2_ITEM
				CB8->CB8_PEDIDO := SD2->D2_PEDIDO
				CB8->CB8_NOTA   := SD2->D2_DOC
				//CB8->CB8_SERIE  := SD2->D2_SERIE
				SerieNfId ("CB8",1,"CB8_SERIE",,,,SD2->D2_SERIE)
				CB8->CB8_PROD   := SD2->D2_COD
				CB8->CB8_local  := SD2->D2_LOCAL
				CB8->CB8_LCALIZ := SDB->DB_LOCALIZ
				CB8->CB8_SEQUEN := SDB->DB_ITEM
				CB8->CB8_LOTECT := SD2->D2_LOTECTL
				CB8->CB8_NUMLOT := SD2->D2_NUMLOTE
				CB8->CB8_NUMSER := SD2->D2_NUMSERI
				CB8->CB8_CFLOTE := "1"
				aadd(aRecSD2,{SD2->(Recno()),CB7->CB7_ORDSEP})
			else
				CB8->(RecLock( "CB8", .f. ))
			endif
			CB8->CB8_QTDORI += SDB->DB_QUANT
			CB8->CB8_SALDOS += SDB->DB_QUANT
			if nEmbalagem == 1
				CB8->CB8_SALDOE += SDB->DB_QUANT
			endif
			if lACD100GI
				ExecBlock("ACD100GI",.F.,.F.)
			endif
			CB8->(MsUnLock())
			SDB->(dbSkip())
		enddo
	else
		CB8->(DbSetorder(4))
		if ! CB8->(DbSeek(xFilial("CB8")+CB7->CB7_ORDSEP+SD2->(D2_ITEM+D2_COD+D2_LOCAL+Space(15)+D2_LOTECTL+D2_NUMLOTE+D2_NUMSERI)))
			CB8->(RecLock( "CB8", .T. ))
			CB8->CB8_FILIAL := xFilial( "CB8" )
			CB8->CB8_ORDSEP := CB7->CB7_ORDSEP
			CB8->CB8_ITEM   := SD2->D2_ITEM
			CB8->CB8_PEDIDO := SD2->D2_PEDIDO
			CB8->CB8_NOTA   := SD2->D2_DOC
			//CB8->CB8_SERIE  := SD2->D2_SERIE
			SerieNfId ("CB8",1,"CB8_SERIE",,,,SD2->D2_SERIE)				
			CB8->CB8_PROD   := SD2->D2_COD
			CB8->CB8_local  := SD2->D2_LOCAL
			CB8->CB8_LCALIZ := Space(15)
			CB8->CB8_SEQUEN := SD2->D2_ITEM
			CB8->CB8_LOTECT := SD2->D2_LOTECTL
			CB8->CB8_NUMLOT := SD2->D2_NUMLOTE
			CB8->CB8_NUMSER := SD2->D2_NUMSERI
			CB8->CB8_CFLOTE := "1"
			aadd(aRecSD2,{SD2->(Recno()),CB7->CB7_ORDSEP})
		else
			CB8->(RecLock( "CB8", .f. ))
		endif
		CB8->CB8_QTDORI += SD2->D2_QUANT
		CB8->CB8_SALDOS += SD2->D2_QUANT
		if nEmbalagem == 1
			CB8->CB8_SALDOE += SD2->D2_QUANT
	    endif
		if lACD100GI
			ExecBlock("ACD100GI",.F.,.F.)
		endif
		CB8->(MsUnLock())
	endif

	if cNotaSerie==Nil
		IncProc()
	endif
	SD2->( dbSkip() )
enddo

CB7->(DbSetOrder(1))
for nI := 1 to len(aOrdSep)
	CB7->(DbSeek(xFilial("CB7")+aOrdSep[nI]))
	CB7->(RecLock("CB7"))
	CB7->CB7_STATUS := "0"  // nao iniciado
	CB7->(MsUnlock())
	if lACDA100F
		ExecBlock("ACDA100F",.F.,.F.,{aOrdSep[nI]})
	endif
next
for nI := 1 to len(aRecSD2)
	SD2->(DbGoto(aRecSD2[nI,1]))
	SD2->(RecLock("SD2",.F.))
	SD2->D2_ORDSEP := aRecSD2[nI,2]
	SD2->(MsUnlock())
next
if !Empty(aLogOS)
	LogACDA100()
endif
Return


STATIC Function GeraOSepProducao( cMarca, lInverte )
local cOrdSep,aOrdSep := {},nI
local cCodOpe
local aRecSC2   := {}
local cTipExp
local aItemCB8  := {}
local lSai      := .f.
local cArm      := Space(Tamsx3("B1_LOCPAD")[1])
local lFilItens := ExistBlock("ACDA100I")  //Ponto de Entrada para filtrar o processamento dos itens selecionados
local cTM	    := GetMV("MV_CBREQD3")
local lConsEst  := SuperGetMV("MV_CBRQEST",,.F.)  //Considera a Estrutura do Produto x Saldo na geracao da Ordem de Separacao
local lParcial  := SuperGetMV("MV_CBOSPRC",,.F.)  //Permite ou nao gerar Ordens de Separacoes parciais
local lGera		:= .T.
local lA100CABE := ExistBlock("A100CABE")
local lACD100GI := ExistBlock("ACD100GI")
local lACDA100F := ExistBlock("ACDA100F")
local lExtACDEMP := ExistBlock("ACD100EMP")
local nSalTotIt := 0
local nSaldoEmp := 0
local aSaldoSBF := {}
local aSaldoSDC := {}
local nSldGrv   := 0
local nRetSldEnd:= 0
local nRetSldSDC:= 0
local nSldAtu   := 0
local nQtdEmpOS := 0
local nPosEmp    
local nX
private aLogOS := {}
private aEmp   := {}

// analisar a pergunta '00-Separcao,01-Separacao/Embalagem,02-Embalagem,03-Gera Nota,04-Imp.Nota,05-Imp.Volume,06-embarque,07-Requisita'
cTipExp := "00*"

if nReqMatOP == 1
	cTipExp += "07*" //Requisicao
endif

if nAglutArmOP == 1 // Aglutina armazem
	cTipExp +="08*"
endif

if nPreSep == 1 // Pre-Separacao
	cTipExp +="09*"
endif
/*Ponto de entrada, permite que o usuário realize o processamento conforme suas particularidades.*/
if ExistBlock("ACD100VG")
	if ! ExecBlock("ACD100VG",.F.,.F.,)
		Return
	endif 	
endif

SC2->( dbGoTop() )
ProcRegua( SC2->( LastRec() ), "oook" )
cCodOpe	 := cSeparador

SB2->(DbSetOrder(1))
SD4->(DbSetOrder(2))
SDC->(dbSetOrder(2))
CB7->(DbSetOrder(1))
while !SC2->( Eof() )

	if ! SC2->(IsMark("C2_OK",ThisMark(),ThisInv()))
		IncProc()
		SC2->(dbSkip())
		Loop
	endif

	if lFilItens
		if !ExecBlock("ACDA100I",.F.,.F.)
			SC2->(DbSkip())
			IncProc()
			Loop
		endif
	endif

	CB8->(DbSetOrder(6))
	if CB8->(DbSeek(xFilial("CB8")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN))
		if CB7->(DbSeek(xFilial("CB7")+CB8->CB8_ORDSEP)) .and. CB7->CB7_STATUS # "9" // Ordem em aberto
			//Grava o historico das geracoes:
			aadd(aLogOS,{"2","OP",SC2->(C2_NUM+C2_ITEM+C2_SEQUEN),"","","Existe uma Ordem de Separacao em aberto para esta Ordem de Producao","NAO_GEROU_OS"})
			IncProc()
			SC2->(dbSkip())
			Loop
		endif
	endif
	lSai := .f.
	aEmp := {}
	SD4->(DbSeek(xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN))
	while SD4->(! Eof() .And. D4_FILIAL+Left(D4_OP,11) == xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)
		if Empty(SD4->D4_QUANT)
			SD4->(DbSkip())
			Loop
		endif
		if lParcial .And. Localiza(SD4->D4_COD)// Se permitir parcial, controlar localização e nao existir composição de empenho, passa para o proximo.   
			if !CBArmProc(SD4->D4_COD,cTM)
				aSaldoSDC := RetSldSDC(SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_OP,.F.,"","",SD4->D4_TRT)
				if Empty(aSaldoSDC)
				    SD4->(DbSkip())
	             endif
			else
				aSaldoSBF := RetSldEnd(SD4->D4_COD,.f.)
				if Empty(aSaldoSBF)
					SD4->(DbSkip())
				endif
			endif  
	    endif
		SB1->(DBSetOrder(1))
		if SB1->(DbSeek(xFilial("SB1")+SD4->D4_COD)) .And. IsProdMOD(SD4->D4_COD)
			SD4->(DbSkip())
			Loop
		endif
		if lExtACDEMP
			lACD100EMP := ExecBlock("ACD100EMP",.F.,.F.,{SD4->D4_OP,SD4->D4_COD,SD4->D4_QUANT})
			lACD100EMP := If(ValType(lACD100EMP)=="L",lACD100EMP,.T.)
			if !lACD100EMP
				SD4->(DbSkip())
				Loop
			endif
		endif
		if !Localiza(SD4->D4_COD) // Nao controla endereco
			SB2->(DbSeek(xFilial("SB2")+SD4->(D4_COD+D4_LOCAL)))
			nSldAtu := If(CBArmProc(SD4->D4_COD,cTM),SB2->B2_QATU,SaldoSB2())
			nPosEmp := Ascan(aEmp,{|x| x[02] == SD4->D4_COD})
			if nPosEmp == 0
				aadd(aEmp,{SD4->D4_OP,SD4->D4_COD,SD4->D4_QUANT,nSldAtu,0,0,0})
			else
				aEmp[nPosEmp,03] += SD4->D4_QUANT
			endif
			SD4->(DbSkip())
			Loop
		endif
		if !CBArmProc(SD4->D4_COD,cTM) .AND. If(!lParcial,(SD4->D4_QUANT > (nRetSldSDC := RetSldSDC(SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_OP,.t.,"","",SD4->D4_TRT))),.F.) .AND. !lConsEst  
			//Grava o historico das geracoes:
			aadd(aLogOS,{"2","OP",SD4->D4_OP,SD4->D4_COD,"","O produto "+Alltrim(SD4->D4_COD)+" nao encontra-se empenhado (SD4 x SDC)","NAO_GEROU_OS"})
			lSai := .t.
		elseif CBArmProc(SD4->D4_COD,cTM) .AND. If(!lParcial,(SD4->D4_QUANT > (nRetSldEnd := RetSldEnd(SD4->D4_COD,.t.))),.F.) .AND. !lConsEst
			//Grava o historico das geracoes:
			aadd(aLogOS,{"2","OP",SD4->D4_OP,SD4->D4_COD,"","O produto "+Alltrim(SD4->D4_COD)+" nao possui saldo enderecado suficiente."+CHR(13)+CHR(10)+"        (ou existem Ordens de Separacao ainda nao requisitadas)","NAO_GEROU_OS"})
			lSai := .t.
		endif
		nPosEmp := Ascan(aEmp,{|x| x[02] == SD4->D4_COD})
		if nPosEmp == 0
			aadd(aEmp,{SD4->D4_OP,SD4->D4_COD,SD4->D4_QUANT,If(CBArmProc(SD4->D4_COD,cTM),nRetSldEnd,nRetSldSDC),0,0,0})
		else
			aEmp[nPosEmp,03] += SD4->D4_QUANT
		endif
		SD4->(DbSkip())
	enddo
	if lConsEst  //Considera a Estrutura do Produto x Saldo na geracao da Ordem de Separacao
		if SemSldOS()
			//Grava o historico das geracoes:
			aadd(aLogOS,{"2","OP",SD4->D4_OP,SD4->D4_COD,"","Os itens empenhados nao possuem saldo em estoque suficiente para a producao de uma unidade do produto da OP","NAO_GEROU_OS"})
			lSai := .t.
		endif
	endif
	if lSai
		IncProc()
		SC2->(dbSkip())
		Loop
	endif

	SD4->(DbSeek(xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN))
	while SD4->(!Eof() .And. D4_FILIAL+Left(D4_OP,11) == xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)
		if Empty(SD4->D4_QUANT)
			SD4->(DbSkip())
			Loop
		endif  
		if lParcial .And. Localiza(SD4->D4_COD)// Se permitir parcial, controlar localização e nao existir composição de empenho, passa para o proximo.   
			if !CBArmProc(SD4->D4_COD,cTM)
				aSaldoSDC := RetSldSDC(SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_OP,.F.,SD4->D4_LOTECTL,SD4->D4_NUMLOTE,SD4->D4_TRT)
				if Empty(aSaldoSDC)
					aadd(aLogOS,{"2","OP",SD4->D4_OP,SD4->D4_COD,"","O produto "+Alltrim(SD4->D4_COD)+" nao encontra-se empenhado (SD4 x SDC)","NAO_GEROU_OS"})
				    SD4->(DbSkip())
				    Loop
	             endif
			else
				aSaldoSBF := RetSldEnd(SD4->D4_COD,.f.)
				if Empty(aSaldoSBF)
					aadd(aLogOS,{"2","OP",SD4->D4_OP,SD4->D4_COD,"","O produto "+Alltrim(SD4->D4_COD)+" nao possui saldo enderecado suficiente."+CHR(13)+CHR(10)+"        (ou existem Ordens de Separacao ainda nao requisitadas)","NAO_GEROU_OS"})
					SD4->(DbSkip())
					Loop
				endif
			endif  
	    endif
		SB1->(DBSetOrder(1))
		if SB1->(DbSeek(xFilial("SB1")+SD4->D4_COD)) .And. IsProdMOD(SD4->D4_COD)
			SD4->(DbSkip())
			Loop
		endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada na Geração das Ordens de Separação.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if lExtACDEMP
			lACD100EMP := ExecBlock("ACD100EMP",.F.,.F.,{SD4->D4_OP,SD4->D4_COD,SD4->D4_QUANT})
			lACD100EMP := If(ValType(lACD100EMP)=="L",lACD100EMP,.T.)
			if !lACD100EMP
				SD4->(DbSkip())
				Loop
			endif
		endif
		
		if !("08*" $ cTipExp)  // gera ordem de separacao por armazem
			cArm :=If(CBArmProc(SD4->D4_COD,cTM),SB1->B1_LOCPAD,SD4->D4_LOCAL)
		else  // gera ordem de separa com todos os armazens
			cArm :=Space(Tamsx3("B1_LOCPAD")[1])
		endif
		if "09*" $ cTipExp // AGLUTINA PARA PRE-SEPARACAO
			cOP:= Space(Len(SD4->D4_OP))
		else
			cOP:= SD4->D4_OP
		endif
			CB7->(DbSetOrder(5))
		if ! CB7->(DbSeek(xFilial("CB7")+cOP+cArm+" "))
			cOrdSep   := GetSX8Num( "CB7", "CB7_ORDSEP" )
			CB7->(RecLock( "CB7", .T. ))
			CB7->CB7_FILIAL := xFilial( "CB7" )
			CB7->CB7_ORDSEP := cOrdSep
			CB7->CB7_OP     := cOP
			CB7->CB7_local  := cArm
			CB7->CB7_DTEMIS := dDataBase
			CB7->CB7_HREMIS := Time()
			CB7->CB7_STATUS := " "   // gravar STATUS de nao iniciada somente depois do processo
			CB7->CB7_CODOPE := cCodOpe
			CB7->CB7_PRIORI := "1"
			CB7->CB7_ORIGEM := "3"
			CB7->CB7_TIPEXP := cTipExp 
			if lA100CABE
				ExecBlock("A100CABE",.F.,.F.)
			endif
			ConfirmSX8()
			//Grava o historico das geracoes:
			aadd(aLogOS,{"1","OP",SD4->D4_OP,"",cArm,"",CB7->CB7_ORDSEP})
			aadd(aOrdSep,cOrdSep)
		endif

		if Localiza(SD4->D4_COD) //controla endereco

			if !CBArmProc(SD4->D4_COD,cTM)
				aSaldoSDC := RetSldSDC(SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_OP,.F.,SD4->D4_LOTECTL,SD4->D4_NUMLOTE,SD4->D4_TRT)
				nSalTotIt := 0
				for nX:=1 to len(aSaldoSDC)
					nSalTotIt+=aSaldoSDC[nX,7]
				next
 			    if lConsEst
	 			    nSaldoEmp := RetEmpOS(lConsEst,SD4->D4_COD,SD4->D4_QUANT)
 			    endif
 			    
				// Separacoes sao geradas conf. empenhos nos enderecos (SDC)
				for nX:=1 to len(aSaldoSDC)
					lGera := .T.
	 			    if !lConsEst
	 				    nSaldoEmp := RetEmpOS(lConsEst,SD4->D4_COD,aSaldoSDC[nX,7])
                    endif
					if (!lConsEst .And. !lParcial) .And. SD4->D4_QTDEORI <> nSalTotIt
						Exit
					elseif lConsEst .And. nSaldoEmp == 0
						lGera := .F.
					else
						nSldGrv   := aSaldoSDC[nX,7]
						nSaldoEmp -= aSaldoSDC[nX,7]
					endif
					if lGera
						cOrdSep := CB7->CB7_ORDSEP
						CB8->(RecLock( "CB8", .T. ))
						CB8->CB8_FILIAL := xFilial( "CB8" )
						CB8->CB8_ORDSEP := cOrdSep
						CB8->CB8_OP     := SD4->D4_OP
						CB8->CB8_ITEM   := RetItemCB8(cOrdSep,aItemCB8)
						CB8->CB8_PROD   := SD4->D4_COD
						CB8->CB8_local  := aSaldoSDC[nX,2]
						CB8->CB8_QTDORI := nSldGrv
						CB8->CB8_SALDOS := nSldGrv
						if nEmbalagem == 1
							CB8->CB8_SALDOE := nSldGrv
						endif
						CB8->CB8_LCALIZ := aSaldoSDC[nX,3]
						CB8->CB8_SEQUEN := ""
						CB8->CB8_LOTECT := aSaldoSDC[nX,4]
						CB8->CB8_NUMLOT := aSaldoSDC[nX,5]
						CB8->CB8_NUMSER := aSaldoSDC[nX,6]
						CB8->CB8_CFLOTE := "1"
						if "09*" $ cTipExp
							CB8->CB8_SLDPRE := nSldGrv
						endif
						if lACD100GI
							ExecBlock("ACD100GI",.F.,.F.)
						endif
						CB8->(MsUnLock())
					endif
				next
				SD4->(DbSkip())	
			else
				aSaldoSBF := RetSldEnd(SD4->D4_COD,.f.)
 			    if lConsEst
	 			    nSaldoEmp := RetEmpOS(lConsEst,SD4->D4_COD,SD4->D4_QUANT)
 			    endif 
				for nX:=1 to len(aSaldoSBF)
	 			    if !lConsEst
	 				    nSaldoEmp := RetEmpOS(lConsEst,SD4->D4_COD,SD4->D4_QUANT)
                    endif
					if lConsEst .And. nSaldoEmp == 0
						SD4->(DbSkip())
						Exit
						nSaldoEmp -= aSaldoSDC[nX,7]
					endif
					cOrdSep := CB7->CB7_ORDSEP
					CB8->(RecLock( "CB8", .T. ))
					CB8->CB8_FILIAL := xFilial( "CB8" )
					CB8->CB8_ORDSEP := cOrdSep
					CB8->CB8_OP     := SD4->D4_OP
					CB8->CB8_ITEM   := RetItemCB8(cOrdSep,aItemCB8)
					CB8->CB8_PROD   := SD4->D4_COD
					CB8->CB8_local  := aSaldoSBF[nX,2]
					CB8->CB8_QTDORI := SD4->D4_QTDEORI
					CB8->CB8_SALDOS := nSaldoEmp
					if nEmbalagem == 1
						CB8->CB8_SALDOE := nSaldoEmp
	                endif
					CB8->CB8_LCALIZ := aSaldoSBF[nX,3]
					CB8->CB8_SEQUEN := ""
					CB8->CB8_LOTECT := aSaldoSBF[nX,4]
					CB8->CB8_NUMLOT := aSaldoSBF[nX,5]
					CB8->CB8_NUMSER := aSaldoSBF[nX,6]
					CB8->CB8_CFLOTE := "1"
					if "09*" $ cTipExp
						CB8->CB8_SLDPRE := nSaldoEmp
					endif
					if lACD100GI
						ExecBlock("ACD100GI",.F.,.F.)
					endif
					CB8->(MsUnLock())
					SD4->(DbSkip())					
				next Nx
			endif
		else
			cOrdSep   := CB7->CB7_ORDSEP
			nQtdEmpOS := RetEmpOS(lConsEst,SD4->D4_COD,SD4->D4_QUANT)
			CB8->(RecLock( "CB8", .T. ))
			CB8->CB8_FILIAL := xFilial( "CB8" )
			CB8->CB8_ORDSEP := cOrdSep
			CB8->CB8_OP     := SD4->D4_OP
			CB8->CB8_ITEM   := RetItemCB8(cOrdSep,aItemCB8)
			CB8->CB8_PROD   := SD4->D4_COD
			CB8->CB8_local  := If(CBArmProc(SD4->D4_COD,cTM),SB1->B1_LOCPAD,SD4->D4_LOCAL)
			CB8->CB8_QTDORI := nQtdEmpOS
			CB8->CB8_SALDOS := nQtdEmpOS
			if nEmbalagem == 1
				CB8->CB8_SALDOE := nQtdEmpOS
			endif
			CB8->CB8_LCALIZ := Space(15)
			CB8->CB8_SEQUEN := ""
			CB8->CB8_LOTECT := SD4->D4_LOTECTL
			CB8->CB8_NUMLOT := SD4->D4_NUMLOTE
			CB8->CB8_CFLOTE := "1"
			if "09*" $ cTipExp
				CB8->CB8_SLDPRE := nQtdEmpOS
			endif
			if lACD100GI
				ExecBlock("ACD100GI",.F.,.F.)
			endif
			CB8->(MsUnLock())
			SD4->(DbSkip())
		endif
	enddo
	aadd(aRecSC2,SC2->(Recno()))
	IncProc()
	SC2->( dbSkip() )
enddo

CB7->(DbSetOrder(1))
for nI := 1 to len(aOrdSep)
	CB7->(DbSeek(xFilial("CB7")+aOrdSep[nI]))
	CB7->(RecLock("CB7"))
	CB7->CB7_STATUS := "0"  // nao iniciado
	CB7->(MsUnlock())
	if lACDA100F
		ExecBlock("ACDA100F",.F.,.F.,{aOrdSep[nI]})
	endif
next
for nI := 1 to len(aRecSC2)
	SC2->(DbGoto(aRecSC2[nI]))
	SC2->(RecLock("SC2"))
	SC2->C2_ORDSEP := cOrdSep
	SC2->(MsUnlock())
next

if lParcial .and. Empty(aOrdSep) .and. !Empty(aLogOS) // Quando permitir parcial somente gera log se nao existir nenhuma item na OS
	LogACDA100()
elseif !lparcial .and.!Empty(aLogOS)
	LogACDA100()
endif

Return

Static Function RetItemCB8(cOrdSep,aItemCB8)

local nPos := Ascan(aItemCB8,{|x| x[1] == cOrdSep})
local cItem :=' '

if Empty(nPos )
	AAdd(aItemCB8,{cOrdSep,'00'})
	nPos := len(aItemCB8)
endif

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
local i, j, k
local cChaveAtu, cPedCli, cOPAtual

//Cabecalho do Log de processamento:
AutoGRLog(Replicate("=",75))
AutoGRLog("                         I N F O R M A T I V O")
AutoGRLog("               H I S T O R I C O   D A S   G E R A C O E S")

//Detalhes do Log de processamento:
AutoGRLog(Replicate("=",75))
AutoGRLog("I T E N S   P R O C E S S A D O S :")
AutoGRLog(Replicate("=",75))
if aLogOS[1,2] == "Pedido"
	aLogOS := aSort(aLogOS,,,{|x,y| x[01]+x[10]+x[03]+x[04]+x[05]+x[06]+x[07]+x[08]<y[01]+y[10]+y[03]+y[04]+y[05]+y[06]+y[07]+y[08]})
	// Status Ord.Sep(1=Gerou;2=Nao Gerou) + Ordem Separacao + Pedido + Cliente + Loja + Item + Produto + Local
	cChaveAtu := ""
	cPedCli   := ""
	For i:=1 to len(aLogOs)
		if aLogOs[i,10] <> cChaveAtu .OR. (aLogOs[i,03]+aLogOs[i,04] <> cPedCli)
			if !Empty(cChaveAtu)
				AutoGRLog(Replicate("-",75))
			endif
			j:=0
			k:=i  //Armazena o conteudo do contador do laco logico principal (i) pois o "For" j altera o valor de i;
			cChaveAtu := aLogOs[i,10]
			For j:=k to len(aLogOs)
				if aLogOs[j,10] <> cChaveAtu
					Exit
				endif
				if Empty(aLogOs[j,08]) //Aglutina Armazem
					AutoGRLog("Pedido: "+aLogOs[j,03]+" - Cliente: "+aLogOs[j,04]+"-"+aLogOs[j,05])
				else
					AutoGRLog("Pedido: "+aLogOs[j,03]+" - Cliente: "+aLogOs[j,04]+"-"+aLogOs[j,05]+" - Local: "+aLogOs[j,08])
				endif
				cPedCli := aLogOs[j,03]+aLogOs[j,04]
				if aLogOs[j,10] == "NAO_GEROU_OS"
					Exit
				endif
				i:=j
			next
			AutoGRLog("Ordem de Separacao: "+If(aLogOs[i,01]=="1",aLogOs[i,10],"N A O  G E R A D A"))
			if aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
				AutoGRLog("Motivo: ")
			endif
		endif
		if aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
			AutoGRLog("Item: "+aLogOs[i,06]+" - Produto: "+AllTrim(aLogOs[i,07])+" - Local: "+aLogOs[i,08]+" ---> "+aLogOs[i,09])
		endif
	next
elseif aLogOS[1,2] == "Nota"
	aLogOS := aSort(aLogOS,,,{|x,y| x[01]+x[08]+x[03]+x[04]+x[05]+x[06]<y[01]+y[08]+y[03]+y[04]+y[05]+y[06]})
	// Status Ord.Sep(1=Gerou;2=Nao Gerou) + Ordem Separacao + Nota + Serie + Cliente + Loja
	cChaveAtu := ""
	For i:=1 to len(aLogOs)
		if aLogOs[i,08] <> cChaveAtu
			if !Empty(cChaveAtu)
				AutoGRLog(Replicate("-",75))
			endif
			cChaveAtu := aLogOs[i,08]
			AutoGRLog("Nota: "+aLogOs[i,3]+"/"+aLogOs[i,04]+" - Cliente: "+aLogOs[i,05]+"-"+aLogOs[i,06])
			AutoGRLog("Ordem de Separacao: "+If(aLogOs[i,01]=="1",aLogOs[i,08],"N A O  G E R A D A"))
			if aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
				AutoGRLog("Motivo: ")
			endif
		endif
	next
else  //Ordem de Producao
	aLogOS := aSort(aLogOS,,,{|x,y| x[01]+x[07]+x[03]+x[04]<y[01]+y[07]+y[03]+y[04]})
	// Status Ord.Sep(1=Gerou;2=Nao Gerou) + Ordem Separacao + Ordem Producao + Produto
	cChaveAtu := ""
	cOPAtual  := ""
	For i:=1 to len(aLogOs)
		if aLogOs[i,07] <> cChaveAtu .OR. aLogOs[i,03] <> cOPAtual
			if !Empty(cChaveAtu)
				AutoGRLog(Replicate("-",75) )
			endif
			j:=0
			k:=i  //Armazena o conteudo do contador do laco logico principal (i) pois o "For" j altera o valor de i;
			cChaveAtu := aLogOs[i,07]
			For j:=k to len(aLogOs)
				if aLogOs[j,07] <> cChaveAtu
					Exit
				endif
				if Empty(aLogOs[j,05]) //Aglutina Armazem
					AutoGRLog("Ordem de Producao: "+aLogOs[i,03])
				else
					AutoGRLog("Ordem de Producao: "+aLogOs[i,03]+" - Local: "+aLogOs[j,05])
				endif
				cOPAtual := aLogOs[j,03]
				if aLogOs[j,07] == "NAO_GEROU_OS"
					Exit
				endif
				i:=j
			next
			AutoGRLog("Ordem de Separacao: "+If(aLogOs[i,01]=="1",aLogOs[i,07],"N A O  G E R A D A"))
			if aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
				AutoGRLog("Motivo: ")
			endif
		endif
		if aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
			AutoGRLog(" ---> "+aLogOs[i,06])
		endif
	next
endif
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
local cPergParam  := ""
local cPergConfig := ""
local cDescTipGer := ""
local nTamSX1     := Len((_cAliasSX1)->X1_GRUPO)
local aPerg       := {}
local aParam      := {}
local ni          := 0
local ci          := 0
local aLogs       := {}

if cTipGer == "Pedido"
	cPergParam  := PADR('AIA102',nTamSX1)
	cPergConfig := PADR('AIA106',nTamSX1)
	cDescTipGer := 'PEDIDO DE VENDA'
	aAdd(aParam,nConfLote)
	aAdd(aParam,nEmbSimul)
	aAdd(aParam,nEmbalagem)
	if cPaisLoc == "BRA"
		aAdd(aParam,nGeraNota)
		aAdd(aParam,nImpNota)
	endif
	aAdd(aParam,nImpEtVol)
	aAdd(aParam,nEmbarque)
	aAdd(aParam,nAglutPed)
	aAdd(aParam,nAglutArm)
elseif cTipGer == "Nota"
	cPergParam  := PADR('AIA103',nTamSX1)
	cPergConfig := PADR('AIA107',nTamSX1)
	cDescTipGer := 'NOTA FISCAL'
	aAdd(aParam,nEmbSimuNF)
	aAdd(aParam,nEmbalagNF)
	aAdd(aParam,nImpNotaNF)
	aAdd(aParam,nImpVolNF)
	aAdd(aParam,nEmbarqNF)
else //OP
	cPergParam  := PADR('AIA104',nTamSX1)
	cPergConfig := PADR('AIA108',nTamSX1)
	cDescTipGer := 'ORDEM DE PRODUCAO'
	aAdd(aParam,nReqMatOP)
	aAdd(aParam,nAglutArmOP)
endif

aAdd(aPerg,{"P A R A M E T R O S : "+cDescTipGer,cPergParam})
aAdd(aPerg,{"C O N F I G U R A C O E S : "+cDescTipGer,cPergConfig})
//-- Carrega parametros SX1
_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
dbSelectArea(_cAliasSX1)
(_cAliasSX1)->(dbSetOrder(1))
for ni := 1 to len(aPerg)
	ci := 1
	aAdd(aLogs,{aPerg[ni,2],{}})
	(_cAliasSX1)->(dbSeek(aPerg[ni,2]))
	while (_cAliasSX1)->(!Eof() .AND. (_cAliasSX1)->X1_GRUPO == aPerg[ni,2])
		if (_cAliasSX1)->X1_GSC == 'G'
			cTexto := (_cAliasSX1)->("Pergunta "+(_cAliasSX1)->X1_ORDEM+": "+(_cAliasSX1)->X1_PERGUNT+Alltrim((_cAliasSX1)->X1_CNT01))
		else
			if ni == 1
				cTexto := (_cAliasSX1)->("Pergunta "+(_cAliasSX1)->X1_ORDEM+": "+(_cAliasSX1)->X1_PERGUNT+If((_cAliasSX1)->X1_PRESEL==1,"Sim","Nao"))
			else
				cTexto := (_cAliasSX1)->("Pergunta "+(_cAliasSX1)->X1_ORDEM+": "+(_cAliasSX1)->X1_PERGUNT+If(aParam[ci++]==1,"Sim","Nao"))
			endif
		endif
		aAdd(aLogs[ni,2],cTexto)
		(_cAliasSX1)->(dbSkip())
	enddo
next
//-- Gera Log
for ni := 1 to len(aPerg)
	AutoGRLog(Replicate("=",75))
	AutoGRLog(aPerg[ni,1])
	AutoGRLog(Replicate("=",75))
	for ci := 1 to len(aLogs[ni,2])
		AutoGRLog(aLogs[ni,2,ci])
	next
next
AutoGRLog(Replicate("=",75))
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ AtivaF12 ³ Autor ³ Henrique Gomes Oikawa ³ Data ³ 27/09/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa a Funcao da Pergunte                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function AtivaF12(nOrigExp)
	local lPerg := .F.
	local lRet  := .T.
	if nOrigExp == NIL
		lPerg := .T.
		if (lRet:=Pergunte("AIA101",.T.))
			nOrigExp := MV_PAR01
		endif
	endif
	if lRet
		if nOrigExp == 1  //Origem: Pedidos de Venda
			if Pergunte("AIA106",lPerg) .Or. !lPerg
	/*
				nConfLote  := MV_PAR01
				nEmbSimul  := MV_PAR02
				nEmbalagem := MV_PAR03
				nGeraNota  := MV_PAR04
				nImpNota   := MV_PAR05
				nImpEtVol  := MV_PAR06
				nEmbarque  := MV_PAR07
				nAglutPed  := MV_PAR08
				nAglutArm  := MV_PAR09
	*/
				nConfLote	:= MV_PAR01
				nEmbSimul	:= MV_PAR02
				nEmbalagem	:= MV_PAR03
				if cPaisLoc == "BRA"
					nGeraNota	:= MV_PAR04
					nImpNota	:= MV_PAR05
					nImpEtVol	:= MV_PAR06
					nEmbarque	:= MV_PAR07
					nAglutPed	:= MV_PAR08
					nAglutArm	:= MV_PAR09 
				else
					nImpEtVol	:= MV_PAR04
					nEmbarque	:= MV_PAR05
					nAglutPed	:= MV_PAR06
					nAglutArm	:= MV_PAR07
				endif
			endif
		elseif nOrigExp == 2  //Origem: Notas Fiscais
			if Pergunte("AIA107",lPerg) .Or. !lPerg
				nEmbSimuNF := MV_PAR01
				nEmbalagNF := MV_PAR02
				nImpNotaNF := MV_PAR03
				nImpVolNF  := MV_PAR04
				nEmbarqNF  := MV_PAR05
			endif
		else  //Origem: Ordens de Producao
			if Pergunte("AIA108",lPerg) .Or. !lPerg
				nReqMatOP   := MV_PAR01
				nAglutArmOP := MV_PAR02
			endif
		endif
	endif
return
