#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'TOPCONN.CH'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"
#include "tbiconn.ch"

/*/{Protheus.doc} RESTA010
@description  Rotina para criação de saldos referente aos produtos do tipo MP/PI/EM
@author Diego Rodrigues Pereira(ALL System Solutions)
@since 03/05/2023
@version 1.0
@type function
@see https://allss.com.br
@history 03/05/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Adequação da rotina para importação de saldos referente a MP E EM
/*/          

USER function RESTA010()

local _cSB2TMP  := ""
//local _cUpd1    := ""
LOCAL cLoteCtl  := "202306"
local nPotencia := 0
local dMvUlmes  := ""
local dValid    := ""
Private cPerg   := "RESTA008"


If Select("SX3") == 0            // Verifico se está sendo chamada por Schedule
	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "EST" TABLES "SB2", "SB9", "SB8", "SBF", "SB1", "SBK", "SBJ", "SD5"
endIf


ValidPerg()
If Pergunte(cPerg,.T.)
	//Return
//EndIf


    _cSB2TMP :=GetNextAlias()
    dMvUlmes := SuperGetMV("MV_ULMES",,"20230331")
    dMovime  := ddatabase
    cLoteCtl := SuperGetMV("MV_XLOTEUN",,"UNICO")
    dValid  := dMvUlmes + 90
    
    if Select(_cSB2TMP) > 0
            (_cSB2TMP)->(dbCloseArea())
    endif
    
        BeginSql Alias _cSB2TMP
             SELECT SB2.B2_FILIAL ,   SB2.B2_COD , SB2.B2_LOCAL, ROUND(B2_QATU,6) B2_QATU
                    ,ROUND(B2_QTSEGUM,6) B2_QTSEGUM, B2_RESERVA, B2_RESERV2 , B2_QEMP, B2_QEMP2, B2_QEMPSA
                    , B9_QINI, B9_QISEGUM
            FROM SB1010  SB1 
            INNER JOIN SB2010 SB2 (NOLOCK) ON SB2.B2_FILIAL =  '01'		
                        AND SB2.B2_COD      =  SB1.B1_COD
                        AND SB1.D_E_L_E_T_ = '' 
                        AND SB1.B1_TIPO IN ('MP','EM','PI')
                        AND SB2.B2_QATU > 0
                        AND SB2.B2_LOCAL = '01'
            INNER JOIN  SB9010 SB9 (NOLOCK) ON  SB2.B2_COD = SB9.B9_COD AND SB9.D_E_L_E_T_ = '' 
                        AND B2_LOCAL =B9_LOCAL		
            WHERE SB2.B2_FILIAL        = '01' 
                AND SB1.D_E_L_E_T_ = ''
                AND B9_DATA =  %Exp:DTOS(dMvUlmes)%
                AND B1_COD  between   ''  and  'ZZZZZZZZZZZZZZZZZZZZZZZZ'
                AND B1_RASTRO = 'L'
            GROUP BY SB2.B2_FILIAL ,   SB2.B2_COD , SB2.B2_LOCAL, B2_QATU,
            B2_QTSEGUM, B2_RESERVA, B2_RESERV2 , B2_QEMP, B2_QEMP2, B2_QEMPSA
            , B9_QINI, B9_QISEGUM 	
        EndSql
        
        dbSelectArea(_cSB2TMP) 
        While !(_cSB2TMP)->(EOF()) 		    

            dbSelectArea("SD5")
            CNUMSEQ:= ProxNum()

            RecLock("SD5",.T.)
            Replace D5_FILIAL  with (_cSB2TMP)->B2_FILIAL,;
            D5_PRODUTO with (_cSB2TMP)->B2_COD,;
            D5_LOCAL   with (_cSB2TMP)->B2_LOCAL,;
            D5_DATA    with dMovime,;
            D5_ORIGLAN with "MAN",;
            D5_QUANT   with (_cSB2TMP)->B2_QATU,;	
            D5_LOTECTL with cLoteCtl,;
            D5_DTVALID with dValid,;
            D5_QTSEGUM With (_cSB2TMP)->B2_QTSEGUM,;
            D5_POTENCI With nPotencia,;
            D5_NUMSEQ  With CNUMSEQ
            MsUnlock()

            dbSelectArea("SB8")
            RecLock("SB8",.T.)
            Replace	B8_FILIAL  with xFilial("SB8"),;
            B8_PRODUTO with (_cSB2TMP)->B2_COD,;
            B8_LOCAL   with (_cSB2TMP)->B2_LOCAL,;
            B8_DATA    with dMovime,;
            B8_DTVALID with dValid,;
            B8_SALDO   with (_cSB2TMP)->B2_QATU,;
            B8_SALDO2  with (_cSB2TMP)->B2_QTSEGUM,;
            B8_EMPENHO with (_cSB2TMP)->B2_RESERVA,;
            B8_EMPENH2 with (_cSB2TMP)->B2_RESERV2,;
            B8_ORIGLAN with "MN",;
            B8_POTENCI with nPotencia,;
            B8_QTDORI  with (_cSB2TMP)->B9_QINI,;
            B8_QTDORI2 with (_cSB2TMP)->B9_QISEGUM,;
            B8_LOTECTL with cLoteCtl,;
            B8_DFABRIC with	dMvUlmes
            MsUnlock()		

            /*
            RecLock("SBJ",.T.)
            SBJ->BJ_FILIAL	:= (_cSB2TMP)->B2_FILIAL
            SBJ->BJ_COD		:= (_cSB2TMP)->B2_COD
            SBJ->BJ_LOCAL	:= (_cSB2TMP)->B2_LOCAL
            SBJ->BJ_DATA	:= dMvUlmes
            SBJ->BJ_LOTECTL	:= cLoteCtl
            SBJ->BJ_DTVALID	:= dValid
            SBJ->BJ_QINI	:= (_cSB2TMP)->B9_QINI
            SBJ->BJ_QISEGUM	:= (_cSB2TMP)->B9_QISEGUM
            SBJ->(MsUnLock())	
            */	
            (_cSB2TMP)->(dbSkip())

            //_cUpd1   := " UPDATE SBK010 SET BK_LOTECTL = '"+cLoteCtl+ "'  WHERE BK_DATA ='"+dtos(dMvUlmes)+"'AND  BK_COD ='"+ (_cSB2TMP)->B2_COD  + "'  AND BK_QINI > 0 and BK_LOTECTL ='';"
           // _cUpd1   += " UPDATE SBF010 SET BF_LOTECTL = '"+cLoteCtl+ "'  WHERE BF_PRODUTO	='"+ (_cSB2TMP)->B2_COD  + "' AND BF_QUANT >0 and BF_LOTECTL ='';"

           // TCSQLExec(_cUpd1)
        enddo
        
        if Select(_cSB2TMP) > 0
            (_cSB2TMP)->(dbCloseArea())
        endif
EndIf
return()




static function ValidPerg()
	local _sArea     := GetArea()
	local aRegs      := {}
	local _aTam      := {}
	local i          := 0
	local j          := 0
	local _cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()

	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	cPerg  := PADR(cPerg,len((_cAliasSX1)->X1_GRUPO))
	_aTam  := TamSx3("B1_COD"    )
	AADD(aRegs,{cPerg,"01","De Produto?"             ,"","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par01",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SB1"   ,"",""})
	AADD(aRegs,{cPerg,"02","Ao Produto?"             ,"","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","NaoVazio()","mv_par02",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SB1"   ,"",""})
	for i := 1 to len(aRegs)
		if !(_cAliasSX1)->(dbSeek(cPerg+aRegs[i,2]))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				for j := 1 to FCount()
					if j <= len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					else
						Exit
					endif
				next
			(_cAliasSX1)->(MsUnLock())
		endif
	next
	RestArea(_sArea)
return
