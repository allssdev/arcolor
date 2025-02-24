#include "totvs.ch"
/*/{Protheus.doc} RM330PRC
Stored Procedure para a obtenção dos custos de entrada de determinado produto
@type function
@version 12.1.27.1.00
@author ALLSS Soluções em Sistemas - Anderson Coelho
@since 23/05/2022

@history 23/05/2022, Anderson Coelho (ALLSS Soluções em Sistemas), Criação do ExecBlock.

@obs Execblock chamado nos pontos de entrada MA330D2 e MA330D3.

@see https://allss.com.br
/*/
user function RM330PRC()
	local _aSavArea := GetArea()
	local _cRotina  := "RM330PRC"
	local _cQry     := ""
	local _lRet     := TCSPExist(PARAMIXB[1])
	
	if !_lRet
		_cQry := " CREATE PROCEDURE "+PARAMIXB[1]+" ( "+_cEnter
		_cQry += " 							  @IN_EMISSAO  VARCHAR("+cValToChar(TamSx3("D3_EMISSAO")[01])+") "+_cEnter
		_cQry += " 							, @IN_FILIAL   VARCHAR("+cValToChar(TamSx3("D3_FILIAL" )[01])+") "+_cEnter
		_cQry += " 							, @IN_PROD     VARCHAR("+cValToChar(TamSx3("D3_COD"    )[01])+") "+_cEnter
		_cQry += " 							, @IN_ARM      VARCHAR("+cValToChar(TamSx3("D3_LOCAL"  )[01])+") "+_cEnter
//		_cQry += " 							, @IN_NUMSEQ   VARCHAR("+cValToChar(TamSx3("D3_NUMSEQ" )[01])+") "+_cEnter
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
		_cQry += "      SELECT @OUT_NCUSTO1 = COALESCE((CASE WHEN QUANT <> 0 THEN ((CUSTO1/QUANT)*@IN_QUANT) ELSE 0 END), 0) "+_cEnter
		_cQry += "           , @OUT_NCUSTO2 = COALESCE((CASE WHEN QUANT <> 0 THEN ((CUSTO2/QUANT)*@IN_QUANT) ELSE 0 END), 0) "+_cEnter
		_cQry += "           , @OUT_NCUSTO3 = COALESCE((CASE WHEN QUANT <> 0 THEN ((CUSTO3/QUANT)*@IN_QUANT) ELSE 0 END), 0) "+_cEnter
		_cQry += "           , @OUT_NCUSTO4 = COALESCE((CASE WHEN QUANT <> 0 THEN ((CUSTO4/QUANT)*@IN_QUANT) ELSE 0 END), 0) "+_cEnter
		_cQry += "           , @OUT_NCUSTO5 = COALESCE((CASE WHEN QUANT <> 0 THEN ((CUSTO5/QUANT)*@IN_QUANT) ELSE 0 END), 0) "+_cEnter
		_cQry += "      FROM ( "+_cEnter
		_cQry += "            SELECT COALESCE(SUM(QUANT ),0) QUANT  "+_cEnter
		_cQry += "                 , COALESCE(SUM(CUSTO1),0) CUSTO1 "+_cEnter
		_cQry += "                 , COALESCE(SUM(CUSTO2),0) CUSTO2 "+_cEnter
		_cQry += "                 , COALESCE(SUM(CUSTO3),0) CUSTO3 "+_cEnter
		_cQry += "                 , COALESCE(SUM(CUSTO4),0) CUSTO4 "+_cEnter
		_cQry += "                 , COALESCE(SUM(CUSTO5),0) CUSTO5 "+_cEnter
		_cQry += "            FROM ( "+_cEnter
		_cQry += "                    SELECT SUM(B9_QINI) QUANT, SUM(B9_VINI1) CUSTO1, SUM(B9_VINI2) CUSTO2, SUM(B9_VINI3) CUSTO3, SUM(B9_VINI4) CUSTO4, SUM(B9_VINI5) CUSTO5 "+_cEnter
		_cQry += "                    FROM "+RetSqlName("SB9")+" ENT (NOLOCK) "+_cEnter
		_cQry += "                    WHERE ENT.B9_FILIAL  = @IN_FILIAL "+_cEnter
		_cQry += "                      AND ENT.B9_COD     = @IN_PROD "+_cEnter
		_cQry += "                      AND ENT.B9_LOCAL   = @IN_ARM "+_cEnter
		_cQry += "                      AND ENT.B9_DATA    = COALESCE((SELECT MAX(B9_DATA) FROM "+RetSqlName("SB9")+" XXX (NOLOCK) WHERE XXX.B9_FILIAL = ENT.B9_FILIAL AND XXX.B9_COD = ENT.B9_COD AND XXX.B9_LOCAL = ENT.B9_LOCAL AND XXX.B9_DATA < @IN_EMISSAO AND XXX.D_E_L_E_T_ = ''),'') "+_cEnter
		_cQry += "                      AND ENT.D_E_L_E_T_ = '' "+_cEnter
		_cQry += "                  UNION ALL "+_cEnter
		_cQry += "                    SELECT SUM(D3_QUANT) QUANT, SUM(D3_CUSTO1) CUSTO1, SUM(D3_CUSTO2) CUSTO2, SUM(D3_CUSTO3) CUSTO3, SUM(D3_CUSTO4) CUSTO4, SUM(D3_CUSTO5) CUSTO5 "+_cEnter
		_cQry += "                    FROM "+RetSqlName("SD3")+" ENT (NOLOCK) "+_cEnter
		_cQry += "                    WHERE ENT.D3_FILIAL  = @IN_FILIAL "+_cEnter
		_cQry += "                      AND ENT.D3_COD     = @IN_PROD "+_cEnter
		_cQry += "                      AND ENT.D3_LOCAL   = @IN_ARM "+_cEnter
		_cQry += "                      AND SUBSTRING(ENT.D3_EMISSAO,1,6) = SUBSTRING(@IN_EMISSAO,1,6) "+_cEnter
//		_cQry += "                      --AND ENT.D3_SEQCALC < @IN_SEQCALC "+_cEnter
		_cQry += "                      AND ENT.D3_ESTORNO = '' "+_cEnter
//		_cQry += "                      --AND ENT.D3_CUSTO1 <> 0 "+_cEnter
//		_cQry += "                      AND (CASE WHEN ENT.D3_CF = 'DE0' AND ENT.D3_DOC = 'INVENT' THEN 0 ELSE 1 END) = 1 "+_cEnter
		_cQry += "                      AND (SUBSTRING(ENT.D3_CF,1,2) IN ('PR','DE') "+_cEnter
		_cQry += "                               OR (ENT.D3_CF = 'DE4' AND NOT EXISTS( SELECT TOP 1 1 "+_cEnter
		_cQry += "                                                                     FROM "+RetSqlName("SD3")+" XXX (NOLOCK) "+_cEnter
		_cQry += "                                                                     WHERE XXX.D3_FILIAL = ENT.D3_FILIAL "+_cEnter
		_cQry += "                                                                     AND XXX.D3_COD = ENT.D3_COD "+_cEnter
		_cQry += "                                                                     AND XXX.D3_LOCAL = ENT.D3_LOCAL "+_cEnter
		_cQry += "                                                                     AND XXX.D3_NUMSEQ = ENT.D3_NUMSEQ "+_cEnter
		_cQry += "                                                                     AND XXX.D3_EMISSAO = ENT.D3_EMISSAO "+_cEnter
		_cQry += "                                                                     AND XXX.D3_CF = 'RE4' "+_cEnter
		_cQry += "                                                                     AND XXX.D_E_L_E_T_ = '' "+_cEnter
		_cQry += "                                                                   )  "+_cEnter
		_cQry += "                                   ) "+_cEnter
		_cQry += "                           ) "+_cEnter
		_cQry += "                      AND ENT.D_E_L_E_T_ = '' "+_cEnter
		_cQry += "                  UNION ALL "+_cEnter
		_cQry += "                    SELECT SUM(D1_QUANT) QUANT, SUM(D1_CUSTO) CUSTO1, SUM(D1_CUSTO2) CUSTO2, SUM(D1_CUSTO3) CUSTO3, SUM(D1_CUSTO4) CUSTO4, SUM(D1_CUSTO5) CUSTO5 "+_cEnter
		_cQry += "                    FROM "+RetSqlName("SD1")+" ENT (NOLOCK) "+_cEnter
		_cQry += "                         INNER JOIN "+RetSqlName("SF4")+" SF4 (NOLOCK) ON  SF4.F4_FILIAL = ENT.D1_FILIAL AND SF4.F4_TIPO = 'E' AND SF4.F4_ESTOQUE = 'S' AND SF4.F4_CODIGO = ENT.D1_TES AND SF4.D_E_L_E_T_ = '' "+_cEnter
		_cQry += "                    WHERE ENT.D1_FILIAL  = @IN_FILIAL "+_cEnter
		_cQry += "                      AND ENT.D1_COD     = @IN_PROD "+_cEnter
		_cQry += "                      AND ENT.D1_LOCAL   = @IN_ARM "+_cEnter
		_cQry += "                      AND SUBSTRING(ENT.D1_DTDIGIT,1,6) = SUBSTRING(@IN_EMISSAO,1,6) "+_cEnter
		_cQry += "                      AND (CASE WHEN ENT.D1_ORIGLAN = 'LF' THEN 0 ELSE 1 END) = 1 "+_cEnter
//		_cQry += "                      --AND ENT.D1_SEQCALC < @IN_D3_SEQCALC "+_cEnter
//		_cQry += "                      --AND ENT.D1_CUSTO <> 0 "+_cEnter
		_cQry += "                      AND ENT.D_E_L_E_T_ = '' "+_cEnter
		_cQry += "                 ) ENTRADAS "+_cEnter
		_cQry += "           ) FINAL "+_cEnter
		MemoWrite("\"+_cRotina+"_QRY001_"+DTOS(Date())+"_"+StrTran(Time(),":","")+".txt",_cQry)
		if TCSQLExec(_cQry) < 0
			MsgStop("[TCSqlError] Atenção! Houve um erro na tentativa de criação da Procedure de obtenção dos custos de entrada. Contate o administrador imediatamente e passe este erro: "+_cEnter+TCSqlError(),_cRotina+"_001")
		else
			_lRet := .T.
		endif
	endif
	RestArea(_aSavArea)
return _lRet
