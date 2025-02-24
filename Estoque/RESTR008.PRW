#include 'totvs.ch'
#include 'rwmake.ch'
#include 'protheus.ch'
#include 'apwizard.ch'
#include 'fileio.ch'
#include 'rptdef.ch'
#include 'fwprintsetup.ch'
#include 'parmtype.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'
#include 'fwmvcdef.ch'
#include 'olecont.ch'

/*/{Protheus.doc} 
@description Relatorio de faturamento com custeio
@author		Diego Rodrigues Pereira email: diego.rodrigues@allss.com.br
@since 		16/07/2024
@version 	1.01
@see 		https://allss.com.br
@History 	
/*/

User function RESTR008()

	Private _cRotina  	:= "RESTR008" // Coloque aqui o nome do programa para impressao no cabecalho
	Private _cPerg      := "RESTR008"
    Private _cQry  		:= GetNextAlias()
	private lBlind 		:= IsBlind()

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

	Local cArqExcel		:= "Relatorio_faturamento_"+dtos(ddatabase)+".xls"
	Local cPathExcel	:= "c:\relato\"
	
	SB1->(dbSetOrder(1))

	oExcel := FWMSEXCEL():New()
	cTitGrf := "PRODUTOS"
	cTitGrf1:= "PRODUTOS"
	oExcel:AddworkSheet(cTitGrf)
	oExcel:AddTable (cTitGrf,cTitGrf1)

	oExcel:AddColumn(cTitGrf,cTitGrf1,"DTEMISSAO",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"TIPO_NF",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"TP_OPERACAO",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"CFOP",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"NOTA FISCAL",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"SERIE NF",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"CLIENTE",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"LOJA",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"NOME CLIENTE",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"NATUREZA",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"CONTA CONTABIL",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"COD REPRESENTANTE",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"NOME REPRESENTANTE",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"VALOR MERCADO",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"VALOR BRUTO",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"VALOR ICM",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"VALOR IPI",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"VALOR COFINS",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"VALOR PIS",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"VALOR ICMSRET",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"DESPESAS",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"CUSTO NF",1,1,.F.)

	//oExcel:AddColumn(cTitGrf,cTitGrf1,"DESTINACAO",1,1,.F.)

    (_cQry)->(dbGoTop())
	while !(_cQry)->(EOF())

				aDadosExc := {}
                
				aadd(aDadosExc,DTOC(STOD((_cQry)->EMISSAO)))
				aadd(aDadosExc,(_cQry)->TIPO_NF)
				aadd(aDadosExc,(_cQry)->TP_OPERACAO)
                aadd(aDadosExc,(_cQry)->CFOP)
                aadd(aDadosExc,(_cQry)->NOTAFISCAL)
				aadd(aDadosExc,(_cQry)->SERIENF)
				aadd(aDadosExc,(_cQry)->CLIENTE)
				aadd(aDadosExc,(_cQry)->LOJA)
				aadd(aDadosExc,(_cQry)->NOME)
                aadd(aDadosExc,(_cQry)->NATUREZA)
				aadd(aDadosExc,(_cQry)->CONTA_CONTABIL)
                aadd(aDadosExc,(_cQry)->COD_REPRESENTANTE)
                aadd(aDadosExc,(_cQry)->NOME_REPRESENTANTE)
                aadd(aDadosExc,(_cQry)->VALOR_MERCADO)
                aadd(aDadosExc,(_cQry)->VALOR_BRUTO)
                aadd(aDadosExc,(_cQry)->VALOR_ICM)
                aadd(aDadosExc,(_cQry)->VALOR_IPI)
                aadd(aDadosExc,(_cQry)->VALOR_COFINS)
                aadd(aDadosExc,(_cQry)->VALOR_PIS)
                aadd(aDadosExc,(_cQry)->VALOR_ICMSRET)
                aadd(aDadosExc,(_cQry)->DESPESAS)
                aadd(aDadosExc,(_cQry)->CUSTO_NF)

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
            SUBSTRING(F2_EMISSAO,7,2)+'/'+SUBSTRING(F2_EMISSAO,5,2)+'/'+SUBSTRING(F2_EMISSAO,1,4) EMISSAO
            ,F2_TIPO TIPO_NF
            ,C5_TPOPER TP_OPERACAO
            ,D2_CF CFOP
            ,F2_DOC NOTAFISCAL
            ,F2_SERIE SERIENF
            ,F2_CLIENTE CLIENTE
            ,F2_LOJA LOJA
            ,A1_NOME NOME
            ,A1_NATUREZ NATUREZA
            ,A1_CONTA CONTA_CONTABIL
            ,F2_VEND1 COD_REPRESENTANTE
            ,A3_NOME NOME_REPRESENTANTE
            ,SUM(D2_TOTAL) VALOR_MERCADO
            ,SUM(D2_TOTAL)+SUM(D2_VALIPI)+SUM(D2_ICMSRET) VALOR_BRUTO
            ,SUM(D2_VALICM) VALOR_ICM
            ,SUM(D2_VALIPI) VALOR_IPI
            ,SUM(D2_VALIMP5) VALOR_COFINS
            ,SUM(D2_VALIMP6) VALOR_PIS
            ,SUM(D2_ICMSRET) VALOR_ICMSRET
            ,SUM(D2_DESPESA) DESPESAS
            ,SUM(D2_CUSTO1) CUSTO_NF
        FROM SF2010 SF2 (NOLOCK)
        INNER JOIN SA1010 SA1 (NOLOCK) ON SA1.D_E_L_E_T_ = '' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA
        INNER JOIN SA3010 SA3 (NOLOCK) ON SA3.D_E_L_E_T_ = '' AND A3_COD = F2_VEND1
        INNER JOIN SD2010 SD2 (NOLOCK) ON SD2.D_E_L_E_T_ = '' AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE 
                                        AND D2_LOJA = F2_LOJA
        INNER JOIN SC5010 SC5 (NOLOCK) ON SC5.D_E_L_E_T_ = '' AND C5_NUM = D2_PEDIDO
        WHERE SF2.D_E_L_E_T_ = ''
        AND SF2.F2_EMISSAO BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
        //AND SF2.F2_CLIENTE BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
        GROUP BY F2_EMISSAO,F2_TIPO,C5_TPOPER,D2_CF,F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA,A1_NOME,A1_NATUREZ,A1_CONTA,F2_VEND1,A3_NOME
        ORDER BY F2_EMISSAO, F2_DOC
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
		_aTam  := TamSX3("F2_EMISSAO")
		AADD(_aRegs,{_cPerg,"01","Emissao De?"        ,"","","mv_ch1",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"",""})
		AADD(_aRegs,{_cPerg,"02","Emissao Ate?"        ,"","","mv_ch2",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"",""})
	
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
