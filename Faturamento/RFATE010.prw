#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft100LOk3 � Autor �Vendas Clientes        � Data � 09/05/2001 ���
���          �RFATE010  � Autor �Anderson C. P. Coelho  � Data � 27/12/2012 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina de Validacao da linha Ok do cadastro de regras de      ���
���          �Negocios, aba 3, que trata a respeito das regras para desconto���
���          � Esta rotina e utilizada em substituicao da rotina de         ���
���          �validacao padrao Ft100LOk3 (rotina RFATE010 chamada pela      ���
���          �manipula��o do objeto oGetD3, por meio do Ponto de Entrada    ���
���          �FT100MRN.                                                     ���
���������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                        ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Materiais/Distribuicao/Logistica                             ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

User Function RFATE010()

Local aArea     := GetArea()
Local lRetorno  := .T.
Local nPCodPro  := aScan(aHeader,{|x| AllTrim(x[2])=="ACN_CODPRO"})
Local nPGrupo   := aScan(aHeader,{|x| AllTrim(x[2])=="ACN_GRPPRO"})
Local nPDesc    := aScan(aHeader,{|x| AllTrim(x[2])=="ACN_DESCON"})
Local nPItem    := aScan(aHeader,{|x| AllTrim(x[2])=="ACN_ITEM"  })
Local nUsado    := Len(aHeader)
Local nX        := 0

//������������������������������������������������������������������������Ŀ
//�Verifica os campos obrigatorios                                         �
//��������������������������������������������������������������������������
If !aCols[n][nUsado+1]
	If !Empty(aCols[n][nPCodPro]) .AND. !Empty(aCols[n][nPGrupo])
		Help(" ",1,"FT100DESC")
		lRetorno := .F.
	EndIf
EndIf
	
//������������������������������������������������������������������������Ŀ
//�Verifica se nao ha valores duplicados                                   �
//��������������������������������������������������������������������������
If lRetorno
	For nX := 1 To Len(aCols)
		If nX <> N .AND. !aCols[nX][nUsado+1]
			If ( aCols[nX][nPItem]+aCols[nX][nPCodPro]+aCols[nX][nPGrupo] == aCols[N][nPItem]+aCols[N,nPCodPro]+aCols[N][nPGrupo] )
				lRetorno := .F.
				Help(" ",1,"JAGRAVADO")
			EndIf
		EndIf
	Next nX
EndIf

RestArea(aArea)

Return(lRetorno)