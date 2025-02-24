#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FA280    �Autor  �Adriano Leonardo    � Data �  11/10/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada para gravar dados complementares durante  ���
���Desc.     � o processo de fatura do contas a receber.                  ���
�������������������������������������������������������������������������͹��
���Uso P11   � Uso espec�fico Arcolor                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function FA280()

Local _aSavArea := GetArea()
Local _aSavSE1 	:= SE1->(GetArea())
Local _aSavSA1 	:= SA1->(GetArea())
Local _cRotina	:= "FA280"

If ExistBlock("RFINE032")
	U_RFINE032()
EndIf

/*
Private cPerg	:= "FA280"
	
dbSelectArea("SE1")
MsgInfo("Informe o portador para o t�tulo: " + AllTrim(SE1->E1_NUM) + "-" + AllTrim(SE1->E1_PREFIXO) + "/" + AllTrim(SE1->E1_PARCELA),_cRotina+"_001")

//Cria os par�metros da rotina na SX1
ValidPerg()

//N�o deixa o usu�rio fechar a tela sem confirmar
While !(Pergunte(cPerg,.T.))
	Pergunte(cPerg,.T.)
EndDo

dbSelectArea("SA1")
SA1->(dbSetOrder(1))
SA1->(MsSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA,.T.,.F.))
//Grava dados complementares dos t�tulos gerados a partir do processo de fatura (o t�tulo gerado est� posicionado nesse momento)
dbSelectArea("SE1")
while !RecLock("SE1",.F.) ; enddo
	SE1->E1_PORTADO	:= MV_PAR01
	SE1->E1_AGEDEP	:= MV_PAR02
	SE1->E1_CONTA	:= MV_PAR03
	SE1->E1_CARTEIR	:= MV_PAR04
SE1->(MsUnlock())
*/

//Restaura a �rea conforme in�cio do processamento da rotina
RestArea(_aSavSA1)
RestArea(_aSavSE1)
RestArea(_aSavArea)

Return()

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValidPerg �Autor  �Adriano Leonardo    � Data �  11/10/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o respons�vel pela cria��o de par�metros de rotina na ���
���Desc.     � SX1.                                                       ���
�������������������������������������������������������������������������͹��
���Uso P11   � Uso espec�fico Arcolor                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function ValidPerg()

Local _aSArea    := GetArea()
Local aRegistros := {}

cPerg            := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Banco?"	,"","","mv_ch1","C",03,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SA6","","",""})
AADD(aRegistros,{cPerg,"02","Agencia?"	,"","","mv_ch2","C",05,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","",""})
AADD(aRegistros,{cPerg,"03","Conta?"	,"","","mv_ch3","C",10,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","",""})
AADD(aRegistros,{cPerg,"04","Carteira?"	,"","","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","",""})

For i := 1 To Len(aRegistros)
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If !SX1->(dbSeek(cPerg+aRegistros[i,2]))
        while !RecLock("SX1",.T.) ; enddo
			For J:= 1 To FCount()
				If J <= Len(aRegistros[i])
					FieldPut(J,aRegistros[i,j])
				Else
					Exit
				EndIf
			Next
		SX1->(MsUnLock())
	EndIf
Next

RestArea(_aSArea)

Return()