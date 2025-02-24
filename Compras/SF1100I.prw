#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SF1100I   ºAutor ³ Anderson C. P. Coelho º Data ³ 29/01/2014º±±
±±ºPrograma  ³          ºAutor ³ Júlio Soares          º Data ³ 25/07/2014º±±
±±ºPrograma  ³          ºAutor ³ Júlio Soares          º Data ³ 08/06/2016º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada para gravar informações após a gravação doº±±
±±º          ³ Documento de Entrada.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Inserido trecho para envio de workflow para usuários       º±±
±±º          ³ específicos ao realizar-se a entrada de um documento de    º±±
±±º          ³ devolução.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±  
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SF1100I()

Local 	_cAliasSX3 := "SX3_"+GetNextAlias()

Private _aSavArea := GetArea()
Private _aSavCD5  := CD5->(GetArea())
Private _aSavSF1  := SF1->(GetArea())
Private _aSavSD1  := SD1->(GetArea())
Private _aSavSA1  := SA1->(GetArea())
Private _aSavSA2  := SA2->(GetArea())
Private _aSavSE1  := SE1->(GetArea())
Private _aSavSE2  := SE2->(GetArea())
Private _cRotina  := "SF1100I"

// - Chama rotina de envio de workflow por e-mail e messenger
Processa( { |lEnd| Envwfw(@lEnd) },"[WF TOTVS]","Aguarde, enviando e-mail.",.T.)
// - Fim

//If AllTrim(SF1->F1_FORMUL) == "S" .AND. AllTrim(SF1->F1_EST) == "EX"
// - Trecho alterado para que a tela de complemento somente seja apresentado caso a nota seja do tipo normal.
If AllTrim(SF1->F1_FORMUL) == "S" .AND. AllTrim(SF1->F1_EST) == "EX" .AND. Alltrim(SF1->F1_TIPO) == "N"
	dbSelectArea("CD5")
	_cTPFrete 	:= Space(01)
	aComboBx1	:= {"CIF","FOB","Por conta terceiros","Sem frete"}		//C=CIF;F=FOB;T=Por conta terceiros;S=Sem frete
	OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
	dbSelectArea(_cAliasSX3)
	(_cAliasSX3)->(dbSetOrder(2))
	If (_cAliasSX3)->(MsSeek("CD5_VTRANS")) .AND. !Empty((_cAliasSX3)->X3_CBOX)
		//_aTpTrans	:= Separa(SX3->X3_CBOX,";")
		_aTpTrans	:= {"Marítima","Fluvial","Lacustre","Aérea","Postal","Ferroviária","Rodoviária","Conduto","Meios Próprios","Entrada/Saída ficta"}
	Else
		_aTpTrans	:= {"Marítima","Fluvial","Lacustre","Aérea","Postal","Ferroviária","Rodoviária","Conduto","Meios Próprios","Entrada/Saída ficta"}
	EndIf
	If (_cAliasSX3)->(MsSeek("CD5_INTERM")) .AND. !Empty((_cAliasSX3)->X3_CBOX)
		_aFormInt	:= Separa((_cAliasSX3)->X3_CBOX,";")
	Else
		_aFormInt	:= {"Conta própria","Conta e ordem","Encomenda"}
	EndIf

	cComboBx1	:= Space(19)
	cComboBx2	:= Space(19)
	cComboBx3	:= Space(19)
	_cDi        := Space(Len(CD5->CD5_NDI))
	_cDtDi      := STOD("")
	_cLoc       := Space(Len(CD5->CD5_LOCDES))
	_cDtDes     := STOD("")
	_cUf        := Space(Len(CD5->CD5_UFDES))


	@ 030,140 To 430,420  Dialog oDlg Title OemToAnsi("["+_cRotina+"] Informações para Complemento do Documento de Entrada:")

	@ 006,005 To 010,120
	@ 008,030 Say OemToAnsi("Dados Adicionais da Nota")	 SIZE 80,10

	@ 030,005 Say OemToAnsi("Tipo de Frete:")			 SIZE 050,030
	@ 030,070 ComboBox cComboBx1 Items aComboBx1	 	 SIZE 050,030

	@ 050,005 SAY "Numero da DI: "                  	 SIZE 050,030
	@ 050,070 GET _cDi     PICTURE "@R 9999999999"		 SIZE 050,030 
	
	@ 065,005 SAY "Data DI: "	                         SIZE 050,030
	@ 065,070 GET _cDtDi   PICTURE "@!"	          	     SIZE 050,030

	@ 080,005 SAY "Local Desemb.:"      	             SIZE 050,030
	@ 080,070 GET _cLoc    PICTURE "@!"     	         SIZE 050,030

	@ 095,005 SAY "UF Desemb.:"                 	     SIZE 050,030
	@ 095,070 GET _cUf     PICTURE "@!"  Valid ExistCpo("SX5","12"+_cUf)    F3 "12"    SIZE 030,030

	@ 110,005 SAY "Data Desemb.: "                  	 SIZE 050,030
	@ 110,070 GET _cDtDes  PICTURE "@!"               	 SIZE 050,030

	@ 125,005 Say OemToAnsi("Via Transporte:")			 SIZE 050,030
	@ 125,070 ComboBox cComboBx2 Items _aTpTrans	 	 SIZE 050,030

	@ 140,005 Say OemToAnsi("Forma Import.:")			 SIZE 070,030
	@ 140,070 ComboBox cComboBx3 Items _aFormInt	 	 SIZE 070,030

	@ 160,065 BMPBUTTON TYPE 01 Action FGRAVAD()
	@ 160,095 BMPBUTTON TYPE 02 Action IIF(MSGBOX("Tem certeza que deseja cancelar o preenchimento dos complementos? O documento ficará sem as informações necessárias",_cRotina+"_001","YESNO"),Close(oDlg),Nil)

	Activate Dialog oDlg Center
Else
	If SF1->F1_TIPO $ "/D/B/" .AND. !Empty(SF1->F1_DUPL)
		dbSelectArea("SE1")
		SE1->(dbSetOrder(1))
		If SE1->(MsSeek(xFilial("SE1") + SF1->(F1_PREFIXO+F1_DUPL) + Space(Len(SE1->E1_PARCELA)) + "NCC",.T.,.F.))
			While !SE1->(EOF()) .AND. (SE1->E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) == (xFilial("SE1") + SF1->(F1_PREFIXO+F1_DUPL) + Space(Len(SE1->E1_PARCELA)) + "NCC")
				dbSelectArea("SA1")
				SA1->(dbSetOrder(1))
				If SA1->(MsSeek(xFilial("SA1") + SE1->(E1_CLIENTE+E1_LOJA),.T.,.F.))
					dbSelectArea("SE1")
					RecLock("SE1",.F.)
					SE1->E1_NOMCLI  := SA1->A1_NREDUZ
					SE1->E1_NOMERAZ := SA1->A1_NOME
					SE1->(MSUNLOCK())
				EndIf
				dbSelectArea("SE1")
				SE1->(dbSetOrder(1))
				SE1->(dbSkip())
			EndDo
		EndIf
	EndIf
EndIf

RestArea(_aSavSA1)
RestArea(_aSavSA2)
RestArea(_aSavSE1)
RestArea(_aSavSE2)
RestArea(_aSavCD5)
RestArea(_aSavSF1)
RestArea(_aSavSD1)
RestArea(_aSavArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Envwfw  ºAutor  ³ Júlio Soares        º Data ³  20/01/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina criada para passar parâmetros para a rotina de envioº±±
±±º          ³ de workflow por e-mail e messenger.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico empresa Arcolor                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Envwfw()

Private _cTit		:= "Devolução de mercadoria"
Private _cMsg		:= ""
Private _cDestMail	:= ""
Private _cAnexo		:= ""
Private _cFromOri	:= ""
Private _cCco		:= SuperGetMV("MV_MAILMNT",,"")
Private _cAssunt	:= "[WF Totvs] Mensagem Automatica"
Private _cDestMsg 	:= ''   
Private _cPrior 	:= '0'

If SF1->F1_TIPO == 'D'
	_aSendMail      := Separa(SuperGetMV('MV_MAILC00',,{}),"|" )
	//StrTran( _aSendMail, "|000046|", "|" )
	
	For _x := 1 To Len (_aSendMail)
		//_aSendMail[_x]
//		If !(Alltrim(_aSendMail[_x])) $ "SA1|SA3|SU7"
		PswOrder(1)
		If PswSeek(Alltrim(_aSendMail[_x]),.T.)
			_cDestMsg  += IIF(!Empty(_cDestMsg ) ,";" , "") + Alltrim(PswRet()[01][02])
			_cDestMail += IIF(!Empty(_cDestMail) ,";" , "") + Alltrim(PswRet()[01][14])
		EndIf
//		EndIf
	Next
	_cNomcli := POSICIONE("SA1",1,xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA,"A1_NOME")
	_cMsg := 'Realizada a entrada do documento de devolução ' + Alltrim(SF1->F1_DOC) + ' - ' + Alltrim(SF1->F1_SERIE) +;
			 ', do cliente ' + Alltrim(_cNomcli) + '.' + CHR(13) + CHR(10) + CHR(13) + CHR(10) +;
			 'Este e-mail foi enviado automaticamente pelo sistema Protheus. (Não responder)'
	//Chama a rotina de envio de e-mails
	If !Empty(_cDestMail) .AND. ExistBlock("RCFGM001") .And. !lEnd
		U_RCFGM001(_cTit,_cMsg,_cDestMail,_cAnexo,_cFromOri,_cCco,_cAssunt) //Chamada da rotina responsável pelo envio de e-mails
	EndIf
	//Chama a rotina de envio do messenger - 08/10/2019 - Anderson C. P. Coelho (ALL System Solutions) - Desativado conforme solicitação do Sr. Luis Apparicio, uma vez que não utilizam mais o Messenger do Protheus.
	//If ExistBlock("RCFGM002") .And. !lEnd
	//	U_RCFGM002(_cFromOri,_cDestMsg,_cTit,_cMsg,_cPrior)
	//EndIf
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FGRAVAD   ºAutor  ³Anderson C. P. Coelho º Data ³  29/01/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funçao responsavel pela gravação dos dados				  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FGRAVAD()

If Empty(_cDi) .OR. Empty(AllTrim(DTOS(_cDtDi)))
   MsgStop("Informe o número e data da DI!",_cRotina+"_001")
   Return(.T.)
EndIf
If Empty(_cLoc) .OR. Empty(AllTrim(DTOS(_cDtDes))) .OR. !ExistCpo("SX5","12"+_cUf)
   MsgStop("Informe o local, data e a Unidade Federativa do desembarque!",_cRotina+"_002")
   Return(.T.)
EndIf
//If Empty(_cExp)
//   MsgStop("Informe o Exportador!",_cRotina+"_003")
//   Return(.T.)
//EndIf
RestArea(_aSavSF1)
RecLock("SF1",.F.)
Do Case
	Case AllTrim(cComboBx1) == "CIF"
		SF1->F1_TPFRETE := "C"
	Case AllTrim(cComboBx1) == "FOB"
		SF1->F1_TPFRETE := "F"
	Case AllTrim(cComboBx1) == "Por conta terceiros"
		SF1->F1_TPFRETE := "T"
	Case AllTrim(cComboBx1) == "Sem frete" .OR. Empty(cComboBx1)
		SF1->F1_TPFRETE := "S"
EndCase
SF1->(MsUnLock())
dbSelectArea("SD1")
SD1->(dbSetOrder(1))
SD1->(dbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
While !SD1->(EOF()) .AND. SD1->D1_FILIAL == xFilial("SD1") .AND. SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
	dbSelectArea("CD5")
	CD5->(dbSetOrder(4))	//documento/série/fornecedor/loja/item
	If !CD5->(dbSeek(xFilial("CD5")+SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM)))
		dbSelectArea("CD5")
		RecLock("CD5",.T.)
	Else
		dbSelectArea("CD5")
		RecLock("CD5",.F.)
	EndIf	
	CD5->CD5_FILIAL  := xFilial("CD5")
	CD5->CD5_DOC     := SD1->D1_DOC
	CD5->CD5_SERIE   := SD1->D1_SERIE
	CD5->CD5_FORNEC  := SD1->D1_FORNECE
	CD5->CD5_LOJA    := SD1->D1_LOJA
	CD5->CD5_ESPEC   := SF1->F1_ESPECIE
	CD5->CD5_TPIMP   := "0"
	CD5->CD5_DOCIMP  := SD1->D1_DOC
	//CD5->CD5_BSPIS := SD1->D1_BASIMP5
	//CD5->CD5_ALPIS := SD1->D1_ALQIMP5
	//CD5->CD5_VLPIS := SD1->D1_VALIMP5
	//CD5->CD5_BSCOF := SD1->D1_BASIMP6
	//CD5->CD5_ALCOF := SD1->D1_ALQIMP6
	//CD5->CD5_VLCOF := SD1->D1_VALIMP6
	CD5->CD5_LOCAL   := "0"				//LOCAL DE EXECUÇÃO DO SERVIÇO (0 - NO PAIS  / 1 - NO EXPTERIOR, CUJO RESULTADO SE VERIFIQUE NO PAIS)
	CD5->CD5_NDI     := _cDi
	CD5->CD5_DTDI    := _cDtDi
	CD5->CD5_LOCDES  := _cLoc
	CD5->CD5_UFDES   := _cUf
	CD5->CD5_DTDES   := _cDtDes
	CD5->CD5_CODEXP  := SD1->D1_FORNECE 
	CD5->CD5_NADIC   := "001"	//SD1->D1_ADICAO
	CD5->CD5_SQADIC  := "001"	//SD1->D1_SEQADIC
	CD5->CD5_CODFAB  := SD1->D1_FORNECE
	CD5->CD5_VLRII   := SD1->D1_II
	CD5->CD5_ITEM    := SD1->D1_ITEM
	CD5->CD5_LOJEXP  := SD1->D1_LOJA
	CD5->CD5_LOJFAB  := SD1->D1_LOJA
	// Alterado forma de tratamento do conteúdo do complemento de transporte, a tag <tpViaTransp> do XML não aceita 0X.
	//CD5->CD5_VTRANS  := IIF(aScan(_aTpTrans,cComboBx2)==0,"",StrZero(aScan(_aTpTrans,cComboBx2), Len(CD5->CD5_VTRANS)))
	CD5->CD5_VTRANS  := IIF(aScan(_aTpTrans,cComboBx2)==0,"",cValToChar(aScan(_aTpTrans,cComboBx2)))
	CD5->CD5_INTERM  := IIF(aScan(_aFormInt,cComboBx3)==0,"",StrZero(aScan(_aFormInt,cComboBx3), Len(CD5->CD5_INTERM)))
	CD5->(MsUnlock())
	dbSelectArea("SD1")
	SD1->(dbSetOrder(1))
	SD1->(dbSkip())
EndDo

Close(oDlg)

Return(.T.)
