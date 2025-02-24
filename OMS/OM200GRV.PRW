#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE _lEnt CHR(13) + CHR(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM200GRV  บAutor  ณJ๚lio Soares        บ Data ณ  08/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava็ใo do Arquivo Temorแrio da Carga.Ponto de Entrada ap๓sบฑฑ
ฑฑบ          ณa grava็ใo dos campos principais do arquivo de pedidos na   บฑฑ
ฑฑบ          ณmontagem de carga, que permite ao usuแrio gravar seus camposบฑฑ
ฑฑบ          ณespecํficos. Os campos especํficos devem ser incluํdos no   บฑฑ
ฑฑบ          ณarray no ponto de entrada DL200TRB.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especifico para a empresa Arcolor.            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
//Trecho exemplo do fonte TDN.
User Function OM200GRV()
TRBPED->PED_QTLIB2 := ConvUM(SB1->B1_COD, TRBPED->PED_QTDLIB,0 ,2)
MsUnlock()
Return Nil
*/
user function OM200GRV()
	Local _aSavArea   := GetArea()
	Local _aSvArSC9   := SC9->(GetArea())
	Local _aSvArTRB   := TRBPED->(GetArea())
	Local _aSavSD2    := SD2->(GetArea())
	Local _aSavSC5    := SC5->(GetArea())
	Local _cRotina    := 'OM200GRV'
	Local nTipoOper   := OsVlEntCom()
	Local _aNFCar := {} 

	If mv_par06 == 1
		
	//	If aScan(_aNFCar,{|x| x[01]==SC9->C9_PEDIDO})==0.And.x[02]==SC9->C9_DTEMISS
		If aScan(_aNFCar,{|x| x[01]==SC9->C9_PEDIDO})==0
			AADD(_aNFCar,{SC9->C9_PEDIDO})
		Else
			RestArea(_aSavSC5)
			RestArea(_aSavSD2)
			RestArea(_aSvArSC9)
			RestArea(_aSvArTRB)
			RestArea(_aSavArea)
			return nil
		EndIf
	Else
	//	If aScan(_aNFCar,{|x| x[01]==SC9->C9_PEDIDO.AND.x[02]==SC9->C9_ITEM.AND.x[03]==SC9->C9_DTEMISS})==0
		If aScan(_aNFCar,{|x| x[01]==SC9->C9_PEDIDO.AND.x[02]==SC9->C9_ITEM})==0
			AADD(_aNFCar,{SC9->C9_PEDIDO,SC9->C9_ITEM})
		Else
			RestArea(_aSavSC5)
			RestArea(_aSavSD2)
			RestArea(_aSvArSC9)
			RestArea(_aSvArTRB)
			RestArea(_aSavArea)
			return nil
		EndIf
	EndIf
	If MV_PAR06 == 1
		_cQry := " SELECT SC9X.C9_PEDIDO,SC9X.C9_DTEMISS,SC9X.C9_NFISCAL,SC9X.C9_SERIENF "              +_lEnt
	Else
		_cQry := " SELECT SC9X.C9_PEDIDO,SC9X.C9_ITEM,SC9X.C9_DTEMISS,SC9X.C9_NFISCAL,SC9X.C9_SERIENF " +_lEnt
	EndIf
	_cQry += " FROM " + RetSqlName('SC9') + " SC9X (NOLOCK) " +_lEnt
	If MV_PAR06 == 1
		_cQry += "		INNER JOIN (SELECT C9_PEDIDO,C9_DTEMISS " +_lEnt
	Else
		_cQry += "		INNER JOIN (SELECT C9_PEDIDO,C9_ITEM,C9_DTEMISS,MIN(C9_SEQUEN)[C9_SEQUEN] " +_lEnt
	EndIf
	_cQry += "			FROM " + RetSqlName('SC9') + " SC9 (NOLOCK) " +_lEnt
	_cQry += "				INNER JOIN " + RetSqlName('SC6') + " SC6 (NOLOCK) ON SC6.D_E_L_E_T_ = '' " +_lEnt
	_cQry += "					AND SC6.C6_ENTREG  BETWEEN '" + iif(Dtos(mv_par15)> '20181201', Dtos(mv_par15), '20181201')  + "' AND '" + Dtos(mv_par16) + "' " +_lEnt
	_cQry += "					AND SC6.C6_FILIAL  = SC9.C9_FILIAL  " +_lEnt
	_cQry += "					AND SC6.C6_NUM     = SC9.C9_PEDIDO  " +_lEnt
	_cQry += "					AND SC6.C6_ITEM    = SC9.C9_ITEM    " +_lEnt
	_cQry += "					AND SC6.C6_PRODUTO = SC9.C9_PRODUTO " +_lEnt
	_cQry += "			WHERE SC9.D_E_L_E_T_       = '' " +_lEnt
	_cQry += "			AND SC9.C9_FILIAL          = '" + xFilial("SC9")                              + "' " +_lEnt
	_cQry += "			AND SC9.C9_PEDIDO          = '" + TRBPED->PED_PEDIDO                          + "' " +_lEnt
	_cQry += "			AND SC9.C9_ENDPAD          = '" + TRBPED->PED_ENDPAD                          + "' " +_lEnt
	_cQry += "			AND SC9.C9_DATALIB   BETWEEN '" + iif(Dtos(mv_par11)> '20181201', Dtos(mv_par11), '20181201') + "' AND '" + Dtos(mv_par12) + "' " +_lEnt
	If MV_PAR06 == 1
		_cQry += "	GROUP BY C9_PEDIDO, C9_DTEMISS " +_lEnt
	Else
		_cQry += "		AND SC9.C9_ITEM    = '" + TRBPED->PED_ITEM                                + "' " +_lEnt
		_cQry += "	GROUP BY C9_PEDIDO, C9_ITEM, C9_DTEMISS " +_lEnt
	EndIf
	_cQry += "				) C9SEQ " +_lEnt
	_cQry += "				ON  C9SEQ.C9_DTEMISS  = SC9X.C9_DTEMISS " +_lEnt
	_cQry += "				AND C9SEQ.C9_PEDIDO   = SC9X.C9_PEDIDO  " +_lEnt
	_cQry += "				AND C9SEQ.C9_DTEMISS <> '' "  +_lEnt
	If MV_PAR06 <> 1
		_cQry += "			AND C9SEQ.C9_ITEM     = SC9X.C9_ITEM  " +_lEnt
	EndIf
	_cQry += " WHERE SC9X.D_E_L_E_T_ = '' " +_lEnt
	If SC9->(FieldPos("C9_MARKNF")) <> 0
		_cQry += " AND SC9X.C9_MARKNF      = '' " +_lEnt
	EndIf
	If MV_PAR06 == 1
		_cQry += " GROUP BY SC9X.C9_PEDIDO,SC9X.C9_DTEMISS,SC9X.C9_SEQUEN,C9_NFISCAL,C9_SERIENF "
	Else
		_cQry += " GROUP BY SC9X.C9_PEDIDO,SC9X.C9_ITEM,SC9X.C9_DTEMISS,SC9X.C9_NFISCAL,SC9X.C9_SERIENF,SC9X.C9_SEQUEN "
	EndIf
	_cQry += " ORDER BY SC9X.C9_PEDIDO,SC9X.C9_DTEMISS,SC9X.C9_SEQUEN "
	_cQry := ChangeQuery(_cQry)
//	MemoWrite("\2.MemoWrite\OMS\"+_cRotina+"_QRY_001 - " + TRBPED->PED_PEDIDO + ".txt",_cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"TRBTMP",.T.,.F.)
	_aDados := {}
	_nRegs  := 0
	dbSelectArea("TRBTMP")
	TRBTMP->(dbGoTop())
	While !TRBTMP->(EOF())
		_nRegs++
		If _nRegs == 1
			RestArea(_aSvArTRB)
			AADD(_aDados,{"TRBPED->PED_GERA"  ,TRBPED->PED_GERA  })
			AADD(_aDados,{"TRBPED->PED_MARCA" ,TRBPED->PED_MARCA })
			AADD(_aDados,{"TRBPED->PED_ROTA"  ,TRBPED->PED_ROTA  })
			AADD(_aDados,{"TRBPED->PED_ZONA"  ,TRBPED->PED_ZONA  })
			AADD(_aDados,{"TRBPED->PED_SETOR" ,TRBPED->PED_SETOR })
			AADD(_aDados,{"TRBPED->PED_SEQROT",TRBPED->PED_SEQROT})
			AADD(_aDados,{"TRBPED->PED_PEDIDO",TRBPED->PED_PEDIDO})
			AADD(_aDados,{"TRBPED->PED_ITEM"  ,TRBPED->PED_ITEM  })
			AADD(_aDados,{"TRBPED->PED_SEQLIB",TRBPED->PED_SEQLIB})
			If mv_par06 == 2
				AADD(_aDados,{"TRBPED->PED_CODPRO",TRBPED->PED_CODPRO})
				AADD(_aDados,{"TRBPED->PED_DESPRO",TRBPED->PED_DESPRO})
				AADD(_aDados,{"TRBPED->PED_QTDLIB",TRBPED->PED_QTDLIB})
			EndIf
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณVerifca se eh operador logistico e grava a filial solicitanteณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If nTipoOper <> 1
				AADD(_aDados,{"TRBPED->PED_FILORI",TRBPED->PED_FILORI})
			EndIf
			AADD(_aDados,{"TRBPED->PED_FILCLI",TRBPED->PED_FILCLI})
			AADD(_aDados,{"TRBPED->PED_CODCLI",TRBPED->PED_CODCLI})
			AADD(_aDados,{"TRBPED->PED_LOJA  ",TRBPED->PED_LOJA  })
			AADD(_aDados,{"TRBPED->PED_NOME  ",TRBPED->PED_NOME  })
			AADD(_aDados,{"TRBPED->PED_PESO  ",TRBPED->PED_PESO  })
			AADD(_aDados,{"TRBPED->PED_CARGA ",TRBPED->PED_CARGA })
			AADD(_aDados,{"TRBPED->PED_SEQSET",TRBPED->PED_SEQSET})
			AADD(_aDados,{"TRBPED->PED_SEQORI",TRBPED->PED_SEQORI})
			AADD(_aDados,{"TRBPED->PED_VALOR ",TRBPED->PED_VALOR })
			AADD(_aDados,{"TRBPED->PED_VOLUM ",TRBPED->PED_VOLUM })
			AADD(_aDados,{"TRBPED->PED_ENDPAD",TRBPED->PED_ENDPAD})
			AADD(_aDados,{"TRBPED->PED_BAIRRO",TRBPED->PED_BAIRRO})
			AADD(_aDados,{"TRBPED->PED_MUN   ",TRBPED->PED_MUN   })
			AADD(_aDados,{"TRBPED->PED_EST   ",TRBPED->PED_EST   })
		Else
			while !RecLock("TRBPED",.T.) ; enddo
			For _x := 1 To Len(_aDados)
				&(_aDados[_x][01]) := _aDados[_x][02]
			Next
		EndIf
		TRBPED->PED_NOTA  := TRBTMP->C9_NFISCAL
		TRBPED->PED_SERIE := TRBTMP->C9_SERIENF
		TRBPED->PED_EMISS := STOD(TRBTMP->C9_DTEMISS)
		TRBPED->(MSUNLOCK())
		dbSelectArea("TRBTMP")
		TRBTMP->(dbSkip())
	EndDo
	dbSelectArea("TRBTMP")
	TRBTMP->(dbCloseArea())
	RestArea(_aSavSC5)
	RestArea(_aSavSD2)
	RestArea(_aSvArSC9)
	RestArea(_aSvArTRB)
	RestArea(_aSavArea)
return nil
