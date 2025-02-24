#include 'protheus.ch'
#include "tbiconn.ch"
/*/{Protheus.doc} ANFEA001
    @description Rotina para importação da NF-e.
    @author Anderson Coelho (ALLSS)
    @since 20/12/2019
    @version 1.0
    @obs 
	    //Configuração appserver.ini
	    [ONSTART]
	    JOBS=ANFEA001_9901
	    REFRESHRATE=120
	
	    [ANFEA001_9901] 
	    MAIN=U_ANFEA001
	    ENVIRONMENT=ENVIRONMENT
	    nParms=2
	    parm1=99
	    parm2=01
    @see https://allss.com.br
/*/
user function ANFEA001(_cEmp,_cFilial)
	private _cRotina := "ANFEA001"
	default _cEmp    := ""
	default _cFilial := ""

	CONOUT("******************** START "+_cRotina+" ********************")
		if type("cNumEmp")=="C" //Verifico se a rotina nao está sendo executada por JOB JOBA
			MsgRun("Consultando CT-e disponiveis... ","Aguarde",{|| ANFEA01P() })
		else //Rotina sendo executada por JOB JOBA
			CONOUT("Empresa: " + _cEmp + " Filial: " + _cFilial)
			PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFilial MODULO "COM"
				//PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "COM"
				OpenSM0() //Abrir Tabela SM0 (Empresa/Filial)
				dbSelectArea("SM0") //Abro a SM0
				CONOUT("CNPJ: " + SM0->M0_CGC)
				ANFEA01P() //Executa o processamento da consulta aos CT-es
			RESET ENVIRONMENT
		endif
	CONOUT("******************** FINISH "+_cRotina+" ********************")
return
/*/{Protheus.doc} ANFEA001
    @description Rotina para processar as consultas para importação do CT-e.
    @author Anderson Coelho (ALLSS)
    @since  20/12/2019
    @version 1.0
    @see https://allss.com.br
    /*/
static function ANFEA01P()
	local oANFEC001 := NIL
	local _cNSU     := ""
	local _cNSUANT  := ""
	local _aNSU     := {}

    oANFEC001       := ANFEC001():NEW()
    _cNSU           := oANFEC001:UltimoNSU()

    AADD(_aNSU,{_cNSU,0})
    while !empty(_cNSU)
        _cNSUANT := IIF(ALLTRIM(_aNSU[1][1]) == "YYYYYYYYYYYYYYY",oANFEC001:UltimoNSU(),_aNSU[1][1])
        _aNSU    := oANFEC001:ConsultarNFE(_cNSU)
        DO CASE
            CASE EMPTY(_aNSU[1][1]) .AND. ALLTRIM(_aNSU[1][1]) <> "XXXXXXXXXXXXXXX" .AND. ALLTRIM(_aNSU[1][1]) <> "YYYYYYYYYYYYYYY"
                MsgRun("Sleep... " + TIME(),"Aguarde",{|| SLEEP(300000) })  
                _cNSU := _cNSUANT
            CASE ALLTRIM(_aNSU[1][1]) == "XXXXXXXXXXXXXXX"
                _cNSU := ""
            CASE ALLTRIM(_aNSU[1][1]) == "YYYYYYYYYYYYYYY"
                _cNSU := STRZERO(VAL(_cNSUANT) + (_aNSU[1][2] + 1) ,15)
        END CASE
    enddo
    MsgInfo("Consulta CT-es finalizada com sucesso!","["+_cRotina+"_FIM] - Aviso")
return 