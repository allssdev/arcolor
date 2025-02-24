#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} RCOMR004
@description Relatório resumo de compras por data de entrega.
@author Adriano L. de Souza
@since 13/12/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RCOMR004()
	// Régua - colunas
	//           PEDIDO EMISSAO    DT ENTREGA ANTECIPADO FORNECEDOR LOJA RAZAO                                    COND. PAGTO     VALOR ICMS      VALOR IPI  TOTAL MERCADORIA
	//XXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXX     XX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXX         XXXXXXXXXXXXXX XXXXXXXXXXXXXX    XXXXXXXXXXXXXX
	//00     07         18         29         40         51   56                                       97          109            124               142                           
	Private cabec1   := "PEDIDO   EMISSAO      DT ENTREGA   NOVA DATA    FORNECEDOR   LOJA   RAZAO                                      COND. PAGTO       VALOR ICMS        VALOR IPI       TOTAL MERCADORIA    TOTAL C/ IMP"
	Private cabec2   := ""
	Private cabec3   := ""
	Private wnrel    := "RCOMR004"
	Private Titulo   := "Resumo de compras - Por data de entrega"
	Private cDesc1   := "Este programa irá emitir a"
	Private cDesc2   := "o resumo de compras por data de entrega."
	Private cDesc3   := ""
	Private cString  := "SD4"
	Private nLastKey := 0
	Private aReturn  := { "Especial", 1,"Compras", 2, 1, 1, "",1 }
	Private nomeprog := "RCOMR004"
	Private cPerg    := "RCOMR004"
	Private _nLin    := 100
	Private m_pag    := 1
	Private aOrd	 := {}
	Private tamanho  := "G"
	Private nTipo    := 18
	Private _cAlias  := GetNextAlias()
	Private _nTotIcm := 0 //Total de ICMS
	Private _nTotIpi := 0 //Total de IPI
	Private _nTotMer := 0 //Valor total de mercadoria
	Private _nTotGer := 0 //Valor total com impostos
	// Verifica as perguntas selecionadas
	ValidPerg()
	pergunte(cPerg,.F.)
	// Envia controle para a funcao SETPRINT
	Titulo += " (" + DTOC(MV_PAR01) + " - " + DTOC(MV_PAR02) + ")"
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,"","","",.F.)
	If nLastKey == 27
		Return
	Endif
	SetDefault(aReturn,cString)
	If nLastKey == 27
		Return
	Endif
	// Rotina RptDetail
	RptStatus({|| RptDetail()})
return
/*/{Protheus.doc} RptDetail
@description Cria a área de trabalho do relatório.
@author Adriano L. de Souza
@since 13/12/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function RptDetail()
	BeginSql Alias _cAlias
		SELECT SC7.C7_NUM, SC7.C7_EMISSAO, SC7.C7_DATPRF, SC7.C7_ANTEPRO, SC7.C7_FORNECE, SC7.C7_LOJA, SA2.A2_NOME, SC7.C7_COND, SUM(SC7.C7_VALICM) AS [C7_VALICM], SUM(SC7.C7_VALIPI) AS [C7_VALIPI], SUM(SC7.C7_TOTAL) AS [C7_TOTAL], CASE WHEN SC7.C7_ANTEPRO<>'' THEN SC7.C7_ANTEPRO ELSE SC7.C7_DATPRF END AS [DT_ENTREG], (SUM(SC7.C7_VALIPI) + SUM(SC7.C7_TOTAL)) AS [TTLCIMP] 
		FROM %table:SC7% SC7 (NOLOCK)
			INNER JOIN %table:SB1% SB1 (NOLOCK) ON SB1.B1_FILIAL = %xFilial:SB1%
									AND SB1.B1_COD    = SC7.C7_PRODUTO
									AND SB1.%NotDel%
			INNER JOIN %table:SA2% SA2 (NOLOCK) ON SA2.A2_FILIAL = %xFilial:SA2%
									AND SA2.A2_COD    = SC7.C7_FORNECE
									AND SA2.A2_LOJA   = SC7.C7_LOJA
									AND SA2.%NotDel%
			WHERE SC7.C7_FILIAL = %xFilial:SC7%
				AND SC7.C7_FORNECE BETWEEN %Exp:(MV_PAR03)% AND %Exp:(MV_PAR04)%
				AND ((SC7.C7_DATPRF BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)% OR SC7.C7_ANTEPRO BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%) OR (SC7.C7_DATPRF BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)% AND SC7.C7_ANTEPRO=''))
				AND SC7.C7_PRODUTO BETWEEN %Exp:(MV_PAR05)% AND %Exp:(MV_PAR06)%
				AND SB1.B1_TIPO BETWEEN %Exp:(MV_PAR07)% AND %Exp:(MV_PAR08)%
				AND SC7.%NotDel%
		GROUP BY SC7.C7_NUM, SC7.C7_EMISSAO, SC7.C7_DATPRF, SC7.C7_ANTEPRO, SC7.C7_FORNECE, SC7.C7_LOJA, SA2.A2_NOME, SC7.C7_COND
		ORDER BY C7_NUM, DT_ENTREG
	EndSql
	nOrdem := aReturn[8]
	dbSelectArea(_cAlias)
	(_cAlias)->(dbSetOrder(0))
	(_cAlias)->(dbGoTop())
	_cFornAtu := (_cAlias)->C7_FORNECE //Variável auxiliar para avaliar a mudança de fornecedor
	//Totalizadores por fornecedor
	_nTotFIcm := 0
	_nTotFIpi := 0
	_nTotFMer := 0
	_nTotFGer := 0
	While !(_cAlias)->(EOF())
		If lAbortPrint
			@ 00,00 PSay "CANCELADO PELO OPERADOR"
			Exit
		EndIf
		// Imprime o cabeçalho
		If _nLin > 70
			_nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		EndIf
		_nLin++
		If MV_PAR09==1
			If _cFornAtu <> (_cAlias)->C7_FORNECE
				_nLin++
				// Impressão dos subtotais por fornecedor
				@ _nLin, 000 PSay Replicate("_",220)
				_nLin++
				@ _nLin, 000 PSay "SUBTOTAL:"
				@ _nLin, 125 PSay _nTotFIcm Picture PesqPict("SC7","C7_VALICM")
				@ _nLin, 142 PSay _nTotFIpi Picture PesqPict("SC7","C7_VALIPI")
				@ _nLin, 162 PSay _nTotFMer Picture PesqPict("SC7","C7_TOTAL")
				@ _nLin, 179 PSay _nTotFGer Picture PesqPict("SC7","C7_TOTAL")
				_cFornAtu := (_cAlias)->C7_FORNECE //Variável auxiliar para avaliar a mudança de fornecedor
				//Totalizadores por fornecedor
				_nTotFIcm := 0
				_nTotFIpi := 0
				_nTotFMer := 0
				_nTotFGer := 0
				_nLin+=2
			EndIf
		EndIf
	   // Impressão dos resultados
		@ _nLin, 000 PSay SubStr((_cAlias)->C7_NUM,1,6)
		@ _nLin, 009 PSay StoD((_cAlias)->C7_EMISSAO)
		@ _nLin, 022 PSay StoD((_cAlias)->C7_DATPRF)
		@ _nLin, 035 PSay StoD((_cAlias)->C7_ANTEPRO)
		@ _nLin, 048 PSay SubStr((_cAlias)->C7_FORNECE,1,6)
		@ _nLin, 061 PSay SubStr((_cAlias)->C7_LOJA,1,2)
		@ _nLin, 069 PSay SubStr((_cAlias)->A2_NOME,1,40)
		@ _nLin, 111 PSay SubStr((_cAlias)->C7_COND,1,3)
		@ _nLin, 125 PSay (_cAlias)->C7_VALICM Picture PesqPict("SC7","C7_VALICM")
		@ _nLin, 142 PSay (_cAlias)->C7_VALIPI Picture PesqPict("SC7","C7_VALIPI")
		@ _nLin, 162 PSay (_cAlias)->C7_TOTAL  Picture PesqPict("SC7","C7_TOTAL")
		@ _nLin, 179 PSay (_cAlias)->TTLCIMP   Picture PesqPict("SC7","C7_TOTAL")
		_nTotIcm += (_cAlias)->C7_VALICM
		_nTotIpi += (_cAlias)->C7_VALIPI
		_nTotMer += (_cAlias)->C7_TOTAL
		_nTotGer += (_cAlias)->TTLCIMP
		_nTotFIcm += (_cAlias)->C7_VALICM
		_nTotFIpi += (_cAlias)->C7_VALIPI
		_nTotFMer += (_cAlias)->C7_TOTAL
		_nTotFGer += (_cAlias)->TTLCIMP
		dbSelectArea(_cAlias)
		(_cAlias)->(dbSetOrder(0))
		(_cAlias)->(dbSkip())
	enddo
	if _nLin > 65
		_nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	endif
	_nLin++
	// Impressão dos subtotais
	@ _nLin, 000 PSay Replicate("_",220)
	_nLin	++
	@ _nLin, 000 PSay "TOTAL GERAL:"
	@ _nLin, 125 PSay _nTotIcm Picture PesqPict("SC7","C7_VALICM")
	@ _nLin, 142 PSay _nTotIpi Picture PesqPict("SC7","C7_VALIPI")
	@ _nLin, 162 PSay _nTotMer Picture PesqPict("SC7","C7_TOTAL")
	@ _nLin, 179 PSay _nTotGer Picture PesqPict("SC7","C7_TOTAL")
	if Select(_cAlias) > 0
		dbSelectArea(_cAlias)
		(_cAlias)->(dbCloseArea())
	endif
	SET DEVICE TO SCREEN
	// Se saída para disco, ativa SPOOL
	If aReturn[5] == 1
		Set Printer TO
		dbcommitAll()
		ourSpool(wnRel)
	EndIf
	MS_FLUSH()
return
/*/{Protheus.doc} ValidPerg
@description Valida se as perguntas já existem no arquivo SX1 e caso não encontre as cria no arquivo.
@author Adriano L. de Souza
@since 13/12/2013
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
	_aTam            := TamSx3("C7_DATPRF" )
	AADD(aRegs,{cPerg,"01","De data?" 	   				,"","","mv_ch1",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par01",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""	 ,""})
	AADD(aRegs,{cPerg,"02","Até data?"	   				,"","","mv_ch2",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par02",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""	 ,""})
	_aTam            := TamSx3("C7_FORNECE")
	AADD(aRegs,{cPerg,"03","De fornecedor?" 			,"","","mv_ch3",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par03",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SA2" ,""})
	AADD(aRegs,{cPerg,"04","Até fornecedor?"			,"","","mv_ch4",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par04",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SA2" ,""})
	_aTam            := TamSx3("C7_PRODUTO")
	AADD(aRegs,{cPerg,"05","De produto?" 				,"","","mv_ch5",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par05",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SB1" ,""})
	AADD(aRegs,{cPerg,"06","Até produto?"				,"","","mv_ch6",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par06",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SB1" ,""})
	_aTam            := TamSx3("B1_TIPO"   )
	AADD(aRegs,{cPerg,"07","De tipo?" 	   				,"","","mv_ch7",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par07",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""	 ,""})
	AADD(aRegs,{cPerg,"08","Até tipo?"					,"","","mv_ch8",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par08",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""	 ,""})
	_aTam            := {1,0,"N"}
	AADD(aRegs,{cPerg,"09","Totaliza por Fornecedor?"	,"","","mv_ch9",_aTam[3],_aTam[1],_aTam[2],0,"C",""          ,"mv_par09","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","",""	 ,""})
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