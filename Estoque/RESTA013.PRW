#include "totvs.ch"
#include "protheus.ch"
#INCLUDE "RWMAKE.CH"
#Include "topconn.ch"
#Include "tbiconn.ch"
#include "protdef.ch"
/*/{Protheus.doc} RESTA013
FunÃ§ReturnÃ£o para importaÃ§Ã£o da tabela e ajuste de estoque de acordo com as contagens ciclicas.
@author Diego Rodrigues Pereira - ALLSS
@since 24/10/2023
@version 1.0
User Function RESTA013()

/*/
User Function RESTA013()


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
    "Os arquivos devem estar nomeados como por exemplo SA1.CVS.", "[RESTA013_01] - Atenção" )
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
Private oIMPTABC001 := IMPTABC001():NEW()

If !File(cDir+cArq)
    MsgStop("O arquivo " +cDir+cArq + " não foi encontrado. A importaçãoo será abortada!","[ARGENA01P] - ATENCAO")
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
    cRet:= oIMPTABC001:SaldoLOTE(_cTabela,aCampos,aDados,cDir)
    aAdd(aRet,{ i, _cTabela,cRet} )

//next

FT_FUSE()

Return(aRet)



/*/{Protheus.doc} IMPTABC001
    Classe para importaÃ§Ã£o de dados mestre.
    @author Livia Della Corte
    @since 04/03/2023
    @version 1.0
    /*/
Class IMPTABC001    
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
Method New() class IMPTABC001
Return

/*/{Protheus.doc} SaldoLOTE
    Metodo para importacao do saldo inicial
    @author Livia Della Corte
    @since 04/03/2023
    @version 1.0
    /*/
Method SaldoLOTE(_cTabela,aCampos,aDados,_nItem) class IMPTABC001
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
            _nQtdS := Val(aDados[_nY][7])/SB1->B1_CONV
        If  Val(aDados[_nY][7]) > 0
            dbSelectArea("SD3")
            RecLock('SD3', .T.) //-- Origem
				SD3->D3_FILIAL  := xFilial('SD3')
				SD3->D3_COD     := SB1->B1_COD 
				SD3->D3_QUANT   := Val(aDados[_nY][7])
				SD3->D3_CF      := 'RE0'
				SD3->D3_CHAVE   := 'E0'
				SD3->D3_LOCAL   := "01"
				SD3->D3_DOC     := "000150000"
				SD3->D3_EMISSAO := dDataBase
				SD3->D3_UM      := SB1->B1_UM
				SD3->D3_GRUPO   := SB1->B1_GRUPO
				SD3->D3_NUMSEQ  := cNumSeq
				SD3->D3_QTSEGUM := _nQtdS
				SD3->D3_SEGUM   := SB1->B1_SEGUM
				SD3->D3_TM      := '501'
				SD3->D3_TIPO    := SB1->B1_TIPO
				SD3->D3_CONTA   := SB1->B1_CONTA
				SD3->D3_USUARIO := "diego.rodrigues"
				SD3->D3_LOTECTL := aDados[_nY][3]
				SD3->D3_NUMLOTE := ""
				SD3->D3_DTVALID := Ctod(aDados[_nY][4])
                SD3->D3_OBSERVA := 'INVENT ROTATIVO 09/02/2024'
				SD3->D3_POTENCI := 0
				SD3->D3_LOCALIZ := _cEnd
				SD3->D3_NUMSERI := ""
            MsUnlock()

            dbSelectArea("SD5")
            RecLock("SD5",.T.)
                SD5->D5_FILIAL  := xFilial('SD5')
                SD5->D5_PRODUTO := SB1->B1_COD 
                SD5->D5_LOCAL   := "01"
                SD5->D5_DOC     := "000150000"
                SD5->D5_DATA    := dDataBase
                SD5->D5_ORIGLAN := "501"
                SD5->D5_QUANT   := Val(aDados[_nY][7])
                SD5->D5_LOTECTL := aDados[_nY][3]
                SD5->D5_DTVALID := Ctod(aDados[_nY][4])
                SD5->D5_QTSEGUM := _nQtdS
                SD5->D5_POTENCI := 0
                SD5->D5_NUMSEQ  := cNumSeq
            MsUnlock()
            
            If SB1->B1_TIPO == 'PA'
            dbSelectArea("SDB")
            RecLock("SDB",.T.)
                SDB->DB_FILIAL  := xFilial('SDB')
                SDB->DB_ITEM    := "0001"
                SDB->DB_PRODUTO := SB1->B1_COD 
                SDB->DB_LOCAL   := "01"
                SDB->DB_LOCALIZ := _cEnd
                SDB->DB_DOC     := "000150000"
                SDB->DB_TM      := "501"
                SDB->DB_ORIGEM := "SD3"
                SDB->DB_QUANT   := Val(aDados[_nY][7])
                SDB->DB_DATA    := dDataBase
                SDB->DB_LOTECTL := aDados[_nY][3]
                SDB->DB_NUMSEQ  := cNumSeq
                SDB->DB_QTSEGUM := _nQtdS
                SDB->DB_SERVIC := "999"
                SDB->DB_ATIVID := "ZZZ"
                SDB->DB_HRINI  := Time()
                SDB->DB_ATUEST := "S"
                SDB->DB_STATUS := "M"
                SDB->DB_ORDATIV := "ZZ"
            MsUnlock() //Fim Origem
            Endif
        ElseIf  Val(aDados[_nY][7]) < 0
            RecLock('SD3', .T.) //-- Destino
				SD3->D3_FILIAL  := xFilial('SD3')
				SD3->D3_COD     := SB1->B1_COD 
				SD3->D3_QUANT   := (Val(aDados[_nY][7])*-1)
				SD3->D3_CF      := 'DE0'
				SD3->D3_CHAVE   := 'E0'
				SD3->D3_LOCAL   := "01"
				SD3->D3_DOC     := "000150000"
				SD3->D3_EMISSAO := dDataBase
				SD3->D3_UM      := SB1->B1_UM
				SD3->D3_GRUPO   := SB1->B1_GRUPO
				SD3->D3_NUMSEQ  := cNumSeq
				SD3->D3_QTSEGUM := (_nQtdS*-1)
				SD3->D3_SEGUM   := SB1->B1_SEGUM
				SD3->D3_TM      := '004'
				SD3->D3_TIPO    := SB1->B1_TIPO
				SD3->D3_CONTA   := SB1->B1_CONTA
				SD3->D3_USUARIO := "diego.rodrigues"
				SD3->D3_LOTECTL := aDados[_nY][3]
				SD3->D3_NUMLOTE := ""
				SD3->D3_DTVALID := Ctod(aDados[_nY][4])
                SD3->D3_OBSERVA := 'INVENT ROTATIVO 09/02/2024'
				SD3->D3_POTENCI := 0
				SD3->D3_LOCALIZ := _cEnd
				SD3->D3_NUMSERI := ""
            MsUnlock()

            RecLock("SD5",.T.)
                SD5->D5_FILIAL  := xFilial('SD5')
                SD5->D5_PRODUTO := SB1->B1_COD 
                SD5->D5_LOCAL   := "01"
                SD5->D5_DOC     := "000150000"
                SD5->D5_DATA    := dDataBase
                SD5->D5_ORIGLAN := "004"
                SD5->D5_QUANT   := (Val(aDados[_nY][7])*-1)
                SD5->D5_LOTECTL := aDados[_nY][3]
                SD5->D5_DTVALID := Ctod(aDados[_nY][4])
                SD5->D5_QTSEGUM := (_nQtdS*-1)
                SD5->D5_POTENCI := 0
                SD5->D5_NUMSEQ  := cNumSeq
            MsUnlock()

            If SB1->B1_TIPO == 'PA'
            RecLock("SDB",.T.)
                SDB->DB_FILIAL  := xFilial('SDB')
                SDB->DB_ITEM    := "0001"
                SDB->DB_PRODUTO := SB1->B1_COD 
                SDB->DB_LOCAL   := "01"
                SDB->DB_LOCALIZ := _cEnd
                SDB->DB_DOC     := "000150000"
                SDB->DB_TM      := "004"
                SDB->DB_ORIGEM := "SD3"
                SDB->DB_QUANT   := (Val(aDados[_nY][7])*-1)
                SDB->DB_DATA    := dDataBase
                SDB->DB_LOTECTL := aDados[_nY][3]
                SDB->DB_NUMSEQ  := cNumSeq
                SDB->DB_TIPO    := "M"
                SDB->DB_QTSEGUM := (_nQtdS*-1)
                SDB->DB_SERVIC := "499"
                SDB->DB_ATIVID := "ZZZ"
                SDB->DB_HRINI  := Time()
                SDB->DB_ATUEST := "S"
                SDB->DB_STATUS := "M"
                SDB->DB_ORDATIV := "ZZ"
            MsUnlock() //Fim Destino
            EndIf
        EndiF
    Next _nY

Return(cLogTxt)
