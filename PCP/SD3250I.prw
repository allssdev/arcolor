#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*/{Protheus.doc} SD3250I
@description Ponto de entrada após a gravação do consumo na SB3, após o apontamento da produção, utilizado para atualizar a tabela SZG (histório do consumo mensal - específico).
@author Adriano Leonardo
@since 11/12/2013
@version 1.0
@type function
@see https://allss.com.br
@history 14/10/2023/2023, Diego Rodrigues (diego.rodrigues@allss.com.br),Inclusão de validação para encerramento automatico de ordem de produção
/*/

User Function SD3250I()

//Salvo a área de trabalho atual
local _aSavArea  := GetArea()
local _aSavSD3	 := SD3->(GetArea())
local _aSavSB3	 := SB3->(GetArea())
local _aSavSZG	 := SZG->(GetArea())
local _aSavSC2	 := SC2->(GetArea())
local _aSavQPK	 := QPK->(GetArea())
//Variáveis auxiliares
local _cCampo	 := ""//"B3_Q" + STRZERO(MONTH(dDataBase),2) //Campo a ser utilizado como macro - Alterado por Renan em 08/09/2016 para utilizar a Data de emissao da tabela SD3 para os casos de apontamento parcial que ocorrem em meses diferentes.  
local lGrvSzg    := SuperGetMv("MV_GRVSZG" ,,.F.) 
//Local   _aUsrPcp := SuperGetMv("MV_XUSRPCP" ,,"000000" )
Local _cAliasSD3 := GetNextAlias()
Local _cProdPA := ""
Local _cQtdPA := ""
Local _cProdPI := ""
Local _cQtdPI := ""

Private _cRotina	 := "SD3250I"

If lGrvSzg //Determina se a gravação do histórico do consumo mensal está ativa na SZG (consumo médio - específico)
	dbSelectArea("SD3") //Movimentos internos
	SD3->(dbSetOrder(1))
	_cNumOP	:= SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + SC2->C2_ITEMGRD
	If SD3->(dbSeek(xFilial("SD3")+_cNumOP))
		While !SD3->(EOF()) .And. SD3->D3_OP == _cNumOP .And. SD3->D3_FILIAL==xFilial("SD3")
			_cCampo	 := "B3_Q" + SUBSTR(DtoS(SD3->D3_EMISSAO),5,2)//Alterado por Renan em 08/09/2016 - para que seja utilizado o mês conforme o campo da SD3 devido às divergencias na tabela SZG quando efetuado apontamento parcial. 
			dbSelectArea("SB3") // Demandas
			SB3->(dbSetOrder(1))
			SB3->(dbGoTop())
			If SB3->(dbSeek(xFilial("SB3")+SD3->D3_COD))
				u_reste009(SB3->B3_COD , (SB3->&_cCampo) ,_cRotina, SD3->D3_EMISSAO)					
			EndIf
			dbSelectArea("SD3")
			SD3->(dbSetOrder(1))
			SD3->(dbSkip())
		EndDo			
	EndIf				
EndIf

/*
//TRECHO COMENTADO PARA SER VALIDADO EM JANEIRO APÓS AS VALIDAÇÕES DE RASTREABILIDADE
//ATIVIDADO EM 13/02/2024
//Encerramento automatico
	if Select(_cAliasSD3) > 0
		(_cAliasSD3)->(dbCloseArea())
	endif

	BeginSql Alias _cAliasSD3
		SELECT
			SD3.D3_OP,SD3.D3_CF, SD3.D3_COD, SD3.D3_LOCAL ,SD3.D3_LOTECTL, SD3.D3_TIPO, SUM(D3_QUANT) D3_QUANT, SD3X.D3_QTDPI
		FROM SD3010 SD3 (NOLOCK)
		INNER JOIN SB5010 SB5 (NOLOCK) ON SB5.D_E_L_E_T_ = '' AND SB5.B5_FILIAL = SD3.D3_FILIAL AND 
							SB5.B5_COD = SD3.D3_COD AND B5_XENCAUT = '1'
		,	(SELECT D3_OP, D3_COD, D3_CF, D3_LOTECTL, SUM(D3_QUANT) D3_QTDPI
			FROM SD3010 SD3 (NOLOCK) 
			WHERE SD3.D_E_L_E_T_ = '' AND SD3.D3_ESTORNO = '' AND SD3.D3_OP = %Exp:M->D3_OP% AND SD3.D3_TIPO = 'PI'
			GROUP BY D3_OP, D3_COD, D3_CF, D3_LOTECTL ) SD3X
		WHERE SD3.D_E_L_E_T_ = ''
			AND D3_ESTORNO = ''
			AND SD3.D3_OP = %Exp:M->D3_OP%
			AND SD3.D3_OP = SD3X.D3_OP
			AND SD3.D3_QUANT = SD3X.D3_QTDPI
			AND SD3.D3_TIPO = 'PA'
		GROUP BY SD3.D3_OP,SD3.D3_CF, SD3.D3_COD, SD3.D3_LOCAL ,SD3.D3_LOTECTL, SD3.D3_TIPO,SD3X.D3_QTDPI
	EndSql
	//%Exp:SD3->D3_OP%
	dbSelectArea(_cAliasSD3)
	DbGoTop()
	While !(_cAliasSD3)->(EOF()) .and. M->D3_OP = (_cAliasSD3)->D3_OP
		U_RPCPE011((_cAliasSD3)->D3_OP, (_cAliasSD3)->D3_COD,(_cAliasSD3)->D3_LOCAL)
		(_cAliasSD3)->(dbSkip())
	EndDo
	(_cAliasSD3)->(dbCloseArea())
//Fim do encerramento automatico
*/
//Diego Rodrigues - 10/02/21 - Ponto para ativar a impressão das fichas automaticamente ao concluir o apontamento
if Upper(AllTrim(FunName())) == "MATA250" .and. M->D3_TIPO == 'PA' .and. M->D3_QUANT > 0 //.AND. Upper(AllTrim(__cUserId)) $ _aUsrPcp
		U_RESTR006()
		//MsgInfo("Foram processados 1 produtos.","RESTR006_001")
EndIf

//Diego Rodrigues - 24/06/21 - Ponto para ativar a impressão das fichas do PI automaticamente ao concluir o apontamento
if Upper(AllTrim(FunName())) == "MATA250" .and. M->D3_TIPO == 'PI' .and. M->D3_QUANT > 0 //.AND. Upper(AllTrim(__cUserId)) $ _aUsrPcp
		U_RESTR007()
		//MsgInfo("Foram processados 1 produtos.","RESTR007_002")
EndIf
/* AGUARDANDO DEFINIÇÃO DO CLIENTE PARA IMPLANTAÇÃO DO INSPEÇÃO DE PROCESSO.
//Inclusão do registro na QPK devido ao Protheus não permitir apontamento parcial quando utilizamos o modulo Inspeção de Processo
	BeginSql Alias "D3NUMSEQ"
		SELECT
			MAX(D3_NUMSEQ) D3_NUMSEQ
		FROM SD3010 SD3 (NOLOCK)
		WHERE SD3.D_E_L_E_T_ = ''
		AND SD3.D3_OP = %Exp:M->D3_OP%
	EndSql

dbSelectArea("D3NUMSEQ")
DbGoTop()
DbSelectArea("QPK")
QPK->(dbSetOrder(1)) //QPK_FILIAL+QPK_OP+QPK_LOTE+QPK_NUMSER+QPK_PRODUT+QPK_REVI
//If !QPK->(MsSeek(xFilial("QPK")+M->D3_OP+M->D3_LOTECTL+M->D3_XNRFICH+M->D3_COD,.T.))
	RecLock("QPK",.T.)
		QPK->QPK_FILIAL := cFilAnt
		QPK->QPK_OP     := M->D3_OP
		QPK->QPK_PRODUT := M->D3_COD
		QPK->QPK_REVI   := "00"
		QPK->QPK_LOCAL  := M->D3_LOCAL
		QPK->QPK_UM     := M->D3_UM
		QPK->QPK_TAMLOT := M->D3_QUANT
		QPK->QPK_LOTE   := M->D3_LOTECTL
		QPK->QPK_NUMSER := M->D3_XNRFICH
		//QPK->QPK_QTREJ  := 0
		QPK->QPK_DTPROD := M->D3_EMISSAO
		QPK->QPK_EMISSA := M->D3_EMISSAO
		QPK->QPK_SITOP  := ""
		QPK->QPK_CHAVE  := GetSxeNum("QA2","QA2_CHAVE",,2)
		QPK->QPK_LAUDO  := ""
		QPK->QPK_CERQUA := ""
		QPK->QPK_USERGI := ""
		QPK->QPK_USERGA := ""
		QPK->QPK_LDAUTO := "0"
		QPK->QPK_ORIGEM := FUNNAME()
		QPK->QPK_XNUMSE := D3NUMSEQ->D3_NUMSEQ
	QPK->(MsUnlock())
//EndiF
	D3NUMSEQ->(dbCloseArea())  
/*
DbSelectArea("SD7")
SD7->(dbSetOrder(3)) //D7_FILIAL+D7_PRODUTO+D7_NUMSEQ+D7_NUMERO
If SD7->(MsSeek(xFilial("SD7")+M->D3_COD+M->D3_NUMSEQ,.T.))
	RecLock("SD7",.F.)
		SD7->D7_XNRFICH := M->D3_XNRFICH
	SD7->(MsUnlock())
EndiF
*/
//Restauro as áreas armazenadas originalmente
RestArea(_aSavSZG)
RestArea(_aSavSB3)
RestArea(_aSavSD3)
RestArea(_aSavSC2)
RestArea(_aSavQPK)
RestArea(_aSavArea)

Return()     
