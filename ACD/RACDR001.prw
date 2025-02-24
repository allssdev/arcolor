#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'APVT100.CH'
#Include 'TOTVS.ch'
#Include 'topconn.ch'

#DEFINE CENT CHR(13) + CHR(10)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ_cRotinaÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RACDR001³ Autor ³ Arthur Silva			 ³ Data ³07/04/17 ³±±
±±aÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄ ÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ±±
±±³Descricao ³ Etiqueta Volume para processo ACD. Impressora Datamax(LPT1)³±±
±±aÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±aÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso ACDV166  ³ Protheus 11    -   Específico Arcolor                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function RACDR001()
	Local _cPerg        := "RACDR001"
	Private _cRotina    := _cPerg
	Private _cCliente	:= ""	//SF2->F2_CLIENTE
	Private _cLoja		:= ""	//SF2->F2_LOJA
	Private _cNomeCli	:= ""	//Posicione("SA1",1,xFilial("SA1")+_cCliente+_cLoja,"A1_NOME")
	Private _cTipo      := ""
	Private _aMV		:= {}
	Private _nVolumes   := 0

	AjustSX1(_cPerg)
	If AllTrim(FunName()) <> "RACDR001" .AND. AllTrim(FunName()) <> "U_RACDR001" 
		Pergunte(_cPerg,.F.)
		MV_PAR01  := SF2->F2_DOC
		MV_PAR02  := SF2->F2_SERIE
		MV_PAR03  := 1
		MV_PAR04  := SF2->F2_VOLUME1
		_cCliente := SF2->F2_CLIENTE
		_cLoja	  := SF2->F2_LOJA
		_cTipo	  := SF2->F2_TIPO
		_nVolumes := SF2->F2_VOLUME1
		If AllTrim(_cTipo) $ "D/B"
			dbSelectArea("SA2")
			SA2->(dbSetOrder(1))
			If SA2->(MsSeek(xFilial("SA2") + _cCliente + _cLoja,.T.,.F.))
				_cNomeCli := Padr(SA2->A2_NOME,TamSx3("A2_NOME")[01])
			EndIf
		Else
			dbSelectarea("SA1")
			SA1->(dbSetOrder(1))
			If SA1->(MsSeek(xFilial("SA1") + _cCliente + _cLoja,.T.,.F.))
				_cNomeCli := Padr(SA1->A1_NOME,TamSx3("A1_NOME")[01])
			EndIf
		EndIf
	Else
		If IsTelNet()
			if !VtPergunte(_cPerg,.T.)
				return
			endif
		Else
			if !Pergunte(_cPerg,.T.)
				return
			endif
		EndIf
	EndIf
		aadd(_aMV, Padr(AllTrim(mv_par01),TamSx3("F2_DOC"  )[01]))
		aadd(_aMV, Padr(AllTrim(mv_par02),TamSx3("F2_SERIE")[01]))
		aadd(_aMV, mv_par03)
		aadd(_aMV, mv_par04)
		Imprime()
return nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Imprime  ³ Autor ³ Arthur Silva			 ³ Data ³07/04/17 ³±±
±±aÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄ ÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ±±
±±³Descricao ³ Localização: Está localizado na função FimProcesso         ³±±
±±³           com o Objetivo de finalizar o processo de separação         ³±±
±±³           (para itens separa).Finalidade: Este Ponto de Entrada permite±±
±±³           executar rotinas complementares no momento de finalizar o   ³±±
±±³             processo de separação, se os itens forem separados.		  ³±±
±±aÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±aÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso ACDV168  ³ Protheus 11    -   Específico Arcolor                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function Imprime()
	Local _aArea	:= GetArea()
	Local _nQtde 	:= _aMv[4]
	Local _x        := 0
	Local _lTelNet  := .T. //IsTelNet()
	Local _cNota	:= Padr(_aMv[1],TamSx3("F2_DOC"  )[01])
	Local _cSerie	:= Padr(_aMv[2],TamSx3("F2_SERIE")[01])
	Local _cRazao	:= ""
	Local _cRazao1	:= ""
	Local _cRazao2	:= ""
	Local _cImpress := ""
	Local _cCodUser := __cUserId
	Private _cEti   := ""

	dbSelectArea("CB1")
	//CB1->(dbSetOrder(2))
	CB1->(dbOrderNickName("CB1_CODUSR"))
	If CB1->(MsSeek(xFilial("CB1") + _cCodUser,.T.,.F.))
		_cImpress	:= CB1->CB1_IMPRES
	EndIf
	If Empty(_cNomeCli)
		BeginSql Alias "SF2TMP"
			SELECT F2_CLIENTE, F2_LOJA, F2_VOLUME1, F2_TIPO
			FROM %table:SF2% SF2 (NOLOCK)
			WHERE SF2.F2_FILIAL  = %xFilial:SF2%
			  AND SF2.F2_DOC     = %Exp:MV_PAR01%
			  AND SF2.F2_SERIE   = %Exp:MV_PAR02%
			  AND SF2.%NotDel%
			ORDER BY F2_SERIE, F2_DOC, F2_TIPO
		EndSql
		dbSelectArea("SF2TMP")
			_cCliente := SF2TMP->F2_CLIENTE
			_cLoja	  := SF2TMP->F2_LOJA
			_nVolumes := SF2TMP->F2_VOLUME1
			If AllTrim(SF2TMP->F2_TIPO) $ "D/B"
				dbSelectArea("SA2")
				SA2->(dbSetOrder(1))
				If SA2->(MsSeek(xFilial("SA2") + SF2TMP->F2_CLIENTE + SF2TMP->F2_LOJA,.T.,.F.))
					_cNomeCli := Padr(SA2->A2_NOME,TamSx3("A2_NOME")[01])
					_cNomeCli := iif(_cNomeCli$"@",STRTRAN(_cNomeCli, "@","^FD@"),_cNomeCli)	//tratamento para impressao de etiqueta com caracter especial		
				EndIf
			Else
				dbSelectarea("SA1")
				SA1->(dbSetOrder(1))
				If SA1->(MsSeek(xFilial("SA1") + SF2TMP->F2_CLIENTE + SF2TMP->F2_LOJA,.T.,.F.))
					_cNomeCli := Padr(SA1->A1_NOME,TamSx3("A1_NOME")[01])
					_cNomeCli := iif("@"$_cNomeCli,STRTRAN(_cNomeCli, "@","^FD@"),_cNomeCli) //tratamento para impressao de etiqueta com caracter especial	
									
				EndIf
			EndIf
			If _aMv[3] <= SF2TMP->F2_VOLUME1
				If _aMv[4] >= SF2TMP->F2_VOLUME1
					_nQtde := SF2TMP->F2_VOLUME1
				Else
					_nQtde := _aMv[4]
				EndIf
			Else
				_nQtde     := 0
			EndIf
		SF2TMP->(dbCloseArea())
	EndIf
	If _nQtde > 0
		_cRazao  := SubStr(AllTrim(_cNomeCli),01,26)
		_cRazao1 := SubStr(AllTrim(_cNomeCli),27,26)
		_cRazao2 := SubStr(AllTrim(_cNomeCli),53,26)
		If _lTelNet
			CB5SetImp(_cImpress,_lTelNet)
		Else
			CB5SetImp(GetMV("MV_ACDIMP"),_lTelNet) 
		EndIf
			for _x := _aMv[3] to _nQtde // Qtde de Etiquetas //Funcionando
				MSCBBEGIN(1,6,95.62) // MSCBBEGIN(1,6,95.70) 
					MSCBSAY(05.5,0020, "Nota/Serie: " + _cNota +"/"+ _cSerie                                        ,"B","0","050",.T.,.F.,.F.,.T.,.F.)
			 		MSCBSAY(12.0,0033, "VOLUME(S): "  + Alltrim(cValToChar(_x)+"/"+ Alltrim(cValToChar(_nVolumes))) ,"B","0","050",.T.,.F.,.F.,.T.,.F.)
					MSCBSAY(19.0,0015, _cRazao                                                                      ,"B","0","040",.T.,.F.,.F.,.T.,.F.)
					If !Empty(_cRazao1)
						MSCBSAY(25,0015, _cRazao1                                                                   ,"B","0","040",.T.,.F.,.F.,.T.,.F.)
					EndIf
					If !Empty(_cRazao2)
						MSCBSAY(30,0015, _cRazao2                                                                   ,"B","0","040",.T.,.F.,.F.,.T.,.F.)
					EndIf
					
					_cEti+= "Nota/Serie: " + _cNota +"/"+ _cSerie + CENT 
					_cEti+=  "VOLUME(S): "  + Alltrim(cValToChar(_x)+"/"+ Alltrim(cValToChar(_nVolumes))) + CENT		
					_cEti+=  _cRazao + CENT
					_cEti+=  _cRazao1 + CENT
					_cEti+=  _cRazao2 + CENT
					
					MSCBEND() //testar a impressao em lote
			next _x
			//tipo de impressao C=Coletor A=Avulsa
			MemoWrite("\2.MemoWrite\ACD\"+_cRotina+"_ETIQUETA_"+_cNota+"_"+StrTran(Time(),":","")+".TXT",_cEti)
     		MSCBCLOSEPRINTER()
	EndIf
	RestArea(_aArea)
return nil
static function AjustSX1(_cPerg)
	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := "SF2"
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := ""
	U_RGENA001(_cPerg, "01" ,"Nota?" , "MV_PAR01", "MV_CH1", "C", tamSX3('F2_DOC'  )[1], tamSX3('F2_DOC'  )[2], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := ""
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := ""
	U_RGENA001(_cPerg, "02" ,"Serie?", "MV_PAR02", "MV_CH2", "C", tamSX3('F2_SERIE'  )[1], tamSX3('F2_SERIE'  )[2], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := ""
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := ""
	U_RGENA001(_cPerg, "03" ,"De Volume?" , "MV_PAR03", "MV_CH3", "C", 04, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := ""
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := ""
	U_RGENA001(_cPerg, "04" ,"Até Volume?" , "MV_PAR04", "MV_CH4", "C", 04, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	
return(_cPerg)
