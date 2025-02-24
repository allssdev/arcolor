#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'TOPCONN.CH'

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥RFINR007  ∫ Autor ≥Anderson C. P. Coelho ∫ Data ≥  16/02/16 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥RelatÛrio de conferÍncia de comissıes por baixa (auditoria).∫±±
±±∫          ≥                                                            ∫±±
±±∫          ≥OBS.: Na conferÍncia, o relatÛrio n„o apresenta as comissıes∫±±
±±∫          ≥negativas.                                                  ∫±±
±±∫          ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Protheus 11 - EspecÌfico para a empresa Arcolor.           ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

User Function RFINR007()

Local   oReport
Local   cFile     := "SIGAADV.MOT"
Local   _cAlias   := "cArqTmp"
Local   cArqTmp   := ""
Local   aCampos   :={	{"SIGLA"    , 	"C" , 03,0},;
						{"DESCR"    , 	"C" , 10,0},;
						{"CARTEIRA" , 	"C" , 01,0},;
						{"MOVBANC"	,	"C"	, 01,0},;
						{"COMIS"	,	"C"	, 01,0},;
						{"CHEQUE"	,	"C"	, 01,0} }

Private oSection, oSection1, oSection2, oSection3
Private _cRotina  := "RFINR007"
Private cPerg     := _cRotina
Private cTitulo   := "RelatÛrio de conferÍncia de comissıes por baixa (auditoria)"
Private _aTpOper  := {}
Private _cVend    := ""
Private _cMotBx   := ""

If FindFunction("TRepInUse") .AND. TRepInUse()
	ValidPerg()
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
	If ExistBlock("FILEMOT")
		cFile := ExecBlock("FILEMOT",.F.,.F.,{cFile})
	EndIf
	/*
	If !FILE(cFile)
		nHdlMot := MSFCreate(cFile,0)
		IF nHdlMot == -1
			HELP(" ",1,"MOT_ERROR")
			Final("Erro F_"+str(ferror(),2)+" em SIGAADV.MOT")
		EndIf
		If __Language == "ENGLISH"
			fWrite(nHdlMot,"NORNORMAL    ASSS"+chr(13)+chr(10))
			fWrite(nHdlMot,"DACEXCHANGE  ANNN"+chr(13)+chr(10))
			fWrite(nHdlMot,"DEVDEVOLUTIONANNN"+chr(13)+chr(10))
			fWrite(nHdlMot,"DEBDEBIT CC  PSNN"+chr(13)+chr(10))
			fWrite(nHdlMot,"VENVENDOR    PNNN"+chr(13)+chr(10))
		ElseIf __Language == "SPANISH"
			fWrite(nHdlMot,"NORNORMAL    ASSS"+chr(13)+chr(10))
			fWrite(nHdlMot,"DACPERMUTA   ANNN"+chr(13)+chr(10))
			fWrite(nHdlMot,"DEVDEVOLUCIONANNN"+chr(13)+chr(10))
			fWrite(nHdlMot,"DEBDEBITO CC PSNN"+chr(13)+chr(10))
			fWrite(nHdlMot,"VENTIT.BANCO PNNN"+chr(13)+chr(10))
		Else
		    fWrite(nHdlMot,"NORNORMAL    ASSS"+chr(13)+chr(10))
		    fWrite(nHdlMot,"DACDACAO     ANNN"+chr(13)+chr(10))
		    fWrite(nHdlMot,"DEVDEVOLUCAO ANNN"+chr(13)+chr(10))
		    fWrite(nHdlMot,"DEBDEBITO CC PSNN"+chr(13)+chr(10))
		    fWrite(nHdlMot,"VENVENDOR    PNNN"+chr(13)+chr(10))
		EndIf
		fClose(nHdlMot)
	EndIf
	*/
	/* FB - RELEASE 12.1.23
	cArqTmp := CriaTrab( aCampos , .T.)
	dbUseArea( .T.,, cArqTmp, _cAlias, if(.F. .OR. .F., !.F., NIL), .F. )
	*/
	//-------------------
	//Criacao do objeto
	//-------------------
	_cAlias := GetNextAlias()
	oTmpTab01 := FWTemporaryTable():New( _cAlias )
	
	oTmpTab01:SetFields( aCampos )
	//------------------
	//Criacao da tabela
	//------------------
	oTmpTab01:Create()
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ "Importa" o arquivo TXT com a tabela dos Motivos de Baixa ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	dbSelectArea( _cAlias )
	APPEND FROM &cFile SDF
	(_cAlias)->(dbGoTop())
	While !(_cAlias)->(EOF())
		/*
		Field->Sigla    := cSigla
		Field->Descr    := cDescrMot
		Field->Carteira := cCarteira
		Field->MovBanC  := cMovBan
		*/
		If AllTrim(Field->Comis) <> "S"
			If !Empty(_cMotBx)
				_cMotBx += "/"
			EndIf
			_cMotBx += AllTrim(Field->Sigla)
		EndIf
		dbSelectArea( _cAlias )
		(_cAlias)->(dbSkip())
	EndDo
	dbSelectArea( _cAlias )
	(_cAlias)->(dbCloseArea())
	_cMotBx := "%"+FormatIn(_cMotBx,"/")+"%"
	oReport := ReportDef()
	oReport:PrintDialog()
	/* FB - RELEASE 12.1.23
	While MSGBOX("Deseja emitir o relatÛrio novamente?",_cRotina+"_001","YESNO")
		If !Pergunte(cPerg,.T.)
			Return
		EndIf
		oReport := ReportDef()
		oReport:PrintDialog()
	EndDo
	*/
EndIf

Return

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥ReportDef ≥ Autor ≥Anderson C. P. Coelho  ≥ Data ≥ 16/02/16 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥A funcao estatica ReportDef devera ser criada para todos os ≥±±
±±≥          ≥relatorios que poderao ser agendados pelo usuario.          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ExpO1: Objeto do relatÛrio                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥Nenhum                                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥   DATA   ≥ Programador   ≥Manutencao efetuada                         ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

Static Function ReportDef()

Local oReport
//Local oSection
Local oBreak

// AlteraÁ„o - Fernando Bombardi - ALLSS - 03/03/2022
//Local _aOrd       := {"Por Vendedor + Cliente"}		//{"Grupo + Produto", "Grupo + DescriÁ„o de Produto"}
Local _aOrd       := {"Por Representante + Cliente"}		//{"Grupo + Produto", "Grupo + DescriÁ„o de Produto"}
// Fim - Fernando Bombardi - ALLSS - 03/03/2022

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Criacao do componente de impressao                                      ≥
//≥TReport():New                                                           ≥
//≥ExpC1 : Nome do relatorio                                               ≥
//≥ExpC2 : Titulo                                                          ≥
//≥ExpC3 : Pergunte                                                        ≥
//≥ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ≥
//≥ExpC5 : Descricao                                                       ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
oReport := TReport():New(_cRotina,cTitulo,cPerg,{|oReport| PrintReport(oReport)},"Emissao do relatÛrio, de acordo com o intervalo informado na opÁ„o de Par‚metros.")
oReport:SetLandscape() 
oReport:SetTotalInLine(.F.)

Pergunte(oReport:uParam,.F.)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Criacao da secao utilizada pelo relatorio                               ≥
//≥TRSection():New                                                         ≥
//≥ExpO1 : Objeto TReport que a secao pertence                             ≥
//≥ExpC2 : Descricao da seÁao                                              ≥
//≥ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ≥
//≥        sera considerada como principal para a seÁ„o.                   ≥
//≥ExpA4 : Array com as Ordens do relatÛrio                                ≥
//≥ExpL5 : Carrega campos do SX3 como celulas                              ≥
//≥        Default : False                                                 ≥
//≥ExpL6 : Carrega ordens do Sindex                                        ≥
//≥        Default : False                                                 ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Criacao da celulas da secao do relatorio                                ≥
//≥                                                                        ≥
//≥TRCell():New                                                            ≥
//≥ExpO1 : Objeto TSection que a secao pertence                            ≥
//≥ExpC2 : Nome da celula do relatÛrio. O SX3 ser· consultado              ≥
//≥ExpC3 : Nome da tabela de referencia da celula                          ≥
//≥ExpC4 : Titulo da celula                                                ≥
//≥        Default : //X3TITULO()                                            ≥
//≥ExpC5 : Picture                                                         ≥
//≥        Default : X3_PICTURE                                            ≥
//≥ExpC6 : Tamanho                                                         ≥
//≥        Default : X3_TAMANHO                                            ≥
//≥ExpL7 : Informe se o tamanho esta em pixel                              ≥
//≥        Default : False                                                 ≥
//≥ExpB8 : Bloco de cÛdigo para impressao.                                 ≥
//≥        Default : ExpC2                                                 ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Secao da auditoria de comissıes - sintÈtico.                           ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
oSection := TRSection():New(oReport,"Comissıes - SintÈtico",{"SE5","SE1","SF1","SF2","SE3"},_aOrd/*{Array com as ordens do relatÛrio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSection:SetTitle("SeÁ„o 1 - DiferenÁas nas Comissıes")
oSection:SetTotalInLine(.F.)
oSection:SetPageBreak(.T.)

//DefiniÁ„o das colunas do relatÛrio
TRCell():New(oSection,"E1_VEND1"   ,"COMSIN",RetTitle("E1_VEND1"  ),PesqPict("SE1","E1_VEND1"  ),TamSx3("E1_VEND1"  )[1]+2,/*lPixel*/,{|| COMSIN->E1_VEND1      })
TRCell():New(oSection,"E1_VALOR"   ,"COMSIN",RetTitle("E1_VALOR"  ),PesqPict("SE1","E1_VALOR"  ),TamSx3("E1_VALOR"  )[1]+2,/*lPixel*/,{|| COMSIN->E1_VALOR      })
TRCell():New(oSection,"E1_BASCOM1" ,"COMSIN",RetTitle("E1_BASCOM1"),PesqPict("SE1","E1_BASCOM1"),TamSx3("E1_BASCOM1")[1]+2,/*lPixel*/,{|| COMSIN->E1_BASCOM1    })
TRCell():New(oSection,"E1_SALDO"   ,"COMSIN",RetTitle("E1_SALDO"  ),PesqPict("SE1","E1_SALDO"  ),TamSx3("E1_SALDO"  )[1]+2,/*lPixel*/,{|| COMSIN->E1_SALDO      })
TRCell():New(oSection,"E5_VALOR"   ,"COMSIN",RetTitle("E5_VALOR"  ),PesqPict("SE5","E5_VALOR"  ),TamSx3("E5_VALOR"  )[1]+2,/*lPixel*/,{|| COMSIN->E5_VALOR      })
TRCell():New(oSection,"E5_VLDESCO" ,"COMSIN",RetTitle("E5_VLDESCO"),PesqPict("SE5","E5_VLDESCO"),TamSx3("E5_VLDESCO")[1]+2,/*lPixel*/,{|| COMSIN->E5_VLDESCO    })
TRCell():New(oSection,"E5_VLDECRE" ,"COMSIN",RetTitle("E5_VLDECRE"),PesqPict("SE5","E5_VLDECRE"),TamSx3("E5_VLDECRE")[1]+2,/*lPixel*/,{|| COMSIN->E5_VLDECRE    })
TRCell():New(oSection,"E5_VLJUROS" ,"COMSIN",RetTitle("E5_VLJUROS"),PesqPict("SE5","E5_VLJUROS"),TamSx3("E5_VLJUROS")[1]+2,/*lPixel*/,{|| COMSIN->E5_VLJUROS    })
TRCell():New(oSection,"E5_VLCORRE" ,"COMSIN",RetTitle("E5_VLCORRE"),PesqPict("SE5","E5_VLCORRE"),TamSx3("E5_VLCORRE")[1]+2,/*lPixel*/,{|| COMSIN->E5_VLCORRE    })
TRCell():New(oSection,"E5_VLMULTA" ,"COMSIN",RetTitle("E5_VLMULTA"),PesqPict("SE5","E5_VLMULTA"),TamSx3("E5_VLMULTA")[1]+2,/*lPixel*/,{|| COMSIN->E5_VLMULTA    })
TRCell():New(oSection,"RECEBIDO"   ,"COMSIN","Recebido"            ,"@E 999,999,999.99"         ,18                       ,/*lPixel*/,{|| COMSIN->RECEBIDO      })
TRCell():New(oSection,"BASEATU"    ,"COMSIN","Base Proporcional"   ,"@E 999,999,999.99"         ,18                       ,/*lPixel*/,{|| COMSIN->BASEATU       })
TRCell():New(oSection,"E3_BASE"    ,"COMSIN",RetTitle("E3_BASE"   ),PesqPict("SE3","E3_BASE"   ),TamSx3("E3_BASE"   )[1]+2,/*lPixel*/,{|| COMSIN->E3_BASE       })
TRCell():New(oSection,"DIFERENCA"  ,"COMSIN","DIFERENCA"           ,"@E 999,999,999.99"         ,18                       ,/*lPixel*/,{|| COMSIN->DIFERENCA     })

oSection:Cell("E1_VEND1"   ):SetHeaderAlign("CENTER")
oSection:Cell("E1_VALOR"   ):SetHeaderAlign("RIGHT" )
oSection:Cell("E1_BASCOM1" ):SetHeaderAlign("RIGHT" )
oSection:Cell("E1_SALDO"   ):SetHeaderAlign("RIGHT" )
oSection:Cell("E5_VALOR"   ):SetHeaderAlign("RIGHT" )
oSection:Cell("E5_VLDESCO" ):SetHeaderAlign("RIGHT" )
oSection:Cell("E5_VLDECRE" ):SetHeaderAlign("RIGHT" )
oSection:Cell("E5_VLJUROS" ):SetHeaderAlign("RIGHT" )
oSection:Cell("E5_VLCORRE" ):SetHeaderAlign("RIGHT" )
oSection:Cell("E5_VLMULTA" ):SetHeaderAlign("RIGHT" )
oSection:Cell("RECEBIDO"   ):SetHeaderAlign("RIGHT" )
oSection:Cell("BASEATU"    ):SetHeaderAlign("RIGHT" )
oSection:Cell("E3_BASE"    ):SetHeaderAlign("RIGHT" )
oSection:Cell("DIFERENCA"  ):SetHeaderAlign("RIGHT" )

/*
TRFUNCTION():New(oCell,cName,cFunction,oBreak,cTitle,cPicture,uFormula,lEndSection,lEndReport,lEndPage,oParent,bCondition,lDisable,bCanPrint) 

Onde: 
lEndSection Imprime o totalizador na quebra de seÁ„o se .T. 
lEndReport   Imprime o totalizador no final do relatÛrio se .T. 
lEndPage     Imprime o totalizador no final de cada p·gina se .T. 
*/

TRFunction():New(oSection:Cell("E1_VALOR"   ),NIL,"SUM",,,,,,.F.,.F.)
TRFunction():New(oSection:Cell("E1_BASCOM1" ),NIL,"SUM",,,,,,.F.,.F.)
TRFunction():New(oSection:Cell("E1_SALDO"   ),NIL,"SUM",,,,,,.F.,.F.)
TRFunction():New(oSection:Cell("E5_VALOR"   ),NIL,"SUM",,,,,,.F.,.F.)
TRFunction():New(oSection:Cell("E5_VLDESCO" ),NIL,"SUM",,,,,,.F.,.F.)
TRFunction():New(oSection:Cell("E5_VLDECRE" ),NIL,"SUM",,,,,,.F.,.F.)
TRFunction():New(oSection:Cell("E5_VLJUROS" ),NIL,"SUM",,,,,,.F.,.F.)
TRFunction():New(oSection:Cell("E5_VLCORRE" ),NIL,"SUM",,,,,,.F.,.F.)
TRFunction():New(oSection:Cell("E5_VLMULTA" ),NIL,"SUM",,,,,,.F.,.F.)
TRFunction():New(oSection:Cell("RECEBIDO"   ),NIL,"SUM",,,,,,.F.,.F.)
TRFunction():New(oSection:Cell("BASEATU"    ),NIL,"SUM",,,,,,.F.,.F.)
TRFunction():New(oSection:Cell("E3_BASE"    ),NIL,"SUM",,,,,,.F.,.F.)
TRFunction():New(oSection:Cell("DIFERENCA"  ),NIL,"SUM",,,,,,.F.,.F.)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Secao da auditoria de comissıes - analÌtico.                           ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
oSection1 := TRSection():New(oReport,"Comissıes - AnalÌtico",{"SE5","SE1","SF1","SF2","SE3"},_aOrd/*{Array com as ordens do relatÛrio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSection1:SetTitle("SeÁ„o 1 - DiferenÁas nas Comissıes")
oSection1:SetTotalInLine(.F.)
oSection1:SetPageBreak(.T.)

//DefiniÁ„o das colunas do relatÛrio
TRCell():New(oSection1,"E1_VEND1"   ,"COMTMP",RetTitle("E1_VEND1"  ),PesqPict("SE1","E1_VEND1"  ),TamSx3("E1_VEND1"  )[1]+2,/*lPixel*/,{|| COMTMP->E1_VEND1      })
TRCell():New(oSection1,"E1_CLIENTE" ,"COMTMP",RetTitle("E1_CLIENTE"),PesqPict("SE1","E1_CLIENTE"),TamSx3("E1_CLIENTE")[1]+2,/*lPixel*/,{|| COMTMP->E1_CLIENTE    })
TRCell():New(oSection1,"E1_LOJA"    ,"COMTMP",RetTitle("E1_LOJA"   ),PesqPict("SE1","E1_LOJA"   ),TamSx3("E1_LOJA"   )[1]+2,/*lPixel*/,{|| COMTMP->E1_LOJA       })
TRCell():New(oSection1,"E1_PREFIXO" ,"COMTMP",RetTitle("E1_PREFIXO"),PesqPict("SE1","E1_PREFIXO"),TamSx3("E1_PREFIXO")[1]+3,/*lPixel*/,{|| COMTMP->E1_PREFIXO    })
TRCell():New(oSection1,"E1_NUM"     ,"COMTMP",RetTitle("E1_NUM"    ),PesqPict("SE1","E1_NUM"    ),TamSx3("E1_NUM"    )[1]+3,/*lPixel*/,{|| COMTMP->E1_NUM        })
TRCell():New(oSection1,"E1_PARCELA" ,"COMTMP",RetTitle("E1_PARCELA"),PesqPict("SE1","E1_PARCELA"),TamSx3("E1_PARCELA")[1]+2,/*lPixel*/,{|| COMTMP->E1_PARCELA    })
TRCell():New(oSection1,"E1_TIPO"    ,"COMTMP",RetTitle("E1_TIPO"   ),PesqPict("SE1","E1_TIPO"   ),TamSx3("E1_TIPO"   )[1]+2,/*lPixel*/,{|| COMTMP->E1_TIPO       })
TRCell():New(oSection1,"E1_VALOR"   ,"COMTMP",RetTitle("E1_VALOR"  ),PesqPict("SE1","E1_VALOR"  ),TamSx3("E1_VALOR"  )[1]+2,/*lPixel*/,{|| COMTMP->E1_VALOR      })
TRCell():New(oSection1,"E1_BASCOM1" ,"COMTMP",RetTitle("E1_BASCOM1"),PesqPict("SE1","E1_BASCOM1"),TamSx3("E1_BASCOM1")[1]+2,/*lPixel*/,{|| COMTMP->E1_BASCOM1    })
TRCell():New(oSection1,"E1_COMIS1"  ,"COMTMP",RetTitle("E1_COMIS1" ),PesqPict("SE1","E1_COMIS1" ),TamSx3("E1_COMIS1" )[1]+2,/*lPixel*/,{|| COMTMP->E1_COMIS1     })
TRCell():New(oSection1,"E1_SALDO"   ,"COMTMP",RetTitle("E1_SALDO"  ),PesqPict("SE1","E1_SALDO"  ),TamSx3("E1_SALDO"  )[1]+2,/*lPixel*/,{|| COMTMP->E1_SALDO      })
TRCell():New(oSection1,"E5_VALOR"   ,"COMTMP",RetTitle("E5_VALOR"  ),PesqPict("SE5","E5_VALOR"  ),TamSx3("E5_VALOR"  )[1]+2,/*lPixel*/,{|| COMTMP->E5_VALOR      })
TRCell():New(oSection1,"E5_VLDESCO" ,"COMTMP",RetTitle("E5_VLDESCO"),PesqPict("SE5","E5_VLDESCO"),TamSx3("E5_VLDESCO")[1]+2,/*lPixel*/,{|| COMTMP->E5_VLDESCO    })
TRCell():New(oSection1,"E5_VLDECRE" ,"COMTMP",RetTitle("E5_VLDECRE"),PesqPict("SE5","E5_VLDECRE"),TamSx3("E5_VLDECRE")[1]+2,/*lPixel*/,{|| COMTMP->E5_VLDECRE    })
TRCell():New(oSection1,"E5_VLJUROS" ,"COMTMP",RetTitle("E5_VLJUROS"),PesqPict("SE5","E5_VLJUROS"),TamSx3("E5_VLJUROS")[1]+2,/*lPixel*/,{|| COMTMP->E5_VLJUROS    })
TRCell():New(oSection1,"E5_VLCORRE" ,"COMTMP",RetTitle("E5_VLCORRE"),PesqPict("SE5","E5_VLCORRE"),TamSx3("E5_VLCORRE")[1]+2,/*lPixel*/,{|| COMTMP->E5_VLCORRE    })
TRCell():New(oSection1,"E5_VLMULTA" ,"COMTMP",RetTitle("E5_VLMULTA"),PesqPict("SE5","E5_VLMULTA"),TamSx3("E5_VLMULTA")[1]+2,/*lPixel*/,{|| COMTMP->E5_VLMULTA    })
TRCell():New(oSection1,"RECEBIDO"   ,"COMTMP","Recebido"            ,"@E 999,999,999.99"         ,18                       ,/*lPixel*/,{|| COMTMP->RECEBIDO      })
TRCell():New(oSection1,"BASEATU"    ,"COMTMP","Base Proporcional"   ,"@E 999,999,999.99"         ,18                       ,/*lPixel*/,{|| COMTMP->BASEATU       })
TRCell():New(oSection1,"E3_BASE"    ,"COMTMP",RetTitle("E3_BASE"   ),PesqPict("SE3","E3_BASE"   ),TamSx3("E3_BASE"   )[1]+2,/*lPixel*/,{|| COMTMP->E3_BASE       })
TRCell():New(oSection1,"DIFERENCA"  ,"COMTMP","DIFERENCA"           ,"@E 999,999,999.99"         ,18                       ,/*lPixel*/,{|| COMTMP->DIFERENCA     })

oSection1:Cell("E1_VEND1"   ):SetHeaderAlign("CENTER")
oSection1:Cell("E1_CLIENTE" ):SetHeaderAlign("CENTER")
oSection1:Cell("E1_LOJA"    ):SetHeaderAlign("CENTER")
oSection1:Cell("E1_PREFIXO" ):SetHeaderAlign("CENTER")
oSection1:Cell("E1_NUM"     ):SetHeaderAlign("CENTER")
oSection1:Cell("E1_PARCELA" ):SetHeaderAlign("CENTER")
oSection1:Cell("E1_TIPO"    ):SetHeaderAlign("CENTER")
oSection1:Cell("E1_VALOR"   ):SetHeaderAlign("RIGHT" )
oSection1:Cell("E1_BASCOM1" ):SetHeaderAlign("RIGHT" )
oSection1:Cell("E1_COMIS1"  ):SetHeaderAlign("RIGHT" )
oSection1:Cell("E1_SALDO"   ):SetHeaderAlign("RIGHT" )
oSection1:Cell("E5_VALOR"   ):SetHeaderAlign("RIGHT" )
oSection1:Cell("E5_VLDESCO" ):SetHeaderAlign("RIGHT" )
oSection1:Cell("E5_VLDECRE" ):SetHeaderAlign("RIGHT" )
oSection1:Cell("E5_VLJUROS" ):SetHeaderAlign("RIGHT" )
oSection1:Cell("E5_VLCORRE" ):SetHeaderAlign("RIGHT" )
oSection1:Cell("E5_VLMULTA" ):SetHeaderAlign("RIGHT" )
oSection1:Cell("RECEBIDO"   ):SetHeaderAlign("RIGHT" )
oSection1:Cell("BASEATU"    ):SetHeaderAlign("RIGHT" )
oSection1:Cell("E3_BASE"    ):SetHeaderAlign("RIGHT" )
oSection1:Cell("DIFERENCA"  ):SetHeaderAlign("RIGHT" )

//oBreak := TRBreak():New(oSection1, oSection1:Cell("E1_VEND1" ), {|| "Sub-Total Vendedor "})

oBreak := TRBreak():New(oSection1, oSection1:Cell("E1_VEND1" ), {|| "Sub-Total Representante "})

/*
TRFUNCTION():New(oCell,cName,cFunction,oBreak,cTitle,cPicture,uFormula,lEndSection,lEndReport,lEndPage,oParent,bCondition,lDisable,bCanPrint) 

Onde: 
lEndSection Imprime o totalizador na quebra de seÁ„o se .T. 
lEndReport   Imprime o totalizador no final do relatÛrio se .T. 
lEndPage     Imprime o totalizador no final de cada p·gina se .T. 
*/

TRFunction():New(oSection1:Cell("E1_VALOR"   ),NIL,"SUM",oBreak,,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("E1_BASCOM1" ),NIL,"SUM",oBreak,,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("E1_SALDO"   ),NIL,"SUM",oBreak,,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("E5_VALOR"   ),NIL,"SUM",oBreak,,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("E5_VLDESCO" ),NIL,"SUM",oBreak,,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("E5_VLDECRE" ),NIL,"SUM",oBreak,,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("E5_VLJUROS" ),NIL,"SUM",oBreak,,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("E5_VLCORRE" ),NIL,"SUM",oBreak,,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("E5_VLMULTA" ),NIL,"SUM",oBreak,,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("RECEBIDO"   ),NIL,"SUM",oBreak,,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("BASEATU"    ),NIL,"SUM",oBreak,,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("E3_BASE"    ),NIL,"SUM",oBreak,,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("DIFERENCA"  ),NIL,"SUM",oBreak,,,,,.F.,.F.)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Secao da auditoria das duplicidades nas comissıes.                     ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
oSection2 := TRSection():New(oReport,"Comissıes duplicadas",{"SE3"},_aOrd/*{Array com as ordens do relatÛrio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSection2:SetTitle("SeÁ„o 2 - Comissıes Duplicadas")
oSection2:SetTotalInLine(.F.)
oSection2:SetPageBreak(.T.)
//DefiniÁ„o das colunas do relatÛrio
TRCell():New(oSection2,"_FLAG"      ,""      ," "                   ,                            ,01                      ,/*lPixel*/,{|| ""                    })
TRCell():New(oSection2,"E3_VEND"    ,"DUPLCO",RetTitle("E3_VEND"   ),PesqPict("SE3","E3_VEND"   ),TamSx3("E3_VEND"   )[1]+2,/*lPixel*/,{|| DUPLCO->E3_VEND       })
TRCell():New(oSection2,"E3_CODCLI"  ,"DUPLCO",RetTitle("E3_CODCLI" ),PesqPict("SE3","E3_CODCLI" ),TamSx3("E3_CODCLI" )[1]+2,/*lPixel*/,{|| DUPLCO->E3_CODCLI     })
TRCell():New(oSection2,"E3_LOJA"    ,"DUPLCO",RetTitle("E3_LOJA"   ),PesqPict("SE3","E3_LOJA"   ),TamSx3("E3_LOJA"   )[1]+2,/*lPixel*/,{|| DUPLCO->E3_LOJA       })
TRCell():New(oSection2,"E3_PREFIXO" ,"DUPLCO",RetTitle("E3_PREFIXO"),PesqPict("SE3","E3_PREFIXO"),TamSx3("E3_PREFIXO")[1]+2,/*lPixel*/,{|| DUPLCO->E3_PREFIXO    })
TRCell():New(oSection2,"E3_NUM"     ,"DUPLCO",RetTitle("E3_NUM"    ),PesqPict("SE3","E3_NUM"    ),TamSx3("E3_NUM"    )[1]+2,/*lPixel*/,{|| DUPLCO->E3_NUM        })
TRCell():New(oSection2,"E3_PARCELA" ,"DUPLCO",RetTitle("E3_PARCELA"),PesqPict("SE3","E3_PARCELA"),TamSx3("E3_PARCELA")[1]+2,/*lPixel*/,{|| DUPLCO->E3_PARCELA    })
TRCell():New(oSection2,"E3_TIPO"    ,"DUPLCO",RetTitle("E3_TIPO"   ),PesqPict("SE3","E3_TIPO"   ),TamSx3("E3_TIPO"   )[1]+2,/*lPixel*/,{|| DUPLCO->E3_TIPO       })
TRCell():New(oSection2,"E3_BASE"    ,"DUPLCO",RetTitle("E3_BASE"   ),PesqPict("SE3","E3_BASE"   ),TamSx3("E3_BASE"   )[1]+2,/*lPixel*/,{|| DUPLCO->E3_BASE       })
TRCell():New(oSection2,"E3_COMIS"   ,"DUPLCO",RetTitle("E3_COMIS"  ),PesqPict("SE3","E3_COMIS"  ),TamSx3("E3_COMIS"  )[1]+2,/*lPixel*/,{|| DUPLCO->E3_COMIS      })
TRCell():New(oSection2,"E3_PORC"    ,"DUPLCO",RetTitle("E3_PORC"   ),PesqPict("SE3","E3_PORC"   ),TamSx3("E3_PORC"   )[1]+2,/*lPixel*/,{|| DUPLCO->E3_PORC       })
TRCell():New(oSection2,"REGISTROS"  ,"DUPLCO","REGISTROS DUPLICADOS",                            ,07                       ,/*lPixel*/,{|| DUPLCO->REGISTROS     })

oSection2:Cell("_FLAG"      ):SetHeaderAlign("CENTER")
oSection2:Cell("E3_VEND"    ):SetHeaderAlign("CENTER")
oSection2:Cell("E3_CODCLI"  ):SetHeaderAlign("CENTER")
oSection2:Cell("E3_LOJA"    ):SetHeaderAlign("CENTER")
oSection2:Cell("E3_PREFIXO" ):SetHeaderAlign("CENTER")
oSection2:Cell("E3_NUM"     ):SetHeaderAlign("CENTER")
oSection2:Cell("E3_PARCELA" ):SetHeaderAlign("CENTER")
oSection2:Cell("E3_TIPO"    ):SetHeaderAlign("CENTER")
oSection2:Cell("E3_BASE"    ):SetHeaderAlign("RIGHT" )
oSection2:Cell("E3_COMIS"   ):SetHeaderAlign("RIGHT" )
oSection2:Cell("E3_PORC"    ):SetHeaderAlign("RIGHT" )
oSection2:Cell("REGISTROS"  ):SetHeaderAlign("CENTER")

TRFunction():New(oSection2:Cell("_FLAG"    ),NIL,"COUNT",,,,,,.F.,.F.)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Secao da auditoria das comissıes geradas por motivos de baixa indevidos ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
oSection3 := TRSection():New(oReport,"Comissıes por Mot.Baixa Idevido",{"SE3","SE5"},_aOrd/*{Array com as ordens do relatÛrio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSection3:SetTitle("SeÁ„o 3 - Comissıes geradas com motivo de baixa indevido")
oSection3:SetTotalInLine(.F.)
oSection3:SetPageBreak(.T.)
//DefiniÁ„o das colunas do relatÛrio
TRCell():New(oSection3,"E3_EMISSAO" ,"MOTBCO",RetTitle("E3_EMISSAO"),PesqPict("SE3","E3_EMISSAO"),TamSx3("E3_EMISSAO")[1]+2,/*lPixel*/,{|| MOTBCO->E3_EMISSAO    })
TRCell():New(oSection3,"E3_VEND"    ,"MOTBCO",RetTitle("E3_VEND"   ),PesqPict("SE3","E3_VEND"   ),TamSx3("E3_VEND"   )[1]+2,/*lPixel*/,{|| MOTBCO->E3_VEND       })
TRCell():New(oSection3,"E3_CODCLI"  ,"MOTBCO",RetTitle("E3_CODCLI" ),PesqPict("SE3","E3_CODCLI" ),TamSx3("E3_CODCLI" )[1]+2,/*lPixel*/,{|| MOTBCO->E3_CODCLI     })
TRCell():New(oSection3,"E3_LOJA"    ,"MOTBCO",RetTitle("E3_LOJA"   ),PesqPict("SE3","E3_LOJA"   ),TamSx3("E3_LOJA"   )[1]+2,/*lPixel*/,{|| MOTBCO->E3_LOJA       })
TRCell():New(oSection3,"E3_PREFIXO" ,"MOTBCO",RetTitle("E3_PREFIXO"),PesqPict("SE3","E3_PREFIXO"),TamSx3("E3_PREFIXO")[1]+2,/*lPixel*/,{|| MOTBCO->E3_PREFIXO    })
TRCell():New(oSection3,"E3_NUM"     ,"MOTBCO",RetTitle("E3_NUM"    ),PesqPict("SE3","E3_NUM"    ),TamSx3("E3_NUM"    )[1]+2,/*lPixel*/,{|| MOTBCO->E3_NUM        })
TRCell():New(oSection3,"E3_PARCELA" ,"MOTBCO",RetTitle("E3_PARCELA"),PesqPict("SE3","E3_PARCELA"),TamSx3("E3_PARCELA")[1]+2,/*lPixel*/,{|| MOTBCO->E3_PARCELA    })
TRCell():New(oSection3,"E3_TIPO"    ,"MOTBCO",RetTitle("E3_TIPO"   ),PesqPict("SE3","E3_TIPO"   ),TamSx3("E3_TIPO"   )[1]+2,/*lPixel*/,{|| MOTBCO->E3_TIPO       })
TRCell():New(oSection3,"E3_BASE"    ,"MOTBCO",RetTitle("E3_BASE"   ),PesqPict("SE3","E3_BASE"   ),TamSx3("E3_BASE"   )[1]+2,/*lPixel*/,{|| MOTBCO->E3_BASE       })
TRCell():New(oSection3,"E3_COMIS"   ,"MOTBCO",RetTitle("E3_COMIS"  ),PesqPict("SE3","E3_COMIS"  ),TamSx3("E3_COMIS"  )[1]+2,/*lPixel*/,{|| MOTBCO->E3_COMIS      })
TRCell():New(oSection3,"E3_PORC"    ,"MOTBCO",RetTitle("E3_PORC"   ),PesqPict("SE3","E3_PORC"   ),TamSx3("E3_PORC"   )[1]+2,/*lPixel*/,{|| MOTBCO->E3_PORC       })

oSection3:Cell("E3_EMISSAO" ):SetHeaderAlign("CENTER")
oSection3:Cell("E3_VEND"    ):SetHeaderAlign("CENTER")
oSection3:Cell("E3_CODCLI"  ):SetHeaderAlign("CENTER")
oSection3:Cell("E3_LOJA"    ):SetHeaderAlign("CENTER")
oSection3:Cell("E3_PREFIXO" ):SetHeaderAlign("CENTER")
oSection3:Cell("E3_NUM"     ):SetHeaderAlign("CENTER")
oSection3:Cell("E3_PARCELA" ):SetHeaderAlign("CENTER")
oSection3:Cell("E3_TIPO"    ):SetHeaderAlign("CENTER")
oSection3:Cell("E3_BASE"    ):SetHeaderAlign("RIGHT" )
oSection3:Cell("E3_COMIS"   ):SetHeaderAlign("RIGHT" )
oSection3:Cell("E3_PORC"    ):SetHeaderAlign("RIGHT" )

TRFunction():New(oSection3:Cell("E3_BASE"   ),NIL,"SUM",,,,,,.F.,.F.)
TRFunction():New(oSection3:Cell("E3_COMIS"  ),NIL,"SUM",,,,,,.F.,.F.)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Troca descricao do total dos itens                                     ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
oReport:Section(1):SetTotalText("T O T A I S - Relativo a DiferenÁas nas Comissıes - SINT…TICO"          )
oReport:Section(2):SetTotalText("T O T A I S - Relativo a DiferenÁas nas Comissıes - ANALÕTICO"          )
oReport:Section(3):SetTotalText("Comissıes Duplicadas"                                                   )
oReport:Section(4):SetTotalText("T O T A I S - Relativo a Comissıes Geradas com Motivo de Baixa Indevido")

//oReport:Section(2):SetEdit(.F.)
//oReport:Section(1):SetUseQuery(.T.) // Novo compomente tReport para adcionar campos de usuario no relatorio qdo utiliza query

Return(oReport)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PrintReport∫Autor ≥Anderson C. P. Coelho ∫ Data ≥  06/02/15 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Processamento das informaÁıes para impress„o (Print).       ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Programa Principal                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function PrintReport(oReport)

Local oSection  := oReport:Section(1)
Local oSection1 := oReport:Section(2)
Local oSection2 := oReport:Section(3)
Local oSection3 := oReport:Section(4)
Local _cFilSE1  := oSection1:GetSqlExp("SE1")
Local _cFilSE3  := oSection1:GetSqlExp("SE3")
Local _cFilSE5  := oSection1:GetSqlExp("SE5")
Local _cFilSF1  := oSection1:GetSqlExp("SF1")
Local _cFilSF2  := oSection1:GetSqlExp("SF2")
Local _cBaixa   := ""
Local _cSoDif   := "%"+IIF(MV_PAR09 == 1, "KKK.DIF <> 0","0 = 0")+"%"

If MV_PAR01 > MV_PAR02 .OR. MV_PAR03 > MV_PAR04 .OR. MV_PAR05 > MV_PAR07 .OR. MV_PAR06 > MV_PAR08
	MsgStop("Par‚metros informados incorretamente!",_cRotina+"_002")
	Return
EndIf
If MV_PAR10 == 2		//AnalÌtico
	oSection:Disable()
ElseIf MV_PAR10 == 3	//SintÈtico
	oSection1:Disable()
EndIf
If MV_PAR11 == 2		//N„o mostra duplicados
	oSection2:Disable()
EndIf
If MV_PAR12 == 2		//N„o mostra indevidos
	oSection3:Disable()
EndIf
If MV_PAR13 == 2
	_cBaixa := "%SE1.E1_BAIXA <= '"+DTOS(MV_PAR02)+"'%"
Else
	_cBaixa := "%0 = 0%"
EndIf
If !Empty(_cFilSE5)
	_cFilSE5 := "%AND "+_cFilSE5+"%"
Else
	_cFilSE5 := "%AND 0 = 0%"
EndIf
If !Empty(_cFilSF1)
	_cFilSF1 := "%AND "+_cFilSF1+"%"
Else
	_cFilSF1 := "%AND 0 = 0%"
EndIf
If !Empty(_cFilSF2)
	_cFilSF2 := "%AND "+_cFilSF2+"%"
Else
	_cFilSF2 := "%AND 0 = 0%"
EndIf
If !Empty(_cFilSE1)
	_cFilSE1 := "%AND "+_cFilSE1+"%"
Else
	_cFilSE1 := "%AND 0 = 0%"
EndIf
If !Empty(_cFilSE3)
	_cFilSE3 := "%AND "+_cFilSE3+"%"
Else
	_cFilSE3 := "%AND 0 = 0%"
EndIf

//Elimino os filtros do usu·rio para evitar duplicidades na query, uma vez que j· estou tratando (este procedimento precisa ser realizado antes da montagem da Query)
For _x := 1 To Len(oSection:aUserFilter)
	oSection:aUserFilter[_x][02] := oSection:aUserFilter[_x][03] := ""
Next
oSection:CSQLEXP := ""
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Troca descricao do total dos itens                                     ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//oReport:Section(1):SetTotalText("T O T A I S ")
//PROCESSAMENTO DAS INFORMA«’ES PARA IMPRESS√O
//Transforma parametros do tipo Range em expressao SQL para ser utilizada na query 
MakeSqlExpr(oReport:uParam)
//MakeSqlExpr(cPerg)
oSection:BeginQuery()
	BeginSql Alias "COMSIN"
		SELECT E1_VEND1
			 , ROUND(SUM(F2_VALBRUT),2) F2_VALBRUT
			 , ROUND(SUM(F2_VALICM ),2) F2_VALICM
			 , ROUND(SUM(F2_VALIPI ),2) F2_VALIPI
			 , ROUND(SUM(F2_ICMSRET),2) F2_ICMSRET
			 , ROUND(SUM(F2_VALIMP6),2) F2_VALIMP6
			 , ROUND(SUM(F2_VALIMP5),2) F2_VALIMP5
			 , ROUND(SUM(F2_VALBRUT-F2_VALICM-F2_VALIPI-F2_ICMSRET),2) BASE_NF
			 , ROUND(SUM(E1_BASCOM1),2) E1_BASCOM1
			 , ROUND(SUM(E1_VALOR  ),2) E1_VALOR
			 , ROUND(SUM(E1_SALDO  ),2) E1_SALDO
			 , ROUND(SUM(E5_VALOR  ),2) E5_VALOR
			 , ROUND(SUM(E5_VLDESCO),2) E5_VLDESCO
			 , ROUND(SUM(E5_VLDECRE),2) E5_VLDECRE
			 , ROUND(SUM(E5_VLJUROS),2) E5_VLJUROS
			 , ROUND(SUM(E5_VLCORRE),2) E5_VLCORRE
			 , ROUND(SUM(E5_VLMULTA),2) E5_VLMULTA
			 , ROUND(SUM(RECEBIDO  ),2) RECEBIDO
			 , ROUND(SUM(BASEATU   ),2) BASEATU
			 , ROUND(SUM(E3_BASE   ),2) E3_BASE
			 , ROUND(SUM(DIF       ),2) DIFERENCA
		FROM (
						SELECT E1_VEND1, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
							 , E1_EMISSAO
							 , E1_VENCREA
							 , E1_BASCOM1, E1_COMIS1, F2_VALBRUT, F2_VALICM, F2_VALIPI, F2_ICMSRET, F2_VALIMP6, F2_VALIMP5
							 , E1_VALOR
							 , E1_SALDO
							 , SUM(E5_VALOR)                                                                                                            E5_VALOR
							 , SUM(E5_VLDESCO)                                                                                                          E5_VLDESCO
							 , SUM(E5_VLDECRE)                                                                                                          E5_VLDECRE
							 , SUM(E5_VLJUROS)                                                                                                          E5_VLJUROS
							 , SUM(E5_VLCORRE)                                                                                                          E5_VLCORRE
							 , SUM(E5_VLMULTA)                                                                                                          E5_VLMULTA
							 , SUM(ROUND((E5_VALOR-E5_VLJUROS-E5_VLCORRE-E5_VLMULTA+E5_VLDESCO+E5_VLDECRE),2))                                          RECEBIDO
							 , (ROUND((E1_BASCOM1 / E1_VALOR) * SUM(E5_VALOR-E5_VLJUROS-E5_VLCORRE-E5_VLMULTA/*+E5_VLDESCO+E5_VLDECRE*/) ,2))           BASEATU
							 , (ROUND(E3_BASE,2))                                                                                                       E3_BASE
							 , (ROUND((E1_BASCOM1 / E1_VALOR) * SUM(E5_VALOR-E5_VLJUROS-E5_VLCORRE-E5_VLMULTA/*+E5_VLDESCO+E5_VLDECRE*/) ,2) - E3_BASE) DIF
						FROM (
									SELECT DISTINCT E1_VEND1, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
										 , SUBSTRING(E1_EMISSAO,7,2)+'/'+SUBSTRING(E1_EMISSAO,5,2)+'/'+SUBSTRING(E1_EMISSAO,1,4)                                                                                    E1_EMISSAO
										 , SUBSTRING(E1_VENCREA,7,2)+'/'+SUBSTRING(E1_VENCREA,5,2)+'/'+SUBSTRING(E1_VENCREA,1,4)                                                                                    E1_VENCREA
										 , (F2_VALBRUT                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_VALBRUT
										 , (F2_VALICM                                                                                                             * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_VALICM
										 , (F2_VALIPI                                                                                                             * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_VALIPI
										 , (F2_ICMSRET                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_ICMSRET
										 , (F2_VALIMP6                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_VALIMP6
										 , (F2_VALIMP5                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_VALIMP5
										 , ((CASE WHEN E1_TIPO = 'NCC' THEN E1_VALOR ELSE E1_BASCOM1 END)                                                         * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E1_BASCOM1
										 , (E1_COMIS1                                                                                                             * (CASE WHEN E1_TIPO = 'NCC' THEN  1 ELSE 1 END)) E1_COMIS1
										 , (E1_VALOR                                                                                                              * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E1_VALOR
										 , (E1_SALDO                                                                                                              * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E1_SALDO
										 , (E5_VALOR                                                                                                              * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VALOR
										 , (E5_VLDESCO                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VLDESCO
										 , (E5_VLDECRE                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VLDECRE
										 , (E5_VLJUROS                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VLJUROS
										 , (E5_VLCORRE                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VLCORRE
										 , (E5_VLMULTA                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VLMULTA
										 , (ROUND((E5_VALOR-E5_VLJUROS-E5_VLCORRE-E5_VLMULTA+E5_VLDESCO+E5_VLDECRE),02)                                           * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) RECEBIDO
										 , (ROUND(((CASE WHEN E1_TIPO = 'NCC' THEN E1_VALOR ELSE E1_BASCOM1 END) / E1_VALOR) * (E5_VALOR-E5_VLJUROS-E5_VLCORRE-E5_VLMULTA/*+E5_VLDESCO+E5_VLDECRE*/) ,2)             * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) BASEATU
										 , (E3_BASE                                                                                                               * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E3_BASE
										 , (ROUND(((CASE WHEN E1_TIPO = 'NCC' THEN E1_VALOR ELSE E1_BASCOM1 END) / E1_VALOR) * (E5_VALOR-E5_VLJUROS-E5_VLCORRE-E5_VLMULTA/*+E5_VLDESCO+E5_VLDECRE*/) ,2) - (E3_BASE) * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) DIFERENCA
									FROM %table:SE5% SE5
										INNER JOIN %table:SE1% SE1  ON SE1.E1_FILIAL         = %xFilial:SE1%
																   AND SE1.E1_TIPO          <> 'NCC'
																   AND SE1.E1_COMIS1         > 0
																   AND SE1.E1_VEND1    BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
																   AND SE1.E1_CLIENTE  BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR07%
																   AND SE1.E1_LOJA     BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR08%
																   AND SE1.E1_PREFIXO        = SE5.E5_PREFIXO
																   AND SE1.E1_NUM            = SE5.E5_NUMERO
																   AND SE1.E1_PARCELA        = SE5.E5_PARCELA
																   AND SE1.E1_TIPO           = SE5.E5_TIPO
																   AND SE1.E1_CLIENTE        = SE5.E5_CLIFOR
																   AND SE1.E1_LOJA           = SE5.E5_LOJA
																   AND %Exp:_cBaixa%
																   AND SE1.%NotDel%
																   %Exp:_cFilSE1%
										INNER JOIN %table:SF2% SF2  ON SF2.F2_FILIAL         = %xFilial:SF2%
																   AND SF2.F2_TIPO          <> 'D'
																   AND SF2.F2_TIPO          <> 'B'
																   AND SF2.F2_PREFIXO        = SE1.E1_PREFIXO
																   AND SF2.F2_DUPL           = SE1.E1_NUM
																   AND SF2.F2_CLIENTE        = SE1.E1_CLIENTE
																   AND SF2.F2_LOJA           = SE1.E1_LOJA
																   AND SF2.F2_VEND1          = SE1.E1_VEND1
																   AND SF2.%NotDel%
																   %Exp:_cFilSF2%
										LEFT OUTER JOIN %table:SE3% SE3 ON SE3.E3_FILIAL     = %xFilial:SE3%
																   AND SE3.E3_VEND           = SE1.E1_VEND1
																   AND SE3.E3_EMISSAO       >= SE5.E5_DATA
																   AND SE3.E3_PREFIXO        = SE5.E5_PREFIXO
																   AND SE3.E3_NUM            = SE5.E5_NUMERO
																   AND SE3.E3_PARCELA        = SE5.E5_PARCELA
																   AND SE3.E3_CODCLI         = SE5.E5_CLIFOR
																   AND SE3.E3_LOJA           = SE5.E5_LOJA
																   AND SE3.E3_SEQ            = SE5.E5_SEQ
																   AND SE3.%NotDel%
																   %Exp:_cFilSE3%
									WHERE SE5.E5_FILIAL     = %xFilial:SE5%
									  AND SE5.E5_DATA BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
									  AND SE5.E5_RECPAG     = 'R'
									  AND SE5.E5_SITUACA   <> 'C'
									  AND SE5.E5_VALOR      > 0
									  AND (SE5.E5_TIPODOC  IN ('VL','BA') OR SE5.E5_MOTBX = 'CMP')
									  AND SE5.%NotDel%
									  %Exp:_cFilSE5%

								UNION ALL

									SELECT DISTINCT E1_VEND1, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
										 , SUBSTRING(E1_EMISSAO,7,2)+'/'+SUBSTRING(E1_EMISSAO,5,2)+'/'+SUBSTRING(E1_EMISSAO,1,4)                                                                                    E1_EMISSAO
										 , SUBSTRING(E1_VENCREA,7,2)+'/'+SUBSTRING(E1_VENCREA,5,2)+'/'+SUBSTRING(E1_VENCREA,1,4)                                                                                    E1_VENCREA
										 , (F1_VALBRUT                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_VALBRUT
										 , (F1_VALICM                                                                                                             * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_VALICM
										 , (F1_VALIPI                                                                                                             * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_VALIPI
										 , (F1_ICMSRET                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_ICMSRET
										 , (F1_VALIMP6                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_VALIMP6
										 , (F1_VALIMP5                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_VALIMP5
										 , (E1_BASCOM1                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E1_BASCOM1
										 , (E1_COMIS1                                                                                                             * (CASE WHEN E1_TIPO = 'NCC' THEN  1 ELSE 1 END)) E1_COMIS1
										 , (E1_VALOR                                                                                                              * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E1_VALOR
										 , (E1_SALDO                                                                                                              * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E1_SALDO
										 , (E1_VALOR                                                                                                              * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VALOR
										 , (0                                                                                                                     * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VLDESCO
										 , (0                                                                                                                     * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VLDECRE
										 , (0                                                                                                                     * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VLJUROS
										 , (0                                                                                                                     * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VLCORRE
										 , (0                                                                                                                     * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VLMULTA
										 , (ROUND(E1_VALOR,02)                                                                                                    * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) RECEBIDO
										 , (E3_BASE                                                                                                               * (CASE WHEN E1_TIPO = 'NCC' THEN  1 ELSE 1 END)) BASEATU
										 , (E3_BASE                                                                                                               * (CASE WHEN E1_TIPO = 'NCC' THEN  1 ELSE 1 END)) E3_BASE
										 , (0                                                                                                                     * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) DIFERENCA
									FROM %table:SE1% SE1
										INNER JOIN %table:SF1% SF1      ON SF1.F1_FILIAL   = %xFilial:SF1%
																	   AND (SF1.F1_TIPO    = 'D' OR SF1.F1_TIPO = 'B')
																	   AND SF1.F1_SERIE    = SE1.E1_PREFIXO
																	   AND SF1.F1_DOC      = SE1.E1_NUM
																	   AND SF1.F1_FORNECE  = SE1.E1_CLIENTE
																	   AND SF1.F1_LOJA     = SE1.E1_LOJA
																	   AND SF1.%NotDel%
																	   %Exp:_cFilSF1%
										LEFT OUTER JOIN %table:SE3% SE3 ON SE3.E3_FILIAL   = %xFilial:SE3%
																	   AND SE3.E3_BAIEMI   = 'E'
																	   AND SE3.E3_VEND     = SE1.E1_VEND1
																	   AND SE3.E3_EMISSAO  = SE1.E1_EMISSAO
																	   AND SE3.E3_PREFIXO  = SE1.E1_PREFIXO
																	   AND SE3.E3_NUM      = SE1.E1_NUM
																	   AND SE3.E3_PARCELA  = SE1.E1_PARCELA
																	   AND SE3.E3_CODCLI   = SE1.E1_CLIENTE
																	   AND SE3.E3_LOJA     = SE1.E1_LOJA
																	   AND SE3.%NotDel%
																	   %Exp:_cFilSE3%
									WHERE SE1.E1_FILIAL        = %xFilial:SE1%
									  AND SE1.E1_TIPO          = 'NCC'
									  AND SE1.E1_EMISSAO BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
									  AND SE1.E1_CLIENTE BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR07%
									  AND SE1.E1_LOJA    BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR08%
									  AND SE1.E1_VEND1   BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
									  AND SE1.%NotDel%
									  %Exp:_cFilSE1%
							) XXX
						GROUP BY E1_VEND1, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_EMISSAO, E1_VENCREA
							 , F2_VALBRUT, F2_VALICM, F2_VALIPI, F2_ICMSRET, F2_VALIMP6, F2_VALIMP5
							 , E1_BASCOM1, E1_COMIS1, E1_VALOR , E1_SALDO
							 , E3_BASE
			) KKK
		WHERE %Exp:_cSoDif%
		GROUP BY E1_VEND1 
		ORDER BY E1_VEND1 
	EndSql
	/*
	Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
	parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
	pela funcao MakeSqlExpr para serem adicionados a query
	*/
oSection:EndQuery()

//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_000.txt",oSection:CQUERY)

oSection:Print()

//Elimino os filtros do usu·rio para evitar duplicidades na query, uma vez que j· estou tratando (este procedimento precisa ser realizado antes da montagem da Query)
For _x := 1 To Len(oSection1:aUserFilter)
	oSection1:aUserFilter[_x][02] := oSection1:aUserFilter[_x][03] := ""
Next
oSection1:CSQLEXP := ""
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Troca descricao do total dos itens                                     ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//oReport:Section(1):SetTotalText("T O T A I S ")
//PROCESSAMENTO DAS INFORMA«’ES PARA IMPRESS√O
//Transforma parametros do tipo Range em expressao SQL para ser utilizada na query 
MakeSqlExpr(oReport:uParam)
//MakeSqlExpr(cPerg)
oSection1:BeginQuery()
	BeginSql Alias "COMTMP"
		SELECT E1_VEND1, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_EMISSAO, E1_VENCREA, E1_COMIS1
			 , ROUND(SUM(F2_VALBRUT),2) F2_VALBRUT
			 , ROUND(SUM(F2_VALICM ),2) F2_VALICM
			 , ROUND(SUM(F2_VALIPI ),2) F2_VALIPI
			 , ROUND(SUM(F2_ICMSRET),2) F2_ICMSRET
			 , ROUND(SUM(F2_VALIMP6),2) F2_VALIMP6
			 , ROUND(SUM(F2_VALIMP5),2) F2_VALIMP5
			 , ROUND(SUM(F2_VALBRUT-F2_VALICM-F2_VALIPI-F2_ICMSRET),2) BASE_NF
			 , ROUND(SUM(E1_BASCOM1),2) E1_BASCOM1
			 , ROUND(SUM(E1_VALOR  ),2) E1_VALOR
			 , ROUND(SUM(E1_SALDO  ),2) E1_SALDO
			 , ROUND(SUM(E5_VALOR  ),2) E5_VALOR
			 , ROUND(SUM(E5_VLDESCO),2) E5_VLDESCO
			 , ROUND(SUM(E5_VLDECRE),2) E5_VLDECRE
			 , ROUND(SUM(E5_VLJUROS),2) E5_VLJUROS
			 , ROUND(SUM(E5_VLCORRE),2) E5_VLCORRE
			 , ROUND(SUM(E5_VLMULTA),2) E5_VLMULTA
			 , ROUND(SUM(RECEBIDO  ),2) RECEBIDO
			 , ROUND(SUM(BASEATU   ),2) BASEATU
			 , ROUND(SUM(E3_BASE   ),2) E3_BASE
			 , ROUND(SUM(DIF       ),2) DIFERENCA
		FROM (
						SELECT E1_VEND1, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
							 , E1_EMISSAO
							 , E1_VENCREA
							 , E1_BASCOM1, E1_COMIS1, F2_VALBRUT, F2_VALICM, F2_VALIPI, F2_ICMSRET, F2_VALIMP6, F2_VALIMP5
							 , E1_VALOR
							 , E1_SALDO
							 , SUM(E5_VALOR)                                                                                                              E5_VALOR
							 , SUM(E5_VLDESCO)                                                                                                            E5_VLDESCO
							 , SUM(E5_VLDECRE)                                                                                                            E5_VLDECRE
							 , SUM(E5_VLJUROS)                                                                                                            E5_VLJUROS
							 , SUM(E5_VLCORRE)                                                                                                            E5_VLCORRE
							 , SUM(E5_VLMULTA)                                                                                                            E5_VLMULTA
							 , SUM(ROUND((E5_VALOR-E5_VLJUROS-E5_VLCORRE-E5_VLMULTA+E5_VLDESCO+E5_VLDECRE),2))                                            RECEBIDO
							 , (ROUND((E1_BASCOM1 / E1_VALOR) * SUM(E5_VALOR-E5_VLJUROS-E5_VLCORRE-E5_VLMULTA/*+E5_VLDESCO+E5_VLDECRE*/) ,2))             BASEATU
							 , (ROUND(E3_BASE,2))                                                                                                         E3_BASE
							 , (ROUND((E1_BASCOM1 / E1_VALOR) * SUM(E5_VALOR-E5_VLJUROS-E5_VLCORRE-E5_VLMULTA/*+E5_VLDESCO+E5_VLDECRE*/) ,2) - (E3_BASE)) DIF
						FROM (
									SELECT DISTINCT E1_VEND1, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
										 , SUBSTRING(E1_EMISSAO,7,2)+'/'+SUBSTRING(E1_EMISSAO,5,2)+'/'+SUBSTRING(E1_EMISSAO,1,4)                                                                                    E1_EMISSAO
										 , SUBSTRING(E1_VENCREA,7,2)+'/'+SUBSTRING(E1_VENCREA,5,2)+'/'+SUBSTRING(E1_VENCREA,1,4)                                                                                    E1_VENCREA
										 , (F2_VALBRUT                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_VALBRUT
										 , (F2_VALICM                                                                                                             * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_VALICM
										 , (F2_VALIPI                                                                                                             * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_VALIPI
										 , (F2_ICMSRET                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_ICMSRET
										 , (F2_VALIMP6                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_VALIMP6
										 , (F2_VALIMP5                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_VALIMP5
										 , ((CASE WHEN E1_TIPO = 'NCC' THEN E1_VALOR ELSE E1_BASCOM1 END)                                                         * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E1_BASCOM1
										 , (E1_COMIS1                                                                                                             * (CASE WHEN E1_TIPO = 'NCC' THEN  1 ELSE 1 END)) E1_COMIS1
										 , (E1_VALOR                                                                                                              * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E1_VALOR
										 , (E1_SALDO                                                                                                              * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E1_SALDO
										 , (E5_VALOR                                                                                                              * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VALOR
										 , (E5_VLDESCO                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VLDESCO
										 , (E5_VLDECRE                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VLDECRE
										 , (E5_VLJUROS                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VLJUROS
										 , (E5_VLCORRE                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VLCORRE
										 , (E5_VLMULTA                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VLMULTA
										 , (ROUND((E5_VALOR-E5_VLJUROS-E5_VLCORRE-E5_VLMULTA+E5_VLDESCO+E5_VLDECRE),02)                                           * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) RECEBIDO
										 , (ROUND(((CASE WHEN E1_TIPO = 'NCC' THEN E1_VALOR ELSE E1_BASCOM1 END) / E1_VALOR) * (E5_VALOR-E5_VLJUROS-E5_VLCORRE-E5_VLMULTA/*+E5_VLDESCO+E5_VLDECRE*/) ,2)             * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) BASEATU
										 , (E3_BASE                                                                                                               * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E3_BASE
										 , (ROUND(((CASE WHEN E1_TIPO = 'NCC' THEN E1_VALOR ELSE E1_BASCOM1 END) / E1_VALOR) * (E5_VALOR-E5_VLJUROS-E5_VLCORRE-E5_VLMULTA/*+E5_VLDESCO+E5_VLDECRE*/) ,2) - (E3_BASE) * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) DIFERENCA
									FROM %table:SE5% SE5
										INNER JOIN %table:SE1% SE1  ON SE1.E1_FILIAL         = %xFilial:SE1%
																   AND SE1.E1_TIPO          <> 'NCC'
																   AND SE1.E1_COMIS1         > 0
																   AND SE1.E1_VEND1    BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
																   AND SE1.E1_CLIENTE  BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR07%
																   AND SE1.E1_LOJA     BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR08%
																   AND SE1.E1_PREFIXO        = SE5.E5_PREFIXO
																   AND SE1.E1_NUM            = SE5.E5_NUMERO
																   AND SE1.E1_PARCELA        = SE5.E5_PARCELA
																   AND SE1.E1_TIPO           = SE5.E5_TIPO
																   AND SE1.E1_CLIENTE        = SE5.E5_CLIFOR
																   AND SE1.E1_LOJA           = SE5.E5_LOJA
																   AND %Exp:_cBaixa%
																   AND SE1.%NotDel%
																   %Exp:_cFilSE1%
										INNER JOIN %table:SF2% SF2  ON SF2.F2_FILIAL         = %xFilial:SF2%
																   AND SF2.F2_TIPO          <> 'D'
																   AND SF2.F2_TIPO          <> 'B'
																   AND SF2.F2_PREFIXO        = SE1.E1_PREFIXO
																   AND SF2.F2_DUPL           = SE1.E1_NUM
																   AND SF2.F2_CLIENTE        = SE1.E1_CLIENTE
																   AND SF2.F2_LOJA           = SE1.E1_LOJA
																   AND SF2.F2_VEND1          = SE1.E1_VEND1
																   AND SF2.%NotDel%
																   %Exp:_cFilSF2%
										LEFT OUTER JOIN %table:SE3% SE3 ON SE3.E3_FILIAL     = %xFilial:SE3%
																   AND SE3.E3_VEND           = SE1.E1_VEND1
																   AND SE3.E3_EMISSAO       >= SE5.E5_DATA
																   AND SE3.E3_PREFIXO        = SE5.E5_PREFIXO
																   AND SE3.E3_NUM            = SE5.E5_NUMERO
																   AND SE3.E3_PARCELA        = SE5.E5_PARCELA
																   AND SE3.E3_CODCLI         = SE5.E5_CLIFOR
																   AND SE3.E3_LOJA           = SE5.E5_LOJA
																   AND SE3.E3_SEQ            = SE5.E5_SEQ
																   AND SE3.%NotDel%
																   %Exp:_cFilSE3%
									WHERE SE5.E5_FILIAL     = %xFilial:SE5%
									  AND SE5.E5_DATA BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
									  AND SE5.E5_RECPAG     = 'R'
									  AND SE5.E5_SITUACA   <> 'C'
									  AND SE5.E5_VALOR      > 0
									  AND (SE5.E5_TIPODOC  IN ('VL','BA') OR SE5.E5_MOTBX = 'CMP')
									  AND SE5.%NotDel%
									  %Exp:_cFilSE5%

								UNION ALL

									SELECT DISTINCT E1_VEND1, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
										 , SUBSTRING(E1_EMISSAO,7,2)+'/'+SUBSTRING(E1_EMISSAO,5,2)+'/'+SUBSTRING(E1_EMISSAO,1,4)                                                                                    E1_EMISSAO
										 , SUBSTRING(E1_VENCREA,7,2)+'/'+SUBSTRING(E1_VENCREA,5,2)+'/'+SUBSTRING(E1_VENCREA,1,4)                                                                                    E1_VENCREA
										 , (F1_VALBRUT                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_VALBRUT
										 , (F1_VALICM                                                                                                             * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_VALICM
										 , (F1_VALIPI                                                                                                             * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_VALIPI
										 , (F1_ICMSRET                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_ICMSRET
										 , (F1_VALIMP6                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_VALIMP6
										 , (F1_VALIMP5                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) F2_VALIMP5
										 , (E1_BASCOM1                                                                                                            * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E1_BASCOM1
										 , (E1_COMIS1                                                                                                             * (CASE WHEN E1_TIPO = 'NCC' THEN  1 ELSE 1 END)) E1_COMIS1
										 , (E1_VALOR                                                                                                              * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E1_VALOR
										 , (E1_SALDO                                                                                                              * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E1_SALDO
										 , (E1_VALOR                                                                                                              * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VALOR
										 , (0                                                                                                                     * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VLDESCO
										 , (0                                                                                                                     * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VLDECRE
										 , (0                                                                                                                     * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VLJUROS
										 , (0                                                                                                                     * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VLCORRE
										 , (0                                                                                                                     * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) E5_VLMULTA
										 , (ROUND(E1_VALOR,02)                                                                                                    * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) RECEBIDO
										 , (E3_BASE                                                                                                               * (CASE WHEN E1_TIPO = 'NCC' THEN  1 ELSE 1 END)) BASEATU
										 , (E3_BASE                                                                                                               * (CASE WHEN E1_TIPO = 'NCC' THEN  1 ELSE 1 END)) E3_BASE
										 , (0                                                                                                                     * (CASE WHEN E1_TIPO = 'NCC' THEN -1 ELSE 1 END)) DIFERENCA
									FROM %table:SE1% SE1
										INNER JOIN %table:SF1% SF1      ON SF1.F1_FILIAL   = %xFilial:SF1%
																	   AND (SF1.F1_TIPO    = 'D' OR SF1.F1_TIPO = 'B')
																	   AND SF1.F1_SERIE    = SE1.E1_PREFIXO
																	   AND SF1.F1_DOC      = SE1.E1_NUM
																	   AND SF1.F1_FORNECE  = SE1.E1_CLIENTE
																	   AND SF1.F1_LOJA     = SE1.E1_LOJA
																	   AND SF1.%NotDel%
																	   %Exp:_cFilSF1%
										LEFT OUTER JOIN %table:SE3% SE3 ON SE3.E3_FILIAL   = %xFilial:SE3%
																	   AND SE3.E3_BAIEMI   = 'E'
																	   AND SE3.E3_VEND     = SE1.E1_VEND1
																	   AND SE3.E3_EMISSAO  = SE1.E1_EMISSAO
																	   AND SE3.E3_PREFIXO  = SE1.E1_PREFIXO
																	   AND SE3.E3_NUM      = SE1.E1_NUM
																	   AND SE3.E3_PARCELA  = SE1.E1_PARCELA
																	   AND SE3.E3_CODCLI   = SE1.E1_CLIENTE
																	   AND SE3.E3_LOJA     = SE1.E1_LOJA
																	   AND SE3.%NotDel%
																	   %Exp:_cFilSE3%
									WHERE SE1.E1_FILIAL        = %xFilial:SE1%
									  AND SE1.E1_TIPO          = 'NCC'
									  AND SE1.E1_EMISSAO BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
									  AND SE1.E1_CLIENTE BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR07%
									  AND SE1.E1_LOJA    BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR08%
									  AND SE1.E1_VEND1   BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
									  AND SE1.%NotDel%
									  %Exp:_cFilSE1%
							) XXX
						GROUP BY E1_VEND1, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_EMISSAO, E1_VENCREA, F2_VALBRUT, F2_VALICM, F2_VALIPI, F2_ICMSRET, F2_VALIMP6, F2_VALIMP5
							 , E1_BASCOM1, E1_COMIS1
							 , E1_VALOR
							 , E1_SALDO
							 , E3_BASE
			) KKK
		WHERE %Exp:_cSoDif%
		GROUP BY E1_VEND1, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_EMISSAO, E1_VENCREA, E1_COMIS1 
	EndSql
	/*
	Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
	parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
	pela funcao MakeSqlExpr para serem adicionados a query
	*/
oSection1:EndQuery()

//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.txt",oSection1:CQUERY)

oSection1:Print()

//Elimino os filtros do usu·rio para evitar duplicidades na query, uma vez que j· estou tratando (este procedimento precisa ser realizado antes da montagem da Query)
For _x := 1 To Len(oSection2:aUserFilter)
	oSection2:aUserFilter[_x][02] := oSection2:aUserFilter[_x][03] := ""
Next
oSection2:CSQLEXP := ""
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Troca descricao do total dos itens                                     ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//oReport:Section(2):SetTotalText("T O T A I S ")
//PROCESSAMENTO DAS INFORMA«’ES PARA IMPRESS√O
//Transforma parametros do tipo Range em expressao SQL para ser utilizada na query 
MakeSqlExpr(oReport:uParam)
//MakeSqlExpr(cPerg)
oSection2:BeginQuery()
	BeginSql Alias "DUPLCO"
		SELECT E3_VEND, E3_CODCLI, E3_LOJA , E3_PREFIXO, E3_NUM, E3_PARCELA, E3_TIPO, E3_EMISSAO, E3_VENCTO, E3_PEDIDO, E3_ORIGEM, E3_BAIEMI, E3_BASE, E3_PORC, E3_COMIS, COUNT(*) REGISTROS
		FROM %table:SE3% SE3 
		WHERE SE3.E3_FILIAL        = %xFilial:SE3%
		  AND SE3.E3_VEND    BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04% 
		  AND SE3.E3_CODCLI  BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR07% 
		  AND SE3.E3_LOJA    BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR08% 
		  AND SE3.E3_EMISSAO BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% 
		  AND SE3.E3_RELFAT NOT LIKE 'ELIM.EM MASSA%' 
		  AND SE3.%NotDel%
		  %Exp:_cFilSE3%
		GROUP BY E3_VEND, E3_PREFIXO, E3_NUM, E3_PARCELA, E3_TIPO, E3_EMISSAO, E3_VENCTO, E3_PEDIDO, E3_ORIGEM, E3_BAIEMI, E3_CODCLI, E3_LOJA, E3_BASE, E3_COMIS, E3_PORC 
		HAVING COUNT(*) > 1 
		ORDER BY E3_VEND, E3_CODCLI, E3_LOJA, E3_PREFIXO, E3_NUM, E3_PARCELA, E3_EMISSAO, E3_VENCTO
	EndSql
	/*
	Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
	parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
	pela funcao MakeSqlExpr para serem adicionados a query
	*/
oSection2:EndQuery()

//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_002.txt",oSection2:CQUERY)

oSection2:Print()

//Elimino os filtros do usu·rio para evitar duplicidades na query, uma vez que j· estou tratando (este procedimento precisa ser realizado antes da montagem da Query)
For _x := 1 To Len(oSection3:aUserFilter)
	oSection3:aUserFilter[_x][02] := oSection3:aUserFilter[_x][03] := ""
Next
oSection3:CSQLEXP := ""
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Troca descricao do total dos itens                                     ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//oReport:Section(2):SetTotalText("T O T A I S ")
//PROCESSAMENTO DAS INFORMA«’ES PARA IMPRESS√O
//Transforma parametros do tipo Range em expressao SQL para ser utilizada na query 
MakeSqlExpr(oReport:uParam)
//MakeSqlExpr(cPerg)
oSection3:BeginQuery()
	BeginSql Alias "MOTBCO"
		SELECT *
		FROM %table:SE5% SE5
			INNER JOIN %table:SE3% SE3 ON SE3.E3_FILIAL        = %xFilial:SE3%
									  AND SE3.E3_VEND    BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04% 
									  AND SE3.E3_CODCLI  BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR07% 
									  AND SE3.E3_LOJA    BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR08% 
									  AND SE3.E3_EMISSAO BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% 
									  AND SE3.E3_RELFAT NOT LIKE 'ELIM.EM MASSA%' 
									  AND SE3.E3_PREFIXO       = SE5.E5_PREFIXO
									  AND SE3.E3_NUM           = SE5.E5_NUMERO
									  AND SE3.E3_PARCELA       = SE5.E5_PARCELA
									  AND SE3.E3_TIPO          = SE5.E5_TIPO
									  AND SE3.E3_CODCLI        = SE5.E5_CLIENTE
									  AND SE3.E3_LOJA          = SE5.E5_LOJA
									  AND SE3.%NotDel%
									  %Exp:_cFilSE3%
		WHERE SE5.E5_FILIAL  = %xFilial:SE5%
		  AND (SE5.E5_MOTBX IN %Exp:_cMotBx%)
		  AND SE5.%NotDel%
		  %Exp:_cFilSE5%
		ORDER BY E3_VEND, E3_CODCLI, E3_LOJA, E3_PREFIXO, E3_NUM, E3_PARCELA, E3_EMISSAO, E3_VENCTO
	EndSql
	/*
	Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
	parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
	pela funcao MakeSqlExpr para serem adicionados a query
	*/
oSection3:EndQuery()

//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_003.txt",oSection3:CQUERY)

oSection3:Print()

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥VALIDPERG ∫Autor  ≥Anderson C. P. Coelho ∫ Data ≥  16/02/16 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Valida se as perguntas est„o criadas no arquivo SX1 e caso ∫±±
±±∫          ≥ n„o as encontre ele as cria.                               ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Programa Principal                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function ValidPerg()

Local _sAlias := GetArea()
Local aRegs   := {}

cPerg := PADR(cPerg,10)

AADD(aRegs,{cPerg,"01","PerÌodo de?"       ,"","","mv_ch1","D",08,0,0,"G","","mv_par01",""         ,"","","","",""         ,"","","","",""         ,"","","","",""         ,"","","","",""          ,"","","",""   ,""})
AADD(aRegs,{cPerg,"02","PerÌodo atÈ?"      ,"","","mv_ch2","D",08,0,0,"G","","mv_par02",""         ,"","","","",""         ,"","","","",""         ,"","","","",""         ,"","","","",""          ,"","","",""   ,""})

// AlteraÁ„o - Fernando Bombardi - ALLSS - 03/03/2022
//AADD(aRegs,{cPerg,"03","De Vendedor?"      ,"","","mv_ch3","C",06,0,0,"G","","mv_par03",""         ,"","","","",""         ,"","","","",""         ,"","","","",""         ,"","","","",""          ,"","","","SA3",""})
//AADD(aRegs,{cPerg,"04","AtÈ Vendedor?"     ,"","","mv_ch4","C",06,0,0,"G","","mv_par04",""         ,"","","","",""         ,"","","","",""         ,"","","","",""         ,"","","","",""          ,"","","","SA3",""})
AADD(aRegs,{cPerg,"03","De Representante?"      ,"","","mv_ch3","C",06,0,0,"G","","mv_par03",""         ,"","","","",""         ,"","","","",""         ,"","","","",""         ,"","","","",""          ,"","","","SA3",""})
AADD(aRegs,{cPerg,"04","AtÈ Representante?"     ,"","","mv_ch4","C",06,0,0,"G","","mv_par04",""         ,"","","","",""         ,"","","","",""         ,"","","","",""         ,"","","","",""          ,"","","","SA3",""})
// Fim - Fernando Bombardi - ALLSS - 03/03/2022

AADD(aRegs,{cPerg,"05","De Cliente?"       ,"","","mv_ch5","C",06,0,0,"G","","mv_par05",""         ,"","","","",""         ,"","","","",""         ,"","","","",""         ,"","","","",""          ,"","","","SA1",""})
AADD(aRegs,{cPerg,"06","De Loja?"          ,"","","mv_ch6","C",02,0,0,"G","","mv_par06",""         ,"","","","",""         ,"","","","",""         ,"","","","",""         ,"","","","",""          ,"","","",""   ,""})
AADD(aRegs,{cPerg,"07","AtÈ Cliente?"      ,"","","mv_ch7","C",06,0,0,"G","","mv_par07",""         ,"","","","",""         ,"","","","",""         ,"","","","",""         ,"","","","",""          ,"","","","SA1",""})
AADD(aRegs,{cPerg,"08","AtÈ Loja?"         ,"","","mv_ch8","C",02,0,0,"G","","mv_par08",""         ,"","","","",""         ,"","","","",""         ,"","","","",""         ,"","","","",""          ,"","","",""   ,""})
AADD(aRegs,{cPerg,"09","SÛ DiferenÁas?"    ,"","","mv_ch9","C",01,0,0,"C","","mv_par09","Sim"      ,"","","","","N„o"      ,"","","","",""         ,"","","","",""         ,"","","","",""          ,"","","",""   ,""})
AADD(aRegs,{cPerg,"10","Tipo?"             ,"","","mv_cha","C",01,0,0,"C","","mv_par10","Ambos"    ,"","","","","AnalÌtico","","","","","SintÈtico","","","","",""         ,"","","","",""          ,"","","",""   ,""})
AADD(aRegs,{cPerg,"11","Mostra Duplicados?","","","mv_chb","C",01,0,0,"C","","mv_par11","Sim"      ,"","","","","N„o"      ,"","","","",""         ,"","","","",""         ,"","","","",""          ,"","","",""   ,""})
AADD(aRegs,{cPerg,"12","Mostra Indevidos?" ,"","","mv_chc","C",01,0,0,"C","","mv_par12","Sim"      ,"","","","","N„o"      ,"","","","",""         ,"","","","",""         ,"","","","",""          ,"","","",""   ,""})
AADD(aRegs,{cPerg,"13","Baixas?"           ,"","","mv_chd","C",01,0,0,"C","","mv_par13","Todos"    ,"","","","","Totais"   ,"","","","",""         ,"","","","",""         ,"","","","",""          ,"","","",""   ,""})

For i := 1 To Len(aRegs)
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If !SX1->(MsSeek(cPerg+aRegs[i,2],.T.,.F.))
		RecLock("SX1",.T.)
		For j := 1 To FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Else              
				Exit
			EndIf
		Next
		SX1->(MsUnlock())
	EndIf
Next

RestArea(_sAlias)

Return
