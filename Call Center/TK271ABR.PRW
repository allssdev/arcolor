#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºPrograma  ³TK271ABRºAutor  ³Anderson C. P. Coelho º Data º 15/08/13    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Esse ponto de entrada é executado ao acionar (clicar) no   º±±
±±º          ³botão "Alterar" Atendimento no Call Center.                 º±±
±±º          ³ O ponto de entrada permite tratamentos específicos e de    º±±
±±º          ³validação ao tentar incluir, alterar ou consultar um novo   º±±
±±º          ³atendimento televendas, cancelando, se necessário, a        º±±
±±º          ³abertura da janela de atendimento.                          º±±
±±º          ³ Neste momento, é utilizado para não permitir a alteração   º±±
±±º          ³de atendimentos que tenham itens liberados e/ou faturados noº±±
±±º          ³Pedido de Vendas.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Implementação de validação do perfil dos operadores para   º±±
±±º          ³ que somente os usuários com perfil de Televendas ou Tlv/Tmkº±±
±±º          ³ passem pela validação.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Protheus 11 - Específico para a empresa Arcolor.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TK271ABR()

Local _aSavArea  := GetArea()
Local _cRotina   := "TK271ABR"
Local _lRet      := .T.

dbSelectArea("SU7")                                                                                                                              
SU7->(dbSetOrder(4))		// - U7_FILIAL+U7_CODUSU
If SU7->(dbSeek(xFilial("SU7") + __cUserID,.F.,.F.)) // - Valida o perfil do usuário conforme cadastro dos operadores
	If (SU7->U7_TIPOATE) $ '2|5' // - Televendas|Tmk e Tlv
		If ALTERA .AND. AllTrim(SUA->UA_OPER)=="1" .AND. AllTrim(SUA->UA_STATUS)$'LIB/NF./CAN'
			_lRet := .F.
			MSGBOX("Atenção! Não é possível alterar atendimentos que já tenham gerado pedido de vendas em que algum item tenha" +;
					 " sido liberado. Desfaça as liberações para que seja possível proceder a alteração desejada!",_cRotina+"_001","ALERT")
		EndIf
	EndIf
Else
	MSGBOX('USUÁRIO SEM ACESSO PARA EXECUTAR ESSA ROTINA',_cRotina + '_002','STOP')
EndIf

RestArea(_aSavArea)

Return(_lRet)