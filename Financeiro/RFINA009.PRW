#Include "TOTVS.ch"
#Include "PROTHEUS.ch"
#INCLUDE "RwMake.ch"

/*/{Protheus.doc} RFINA009
@description Rotina responsável por gerar os titulos no contas a pagar dos adiantamentos de comissão do tipo de venda consignado
@author Diego Rodrigues (ALL System Solutions)
@since 18/10/2024
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RFINA009()
    Local aArea       := SE1->(GetArea())
	Private _cRotina := "RFINA009"
	Private _cPerg   := _cRotina

	ValidPerg()
	If Pergunte(_cPerg,.T.)
		Processa({ |lEnd| GERAPA(@lEnd) },_cRotina + "_001",' Verificando os titulos a serem processados. Aguarde...',.T.)
	EndIf
    
    // Restaura a área de trabalho
    Restarea(aArea)
return

/*/{Protheus.doc} GERAPA
@description SubRotina de geração dos titulos do tipo PA no contas a pagar
@author Diego Rodrigues (ALL System Solutions)
@since 18/10/2024
@version 1.0
@param lEnd, logical, Se houve cancelamento ou não desta operação.
@type function
@see https://allss.com.br
/*/
Static Function GERAPA(lEnd)

    Local _nx         := 0
    Local _aDados     := {}
    Local _cTipo      := "PA"    // Tipo do Titulo
    Local _dVencto    := Dtos(MV_PAR05)
    Local _dVencReal  := Dtos(MV_PAR05)
    Local _cHist      := ""
    Local _cBanco     := "341"
    Local _cAgencia   := "6748"
    Local _cConta     := "08277"
    Local _cPrefixo   := "CON"

    // Executa a query no banco de dados e armazena os resultados em _aDados
    BeginSql Alias "GERPA"
        SELECT
            COMISPARC.EMISSAO, COMISPARC.NFISCAL,COMISPARC.SERIENF
            ,COMISPARC.COD_CLI, COMISPARC.LOJA_CLI, COMISPARC.NOME_CLIENTE,COMISPARC.A1_BCO1,COMISPARC.A1_AGENCIA,COMISPARC.A1_BCCONT
            ,COMISPARC.COD_VEND, COMISPARC.NOME_VENDEDOR,COMISPARC.COD_FOR,COMISPARC.LOJA_FOR,COMISPARC.NATUREZA
            ,SUM(COMISPARC.VLRBRUTO) VLRBRUTO
            ,SUM(COMISPARC.VLRLIQ) VLRLIQ
            ,SUM(COMISPARC.COM_VLRBRUTO) COM_VLRBRUTO
            ,SUM(COMISPARC.COM_VLRLIQ) COM_VLRLIQ
            ,ROUND(SUM(COMISPARC.COM_VLRLIQ)/4,2) PARC_VLRLIQ
            ,COMISPARC.PARCELA
        FROM
        (
            SELECT
            COMISSAO.EMISSAO, COMISSAO.NFISCAL,COMISSAO.SERIENF
            ,COMISSAO.COD_CLI, COMISSAO.LOJA_CLI, COMISSAO.NOME_CLIENTE,COMISSAO.A1_BCO1,COMISSAO.A1_AGENCIA,COMISSAO.A1_BCCONT
            ,COMISSAO.COD_VEND, COMISSAO.NOME_VENDEDOR,COMISSAO.COD_FOR,COMISSAO.LOJA_FOR,COMISSAO.NATUREZA
            ,SUM(COMISSAO.VLRBRUTO) VLRBRUTO
            ,SUM(COMISSAO.VLRLIQ) VLRLIQ
            ,SUM(COMISSAO.COMISSAO_VLRBRUTO) COM_VLRBRUTO
            ,SUM(COMISSAO.COMISSAO_VLRLIQ) COM_VLRLIQ
            ,ROUND(SUM(COMISSAO.COMISSAO_VLRLIQ)/4,2) PARC_VLRLIQ
            ,'1' PARCELA
            FROM
            (
                SELECT
                    SUBSTRING(D2_EMISSAO,7,2)+'/'+SUBSTRING(D2_EMISSAO,5,2)+'/'+SUBSTRING(D2_EMISSAO,1,4) EMISSAO
                    ,D2_DOC NFISCAL, D2_SERIE SERIENF
                    ,D2_CLIENTE COD_CLI, D2_LOJA LOJA_CLI, A1_NOME NOME_CLIENTE,A1_BCO1,A1_AGENCIA,A1_BCCONT
                    ,A1_VEND COD_VEND, A3_NOME NOME_VENDEDOR,A3_FORNECE COD_FOR,A3_LOJA LOJA_FOR,A2_NATUREZ NATUREZA
                    , D2_COMIS1 COMISSAO
                    ,SUM(D2_VALBRUT) VLRBRUTO
                    ,SUM(D2_TOTAL) VLRLIQ
                    ,ROUND(SUM(D2_VALBRUT)*D2_COMIS1/100,2) COMISSAO_VLRBRUTO
                    ,ROUND(SUM(D2_TOTAL)*D2_COMIS1/100,2) COMISSAO_VLRLIQ
                FROM SD2010 SD2 (NOLOCK)
                INNER JOIN SA1010 SA1 (NOLOCK) ON SA1.D_E_L_E_T_ = '' AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA
                INNER JOIN SA3010 SA3 (NOLOCK) ON SA3.D_E_L_E_T_ = '' AND A3_COD = A1_VEND
                INNER JOIN SA2010 SA2 (NOLOCK) ON SA2.D_E_L_E_T_ = '' AND A2_COD = A3_FORNECE AND A2_LOJA = A3_LOJA
                WHERE SD2.D_E_L_E_T_ = ''
                AND D2_EMISSAO BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
                AND A3_COD BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
                AND SD2.D2_TIPOPER = '06'
                AND SUBSTRING(A3_NOME,1,6) <> 'DIRETO'
                GROUP BY D2_EMISSAO, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA,A1_NOME, A1_VEND,A3_NOME, D2_COMIS1,A3_FORNECE,A3_LOJA
                ,A1_BCO1,A1_AGENCIA,A1_BCCONT,A2_NATUREZ
            )COMISSAO
            GROUP BY  COMISSAO.EMISSAO, COMISSAO.NFISCAL,COMISSAO.SERIENF
            ,COMISSAO.COD_CLI, COMISSAO.LOJA_CLI, COMISSAO.NOME_CLIENTE,COMISSAO.A1_BCO1,COMISSAO.A1_AGENCIA,COMISSAO.A1_BCCONT
            ,COMISSAO.COD_VEND, COMISSAO.NOME_VENDEDOR,COMISSAO.COD_FOR,COMISSAO.LOJA_FOR,COMISSAO.NATUREZA
            
            UNION ALL
            
            SELECT
                COMISSAO.EMISSAO, COMISSAO.NFISCAL,COMISSAO.SERIENF
                ,COMISSAO.COD_CLI, COMISSAO.LOJA_CLI, COMISSAO.NOME_CLIENTE,COMISSAO.A1_BCO1,COMISSAO.A1_AGENCIA,COMISSAO.A1_BCCONT
                ,COMISSAO.COD_VEND, COMISSAO.NOME_VENDEDOR,COMISSAO.COD_FOR,COMISSAO.LOJA_FOR,COMISSAO.NATUREZA
                ,SUM(COMISSAO.VLRBRUTO) VLRBRUTO
                ,SUM(COMISSAO.VLRLIQ) VLRLIQ
                ,SUM(COMISSAO.COMISSAO_VLRBRUTO) COM_VLRBRUTO
                ,SUM(COMISSAO.COMISSAO_VLRLIQ) COM_VLRLIQ
                ,ROUND(SUM(COMISSAO.COMISSAO_VLRLIQ)/4,2) PARC_VLRLIQ
                ,'2' PARCELA
            FROM
                (
                    SELECT
                        SUBSTRING(D2_EMISSAO,7,2)+'/'+SUBSTRING(D2_EMISSAO,5,2)+'/'+SUBSTRING(D2_EMISSAO,1,4) EMISSAO
                        ,D2_DOC NFISCAL, D2_SERIE SERIENF
                        ,D2_CLIENTE COD_CLI, D2_LOJA LOJA_CLI, A1_NOME NOME_CLIENTE,A1_BCO1,A1_AGENCIA,A1_BCCONT
                        ,A1_VEND COD_VEND, A3_NOME NOME_VENDEDOR,A3_FORNECE COD_FOR,A3_LOJA LOJA_FOR,A2_NATUREZ NATUREZA
                        ,D2_COMIS1 COMISSAO
                        ,SUM(D2_VALBRUT) VLRBRUTO
                        ,SUM(D2_TOTAL) VLRLIQ
                        ,ROUND(SUM(D2_VALBRUT)*D2_COMIS1/100,2) COMISSAO_VLRBRUTO
                        ,ROUND(SUM(D2_TOTAL)*D2_COMIS1/100,2) COMISSAO_VLRLIQ
                        
                    FROM SD2010 SD2 (NOLOCK)
                    INNER JOIN SA1010 SA1 (NOLOCK) ON SA1.D_E_L_E_T_ = '' AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA
                    INNER JOIN SA3010 SA3 (NOLOCK) ON SA3.D_E_L_E_T_ = '' AND A3_COD = A1_VEND
                    INNER JOIN SA2010 SA2 (NOLOCK) ON SA2.D_E_L_E_T_ = '' AND A2_COD = A3_FORNECE AND A2_LOJA = A3_LOJA
                    WHERE SD2.D_E_L_E_T_ = ''
                    AND D2_EMISSAO BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
                    AND A3_COD BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
                    AND SD2.D2_TIPOPER = '06'
                    AND SUBSTRING(A3_NOME,1,6) <> 'DIRETO'
                    GROUP BY D2_EMISSAO, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA,A1_NOME, A1_VEND,A3_NOME, D2_COMIS1,A3_FORNECE,A3_LOJA
                    ,A1_BCO1,A1_AGENCIA,A1_BCCONT,A2_NATUREZ
                )COMISSAO
                GROUP BY  COMISSAO.EMISSAO, COMISSAO.NFISCAL,COMISSAO.SERIENF
                ,COMISSAO.COD_CLI, COMISSAO.LOJA_CLI, COMISSAO.NOME_CLIENTE,COMISSAO.A1_BCO1,COMISSAO.A1_AGENCIA,COMISSAO.A1_BCCONT
                ,COMISSAO.COD_VEND, COMISSAO.NOME_VENDEDOR,COMISSAO.COD_FOR,COMISSAO.LOJA_FOR,COMISSAO.NATUREZA

            UNION ALL
            
            SELECT
                COMISSAO.EMISSAO, COMISSAO.NFISCAL,COMISSAO.SERIENF
                ,COMISSAO.COD_CLI, COMISSAO.LOJA_CLI, COMISSAO.NOME_CLIENTE,COMISSAO.A1_BCO1,COMISSAO.A1_AGENCIA,COMISSAO.A1_BCCONT
                ,COMISSAO.COD_VEND, COMISSAO.NOME_VENDEDOR,COMISSAO.COD_FOR,COMISSAO.LOJA_FOR,COMISSAO.NATUREZA
                ,SUM(COMISSAO.VLRBRUTO) VLRBRUTO
                ,SUM(COMISSAO.VLRLIQ) VLRLIQ
                ,SUM(COMISSAO.COMISSAO_VLRBRUTO) COM_VLRBRUTO
                ,SUM(COMISSAO.COMISSAO_VLRLIQ) COM_VLRLIQ
                ,ROUND(SUM(COMISSAO.COMISSAO_VLRLIQ)/4,2) PARC_VLRLIQ
                ,'3' PARCELA
            FROM
                (
                    SELECT
                        SUBSTRING(D2_EMISSAO,7,2)+'/'+SUBSTRING(D2_EMISSAO,5,2)+'/'+SUBSTRING(D2_EMISSAO,1,4) EMISSAO
                        ,D2_DOC NFISCAL, D2_SERIE SERIENF
                        ,D2_CLIENTE COD_CLI, D2_LOJA LOJA_CLI, A1_NOME NOME_CLIENTE,A1_BCO1,A1_AGENCIA,A1_BCCONT
                        ,A1_VEND COD_VEND, A3_NOME NOME_VENDEDOR,A3_FORNECE COD_FOR,A3_LOJA LOJA_FOR,A2_NATUREZ NATUREZA
                        ,D2_COMIS1 COMISSAO
                        ,SUM(D2_VALBRUT) VLRBRUTO
                        ,SUM(D2_TOTAL) VLRLIQ
                        ,ROUND(SUM(D2_VALBRUT)*D2_COMIS1/100,2) COMISSAO_VLRBRUTO
                        ,ROUND(SUM(D2_TOTAL)*D2_COMIS1/100,2) COMISSAO_VLRLIQ
                        
                    FROM SD2010 SD2 (NOLOCK)
                    INNER JOIN SA1010 SA1 (NOLOCK) ON SA1.D_E_L_E_T_ = '' AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA
                    INNER JOIN SA3010 SA3 (NOLOCK) ON SA3.D_E_L_E_T_ = '' AND A3_COD = A1_VEND
                    INNER JOIN SA2010 SA2 (NOLOCK) ON SA2.D_E_L_E_T_ = '' AND A2_COD = A3_FORNECE AND A2_LOJA = A3_LOJA
                    WHERE SD2.D_E_L_E_T_ = ''
                    AND D2_EMISSAO BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
                    AND A3_COD BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
                    AND SD2.D2_TIPOPER = '06'
                    AND SUBSTRING(A3_NOME,1,6) <> 'DIRETO'
                    GROUP BY D2_EMISSAO, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA,A1_NOME, A1_VEND,A3_NOME, D2_COMIS1,A3_FORNECE,A3_LOJA
                    ,A1_BCO1,A1_AGENCIA,A1_BCCONT,A2_NATUREZ
                )COMISSAO
                GROUP BY  COMISSAO.EMISSAO, COMISSAO.NFISCAL,COMISSAO.SERIENF
                ,COMISSAO.COD_CLI, COMISSAO.LOJA_CLI, COMISSAO.NOME_CLIENTE,COMISSAO.A1_BCO1,COMISSAO.A1_AGENCIA,COMISSAO.A1_BCCONT
                ,COMISSAO.COD_VEND, COMISSAO.NOME_VENDEDOR,COMISSAO.COD_FOR,COMISSAO.LOJA_FOR,COMISSAO.NATUREZA
            
            UNION ALL
            
            SELECT
                COMISSAO.EMISSAO, COMISSAO.NFISCAL,COMISSAO.SERIENF
                ,COMISSAO.COD_CLI, COMISSAO.LOJA_CLI, COMISSAO.NOME_CLIENTE,COMISSAO.A1_BCO1,COMISSAO.A1_AGENCIA,COMISSAO.A1_BCCONT
                ,COMISSAO.COD_VEND, COMISSAO.NOME_VENDEDOR,COMISSAO.COD_FOR,COMISSAO.LOJA_FOR,COMISSAO.NATUREZA
                ,SUM(COMISSAO.VLRBRUTO) VLRBRUTO
                ,SUM(COMISSAO.VLRLIQ) VLRLIQ
                ,SUM(COMISSAO.COMISSAO_VLRBRUTO) COM_VLRBRUTO
                ,SUM(COMISSAO.COMISSAO_VLRLIQ) COM_VLRLIQ
                ,ROUND(SUM(COMISSAO.COMISSAO_VLRLIQ)/4,2) PARC_VLRLIQ
                ,'4' PARCELA
            FROM
                (
                    SELECT
                        SUBSTRING(D2_EMISSAO,7,2)+'/'+SUBSTRING(D2_EMISSAO,5,2)+'/'+SUBSTRING(D2_EMISSAO,1,4) EMISSAO
                        ,D2_DOC NFISCAL, D2_SERIE SERIENF
                        ,D2_CLIENTE COD_CLI, D2_LOJA LOJA_CLI, A1_NOME NOME_CLIENTE,A1_BCO1,A1_AGENCIA,A1_BCCONT
                        ,A1_VEND COD_VEND, A3_NOME NOME_VENDEDOR,A3_FORNECE COD_FOR,A3_LOJA LOJA_FOR,A2_NATUREZ NATUREZA
                        ,D2_COMIS1 COMISSAO
                        ,SUM(D2_VALBRUT) VLRBRUTO
                        ,SUM(D2_TOTAL) VLRLIQ
                        ,ROUND(SUM(D2_VALBRUT)*D2_COMIS1/100,2) COMISSAO_VLRBRUTO
                        ,ROUND(SUM(D2_TOTAL)*D2_COMIS1/100,2) COMISSAO_VLRLIQ
                        
                    FROM SD2010 SD2 (NOLOCK)
                    INNER JOIN SA1010 SA1 (NOLOCK) ON SA1.D_E_L_E_T_ = '' AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA
                    INNER JOIN SA3010 SA3 (NOLOCK) ON SA3.D_E_L_E_T_ = '' AND A3_COD = A1_VEND
                    INNER JOIN SA2010 SA2 (NOLOCK) ON SA2.D_E_L_E_T_ = '' AND A2_COD = A3_FORNECE AND A2_LOJA = A3_LOJA
                    WHERE SD2.D_E_L_E_T_ = ''
                    AND D2_EMISSAO BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
                    AND A3_COD BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
                    AND SD2.D2_TIPOPER = '06'
                    AND SUBSTRING(A3_NOME,1,6) <> 'DIRETO'
                    GROUP BY D2_EMISSAO, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA,A1_NOME, A1_VEND,A3_NOME, D2_COMIS1,A3_FORNECE,A3_LOJA
                    ,A1_BCO1,A1_AGENCIA,A1_BCCONT,A2_NATUREZ
                )COMISSAO
                GROUP BY  COMISSAO.EMISSAO, COMISSAO.NFISCAL,COMISSAO.SERIENF
                ,COMISSAO.COD_CLI, COMISSAO.LOJA_CLI, COMISSAO.NOME_CLIENTE,COMISSAO.A1_BCO1,COMISSAO.A1_AGENCIA,COMISSAO.A1_BCCONT
                ,COMISSAO.COD_VEND, COMISSAO.NOME_VENDEDOR,COMISSAO.COD_FOR,COMISSAO.LOJA_FOR,COMISSAO.NATUREZA
        )COMISPARC
        GROUP BY COMISPARC.EMISSAO, COMISPARC.NFISCAL,COMISPARC.SERIENF
                ,COMISPARC.COD_CLI, COMISPARC.LOJA_CLI, COMISPARC.NOME_CLIENTE,COMISPARC.A1_BCO1,COMISPARC.A1_AGENCIA,COMISPARC.A1_BCCONT
                ,COMISPARC.COD_VEND, COMISPARC.NOME_VENDEDOR,COMISPARC.COD_FOR,COMISPARC.LOJA_FOR
                ,COMISPARC.PARCELA,COMISPARC.NATUREZA
        ORDER BY COMISPARC.COD_VEND,COMISPARC.EMISSAO,COMISPARC.NFISCAL,COMISPARC.PARCELA
    EndSql

    While GERPA->(!EOF()) 
        AADD(_aDados,{  GERPA->EMISSAO,;
                        GERPA->NFISCAL,;
                        GERPA->SERIENF,;
                        GERPA->COD_FOR,;
                        GERPA->LOJA_FOR,;
                        GERPA->NOME_VENDEDOR,;
                        GERPA->PARC_VLRLIQ,;
                        GERPA->COD_VEND,;
                        GERPA->NOME_VENDEDOR,;
                        GERPA->PARCELA,;
                        _cBanco    ,;
                        _cAgencia  ,;
                        _cConta    ,;
                        GERPA->NATUREZA})
        GERPA->(dbSkip())
    EndDo
    GERPA->(dbCloseArea())

    // Verifica se a consulta retornou resultados
    If Len(_aDados) == 0
        MsgInfo("Nenhum título pendente encontrado.")
        Return .F.
    EndIf

    // Itera sobre os resultados da query
    For _nX := 1 to Len(_aDados)

        _cHist := "REF COM CONSIG VEND: "+Alltrim(_aDados[_nX][8])+" "+Alltrim(_aDados[_nX][9])
        //Prepara o array para o execauto
        aVetSE2 := {}
        aAdd(aVetSE2, {"E2_FILIAL"  ,  FWxFilial("SE2")                         ,  Nil})
        aAdd(aVetSE2, {"E2_NUM"     , cValToChar(_aDados[_nX][2])               ,  Nil})
        aAdd(aVetSE2, {"E2_PREFIXO" , _cPrefixo                                 ,  Nil})
        aAdd(aVetSE2, {"E2_PARCELA" , cValToChar(_aDados[_nX][10])              ,  Nil})
        aAdd(aVetSE2, {"E2_TIPO"    , _cTipo                                    ,  Nil})
        //aAdd(aVetSE2, {"E2_NATUREZ" , cValToChar(_aDados[_nX][14])              ,  Nil})
        aAdd(aVetSE2, {"E2_NATUREZ" , "202080"                                  ,  Nil})
        aAdd(aVetSE2, {"E2_FORNECE" , cValToChar(_aDados[_nX][4])               ,  Nil})
        aAdd(aVetSE2, {"E2_LOJA"    , cValToChar(_aDados[_nX][5])               ,  Nil})
        aAdd(aVetSE2, {"E2_NOMFOR"  , Substr(_aDados[_nX][6],1,20)              ,  Nil})
        aAdd(aVetSE2, {"E2_EMISSAO" , ddatabase                                 ,  Nil})
        aAdd(aVetSE2, {"E2_VENCTO"  , STOD(_dVencto)                            ,  Nil})
        aAdd(aVetSE2, {"E2_VENCREA" , STOD(_dVencReal)                          ,  Nil})
        aAdd(aVetSE2, {"E2_VALOR"   , _aDados[_nX][7]                           ,  Nil})
        aAdd(aVetSE2, {"E2_HIST"    , _cHist                                    ,  Nil})
        aAdd(aVetSE2, {"E2_MOEDA"   , 1                                         ,  Nil})
        aAdd(aVetSE2, {"AUTBANCO"   , cValToChar(_aDados[_nX][11])              ,  Nil})
        aAdd(aVetSE2, {"AUTAGENCIA" , cValToChar(_aDados[_nX][12])              ,  Nil})
        aAdd(aVetSE2, {"AUTCONTA"   , cValToChar(_aDados[_nX][13])              ,  Nil})
        
        //Inicia o controle de transação
        Begin Transaction
            //Chama a rotina automática
            lMsErroAuto := .F.
            MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aVetSE2,, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
            
            //Se houve erro, mostra o erro ao usuário e desarma a transação
            If lMsErroAuto
                MostraErro()
                DisarmTransaction()
            EndIf
        //Finaliza a transação
        End Transaction

    Next
Return .T. 

/*/{Protheus.doc} ValidPerg
@description Valida as perguntas no arquivo SX1.
@author Diego Rodrigues (ALL System Solutions)
@since 18/04/2024
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	local _aAlias    := GetArea()
	local aRegs     := {}
	local _aTam      := {}
	local _x         := 0
	local _y         := 0
	local _cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()

	if select(_cAliasSX1)>0
		(_cAliasSX1)->(dbCloseArea())
	endif
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))

	_cPerg           := PADR(_cPerg,len((_cAliasSX1)->X1_GRUPO))
	_aTam            := TamSx3("D2_EMISSAO")
	AADD(aRegs,{_cPerg,"01","De Emissão?"               ,"","","mv_ch1",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""     ,"","","",""})
	AADD(aRegs,{_cPerg,"02","Até Emissão?"              ,"","","mv_ch2",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""     ,"","","",""})
    _aTam            := TamSx3("A3_COD")
	AADD(aRegs,{_cPerg,"03","Do Representante?"			,"","","mv_ch3",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA3"  ,"","","",""})
	AADD(aRegs,{_cPerg,"04","Ao Representante?"			,"","","mv_ch4",_aTam[3],_aTam[1],_aTam[2],0,"G","NAOVAZIO()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SA3"  ,"","","",""})
	_aTam            := TamSx3("E2_VENCREA")
	AADD(aRegs,{_cPerg,"05","Vencimento Titulo?"	    ,"","","mv_ch5",_aTam[3],_aTam[1],_aTam[2],0,"G","NAOVAZIO()","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""     ,"","","",""})
    for _x := 1 To Len(aRegs)
		if !(_cAliasSX1)->(dbSeek(_cPerg+aRegs[_x,2],.T.,.F.))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				for _y := 1 to FCount()
					if _y <= len(aRegs[_x])
						FieldPut(_y,aRegs[_x,_y])
					else
						Exit
					endif
				next
			(_cAliasSX1)->(MsUnLock())
		endif
	next
	if select(_cAliasSX1)>0
		(_cAliasSX1)->(dbCloseArea())
	endif
	RestArea(_aAlias)
return
