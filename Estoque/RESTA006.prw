#include 'protheus.ch'
#include 'rwmake.ch'
#include 'topconn.ch'
#include 'olecont.ch'
#define STR_PULA CHR(13) + CHR(10)
/*/{Protheus.doc} RESTA006
Função de usuário para atualização das informações do cadastro de produtos com base em arquivo ".csv".
@author Diego Rodrigues (diego.rodrigues@allss.com.br) / Rodrigo Telecio (rodrigo.telecio@allss.com.br)
@since 26/05/2021
@version P12
@type Function
@obs Sem observações
@see https://allss.com.br/
@history 26/05/2021, Diego Rodrigues (diego.rodrigues@allss.com.br), Inicio do desenvolvimento da primeira versão do programa.
@history 18/08/2021, Diego Rodrigues (diego.rodrigues@allss.com.br), Removido a validação para não leitura dos numeros após a virgula nos casos de PI/MP.
@history 06/10/2021, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Adição do campo B1_LM para atualização por meio desta rotina.
/*/ 
user function RESTA006()
private oLeTxt
@ 200,001 to 380,380 dialog oLeTxt TITLE OemToAnsi('Atualização de dados no cadastro de produtos (MRP)')
@ 002,002 to 090,190
@ 010,003 Say '    Este programa atualizará as informações no cadastro de produtos         '
@ 018,003 Say '    referente ao MRP do Protheus de acordo com arquivo ".csv"               '
@ 026,003 Say '            *** ATENÇÃO! ESSA OPERAÇÃO NÃO TEM REVERSÃO ***                 '
@ 070,118 BMPBUTTON TYPE 01 ACTION Processa({|| ProcImport()},'Atualização de dados no cadastro de produtos','Processando, aguarde...',.F.)
@ 070,148 BMPBUTTON TYPE 02 ACTION Close(oLeTxt)
activate dialog oLeTxt centered
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ProcImport  ºAutor  ³Rodrigo Telecio    º Data ³  26/05/2021º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Escolha dos campos que serão atualizados                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                           			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ProcImport()
private oOK 		:= LoadBitmap(GetResources(),'br_verde')
private oNO 		:= LoadBitmap(GetResources(),'br_vermelho')
private aListAux    := {}
private aList		:= {}
private nX
private oDlg
aListAux            := {.T.,'B1_EMIN'   ,FWX3Titulo('B1_EMIN')      ,TamSX3('B1_EMIN')[3]       ,TamSX3('B1_EMIN')[1]   ,TamSX3('B1_EMIN')[2]   }
AADD(aList, aListAux)
aListAux            := {.T.,'B1_ESTSEG' ,FWX3Titulo('B1_ESTSEG')    ,TamSX3('B1_ESTSEG')[3]     ,TamSX3('B1_ESTSEG')[1] ,TamSX3('B1_ESTSEG')[2] }
AADD(aList, aListAux)
aListAux            := {.T.,'B1_EMAX'   ,FWX3Titulo('B1_EMAX')      ,TamSX3('B1_EMAX')[3]       ,TamSX3('B1_EMAX')[1]   ,TamSX3('B1_EMAX')[2]   }
AADD(aList, aListAux)
aListAux            := {.T.,'B1_LE'     ,FWX3Titulo('B1_LE')        ,TamSX3('B1_LE')[3]         ,TamSX3('B1_LE')[1]     ,TamSX3('B1_LE')[2]     }
AADD(aList, aListAux)
aListAux            := {.T.,'B1_PE'     ,FWX3Titulo('B1_PE')        ,TamSX3('B1_PE')[3]         ,TamSX3('B1_PE')[1]     ,TamSX3('B1_PE')[2]     }
AADD(aList, aListAux)
aListAux            := {.T.,'B1_TIPE'   ,FWX3Titulo('B1_TIPE')      ,TamSX3('B1_TIPE')[3]       ,TamSX3('B1_TIPE')[1]   ,TamSX3('B1_TIPE')[2]   }
AADD(aList, aListAux)
aListAux            := {.T.,'B1_LM'     ,FWX3Titulo('B1_LM')        ,TamSX3('B1_LM')[3]         ,TamSX3('B1_LM')[1]     ,TamSX3('B1_LM')[2]     }
AADD(aList, aListAux)
define msdialog oDlg from 000,000 to 520,600 pixel title 'Atualização por importação de dados - Selecione os campos a serem atualizados' 
define font oFont name 'Courier New' size 0, -12
oList               := TCBrowse():New(001,001,300,200,,{'','Campo','Descrição','Tipo de dados','Tamanho','Decimais'},{20,50,60,30,30,30},oDlg,,,,,{||},,oFont,,,,,.F.,,.T.,,.F.,,,)
oList:SetArray(aList) 
oList:bLine         := {||{ If(aList[oList:nAt,01],oOK,oNO),aList[oList:nAt,02],aList[oList:nAt,03]}}
oList:bLDblClick    := {|| aList[oList:nAt][1] := !aList[oList:nAt][1],oList:DrawSelect() }
oBtn                := TButton():New(220,040,'&Atualizar registros' , oDlg,{|| ProcDados()}		,090,010,,,.F.,.T.,.F.,,.F.,,,.F.)
oBtn                := TButton():New(220,180,'&Legenda'	            , oDlg,{|| ExibeLegenda()}	,090,010,,,.F.,.T.,.F.,,.F.,,,.F.)
activate msdialog oDlg centered
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ProcDados  ºAutor  ³Rodrigo Telecio     º Data ³  26/05/2021º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função de processamento principal                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ProcDados()                       
local nTam 		:= Len(aList)
local nFalse	:= 0
local nTrue		:= 0
local i         := 0
for i := 1 to nTam
	if !aList[i,1]
		nFalse++
	else
		nTrue++		
	endif
next i
if nFalse == nTam
    Aviso('TOTVS','Nenhum campo foi selecionado para importação. Tente novamente!',{'&OK'},3,'Falha na seleção dos campos')
	return .F.
endif
Processa({|| ImportaDad()},'Lendo arquivo ".csv"')
Close(oDlg)
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImportaDad  ºAutor  ³Rodrigo Telecio    º Data ³  26/05/2021º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função responsavel pela abertura do arquivo e gravação dos º±±
±±º          ³dados                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ImportaDad()
local cFileOpen := ""
local cTitulo1  := "Selecione o arquivo"
local cExtens   := "Arquivo CSV | *.csv"
local cAliasAux := GetNextAlias()
local i         := 0
local y         := 0
local aConteudo := {}
local nX        := 0
local aRet      := {}
local aCampos   := {}
local aProd     := {}
cFileOpen       := cGetFile(cExtens,cTitulo1,,,.T.)
_aStru          := {}
AADD(_aStru,{'B1_COD'	    ,TamSX3('B1_COD')[3]    ,TamSX3('B1_COD')[1]   ,TamSX3('B1_COD')[2]}    )
for i := 1 to Len(aList)
	if aList[i,01]
		AADD(_aStru,{aList[i,2]   ,aList[i,4]     ,aList[i,5]     ,aList[i,6]})
	endif	
next i
_cArq2          := CriaTrab(_aStru,.T.)
dbUseArea(.T.,,_cArq2,cAliasAux,.F.,.F.)
IndRegua(cAliasAux,_cArq2,"B1_COD",,,"Criando arquivo temporario...")
oFile := FWFileReader():New(cFileOpen)
if !oFile:Open()
    Aviso('TOTVS','Arquivo ' + AllTrim(cFileOpen) + ' não localizado. Tente novamente.',{'&OK'},3,'Falha de processamento')
    Close(oDlg)
    oFile:Close()
    return .F.
endif
oFile:SetBufferSize(65536)
lPrimer	        := .F.
nCont	        := 0
while oFile:HasLine()
	IncProc("Obtendo informações do arquivo...")
    aConteudo   := oFile:GetAllLines()
enddo
oFile:Close()
if Len(aConteudo) > 0
    IncProc("Montando arquivo temporário...")
    for nX := 1 to Len(aConteudo)
        aProd       := {}
        aRet		:= StrTokArr2(aConteudo[nX],";",.T.)
        if !lPrimer
            if Len(aRet) > 0
            //if Len(aRet) == 0
                for i := 1 to Len(aRet)
                    nPosCampo   := aScan(aRet,_aStru[i,1])
                    if nPosCampo # 0
                        AADD(aCampos,{_aStru[i,1],nPosCampo})
                    endif
                next i
                lPrimer := .T.
                nCont++
            endif
        endif
        if nCont > 1 .AND. !Empty(aRet[1])
            dbSelectArea("SB1")
            SB1->(dbSetOrder(1))
            dbSeek(FWFilial("SB1") + aRet[1])
            /*  Conforme solicitado remover a validação de não possui numeros após a virgula para os casos de MP/PI
            aadd(aProd, {"B1_FILIAL", FWFilial("SB1"), NIL})
            aadd(aProd, {"B1_COD", aRet[1], NIL})
            aadd(aProd, {"B1_EMIN", Round(Val(aRet[2]),1), NIL})
            aadd(aProd, {"B1_ESTSEG", Round(Val(aRet[3]),1), NIL})
            aadd(aProd, {"B1_EMAX", Round(Val(aRet[4]),1), NIL})
            aadd(aProd, {"B1_LE", Round(Val(aRet[5]),1), NIL})
            aadd(aProd, {"B1_PE", Round(Val(aRet[6]),1), NIL})
            aadd(aProd, {"B1_TIPE", aRet[7], NIL})
            */
            aadd(aProd, {"B1_FILIAL"    , FWFilial("SB1"), NIL})
            aadd(aProd, {"B1_COD"       , aRet[1], NIL})
            aadd(aProd, {"B1_EMIN"      , iif(SB1->B1_TIPO $ "MP/PI",Round(Val(aRet[2]),2),Round(Val(aRet[2]),0)), NIL})
            aadd(aProd, {"B1_ESTSEG"    , iif(SB1->B1_TIPO $ "MP/PI",Round(Val(aRet[3]),2),Round(Val(aRet[3]),0)), NIL})
            aadd(aProd, {"B1_EMAX"      , iif(SB1->B1_TIPO $ "MP/PI",Round(Val(aRet[4]),2),Round(Val(aRet[4]),0)), NIL})
            aadd(aProd, {"B1_LE"        , iif(SB1->B1_TIPO $ "MP/PI",Round(Val(aRet[5]),2),Round(Val(aRet[5]),0)), NIL})
            aadd(aProd, {"B1_PE"        , Round(Val(aRet[6]),1), NIL})
            aadd(aProd, {"B1_TIPE"      , aRet[7], NIL})
            aadd(aProd, {"B1_LM"        , iif(SB1->B1_TIPO $ "MP/PI",Round(Val(aRet[8]),2),Round(Val(aRet[8]),0)), NIL})
            MSExecAuto({|x,y| MATA010(x,y)},aProd,4)
            // Tratativa para verificar se a alteração apresentou algum erro
            cErro := MostraErro("C:\temp\Log\", "teste.log")
            nLinhaErro := MLCount(cErro)
            cBuffer := ""
            cCampo := ""
            nErrLin := 1
            cBuffer := RTrim(MemoLine(cErro,,nErrLin))
            // Carrega o nome do campo
            While (nErrLin <= nLinhaErro)
                nErrLin++
                cBuffer := RTrim(MemoLine(cErro,,nErrLin))
                If (Upper(SubStr(cBuffer,Len(cBuffer)-7,Len(cBuffer))) == "INVALIDO")
                    cCampo := cBuffer
                    xTemp := AT("-",cBuffer)
                    cCampo := AllTrim(SubStr(cBuffer,xTemp+1,AT(":",cBuffer)-xTemp-2))
                    Exit
                EndIf
            EndDo
       endif
       nCont++  
    next nX
else
    Aviso('TOTVS','Não foi possível obter as informações do arquivo indicado. Tente executar o processo novamente.',{'&OK'},3,'Falha de processamento')
endif
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ExibeLegenda ºAutor  ³Rodrigo Telecio  º Data ³  31/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função responsavel pela exibição da legenda da tela	     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ExibeLegenda()
local nX            := 0
local nY 			:= 0
private aCores      := { 	{"br_verde"   ,"Atualizar o campo"  		},;
						    {"br_vermelho","Não Atualizar o campo" 	    }}
private aBmp[Len(aCores)]	               		
private oVm 		:= LoadBitmap( GetResources(), "br_vermelho"	    )
private oVd 		:= LoadBitmap( GetResources(), "br_verde"   	    )
private oButton1	:= nil                
private cTitulo 	:= "Legenda - Atualização por importação de dados"
private oSay2		:= nil
private oDlg1
define msdialog oDlg1 title cTitulo from 000,000 to 150,300 colors 0, 16777215 pixel
for nX := 1 to Len(aCores)
	@ 009 + ((nX-1) * 10)   ,005 bitmap aBmp[nX] RESNAME aCores[nX][1]                                               			        of oDlg1 size 020,020 noborder  when .F.  pixel
	@ 009 + ((nX-1) * 10)   ,015 say iif((nY += 1) == nY, aCores[nY][2] + iif(nY == Len(aCores), iif((nY := 0) == nY,"",""),""),"")     of oDlg1                                  pixel
	@ 015                   ,100 button oButton1 prompt "&Fechar" 	                                                                    of oDlg1 size 050,020                     pixel ACTION(oDlg1:End())
next nX
activate msdialog oDlg1 centered
return .T.
