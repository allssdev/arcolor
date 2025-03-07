#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���Programa  �RFATA012�Autor  �Anderson C. P. Coelho � Data � 15/10/13    ���
�������������������������������������������������������������������������͹��
���Descri��o � Rotina utilizada para a altera��o do pedido de vendas,     ���
���          � para que as regras de neg�cios sejam realizadas.           ���
���          � Esta rotina � chamada pelo ponto de entrada TMKVFIM, por   ���
���          �StartJob.                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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