#include "totvs.ch"
/*/{Protheus.doc} MA330D3
Ponto de Entrada para a correção dos custos das saídas baseado nas entradas.
@type function
@version 12.1.27.1.00
@author ALLSS Soluções em Sistemas - Anderson Coelho
@since 23/05/2022

@history 23/05/2022, Anderson Coelho (ALLSS Soluções em Sistemas), Criação do Ponto de Entrada.

@obs Chama a Stored Procedure criada pelo Execblock RM330PRC.

@see https://allss.com.br
/*/
user function MA330D3()
	local   _aSavArea  := GetArea()
	local   _n         := 0
	local   _nPlano    := 2

	private _cRotina   := "MA330D3"
	private _cEnter    := CHR(13)+CHR(10)
	private _cAlias    := GetNextAlias()
	private _nTamC1    := TAMSX3('D3_CUSTO1')[2]
    private _nTamC2    := TAMSX3('D3_CUSTO2')[2]
    private _nTamC3    := TAMSX3('D3_CUSTO3')[2]
    private _nTamC4    := TAMSX3('D3_CUSTO4')[2]
    private _nTamC5    := TAMSX3('D3_CUSTO5')[2]
	private _nMoedas   := 5 

	//if SD3->D3_FILIAL $ _cFilial
	//	return
	//endif
	if _nPlano == 1
		Plano1()
	elseif _nPlano == 2
		Plano2()
	endif
	
	if SD3->D3_CUSTO1 == 0 .AND. ((SD3->D3_CF $ "RE0/DE0/RE4/DE4") .AND. SD3->D3_DOC <> "INVENT") 
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
					WHERE B9_FILIAL = %Exp:SD3->D3_FILIAL%
					  AND B9_COD    = %Exp:SD3->D3_COD%
					  AND B9_LOCAL  = %Exp:SD3->D3_LOCAL%
					  AND B9_DATA   = (	SELECT MAX(B9_DATA) 
										FROM %table:SB9% XXX (NOLOCK) 
										WHERE XXX.B9_FILIAL = %Exp:SD3->D3_FILIAL%
										  AND XXX.B9_COD    = %Exp:SD3->D3_COD%
										  AND XXX.B9_LOCAL  = %Exp:SD3->D3_LOCAL%
										  AND (CASE WHEN XXX.B9_VINI1 = 0 THEN 0 ELSE 1 END) = 1
										  AND XXX.B9_DATA   < %Exp:DTOS(SD3->D3_EMISSAO)%
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
					WHERE B9_FILIAL = %Exp:SD3->D3_FILIAL%
					AND B9_COD    = %Exp:SD3->D3_COD%
					AND (CASE WHEN B9_VINI1 = 0 THEN 0 ELSE 1 END) = 1
					AND B9_DATA   = (	SELECT MAX(B9_DATA) 
										FROM %table:SB9% XXX (NOLOCK) 
										WHERE XXX.B9_FILIAL = %Exp:SD3->D3_FILIAL%
										AND XXX.B9_COD    = %Exp:SD3->D3_COD%
										AND (CASE WHEN XXX.B9_VINI1 = 0 THEN 0 ELSE 1 END) = 1
										AND XXX.B9_DATA   < %Exp:DTOS(SD3->D3_EMISSAO)%
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
					WHERE B9_COD    = %Exp:SD3->D3_COD%
					AND (CASE WHEN B9_VINI1 = 0 THEN 0 ELSE 1 END) = 1
					AND B9_DATA   = (	SELECT MAX(B9_DATA) 
										FROM %table:SB9% XXX (NOLOCK) 
										WHERE XXX.B9_COD    = %Exp:SD3->D3_COD%
										  AND (CASE WHEN XXX.B9_VINI1 = 0 THEN 0 ELSE 1 END) = 1
										  AND XXX.B9_DATA   < %Exp:DTOS(SD3->D3_EMISSAO)%
										  AND XXX.%NotDel%
									)
					AND %NotDel%
				) XXX
			WHERE CUSTO1 <> 0
		EndSql
		if Select(_cAlias) > 0 .AND. !(_cAlias)->(EOF())
			Reclock("SD3",.F.)
				for _n := 1 to _nMoedas
					if SD3->(FieldPos("D3_CUSTO"+cValToChar(_n))) > 0
						&("SD3->D3_CUSTO"+cValToChar(_n)) := Round(&("(_cAlias)->CUSTO"+cValToChar(_n))*SD3->D3_QUANT,&("_nTamC"+cValToChar(_n)))
					endif
				next
			SD3->(MSUNLOCK())
		endif
		if Select(_cAlias) > 0
			(_cAlias)->(dbCloseArea())
		endif
	endif
	RestArea(_aSavArea)
return
/*/{Protheus.doc} Plano2
Plano 2 (principal) de execução para o Ponto de Entrada MA330D3.
@type function
@version 12.1.27.1.00
@author ALLSS Soluções em Sistemas - Anderson Coelho
@since 23/05/2022

@history 23/05/2022, Anderson Coelho (ALLSS Soluções em Sistemas), Criação do Ponto de Entrada.

@obs Chama a Stored Procedure criada pelo Execblock RM330PRC.

@see https://allss.com.br
/*/
static function Plano2()
	local   _aResulSP  := {}
	local   _n         := 0
	local   _cSP1      := "ALLSS_RM330PRC_ENTRADAS_"+SubStr(cNumEmp,1,2)+"_001"
	local   _cSP2      := "ALLSS_MATA330_CUSTO_RE4"+SubStr(cNumEmp,1,2)+"_002"
	local   _cQry      := ""

	//if a330ParamZX[14] == 2		//Somente para apropriação mensal
		if !empty(SD3->D3_SEQCALC) .AND. ((SubStr(SD3->D3_CF,1,2) == "RE4" .AND. SD3->D3_CF <> "RE6") .OR. SD3->D3_CF == "DE0")
			if TCSPExist(_cSP1) .OR. (ExistBlock("RM330PRC") .AND. ExecBlock(/*cNomePE*/"RM330PRC",/*lVarEnv*/.F.,/*lSet*/.F.,/*uParam*/{_cSP1}))	//Chamada da Procedure
				_aResulSP := TCSPExec(	_cSP1,;
										DTOS(SD3->D3_EMISSAO),;
										SD3->D3_FILIAL       ,;
										SD3->D3_COD          ,;
										SD3->D3_LOCAL        ,;
										SD3->D3_QUANT         )
				if len(_aResulSP) > 0
					Reclock("SD3",.F.)
						for _n := 1 to _aResulSP
							if SD3->(FieldPos("D3_CUSTO"+cValToChar(_n))) > 0
								&("SD3->D3_CUSTO"+cValToChar(_n)) := _aResulSP[_n]
							endif
						next
					SD3->(MSUNLOCK())
				endif
			else
				MsgInfo("Erro na chamada da Stored Procedure '"+_cSP1+"'. O processamento continuará pelo método convencional (Plano1)!",_cRotina+"_001")
				Plano1()
			endif
		//elseif SD3->D3_CF == "DE4"		//
		elseif SD3->D3_CF == "DE4" .AND. Empty(SD3->D3_ESTORNO)
			if !TCSPExist(_cSP2)
				_cQry := " CREATE PROCEDURE "+_cSP2+" ( "+_cEnter
				_cQry += " 							  @IN_EMISSAO  VARCHAR("+cValToChar(TamSx3("D3_EMISSAO")[01])+") "+_cEnter
				_cQry += " 							, @IN_FILIAL   VARCHAR("+cValToChar(TamSx3("D3_FILIAL" )[01])+") "+_cEnter
				_cQry += " 							, @IN_PROD     VARCHAR("+cValToChar(TamSx3("D3_COD"    )[01])+") "+_cEnter
				_cQry += " 							, @IN_ARM      VARCHAR("+cValToChar(TamSx3("D3_LOCAL"  )[01])+") "+_cEnter
				_cQry += " 							, @IN_NUMSEQ   VARCHAR("+cValToChar(TamSx3("D3_NUMSEQ" )[01])+") "+_cEnter
		//		_cQry += " 							, @IN_SEQCALC  VARCHAR("+cValToChar(TamSx3("D3_SEQCALC")[01])+") "+_cEnter
				_cQry += " 							, @IN_QUANT    FLOAT "+_cEnter
				_cQry += " 							, @OUT_NCUSTO1 FLOAT OUTPUT "+_cEnter
				_cQry += " 							, @OUT_NCUSTO2 FLOAT OUTPUT "+_cEnter
				_cQry += " 							, @OUT_NCUSTO3 FLOAT OUTPUT "+_cEnter
				_cQry += " 							, @OUT_NCUSTO4 FLOAT OUTPUT "+_cEnter
				_cQry += " 							, @OUT_NCUSTO5 FLOAT OUTPUT "+_cEnter
				_cQry += " 						) "+_cEnter
				_cQry += " AS "+_cEnter
		//		_cQry += " BEGIN "+_cEnter
				_cQry += "      SELECT @OUT_NCUSTO1 = COALESCE((CASE WHEN D3_QUANT <> 0 THEN ((D3_CUSTO1/D3_QUANT)*@IN_QUANT) ELSE 0 END), 0) "+_cEnter
				_cQry += "           , @OUT_NCUSTO2 = COALESCE((CASE WHEN D3_QUANT <> 0 THEN ((D3_CUSTO2/D3_QUANT)*@IN_QUANT) ELSE 0 END), 0) "+_cEnter
				_cQry += "           , @OUT_NCUSTO3 = COALESCE((CASE WHEN D3_QUANT <> 0 THEN ((D3_CUSTO3/D3_QUANT)*@IN_QUANT) ELSE 0 END), 0) "+_cEnter
				_cQry += "           , @OUT_NCUSTO4 = COALESCE((CASE WHEN D3_QUANT <> 0 THEN ((D3_CUSTO4/D3_QUANT)*@IN_QUANT) ELSE 0 END), 0) "+_cEnter
				_cQry += "           , @OUT_NCUSTO5 = COALESCE((CASE WHEN D3_QUANT <> 0 THEN ((D3_CUSTO5/D3_QUANT)*@IN_QUANT) ELSE 0 END), 0) "+_cEnter
				_cQry += "      FROM "+RetSqlName("SD3")+" SD3 (NOLOCK) "+_cEnter
				_cQry += "      WHERE SD3.D3_FILIAL  = @IN_FILIAL "+_cEnter
				_cQry += "        AND SD3.D3_COD     = @IN_PROD "+_cEnter
				_cQry += "        AND SD3.D3_LOCAL   = @IN_ARM "+_cEnter
				_cQry += "        AND SD3.D3_EMISSAO = @IN_EMISSAO "+_cEnter
				_cQry += "        AND SD3.D3_NUMSEQ  = @IN_NUMSEQ "+_cEnter
				_cQry += "        AND SD3.D3_ESTORNO = '' "+_cEnter
				_cQry += "        AND SD3.D3_CF      = 'RE4' "+_cEnter
				_cQry += "        AND SD3.D_E_L_E_T_ = '' "+_cEnter
				MemoWrite("\"+_cRotina+"_QRY001_"+DTOS(Date())+"_"+StrTran(Time(),":","")+".txt",_cQry)
				if TCSQLExec(_cQry) < 0
					MsgStop("[TCSqlError] Atenção! Houve um erro na tentativa de criação da Procedure de obtenção do custo da transferência (RE4). Contate o administrador imediatamente e passe este erro: "+_cEnter+TCSqlError(),_cRotina+"_001")
					Plano1()
					return
				endif
			endif
			if Select(_cAlias) > 0
				(_cAlias)->(dbCloseArea())
			endif
			BeginSql Alias _cAlias
				SELECT D3_FILIAL, D3_EMISSAO, D3_COD, D3_LOCAL, D3_NUMSEQ, D3_QUANT
					 , D3_CUSTO1 CUSTO1, D3_CUSTO2 CUSTO2, D3_CUSTO3 CUSTO3, D3_CUSTO4 CUSTO4, D3_CUSTO5 CUSTO5
				FROM %table:SD3% SD3 (NOLOCK)
				WHERE SD3.D3_FILIAL  = %Exp:SD3->D3_FILIAL% 
				  AND SD3.D3_NUMSEQ  = %Exp:SD3->D3_NUMSEQ%  
				  AND SD3.D3_DOC     = %Exp:SD3->D3_DOC%  
				  AND SD3.D3_OP      = %Exp:SD3->D3_OP%  
				  AND SD3.D3_EMISSAO = %Exp:SD3->D3_EMISSAO%
				  AND SD3.D3_CF      = 'RE4'
				  AND SD3.D3_ESTORNO = ''
				  AND SD3.%NotDel%
			EndSql
			if Select(_cAlias) > 0 .AND. !(_cAlias)->(EOF())
				if SD3->D3_QUANT <> (_cAlias)->D3_QUANT .AND. (_cAlias)->CUSTO1 <> 0
					_aResulSP := TCSPExec(	 _cSP2               ,;
											(_cAlias)->D3_EMISSAO,;
											(_cAlias)->D3_FILIAL ,;
											(_cAlias)->D3_COD    ,;
											(_cAlias)->D3_LOCAL  ,;
											(_cAlias)->D3_NUMSEQ ,;
											(_cAlias)->D3_QUANT   )
				else
					_aResulSP := {}
					Reclock("SD3",.F.)
						for _n := 1 to _nMoedas
							if SD3->(FieldPos("D3_CUSTO"+cValToChar(_n))) > 0
								&("SD3->D3_CUSTO"+cValToChar(_n)) := &("(_cAlias)->CUSTO"+cValToChar(_n))
							endif
						next
					SD3->(MSUNLOCK())
				endif
			else
				_aResulSP := TCSPExec(	_cSP2                ,;
										DTOS(SD3->D3_EMISSAO),;
										SD3->D3_FILIAL       ,;
										SD3->D3_COD          ,;
										SD3->D3_LOCAL        ,;
										SD3->D3_NUMSEQ       ,;
										SD3->D3_QUANT         )
			endif
			if Select(_cAlias) > 0
				(_cAlias)->(dbCloseArea())
			endif
			if len(_aResulSP) > 0
				Reclock("SD3",.F.)
					for _n := 1 to len(_aResulSP)
						if SD3->(FieldPos("SD3->D3_CUSTO"+cValToChar(_n))) > 0
							&("SD3->D3_CUSTO"+cValToChar(_n)) := _aResulSP[_n]
						endif
					next
				SD3->(MSUNLOCK())
			endif
		endif
	//endif
return
/*/{Protheus.doc} Plano1
Plano 1 (inicial / obsoleto) de execução para o Ponto de Entrada MA330D3.
@type function
@version 12.1.27.1.00
@author ALLSS Soluções em Sistemas - Anderson Coelho
@since 23/05/2022

@history 23/05/2022, Anderson Coelho (ALLSS Soluções em Sistemas), Criação do Ponto de Entrada.

@obs Sem chamada de Stored Procedure.

@see https://allss.com.br
/*/
static function Plano1()
    local   _nTamC1   := TAMSX3('D3_CUSTO1')[2]
    local   _nTamC2   := TAMSX3('D3_CUSTO2')[2]
    local   _nTamC3   := TAMSX3('D3_CUSTO3')[2]
    local   _nTamC4   := TAMSX3('D3_CUSTO4')[2]
    local   _nTamC5   := TAMSX3('D3_CUSTO5')[2]
	
	//if a330ParamZX[14] == 2		//Somente para apropriação mensal
		if !empty(SD3->D3_SEQCALC) .AND. SubStr(SD3->D3_CF,1,2) == "RE" .AND. SD3->D3_CF <> "RE6"
			if Select(_cAlias) > 0
				(_cAlias)->(dbCloseArea())
			endif
			BeginSql Alias _cAlias
				SELECT (CASE WHEN QUANT <> 0 THEN ((CUSTO1/QUANT)*%Exp:SD3->D3_QUANT%) ELSE 0 END) CUSTO1
					 , (CASE WHEN QUANT <> 0 THEN ((CUSTO2/QUANT)*%Exp:SD3->D3_QUANT%) ELSE 0 END) CUSTO2
					 , (CASE WHEN QUANT <> 0 THEN ((CUSTO3/QUANT)*%Exp:SD3->D3_QUANT%) ELSE 0 END) CUSTO3
					 , (CASE WHEN QUANT <> 0 THEN ((CUSTO4/QUANT)*%Exp:SD3->D3_QUANT%) ELSE 0 END) CUSTO4
					 , (CASE WHEN QUANT <> 0 THEN ((CUSTO5/QUANT)*%Exp:SD3->D3_QUANT%) ELSE 0 END) CUSTO5
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
									WHERE ENT.B9_FILIAL  = %Exp:SD3->D3_FILIAL%
									  AND ENT.B9_COD     = %Exp:SD3->D3_COD%
									  AND ENT.B9_LOCAL   = %Exp:SD3->D3_LOCAL%
									  AND ENT.B9_DATA    = COALESCE((SELECT MAX(B9_DATA) FROM %table:SB9% XXX (NOLOCK) WHERE XXX.B9_FILIAL = ENT.B9_FILIAL AND XXX.B9_COD = ENT.B9_COD AND XXX.B9_LOCAL = ENT.B9_LOCAL AND XXX.B9_DATA < %Exp:DTOS(SD3->D3_EMISSAO)% AND XXX.%NotDel%),'')
									  AND ENT.%NotDel%
								UNION ALL
									SELECT SUM(D3_QUANT) QUANT, SUM(D3_CUSTO1) CUSTO1, SUM(D3_CUSTO2) CUSTO2, SUM(D3_CUSTO3) CUSTO3, SUM(D3_CUSTO4) CUSTO4, SUM(D3_CUSTO5) CUSTO5
									FROM %table:SD3% ENT (NOLOCK)
									WHERE ENT.D3_FILIAL  = %Exp:SD3->D3_FILIAL%
									  AND ENT.D3_COD     = %Exp:SD3->D3_COD%
									  AND ENT.D3_LOCAL   = %Exp:SD3->D3_LOCAL%
									  AND SUBSTRING(ENT.D3_EMISSAO,1,6) = %Exp:SubStr(DTOS(SD3->D3_EMISSAO),1,6)%
									  //AND ENT.D3_SEQCALC < %Exp:SD3->D3_SEQCALC%
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
									WHERE ENT.D1_FILIAL  = %Exp:SD3->D3_FILIAL%
									  AND ENT.D1_COD     = %Exp:SD3->D3_COD%
									  AND ENT.D1_LOCAL   = %Exp:SD3->D3_LOCAL%
									  AND SUBSTRING(ENT.D1_DTDIGIT,1,6) = %Exp:SubStr(DTOS(SD3->D3_EMISSAO),1,6)%
									  AND (CASE WHEN ENT.D1_ORIGLAN = 'LF' THEN 0 ELSE 1 END) = 1
									  //AND ENT.D1_SEQCALC < %Exp:SD3->D3_SEQCALC%
									  //AND ENT.D1_CUSTO <> 0
									  AND ENT.%NotDel%
								) ENTRADAS
						) FINAL
			EndSql
			dbSelectArea(_cAlias)
           	if Select(_cAlias) > 0 .AND. !(_cAlias)->(EOF())
                Reclock("SD3",.F.)
					SD3->D3_CUSTO1 := Round((_cAlias)->CUSTO1,_nTamC1)
					SD3->D3_CUSTO2 := Round((_cAlias)->CUSTO2,_nTamC2)
					SD3->D3_CUSTO3 := Round((_cAlias)->CUSTO3,_nTamC3)
					SD3->D3_CUSTO4 := Round((_cAlias)->CUSTO4,_nTamC4)
					SD3->D3_CUSTO5 := Round((_cAlias)->CUSTO5,_nTamC5)
                SD3->(MSUNLOCK())
			endif
			if Select(_cAlias) > 0
				(_cAlias)->(dbCloseArea())
			endif
        elseif SD3->D3_CF == "DE4" .AND. Empty(SD3->D3_ESTORNO)
			if Select(_cAlias) > 0
				(_cAlias)->(dbCloseArea())
			endif
			BeginSql Alias _cAlias
				SELECT (CASE WHEN D3_QUANT <> 0 THEN ((D3_CUSTO1/D3_QUANT)*%Exp:SD3->D3_QUANT%) ELSE 0 END) CUSTO1
					 , (CASE WHEN D3_QUANT <> 0 THEN ((D3_CUSTO2/D3_QUANT)*%Exp:SD3->D3_QUANT%) ELSE 0 END) CUSTO2
					 , (CASE WHEN D3_QUANT <> 0 THEN ((D3_CUSTO3/D3_QUANT)*%Exp:SD3->D3_QUANT%) ELSE 0 END) CUSTO3
					 , (CASE WHEN D3_QUANT <> 0 THEN ((D3_CUSTO4/D3_QUANT)*%Exp:SD3->D3_QUANT%) ELSE 0 END) CUSTO4
					 , (CASE WHEN D3_QUANT <> 0 THEN ((D3_CUSTO5/D3_QUANT)*%Exp:SD3->D3_QUANT%) ELSE 0 END) CUSTO5
				FROM %table:SD3% SD3 (NOLOCK)
				WHERE SD3.D3_FILIAL  = %Exp:SD3->D3_FILIAL% 
				  AND SD3.D3_NUMSEQ  = %Exp:SD3->D3_NUMSEQ%  
				  AND SD3.D3_DOC     = %Exp:SD3->D3_DOC%  
				  AND SD3.D3_OP      = %Exp:SD3->D3_OP%  
				  AND SD3.D3_EMISSAO = %Exp:SD3->D3_EMISSAO%
                  AND SD3.D3_CF      = 'RE4'
				  AND SD3.D3_ESTORNO = ''
                  AND SD3.%NotDel%
			EndSql
			dbSelectArea(_cAlias)
           	if Select(_cAlias) > 0 .AND. !(_cAlias)->(EOF())
                Reclock("SD3",.F.)
					SD3->D3_CUSTO1 := Round((_cAlias)->CUSTO1,_nTamC1)
					SD3->D3_CUSTO2 := Round((_cAlias)->CUSTO2,_nTamC2)
					SD3->D3_CUSTO3 := Round((_cAlias)->CUSTO3,_nTamC3)
					SD3->D3_CUSTO4 := Round((_cAlias)->CUSTO4,_nTamC4)
					SD3->D3_CUSTO5 := Round((_cAlias)->CUSTO5,_nTamC5)
                SD3->(MSUNLOCK())
			endif
			if Select(_cAlias) > 0
				(_cAlias)->(dbCloseArea())
			endif
		endif
	//endif
return
