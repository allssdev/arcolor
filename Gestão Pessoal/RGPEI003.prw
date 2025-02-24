#include 'rwmake.ch'
#include 'protheus.ch'
#include "tbiconn.ch"
#include "shell.ch"
#include "parmtype.ch"
#include "fileio.ch"
#define _CRLF CHR(13) + CHR(10)
/*/{Protheus.doc} RGPEI003
@description Rotina de importação do Dissidio Retroativo do escritório contábil DJ para a tabela RHH (via RecLock).
@author Rodrigo Telecio (ALLSS - rodrigo.telecio@allss.com.br)
@since 17/09/2019
@version 1.00 (P12.1.17)
@type Function
@param nulo, Nil, nenhum 
@return nulo, Nil	
@obs O arquivo que nos foi enviado foi no formato PDF, sendo impossível a sua importação. Para obtermos êxito, convertemos o arquivo para o formato XLS (via URL "https://www.aconvert.com/pdf/pdf-to-xml/"). Depois, por meio do Excel (Office 365), o arquivo foi convertido para TXT. Estes procedimentos sejam gerados exatamente desta forma.
@see https://allss.com.br 
@history 17/09/2019, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Disponibilização da rotina para uso.
@history 24/09/2019, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Alterações pontuais para atendimento ao IR RRA.
/*/
user function RGPEI003()
	Local oGroup1
	Local oSay1
	Local oSay3
	Local oSButton1
	Local oSButton2
	Local oSButton3
	Local _cLog          := ""
	Local _cLogTempo     := ""
	Private cDrive, cDir, cNome, cExt
	Private _cRotina     := "RGPEI003"
	Private cPerg        := _cRotina
	Private _cArqLog     := GetTempPath()+_cRotina+"_Dissidio retroativo_"+DTOS(Date())+"_"+StrTran(Time(),":","")+".csv"
	Private cTitulo      := "Importação do Dissídio Retroativo (TXT)"
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
	If SRV->(FieldPos("RV_VBDPDIS")) > 0
		DEFINE MSDIALOG oDlg TITLE "["+_cRotina+"] "+cTitulo FROM 000, 000  TO 220, 750 COLORS 0, 16777215 PIXEL
		    @ 004, 003 GROUP oGroup1 TO 104, 371 PROMPT " GESTÃO DE PESSOAL " OF oDlg COLOR 0, 16777215 PIXEL
		    @ 025, 010 SAY oSay1 PROMPT "Esta rotina é utilizada para a importação do dissidio retroativo. Selecione o arquivo em formato TXT para que possa ser processado.	  " SIZE 350, 007 OF oDlg COLORS 0, 16777215 PIXEL
		    @ 050, 010 SAY oSay3 PROMPT "Após selecionar o arquivo, clique em OK para iniciar o processo.                                                                         " SIZE 350, 007 OF oDlg COLORS 0, 16777215 PIXEL
		    DEFINE SBUTTON oSButton1 FROM 087, 237 TYPE 14 OF oDlg ENABLE  ACTION Eval(bDir   )
		    DEFINE SBUTTON oSButton2 FROM 087, 280 TYPE 01 OF oDlg ENABLE  ACTION Eval(bOk    )
		    DEFINE SBUTTON oSButton3 FROM 087, 320 TYPE 02 OF oDlg ENABLE  ACTION Eval(bCancel)

		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		MsgStop("Atenção! Crie o campo 'RV_VBDPDIS' e o índice 'RV_FILIAL+RV_VBDPDIS' com o NickName 'RV_VBDPDIS', antes de prosseguir!",_cRotina+"_001")
		_nOpc := 0
	EndIf
	If _nOpc == 1
		ValidPerg()
		If Pergunte(cPerg,.T.) .AND. !Empty(MV_PAR01) .AND. !Empty(MV_PAR02) .AND. !Empty(MV_PAR03) .AND. !Empty(MV_PAR04) .AND. !Empty(MV_PAR05) .AND. !Empty(MV_PAR06) .AND. !Empty(MV_PAR07) .AND. !Empty(MV_PAR08) .AND. !Empty(MV_PAR09) .AND. !Empty(MV_PAR10) .AND. !Empty(MV_PAR11)    
			_cLogTempo += "Início: "  + DTOC(Date()) + " - " + Time() + " - Arquivo: " + (_cArqOri) + _CRLF
			ProcRotIni()
			_cLogTempo += "Término: " + DTOC(Date()) + " - " + Time() + " - Arquivo: " + (_cArqOri) + _CRLF
			If !Empty(_cLogTempo)
				_cLog := "Processamento concluído!" + _CRLF + "LOG de Tempo de Processamento: " + _CRLF + _cLogTempo
				MsgInfo(_cLog, _cRotina+"_006")
			EndIf
		Else
			MsgStop("Perguntas não selecionadas da maneira correta. Processamento abortado!", _cRotina+"_002")
		EndIf
	EndIf
return
/*/{Protheus.doc} SelDirArq
@description Função responsável pela seleção do arquivo a ser processado pela rotina.
@author Anderson C. P. Coelho (ALLSS - anderson.coelho@allss.com.br)
@since 17/09/2019
@version 1.0
@type function
@see https://allss.com.br
/*/
static function SelDirArq()
	Local _cTipo := "Arquivos do tipo TXT | *.TXT"
	_cArqOri     := cGetFile(_cTipo, "Selecione o arquivo a ser importado ",0,"C:\",.T.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY)
return(_cArqOri)
/*/{Protheus.doc} ProcRotIni
@description Função responsável pelo questionamento ao usuário se, após a geração do arquivo de conferencia, serão gravados os registros no Protheus.
@author Anderson C. P. Coelho (ALLSS - anderson.coelho@allss.com.br)
@since 17/09/2019
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ProcRotIni()
	If !_lProc .OR. _nOpc <> 1 .OR. (!MsgYesNo("Confirma a importação do arquivo '" + _cArqOri + "' selecionado?",_cRotina+"_003"))
		MsgStop("Operação cancelada!",_cRotina+"_003")
		_lProc := .F.
	EndIf
	If _lProc
		SplitPath( _cArqOri, @cDrive, @cDir, @cNome, @cExt)
		Processa( { |lEnd| _lProc := ProcArq(@lEnd, (cDrive+cDir+cNome+cExt)) }, "["+_cRotina+"] "+cTitulo, "Processando arquivo " + (cDrive+cDir+cNome+cExt) + "...", .F. )
		If _lProc .AND. len(_aFichaFin) > 0 .AND. MsgYesNo("Atualiza a RHH agora com '"+cValToChar(len(_aFichaFin))+"' registros com base no arquivo de log apresentado ("+_cArqLog+")?",_cRotina+"_007")
			Processa( { |lEnd| _lProc := AtuRHH(@lEnd, (cDrive+cDir+cNome+cExt)) }, "["+_cRotina+"] "+cTitulo, "Gerando a RHH ...", .F. )
		EndIf
	EndIf
	RestArea(_aSvAr)
return(_lProc)
/*/{Protheus.doc} ProcArq
@description Função responsável pela leitura, interpretação e montagem de arquivo ".csv" do processamento executado, para conferencia das informações antes da efetiva importação.
@author Anderson C. P. Coelho (ALLSS - anderson.coelho@allss.com.br)
@since 17/09/2019
@version 1.0
@type function
@see https://allss.com.br
/*/
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
				_cLin   := StrTran(_cLin, 'Liquido:'                     , ' | 998 ; ')
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
									SRV->(dbOrderNickName("RV_VBDPDIS"))
									If SRV->(MsSeek(xFilial("SRV") + _cVrb, .T., .F.)) .AND. !Empty(SRV->RV_VBDPDIS)
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
										SRV->(dbOrderNickName("RV_VBDPDIS"))
										If !Empty(_cVrb) .AND. SRV->(MsSeek(xFilial("SRV") + _cVrb, .T., .F.)) .AND. !Empty(SRV->RV_VBDPDIS)
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
									SRV->(dbOrderNickName("RV_VBDPDIS"))
									If !Empty(_cVrb) .AND. SRV->(MsSeek(xFilial("SRV") + _cVrb, .T., .F.)) .AND. !Empty(SRV->RV_VBDPDIS)
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
	EndIf
	FT_FUSE()
	fClose(nHandle)                   // Fecha arquivo de log
	If _lGeraLog
		MsgInfo("Foram processadas "+cValToChar(_nMat)+" matrículas em "+cValToChar(_nLin)+" linhas do arquivo, sendo gerados "+cValToChar(len(_aFichaFin))+" registros. Verifique o arquivo de log a seguir: "+_cArqLog,_cRotina+"_017")
		shellExecute( "Open", _cArqLog, "",GetTempPath(), 1 )
	EndIf
return(_lProc)
/*/{Protheus.doc} AtuRHH
@description Função responsável pela inclusão de parâmetros na rotina.
@author Rodrigo Telecio (ALLSS - rodrigo.telecio@allss.com.br)
@since 17/09/2019
@version 1.0
@type function
@see https://allss.com.br
/*/
static function AtuRHH(lEnd,_cArqTxt)
	Local   _lRet     := .T.
	Local   _nX       := 0
	Local   _nProc    := 0
	Local   _nPos     := 0
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
	if len(_aFichaFin) > 0
		//*****************************************************************
		//Deletamos os registros, para manter apenas aquilo que está sendo 
		//implementado por meio do arquivo processado
		//*****************************************************************
		//INFORMAÇÕES DO DISSIDIO RETROATIVO
		cQuery := "DELETE FROM 								" 
		cQuery += 		RetSqlName("RHH") + "				" 
		cQuery += "WHERE									" 
		cQuery += "		D_E_L_E_T_ = '' 					"
		cQuery += "		AND RHH_MESANO = '" + mv_par03 + "' "
		cQuery += "		AND RHH_DATA   = '" + mv_par01 + "' "
		cQuery += "		AND RHH_PROCES = '" + mv_par04 + "' "
		cQuery += "		AND RHH_ROTEIR = '" + mv_par05 + "'	"
		cQuery += "		AND RHH_TPOAUM = '" + mv_par02 + "' "
		TCSQlExec(cQuery)
		//INFORMAÇÕES DO IR RRA
		//cQuery := "DELETE FROM							"
		//cQuery += 	RetSqlName("RFC") + "				"
		//cQuery += "WHERE									"
		//cQuery += "	D_E_L_E_T_ = ''						"
		//cQuery += "	AND RFC_DATARQ = '" + mv_par03 + "' "
		//cQuery += "	AND RFC_IDCMPL = '" + mv_par12 + "' "
		//TCSQlExec(cQuery) 	
	endif
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
			SRV->(dbSetOrder(1))
			If !Empty(_aFichaFin[_nX][05]) .AND. SRV->(MsSeek(xFilial("SRV") + _aFichaFin[_nX][05], .T., .F.))
				dbSelectArea("RHH")
				RHH->(dbSetOrder(1))
				//*****************************************************************
				//Tratamos a gravação do registro que será utilizado como referencia 
				//para posterior gravação do histórico salarial
				//*****************************************************************				
				if alltrim(_aFichaFin[_nX][05]) == "002"
					while !RecLock("RHH",.T.) ; enddo
						RHH->RHH_FILIAL		:= xFilial("RHH")
						RHH->RHH_MAT		:= SRA->RA_MAT
						RHH->RHH_CC			:= SRA->RA_CC
						RHH->RHH_VB			:= "000"
						RHH->RHH_VL			:= SRA->RA_SALARIO
						RHH->RHH_DATA		:= mv_par01
						RHH->RHH_VERBA		:= ""
						RHH->RHH_CALC		:= SRA->RA_SALARIO + _aFichaFin[_nX][04] 
						RHH->RHH_VALOR		:= _aFichaFin[_nX][04]
						if SRA->RA_SALARIO > mv_par08
							RHH->RHH_VLRAUM		:= mv_par09
						else
							RHH->RHH_INDICE		:= mv_par07
						endif
						RHH->RHH_TPOAUM		:= mv_par02
						RHH->RHH_COMPL_		:= "N"
						RHH->RHH_SEMANA		:= mv_par06
						RHH->RHH_MESANO		:= mv_par03
						RHH->RHH_TIPO1		:= ""
						RHH->RHH_TIPO2		:= ""
						RHH->RHH_HORAS		:= 0
						RHH->RHH_IDCMPL		:= mv_par12
						RHH->RHH_SINDIC		:= SRA->RA_SINDICA
						RHH->RHH_DTACOR		:= mv_par10
						RHH->RHH_PROCES		:= mv_par04
						RHH->RHH_ROTEIR		:= mv_par05
						RHH->(MsUnlock())				
						RHH->(dbUnLock())						
				endif
				//*****************************************************************
				//Tratamos a gravação do registro para que não sejam gravados  
				//registros de liquidos, por exemplo
				//*****************************************************************				
				if !alltrim(_aFichaFin[_nX][05]) $ "998/936"
					while !RecLock("RHH",.T.) ; enddo
						RHH->RHH_FILIAL		:= xFilial("RHH")
						RHH->RHH_MAT		:= SRA->RA_MAT
						RHH->RHH_CC			:= SRA->RA_CC
						RHH->RHH_VB			:= SRV->RV_COD
						RHH->RHH_VL			:= 0
						RHH->RHH_DATA		:= mv_par01
						RHH->RHH_VERBA		:= SRV->RV_CODCOM_
						RHH->RHH_CALC		:= 0
						RHH->RHH_VALOR		:= _aFichaFin[_nX][04]
						RHH->RHH_TPOAUM		:= mv_par02
						RHH->RHH_COMPL_		:= "S"
						RHH->RHH_SEMANA		:= mv_par06
						RHH->RHH_MESANO		:= mv_par03
						RHH->RHH_TIPO1		:= SRV->RV_TIPO
						RHH->RHH_TIPO2		:= "G"
						RHH->RHH_HORAS		:= _aFichaFin[_nX][03]
						RHH->RHH_DTPGT		:= mv_par11
						RHH->RHH_IDCMPL		:= mv_par12
						RHH->RHH_RRA		:= "0"
						RHH->RHH_PROCES		:= mv_par04
						RHH->RHH_ROTEIR		:= mv_par05
						RHH->(MsUnlock())				
						RHH->(dbUnLock())
						//_nProc++
				endif
				//*****************************************************************
				//Tratamos a gravação das informações referentes ao IR diretamente  
				//na tabela "RFC - Sintética RRA"
				//*****************************************************************				
				if alltrim(_aFichaFin[_nX][05]) $ "410/414/716"
					cVerba := iif(alltrim(_aFichaFin[_nX][05]) $ "410/414", "978", iif(alltrim(_aFichaFin[_nX][05]) == "716", "974", "000"))
					dbSelectArea("RCH")
					RCH->(dbSetOrder(9))
					RCH->(dbSeek(xFilial("RCH") + mv_par03 + "01" + mv_par04 + mv_par05))
					dbSelectArea("RFC")
					RFC->(dbSetOrder(3))
					if !RFC->(dbSeek(xFilial("RCF") + SRA->RA_MAT + mv_par12 + cVerba + SRA->RA_CC + mv_par03 + "1"))
							while !RecLock("RFC",.T.) ; enddo
								RFC->RFC_FILIAL		:= xFilial("RFC")
								RFC->RFC_MAT		:= SRA->RA_MAT
								RFC->RFC_DATPGT		:= RCH->RCH_DTPAGO
								RFC->RFC_DATARQ		:= mv_par03
								RFC->RFC_PD			:= cVerba 
								RFC->RFC_CC			:= SRA->RA_CC
								RFC->RFC_SEQ		:= "1"
								RFC->RFC_EMPRES		:= FWCodEmp()
								RFC->RFC_DEPTO		:= SRA->RA_DEPTO
								RFC->RFC_PARC		:= 1
								RFC->RFC_MESES		:= 1
								RFC->RFC_VALOR		:= _aFichaFin[_nX][04]
								RFC->RFC_IDCMPL		:= mv_par12
								RFC->RFC_RRA		:= "1"
								RFC->(MsUnlock())				
								RFC->(dbUnLock())
					else
						if cVerba == "974"
							while !RecLock("RFC",.F.) ; enddo
								RFC->RFC_MESES		+= 1
								RFC->RFC_VALOR		:= _aFichaFin[_nX][04]
								RFC->(MsUnlock())				
								RFC->(dbUnLock())
						elseIf cVerba == "978"
							while !RecLock("RFC",.F.) ; enddo
								RFC->RFC_MESES		+= 1
								RFC->RFC_VALOR		+= _aFichaFin[_nX][04]
								RFC->(MsUnlock())				
								RFC->(dbUnLock())						
						endif
					endif				
				endif
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
	fClose(nHandle)                   // Fecha arquivo de log
	If _lGeraLog
		shellExecute( "Open", _cArqErro, "",GetTempPath(), 1 )
	EndIf
return _lRet
/*/{Protheus.doc} ValidPerg
@description Função responsável pela inclusão de parâmetros na rotina.
@author Rodrigo Telecio (ALLSS - rodrigo.telecio@allss.com.br)
@since 17/09/2019
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
Local aAlias 	:= GetArea()
Local aRegs   	:= {}
Local aRet		:= {}
Local i,j
aRet := TamSX3("RHH_DATA")
AAdd(aRegs,{cPerg,"01","Comp.Retroativa (AAAAMM)?"	,"","","mv_ch1",aRet[3],aRet[1],aRet[2],0,"G",'naovazio()'	                       					,"mv_par01",""         ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","",""	    	,"","",""})
aRet := TamSX3("RHH_TPOAUM")
AAdd(aRegs,{cPerg,"02","Tipo de aumento?"  			,"","","mv_ch2",aRet[3],aRet[1],aRet[2],0,"G",'fTipAumen()'   										,"mv_par02",""         ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","",""			,"","",""})
aRet := TamSX3("RHH_MESANO")
AAdd(aRegs,{cPerg,"03","Aplicar em (AAAAMM)?"		,"","","mv_ch3",aRet[3],aRet[1],aRet[2],0,"G",'naovazio()'   										,"mv_par03",""         ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","",""			,"","",""})
aRet := TamSX3("RHH_PROCES")
AAdd(aRegs,{cPerg,"04","Processo?"      			,"","","mv_ch4",aRet[3],aRet[1],aRet[2],0,"G",'naovazio() .AND. ExistCpo("RCJ")'   					,"mv_par04",""         ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","","RCJ"		,"","",""})
aTam := TamSx3("RHH_ROTEIR")
AADD(aRegs,{cPerg,"05","Roteiro de Cálculo?"    	,"","","mv_ch5",aTam[3],aTam[1],aTam[2],0,"G",'naovazio()'											,"mv_par05",""     	   ,"","","","",""         ,"","","","",""      ,"","","","","","","","","","","","","","SRY"       ,"","",""})
aRet := TamSX3("RHH_SEMANA")
AAdd(aRegs,{cPerg,"06","Semana?"   					,"","","mv_ch6",aRet[3],aRet[1],aRet[2],0,"G",'naovazio()'   										,"mv_par06",""         ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","",""			,"","",""})
aRet := TamSX3("RHH_INDICE")
AAdd(aRegs,{cPerg,"07","Indice reajuste (%)?"		,"","","mv_ch7",aRet[3],aRet[1],aRet[2],0,"G",'naovazio()'   										,"mv_par07",""         ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","",""			,"","",""})
aRet := TamSX3("RHH_VL")
AAdd(aRegs,{cPerg,"08","Teto p/ indice (R$)?"		,"","","mv_ch8",aRet[3],aRet[1],aRet[2],0,"G",'naovazio()'   										,"mv_par08",""         ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","",""			,"","",""})
aRet := TamSX3("RHH_VALOR")
AAdd(aRegs,{cPerg,"09","Vlr. reaj. acima teto(R$)?"	,"","","mv_ch9",aRet[3],aRet[1],aRet[2],0,"G",'naovazio()'   										,"mv_par09",""         ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","",""			,"","",""})
aTam := TamSx3("RHH_DTACOR")
AADD(aRegs,{cPerg,"10","Data do acordo?"     		,"","","mv_chA",aTam[3],aTam[1],aTam[2],0,"G",'naovazio()'											,"mv_par10",""     	   ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","",""   		,"","",""})
aTam := TamSx3("RHH_DTPGT")
AADD(aRegs,{cPerg,"11","Data de pagamento?"     	,"","","mv_chB",aTam[3],aTam[1],aTam[2],0,"G",'naovazio()'											,"mv_par11",""     	   ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","",""   		,"","",""})
aTam := TamSx3("RHH_IDCMPL")
AADD(aRegs,{cPerg,"12","Complemento?"     			,"","","mv_chC",aTam[3],aTam[1],aTam[2],0,"G",'naovazio() .AND. ExistCpo("RF1")'					,"mv_par12",""     	   ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","","RF1"  		,"","",""})
cAliasSX1 		:= "SX1_" + GetNextAlias()
OpenSXS(,,,, FWCodEmp(), cAliasSX1, "SX1", , .F.)
dbSelectArea(cAliasSX1)
(cAliasSX1)->(dbSetOrder(1))
For i := 1 to Len(aRegs)
	If !(cAliasSX1)->(dbSeek(cPerg + Space(Len((cAliasSX1)->X1_GRUPO) - Len(cPerg)) + aRegs[i,2]))
		RecLock(cAliasSX1,.T.)
		for j := 1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j, aRegs[i,j])
			EndIf
		Next
		MsUnlock()
	EndIf
Next
RestArea(aAlias)
Return