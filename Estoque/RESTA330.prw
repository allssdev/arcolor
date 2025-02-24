#include "rwmake.ch"
#include "ap5mail.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "protheus.ch"
#include "parmtype.ch"

#define _lEnt  CHR(13) + CHR(10)

/*/{Protheus.doc} RESTA330
@description ExcAuto da rotina MATA330 - Rec�lculo Custo M�dio
@obs sem observa��es 
@author Livia Della Corte (ALL System Solutions)
@since 05/11/2018
@version 1.0
@return null
@type function
@see https://allss.com.br
/*/
user function RESTA330()
	local   _lAt        := Type("CFILANT")=="U" //s� executa por JOB
	local   _cRotina    := "RESTA330"
	//27/12/2018 - ANDERSON C. P. COELHO - O MemoRead abaixo foi desativado pois, ao longo do tempo, poder� gerar error.log pelo estouro do tamanho limite da vari�vel. Al�m disso, como a rotina padr�o j� disp�e de um log espec�fico para a rotina padr�o, utilizaremos o padr�o para este fim.
	local   _cLog       := ""	//MemoRead("\2.MemoWrite\"+_cRotina+".log")
	local   _cArqErro   := ""
	local   _cErroTemp  := ""

	private _nSeq       := 1
	private _cEmpr      := IIF(type("CFILANT")=="U",GetPvProfString("RESTA330_"+StrZero(_nSeq,3),"EMPRESA"   ,"",GetAdv97()),SubStr(cNumEmp,1,2))
	private _cFil       := IIF(type("CFILANT")=="U",GetPvProfString("RESTA330_"+StrZero(_nSeq,3),"FILIAL"    ,"",GetAdv97()),SubStr(cNumEmp,3,2))

	// FB - RELEASE 12.1.23
	Private _bCFILANT :=  "type('CFILANT')"

	If _lAt
		while !Empty(_cEmpr) .AND. !Empty(_cFil)
			PREPARE ENVIRONMENT EMPRESA _cEmpr FILIAL _cFil FUNNAME _cRotina
				_cLog += _lEnt
				_cLog += "********************************************************************************" + _lEnt
			   	_cLog += "[" + _cRotina +  "] In�cio Execu��o"+_lEnt
				_cLog += "[DATA]" + cValtoChar(DATE())     + "  [HORA] " +  cValtoChar(Time()) + _lEnt 
			 	MemoWrite("\2.MemoWrite\"+_cRotina+".log",_cLog)
				lMsErroAuto := .T.
				MSExecAuto({|x| mata330(x)},.T.)
			 	_cLog += _lEnt
			 	_cLog += "[" + _cRotina +  "] Fim Execu��o"+_lEnt
				_cLog += "[DATA]" + cValtoChar(DATE())     + "  [HORA] " +  cValtoChar(Time()) + _lEnt 
				if lMsErroAuto
					_cArqErro := STRZERO(1,6) + ".log"
					_cErroTemp:=MostraErro("\2.MemoWrite\"+_cRotina+".log", _cArqErro) 
			    	MemoWrite("\2.MemoWrite\"+_cArqErro+".log", _cErroTemp )
			    	_cLog += MemoRead("\2.MemoWrite\"+_cArqErro+".log")
				Else
					_cLog+= "Executado sem Erro!"
				EndIf
			RESET ENVIRONMENT
			_nSeq++
			/* FB - RELEASE 12.1.23
			_cEmpr := IIF(type("CFILANT")=="U",GetPvProfString("RESTA330_"+StrZero(_nSeq,3),"EMPRESA"   ,"",GetAdv97()),SubStr(cNumEmp,1,2))
			_cFil  := IIF(type("CFILANT")=="U",GetPvProfString("RESTA330_"+StrZero(_nSeq,3),"FILIAL"    ,"",GetAdv97()),SubStr(cNumEmp,3,2))
			*/
			_cEmpr := IIF( &(_bCFILANT) == "U",GetPvProfString("RESTA330_"+StrZero(_nSeq,3),"EMPRESA"   ,"",GetAdv97()),SubStr(cNumEmp,1,2))
			_cFil  := IIF( &(_bCFILANT) == "U",GetPvProfString("RESTA330_"+StrZero(_nSeq,3),"FILIAL"    ,"",GetAdv97()),SubStr(cNumEmp,3,2))
			
		enddo
	EndIf
Return