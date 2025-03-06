#include 'totvs.ch'
#include 'rwmake.ch'
#include 'protheus.ch'
#include 'apwizard.ch'
#include 'fileio.ch'
#include 'rptdef.ch'
#include 'fwprintsetup.ch'
#include 'parmtype.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'
#include 'fwmvcdef.ch'
#include 'olecont.ch'
#define STR_PULA CHR(13) + CHR(10)
#define PAD_LEFT    0
#define PAD_RIGHT   1
#define PAD_CENTER  2
#define CLRF CHR(13)+CHR(10)
/*/{Protheus.doc} RFATR051
Rotina automática para envio de e-mail da nova meta de vendas para representantes comerciais 
RESUMO POR REPRESENTANTE
@author Rodrigo Telecio (rodrigo.telecio@allss.com.br) - ALLSS Soluções em Sistemas
@since 02/08/2022
@version P12.1.33
@type Function
@obs Sem observações
@see https://allss.com.br/
@history 02/08/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Versão inicial da rotina.
@history 22/08/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Aplicação no ambiente de produção.
@history 24/08/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Ajuste com adição de percentuais no resumo da meta global.
@history 31/08/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Ajuste com adição de percentuais no resumo da meta do representante.
@history 14/09/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Adição de data da posição do e-mail e troca do termo "SALDO" para "SALDO".
@history 03/11/2022, Diego Rodrigues (diego.rodrigues@allss.com.br), Alteração da ordem de calculo do saldo "_nReal - _nMeta" e troca do termo "FALTANTE" para "SALDO".
/*/
user function RFATR051(_cTipo)
local   nAntes  				:= 2
local   dDeData 				:= StoD('')
local   dAtData 				:= StoD('')
local   cAliasAC6               := GetNextAlias()
local   cMeta                   := ""
local   cTitMeta                := ""
private cRotina 				:= ""
private oProcessa
private cArquivo 				:= "RFATR051"
private cTitulo  				:= "Acompanhamento das Metas de Vendas - Resumo por Representante"
private cText					:= "Acompanhamento das Metas de Vendas - Resumo por Representante"
//private lBlind 				:= .T. //temporário, reativar
private lBlind 					:= IsBlind()
private cEmpExec				:= "01"
private cFilExec				:= "01"
private cUsuario				:= ""
private cArqLogs				:= ""
private aArqsLog                := {}
private lValida 				:= .T.
default _cTipo   				:= "M"
if lBlind
	PREPARE ENVIRONMENT EMPRESA cEmpExec FILIAL cFilExec MODULO 'FAT'
	cRotina 				:= "RFATR051 - " + AllTrim(FunName()) + " (Automático)"
	cUsuario				:= "Administrador"
	cArqLogs				:= AllTrim(SuperGetMv('MV_XARQLOG' ,.F.,'\04. Logs\'))
	AADD(aArqsLog,"INICIO - " + AllTrim(cRotina) + " - Acompanhamento das Metas de Vendas - Resumo por Representante")
	AADD(aArqsLog,"--------------------------------------------------------------------------------")
	AADD(aArqsLog,"Data/Hora do inicio de processamento: "      + AllTrim(DtoC(Date()))     + " - "         + AllTrim(Time()))
	AADD(aArqsLog,"*************************** EXECUÇÃO AUTOMÁTICA ********************************")
	AADD(aArqsLog,"Usuário responsável pelo processamento: "    + AllTrim(RetCodUsr())      + " - "         + UsrFullName(RetCodUsr()))
	AADD(aArqsLog,"Informações do ambiente: Protheus "          + AllTrim(GetRPORelease())  + " - Build "   + AllTrim(GetBuild(.F.)))
	AADD(aArqsLog,"--------------------------------------------------------------------------------")
    //****************************************************************************************
    //Query para captura da campanha (AC6/AC7) ativa no momento
    //****************************************************************************************
    BeginSql Alias cAliasAC6
        SELECT TOP 1
			AC6_META    AS META,
            AC6_TITULO  AS TITULO,
			AC6_DTINI   AS INICIO,
			AC6_DTFIM   AS FINAL
		FROM
            %table:AC6% AS AC6 (NOLOCK)
		WHERE
			AC6.AC6_FILIAL     = %xFilial:AC6%
			AND (%Exp:DtoS(DataValida(dDataBase-nAntes,.F.))% >= AC6.AC6_DTINI OR %Exp:DtoS(DataValida(dDataBase-nAntes,.F.))% <= AC6.AC6_DTFIM)
			AND AC6.AC6_MSBLQL <> %Exp:'1'%
			AND AC6.%notdel%
    EndSql
    MemoWrite("\2.MemoWrite\" + cRotina + "_QRY_001.TXT",GetLastQuery()[02])
    while !(cAliasAC6)->(EOF())
        dDeData 		    := StoD((cAliasAC6)->INICIO)
        dAtData 			:= StoD((cAliasAC6)->FINAL)
        cMeta               := (cAliasAC6)->META
        cTitMeta            := (cAliasAC6)->TITULO
        (cAliasAC6)->(dbSkip())
    enddo
    (cAliasAC6)->(dbCloseArea())
    if AllTrim(DtoS(dDeData)) != '' .OR. AllTrim(DtoS(dAtData)) != ''
        AADD(aArqsLog,"Campanha ativa e selecionada para composição de metas e valores: " + AllTrim(cMeta + '-' + cTitMeta))
        AADD(aArqsLog,"--------------------------------------------------------------------------------")
	    ProcMail1(_cTipo,dDeData,dAtData,cMeta,cTitMeta,.F.)
    else
        AADD(aArqsLog,"Não foi encontrada uma campanha ativa para composição de metas e valores.")
        AADD(aArqsLog,"--------------------------------------------------------------------------------")
    endif
else
	cRotina 				:= AllTrim(FunName()) + " (Manual)"
	cUsuario				:= UsrFullName(RetCodUsr())
	cArqLogs				:= AllTrim(SuperGetMv('MV_XARQLOG' ,.F.,'\04. Logs\'))
	AADD(aArqsLog,"INICIO - " + AllTrim(cRotina) + " - Acompanhamento das Metas de Vendas - Resumo por Representante")
	AADD(aArqsLog,"--------------------------------------------------------------------------------")
	AADD(aArqsLog,"***************************** EXECUÇÃO MANUAL **********************************")
	AADD(aArqsLog,"Data/Hora do inicio de processamento: "      + AllTrim(DtoC(Date()))     + " - "         + AllTrim(Time()))
	AADD(aArqsLog,"Usuário responsável pelo processamento: "    + AllTrim(RetCodUsr())      + " - "         + UsrFullName(RetCodUsr()))
	AADD(aArqsLog,"Informações do ambiente: Protheus "          + AllTrim(GetRPORelease())  + " - Build "   + AllTrim(GetBuild(.F.)))

	AADD(aArqsLog,"--------------------------------------------------------------------------------")
	if cEmpExec + cFilExec <> FWCodEmp() + FWCodFil()
    	Aviso('TOTVS','Empresa/filial nao autorizada para executar tal rotina.',{'&OK'},3,'Cancelamento de operação')
		AADD(aArqsLog,'Empresa/filial nao autorizada para executar tal rotina.')
		AADD(aArqsLog,"--------------------------------------------------------------------------------")
    	lValida					:= .F.
	else
        //****************************************************************************************
        //Query para captura da campanha (AC6/AC7) ativa no momento
        //****************************************************************************************
        BeginSql Alias cAliasAC6
            SELECT TOP 1
                AC6_META    AS META,
                AC6_TITULO  AS TITULO,
                AC6_DTINI   AS INICIO,
                AC6_DTFIM   AS FINAL
            FROM
                %table:AC6% AS AC6 (NOLOCK)
            WHERE
                AC6.AC6_FILIAL     = %xFilial:AC6%
                AND (%Exp:DtoS(DataValida(dDataBase-nAntes,.F.))% >= AC6.AC6_DTINI OR %Exp:DtoS(DataValida(dDataBase-nAntes,.F.))% <= AC6.AC6_DTFIM)
                AND AC6.AC6_MSBLQL <> %Exp:'1'%
                AND AC6.%notdel%
        EndSql
        MemoWrite("\2.MemoWrite\" + cRotina + "_QRY_001.TXT",GetLastQuery()[02])
        while !(cAliasAC6)->(EOF())
            dDeData 			:= StoD((cAliasAC6)->INICIO)
            dAtData 			:= StoD((cAliasAC6)->FINAL)
            cMeta               := (cAliasAC6)->META
            cTitMeta            := (cAliasAC6)->TITULO            
            (cAliasAC6)->(dbSkip())
        enddo
        (cAliasAC6)->(dbCloseArea())
        if AllTrim(DtoS(dDeData)) != '' .OR. AllTrim(DtoS(dAtData)) != ''
            AADD(aArqsLog,"Campanha ativa e selecionada para composição de metas e valores: " + AllTrim(cMeta + '-' + cTitMeta))
            AADD(aArqsLog,"--------------------------------------------------------------------------------")
            lBlind 				:= .F.
            @ 200,001 to 380,380 dialog oProcessa TITLE OemToAnsi(cText)
            @ 002,002 to 090,190
            @ 010,003 Say '  Acompanhamento das Metas de Vendas - Resumo por Representante                   '
            @ 020,003 Say '  Campanha ativa e disponível: ' + AllTrim(cMeta) + '-' + AllTrim(cTitMeta) + '.  '
            @ 070,118 BMPBUTTON TYPE 01 ACTION Processa({|lEnd| ProcMail1(_cTipo,dDeData,dAtData,cMeta,cTitMeta,@lEnd)},"[" + cRotina + "] " + cTitulo,"Processando...",.F.)
            @ 070,148 BMPBUTTON TYPE 02 ACTION Close(oProcessa)
            activate dialog oProcessa centered
        else
            AADD(aArqsLog,"Não foi encontrada uma campanha ativa para composição de metas e valores.")
            AADD(aArqsLog,"--------------------------------------------------------------------------------")
        endif
	endif
endif
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ProcMail1  ºAutor  ³Rodrigo Telecio    º Data ³  11/07/2022º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processa resultados e envio e-mail                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                           			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ProcMail1(_cTipo,_dDeData,_dAtData,cMeta,cTitMeta,lEnd)
local   _cView          := "%[P12_VIEWPRODUCAO].[dbo].[RFATA050_" + cNumEmp + "]%"
local   _cMail          := ""
local   _cAnexo         := ""
local   _cCC 	        := ""
local 	_cBCC           := ""
local   _cHtml          := ""
local   _lEnvia         := SuperGetMV("MV_XLENVIA"  ,.F.,.F.)
local   _cAssunto       := cTitulo
local   _cFromOri       := "naoresponda@arcolor.com.br"			 //SuperGetMv("MV_RELFROM"  ,,"" )		 // Remetente da mensagem
local   _lExcAnex       := .F.
local   _lAlert         := .F.
local   _lHtmlOk        := .F.
local   nX              := 0
local   lRetMail        := .F.
local   cAliasMeta      := GetNextAlias()
local   cAliasTotal     := GetNextAlias()
local   _nTotMetaReal   := 0
local   _nTotMetaPrev   := 0
Local   _cLogo          := "\system\logotipo.bmp"
//****************************************************************************************
//Query para levantamento do valor GLOBAL realizado, dentro do período da meta determinada
//****************************************************************************************
if Select(cAliasTotal) > 0
    (cAliasTotal)->(dbCloseArea())
endif
BeginSql Alias cAliasTotal
    %noparser%
    SELECT
        ROUND(ISNULL(SUM(VDAS.C6_VALOR),0),2)										        AS C6_VALOR
    FROM
        (SELECT
            SCT.CT_DOC,
            SCT.CT_VEND,
            SA3.A3_NOME,
            SA3.A3_EMAIL,
            SA3.A3_GEREN,
            (CASE WHEN SA3.A3_SUPER = '' THEN SCT.CT_VEND ELSE SA3.A3_SUPER END)	        AS A3_SUPER,
            SCT.CT_DATA,
            SUM(SCT.CT_QUANT)														        AS CT_QUANT,
            SUM(SCT.CT_VALOR)														        AS CT_VALOR
        FROM
            %table:SCT% AS SCT (NOLOCK)
            INNER JOIN
                %table:SA3% AS SA3 (NOLOCK)                            
            ON
                SA3.A3_FILIAL					= %xFilial:SA3%
                AND SA3.A3_COD					= CT_VEND 
                AND (CASE WHEN A3_EMAIL			= %Exp:''% THEN 0 ELSE 1 END) = %Exp:1% 
                AND SA3.%notdel%
        WHERE
            SCT.CT_FILIAL						= %xFilial:SCT%
            AND SCT.CT_MSBLQL					= %Exp:'2'%
            AND (CASE WHEN CT_VEND				= %Exp:''% THEN 0 ELSE 1 END) = %Exp:1% 
            AND SCT.CT_DATA						BETWEEN %Exp:DTOS(_dDeData)% AND %Exp:DTOS(_dAtData)%
            AND SCT.%notdel%
        GROUP BY
            SCT.CT_DOC, SCT.CT_VEND, SA3.A3_NOME, SA3.A3_EMAIL, SA3.A3_GEREN, SA3.A3_SUPER, SCT.CT_DATA
        ) META
        LEFT OUTER JOIN
            %Exp:_cView% AS VDAS
        ON 
            VDAS.C5_EMISSAO						    BETWEEN %Exp:DTOS(_dDeData)% AND %Exp:DTOS(_dAtData)%
            AND SUBSTRING(VDAS.C5_EMISSAO,1,6)      = META.CT_DOC
            AND VDAS.C5_VEND1					    = META.CT_VEND
            LEFT OUTER JOIN
                %table:SA3% AS SA31 (NOLOCK)
            ON
                SA31.A3_FILIAL						= %xFilial:SA3%
                AND SA31.A3_COD						= META.A3_SUPER 
                AND SA31.%notdel%
            LEFT OUTER JOIN 
                %table:SA3% AS SA32 (NOLOCK)                        
            ON 
                SA32.A3_FILIAL						= %xFilial:SA3%
                AND SA32.A3_COD						= META.A3_GEREN 
                AND SA32.%notdel%
EndSql
MemoWrite("\2.MemoWrite\" + cRotina + "_QRY_002.TXT",GetLastQuery()[02])
dbSelectArea(cAliasTotal)
ProcRegua((cAliasTotal)->(RecCount()))
while !(cAliasTotal)->(EOF()) .AND. !lEnd
    _nTotMetaReal := Round((cAliasTotal)->C6_VALOR,TamSX3("C6_VALOR")[1])
    (cAliasTotal)->(dbSkip())
enddo
(cAliasTotal)->(dbCloseArea())
//*******************************************************************************************************
//Query para levantamento do valor INDIVIDUAL previsto e realizado, dentro do período da meta determinada
//*******************************************************************************************************
if Select(cAliasMeta) > 0
	(cAliasMeta)->(dbCloseArea())
endif
BeginSql Alias cAliasMeta
	%noparser%
    SELECT
        ISNULL(AC6.AC6_META,'')																AS AC6_META,
        ISNULL(AC6.AC6_TITULO,'')															AS AC6_TITULO,
        ISNULL(AC6.AC6_DTINI,'')															AS AC6_DTINI,
        ISNULL(AC6.AC6_DTFIM,'')															AS AC6_DTFIM,
        ISNULL(AC6.AC6_TOTFAT,0)															AS AC6_TOTFAT,
        ISNULL(AC7.AC7_CODCAM,'')															AS AC7_CODCAM,
        ISNULL(AC7.AC7_FATCAM,'')															AS AC7_FATCAM,
        ISNULL(AC7.AC7_DOC,'')																AS AC7_DOC,
        ISNULL(SUO.UO_DESC,'')																AS UO_DESC,
        ISNULL(SUO.UO_DTINI,'')																AS UO_DTINI,
        ISNULL(SUO.UO_DTFIM,'')																AS UO_DTFIM,
        ISNULL(VENDAS.CT_VEND,'')															AS CT_VEND,
        ISNULL(VENDAS.A3_NOME,'')															AS A3_NOME,
        ISNULL(VENDAS.A3_EMAIL,'')															AS A3_EMAIL,
        ISNULL(VENDAS.A3_GEREN,'')															AS A3_GEREN,
        ISNULL(VENDAS.GER_EMAIL,'')															AS GER_EMAIL,
        ISNULL(VENDAS.A3_SUPER,'')															AS A3_SUPER,
        ISNULL(VENDAS.SUP_NOME,'')															AS A3_SUPNOME,
        ISNULL(VENDAS.SUP_EMAIL,'')															AS SUP_EMAIL,
        ISNULL(VENDAS.CT_DATA,'')															AS CT_DATA,
        ISNULL(VENDAS.CT_QUANT,0)															AS CT_QUANT,
        ISNULL(VENDAS.CT_VALOR,0)															AS CT_VALOR,
        ROUND(SUM(ISNULL(VENDAS.C6_QTDVEN,0)),2)											AS C6_QTDVEN,
        ROUND(SUM(ISNULL(VENDAS.C6_VALOR,0)),2)												AS C6_VALOR
    FROM
        %table:AC6% AS AC6 (NOLOCK)
            LEFT OUTER JOIN
                %table:AC7% AS AC7 (NOLOCK)
            ON
                AC7.AC7_FILIAL     = AC6.AC6_FILIAL
                AND AC7.AC7_META   = AC6.AC6_META
                AND AC7.%notdel%
            LEFT OUTER JOIN
                %table:SUO% AS SUO (NOLOCK)
            ON
                SUO.UO_FILIAL      = %xFilial:SUO%
                AND SUO.UO_CODCAMP = AC7.AC7_CODCAM
                AND SUO.%notdel%
            LEFT OUTER JOIN
                (SELECT
                    META.CT_DOC																	AS CHAVE,
                    META.CT_VEND,
                    META.A3_NOME,
                    META.A3_EMAIL,
                    META.A3_GEREN,
                    ISNULL(SA32.A3_EMAIL,'')													AS GER_EMAIL,
                    META.A3_SUPER,
                    ISNULL(SA31.A3_EMAIL,'')													AS SUP_EMAIL,
                    ISNULL(SA31.A3_NOME,'')														AS SUP_NOME,
                    META.CT_DATA,
                    META.CT_QUANT,
                    META.CT_VALOR,
                    ISNULL(SUM(VDAS.C6_QTDVEN),0)												AS C6_QTDVEN,
                    ISNULL(SUM(VDAS.C6_VALOR),0)												AS C6_VALOR
                FROM
                    (SELECT
                        SCT.CT_DOC,
                        SCT.CT_VEND,
                        SA3.A3_NOME,
                        SA3.A3_EMAIL,
                        SA3.A3_GEREN,
                        (CASE WHEN SA3.A3_SUPER = '' THEN SCT.CT_VEND ELSE SA3.A3_SUPER END)	AS A3_SUPER,
                        SCT.CT_DATA,
                        SUM(SCT.CT_QUANT)														AS CT_QUANT,
                        SUM(SCT.CT_VALOR)														AS CT_VALOR
                    FROM
                        %table:SCT% AS SCT (NOLOCK)
                        INNER JOIN
                            %table:SA3% AS SA3 (NOLOCK)                            
                        ON
                            SA3.A3_FILIAL					= %xFilial:SA3%
                            AND SA3.A3_COD					= CT_VEND 
                            AND (CASE WHEN A3_EMAIL			= %Exp:''% THEN 0 ELSE 1 END) = %Exp:1% 
                            AND SA3.%notdel%
                    WHERE
                        SCT.CT_FILIAL						= %xFilial:SCT%
                        AND SCT.CT_MSBLQL					= %Exp:'2'%
                        AND (CASE WHEN CT_VEND				= %Exp:''% THEN 0 ELSE 1 END) = %Exp:1% 
                        AND SCT.CT_DATA						BETWEEN %Exp:DTOS(_dDeData)% AND %Exp:DTOS(_dAtData)%
                        AND SCT.%notdel%
                    GROUP BY
                        SCT.CT_DOC, SCT.CT_VEND, SA3.A3_NOME, SA3.A3_EMAIL, SA3.A3_GEREN, SA3.A3_SUPER, SCT.CT_DATA
                    ) META
                    LEFT OUTER JOIN
                        %Exp:_cView% AS VDAS
                    ON 
                        VDAS.C5_EMISSAO						BETWEEN %Exp:DTOS(_dDeData)% AND %Exp:DTOS(_dAtData)%
                        AND SUBSTRING(VDAS.C5_EMISSAO,1,6)  = META.CT_DOC
                        AND VDAS.C5_VEND1					= META.CT_VEND
                    LEFT OUTER JOIN
                        %table:SA3% AS SA31 (NOLOCK)
                    ON
                        SA31.A3_FILIAL						= %xFilial:SA3%
                        AND SA31.A3_COD						= META.A3_SUPER 
                        AND SA31.%notdel%
                    LEFT OUTER JOIN 
                        %table:SA3% AS SA32 (NOLOCK)                        
                    ON 
                        SA32.A3_FILIAL						= %xFilial:SA3%
                        AND SA32.A3_COD						= META.A3_GEREN 
                        AND SA32.%notdel%
                GROUP BY
                    META.CT_DOC, META.CT_VEND, META.A3_NOME, META.A3_EMAIL, META.A3_GEREN, SA32.A3_EMAIL, META.A3_SUPER, SA31.A3_NOME, SA31.A3_EMAIL,
                    META.CT_DATA, META.CT_QUANT, META.CT_VALOR, SUBSTRING(VDAS.C5_EMISSAO,1,6)
                ) AS VENDAS
    ON
		AC7.AC7_DOC = VENDAS.CHAVE
    WHERE
        AC6.AC6_FILIAL      = %xFilial:AC6%
        AND AC6.AC6_META    = %Exp:cMeta%
        AND AC6.AC6_MSBLQL  <> %Exp:'1'%
        AND AC6.%notdel%
    GROUP BY
        AC6.AC6_META, AC6.AC6_TITULO, AC6.AC6_DTINI, AC6.AC6_DTFIM, AC6.AC6_TOTFAT, AC7.AC7_CODCAM, AC7.AC7_FATCAM, AC7.AC7_DOC, SUO.UO_DESC, SUO.UO_DTINI, SUO.UO_DTFIM,
        VENDAS.CT_VEND, VENDAS.A3_NOME, VENDAS.A3_EMAIL, VENDAS.A3_GEREN, VENDAS.GER_EMAIL, VENDAS.A3_SUPER, VENDAS.SUP_NOME, VENDAS.SUP_EMAIL, VENDAS.CT_DATA, VENDAS.CT_QUANT, VENDAS.CT_VALOR
    ORDER BY
        VENDAS.A3_GEREN, VENDAS.A3_SUPER, VENDAS.CT_VEND, SUO.UO_DTINI
EndSql
MemoWrite("\2.MemoWrite\" + cRotina + "_QRY_003.TXT",GetLastQuery()[02])
dbSelectArea(cAliasMeta)
ProcRegua((cAliasMeta)->(RecCount()))
while !(cAliasMeta)->(EOF()) .AND. !lEnd
    if AllTrim((cAliasMeta)->CT_VEND) == ''
        (cAliasMeta)->(dbSkip())
        loop
    endif
	if !lBlind
		IncProc("Processando representante '" + (cAliasMeta)->CT_VEND + "'...")
	endif
	AADD(aArqsLog,'Processando representante ' + (cAliasMeta)->CT_VEND)
	_cVend          := (cAliasMeta)->CT_VEND
    _cMails         := AllTrim(SuperGetMV("MV_XFRO051"  ,.F.,'rodrigo.telecio@allss.com.br'))
    _cCCs           := AllTrim(SuperGetMV("MV_XCC051"   ,.F.,'rodrigo.telecio@allss.com.br'))
    if _lEnvia
        _cMail      := AllTrim((cAliasMeta)->A3_EMAIL) + iif(!Empty(_cMails),";" + _cMails,"")
        _cCC 	    := AllTrim((cAliasMeta)->SUP_EMAIL) + iif(!Empty(_cCCs),";" + _cCCs,"")        
    else
        _cMail      := AllTrim((cAliasMeta)->SUP_EMAIL) + iif(!Empty(_cMails),";" + _cMails,"")
        _cCC 	    := iif(!Empty(_cCCs),";" + _cCCs,"")
    endif
    _cBCC           := SuperGetMV("MV_XBCC051"  ,.F.,'rodrigo.telecio@allss.com.br')
	_cAssunto       := "[ARCOLOR] Acompanhamento de vendas - Posição em " + DtoC(dDataBase-1) + " - Referente ao mês " + DtoC(_dDeData) + " a " + DtoC(_dAtData) + " - Representante - " + AllTrim((cAliasMeta)->A3_NOME)
    _cHtml          := "<H2>Acompanhamento de vendas - Posição em " + DtoC(dDataBase-1) + " - Referente ao mês " + DtoC(_dDeData) + " a " + DtoC(_dAtData) + " - Representante - " + AllTrim((cAliasMeta)->A3_NOME) + CLRF
	_cHtml          += "<BR><BR>"                                                                       + CLRF
	_cHtml          += "<table border='1' bgcolor='#FFFFFF'> "                                          + CLRF
	_cHtml          += " 	<thead bgcolor='#808080'> "                                                 + CLRF
	_cHtml          += " 		<tr border='1'> "                                                       + CLRF
    //_cHtml          += " 			<th border='1' align='center' width='150'>         </th> "          + CLRF
    _cHtml          += " 			<td border='1' align='center' width='150'>META            </td> "   + CLRF
    _cHtml          += " 			<td border='1' align='center' width='150'>REALIZADO       </td> "   + CLRF
	_cHtml          += " 			<td border='1' align='center' width='150'>SALDO           </td> "   + CLRF
    _cHtml          += " 			<td border='1' align='center' width='150'>QTD DE PEDIDOS</td> "     + CLRF
   	_cHtml          += " 		</tr> "                                                                 + CLRF
	_cHtml          += " 	</thead> "                                                                  + CLRF
	_cHtml          += " 	<tbody> "                                                                   + CLRF
    _nPrevRepr      := 0
    _nRealRepr      := 0
    _nReal          := 0
    _nMeta          := (cAliasMeta)->CT_VALOR
    _nSaldo         := (cAliasMeta)->CT_VALOR
    while !(cAliasMeta)->(EOF()) .AND. !lEnd .AND. _cVend == (cAliasMeta)->CT_VEND
        _nPrevRepr      += Round((cAliasMeta)->CT_VALOR     ,TamSX3("C6_VALOR")[1])
        _nRealRepr      += Round((cAliasMeta)->C6_VALOR     ,TamSX3("C6_VALOR")[1])
        _nTotMetaPrev   := Round((cAliasMeta)->AC6_TOTFAT   ,TamSX3("C6_VALOR")[1])
        _nMeta          := Round((cAliasMeta)->CT_VALOR     ,TamSX3("C6_VALOR")[1])
        _nReal          := Round((cAliasMeta)->C6_VALOR     ,TamSX3("C6_VALOR")[1])
        _nSaldo         := 0
        //_nSaldo 	    := _nMeta - _nReal
        _nSaldo 	    := _nReal - _nMeta

        _nTotalPedidos := RFATR51PV((cAliasMeta)->CT_VEND, DtoS(_dDeData), DtoS(_dAtData) )

        _cHtml   	    += " 		<tr> "                                                              + CLRF
        //_cHtml   	    += " 			<th valign='top' align='center' border='1' width='150'>"    + AllTrim((cAliasMeta)->UO_DESC)              + "</th> " + CLRF
        _cHtml   	    += " 			<td valign='top' align='right'  border='1' width='150'>R$ " + Transform(_nMeta , "@E 999,999,999,999.99") + "</td> " + CLRF                
        _cHtml   	    += " 			<td valign='top' align='right'  border='1' width='150'>R$ " + Transform(_nReal , "@E 999,999,999,999.99") + "</td> " + CLRF
        _cHtml   	    += " 			<td valign='top' align='right'  border='1' width='150'>R$ " + Transform(_nSaldo, "@E 999,999,999,999.99") + "</td> " + CLRF
        _cHtml   	    += " 			<td valign='top' align='right'  border='1' width='150'>"    + Transform(_nTotalPedidos , "@E 999,999,999,999") + "</td> " + CLRF                
        _cHtml   	    += " 		</tr> "                                                             + CLRF
        _nMeta   	    := _nSaldo
        _cHtml          += " 		<tr> "                                                                  + CLRF
        _cHtml          += " 			<td valign='top' align='right'  border='1' width='150'> "   + AllTrim(Transform(Round(((_nPrevRepr / _nPrevRepr) * 100),2)                          , "@E 999,999,999,999.99"))  + "%</td> " + CLRF                
        _cHtml          += " 			<td valign='top' align='right'  border='1' width='150'> "   + AllTrim(Transform(Round(((_nRealRepr / _nPrevRepr) * 100),2)                          , "@E 999,999,999,999.99"))  + "%</td> " + CLRF
        //_cHtml          += " 			<td valign='top' align='right'  border='1' width='150'> "   + AllTrim(Transform(Round(((_nRealRepr / _nPrevRepr) / _nPrevRepr) * 100,2)             , "@E 999,999,999,999.99"))  + "%</td> " + CLRF
        _cHtml          += " 			<td valign='top' align='right'  border='1' width='150'> "   + AllTrim(Transform(Round(((_nRealRepr / _nPrevRepr) * 100),2) - Round(((_nPrevRepr / _nPrevRepr) * 100),2)             , "@E 999,999,999,999.99"))  + "%</td> " + CLRF
        _cHtml          += " 			<th border='1' align='center' width='150'>         </th> "          + CLRF
        _cHtml          += " 		<tr> "                                                                  + CLRF
        _cHtml          += "            <th colspan='4'> META GLOBAL - " + AllTrim(cTitMeta) + "</th> "     + CLRF
        _cHtml          += "        </tr> "                                                                 + CLRF
        _cHtml          += " 		<tr> "                                                                  + CLRF
        _cHtml          += " 			<td valign='top' align='right'  border='1' width='150'>R$ " + Transform(_nTotMetaPrev , "@E 999,999,999,999.99")                    + "</td> " + CLRF                
        _cHtml          += " 			<td valign='top' align='right'  border='1' width='150'>R$ " + Transform(_nTotMetaReal , "@E 999,999,999,999.99")                    + "</td> " + CLRF
        _cHtml          += " 			<td valign='top' align='right'  border='1' width='150'>R$ " + Transform(_nTotMetaReal - _nTotMetaPrev , "@E 999,999,999,999.99")    + "</td> " + CLRF
        _cHtml          += " 			<th valign='top' align='center' border='1' width='150'>"    + "    "                                                                + "</th> "  + CLRF
        _cHtml          += " 		</tr> "                                                                 + CLRF
        _cHtml          += " 		<tr> "                                                                  + CLRF
        _cHtml          += " 			<td valign='top' align='right'  border='1' width='150'> "   + AllTrim(Transform(Round(((_nTotMetaPrev / _nTotMetaPrev) * 100),2)                    , "@E 999,999,999,999.99"))  + "%</td> " + CLRF                
        _cHtml          += " 			<td valign='top' align='right'  border='1' width='150'> "   + AllTrim(Transform(Round(((_nTotMetaReal / _nTotMetaPrev) * 100),2)                    , "@E 999,999,999,999.99"))  + "%</td> " + CLRF
        _cHtml          += " 			<td valign='top' align='right'  border='1' width='150'> "   + AllTrim(Transform(Round(((_nTotMetaReal - _nTotMetaPrev) / _nTotMetaPrev) * 100,2)    , "@E 999,999,999,999.99"))  + "%</td> " + CLRF
        _cHtml          += " 			<th valign='top' align='center' border='1' width='150'>"    + "    "                                                                                                             + "</th> "  + CLRF
        _cHtml          += " 		</tr> "                                                                 + CLRF
        (cAliasMeta)->(dbSkip())
    enddo
    _cHtml          += " 	</tbody> "                                                                  + CLRF
    _cHtml          += "</table> "                                                                      + CLRF
    //********************************************************************************
    //Valores totais por representante
    //********************************************************************************
    /* COMENTADO DEVIDO A MUDANÇA NO LAYOUT DO E-MAIL.
    _cHtml          += "<BR><BR>"                                                                       + CLRF
    _cHtml          += "<table border='1' bgcolor='#FFFFFF'> "                                          + CLRF
    _cHtml          += " 	<thead bgcolor='#808080'> "                                                 + CLRF
    _cHtml          += " 		<tr border='1'> "                                                       + CLRF
    _cHtml          += " 			<th border='1' align='center' width='150'>         </th> "          + CLRF
    _cHtml          += " 			<td border='1' align='center' width='150'>META     </td> "          + CLRF
    _cHtml          += " 			<td border='1' align='center' width='150'>REALIZADO</td> "          + CLRF
    _cHtml          += " 			<td border='1' align='center' width='150'>SALDO </td> "          + CLRF
    _cHtml          += " 		</tr> "                                                                 + CLRF
    _cHtml          += " 	</thead> "                                                                  + CLRF
    _cHtml          += " 	<tbody> "                                                                   + CLRF
    _cHtml          += " 		<tr> "                                                                  + CLRF
    _cHtml          += " 			<th valign='top' align='center' border='1' width='150'>"    + "TOTAL META REPRESENTANTE"                                            + "</th> " + CLRF
    _cHtml          += " 			<td valign='top' align='right'  border='1' width='150'>R$ " + Transform(_nPrevRepr , "@E 999,999,999,999.99")                       + "</td> " + CLRF
    _cHtml          += " 			<td valign='top' align='right'  border='1' width='150'>R$ " + Transform(_nRealRepr , "@E 999,999,999,999.99")                       + "</td> " + CLRF
    _cHtml          += " 			<td valign='top' align='right'  border='1' width='150'>R$ " + Transform(_nRealRepr - _nPrevRepr  , "@E 999,999,999,999.99")          + "</td> " + CLRF
    _cHtml          += " 		</tr> "                                                                 + CLRF
    _cHtml          += " 		<tr> "                                                                  + CLRF
    _cHtml          += " 			<th valign='top' align='center' border='1' width='150'>"    + "    "                                                                                                             + "</th> "  + CLRF
    _cHtml          += " 			<td valign='top' align='right'  border='1' width='150'> "   + AllTrim(Transform(Round(((_nPrevRepr / _nPrevRepr) * 100),2)                          , "@E 999,999,999,999.99"))  + "%</td> " + CLRF                
    _cHtml          += " 			<td valign='top' align='right'  border='1' width='150'> "   + AllTrim(Transform(Round(((_nRealRepr / _nPrevRepr) * 100),2)                          , "@E 999,999,999,999.99"))  + "%</td> " + CLRF
    _cHtml          += " 			<td valign='top' align='right'  border='1' width='150'> "   + AllTrim(Transform(Round(((_nRealRepr / _nPrevRepr) / _nPrevRepr) * 100,2)             , "@E 999,999,999,999.99"))  + "%</td> " + CLRF
    _cHtml          += " 		</tr> "                                                                 + CLRF
    _cHtml          += " 	</tbody> "                                                                  + CLRF
    _cHtml          += "</table> "                                                                      + CLRF   
         
    //********************************************************************************
    //Valores totais globais
    //********************************************************************************
    _cHtml          += "<BR><BR>"                                                                       + CLRF
    _cHtml          += "<table border='1' bgcolor='#FFFFFF'> "                                          + CLRF
    _cHtml          += "    <thead bgcolor='#808080'> "                                                 + CLRF
    _cHtml          += "        <tr> "                                                                  + CLRF
    _cHtml          += "            <th colspan='4'> META GLOBAL - " + AllTrim(cTitMeta) + "</th> "     + CLRF
    _cHtml          += "        </tr> "                                                                 + CLRF
    _cHtml          += "    </thead> "                                                                  + CLRF    
    _cHtml          += " 	<thead bgcolor='#808080'> "                                                 + CLRF
    _cHtml          += " 		<tr border='1'> "                                                       + CLRF
    _cHtml          += " 			<th border='1' align='center' width='150'>         </th> "          + CLRF
    _cHtml          += " 			<td border='1' align='center' width='150'>META     </td> "          + CLRF
    _cHtml          += " 			<td border='1' align='center' width='150'>REALIZADO</td> "          + CLRF
    _cHtml          += " 			<td border='1' align='center' width='150'>SALDO </td> "          + CLRF        
    _cHtml          += " 		</tr> "                                                                 + CLRF
    _cHtml          += " 	</thead> "                                                                  + CLRF
    _cHtml          += " 	<tbody> "                                                                   + CLRF
    _cHtml          += " 		<tr> "                                                                  + CLRF
    _cHtml          += " 			<th valign='top' align='center' border='1' width='150'>"    + "TOTAL META GLOBAL"                                                   + "</th> " + CLRF
    _cHtml          += " 			<td valign='top' align='right'  border='1' width='150'>R$ " + Transform(_nTotMetaPrev , "@E 999,999,999,999.99")                    + "</td> " + CLRF                
    _cHtml          += " 			<td valign='top' align='right'  border='1' width='150'>R$ " + Transform(_nTotMetaReal , "@E 999,999,999,999.99")                    + "</td> " + CLRF
    _cHtml          += " 			<td valign='top' align='right'  border='1' width='150'>R$ " + Transform(_nTotMetaPrev - _nTotMetaReal , "@E 999,999,999,999.99")    + "</td> " + CLRF
    _cHtml          += " 		</tr> "                                                                 + CLRF
    _cHtml          += " 		<tr> "                                                                  + CLRF
    _cHtml          += " 			<th valign='top' align='center' border='1' width='150'>"    + "    "                                                                                                             + "</th> "  + CLRF
    _cHtml          += " 			<td valign='top' align='right'  border='1' width='150'> "   + AllTrim(Transform(Round(((_nTotMetaPrev / _nTotMetaPrev) * 100),2)                    , "@E 999,999,999,999.99"))  + "%</td> " + CLRF                
    _cHtml          += " 			<td valign='top' align='right'  border='1' width='150'> "   + AllTrim(Transform(Round(((_nTotMetaReal / _nTotMetaPrev) * 100),2)                    , "@E 999,999,999,999.99"))  + "%</td> " + CLRF
    _cHtml          += " 			<td valign='top' align='right'  border='1' width='150'> "   + AllTrim(Transform(Round(((_nTotMetaReal - _nTotMetaPrev) / _nTotMetaPrev) * 100,2)    , "@E 999,999,999,999.99"))  + "%</td> " + CLRF
    _cHtml          += " 		</tr> "                                                                 + CLRF
    _cHtml          += " 	</tbody> "                                                                  + CLRF
    _cHtml          += "</table> "                                                                      + CLRF
    */
	_cHtml          += "</H2> <BR> "                                                                    + CLRF
    _cHtml          := StrTran(_cHtml,CLRF,"")
	lRetMail        := U_RCFGM001(/*cTitulo*/"",_cHtml,_cMail,_cAnexo,_cFromOri,_cBCC,_cAssunto,_lExcAnex,_lAlert,_lHtmlOk,_cCC)
	if lRetMail
		AADD(aArqsLog,'Envio de e-mail com metas de venda para: ')
		AADD(aArqsLog,'Destinatário: ' 	+ AllTrim(_cMail))
		AADD(aArqsLog,'Cópia: ' 		+ AllTrim(_cCC))
		AADD(aArqsLog,'Cópia oculta: ' 	+ AllTrim(_cBCC))
		AADD(aArqsLog,"--------------------------------------------------------------------------------")
	else
		AADD(aArqsLog,'Houve algum problema durante o envio de e-mail. Nenhum e-mail foi enviado para: ')
		AADD(aArqsLog,'Destinatário: ' 	+ AllTrim(_cMail))
		AADD(aArqsLog,'Cópia: ' 		+ AllTrim(_cCC))
		AADD(aArqsLog,'Cópia oculta: ' 	+ AllTrim(_cBCC))
		AADD(aArqsLog,"--------------------------------------------------------------------------------")			
	endif
	dbSelectArea(cAliasMeta)
enddo
if Select(cAliasMeta) > 0
	(cAliasMeta)->(dbCloseArea())
endif
AADD(aArqsLog,"Data/Hora de término de processamento: " + AllTrim(DtoC(Date())) + " - " + AllTrim(Time()))
AADD(aArqsLog,"TÉRMINO - " + AllTrim(cRotina))
AADD(aArqsLog,"--------------------------------------------------------------------------------")
if Len(aArqsLog) > 0
    for nX := 1 to Len(aArqsLog)
        if nX == 1
            cArqsLog := AllTrim(aArqsLog[nX]) + STR_PULA
        else
            cArqsLog += AllTrim(aArqsLog[nX]) + STR_PULA
        endif
    next nX
endif
if !lBlind
	MemoWrite(GetTempPath() + AllTrim(Lower(cArquivo)) + '-' + AllTrim(DtoS(Date())) + '-' + StrTran(AllTrim(Time()),':','') + '_log.txt',cArqsLog)
	Aviso('TOTVS','Término do processamento. Verifique o arquivo de log gerado pelo processamento e confira os resultados.',{'&OK'},3,'Término de processamento')
	Close(oProcessa)
else
	MemoWrite(cArqLogs + AllTrim(Lower(cArquivo)) + '-' + AllTrim(DtoS(Date())) + '-' + StrTran(AllTrim(Time()),':','') + '_log.txt',cArqsLog)
endif
RESET ENVIRONMENT
return

/*/{Protheus.doc} RFATR51PV
    Função para buscar quantidade de Pedidos de Venda do representante
    @type  Static Function
    @author Fernando Bombardi
    @since 04/04/2024
    @version 1.0
    @param _cVend, _dDataDe, _dDataAte
    @return _nQtdPv
/*/
Static Function RFATR51PV(_cVend, _dDataDe, _dDataAte)
Local _nQtdPv := 0

BeginSql Alias 'SC5TMP'
    %noparser%
    SELECT
        COUNT(C5_NUM) AS QTDPV
    FROM
        %table:SC5% AS SC5 (NOLOCK)
    WHERE
            SC5.C5_FILIAL						= %xFilial:SC5%
            AND SC5.C5_EMISSAO					BETWEEN %Exp:_dDataDe% AND %Exp:_dDataAte%
            AND SC5.C5_VEND1					= %Exp:_cVend%
            AND SC5.C5_TIPO                     = 'N'
            AND SC5.%notdel%
EndSql

_cQry := GetLastQuery()[02]

if SC5TMP->(!EOF())
    _nQtdPv :=  SC5TMP->QTDPV
endif

SC5TMP->(dbCloseARea())

Return _nQtdPv
