#include "Totvs.ch"

/*/{Protheus.doc} RPCPC002
    Classe responsável da rotina de Recall de produtos.
    @type  Function
    @author Fernando Bombardi
    @since 23/10/2023
    @version 1.0
    /*/
Class RPCPC002

    Method New() CONSTRUCTOR
    Method ConsultaLote()

EndClass

/*/{Protheus.doc} New
    Metodo construtor da classe
    @type  Method
    @author Fernando Bombardi
    @since 23/10/2023
    @version 1.0
    /*/
Method New() class RPCPC002
    
Return Self

/*/{Protheus.doc} ConsultaLote
    Metodo para realizar a consulta do lote conforme definido nos parametros da rotina.
    @type  Method
    @author Fernando Bombardi
    @since 23/10/2023
    @version 1.0
    /*/
Method ConsultaLote(_cLoteCtl, _cProd, _cTipo) class RPCPC002

    Do Case

        Case _cTipo == "1" // PA

            BeginSql alias 'FATURADOONDE'
                SELECT 
                    D2_DOC,
                    D2_SERIE,
                    D2_COD,
                    D2_TP,
                    D2_QUANT,
                    D2_LOTECTL,
                    D2_DTVALID,
                    D2_CLIENTE,
                    D2_LOJA,
                    F2_VEND1
                FROM  
                    %table:SD2% SD2 (NOLOCK) INNER JOIN %table:SF2% SF2 (NOLOCK)
                    ON SD2.D2_FILIAL = SF2.F2_FILIAL AND SD2.D2_DOC = SF2.F2_DOC 
                    AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_CLIENTE = SF2.F2_CLIENTE
                    AND SD2.D2_LOJA = SF2.F2_LOJA AND SF2.%NotDel%
                WHERE 
                    D2_FILIAL =  %xFilial:SD2% 
                    AND D2_COD = %Exp:_cProd%
                    AND D2_LOTECTL = %Exp:_cLoteCtl%
                    AND SD2.%NotDel%
                ORDER BY SF2.F2_VEND1, SD2.D2_CLIENTE, SD2.D2_LOJA
            EndSql	

            _cQry := GetLastQuery()[2]

            If FATURADOONDE->(!EOF())

                While FATURADOONDE->(!EOF())

                    While Alltrim(_cVend) == Alltrim(FATURADOONDE->F2_VEND1)

                        FATURADOONDE->(dbSkip())
                        if _cVend <> Alltrim(FATURADOONDE->F2_VEND1)
                            _cVend := Alltrim(FATURADOONDE->F2_VEND1)
                            Loop
                        endif

                    EndDo

                EndDo

            EndIf
            FATURADOONDE->(dbCloseArea())

        Case _cTipo == "2" // PI

            BeginSql alias 'RASTLOTE'
                SELECT 
                    D3_EMISSAO,D3_OP,D3_COD,D3_QUANT,D3_LOTECTL,D3_NUMSEQ,D3_TM,D3_CF,B1_TIPO,B1_DESC 
                FROM  
                    %table:SD3% SD3 (NOLOCK) INNER JOIN  %table:SB1% SB1 (NOLOCK)
                    ON B1_COD = D3_COD AND SB1.%NotDel%
                WHERE 
                    D3_FILIAL =  %xFilial:SC2%  
                    AND D3_COD BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
                    AND D3_OP BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
                    AND D3_LOTECTL BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
                    AND SD3.%NotDel%
                ORDER BY D3_NUMSEQ, D3_TM
            EndSql

            BeginSql alias 'FATURADOONDE'
                SELECT 
                    D2_DOC,
                    D2_SERIE,
                    D2_COD,
                    D2_TP,
                    D2_QUANT,
                    D2_LOTECTL,
                    D2_DTVALID,
                    D2_CLIENTE,
                    D2_LOJA,
                    F2_VEND1
                FROM  
                    %table:SD2% SD2 (NOLOCK) INNER JOIN %table:SF2% SF2 (NOLOCK)
                    ON SD2.D2_FILIAL = SF2.F2_FILIAL AND SD2.D2_DOC = SF2.F2_DOC 
                    AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_CLIENTE = SF2.F2_CLIENTE
                    AND SD2.D2_LOJA = SF2.F2_LOJA AND SF2.%NotDel%
                WHERE 
                    D2_FILIAL =  %xFilial:SD2% 
                    AND D2_COD = %Exp:_cProd%
                    AND D2_LOTECTL = %Exp:_cLoteCtl%
                    AND SD2.%NotDel%
                ORDER BY SF2.F2_VEND1, SD2.D2_CLIENTE, SD2.D2_LOJA
            EndSql		

        Case _cTipo == "3" // MP/EM

            BeginSql alias 'RASTLOTE'
                SELECT 
                    D3_EMISSAO,D3_OP,D3_COD,D3_QUANT,D3_LOTECTL,D3_NUMSEQ,D3_TM,D3_CF,B1_TIPO,B1_DESC 
                FROM  
                    %table:SD3% SD3 (NOLOCK) INNER JOIN  %table:SB1% SB1 (NOLOCK)
                    ON B1_COD = D3_COD AND SB1.%NotDel%
                WHERE 
                    D3_FILIAL =  %xFilial:SC2%  
                    AND D3_COD BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
                    AND D3_OP BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
                    AND D3_LOTECTL BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
                    AND SD3.%NotDel%
                ORDER BY D3_NUMSEQ, D3_TM
            EndSql

            BeginSql alias 'FATURADOONDE'
                SELECT 
                    D2_DOC,
                    D2_SERIE,
                    D2_COD,
                    D2_TP,
                    D2_QUANT,
                    D2_LOTECTL,
                    D2_DTVALID,
                    D2_CLIENTE,
                    D2_LOJA,
                    F2_VEND1
                FROM  
                    %table:SD2% SD2 (NOLOCK) INNER JOIN %table:SF2% SF2 (NOLOCK)
                    ON SD2.D2_FILIAL = SF2.F2_FILIAL AND SD2.D2_DOC = SF2.F2_DOC 
                    AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_CLIENTE = SF2.F2_CLIENTE
                    AND SD2.D2_LOJA = SF2.F2_LOJA AND SF2.%NotDel%
                WHERE 
                    D2_FILIAL =  %xFilial:SD2% 
                    AND D2_COD = %Exp:_cProd%
                    AND D2_LOTECTL = %Exp:_cLoteCtl%
                    AND SD2.%NotDel%
                ORDER BY SF2.F2_VEND1, SD2.D2_CLIENTE, SD2.D2_LOJA
            EndSql		

    End Case





Return
