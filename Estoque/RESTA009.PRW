#include "totvs.ch"
#include "protheus.ch"
#INCLUDE "RWMAKE.CH"
#Include "topconn.ch"
#Include "tbiconn.ch"
#include "protdef.ch"
/*/{Protheus.doc} RESTA009
FunçReturnão para importação das tabelas referente a saldos inventarios dos produtos.
@author Livia Della Corte- ALLSS
@since 04/03/2023
@version 1.0
User Function RESTA009()

/*/
User Function RESTA009()


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
Private oARGENC001 := ARGENC001():NEW()

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
    cRet:= oARGENC001:SaldoLOTE(_cTabela,aCampos,aDados,cDir)
    aAdd(aRet,{ i, _cTabela,cRet} )

//next

FT_FUSE()

Return(aRet)



/*/{Protheus.doc} ARGENC001
    Classe para importação de dados mestre.
    @author Livia Della Corte
    @since 04/03/2023
    @version 1.0
    /*/
Class ARGENC001    
    Method New() CONSTRUCTOR
    Method MontarDados()
    Method SaldoLOTE()   
EndClass



/*/{Protheus.doc} New
    Metodo construtor
    @author Livia Della Corte
    @since 04/03/2023
    @version 1.0
    /*/
Method New() class ARGENC001
Return


/*/{Protheus.doc} MontarDados
    Metodo para montar dados para importacao
    @author Livia Della Corte
    @since 04/03/2023
    @version 1.0
    /*/
/*
Method MontarDados(_cTabela,aCampos,aDados,_nPosIt) class ARGENC001
Local j       := 0
Local _aInfo  := {}

_cAliasSX3 := "SX3_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
dbSelectArea(_cAliasSX3)
(_cAliasSX3)->(dbSetOrder(2))
        
    For j:=1 to Len(aCampos[1])
        If Empty(_aInfo)
            aAdd(_aInfo, {aCampos[1][1], Alltrim((aDados[1])) , nil})
            //aAdd(_aInfo, {aCampos[1][1], "0001" , nil})
        EndIf
        if (_cAliasSX3)->(dbSeek(ALLTRIM(aCampos[1][j]))) .and. !empty(aDados[j])
            DO CASE
                CASE (_cAliasSX3)->X3_TIPO == "N"
                    aAdd(_aInfo, {aCampos[1][j], VAL(aDados[j]) , nil})
                CASE (_cAliasSX3)->X3_TIPO == "D"
                    aAdd(_aInfo, {aCampos[1][j], CTOD(aDados[j]) , nil})
                OTHERWISE
                    aAdd(_aInfo, {aCampos[1][j], substr(alltrim(aDados[j]),1,(_cAliasSX3)->X3_TAMANHO), nil})
            END CASE
        endif
    _nPosIt++
    Next j

Return(_aInfo)
*/

/*/{Protheus.doc} SaldoLOTE
    Metodo para importacao do saldo inicial
    @author Livia Della Corte
    @since 04/03/2023
    @version 1.0
    /*/
Method SaldoLOTE(_cTabela,aCampos,aDados,_nItem) class ARGENC001
Local _nY
//Local aLogAuto := {}
//Local cArq :=""
Local cLogTxt:= "importado"
//Local nAux := 0
//Local aAuto := {}
//Local aVetor := {}
//Local aLinha := {}
Local _nQtdS := 0
Local _cEnd := ""
Private lMsErroAuto := .F.  
Private lAutoErrNoFile:= .T.


    for _nY := 1 to Len(aDados) 

        cNumSeq := ProxNum()
        //Origem 
        SB1->(DbSeek(xFilial("SB1")+PadR(aDados[_nY][1], tamsx3('D3_COD') [1])))
        
            dbSelectArea("CBJ")
            CBJ->(dbSetOrder(1))
            if CBJ->(dbSeek(FwFilial("CBJ") + PadR(aDados[_nY][1], tamsx3('D3_COD') [1]) + "01")) //CBJ_FILIAL+CBJ_CODPRO+CBJ_ARMAZ+CBJ_ENDERE
                _cEnd := CBJ->CBJ_ENDERE
            endif
            _nQtdS := Val(aDados[_nY][5])/SB1->B1_CONV

            dbSelectArea("SD3")
            RecLock('SD3', .T.) //-- Origem
				SD3->D3_FILIAL  := xFilial('SD3')
				SD3->D3_COD     := SB1->B1_COD 
				SD3->D3_QUANT   := Val(aDados[_nY][5])
				SD3->D3_CF      := 'RE4'
				SD3->D3_CHAVE   := 'E0'
				SD3->D3_LOCAL   := "01"
				SD3->D3_DOC     := "000240101"
				SD3->D3_EMISSAO := dDataBase
				SD3->D3_UM      := SB1->B1_UM
				SD3->D3_GRUPO   := SB1->B1_GRUPO
				SD3->D3_NUMSEQ  := cNumSeq
				SD3->D3_QTSEGUM := _nQtdS
				SD3->D3_SEGUM   := SB1->B1_SEGUM
				SD3->D3_TM      := '999'
				SD3->D3_TIPO    := SB1->B1_TIPO
				SD3->D3_CONTA   := SB1->B1_CONTA
				SD3->D3_USUARIO := "diego.rodrigues"
				SD3->D3_LOTECTL := "UNICO"
				SD3->D3_NUMLOTE := ""
				SD3->D3_DTVALID := Ctod(aDados[_nY][4])
				SD3->D3_POTENCI := 0
				SD3->D3_LOCALIZ := _cEnd
				SD3->D3_NUMSERI := ""
            MsUnlock()

            dbSelectArea("SD5")
            RecLock("SD5",.T.)
                SD5->D5_FILIAL  := xFilial('SD5')
                SD5->D5_PRODUTO := SB1->B1_COD 
                SD5->D5_LOCAL   := "01"
                SD5->D5_DOC     := "000240101"
                SD5->D5_DATA    := dDataBase
                SD5->D5_ORIGLAN := "999"
                SD5->D5_QUANT   := Val(aDados[_nY][5])
                SD5->D5_LOTECTL := "UNICO"
                SD5->D5_DTVALID := Ctod(aDados[_nY][4])
                SD5->D5_QTSEGUM := _nQtdS
                SD5->D5_POTENCI := 0
                SD5->D5_NUMSEQ  := cNumSeq
            MsUnlock()
            
            
            dbSelectArea("SDB")
            RecLock("SDB",.T.)
                SDB->DB_FILIAL  := xFilial('SDB')
                SDB->DB_ITEM    := "0001"
                SDB->DB_PRODUTO := SB1->B1_COD 
                SDB->DB_LOCAL   := "01"
                SDB->DB_LOCALIZ := _cEnd
                SDB->DB_DOC     := "000150000"
                SDB->DB_TM      := "999"
                SDB->DB_ORIGEM := "SD3"
                SDB->DB_QUANT   := Val(aDados[_nY][5])
                SDB->DB_DATA    := dDataBase
                SDB->DB_LOTECTL := "UNICO"
                SDB->DB_NUMSEQ  := cNumSeq
                SDB->DB_QTSEGUM := _nQtdS
                SDB->DB_SERVIC := "999"
                SDB->DB_ATIVID := "ZZZ"
                SDB->DB_HRINI  := Time()
                SDB->DB_ATUEST := "S"
                SDB->DB_STATUS := "M"
                SDB->DB_ORDATIV := "ZZ"
            MsUnlock() //Fim Origem
            

            RecLock('SD3', .T.) //-- Destino
				SD3->D3_FILIAL  := xFilial('SD3')
				SD3->D3_COD     := SB1->B1_COD 
				SD3->D3_QUANT   := Val(aDados[_nY][5])
				SD3->D3_CF      := 'DE4'
				SD3->D3_CHAVE   := 'E9'
				SD3->D3_LOCAL   := "01"
				SD3->D3_DOC     := "000240101"
				SD3->D3_EMISSAO := dDataBase
				SD3->D3_UM      := SB1->B1_UM
				SD3->D3_GRUPO   := SB1->B1_GRUPO
				SD3->D3_NUMSEQ  := cNumSeq
				SD3->D3_QTSEGUM := _nQtdS
				SD3->D3_SEGUM   := SB1->B1_SEGUM
				SD3->D3_TM      := '499'
				SD3->D3_TIPO    := SB1->B1_TIPO
				SD3->D3_CONTA   := SB1->B1_CONTA
				SD3->D3_USUARIO := "diego.rodrigues"
				SD3->D3_LOTECTL := aDados[_nY][3]
				SD3->D3_NUMLOTE := ""
				SD3->D3_DTVALID := Ctod(aDados[_nY][4])
				SD3->D3_POTENCI := 0
				SD3->D3_LOCALIZ := _cEnd
				SD3->D3_NUMSERI := ""
            MsUnlock()

            RecLock("SD5",.T.)
                SD5->D5_FILIAL  := xFilial('SD5')
                SD5->D5_PRODUTO := SB1->B1_COD 
                SD5->D5_LOCAL   := "01"
                SD5->D5_DOC     := "000240101"
                SD5->D5_DATA    := dDataBase
                SD5->D5_ORIGLAN := "499"
                SD5->D5_QUANT   := Val(aDados[_nY][5])
                SD5->D5_LOTECTL := aDados[_nY][3]
                SD5->D5_DTVALID := Ctod(aDados[_nY][4])
                SD5->D5_QTSEGUM := _nQtdS
                SD5->D5_POTENCI := 0
                SD5->D5_NUMSEQ  := cNumSeq
            MsUnlock()
            
            RecLock("SDB",.T.)
                SDB->DB_FILIAL  := xFilial('SDB')
                SDB->DB_ITEM    := "0001"
                SDB->DB_PRODUTO := SB1->B1_COD 
                SDB->DB_LOCAL   := "01"
                SDB->DB_LOCALIZ := _cEnd
                SDB->DB_DOC     := "000150000"
                SDB->DB_TM      := "499"
                SDB->DB_ORIGEM := "SD3"
                SDB->DB_QUANT   := Val(aDados[_nY][5])
                SDB->DB_DATA    := dDataBase
                SDB->DB_LOTECTL := aDados[_nY][3]
                SDB->DB_NUMSEQ  := cNumSeq
                SDB->DB_TIPO    := "M"
                SDB->DB_QTSEGUM := _nQtdS
                SDB->DB_SERVIC := "499"
                SDB->DB_ATIVID := "ZZZ"
                SDB->DB_HRINI  := Time()
                SDB->DB_ATUEST := "S"
                SDB->DB_STATUS := "M"
                SDB->DB_ORDATIV := "ZZ"
            MsUnlock() //Fim Destino
            
    Next _nY

/*
aVetor := ::MontarDados(_cTabela,aCampos,aDados,_nItem)
_cDocSD3 := GetSxeNum("SD3","D3_DOC")
aadd(aAuto,{_cDocSD3,dDataBase})  //Cabecalho
aAdd(aAuto,aVetor) //Linhas

MSExecAuto({|x,y| Mata261(x,y)},aAuto,3)
*/

 //Cabecalho a Incluir
/*   _cDocSD3 := GetSxeNum("SD3","D3_DOC")
    aadd(aAuto,{"TRFLOTE", dDataBase}) //Cabecalho

    //Itens a Incluir 
    aItem  := {}

    for _nY := 1 to Len(aDados)

        aLinha := {}
        
        //Origem 
        SB1->(DbSeek(xFilial("SB1")+PadR(aDados[_nY][1], tamsx3('D3_COD') [1])))
        
        _nQtdS := Val(aDados[_nY][5])/SB1->B1_CONV
        
        aadd(aLinha,{"ITEM"       , StrZero(_nY,3)         ,Nil})
        aadd(aLinha,{"D3_COD"     , SB1->B1_COD  , Nil}) //Cod Produto origem 
        aadd(aLinha,{"D3_DESCRI"  , SB1->B1_DESC , Nil}) //descr produto origem 
        aadd(aLinha,{"D3_UM"      , SB1->B1_UM   , Nil}) //unidade medida origem 
        aadd(aLinha,{"D3_LOCAL"   ,"01", Nil}) //armazem origem 
        aadd(aLinha,{"D3_LOCALIZ" , _cEnd,Nil}) //Informar endereço origem
        
        //Destino 
        aadd(aLinha,{"D3_COD"     , SB1->B1_COD , Nil}) //cod produto destino 
        aadd(aLinha,{"D3_DESCRI"  , SB1->B1_DESC, Nil}) //descr produto destino 
        aadd(aLinha,{"D3_UM"      , SB1->B1_UM  , Nil}) //unidade medida destino 
        aadd(aLinha,{"D3_LOCAL"   , "01", Nil}) //armazem destino 
        aadd(aLinha,{"D3_LOCALIZ" , _cEnd,Nil}) //Informar endereço destino

        aadd(aLinha,{"D3_NUMSERI", "", Nil}) //Numero serie
        aadd(aLinha,{"D3_LOTECTL", aDados[_nY][3], Nil}) //Lote Origem
        aadd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote origem
        aadd(aLinha,{"D3_DTVALID", Ctod(aDados[_nY][4]), Nil}) //data validade 
        aadd(aLinha,{"D3_POTENCI", 0 , Nil}) // Potencia
        aadd(aLinha,{"D3_QUANT"  ,Val(aDados[_nY][5]), Nil}) //Quantidade
        aadd(aLinha,{"D3_QTSEGUM", _nQtdS , Nil}) //Seg unidade medida
        aadd(aLinha,{"D3_ESTORNO", "", Nil}) //Estorno 
        aadd(aLinha,{"D3_NUMSEQ" , "", Nil}) // Numero sequencia D3_NUMSEQ

        aadd(aLinha,{"D3_LOTECTL", aDados[_nY][3], Nil}) //Lote destino
        aadd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote destino 
        aadd(aLinha,{"D3_DTVALID", Ctod(aDados[_nY][22]), Nil}) //validade lote destino
        aadd(aLinha,{"D3_ITEMGRD", "", Nil}) //Item Grade

        aadd(aLinha,{"D3_CODLAN" , "", Nil}) //cat83 prod origem
        aadd(aLinha,{"D3_CODLAN" , "", Nil}) //cat83 prod destino 
        aAdd(aAuto,aLinha)
    Next _nY

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
EndIf
*/
Return(cLogTxt)
