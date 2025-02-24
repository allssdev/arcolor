#include "totvs.ch"
#include "topconn.ch"
#include "tbiconn.ch"
/*/{Protheus.doc} GP120END
    @description Permite a gravação de informações de campos do usuário após o processamento completo do Fechamento de um roteiro, ou seja, após todos os registro de Funcionários terem sido processados.
    @author Fernando Bombardi (ALLSS Soluções em Sistemas)
    @since 11/02/2020
    @version 1.0
    @type Function
    @see https://allss.com.br
/*/
user function GP120END()
	local   _aROTEIRO   := PARAMIXB
	local   _aBAIXA     := {}
	local   _nX         := 0
	local   _nSeq       := 1
	local   _nStart     := Seconds()
	local   _cRotina    := "GP120END"
	local   _cFILIAL    := ""
	local   _cPROC      := ""
	local   _cROTEIRO   := ""
	local   _cPERIODO   := ""
	local   _cNPG       := ""
	local   _cFECH      := GetNextAlias()
	local   _cVERBA     := PadR(SuperGetMV("MV_XVERBAVF",,"505"      ),TamSx3("RV_COD"    )[1])
	local   _cMOTBAX    := PadR(SuperGetMV("MV_XMOTBAX",,"NOR"       ),TamSx3("E5_MOTBX"  )[1])
	local   _cBANCO     := PadR(SuperGetMV("MV_XBANCO" ,,"FUN"       ),TamSx3("E5_BANCO"  )[1])
	local   _cAGENC     := PadR(SuperGetMV("MV_XAGENC" ,,"00000"     ),TamSx3("E5_AGENCIA")[1])
	local   _cCONTA     := PadR(SuperGetMV("MV_XCONTA" ,,"000000000 "),TamSx3("E5_CONTA"  )[1])

	private lMsErroAuto := .F.
 
	if Len(_aROTEIRO) > 0 .AND. SRK->(FieldPos("RK_XDOC")) > 0 .AND. SRK->(FieldPos("RK_XSERIE")) > 0 .AND. SRK->(FieldPos("RK_XPARC")) > 0
		for _nX := 1 to Len(_aROTEIRO)
			_cROTEIRO := _aROTEIRO[_nX,1]
			_cPERIODO := _aROTEIRO[_nX,2]
			_cNPG     := _aROTEIRO[_nX,3]
			_cFILIAL  := _aROTEIRO[_nX,5]
			_cPROC    := _aROTEIRO[_nX,6]
			if AllTrim(_cROTEIRO) $ "/FOL/RES/"
				if Select(_cFECH) > 0				
					(_cFECH)->(dbCloseArea())
				endif
				BeginSql Alias _cFECH
					%noparser%
					SELECT RK_XDOC,RK_XSERIE,RK_FILIAL,RK_MAT,RK_PD,RK_VALORTO,RK_PARCELA,RK_DOCUMEN,RK_DTVENC,RK_NUMID,RK_XPARC
					FROM %table:SRD% SRD (NOLOCK)
						INNER JOIN %table:SRK% SRK (NOLOCK) ON SRK.RK_FILIAL = %xFilial:SRK% 
														   AND SRK.RK_STATUS = %exp:'3'%
														   AND SRK.RK_NUMID  = SRD.RD_NUMID
														   AND SRK.%NotDel%
					WHERE SRD.RD_FILIAL  = %exp:_cFILIAL%
					  AND SRD.RD_PD      = %exp:_cVERBA%
					  AND SRD.RD_PROCES  = %exp:_cPROC%
					  AND SRD.RD_PERIODO = %exp:_cPERIODO%
					  AND SRD.RD_ROTEIR  = %exp:_cROTEIRO%                                        
					  AND SRD.%notDel%                  
				EndSql
				_aQry := GetLastQuery()
				dbSelectArea(_cFECH)
				if !(_cFECH)->(EOF()) 
					while !(_cFECH)->(EOF())
						_aBAIXA := {{"E1_PREFIXO"  ,(_cFECH)->RK_XSERIE     ,Nil    },;
									{"E1_NUM"      ,(_cFECH)->RK_XDOC       ,Nil    },;
									{"E1_PARCELA"  ,(_cFECH)->RK_XPARC      ,Nil    },;
									{"E1_TIPO"     ,"NF "                   ,Nil    },;
									{"AUTMOTBX"    ,_cMOTBAX                ,Nil    },;
									{"AUTBANCO"    ,_cBANCO                 ,Nil    },;
									{"AUTAGENCIA"  ,_cAGENC                 ,Nil    },;
									{"AUTCONTA"    ,_cCONTA        	        ,Nil    },;                            
									{"AUTDTBAIXA"  ,dDataBase               ,Nil    },;
									{"AUTDTCREDITO",dDataBase               ,Nil    },;
									{"AUTHIST"     ,(_cFECH)->RK_NUMID      ,Nil    },;
									{"AUTJUROS"    ,0                       ,Nil,.T.},;
									{"AUTVALREC"   ,(_cFECH)->RK_VALORTO    ,Nil    } }
						MSExecAuto({|x,y| Fina070(x,y)}, _aBAIXA, 3)
						if !lMsErroAuto
							FwLogMsg(	"INFO",;
										nil,;					//cTransactionId
										_cRotina,;
										_cRotina+"_LOG",;
										_cRotina+"_LOG_"+StrZero(_nSeq),;
										StrZero(_nSeq),;
										("### Título a receber alterado com sucesso! Documento: " + (_cFECH)->RK_XSERIE + " - " + (_cFECH)->RK_XDOC + " - " + (_cFECH)->RK_XPARC + " - NF "),;
										0,;
										(Seconds()-_nStart),;
										{} ) ; _nSeq++
						else
							MostraErro()
							FwLogMsg(	"ERROR",;
										nil,;					//cTransactionId
										_cRotina,;
										_cRotina+"_LOG",;
										_cRotina+"_LOG_"+StrZero(_nSeq),;
										StrZero(_nSeq),;
										("### Falha na alteração do título a receber! Documento: " + (_cFECH)->RK_XSERIE + " - " + (_cFECH)->RK_XDOC + " - " + (_cFECH)->RK_XPARC + " - NF "),;
										0,;
										(Seconds()-_nStart),;
										{} ) ; _nSeq++
						endif
						dbSelectArea(_cFECH)
						(_cFECH)->(dbSkip()) 
					enddo
				endif
				if Select(_cFECH) > 0
					(_cFECH)->(dbCloseArea())
				endif
			endif
		next _nX
	endif
return