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
#include 'restful.ch'
#define STR_PULA Chr(13) + Chr(10)
/*/{Protheus.doc} RFINA008
Fun็ใo de usuแrio responsแvel pela gera็ใo de arquivo XML de dados cadatrais para posterior integra็ใo com SERASA.
@author Rodrigo Telecio (rodrigo.telecio@allss.com.br)
@since 06/05/2023
@version P12.1.33
@type Function
@obs Sem observa็๕es
@see https://allss.com.br/
@history 06/05/2023, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Versใo inicial de desenvolvimento.
@history 12/05/2023, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Retirada de caracteres especiais " – " (tra็o duplo) e " " " (aspas duplas) e correta alimenta็ใo da regra de processamento.
/*/
user function RFINA008()
local cText         := OemToAnsi('SERASA - Gera็ใo de arquivo XML de dados cadastrais')
@ 0200,0001 to 0380,0380 dialog oProcessa TITLE cText
@ 0002,0002 to 0090,0190
@ 0012,0003 Say OemToAnsi(' Com base no cadastro de clientes, esta rotina gerarแ um arquivo XML de  ')
@ 0019,0003 Say OemToAnsi(' dados cadastrais em layout pr้-definido para integra็ใo com a SERASA,   ')
@ 0026,0003 Say OemToAnsi(' atendendo ao dispositivo legal do Cadastro Positivo (regulamentado pela ')
@ 0033,0003 Say OemToAnsi(' Lei 12.414/2011 e Lei Complementar 166/2019).                           ')
@ 0070,0118 BMPBUTTON TYPE 01 ACTION Processa({|| ProcXML()},cText,'Processando, aguarde...',.F.)
@ 0070,0148 BMPBUTTON TYPE 02 ACTION Close(oProcessa)
activate dialog oProcessa centered
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ProcXML    บAutor  ณ Rodrigo Telecio  บData ณ   18/10/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsavel pelo processamento dos dados e gera็ใo  บฑฑ
ฑฑบ          ณ do arquivo XML de dados cadastrais do cliente              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function ProcXML()
local nX
local nLinhas
private cRotina       := AllTrim(FunName())
private cPerg         := AllTrim(FunName())
private cTitulo       := OemToAnsi('SERASA - Log de valida็ใo da gera็ใo de arquivo XML de dados cadastrais')
private cUsuario      := ''
//variแveis de tratativa da string XML do arquivo a ser gerado
private cIniString    := ''
private cCliString    := ''
private cCliGString   := ''
private cFimString    := ''
private cStringUTF    := ''
//variแveis de identifica็ใo da empresa e controle da rotina
private DtRMS         := ''
private NrRms         := AllTrim(Str(SuperGetMv('MV_XREMSER',.F.,1)))
private NmOgm         := ''
private CNPJOgm       := ''
private aFieldSM0     :=  { 'M0_CODIGO' ,;
                            'M0_CODFIL' ,;
                            'M0_NOMECOM',;
                            'M0_CGC'     }
private aSM0Data2     := {}
private cLocalXML     := AllTrim(SuperGetMv('MV_XXMLSER',.F.,'\serasa\'))
private cLocalXSD     := AllTrim(SuperGetMv('MV_XXSDSER',.F.,'\serasa\schema\ACPO107.xsd'))
private cPrefixo      := AllTrim(SuperGetMv('MV_XPRESER',.F.,'ACPO107'))
private cCNPJOrigem   := ''
private cCNPJDestino  := AllTrim(SuperGetMV('MV_XCGCSER',.F.,'62173620'))
private cExtensaoXML  := AllTrim(SuperGetMV('MV_XEXTSER',.F.,'.xml'))
private cExtensaoLOG  := AllTrim(SuperGetMV('MV_XEXLSER',.F.,'.txt'))
private cArquivoXML   := ''
private cArquivoLOG   := ''
private cTextoLOG     := ''
private nSequencial   := 1
private aArqLog       := {}
private aArqRel       := {}
private cError        := ''
private cWarning      := ''
private nMaxCliArq    := SuperGetMV('MV_XMAXSER',.F.,1000)
private nCliente      := 0
private cCliente      := ''
private cLoja         := ''
//variแveis de identifica็ใo do cliente
private NmCli         := ''
private IdfcCli       := ''
private TipCli        := ''
//variแveis de endere็o do cliente
private UfEndCli      := ''
private MunEndCli     := ''
private CepEndCli     := ''
private BaiEndCli     := ''
private CmptEndCli    := ''
private NrEndCli      := ''
private LgrEndCli     := ''
//variแveis de contato (telefone e e-mail) do cliente
private NrTelCli      := ''
private DddTelCli     := ''
private aEmail        := {}
private EmaiCli       := ''
private cAliasSA1     := GetNextAlias()
private lRet          := .T.
ValidPerg()
if !Pergunte(cPerg,.T.)
    Aviso('TOTVS','Cancelamento de rotina em sua parametriza็ใo. Nada serแ processado.',{"&OK"},3,'Aus๊ncia de parโmetros para processamento')
else
    //verifica็ใo da existencia do diret๓rio para salvar os arquivos de integra็ใo
    if Empty(cLocalXML)
        Aviso('TOTVS','O parโmetro "MV_XXMLSER" que define o local onde serแ(ใo) salvo(s) o(s) arquivo(s) XML da integra็ใo com a SERASA nใo estแ definido/configurado e, portanto, o processamento serแ abortado. Revise a parametriza็ใo e tente novamente.',{"&OK"},3,'MV_XXMLSER - Necessidade de revisใo de conte๚do')
        lRet          := .F.
    elseif !CriaPasta(cLocalXML,'MV_XXMLSER')
        Aviso('TOTVS','A pasta ' + cLocalXML + ' declarada no parโmetro "MV_XXMLSER" nใo existe e, portanto, o processamento serแ abortado. Revise a parametriza็ใo e tente novamente.',{"&OK"},3,cLocalXML + ' - Cria็ใo de diret๓rio')        
        lRet          := .F.
    //verifica็ใo da existencia do diret๓rio e arquivo de schema para valida็ใo do arquivo de integra็ใo
    elseif Empty(cLocalXSD)
        Aviso('TOTVS','O parโmetro "MV_XXSDSER" que define o local onde estแ o arquivo de schema (".xsd") para valida็ใo do(s) arquivo(s) XML da integra็ใo com a SERASA nใo estแ definido/configurado e, portanto, o processamento serแ abortado. Revise a parametriza็ใo e tente novamente.',{"&OK"},3,'MV_XXSDSER - Necessidade de revisใo de conte๚do')
        lRet          := .F.
    //verifica็ใo do prefixo que comp๕e o arquivo de integra็ใo
    elseif Empty(cPrefixo)
        Aviso('TOTVS','O parโmetro "MV_XPRESER" que define o prefixo no nome do arquivo XML para integra็ใo com a SERASA nใo estแ definido/configurado e, portanto, o processamento serแ abortado. Revise a parametriza็ใo e tente novamente.',{"&OK"},3,'MV_XPRESER - Necessidade de revisใo de conte๚do')
        lRet          := .F.
    //verifica็ใo do CNPJ da SERASA que comp๕e o arquivo de integra็ใo
    elseif Empty(cCNPJDestino)
        Aviso('TOTVS','O parโmetro "MV_XCGCSER" que define a raํz do CNPJ da SERASA no mome do arquivo XML para integra็ใo com a SERASA nใo estแ definido/configurado e, portanto, o processamento serแ abortado. Revise a parametriza็ใo e tente novamente.',{"&OK"},3,'MV_XCGCSER - Necessidade de revisใo de conte๚do')
        lRet          := .F.
    //verifica็ใo da extensใo do arquivo de integra็ใo
    elseif Empty(cExtensaoXML) .OR. !cExtensaoXML $ '.xml|.gz'
        Aviso('TOTVS','O parโmetro "MV_XEXTSER" que define a extensใo no mome do arquivo XML para integra็ใo com a SERASA nใo estแ definido/configurado e, portanto, o processamento serแ abortado. Extens๕es aceitas: ".xml|.gz". Revise a parametriza็ใo e tente novamente.',{"&OK"},3,'MV_XEXTSER - Necessidade de revisใo de conte๚do')
        lRet          := .F.
    //verifica็a๕ da extensใo do arquivo de log de processamento
    elseif Empty(cExtensaoLOG) .OR. !cExtensaoLOG $ '.txt'
        Aviso('TOTVS','O parโmetro "MV_XEXLSER" que define a extensใo no mome do arquivo de log de processamento da integra็ใo com a SERASA nใo estแ definido/configurado e, portanto, o processamento serแ abortado. Extens๕es aceitas: ".txt". Revise a parametriza็ใo e tente novamente.',{"&OK"},3,'MV_XEXLSER - Necessidade de revisใo de conte๚do')
        lRet          := .F.
    //verifica็ใo da quantidade mแxima de clientes por arquivo
    elseif nMaxCliArq <= 0
        Aviso('TOTVS','O parโmetro "MV_XMAXSER" que define a quantidade mแxima de clientes por arquivo XML para integra็ใo com a SERASA nใo estแ definido/configurado e, portanto, o processamento serแ abortado. Revise a parametriza็ใo e tente novamente.',{"&OK"},3,'MV_XMAXSER - Necessidade de revisใo de conte๚do')
        lRet          := .F.
    endif
    //sendo vแlido, prossegue processamento
    if lRet
        beginsql alias cAliasSA1
            SELECT
                SA1.A1_FILIAL,
                SA1.A1_COD,
                SA1.A1_LOJA,
                SA1.A1_PESSOA,
                SA1.A1_CGC,
                SA1.A1_NOME,
                SA1.A1_END,
                SA1.A1_COMPLEM,
                SA1.A1_BAIRRO,
                SA1.A1_CEP,
                SA1.A1_MUN,
                SA1.A1_EST,
                SA1.A1_DDD,
                SA1.A1_TEL,
                SA1.A1_FAX,
                SA1.A1_CEL,
                SA1.A1_EMAIL
            FROM
                %table:SA1% AS SA1 (NOLOCK)
            WHERE
                SA1.A1_FILIAL     = %Exp:FwFilial('SA1')% 
                AND SA1.A1_PESSOA <> %Exp:''%
                AND SA1.A1_CGC    <> %Exp:''%
                AND SA1.A1_NOME   <> %Exp:''%
                AND SA1.A1_END    <> %Exp:''%
                AND SA1.A1_CEP    <> %Exp:''%
                AND SA1.A1_MUN    <> %Exp:''%
                AND SA1.A1_EST    <> %Exp:''%
                AND SA1.A1_TEL    <> %Exp:''%
                AND SA1.A1_EMAIL  <> %Exp:''%
                AND SA1.A1_MSBLQL <> %Exp:'1'%
                AND SA1.A1_EST    <> %Exp:'EX'%
                AND SA1.A1_COD    BETWEEN %Exp:mv_par01% AND %Exp:mv_par03%
                AND SA1.A1_LOJA   BETWEEN %Exp:mv_par02% AND %Exp:mv_par04%
                AND SA1.A1_EST    BETWEEN %Exp:mv_par05% AND %Exp:mv_par06%            
                AND SA1.%notDel%
            ORDER BY
                SA1.A1_COD, SA1.A1_LOJA
        endsql
        if (cAliasSA1)->(!EOF())            
            //identifica็ใo da empresa
            AbreArquivo()
            dbSelectArea(cAliasSA1)
            ProcRegua(RecCount())            
            while (cAliasSA1)->(!EOF())
                IncProc("Processando cliente " + AllTrim((cAliasSA1)->A1_NOME) + ", aguarde...")            
                nCliente++
                // **** quebra de arquivo ****
                if nCliente > nMaxCliArq
                    //finaliza็ใo do arquivo
                    FinalArquivo(1)
                    nSequencial++
                    //identifica็ใo da empresa
                    AbreArquivo()
                    cCliGString := ''
                    nCliente    := 1
                endif
                cCliente        := (cAliasSA1)->A1_COD
                cLoja           := (cAliasSA1)->A1_LOJA
                //tratativa de identifica็ใo do cliente
                NmCli           := ConvType(AllTrim((cAliasSA1)->A1_NOME),60)
                IdfcCli         := ConvType(AllTrim((cAliasSA1)->A1_CGC))
                TipCli          := ConvType(iif(AllTrim((cAliasSA1)->A1_PESSOA) == 'F','1','2'),1)
                cCliString      := '  <Cli NmCli="' + NmCli + '" IdfcCli="' + IdfcCli + '" TipCli="' + TipCli + '">' + STR_PULA
                while (cAliasSA1)->(!EOF()) .AND. cCliente == (cAliasSA1)->A1_COD .AND. cLoja == (cAliasSA1)->A1_LOJA
                    //tratativa referente ao endere็o
                    UfEndCli        := ConvType(AllTrim((cAliasSA1)->A1_EST),2)
                    MunEndCli       := ConvType(AllTrim((cAliasSA1)->A1_MUN),60)
                    CepEndCli       := ConvType(AllTrim((cAliasSA1)->A1_CEP),8)
                    BaiEndCli       := ConvType(AllTrim((cAliasSA1)->A1_BAIRRO),60)
                    CmptEndCli      := ConvType(AllTrim((cAliasSA1)->A1_COMPLEM),60)
                    if "/" $ FisGetEnd((cAliasSA1)->A1_END,(cAliasSA1)->A1_EST)[3]
                        NrEndCli    := ConvType(iif(FisGetEnd((cAliasSA1)->A1_END,(cAliasSA1)->A1_EST)[3] <> "",FisGetEnd((cAliasSA1)->A1_END,(cAliasSA1)->A1_EST)[3],"S/N"),6)
                    else
                        NrEndCli    := ConvType(iif(FisGetEnd((cAliasSA1)->A1_END,(cAliasSA1)->A1_EST)[2] <> 0,FisGetEnd((cAliasSA1)->A1_END,(cAliasSA1)->A1_EST)[2],"S/N"),6)
                    endif
                    LgrEndCli       := ConvType(AllTrim(FisGetEnd((cAliasSA1)->A1_END,(cAliasSA1)->A1_EST)[1]),60)
                    cCliString      += '    <EndCli UfEndCli="' + UfEndCli + '" MunEndCli="' + MunEndCli + '" CepEndCli="' + CepEndCli + '" BaiEndCli="' + BaiEndCli + '" CmptEndCli="' + CmptEndCli + '" NrEndCli="' + NrEndCli + '" LgrEndCli="' + LgrEndCli + '"/>' + STR_PULA
                    //tratativas referente ao(s) n๚mero(s) de telefone
                    NrTelCli        := FormatTel(AllTrim((cAliasSA1)->A1_TEL))
                    DddTelCli       := FormatDDD(AllTrim((cAliasSA1)->A1_DDD))
                    cCliString      += '    <TelCli NrTelCli="' + NrTelCli + '" DddTelCli="' + DddTelCli + '"/>' + STR_PULA
                    if !Empty(AllTrim((cAliasSA1)->A1_CEL))
                        NrTelCli    := FormatTel(AllTrim((cAliasSA1)->A1_CEL))
                        DddTelCli   := FormatDDD(AllTrim((cAliasSA1)->A1_DDD))
                        cCliString  += '    <TelCli NrTelCli="' + NrTelCli + '" DddTelCli="' + DddTelCli + '"/>' + STR_PULA
                    endif
                    if !Empty(AllTrim((cAliasSA1)->A1_FAX))
                        NrTelCli    := FormatTel(AllTrim((cAliasSA1)->A1_FAX))
                        DddTelCli   := FormatDDD(AllTrim((cAliasSA1)->A1_DDD))
                        cCliString  += '    <TelCli NrTelCli="' + NrTelCli + '" DddTelCli="' + DddTelCli + '"/>' + STR_PULA
                    endif
                    //tratativa referente ao(s) endere็o(s) de e-mail
                    aEmail          := StrtokArr(Lower(AllTrim((cAliasSA1)->A1_EMAIL)),";")
                    if Len(aEmail) > 0
                        for nX := 1 to Len(aEmail)
                            EmaiCli         := ConvType(aEmail[nX],120)
                            cCliString      += '    <EndEtnCli EmaiCli="' + EmaiCli + '"/>' + STR_PULA
                        next nX
                    endif
                    (cAliasSA1)->(dbSkip())
                enddo
                cCliString      += '  </Cli>' + STR_PULA
                //valida็ใo registro a registro
                cCliString      := SpecialChar(cCliString)
                cStringUTF      := SpecialChar(cIniString + cCliString + cFimString)
                cStringUTF      := EncodeUTF8(cStringUTF)
                if !XmlSVldSch(cStringUTF,cLocalXSD,@cError,@cWarning)
                    //erro no schema
                    if Len(cError) > 0
                        AADD(aArqLog,'Encontramos erro na valida็ใo do schema (estrutura) do arquivo do XML no cliente ' + cCliente + '/' + cLoja + '-' + NmCli + ":")
                        AADD(aArqRel,{cFilAnt,nSequencial,'Encontramos erro na valida็ใo do schema (estrutura) do arquivo do XML no cliente ' + cCliente + '/' + cLoja + '-' + NmCli + ":"})
                        cError      := StrTran(cError,Chr(13),' ')
                        cError      := StrTran(cError,Chr(10),' ')
                        cError      := StrTran(cError,Chr(9) ,'')
                        nLinhas     := MLCount(AllTrim(cError),200)
                        for nX := 1 to nLinhas
                            AADD(aArqLog,Memoline(AllTrim(cError),200,nX))
                            AADD(aArqRel,{cFilAnt,nSequencial,Memoline(AllTrim(cError),200,nX)})
                        next nX
                        AADD(aArqLog,'--------------------------------------------------------------------------------')
                        AADD(aArqRel,{cFilAnt,nSequencial,Replicate('*',180)})
                    //alerta (warning) no schema
                    elseif Len(cWarning) > 0
                        AADD(aArqLog,'Encontramos alerta na valida็ใo do schema (estrutura) do arquivo do XML no cliente ' + cCliente + '/' + cLoja + '-' + NmCli + ":")
                        AADD(aArqRel,{cFilAnt,nSequencial,'Encontramos alerta na valida็ใo do schema (estrutura) do arquivo do XML no cliente ' + cCliente + '/' + cLoja + '-' + NmCli + ":"})
                        cWarning      := StrTran(cWarning,Chr(13),' ')
                        cWarning      := StrTran(cWarning,Chr(10),' ')
                        cWarning      := StrTran(cWarning,Chr(9) ,'')
                        nLinhas       := MLCount(AllTrim(cWarning),200)
                        for nX := 1 to nLinhas
                            AADD(aArqLog,Memoline(AllTrim(cWarning),200,nX))
                            AADD(aArqRel,{cFilAnt,nSequencial,Memoline(AllTrim(cWarning),200,nX)})
                        next nX
                        AADD(aArqLog,'--------------------------------------------------------------------------------')
                        AADD(aArqRel,{cFilAnt,nSequencial,Replicate('*',180)})
                    //algum tipo de erro nใo especificado
                    else
                        AADD(aArqLog,'Encontramos problema na valida็ใo do schema (estrutura) do arquivo do XML no cliente ' + cCliente + '/' + cLoja + '-' + NmCli + ":")
                        AADD(aArqRel,{cFilAnt,nSequencial,'Encontramos problema na valida็ใo do schema (estrutura) do arquivo do XML no cliente ' + cCliente + '/' + cLoja + '-' + NmCli + ":"})
                        AADD(aArqLog,'Erro nใo especificado.')
                        AADD(aArqRel,{cFilAnt,nSequencial,'Erro nใo especificado.'})
                        AADD(aArqLog,'--------------------------------------------------------------------------------')
                        AADD(aArqRel,{cFilAnt,nSequencial,Replicate('*',180)})
                    endif
                endif
                cCliGString     += cCliString
            enddo
            (cAliasSA1)->(dbCloseArea())
            //finaliza็ใo do arquivo
            FinalArquivo(2)
        else
            Aviso('TOTVS','Nใo foram encontrados registros com os parโmetros informados. Por favor, revise a parametriza็ใo da rotina e tente novamente.',{"&OK"},3,'Aus๊ncia de registros para processamento')
        endif
    endif
endif
Close(oProcessa)
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AbreArquivo บAutor  ณ Rodrigo Telecio   บData ณ 20/10/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsavel pela tratativa do cabe็alho do arquivo  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function AbreArquivo()
cIniString          := '<?xml version="1.0" encoding="UTF-8"?>' + STR_PULA
DtRMS               := ConvType(AllTrim(SubStr(DtoS(dDataBase),7,2) + SubStr(DtoS(dDataBase),5,2) + SubStr(DtoS(dDataBase),1,4)),8)
SeqlRms             := AllTrim(Str(nSequencial))
aSM0Data2           := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,aFieldSM0)
if Len(aSM0Data2) > 0
    NmOgm           := ConvType(AllTrim(aSM0Data2[3,2]),60)
    CNPJOgm         := ConvType(AllTrim(aSM0Data2[4,2]),14)
endif
cIniString          += '<EnvoCad DtRms="' + DtRMS + '" SeqlRms="' + SeqlRms + '" NrRms="' + NrRms + '" NmOgm="' + NmOgm + '" CnpjOgm="' + CNPJOgm + '">' + STR_PULA
cFimString          := '</EnvoCad>'
cUsuario			:= UsrFullName(RetCodUsr())
aArqLog             := {}
AADD(aArqLog,'--------------------------------------------------------------------------------')
AADD(aArqLog,'INICIO - ' + AllTrim(cRotina) + ' - ' + cTitulo)
AADD(aArqLog,'--------------------------------------------------------------------------------')
AADD(aArqLog,'************************ EXECUวรO MANUAL (via menu) ****************************')
AADD(aArqLog,'Data/Hora do inicio de processamento: '   + AllTrim(DtoC(Date()))     + ' - '         + AllTrim(Time()))
AADD(aArqLog,'Usuแrio responsแvel pelo processamento: ' + AllTrim(RetCodUsr())      + ' - '         + UsrFullName(RetCodUsr()))
AADD(aArqLog,'Informa็๕es do ambiente: Protheus '       + AllTrim(GetRPORelease())  + ' - Build '   + AllTrim(GetBuild(.F.)) + ' - Environment ' + AllTrim(GetEnvServer()))
AADD(aArqLog,'--------------------------------------------------------------------------------')
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FinalArquivo บAutor  ณ Rodrigo Telecio  บData ณ 20/10/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsavel pela tratativa de finaliza็ใo do arquivoบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function FinalArquivo(nMomento)
local nX
local nStatus
local cMensagem
local nLinhas
// Todo sequencial deve seguir a nomenclatura padrใo: "ACPO107_CNPJorigem_CNPJdestino_Data_sequencial"
//  ACPO107         - Prefixo constante, nใo deve ser alterado
//  CNPJorigem      - Raiz do CNPJ da empresa fonte
//  CNPJdestino     – Raiz do CNPJ da Serasa Experian –valor fixo 62173620
//  Data            – Data de envio no formato AAAAMMDD
//  Sequencial      – N๚mero do sequencial da remessa expresso por 5 dํgitos
cCNPJOrigem         := SubStr(CNPJOgm,1,8)
cArquivoXML         := cPrefixo + '_' + cCNPJOrigem + '_' + cCNPJDestino + '_' + DtoS(dDataBase) + '_' + StrZero(nSequencial,5) + cExtensaoXML
MemoWrite(cLocalXML + cArquivoXML,cIniString + cCliGString + cFimString)
nStatus             := FRename(cLocalXML + cArquivoXML,Upper(cLocalXML + cArquivoXML),nil,.F.)
if nStatus == -1
    AADD(aArqLog,'Houve falha na tentativa de renomear o arquivo: ')
    AADD(aArqRel,{cFilAnt,nSequencial,'Houve falha na tentativa de renomear o arquivo: '})
    cMensagem       := AllTrim(FError())
    cMensagem       := StrTran(cMensagem,Chr(13),' ')
    cMensagem       := StrTran(cMensagem,Chr(10),' ')
    cMensagem       := StrTran(cMensagem,Chr(9) ,'')
    nLinhas         := MLCount(AllTrim(cMensagem),200)
    for nX := 1 to nLinhas
        AADD(aArqLog,Memoline(AllTrim(cMensagem),200,nX))
        AADD(aArqRel,{cFilAnt,nSequencial,Memoline(AllTrim(cMensagem),200,nX)})
    next nX
    AADD(aArqLog,'--------------------------------------------------------------------------------')
    AADD(aArqRel,{cFilAnt,nSequencial,Replicate('*',180)})
endif
AADD(aArqLog,'--------------------------------------------------------------------------------')
AADD(aArqLog,'Data/Hora de t้rmino de processamento: ' + AllTrim(DtoC(Date())) + ' - ' + AllTrim(Time()))
AADD(aArqLog,'TษRMINO - ' + AllTrim(cRotina))
AADD(aArqLog,'--------------------------------------------------------------------------------')
cTextoLOG           := ''
if Len(aArqLog) > 0
    for nX := 1 to Len(aArqLog)
        cTextoLOG   += AllTrim(aArqLog[nX]) + STR_PULA
    next nX
    cArquivoLOG     := 'LOG_' + cCNPJOrigem + '_' + cCNPJDestino + '_' + DtoS(dDataBase) + '_' + StrZero(nSequencial,5) + cExtensaoLOG
    MemoWrite(cLocalXML + cArquivoLOG,cTextoLOG)
endif
if nMomento == 2
    //Gera็ใo do arquivo bastใo
    nSequencial++
    GeraArqBastao()
    //Gera็ใo de relat๓rio de log e mensagem de t้rmino de processamento
    RelLog()
	Aviso('TOTVS','T้rmino do processamento. Verifique o(s) arquivo(s) gerado(s) em ' + cLocalXML +  ' e confira os resultados.',{'&OK'},3,'T้rmino de processamento')
    //Atualizar parโmetro com o n๚mero sequencial de registro de remessas
    NrRms           := Val(NrRms) + 1
    PutMv('MV_XREMSER',NrRms)
endif
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GeraArqBastao  บAutor ณ Rodrigo Telecio บData ณ 25/10/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsavel pela gera็ใo de arquivo bastใo          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function GeraArqBastao()
local nStatus
local nX
cIniString          := '<?xml version="1.0" encoding="UTF-8"?>' + STR_PULA
DtRMS               := ConvType(AllTrim(SubStr(DtoS(dDataBase),7,2) + SubStr(DtoS(dDataBase),5,2) + SubStr(DtoS(dDataBase),1,4)),8)
SeqlRms             := AllTrim(Str(nSequencial))
aSM0Data2           := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,aFieldSM0)
if Len(aSM0Data2) > 0
    NmOgm           := ConvType(AllTrim(aSM0Data2[3,2]),60)
    CNPJOgm         := ConvType(AllTrim(aSM0Data2[4,2]),14)
endif
cIniString          += '<EnvoCad DtRms="' + DtRMS + '" SeqlRms="' + SeqlRms + '" NrRms="' + NrRms + '" NmOgm="' + NmOgm + '" CnpjOgm="' + CNPJOgm + '">' + STR_PULA
cFimString          := '</EnvoCad>'
cStringUTF          := SpecialChar(cIniString + cFimString)
cStringUTF          := EncodeUTF8(cStringUTF)
// Todo sequencial deve seguir a nomenclatura padrใo: "ACPO107_CNPJorigem_CNPJdestino_Data_sequencial"
//  ACPO107         - Prefixo constante, nใo deve ser alterado
//  CNPJorigem      - Raiz do CNPJ da empresa fonte
//  CNPJdestino     – Raiz do CNPJ da Serasa Experian –valor fixo 62173620
//  Data            – Data de envio no formato AAAAMMDD
//  Sequencial      – N๚mero do sequencial da remessa expresso por 5 dํgitos
cCNPJOrigem         := SubStr(CNPJOgm,1,8)
cArquivoXML         := cPrefixo + '_' + cCNPJOrigem + '_' + cCNPJDestino + '_' + DtoS(dDataBase) + '_' + StrZero(nSequencial,5) + cExtensaoXML
MemoWrite(cLocalXML + cArquivoXML,cStringUTF)
nStatus             := FRename(cLocalXML + cArquivoXML,Upper(cLocalXML + cArquivoXML),nil,.F.)
if nStatus == -1
    AADD(aArqRel,{cFilAnt,nSequencial,'Houve falha na tentativa de renomear o arquivo: '})
    cMensagem       := AllTrim(FError())
    cMensagem       := StrTran(cMensagem,Chr(13),' ')
    cMensagem       := StrTran(cMensagem,Chr(10),' ')
    cMensagem       := StrTran(cMensagem,Chr(9) ,'')
    nLinhas         := MLCount(AllTrim(cMensagem),200)
    for nX := 1 to nLinhas
        AADD(aArqRel,{cFilAnt,nSequencial,Memoline(AllTrim(cMensagem),200,nX)})
    next nX
    AADD(aArqRel,{cFilAnt,nSequencial,Replicate('*',180)})
endif
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CriaPasta      บAutor ณ Rodrigo Telecio บData ณ 25/10/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsavel pela checagem e cria็ใo de diret๓rio    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function CriaPasta(cDiretorio,cParametro)
local lRet          := .T.
local nRet          := 0
default cDiretorio  := ''
default cParametro  := ''
if !Empty(cDiretorio) .AND. !Empty(cParametro)
    if !ExistDir(cLocalXML,nil,.F.)
        nRet            := MakeDir(cLocalXML,nil,.F.)
        if nRet <> 0
            lRet        := .F. 
        else
            Aviso('TOTVS','A pasta ' + AllTrim(cDiretorio) + ' declarada no parโmetro ' + AllTrim(cParametro) + ' foi criada com ๊xito.',{"&OK"},3,AllTrim(cParametro) + ' - Cria็ใo de diret๓rio')
        endif
    endif
endif
return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ConvType   บAutor  ณ Rodrigo Telecio   บ Data ณ 18/10/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsavel por formatar conte๚do de campo de       บฑฑ
ฑฑบ          ณ acordo com seu tipo de dado.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function ConvType(xValor,nTam,nDec)
local cNovo         := ''
default nDec        := 0
do case
	case ValType(xValor) == "N"
		if xValor <> 0
			cNovo   := AllTrim(Str(xValor,nTam,nDec))	
		else
			cNovo   := "0"
		endif
	case ValType(xValor) == "D"
		cNovo       := FsDateConv(xValor,"DDMMYYYY")
	case ValType(xValor) == "C"
		if nTam == nil
			xValor  := AllTrim(xValor)
		endif
        default nTam        := 60		
		cNovo       := AllTrim(NoAcento(SubStr(xValor,1,nTam)))
endcase
return(cNovo)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ NoAcento   บAutor  ณ Rodrigo Telecio   บ Data ณ 18/10/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsavel por remover caracteres especiais de     บฑฑ
ฑฑบ          ณ campo do tipo "caractere"                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function NoAcento(cString)
local cChar         := ''
local nX            := 0
local nY            := 0
local cVogal        := "aeiouAEIOU"
local cAgudo        := "แ้ํ๓๚" + "มษอำฺ"
local cCircu        := "โ๊๎๔๛" + "ยสฮิÛ"
local cTrema        := "ไ๋๏๖ü" + "ฤหฯึÜ"
local cCecid        := "็ว"
local cTio          := "ใ๕รี"
local cCrase        := "เ่์๒๙" + "ภศฬาู" 
local cMaior        := "&lt;"
local cMenor        := "&gt;"
local cEComercial   := "&"
local cAspasDuplas  := '"'
local cAspasSimples := "'"
local cHifenDuplo   := "–"
for nX := 1 to Len(cString)
	cChar           := SubStr(cString, nX, 1)
	if cChar $ cAgudo + cCircu + cTrema + cCecid + cTio + cCrase + cEComercial + cAspasDuplas + cAspasSimples + cHifenDuplo
		nY          := At(cChar,cAgudo)
		if nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		endif
		nY          := At(cChar,cCircu)
		if nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		endif
		nY          := At(cChar,cTrema)
		if nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		endif
		nY          := At(cChar,cCrase)
		if nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		endif
		nY          := At(cChar,cTio)
		if nY > 0          
			cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
		endif
		nY          := At(cChar,cCecid)
		if nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		endif
        nY          := At(cChar,cEComercial)
        if nY > 0
            cString := StrTran(cString,cChar,SubStr("E",nY,1))
        endif
        nY          := At(cChar,cAspasDuplas)
        if nY > 0
            cString := StrTran(cString,cChar,SubStr(" ",nY,1))
        endif
        nY          := At(cChar,cAspasSimples)
        if nY > 0
            cString := StrTran(cString,cChar,SubStr(" ",nY,1))
        endif
        nY          := At(cChar,cHifenDuplo)
        if nY > 0
            cString := StrTran(cString,cChar,SubStr(" ",nY,1))
        endif        
	endif
next nX
if cMaior $ cString 
	cString         := StrTran(cString,cMaior,"") 
endif
if cMenor $ cString 
	cString         := strTran(cString,cMenor,"")
endif
cString             := StrTran(cString,CRLF," ")
return cString
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FormatTel  บAutor  ณ Rodrigo Telecio   บ Data ณ 18/10/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsavel por formatar n๚mero de telefone         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function FormatTel(cTel)
local cRet          := ''
default cTel        := ''
cRet                := StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(cTel,"/",""),"(",""),")",""),"+",""),"-","")," ","")
return cRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FormatDDD  บAutor  ณ Rodrigo Telecio   บ Data ณ 18/10/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsavel por formatar DDD do n๚mero de telefone  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function FormatDDD(cDDD)
local cRet          := ''
default cTel        := ''
if SubStr(cDDD,1,1) == '0'
    cRet            := SubStr(cDDD,2)
else
    cRet            := AllTrim(cDDD)
endif
return cRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SpecialChar บAutor  ณ Rodrigo Telecio  บ Data ณ 20/10/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Limpa os c๓digos ASCII faixa 127 a 255 que falham os       บฑฑ
ฑฑบ          ณ EncodeUTF8                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function SpecialChar(cString)
local nX            := 0
local aChar         := {}
default cString     := ""
if !Empty(cString)
    AADD(aChar,129)
    AADD(aChar,141)
    AADD(aChar,143)
    AADD(aChar,144)
    AADD(aChar,157)
    AADD(aChar,169)
    AADD(aChar,170) 
    AADD(aChar,174) 
    AADD(aChar,176)
    AADD(aChar,177)
    AADD(aChar,178)
    AADD(aChar,179)
    AADD(aChar,180)
    AADD(aChar,186)
    AADD(aChar,188)
    AADD(aChar,189)
    AADD(aChar,190)
    for nX := 1 to Len(aChar)
        cString     := StrTran(cString,Chr(aChar[nX]),' ')
    next nX
endif
return cString
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RelLog    บAutor  ณ Rodrigo Telecio    บ Data ณ 20/10/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Imprime relat๓rio com erros gerados                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function RelLog()
local oReport
if FindFunction("TRepInUse") .AND. TRepInUse()	
    oReport     := ReportDef()
    oReport:PrintDialog()
endif
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ ReportDef  บAutor  ณ Rodrigo Telecio   บ Data ณ 20/10/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ A funcao estatica ReportDef devera ser criada para todos   ณฑฑ
ฑฑณ          ณos relatorios que poderao ser agendados pelo usuario.       ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function ReportDef()
local oReport
local oSection1
oReport             := TReport():New(cRotina,cTitulo,, {|oReport| PrintReport(oReport)},"Emissao do relat๓rio, de acordo com o resultado do arquivo de log de processamento da rotina.")
oReport:SetLandscape()
oSection1           := TRSection():New(oReport,cTitulo,{"SA1"},/*Ordem*/)
oSection1:SetHeaderBreak()
TRCell():New(oSection1,"FILIAL"    ,/*Alias*/,"Filial        "          ,/*Picture*/            ,TamSx3("A1_FILIAL")[01],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"SEQUENCIAL",/*Alias*/,"Seq. Arq.     "          ,/*Picture*/            ,8                      ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DESCRICAO" ,/*Alias*/,"Descri็ใo     "          ,/*Picture*/            ,200                    ,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("FILIAL"    ):SetHeaderAlign("LEFT")
oSection1:Cell("SEQUENCIAL"):SetHeaderAlign("LEFT")
oSection1:Cell("DESCRICAO" ):SetHeaderAlign("LEFT")
return(oReport)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ PrintReportบAutor  ณ Rodrigo Telecio   บ Data ณ 20/10/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ A funcao estatica PrintReport devera ser criada para todos ณฑฑ
ฑฑณ          ณos relatorios que poderao ser agendados pelo usuario.       ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function PrintReport(oReport)
local nX
local nSections     := 1
local oSection1     := oReport:Section(1)
oReport:SetMeter(nSections)
oSection1:Init()
oReport:IncMeter()
if Len(aArqRel) > 0
    for nX := 1 to Len(aArqRel)
        oReport:IncMeter()
        oSection1:Cell("FILIAL"    ):SetValue(AllTrim(aArqRel[nX,1]))
        oSection1:Cell("SEQUENCIAL"):SetValue(StrZero(aArqRel[nX,2],5))   
        oSection1:Cell("DESCRICAO" ):SetValue(AllTrim(aArqRel[nX,3]))
        oSection1:PrintLine()
    next nX
else
    oReport:IncMeter()
    oSection1:Cell("FILIAL"    ):SetValue('')
    oSection1:Cell("SEQUENCIAL"):SetValue('')   
    oSection1:Cell("DESCRICAO" ):SetValue('Nใo hแ informa็๕es de log coletadas durante o processamento.')
    oSection1:PrintLine()
endif
oReport:SkipLine()
oSection1:Finish()
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ValidPerg  บAutor  ณ Rodrigo Telecio   บ Data ณ 18/10/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsavel por criar as perguntas utilizadas no    บฑฑ
ฑฑบ          ณ relat๓rio                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function ValidPerg()
local aAlias 		:= GetArea()
local aRegs   		:= {}
local aTam   		:= {}
local cTit			:= ''
local i,j
local cAliasSX1     := "SX1"
OpenSxs(,,,,FWCodEmp(),cAliasSX1,"SX1",,.F.)
dbSelectArea(cAliasSX1)
(cAliasSX1)->(dbSetOrder(1))
cPerg  := PADR(cPerg,len((cAliasSX1)->X1_GRUPO))
aTam 			:= TamSX3('A1_COD')
cTit 			:= "De cliente?"
AADD(aRegs,{cPerg,"01", cTit, cTit, cTit, "mv_ch1",aTam[03],aTam[01],aTam[02],0,"G",""                    ,"mv_par01",""           ,"","","","",""                    ,"","","","",""            ,"","","","",""               ,"","","","",""     ,"","","","SA1"   ,"","",""})
aTam 			:= TamSX3('A1_LOJA')
cTit 			:= "De loja do cliente?"
AADD(aRegs,{cPerg,"02", cTit, cTit, cTit, "mv_ch2",aTam[03],aTam[01],aTam[02],0,"G",""                    ,"mv_par02",""           ,"","","","",""                    ,"","","","",""            ,"","","","",""               ,"","","","",""     ,"","","",""      ,"","",""})
aTam 			:= TamSX3('A1_COD')
cTit 			:= "At้ cliente?"
AADD(aRegs,{cPerg,"03", cTit, cTit, cTit, "mv_ch3",aTam[03],aTam[01],aTam[02],0,"G","naovazio()"          ,"mv_par03",""           ,"","","","",""                    ,"","","","",""            ,"","","","",""               ,"","","","",""     ,"","","","SA1"   ,"","",""})
aTam 			:= TamSX3('A1_LOJA')
cTit 			:= "At้ loja do cliente?"
AADD(aRegs,{cPerg,"04", cTit, cTit, cTit, "mv_ch4",aTam[03],aTam[01],aTam[02],0,"G","naovazio()"          ,"mv_par04",""           ,"","","","",""                    ,"","","","",""            ,"","","","",""               ,"","","","",""     ,"","","",""      ,"","",""})
aTam 			:= TamSX3('A1_EST')
cTit 			:= "De UF?"
AADD(aRegs,{cPerg,"05", cTit, cTit, cTit, "mv_ch5",aTam[03],aTam[01],aTam[02],0,"G",""                    ,"mv_par05",""           ,"","","","",""                    ,"","","","",""            ,"","","","",""               ,"","","","",""     ,"","","","12"    ,"","",""})
aTam 			:= TamSX3('A1_EST')
cTit 			:= "At้ UF?"
AADD(aRegs,{cPerg,"06", cTit, cTit, cTit, "mv_ch6",aTam[03],aTam[01],aTam[02],0,"G","naovazio()"          ,"mv_par06",""           ,"","","","",""                    ,"","","","",""            ,"","","","",""               ,"","","","",""     ,"","","","12"    ,"","",""})
//cAliasSX1 		:= "SX1_" + GetNextAlias()

for i := 1 to len(aRegs)
    if !(cAliasSX1)->(dbSeek(cPerg+aRegs[i,2]))
        while !RecLock(cAliasSX1,.T.) ; enddo
            for j := 1 to FCount()
                if j <= len(aRegs[i])
                    FieldPut(j,aRegs[i,j])
                else
                    Exit
                endif
            next
        (cAliasSX1)->(MsUnLock())
    endif
next
RestArea(aAlias)
return
