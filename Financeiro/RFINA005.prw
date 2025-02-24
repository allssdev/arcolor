#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FWPRINTSETUP.CH'
#INCLUDE 'RPTDEF.CH'
#INCLUDE "AP5MAIL.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RFINA005  บAutor  ณJ๚lio Soares       บ Data ณ  25/02/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina criada para avaliar e atualizar de forma automแtica บฑฑ
ฑฑบ          ณ o limite de cr้dito do cliente assim como o risco.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico empresa Arcolor                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                            	

User Function RFINA005(_nOpc)

// - TRECHO INCLUIDO PARA REALIZAR O LOGIN AUTOMมTICO PARA A REALIZAวรO DA ROTINA VIA SCHEDULE.
/*
Local _cAqrLogin := "\boletos\logempfil.cfg"
Local _cEmpr     := "01"
Local _cFil      := "01"

RPCSetType(3)
If !RpcSetEnv(_cEmpr,_cFil,,,"FIN",,,.T.,.F.,.T.,.T.)		//RpcSetEnv(_cEmpr,_cFil,_cPswUsr,_cPswPwd,"FAT",,,.T.,.F.,.T.,.T.)
	_cStatus := "[RXMLQS01 ERROR CFG] Falha na autentica็ใo interna de ambiente. Contate o administrador! - " + ;
	IIF(!Empty(_cDtHr),;
	DTOC(STOD(SubStr(_cDtHr,1,8))) + " - " + SubStr(_cDtHr,9,2) + ":" + SubStr(_cDtHr,11,2) + ":" +	SubStr(_cDtHr,13,2),;
	DTOC(Date()) + " - " + Time()) + "."
	If _lGravaLg
		AutoGrLog(_cStatus)
	EndIf
	RpcClearEnv()
//	Loop()
	Return()
EndIf
*/

Private _aSavArea := GetArea()
Private _aCpos    := {} //Campos a serem atualizados
Private _aCampos  := {}
Private _lRet     := .T.
Private _lRetMail := .F.
Private _lEnt     := CHR(13) + CHR(10)
Private _dData    := (dDataBase) // - Data do sistema
//Private _dData    := Date() // - Data do Windows
Private _nCont    := 0
Private _nRiscb   := SuperGetMv("MV_RISCOB" ,,2)
Private _nRiscc   := SuperGetMv("MV_RISCOC" ,,4)
Private _nRiscd   := SuperGetMv("MV_RISCOD" ,,7)
Private _nValLim  := SuperGetMv("MV_VALVIC" ,,(20000.00)) // - LIMITE DE VALOR DEFINIDO PELO Sr. MARCO PARA IDENTIFICAR CLIENTES COM RISCO DE CREDITO A
Private _nDiaComp := SuperGetMv("MV_DIACOMP" ,,180)
Private _nNumComp := SuperGetMv("MV_NRCOMPR" ,,4)
Private _nDiascrd := SuperGetMv("MV_DIASCRD",,90)  // - DIAS PARA AVALIAR O CREDITO
Private _nDiasval := SuperGetMv("MV_NDEATRS",,365) // - DIAS PARA AVALIAR ATRASO EM DIAS
Private _nVctocrd := SuperGetMv("MV_VNCTCRD",,30)  // - DIAS PARA VENCIMENTO DO NOVO LIMITE
Private _nFatrcrd := SuperGetMv("MV_FATRCRD",,1.5) // - FATOR DE MULTIPLICAวรO DO PAGTO PARA NOVO LIMITE
Private _cAtuCred := "1"
Private _cTemp    := 'TMPTRA'
Private _cRotina  := 'RFINA005'
Private _cTitulo  := ("Atualiza็ใo de " + DTOC(_dData-(_nDiascrd)) + " at้ " + DTOC(_dData) + " - " + _cRotina)
Private _cTitulo1 := ("Atualia็ใo automแtica do limite de cr้dito do cliente")
Private _cMsg1    := "Essa rotina irแ atualizar o limite de cr้dito do cliente baseando-se na soma dos valores dos tํtulos quitados dentro dos" +;
					 " ๚ltimos " +  (Alltrim(STR(_nDiascrd))) + " dias contados a partir da data-base do sistema, esse valor ้ multiplicado por " +;
					 (Alltrim(STR(_nFatrcrd))) + " conforme defini็ใo interna e atualizado no cadastro do cliente." + (_lEnt) + (_lEnt) +;
					 "Deseja processar os limites de cr้dito entre " + (DTOC((_dData)-(_nDiascrd))) + " e " + (DTOC(_dData)) + " ? "
Private _cMsg2    := "Deseja processar a rotina antes de verificar as altera็๕es a serem executadas na planilha gerada? "+_lEnt+;
					 "Verifique o e-mail com os dados a serem atualizados."
Default _nOpc     := 0

dbSelectArea("SE1")
_aSavSE1 := SE1->(GetArea())
dbSelectArea("SA1")
_aSavSA1 := SA1->(GetArea())

If (_nOpc) == 0
	If MsgYesNo(_cMsg1,_cRotina+"_01")
		MsgRun(" Selecionando dados para atualiza็ใo. Por favor AGUARDE. ",_cTitulo,{ || _SelQuery()})
		MsgRun(" Gerando os dados em planilha. Por favor AGUARDE. ",_cTitulo,{ || _Geraxls() })
		MsgRun(" Enviando e-mail com as atualiza็๕es. Por favor AGUARDE. ",_cTitulo,{ || _EnvMail() })
//		If _lRetMail
			If MsgYesNo(_cMsg2,_cRotina+"_02")
				Processa({ || _aProcess() },_cRotina,' Atualizando limites de cr้dito. Por favor aguarde.',.T.)
				MSGBOX("Foram atualizados " + Alltrim(STR(_nCont)) + " cadastros de clientes. ",_cRotina+'_04','INFO')
			EndIf
//		Else
//			MSGBOX("Nใo foi possํvel enviar o e-mail com os cadastros. ",_cRotina+'_05','ALERT')
//		EndIf
	Else
		MSGBOX("Nใo foi possํvel concluir a atualiza็ใo, reprocesse a rotina caso necessแrio. ",_cRotina+'_06','ALERT')
		Return()	
	EndIf
	RestArea(_aSavSA1)
	RestArea(_aSavSE1)
	RestArea(_aSavArea)
Else
	_SelQuery()
	_Geraxls()
	_EnvMail()
	If _lRetMail
		_aProcess()
	EndIf
	RestArea(_aSavSA1)
	RestArea(_aSavSE1)
	RestArea(_aSavArea)
	RpcClearEnv()
EndIf
	
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ _SelQuery  บAutor  ณ J๚lio Soares       บ Data ณ  25/02/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina responsแvel por selecionar os dados a serem         บฑฑ
ฑฑบ          ณ avaliados                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico empresa Arcolor                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function _SelQuery()

// - ADICIONO OS CAMPOS A SEREM INSERIDOS COMO COLUNAS NO EXCEL

AADD(_aCpos,{"COD"              ,"(_cTemp)->COD"       ,1,1,.F.})
AADD(_aCpos,{"LOJA"             ,"(_cTemp)->LOJA"      ,1,1,.F.})
AADD(_aCpos,{"CLIENTE"          ,"(_cTemp)->CLIENTE"   ,1,1,.F.})
AADD(_aCpos,{"CREDITO"          ,"(_cTemp)->CREDITO"   ,3,3,.F.})
AADD(_aCpos,{"RISCO"            ,"(_cTemp)->RISCO"     ,2,1,.F.})
AADD(_aCpos,{"N-CREDITO"        ,"(_cTemp)->N_CREDITO" ,3,3,.F.})
AADD(_aCpos,{"N-RISCO"          ,"(_cTemp)->N_RISCO"   ,2,1,.F.})
AADD(_aCpos,{"PGTO REALIZADOS"  ,"(_cTemp)->PGTO"      ,3,3,.F.})
AADD(_aCpos,{"DIAS PGTO C ATRS" ,"(_cTemp)->DIAS"      ,2,2,.F.})
AADD(_aCpos,{"QTD. TIT PGTO"    ,"(_cTemp)->TITULOS"   ,2,2,.F.})
AADD(_aCpos,{"DIAS EM ATRASO"   ,"(_cTemp)->DIAS_A"    ,2,2,.F.})
AADD(_aCpos,{"QTD. TIT ATRASO"  ,"(_cTemp)->TITULOS_A" ,2,2,.F.})

// - INICIO A MONTAGEM DA EXTRUTURA DE SELEวรO NO BANCO DE DADOS.

_cQry := " SELECT CRED.COD[COD], CRED.LOJA[LOJA], CRED.CLIENTE[CLIENTE], " +_lEnt
_cQry += " SUM(CRED.CREDITO)[CREDITO], " +_lEnt
_cQry += " MAX(CRED.RISCO)[RISCO], " +_lEnt
_cQry += " ROUND(SUM(CRED.N_CREDITO),2)[N_CREDITO], " +_lEnt
_cQry += " MAX(CRED.N_RISCO)[N_RISCO], " +_lEnt
_cQry += " SUM(CRED.PGTO)[PGTO], " +_lEnt
_cQry += " SUM(CRED.DIAS)[DIAS], " +_lEnt
_cQry += " SUM(CRED.TITULOS)[TITULOS], " +_lEnt
_cQry += " SUM(CRED.[TITULOS_A])[TITULOS_A], " +_lEnt
_cQry += " SUM(CRED.[DIAS_A])[DIAS_A] " +_lEnt
_cQry += " FROM (  " +_lEnt
_cQry += "  SELECT SE1.E1_CLIENTE[COD],SE1.E1_LOJA[LOJA],SA1.A1_NOME[CLIENTE],SA1.A1_LC[CREDITO],SA1.A1_RISCO[RISCO], " +_lEnt
_cQry += "  SUM(SE1.E1_VALLIQ)*("+ Alltrim(STR(_nFatrcrd)) +") [N_CREDITO],  " +_lEnt
_cQry += "  CASE  " +_lEnt
_cQry += "  	WHEN SUM(SE1.E1_VALLIQ) > 20000.00  THEN 'A'  " +_lEnt
_cQry += "  ELSE  " +_lEnt
_cQry += "  	CASE  " +_lEnt
_cQry += "  		WHEN SUM(DATEDIFF(DAY,E1_VENCREA,E1_BAIXA)) <= " + cValtoChar(_nRiscb) + " THEN 'B'  " +_lEnt
_cQry += "  	ELSE  " +_lEnt
_cQry += "  		CASE  " +_lEnt
_cQry += "  			WHEN SUM(DATEDIFF(DAY,E1_VENCREA,E1_BAIXA)) <= " + cValtoChar(_nRiscc) + "  THEN 'C'  " +_lEnt
_cQry += "  		ELSE  " +_lEnt
_cQry += "  			CASE  " +_lEnt
_cQry += "  				WHEN SUM(DATEDIFF(DAY,E1_VENCREA,E1_BAIXA)) <= " + cValtoChar(_nRiscd) + "  THEN 'D'  " +_lEnt
_cQry += "  			ELSE 'E'  " +_lEnt
_cQry += "  			END  " +_lEnt
_cQry += "  		END  " +_lEnt
_cQry += "  	END  " +_lEnt
_cQry += "  END [N_RISCO],  " +_lEnt
_cQry += "  SUM(SE1.E1_VALLIQ) [PGTO],  " +_lEnt
_cQry += "  SUM(DATEDIFF(DAY,E1_VENCREA,E1_BAIXA))[DIAS], " +_lEnt
_cQry += "  0[TITULOS], 0[TITULOS_A], 0[DIAS_A] " +_lEnt
_cQry += "  FROM " + RetSqlName("SE1") + " SE1  " +_lEnt
_cQry += "  	INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = ''  " +_lEnt
_cQry += " 			AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' " +_lEnt
_cQry += "  		AND SA1.A1_COD  = SE1.E1_CLIENTE  " +_lEnt
_cQry += "  		AND SA1.A1_LOJA = SE1.E1_LOJA  " +_lEnt
_cQry += "  WHERE SE1.D_E_L_E_T_ = ''  " +_lEnt
_cQry += "  AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' " +_lEnt
_cQry += "  AND SE1.E1_BAIXA  BETWEEN '" + DTOS(_dData-(_nDiascrd)) + "' AND '" + DTOS(_dData) + "'  " +_lEnt
_cQry += "  AND SE1.E1_STATUS = 'B'  " +_lEnt
_cQry += "  AND SE1.E1_TIPO   = 'NF'  " +_lEnt
_cQry += "  GROUP BY SE1.E1_CLIENTE,SE1.E1_LOJA,SA1.A1_NOME,SA1.A1_LC,SA1.A1_RISCO  " +_lEnt +_lEnt

_cQry += " UNION ALL  " +_lEnt +_lEnt

_cQry += "  SELECT SE1B.E1_CLIENTE[COD], SE1B.E1_LOJA[LOJA],SA1.A1_NOME [CLIENTE],0[CREDITO],''[RISCO],0[N_CREDITO],''[N_RISCO],  " +_lEnt
_cQry += "  0[PGTO], 0[DIAS], COUNT(*)[TITULOS], 0[TITULOS_A], 0[DIAS_A] " +_lEnt
_cQry += "  FROM " + RetSqlName("SE1") + " SE1B  " +_lEnt
_cQry += "  	INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = ''  " +_lEnt
_cQry += " 			AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' " +_lEnt
_cQry += "  		AND SA1.A1_COD    = SE1B.E1_CLIENTE  " +_lEnt
_cQry += "  		AND SA1.A1_LOJA   = SE1B.E1_LOJA  " +_lEnt
_cQry += " 	WHERE SE1B.D_E_L_E_T_ = ''  " +_lEnt
_cQry += " 	AND SE1B.E1_TIPO    = 'NF'  " +_lEnt
_cQry += " 	AND SE1B.E1_STATUS  = 'B'  " +_lEnt
_cQry += " 	AND SE1B.E1_BAIXA BETWEEN '" + DTOS(_dData-(_nDiascrd)) + "' AND '" + DTOS(_dData) + "'  " +_lEnt
_cQry += " 	GROUP BY SE1B.E1_CLIENTE,SE1B.E1_LOJA,SA1.A1_NOME  " +_lEnt +_lEnt

_cQry += " UNION ALL " +_lEnt +_lEnt

_cQry += " 	SELECT SE1C.E1_CLIENTE[COD], SE1C.E1_LOJA[LOJA], SA1.A1_NOME[CLIENTE], 0[CREDITO], ''[RISCO], 0[N_CREDITO], ''[N_RISCO],  " +_lEnt
_cQry += " 	0[PGTO], 0[DIAS], 0[TITULOS], COUNT(*)[TITULOS_A],0[DIAS_A] " +_lEnt
_cQry += " 	FROM " + RetSqlName("SE1") + " SE1C " +_lEnt
_cQry += " 		INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' " +_lEnt
_cQry += " 			AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' " +_lEnt
_cQry += " 			AND SA1.A1_COD    = SE1C.E1_CLIENTE " +_lEnt
_cQry += " 			AND SA1.A1_LOJA   = SE1C.E1_LOJA " +_lEnt
_cQry += " 	WHERE SE1C.D_E_L_E_T_ = '' " +_lEnt
_cQry += " 	AND SE1C.E1_TIPO    = 'NF' " +_lEnt
_cQry += " 	AND SE1C.E1_SALDO = SE1C.E1_VALOR " +_lEnt
_cQry += " 	AND SE1C.E1_VENCREA BETWEEN '" + DTOS(_dData-(_nDiasval)) + "' AND '" + DTOS(_dData) + "' " +_lEnt
_cQry += " 	GROUP BY SE1C.E1_CLIENTE,SE1C.E1_LOJA,SA1.A1_NOME " +_lEnt +_lEnt

_cQry += " UNION ALL " +_lEnt +_lEnt

_cQry += " 	SELECT SE1D.E1_CLIENTE[COD], SE1D.E1_LOJA[LOJA], SA1.A1_NOME[CLIENTE], 0[CREDITO], ''[RISCO], 0[N_CREDITO], ''[N_RISCO], " +_lEnt
_cQry += " 	0[PGTO], 0[DIAS], 0[TITULOS], 0[TITULOS_A], SUM(DATEDIFF(DAY,SE1D.E1_VENCREA,'20140410'))[DIAS_A] " +_lEnt
_cQry += " 	FROM " + RetSqlName("SE1") + " SE1D " +_lEnt
_cQry += " 		INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' " +_lEnt
_cQry += " 			AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' " +_lEnt
_cQry += " 			AND SA1.A1_COD    = SE1D.E1_CLIENTE " +_lEnt
_cQry += " 			AND SA1.A1_LOJA   = SE1D.E1_LOJA " +_lEnt
_cQry += " 	WHERE SE1D.D_E_L_E_T_ = '' " +_lEnt
_cQry += " 	AND SE1D.E1_VENCREA BETWEEN '" + DTOS(_dData-(_nDiasval)) + "' AND '" + DTOS(_dData) + "' " +_lEnt
_cQry += " 	AND SE1D.E1_TIPO = 'NF' " +_lEnt
_cQry += " 	AND SE1D.E1_SALDO = SE1D.E1_VALOR " +_lEnt
_cQry += " 	GROUP BY SE1D.E1_CLIENTE,SE1D.E1_LOJA,SA1.A1_NOME " +_lEnt +_lEnt
_cQry += "  	) CRED  " +_lEnt
//_cQry += " WHERE CRED.COD BETWEEN '' AND '' "
//_cQry += " AND CRED.LOJA BETWEEN '' AND '' "
_cQry += "  GROUP BY CRED.COD,CRED.LOJA,CRED.CLIENTE  " +_lEnt
_cQry += "  ORDER BY CRED.COD,CRED.LOJA " +_lEnt

//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY.TXT",_cQry)

If TCSQLExec(_cQry) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_07")
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"TMPTRA",.T.,.F.)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ _aProcess บAutor  ณ J๚lio Soares      บ Data ณ  25/02/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina responsแvel por atualizar o cadastro do cliente     บฑฑ
ฑฑบ          ณ conforme a avalia็ใo da pesquisa da fun็ใo _SelQuery       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico empresa Arcolor                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function _aProcess()
Private _cFUNCOND := SuperGetMV("MV_FUNCOND",,"FOL")

dbSelectArea("TMPTRA")
TMPTRA->(dbGoTop())
ProcRegua(TMPTRA->(RecCount()))

While !TMPTRA->(EOF())
	dbSelectArea("SA1")
	dbSetOrder(1)
	If MsSeek((xFilial("SA1"))+ TMPTRA->(COD) + TMPTRA->(LOJA),.T.,.F.)
		If !Empty(SA1->(A1_COND))
		dbSelectArea("SE4")
		dbSetOrder(1)
			If MsSeek((xFilial("SE4"))+ SA1->(A1_COND),.T.,.F.)
				_cAtuCred := SE4->(E4_ATUCRED)
			EndIf
		EndIf
		IncProc('Atualizando O limite de cr้dito para o cliente: ' + _lEnt + Alltrim(TMPTRA->(CLIENTE)))
		// - ------------------------------------------------------------------------------------------------------------------------------------ - //
		// - IMPLEMENTADO EM 23/04/2014 POR J๚lio Soares PARA QUE SEJA AVALIADO A QUANTIDADE DE COMPRAS DDO CLIENTE DENTRO DO PRAZO ESTIPULADO    - //
		_cQry2 := " SELECT COUNT(*) [N_DIAS] "                          +_lEnt
		_cQry2 += " FROM " + RetSqlName("SC5") + " SC5 "                +_lEnt
		_cQry2 += " WHERE SC5.D_E_L_E_T_ = '' "                         +_lEnt
		_cQry2 += " AND SC5.C5_FILIAL    = '" + xFilial("SC5")   + "' " +_lEnt		
		_cQry2 += " AND SC5.C5_CLIENTE   = '" + (TMPTRA->(COD))  + "' " +_lEnt
		_cQry2 += " AND SC5.C5_LOJACLI   = '" + (TMPTRA->(LOJA)) + "' " +_lEnt
		_cQry2 += " AND SC5.C5_EMISSAO   BETWEEN '" + DTOS(_dData-(_nDiaComp)) + "' AND '" + DTOS(_dData) + "' " +_lEnt
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry2),"TMPTRB",.T.,.F.)
		// - ------------------------------------------------------------------------------------------------------------------------------------ - //
		// - F๓rmula para avaliar o coeficiente entre dias em atraso e tํtulos baixados em atraso
		If((TMPTRA->(DIAS)) <> 0 .OR. TMPTRA->(TITULOS) <> 0) .OR. ((TMPTRA->(DIAS_A)) <> 0 .OR. TMPTRA->(TITULOS_A) <> 0)
			_nDias   := ((TMPTRA->(DIAS))/(TMPTRA->(TITULOS)))
			_nDias_a := ((TMPTRA->(DIAS_A))/(TMPTRA->(TITULOS_A)))
		Else
			_nDias   := 0
			_nDias_a := 0
		EndIf
		
		If SA1->A1_COND	<> _cFUNCOND //Linha adicionada por Adriano Leonardo em 03/10/2014 para inibir a atualiza็ใo do limite de cr้dito de funcionแrios
			while !RecLock("SA1",.F.) ; enddo
				SA1->A1_MOEDALC := 1
				//SA1->A1_LC      := TMPTRA->(N_CREDITO) // - LINHA COMENTADA APำS ALTERAวรO
				SA1->A1_LC      := TMPTRA->PGTO/(_nDiascrd/30) // - INSERIDO EM 24/04/2014 POR J๚lio Soares ap๓s a 
																	 // - altera็ใo das regras definidas pelo cliente.
				SA1->A1_VENCLC  := _dData+_nVctocrd
	
				// - ACIMA DE R$ 20.000,00 LIMITE PARA CLASSE A CASO CONTRARIO CLASSE B "
				// - Trecho alterado em 06/05/2014 por J๚lio Soares para que o limite mํnimo para clientes classe A possa ser contabilizado 
				// - tamb้m com base nos 12 meses.
				//If (TMPTRA->(PGTO)) > (_nValLim) // - trecho comentado ap๓s altera็ใo.
				If ((TMPTRA->(PGTO)) / (_nDiascrd/30)) > (_nValLim) 
					SA1->(A1_RISCO) := 'A'
				Else
					If (SA1->(A1_VENDRES) == '1' .OR. (_cAtuCred) == '1') .And. (TMPTRB->(N_DIAS)) > (_nNumComp)
						If     (_nDias) <= (_nRiscb) .Or. ((_nDias_a) > 0         .And. (_nDias_a) <= (_nRiscb))
							SA1->(A1_RISCO) := 'B'
						ElseIf (_nDias) <= (_nRiscc) .Or. ((_nDias_a) > (_nRiscb) .And. (_nDias_a) <= (_nRiscc))
							SA1->(A1_RISCO) := 'C'
						ElseIf (_nDias) <= (_nRiscd) .Or. ((_nDias_a) > (_nRiscc) .And. (_nDias_a) <= (_nRiscd))
							SA1->(A1_RISCO) := 'D'
						Else
							SA1->(A1_RISCO) := 'E'
						EndIf
					Else
						SA1->(A1_RISCO) := 'E'
					EndIf
				EndIf	
			SA1->(MsUnlock())
		EndIf
	Else
		MSGBOX('Cliente ' + TMPTRA->(CLIENTE) + ' nใo encontrado.',_cRotina+'_03','ALERT')
	EndIf
	TMPTRB->(dbCloseArea())
	TMPTRA->(dbSkip())
	_nCont ++
EndDo
TMPTRA->(dbCloseArea())

//Inํcio - Trecho adicionado por Adriano Leonardo em 03/10/2014 - Para atualiza็ใo do limite de cr้dito dos funcionแrios com base no salแrio
_cUpd := "UPDATE " + RetSqlName("SA1") + " SET A1_LC=(SRA.RA_SALARIO*0.25), A1_RISCO='" + SuperGetMV("MV_RISCOFUN",,"B") + "' FROM " + RetSqlName("SRA") + " SRA "
_cUpd += "INNER JOIN " + RetSqlName("SA1") + " SA1 "
_cUpd += "ON SRA.RA_CLIENTE=SA1.A1_COD "
_cUpd += "AND SRA.RA_LOJACLI=SA1.A1_LOJA "
_cUpd += "AND SRA.D_E_L_E_T_='' "
_cUpd += "AND SRA.RA_FILIAL='" + xFilial("SRA") + "' "
_cUpd += "AND SRA.D_E_L_E_T_='' "
_cUpd += "AND SA1.A1_FILIAL='" + xFilial("SA1") + "' "
_cUpd += "WHERE SA1.A1_LC<>(SRA.RA_SALARIO * " + SuperGetMV("MV_LIMITFUN",,0.25) + ") " //Percentual do salแrio a ser considerado como limite de cr้dito do funcionแrio

If TCSQLExec(_cUpd) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_08")
EndIf

//Final  - Trecho adicionado por Adriano Leonardo em 03/10/2014
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFATR017  บAutor  ณMicrosiga           บ Data ณ  15/01/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsแvel por gerar a planilha conforme dados     บฑฑ
ฑฑบ          ณ obtidos da consulta formada de acordo com parโmetros       บฑฑ
ฑฑบ          ณ inseridos pelo usuแrio.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para empresa ARCOLOR              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function _Geraxls()

Local oExcel
Local _cSheet1    := 'Limte Cred.'
Local _cSheet2    := ''

//Private _cFileTMP := ""
Private _cFile    := ""
Private _aPar     := {}

Public _cFileTMP  := ""  

dbSelectArea(_cTemp)
ProcRegua(((_cTemp)->(RecCount())*2)+1)
(_cTemp)->(dbGoTop())
If !(_cTemp)->(EOF())
	oExcel := FWMSEXCEL():New()
	oExcel:AddWorkSheet(_cSheet1)
	oExcel:AddTable(_cSheet1,_cTitulo)
	For _x := 1 To Len(_aCpos)
		oExcel:AddColumn(_cSheet1,_cTitulo,_aCpos[_x][01],_aCpos[_x][03],_aCpos[_x][04],_aCpos[_x][05])
	Next
	// - ACRESCENTA AS LINHAS COM INFORMAวีES WHILE ! TEMP ->(EOF())
	While !(_cTemp)->(EOF())
		IncProc('PROCESSANDO CLIENTE: ' + _lEnt + AllTrim(TMPTRA->(CLIENTE)) + '.')
		_aAux := {}
		For _x := 1 To Len(_aCpos)
		    AADD(_aAux, &(_aCpos[_x][02]))
		Next
		oExcel:AddRow(_cSheet1, _cTitulo, _aAux )
		(_cTemp)->(dbSkip())
	EndDo

// - INCLUI UMA ABA COM AS INFORMAวีES DOS PARAMETROS
    /*
	oExcel:AddWorkSheet(_cSheet2)
	oExcel:AddTable(_cSheet2,_cTitulo2)
	oExcel:AddColumn(_cSheet2,_cTitulo2,"DESCRIวรO" ,1,1,.F.)
	oExcel:AddColumn(_cSheet2,_cTitulo2,"CONTEฺDO"  ,1,1,.F.)
	dbSelectArea("SX1")
	dbSetOrder(1)  //Grupo + Ordem    
	dbGoTop()
	cPerg := PADR(cPerg,10)
	If SX1->(dbSeek(cPerg))
		While !EOF() .And. SX1->X1_GRUPO==cPerg
			//IncProc('PROCESSANDO PARAMETROS...')
			If AllTrim(SX1->X1_GSC)=="C"
				AAdd(_aPar,{ SX1->X1_PERGUNT,&("SX1->X1_DEF"+StrZero(&(SX1->X1_VAR01),2)) })
			Else
				AAdd(_aPar,{ SX1->X1_PERGUNT,&(SX1->X1_VAR01) })
			EndIf
			dbSelectArea("SX1")
			dbSetOrder(1)  //Grupo + Ordem    
			dbSkip()
		EndDo
	EndIf
	If Len(_aPar) > 0
		For _nPosPar := 1 To Len(_aPar)
			oExcel:AddRow(_cSheet2, _cTitulo2, _aPar[_nPosPar])
		Next
	EndIf
	*/

// - IMPRIME O RELATำRIO NO EXCEL
	IncProc("ABRINDO ARQUIVO...")
	oExcel:Activate()
	_cFile := (CriaTrab(NIL, .F.) + ".xml")
	While File(_cFile)
		_cFile := (CriaTrab(NIL, .F.) + ".xml")
	EndDo
	oExcel:GetXMLFile(_cFile)
	oExcel:DeActivate()
	If !(File(_cFile))
		_cFile := ""
		Break
	EndIf
//	_cFileTMP := (GetTempPath() + _cFile) // - Gera a planilha em Excel
	_cFileTMP := ( "\boletos\" + _cFile)
	If !(__CopyFile(_cFile , _cFileTMP))
		fErase( _cFile )
		_cFile := ""
		Break
	EndIf
//	fErase(_cFile)
	_cFile := _cFileTMP
	If !(File(_cFile))
		_cFile := ""
		Break
	EndIf
	oMsExcel:= MsExcel():New()
//	If ApOleClient('MsExcel')
		oMsExcel:WorkBooks:Open(_cFile)
		oMsExcel:SetVisible(.T.)
	/*
	Else
		Msgbox('Excel nใo instalado.',_cRotina +"07",'ALERT')
		 Return(Nil)
	EndIf
	*/

//	oMsExcel:= oMsExcel:Destroy() // - APAGA O ARQUIVO TEMPORมRIO APำS A ABERTURA DO MESMO
Else
	MSGBOX('Nใo hแ dados a serem apresentados. Informe o Administrador do sistema.',_cRotina+'_05','ALERT')
EndIf

FreeObj(oExcel)
oExcel := NIL

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ _EnvMail()  บAutor  ณJ๚lio Soares     บ Data ณ  04/04/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function _EnvMail()

Private Titulo    := _cTitulo1
Private _cMsg     := "ale.primilla@arcolor.com.br"
Private _cMail    := "" // - Parโmetro
Private _cAnexo   := ""
Private _cFromOri := ""
Private _cBCC     := "marco.mendes@arcolor.com.br"//julio@crintelligence.com.br;anderson@crintelligence.com.br"

_cAnexo := _cFileTMP

_cMsg := "<HTML><HEAD><TITLE></TITLE>"
_cMsg += "<META http-equiv=Content-Type content='text/html; charset=windows-1252'>"
_cMsg += "<META content='MSHTML 6.00.6000.16735' name=GENERATOR></HEAD>"
_cMsg += "<BODY>"   		 //Inicia conteudo do e-mail
_cMsg += "<H4><Font Face = 'Arial' Size = '2'><P>Atualiza็ใo do limite de cr้dito dos clientes: </P>"
_cMsg += "<P>Segue em anexo os dados dos clientes que tiveram os cr้ditos atualizados. "
_cMsg += "<P><I>[WF TOTVS] Mensagem automแtica Protheus11</I></P></H4><BR>"
_cMsg += "<P>&nbsp;</P>"
_cMsg += "</A></P></BODY>" //Finaliza conteudo do e-mail

U_RCFGM001(Titulo,_cMsg,_cMail,_cAnexo,_cFromOri,_cBCC)

Return()


// - ------------------------------------------------- USO ANTERIOR -------------------------------------------------

/* // - ALTERADO EM 10/04/2014 POR JฺLIO
_cQry := " SELECT CRED.COD[COD], CRED.LOJA[LOJA], CRED.CLIENTE[CLIENTE]," +_lEnt
//_cQry += " SUM(CRED.CREDITO)[CREDITO], MAX(CRED.RISCO)[RISCO], MAX(CRED.NRISC)[NRISC], SUM(CRED.PGTO)[PGTO], " +_lEnt
//_cQry += " ROUND(SUM(CRED.LIMITE),2)[LIMITE], SUM(CRED.DIAS)[DIAS], SUM(CRED.TITULOS)[TITULOS] " +_lEnt
_cQry += " SUM(CRED.CREDITO)[CREDITO]," +_lEnt
_cQry += " MAX(CRED.RISCO)[RISCO]," +_lEnt
_cQry += " ROUND(SUM(CRED.N_CREDITO),2)[N_CREDITO]," +_lEnt
_cQry += " MAX(CRED.N_RISCO)[N_RISCO]," +_lEnt
_cQry += " SUM(CRED.PGTO)[PGTO]," +_lEnt
_cQry += " SUM(CRED.DIAS)[DIAS]," +_lEnt
_cQry += " SUM(CRED.TITULOS)[TITULOS]" +_lEnt
_cQry += " FROM ( " +_lEnt
_cQry += " 	SELECT SE1.E1_CLIENTE[COD],SE1.E1_LOJA[LOJA],SA1.A1_NOME[CLIENTE],SA1.A1_LC[CREDITO],SA1.A1_RISCO[RISCO]," +_lEnt
_cQry += " 	SUM(SE1.E1_VALLIQ)*("+ Alltrim(STR(_nFatrcrd)) +") [N_CREDITO], " +_lEnt
_cQry += " 	CASE " +_lEnt
_cQry += " 		WHEN SUM(SE1.E1_VALLIQ) > 20000.00  THEN 'A' " +_lEnt
_cQry += " 	ELSE " +_lEnt
_cQry += " 		CASE " +_lEnt
_cQry += " 			WHEN SUM(DATEDIFF(DAY,E1_VENCREA,E1_BAIXA)) <= 2  THEN 'B' " +_lEnt
_cQry += " 		ELSE " +_lEnt
_cQry += " 			CASE " +_lEnt
_cQry += " 				WHEN SUM(DATEDIFF(DAY,E1_VENCREA,E1_BAIXA)) <= 4  THEN 'C' " +_lEnt
_cQry += " 			ELSE " +_lEnt
_cQry += " 				CASE " +_lEnt
_cQry += " 					WHEN SUM(DATEDIFF(DAY,E1_VENCREA,E1_BAIXA)) <= 7  THEN 'D' " +_lEnt
_cQry += " 				ELSE 'E' " +_lEnt
_cQry += " 				END " +_lEnt
_cQry += " 			END " +_lEnt
_cQry += " 		END " +_lEnt
_cQry += " 	END [N_RISCO], " +_lEnt
_cQry += " 	SUM(SE1.E1_VALLIQ) [PGTO], " +_lEnt
_cQry += " 	SUM(DATEDIFF(DAY,E1_VENCREA,E1_BAIXA))[DIAS]," +_lEnt
_cQry += " 	0[TITULOS] " +_lEnt
_cQry += " 	FROM " + RetSqlName("SE1") + " SE1 " +_lEnt
_cQry += " 		INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' " +_lEnt
_cQry += " 			AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' " +_lEnt
_cQry += " 			AND SA1.A1_COD  = SE1.E1_CLIENTE " +_lEnt
_cQry += " 			AND SA1.A1_LOJA = SE1.E1_LOJA " +_lEnt
_cQry += " 	WHERE SE1.D_E_L_E_T_ = '' " +_lEnt
_cQry += " 	AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' " +_lEnt
_cQry += " 	AND SE1.E1_BAIXA  BETWEEN '" + DTOS(_dData-(_nDiascrd)) + "' AND '" + DTOS(_dData) + "' " +_lEnt
_cQry += " 	AND SE1.E1_STATUS = 'B' " +_lEnt
_cQry += " 	AND SE1.E1_TIPO   = 'NF' " +_lEnt
_cQry += " 	GROUP BY SE1.E1_CLIENTE,SE1.E1_LOJA,SA1.A1_NOME,SA1.A1_LC,SA1.A1_RISCO " +_lEnt +_lEnt
_cQry += " UNION ALL " +_lEnt +_lEnt
_cQry += "  	SELECT SE1B.E1_CLIENTE[COD], SE1B.E1_LOJA[LOJA],SA1.A1_NOME [CLIENTE],0[CREDITO],''[RISCO],0[N_CREDITO],''[N_RISCO], " +_lEnt
_cQry += "  	0[PGTO],0[DIAS],COUNT(*)[TITULOS] " +_lEnt
_cQry += " 	FROM " + RetSqlName("SE1") + " SE1B " +_lEnt
_cQry += " 	INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' " +_lEnt
_cQry += " 			AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' " +_lEnt
_cQry += " 			AND SA1.A1_COD    = SE1B.E1_CLIENTE " +_lEnt
_cQry += " 			AND SA1.A1_LOJA   = SE1B.E1_LOJA " +_lEnt
_cQry += " 	WHERE SE1B.D_E_L_E_T_ = '' " +_lEnt
_cQry += " 	AND SE1B.E1_FILIAL  = '" + xFilial("SE1") + "' " +_lEnt
_cQry += " 	AND SE1B.E1_TIPO    = 'NF' " +_lEnt
_cQry += " 	AND SE1B.E1_STATUS  = 'B' " +_lEnt
_cQry += " 	AND SE1B.E1_BAIXA BETWEEN '" + DTOS(_dData-(_nDiascrd)) + "' AND '" + DTOS(_dData) + "' " +_lEnt
_cQry += " 	GROUP BY SE1B.E1_CLIENTE,SE1B.E1_LOJA,SA1.A1_NOME " +_lEnt
_cQry += " 	) CRED " +_lEnt
//_cQry += " WHERE CRED.COD  BETWEEN '001000' AND '005000' "                                                                                                   +_lEnt
//_cQry += " AND   CRED.LOJA BETWEEN '' AND 'ZZ'     "                                                                                                   +_lEnt
_cQry += " GROUP BY CRED.COD,CRED.LOJA,CRED.CLIENTE " +_lEnt
_cQry += " ORDER BY CRED.COD,CRED.LOJA " +_lEnt
*/

/*
_cQry := " SELECT CRED.COD[COD], CRED.LOJA[LOJA], CRED.CLIENTE[CLIENTE]," +_lEnt
//_cQry += " SUM(CRED.CREDITO)[CREDITO], MAX(CRED.RISCO)[RISCO], MAX(CRED.NRISC)[NRISC], SUM(CRED.PGTO)[PGTO], " +_lEnt
//_cQry += " ROUND(SUM(CRED.LIMITE),2)[LIMITE], SUM(CRED.DIAS)[DIAS], SUM(CRED.TITULOS)[TITULOS] " +_lEnt
_cQry += " SUM(CRED.CREDITO)[CREDITO]," +_lEnt
_cQry += " MAX(CRED.RISCO)[RISCO]," +_lEnt
_cQry += " ROUND(SUM(CRED.N_CREDITO),2)[N_CREDITO]," +_lEnt
_cQry += " MAX(CRED.N_RISCO)[N_RISCO]," +_lEnt
_cQry += " SUM(CRED.PGTO)[PGTO]," +_lEnt
_cQry += " SUM(CRED.DIAS)[DIAS]," +_lEnt
_cQry += " SUM(CRED.TITULOS)[TITULOS]" +_lEnt
_cQry += " FROM ( " +_lEnt
_cQry += " 	SELECT SE1.E1_CLIENTE[COD],SE1.E1_LOJA[LOJA],SA1.A1_NOME[CLIENTE],SA1.A1_LC[CREDITO],SA1.A1_RISCO[RISCO]," +_lEnt
_cQry += " 	SUM(SE1.E1_VALLIQ)*("+ Alltrim(STR(_nFatrcrd)) +") [N_CREDITO], " +_lEnt
_cQry += " 	CASE " +_lEnt
_cQry += " 		WHEN SUM(SE1.E1_VALLIQ) > 20000.00  THEN 'A' " +_lEnt
_cQry += " 	ELSE " +_lEnt
_cQry += " 		CASE " +_lEnt
_cQry += " 			WHEN SUM(DATEDIFF(DAY,E1_VENCREA,E1_BAIXA)) <= 2  THEN 'B' " +_lEnt
_cQry += " 		ELSE " +_lEnt
_cQry += " 			CASE " +_lEnt
_cQry += " 				WHEN SUM(DATEDIFF(DAY,E1_VENCREA,E1_BAIXA)) <= 4  THEN 'C' " +_lEnt
_cQry += " 			ELSE " +_lEnt
_cQry += " 				CASE " +_lEnt
_cQry += " 					WHEN SUM(DATEDIFF(DAY,E1_VENCREA,E1_BAIXA)) <= 7  THEN 'D' " +_lEnt
_cQry += " 				ELSE 'E' " +_lEnt
_cQry += " 				END " +_lEnt
_cQry += " 			END " +_lEnt
_cQry += " 		END " +_lEnt
_cQry += " 	END [N_RISCO], " +_lEnt
_cQry += " 	SUM(SE1.E1_VALLIQ) [PGTO], " +_lEnt
_cQry += " 	SUM(DATEDIFF(DAY,E1_VENCREA,E1_BAIXA))[DIAS]," +_lEnt
_cQry += " 	0[TITULOS] " +_lEnt
_cQry += " 	FROM " + RetSqlName("SE1") + " SE1 " +_lEnt
_cQry += " 		INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' " +_lEnt
_cQry += " 			AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' " +_lEnt
_cQry += " 			AND SA1.A1_COD  = SE1.E1_CLIENTE " +_lEnt
_cQry += " 			AND SA1.A1_LOJA = SE1.E1_LOJA " +_lEnt
_cQry += " 	WHERE SE1.D_E_L_E_T_ = '' " +_lEnt
_cQry += " 	AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' " +_lEnt
_cQry += " 	AND SE1.E1_BAIXA  BETWEEN '" + DTOS(_dData-(_nDiascrd)) + "' AND '" + DTOS(_dData) + "' " +_lEnt
_cQry += " 	AND SE1.E1_STATUS = 'B' " +_lEnt
_cQry += " 	AND SE1.E1_TIPO   = 'NF' " +_lEnt
_cQry += " 	GROUP BY SE1.E1_CLIENTE,SE1.E1_LOJA,SA1.A1_NOME,SA1.A1_LC,SA1.A1_RISCO " +_lEnt +_lEnt
_cQry += " UNION ALL " +_lEnt +_lEnt
_cQry += "  	SELECT SE1B.E1_CLIENTE[COD], SE1B.E1_LOJA[LOJA],SA1.A1_NOME [CLIENTE],0[CREDITO],''[RISCO],0[N_CREDITO],''[N_RISCO], " +_lEnt
_cQry += "  	0[PGTO],0[DIAS],COUNT(*)[TITULOS] " +_lEnt
_cQry += " 	FROM " + RetSqlName("SE1") + " SE1B " +_lEnt
_cQry += " 	INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' " +_lEnt
_cQry += " 			AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' " +_lEnt
_cQry += " 			AND SA1.A1_COD    = SE1B.E1_CLIENTE " +_lEnt
_cQry += " 			AND SA1.A1_LOJA   = SE1B.E1_LOJA " +_lEnt
_cQry += " 	WHERE SE1B.D_E_L_E_T_ = '' " +_lEnt
_cQry += " 	AND SE1B.E1_FILIAL  = '" + xFilial("SE1") + "' " +_lEnt
_cQry += " 	AND SE1B.E1_TIPO    = 'NF' " +_lEnt
_cQry += " 	AND SE1B.E1_STATUS  = 'B' " +_lEnt
_cQry += " 	AND SE1B.E1_BAIXA BETWEEN '" + DTOS(_dData-(_nDiascrd)) + "' AND '" + DTOS(_dData) + "' " +_lEnt
_cQry += " 	GROUP BY SE1B.E1_CLIENTE,SE1B.E1_LOJA,SA1.A1_NOME " +_lEnt
_cQry += " 	) CRED " +_lEnt
//_cQry += " WHERE CRED.COD  BETWEEN '001000' AND '005000' "                                                                                                   +_lEnt
//_cQry += " AND   CRED.LOJA BETWEEN '' AND 'ZZ'     "                                                                                                   +_lEnt
_cQry += " GROUP BY CRED.COD,CRED.LOJA,CRED.CLIENTE " +_lEnt
_cQry += " ORDER BY CRED.COD,CRED.LOJA " +_lEnt
*/

/*
			If SA1->(A1_VENDRES) == '1' .OR. (_cAtuCred) == '1'
				If (TMPTRA->(PGTO)) > (_nValLim)
					SA1->(A1_RISCO) := 'A'
				Else
					If     (_nDias) <= (_nRiscb) .Or. ((_nDias_a) > 0         .And. (_nDias_a) <= (_nRiscb))
						SA1->(A1_RISCO) := 'B'
					ElseIf (_nDias) <= (_nRiscc) .Or. ((_nDias_a) > (_nRiscb) .And. (_nDias_a) <= (_nRiscc))
						SA1->(A1_RISCO) := 'C'
					ElseIf (_nDias) <= (_nRiscd) .Or. ((_nDias_a) > (_nRiscc) .And. (_nDias_a) <= (_nRiscd))
						SA1->(A1_RISCO) := 'D'
					Else
						SA1->(A1_RISCO) := 'E'
					EndIf
				EndIf
			Else
				SA1->(A1_RISCO) := 'E'
			EndIf
*/
