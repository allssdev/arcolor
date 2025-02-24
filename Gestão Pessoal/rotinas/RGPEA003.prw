#include "totvs.ch"
/*/{Protheus.doc} RGPEA003
Rotina especifica para realizar a correção RD_HORAS para verbas "029" e "031".
@type  Function
@author Fernando Bombardi - ALLSS
@since 02/08/2022
@version 1.0 (P12.1.33)
/*/
user function RGPEA003()
	local _lExeFun := .F.
	Private _lProc := .T.
	DEFINE MSDIALOG oDlg FROM  96,4 TO 355,625 TITLE 'Correção RD_HORAS' PIXEL
	@ 18, 9 TO 99, 300 LABEL "" OF oDlg  PIXEL
	@ 29, 15 Say "A presente rotina tem por objetivo realizar a correção RD_HORAS para verbas 029 e 031."  SIZE 275, 10 OF oDlg PIXEL
	DEFINE SBUTTON FROM 108,238 TYPE 1 ACTION (_lExeFun:=.T.,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 108,267 TYPE 2 ACTION (_lExeFun := .F.,oDlg:End()) ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg
	if _lExeFun
		MsgRun("Realizando as alterações de verba...","Aguarde um momento, processando sua requisicao",{|| RGPEA03P() })
	    MsgInfo("Processamento finalizado com sucesso.","[RGPEA003_001] - Aviso")
	endif
return .T.
/*/{Protheus.doc} RGPEA03P
Função para atualizar verbas da tabela SRD
@type  Function
@author Fernando Bombardi - ALLSS
@since 02/08/2022
@version p12.1.33
/*/
Static Function RGPEA03P()
	BeginSQL alias "QRYSRD"
		SELECT 
			RD_FILIAL, RD_MAT, RD_DATARQ, RD_PD, RD_VALOR
		FROM 
			%table:SRD% SRD
		WHERE
			RD_DATARQ BETWEEN '202201' AND '202205'
			AND RD_PD = '950'
			AND SRD.%notDel%
		ORDER BY RD_MAT
	EndSQL
	dbSelectArea("QRYSRD")
	if QRYSRD->(!EOF())
		while QRYSRD->(!EOF())
			_nValor := QRYSRD->RD_VALOR / 220
			DBSelectArea("SRD")
			SRD->(dbSetOrder(1)) //RD_FILIAL, RD_MAT, RD_DATARQ, RD_PD, RD_SEMANA, RD_SEQ, RD_CC, RD_PROCES, R_E_C_N_O_, D_E_L_E_T_
			if dbSeek(QRYSRD->RD_FILIAL+QRYSRD->RD_MAT+QRYSRD->RD_DATARQ+"029")
				RecLock("SRD",.F.)
				//SRD->RD_VALOR := _nValor
                SRD->RD_HORAS := (SRD->RD_VALOR / Round(_nValor,2))
				SRD->(MsUnlock())
			ENDIF
			DBSelectArea("SRD")
			SRD->(dbSetOrder(1)) //RD_FILIAL, RD_MAT, RD_DATARQ, RD_PD, RD_SEMANA, RD_SEQ, RD_CC, RD_PROCES, R_E_C_N_O_, D_E_L_E_T_
			if dbSeek(QRYSRD->RD_FILIAL+QRYSRD->RD_MAT+QRYSRD->RD_DATARQ+"031")
				RecLock("SRD",.F.)
				//SRD->RD_VALOR := _nValor
                SRD->RD_HORAS := (SRD->RD_VALOR / Round(_nValor,2))
				SRD->(MsUnlock())
			ENDIF
			dbSelectArea("QRYSRD")
			QRYSRD->(dbSkip())
		enddo
	else
		MsgAlert("Não foram encontrados dados a serem processados. Por favor, verifique os parâmetros informados!","[RGPEA003_002] - Atenção")
		_lProc := .F.
	endif
	QRYSRD->(dbCloseArea())
Return
