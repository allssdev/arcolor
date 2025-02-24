#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa � RTMKE029 �Autor  � Adriano L. de Souza � Data � 16/06/2014   ���
��������������������������������������������������������������������������͹��
���Desc.   � Fun��o desenvolvida busca avan�ada nos itens, para telas com  ���
���Desc.   � cabe�alho e itens.                                            ���
�������������������������������������������������������������������������͹��
���	Inserir o trecho abaixo no ponto de entrada do m�dulo desejado:       ���
��	                                                                      ���
��	Local _aSavArea := GetArea()                                          ���
��	                                                                      ���
���	If ExistBlock("RTMKE029")                                             ���
���     //Defino tecla de atalho para chamada da rotina de busca avan�ada ���
���     SetKey(K_CTRL_F5,{|| })                                           ���
���     SetKey(K_CTRL_F5,{|| U_RTMKE029() })                              ���
��� EndIf                                                                 ���
��	                                                                      ���
��	RestArea(_aSavArea)                                                   ���
��	                                                                      ���
�������������������������������������������������������������������������͹��
��������������������������������������������������������������������������͹��
���Uso      � Protheus 11 - Espec�fico para a empresa Arcolor.             ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������ͱ����
����������������������������������������������������������������������������*/

User Function RTMKE029()

Local _aColBkp := IIF(Type("aCols"  )<>"U",aClone(aCols  ),{})
Local _aHeaBkp := IIF(Type("aHeader")<>"U",aClone(aHeader),{})
Local _nBkp    := IIF(Type("n"      )<>"U",n              ,1 )

Private btnCancel
Private btnOK
Private cboTpBusca
Private nboTpBusca	:= 1
Private _lChkAcima 	:= .F.
Private _lblLinha	:= .F.
Private lblLinha
Private oComboBo1
Private nComboBo1	:= 1
Private cxtChave	:= Space(80)
Private _aCampos 	:= {}
Private chkAcima
Private chkLinIni
Private txtChave
Private _oObj
Private _cRotina    := "RTMKE029"

If AllTrim(FunName())=="TMKA271" .OR. AllTrim(FunName())=="RTMKI001" .OR. AllTrim(FunName())=="RPC"
	_oObj := oGetTlv
ElseIf AllTrim(FunName())$"/FATA100/FATA210/" .AND. Type("OGETD3")<>"U"
	_oObj	:= oGetd3
	n		:= _oObj:nAt				//O m�todo do getDados na tela de Regras de Neg�cios n�o utiliza a vari�vel n
	aHeader	:= aClone(_oObj:aHeader)	//O m�todo do getDados na tela de Regras de Neg�cios n�o utiliza a vari�vel aHeader
	aCols	:= aClone(_oObj:aCols  )	//O m�todo do getDados na tela de Regras de Neg�cios n�o utiliza a vari�vel aCols
ElseIf Type("OGETDADOS")<>"U"
	_oObj	:= oGetd3
	n		:= _oObj:nAt				//O m�todo do getDados na tela de Regras de Neg�cios n�o utiliza a vari�vel n
	aHeader	:= aClone(_oObj:aHeader)	//O m�todo do getDados na tela de Regras de Neg�cios n�o utiliza a vari�vel aHeader
	aCols	:= aClone(_oObj:aCols  )	//O m�todo do getDados na tela de Regras de Neg�cios n�o utiliza a vari�vel aCols
Else
	Return()
EndIf

If Type("_oObj")<>"O"
	MsgAlert("Fun��o de busca por item n�o dispon�vel nesta tela!",_cRotina+"_001")
	Return()
EndIf

//Verifico se a tela possui aCols para identificar se � cadastro modelo 2 (cabe�alho e itens)
If Type("aCols")<>"A"
	Return()
Else
	//Com base no aHeader monto array com os campos para sele��o da busca
	For _nCont := 1 To Len(aHeader)
		AAdd(_aCampos,aHeader[_nCont][1])
	Next
EndIf

Static oDlg

  DEFINE MSDIALOG oDlg TITLE "Busca Avan�ada - Itens" FROM 000, 000  TO 220, 550 COLORS 0, 16777215 PIXEL

    @ 016, 005 MSCOMBOBOX oComboBo1 VAR nComboBo1 ITEMS _aCampos SIZE 264, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 032, 005 MSGET txtChave VAR cxtChave SIZE 263, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 060, 004 SAY lblLinha PROMPT "Linha atual: " + AllTrim(Str(n)) SIZE 042, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 059, 048 CHECKBOX chkLinIni VAR _lblLinha PROMPT "Busca a partir do item posicionado" SIZE 094, 008 OF oDlg COLORS 0, 16777215 PIXEL
    @ 059, 148 CHECKBOX chkAcima VAR _lChkAcima PROMPT "Acima" SIZE 027, 008 OF oDlg COLORS 0, 16777215 PIXEL
    @ 058, 197 MSCOMBOBOX cboTpBusca VAR nboTpBusca ITEMS {"Parcial","Exata"} SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 095, 135 BUTTON btnOK PROMPT "Pesquisar" SIZE 061, 012 ACTION Posicionar() OF oDlg PIXEL
    @ 095, 206 BUTTON btnCancel PROMPT "Cancelar" SIZE 061, 012 ACTION Eval({||_nOpc:=0,Close(oDlg)}) OF oDlg PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

n       := _nBkp
aCols   := aClone(_aColBkp)
aHeader := aClone(_aHeaBkp)

Return()

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa � Posicionar�Autor  �Adriano L. de Souza � Data � 16/06/2014   ���
��������������������������������������������������������������������������͹��
���Desc.    � Sub-rotina de busca.                                         ���
��������������������������������������������������������������������������͹��
���Uso      � Programa Principal                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������ͱ����
����������������������������������������������������������������������������*/

Static Function Posicionar()
    
_nBkpN := n
    
//Verifico se a pesquisa ser� completa ou a partir do item posicionado
If _lChkAcima
	_aColsAux := aClone(aCols)
Else
	If !_lblLinha
		_nLinAtu := n
	Else
		_nLinAtu := 1
	EndIf
	_aColsAux    := {}
	For _nLinha  := _nLinAtu To Len(aCols)
		AAdd(_aColsAux,aCols[_nLinha])
	Next
EndIf
If Type("nComboBo1")<>"N"
	nComboBo1 := aScan(_aCampos,nComboBo1)
EndIf
_nPosCol := aScan(aHeader,{|x|AllTrim(x[01]) == AllTrim(_aCampos[nComboBo1])})
If Type("nboTpBusca")=="N"
	If nboTpBusca==1
		_nPosLin :=	aScan(_aColsAux,{|x| UPPER(AllTrim(cxtChave)) $ UPPER(AllTrim(x[_nPosCol]))})		//aScan(_aColsAux,{|x| UPPER(SubStr(AllTrim(x[_nPosCol]),1,Len(AllTrim(cxtChave)))) == UPPER(AllTrim(cxtChave))})
	Else
		_nPosLin :=	aScan(_aColsAux,{|x| UPPER(AllTrim(x[_nPosCol])) == UPPER(AllTrim(cxtChave))})
	EndIf
ElseIf Type("nboTpBusca")=="C"
	If AllTrim(nboTpBusca)=="Parcial"
		_nPosLin :=	aScan(_aColsAux,{|x| UPPER(AllTrim(cxtChave)) $ UPPER(AllTrim(x[_nPosCol]))})		//aScan(_aColsAux,{|x| UPPER(SubStr(AllTrim(x[_nPosCol]),1,Len(AllTrim(cxtChave)))) == UPPER(AllTrim(cxtChave))})
	Else
		_nPosLin :=	aScan(_aColsAux,{|x| UPPER(AllTrim(x[_nPosCol])) == UPPER(AllTrim(cxtChave))})
	EndIf
EndIf
If _nPosLin==0
	_nPosLin := _nBkpN
EndIf
n := _nPosLin
If Type("_oObj")=="O"
	_oObj:oBrowse:nAt := n
EndIf

Close(oDlg)

Return()