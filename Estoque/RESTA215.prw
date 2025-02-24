#include "rwmake.ch"
#include "ap5mail.ch"
#include "topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} RESTA215
@description ExcAuto da rotina MATA215 - Refaz Acumulados
@obs 
@author Livia Della Corte (ALL System Solutions)
@since 05/11/2018
@version 1.0
@return null
@type function
@see https://allss.com.br
/*/

User Function RESTA215()


Local _lAt := Type("CFILANT")=="U"
Local _cRotina := "RESTA215"
//27/12/2018 - ANDERSON C. P. COELHO - O MemoRead abaixo foi desativado pois, ao longo do tempo, poderá gerar error.log pelo estouro do tamanho limite da variável. Além disso, como a rotina padrão já dispõe de um log específico para a rotina padrão, utilizaremos o padrão para este fim.
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
		   	_cLog += "[" + _cRotina +  "] Início Execução"+_lEnt
			_cLog += "[DATA]" + cValtoChar(DATE())     + "  [HORA] " +  cValtoChar(Time()) + _lEnt 
		 	MemoWrite("\2.MemoWrite\"+_cRotina+".log",_cLog)
			lMsErroAuto := .T.
			MSExecAuto({|x| mata215(x)},.T.)
		 	_cLog += _lEnt
		 	_cLog += "[" + _cRotina +  "] Fim Execução"+_lEnt
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
		_cEmpr := IIF( type("CFILANT")=="U",GetPvProfString("RESTA330_"+StrZero(_nSeq,3),"EMPRESA"   ,"",GetAdv97()),SubStr(cNumEmp,1,2))
		_cFil  := IIF(type("CFILANT")=="U",GetPvProfString("RESTA330_"+StrZero(_nSeq,3),"FILIAL"    ,"",GetAdv97()),SubStr(cNumEmp,3,2))
		*/
		_cEmpr := IIF( &(_bCFILANT) == "U",GetPvProfString("RESTA330_"+StrZero(_nSeq,3),"EMPRESA"   ,"",GetAdv97()),SubStr(cNumEmp,1,2))
		_cFil  := IIF( &(_bCFILANT) == "U",GetPvProfString("RESTA330_"+StrZero(_nSeq,3),"FILIAL"    ,"",GetAdv97()),SubStr(cNumEmp,3,2))
		
	enddo
EndIf



Return 