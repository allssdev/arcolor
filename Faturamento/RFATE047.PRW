#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFATE047  �Autor  � J�lio Soares       � Data �  27/05/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock utilizado para preencher automaticamente o nome  ���
���          � central referente ao CNPJ central.                         ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico ARCOLOR                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFATE047()

Local _cNome := ""

_cSel := " SELECT A1_CGCCENT,A1_NOMECGC[NOMECGC],SUBSTRING(A1_NOME,1,45)[NOME] "
_cSel += " FROM " + RetSqlName("SA1") + " SA1 "
_cSel += " WHERE SA1.D_E_L_E_T_ = '' "
_cSel += " AND SA1.A1_FILIAL  = '" + xFilial("SA1") + "' "
_cSel += " AND SA1.A1_CGCCENT = '" + (M->A1_CGCCENT) + "' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cSel),"TMPCGC",.F.,.T.)

dbSelectArea("TMPCGC")

If TMPCGC->(!EOF())
	If !Empty (TMPCGC->(NOMECGC))
		_cNome := (ALLTRIM(TMPCGC->(NOMECGC)))
	Else
		_cNome := (ALLTRIM(TMPCGC->(NOME)))
	EndIf
EndIf

dbSelectArea("TMPCGC")
dbCloseArea()

Return(_cNome)