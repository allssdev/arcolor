#include "totvs.ch"
#include "protheus.ch"
#INCLUDE "RWMAKE.CH"
#Include "topconn.ch"
#Include "tbiconn.ch"
#include "protdef.ch"
/*/{Protheus.doc} RESTA011
FunçReturnão para importação das tabelas. e transferencia transferencia de endereço 
@author Diego Rodrigues - ALLSS
@since 10/08/2023
@version 1.0
User Function RESTA009()
@history - 10/08/2023 - Continuidade no desenvolvimento da rotina para transferencia de endereço 
/*/
User Function RESTA011()


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
    @author Livia Della Corte- ALLSS
    @since 04/03/2023
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
Private oIMPTRF001 := IMPTRF001():NEW()

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
    cRet:= oIMPTRF001:TransfLote(_cTabela,aCampos,aDados,cDir)
    aAdd(aRet,{ i, _cTabela,cRet} )

//next

FT_FUSE()

Return(aRet)



/*/{Protheus.doc} IMPTRF001
    Classe para importação de dados mestre.
    @author Livia Della Corte
    @since 04/03/2023
    @version 1.0
    /*/
Class IMPTRF001    
    Method New() CONSTRUCTOR
    Method MontarDados()
    Method TransfLote()   
EndClass



/*/{Protheus.doc} New
    Metodo construtor
    @author Livia Della Corte
    @since 04/03/2023
    @version 1.0
    /*/
Method New() class IMPTRF001
Return


/*/{Protheus.doc} TransfLote
    Metodo para importacao do saldo inicial
    @author Livia Della Corte
    @since 04/03/2023
    @version 1.0
    /*/
Method TransfLote(_cTabela,aCampos,aDados,_nItem) class IMPTRF001
Local nAux
Local _nY
Local aLogAuto := {}
Local cArq :=""
Local cLogTxt:= "importado"
Local aAuto := {}
Local aLinha := {}
Local _nQtdS := 0
//Local _cEnd := ""
Private lMsErroAuto := .F.  
Private lAutoErrNoFile:= .T.


            for _nY := 1 to Len(aDados)
                    aAuto := {}
                        //Cabecalho a Incluir
                    aadd(aAuto,{GetSxeNum("SD3","D3_DOC"),dDataBase}) //Cabecalho 

                    //Itens a Incluir 
                    aItem  := {}

                        aLinha := {}
                        cNumSeq := ProxNum()
                        //Origem 
                        SB1->(DbSeek(xFilial("SB1")+PadR(aDados[_nY][1], tamsx3('D3_COD') [1])))
                        
                        _nQtdS := Val(aDados[_nY][5])/SB1->B1_CONV
                        
                        aadd(aLinha,{"ITEM"       , "001",Nil})
                        aadd(aLinha,{"D3_COD"     , SB1->B1_COD  , Nil}) //Cod Produto origem 
                        aadd(aLinha,{"D3_DESCRI"  , SB1->B1_DESC , Nil}) //descr produto origem 
                        aadd(aLinha,{"D3_UM"      , SB1->B1_UM   , Nil}) //unidade medida origem 
                        aadd(aLinha,{"D3_LOCAL"   ,"01", Nil}) //armazem origem 
                        aadd(aLinha,{"D3_LOCALIZ" , aDados[_nY][6],Nil}) //Informar endereço origem
                        
                        //Destino 
                        aadd(aLinha,{"D3_COD"     , SB1->B1_COD , Nil}) //cod produto destino 
                        aadd(aLinha,{"D3_DESCRI"  , SB1->B1_DESC, Nil}) //descr produto destino 
                        aadd(aLinha,{"D3_UM"      , SB1->B1_UM  , Nil}) //unidade medida destino 
                        aadd(aLinha,{"D3_LOCAL"   , "01", Nil}) //armazem destino 
                        aadd(aLinha,{"D3_LOCALIZ" , aDados[_nY][7],Nil}) //Informar endereço destino

                        aadd(aLinha,{"D3_NUMSERI", "", Nil}) //Numero serie
                        aadd(aLinha,{"D3_LOTECTL", aDados[_nY][3], Nil}) //Lote Origem
                        aadd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote origem
                        aadd(aLinha,{"D3_DTVALID", Ctod(aDados[_nY][4]), Nil}) //data validade 
                        aadd(aLinha,{"D3_POTENCI", 0 , Nil}) // Potencia
                        aadd(aLinha,{"D3_QUANT"  ,Val(aDados[_nY][5]), Nil}) //Quantidade
                        aadd(aLinha,{"D3_QTSEGUM", _nQtdS , Nil}) //Seg unidade medida
                        aadd(aLinha,{"D3_ESTORNO", "", Nil}) //Estorno 
                        aadd(aLinha,{"D3_NUMSEQ" , cNumSeq, Nil}) // Numero sequencia D3_NUMSEQ

                        aadd(aLinha,{"D3_LOTECTL", aDados[_nY][3], Nil}) //Lote destino
                        aadd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote destino 
                        aadd(aLinha,{"D3_DTVALID", Ctod(aDados[_nY][4]), Nil}) //validade lote destino
                        aadd(aLinha,{"D3_ITEMGRD", "", Nil}) //Item Grade

                        aadd(aLinha,{"D3_CODLAN" , "", Nil}) //cat83 prod origem
                        aadd(aLinha,{"D3_CODLAN" , "", Nil}) //cat83 prod destino 
                        aAdd(aAuto,aLinha)

                MSExecAuto({|x,y| mata261(x,y)},aAuto,3)


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
                lMsErroAuto := .F.  
                EndIf
                    
                    
            Next _nY

              
                
Return(cLogTxt)
