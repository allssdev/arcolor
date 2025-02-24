#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"

/*
�����������������������������������������������������������������������������
���                                                                       ���
���     ROTINA DESATIVDA - AGUARDANDO VALIDA��O DO PROCESSO FINANCEIRO    ���
���                                                                       ���
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FA050INC �Autor  � J�lio Soares       � Data �  02/07/15   ���
�������������������������������������������������������������������������͹��
���Desc.TOTVS� O ponto de entrada FA050INC - ser� executado na valida��o  ���
���          � da Tudo Ok na inclus�o do contas a pagar.                  ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada sendo utilizado para validar o tipo do    ���
���          � t�tulo que est� sendo incluido, se for diferente de PA ou  ���
���          � PR n�o permite a inclus�o manual.                          ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa ARCOLOR                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FA050INC()

Local _lRet     := .T.
/*Local _aSavArea := GetArea()
Local _cRotina  := "FA050INC"
Local _cTpcp    := SuperGetMv("MV_TIPOSCP",,"PA/PR") // "PR/PA/DPV/TCN/CLN"



If !Empty(_cTpcp)
	If !Alltrim((M->E2_TIPO)) $ _cTpcp
		MSGBOX("Usu�rio sem permiss�o para incluir t�tulos a pagar no financeiro, apenas t�tulos do tipo PA (Pagamento Antecipado) e PR "+;
		" (Provis�rio) podem ser incluidos. " + CHR(10) + CHR(13) + "Informe o administrador do sistema",_cRotina+"_001","STOP")
		_lRet := .F.
	EndIf
Else
	MSGBOX("Usu�rio sem permiss�o para incluir t�tulos a pagar no financeiro, verifique o par�metro 'MV_TIPOSPC' ou informe o Administrador do sistema. ",_cRotina+"_002","STOP")
	_lRet := .F.
EndIf


RestArea(_aSavArea)*/

Return(_lRet)