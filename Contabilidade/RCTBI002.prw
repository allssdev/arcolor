#include 'protheus.ch'
#include 'parmtype.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณRCTBI002 บAutor  ณAnderson C. P. Coelho บ Data ณ 27/07/11   บฑฑ
ฑฑบ          ณ         บAutor  ณ J๚lio Soares         บ Data ณ 29/08/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de importa็ใo do arquivo CVS, conforme layout espe- บฑฑ
ฑฑบ          ณcificado no projeto.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ Inserido tratamento para gerar arquivos de acordo com o    บฑฑ
ฑฑบ          ณ tipo de contabiliza็ใo.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico empresa Arcolor.                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user function RCTBI002()
	Local   _lRet    := .T.
	Private cDrive, cDir, cNome, cExt
	Private aErro    := {}
	Private cArq     := ""
	Private _cRotina := "RCTBI002"
	If !Pergunte("CTB500",.T.)
		return
	EndIf
	cArq := AllTrim(Lower(MV_PAR03))
	If !Empty(cArq)
		SplitPath(cArq, @cDrive, @cDir, @cNome, @cExt)
		If !File(cDrive+cDir+cNome+cExt) .OR. ".CSV"<>UPPER(cExt)
			MsgStop("O arquivo '" + cDrive+cDir+cNome+cExt + "' nใo foi encontrado ou encontra-se em formato divergente. Importa็ใo abortada!",_cRotina+"_001")
			_lRet := .F.
		Else
			Processa( { |lEnd| _lRet := ImportArq(@lEnd) }, "["+_cRotina+"] Importa็ใo das Contabiliza็๕es","Aguarde, processando arquivo...",.F.)
		EndIf
	Else
		MsgAlert("Nenhum arquivo selecionado!",_cRotina+"_002")
	EndIf
	If _lRet
		SetFUnName("RCTB001A")
		CTBA500()
		SetFUnName("RCTB001B")
		CTBA500()
		SetFUnName("RCTB001C")
		CTBA500()
	EndIf
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณImportArq บAutor  ณAnderson C. P. Coelho บ Data ณ  26/08/16 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Sub-Rotina de processamento do arquivo CSV selecionado.    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function ImportArq()
	Local nTamLin, cLin, cCpo
	Local   aCampos  := {}
	Local   aDados   := {}
	Local   aLinha   := {}
	Local   _aLayout := {	{"CT2_LP"    , TamSx3("CT2_LP")[01]                    },;
							{"CT2_DATA"  , Len(StrTran(DTOC(CT2->CT2_DATA),"/",""))},;
							{"CT2_DEBITO", TamSx3("CT2_DEBITO")[01]                },;
							{"CT2_CREDIT", TamSx3("CT2_CREDIT")[01]                },;
							{"CT2_VALOR" , TamSx3("CT2_VALOR" )[01]                },;
							{"CT2_HIST"  , TamSx3("CT2_HIST"  )[01]                } }
	Local   _lProc   := .T.
	Local   cLin1    := ''
	Local   cLin2    := ''
	Local   cLin3    := ''
	Local   cLinha   := ""
	Local   _cNum    := ""
	Local   _cProds  := ""
	Local   nLinha   := 0
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cria o arquivo texto                                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Private nHdl1    := fCreate(StrTran(Substring(cArq,1,Len(cArq)-4) + '_a'+Substring(cArq,Len(cArq)-3,4) ,".csv",".txt"))
	Private nHdl2    := fCreate(StrTran(Substring(cArq,1,Len(cArq)-4) + '_c'+Substring(cArq,Len(cArq)-3,4) ,".csv",".txt"))
	Private nHdl3    := fCreate(StrTran(Substring(cArq,1,Len(cArq)-4) + '_d'+Substring(cArq,Len(cArq)-3,4) ,".csv",".txt"))
	Private cEOL     := "CHR(13)+CHR(10)"
	If Empty(cEOL)
	    cEOL := CHR(13)+CHR(10)
	Else
	    cEOL := Trim(cEOL)
	    cEOL := &cEOL
	EndIf
	If nHdl1 == -1 .And. nHdl2 == -1 .And. nHdl3 == -1 
	    MsgAlert("O arquivo de nome '"+cArq+"' nao pode ser executado! Verifique os parametros.",_cRotina+"_003")
	    _lProc := .F.
	EndIf
	dbSelectArea("CT2")
	CT2->(dbSetOrder(1))
	//Processa o arquivo CSV
	FT_FUSE(cDrive+cDir+cNome+cExt)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	// TRATAR O ARQUIVO DIVISOR
	If _lProc .AND. !FT_FEOF()
		While !FT_FEOF()
			nLinha++
			IncProc("Lendo linha " + cValToChar(nLinha) + " do arquivo " + AllTrim(cNome+cExt) + "...")
			cLinha  := FT_FREADLN()
			aLinha  := Separa(cLinha,";",.T.)
			nTamLin := 240
			cLin    := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Substitui nas respectivas posicioes na variavel cLin pelo conteudo  ณ
			//ณ dos campos segundo o Lay-Out. Utiliza a funcao STUFF insere uma     ณ
			//ณ string dentro de outra string.                                      ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			nTamA := 1
			If !Empty(aLinha[3]) .And.!Empty(aLinha[4])
				cLin1    := Space(nTamLin)+cEOL
				for _x := 1 to Len(aLinha)
					If Len(_aLayout) >= _x
						nTam := _aLayout[_x][02]
						If _aLayout[_x][01] == "CT2_DATA"
							cCpo := PADR(StrZero(Val(aLinha[_x]),_aLayout[_x][02])  , nTam)
						ElseIf _aLayout[_x][01] == "CT2_VALOR"
							cCpo := PADR(StrTran(StrTran(aLinha[_x],".",""),",","") ,nTam)
						Else
							cCpo := PADR(aLinha[_x], nTam)
						EndIf
						cLin1 := Stuff(cLin1,nTamA,nTam,cCpo)
						nTamA+= nTam
						If _x  < Len(aLinha)
							nTam := 1
							cCpo := ";"
							cLin1 := Stuff(cLin1,nTamA,nTam,cCpo)
							nTamA+= nTam
						EndIf
					Else
						MsgAlert("Problemas com a estrutura do arquivo!",_cRotina+"_004")
						_lProc := .F.
						Exit
					EndIf
				next
				If fWrite(nHdl1,cLin1,Len(cLin1)) != Len(cLin1)
					MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?",_cRotina+"_005")
					_lProc := .F.
					Exit
				EndIf
			ElseIf Empty(aLinha[3]) .And. !Empty(aLinha[4])
				cLin2  := Space(nTamLin)+cEOL
				for _x := 1 to Len(aLinha)
					If Len(_aLayout) >= _x
						nTam := _aLayout[_x][02]
						If _aLayout[_x][01] == "CT2_DATA"
							cCpo := PADR(StrZero(Val(aLinha[_x]),_aLayout[_x][02])  , nTam)
						ElseIf _aLayout[_x][01] == "CT2_VALOR"
							cCpo := PADR(StrTran(StrTran(aLinha[_x],".",""),",","") ,nTam)
						Else
							cCpo := PADR(aLinha[_x], nTam)
						EndIf
						cLin2 := Stuff(cLin2,nTamA,nTam,cCpo)
						nTamA+= nTam
						If _x  < Len(aLinha)
							nTam := 1
							cCpo := ";"
							cLin2 := Stuff(cLin2,nTamA,nTam,cCpo)
							nTamA+= nTam
						EndIf
					Else
						MsgAlert("Problemas com a estrutura do arquivo!",_cRotina+"_004")
						_lProc := .F.
						Exit
					EndIf
				next
				If fWrite(nHdl2,cLin2,Len(cLin2)) != Len(cLin2)
					MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?",_cRotina+"_005")
					_lProc := .F.
					Exit
				EndIf
			ElseIf !Empty(aLinha[3]) .And.Empty(aLinha[4])
				cLin3  := Space(nTamLin)+cEOL
				for _x := 1 to Len(aLinha)
					If Len(_aLayout) >= _x
						nTam := _aLayout[_x][02]
						If _aLayout[_x][01] == "CT2_DATA"
							cCpo := PADR(StrZero(Val(aLinha[_x]),_aLayout[_x][02])  , nTam)
						ElseIf _aLayout[_x][01] == "CT2_VALOR"
							cCpo := PADR(StrTran(StrTran(aLinha[_x],".",""),",","") ,nTam)
						Else
							cCpo := PADR(aLinha[_x], nTam)
						EndIf
						cLin3 := Stuff(cLin3,nTamA,nTam,cCpo)
						nTamA+= nTam
						If _x  < Len(aLinha)
							nTam := 1
							cCpo := ";"
							cLin3 := Stuff(cLin3,nTamA,nTam,cCpo)
							nTamA+= nTam
						EndIf
					Else
						MsgAlert("Problemas com a estrutura do arquivo!",_cRotina+"_004")
						_lProc := .F.
						Exit
					EndIf
				next
				If fWrite(nHdl3,cLin3,Len(cLin3)) != Len(cLin3)
					MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?",_cRotina+"_005")
					_lProc := .F.
					Exit
				EndIf
			EndIf
			FT_FSKIP()
		EndDo
	Else
		MsgAlert("Arquivo vazio!",_cRotina+"_006")
		_lProc := .F.
	EndIf
	FClose(nHdl1)
	FClose(nHdl2)
	FClose(nHdl3)
	FT_FUSE()
return(_lProc)