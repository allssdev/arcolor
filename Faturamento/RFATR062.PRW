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
@description Relatorio de divergencia de quantidades separadas para quantidades faturadas
@author		Diego Rodrigues Pereira email: diego.rodrigues@allss.com.br
@since 		26/08/2023
@version 	1.01
@see 		https://allss.com.br
@History 	
/*/

User function RFATR062()

	Private _cRotina  	:= "RFATR062" // Coloque aqui o nome do programa para impressao no cabecalho
	Private _cPerg      := "FATR62"
	Private _lRCFGM001 	:= ExistBlock("RCFGM001")
    Private _cQry  		:= GetNextAlias()
	private lBlind 		:= IsBlind()

	if lBlind
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" TABLES "SC9", "SC6", "CB9","CB8","CB7", "SD2"
			MV_PAR01 := Dtos(dDataBase)
			MV_PAR02 := Dtos(dDataBase)
			
			MsAguarde({|| GeraArq()}," Gerando Arquivo de Trabalho... ")
			MsAguarde({|| ExpExcel()}," Exportando Excel... ")
		(_cQry)->(dbCloseArea())
		
	else

		ValidPerg()
		//AjustaSX1(cPerg)
		If !pergunte(_cPerg,.T.)
			Return
		EndIf

			MsAguarde({|| GeraArq()}," Gerando Arquivo de Trabalho... ")
			MsAguarde({|| ExpExcel()}," Exportando Excel... ")

		(_cQry)->(dbCloseArea())
	ENDIF
	RESET ENVIRONMENT	
return

/*
Exporta os Dados para o Excel  
*/
Static function ExpExcel()

	Local _cTitulo   := "Divergência Itens Separados versus Nota Fiscal"
	Local _cMsg		 := ""
	Local _cFromOri  := ""
	local _cMail     := AllTrim(SuperGetMv("MV_XRELDIV",,"diego.rodrigues@allss.com.br"))
	//Local cArqExcel		:= "produtos_divegencia.xls"
	//Local cPathExcel	:= "c:\relato\"
	
	SB1->(dbSetOrder(1))

	oExcel := FWMSEXCEL():New()
	cTitGrf := "PRODUTOS"
	cTitGrf1:= "PRODUTOS"
	oExcel:AddworkSheet(cTitGrf)
	oExcel:AddTable (cTitGrf,cTitGrf1)

	oExcel:AddColumn(cTitGrf,cTitGrf1,"PEDIDO",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"DTEMISSAO",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"ORDSEP",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"PRODUTO",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"DESCRICAO",1,1,.F.)
	//oExcel:AddColumn(cTitGrf,cTitGrf1,"LOTE SEPARADO",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"QTD VENDIDA",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"QTD ENTREGUE",1,1,.F.)
    oExcel:AddColumn(cTitGrf,cTitGrf1,"QTD SEPARADA",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"VALOR PEDIDO",1,1,.F.)
	oExcel:AddColumn(cTitGrf,cTitGrf1,"VALOR SEPARADO",1,1,.F.)

	//oExcel:AddColumn(cTitGrf,cTitGrf1,"DESTINACAO",1,1,.F.)

    (_cQry)->(dbGoTop())
	while !(_cQry)->(EOF())

				SB1->(dbSeek(xFilial("SB1")+(_cQry)->PRODUTO))

				aDadosExc := {}
                
				aadd(aDadosExc,DTOC(STOD((_cQry)->PEDIDO)))
				aadd(aDadosExc,(_cQry)->EMISSAO)
				aadd(aDadosExc,(_cQry)->ORDSEP)
                aadd(aDadosExc,(_cQry)->PRODUTO)
                aadd(aDadosExc,SB1->B1_DESC)
				//aadd(aDadosExc,(_cQry)->LOTESEP)
				aadd(aDadosExc,(_cQry)->QTDVEN)
				aadd(aDadosExc,(_cQry)->QTDENT)
				aadd(aDadosExc,(_cQry)->QTDSEP)
                aadd(aDadosExc,(_cQry)->VLRPEDIDO)
				aadd(aDadosExc,(_cQry)->VLRSEPARADO)

				oExcel:AddRow(cTitGrf,cTitGrf1,aDadosExc)

		(_cQry)->(dbSkip())
		IncProc("Gerando dados para planilha Excel")
	Enddo


	// Faco a chamada da geracao do arquivo
	// XML

	oExcel:Activate()
	//Pego o caminho da pasta de temporários da máquina do usuário
	_cDirTmp := "\system\" //GetTempPath()
	//Defino o nome do arquivo do Excel a ser gerado
	_cArq    := "Div_Separados_Notas_"  + dToS(dDataBase) + "_" + StrTran(Time(), ':', '-') +".xml"
	//Gero o Excel com o nome que defini anteriormente no servidor
	oExcel:GetXmlFile(_cArq)
	oExcel:DeActivate()
	//Se o arquivo foi criado com sucesso, copio para a pasta temporária na máquina do usuário
	If File(_cArq)
		If _lRCFGM001 //RCFGM001(Titulo,_cMsg,_cMail,_cAnexo,_cFromOri,_cBCC,_cAssunto,_lExcAnex,_lAlert)
			U_RCFGM001(_cTitulo,_cMsg,_cMail,"\system\"+_cArq,_cFromOri,"diego.rodrigues@allss.com.br","[Arcolor] - Analise de divergencias entre produtos separados e nota fiscal" ) //Chamada da rotina responsável pelo envio de e-mails
		EndIf
		//Apago o arquivo de Excel original do Servidor                
		FErase(_cArq)
	EndIf
	/*
	oExcel:GetXMLFile(cPathExcel + cArqExcel)
	oExcel:DeActivate()

	// Faco a chamada da classe MsExcel para abertura
	// do arquivo
	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open(cPathExcel + cArqExcel)// Abre uma planilha
	oExcelApp:SetVisible(.T.)
	oExcelApp:Destroy()
	*/
return Nil


/*
Gera arquivo de trabalho
*/
Static function GeraArq()

	BeginSql alias _cQry
		%noparser%
			SELECT
						C6_NUM PEDIDO
						, SEPARADOS.CB7_DTINIS EMISSAO
						, SEPARADOS.CB9_ORDSEP ORDSEP
						, SEPARADOS.CB9_PROD PRODUTO
						, C6_QTDVEN QTDVEN
						, C6_QTDENT QTDENT
						, QTDSEPARADAS.QTDSEP QTDSEP
						, C6_PRCVEN PRCPEDIDO
						, C6_VALOR VLRPEDIDO
						, ROUND(QTDSEPARADAS.QTDSEP,2) * C6_PRCVEN AS VLRSEPARADO
			//		, CASE WHEN NOTA.C9_NFISCAL = '' THEN 'SEPARANDO' ELSE 'DIVERGENTE' END STATUS
			FROM
			SC6010 SC6 (NOLOCK)
			,(
				SELECT 
				CB7_DTINIS,CB9_ORDSEP, CB9_PEDIDO, CB9_PROD,CB9_LOTECT
				FROM CB9010 CB9 (NOLOCK)
				INNER JOIN CB7010 CB7 (NOLOCK) ON CB7.D_E_L_E_T_ = '' AND CB7_PEDIDO = CB9_PEDIDO 
												AND CB7_ORDSEP = CB9_ORDSEP AND CB7_DTEMIS >= %Exp:MV_PAR01% AND CB7_DTEMIS <= %Exp:MV_PAR02%
				INNER JOIN SC9010 SC9 (NOLOCK) ON SC9.D_E_L_E_T_ = '' AND C9_ORDSEP = CB9_ORDSEP AND C9_PEDIDO = CB9_PEDIDO 
				AND C9_PRODUTO = CB9_PROD 
				WHERE
				CB9.D_E_L_E_T_ = ''
				//AND CB9_PEDIDO = '413282'
				AND NOT EXISTS (
								SELECT	TOP 1 1
								FROM SD2010 SD2 (NOLOCK)
								WHERE SD2.D_E_L_E_T_ = ''
								AND D2_COD = CB9_PROD
								AND D2_LOTECTL = CB9_LOTECT
								AND D2_PEDIDO = CB9_PEDIDO
								AND D2_EMISSAO = CB7_DTFIMS
								) 
				GROUP BY 
				CB7_DTINIS,CB9_ORDSEP, CB9_PEDIDO, CB9_PROD,CB9_LOTECT
			) SEPARADOS
			,
			(
				SELECT 
				CB9_ORDSEP, CB9_PEDIDO, CB9_PROD,SUM(CB9_QTESEP) QTDSEP
				FROM CB9010 CB9 (NOLOCK)
				WHERE CB9.D_E_L_E_T_ = ''
				GROUP BY CB9_ORDSEP, CB9_PEDIDO, CB9_PROD
			) QTDSEPARADAS
			,
			(
				SELECT 
				CB8_ORDSEP, CB8_PEDIDO,SUM(CB8_SALDOS) SALDO
				FROM CB8010 CB8 (NOLOCK)
				WHERE CB8.D_E_L_E_T_ = ''
				GROUP BY CB8_ORDSEP, CB8_PEDIDO
			) OSFINALIZADA

			,
			(
				SELECT 
				C9_PEDIDO, C9_NFISCAL,C9_ORDSEP
				FROM SC9010 SC9 (NOLOCK)
				WHERE SC9.D_E_L_E_T_ = ''
				GROUP BY C9_PEDIDO, C9_NFISCAL,C9_ORDSEP
			) NOTA

			WHERE 	SC6.D_E_L_E_T_ = '' 
					AND SC6.C6_NUM = SEPARADOS.CB9_PEDIDO
					AND SC6.C6_PRODUTO = SEPARADOS.CB9_PROD
					AND SC6.C6_QTDVEN <> C6_QTDENT
					AND SC6.C6_NUM = QTDSEPARADAS.CB9_PEDIDO
					AND SEPARADOS.CB9_ORDSEP = QTDSEPARADAS.CB9_ORDSEP
					AND SC6.C6_PRODUTO = QTDSEPARADAS.CB9_PROD
					AND SC6.C6_NUM = OSFINALIZADA.CB8_PEDIDO
					AND SEPARADOS.CB9_ORDSEP = OSFINALIZADA.CB8_ORDSEP
					AND NOTA.C9_ORDSEP = SEPARADOS.CB9_ORDSEP
					AND NOTA.C9_PEDIDO = SC6.C6_NUM
					AND CASE WHEN NOTA.C9_NFISCAL = '' THEN 1 ELSE 0 END = 0
			GROUP BY C6_NUM, SEPARADOS.CB7_DTINIS,SEPARADOS.CB9_ORDSEP, SEPARADOS.CB9_PROD
			, C6_QTDVEN, C6_QTDENT, QTDSEPARADAS.QTDSEP,C6_PRCVEN, C6_VALOR, QTDSEPARADAS.QTDSEP
			, OSFINALIZADA.SALDO, NOTA.C9_NFISCAL
			ORDER BY C6_NUM
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
