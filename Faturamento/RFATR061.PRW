#INCLUDE "rwmake.ch"

/*/{Protheus.doc} 
@description Relatorio de notas fiscais e produtos cancelados
@author		Diego Rodrigues Pereira email: diego.rodrigues@allss.com.br
@since 		26/06/2023
@version 	1.01
@see 		https://allss.com.br
@History 	
/*/

User function RFATR061()

	Private _cRotina  := "RFATR061" // Coloque aqui o nome do programa para impressao no cabecalho
	Private _cPerg      := "FATR61"
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

	Local cArqExcel		:= "Itens_cancelados.xls"
	Local cPathExcel	:= "c:\relato\"
	
	SB1->(dbSetOrder(1))

	oExcel := FWMSEXCEL():New()
	cTitGrf := "PRODUTOS"
	cTitGrf1:= "PRODUTOS"
	oExcel:AddworkSheet(cTitGrf)
	oExcel:AddTable (cTitGrf,cTitGrf1)

	oExcel:AddColumn(cTitGrf,cTitGrf1,"DTEMISSAO",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"NOTA",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"SERIE",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"PEDIDO",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"CLIENTE",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"LOJA",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"NOME",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"PRODUTO",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"DESCRICAO PRODUTO",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"LOTE",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"QUANTIDADE",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"CONFERENTE",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"MOTIVO",1,1,.F.)
	//oExcel:AddColumn(cTitGrf,cTitGrf1,"DESTINACAO",1,1,.F.)

    (_cQry)->(dbGoTop())
	while !(_cQry)->(EOF())

				SB1->(dbSeek(xFilial("SB1")+(_cQry)->PRODUTO))

				aDadosExc := {}
                
				aadd(aDadosExc,DTOC(STOD((_cQry)->EMISSAO)))
				aadd(aDadosExc,(_cQry)->NOTA)
				aadd(aDadosExc,(_cQry)->SERIE)
                aadd(aDadosExc,(_cQry)->PEDIDO)
				aadd(aDadosExc,(_cQry)->CLIENTE)
				aadd(aDadosExc,(_cQry)->LOJA)
				aadd(aDadosExc,(_cQry)->NOME)
				aadd(aDadosExc,(_cQry)->PRODUTO)
                aadd(aDadosExc,SB1->B1_DESC)
				aadd(aDadosExc,(_cQry)->LOTE)
				aadd(aDadosExc,(_cQry)->QUANT)
                aadd(aDadosExc,(_cQry)->CONFERENTE)
                aadd(aDadosExc,(_cQry)->MOTIVO)
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
        	F2_EMISSAO AS EMISSAO,
            F2_DOC AS NOTA,
            D2_PEDIDO AS PEDIDO,
            F2_SERIE AS SERIE,
            F2_CLIENTE AS CLIENTE,
            F2_LOJA AS LOJA,
            CASE WHEN F2_TIPO NOT IN ('D','B') THEN A1_NOME ELSE A2_NOME END AS [NOME],
            ISNULL(CONVERT(VARCHAR(2024), CONVERT(VARBINARY(2024),F2_MOTEXCL)),'') AS MOTIVO,
            D2_COD AS PRODUTO,
            D2_LOTECTL AS LOTE,
            D2_QUANT AS QUANT,
            SF2.F2_NOMCONF CONFERENTE
	    FROM SF2010 SF2
        INNER JOIN SD2010 SD2 ON SD2.D_E_L_E_T_ = '*' AND SD2.D2_FILIAL = %xFilial:SD2%
                              AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE  
                              AND F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA
        LEFT JOIN SA1010 SA1 ON SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = %xFilial:SA1%
                              AND SA1.A1_COD = F2_CLIENTE AND SA1.A1_LOJA = F2_LOJA
        LEFT JOIN SA2010 SA2 ON SA2.D_E_L_E_T_ = '' AND SA2.A2_FILIAL = %xFilial:SA2%
                              AND SA2.A2_COD = F2_CLIENTE AND SA2.A2_LOJA = F2_LOJA
        WHERE SF2.D_E_L_E_T_ = '*'
              AND SF2.F2_FILIAL = %xFilial:SF2%
              AND SF2.F2_EMISSAO BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
              AND SF2.F2_DOC BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
        ORDER BY F2_DOC
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
		_aTam  := TamSX3("F2_DOC")
		AADD(_aRegs,{_cPerg,"01","Nota fiscal De?"        ,"","","mv_ch1",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SF2"   ,"",""})
		AADD(_aRegs,{_cPerg,"02","Nota Fiscal Até?"        ,"","","mv_ch2",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SF2"   ,"",""})
		_aTam  := TamSX3("F2_EMISSAO")
		AADD(_aRegs,{_cPerg,"03","Emissao De?"        ,"","","mv_ch3",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"",""})
		AADD(_aRegs,{_cPerg,"04","Emissao Ate?"        ,"","","mv_ch4",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"",""})
	
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
