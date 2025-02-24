#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE ENT CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณRFINE033  บAutor  ณAnderson C. P. Coelho บ Data ณ  17/04/17 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Nova rotina de gera็ใo de pedidos de compras com as        บฑฑ
ฑฑบ          ณcomiss๕es, baseado na SE3 para os vendedores com o campo    บฑฑ
ฑฑบ          ณde integra็ใo com a SE2 (A3_GERASE2) igual a 'P' (Pedido de บฑฑ
ฑฑบ          ณcompras). A rotina somente gerarแ comiss๕es para regitros daบฑฑ
ฑฑบ          ณSE3 que nใo tenham data de pagamento preenchida pela rotina บฑฑ
ฑฑบ          ณpadrใo de 'Atualiza Pgto. das Comiss๕es' ou que tenham o    บฑฑ
ฑฑบ          ณcampo customizado 'E3_SALDO' maior que zero.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user function RFINE033()
	Local _aSavArea := GetArea()
	Local _aSavSC7	:= SC7->(GetArea())
	Local _aSavSE3	:= SE3->(GetArea())
	Local _aSavSA3	:= SA3->(GetArea())

	Private _MV_PAR01, _MV_PAR02, _MV_PAR03, _MV_PAR04, _MV_PAR06, _MV_PAR07
	Private oMark, oMark2
	Private _btnOk, _btnCancel, _bMarkAll, _bDesmAll
	Private lblPeriodo, lblDataCons, lblVlrLimit, lblLimite, lblVlrSelec, lblSelecionado
	Private aMarcados[2]
	Private nMarcado    := 0
	Private _cRotina    := "RFINE033"
	Private cCadastro   := "Atual. Pgto. das Comiss๕es - Ped. Compras"
	Private cPerg       := _cRotina
	Private cMark		:= GetMARK()
	Private _cTabTmp1	:= GetNextAlias()
	Private _cTabTmp2	:= _cTabTmp1+"2"
	Private _cTabRet	:= _cTabTmp1+"3"
	Private _cInd1      := ""
	Private _cInd2      := ""
	Private _nLimite    := 0
	Private _nValSel    := 0
	Private _nTamBtn	:= 54
	Private _nEspPad	:= 8
	Private _dToler     := 0
	Private _nTamMark	:= Len(cMark)
	Private lInverte    := .F.
	Private _aSize      := MsAdvSize()
	Private oFont1		:= TFont():New("MS Sans Serif",,018,,.T.,,,,,.F.,.F.)
//	Private oFont2		:= TFont():New("MS Sans Serif",,016,,.T.,,,,,.F.,.F.)
	Private _aCpos1     := {}
	Private _aCampos1   := {}
	Private aRecnoSE2RA := {}
	Private _aVincPA    := {}

	// Altera็ใo - Fernando Bombardi - ALLSS - 03/03/2022
	//If MsgBox("Esta rotina irแ gerar pedidos de compras de acordo com as comiss๕es dos vendedores. Deseja continuar?", _cRotina + "_001", "YESNO")
	If MsgBox("Esta rotina irแ gerar pedidos de compras de acordo com as comiss๕es dos representantes. Deseja continuar?", _cRotina + "_001", "YESNO")
	// Fim - Fernando Bombardi - ALLSS - 03/03/2022

		//Defini็ใo dos parโmetros da rotina
		ValidPerg()
	 	//Apresenta tela de parโmetros
		If !Pergunte(cPerg,.T.)
			return
		EndIf
		If dDataBase >= MV_PAR03 .AND. dDataBase >= MV_PAR04
			_MV_PAR01 := MV_PAR01
			_MV_PAR02 := MV_PAR02
			_MV_PAR03 := MV_PAR03
			_MV_PAR04 := MV_PAR04
			_MV_PAR06 := MV_PAR06
			_MV_PAR07 := MV_PAR07
			_dToler   := (dDataBase-_MV_PAR06)
			//Estruturas utilizas para o oMark (Primeiro MarkBrowse) e oMark3 (segundo MarkBrose de Reservas/Retencoes)
			//Monto estrutura para tabela temporแria que serแ utilizada no markbrowse
			AADD(_aCpos1,{"TM_OK"  		,"C"                     ,_nTamMark                 ,0                       })
			AADD(_aCpos1,{"TM_VEND" 	,TamSx3("E3_VEND"	)[03],TamSx3("E3_VEND"   )[01]	,TamSx3("E3_VEND"	)[02]})
			AADD(_aCpos1,{"TM_NOMEVEN" 	,TamSx3("A3_NOME"	)[03],TamSx3("A3_NOME"   )[01]	,TamSx3("A3_NOME"	)[02]})
			AADD(_aCpos1,{"TM_PREFIXO" 	,TamSx3("E1_PREFIXO")[03],TamSx3("E1_PREFIXO")[01]	,TamSx3("E1_PREFIXO")[02]})
			AADD(_aCpos1,{"TM_NUM"		,TamSx3("E1_NUM"	)[03],TamSx3("E1_NUM"    )[01]	,TamSx3("E1_NUM"	)[02]})
			AADD(_aCpos1,{"TM_PARCELA"	,TamSx3("E1_PARCELA")[03],TamSx3("E1_PARCELA")[01]	,TamSx3("E1_PARCELA")[02]})
			AADD(_aCpos1,{"TM_TIPO"		,TamSx3("E3_TIPO"	)[03],TamSx3("E3_TIPO"   )[01]	,TamSx3("E3_TIPO"	)[02]})
			AADD(_aCpos1,{"TM_CODCLI"	,TamSx3("E1_CLIENTE")[03],TamSx3("E1_CLIENTE")[01]	,TamSx3("E1_CLIENTE")[02]})
			AADD(_aCpos1,{"TM_LOJACLI"	,TamSx3("E1_LOJA"	)[03],TamSx3("E1_LOJA"   )[01]	,TamSx3("E1_LOJA"	)[02]})
			AADD(_aCpos1,{"TM_NOMECLI"	,TamSx3("A1_NOME"	)[03],TamSx3("A1_NOME"   )[01]	,TamSx3("A1_NOME"	)[02]})
			AADD(_aCpos1,{"TM_PEDIDO"	,TamSx3("E3_PEDIDO"	)[03],TamSx3("E3_PEDIDO" )[01]	,TamSx3("E3_PEDIDO"	)[02]})
			AADD(_aCpos1,{"TM_EMISSAO"	,TamSx3("E3_EMISSAO")[03],TamSx3("E3_EMISSAO")[01]	,TamSx3("E3_EMISSAO")[02]})
			AADD(_aCpos1,{"TM_VENCTO"	,TamSx3("E3_VENCTO"	)[03],TamSx3("E3_VENCTO" )[01]	,TamSx3("E3_VENCTO"	)[02]})
			AADD(_aCpos1,{"TM_VALOR"	,TamSx3("E1_VALOR"	)[03],TamSx3("E1_VALOR"	 )[01]	,TamSx3("E1_VALOR"	)[02]})
			AADD(_aCpos1,{"TM_SALDO"	,TamSx3("E1_SALDO"	)[03],TamSx3("E1_SALDO"	 )[01]	,TamSx3("E1_SALDO"	)[02]})
			AADD(_aCpos1,{"TM_BASE"		,TamSx3("E3_BASE"	)[03],TamSx3("E3_BASE"	 )[01]	,TamSx3("E3_BASE"	)[02]})
			AADD(_aCpos1,{"TM_PORC"		,TamSx3("E3_PORC"	)[03],TamSx3("E3_PORC"	 )[01]	,TamSx3("E3_PORC"	)[02]})
			AADD(_aCpos1,{"TM_COMIS"	,TamSx3("E3_COMIS"	)[03],TamSx3("E3_COMIS"	 )[01]	,TamSx3("E3_COMIS"	)[02]})
			AADD(_aCpos1,{"TM_ATRASO"	,TamSx3("E1_VALOR"	)[03],TamSx3("E1_VALOR"	 )[01]	,TamSx3("E1_VALOR"	)[02]})
			AADD(_aCpos1,{"TM_LIMITE"	,TamSx3("E1_VALOR"	)[03],TamSx3("E1_VALOR"	 )[01]	,TamSx3("E1_VALOR"	)[02]})
			AADD(_aCpos1,{"TM_RESERVA"  ,TamSx3("E1_VALOR"	)[03],TamSx3("E1_VALOR"	 )[01]	,TamSx3("E1_VALOR"	)[02]})
			AADD(_aCpos1,{"TM_BAIEMI"	,TamSx3("E3_BAIEMI"	)[03],TamSx3("E3_BAIEMI" )[01]	,TamSx3("E3_BAIEMI"	)[02]})
			AADD(_aCpos1,{"TM_FORNECE"	,TamSx3("A3_FORNECE")[03],TamSx3("A3_FORNECE")[01]	,TamSx3("A3_FORNECE")[02]})
			AADD(_aCpos1,{"TM_LOJA"   	,TamSx3("A3_LOJA"   )[03],TamSx3("A3_LOJA"   )[01]	,TamSx3("A3_LOJA"   )[02]})
			AADD(_aCpos1,{"TM_PRODUTO"	,TamSx3("A3_PRODCOM")[03],TamSx3("A3_PRODCOM")[01]	,TamSx3("A3_PRODCOM")[02]})
			AADD(_aCpos1,{"TM_RECSE3"	, "N"                    , 17                       , 0                      })
			AADD(_aCpos1,{"TM_RECSA3"	, "N"                    , 17                       , 0                      })
			AADD(_aCpos1,{"TM_RECSE1"	, "N"                    , 17                       , 0                      })
			AADD(_aCpos1,{"TM_IDAP"		, "C"                    , 10                       , 0                      })

			//Campos que serใo apresentados no markbrowse
			AADD(_aCampos1,{"TM_OK"  		,"" ,Space(_nTamMark)		,"" })

			// Altera็ใo - Fernando Bombardi - ALLSS - 03/03/2022
			//AADD(_aCampos1,{"TM_VEND" 		,"" ,"Vendedor"   			,"" })
			//AADD(_aCampos1,{"TM_NOMEVEN"	,"" ,"Nome Vendedor"		,"" })
			AADD(_aCampos1,{"TM_VEND" 		,"" ,"Representante"  		,"" })
			AADD(_aCampos1,{"TM_NOMEVEN"	,"" ,"Nome Representante"	,"" })
			// Fim - Fernando Bombardi - ALLSS - 03/03/2022

			AADD(_aCampos1,{"TM_PREFIXO"	,"" ,"Prefixo"   			,"" })
			AADD(_aCampos1,{"TM_NUM"		,"" ,"N๚mero"   			,"" })
			AADD(_aCampos1,{"TM_PARCELA"	,"" ,"Parcela"   			,"" })
			AADD(_aCampos1,{"TM_CODCLI"		,"" ,"Cliente"   			,"" })
			AADD(_aCampos1,{"TM_NOMECLI"	,"" ,"Razใo Social"			,"" })
			AADD(_aCampos1,{"TM_EMISSAO"	,"" ,"Dt Comissใo"			,"" })
			AADD(_aCampos1,{"TM_VALOR"		,"" ,"Vlr Titulo"			,"" })
			AADD(_aCampos1,{"TM_BASE"		,"" ,"Vlr Base"				,"" })
			AADD(_aCampos1,{"TM_PORC"		,"" ,"%"					,"" })
			AADD(_aCampos1,{"TM_COMIS"		,"" ,"Comissใo"				,"" })
			AADD(_aCampos1,{"TM_ATRASO"		,"" ,"Atraso"  				,"" })
			AADD(_aCampos1,{"TM_LIMITE"		,"" ,"Limite"  				,"" })
			AADD(_aCampos1,{"TM_RESERVA" 	,"" ,"Reserva/Reten็ใo"		,"" })
			AADD(_aCampos1,{"TM_SALDO"		,"" ,"Saldo Titulo"			,"" })
			AADD(_aCampos1,{"TM_VENCTO"		,"" ,"Vencimento"			,"" })
			AADD(_aCampos1,{"TM_PEDIDO"		,"" ,"Pedido"				,"" })
			AADD(_aCampos1,{"TM_LOJACLI"	,"" ,"Loja Cliente"			,"" })
			AADD(_aCampos1,{"TM_TIPO"		,"" ,"Tipo"   				,"" })
			AADD(_aCampos1,{"TM_BAIEMI"		,"" ,"Baixa/Emissใo"		,"" })
			AADD(_aCampos1,{"TM_FORNECE"	,"" ,"Fornecedor"   		,"" })
			AADD(_aCampos1,{"TM_LOJA"   	,"" ,"Loja"         		,"" })
			AADD(_aCampos1,{"TM_PRODUTO"	,"" ,"Produto"      		,"" })
			AADD(_aCampos1,{"TM_RECSE3"		,"" ,"Recno Comiss."		,"" })
			AADD(_aCampos1,{"TM_RECSA3"		,"" ,"Recno Vendedor"		,"" })
			AADD(_aCampos1,{"TM_RECSE1"		,"" ,"Recno T.Receb."		,"" })
			AADD(_aCampos1,{"TM_IDAP"		,"" ,"ID a Processar"		,"" })

			MsAguarde( { |lEnd| Process() },"["+_cRotina+"] "+cCadastro,"Processando comiss๕es...",.T.)
		Else
			MsgStop("Atencao! A database do sistema esta em desacordo com os parametros de data informados!",_cRotina+"_015")
		EndIf
	EndIf
	RestArea(_aSavSA3)
	RestArea(_aSavSE3)
	RestArea(_aSavSC7)
	RestArea(_aSavArea)
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณProcess   บAutor  ณAnderson C. P. Coelho บ Data ณ  17/04/17 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de apresenta็ใo da tela de Mark-Browse para a sele- บฑฑ
ฑฑบ          ณ็ใo dos registros que irใo gerar os pedidos de compras de   บฑฑ
ฑฑบ          ณcomiss๕es.                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function Process()
	Static oDlg
	DEFINE MSDIALOG oDlg TITLE "Selecione as comiss๕es a serem pagas" FROM _aSize[1], _aSize[1]  TO _aSize[6], _aSize[5]                        COLORS 0        , 16777215 PIXEL STYLE DS_MODALFRAME
		oDlg:lEscClose := .F.
	//	_nLimite := VlrSelecao() //Total selecionado
		//Labels
		@ 009, 013 SAY lblPeriodo 		PROMPT "Perํodo:" 										SIZE _aSize[1]+025, 007 OF oDlg 				COLORS 0		, 16777215 PIXEL
		@ 008, 034 SAY lblDataCons 		PROMPT DtoC(_MV_PAR03) + " - " + DtoC(_MV_PAR04)		SIZE _aSize[1]+107, 010 OF oDlg FONT oFont1 	COLORS 16711680	, 16777215 PIXEL
		@ 009, 124 SAY lblVlrLimit 		PROMPT "Valor Limite:" 									SIZE _aSize[1]+037, 007 OF oDlg 				COLORS 0		, 16777215 PIXEL
		@ 008, 162 SAY lblLimite 		PROMPT Transform(_nLimite,PesqPict("SE3","E3_COMIS")) 	SIZE _aSize[1]+050, 010 OF oDlg FONT oFont1 	COLORS 16711680	, 16777215 PIXEL
		@ 009, 232 SAY lblVlrSelec 		PROMPT "Valor Selecionado:" 							SIZE _aSize[1]+054, 007 OF oDlg 				COLORS 0		, 16777215 PIXEL
		@ 008, 287 SAY lblSelecionado 	PROMPT Transform(_nValSel,PesqPict("SE3","E3_COMIS")) 	SIZE _aSize[1]+050, 010 OF oDlg FONT oFont1 	COLORS 16711680	, 16777215 PIXEL
		//MarkBrowse
		SelecaoSE3()
		//Bot๕es
		@ 008/*_aSize[6]-295*/, _aSize[3]-(_nTamBtn*4)-(_nEspPad*4) 	BUTTON _bMarkAll 	PROMPT "&Marca Todos"    SIZE _nTamBtn, 012 OF oDlg ACTION MarkDesmark1("M") PIXEL
		@ 008/*_aSize[6]-295*/, _aSize[3]-(_nTamBtn*3)-(_nEspPad*3) 	BUTTON _bDesmAll 	PROMPT "&Desmarca Todos" SIZE _nTamBtn, 012 OF oDlg ACTION MarkDesmark1("D") PIXEL
		@ 008/*_aSize[6]-295*/, _aSize[3]-(_nTamBtn*2)-(_nEspPad*2) 	BUTTON _btnOk 		PROMPT "&Confirmar"      SIZE _nTamBtn, 012 OF oDlg ACTION Confirmar() 	     PIXEL
		@ 008/*_aSize[6]-295*/, _aSize[3]-(_nTamBtn*1)-(_nEspPad*1) 	BUTTON _btnCancel 	PROMPT "&Fechar" 	     SIZE _nTamBtn, 012 OF oDlg ACTION Close(oDlg)	     PIXEL
	ACTIVATE MSDIALOG oDlg CENTERED
return
static function MarkDesmark1(_cOperM)
	Local   _aTbTmp := GetArea()
	default _cOperM := "I"
	_nValSel        := 0
	dbSelectArea(_cTabTmp1)
	(_cTabTmp1)->(dbGoTop())
	While !(_cTabTmp1)->(EOF())
		while !RecLock(_cTabTmp1,.F.) ; enddo
			If _cOperM == "M" .OR. (_cOperM == "I" .AND. Empty((_cTabTmp1)->TM_OK))			//!Marked("TM_OK")
				(_cTabTmp1)->TM_OK      := cMark
			Else
				(_cTabTmp1)->TM_OK      := Space(Len(cMark))
			EndIf
		(_cTabTmp1)->(MSUNLOCK())
		If !Empty((_cTabTmp1)->TM_OK)
			_nValSel += (_cTabTmp1)->TM_COMIS
		EndIf
		dbSelectArea(_cTabTmp1)
		(_cTabTmp1)->(dbSkip())
	EndDo
	If Type("oMark")=="O"
		oMark:oBrowse:Refresh()
	EndIf
	RestArea(_aTbTmp)
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณSelecaoSE3บAutor  ณAnderson C. P. Coelho บ Data ณ  17/04/17 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de montagem do mark-browse.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function SelecaoSE3()
	/* FB - RELEASE 12.1.23
	_cInd1 := CriaTrab(_aCpos1,.T.)
	//Crio tabela temporแria para uso com markbrowse
	dbUseArea(.T.,,_cInd1,_cTabTmp1,.T.,.F.)
	IndRegua(_cTabTmp1,_cInd1,"TM_VEND + TM_PREFIXO + TM_NUM + TM_PARCELA + TM_BAIEMI + TM_CODCLI + TM_LOJACLI + DTOS(TM_EMISSAO)","D",,"Criando ํndice temporแrio...")
	*/
	//-------------------
	//Criacao do objeto
	//-------------------
	_cTabTmp1 := GetNextAlias()
	oTmpTab01 := FWTemporaryTable():New( _cTabTmp1 )
	
	oTmpTab01:SetFields( _aCpos1 )
	oTmpTab01:AddIndex("indice1", {"TM_VEND","TM_PREFIXO","TM_NUM","TM_PARCELA","TM_BAIEMI","TM_CODCLI","TM_LOJACLI","TM_EMISSAO"} )
	//------------------
	//Criacao da tabela
	//------------------
	oTmpTab01:Create()
	
	/*
	//Limpo o campo de marca
	If TCSQLExec("UPDATE "+RetSQLName("SE3")+ " SET E3_MARK = '' ") <> 0
		MsgAlert("Problemas ao tentar limparo campo E3_MARK. Contate o administrador!" + ENT + TCSqlError(),_cRotina+"_006")
	EndIf
	TcRefresh("SE3")
	*/
	//TRATO OS TอTULOS DE COMISSีES APENAS (COM VอNCULO DIRETO A SE3)
	_cQtmp  := GetNextAlias()
	//Query para retornar os tํtulos de comissใo a serem processados
	//_cQry	:= "SELECT CASE WHEN SE3.E3_PREFIXO='RET' THEN '" + cMark + "' ELSE '' END AS [OK], " + ENT
	_cQry	:= "SELECT DISTINCT '" + cMark + "'    TM_OK     , '' TM_IDAP " + ENT
	_cQry	+= "       , ISNULL(SA3.A3_COD    ,'') TM_VEND   , ISNULL(SA3.A3_NOME   ,'') TM_NOMEVEN " + ENT
	_cQry	+= "       , ISNULL(SE1.E1_PREFIXO,'') TM_PREFIXO, ISNULL(SE1.E1_NUM    ,'') TM_NUM    , ISNULL(SE1.E1_PARCELA,'') TM_PARCELA, ISNULL(SE1.E1_TIPO   ,'') TM_TIPO    " + ENT
	_cQry	+= "       , ISNULL(SE1.E1_CLIENTE,'') TM_CODCLI , ISNULL(SE1.E1_LOJA   ,'') TM_LOJACLI, ISNULL(SE1.E1_NOMCLI ,'') TM_NOMECLI, ISNULL(SE1.E1_PEDIDO ,'') TM_PEDIDO  " + ENT
	_cQry	+= "       , ISNULL(SE3.E3_EMISSAO,'') TM_EMISSAO " + ENT
	_cQry	+= "       , ISNULL(SE1.E1_VENCTO ,'') TM_VENCTO , ISNULL(SE1.E1_VALOR  ,0 ) TM_VALOR  , ISNULL(SE1.E1_SALDO  ,0 ) TM_SALDO  " + ENT
	_cQry	+= "       ,( CASE WHEN ISNULL(SE1.E1_NUM    ,'') = ISNULL(SE1.E1_NUM   ,'') " + ENT
	_cQry	+= "               THEN ISNULL(SE3.E3_BASE   ,0 ) " + ENT
	_cQry	+= "               ELSE 0        END ) TM_BASE    " + ENT
	_cQry	+= "       ,( CASE WHEN ISNULL(SE1.E1_NUM    ,'') = ISNULL(SE1.E1_NUM   ,'') " + ENT
	_cQry	+= "               THEN ISNULL(SE3.E3_PORC   ,0 ) " + ENT
	_cQry	+= "               ELSE 0        END ) TM_PORC    " + ENT
If MV_PAR08 == 1	//Somente baixas integrais
	_cQry	+= "       ,( CASE WHEN ISNULL(SE1.E1_SALDO  ,0 ) = 0 AND ISNULL(SE1.E1_NUM    ,'') = ISNULL(SE1.E1_NUM   ,'') " + ENT
Else
	_cQry	+= "       ,( CASE WHEN ISNULL(SE1.E1_NUM    ,'') = ISNULL(SE1.E1_NUM   ,'') " + ENT
EndIf
	_cQry	+= "               THEN ISNULL(SE3.E3_COMIS  ,0 ) " + ENT
	_cQry	+= "               ELSE 0        END ) TM_COMIS   " + ENT
	/*
	_cQry	+= "       ,( CASE WHEN ISNULL(SE1.E1_SALDO,0) > 0 AND ISNULL(SE1.E1_VENCTO,'') < '" + DTOS(_dToler) + "' " + ENT
	_cQry	+= "               THEN ISNULL(SE1.E1_SALDO,0)    " + ENT
	_cQry	+= "               ELSE 0        END ) TM_ATRASO " + ENT
	*/
	//If MV_PAR05 == 1		//Nใo apresenta os atrasos
		_cQry	+= "       , 0 TM_ATRASO " + ENT
	//Else
	//	_cQry	+= "       , 0 TM_ATRASO " + ENT
	//EndIf
	_cQry	+= "       , ISNULL(SA3.A3_LIMITE ,0 ) TM_LIMITE " + ENT
	_cQry	+= "       , ISNULL(SE3.E3_BAIEMI ,'') TM_BAIEMI , ISNULL(SA3.A3_FORNECE,'') TM_FORNECE, ISNULL(SA3.A3_LOJA   ,'') TM_LOJA   , ISNULL(SA3.A3_PRODCOM,'') TM_PRODUTO " + ENT
	_cQry	+= "       ,( CASE WHEN ISNULL(SE1.E1_NUM    ,'') = ISNULL(SE1.E1_NUM   ,'') " + ENT
	_cQry	+= "               THEN ISNULL(SE3.R_E_C_N_O_,0 ) "
	_cQry	+= "               ELSE 0        END ) TM_RECSE3  " + ENT
	_cQry	+= "       , ISNULL(SA3.R_E_C_N_O_,0 ) TM_RECSA3 , ISNULL(SE1.R_E_C_N_O_,0 ) TM_RECSE1 " + ENT
	_cQry	+= "FROM " + RetSqlName("SE3") + " SE3 (NOLOCK) " + ENT
	_cQry	+= "          INNER JOIN " + RetSqlName("SA3") + " SA3 (NOLOCK) ON SA3.A3_FILIAL  = '" + xFilial("SA3") + "' " + ENT
	_cQry	+= "                                                  AND SA3.A3_GERASE2 = 'P' " + ENT
	If (_MV_PAR04-_MV_PAR03) > 16
		_cQry	+= "                                              AND SA3.A3_PERIODO = 'M' " + ENT
	Else
		_cQry	+= "                                              AND SA3.A3_PERIODO = 'Q' " + ENT
	EndIf
	_cQry	+= "                                                  AND SA3.A3_COD     = SE3.E3_VEND " + ENT
	_cQry	+= "                                                  AND SA3.D_E_L_E_T_ = '' " + ENT
	_cQry	+= "           LEFT JOIN " + RetSqlName("SE1") + " SE1 (NOLOCK) ON SE1.E1_FILIAL  = '" + xFilial("SE1") + "' " + ENT
	_cQry	+= "                                                  AND ("    + ENT
	_cQry	+= "                                                         (" + ENT
	_cQry	+= "                                                              SE1.E1_NUM     = SE3.E3_NUM "     + ENT
	_cQry	+= "                                                          AND SE1.E1_SERIE   = SE3.E3_SERIE "   + ENT
	_cQry	+= "                                                          AND SE1.E1_PARCELA = SE3.E3_PARCELA " + ENT
	_cQry	+= "                                                          AND SE1.E1_TIPO    = SE3.E3_TIPO    " + ENT
	_cQry	+= "                                                         )" + ENT
	_cQry	+= "                                                  AND SE1.D_E_L_E_T_ = '' " + ENT
	//AJUSTE INSERIDO EM 20/06/2015 POR ANDERSON C. P. COELHO, UMA VEZ VEZ ESTAVAM SENDO APRESENTADOS APENAS ATRASOS VINCULADOS A TอTULOS QUE Jม GERARAM COMISSรO. DESTA VEZ, FOI ACRESCENTADO UM VอNCULO PELO VENDEDOR DA COMISSรO
	//_cQry	+= "                                                      OR (" + ENT
	//_cQry	+= "                                                              SE1.E1_SALDO   > 0 "              + ENT
	//_cQry	+= "                                                          AND (   SE1.E1_VEND1  = SA3.A3_COD "  + ENT
	//_cQry	+= "                                                               OR SE1.E1_VEND2  = SA3.A3_COD "  + ENT
	//_cQry	+= "                                                               OR SE1.E1_VEND3  = SA3.A3_COD "  + ENT
	//_cQry	+= "                                                               OR SE1.E1_VEND4  = SA3.A3_COD "  + ENT
	//_cQry	+= "                                                               OR SE1.E1_VEND5  = SA3.A3_COD "  + ENT
	//_cQry	+= "                                                              ) " + ENT
	//_cQry	+= "                                                         )" + ENT 
	//FIM DO AJUSTE INSERIDO EM 20/06/2015 POR ANDERSON C. P. COELHO, UMA VEZ VEZ ESTAVAM SENDO APRESENTADOS APENAS ATRASOS VINCULADOS A TอTULOS QUE Jม GERARAM COMISSรO. DESTA VEZ, FOI ACRESCENTADO UM VอNCULO PELO VENDEDOR DA COMISSรO
	_cQry	+= "                                                      )"    + ENT
	_cQry	+= "WHERE SE3.E3_FILIAL        = '" + xFilial("SE3")  + "' " + ENT
	_cQry	+= "  AND SE3.E3_DATA          = '' " + ENT
	_cQry	+= "  AND SE3.E3_VEND    BETWEEN '" + _MV_PAR01       + "' AND '" + _MV_PAR02       + "' " + ENT	
	_cQry	+= "  AND SE3.E3_EMISSAO BETWEEN '" + DTOS(_MV_PAR03) + "' AND '" + DTOS(_MV_PAR04) + "' " + ENT
	_cQry	+= "  AND SE3.D_E_L_E_T_       = '' " + ENT	
	//MemoWrite("\2.Memowrite\"+_cRotina+"_QRY_001.txt",_cQry)
	_cQry   := ChangeQuery(_cQry)
	//Crio tabela temporแria com tํtulos passํveis de compensa็ใo com o pedido posicionado
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cQTmp,.F.,.T.)
	//Gravo a tabela temporแria com base no resultado da query acima
	dbSelectArea(_cQTmp) //Tabela temporแria com resultado da query
	(_cQTmp)->(dbGoTop())
	While (_cQTmp)->(!EOF())
		dbSelectArea(_cTabTmp1)
		If MV_PAR08 == 2 .OR. (_cQTmp)->TM_SALDO == 0
			while !RecLock(_cTabTmp1,.T.) ; enddo
				for _x := 1 to len(_aCpos1)
					If AllTrim(_aCpos1[_x][01])=="TM_RESERVA"
						If _MV_PAR07 == 2
							(_cTabTmp1)->TM_RESERVA := (_cQTmp)->TM_ATRASO-(_cQTmp)->TM_LIMITE
							If (_cTabTmp1)->TM_RESERVA < 0
								(_cTabTmp1)->TM_RESERVA := 0
							Else
								(_cTabTmp1)->TM_RESERVA := (_cTabTmp1)->TM_RESERVA * (-1)
							EndIf
						EndIf
					ElseIf AllTrim(_aCpos1[_x][02]) == "D"
						&(_cTabTmp1+"->"+_aCpos1[_x][01]) := STOD(&(_cQTmp+"->"+_aCpos1[_x][01]))
					Else
						&(_cTabTmp1+"->"+_aCpos1[_x][01]) := &(_cQTmp+"->"+_aCpos1[_x][01])
					EndIf
				next
			(_cTabTmp1)->(MsUnlock())
			If !Empty((_cQTmp)->TM_OK)
				_nValSel += (_cQTmp)->TM_COMIS
			EndIf
			_nLimite     += (_cQTmp)->TM_COMIS
		EndIf
		dbSelectArea(_cQTmp)
		(_cQTmp)->(dbSkip())
	EndDo
	dbSelectArea(_cQTmp)
	(_cQTmp)->(dbCloseArea()) //Fecho a tabela temporแria com base no resultado da query
	dbSelectArea(_cTabTmp1)
	(_cTabTmp1)->(dbSetOrder(1))
	(_cTabTmp1)->(dbGoTop())
	//Fa็o a instancia do markbrowse
	oMark := MsSelect():New(_cTabTmp1,"TM_OK",,_aCampos1,lInverte,@cMark,{_aSize[1]+028, _aSize[1]+008, _aSize[6]-350, _aSize[3]-_nEspPad})
//	oMark:oBrowse:lHasMARK		:= .T.
	oMark:oBrowse:lCanAllMARK	:= .F.
	oMark:bAval					:= { || ChkMarca(oMark,cMark) }
	AddColMARK(oMark,"TM_OK")
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณSelRet    บAutor  ณAnderson C. P. Coelho บ Data ณ  25/10/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de montagem do mark-browse das reservas/retencoes.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function SelRet()	
	Local _aRotBkp      := IIF(Type("aRotina")<>"U",aClone(aRotina),{})
	Local _lRet         := .F.

	/* FB - RELEASE 12.1.23
	_cInd3 := CriaTrab(_aCpos1,.T.)
	//Crio tabela temporแria para uso com markbrowse
	dbUseArea(.T.,,_cInd3,_cTabRet,.T.,.F.)
	IndRegua(_cTabRet,_cInd3,"TM_VEND + TM_PREFIXO + TM_NUM + TM_PARCELA + TM_BAIEMI + TM_CODCLI + TM_LOJACLI + DTOS(TM_EMISSAO)","D",,"Criando ํndice temporแrio...")
	*/
	//-------------------
	//Criacao do objeto
	//-------------------
	_cTabRet := GetNextAlias()
	oTmpTab02 := FWTemporaryTable():New( _cTabRet )
	
	oTmpTab02:SetFields( _aCpos1 )
	oTmpTab02:AddIndex("indice1", {"TM_VEND","TM_PREFIXO","TM_NUM","TM_PARCELA","TM_BAIEMI","TM_CODCLI","TM_LOJACLI","DTOS(TM_EMISSAO)"} )
	//------------------
	//Criacao da tabela
	//------------------
	oTmpTab02:Create()
	
	/*
	//Limpo o campo de marca
	If TCSQLExec("UPDATE "+RetSQLName("SE3")+ " SET E3_MARK = '' ") <> 0
		MsgAlert("Problemas ao tentar limparo campo E3_MARK. Contate o administrador!" + ENT + TCSqlError(),_cRotina+"_006")
	EndIf
	TcRefresh("SE3")
	*/
	//TRATO OS TอTULOS DE RETENวรO (QUE ESTรO EM ATRASO E, POR ISSO, AINDA NรO GERARAM RETENวรO)
	_cQtmp  := GetNextAlias()
	//Query para retornar os tํtulos de comissใo a serem processados
	//_cQry	:= "SELECT CASE WHEN SE3.E3_PREFIXO='RET' THEN '" + cMark + "' ELSE '' END AS [OK], " + ENT
	_cQry	:= "SELECT DISTINCT '" + Space(Len(cMark)) + "' TM_OK, '' TM_IDAP " + ENT
	_cQry	+= "       , ISNULL(SA3.A3_COD    ,'') TM_VEND   , ISNULL(SA3.A3_NOME   ,'') TM_NOMEVEN " + ENT
	_cQry	+= "       , ISNULL(SE1.E1_PREFIXO,'') TM_PREFIXO, ISNULL(SE1.E1_NUM    ,'') TM_NUM    , ISNULL(SE1.E1_PARCELA,'') TM_PARCELA, ISNULL(SE1.E1_TIPO   ,'') TM_TIPO    " + ENT
	_cQry	+= "       , ISNULL(SE1.E1_CLIENTE,'') TM_CODCLI , ISNULL(SE1.E1_LOJA   ,'') TM_LOJACLI, ISNULL(SE1.E1_NOMCLI ,'') TM_NOMECLI, ISNULL(SE1.E1_PEDIDO ,'') TM_PEDIDO  " + ENT
	_cQry	+= "       , '" + DTOS(_MV_PAR04) + "'  TM_EMISSAO " + ENT
	_cQry	+= "       , ISNULL(SE1.E1_VENCTO ,'') TM_VENCTO , ISNULL(SE1.E1_VALOR  ,0 ) TM_VALOR  , ISNULL(SE1.E1_SALDO  ,0 ) TM_SALDO  " + ENT
	_cQry	+= "       , 0 TM_BASE, 0 TM_PORC, 0 TM_COMIS   " + ENT
	/*
	_cQry	+= "       ,( CASE WHEN ISNULL(SE1.E1_SALDO,0) > 0 AND ISNULL(SE1.E1_VENCTO,'') < '" + DTOS(_dToler) + "' " + ENT
	_cQry	+= "               THEN ISNULL(SE1.E1_SALDO,0)    " + ENT
	_cQry	+= "               ELSE 0        END ) TM_ATRASO " + ENT
	*/
	//If MV_PAR05 == 1		//Nใo apresenta os atrasos
		_cQry	+= "       , 0 TM_ATRASO " + ENT
	//Else
	//	_cQry	+= "       , 0 TM_ATRASO " + ENT
	//EndIf
	_cQry	+= "       , ISNULL(SA3.A3_LIMITE ,0 ) TM_LIMITE " + ENT
	_cQry	+= "       , 'E' TM_BAIEMI, ISNULL(SA3.A3_FORNECE,'') TM_FORNECE, ISNULL(SA3.A3_LOJA   ,'') TM_LOJA   , ISNULL(SA3.A3_PRODCOM,'') TM_PRODUTO " + ENT
	_cQry	+= "       , 0   TM_RECSE3, ISNULL(SA3.R_E_C_N_O_,0 ) TM_RECSA3 , ISNULL(SE1.R_E_C_N_O_,0 ) TM_RECSE1 " + ENT
	_cQry	+= "FROM " + RetSqlName("SA3") + " SA3 (NOLOCK) " + ENT
	_cQry	+= "          INNER JOIN " + RetSqlName("SE1") + " SE1 (NOLOCK) ON SE1.E1_FILIAL  = '" + xFilial("SE1") + "' " + ENT
	_cQry	+= "                                                  AND (   SE1.E1_VEND1 = SA3.A3_COD  " + ENT
	_cQry	+= "                                                       OR SE1.E1_VEND2 = SA3.A3_COD  " + ENT
	_cQry	+= "                                                       OR SE1.E1_VEND3 = SA3.A3_COD  " + ENT
	_cQry	+= "                                                       OR SE1.E1_VEND4 = SA3.A3_COD  " + ENT
	_cQry	+= "                                                       OR SE1.E1_VEND5 = SA3.A3_COD  " + ENT
	_cQry	+= "                                                      )" + ENT
	_cQry	+= "                                                  AND SE1.E1_SALDO     > 0 " + ENT
	_cQry	+= "                                                  AND SE1.E1_VENCTO    < '" + DTOS(_dToler) + "' " + ENT
	_cQry	+= "                                                  AND SE1.D_E_L_E_T_   = '' " + ENT
	_cQry	+= "WHERE SA3.A3_FILIAL        = '" + xFilial("SA3") + "' " + ENT
	_cQry	+= "  AND SA3.A3_GERASE2       = 'P' " + ENT
	If (_MV_PAR04-_MV_PAR03) > 16
		_cQry	+= "AND SA3.A3_PERIODO     = 'M' " + ENT
	Else
		_cQry	+= "AND SA3.A3_PERIODO     = 'Q' " + ENT
	EndIf
	_cQry	+= "  AND SA3.A3_COD     BETWEEN '" + _MV_PAR01      + "' AND '" + _MV_PAR02       + "' " + ENT
	_cQry	+= "  AND SA3.D_E_L_E_T_       = '' " + ENT
	//MemoWrite("\2.Memowrite\"+_cRotina+"_QRY_002.txt",_cQry)
	_cQry   := ChangeQuery(_cQry)
	//Crio tabela temporแria com tํtulos passํveis de compensa็ใo com o pedido posicionado
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cQTmp,.F.,.T.)
	//Gravo a tabela temporแria com base no resultado da query acima
	dbSelectArea(_cQTmp) //Tabela temporแria com resultado da query
	(_cQTmp)->(dbGoTop())
	While (_cQTmp)->(!EOF())
		dbSelectArea(_cTabRet)
		If MV_PAR08 == 2 .OR. (_cQTmp)->TM_SALDO == 0
			while !RecLock(_cTabRet,.T.) ; enddo
				for _x := 1 to len(_aCpos1)
					If AllTrim(_aCpos1[_x][01])=="TM_RESERVA"
						(_cTabRet)->TM_RESERVA := (_cQTmp)->TM_ATRASO-(_cQTmp)->TM_LIMITE
						If (_cTabRet)->TM_RESERVA < 0
							(_cTabRet)->TM_RESERVA := 0
						Else
							(_cTabRet)->TM_RESERVA := (_cTabRet)->TM_RESERVA * (-1)
						EndIf
					ElseIf AllTrim(_aCpos1[_x][02]) == "D"
						&(_cTabRet+"->"+_aCpos1[_x][01]) := STOD(&(_cQTmp+"->"+_aCpos1[_x][01]))
					Else
						&(_cTabRet+"->"+_aCpos1[_x][01]) := &(_cQTmp+"->"+_aCpos1[_x][01])
					EndIf
				next
			(_cTabRet)->(MsUnlock())
			If !Empty((_cQTmp)->TM_OK)
				_nValSel += (_cQTmp)->TM_COMIS
			EndIf
			_nLimite     += (_cQTmp)->TM_COMIS
		EndIf
		dbSelectArea(_cQTmp)
		(_cQTmp)->(dbSkip())
	EndDo
	dbSelectArea(_cQTmp)
	(_cQTmp)->(dbCloseArea()) //Fecho a tabela temporแria com base no resultado da query
	dbSelectArea(_cTabRet)
	(_cTabRet)->(dbSetOrder(1))
	(_cTabRet)->(dbGoTop())
	//Cria uma Dialog
	Static oDlg3
		DEFINE MSDIALOG oDlg3 TITLE "Selecione as comiss๕es a serem pagas" FROM _aSize[1], _aSize[1]  TO _aSize[6], _aSize[5] COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME
			oDlg3:lEscClose := .F.
			dbSelectArea(_cTabRet)
			(_cTabRet)->(dbGoTop())
			//Cria a MsSelect
			oMark3 := MsSelect():New(_cTabRet,"TM_OK","",_aCampos1,@lInverte,@cMark,{_aSize[1]+028, _aSize[1]+008, _aSize[6]-350, _aSize[3]-_nEspPad}/*{17,1,150,400}*//*,,,,,aCores*/)
	//		oMark3:oBrowse:lHasMARK		:= .T.
			oMark3:oBrowse:lCanAllMARK	:= .F.
			oMark3:bMark := {| | MarkYN3()}
			AddColMARK(oMark3,"TM_OK")
		ACTIVATE MSDIALOG oDlg3 CENTERED ON INIT EnchoiceBar(oDlg3,{|| _lRet := ConfMkb3()},{|| oDlg3:End()},.F./*,aButtons*/)
	aRotina := aClone(_aRotBkp)
return(_lRet)
static function ConfMkb3()
	oDlg3:End()
return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ MarkYN3  บAutor  ณAnderson C. P. Coelho บ Data ณ  17/10/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Sub-Rotina de marca็ใo/desmarca็ใo do MarkBrowse 3.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function MarkYN3()
	dbSelectArea(_cTabRet)
	while !RecLock(_cTabRet,.F.) ; enddo
		If Empty((_cTabRet)->TM_OK)		//!Marked("TM_OK")	
			(_cTabRet)->TM_OK      := cMark
			(_cTabRet)->TM_RESERVA := Retencao((_cTabRet)->TM_RESERVA)
		Else
			(_cTabRet)->TM_OK      := Space(Len(cMark))
		EndIf
	(_cTabRet)->(MSUNLOCK())
	oMark3:oBrowse:Refresh()
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณChkMarca  บAutor  ณAnderson C. P. Coelho บ Data ณ  25/10/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina marca็ใo/desmarca็ใo dos registros do mark-browse.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function ChkMarca(oMark,cMark)
	dbSelectArea(_cTabTmp1)
	If !Empty((_cTabTmp1)->TM_OK)
		while !RecLock(_cTabTmp1,.F.) ; enddo
			(_cTabTmp1)->TM_OK := Space(_nTamMark)
		(_cTabTmp1)->(MsUnLock())
		_nValSel -= (_cTabTmp1)->TM_COMIS //Atualizo o valor selecionado
	Else
		while !RecLock(_cTabTmp1,.F.) ; enddo
			(_cTabTmp1)->TM_OK      := cMark
			(_cTabTmp1)->TM_RESERVA := Retencao((_cTabTmp1)->TM_RESERVA)
		(_cTabTmp1)->(MsUnLock())
		_nValSel += (_cTabTmp1)->TM_COMIS //Atualizo o valor selecionado
	EndIf
	oMark:oBrowse:Refresh()
	lblSelecionado:SetText(Transform(_nValSel,PesqPict("SE3","E3_COMIS")))
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณConfirmar บAutor  ณAnderson C. P. Coelho บ Data ณ  25/10/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณRotina gera็ใo dos pedidos de compras, baseado nas marca็๕esบฑฑ
ฑฑบ          ณfeitas pelo usuแrio.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function Confirmar()
	Local _lCont := .F.
	Local _bTYPE01 := "Type((_cTabTmp1+'->'+_aCpos1[_x][01]))"
	Local _bTYPE02 := "Type((_cTabRet+'->'+_aCpos1[_x][01]))"
	
	//Certifico que alguma comissใo foi selecionada para pagamento antes de continuar
	If _nValSel == 0
		MsgInfo("Nenhuma comissใo foi selecionada para pagamento!",_cRotina+"_002")
		Close(oDlg)
	Else
		Close(oDlg)
		//TRATO OS TอTULOS DE RETENวรO (QUE ESTรO EM ATRASO E, POR ISSO, AINDA NรO GERARAM RETENวรO)
		If _MV_PAR07 == 2
			If MsgYesNo("Deseja selecionar as retencoes neste momento?",_cRotina+"_013") .AND. SelRet()
				dbSelectArea(_cTabRet)	//Esta tabela temporaria e criada pela sub-funcao SelRet()
				(_cTabRet)->(dbGoTop())
				While !(_cTabRet)->(EOF())
					If !Empty((_cTabRet)->TM_OK)
						dbSelectArea(_cTabTmp1)
						while !RecLock(_cTabTmp1,.T.) ; enddo
						For _x := 1 To Len(_aCpos1)
							/* FB - RELEASE 12.1.23
							If Type((_cTabTmp1+"->"+_aCpos1[_x][01]))<>"U".AND.Type((_cTabRet+"->"+_aCpos1[_x][01]))<>"U"
							*/
							If &(_bTYPE01) <> "U" .AND. &(_bTYPE02) <> "U"
								If AllTrim(_aCpos1[_x][01]) == "TM_RESERVA"
									&(_cTabTmp1+"->"+_aCpos1[_x][01]) := ABS(&(_cTabRet+"->"+_aCpos1[_x][01]))*(-1)
								Else
									&(_cTabTmp1+"->"+_aCpos1[_x][01]) := &(_cTabRet+"->"+_aCpos1[_x][01])
								EndIf
							EndIf
						Next
						(_cTabTmp1)->(MSUNLOCK())
					EndIf
					dbSelectArea(_cTabRet)
					(_cTabRet)->(dbSkip())
				EndDo
				dbSelectArea(_cTabRet)
				(_cTabRet)->(dbCloseArea())
			Else
				MsgStop("Retencoes nao selecionadas!",_cRotina+"_014")
			EndIf
		EndIf
		MsgRun("Aguarde, resumindo informa็๕es para confer๊ncia final...", "["+_cRotina+"] "+cCadastro, {|| _lCont := Resumo() })
		If _lCont .AND. MsgYesNo("Confirma a gera็ใo dos pedidos de compras com as comiss๕es selecionadas?",_cRotina+"_008")
			MsgRun("Aguarde, gerando os pedidos de compras...", "["+_cRotina+"] "+cCadastro, {|| GeraPCComis() })
		Else
			MsgAlert("Processamento abortado pelo usuแrio!",_cRotina+"_009")
		EndIf
	EndIf
	If Select(_cTabTmp1) > 0
		dbSelectArea(_cTabTmp1)
		(_cTabTmp1)->(dbCloseArea())
	EndIf
	If Select(_cTabTmp2) > 0
		dbSelectArea(_cTabTmp2)
		(_cTabTmp2)->(dbCloseArea())
	EndIf
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณResumo    บAutor  ณAnderson C. P. Coelho บ Data ณ  25/10/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณApresenta um resumo por representante do que fora           บฑฑ
ฑฑบ          ณselecionado para pagamento.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function Resumo()
	Local _aRotBkp      := IIF(Type("aRotina")<>"U",aClone(aRotina),{})
	Local _aCampos      := {}
	Local aCores        := {}
	Local aButtons      := {}
	Local _nIdAp        := 0
	Local _nVlAtraso    := 0
	Local _lRet         := .F.
	
	Local _bTYPE01      := "Type((_cTabTmp2+'->'+_aCpos[_x][01]))"
	Local _bTYPE02      := "Type((_cTabTmp1+'->'+_aCpos[_x][01]))"
	
	Private _aCpos        := {}
	
	//aRotina := {{"&Pesquisar" ,"AxPesqui"    ,0,1      },;
	//			{"&Legenda"   ,"U_RFINE33L()",0,6,0,.F.} }
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณArray com as cores da legenda                                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Aadd(aCores,{'TM_RESERVA == 0' ,'ENABLE'	})
	Aadd(aCores,{'TM_RESERVA <> 0' ,'BR_PRETO'  })

	//Monto estrutura para tabela temporแria que serแ utilizada no markbrowse
	AADD(_aCpos,{"TM_OK"  		,"C"                     ,_nTamMark                 ,0                       })
	AADD(_aCpos,{"TM_VEND" 		,TamSx3("E3_VEND"	)[03],TamSx3("E3_VEND"   )[01]	,TamSx3("E3_VEND"	)[02]})
	AADD(_aCpos,{"TM_NOMEVEN" 	,TamSx3("A3_NOME"	)[03],TamSx3("A3_NOME"   )[01]	,TamSx3("A3_NOME"	)[02]})
	AADD(_aCpos,{"TM_VALOR"		,TamSx3("E1_VALOR"	)[03],TamSx3("E1_VALOR"	 )[01]	,TamSx3("E1_VALOR"	)[02]})
	AADD(_aCpos,{"TM_SALDO"		,TamSx3("E1_SALDO"	)[03],TamSx3("E1_SALDO"	 )[01]	,TamSx3("E1_SALDO"	)[02]})
	AADD(_aCpos,{"TM_BASE"		,TamSx3("E3_BASE"	)[03],TamSx3("E3_BASE"	 )[01]	,TamSx3("E3_BASE"	)[02]})
	AADD(_aCpos,{"TM_COMIS"		,TamSx3("E3_COMIS"	)[03],TamSx3("E3_COMIS"	 )[01]	,TamSx3("E3_COMIS"	)[02]})
	AADD(_aCpos,{"TM_ATRASO"	,TamSx3("E1_VALOR"	)[03],TamSx3("E1_VALOR"	 )[01]	,TamSx3("E1_VALOR"	)[02]})
	AADD(_aCpos,{"TM_LIMITE"	,TamSx3("E1_VALOR"	)[03],TamSx3("E1_VALOR"	 )[01]	,TamSx3("E1_VALOR"	)[02]})
	AADD(_aCpos,{"TM_RESERVA"  	,TamSx3("E1_VALOR"	)[03],TamSx3("E1_VALOR"	 )[01]	,TamSx3("E1_VALOR"	)[02]})
	AADD(_aCpos,{"TM_ABATIM"    ,TamSx3("E2_DECRESC")[03],TamSx3("E2_DECRESC")[01]	,TamSx3("E2_DECRESC")[02]})
	AADD(_aCpos,{"TM_MOTABAT"   ,TamSx3("C7_MOTABAT")[03],TamSx3("C7_MOTABAT")[01]	,TamSx3("C7_MOTABAT")[02]})
	AADD(_aCpos,{"TM_TOTAL"    	,TamSx3("E2_VALOR"	)[03],TamSx3("E2_VALOR"	 )[01]	,TamSx3("E2_VALOR"	)[02]})
	AADD(_aCpos,{"TM_FORNECE"	,TamSx3("A3_FORNECE")[03],TamSx3("A3_FORNECE")[01]	,TamSx3("A3_FORNECE")[02]})
	AADD(_aCpos,{"TM_LOJA"   	,TamSx3("A3_LOJA"   )[03],TamSx3("A3_LOJA"   )[01]	,TamSx3("A3_LOJA"   )[02]})
	AADD(_aCpos,{"TM_PRODUTO"	,TamSx3("A3_PRODCOM")[03],TamSx3("A3_PRODCOM")[01]	,TamSx3("A3_PRODCOM")[02]})
	AADD(_aCpos,{"TM_COND"	    ,TamSx3("A2_COND"   )[03],TamSx3("A2_COND"   )[01]	,TamSx3("A2_COND"   )[02]})
	AADD(_aCpos,{"TM_IDAP"		, "C"                    , 10                       , 0                      })
	/* FB - RELASE 12.1.23
	_cInd2 := CriaTrab(_aCpos,.T.)
	//Crio tabela temporแria para uso com markbrowse
	dbUseArea(.T.,,_cInd2,_cTabTmp2,.T.,.F.)
	IndRegua(_cTabTmp2,_cInd2,"TM_VEND",,,"Criando ํndice temporแrio...")
	*/
	//-------------------
	//Criacao do objeto
	//-------------------
	_cTabTmp2 := GetNextAlias()
	oTmpTab03 := FWTemporaryTable():New( _cTabTmp2 )
	
	oTmpTab03:SetFields( _aCpos )
	oTmpTab03:AddIndex("indice1", {"TM_VEND"} )
	//------------------
	//Criacao da tabela
	//------------------
	oTmpTab03:Create()

	dbSelectArea(_cTabTmp1)
	(_cTabTmp1)->(dbGoTop())
	While !(_cTabTmp1)->(EOF())
		If !Empty((_cTabTmp1)->TM_OK)		//AllTrim((_cTabTmp1)->TM_OK) == AllTrim(cMark)
			dbSelectArea(_cTabTmp2)
			If (_cTabTmp2)->(dbSeek((_cTabTmp1)->TM_VEND))
				while !RecLock(_cTabTmp2,.F.) ; enddo
			Else
				//Sele็ใo dos atrasos por vendedor
				_nVlAtraso  := 0
				If MV_PAR05 == 2		//Apresenta os atrasos
					BeginSql Alias "SE1ATR"
						SELECT ISNULL(SUM(E1_SALDO),0) ATRASO
						FROM %table:SE1% SE1
						WHERE SE1.E1_FILIAL  = %xFilial:SE1%
						  AND SE1.E1_SALDO   > %Exp:0             %
						  AND SE1.E1_VENCREA < %Exp:DTOS(_dToler) %
						  AND SE1.E1_TIPO   <> %Exp:'RA'          %
						  AND SE1.E1_TIPO   <> %Exp:'NCC'         %
						  AND SE1.E1_TIPO   <> %Exp:'PR'          %
						  AND (   SE1.E1_VEND1  = %Exp:(_cTabTmp1)->TM_VEND%
						       OR SE1.E1_VEND2  = %Exp:(_cTabTmp1)->TM_VEND%
						       OR SE1.E1_VEND3  = %Exp:(_cTabTmp1)->TM_VEND%
						       OR SE1.E1_VEND4  = %Exp:(_cTabTmp1)->TM_VEND%
						       OR SE1.E1_VEND5  = %Exp:(_cTabTmp1)->TM_VEND%
						      )
						  AND SE1.%NotDel%
					EndSql
					//MemoWrite("\2.Memowrite\"+_cRotina+"_QRY_003_atrasos.txt",GetLastQuery()[02])
					dbSelectArea("SE1ATR")
						_nVlAtraso := SE1ATR->ATRASO
					SE1ATR->(dbCloseArea())
				EndIf
				//Cria็ใo do registro do vendedor
				while !RecLock(_cTabTmp2,.T.) ; enddo
				_nIdAp++
				(_cTabTmp2)->TM_IDAP    := StrZero(_nIdAp,_aCpos[aScan(_aCpos,{|x| AllTrim(x[01]) == "TM_IDAP"})][03])
				(_cTabTmp2)->TM_ATRASO  := _nVlAtraso
				(_cTabTmp2)->TM_ABATIM  := 0
				(_cTabTmp2)->TM_MOTABAT := Space(Len((_cTabTmp2)->TM_MOTABAT))
			EndIf
			For _x := 1 To Len(_aCpos)
				If AllTrim(_aCpos[_x][01])<>"TM_IDAP" .AND. AllTrim(_aCpos[_x][01])<>"TM_ATRASO" .AND. AllTrim(_aCpos[_x][01])<>"TM_ABATIM" .AND. AllTrim(_aCpos[_x][01])<>"TM_MOTABAT"
					If AllTrim(_aCpos[_x][01])=="TM_TOTAL"
						&(_cTabTmp2+"->"+_aCpos[_x][01]) += (_cTabTmp1)->TM_COMIS + (_cTabTmp1)->TM_RESERVA
					/* FB - RELEASE 12.1.23
					ElseIf Type((_cTabTmp2+"->"+_aCpos[_x][01])) == Type((_cTabTmp1+"->"+_aCpos[_x][01]))
					*/
					ElseIf &(_bTYPE01) == &(_bTYPE02) 
						If _aCpos[_x][02] == "C" .OR. AllTrim(_aCpos[_x][01]) == "TM_LIMITE"
							&(_cTabTmp2+"->"+_aCpos[_x][01]) := &(_cTabTmp1+"->"+_aCpos[_x][01])
						ElseIf _aCpos[_x][02] == "N"
							&(_cTabTmp2+"->"+_aCpos[_x][01]) += &(_cTabTmp1+"->"+_aCpos[_x][01])
						EndIf
					EndIf
				EndIf
			Next
			(_cTabTmp2)->TM_COND := POSICIONE("SA2",1,xFilial("SA2") + (_cTabTmp2)->TM_FORNECE + (_cTabTmp2)->TM_LOJA, "A2_COND")
			(_cTabTmp2)->(MSUNLOCK())
			dbSelectArea(_cTabTmp1)
			while !RecLock(_cTabTmp1,.F.) ; enddo
				(_cTabTmp1)->TM_IDAP := StrZero(_nIdAp,_aCpos[aScan(_aCpos,{|x| AllTrim(x[01]) == "TM_IDAP"})][03])
			(_cTabTmp1)->(MSUNLOCK())
		EndIf
		dbSelectArea(_cTabTmp1)
		(_cTabTmp1)->(dbSkip())
	EndDo
	AADD(_aCampos,{"TM_OK"  		,"" ,Space(_nTamMark)		,""                  })
	
	// Altera็ใo - Fernando Bombardi - ALLSS - 03/03/2022
	//AADD(_aCampos,{"TM_VEND" 		,"" ,"Vendedor"   			,""                  })
	AADD(_aCampos,{"TM_VEND" 		,"" ,"Representante" 		,""                  })
	// Fim - Fernando Bombardi - ALLSS - 03/03/2022

	AADD(_aCampos,{"TM_NOMEVEN"		,"" ,"Nome Representante"	,"@!"                })
	AADD(_aCampos,{"TM_VALOR"		,"" ,"Vlr Titulo"			,"@E 999,999,999.99" })
	AADD(_aCampos,{"TM_SALDO"		,"" ,"Saldo Titulo"			,"@E 999,999,999.99" })
	AADD(_aCampos,{"TM_BASE"		,"" ,"Vlr Base"				,"@E 999,999,999.99" })
	AADD(_aCampos,{"TM_COMIS"		,"" ,"Comissใo"				,"@E 999,999,999.99" })
	AADD(_aCampos,{"TM_ATRASO"		,"" ,"Atraso"  				,"@E 999,999,999.99" })
	AADD(_aCampos,{"TM_LIMITE"		,"" ,"Limite"  				,"@E 999,999,999.99" })
	AADD(_aCampos,{"TM_RESERVA"		,"" ,"Reserva/Reten็ใo"		,"@E 999,999,999.99" })
	AADD(_aCampos,{"TM_TOTAL"		,"" ,"Val.Bruto"        	,"@E 999,999,999.99" })
	AADD(_aCampos,{"TM_ABATIM"		,"" ,"Abatimento"	        ,"@E 999,999,999.99" })
	AADD(_aCampos,{"TM_MOTABAT"		,"" ,"Motivo Abatimento"    ,""                  })
	AADD(_aCampos,{"TM_FORNECE"		,"" ,"Fornecedor"   		,""                  })
	AADD(_aCampos,{"TM_LOJA"   		,"" ,"Loja"         		,""                  })
	AADD(_aCampos,{"TM_PRODUTO"		,"" ,"Produto"      		,""                  })
	AADD(_aCampos,{"TM_COND"		,"" ,"Cond.Pgto."      		,""                  })
	AADD(_aCampos,{"TM_IDAP"		,"" ,"ID a Processar"		,""                  })
	//dbSelectArea(_cTabTmp2)
	//(_cTabTmp2)->(dbGoTop())
	//MarkBrow(_cTabTmp2,_aCpos[1],,_aCampos,.F.,cMark,,,,,,,,,aCores,)
	//MarkBrow(_cTabTmp2,_aCpos[1],,_aCampos,.F.,cMark)
	//MarkBrow(_cTabTmp2,_aCpos[1],,_aCampos,.F.,GetMark(,_cTabTmp2,"TM_OK"))
	AADD(aButtons, {"ANALITIC", {|| U_RFINE33L()   }, "&Legenda"     })
	AADD(aButtons, {"ANALITIC", {|| U_RFINE33M("M")}, "&Marca    Todos"  })
	AADD(aButtons, {"ANALITIC", {|| U_RFINE33M("D")}, "&Desmarca Todos"  })
	AADD(aButtons, {"ANALITIC", {|| U_RFINE33M("I")}, "&Inverte Sele็ใo" })
	AADD(aButtons, {"FINIMG32", {|| U_RFINE33V()   }, "&Vincula PA"      })
	AADD(aButtons, {"FINIMG32", {|| U_RFINE33A()   }, "&Aplica Abatimto."})
	//Cria uma Dialog
	Static oDlg2
		DEFINE MSDIALOG oDlg2 TITLE "Selecione as comiss๕es a serem pagas" FROM _aSize[1], _aSize[1]  TO _aSize[6], _aSize[5] COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME
			oDlg2:lEscClose := .F.
			dbSelectArea(_cTabTmp2)
			(_cTabTmp2)->(dbGoTop())
			//Cria a MsSelect
			oMark2 := MsSelect():New(_cTabTmp2,"TM_OK","",_aCampos,@lInverte,@cMark,{_aSize[1]+028, _aSize[1]+008, _aSize[6]-350, _aSize[3]-_nEspPad}/*{17,1,150,400}*/,,,,,aCores)
	//		oMark2:oBrowse:lHasMARK		:= .T.
			oMark2:oBrowse:lCanAllMARK	:= .F.
			oMark2:bMark := {| | MarkYN2(oMark2,cMark)}
			AddColMARK(oMark2,"TM_OK")
		ACTIVATE MSDIALOG oDlg2 CENTERED ON INIT EnchoiceBar(oDlg2,{|| _lRet := ConfMkb2()},{|| oDlg2:End()},.F.,aButtons)
		aRotina := aClone(_aRotBkp)
return(_lRet)
static function ConfMkb2()
	oDlg2:End()
return(.T.)
user function RFINE33M(_cOperM)
	Local   _aTbTmp := GetArea()
	default _cOperM := "I"
	dbSelectArea(_cTabTmp2)
	(_cTabTmp2)->(dbGoTop())
	While !(_cTabTmp2)->(EOF())
		while !RecLock(_cTabTmp2,.F.) ; enddo
			If _cOperM == "M" .OR. (_cOperM == "I" .AND. Empty((_cTabTmp2)->TM_OK))		//!Marked("TM_OK")
				(_cTabTmp2)->TM_OK      := cMark
			Else
				(_cTabTmp2)->TM_OK      := Space(Len(cMark))
			EndIf
		(_cTabTmp2)->(MSUNLOCK())
		dbSelectArea(_cTabTmp2)
		(_cTabTmp2)->(dbSkip())
	EndDo
	If Type("oMark2")=="O"
		oMark2:oBrowse:Refresh()
	EndIf
	RestArea(_aTbTmp)
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ MarkYN2  บAutor  ณAnderson C. P. Coelho บ Data ณ  17/10/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Sub-Rotina de marca็ใo/desmarca็ใo do MarkBrowse 2.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function MarkYN2(oMark2,cMark)
	Local _aAlias  := GetArea()
	Local _aAlias2 := (_cTabTmp2)->(GetArea())

	dbSelectArea(_cTabTmp2)
	while !RecLock(_cTabTmp2,.F.) ; enddo
		If Empty((_cTabTmp2)->TM_OK)
			(_cTabTmp2)->TM_OK := ""//Space(_nTamMark)
			(_cTabTmp2)->(MSUNLOCK())
		Else	
			(_cTabTmp2)->TM_OK := cMark
			(_cTabTmp2)->(MSUNLOCK())
			If (_cTabTmp2)->TM_COMIS > 0
				U_RFINE33V()
				If MsgYesNo("Aplica abatimento para esta comissใo?",_cRotina+"_018")
					U_RFINE33A()
				EndIf
			EndIf
		EndIf
	RestArea(_aAlias2)
	RestArea(_aAlias)
	oMark2:oBrowse:Refresh()
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ RFINE33L บAutor  ณAnderson C. P. Coelho บ Data ณ  17/10/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ ExecBlock para defini็ใo da legenda no segundo mark-browse บฑฑ
ฑฑบ          ณ da rotina.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user function RFINE33L()
	_aLeg := {	{'BR_PRETO','Comissใo com reserva/reten็ใo'},;
				{'ENABLE'  ,'Comissใo sem reserva/reten็ใo'} }
	BrwLegenda('Pedidos de Compras de','Legenda',_aLeg)
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณGeraPCComisบAutor  ณAnderson C. P. Coelho บ Data ณ 17/10/14 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de gera็ใo dos pedidos de compras.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function GeraPCComis()
	Local _nPos         := 0
	Local _Ad           := 0
	Local _nQuanti      := 1								//Default
	Local _nOpc         := 3 								//Inclusใo (ExecAuto)
	Local _nValor       := 0
	Local _nVendOK      := 0
	Local _nVendER      := 0
	Local _nDesmark     := 0
	//Local _nDProxPer    := SuperGetMv("MV_DPROPER",,30 )	//Dias para o pr๓ximo perํodo
	Local _cNMoeda      := SuperGetMv("MV_CMMOEDA",,1  ) 	//Real
	Local _cTxMoed      := SuperGetMv("MV_CMTXMOE",,1  ) 	//Taxa de conversใo zerada
	Local _cDemonstr    := ""
	Local _cNumPed      := ""
	Local _cNumSc       := ""
	Local _cProdu       := ""
	Local _cForne       := ""
	Local _cLoja        := ""
	Local _cCondPg      := ""
	Local _cVend        := ""
	Local _cIdAp        := ""
	Local _aPAPC        := {}
	Local _aEmiss       := {}
	Local _aCabec       := {}
	Local _aLinha       := {}
	Local _aItens       := {}
	Local _aBkpSE3      := {}
	Local _aStruSE3     := SE3->(dbStruct())
	Local _l1Mes        := .T.
	Private _cCondPg    := Padr(SuperGetMv("MV_CNDPPAD",,"COM"),Len(SA2->A2_COND))
	Private lMsErroAuto := .F.

	dbSelectArea(_cTabTmp1)
	IndRegua(_cTabTmp1,_cInd1,"TM_IDAP + TM_VEND + TM_CODCLI + TM_LOJACLI",,,"Criando ํndice temporแrio...")
	//Varro a tabela temporแria com as comiss๕es a serem processadas
	dbSelectArea(_cTabTmp2)
	(_cTabTmp2)->(dbGoTop())
	While !(_cTabTmp2)->(EOF())
		If Empty((_cTabTmp2)->TM_OK)
			_nDesmark++
			dbSelectArea(_cTabTmp2)
			(_cTabTmp2)->(dbSkip())
			Loop
		EndIf
		If Empty((_cTabTmp2)->TM_FORNECE) .OR. (_cTabTmp2)->TM_COMIS == 0		//AllTrim((_cTabTmp2)->TM_OK) <> Alltrim(cMark)
			_nVendER++
			dbSelectArea(_cTabTmp2)
			(_cTabTmp2)->(dbSkip())
			Loop
		EndIf
		_nValor	:= (_cTabTmp2)->TM_COMIS+(_cTabTmp2)->TM_RESERVA
		If _nValor <= 0

			// Altera็ใo - Fernando Bombardi - ALLSS - 03/03/2022
			//MsgStop("Aten็ใo! Nใo serแ gerada comissใo para o vendedor " + (_cTabTmp2)->TM_VEND + ", pois com a reten็ใo, esta ficarแ menor ou igual a zero e isto nใo ้ permitido!",_cRotina+"_010")
			MsgStop("Aten็ใo! Nใo serแ gerada comissใo para o representante " + (_cTabTmp2)->TM_VEND + ", pois com a reten็ใo, esta ficarแ menor ou igual a zero e isto nใo ้ permitido!",_cRotina+"_010")
			// Fim - Fernando Bombardi - ALLSS - 03/03/2022

			_nVendER++
			dbSelectArea(_cTabTmp2)
			(_cTabTmp2)->(dbSkip())
			Loop
		EndIf
		_aCabec     := {}
		_aItens     := {}
		_aLinha     := {}
		/* FB - RELEASE 12.1.23
		_cCondPg    := Padr(SuperGetMv("MV_CNDPPAD",,"COM"),Len(SA2->A2_COND))
		*/
		_cVend      := (_cTabTmp2)->TM_VEND
		_cForne     := (_cTabTmp2)->TM_FORNECE
		_cLoja	    := (_cTabTmp2)->TM_LOJA
		_cProdu	    := (_cTabTmp2)->TM_PRODUTO
		_cObs		:= "COMISSAO GERADA POR " + __cUserId + " - " + cUserName	//"NF: " + AllTrim((_cTabTmp2)->TM_NUM) + IIF(!Empty(((_cTabTmp2)->TM_PREFIXO)), "-" + AllTrim(((_cTabTmp2)->TM_PREFIXO)), "") + IIF(!Empty(((_cTabTmp2)->TM_PARCELA)),"/" + AllTrim(((_cTabTmp2)->TM_PARCELA)),"")
		_cNumPed   	:= GetSXENum("SC7","C7_NUM")
		ConfirmSX8()
		dbSelectArea("SA2")
		SA2->(dbSetOrder(1)) //Filial + Fornecedor + Loja
		If SA2->(MsSeek(xFilial("SA2")+_cForne+_cLoja,.T.,.F.))
			If AllTrim(SA2->A2_MSBLQL) == '1'

				// Altera็ใo - Fernando Bombardi - ALLSS - 03/03/2022
				//MsgStop("Aten็ใo! O fornecedor " + (_cForne+_cLoja) + " vinculado ao vendedor " + _cVend + " encontra-se bloqueado. Portanto este serแ ignorado!",_cRotina+"_007")
				MsgStop("Aten็ใo! O fornecedor " + (_cForne+_cLoja) + " vinculado ao representate " + _cVend + " encontra-se bloqueado. Portanto este serแ ignorado!",_cRotina+"_007")
				// Fim - Fernando Bombardi - ALLSS - 03/03/2022

				_nVendER++
				(_cTabTmp2)->(dbSkip())
				Loop
			Else
				If !Empty(SA2->A2_COND)
					_cCondPg := SA2->A2_COND
				EndIf
			EndIf
		Else

			// Altera็ใo - Fernando Bombardi - ALLSS - 03/03/2022
			//MsgStop("Aten็ใo! O fornecedor " + (_cForne+_cLoja) + " vinculado ao vendedor " + _cVend + " nใo foi localizado. Portanto este serแ ignorado!",_cRotina+"_005")
			MsgStop("Aten็ใo! O fornecedor " + (_cForne+_cLoja) + " vinculado ao representante " + _cVend + " nใo foi localizado. Portanto este serแ ignorado!",_cRotina+"_005")
			// Altera็ใo - Fernando Bombardi - ALLSS - 03/03/2022
			
			_nVendER++
			(_cTabTmp2)->(dbSkip())
			Loop
		EndIf
		//CABEวALHO
		aAdd(_aCabec,{"C7_NUM"     ,_cNumPed                           })
		aAdd(_aCabec,{"C7_EMISSAO" ,dDataBase                          })
		aAdd(_aCabec,{"C7_FORNECE" ,_cForne                            })
		aAdd(_aCabec,{"C7_LOJA"    ,_cLoja                             })
		aAdd(_aCabec,{"C7_COND"    ,_cCondPg                           })
		aAdd(_aCabec,{"C7_CONTATO" ,"COMISSAO"                         })
		aAdd(_aCabec,{"C7_FILENT"  ,cFilAnt                            })
		aAdd(_aCabec,{"C7_MOEDA"   ,_cNMoeda                           })
		aAdd(_aCabec,{"C7_TXMOEDA" ,_cTxMoed                           })
		aAdd(_aCabec,{"C7_FRETE"   ,0                                  })
		aAdd(_aCabec,{"C7_DESPESA" ,0                                  })
		aAdd(_aCabec,{"C7_SEGURO"  ,0                                  })
		aAdd(_aCabec,{"C7_DESC1"   ,0                                  })
		aAdd(_aCabec,{"C7_DESC2"   ,0                                  })
		aAdd(_aCabec,{"C7_DESC3"   ,0                                  })
		aAdd(_aCabec,{"C7_MSG"     ,""                                 })
		If SC7->(FieldPos("C7_DEPART"))>0
			aAdd(_aLinha,{"C7_DEPART","F"                              })
		EndIf
		//ITENS
		aAdd(_aLinha,{"C7_PRODUTO" ,_cProdu                       , Nil})
		aAdd(_aLinha,{"C7_QUANT"   ,_nQuanti                      , Nil})
		aAdd(_aLinha,{"C7_PRECO"   ,_nValor	                      , Nil})
		aAdd(_aLinha,{"C7_OBS"     ,_cObs	                      , Nil})
		aAdd(_aLinha,{"C7_ATRASO"  ,(_cTabTmp2)->TM_ATRASO        , Nil})
		aAdd(_aLinha,{"C7_LIMITE"  ,(_cTabTmp2)->TM_LIMITE        , Nil})
		aAdd(_aLinha,{"C7_RESERVA" ,(_cTabTmp2)->TM_RESERVA       , Nil})
		aAdd(_aLinha,{"C7_TPOP"    ,"F"                           , Nil})
		aAdd(_aLinha,{"C7_FLUXO"   ,"S"                           , Nil})
		aAdd(_aLinha,{"C7_ESTOQUE" ,"N"                           , Nil})
		aAdd(_aLinha,{"C7_DTEMB"   ,STOD("")                      , Nil})
		If SC7->(FieldPos("C7_ABATIM"))>0 .AND. (_cTabTmp2)->TM_ABATIM > 0
			aAdd(_aLinha,{"C7_ABATIM",(_cTabTmp2)->TM_ABATIM      , Nil})
			If SC7->(FieldPos("C7_MOTABAT"))>0 .AND. !Empty((_cTabTmp2)->TM_MOTABAT)
				aAdd(_aLinha,{"C7_MOTABAT",(_cTabTmp2)->TM_MOTABAT, Nil})
			EndIf
		EndIf
		aAdd(_aItens,_aLinha)
		//GERAวรO DO PEDIDO DE COMRPAS
		Begin Transaction
			dbSelectArea("SC7")
			SC7->(dbSetOrder(1))
			lMsErroAuto := .F.
			_aPAPC      := {}
			_nPos       := aScan(_aVincPA,{|x| AllTrim(x[01]) == (_cTabTmp2)->TM_VEND})
			If _nPos > 0
				For _Ad := 1 To Len(_aVincPA[_nPos][02])
					_aVincPA[_nPos][02][_Ad][01] := _cNumPed
					dbSelectArea("SE2")
					SE2->(dbSetOrder(1))
					SE2->(dbGoTo(_aVincPA[_nPos][02][_Ad][02]))
					If !SE2->(EOF())
						cA120Num    := _cNumPed
						aRecnoSE2RA := aClone(_aVincPA[_nPos][02])
						//nOpcAdt
						AADD(_aPAPC, {	{"FIE_FILIAL", xFilial("FIE")  } ,;
										{"FIE_CART"  , "P"             } ,;
										{"FIE_PEDIDO", _cNumPed        } ,;		//Pedido
										{"FIE_PREFIX", SE2->E2_PREFIXO } ,;
										{"FIE_NUM"   , SE2->E2_NUM     } ,;
										{"FIE_PARCEL", SE2->E2_PARCELA } ,;
										{"FIE_TIPO"  , SE2->E2_TIPO    } ,;
										{"FIE_CLIENT", ""              } ,;		//Sem cliente
										{"FIE_FORNEC", SE2->E2_FORNECE } ,;
										{"FIE_LOJA"  , SE2->E2_LOJA    } ,;
										{"FIE_VALOR" , SE2->E2_VALOR   } ,;
										{"FIE_SALDO" , SE2->E2_SALDO   } })		//Saldo
					EndIf
				Next
				//_aPAPC := aClone(_aVincPA[_nPos][02])
			EndIf
			//MSExecAuto({|v,x,y,z,a,b,c| MATA120(v,x,y,z,a,b,c)}, 1     , _aCabec, _aItens  , _nOpc  ,        , NIL     , _aPAPC)
			//Mata120                                          (nFuncao,xAutoCab,xAutoItens,nOpcAuto,lWhenGet,xRatCTBPC,xAdtPC )
			//Mata120(nFuncao,xAutoCab,xAutoItens,nOpcAuto,lWhenGet,xRatCTBPC,xAdtPC)
			MSExecAuto({|v,x,y,z,a,b| MATA120(v,x,y,z,a,b)},1,_aCabec,_aItens,_nOpc,,NIL)
			If lMsErroAuto
				_nVendER++
				MostraErro() //Em caso de erro ้ apresentada mensagem informando a inconsist๊ncia
				DisarmTransaction()
				Break
	//			RollBack()
			Else
				dbSelectArea("SC7")
				SC7->(dbSetOrder(1))
				SC7->(dbSeek(xFilial("SC7") + _cNumPed))
				/*
				dbSelectArea("SC1")
				SC1->(dbSetOrder(1))
				_cNumSc := GetSXENum("SC1","C1_NUM")
				ConfirmSX8()
				while !RecLock("SC1",.T.) ; enddo
				SC1->C1_FILIAL  := xFilial("SC1")
				SC1->C1_FILENT  := xFilial("SC1")
				SC1->C1_NUM     := _cNumSc
				SC1->C1_ITEM    := StrZero(VAL(SC7->C7_ITEM), TamSx3("C1_ITEM")[01])
				SC1->C1_PRODUTO := SC7->C7_PRODUTO
				SC1->C1_DESCRI  := SC7->C7_DESCRI
				SC1->C1_UM      := SC7->C7_UM
				SC1->C1_QUANT   := SC7->C7_QUANT
				SC1->C1_QUJE    := SC7->C7_QUANT
				SC1->C1_QTDORIG := SC7->C7_QUANT
				SC1->C1_SEGUM   := SC7->C7_SEGUM
				SC1->C1_QTSEGUM := SC7->C7_QTSEGUM
				SC1->C1_QUJE2   := SC7->C7_QTSEGUM
				SC1->C1_VUNIT   := SC7->C7_PRECO
				SC1->C1_PRECO   := SC7->C7_PRECO
				SC1->C1_VTOTAL  := SC7->C7_TOTAL
				SC1->C1_TOTAL   := SC7->C7_TOTAL
				SC1->C1_DATPRF  := SC7->C7_DATPRF
				SC1->C1_LOCAL   := SC7->C7_LOCAL
				SC1->C1_OBS     := SC7->C7_OBS
				SC1->C1_CC      := SC7->C7_CC
				SC1->C1_CONTA   := SC7->C7_CONTA
				SC1->C1_ITEMCTA := SC7->C7_ITEMCTA
				SC1->C1_EMISSAO := SC7->C7_EMISSAO
				SC1->C1_COTACAO := Replicate("X",Len(SC1->C1_COTACAO))
				SC1->C1_FORNECE := SC7->C7_FORNECE
				SC1->C1_LOJA    := SC7->C7_LOJA
				SC1->C1_CONDPAG := SC7->C7_COND
				SC1->C1_PEDIDO  := SC7->C7_NUM
				SC1->C1_ITEMPED := SC7->C7_ITEM
				SC1->C1_USER    := __cUserId
				SC1->C1_SOLICIT := cUserName
				SC1->C1_IMPORT  := "N"
				SC1->C1_CLASS   := "1"
				SC1->C1_TIPO    := 1
				SC1->(MSUNLOCK())
				*/
				dbSelectArea("SC7")
				while !RecLock("SC7",.F.) ; enddo
				//	SC7->C7_NUMSC  := SC1->C1_NUM
				//	SC7->C7_ITEMSC := SC1->C1_ITEM
				//	SC7->C7_QTDSOL := SC1->C1_QUANT
					SC7->C7_DEPART := "F"
					SC7->C7_FLUXO  := "S"
				SC7->(MSUNLOCK())
				cNumPedido := SC7->C7_NUM
				If Len(aRecnoSE2RA) > 0
					// Grava quando ้ proveniente da Nota.
					FPedAdtGrv("P", 1, cNumPedido, aRecnoSE2RA)
				Else
					// Limpa qualquer relacionamento de adiantamento caso a tela volte sem selecao
					DbSelectArea( "FIE" )
					FIE->( DbSetOrder( 1 ) )
					FIE->( DbSeek( xFilial( "FIE" ) + "P" + cNumPedido ) )
					While !FIE->(EOF()) .AND. FIE->(FIE_FILIAL+FIE_CART+FIE_PEDIDO)==xFilial( "FIE" )+"P"+cNumPedido
						while !RecLock("FIE",.F.) ; enddo
							FIE->(dbDelete())
						FIE->(MsUnLock())
						FIE->(dbSkip())
					EndDo
				EndIf
				_nVendOK++
				//DEFINO O NฺMERO DO DEMONSTRATIVO
				BeginSql Alias "SE3TMPD"
					SELECT MAX(E3_DEMONST) NUMDEM
					FROM %table:SE3% SE3 (NOLOCK)
					WHERE SE3.E3_FILIAL              = %xFilial:SE3%
					  AND SE3.E3_VEND                = %Exp:(_cTabTmp2)->TM_VEND%
					  AND SUBSTRING(SE3.E3_DATA,1,4) = %Exp:SubStr(DTOS(dDataBase),1,4)%
					  AND SE3.E3_DEMONST            <> %Exp:""%
					  AND SE3.%NotDel%
				EndSql
				dbSelectArea("SE3TMPD")
				_cDemonstr := Soma1(AllTrim(SE3TMPD->NUMDEM))
				If Empty(_cDemonstr)
					_cDemonstr := StrZero(1,TamSx3("E3_DEMONST")[01])
				EndIf
				SE3TMPD->(dbCloseArea())
				//LOCALIZO CADA REGISTRO DO MARK-BROWSE 1 PARA, COM BASE NESTE, VERIFICAR O QUE FOI REALMENTE PROCESSADO, PARA TRATARMOS AS AMARRAวีES NA SE3
				dbSelectArea(_cTabTmp2)
				_aSavTmp2 := (_cTabTmp2)->(GetArea())
				_cIdAp    := (_cTabTmp2)->TM_IDAP
				dbSelectArea(_cTabTmp1)
				(_cTabTmp1)->(dbGoTop())
				(_cTabTmp1)->(dbSeek(_cIdAp))
				While !(_cTabTmp1)->(EOF()) .AND. _cIdAp == (_cTabTmp1)->TM_IDAP
					If (_cTabTmp1)->TM_RECSE3 > 0
						dbSelectArea("SE3")
						SE3->(dbSetOrder(1))
						SE3->(dbGoTo((_cTabTmp1)->TM_RECSE3))
						If Empty(SE3->E3_DATA)
							//ATUALIZO A SE3 CORRESPONDENTE
							while !RecLock("SE3",.F.) ; enddo
							SE3->E3_DATA    := dDataBase
							SE3->E3_PEDCOM  := _cNumPed
							SE3->E3_DEMONST := _cDemonstr
							SE3->E3_PERDE   := _MV_PAR03
							SE3->E3_PERATE  := _MV_PAR04
							SE3->(MSUNLOCK())
							If (_cTabTmp1)->TM_RESERVA <> 0
								//PRESERVO TODOS OS CAMPOS DA SE3 PARA GERAR A NOVA SE3 PARA OS CASOS DE RETENวรO/RESERVA
								_aBkpSE3 := {}
								For _x := 1 To Len(_aStruSE3)
									If AllTrim(_aStruSE3[_x][01]) == "E3_PCORIG"
										AADD(_aBkpSE3,{_aStruSE3[_x][01], _cNumPed                    })
									ElseIf AllTrim(_aStruSE3[_x][01]) == "E3_COMIS"
										AADD(_aBkpSE3,{_aStruSE3[_x][01], IIF((_cTabTmp1)->TM_RESERVA   <0,(_cTabTmp1)->TM_RESERVA   ,(_cTabTmp1)->TM_RESERVA   *(-1)) })
									ElseIf AllTrim(_aStruSE3[_x][01]) == "E3_BASE"
										AADD(_aBkpSE3,{_aStruSE3[_x][01], IIF((_cTabTmp1)->TM_ATRASO<0,(_cTabTmp1)->TM_ATRASO,(_cTabTmp1)->TM_ATRASO*(-1)) })
									ElseIf AllTrim(_aStruSE3[_x][01]) == "E3_ORIGEM"
										AADD(_aBkpSE3,{_aStruSE3[_x][01], ""                          })	//Limpo a Origem para que o registro nใo entre no recแlculo
									ElseIf AllTrim(_aStruSE3[_x][01]) == "E3_CODCLI"
										AADD(_aBkpSE3,{_aStruSE3[_x][01], (_cTabTmp1)->TM_CODCLI      })
									ElseIf AllTrim(_aStruSE3[_x][01]) == "E3_LOJA"
										AADD(_aBkpSE3,{_aStruSE3[_x][01], (_cTabTmp1)->TM_LOJACLI     })
									ElseIf AllTrim(_aStruSE3[_x][01]) == "E3_PREFIXO" .OR. AllTrim(_aStruSE3[_x][01]) == "E3_SERIE"
										AADD(_aBkpSE3,{_aStruSE3[_x][01], (_cTabTmp1)->TM_PREFIXO     })
									ElseIf AllTrim(_aStruSE3[_x][01]) == "E3_NUM"
										AADD(_aBkpSE3,{_aStruSE3[_x][01], (_cTabTmp1)->TM_NUM         })
									ElseIf AllTrim(_aStruSE3[_x][01]) == "E3_PARCELA"
										AADD(_aBkpSE3,{_aStruSE3[_x][01], (_cTabTmp1)->TM_PARCELA     })
									ElseIf AllTrim(_aStruSE3[_x][01]) == "E3_TIPO"
										AADD(_aBkpSE3,{_aStruSE3[_x][01], (_cTabTmp1)->TM_TIPO        })
									ElseIf AllTrim(_aStruSE3[_x][01]) == "E3_VENCTO"
										AADD(_aBkpSE3,{_aStruSE3[_x][01], (_cTabTmp1)->TM_VENCTO      })
									ElseIf AllTrim(_aStruSE3[_x][01]) == "E3_PEDIDO"
										AADD(_aBkpSE3,{_aStruSE3[_x][01], (_cTabTmp1)->TM_PEDIDO      })
	//								ElseIf AllTrim(_aStruSE3[_x][01]) == "E3_SEQ"
	//									AADD(_aBkpSE3,{_aStruSE3[_x][01], Soma1((_cTabTmp1)->TM_SEQ)  })
									ElseIf AllTrim(_aStruSE3[_x][01]) == "E3_MSIDENT"
										AADD(_aBkpSE3,{_aStruSE3[_x][01], ""                          })
									Else
										AADD(_aBkpSE3,{_aStruSE3[_x][01], &("SE3->"+_aStruSE3[_x][01])})
									EndIf
								Next
								_aBkpSE3[aScan(_aBkpSE3, {|x| AllTrim(x[01]) == "E3_PORC"})][02] := ROUND(_aBkpSE3[aScan(_aBkpSE3, {|x| AllTrim(x[01]) == "E3_COMIS"})][02] / _aBkpSE3[aScan(_aBkpSE3, {|x| AllTrim(x[01]) == "E3_BASE"})][02], TamSx3("E3_PORC")[02])
								//GERAวรO DA SE3 NEGATIVA COM NO VALOR DA RETENวรO/RESERVA, Jม BAIXADA PARA A MESMA DATA DA SE3 ORIGINAL
								dbSelectArea("SE3")
								while !RecLock("SE3",.T.) ; enddo
								For _x := 1 To Len(_aBkpSE3)
									&("SE3->"+_aBkpSE3[_x][01])         := _aBkpSE3[_x][02]
								Next
								SE3->(MSUNLOCK())
								//GERAวรO DA SE3 POSITIVA COM NO VALOR DA RETENวรO/RESERVA, MAS AINDA EM ABERTO E PARA O PRำXIMO PERอODO, BASEADO NAS INFORMAวีES DA SE3 NEGATIVA RELATADA ACIMA
								dbSelectArea("SE3")
								while !RecLock("SE3",.T.) ; enddo
								For _x := 1 To Len(_aBkpSE3)
									If AllTrim(_aBkpSE3[_x][01]) == "E3_BASE" .OR. AllTrim(_aBkpSE3[_x][01]) == "E3_COMIS"
										&("SE3->"+_aBkpSE3[_x][01])     := IIF(_aBkpSE3[_x][02]<0,_aBkpSE3[_x][02]*(-1),_aBkpSE3[_x][02])
									ElseIf AllTrim(_aBkpSE3[_x][01]) == "E3_DATA"
										&("SE3->"+_aBkpSE3[_x][01])     := STOD("")
									ElseIf AllTrim(_aBkpSE3[_x][01]) == "E3_DEMONST"
										&("SE3->"+_aBkpSE3[_x][01])     := ""
									ElseIf AllTrim(_aBkpSE3[_x][01]) == "E3_EMISSAO"
										If _l1Mes
											_aEmiss := {SubStr(DTOS(_aBkpSE3[_x][02]),1,4), SubStr(DTOS(_aBkpSE3[_x][02]),5,2), SubStr(DTOS(_aBkpSE3[_x][02]),7,2)}
											If VAL(_aEmiss[02]) == 12
												_aEmiss[01] := StrZero(VAL(_aEmiss[01])+1, 4)
												_aEmiss[02] := "01"
											Else
												_aEmiss[02] := StrZero(VAL(_aEmiss[02]+1), 2)
											EndIf
											&("SE3->"+_aBkpSE3[_x][01]) := STOD(_aEmiss[01]+_aEmiss[02]+_aEmiss[03])
										Else
											&("SE3->"+_aBkpSE3[_x][01]) := _MV_PAR04+1		//_aBkpSE3[_x][01]+_nDProxPer
										EndIf
									Else
										&("SE3->"+_aBkpSE3[_x][01])     := _aBkpSE3[_x][02]
									EndIf
								Next
								SE3->(MSUNLOCK())
							EndIf
						EndIf
					Else
						If (_cTabTmp1)->TM_RESERVA <> 0
							//GRAVAวรO DE 02 REGISTROS DE COMISSีES, SENDO:
							//	1= A PRIMEIRA NEGATIVA, COM O VALOR RETIDO, NA DATA DE EMISSAO CORRENTE (DATA DE VENCIMENTODO TITULO A RECEBER EM ATRASO/ABERTO). ESTA COMISSรO ESTARม BAIXADA
							//	2= A SEGUNDA POSITIVA (NO MESMO VALOR E VINCULADO AO MESMO TITULO), SO QUE PARA O MES SEGUINTE. ESTA COMISSรO FICARม EM ABERTO PARA O PRำXIMO MสS.
							//AMBOS ESTARรO VINCULADOS AO PEDIDO DE COMPRAS CORRENTE PELO CAMPO "E3_PCORIG".
							for _x := 1 to 2
								dbSelectArea("SE3")
								while !RecLock("SE3",.T.) ; enddo
									If _x == 1
										SE3->E3_DATA        := dDataBase
										SE3->E3_PEDCOM      := _cNumPed
										SE3->E3_BASE        := IIF((_cTabTmp1)->TM_ATRASO <0,(_cTabTmp1)->TM_ATRASO ,(_cTabTmp1)->TM_ATRASO *(-1))
										SE3->E3_COMIS       := IIF((_cTabTmp1)->TM_RESERVA<0,(_cTabTmp1)->TM_RESERVA,(_cTabTmp1)->TM_RESERVA*(-1))
										SE3->E3_PORC        := round((SE3->E3_COMIS/SE3->E3_BASE) * 100,0)
										SE3->E3_EMISSAO     := (_cTabTmp1)->TM_EMISSAO
										SE3->E3_DEMONST     := _cDemonstr
									Else
										SE3->E3_DATA        := STOD("")
										SE3->E3_PEDCOM      := ""
										SE3->E3_BASE        := ABS((_cTabTmp1)->TM_ATRASO )
										SE3->E3_COMIS       := ABS((_cTabTmp1)->TM_RESERVA)
										If _l1Mes
											_aEmiss         := {SubStr(DTOS((_cTabTmp1)->TM_EMISSAO),1,4), SubStr(DTOS((_cTabTmp1)->TM_EMISSAO),5,2), SubStr(DTOS((_cTabTmp1)->TM_EMISSAO),7,2)}
											If VAL(_aEmiss[02]) == 12
												_aEmiss[01] := StrZero(VAL(_aEmiss[01])+1, 4)
												_aEmiss[02] := "01"
											Else
												_aEmiss[02] := StrZero(VAL(_aEmiss[02])+1, 2)
											EndIf
											SE3->E3_EMISSAO := STOD(_aEmiss[01]+_aEmiss[02]+_aEmiss[03])
										Else
											SE3->E3_EMISSAO := _MV_PAR04+1		//(_cTabTmp1)->TM_EMISSAO+_nDProxPer
										EndIf
									EndIf
									SE3->E3_FILIAL  := xFilial("SE3")
									SE3->E3_VEND    := (_cTabTmp1)->TM_VEND
									SE3->E3_PCORIG  := _cNumPed
									SE3->E3_PERDE   := _MV_PAR03
									SE3->E3_PERATE  := _MV_PAR04
									SE3->E3_ORIGEM  := ""
									SE3->E3_MSIDENT := ""
									SE3->E3_MSFIL   := ""
									SE3->E3_SEQ     := StrZero(_x, TamSx3("E3_SEQ")[01])
									SE3->E3_PORC    := round((SE3->E3_COMIS/SE3->E3_BASE) * 100,0)
									SE3->E3_BAIEMI  := "E"
									SE3->E3_SERIE   := (_cTabTmp1)->TM_PREFIXO
									SE3->E3_PREFIXO := (_cTabTmp1)->TM_PREFIXO
									SE3->E3_NUM     := (_cTabTmp1)->TM_NUM
									SE3->E3_PARCELA := (_cTabTmp1)->TM_PARCELA
									SE3->E3_TIPO    := (_cTabTmp1)->TM_TIPO
									SE3->E3_CODCLI  := (_cTabTmp1)->TM_CODCLI
									SE3->E3_LOJA    := (_cTabTmp1)->TM_LOJACLI
									SE3->E3_PEDIDO  := (_cTabTmp1)->TM_PEDIDO
									SE3->E3_VENCTO  := (_cTabTmp1)->TM_VENCTO
									SE3->E3_MOEDA   := StrZero(_cNMoeda, TamSx3("E3_MOEDA")[01])
								SE3->(MSUNLOCK())
							next
						EndIf
					EndIf
					dbSelectArea(_cTabTmp1)
					(_cTabTmp1)->(dbSkip())
				EndDo
				RestArea(_aSavTmp2)
			EndIf
		End Transaction
		dbSelectArea(_cTabTmp2)
		(_cTabTmp2)->(dbSkip())
	EndDo
	If _nVendOK > 0 .OR. _nVendER > 0 .OR. _nDesmark > 0
		MsgInfo("Processamento finalizado ("+cValToChar(_nVendOK+_nVendER+_nDesmark)+" registros ao todo): " + ENT + cValToChar(_nVendOK) + " registros processados com ๊xito." + ENT + cValToChar(_nVendER) + " registros nใo processados por problemas." + ENT + cValToChar(_nDesmark) + " registros foram desmarcados e, portanto, nใo processados.",_cRotina+"_011")
	Else
		MsgStop("Nenhum registro processado!",_cRotina+"_012")
	EndIf
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณRetencao  บAutor  ณAnderson C. P. Coelho บ Data ณ  25/10/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Tela para altera็ใo do valor de reten็ใo.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function Retencao(_nValRet)
	Local oGroup18
	Local oSay18
	Local oGet18
	Local oSButton18
	Local oFont18 := TFont():New("MS Sans Serif",,018,,.T.,,,,,.F.,.F.)
	Static oDlg2
	DEFINE MSDIALOG oDlg2 TITLE "["+_cRotina+"]"+cCadastro    FROM 000, 000                        TO 140, 350                       COLORS 0, 16777215        PIXEL STYLE DS_MODALFRAME
		oDlg2:lEscClose := .F.
			@ 005, 007 GROUP oGroup18 TO 060, 167 PROMPT " Reten็ใo de Comissใo "                              OF oDlg2              COLOR  0       , 16777215 PIXEL
			@ 017, 012   SAY oSay18               PROMPT "Informe o Valor a ser Retido:"         SIZE 150, 007 OF oDlg2 FONT oFont18 COLORS 16711680, 16777215 PIXEL
			@ 030, 012 MSGET oGet18                  VAR _nValRet  Picture "@E 999,999,999.99"   SIZE 150, 010 OF oDlg2              COLORS 0       , 16777215 PIXEL
		DEFINE   SBUTTON oSButton18            FROM 044, 136   TYPE 01   ACTION Close(oDlg2)               OF oDlg2                                       ENABLE
	ACTIVATE MSDIALOG oDlg2 CENTERED
	_nValRet := ABS(_nValRet) * (-1)
return(_nValRet)
user function RFINE33A()
	Local oGroupAB
	Local oSayAB
	Local oGetAB
	Local oSButtonAB
	Local oFont12 := TFont():New("MS Sans Serif",,010,,.F.,,,,,.F.,.F.)
	Local _nAbat  := (_cTabTmp2)->TM_ABATIM
	Local _cMotAb := (_cTabTmp2)->TM_MOTABAT
	Static oDlgAB
	DEFINE MSDIALOG oDlgAB TITLE "["+_cRotina+"]"+cCadastro    FROM 000, 000                                                                   TO 150, 800                        COLORS 0       , 16777215 PIXEL STYLE DS_MODALFRAME
		oDlgAB:lEscClose := .F.
			@ 003, 002 GROUP oGroupAB TO 075, 400 PROMPT " Abatimento da Comissใo "                                                                        OF oDlgAB              COLOR  128     , 16777215 PIXEL
			@ 025, 010   SAY oSayAB               PROMPT "Valor do Abatimento:"                                                              SIZE 057, 007 OF oDlgAB FONT oFont12 COLORS 16711680, 16777215 PIXEL
			@ 023, 070 MSGET oGetAB                  VAR _nAbat    Picture "@E 999,999,999.99"   Valid Positivo(@_nAbat)                     SIZE 077, 010 OF oDlgAB              COLORS 0       , 16777215 PIXEL
			@ 043, 010   SAY oSayAB               PROMPT "Motivo do Abatimento:"                                                             SIZE 057, 007 OF oDlgAB FONT oFont12 COLORS 16711680, 16777215 PIXEL
			@ 040, 070 MSGET oGetAB                  VAR _cMotAb   Picture "@!"                  Valid _nAbat == 0 .OR. NaoVazio(@_cMotAb)   SIZE 320, 010 OF oDlgAB              COLORS 0       , 16777215 PIXEL
		DEFINE   SBUTTON oSButtonAB                 TYPE 13                                      ACTION Close(oDlgAB)                        FROM 018, 362 OF oDlgAB                                       ENABLE
	ACTIVATE MSDIALOG oDlgAB CENTERED
	while !RecLock(_cTabTmp2,.F.) ; enddo
		(_cTabTmp2)->TM_ABATIM  := _nAbat
		(_cTabTmp2)->TM_MOTABAT := _cMotAb
	(_cTabTmp2)->(MSUNLOCK())
return
user function RFINE33V()
	//aAdd(aButtons,{"FINIMG32",{|| A120Adiant(cA120Num, cCondicao,  @aRecnoSE2RA, , cA120Forn, cA120loj,aRatCTBPC,aAdtPC,@cCondPAdt)},"Pagamento antecipado","Adiantamento"})
	//A120Adiant(cA120Num, cCondicao,  @aRecnoSE2RA, , cA120Forn, cA120loj,aRatCTBPC,aAdtPC,@cCondPAdt)
	//Function A120Adiant(cNumPedido, cCondPagto,aRecnoSE2RA, lCarregaTotal, cCodForn, cCodLoja,aRatCTBPC,aAdtPC,cCondPAdt)
	Local aArea	          := GetArea()
	Local aAreaSE4	      := SE4->(GetArea())
	Local aRotinaBKP      := aClone(aRotina)
	Local aHeaderBKP      := IIF(Type("aHeader")=="A",aClone(aHeader),{})
	Local aColsBKP        := IIF(Type("aCols"  )=="A",aClone(aCols  ),{})
	Local aVenc		      := {}
	Local _nPos           := 0 
	Local nTotped         := (_cTabTmp2)->TM_COMIS
	Local cCondPagto      := (_cTabTmp2)->TM_COND
	Local cNumPedido      := "PENDENTE"
//	Local lRet            := .F.
	Local aRecnoSE2RA     := {}
	Local cCondPAdt       := "0"

	If !Empty(cCondPagto)
		_nPos := aScan(_aVincPA,{|x| AllTrim(x[01]) == (_cTabTmp2)->TM_VEND})
		aVenc := Condicao(nTotped,cCondPagto,0.00,dDataBase,0.00,{},,0)
		If Len(aVenc) > 0
			nTotped := aVenc[1,2] 
		EndIf
		If FindFunction("FPedAdtGrv") .AND. AliasInDic("FIE")
			dbSelectArea("SE4")
			SE4->(dbSetOrder(1))
			If SE4->(FieldPos("E4_CTRADT")) > 0 .AND. SE4->(MsSeek(xFilial("SE4")+cCondPagto,.T.,.F.)) .AND. SE4->E4_CTRADT == "1"
				cCondPAdt := "1"
			EndIf
		EndIf    
		RestArea(aAreaSE4)
		If cCondPAdt == "1" .AND. A120UsaAdi( cCondPagto,@cCondPAdt )
		 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณChamada da tela de Recebimento do Financeiro.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			aRecnoSE2RA := FPEDADT("P", cNumPedido, (_cTabTmp2)->TM_COMIS, aRecnoSE2RA, (_cTabTmp2)->TM_FORNECE, (_cTabTmp2)->TM_LOJA)
			If Len(aRecnoSE2RA) > 0
				If _nPos > 0
					_aVincPA[_nPos][02] := aClone(aRecnoSE2RA)
				Else
					AADD(_aVincPA,{(_cTabTmp2)->TM_VEND, aClone(aRecnoSE2RA)})
				EndIf
			EndIf
		Else
			//MsgAlert("A condi็ใo de pagamento '"+(_cTabTmp2)->TM_COND+"' vinculada ao fornecedor '"+(_cTabTmp2)->TM_FORNECE+(_cTabTmp2)->TM_LOJA+"', nใo aceita vํnculo a adiantamento(s)!",_cRotina+"_016")
		EndIf
	Else
		//MsgAlert("Condi็ใo de pagamento nใo vinculada ao fornecedor '"+(_cTabTmp2)->TM_FORNECE+(_cTabTmp2)->TM_LOJA+"'. Opera็ใo nใo permitida!",_cRotina+"_017")
	EndIf
	aRotina := aClone(aRotinaBKP)
	aHeader := aClone(aHeaderBKP)
	aCols   := aClone(aColsBKP  )
	RestArea(aAreaSE4)
	RestArea(aArea)
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณVALIDPERG บAutor  ณAnderson C. P. Coelho บ Data ณ  25/10/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se as perguntas estใo criadas no arquivo SX1 e caso บฑฑ
ฑฑบ          ณ nใo as encontre ele as cria.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function ValidPerg()
	Local _sAlias := GetArea()
	Local aRegs   := {}
	Local _aTam   := {}
	cPerg         := PADR(cPerg,10)
	_aTam := TamSx3("A3_COD"    )

	// Altera็ใo - Fernando Bombardi - ALLSS - 03/03/2022
	//AADD(aRegs,{cPerg,"01","De Vendedor?"	  	,"","","mv_ch1",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par01",""        ,"","","","",""       ,"","","","","","","","","","","","","","","","","","","SA3",""})
	//AADD(aRegs,{cPerg,"02","At้ Vendedor?"	  	,"","","mv_ch2",_aTam[3],_aTam[1],_aTam[2],0,"G","NAOVAZIO()","mv_par02",""        ,"","","","",""       ,"","","","","","","","","","","","","","","","","","","SA3",""})
	AADD(aRegs,{cPerg,"01","De Representante?"	  	,"","","mv_ch1",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par01",""        ,"","","","",""       ,"","","","","","","","","","","","","","","","","","","SA3",""})
	AADD(aRegs,{cPerg,"02","At้ Representante?"	  	,"","","mv_ch2",_aTam[3],_aTam[1],_aTam[2],0,"G","NAOVAZIO()","mv_par02",""        ,"","","","",""       ,"","","","","","","","","","","","","","","","","","","SA3",""})
	// Fim - Fernando Bombardi - ALLSS - 03/03/2022

	_aTam := TamSx3("E3_EMISSAO")
	AADD(aRegs,{cPerg,"03","De Data?"		  	,"","","mv_ch3",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par03",""        ,"","","","",""       ,"","","","","","","","","","","","","","","","","","",""   ,""})
	AADD(aRegs,{cPerg,"04","At้ Data?"		  	,"","","mv_ch4",_aTam[3],_aTam[1],_aTam[2],0,"G","NAOVAZIO()","mv_par04",""        ,"","","","",""       ,"","","","","","","","","","","","","","","","","","",""   ,""})
	_aTam[3] := "N"; _aTam[1] := 01; _aTam[2] := 0
	AADD(aRegs,{cPerg,"05","Apresenta atrasos ?","","","mv_ch5",_aTam[3],_aTam[1],_aTam[2],0,"C","NAOVAZIO()","mv_par05","Nao"     ,"","","","","Sim"    ,"","","","","","","","","","","","","","","","","","",""   ,""})
	_aTam[3] := "N"; _aTam[1] := 03; _aTam[2] := 0
	AADD(aRegs,{cPerg,"06","Toler.Atraso p/Ret?","","","mv_ch6",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par06",""        ,"","","","",""       ,"","","","","","","","","","","","","","","","","","",""   ,""})
	_aTam[3] := "N"; _aTam[1] := 01; _aTam[2] := 0
	AADD(aRegs,{cPerg,"07","Retem atrasos     ?","","","mv_ch7",_aTam[3],_aTam[1],_aTam[2],0,"C","NAOVAZIO()","mv_par07","Nao"     ,"","","","","Sim"    ,"","","","","","","","","","","","","","","","","","",""   ,""})
	_aTam[3] := "N"; _aTam[1] := 01; _aTam[2] := 0
	AADD(aRegs,{cPerg,"08","Valores Recebidos ?","","","mv_ch8",_aTam[3],_aTam[1],_aTam[2],0,"C","NAOVAZIO()","mv_par08","Integral","","","","","Parcial","","","","","","","","","","","","","","","","","","",""   ,""})
	for i := 1 to len(aRegs)
		dbSelectArea("SX1")
		SX1->(dbSetOrder(1))
		If !SX1->(dbSeek(cPerg+aRegs[i,2]))
			while !RecLock("SX1",.T.) ; enddo
			for j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Else
					exit
				EndIf
			next
			MsUnlock()
		EndIf
	next
	RestArea(_sAlias)
return
