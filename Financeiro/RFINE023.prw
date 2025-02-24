#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFINE023  �Autor  �J�lio Soares        � Data �  01/08/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina criada para automatizar o preenchimento dos         ���
���          � par�metros com base nas regras cadastradas nos par�metros  ���
���          � de banco.                                                  ���
�������������������������������������������������������������������������͹��
���          � Para o correto funcionamento dessa rotina � necess�rio     ���
���          � criar o campo EE_ARQUIVO contendo o nome dos arquivos com  ���
���          � as extens�es respectivos.                                  ���
���          � Deve ser preenchido temb�m o campo X1_VALID na tabela SX1  ���
���          � para o grupo 'AFI150' pergunta '01' a fun��o abaixo.       ���
���          �  "IIF(EXISTBLOCK("RFINE023"),U_RFINE023(),'')"             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa ARCOLOR                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFINE023()

Local _cRotina := 'RFINE023'
Local _cTmpFil := 'AIF150'
Local _cPerg   := Padr((_cTmpFil),10)
Local _lRet    := .T.

_cValid := " SELECT DISTINCT E1_PORTADO[BANK],E1_AGEDEP[AGEN],E1_CONTA[CONT],E1_CARTEIR[CART],EE_SUBCTA[SBCC],EE_ARQUIVO[ARQV] "
_cValid += " FROM " + RetSqlName("SE1") + " SE1 "
_cValid += " 	INNER JOIN " + RetSqlName("SEE") + " SEE "
_cValid += " 	ON SEE.D_E_L_E_T_  = '' "
_cValid += " 		AND SEE.EE_FILIAL  = '" + xFilial("SEE") + "' "
_cValid += " 		AND SEE.EE_CODIGO  = SE1.E1_PORTADO "
_cValid += " 		AND SEE.EE_AGENCIA = SE1.E1_AGEDEP "
_cValid += " 		AND SEE.EE_CONTA   = SE1.E1_CONTA "
_cValid += " 		AND SEE.EE_CARTEIR = SE1.E1_CARTEIR "
_cValid += " 		AND SEE.EE_VALIDSC = '2' "
_cValid += " WHERE SE1.D_E_L_E_T_ = '' "
_cValid += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
_cValid += " AND SE1.E1_NUMBOR = '" + (MV_PAR01) + "' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cValid),_cTmpFil,.F.,.T.)
dbSelectArea(_cTmpFil)
dbGoTop()	
_cArqv := (_cTmpFil)->(ARQV)
_cBank := (_cTmpFil)->(BANK)
_cAgen := (_cTmpFil)->(AGEN)
_cCont := (_cTmpFil)->(CONT)
_cCart := (_cTmpFil)->(CART)
_cSbcc := (_cTmpFil)->(SBCC)

If (MV_PAR02) <> (MV_PAR01)
	(MV_PAR02) := (MV_PAR01)
//	MSGBOX('DEVIDO AUTOMATIZA��O DA ROTINA N�O � PERMITIDO GERAR MAIS DE UM BORDER� POR VEZ.',_cRotina+'_01','ALERT')
EndIF

If !(MV_PAR03) == (_cTmpFil)->(ARQV)
	(MV_PAR03) := (_cTmpFil)->(ARQV)
//	MSGBOX('O ARQUIVO DE CONFIGURA��O UTILIZADO N�O CONFERE COM AS REGRAS DE PAR�METROS DE BANCO, VERIFIQUE! ',_cRotina+'_02','ALERT')
EndIf

If !(MV_PAR05) == (_cTmpFil)->(BANK)
	(MV_PAR05) := (_cTmpFil)->(BANK)
//	MSGBOX('O C�DIGO DO BANCO UTILIZADO N�O CONFERE COM AS REGRAS DE PAR�METROS DE BANCO, VERIFIQUE! ',_cRotina+'_03','ALERT')
EndIf
	
If !(MV_PAR06) == (_cTmpFil)->(AGEN)
	(MV_PAR06) := (_cTmpFil)->(AGEN)
//	MSGBOX('O C�DIGO DA AGENCIA UTILIZADA N�O CONFERE COM AS REGRAS DE PAR�METROS DE BANCO, VERIFIQUE! ',_cRotina+'_04','ALERT')	
EndIf
	
If !(MV_PAR07) == (_cTmpFil)->(CONT)
	(MV_PAR07) := (_cTmpFil)->(CONT)
//	MSGBOX('A CONTA UTILIZADA N�O CONFERE COM AS REGRAS DE PAR�METROS DE BANCO, VERIFIQUE! ',_cRotina+'_05','ALERT')
EndIf

If !(MV_PAR08) == (_cTmpFil)->(SBCC)
	(MV_PAR08) := (_cTmpFil)->(SBCC)
//	MSGBOX('A SUB CONTA UTILIZADA N�O CONFERE COM AS REGRAS DE PAR�METROS DE BANCO, VERIFIQUE! ',_cRotina+'_06','ALERT')
EndIf

(_cTmpFil)->(dbCloseArea())

Return()