#include "rwmake.ch"
#include "ap5mail.ch"
#include "topconn.ch"
#include "tbiConn.ch"
#include "tbiCode.ch"
#include "protheus.ch"
/*/{Protheus.doc} RESTA265
Função de usuário utilizada para realização do endereçamento automático das notas fiscais de entrada e alguns movimentos internos.
@author Desconhecido
@since 14/01/2022
@version P12.1.33
@type Function
@obs Sem observações
@see https://allss.com.br
@history 14/01/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Inclusão de documentação da rotina.
@history 14/01/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Revisão/correção de problemas no endereçamento automático.
@history 27/07/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Revisão para adequação de chamadas de tabela em querys sem NOLOCK.
@history 18/02/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Revisão para adequação dda rastreabilidade.
/*/
user function RESTA265()
local _aCabSDA   	:= {}
local _aItSDB    	:= {}
local _aItensSDB 	:= {}
local _nCont	 	:= 1
local _cPathErr  	:= "\2.Memowrite\estoque\ENDERECAMENTO\"
local _cArq 		:= ""
local   _lProc    	:= type("cFilAnt")=="U"
private _cRotina 	:= "RESTA265"
private _cAlias 	:= "TEMPSDA"
private _nSeqJob  	:= 0
private lMsErroAuto := .F.
private _nSeq       := 1
private _cEmpr      := iif(type("CFILANT")=="U",GetPvProfString(_cRotina+StrZero(_nSeq,3),"EMPRESA"   ,"",GetAdv97()),SubStr(cNumEmp,1,2))
private _cFil       := iif(type("CFILANT")=="U",GetPvProfString(_cRotina+StrZero(_nSeq,3),"FILIAL"    ,"",GetAdv97()),SubStr(cNumEmp,3,2))
if _lProc
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" FUNNAME _cRotina tables "TEMPSDA", "SDA", "SDB", "CBJ"
	BeginSql Alias _cAlias
		SELECT
			DA_PRODUTO,	DA_LOCAL, DA_LOTECTL, DA_DOC, DA_SERIE,	DA_CLIFOR, DA_LOJA,
			DA_NUMSEQ, DA_SALDO, DA_DATA, CBJ_ENDERE
		FROM
			%Table:SDA% SDA (NOLOCK)
			INNER JOIN %Table:CBJ% CBJ (NOLOCK) ON
				CBJ.CBJ_FILIAL = %xFilial:CBJ%
				AND CBJ.CBJ_CODPRO = SDA.DA_PRODUTO 
				AND CBJ.CBJ_ARMAZ = SDA.DA_LOCAL
				AND CBJ.D_E_L_E_T_ = ''
			LEFT JOIN %Table:SD3% SD3 (NOLOCK)	ON
				SD3.D3_FILIAL = %xFilial:SD3% 
				AND SDA.DA_PRODUTO = SD3.D3_COD
				AND SDA.DA_DOC = SD3.D3_DOC 
				AND SD3.D_E_L_E_T_ = ''
		WHERE SDA.DA_FILIAL = %xFilial:SDA%
			AND SDA.DA_SALDO > 0 
			AND ((SD3.D3_TM IN ('001','004') OR SDA.DA_ORIGEM = 'SD1')
			OR (SD3.D3_TM = '010' AND SD3.D3_LOCAL = '98'))
			AND SDA.%NotDel%
		ORDER BY SDA.R_E_C_N_O_
	endsql
	dbSelectArea(_cAlias)
	(_cAlias)->(dbGoTop())
	if !(_cAlias)->(EOF())	
		while (_cAlias)->(! Eof())	
			if (_cAlias)->DA_SALDO > 0 			
				//Cabeçalho com a informação do item e NumSeq que sera endereçado.
				_aCabSDA := {	{"DA_PRODUTO"  ,(_cAlias)->DA_PRODUTO		,Nil},;
								{"DA_NUMSEQ"   ,(_cAlias)->DA_NUMSEQ		,Nil},;
								{"DA_LOTECTL"   ,(_cAlias)->DA_LOTECTL		,Nil}}	
				//Dados do item que será endereçado
				_cAliasSDB := GetNextAlias()
				BeginSql Alias _cAliasSDB
					SELECT
						MAX(DB_ITEM) AS DB_ITEM
					FROM
						%Table:SDB% SDB (NOLOCK)
					WHERE
						SDB.DB_NUMSEQ = %Exp:(_cAlias)->DA_NUMSEQ%
						AND SDB.DB_LOTECTL = %Exp:(_cAlias)->DA_LOTECTL%
						AND SDB.D_E_L_E_T_ = ''
				EndSql
				dbSelectArea(_cAliasSDB)
				(_cAliasSDB)->(dbGoTop())
				if !(_cAliasSDB)->(EOF())
					_nCont := Val((_cAliasSDB)->DB_ITEM) + 1
				else
					_nCont := 1
				endif
				(_cAliasSDB)->(dbCloseArea())
				_aItSDB := 	{	{"DB_FILIAL"  ,FwFilial("SDB") 			  	,Nil},;
								{"DB_ITEM"    ,StrZero(_nCont,4)			,Nil},;
								{"DB_ESTORNO" ," "       	  			  	,Nil},;
								{"DB_PRODUTO" ,(_cAlias)->DA_PRODUTO	  	,Nil},;
								{"DB_LOCAL"   ,(_cAlias)->DA_LOCAL	  		,Nil},;
								{"DB_LOTECTL" ,(_cAlias)->DA_LOTECTL		,Nil},;
								{"DB_LOCALIZ" ,(_cAlias)->CBJ_ENDERE		,Nil},;
								{"DB_DOC" 	  ,(_cAlias)->DA_DOC			,Nil},;
								{"DB_SERIE"   ,(_cAlias)->DA_SERIE			,Nil},;
								{"DB_CLIFOR"  ,(_cAlias)->DA_CLIFOR			,Nil},;
								{"DB_LOJA"    ,(_cAlias)->DA_LOJA			,Nil},;
								{"DB_QUANT"   ,(_cAlias)->DA_SALDO       	,Nil},;
								{"DB_DATA"    ,dDataBase		    		,Nil},;
								{"DB_NUMSEQ"  ,(_cAlias)->DA_NUMSEQ   		,Nil} }		
				aadd(_aItensSDB,_aitSDB)
				Begin Transaction
					//Executa o endereçamento do item
					MsExecAuto({|x,y,z| MATA265(x,y,z)},_aCabSDA,_aItensSDB,3,,)
					_cArq:= "ENDERECAMENTO_DA_NUMSEQ_"+(_cAlias)->DA_NUMSEQ+"_DATA_"+DTOS(dDatabase)+"_HORA_"+StrTran(Time(),":","")+".log"
					if lMsErroAuto		
						MostraErro(_cPathErr,"ERRO_" + _cArq)
					else
						MemoWrite(_cPathErr+_cArq, "Endereçamento Executado com Sucesso!" )
					endif
				End Transaction
			endif
			_nCont 		:= 0
			_aCabSDA   	:= {}
			_aItSDB    	:= {}
			_aItensSDB 	:= {}
			(_cAlias)->(dbSkip())
		enddo	
	else
		_cArq:= "ENDERECAMENTO_DATA_"+DTOS(dDatabase)+"_HORA_"+StrTran(Time(),":","") +".log"		
		MemoWrite(_cPathErr+_cArq, "Rotina concluida sem erro! Sem Saldo a Endereçar!" )
	endif
	dbSelectArea((_cAlias))
	(_cAlias)->(dbCloseArea())
	RESET ENVIRONMENT
endif
return
