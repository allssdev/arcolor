#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATA004  �Autor  �Marcelo Evangelista � Data �  20/01/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Confere volumes na saida de mercadoria/ na SZ9 e SF2       ���
���          � Esta rotina recebe o codigode barras coletado pela etiqueta���
���          � e compara com a tabela SZ9 com os registros gravados.      ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFATA004()

Private cCadastro := "Conferencia de Volumes"
Private _cDoc	  := ""
Private _cSerie	  := ""
Private _cVol1	  := ""
Private _cCBDef   := Padr("",tamsx3("F2_DOC")[01] + tamsx3("F2_SERIE")[01] + tamsx3("F2_VOLUME1")[01])
Private _cCodBar  := _cCBDef
Private aRotina   := {	{ "Pesquisar"   ,"AxPesqui" ,0,1},;  //"Pesquisar"
	                    { "Visualizar"  ,"AxVisual" ,0,2},;  //"Visualizar"
					    { "Conferir Volumes","U_RFATR18C()",0,4}}   //"Confere volume"

dbSelectArea("SF2")
SF2->(dbSetOrder(1))

mBrowse(6,1,22,75,"SF2")

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATR18C  �Autor  �Marcelo Evangelista � Data �  20/01/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Apresenta��o da tela de confer�ncia dos volumes.           ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal.                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFATR18C()

_cDoc		:= SF2->F2_DOC
_cSerie		:= SF2->F2_SERIE
_cVol1		:= SF2->F2_VOLUME1
_cCodBar    := _cCBDef
bSet15		:= {|| F_OK() }
bSet24		:= {|| oDlg3:End()}

Static oDlg3

@ 001,001 TO 200,600 DIALOG oDlg3 TITLE "Conferencia de Volumes "
	@ 010,002 TO 099,298
	@ 015,005 Say OemToAnsi("Numero da NF:")
	@ 022,005 GET _cDoc	        When .F.	       				  		SIZE 040,11
	@ 015,045 Say OemToAnsi("Serie")
	@ 022,045 GET _cSerie       When .F.   	            	  			SIZE 040,11
	@ 015,075 Say OemToAnsi("Codigo de barras")
	@ 022,075 GET _cCodBar      When .T.   Valid EVAL(bSet15)  			SIZE 040,11
ACTIVATE MSDIALOG oDlg3 ON INIT EnchoiceBar( oDlg3 , bSet15 , bSet24 , NIL , ,) CENTERED     

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F_OK      �Autor  �Marcelo Evangelista � Data �  20/01/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��o da confer�ncia realizada.                        ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal.                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function F_OK()

Local _lRet := .T.

If !Empty(_cCodBar)
	dbSelectArea("SZ1")
	SZ1->(dbSetOrder(1))
	If SZ1->(MsSeek(xFilial("SZ1")+_cCodBar,.T.,.F.))
		while !RecLock("SZ1", .F.) ; enddo
			If Alltrim(_cCodBar) == Alltrim(SZ1->Z1_NUMNOTA+SZ1->Z1_SERIENO+ cValToChar(SZ1->Z1_VOLUME1))
				SZ1->Z1_PERMITE := "Liberado com sucesso"
			Else
				SZ1->Z1_PERMITE := "Liberado com DIVERGENCIA"
			EndIf
		SZ1->(MsUnLock())
	Else
		MsgAlert("Etiqueta n�o encontrada!")
		_lRet := .F.
	EndIf
	_cCodBar := _cCBDef
	oDlg3:SetFocus(6007)
EndIf

Return(_lRet)