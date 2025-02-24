#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RFINR010 บAutor  ณ Renan Santos      บ Data ณ  27/10/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Relat๓rio de Rela็ใo de retorno CNAB sem multa e juros     บฑฑ
ฑฑบ          ณ Informa possiveis baixas manipuladas para nao pagamento    บฑฑ
ฑฑบ          ณ de Juros e Multa                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RFINR010()

Local oExcel	:= FWMSExcel():New()
Local _cTitulo	:= "Retornos bancแrio sem multa e juros "
Local _cTitulo2	:= "Parโmetros"
Local _cRotina	:= "RFINR010"
Local _cQry		:= ""
Local cString	:= "QRYTMP"
Local _cSheet1	:= "Retornos bancแrio sem multa e juros"
Local _cSheet2	:= "Parโmetros"
Private _cPerg	:= _cRotina
Private _aPar   := {}
Private _lEnt	:= + CHR(13) + CHR(10)

// - VERIFICA SE USUมRIO TEM PERMISSรO PARA GERAR DADOS EM EXCEL
If !(SubStr(cAcesso,160,1) == "S" .AND. SubStr(cAcesso,168,1) == "S" .AND. SubStr(cAcesso,170,1) == "S")
	MSGBOX('Usuแrio sem permissใo para gerar relat๓rio em Excel. Informe o Administrador.',_cRotina+"_002",'STOP')
   Return(Nil)
EndIf

//Verifica as perguntas selecionadas.
ValidPerg()
If !Pergunte(_cPerg,.T.)
	Return
EndIf

//Defino a Sheet/Plan
oExcel:AddWorkSheet(_cSheet1)
//Defino o Tํtulo da tabela no Excel
oExcel:AddTable(_cSheet1,_cTitulo)
//Crio o cabe็alho das colunas do relat๓rio
//E1_NUM, E1_PREFIXO,E1_PARCELA, E1_TIPO,E5_RECPAG,E1_CLIENTE,E1_NOMERAZ, E5_VALOR, E1_VENCREA, E1_BAIXA, E1_NUMBCO 
oExcel:AddColumn(_cSheet1,_cTitulo,"Titulo"		,2,1,.F.) //E1_NUM
oExcel:AddColumn(_cSheet1,_cTitulo,"Prefixo"	,2,1,.F.) //E1_PREFIXO
oExcel:AddColumn(_cSheet1,_cTitulo,"Parcela"	,2,1,.F.) //E1_PARCELA
oExcel:AddColumn(_cSheet1,_cTitulo,"Cliente"	,2,1,.F.) //E1_CLIENTE
oExcel:AddColumn(_cSheet1,_cTitulo,"Loja"		,2,1,.F.) //E1_LOJA
oExcel:AddColumn(_cSheet1,_cTitulo,"Nome"		,1,1,.F.) //E1_NOMERAZ
oExcel:AddColumn(_cSheet1,_cTitulo,"Num. Banco"	,1,1,.F.) //E1_NUMBCO
oExcel:AddColumn(_cSheet1,_cTitulo,"Dt. Vencim" ,2,4,.F.) //E1_VENCREA
oExcel:AddColumn(_cSheet1,_cTitulo,"Dt. Baixa"  ,2,4,.F.) //E1_BAIXA
oExcel:AddColumn(_cSheet1,_cTitulo,"Dias Atrasados "  ,2,4,.F.) //E1_BAIXA
oExcel:AddColumn(_cSheet1,_cTitulo,"Val. Baixa"	,2,2,.T.) //E5_VALOR

_cQry   += "SELECT E1_NUM, E1_PREFIXO,E1_PARCELA, E1_TIPO,E5_RECPAG,E1_CLIENTE, E1_LOJA ,E1_NOMERAZ, E5_VALOR, E1_VENCREA, E1_BAIXA, E1_NUMBCO " + _lEnt
_cQry   += " FROM "+RetSqlName("SE1")+" SE1 " 					+ _lEnt 
_cQry   += " 	INNER JOIN "+RetSqlName("SE5")+" SE5 " 			+ _lEnt
_cQry   += " 		ON  SE5.E5_FILIAL = '"+xFilial("SE5")+"' " 	+ _lEnt
_cQry   += " 		AND SE5.E5_PREFIXO	= SE1.E1_PREFIXO " 		+ _lEnt  
_cQry   += " 		AND SE5.E5_NUMERO	= SE1.E1_NUM " 			+ _lEnt
_cQry   += " 		AND SE5.E5_PARCELA  = SE1.E1_PARCELA " 		+ _lEnt
_cQry   += " 		AND SE5.E5_CLIENTE	= SE1.E1_CLIENTE " 		+ _lEnt
_cQry   += " 		AND SE5.E5_LOJA		= SE1.E1_LOJA " 		+ _lEnt
_cQry   += " 		AND SE5.E5_VALOR	= SE1.E1_VALOR " 		+ _lEnt
_cQry   += " 		AND SE5.D_E_L_E_T_ = '' " 					+ _lEnt
_cQry   += " WHERE SE1.D_E_L_E_T_ = '' " 						+ _lEnt
_cQry   += " AND SE1.E1_VENCREA  < SE1.E1_BAIXA "				+ _lEnt
_cQry   += " AND SE1.E1_NATUREZ <>'IMP_DADOS' "				+ _lEnt
_cQry   += " AND SE1.E1_SALDO = 0 "				+ _lEnt
_cQry   += " AND E1_NUMBCO <>'' "				+ _lEnt
_cQry   += " AND SE1.E1_VENCREA	BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' " + _lEnt
_cQry   += " ORDER BY(SE1.E1_VENCREA) "				+ _lEnt	

_cQry   := ChangeQuery (_cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cString,.T.,.F.)   
MemoWrite("D:\RFINR100_QRY_1.TXT",_cQry)

dbSelectArea("SE1")
aStruSE1 := SE1->(dbStruct())
For nSE1 := 1 To Len(aStruSE1)
	If aStruSE1[nSE1][2] <> "C" .and.  FieldPos(aStruSE1[nSE1][1]) > 0
		TcSetField(cString,aStruSE1[nSE1][1],aStruSE1[nSE1][2],aStruSE1[nSE1][3],aStruSE1[nSE1][4])
	EndIf
Next nSE1
//Loop para inclusใo das linhas de dados no Excel
dbSelectArea("QRYTMP")
While !QRYTMP->(EOF())
	oExcel :AddRow(_cSheet1,_cTitulo,{	QRYTMP->E1_NUM		,;
										QRYTMP->E1_PREFIXO	,;
										QRYTMP->E1_PARCELA	,;
										QRYTMP->E1_CLIENTE		,;
										QRYTMP->E1_LOJA		,;
										QRYTMP->E1_NOMERAZ	,;
										QRYTMP->E1_NUMBCO		,;
										QRYTMP->E1_VENCREA		,;
  										QRYTMP->E1_BAIXA	,;
  										(QRYTMP->E1_VENCREA - QRYTMP->E1_BAIXA) ,; 
  										QRYTMP->E5_VALOR		;
  										})				
	QRYTMP->(dbSkip())
EndDo
//Fecho a query
QRYTMP->(dbCloseArea())

// - TRECHO RESPONSมVEL PELA INSERวรO DE UMA ABA COM AS INFORMAวีES DOS PARAMETROS
oExcel:AddWorkSheet(_cSheet2)
oExcel:AddTable(_cSheet2,_cTitulo2)
oExcel:AddColumn(_cSheet2,_cTitulo2,"DESCRIวรO" ,1,1,.F.)
oExcel:AddColumn(_cSheet2,_cTitulo2,"CONTEฺDO"  ,1,1,.F.)

/* FB - RELEASE 12.1.23
dbSelectArea("SX1")
dbSetOrder(1)  // - GRUPO + ORDEM
dbGoTop()
_cPerg := PADR(_cPerg,10)

If SX1->(dbSeek(_cPerg))
	While !EOF() .And. SX1->X1_GRUPO == _cPerg
		//IncProc('PROCESSANDO PARAMETROS...')
		If AllTrim(SX1->X1_GSC)=="C"
			AAdd(_aPar,{ SX1->X1_PERGUNT,&("SX1->X1_DEF"+StrZero(&(SX1->X1_VAR01),2)) })
		Else
			AAdd(_aPar,{ SX1->X1_PERGUNT,&(SX1->X1_VAR01) })
		EndIf
		dbSelectArea("SX1")
		dbSetOrder(1)
		dbSkip()
	EndDo
EndIf
*/
_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
dbSelectArea(_cAliasSX1)
(_cAliasSX1)->(dbSetOrder(1))

_cPerg := PADR(_cPerg,10)

If (_cAliasSX1)->(dbSeek(_cPerg))
	While (_cAliasSX1)->(!EOF()) .And. (_cAliasSX1)->X1_GRUPO == _cPerg
		//IncProc('PROCESSANDO PARAMETROS...')
		If AllTrim((_cAliasSX1)->X1_GSC)=="C"
			AAdd(_aPar,{ (_cAliasSX1)->X1_PERGUNT,&("(_cAliasSX1)->X1_DEF"+StrZero(&((_cAliasSX1)->X1_VAR01),2)) })
		Else
			AAdd(_aPar,{ (_cAliasSX1)->X1_PERGUNT,&((_cAliasSX1)->X1_VAR01) })
		EndIf
		dbSelectArea(_cAliasSX1)
		(_cAliasSX1)->(dbSkip())
	EndDo
EndIf

If Len(_aPar) > 0
	For _nPosPar := 1 To Len(_aPar)
		oExcel:AddRow(_cSheet2, _cTitulo2, _aPar[_nPosPar])
	Next
EndIf


//Ativo o Excel
oExcel:Activate()
//Pego o caminho da pasta de temporแrios da mแquina do usuแrio
_cDirTmp := GetTempPath()
//Defino o nome do arquivo do Excel a ser gerado
_cArq    := _cRotina+".xml"
//Gero o Excel com o nome que defini anteriormente no servidor (ainda nใo no caminho temporแrio que mencionei)
oExcel:GetXmlFile(_cArq)
//Desativo o Excel (pois a planilha jแ foi gerada)
oExcel:DeActivate()
//Se o arquivo foi criado com sucesso, copio para a pasta temporแria na mแquina do usuแrio
If File(_cArq) .AND. __CopyFile(_cArq,_cDirTmp+_cArq)
	//Apago o arquivo de Excel original do Servidor
	FErase(_cArq)
	MsgInfo("Arquivo gerado com sucesso!" + CHR(13) + CHR(10) + (_cDirTmp+_cArq) ,_cRotina+"_001")
	//Verifico se o Excel estแ instalado na mแquina do usuแrio
	/*If !ApOleClient('MsExcel')
		MsgStop("Excel nใo instalado",_cRotina+"_002")
	Else
	*/	//Trecho para abrir a planilha gerada no Excel para o usuแrio
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(_cDirTmp+_cArq)
		oExcelApp:SetVisible(.T.)
		oExcelApp := oExcelApp:Destroy()
	//EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ValidPerg  บAutor ณJ๚lio Soares       บ Data ณ  22/06/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica/cria as perguntas de usuแrio na tabela SX1.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ValidPerg()

Local _aArea := GetArea()
Local aRegs  := {}
Local _aTam  := {}

_cPerg := PADR(_cPerg,10)

// De/At้ Data
_aTam := TamSx3("E1_VENCREA")
AADD(aRegs,{_cPerg,"01","De Vencimento?"   			,"","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","mv_par01",""		,"","","","",""             ,"","","","",""				,"","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{_cPerg,"02","At้ Vencimento?"  			,"","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","mv_par02",""		,"","","","",""             ,"","","","",""				,"","","","","","","","","","","","","",""   ,"",""})

For i := 1 To Len(aRegs)
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If !SX1->(dbSeek(_cPerg+aRegs[i,2]))
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

RestArea(_aArea)

Return()
