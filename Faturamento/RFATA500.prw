#include 'protheus.ch'
#include 'rwmake.ch'
#include 'topconn.ch'
#include 'olecont.ch'
#define STR_PULA CHR(13) + CHR(10)
/*/{Protheus.doc} RESTA006
Fun��o de usu�rio para corte na libera��o de pedidos de venda com base em arquivo ".csv".
@author Rodrigo Telecio (rodrigo.telecio@allss.com.br)
@since 08/12/2021
@version 1.00 (P12.1.25)
@type Function
@obs Sem observa��es
@see https://allss.com.br/
@history 08/12/2021, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Desenvolvimento da primeira vers�o do programa.
/*/ 
user function RFATA500()
private oLeTxt
private _cRotina := FunName()
@ 200,001 to 380,380 dialog oLeTxt TITLE OemToAnsi('Corte na libera��o de pedidos de venda')
@ 002,002 to 090,190
@ 010,003 Say '    Este programa atualizar� as informa��es na libera��o de pedidos         '
@ 018,003 Say '    de venda cortando quantidades liberadas de acordo com arquivo ".csv"    '
@ 026,003 Say '                                                                            '
@ 034,003 Say '    ATEN��O! AP�S AS LIBERA��ES, CONFERIR OS RESULTADOS                     '
@ 042,003 Say '    PROCESSADOS PELA ROTINA ANTES DE AVAN�AR NOS DEMAIS                     '
@ 050,003 Say '    PROCESSOS, PARA EVITAR RETRABALHOS E/OU DIVERG�NCIAS.                   '
@ 070,118 BMPBUTTON TYPE 01 ACTION Processa({|| ProcImport()},'Corte na libera��o de pedidos de venda','Processando, aguarde...',.F.)
@ 070,148 BMPBUTTON TYPE 02 ACTION Close(oLeTxt)
activate dialog oLeTxt centered
return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ProcImport  �Autor  �Rodrigo Telecio    � Data �  08/12/2021���
�������������������������������������������������������������������������͹��
���Desc.     � Escolha dos campos que ser�o atualizados                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                           			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static function ProcImport()
private oOK 		:= LoadBitmap(GetResources(),'br_verde')
private oNO 		:= LoadBitmap(GetResources(),'br_vermelho')
private aListAux    := {}
private aList		:= {}
private nX
private oDlg
aListAux            := {.T.,'C5_NUM'    ,FWX3Titulo('C5_NUM')      ,TamSX3('C5_NUM')[3]       ,TamSX3('C5_NUM')[1]   ,TamSX3('C5_NUM')[2]   }
AADD(aList, aListAux)
aListAux            := {.T.,'AEC_PERC'  ,FWX3Titulo('AEC_PERC')    ,TamSX3('AEC_PERC')[3]     ,TamSX3('AEC_PERC')[1] ,TamSX3('AEC_PERC')[2] }
AADD(aList, aListAux)
define msdialog oDlg from 000,000 to 520,600 pixel title 'Corte na libera��o de pedidos de venda - Necessidade de exist�ncia dos seguintes campos no arquivo:' 
define font oFont name 'Courier New' size 0, -12
oList               := TCBrowse():New(001,001,300,200,,{'','Campo','Descri��o','Tipo de dados','Tamanho','Decimais'},{20,50,60,30,30,30},oDlg,,,,,{||},,oFont,,,,,.F.,,.T.,,.F.,,,)
oList:SetArray(aList) 
oList:bLine         := {||{ If(aList[oList:nAt,01],oOK,oNO),aList[oList:nAt,02],aList[oList:nAt,03]}}
oList:bLDblClick    := {|| aList[oList:nAt][1] := !aList[oList:nAt][1],oList:DrawSelect() }
oBtn                := TButton():New(220,040,'&Efet. Lib. c/ Cortes' , oDlg,{|| ProcDados()}		,090,010,,,.F.,.T.,.F.,,.F.,,,.F.)
oBtn                := TButton():New(220,180,'&Legenda'	             , oDlg,{|| ExibeLegenda()}	    ,090,010,,,.F.,.T.,.F.,,.F.,,,.F.)
activate msdialog oDlg centered
return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ProcDados  �Autor  �Rodrigo Telecio     � Data �  08/12/2021���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o de processamento principal                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
    Aviso('TOTVS - ' + AllTrim(_cRotina) + ' - Aten��o','Nenhum campo foi selecionado para importa��o. Tente novamente!',{'&OK'},3,'Falha na sele��o dos campos')
	return .F.
endif
Processa({|| ImportaDad()},'Lendo arquivo ".csv"')
Close(oDlg)
return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImportaDad  �Autor  �Rodrigo Telecio    � Data �  08/12/2021���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o responsavel pela abertura do arquivo e grava��o dos ���
���          �dados                                                       ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static function ImportaDad()
local cFileOpen := ""
local cTitulo1  := "Selecione o arquivo"
local cExtens   := "Arquivo CSV | *.csv"
local cAliasAux := GetNextAlias()
local i         := 0
local aConteudo := {}
local nX        := 0
local aRet      := {}
local aCampos   := {}
local aProd     := {}
cFileOpen       := cGetFile(cExtens,cTitulo1,,,.T.)
_aStru          := {}
for i := 1 to Len(aList)
	if aList[i,01]
		AADD(_aStru,{aList[i,2]   ,aList[i,4]     ,aList[i,5]     ,aList[i,6]})
	endif	
next i
_cArq2          := CriaTrab(_aStru,.T.)
dbUseArea(.T.,,_cArq2,cAliasAux,.F.,.F.)
IndRegua(cAliasAux,_cArq2,"C5_NUM",,,"Criando arquivo temporario...")
oFile := FWFileReader():New(cFileOpen)
if !oFile:Open()
    Aviso('TOTVS - ' + AllTrim(_cRotina) + ' - Aten��o','Arquivo ' + AllTrim(cFileOpen) + ' n�o localizado. Tente novamente.',{'&OK'},3,'Falha de processamento')
    Close(oDlg)
    oFile:Close()
    return .F.
endif
oFile:SetBufferSize(65536)
lPrimer	        := .F.
nCont	        := 0
while oFile:HasLine()
	IncProc("Obtendo informa��es do arquivo...")
    aConteudo   := oFile:GetAllLines()
enddo
oFile:Close()
if Len(aConteudo) > 0
    IncProc("Montando arquivo tempor�rio...")
    for nX := 1 to Len(aConteudo)
        aProd       := {}
        aRet		:= StrTokArr2(aConteudo[nX],";",.T.)
        if !lPrimer
            if Len(aRet) > 0
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
            if ExistBlock("RFATA501")
                U_RFATA501(aRet[1],Round(Val(aRet[2]),0),2)
            else
                Aviso('TOTVS - ' + AllTrim(_cRotina) + ' - Aten��o','A fun��o "RFATA501" n�o foi aplicada no reposit�rio de objetos. Avise o administrador do sistema com esta mensagem para prosseguir com as devidas tratativas.',{"&Ok"},3,"Corte na libera��o de pedidos")
                exit
            endif
        endif
        nCont++  
    next nX
else
    Aviso('TOTVS - ' + AllTrim(_cRotina) + ' - Aten��o','N�o foi poss�vel obter as informa��es do arquivo indicado. Tente executar o processo novamente.',{'&OK'},3,'Falha de processamento')
endif
return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ExibeLegenda �Autor  �Rodrigo Telecio   � Data �  08/12/2021���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o responsavel pela exibi��o da legenda da tela	      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static function ExibeLegenda()
local nX            := 0
local nY 			:= 0
private aCores      := { 	{"br_verde"   ,"Atualizar o campo"  		},;
						    {"br_vermelho","N�o Atualizar o campo" 	    }}
private aBmp[Len(aCores)]	               		
private oVm 		:= LoadBitmap( GetResources(), "br_vermelho"	    )
private oVd 		:= LoadBitmap( GetResources(), "br_verde"   	    )
private oButton1	:= nil                
private cTitulo 	:= "Legenda - Atualiza��o por importa��o de dados"
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
