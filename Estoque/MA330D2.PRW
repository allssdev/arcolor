#include "totvs.ch"
/*/{Protheus.doc} MA330D2
Ponto de Entrada para a correção dos custos das saídas baseado nas entradas.
@type function
@version 12.1.27.1.00
@author ALLSS Soluções em Sistemas - Anderson Coelho
@since 23/05/2022
@history 23/05/2022, Anderson Coelho (ALLSS Soluções em Sistemas), Criação do Ponto de Entrada.
@obs Chama a Stored Procedure criada pelo Execblock RM330PRC.
@see https://allss.com.br
@history 16/07/2024, Diego Rodrigues (diego.rodrigues@allss.com.br), Adequação para Arcolor.
/*/
user function MA330D2()
	local   _aSavArea  := GetArea()
	local   _n         := 0
	local   _nPlano    := 2

	private _cRotina   := "MA330D2"
	private _cEnter    := CHR(13)+CHR(10)
	private _cAlias    := GetNextAlias()
	private _nTamC1    := TAMSX3('D2_CUSTO1')[2]
    private _nTamC2    := TAMSX3('D2_CUSTO2')[2]
    private _nTamC3    := TAMSX3('D2_CUSTO3')[2]
    private _nTamC4    := TAMSX3('D2_CUSTO4')[2]
    private _nTamC5    := TAMSX3('D2_CUSTO5')[2]
	private _nMoedas   := 5

	if _nPlano == 1
		Plano1()
	elseif _nPlano == 2
		Plano2()
	endif
	if SD2->D2_CUSTO1 == 0
		if Select(_cAlias) > 0
			(_cAlias)->(dbCloseArea())
		endif
		BeginSql Alias _cAlias 
			SELECT TOP 1 *
			FROM (
					SELECT '1' TP
						, COALESCE((CASE WHEN SUM(B9_QINI)<>0 THEN (SUM(B9_VINI1)/SUM(B9_QINI)) ELSE AVG(B9_CM1) END),0) CUSTO1
						, COALESCE((CASE WHEN SUM(B9_QINI)<>0 THEN (SUM(B9_VINI2)/SUM(B9_QINI)) ELSE AVG(B9_CM2) END),0) CUSTO2
						, COALESCE((CASE WHEN SUM(B9_QINI)<>0 THEN (SUM(B9_VINI3)/SUM(B9_QINI)) ELSE AVG(B9_CM3) END),0) CUSTO3
						, COALESCE((CASE WHEN SUM(B9_QINI)<>0 THEN (SUM(B9_VINI4)/SUM(B9_QINI)) ELSE AVG(B9_CM4) END),0) CUSTO4
						, COALESCE((CASE WHEN SUM(B9_QINI)<>0 THEN (SUM(B9_VINI5)/SUM(B9_QINI)) ELSE AVG(B9_CM5) END),0) CUSTO5
					FROM %table:SB9% SB9 (NOLOCK)
					WHERE B9_FILIAL = %Exp:SD2->D2_FILIAL%
					AND B9_COD    = %Exp:SD2->D2_COD%
					AND B9_LOCAL  = %Exp:SD2->D2_LOCAL%
					AND B9_DATA   = (	SELECT MAX(B9_DATA) 
										FROM %table:SB9% XXX (NOLOCK) 
										WHERE XXX.B9_FILIAL = %Exp:SD2->D2_FILIAL%
										AND XXX.B9_COD    = %Exp:SD2->D2_COD%
										AND XXX.B9_LOCAL  = %Exp:SD2->D2_LOCAL%
										AND (CASE WHEN XXX.B9_VINI1 = 0 THEN 0 ELSE 1 END) = 1
										AND XXX.B9_DATA   < %Exp:DTOS(SD2->D2_EMISSAO)%
										AND XXX.%NotDel%
									)
					AND %NotDel%
			UNION ALL
					SELECT '2' TP
						, COALESCE((CASE WHEN SUM(B9_QINI)<>0 THEN (SUM(B9_VINI1)/SUM(B9_QINI)) ELSE AVG(B9_CM1) END),0) CUSTO1
						, COALESCE((CASE WHEN SUM(B9_QINI)<>0 THEN (SUM(B9_VINI2)/SUM(B9_QINI)) ELSE AVG(B9_CM2) END),0) CUSTO2
						, COALESCE((CASE WHEN SUM(B9_QINI)<>0 THEN (SUM(B9_VINI3)/SUM(B9_QINI)) ELSE AVG(B9_CM3) END),0) CUSTO3
						, COALESCE((CASE WHEN SUM(B9_QINI)<>0 THEN (SUM(B9_VINI4)/SUM(B9_QINI)) ELSE AVG(B9_CM4) END),0) CUSTO4
						, COALESCE((CASE WHEN SUM(B9_QINI)<>0 THEN (SUM(B9_VINI5)/SUM(B9_QINI)) ELSE AVG(B9_CM5) END),0) CUSTO5
					FROM %table:SB9% SB9 (NOLOCK)
					WHERE B9_FILIAL = %Exp:SD2->D2_FILIAL%
					AND B9_COD    = %Exp:SD2->D2_COD%
					AND (CASE WHEN B9_VINI1 = 0 THEN 0 ELSE 1 END) = 1
					AND B9_DATA   = (	SELECT MAX(B9_DATA) 
										FROM %table:SB9% XXX (NOLOCK) 
										WHERE XXX.B9_FILIAL = %Exp:SD2->D2_FILIAL%
										AND XXX.B9_COD    = %Exp:SD2->D2_COD%
										AND (CASE WHEN XXX.B9_VINI1 = 0 THEN 0 ELSE 1 END) = 1
										AND XXX.B9_DATA   < %Exp:DTOS(SD2->D2_EMISSAO)%
										AND XXX.%NotDel%
									)
					AND %NotDel%
			UNION ALL
					SELECT '3' TP
						, COALESCE((CASE WHEN SUM(B9_QINI)<>0 THEN (SUM(B9_VINI1)/SUM(B9_QINI)) ELSE AVG(B9_CM1) END),0) CUSTO1
						, COALESCE((CASE WHEN SUM(B9_QINI)<>0 THEN (SUM(B9_VINI2)/SUM(B9_QINI)) ELSE AVG(B9_CM2) END),0) CUSTO2
						, COALESCE((CASE WHEN SUM(B9_QINI)<>0 THEN (SUM(B9_VINI3)/SUM(B9_QINI)) ELSE AVG(B9_CM3) END),0) CUSTO3
						, COALESCE((CASE WHEN SUM(B9_QINI)<>0 THEN (SUM(B9_VINI4)/SUM(B9_QINI)) ELSE AVG(B9_CM4) END),0) CUSTO4
						, COALESCE((CASE WHEN SUM(B9_QINI)<>0 THEN (SUM(B9_VINI5)/SUM(B9_QINI)) ELSE AVG(B9_CM5) END),0) CUSTO5
					FROM %table:SB9% SB9 (NOLOCK)
					WHERE B9_COD    = %Exp:SD2->D2_COD%
					AND (CASE WHEN B9_VINI1 = 0 THEN 0 ELSE 1 END) = 1
					AND B9_DATA   = (	SELECT MAX(B9_DATA) 
										FROM %table:SB9% XXX (NOLOCK) 
										WHERE XXX.B9_COD    = %Exp:SD2->D2_COD%
										  AND (CASE WHEN XXX.B9_VINI1 = 0 THEN 0 ELSE 1 END) = 1
										  AND XXX.B9_DATA   < %Exp:DTOS(SD2->D2_EMISSAO)%
										  AND XXX.%NotDel%
									)
					AND %NotDel%
				) XXX
			WHERE (CASE WHEN CUSTO1 = 0 THEN 0 ELSE 1 END) = 1
		EndSql
		if Select(_cAlias) > 0 .AND. !(_cAlias)->(EOF())
			Reclock("SD2",.F.)
				for _n := 1 to _nMoedas
					if SD2->(FieldPos("D2_CUSTO"+cValToChar(_n))) > 0
						&("SD2->D2_CUSTO"+cValToChar(_n)) := Round(&("(_cAlias)->CUSTO"+cValToChar(_n))*SD2->D2_QUANT,&("_nTamC"+cValToChar(_n)))
					endif
				next
			SD2->(MSUNLOCK())
		endif
		if Select(_cAlias) > 0
			(_cAlias)->(dbCloseArea())
		endif
	endif
	RestArea(_aSavArea)
return
/*/{Protheus.doc} Plano2
Plano 2 (principal) de execução para o Ponto de Entrada MA330D2.
@type function
@version  12.1.27.1.00
@author ALLSS Soluções em Sistemas
@since 23/05/2022
@history 23/05/2022, Anderson Coelho (ALLSS Soluções em Sistemas), Criação do Ponto de Entrada.
@obs Chama a Stored Procedure criada pelo Execblock RM330PRC.
@see https://allss.com.br
/*/
static function Plano2()
	local   _aResulSP  := {}
	local   _n         := 0
	local   _cSP1      := "ALLSS_RM330PRC_ENTRADAS_"+SubStr(cNumEmp,1,2)+"_001"

	//if a330ParamZX[14] == 2		//Somente para apropriação mensal
		if !empty(SD2->D2_SEQCALC) .AND. SD2->D2_TIPO == "N"
			if TCSPExist(_cSP1) .OR. (ExistBlock("RM330PRC") .AND. ExecBlock(/*cNomePE*/"RM330PRC",/*lVarEnv*/.F.,/*lSet*/.F.,/*uParam*/{_cSP1}))	//Chamada da Procedure
				_aResulSP := TCSPExec(	_cSP1,;
										DTOS(SD2->D2_EMISSAO),;
										SD2->D2_FILIAL       ,;
										SD2->D2_COD          ,;
										SD2->D2_LOCAL        ,;
										SD2->D2_QUANT         )
				if len(_aResulSP) > 0
					Reclock("SD2",.F.)
						for _n := 1 to len(_aResulSP)
							if SD2->(FieldPos("D2_CUSTO"+cValToChar(_n))) > 0
								&("SD2->D2_CUSTO"+cValToChar(_n)) := _aResulSP[_n]
							endif
						next
					SD2->(MSUNLOCK())
				endif
			else
				MsgInfo("Erro na chamada da Stored Procedure '"+_cSP1+"'. O processamento continuará pelo método convencional (Plano1)!",_cRotina+"_001")
				Plano1()
			endif
		endif
	//endif
return
/*/{Protheus.doc} Plano1
Plano 1 (inicial / obsoleto) de execução para o Ponto de Entrada MA330D2.
@type function
@version 12.1.27.1.00
@author ALLSS Soluções em Sistemas - Anderson Coelho
@since 23/05/2022
@history 23/05/2022, Anderson Coelho (ALLSS Soluções em Sistemas), Criação do Ponto de Entrada.
@obs Sem chamada de Stored Procedure.
@see https://allss.com.br
/*/
static function Plano1()
	local    _n := 0
	//if a330ParamZX[14] == 2		//Somente para apropriação mensal
		if !empty(SD2->D2_SEQCALC) .AND. SD2->D2_TIPO == "N"
			if Select(_cAlias) > 0
				(_cAlias)->(dbCloseArea())
			endif
			BeginSql Alias _cAlias
				SELECT (CASE WHEN QUANT = 0 THEN 0 ELSE ((CUSTO1/QUANT)*%Exp:SD2->D2_QUANT%) END) CUSTO1
					 , (CASE WHEN QUANT = 0 THEN 0 ELSE ((CUSTO2/QUANT)*%Exp:SD2->D2_QUANT%) END) CUSTO2
					 , (CASE WHEN QUANT = 0 THEN 0 ELSE ((CUSTO3/QUANT)*%Exp:SD2->D2_QUANT%) END) CUSTO3
					 , (CASE WHEN QUANT = 0 THEN 0 ELSE ((CUSTO4/QUANT)*%Exp:SD2->D2_QUANT%) END) CUSTO4
					 , (CASE WHEN QUANT = 0 THEN 0 ELSE ((CUSTO5/QUANT)*%Exp:SD2->D2_QUANT%) END) CUSTO5
				FROM (
						SELECT COALESCE(SUM(QUANT ),0) QUANT
							 , COALESCE(SUM(CUSTO1),0) CUSTO1
							 , COALESCE(SUM(CUSTO2),0) CUSTO2
							 , COALESCE(SUM(CUSTO3),0) CUSTO3
							 , COALESCE(SUM(CUSTO4),0) CUSTO4
							 , COALESCE(SUM(CUSTO5),0) CUSTO5
						FROM (
									SELECT SUM(B9_QINI) QUANT, SUM(B9_VINI1) CUSTO1, SUM(B9_VINI2) CUSTO2, SUM(B9_VINI3) CUSTO3, SUM(B9_VINI4) CUSTO4, SUM(B9_VINI5) CUSTO5
									FROM %table:SB9% ENT (NOLOCK)
									WHERE ENT.B9_FILIAL  = %Exp:SD2->D2_FILIAL%
									  AND ENT.B9_COD     = %Exp:SD2->D2_COD%
									  AND ENT.B9_LOCAL   = %Exp:SD2->D2_LOCAL%
									  AND ENT.B9_DATA    = COALESCE((SELECT MAX(B9_DATA) FROM %table:SB9% XXX (NOLOCK) WHERE XXX.B9_FILIAL = ENT.B9_FILIAL AND XXX.B9_COD = ENT.B9_COD AND XXX.B9_LOCAL = ENT.B9_LOCAL AND XXX.B9_DATA < %Exp:DTOS(SD2->D2_EMISSAO)% AND XXX.%NotDel%),'')
									  AND ENT.%NotDel%
								UNION ALL
									SELECT SUM(D3_QUANT) QUANT, SUM(D3_CUSTO1) CUSTO1, SUM(D3_CUSTO2) CUSTO2, SUM(D3_CUSTO3) CUSTO3, SUM(D3_CUSTO4) CUSTO4, SUM(D3_CUSTO5) CUSTO5
									FROM %table:SD3% ENT (NOLOCK)
									WHERE ENT.D3_FILIAL  = %Exp:SD2->D2_FILIAL%
									  AND ENT.D3_COD     = %Exp:SD2->D2_COD%
									  AND ENT.D3_LOCAL   = %Exp:SD2->D2_LOCAL%
									  AND SUBSTRING(ENT.D3_EMISSAO,1,6) = %Exp:SubStr(DTOS(SD2->D2_EMISSAO),1,6)%
									  //AND ENT.D3_SEQCALC < %Exp:SD2->D2_SEQCALC%
									  AND ENT.D3_ESTORNO = ''
									  //AND ENT.D3_CUSTO1 <> 0
									  AND (SUBSTRING(ENT.D3_CF,1,2) IN ('PR','DE') OR (ENT.D3_CF = 'DE4' AND NOT EXISTS( SELECT TOP 1 1
                                                                                                                         FROM %table:SD3% XXX (NOLOCK)
                                                                                                                         WHERE XXX.D3_FILIAL  = ENT.D3_FILIAL
                                                                                                                           AND XXX.D3_COD     = ENT.D3_COD
                                                                                                                           AND XXX.D3_LOCAL   = ENT.D3_LOCAL
                                                                                                                           AND XXX.D3_NUMSEQ  = ENT.D3_NUMSEQ
                                                                                                                           AND XXX.D3_EMISSAO = ENT.D3_EMISSAO
                                                                                                                           AND XXX.D3_CF      = 'RE4'
																														   AND XXX.D3_ESTORNO = ''
                                                                                                                           AND XXX.%NotDel%
                                                                                                                        ) 
                                                                                        )
									      )
									  AND ENT.%NotDel%
								UNION ALL
									SELECT SUM(D1_QUANT) QUANT, SUM(D1_CUSTO) CUSTO1, SUM(D1_CUSTO2) CUSTO2, SUM(D1_CUSTO3) CUSTO3, SUM(D1_CUSTO4) CUSTO4, SUM(D1_CUSTO5) CUSTO5
									FROM %table:SD1% ENT (NOLOCK)
										INNER JOIN %table:SF4% SF4 (NOLOCK) ON  SF4.F4_FILIAL = ENT.D1_FILIAL AND SF4.F4_TIPO = 'E' AND SF4.F4_ESTOQUE = 'S' AND SF4.F4_CODIGO = ENT.D1_TES AND SF4.%NotDel%
									WHERE ENT.D1_FILIAL  = %Exp:SD2->D2_FILIAL%
									  AND ENT.D1_COD     = %Exp:SD2->D2_COD%
									  AND ENT.D1_LOCAL   = %Exp:SD2->D2_LOCAL%
									  AND SUBSTRING(ENT.D1_DTDIGIT,1,6) = %Exp:SubStr(DTOS(SD2->D2_EMISSAO),1,6)%
									  AND (CASE WHEN ENT.D1_ORIGLAN = 'LF' THEN 0 ELSE 1 END) = 1
									  //AND ENT.D1_SEQCALC < %Exp:SD2->D2_SEQCALC%
									  //AND ENT.D1_CUSTO <> 0
									  AND ENT.%NotDel%
								) ENTRADAS
						) FINAL
			EndSql
			dbSelectArea(_cAlias)
			if Select(_cAlias) > 0 .AND. !(_cAlias)->(EOF())
				Reclock("SD2",.F.)
					for _n := 1 to _nMoedas
						if SD2->(FieldPos("D2_CUSTO"+cValToChar(_n))) > 0
							&("SD2->D2_CUSTO"+cValToChar(_n)) := Round(&("(_cAlias)->CUSTO"+cValToChar(_n)),&("_nTamC"+cValToChar(_n)))
						endif
					next
				SD2->(MSUNLOCK())
			endif
			if Select(_cAlias) > 0
				(_cAlias)->(dbCloseArea())
			endif
		endif
	//EndIf
return
