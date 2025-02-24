#include "totvs.ch"
#include "protheus.ch"
#INCLUDE "RWMAKE.CH"
#Include "topconn.ch"
#Include "tbiconn.ch"
#include "protdef.ch"
/*/{Protheus.doc} RESTA012
FunçReturnão para importação das tabelas. e bloqueio de lotes
@author Diego Rodrigues - ALLSS
@since 10/08/2023
@version 1.0
User Function RESTA012()
/*/
User Function RESTA012()


Local aFiles    := {}
Local nX        := 0
Local nCount    := 0
Local _cTabela  := ""
Local _cArquivo := ""
local alog:={}
Local _x := 0

Local oFWMsExcel
Local oExcel
Private cPasta := SUPERGETMV( "cPasLote", .f., "C:\IMPARCOLOR\" )
Private cArquivo    := cPasta + "ARQUIVO_LOG_"+DTOS(Date())+"_HORA_"+StrTran(Time(),":","")+".xls"


If !ExistDir(cPasta)
	LjDirect(cPasta,.T.)
    msgstop("Salvar arquivos para importação em: "+ cPasta + ". Os arquivos devem estar nomeados, como por exemplo: SA1.CVS " )
else

    aFiles := Directory(cPasta +"*.CSV", "D")
    nCount := Len( aFiles )

    IF MSGYESNO( "Deseja realmente importar os dados?" + chr(10) + chr(13) +;
    "Os arquivos devem estar nomeados como por exemplo SA1.CVS.", "[RESTA009_01] - Atenção" )
        For nX := 1 to nCount
            _cTAbela  := SUBSTR(ALLTRIM(aFiles[nX,1]), 1, AT( ".", ALLTRIM(aFiles[nX,1]))-1 )
            _cArquivo := ALLTRIM(aFiles[nX,1]) 
            Processa( {|| alog:= ARGENA01P(_cTabela,_cArquivo) }, "Aguarde...", "Importando arquivo..." + _cTAbela ,.F.)  
        Next

        oExcel    := FWMSEXCEL():New()
        oExcel:AddworkSheet("LOG_IMPORTACAO")
        oExcel:AddTable ("LOG_IMPORTACAO","LOG_IMPORTACAO")
        oExcel:AddColumn("LOG_IMPORTACAO","LOG_IMPORTACAO","LINHA",1,1)
        oExcel:AddColumn("LOG_IMPORTACAO","LOG_IMPORTACAO","TABELA",1,1)
        oExcel:AddColumn("LOG_IMPORTACAO","LOG_IMPORTACAO","LOG",1,1)
        

        For _x := 1 To Len(aLog)
            oExcel:AddRow("LOG_IMPORTACAO","LOG_IMPORTACAO",{;
                        alog[_x][1],;
                        alog[_x][2],;
                        alog[_x][3]})
        Next
         //Ativando o arquivo e gerando o xml
        oExcel:Activate()
        oExcel:GetXMLFile(cArquivo)
        oExcel:DeActivate()	

    ENDIF
endIf
Return

/*/{Protheus.doc} ARGENA01P
    Processa a importacao do arquivo CSV
    @author Diego Rodrigues- ALLSS
    @since 10/08/2023
    @version 1.0
    @see http://www.allss.com.br
    /*/
Static Function ARGENA01P(_cTabela,_cArquivo)
Local cArq    := _cArquivo
Local cLinha  := ""
Local lPrim   := .T.
Local aCampos := {}
Local aDados  := {}
Local cRet:= ""
Local aRet:={}
Local i := 1

Private aErro := {}
Private cDir    := cPasta
Private oIMPBLQ001:= IMPBLQ001():NEW()

If !File(cDir+cArq)
    MsgStop("O arquivo " +cDir+cArq + " não foi encontrado. A importação será abortada!","[ARGENA01P] - ATENCAO")
    Return
EndIf

FT_FUSE(cDir+cArq)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()
While !FT_FEOF()

    IncProc("Lendo arquivo texto..." + _cArquivo)

    cLinha := FT_FREADLN()

    If lPrim
        AADD(aCampos,Separa(cLinha,";",.T.))         
        lPrim := .F.
    Else
        AADD(aDados,Separa(cLinha,";",.T.))
    EndIf

    FT_FSKIP()
EndDo

ProcRegua(Len(aDados))

//For i := 1 to Len(aDados)

    IncProc("Importando...")
    cRet:= oIMPBLQ001:BlqLote(_cTabela,aCampos,aDados,cDir)
    aAdd(aRet,{ i, _cTabela,cRet} )

//next

FT_FUSE()

Return(aRet)



/*/{Protheus.doc} IMPBLQ001
    Classe para importação de dados mestre.
    @author Diego Rodrigues
    @since 10/08/2023
    @version 1.0
    /*/
Class IMPBLQ001   
    Method New() CONSTRUCTOR
    Method BlqLote()   
EndClass



/*/{Protheus.doc} New
    Metodo construtor
    @author Diego Rodrigues
    @since 10/08/2023
    @version 1.0
    /*/
Method New() class IMPBLQ001
Return


/*/{Protheus.doc} BlqLote
    Metodo para importacao do saldo inicial
    @author Diego Rodrigues
    @since 10/08/2023
    @version 1.0
    /*/
Method BlqLote(_cTabela,aCampos,aDados,_nItem) class IMPBLQ001
Local nAux
Local _nY
Local aLogAuto := {}
Local cArq :=""
Local cLogTxt:= "importado"
Local _aVetor := {}
Local _nQtdS := 0
//Local _cEnd := ""
Private lMsErroAuto := .F.  
Private lAutoErrNoFile:= .T.


                for _nY := 1 to Len(aDados)
                        
                        //Origem 
                        SB1->(DbSeek(xFilial("SB1")+PadR(aDados[_nY][2], tamsx3('D3_COD') [1])))
                        
                        _nQtdS := Val(aDados[_nY][5])/SB1->B1_CONV
                         _aVetor := {;
                                    {"DD_DOC"	 ,aDados[_nY][1] ,NIL},;
                                    {"DD_PRODUTO",aDados[_nY][2] ,NIL},;
                                    {"DD_LOCAL"  ,aDados[_nY][4] ,NIL},;
                                    {"DD_LOTECTL",aDados[_nY][5] ,NIL},;
                                    {"DD_QUANT"  ,Val(aDados[_nY][6]) ,NIL},;
                                    {"DD_MOTIVO" ,"ND"  ,NIL}}         
                 MSExecAuto({|x, y| mata275(x, y)},_aVetor, 3)

                //Se houve erro, mostra mensagem
                If lMsErroAuto 
                    aLogAuto	:= {}
                    cLogTxt	:= ""
                    
                    //Pegando log do ExecAuto
                    aLogAuto := GetAutoGRLog()
                    
                    //Percorrendo o Log
                    For nAux:=1 To Len(aLogAuto)
                        cLogTxt += StrTran(StrTran(StrTran(aLogAuto[nAux],">",""),"<",""),";",",") + ";"
                    Next
                cPath := cPasta+"\ERRO\"
                cArq := DTOS(dDataBase)+"_"+StrTran(Time(),":","")+"_"+_cTabela+".txt"
                MostraErro(cPath, cArq)
                EndIf


             Next _nY

                
                
Return(cLogTxt)
