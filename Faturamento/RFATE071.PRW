#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} RFATE071
    Rotina para exibir o campo Observaçoes do Pedido de Venda
    @type  Static Function
    @author Fernando Bombardi
    @since 13/07/2023
    @version 1.0
/*/
User Function RFATE071()
Local _cMsgPv := ""
DEFINE FONT oFont6 NAME "Courier New" SIZE 6,20

    BeginSql Alias "PEDIDO"
        SELECT SC5.R_E_C_N_O_ AS RECNO
        FROM %table:SD2% SD2
            INNER JOIN %table:SC5% SC5 
            ON SD2.D2_FILIAL = SC5.C5_FILIAL 
            AND SD2.D2_PEDIDO = SC5.C5_NUM
            AND SD2.D2_CLIENTE = SC5.C5_CLIENTE
            AND SD2.D2_LOJA = SC5.C5_LOJACLI
            AND SC5.%notDel%
        WHERE 
            SD2.D2_FILIAL = %xFilial:SG1%  
            AND SD2.D2_DOC = %exp:SF2->F2_DOC%
            AND SD2.D2_SERIE = %exp:SF2->F2_SERIE%
            AND SD2.D2_CLIENTE = %exp:SF2->F2_CLIENTE%
            AND SD2.D2_LOJA = %exp:SF2->F2_LOJA%
            AND SD2.%notDel%
        GROUP BY SC5.R_E_C_N_O_
    EndSql
    if PEDIDO->(!EOF())
        _nRecno := PEDIDO->RECNO

        dbSelectArea("SC5")
        SC5->(dbGoTo(_nRecno))
        _cMsgPv := SC5->C5_OBSSEP

    endif
    PEDIDO->(dbCloseArea())

	DEFINE MSDIALOG oProdd FROM 0,0 TO 300,420 PIXEL TITLE "Observações - Pedido de Venda"
	@ 005,005 say "Observações:" SIZE 150,40 FONT oFont6 OF oProdd PIXEL COLOR CLR_HBLUE
	@ 015,005 GET oMemo VAR _cMsgPv MEMO SIZE 200,135 FONT oFont6 PIXEL OF oProdd
	ACTIVATE MSDIALOG oProdd CENTER

Return
