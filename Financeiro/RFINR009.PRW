#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RFINR009  ºAutor  ³ Júlio Soares     º Data ³  22/06/2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório de faturamento com informações financeiras.      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFINR009()

Local oExcel	:= FWMSExcel():New()
Local _cTitulo	:= "Relação de faturamento"
Local _cTitulo2	:= "Parâmetros"
Local _cRotina	:= "RFINR009"
Local _cQry		:= ""
Local cString	:= "QRYTMP"
Local _cSheet1	:= "Relação de Faturamento"
Local _cSheet2	:= "Parâmetros"
Private _cPerg	:= _cRotina
Private _aPar   := {}
Private _lEnt	:= + CHR(13) + CHR(10)

// - VERIFICA SE USUÁRIO TEM PERMISSÃO PARA GERAR DADOS EM EXCEL
If !(SubStr(cAcesso,160,1) == "S" .AND. SubStr(cAcesso,168,1) == "S" .AND. SubStr(cAcesso,170,1) == "S")
	MSGBOX('Usuário sem permissão para gerar relatório em Excel. Informe o Administrador.',_cRotina+"_002",'STOP')
   Return(Nil)
EndIf

//Verifica as perguntas selecionadas.
ValidPerg()
If !Pergunte(_cPerg,.T.)
	Return
EndIf

//Defino a Sheet/Plan
oExcel:AddWorkSheet(_cSheet1)
//Defino o Título da tabela no Excel
oExcel:AddTable(_cSheet1,_cTitulo)
//Crio o cabeçalho das colunas do relatório
oExcel:AddColumn(_cSheet1,_cTitulo,"NF"			,2,1,.F.) //D2_DOC
oExcel:AddColumn(_cSheet1,_cTitulo,"Série"		,2,1,.F.) //D2_SERIE
oExcel:AddColumn(_cSheet1,_cTitulo,"Cliente"	,2,1,.F.) //D2_CLIENT
oExcel:AddColumn(_cSheet1,_cTitulo,"Loja"		,2,1,.F.) //D2_LOJA
oExcel:AddColumn(_cSheet1,_cTitulo,"Nome"		,1,1,.F.) //A1_NOME
oExcel:AddColumn(_cSheet1,_cTitulo,"Dt. Emissão",2,4,.F.) //D2_EMISSAO
oExcel:AddColumn(_cSheet1,_cTitulo,"CFOP"		,2,1,.F.) //D2_CFOP
oExcel:AddColumn(_cSheet1,_cTitulo,"Tp operação",2,1,.F.) //D2_TIPOPER
oExcel:AddColumn(_cSheet1,_cTitulo,"Produto"	,1,1,.F.) //D2_COD
oExcel:AddColumn(_cSheet1,_cTitulo,"Descrição"	,1,1,.F.) //B1_DESC
oExcel:AddColumn(_cSheet1,_cTitulo,"Val. Merc."	,2,2,.T.) //D2_VALBRUT
oExcel:AddColumn(_cSheet1,_cTitulo,"Val. ICM"	,2,2,.T.) //D2_VALICM
oExcel:AddColumn(_cSheet1,_cTitulo,"Val. IPI"	,2,2,.T.) //D2_VALIPI
oExcel:AddColumn(_cSheet1,_cTitulo,"Val. ST"	,2,2,.T.) //D2_ICMSRET  
oExcel:AddColumn(_cSheet1,_cTitulo,"Val. Desp"	,2,2,.T.) //D2_DESP
oExcel:AddColumn(_cSheet1,_cTitulo,"Val. Fret"	,2,2,.T.) //D2_VALFRE
oExcel:AddColumn(_cSheet1,_cTitulo,"Val. Total"	,2,2,.T.) //D2_TOTAL
oExcel:AddColumn(_cSheet1,_cTitulo,"Val. Finan"	,2,2,.F.) //E1_VALOR

_cQry   += " SELECT D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,A1_NOME, D2_EMISSAO,D2_CF,D2_TIPOPER,D2_COD,B1_DESC, " + _lEnt
_cQry   += " 		D2_VALBRUT,D2_VALICM,D2_VALIPI,D2_ICMSRET,ROUND(F2_DESPESA*((D2_TOTAL*100/F2_VALFAT)/100),2) " + _lEnt
_cQry   += "		D2_DESP,D2_VALFRE,D2_TOTAL,(SELECT SUM(E1_VALOR) E1_VALOR " + _lEnt
_cQry   += "									FROM "+RetSqlName("SE1")+" SE1 " + _lEnt
_cQry   += "									WHERE SE1.E1_FILIAL		= '"+xFilial("SE1")+"' " + _lEnt
_cQry   += "									AND SE1.D_E_L_E_T_	= '' " + _lEnt
_cQry   += "									AND SE1.E1_PREFIXO		= SF2.F2_PREFIXO " + _lEnt
_cQry   += "									AND SE1.E1_NUM 			= SF2.F2_DUPL " + _lEnt
_cQry   += "									AND SE1.E1_CLIENTE		= SF2.F2_CLIENT " + _lEnt
_cQry   += "									AND SE1.E1_LOJA			= SF2.F2_LOJA " + _lEnt
_cQry   += "									GROUP BY E1_PREFIXO,E1_NUM,E1_CLIENTE,E1_LOJA,E1_TIPO " + _lEnt
_cQry   += "									) E1_VALOR "  + _lEnt
_cQry   += " FROM "+RetSqlName("SD2")+" SD2 " + _lEnt
_cQry   += " INNER JOIN "+RetSqlName("SF2")+" SF2 " + _lEnt
_cQry   += " 		ON  SF2.F2_FILIAL = '"+xFilial("SF2")+"' " + _lEnt
_cQry   += " 		AND SF2.F2_CLIENT	= SD2.D2_CLIENTE " + _lEnt
_cQry   += " 		AND SF2.F2_LOJA		= SD2.D2_LOJA " + _lEnt
_cQry   += " 		AND SF2.F2_DOC		= SD2.D2_DOC " + _lEnt
_cQry   += " 		AND SF2.F2_SERIE	= SD2.D2_SERIE " + _lEnt
_cQry   += " 		AND SF2.D_E_L_E_T_ = '' " + _lEnt
_cQry   += " 	INNER JOIN "+RetSqlName("SF4")+" SF4  " + _lEnt
_cQry   += " 		ON  SF4.F4_FILIAL	= '"+XfILIAL("SF4")+"' " + _lEnt
_cQry   += " 		AND SF4.F4_CODIGO	= SD2.D2_TES " + _lEnt
If MV_PAR07 == 1
	_cQry   += " 		AND SF4.F4_DUPLIC = 'S' " + _lEnt
ElseIf MV_PAR == 2 
	_cQry   += " 		AND SF4.F4_DUPLIC = 'N' " + _lEnt
EndIf
_cQry   += " 		AND SF4.D_E_L_E_T_	= '' " + _lEnt
_cQry   += " 	INNER JOIN "+RetSqlName("SA1")+" SA1 " + _lEnt
_cQry   += " 		ON  SA1.A1_FILIAL	= '"+xFilial("SA1")+"' " + _lEnt
_cQry   += " 		AND SA1.A1_COD		= SF2.F2_CLIENT " + _lEnt
_cQry   += " 		AND SA1.A1_LOJA		= SF2.F2_LOJA " + _lEnt
_cQry   += " 		AND SA1.D_E_L_E_T_	= '' " + _lEnt
_cQry   += " 	INNER JOIN "+RetSqlName("SB1")+" SB1 " + _lEnt
_cQry   += " 		ON  SB1.B1_FILIAL	= '"+xFilial("SB1")+"' " + _lEnt
_cQry   += " 		AND SB1.B1_COD		= SD2.D2_COD " + _lEnt
_cQry   += " 		AND SB1.B1_TIPO		= SD2.D2_TP " + _lEnt
_cQry   += " 		AND SB1.D_E_L_E_T_	= '' " + _lEnt
_cQry   += " WHERE SD2.D_E_L_E_T_ = '' " + _lEnt
_cQry   += " AND SD2.D2_FILIAL  = '"+xFilial("SD2")+"' " + _lEnt
_cQry   += " AND SD2.D2_EMISSAO	BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' " + _lEnt
_cQry   += " AND SD2.D2_CLIENTE	BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"' " + _lEnt
_cQry   += " AND SD2.D2_LOJA	BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"' " + _lEnt
_cQry   += " AND SD2.D2_CF		BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' " + _lEnt
_cQry   += " AND SD2.D2_TIPO	= 'N' " + _lEnt
If !Empty(Alltrim(MV_PAR08))
	_cQry   += " AND SD2.D2_TIPOPER IN "+FormatIn(Alltrim(MV_PAR08),';')+ _lEnt
EndIf
_cQry   += " ORDER BY D2_EMISSAO,D2_DOC,D2_SERIE,D2_CLIENTE,F2_LOJA,A1_NOME,D2_ITEM " + _lEnt
_cQry   := ChangeQuery (_cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cString,.T.,.F.)

//Converto as datas que vieram na Query como caracter (ex.: "20150319") para o formato de Data (19/03/2015), para que eu não precise converter com a função STOD no meio do loop
dbSelectArea("SD2")
aStruSD2 := SD2->(dbStruct())
For nSD2 := 1 To Len(aStruSD2)
	If aStruSD2[nSD2][2] <> "C" .and.  FieldPos(aStruSD2[nSD2][1]) > 0
		TcSetField(cString,aStruSD2[nSD2][1],aStruSD2[nSD2][2],aStruSD2[nSD2][3],aStruSD2[nSD2][4])
	EndIf
Next nSD2
//Loop para inclusão das linhas de dados no Excel
dbSelectArea("QRYTMP")
While !QRYTMP->(EOF())
	oExcel :AddRow(_cSheet1,_cTitulo,{	QRYTMP->D2_DOC		,;
										QRYTMP->D2_SERIE	,;
										QRYTMP->D2_CLIENTE	,;
										QRYTMP->D2_LOJA		,;
										QRYTMP->A1_NOME		,;
										QRYTMP->D2_EMISSAO	,;
										QRYTMP->D2_CF		,;
  										QRYTMP->D2_TIPOPER	,;
  										QRYTMP->D2_COD		,;
  										QRYTMP->B1_DESC		,;
										QRYTMP->D2_VALBRUT	,;
										QRYTMP->D2_VALICM	,;
										QRYTMP->D2_VALIPI	,;
										QRYTMP->D2_ICMSRET	,;
										QRYTMP->D2_DESP		,;
										QRYTMP->D2_VALFRE	,;
										QRYTMP->D2_TOTAL	,;
										QRYTMP->E1_VALOR	;
										})				
	QRYTMP->(dbSkip())
EndDo
//Fecho a query
QRYTMP->(dbCloseArea())

// - TRECHO RESPONSÁVEL PELA INSERÇÃO DE UMA ABA COM AS INFORMAÇÕES DOS PARAMETROS
oExcel:AddWorkSheet(_cSheet2)
oExcel:AddTable(_cSheet2,_cTitulo2)
oExcel:AddColumn(_cSheet2,_cTitulo2,"DESCRIÇÃO" ,1,1,.F.)
oExcel:AddColumn(_cSheet2,_cTitulo2,"CONTEÚDO"  ,1,1,.F.)

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
//Pego o caminho da pasta de temporários da máquina do usuário
_cDirTmp := GetTempPath()
//Defino o nome do arquivo do Excel a ser gerado
_cArq    := _cRotina+".xml"
//Gero o Excel com o nome que defini anteriormente no servidor (ainda não no caminho temporário que mencionei)
oExcel:GetXmlFile(_cArq)
//Desativo o Excel (pois a planilha já foi gerada)
oExcel:DeActivate()
//Se o arquivo foi criado com sucesso, copio para a pasta temporária na máquina do usuário
If File(_cArq) .AND. __CopyFile(_cArq,_cDirTmp+_cArq)
	//Apago o arquivo de Excel original do Servidor
	FErase(_cArq)
	MsgInfo("Arquivo gerado com sucesso!" + CHR(13) + CHR(10) + (_cDirTmp+_cArq) ,_cRotina+"_001")
	//Verifico se o Excel está instalado na máquina do usuário
	/*If !ApOleClient('MsExcel')
		MsgStop("Excel não instalado",_cRotina+"_002")
	Else*/
		//Trecho para abrir a planilha gerada no Excel para o usuário
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(_cDirTmp+_cArq)
		oExcelApp:SetVisible(.T.)
		oExcelApp := oExcelApp:Destroy()
	//EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ValidPerg  ºAutor ³Júlio Soares       º Data ³  22/06/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica/cria as perguntas de usuário na tabela SX1.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ValidPerg()

Local _aArea := GetArea()
Local aRegs  := {}
Local _aTam  := {}

_cPerg := PADR(_cPerg,10)

// De/Até Data
_aTam := TamSx3("F2_EMISSAO")
AADD(aRegs,{_cPerg,"01","De Emissão?"   			,"","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","mv_par01",""		,"","","","",""             ,"","","","",""				,"","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{_cPerg,"02","Até Emissão?"  			,"","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","mv_par02",""		,"","","","",""             ,"","","","",""				,"","","","","","","","","","","","","",""   ,"",""})
// De/Até Cliente
_aTam := TamSx3("A1_COD")
AADD(aRegs,{_cPerg,"03","Do Cliente?"				,"","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par03",""		,"","","","",""             ,"","","","",""				,"","","","","","","","","","","","","","SA1","",""})
_aTam := TamSx3("A1_LOJA")                                    
AADD(aRegs,{_cPerg,"04","Da Loja?"					,"","","mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"MV_PAR04",""		,"","","","",""             ,"","","","",""				,"","","","","","","","","","","","","",""   ,"",""})
_aTam := TamSx3("A1_COD")
AADD(aRegs,{_cPerg,"05","Ao Cliente?"				,"","","mv_ch5",_aTam[03],_aTam[01],_aTam[02],0,"G","NaoVazio()","mv_par05",""		,"","","","",""             ,"","","","",""				,"","","","","","","","","","","","","","SA1","",""})
_aTam := TamSx3("A1_LOJA")                                                                                                                                                                  
AADD(aRegs,{_cPerg,"06","Até a Loja?"				,"","","mv_ch6",_aTam[03],_aTam[01],_aTam[02],0,"G","NaoVazio()","mv_par06",""		,"","","","",""             ,"","","","",""				,"","","","","","","","","","","","","",""   ,"",""})
// Somente Operações que Geram Contas a Receber? (Sim/Não/Ambos)
_aTam := {10,00,"C"}
AADD(aRegs,{_cPerg,"07","Contas a Receber?"			,"","","mv_ch7",_aTam[03],_aTam[01],_aTam[02],0,"C","NaoVazio()","mv_par07","Gera"	,"","","","","Não gera"		,"","","","","Ambos"		,"","","","","","","","","","","","","",""   ,"",""})
// Filtra Tipos de Operação? (Se informa "Sim", apresentar um Markbrowse com os Tipos de Operação)
_aTam := {99,00,"C"}
AADD(aRegs,{_cPerg,"08","Filtra tipos de operação?"	,"","","mv_ch8",_aTam[03],_aTam[01],_aTam[02],0,"G",'U_PESQSX5("DJ")',"mv_par08",""		,"","","","",""				,"","","","",""				,"","","","","","","","","","","","","",""   ,"",""})
// Filtra CFOPs? (Se informa "Sim", apresentar um Markbrowse com os CFOPs)
_aTam := {10,00,"C"}
AADD(aRegs,{_cPerg,"09","De CFOP?"					,"","","mv_ch9",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par09",""		,"","","","",""             ,"","","","",""              ,"","","","","","","","","","","","","","SYD","",""})
AADD(aRegs,{_cPerg,"10","Até CFOP?"					,"","","mv_cha",_aTam[03],_aTam[01],_aTam[02],0,"G","NaoVazio()","mv_par10",""		,"","","","",""             ,"","","","",""              ,"","","","","","","","","","","","","","SYD","",""})
// Apresenta Devoluções? (Não / Sim, Conforme NF de Devolução / Sim, Conforme NF Original)
_aTam := {1,00,"C"}
AADD(aRegs,{_cPerg,"11","Apresenta devolução?"		,"","","mv_chb",_aTam[03],_aTam[01],_aTam[02],0,"C",""          ,"mv_par11","Não"	,"","","","","Sim, NF Devol","","","","","Sim, NF Origem","","","","","","","","","","","","","",""   ,"",""})

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
