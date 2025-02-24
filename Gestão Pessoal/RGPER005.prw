#include 'totvs.ch'
#include 'parmtype.ch'
#include 'topconn.ch'
#include 'olecont.ch'
#include 'rwmake.ch'
#define STR_PULA CHR(13) + CHR(10)
Static cDirTmp 		:= GetTempPath()
/*/{Protheus.doc} RGPER005
Função de usuário responsável por emitir o relatório de conferência dos eventos do Ponto Eletrônico (SIGAPON), para envio ao DJ
@author Rodrigo Telecio (rodrigo.telecio@allss.com.br)
@since 25/09/2020
@version 1.00 (P12.1.25)
@type Function	
@param nulo, Nil, nenhum 
@return nulo, Nil 
@obs Sem observações até o momento. 
@see https://allss.com.br/
@history 25/09/2020, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Disponibilização da rotina para uso.
@history 05/01/2021, Diego Rodrigues (diego.rodrigues@allss.com.br), Ajuste na query para conversão em horas decimais ou sexagenais.
@history 01/06/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Ajustes na query de processamento do relatório inserindo "DISTINCT", correção do relacionamento com a SRV e adequações ao EMBEDDED na tabela SQB.
/*/
user function RGPER005()
Private cPerg       := FunName()
Private cTitulo		:= 'Export. conferência do Ponto Eletrônico - SIGAPON'
Private cRotina		:= AllTrim(FunName())
Private oLeTxt
ValidPerg()
@ 200,001 TO 380,380 DIALOG oLeTxt TITLE OemToAnsi(cTitulo)
@ 002,002 TO 090,190
@ 010,003 Say '   Este programa tem por objetivo exportar o relatório de conferencia  '
@ 018,003 Say '   dos eventos do Ponto Eletrônico seguindo os parâmetros indicados.   '
@ 070,088 BMPBUTTON TYPE 01 ACTION Processa({|| ProcRel()}, cTitulo, 'Processando, aguarde...', .F.)
@ 070,118 BMPBUTTON TYPE 02 ACTION Close(oLeTxt)
@ 070,148 BMPBUTTON TYPE 05 ACTION Pergunte(cPerg,.T.)
ACTIVATE DIALOG oLeTxt CENTERED
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ProcRel    ºAutor  ³ Rodrigo Telecio 	 º Data ³  25/09/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função de processamento do relatório					      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function ProcRel()
local lRet		:= .T.
local cExtensao	:= ".xml"
local lGerou	:= .F.
local cAba		:= 'Parametros'
local cAba2		:= 'Conferencia SIGAPON'
local cTitulo	:= 'Parametros utilizados'
local cTitulo2	:= "Conferencia do Ponto Eletrônico - SIGAPON - período de " + AllTrim(DtoC(mv_par07)) + " a " + AllTrim(DtoC(mv_par08))
local aSavArea	:= ""
local aPar		:= {}
local cArquivo	:= cDirTmp + cRotina + cExtensao
local nPosPar	:= 0
local cOrder    := ""
local cConv     := ""
local cAlsTmp   := ""
local oFWMsExcel
local oExcel
if !(SubStr(cAcesso, 160, 1) == "S" .AND. SubStr(cAcesso, 168, 1) == "S" .AND. SubStr(cAcesso, 170, 1) == "S")
	Aviso('TOTVS','Usuário sem permissão para gerar relatórios em Excel. Informe essa mensagem ao administrador.',{'OK'},3,'Cancelamento de operação por falta de permissões')
	lRet := .F.
endif

/*
if !ApOleClient('MsExcel')
	Aviso('TOTVS','Excel não está instalado nessa estação.',{'OK'},3,'Cancelamento de operação por ausencia de aplicativo')
	lRet := .F.
endif
*/
if lRet
	if Empty(AllTrim(mv_par09))
        cArquivo	:= cDirTmp + cRotina + cExtensao
    else
        cArquivo    := AllTrim(mv_par09)
	endif
endif
if lRet
    lGerou	:= .T.			
    //ABA PARÂMETROS
    oFWMsExcel 	:= FWMSExcel():New()
    oFWMsExcel:AddWorkSheet(cAba)
    oFWMsExcel:AddTable(cAba, cTitulo)
    oFWMsExcel:AddColumn(cAba, cTitulo, 'Descrição'					, 1, 1) //1 = Modo Texto
    oFWMsExcel:AddColumn(cAba, cTitulo, 'Conteúdo'					, 1, 1) //1 = Modo Texto
    //cAliasSX1 := "SX1_" + GetNextAlias()
    cAliasSX1 	:= "SX1"
    aSavArea	:= GetArea()
    OpenSXS(,,,, FWCodEmp(), cAliasSX1, "SX1",, .F.)
    dbSelectArea(cAliasSX1)
    (cAliasSX1)->(dbSetOrder(1))
    (cAliasSX1)->(dbGoTop())
    cPerg 		:= PADR(cPerg, 10)
    if (cAliasSX1)->(dbSeek(cPerg))
        while !(cAliasSX1)->(EOF()) .AND. (cAliasSX1)->X1_GRUPO == cPerg
            if AllTrim((cAliasSX1)->X1_GSC) == "C"
                AAdd(aPar,{(cAliasSX1)->X1_PERGUNT, &("(cAliasSX1)->X1_DEF" + StrZero(&((cAliasSX1)->X1_VAR01),2))})
            else
                AAdd(aPar,{(cAliasSX1)->X1_PERGUNT, &((cAliasSX1)->X1_VAR01)})
            endif
            dbSelectArea(cAliasSX1)
            (cAliasSX1)->(dbSetOrder(1))    
            (cAliasSX1)->(dbSkip())
        enddo
    endif
    if Len(aPar) > 0
        for nPosPar := 1 to Len(aPar)
            oFWMsExcel:AddRow(cAba, cTitulo, aPar[nPosPar])
        next nPosPar
    endif
    RestArea(aSavArea)
    //ABA CONFERENCIA SIGAPON
    oFWMsExcel:AddworkSheet(cAba2)
    oFWMsExcel:AddTable(cAba2, cTitulo2)
    oFWMsExcel:AddColumn(cAba2, cTitulo2, "Filial"					, 1, 1) //1 = Modo Texto
    oFWMsExcel:AddColumn(cAba2, cTitulo2, "Período"			        , 1, 1) //1 = Modo Texto
    oFWMsExcel:AddColumn(cAba2, cTitulo2, "Centro de custo"			, 1, 1) //1 = Modo Texto
    oFWMsExcel:AddColumn(cAba2, cTitulo2, "Departamento"			, 1, 1) //1 = Modo Texto
    oFWMsExcel:AddColumn(cAba2, cTitulo2, "Matrícula"				, 1, 1) //1 = Modo Texto
    oFWMsExcel:AddColumn(cAba2, cTitulo2, "Nome do colaborador"		, 1, 1) //1 = Modo Texto
    oFWMsExcel:AddColumn(cAba2, cTitulo2, "Evento"		    		, 1, 1) //1 = Modo Texto
    oFWMsExcel:AddColumn(cAba2, cTitulo2, "Tipo do evento"			, 1, 1) //1 = Modo Texto
    oFWMsExcel:AddColumn(cAba2, cTitulo2, "Quantidade"				, 2, 2) //2 = Valor sem R$
    if mv_par10 == 1
        cOrder := "%SPB.PB_CC, SPB.PB_MAT%"
    elseif mv_par10 == 2
        cOrder := "%SPB.PB_CC, SRA.RA_NOME%"
    endif

    if mv_par11 == 1
        cConv := "1"
    elseif mv_par11 == 2
        cConv := "2"
    endif
    cAlsTmp := GetNextAlias()
    //Ajuste na query para conversão em horas decimais ou sexagenais Diego AllSS 04/01/21
    BeginSQL Alias cAlsTmp
    SELECT DISTINCT
        SPB.PB_FILIAL AS FILIAL,
        SUBSTRING(SPB.PB_DATA,1,6) AS PERIODO,
        SPB.PB_CC AS COD_CC,
        CTT.CTT_DESC01 AS DESC_CC,
        SRA.RA_DEPTO AS DEPTO,
		SQB.QB_DESCRIC AS DESC_DPTO,
        SPB.PB_MAT AS COD_MAT,
        SRA.RA_NOME AS DESC_MAT,
        SPB.PB_PD AS COD_EV,
        SRV.RV_DESC AS DESC_EV,
        CASE
            WHEN SPB.PB_TIPO1 = %exp:'D'% THEN %exp:'DIAS'%
            WHEN SPB.PB_TIPO1 = %exp:'H'% THEN %exp:'HORAS'%
            WHEN SPB.PB_TIPO1 = %exp:'V'% THEN %exp:'VALOR'%
            ELSE %exp:'N/D'%
        END AS TP_EV,
        CASE WHEN %exp:cConv% = %exp:'1'% THEN SPB.PB_HORAS ELSE 
        ROUND((CAST(SPB.PB_HORAS AS INT)+(((SPB.PB_HORAS - CAST(SPB.PB_HORAS AS INT))*60)/100)),2) END AS QUANT
    FROM 
        %table:SPB% AS SPB 
        LEFT OUTER JOIN
            %table:CTT% AS CTT
        ON
            CTT.CTT_FILIAL = SPB.PB_FILIAL
            AND CTT.CTT_CUSTO = SPB.PB_CC
            AND CTT.%notDel%
        LEFT OUTER JOIN
            %table:SRA% AS SRA
        ON
            SRA.RA_FILIAL = SPB.PB_FILIAL
            AND SRA.RA_MAT = SPB.PB_MAT
            AND SRA.%notDel%
        LEFT OUTER JOIN
            %table:SRV% AS SRV
        ON
            SRV.RV_FILIAL = %exp:FwFilial("SRV")%
            AND SRV.RV_COD = SPB.PB_PD
            AND SRV.%notDel%
        LEFT OUTER JOIN
            %table:SQB% AS SQB
        ON
            SQB.QB_DEPTO = SRA.RA_DEPTO
            AND SQB.%notDel%
    WHERE
        SPB.PB_FILIAL BETWEEN %exp:mv_par01% AND %exp:mv_par02%
        AND SPB.PB_MAT BETWEEN %exp:mv_par03% AND %exp:mv_par04%
        AND SPB.PB_CC BETWEEN %exp:mv_par05% AND %exp:mv_par06%
        AND SPB.PB_DATA BETWEEN %exp:DtoS(mv_par07)% AND %exp:DtoS(mv_par08)%
        AND SQB.QB_DEPTO BETWEEN  %exp:mv_par12% AND %exp:mv_par13%
        AND SPB.%notDel%
    ORDER BY
        %exp:cOrder%
    EndSQL
    MemoWrite(GetTempPath() + cRotina + "_QRY_001.txt",GetLastQuery()[02])
    dbSelectArea(cAlsTmp)
    ProcRegua(RecCount())
    while (cAlsTmp)->(!EOF())
        IncProc("Gravando registro do '" + AllTrim((cAlsTmp)->DESC_MAT) + "', aguarde...")							
        //ABA CONFERENCIA SIGAPON
        oFWMsExcel:AddRow(cAba2, cTitulo2,	{	AllTrim((cAlsTmp)->FILIAL)				,;
                                                AllTrim((cAlsTmp)->PERIODO)			    ,;
                                                AllTrim((cAlsTmp)->DESC_CC)			    ,;
                                                AllTrim((cAlsTmp)->DESC_DPTO)			,;
                                                AllTrim((cAlsTmp)->COD_MAT)				,;
                                                AllTrim((cAlsTmp)->DESC_MAT)			,;
                                                AllTrim((cAlsTmp)->DESC_EV)				,;
                                                AllTrim((cAlsTmp)->TP_EV)			    ,;
                                                (cAlsTmp)->QUANT	                    })
        (cAlsTmp)->(dbSkip())
    enddo
    (cAlsTmp)->(dbCloseArea())			
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
    oExcel := MsExcel():New()
    //oExcel:WorkBooks:Open(cArquivo)
    oExcel:SetVisible(.T.)
    oExcel:Destroy()
endif
if lGerou
	Aviso('TOTVS',"Arquivo '" + cArquivo + "' gerado com sucesso. Realize as devidas conferências antes de enviar aos responsáveis para os próximos passos.",{'OK'},3,'Notificação de conclusão do processo')
endif
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg   ºAutor  ³Rodrigo Telecio   º Data ³  25/09/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se as perguntas estão criadas no arquivo SX1 e caso º±±
±±º          ³ não as encontre ele as cria.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ValidPerg()
local _sAlias 	:= GetArea()
local aRegs   	:= {}
local _aTam   	:= {}
local _cTit		:= ""
local i,j
_aTam 			:= TamSx3("PB_FILIAL" )
_cTit 			:= "Da Filial?"
AADD(aRegs,{cPerg,"01", _cTit, _cTit, _cTit, "mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par01",""           ,"","","","",""                   ,"","","","",""            ,"","","","",""               ,"","","","",""     ,"","","","SM0","","",""})
_cTit 			:= "Até Filial?"
AADD(aRegs,{cPerg,"02", _cTit, _cTit, _cTit, "mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","NaoVazio()","mv_par02",""           ,"","","","",""                   ,"","","","",""            ,"","","","",""               ,"","","","",""     ,"","","","SM0","","",""})
_aTam 			:= TamSx3("PB_MAT"    )
_cTit 			:= "De Matrícula?"
AADD(aRegs,{cPerg,"03", _cTit, _cTit, _cTit, "mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par03",""           ,"","","","",""                   ,"","","","",""            ,"","","","",""               ,"","","","",""     ,"","","","SRA","","",""})
_cTit 			:= "Até Matricula?"
AADD(aRegs,{cPerg,"04", _cTit, _cTit, _cTit, "mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G","NaoVazio()","mv_par04",""           ,"","","","",""                   ,"","","","",""            ,"","","","",""               ,"","","","",""     ,"","","","SRA","","",""})
_aTam 			:= TamSx3("PB_CC"     )
_cTit 			:= "Do Centro de Custo?"
AADD(aRegs,{cPerg,"05", _cTit, _cTit, _cTit, "mv_ch5",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par05",""           ,"","","","",""                   ,"","","","",""            ,"","","","",""               ,"","","","",""     ,"","","","CTT","","",""})
_cTit 			:= "Até Centro de Custo?"
AADD(aRegs,{cPerg,"06", _cTit, _cTit, _cTit, "mv_ch6",_aTam[03],_aTam[01],_aTam[02],0,"G","NaoVazio()","mv_par06",""           ,"","","","",""                   ,"","","","",""            ,"","","","",""               ,"","","","",""     ,"","","","CTT","","",""})
_aTam 			:= TamSx3("PB_DATA"   )
_cTit 			:= "Da Dt. inicial período?"
AADD(aRegs,{cPerg,"07", _cTit, _cTit, _cTit, "mv_ch7",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par07",""           ,"","","","",""                   ,"","","","",""            ,"","","","",""               ,"","","","",""     ,"","","",""   ,"","",""})
_cTit 			:= "Até Dt. final período?"
AADD(aRegs,{cPerg,"08", _cTit, _cTit, _cTit, "mv_ch8",_aTam[03],_aTam[01],_aTam[02],0,"G","NaoVazio()","mv_par08",""           ,"","","","",""                   ,"","","","",""            ,"","","","",""               ,"","","","",""     ,"","","",""   ,"","",""})
_aTam[03] 		:= "C"; _aTam[01] := 90; _aTam[02] := 0
_cTit 			:= "Diretorio p/Salvar Arq.?"
AADD(aRegs,{cPerg,"09", _cTit, _cTit, _cTit, "mv_ch9",_aTam[03],_aTam[01],_aTam[02],0,"G",'U_CAPARQ()',"mv_par09",""           ,"","","","",""                   ,"","","","",""		    ,"","","","",""               ,"","","","",""     ,"","","",""   ,"","",""})
_aTam[03] 		:= "N"; _aTam[01] := 01; _aTam[02] := 0
_cTit 			:= "Ordem do relatório?"
AADD(aRegs,{cPerg,"10", _cTit, _cTit, _cTit, "mv_cha",_aTam[03],_aTam[01],_aTam[02],0,"C",'NaoVazio()',"mv_par10","C.C. + Mat.","","","","","C.C. + Nome"        ,"","","","",""		    ,"","","","",""               ,"","","","",""     ,"","","",""   ,"","",""})
_aTam[03] 		:= "C"; _aTam[01] := 01; _aTam[02] := 0
_cTit 			:= "Horas centesimais ou sexagenais?"
AADD(aRegs,{cPerg,"11", _cTit, _cTit, _cTit, "mv_chb",_aTam[03],_aTam[01],_aTam[02],0,"C",'NaoVazio()',"mv_par11","Centesimais","","","","","Sexagenais"        ,"","","","",""		    ,"","","","",""               ,"","","","",""     ,"","","",""   ,"","",""})
_aTam 			:= TamSx3("PB_CC"     )
_cTit 			:= "Do Centro de Custo?"
AADD(aRegs,{cPerg,"12", _cTit, _cTit, _cTit, "mv_chc",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par12",""           ,"","","","",""                   ,"","","","",""            ,"","","","",""               ,"","","","",""     ,"","","","SQB","","",""})
_cTit 			:= "Até Centro de Custo?"
AADD(aRegs,{cPerg,"13", _cTit, _cTit, _cTit, "mv_chd",_aTam[03],_aTam[01],_aTam[02],0,"G","NaoVazio()","mv_par13",""           ,"","","","",""                   ,"","","","",""            ,"","","","",""               ,"","","","",""     ,"","","","SQB","","",""})

//cAliasSX1 	:= "SX1_" + GetNextAlias()
cAliasSX1 		:= "SX1"
OpenSxs( , , , , FWCodEmp(), cAliasSX1, "SX1", , .F.)
dbSelectArea(cAliasSX1)
(cAliasSX1)->(dbSetOrder(1))
for i := 1 to Len(aRegs)
	if !(cAliasSX1)->(dbSeek(cPerg + Space(Len((cAliasSX1)->X1_GRUPO) - Len(cPerg)) + aRegs[i,2]))
		RecLock(cAliasSX1,.T.)
		for j := 1 to FCount()
			if j <= Len(aRegs[i])
				FieldPut(j, aRegs[i,j])
			endif
		next j
		MsUnlock()
	endif
next i
RestArea(_sAlias)
return
/*/{Protheus.doc} CAPARQ
Função para coleta do diretório para salvar arquivo.
@author Rodrigo Telecio (rodrigo.telecio@allss.com.br)
@since 25/09/2020
@version 1.00 (P12.1.25)
@type Function	
@param nulo, Nil, nenhum 
@return nulo, Nil 
@obs Sem observações até o momento. 
@see https://allss.com.br/
@history 25/09/2020, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Disponibilização da rotina para uso.
/*/
user function CAPARQ()
local cTitulo 	:= 'Escolha o diretório para salvar o arquivo'
local cDirTmp 	:= GetTempPath()
mv_par09 		:= cGetFile('*.xml|*.xml',cTitulo,1,cDirTmp,.F.,nOR(GETF_LOCALHARD,GETF_LOCALFLOPPY,GETF_RETDIRECTORY),.F.,.T.)
return .T.
