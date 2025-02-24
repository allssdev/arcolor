#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RCFGE002  �Autor  �Adriano Leonardo    � Data �  14/02/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina respon�vel por montar o comando merge para sincro-  ���
���          � nia entre os bancos de dados entre diversos servidores.    ���
�������������������������������������������������������������������������͹��
���Uso       �Protheus 11 - Espec�fico para a empresa Arcolor.(CD Control)���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RCFGE002()    

Local _aSavArea := GetArea()
Local _aSavSZ8  := SZ8->(GetArea())
Local _cRotina  := "RCFGE002"

If MsgYesNo("Deseja executar o Merge neste momento [Se continuar, antes certifique-se de ter realizado o backup da base de dados]?",_cRotina+"_003")
	If ExistBlock("RCFGE003")
		If !MsgYesNo("Deseja abortar a rotina do merge neste momento [Se continuar, antes certifique-se de ter realizado o backup da base de dados]?",_cRotina+"_002")
			dbSelectArea("SZ8")
			SZ8->(dbSetOrder(3))		//Z8_FILIAL+Z8_ORDEM
			SZ8->(dbGoTop())
			While !SZ8->(EOF()) //Nesse caso n�o ser� considerado filial
				//Executa a rotina que dispara o merge nas tabelas
				//Verifico se o resgistro est� bloqueado
				If SZ8->(FieldPos("Z8_MSBLQL"))<>0
					If SZ8->Z8_MSBLQL=='1'
						dbSelectArea("SZ8")
						SZ8->(dbSetOrder(3))
						SZ8->(dbSkip())
						Loop
					EndIf
				EndIf
				MsAguarde({|lEnd| U_RCFGE003(AllTrim(SZ8->Z8_SERVORI),AllTrim(SZ8->Z8_SERVDES),AllTrim(SZ8->Z8_TABELA),AllTrim(SZ8->Z8_FILTRO),AllTrim(SZ8->Z8_INSERT),AllTrim(SZ8->Z8_UPDATE),AllTrim(SZ8->Z8_INSTPOS))},"[" + _cRotina + "] MERGE","Tabela " + AllTrim(SZ8->Z8_TABELA),.T.)
				dbSelectArea("SZ8")
				SZ8->(dbSetOrder(3))
				SZ8->(dbSkip())
			EndDo
		EndIf
	Else
		MsgAlert("Rotina RCFGE003 inexistente!",_cRotina+"_001")
	EndIf
Else
	MsgAlert("Rotina abortada!",_cRotina+"_004")
EndIf

RestArea(_aSavSZ8)
RestArea(_aSavArea)

Return()