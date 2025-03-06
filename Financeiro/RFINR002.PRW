#INCLUDE "rwmake.ch"
#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} 
@description Relatorio de titulos das notas fiscais de faturamento da consignação.
@author		Diego Rodrigues Pereira email: diego.rodrigues@allss.com.br
@since 		11/02/2025
@version 	1.01
@see 		https://allss.com.br
@History 	
/*/

User function RFINR002()

	Private _cRotina  := "RFINR002" // Coloque aqui o nome do programa para impressao no cabecalho
	Private _cPerg      := "RFINR02"
    private _cQry  := GetNextAlias()

    ValidPerg()
	//AjustaSX1(cPerg)
	If !pergunte(_cPerg,.T.)
		Return
	EndIf

		MsAguarde({|| GeraArq()}," Gerando Arquivo de Trabalho... ")
		MsAguarde({|| ExpExcel()}," Exportando Excel... ")

	(_cQry)->(dbCloseArea())
return

/*
Exporta os Dados para o Excel  
*/
Static function ExpExcel()

	Local cArqExcel		:= "Titulos_Consignados.xls"
	Local cPathExcel	:= "c:\relato\"
	
	SB1->(dbSetOrder(1))

	oExcel := FWMSEXCEL():New()
	cTitGrf := "TITULOS"
	cTitGrf1:= "TITULOS"
	oExcel:AddworkSheet(cTitGrf)
	oExcel:AddTable (cTitGrf,cTitGrf1)

	oExcel:AddColumn(cTitGrf,cTitGrf1,"DTEMISSAO",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"CLIENTE",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"LOJA",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"NOME",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"CODVEND",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"NOMEVEND",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"PREFIXO",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"TITULO",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"PARCELA",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"VALOR",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"DTVENCIMENTO",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"SALDOTITULO",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"DTBAIXA",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"TIPOPER",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"PERCCOM",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"VLRCOM",1,1,.F.)

    (_cQry)->(dbGoTop())
	while !(_cQry)->(EOF())

				aDadosExc := {}
				aadd(aDadosExc,DTOC(STOD((_cQry)->DT_EMISSAO)))
				aadd(aDadosExc,(_cQry)->COD_CLI)
				aadd(aDadosExc,(_cQry)->LOJA_CLI)
                aadd(aDadosExc,(_cQry)->NOME_CLI)
				aadd(aDadosExc,(_cQry)->COD_VEND)
				aadd(aDadosExc,(_cQry)->NOME_VEND)
				aadd(aDadosExc,(_cQry)->PREFIXO)
				aadd(aDadosExc,(_cQry)->NUMERO)
                aadd(aDadosExc,(_cQry)->PARCELA)
				aadd(aDadosExc,(_cQry)->VALOR)
				aadd(aDadosExc,(_cQry)->DT_VENCIMENTO)
                aadd(aDadosExc,(_cQry)->E1_SALDO)
                aadd(aDadosExc,(_cQry)->DT_BAIXA)
                aadd(aDadosExc,(_cQry)->TIP_OPER)
                aadd(aDadosExc,(_cQry)->PERC_COM)
                aadd(aDadosExc,(_cQry)->VLR_COM)
				oExcel:AddRow(cTitGrf,cTitGrf1,aDadosExc)
		(_cQry)->(dbSkip())
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
Gera arquivo de trabalho
*/
Static function GeraArq()

	BeginSql alias _cQry
		%noparser%
        SELECT
            SUBSTRING(E1_EMISSAO,7,2)+'/'+SUBSTRING(E1_EMISSAO,5,2)+'/'+SUBSTRING(E1_EMISSAO,1,4) DT_EMISSAO
            , E1_CLIENTE COD_CLI
            , E1_LOJA LOJA_CLI
            , E1_NOMERAZ NOME_CLI
            , E1_VEND1 COD_VEND
            , A3_NOME NOME_VEND
            , E1_PREFIXO PREFIXO
            , E1_NUM NUMERO
            , E1_PARCELA PARCELA
            , E1_VALOR VALOR
            , SUBSTRING(E1_VENCREA,7,2)+'/'+SUBSTRING(E1_VENCREA,5,2)+'/'+SUBSTRING(E1_VENCREA,1,4) DT_VENCIMENTO
            , E1_SALDO
            , SUBSTRING(E1_BAIXA,7,2)+'/'+SUBSTRING(E1_BAIXA,5,2)+'/'+SUBSTRING(E1_BAIXA,1,4) DT_BAIXA
            , D2_TIPOPER TIP_OPER
            , ISNULL(E3_PORC,0) PERC_COM
            , ISNULL(E3_COMIS,0) VLR_COM
        FROM SE1010 SE1 (NOLOCK)
        INNER JOIN SD2010 SD2 (NOLOCK) ON SD2.D_E_L_E_T_ = '' AND D2_DOC = E1_NUM and D2_SERIE = E1_PREFIXO 
                                        AND D2_CLIENTE = E1_CLIENTE AND D2_TIPOPER = 'VC'
        INNER JOIN SA3010 SA3 (NOLOCK) ON SA3.D_E_L_E_T_ = '' AND A3_COD = E1_VEND1
        LEFT JOIN  SE3010 SE3 (NOLOCK) ON SE3.D_E_L_E_T_ = '' AND E3_NUM = E1_NUM AND E3_PREFIXO = E1_PREFIXO 
                                        AND E3_PARCELA = E1_PARCELA  AND E3_CODCLI = E1_CLIENTE AND E3_LOJA = E1_LOJA
        WHERE SE1.D_E_L_E_T_ = ''
            AND E1_BAIXA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
            AND E1_VEND1 BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
            AND E1_CLIENTE BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
        GROUP BY E1_EMISSAO, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMERAZ, E1_VEND1
                ,A3_NOME, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_VALOR, E1_VENCREA, E1_SALDO, E1_BAIXA, D2_TIPOPER
                , E3_PORC, E3_COMIS
        ORDER BY E1_NUM, E1_PARCELA
    EndSql

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
	local _cQrySX1 := "SX1"

	OpenSxs(,,,,FWCodEmp(),_cQrySX1,"SX1",,.F.)
	dbSelectArea(_cQrySX1)
	(_cQrySX1)->(dbSetOrder(1))
		
		_cPerg := PADR(_cPerg,len((_cQrySX1)->X1_GRUPO))
		_aTam  := TamSX3("E1_BAIXA")
		AADD(_aRegs,{_cPerg,"01","Baixa Tit De?"        ,"","","mv_ch1",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"",""})
		AADD(_aRegs,{_cPerg,"02","Baixa Tit Até?"       ,"","","mv_ch2",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"",""})
		_aTam  := TamSX3("A3_COD")
		AADD(_aRegs,{_cPerg,"03","Vendedor De?"        ,"","","mv_ch2",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA3"   ,"",""})
		AADD(_aRegs,{_cPerg,"04","Vendedor Até?"       ,"","","mv_ch3",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SA3"   ,"",""})
		_aTam  := TamSX3("A1_COD")
		AADD(_aRegs,{_cPerg,"05","Cliente De?"        ,"","","mv_ch4",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SA1"   ,"",""})
		AADD(_aRegs,{_cPerg,"06","Cliente Até?"       ,"","","mv_ch5",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SA1"   ,"",""})
	
    for i := 1 to len(_aRegs)
		if !(_cQrySX1)->(dbSeek(_cPerg+_aRegs[i,2]))
			while !RecLock(_cQrySX1,.T.) ; enddo
				for j := 1 to FCount()
					if j <= Len(_aRegs[i])
						FieldPut(j,_aRegs[i,j])
					else
						Exit
					endif
				next
			(_cQrySX1)->(MsUnLock())
		endif
	next
	RestArea(_aArea)
return
