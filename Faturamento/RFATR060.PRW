#INCLUDE "rwmake.ch"

/*/{Protheus.doc} 
@description Relatorio de produtos sem movimento
@author		Diego Rodrigues Pereira email: diego.rodrigues@allss.com.br
@since 		04/11/2022
@version 	1.01
@see 		https://allss.com.br
@History 	
/*/

User function RFATR060()

	Private _cRotina  := "RFATR060" // Coloque aqui o nome do programa para impressao no cabecalho
	Private _cPerg      := "FATR60"

    ValidPerg()
	//AjustaSX1(cPerg)
	If !pergunte(_cPerg,.T.)
		Return
	EndIf

		MsAguarde({|| GeraArq()}," Gerando Arquivo de Trabalho... ")
		MsAguarde({|| ExpExcel()}," Exportando Excel... ")

	PROD->(dbCloseArea())
return

/*
Exporta os Dados para o Excel  
*/
Static function ExpExcel()

	Local aSldAtu		:= {}
	Local cArqExcel		:= "Ult_Mov.xls"
	Local cPathExcel	:= "c:\relato\"
	Local sDtFech		:= GetMv("MV_ULMES")

	SB1->(dbSetOrder(1))

	oExcel := FWMSEXCEL():New()
	cTitGrf := "PRODUTOS"
	cTitGrf1:= "PRODUTOS"
	oExcel:AddworkSheet(cTitGrf)
	oExcel:AddTable (cTitGrf,cTitGrf1)

	oExcel:AddColumn(cTitGrf,cTitGrf1,"CODIGO",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"DESCRICAO",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"TIPO",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"DESCTIPO",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"GRUPO",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"DESCGRUPO",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"SALDO",1,2,.T.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"VALOR",1,2,.T.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"DTMOV",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"DIAS",1,2,.F.)
	//oExcel:AddColumn(cTitGrf,cTitGrf1,"DESTINACAO",1,1,.F.)

	dbSelectArea("PROD")
	dbGotop()
	ProcRegua(PROD->(RecCount()))

	While !(PROD->(EOF()))

		sDtPesq := IIF(Empty(PROD->MOVIMENTO),"19880101",PROD->MOVIMENTO)
		sDtLimt := MonthSub(ddatabase,mv_par07)
	
		If  sDtPesq <= dTOS(sDtLimt)

				aSldAtu := CalcSaldo(PROD->CODIGO) 
				nSldAtu:= aSldAtu[1]
				nVlrAtu:= aSldAtu[2]

				SB1->(dbSeek(xFilial("SB1")+PROD->CODIGO))

				aDadosExc := {}
				aadd(aDadosExc,PROD->CODIGO)
				aadd(aDadosExc,SB1->B1_DESC)
				aadd(aDadosExc,SB1->B1_TIPO)
				aadd(aDadosExc,Posicione('SX5',1,xFilial("SX5")+"02"+SB1->B1_TIPO,"X5_DESCRI"))
				aadd(aDadosExc,SB1->B1_GRUPO)
				aadd(aDadosExc,Posicione('SBM',1,xFilial("SBM")+SB1->B1_GRUPO,"BM_DESC"))
				aadd(aDadosExc,nSldAtu)
				aadd(aDadosExc,nVlrAtu)
				aadd(aDadosExc,DTOC(STOD(PROD->MOVIMENTO)))
				aadd(aDadosExc,ROUND((ddatabase - StoD(PROD->MOVIMENTO)),0))
				//aadd(aDadosExc,SB1->B1_FABRIC)

				oExcel:AddRow(cTitGrf,cTitGrf1,aDadosExc)

		EndIf

		PROD->(dbSkip())
		IncProc("Gerando dados para planilha Excel")
	Enddo


	// Faco a chamada da geracao do arquivo
	// XML

	oExcel:Activate()
	oExcel:GetXMLFile(cPathExcel + cArqExcel)
	oExcel:DeActivate()

	// Faco a chamada da classe MsExcel para abertura
	// do arquivo
	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open(cPathExcel + cArqExcel)// Abre uma planilha
	oExcelApp:SetVisible(.T.)
	oExcelApp:Destroy()

return Nil


/*
Calcula o saldo do produto de acordo com SB2  
*/
Static function CalcSaldo(cCodigo)

	Local nSldAtu 	:= 0
	Local nVlrAtu	:= 0
	Local _aAreaSB2 := SB2->(GetArea())

        dbSelectArea("SB2")
		dbSetOrder(1)

		If !dbSeek(xFilial("SB2")+cCodigo)
			Return nSldAtu
		EndIf

		While !Eof() .and. B2_COD == cCodigo .and. B2_FILIAL == xFilial("SB2")
			nQtd 	:= SaldoSB2()
			nSldAtu += nQtd
			nVlrAtu += Round(nQtd * B2_CM1,TamSX3("B2_VATU1")[2])
			dbSkip()
		Enddo
	
	RestArea(_aAreaSB2)

Return {nSldAtu,nVlrAtu}

/*
Gera arquivo de trabalho
*/
Static function GeraArq()

	Local cQuery

	cQuery := "SELECT DISTINCT CODIGO, MAX(DATA) AS MOVIMENTO" // Nao se deve mexer na ordem de solicitacao dos campos para nao afetar o processo de selecao de ordem de impressao
	cQuery += " FROM"
	cQuery += " 	(SELECT DISTINCT D3_COD AS 'CODIGO' "
	cQuery += " 					,MAX(D3_EMISSAO) AS 'DATA' "
	cQuery += " 	FROM "+RetSQLName("SD3")+" D3 (NOLOCK), "+RetSQLName("SB1")+" B1 (NOLOCK) "
	cQuery += " 	WHERE D3.D_E_L_E_T_ <> '*' "
	cQuery += " 	   AND D3_FILIAL = '"+xFilial("SD3")+"'"
	cQuery += " 	   AND D3_ESTORNO =   '' "
	cQuery += " 	   AND RTRIM(LTRIM(D3_DOC)) <> 'INVENT' "
	cQuery += "			AND B1.D_E_L_E_T_ <> '*'"
	cQuery += " 		AND B1_FILIAL='"+xFilial("SB1")+"'"
	cQuery += "			AND B1_COD = D3_COD"
	cQuery += "			AND B1_COD >= '"+mv_par01+"'"
	cQuery += "			AND B1_COD <= '"+mv_par02+"'"
	cQuery += "			AND B1_TIPO >= '"+mv_par03+"'"
	cQuery += "			AND B1_TIPO <= '"+mv_par04+"'"
	cQuery += "			AND B1_GRUPO >= '"+mv_par05+"'"
	cQuery += "			AND B1_GRUPO <= '"+mv_par06+"'"
	cQuery += " 	GROUP BY D3_COD"
	cQuery += " 	UNION"
	cQuery += " 	SELECT DISTINCT D2_COD AS 'CODIGO'"
	cQuery += " 					,MAX(D2_EMISSAO) AS 'DATA'"
	cQuery += " 	FROM  "+RetSQLName("SD2")+" D2 (NOLOCK), "+RetSQLName("SF4")+" F4 (NOLOCK), "+RetSQLName("SB1")+" B1 (NOLOCK)"
	cQuery += " 	WHERE D2_TES = F4_CODIGO"
	cQuery += " 		AND F4_ESTOQUE = 'S'"
	cQuery += " 		AND F4_FILIAL = '"+xFilial("SF4")+"'"
	cQuery += " 		AND F4.D_E_L_E_T_ <> '*'"
	cQuery += " 		AND D2.D_E_L_E_T_ <> '*'"
	cQuery += " 		AND D2_FILIAL = '"+xFilial("SD2")+"'"
	cQuery += "			AND B1.D_E_L_E_T_ <> '*'"
	cQuery += " 		AND B1_FILIAL='"+xFilial("SB1")+"'"
	cQuery += "			AND B1_COD = D2_COD"
	cQuery += "			AND B1_COD >= '"+mv_par01+"'"
	cQuery += "			AND B1_COD <= '"+mv_par02+"'"
	cQuery += "			AND B1_TIPO >= '"+mv_par03+"'"
	cQuery += "			AND B1_TIPO <= '"+mv_par04+"'"
	cQuery += "			AND B1_GRUPO >= '"+mv_par05+"'"
	cQuery += "			AND B1_GRUPO <= '"+mv_par06+"'"
	cQuery += " 	GROUP BY D2_COD"
	cQuery += " 	UNION"
	cQuery += " 	SELECT DISTINCT D1_COD AS 'CODIGO'"
	cQuery += " 					,MAX(D1_DTDIGIT) AS 'DATA'"
	cQuery += " 	FROM "+RetSQLName("SD1")+" D1 (NOLOCK), "+RetSQLName("SF4")+" F4 (NOLOCK), "+RetSQLName("SB1")+" B1 (NOLOCK)"
	cQuery += " 	WHERE D1_TES = F4_CODIGO"
	cQuery += " 		AND F4_ESTOQUE = 'S'"
	cQuery += " 		AND F4_FILIAL = '"+xFilial("SF4")+"'"
	cQuery += " 		AND F4.D_E_L_E_T_ <> '*'"
	cQuery += " 		AND D1.D_E_L_E_T_ <> '*'"
	cQuery += " 		AND D1_FILIAL = '"+xFilial("SD1")+"'"
	cQuery += "			AND B1.D_E_L_E_T_ <> '*'"
	cQuery += " 		AND B1_FILIAL='"+xFilial("SB1")+"'"
	cQuery += "			AND B1_COD = D1_COD"
	cQuery += "			AND B1_COD >= '"+mv_par01+"'"
	cQuery += "			AND B1_COD <= '"+mv_par02+"'"
	cQuery += "			AND B1_TIPO >= '"+mv_par03+"'"
	cQuery += "			AND B1_TIPO <= '"+mv_par04+"'"
	cQuery += "			AND B1_GRUPO >= '"+mv_par05+"'"
	cQuery += "			AND B1_GRUPO <= '"+mv_par06+"'"
	cQuery += " 	GROUP BY D1_COD"
	cQuery += " 	UNION"
	cQuery += " 	SELECT DISTINCT B2_COD AS 'CODIGO'"
	cQuery += " 					,MAX(B2_USAI) AS 'DATA'"
	cQuery += " 	FROM "+RetSQLName("SB2")+" B2 (NOLOCK), "+RetSQLName("SB1")+" B1 (NOLOCK)"
	cQuery += " 	WHERE
	cQuery += " 		B2.D_E_L_E_T_ <> '*'"
	cQuery += " 		AND B2_FILIAL = '"+xFilial("SB2")+"'"
	cQuery += "			AND B1.D_E_L_E_T_ <> '*'"
	cQuery += " 		AND B1_FILIAL='"+xFilial("SB1")+"'"
	cQuery += "			AND B1_COD = B2_COD"
	cQuery += "			AND B1_COD >= '"+mv_par01+"'"
	cQuery += "			AND B1_COD <= '"+mv_par02+"'"
	cQuery += "			AND B1_TIPO >= '"+mv_par03+"'"
	cQuery += "			AND B1_TIPO <= '"+mv_par04+"'"
	cQuery += "			AND B1_GRUPO >= '"+mv_par05+"'"
	cQuery += "			AND B1_GRUPO <= '"+mv_par06+"'"
	cQuery += " 	GROUP BY B2_COD"
	cQuery += " 	) AS TABELA"
	cQuery += " GROUP BY CODIGO"
	cQuery += " ORDER BY CODIGO"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"PROD")

return

/*/{Protheus.doc} ValidPerg
@description Verifica as perguntas no dicionário SX1, as criando, caso não existam.
@author Diego Rodrigues Pereira (ALLSS Soluções em Sistemas)
@since 22/06/2021
@type function
@version 1.00
@see https://allss.com.br
/*/
static function ValidPerg()
	local _aArea     := GetArea()
	local _aTam      := {}
	local _aRegs     := {}
	local i          := 0
	local j          := 0
	local _cAliasSX1 := "SX1"

	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
		
		_cPerg := PADR(_cPerg,len((_cAliasSX1)->X1_GRUPO))
		_aTam  := TamSX3("B1_COD")
		AADD(_aRegs,{_cPerg,"01","Do Produto?"        ,"","","mv_ch1",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1"   ,"",""})
		AADD(_aRegs,{_cPerg,"02","Ao Produto?"        ,"","","mv_ch2",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1"   ,"",""})
		_aTam  := TamSX3("B1_TIPO")
		AADD(_aRegs,{_cPerg,"03","Do Tipo?"        ,"","","mv_ch3",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"",""})
		AADD(_aRegs,{_cPerg,"04","Ao Tipo?"        ,"","","mv_ch4",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"",""})
		_aTam  := TamSX3("B1_GRUPO")
		AADD(_aRegs,{_cPerg,"05","Do Grupo?"        ,"","","mv_ch5",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SBM"   ,"",""})
		AADD(_aRegs,{_cPerg,"06","Ao Grupo?"        ,"","","mv_ch6",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SBM"   ,"",""})
		AADD(_aRegs,{_cPerg,"07","Periodo"          ,"","","mv_ch7","N",02,0                        ,0,"G","NAOVAZIO()","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
	for i := 1 to len(_aRegs)
		if !(_cAliasSX1)->(dbSeek(_cPerg+_aRegs[i,2]))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				for j := 1 to FCount()
					if j <= Len(_aRegs[i])
						FieldPut(j,_aRegs[i,j])
					else
						Exit
					endif
				next
			(_cAliasSX1)->(MsUnLock())
		endif
	next
	RestArea(_aArea)
return
