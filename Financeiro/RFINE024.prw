#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFINE024  �Autor  � J�lio Soares       � Data �  01/08/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina criada para n�o permitir que o campo EE_VALIDSC     ���
���          � permita mais de um campo, onde os par�metros: BANCO,AGENCIA���
���          � ,CONTA,SUBCONTA,CARTEIRA, sejam iguais.                    ���
���          � Para funcionamento correto da rotina � necess�rio inserir  ���
���          � a fun��o "IIF(EXISTBLOCK("RFINE024"),U_RFINE024(),'')" no  ���
���          � campo EE_VALIDSC(campo customizado)                        ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Uso espec�fico empresa - Arcolor              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFINE024()

Local _cRotina := 'RFINE024'
Local _cTmpFil := 'TMPSEE'
Local _lRet    := .T.

If (M->(EE_VALIDSC)) == '1' // 1 = SIM

	_cValid := " SELECT COUNT (*)[CONT] "                	
	_cValid += " FROM "
	_cValid += " (SELECT EE_VALIDSC,EE_CODIGO,EE_AGENCIA,EE_DVAGE,EE_CONTA,EE_DVCTA,EE_CARTEIR "
	_cValid += " FROM "+ RetSqlName("SEE") +" SEE  "
	_cValid += " WHERE SEE.EE_FILIAL  = '" + xFilial("SEE") + "' "
	_cValid += " AND SEE.EE_EXTEN   = 'REM' "
	_cValid += " AND SEE.EE_VALIDSC = '1' "
	_cValid += " AND SEE.EE_AGENCIA = '"+(SEE->EE_AGENCIA)+"' "
	_cValid += " AND SEE.EE_CONTA   = '"+(SEE->EE_CONTA)  +"' "
	_cValid += " AND SEE.EE_CARTEIR = '"+(SEE->EE_CARTEIR)+"' "
	_cValid += " AND SEE.D_E_L_E_T_ = '' "
	_cValid += " ) SEEAUX"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cValid),_cTmpFil,.F.,.T.)

	dbSelectArea(_cTmpFil)
	dbGoTop()
	If ((_cTmpFil)->(CONT)) > 0
		MSGBOX('Por quest�es de seguran�a n�o � permitido que mais de um par�metro de banco, contendo a op��o [SIM], no cadastro para as mesmas configura��es de: '+;
				'[BANCO] [AGENCIA] [CONTA] [CARTEIRA]',_cRotina+'_01','ALERT')
		_lRet := .F.
	EndIf
	(_cTmpFil)->(dbCloseArea())

EndIf

Return(_lRet)