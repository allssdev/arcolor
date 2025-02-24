#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RTMKC003  �Autor  �Anderson C. P. Coelho � Data �  01/12/15 ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina utilizada para a manipula��o do par�metro MV_DTFIXAT.���
���          �Este par�metro � utilizado para definir uma data fixa de    ���
���          �emiss�o para pedidos de vendas e atendimentos call center.  ���
���          �Se este par�metro etiver sem conte�do, o sistema utilizar� o���
���          �conceito padr�o (database do sistema).                      ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RTMKC003()

Local oSButton1
Local oGroup1
Local oSay1
Local oGet1
Local _cRotina   := "RTMKC003"
Local cGet1      := SuperGetMv("MV_DTFIXAT",,STOD(""))
Local cGet1Old   := cGet1
Local _nOpc      := 0

If MsgYesNo("Esta rotina � utilizada para que seja fixada uma data de emiss�o para os pedidos inclu�dos pelos m�dulos Call Center e/ou Faturamento. Deseja prosseguir com esta defini��o?",_cRotina+"_001")
	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "Data Fixa para Pedidos" FROM 000, 000  TO 150, 800 COLORS 0, 16777215 PIXEL

	    @ 003, 004 GROUP oGroup1 TO 061, 392 PROMPT " Informe a data de emiss�o fixa para os pedidos (Call Center e Faturamento) " OF oDlg COLOR 0, 16777215 PIXEL
	    @ 019, 011   SAY oSay1   PROMPT "Data:"    SIZE 028, 007 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 016, 039 MSGET oGet1   VAR    cGet1      SIZE 344, 010 OF oDlg COLORS 0, 16777215 PIXEL
	    DEFINE SBUTTON oSButton1 FROM 041, 356 TYPE 01 OF oDlg ENABLE Action (_nOpc:=1,oDlg:End())

	    ACTIVATE MSDIALOG oDlg CENTERED

	If _nOpc == 1
		PutMV("MV_DTFIXAT",cGet1)
		MsgInfo("Conte�do atualizado com sucesso de '"+DTOC(cGet1Old)+"' para '" + DTOC(cGet1) + "'.",_cRotina+"_002")
		MsgInfo("Solicite aos usu�rios digitadores de pedido que saiam do sistema e entrem novamnete, para que possamos garantir a atualiza��o dos pedidos. Assim que conclu�rem, deixe o conte�do deste par�metro em branco para que o sistema adote suas tratativas padr�es. Em caso de d�vidas, contate o Administrador do sistema!",_cRotina+"_003")
	EndIf
EndIf

Return