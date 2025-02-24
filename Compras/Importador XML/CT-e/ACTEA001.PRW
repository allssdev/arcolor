#include 'protheus.ch'
#include "tbiconn.ch"
#DEFINE _CRLF CHR(13) + CHR(10)
/*/{Protheus.doc} ACTEA001
    Rotina para importação do CT-e
    @type  Fernando Bombardi (ALLSS)
    @author Fernando Bombardi
    @since 20/12/2019
    @version 1.0
  /*/
  
 /*  
 //MV_IMPXML = .t.
 
 Configuração appserver.ini
    [ONSTART]
    JOBS=ACTEA001_0101
    REFRESHRATE=120

    [ACTEA001_0101] 
    MAIN=U_ACTEA001
    ENVIRONMENT=TOTVS_12_1_25_NODICDB_APOIO
    nParms=2
    parm1=01
    parm2=01
*/
  
User Function ACTEA001(_cEmp,_cFilial)
    Default _cEmp    := "01"
    Default _cFilial := "01"

    IF type("cNumEmp")=="C" //Verifico se a rotina nao está sendo executada por JOB 
        MsgRun("Consultando CT-e disponiveis... ","Aguarde",{|| ACTEA01P() })
    ELSE //Rotina sendo executada por JOB 
        PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFilial MODULO "COM"     
        OpenSM0() //Abrir Tabela SM0 (Empresa/Filial)
        dbSelectArea("SM0") 
        ACTEA01P() //Executa o processamento da consulta aos CT-es
    ENDIF

RETURN

/*/{Protheus.doc} ACTEA001
    Rotina para processar as consultas para importação do CT-e
    @type  Fernando Bombardi (ALLSS)
    @author Fernando Bombardi
    @since 20/12/2019
    @version 1.0
    /*/
Static Function ACTEA01P()
Local oACTEC001 := NIL
Local _cNSU     := ""
Local _cNSUANT  := ""
Local _aNSU     := {}
local nNx   	:= 1
local _clog		:= ""
local nHandle	:= ""
private cDirLog	  := SuperGetMV("MV_NGINN",.F.,"\XML\NGINN\")+'CTE\log.txt'

nHandle  := MemoRead( cDirLog ) 
if nHandle < "0"
   nHandle:=  FCREATE(cDirLog)
   fCLOSE(nHandle)
else 
	_clog:= MemoRead( cDirLog )
	fCLOSE(cDirLog) 
endif

oACTEC001 := ACTEC001():NEW()
_cNSU     := oACTEC001:UltimoNSU()

aADD(_aNSU,{_cNSU,0,""})
WHILE !EMPTY(_cNSU)        

    _cNSUANT := IIF(ALLTRIM(_aNSU[1][1]) == "YYYYYYYYYYYYYYY",oACTEC001:UltimoNSU(),_aNSU[1][1])
    AADD(_aNSU,{oACTEC001:ConsultarCTe(_cNSU),0})
    DO CASE
        CASE EMPTY(_aNSU[1][1]) .AND. ALLTRIM(_aNSU[1][1]) <> "XXXXXXXXXXXXXXX" .AND. ALLTRIM(_aNSU[1][1]) <> "YYYYYYYYYYYYYYY"              
            _cNSU := ""
            _clog:=  "[ERRO][DATA] " + cValtoChar(DATE()) + " [HORA] " +  cValtoChar(Time()) + ALLTRIM(_aNSU[1][3]) + _CRLF + _clog 
            _clog:=  "[INFO][DATA] " + cValtoChar(DATE()) + " [HORA] " +  cValtoChar(Time()) + " [CAPTDADOS] " + cvaltochar(nNx) +_CRLF + _clog
            MemoWrite(cDirLog,_clog)       
            return       //erro de consumo sair      
        CASE ALLTRIM(_aNSU[1][1]) == "XXXXXXXXXXXXXXX" 
           _cNSU := ""
           _clog:= "[ERRO][DATA] " + cValtoChar(DATE()) + " [HORA] " +  cValtoChar(Time()) + ALLTRIM(_aNSU[1][3]) + _CRLF + _clog   
           MemoWrite(cDirLog,_clog)  
           nNx++
           return    //ultima consulta retornou o ultimo documento emitido contra o CNPJ
        CASE ALLTRIM(_aNSU[1][1]) == "YYYYYYYYYYYYYYY"
           _cNSU := STRZERO(VAL(_cNSUANT) + (_aNSU[1][2] + 1) ,15)
           _clog:=  "[INFO][DATA] " + cValtoChar(DATE()) + " [HORA] " +  cValtoChar(Time()) + " [CAPTDADOS] " + cvaltochar(nNx) +_CRLF + _clog
           MemoWrite(cDirLog,_clog)
           nNx++    //seguir com a execução
        Otherwise        
           _clog:=  "[INFO][DATA] " + cValtoChar(DATE()) + " [HORA] " +  cValtoChar(Time()) + " [CAPTDADOS] " + cvaltochar(nNx) +_CRLF + _clog
           MemoWrite(cDirLog,_clog)
           return  //erro desconhecido sair da execução
        END CASE        
    ENDDO         
Return 