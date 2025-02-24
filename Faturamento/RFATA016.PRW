#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºPrograma  ³RFATA012ºAutor  ³Anderson C. P. Coelho º Data º 15/10/13    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Rotina utilizada para a alteração do pedido de vendas,     º±±
±±º          ³ para que as regras de negócios sejam realizadas.           º±±
±±º          ³ Esta rotina é chamada pelo ponto de entrada TMKVFIM, por   º±±
±±º          ³StartJob.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFATA016()//(_aCab,_aItPV,_cPed,_cEmpFil,_lJob)

Local _lRet         := .T.
Local _cRotina      := "RFATA016"

Private lMsErroAuto := .F.

Default _aCab       := {}
Default _aItPV      := {}
Default _cPed       := ""
Default _cEmpFil    := ""
Default _lJob       := .F.

If Len(_aCab) > 0 .AND. Len(_aItPV) > 0 .AND. !Empty(_cPed) .AND. !Empty(_cEmpFil)
	If _lJob
		RpcClearEnv()
		RpcSetType(3)
		//RpcSetEnv( SubStr(_cEmpFil,1,2),SubStr(_cEmpFil,3,2),,,'FAT',GetEnvServer())
		PREPARE ENVIRONMENT EMPRESA SubStr(_cEmpFil,1,2) FILIAL SubStr(_cEmpFil,3,2) FUNNAME _cRotina
		SetModulo( "SIGAFAT", "FAT" )
	EndIf
	_cFunName := FunName()
	SetFunName("MATA410")
	If _lJob
		MSExecAuto({|x,y,z| mata410(x,y,z)},_aCab,_aItPV,4)
		_lRet := !lMsErroAuto
		If lMsErroAuto
			MostraErro()
		EndIf
	EndIf
	SetFunName(_cFunName)
EndIf

//U_RCFGM001(Titulo,_cMsg,_cMail,_cAnexo,_cFromOri,_cBCC)

Return(_lRet)