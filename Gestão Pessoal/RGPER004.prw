#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} RGPER004
Relatório de controle de acesso ao refeitório (controle para evitar aglomerações - COVID-19) 
@author Rodrigo Telecio (ALLSS Soluções em Sistemas)
@since 21/07/2016
@version P12
@type Function
@param nulo, Nil, nenhum 
@return nulo, Nil 
@obs Sem observacoes ate o momento 
@see https://allss.com.br/
@history 21/07/2020, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Disponibilização do relatório no ambiente para testes.
/*/
user function RGPER004()
private cPerg 	:= FunName()
private cTit 	:= "Controle de acesso ao refeitório (medidas contenção COVID-19)"
private lRet	:= .T. 
ValidPerg(cPerg)
if !Pergunte(cPerg, .T.)
	return
endif
Processa({ |lEnd| ImpRel(lEnd)},cTit,"Processando informações...",.T.)		
return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpBolIt  ºAutor  ³Rodrigo Telecio       Data ³ 21/07/2020  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processamento de impressão da rotina.                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal.                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ImpRel(lEnd)
local cIniPer   	:= mv_par07
local cFimPer   	:= mv_par08
local cRotina		:= AllTrim(FunName())
local cAba			:= 'Parametros'
local cAba2			:= 'Sintetico'
local cAba3			:= 'Analítico'
local cTitulo		:= 'Parametros utilizados'
local cTitulo2		:= cTit + ' - periodo de avaliacao - de ' + AllTrim(DtoC(cIniPer)) + ' a ' + AllTrim(DtoC(cFimPer)) + ' - ' + cAba2
local cTitulo3		:= cTit + ' - periodo de avaliacao - de ' + AllTrim(DtoC(cIniPer)) + ' a ' + AllTrim(DtoC(cFimPer)) + ' - ' + cAba3 
local cArquivo    	:= Lower(AllTrim(mv_par09))
local lRet			:= .T.
local cArea      	:= GetArea()
local lOpen			:= .F.
local oFWMsExcel
local oExcel
//-------------------------------------------------------------------
//Inserida validacao com relacao ao preenchimento do nome do arquivo
//-------------------------------------------------------------------
if Empty(RetFileName(cArquivo)) 
	cArquivo := Lower(AllTrim(cArquivo)) + cRotina + '.xml'
endif
//-------------------------------------------------------------------
//Inserida validacao com relacao as permissoes do usuario.
//-------------------------------------------------------------------
if !(SubStr(cAcesso,160,1) == "S" .AND. SubStr(cAcesso,168,1) == "S" .AND. SubStr(cAcesso,170,1) == "S")
	Aviso('TOTVS','Usuário sem permissão para gerar relatórios em Excel.',{'OK'},3,'Cancelamento de operacao por falta de permissões')
	lRet := .F.
endif
//-------------------------------------------------------------------
//Inserida validacao quanto a existencia do MsExcel no computador que
// esta executando o "smartclient.exe"
//-------------------------------------------------------------------
/*if lRet
	if !ApOleClient('MsExcel')
		Aviso('TOTVS','Microsoft Excel não está instalado nessa estacao.',{'OK'},3,'Cancelamento de operação por ausência de aplicativo')
		lRet := .F.
	endif
endif*/
if lRet
	//PARÂMETROS DO RELATÓRIO	
	oFWMsExcel := FWMSExcel():New()
	oFWMsExcel:AddWorkSheet(cAba)
	oFWMsExcel:AddTable(cAba,cTitulo)
	oFWMsExcel:AddColumn(cAba,cTitulo,'Descricao'							, 1, 1) //1 = Modo Texto
	oFWMsExcel:AddColumn(cAba,cTitulo,'Conteudo'							, 1, 1) //1 = Modo Texto
	_aSavArea	:= GetArea()
	_cAliasSX1 	:= "SX1"
	OpenSXS(Nil,Nil,Nil,Nil,FWCodEmp(),_cAliasSX1,"SX1",Nil,.F.)
	lOpen		:= Select(_cAliasSX1) > 0
	if lOpen
		dbSelectArea(_cAliasSX1)
		(_cAliasSX1)->(dbSetOrder(1))
		(_cAliasSX1)->(dbGoTop())
		cPerg 		:= PADR(cPerg, 10)
		_aPar		:= {}
		if (_cAliasSX1)->(dbSeek(cPerg))
			while !(_cAliasSX1)->(EOF()) .AND. (_cAliasSX1)->X1_GRUPO == cPerg
				if AllTrim((_cAliasSX1)->X1_GSC) == "C"
					aAdd(_aPar,{(_cAliasSX1)->X1_PERGUNT, &("(_cAliasSX1)->X1_DEF" + StrZero(&((_cAliasSX1)->X1_VAR01),2))})
				else
					aAdd(_aPar,{(_cAliasSX1)->X1_PERGUNT, &((_cAliasSX1)->X1_VAR01)})
				endif
				dbSelectArea(_cAliasSX1)
				(_cAliasSX1)->(dbSetOrder(1))    
				(_cAliasSX1)->(dbSkip())
			enddo
		endif
		if Len(_aPar) > 0
			for _nPosPar := 1 to Len(_aPar)
				oFWMsExcel:AddRow(cAba,cTitulo,_aPar[_nPosPar])
			next _nPosPar
		endif
	endif
	RestArea(_aSavArea)
	//MOVIMENTAÇÃO SINTÉTICA
	oFWMsExcel:AddworkSheet(cAba2)
	oFWMsExcel:AddTable(cAba2,cTitulo2)
	oFWMsExcel:AddColumn(cAba2,cTitulo2, "Data"								, 1, 1) //1 = Modo Texto
	oFWMsExcel:AddColumn(cAba2,cTitulo2, "Faixa de horário (saída p/ ref.)"	, 1, 1) //1 = Modo Texto	
	oFWMsExcel:AddColumn(cAba2,cTitulo2, "Quantidade de colaboradores"		, 2, 2) //2 = Valor sem R$
	if Select("QRY1") <> 0
		dbSelectArea("QRY1")
		QRY1->(dbCloseArea())
	endif
	if mv_par10 == 2 
		BEGINSQL Alias "QRY1"
			SELECT 
				SPG.PG_DATA AS DT_APONT, CAST(SPG.PG_HORA AS int) AS HOR_SAI, COUNT(PG_MAT) AS QTD
			FROM
				%table:SPG% AS SPG
			WHERE
			 	PG_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			 	AND PG_CC BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			 	AND PG_MAT BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
				AND PG_DATA BETWEEN %Exp:DtoS(MV_PAR07)% AND %Exp:DtoS(MV_PAR08)%
				AND PG_APONTA = 'S'
				AND PG_TPMARCA IN ('1S')
				AND SPG.%NotDel%
			GROUP BY
				PG_DATA, CAST(SPG.PG_HORA AS int)
			ORDER BY 
				PG_DATA, CAST(SPG.PG_HORA AS int) 
		ENDSQL
	else
		BEGINSQL Alias "QRY1"	
			SELECT 
				SP8.P8_DATA AS DT_APONT, CAST(SP8.P8_HORA AS int) AS HOR_SAI, COUNT(P8_MAT) AS QTD
			FROM
				%table:SP8% AS SP8 
			WHERE
			 	P8_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			 	AND P8_CC BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			 	AND P8_MAT BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
				AND P8_DATA BETWEEN %Exp:DtoS(MV_PAR07)% AND %Exp:DtoS(MV_PAR08)%
				AND P8_APONTA = 'S'				
				AND P8_TPMARCA IN ('1S')				
				AND SP8.%NotDel%
			GROUP BY
				P8_DATA, CAST(SP8.P8_HORA AS int)
			ORDER BY 
				P8_DATA, CAST(SP8.P8_HORA AS int)	
		ENDSQL
	endif
	dbSelectArea("QRY1")
	ProcRegua(RecCount())
	QRY1->(dbGoTop())
	while !QRY1->(EOF())
		oFWMsExcel:AddRow(cAba2,cTitulo2,  {StoD(QRY1->DT_APONT)	,;
											QRY1->HOR_SAI			,;
											QRY1->QTD				})
		IncProc("Gravando informacoes, aguarde...")
		QRY1->(dbSkip())		
	enddo
	dbSelectArea("QRY1")
	QRY1->(dbCloseArea())
	//MOVIMENTAÇÃO ANALÍTICA
	oFWMsExcel:AddworkSheet(cAba3)
	oFWMsExcel:AddTable(cAba3,cTitulo3)
	oFWMsExcel:AddColumn(cAba3,cTitulo3, "Filial"							, 1, 1) //1 = Modo Texto
	oFWMsExcel:AddColumn(cAba3,cTitulo3, "Centro de Custo"					, 1, 1) //1 = Modo Texto	
	oFWMsExcel:AddColumn(cAba3,cTitulo3, "Matricula"						, 1, 1) //1 = Modo Texto
	oFWMsExcel:AddColumn(cAba3,cTitulo3, "Nome"								, 1, 1) //1 = Modo Texto	
	oFWMsExcel:AddColumn(cAba3,cTitulo3, "Data Apontamento"					, 1, 1) //1 = Modo Texto
	oFWMsExcel:AddColumn(cAba3,cTitulo3, "Horário Apontamento"				, 2, 2) //2 = Valor sem R$
	if Select("QRY1") <> 0
		dbSelectArea("QRY1")
		QRY1->(dbCloseArea())
	endif
	if mv_par10 == 2 
		BEGINSQL Alias "QRY1"
			SELECT DISTINCT
				PG_FILIAL AS FILIAL, PG_MAT AS MATRICULA, RA_NOME AS NOME, 
				PG_DATA AS DT_APONT, PG_HORA AS HOR_SAI, PG_CC AS C_CUSTO 
			FROM 
				%table:SPG% AS SPG
				LEFT OUTER JOIN
					%table:SRA% AS SRA
				ON
					RA_FILIAL = PG_FILIAL
					AND RA_MAT = PG_MAT
					AND SRA.%NotDel%
			WHERE
			 	PG_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			 	AND PG_CC BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			 	AND PG_MAT BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
				AND PG_DATA BETWEEN %Exp:DtoS(MV_PAR07)% AND %Exp:DtoS(MV_PAR08)%
				AND PG_APONTA = 'S'
				AND PG_TPMARCA IN ('1S')
				AND SPG.%NotDel%
			ORDER BY 
				PG_FILIAL, PG_DATA, PG_HORA, PG_CC				 
		ENDSQL
	else
		BEGINSQL Alias "QRY1"
			SELECT DISTINCT
				P8_FILIAL AS FILIAL, P8_MAT AS MATRICULA, RA_NOME AS NOME, 
				P8_DATA AS DT_APONT, P8_HORA AS HOR_SAI, P8_CC AS C_CUSTO
			FROM 
				%table:SP8% AS SP8
				LEFT OUTER JOIN
					%table:SRA% AS SRA
				ON
					RA_FILIAL = P8_FILIAL
					AND RA_MAT = P8_MAT
					AND SRA.%NotDel%
			WHERE
				P8_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%		 
				AND P8_CC BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%	
				AND P8_MAT BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
				AND P8_DATA BETWEEN %Exp:DtoS(MV_PAR07)% AND %Exp:DtoS(MV_PAR08)%
				AND P8_APONTA = 'S'											 
				AND P8_TPMARCA IN ('1S') 			
				AND SP8.%NotDel%
			ORDER BY 
				P8_FILIAL, P8_DATA, P8_HORA, P8_CC
		ENDSQL
	endif
	dbSelectArea("QRY1")
	ProcRegua(RecCount())
	QRY1->(dbGoTop())
	while !QRY1->(EOF())
		oFWMsExcel:AddRow(cAba3,cTitulo3,  {QRY1->FILIAL			,;
											QRY1->C_CUSTO			,;
											QRY1->MATRICULA			,;
											QRY1->NOME				,;
											StoD(QRY1->DT_APONT)	,;
											QRY1->HOR_SAI			})
		IncProc("Gravando informacoes, aguarde...")
		QRY1->(dbSkip())		
	enddo
	dbSelectArea("QRY1")
	QRY1->(dbCloseArea())	
	RestArea(cArea)
	//EXIBIÇÃO DOS DADOS LEVANTADOS	
	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArquivo)
	oExcel := MsExcel():New()
	oExcel:WorkBooks:Open(cArquivo)
	oExcel:SetVisible(.T.)
	oExcel:Destroy()
	Aviso('TOTVS','Arquivo gerado com sucesso! O arquivo está gravado em ' + AllTrim(cArquivo) + '.',{'OK'},3,'Arquivo processado')
endif
return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ValidPerg  ºAutor  ³Rodrigo Telecio   º Data ³  21/07/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função responsavel por criar as perguntas utilizadas no    º±±
±±º          ³ relatório                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ValidPerg(cPerg)
local aAlias 	:= GetArea()
local aRegs   	:= {}
local lOpen	    := .F.
local cAliasSX1 := "SX1"
local aRet      := {}
local _x,_y
cPerg 			:= PADR(cPerg,10)
aRet := TamSX3("RA_FILIAL")
aAdd(aRegs,{cPerg,"01","Da Filial?"    				,"","","mv_ch1",aRet[3],aRet[1],aRet[2],0,"G",""			,"mv_par01",""         ,"","","","",""              ,"","","","","","","","","","","","","","","","","","","SM0"	,"","",""})
aAdd(aRegs,{cPerg,"02","Ate a Filial?" 				,"","","mv_ch2",aRet[3],aRet[1],aRet[2],0,"G","naovazio()"	,"mv_par02",""         ,"","","","",""              ,"","","","","","","","","","","","","","","","","","","SM0"	,"","",""})
aRet := TamSX3("CTT_CUSTO")
aAdd(aRegs,{cPerg,"03","Do C.Custo?"   				,"","","mv_ch3",aRet[3],aRet[1],aRet[2],0,"G",""			,"mv_par03",""         ,"","","","",""              ,"","","","","","","","","","","","","","","","","","","CTT"	,"","",""})
aAdd(aRegs,{cPerg,"04","Ate C.Custo?"				,"","","mv_ch4",aRet[3],aRet[1],aRet[2],0,"G","naovazio()"	,"mv_par04",""         ,"","","","",""              ,"","","","","","","","","","","","","","","","","","","CTT"	,"","",""})
aRet := TamSX3("RA_MAT")
aAdd(aRegs,{cPerg,"05","Da Matricula?" 				,"","","mv_ch5",aRet[3],aRet[1],aRet[2],0,"G",""			,"mv_par05",""         ,"","","","",""              ,"","","","","","","","","","","","","","","","","","","SRA"	,"","",""})
aAdd(aRegs,{cPerg,"06","Ate a Matricula?"			,"","","mv_ch6",aRet[3],aRet[1],aRet[2],0,"G","naovazio()"	,"mv_par06",""         ,"","","","",""              ,"","","","","","","","","","","","","","","","","","","SRA"	,"","",""})
aRet := TamSX3("PO_DATAINI")
aAdd(aRegs,{cPerg,"07","Do periodo?"      			,"","","mv_ch7",aRet[3],aRet[1],aRet[2],0,"G","naovazio()"	,"mv_par07",""         ,"","","","",""              ,"","","","","","","","","","","","","","","","","","",""	    ,"","",""})
aAdd(aRegs,{cPerg,"08","Ate o periodo?"      		,"","","mv_ch8",aRet[3],aRet[1],aRet[2],0,"G","naovazio()"	,"mv_par08",""         ,"","","","",""              ,"","","","","","","","","","","","","","","","","","",""	    ,"","",""})
aAdd(aRegs,{cPerg,"09","Diretorio p/Salvar Arq.?"   ,"","","mv_ch9","C"    ,90     ,0      ,0,"G",""			,"mv_par09",""         ,"","","","",""              ,"","","","","","","","","","","","","","","","","","","DIR"	,"","",""})
aAdd(aRegs,{cPerg,"10","Periodo?"     				,"","","mv_cha","N"    ,1	   ,0      ,0,"C",'naovazio()'	,"mv_par10","Atual"	   ,"","","","","Anterior(es)"  ,"","","","","","","","","","","","","","","","","","",""    	,"","",""})
cAliasSX1 		:= "SX1"
//OpenSXS(Nil,Nil,Nil,Nil,FWCodEmp(),cAliasSX1,"SX1",Nil,.F.)
lOpen			:= Select(cAliasSX1) > 0
//if lOpen
	for _x := 1 to Len(aRegs)
		dbSelectArea((cAliasSX1))
		(cAliasSX1)->(dbSetOrder(1))
		if !(cAliasSX1)->(MsSeek(cPerg + aRegs[_x,2],.T.,.F.))
			Reclock("SX1",.T.)
			for _y := 1 to FCount()
				if _y <= Len(aRegs[_x])
					FieldPut(_y,aRegs[_x,_y])
				else              
					exit
				endif
			next _y 
			(cAliasSX1)->(MsUnlock())
		endif
	next _x
//endif
RestArea(aAlias)
return
