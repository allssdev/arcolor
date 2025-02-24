#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "SHELL.CH"
//#INCLUDE "APWEBEX.CH"
#include 'parmtype.ch'
#include "fileio.ch"
//#INCLUDE "TOTVS.CH"
#DEFINE _CRLF CHR(13) + CHR(10)
/*/{Protheus.doc} RGPEI002
@description Rotina de importação da Ficha Financeira da Folha de Pagamento do escritório contábil DJ para a tabela SRC (via RecLock).
@author Anderson C. P. Coelho (ALL System Solutions)
@since 05/01/2019
@version 1.0
@obs O arquivo que nos foi enviado foi no formato PDF, sendo impossível a sua importação. Para obtermos êxito, convertemos o arquivo para o formato XLS (via URL "https://www.aconvert.com/pdf/pdf-to-xml/"). Depois, por meio do Excel (Office 365), o arquivo foi convertido para TXT. Estes procedimentos sejam gerados exatamente desta forma. 
@type function
@see https://allss.com.br
/*/
user function RGPEI002()
	Local oGroup1
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSButton1
	Local oSButton2
	Local oSButton3
	Local _cLog          := ""
	Local _cLogTempo     := ""

	Private cDrive, cDir, cNome, cExt
	Private _cRotina     := "RGPEI002"
	Private cPerg        := _cRotina
	Private _cArqLog     := GetTempPath()+_cRotina+"_Ficha_Financeira_"+DTOS(Date())+"_"+StrTran(Time(),":","")+".csv"
	Private cTitulo      := "Importação da Ficha Financeira da Folha de Pagamento (TXT)"
	Private cCadastro    := cTitulo
	Private _cArqOri     := ""
	Private _nOpc        := 0
	Private _nMat        := 0
	Private _lProc       := .T.
	Private _aSvAr       := GetArea()
	Private _aFichaFin   := {}
	Private bOk          := { || IIF(!Empty(_cArqOri),_nOpc := 1, _nOpc := 0), IIF(_nOpc == 1,oDlg:End(),MsgAlert("Arquivo não escolhido!",_cRotina+"_009"))                  }
	Private bCancel      := { || oDlg:End()                              }
	Private bDir         := { || _cArqOri := Lower(AllTrim(Lower(SelDirArq()))) }
	Private _lGeraLog    := .T.

	Static oDlg

	If SRV->(FieldPos("RV_VBDPARA")) > 0
		DEFINE MSDIALOG oDlg TITLE "["+_cRotina+"] "+cTitulo FROM 000, 000  TO 220, 750 COLORS 0, 16777215 PIXEL

		    @ 004, 003 GROUP oGroup1 TO 104, 371 PROMPT " GESTÃO DE PESSOAL " OF oDlg COLOR 0, 16777215 PIXEL
		    @ 025, 010 SAY oSay1 PROMPT "Esta rotina é utilizada para a importação da ficha financeira para a Folha de Pagamento. Selecione o arquivo em formato TXT para que     " SIZE 350, 007 OF oDlg COLORS 0, 16777215 PIXEL
		    @ 038, 010 SAY oSay2 PROMPT "possa ser processado.                                                                                                                    " SIZE 350, 007 OF oDlg COLORS 0, 16777215 PIXEL
		    @ 050, 010 SAY oSay3 PROMPT "Após selecionar o arquivo, clique em confirmar.                                                                                          " SIZE 350, 007 OF oDlg COLORS 0, 16777215 PIXEL
		    DEFINE SBUTTON oSButton1 FROM 087, 237 TYPE 14 OF oDlg ENABLE  ACTION Eval(bDir   )
		    DEFINE SBUTTON oSButton2 FROM 087, 280 TYPE 01 OF oDlg ENABLE  ACTION Eval(bOk    )
		    DEFINE SBUTTON oSButton3 FROM 087, 320 TYPE 02 OF oDlg ENABLE  ACTION Eval(bCancel)

		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		MsgStop("Atenção! Crie o campo 'RV_VBDPARA' e o índice 'RV_FILIAL+RV_VBDPARA' com o NickName 'RV_VBDPARA', antes de prosseguir!",_cRotina+"_001")
		_nOpc := 0
	EndIf
	If _nOpc == 1
		ValidPerg()
		If Pergunte(cPerg,.T.) .AND. !Empty(MV_PAR02) .AND. !Empty(MV_PAR03) .AND. !Empty(MV_PAR04) .AND. !Empty(MV_PAR05) .AND. !Empty(MV_PAR06)
			_cLogTempo += "Início: "  + DTOC(Date()) + " - " + Time() + " - Arquivo: " + (_cArqOri) + _CRLF
			ProcRotIni()
			_cLogTempo += "Término: " + DTOC(Date()) + " - " + Time() + " - Arquivo: " + (_cArqOri) + _CRLF
			If !Empty(_cLogTempo)
				_cLog := "Processamento concluído!" + _CRLF + "LOG de Tempo de Processamento: " + _CRLF + _cLogTempo
				MsgInfo(_cLog, _cRotina+"_006")
				//CONOUT("["+_cRotina+"_006] "+_cLog)
			EndIf
		Else
			MsgStop("Perguntas não selecionadas da maneira correta. Processamento abortado!", _cRotina+"_002")
		EndIf
	EndIf
return
static function SelDirArq()
	Local _cTipo := "Arquivos do tipo TXT | *.TXT"
	_cArqOri     := cGetFile(_cTipo, "Selecione o arquivo a ser importado ",0,"C:\",.T.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY)
return(_cArqOri)
static function ProcRotIni()
	If !_lProc .OR. _nOpc <> 1 .OR. (!MsgYesNo("Confirma a importação do arquivo '" + _cArqOri + "' selecionado?",_cRotina+"_003"))
		MsgStop("Operação cancelada!",_cRotina+"_003")
		//CONOUT("["+_cRotina+"_003] Operação cancelada!")
		_lProc := .F.
	EndIf
	If _lProc
		SplitPath( _cArqOri, @cDrive, @cDir, @cNome, @cExt)
		Processa( { |lEnd| _lProc := ProcArq(@lEnd, (cDrive+cDir+cNome+cExt)) }, "["+_cRotina+"] "+cTitulo, "Processando arquivo " + (cDrive+cDir+cNome+cExt) + "...", .F. )
		If _lProc .AND. len(_aFichaFin) > 0 .AND. MsgYesNo("Atualiza a SRC agora com '"+cValToChar(len(_aFichaFin))+"' registros com base no arquivo de log apresentado ("+_cArqLog+")?",_cRotina+"_007")
			Processa( { |lEnd| _lProc := AtuSRC(@lEnd, (cDrive+cDir+cNome+cExt)) }, "["+_cRotina+"] "+cTitulo, "Gerando a SRC ...", .F. )
		EndIf
	EndIf
	RestArea(_aSvAr)
return(_lProc)
static function ProcArq(lEnd,_cArqTxt)
	Local   _aLinha      := {}
	Local   _cMat        := ""
	Local   _cVrb        := ""
	Local   _cLin        := ""
	Local   _nX          := 0
	Local   _nV          := 0
	Local   _nLin        := 1
	Local   _nHr         := 0
	Local   _nVal        := 0
	Private lMsErroAuto  := .F.
	Private nHandle      := 0

	Default lEnd         := .T.
	Default _cArqTxt     := ""

	_aFichaFin           := {}
	_lGeraLog            := .T.
	_nMat                := 0

	If File(_cArqLog)
		FErase(_cArqLog)
	EndIf
	MemoWrite(_cArqLog, "")
	nHandle := fOpen(_cArqLog , FO_READWRITE + FO_SHARED )
	If nHandle == -1
		MsgStop('Erro de abertura do arquivo de log ("'+_cArqLog+'"): FERROR '+str(ferror(),4),_cRotina+"_012")
		_lGeraLog := .F.
	EndIf
	If _lGeraLog
		FSeek(nHandle, 0, FS_END)         // Posiciona no fim do arquivo de log
		FWrite(nHandle, ("MATRÍCULA;VERBA DJ;VERBA PROTHEUS;DESCRIÇÃO VERBA;HORAS;VALOR;ARQUIVO"+_CRLF) , 440) // Insere texto no arquivo de log
	EndIf
	FT_FUSE(_cArqTxt)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	If !FT_FEOF()
		While !FT_FEOF() .AND. !lEnd
			IncProc('Lendo linha ' + cValToChar(_nLin) + ' do arquivo ' + _cArqTxt + '...')
			_cLin   := AllTrim(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(DecodeUTF8(NoAcento(StrTran(StrTran(FT_FREADLN(),"º","o"),"ª","a"))),'"',''), '	',' '),'F.G.T.S.','F#G#T#S#'),'.',''),',','.'),'-',''))
			If 'R E S U M O'$_cLin
				FT_FSKIP() ; _nLin++
				_cLin   := AllTrim(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(DecodeUTF8(NoAcento(StrTran(StrTran(FT_FREADLN(),"º","o"),"ª","a"))),'"',''), '	',' '),'F.G.T.S.','F#G#T#S#'),'.',''),',','.'),'-',''))
				IncProc('Lendo linha ' + cValToChar(_nLin) + ' do arquivo ' + _cArqTxt + '...')
				while !FT_FEOF() .AND. !lEnd .AND. !'Total de Empregados'$_cLin		//!'Total de Empregados Afastados'$_cLin
					_cLin   := AllTrim(StrTran(StrTran(StrTran(StrTran(StrTran(DecodeUTF8(NoAcento(StrTran(StrTran(FT_FREADLN(),"º","o"),"ª","a"))),'"',''), '	',' '),'.',''),',','.'),'-',''))
					while '  '$_cLin
						_cLin := StrTran(_cLin,'  ',' ')
					enddo
					FT_FSKIP() ; _nLin++
					IncProc('Lendo linha ' + cValToChar(_nLin) + ' do arquivo ' + _cArqTxt + '...')
				enddo
				_cMat := ""
				Loop
			//MATRÍCULA DO FUNCIONÁRIO
			ElseIf !Empty(_cLin) .AND. 'Cod:'$_cLin
				//Colho a Matrícula
				_cLin := StrTran(_cLin,' ','')
				_cMat := PadL(AllTrim(SubStr(_cLin,AT('Cod:',_cLin)+4,(AT('Nome:',_cLin)-AT('Cod:',_cLin)-4))),TamSx3('RA_MAT')[01],'0') ; _nMat++
			//VERBAS FINAIS DE BASE
			ElseIf !Empty(_cLin) .AND. '.'$_cLin .AND. !empty(_cMat) .AND.;
				   ('Base INSS Empresa:'$_cLin .OR. ;
				 	'Base INSS Funcionario:'$_cLin .OR. ;
				 	'Base INSS Func 13o Salario:'$_cLin .OR. ;
				 	'Base F#G#T#S# 13o:'$_cLin .OR. ;
				 	'Base F#G#T#S#:'$_cLin .OR. ;
				 	'F#G#T#S#:'$_cLin .OR. ;
				 	'Base IRRF:'$_cLin .OR. ;
				 	'Deducoes:'$_cLin .OR. ;
				 	'Liquido:'$_cLin)
				 	//'Proventos:'$_cLin .OR. ;
				 	//'Descontos:'$_cLin .OR. ;
			 	//Linhas Finais
			 	//Linha 1
				_cLin   := StrTran(_cLin, 'Base INSS Empresa:'           ,    '821 ; ')
				_cLin   := StrTran(_cLin, 'Base INSS Funcionario:'       , ' | 701 ; ')
				_cLin   := StrTran(_cLin, 'Base INSS Func 13o Salario:'  , ' | 705 ; ')
				//Linha 2
				_cLin   := StrTran(_cLin, 'Base F#G#T#S# 13o:'           ,    '733 ; ')
				_cLin   := StrTran(_cLin, 'Base F#G#T#S#:'               , ' | 731 ; ')
				_cLin   := StrTran(_cLin, 'F#G#T#S#:'                    , ' | 730 ; ')
				//Linha 3
				_cLin   := StrTran(_cLin, 'Base IRRF:'                   ,    '716 ; ')
				_cLin   := StrTran(_cLin, 'Deducoes:'                    , ' | 796 ; ')
				//Linha 4
			//	_cLin  := StrTran(_cLin, 'Proventos:'                    ,    '??? ; ')
			//	_cLin  := StrTran(_cLin, 'Descontos:'                    , ' | ??? ; ')
				_cLin   := StrTran(_cLin, 'Liquido:'                     , ' | 998 ; ')
			//	_cLin   := StrTran(StrTran(StrTran(_cLin,'.',''),',','.'),' ','')
				_aLinha := Separa(_cLin,'|')
				for _nX := 1 to len(_aLinha)
					If ';'$_aLinha[_nX]
						_nVal  := val(Separa(_aLinha[_nX],';')[2])
						If _nVal > 0
							_nHr   := 0
							_cVrb  := AllTrim(Separa(_aLinha[_nX],';')[1])
							dbSelectArea("SRV")
							If !Empty(_cVrb)
								SRV->(dbSetOrder(1))
								If SRV->(MsSeek(xFilial("SRV") + _cVrb, .T., .F.))
									_cCVerba := SRV->RV_COD
									_cDVerba := SRV->RV_DESC
								Else
									SRV->(dbOrderNickName("RV_VBDPARA"))
									If SRV->(MsSeek(xFilial("SRV") + _cVrb, .T., .F.)) .AND. !Empty(SRV->RV_VBDPARA)
										_cCVerba := SRV->RV_COD
										_cDVerba := SRV->RV_DESC
									EndIf
								EndIf
							Else
								_cCVerba := ""
								_cDVerba := "VERBA NAO ENCONTRADA!"
							EndIf
							AADD(_aFichaFin,{_cMat, _cVrb, _nHr, _nVal,_cCVerba,_cDVerba})
							If _lGeraLog
								FSeek(nHandle, 0, FS_END)         // Posiciona no fim do arquivo de log
								FWrite(nHandle, (	_aFichaFin[len(_aFichaFin)][01]+";"+;
													_aFichaFin[len(_aFichaFin)][02]+";"+;
													_aFichaFin[len(_aFichaFin)][05]+";"+;
													_aFichaFin[len(_aFichaFin)][06]+";"+;
													Transform(_aFichaFin[len(_aFichaFin)][03],"@E 999,999,999.99")+";"+;
													Transform(_aFichaFin[len(_aFichaFin)][04],"@E 999,999,999.99")+";"+;
													_cArqTxt+_CRLF) ;
											  , 440) // Insere texto no arquivo de log
							EndIf
						EndIf
					EndIf
				next
			//VERBAS NORMAIS
			ElseIf !Empty(_cLin) .AND. '.'$_cLin .AND. !empty(_cMat) .AND. SubStr(_cLin,1,1)$'0123456789'
				while '  '$_cLin
					_cLin := StrTran(_cLin,'  ',' ')
				enddo
				_cLin   := AllTrim(_cLin)
				_aLinha := Separa(_cLin,' ')
				_cVrb   := ''
				_nHr    := 0
				_nVal   := 0
				for _nV := 1 to len(_aLinha)
					If val(_aLinha[_nV]) > 0 .AND. !'o'$_aLinha[_nV] .AND. !'a'$_aLinha[_nV] .AND. !'/'$_aLinha[_nV] .AND. !'%'$_aLinha[_nV]
						If Empty(_cVrb) .AND. _nVal == 0 .AND. !'.'$_aLinha[_nV]
							_cVrb := StrZero(val(_aLinha[_nV]),4)	//_aLinha[_nV]
						Else
							If '.'$_aLinha[_nV]
								//Só pode ser valor (pode ser que esteja concatenado a alguma verba)
								If len(SubStr(_aLinha[_nV],AT('.',_aLinha[_nV])+1,len(_aLinha[_nV])-AT('.',_aLinha[_nV])+1)) == 2	//Se tiver apenas 2decimais, é só valor. Caso contrário, está concatenado com a próxima verba
									//Verifico se o próximo registro é valor (com separador de decimal) ou não
									If _nHr == 0 .AND. _nV < len(_aLinha) .AND. _nV+1 <= len(_aLinha) .AND. '.'$_aLinha[_nV+1] .AND. val(_aLinha[_nV+1]) > 0 .AND. !'o'$_aLinha[_nV+1] .AND. !'a'$_aLinha[_nV+1] .AND. !'/'$_aLinha[_nV+1] .AND. !'%'$_aLinha[_nV+1]
										_nHr    := val(_aLinha[_nV])
									Else
										_nVal   := val(_aLinha[_nV])
										dbSelectArea("SRV")
										SRV->(dbOrderNickName("RV_VBDPARA"))
										If !Empty(_cVrb) .AND. SRV->(MsSeek(xFilial("SRV") + _cVrb, .T., .F.)) .AND. !Empty(SRV->RV_VBDPARA)
											_cCVerba := SRV->RV_COD
											_cDVerba := SRV->RV_DESC
										Else
											_cCVerba := ""
											_cDVerba := "VERBA NAO ENCONTRADA!"
										EndIf
										AADD(_aFichaFin,{_cMat, _cVrb, _nHr, _nVal,_cCVerba,_cDVerba})
										If _lGeraLog
											FSeek(nHandle, 0, FS_END)         // Posiciona no fim do arquivo de log
											FWrite(nHandle, (	_aFichaFin[len(_aFichaFin)][01]+";"+;
																_aFichaFin[len(_aFichaFin)][02]+";"+;
																_aFichaFin[len(_aFichaFin)][05]+";"+;
																_aFichaFin[len(_aFichaFin)][06]+";"+;
																Transform(_aFichaFin[len(_aFichaFin)][03],"@E 999,999,999.99")+";"+;
																Transform(_aFichaFin[len(_aFichaFin)][04],"@E 999,999,999.99")+";"+;
																_cArqTxt+_CRLF) ;
														  , 440) // Insere texto no arquivo de log
										EndIf
										_cVrb := ''
										_nHr  := 0
										_nVal := 0
									EndIf
								Else	//Casos onde a verba da segunda coluna está concatenada ao valor da primeira coluna
									_nVal := val(SubStr(_aLinha[_nV],AT('.',_aLinha[_nV])+1,2))
									dbSelectArea("SRV")
									SRV->(dbOrderNickName("RV_VBDPARA"))
									If !Empty(_cVrb) .AND. SRV->(MsSeek(xFilial("SRV") + _cVrb, .T., .F.)) .AND. !Empty(SRV->RV_VBDPARA)
										_cCVerba := SRV->RV_COD
										_cDVerba := SRV->RV_DESC
									Else
										_cCVerba := ""
										_cDVerba := "VERBA NAO ENCONTRADA!"
									EndIf
									AADD(_aFichaFin,{_cMat, _cVrb, _nHr, _nVal, _cCVerba, _cDVerba})
									If _lGeraLog
										FSeek(nHandle, 0, FS_END)         // Posiciona no fim do arquivo de log
										FWrite(nHandle, (	_aFichaFin[len(_aFichaFin)][01]+";"+;
															_aFichaFin[len(_aFichaFin)][02]+";"+;
															_aFichaFin[len(_aFichaFin)][05]+";"+;
															_aFichaFin[len(_aFichaFin)][06]+";"+;
															Transform(_aFichaFin[len(_aFichaFin)][03],"@E 999,999,999.99")+";"+;
															Transform(_aFichaFin[len(_aFichaFin)][04],"@E 999,999,999.99")+";"+;
															_cArqTxt+_CRLF) ;
													  , 440) // Insere texto no arquivo de log
									EndIf
									//Colho a verba da segunda coluna, que estava concatenada com a informação de valor da primeira coluna
									_cVrb := StrZero(val(SubStr(_aLinha[_nV],AT('.',_aLinha[_nV])+1+2)),4) //SubStr(_aLinha[_nV],AT('.',_aLinha[_nV])+1+2)
									_nHr  := 0
									_nVal := 0
								EndIf
							Else
								//Só pode ser lixo - estamos desconsiderando
							EndIf
						EndIf
					EndIf
				next
			EndIf
			FT_FSKIP() ; _nLin++
		EndDo
	Else
		_lProc := .F.
		MsgStop("Arquivo " + _cArqTxt + " vazio. Nada a importar!",_cRotina+"_005")
		//CONOUT("["+_cRotina+"_005] Arquivo " + _cArqTxt + " vazio. Nada a importar!")
	EndIf
	FT_FUSE()
	//MemoWrite(GetTempPath()+_cRotina+"_Ficha_Financeira1.Txt", VarInfo(">>> Matriz _aFichaFin populada: ",_aFichaFin            ,,.T.,.F.))
	//MemoWrite(GetTempPath()+_cRotina+"_Ficha_Financeira2.Txt", VarInfo(">>> Matriz _aFichaFin populada: ",TxtlNoTags(_aFichaFin),,.T.,.F.))
	////CONOUT("["+_cRotina+"_010] Conteúdo da matriz da Ficha Financeira: " + _CRLF + _CRLF + VarInfo(">>> Matriz _aFichaFin populada: ",TxtlNoTags(_aFichaFin),,.T.,.F.))
	fClose(nHandle)                   // Fecha arquivo de log
	If _lGeraLog
		MsgInfo("Foram processadas "+cValToChar(_nMat)+" matrículas em "+cValToChar(_nLin)+" linhas do arquivo, sendo gerados "+cValToChar(len(_aFichaFin))+" registros. Verifique o arquivo de log a seguir: "+_cArqLog,_cRotina+"_017")
		shellExecute( "Open", _cArqLog, "",GetTempPath(), 1 )
	EndIf
return(_lProc)
static function AtuSRC(lEnd,_cArqTxt)
	Local   _lRet     := .T.
	Local   _lIncl    := .T.
	Local   _lMsgG    := .T.
	Local   _nX       := 0
	Local   _nProc    := 0
	Local   _nPos     := 0
	Local   _nSeq     := 0
	Local   nHandle   := 0
	Local   _aMat     := {}
	Local   _cArqErro := GetTempPath()+_cRotina+"_Erros_"+DTOS(Date())+"_"+StrTran(Time(),":","")+".csv"

	default _cArqTxt  := ""

	_lGeraLog         := .T.

	If File(_cArqErro)
		FErase(_cArqErro)
	EndIf
	MemoWrite(_cArqErro, "")
	nHandle := fOpen(_cArqErro , FO_READWRITE + FO_SHARED )
	If nHandle == -1
		MsgStop('Erro de abertura do arquivo de log ("'+_cArqErro+'"): FERROR '+str(ferror(),4),_cRotina+"_013")
		_lGeraLog := .F.
	EndIf
	If _lGeraLog
		FSeek(nHandle, 0, FS_END)         // Posiciona no fim do arquivo de log
		FWrite(nHandle, ("MATRÍCULA;VERBA DJ;VERBA PROTHEUS;DESCRIÇÃO VERBA;HORAS;VALOR;LOG;ARQUIVO"+_CRLF) , 440) // Insere texto no arquivo de log
	EndIf
	ProcRegua(len(_aFichaFin))
	for _nX := 1 to len(_aFichaFin)
		IncProc("Processando registro "+cValToChar(_nX)+"...")
		dbSelectArea("SRA")
		SRA->(dbSetOrder(1))
		If SRA->(MsSeek(xFilial("SRA") + _aFichaFin[_nX][01], .T., .F.))
			_nPos := aScan(_aMat,{|x| x[1] == _aFichaFin[_nX][01]})
			If _nPos == 0
				AADD(_aMat, {_aFichaFin[_nX][01], 1})
				_nPos := len(_aMat)
			Else
				_aMat[_nPos][02] := _aMat[_nPos][02] + 1
			EndIf
			dbSelectArea("SRV")
			//SRV->(dbOrderNickName("RV_VBDPARA"))
			//If !Empty(_aFichaFin[_nX][02]) .AND. SRV->(MsSeek(xFilial("SRV") + _aFichaFin[_nX][02], .T., .F.)) .AND. !Empty(SRV->RV_VBDPARA)
			SRV->(dbSetOrder(1))
			If !Empty(_aFichaFin[_nX][05]) .AND. SRV->(MsSeek(xFilial("SRV") + _aFichaFin[_nX][05], .T., .F.))
				dbSelectArea("SRC")
				SRC->(dbSetOrder(1))
				//_lIncl := !SRC->(dbSeek(xFilial("SRC") + SRA->RA_MAT + SRV->RV_COD + SRA->RA_CC))
				_lIncl := !SRC->(dbSeek(xFilial("SRC") + SRA->RA_MAT + SRV->RV_COD))
				//If _lMsgG .AND. !MsgYesNo("As seguintes informações serão "+iif(_lIncl,"INCLUÍDAS.","ALTERADAS (RECNO '"+cValToChar(SRC->(Recno()))+"').")+" Continua apresentando esta mensagem para os próximos registros?"+_CRLF+;
				If _lIncl
					_nSeq := 0
				Else
					_nSeq := CONTAR("SRC","RC_FILIAL == '" + xFilial("SRC") + "' .AND. RC_MAT == '" + SRA->RA_MAT + "' .AND. RC_PD == '" + SRV->RV_COD + "' ")
				EndIf
				_nSeq++
				If _lMsgG .AND. !MsgYesNo("As seguintes informações serão INCLUÍDAS. Continua apresentando esta mensagem para os próximos registros?"+_CRLF+;
											"SRC->RC_FILIAL      := "+xFilial("SRC") + _CRLF + ;
											"SRC->RC_MAT         := "+SRA->RA_MAT + _CRLF + ;
											"SRC->RC_PD          := "+SRV->RV_COD + _CRLF + ;
											"SRC->RC_TIPO1       := "+SRV->RV_TIPO + _CRLF + ;
											"SRC->RC_SEQ         := "+IIF(_nSeq>1,cValToChar(_nSeq),"") + _CRLF + ;
											"SRC->RC_HORAS       := "+cValToChar(_aFichaFin[_nX][03]) + _CRLF + ;
											"SRC->RC_VALOR       := "+cValToChar(_aFichaFin[_nX][04]) + _CRLF + ;
											"SRC->RC_DATA        := "+DTOC(MV_PAR06) + _CRLF + ;
											"SRC->RC_DTREF       := "+DTOC(LASTDAY(STOD(MV_PAR04+MV_PAR05+"01"), 0)) + _CRLF + ;
											"SRC->RC_SEMANA      := "+MV_PAR01 + _CRLF + ;
											"SRC->RC_CC          := "+SRA->RA_CC + _CRLF + ;
											"SRC->RC_TIPO2       := "+"G" + _CRLF + ;
											"SRC->RC_PROCES      := "+MV_PAR02 + _CRLF + ;
											"SRC->RC_PERIODO     := "+MV_PAR04+MV_PAR05 + _CRLF + ;
											"SRC->RC_ROTEIR      := "+MV_PAR03 + _CRLF + ;
											"SRC->RC_CODB1T      := "+cValToChar(_aMat[_nPos][02]) + _CRLF + ;   
											"SRC->RC_VALORBA     := "+cValToChar(SRA->RA_SALARIO) + _CRLF + ;
											"SRC->RC_DEPTO       := "+SRA->RA_DEPTO + _CRLF )
					_lMsgG := .F.
				EndIf
				while !RecLock("SRC",.T.) ; enddo
					SRC->RC_FILIAL      := xFilial("SRC") 
					SRC->RC_MAT         := SRA->RA_MAT
					SRC->RC_PD          := SRV->RV_COD
					SRC->RC_TIPO1       := SRV->RV_TIPO
					SRC->RC_SEQ         := IIF(_nSeq>1,cValToChar(_nSeq),"")
				//	SRC->RC_HORAS       := _aFichaFin[_nX][03] + IIF(!_lIncl,SRC->RC_HORAS,0)
				//	SRC->RC_VALOR       := _aFichaFin[_nX][04] + IIF(!_lIncl,SRC->RC_VALOR,0)
					SRC->RC_HORAS       := _aFichaFin[_nX][03]
					SRC->RC_VALOR       := _aFichaFin[_nX][04]
					SRC->RC_DATA        := MV_PAR06
					SRC->RC_DTREF       := LASTDAY(STOD(MV_PAR04+MV_PAR05+"01"), 0)
					SRC->RC_SEMANA      := MV_PAR01
					SRC->RC_CC          := SRA->RA_CC
					SRC->RC_TIPO2       := "G"
					SRC->RC_PROCES      := MV_PAR02
					SRC->RC_PERIODO     := MV_PAR04+MV_PAR05
					SRC->RC_ROTEIR      := MV_PAR03
					SRC->RC_CODB1T      := cValToChar(_aMat[_nPos][02])   
					SRC->RC_VALORBA     := SRA->RA_SALARIO
					SRC->RC_DEPTO       := SRA->RA_DEPTO
				SRC->(MSUNLOCK())
				SRC->(dbUnLock())
				_nProc++
			Else
				If _lGeraLog
					FSeek(nHandle, 0, FS_END)         // Posiciona no fim do arquivo de log
					FWrite(nHandle, (	_aFichaFin[_nX][01]+";"+;
										_aFichaFin[_nX][02]+";"+;
										_aFichaFin[_nX][05]+";"+;
										_aFichaFin[_nX][06]+";"+;
										Transform(_aFichaFin[_nX][03],"@E 999,999,999.99")+";"+;
										Transform(_aFichaFin[_nX][04],"@E 999,999,999.99")+";"+;
										">>> VERBA NAO ENCONTRADA!"+";"+;
										_cArqTxt+_CRLF ;
									 ) , 440) // Insere texto no arquivo de log
				EndIf
			EndIf
		Else
			If _lGeraLog
				FSeek(nHandle, 0, FS_END)         // Posiciona no fim do arquivo de log
				FWrite(nHandle, (	_aFichaFin[_nX][01]+";"+;
									_aFichaFin[_nX][02]+";"+;
									_aFichaFin[_nX][05]+";"+;
									_aFichaFin[_nX][06]+";"+;
									Transform(_aFichaFin[_nX][03],"@E 999,999,999.99")+";"+;
									Transform(_aFichaFin[_nX][04],"@E 999,999,999.99")+";"+;
									">>> FUNCIONARIO NAO ENCONTRADO!"+";"+;
									_cArqTxt+_CRLF ;
								 ) , 440) // Insere texto no arquivo de log
			EndIf
		EndIf
	next
	MsgInfo("Processamento finalizado! De '"+cValToChar(len(_aFichaFin))+"' registros, '"+cValToChar(_nProc)+"' foram processados com sucesso, sendo apresentados problemas em '"+cValToChar(len(_aFichaFin)-_nProc)+"' registros."+_CRLF+" Será aberto um aquivo no bloco de notas, demonstrando as verbas DJ que apresentaram problemas para que possa analisar.",_cRotina+"_008")
	//If len(_aVerba) > 0
		//MemoWrite(GetTempPath()+_cRotina+"_Verbas_com_Problemas1.Txt", VarInfo(">>> Matriz _aFichaFin populada: ",_aVerba            ,,.T.,.F.))
		//MemoWrite(GetTempPath()+_cRotina+"_Verbas_com_Problemas2.Txt", VarInfo(">>> Matriz _aFichaFin populada: ",TxtlNoTags(_aVerba),,.T.,.F.))
		//shellExecute( "Open", GetTempPath()+_cRotina+"_Verbas_com_Problemas1.Txt", "",GetTempPath(), 1 )
		//%windir%\system32\notepad.exe
		//shellExecute( "Open", "C:\Windows\System32\notepad.exe", _cRotina+"_Verbas_com_Problemas1.Txt", GetTempPath(), 1 )
		//shellExecute( "Open", "C:\Windows\System32\notepad.exe", _cRotina+"_Verbas_com_Problemas2.Txt", GetTempPath(), 1 )
	//EndIf
	fClose(nHandle)                   // Fecha arquivo de log
	If _lGeraLog
		shellExecute( "Open", _cArqErro, "",GetTempPath(), 1 )
	EndIf
return _lRet
/*/{Protheus.doc} ValidPerg
@description Função responsável pela inclusão de parâmetros na rotina.
@author Anderson C. P. Coelho (ALL SYSTEM SOLUTIONS)
@since 18/01/2016
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	Local _sAlias := GetArea()
	Local aRegs   := {}
	Local _aTam   := {}
	Local i       := 0
	Local j       := 0

	_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))

	cPerg := PADR(cPerg,len((_cAliasSX1)->X1_GRUPO))
	_aTam := TamSx3("RC_SEMANA")
	AADD(aRegs,{cPerg,"01","Semana?" 	  		    ,"","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par01",""     ,"","","","",""       ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
	_aTam := TamSx3("RC_PROCES")
	AADD(aRegs,{cPerg,"02","Processo?" 	  		    ,"","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","NaoVazio()","mv_par02",""     ,"","","","",""       ,"","","","","","","","","","","","","","","","","","","RCJ","",""})
	_aTam := TamSx3("RC_ROTEIR")
	AADD(aRegs,{cPerg,"03","Roteiro de Cálculo?"    ,"","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G","NaoVazio()","mv_par03",""     ,"","","","",""       ,"","","","","","","","","","","","","","","","","","","SRY","",""})
	_aTam := {04,00,"C"}
	AADD(aRegs,{cPerg,"04","Ano?"                   ,"","","mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G","NaoVazio()","mv_par04",""     ,"","","","",""       ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
	_aTam := {02,00,"C"}
	AADD(aRegs,{cPerg,"05","Mês?"                   ,"","","mv_ch5",_aTam[03],_aTam[01],_aTam[02],0,"G","NaoVazio()","mv_par05",""     ,"","","","",""       ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
	_aTam := {08,00,"D"}
	AADD(aRegs,{cPerg,"06","Data de Pagamento?"     ,"","","mv_ch6",_aTam[03],_aTam[01],_aTam[02],0,"G","NaoVazio()","mv_par06",""     ,"","","","",""       ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
	For i := 1 To Len(aRegs)
		If !(_cAliasSX1)->(dbSeek(cPerg+aRegs[i,2]))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				For j := 1 To FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					Else
						Exit
					EndIf
				Next
			(_cAliasSX1)->(MsUnLock())
		EndIf
	Next
	RestArea(_sAlias)
return