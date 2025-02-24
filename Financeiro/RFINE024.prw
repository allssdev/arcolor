#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RFINE024  ºAutor  ³ Júlio Soares       º Data ³  01/08/14  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina criada para não permitir que o campo EE_VALIDSC     º±±
±±º          ³ permita mais de um campo, onde os parâmetros: BANCO,AGENCIAº±±
±±º          ³ ,CONTA,SUBCONTA,CARTEIRA, sejam iguais.                    º±±
±±º          ³ Para funcionamento correto da rotina é necessário inserir  º±±
±±º          ³ a função "IIF(EXISTBLOCK("RFINE024"),U_RFINE024(),'')" no  º±±
±±º          ³ campo EE_VALIDSC(campo customizado)                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Uso específico empresa - Arcolor              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
		MSGBOX('Por questões de segurança não é permitido que mais de um parâmetro de banco, contendo a opção [SIM], no cadastro para as mesmas configurações de: '+;
				'[BANCO] [AGENCIA] [CONTA] [CARTEIRA]',_cRotina+'_01','ALERT')
		_lRet := .F.
	EndIf
	(_cTmpFil)->(dbCloseArea())

EndIf

Return(_lRet)