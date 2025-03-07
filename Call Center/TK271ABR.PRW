#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���Programa  �TK271ABR�Autor  �Anderson C. P. Coelho � Data � 15/08/13    ���
�������������������������������������������������������������������������͹��
���Descri��o � Esse ponto de entrada � executado ao acionar (clicar) no   ���
���          �bot�o "Alterar" Atendimento no Call Center.                 ���
���          � O ponto de entrada permite tratamentos espec�ficos e de    ���
���          �valida��o ao tentar incluir, alterar ou consultar um novo   ���
���          �atendimento televendas, cancelando, se necess�rio, a        ���
���          �abertura da janela de atendimento.                          ���
���          � Neste momento, � utilizado para n�o permitir a altera��o   ���
���          �de atendimentos que tenham itens liberados e/ou faturados no���
���          �Pedido de Vendas.                                           ���
�������������������������������������������������������������������������͹��
���          � Implementa��o de valida��o do perfil dos operadores para   ���
���          � que somente os usu�rios com perfil de Televendas ou Tlv/Tmk���
���          � passem pela valida��o.                                     ���
�������������������������������������������������������������������������͹��
���Uso       �Protheus 11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function TK271ABR()

Local _aSavArea  := GetArea()
Local _cRotina   := "TK271ABR"
Local _lRet      := .T.

dbSelectArea("SU7")                                                                                                                              
SU7->(dbSetOrder(4))		// - U7_FILIAL+U7_CODUSU
If SU7->(dbSeek(xFilial("SU7") + __cUserID,.F.,.F.)) // - Valida o perfil do usu�rio conforme cadastro dos operadores
	If (SU7->U7_TIPOATE) $ '2|5' // - Televendas|Tmk e Tlv
		If ALTERA .AND. AllTrim(SUA->UA_OPER)=="1" .AND. AllTrim(SUA->UA_STATUS)$'LIB/NF./CAN'
			_lRet := .F.
			MSGBOX("Aten��o! N�o � poss�vel alterar atendimentos que j� tenham gerado pedido de vendas em que algum item tenha" +;
					 " sido liberado. Desfa�a as libera��es para que seja poss�vel proceder a altera��o desejada!",_cRotina+"_001","ALERT")
		EndIf
	EndIf
Else
	MSGBOX('USU�RIO SEM ACESSO PARA EXECUTAR ESSA ROTINA',_cRotina + '_002','STOP')
EndIf

RestArea(_aSavArea)

Return(_lRet)