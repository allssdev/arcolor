#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*/{Protheus.doc} User Function MA651GRV
    LOCALIZAÇÃO : Function A651Do() - Responsável por atualizar os arquivos envolvidos na Ordem de Producao.É chamado apos trocar o tipo da OP
    DESCRIÇÃO : Para vincular os lotes aos empenhos e imprimir a ordem de produção
    @type  Function
    @author Diego Rodrigues
    @since 01/07/2024
    @version 1.0
/*/
User Function MA651GRV

Local _cImpIni := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
Local _cNumFim := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
Local _aOpImp  := {}
Local _cUsrProd := SuperGetMV("MV_XUSRPROD",,"000000")
Local _cMarca := cMarca
Private _lRet := .F.

	   BeginSql Alias "EMPOP"
          	SELECT
				C2_NUM,C2_ITEM,C2_SEQUEN, C2_NUMPAGS, B1_OPERPAD
			FROM SC2010 SC2 (NOLOCK)
			INNER JOIN SB1010 SB1 (NOLOCK) ON SB1.D_E_L_E_T_ = '' AND B1_COD = C2_PRODUTO
			WHERE SC2.D_E_L_E_T_ = ''
				AND C2_OK = %Exp:cMarca% 
				AND C2_DATPRF >= '20240729'
			ORDER BY C2_NUM,C2_ITEM,C2_SEQUEN
        EndSql

		While EMPOP->(!EOF())
			U_RPCPE012(EMPOP->C2_NUM + EMPOP->C2_ITEM + EMPOP->C2_SEQUEN)
			EMPOP->(dbSkip())
		EndDo
		EMPOP->(dbCloseArea())    


If !__cUserId$_cUsrProd	
    if MsgYesNo("Ordens de Produção firmadas! Deseja Imprimir?",'[MA651GRV_1] - Atenção')
		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		If SB1->(MsSeek(xFilial("SB1")+SC2->C2_PRODUTO,.T.,.F.))
			If !Empty(SB1->B1_OPERPAD)
				U_RPCPR013(_cImpIni,_cNumFim,_aOpImp)		
				_aOpImp := {}
			Else
				U_RPCPR006(_cImpIni,_cNumFim,_aOpImp)		
				_aOpImp := {}
			EndIf
		EndIf
	EndIf
Else
	//if MsgYesNo("Ordens de Produção firmadas! Deseja Imprimir?",'[MA651GRV_1] - Atenção')
		   BeginSql Alias "IMPOP"
          	SELECT
				MIN(C2_NUM+C2_ITEM+C2_SEQUEN) PRIOP, MAX(C2_NUM+C2_ITEM+C2_SEQUEN) ULTOP, C2_NUMPAGS, B1_OPERPAD
			FROM SC2010 SC2 (NOLOCK)
			INNER JOIN SB1010 SB1 (NOLOCK) ON SB1.D_E_L_E_T_ = '' AND B1_COD = C2_PRODUTO
			WHERE SC2.D_E_L_E_T_ = ''
				AND C2_NUMPAGS = 0
				AND C2_OK = %Exp:cMarca% 
				AND C2_DATPRF >= '20250201'
			GROUP BY C2_NUMPAGS, B1_OPERPAD
        	EndSql

			While IMPOP->(!EOF())
				If !Empty(IMPOP->B1_OPERPAD)
					U_RPCPR013(IMPOP->PRIOP,IMPOP->ULTOP,_aOpImp,_cMarca)		
					_aOpImp := {}
				Else
					U_RPCPR006(IMPOP->PRIOP,IMPOP->ULTOP,_aOpImp, _cMarca)		
					_aOpImp := {}
				EndIf
			    IMPOP->(dbSkip())
     		EndDo
     		IMPOP->(dbCloseArea())    
   	//endif
EndIf
Return 
