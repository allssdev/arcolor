#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
/*/{Protheus.doc} RCTBI001
@description Rotina de geração de arquivo TXT dos lançamentos contábeis para manipulação e reimportação posterior pelo padrão.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 26/08/2016
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RCTBI001()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private oGeraTxt
	Private _cRotina := "RCTBI001"
	Private cPerg    := _cRotina
	Private cString  := GetNextAlias()
	ValidPerg()
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da tela de processamento.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CT2")
	CT2->(dbSetOrder(1))
	@ 200,1 TO 380,380 DIALOG oGeraTxt TITLE OemToAnsi("Geração de Arquivo Texto")
		@ 02,10 TO 080,190
		@ 10,018 Say " Este programa ira gerar um arquivo texto, conforme os parame- "
		@ 18,018 Say " tros definidos  pelo usuario,  com os registros do arquivo de "
		@ 26,018 Say " Contabilizações (CT2).                                        "
		@ 70,098 BMPBUTTON TYPE 03 ACTION Pergunte(cPerg,.T.)
		@ 70,128 BMPBUTTON TYPE 01 ACTION OkGeraTxt()
		@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oGeraTxt)
	Activate Dialog oGeraTxt Centered
return
/*/{Protheus.doc} OkGeraTxt
@description Funcao chamada pelo botao OK na tela inicial de processamento. Executa a geracao do arquivo texto.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 26/08/2016
@version 1.0
@type function
@see https://allss.com.br
/*/
static function OkGeraTxt()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o arquivo texto                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private nHdl    := fCreate(mv_par01)
	Private cEOL    := "CHR(13)+CHR(10)"

	If Empty(cEOL)
	    cEOL := CHR(13)+CHR(10)
	Else
	    cEOL := Trim(cEOL)
	    cEOL := &cEOL
	EndIf
	If nHdl == -1
	    MsgAlert("O arquivo de nome "+mv_par01+" nao pode ser executado! Verifique os parametros.","Atencao!")
	    Return
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa a regua de processamento                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Processa({|lEnd| RunCont(@lEnd) },"Exportação dos Lançamentos Contábeis","Processando...",.T.)
return
/*/{Protheus.doc} RunCont
@description Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA, monta a janela com a regua de processamento.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 26/08/2016
@version 1.0
@type function
@see https://allss.com.br
/*/
static function RunCont(lEnd)
	Local nTamLin, cLin, cCpo

	BeginSql Alias cString
		SELECT *
		FROM %table:CT2% CT2 (NOLOCK)
		WHERE CT2.CT2_FILIAL = %xFilial:CT2%
		  AND CT2.CT2_LOTE   = %Exp:MV_PAR04%
		  AND CT2.CT2_DATA BETWEEN %Exp:DTOS(MV_PAR02)% AND %Exp:DTOS(MV_PAR03)%
		  AND CT2.CT2_DOC  BETWEEN %Exp:MV_PAR05      % AND %Exp:MV_PAR06      %
		  AND CT2.%NotDel%
		ORDER BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, R_E_C_N_O_ 
	EndSql
	dbSelectArea(cString)
	(cString)->(dbGoTop())
	ProcRegua(RecCount()) // Numero de registros a processar
	If !(cString)->(EOF()) .AND. !lEnd
		While !(cString)->(EOF()) .AND. !lEnd
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Incrementa a regua                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IncProc()
			nTamLin := 240
			cLin    := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Substitui nas respectivas posicioes na variavel cLin pelo conteudo  ³
			//³ dos campos segundo o Lay-Out. Utiliza a funcao STUFF insere uma     ³
			//³ string dentro de outra string.                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTamA:= 1
			nTam := TamSx3("CT2_LP")[01]
	//		cCpo := PADR((cString)->CT2_LP                              ,nTam)
			cCpo := PADR("200"                                          ,nTam)
			cLin := Stuff(cLin,nTamA,nTam,cCpo)
			nTamA+= nTam

			nTam := 1
			cCpo := ";"
			cLin := Stuff(cLin,nTamA,nTam,cCpo)
			nTamA+= nTam

			nTam := Len(StrTran(DTOC(STOD((cString)->CT2_DATA)),"/",""))
			cCpo := PADR(StrTran(DTOC(STOD((cString)->CT2_DATA)),"/",""),nTam)
			cLin := Stuff(cLin,nTamA,nTam,cCpo)
			nTamA+= nTam

			nTam := 1
			cCpo := ";"
			cLin := Stuff(cLin,nTamA,nTam,cCpo)
			nTamA+= nTam

			nTam := TamSx3("CT2_DEBITO")[01]
			cCpo := PADR((cString)->CT2_DEBITO                          ,nTam)
			cLin := Stuff(cLin,nTamA,nTam,cCpo)
			nTamA+= nTam

			nTam := 1
			cCpo := ";"
			cLin := Stuff(cLin,nTamA,nTam,cCpo)
			nTamA+= nTam

			nTam := TamSx3("CT2_CREDIT")[01]
			cCpo := PADR((cString)->CT2_CREDIT                          ,nTam)
			cLin := Stuff(cLin,nTamA,nTam,cCpo)
			nTamA+= nTam

			nTam := 1
			cCpo := ";"
			cLin := Stuff(cLin,nTamA,nTam,cCpo)
			nTamA+= nTam

			nTam := TamSx3("CT2_VALOR")[01]
			cCpo := StrTran(Str((cString)->CT2_VALOR                    ,nTam, TamSx3("CT2_VALOR")[02]), ".", ",")
			cLin := Stuff(cLin,nTamA,nTam,cCpo)
			nTamA+= nTam

			nTam := 1
			cCpo := ";"
			cLin := Stuff(cLin,nTamA,nTam,cCpo)
			nTamA+= nTam

			nTam := TamSx3("CT2_HIST")[01]
			cCpo := PADR((cString)->CT2_HIST                            ,nTam)
			cLin := Stuff(cLin,nTamA,nTam,cCpo)
			nTamA+= nTam

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravacao no arquivo texto. Testa por erros durante a gravacao da    ³
			//³ linha montada.                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
					Exit
				EndIf
			EndIf
			dbSelectArea(cString)
			(cString)->(dbSkip())
		EndDo
		MsgInfo("Arquivo gerado com sucesso ('"+AllTrim(Lower(MV_PAR01))+"')!!!",_cRotina+"_001")
	Else
		MsgAlert("Nada a processar!")
	EndIf
	dbSelectArea(cString)
	(cString)->(dbCloseArea())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ O arquivo texto deve ser fechado, bem como o dialogo criado na fun- ³
	//³ cao anterior.                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fClose(nHdl)
	Close(oGeraTxt)
return
/*/{Protheus.doc} ValidPerg
@description Valida se as perguntas já existem no arquivo SX1 e caso não encontre as cria no arquivo.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 26/08/2016
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	local _aAlias    := GetArea()
	local aRegs     := {}
	local _aTam      := {}
	local _x         := 0
	local _y         := 0
	local _cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()

	if select(_cAliasSX1)>0
		(_cAliasSX1)->(dbCloseArea())
	endif
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))

	_cPerg           := PADR(_cPerg,len((_cAliasSX1)->X1_GRUPO))
	_aTam            := {99,00,"C"}
	AADD(aRegs,{cPerg,"01","Arquivo (c/ caminho):"  ,"","","mv_ch1",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par01","","","",""        ,"","","","","","","","","","","","","","","","","","","","",""   ,""})
	_aTam            := TamSx3("CT2_DATA"  )
	AADD(aRegs,{cPerg,"02","De Data?" 	  		    ,"","","mv_ch2",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par02","","","","20000101","","","","","","","","","","","","","","","","","","","","",""   ,""})
	AADD(aRegs,{cPerg,"03","Até Data?"	  		    ,"","","mv_ch3",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par03","","","","20491231","","","","","","","","","","","","","","","","","","","","",""   ,""})
	_aTam            := TamSx3("CT2_LOTE"  )
	AADD(aRegs,{cPerg,"04","Lote?"       	  		,"","","mv_ch4",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par04","","","",""        ,"","","","","","","","","","","","","","","","","","","","",""   ,""})
	_aTam            := TamSx3("CT2_DOC"   )
	AADD(aRegs,{cPerg,"05","De Documento?" 	  		,"","","mv_ch5",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par05","","","",""        ,"","","","","","","","","","","","","","","","","","","","",""   ,""})
	AADD(aRegs,{cPerg,"06","Ate Documento?"    		,"","","mv_ch6",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par06","","","","ZZZZZZ"  ,"","","","","","","","","","","","","","","","","","","","",""   ,""})
	for _x := 1 To Len(aRegs)
		if !(_cAliasSX1)->(dbSeek(cPerg+aRegs[_x,2],.T.,.F.))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				for _y := 1 to FCount()
					if _y <= len(aRegs[_x])
						FieldPut(_y,aRegs[_x,_y])
					else
						Exit
					endif
				next
			(_cAliasSX1)->(MsUnLock())
		endif
	next
	if select(_cAliasSX1)>0
		(_cAliasSX1)->(dbCloseArea())
	endif
	RestArea(_aAlias)
return