#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFATE039 � Autor �Adriano Leonardo      � Data �  18/03/14 ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina criada para permitir busca avan�ada na tela de      ���
���          � cadastro de clientes.                                      ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function RFATE039()

Local oCboCampo
Local oCboTipo 
Local oBtnOk
Local oBtnCancel
Local oSay1
Local oTxtTexto
Private _cRotina	:= "RFATE039"
Private _cAlias		:= "SA1"
Private _nCboCampo 	:= ""
Private _nCboTipo  	:= ""
Private _cConteudo 	:= ""
Private _aCampos 	:= {}
Private _aCpoSX3 	:= {} //Posi��es do array - 1: Titulo, 2: Campo , 3: Tipo, 4: Tamanho, 5: Decimal
Static oDlg

If FunName()<>"MATA030" //Cadastro de clientes
	Return()
EndIf

//Inibe a tecla de atalho para prevenir duplicidade da abertura da janela
SetKey(VK_F5,{|| })

  DEFINE MSDIALOG oDlg TITLE "Busca Avan�ada" FROM 000, 000  TO 170, 600 COLORS 0, 16777215 PIXEL
	
	ListarCampos()

	_nPosCgc := aScan(_aCpoSX3,{|x|AllTrim(x[02])==AllTrim("A1_CGC")})
	
	//Prioriza o campo de CNPJ na abertura da tela
	If _nPosCgc>0
		_nCboCampo := _aCpoSx3[_nPosCgc,01]
	EndIf
	
    @ 016, 004 MSCOMBOBOX oCboCampo VAR _nCboCampo ITEMS _aCampos SIZE 289, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 036, 004 MSGET oTxtTexto VAR _cConteudo SIZE 289, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 055, 047 MSCOMBOBOX oCboTipo VAR _nCboTipo ITEMS {"Exata","Parcial"} SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 052, 182 BUTTON oBtnOk PROMPT "Buscar" SIZE 050, 012 OF oDlg ACTION Filtrar() PIXEL
    @ 057, 004 SAY oSay1 PROMPT "Tipo de busca:" SIZE 037, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 052, 242 BUTTON oBtnCancel PROMPT "Cancelar" SIZE 050, 012 OF oDlg ACTION Fechar() PIXEL
	
  ACTIVATE MSDIALOG oDlg CENTERED

Return()

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFATE039 � Autor �Adriano Leonardo      � Data �  18/03/14 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o respons�vel por fechar a tela de busca avan�ada e   ���
���          � restaurar a tecla de atalho (F5).                          ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function Fechar()
	
	Close(oDlg)
	
	//Restaura a tecla de atalho ao fechar a janela de busca
	SetKey(VK_F5,{|| })
	SetKey(VK_F5,{|| U_RFATE039() })
	
Return()

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFATE039 � Autor �Adriano Leonardo      � Data �  18/03/14 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o respons�vel por selecionar quais campos ser�o dispo-���
���          � nibilizados para edi��o do filtro pelo usu�rio.            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function ListarCampos()

Local _aSavArea	:= GetArea()
//Local _aSavSx3 	:= SX3->(GetArea())

_cAliasSX3 := "SX3_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
dbSelectArea(_cAliasSX3)
(_cAliasSX3)->(dbSetOrder(1))

If (_cAliasSX3)->(dbSeek(_cAlias))
	While ! (_cAliasSX3)->(EOF()) .And. (_cAliasSX3)->X3_ARQUIVO==_cAlias
		
		//Certifico que o campo � real e esteja dispon�vel no browse
		If (_cAliasSX3)->X3_CONTEXT<>"V" .And. (_cAliasSX3)->X3_BROWSE=="S"
			
			If Empty(_cConteudo)
				_cConteudo := Space(50)//Space(SX3->X3_TAMANHO)
			EndIf
			
			If Empty(_nCboTipo)
				_nCboTipo  := "Exata"
			EndIf
			
			If Empty(_nCboCampo)
				_nCboCampo := (_cAliasSX3)->X3_TITULO
			EndIf
			
			AAdd(_aCampos,(_cAliasSX3)->X3_TITULO)
			AAdd(_aCpoSX3,{(_cAliasSX3)->X3_TITULO,(_cAliasSX3)->X3_CAMPO,(_cAliasSX3)->X3_TIPO, (_cAliasSX3)->X3_TAMANHO, (_cAliasSX3)->X3_DECIMAL})
		EndIf
		
		dbSelectArea(_cAliasSX3)
		dbSetOrder(1)
		dbSkip()
	EndDo
EndIf

//RestArea(_aSavSx3)
RestArea(_aSavArea)

Return()

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFATE039 � Autor �Adriano Leonardo      � Data �  18/03/14 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o respons�vel por aplicar o filtro do usu�rio na tela ���
���          � do atendimento do Call Center.                             ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function Filtrar()
         
Local _aSavArea		:= GetArea()
Local _aSavSx3		:= SX3->(GetArea())
Local aIndex 		:= {}
Local aCores2		:= IIF(ExistBlock("TK271COR"),U_TK271COR(),{}) //Ponto de entrada para manipula��o das cores da legenda do atendimento
Private aIndexSA1	:= {}
Static cFiltra 		:= ""

dbSelectArea(_cAlias)

_nPosArr := aScan(_aCpoSX3,{|x|AllTrim(x[01])==AllTrim(_nCboCampo)})

cFiltra := "AllTrim(" + _cAlias + "->" + AllTrim(_aCpoSx3[_nPosArr,2]) + ")"

If _aCpoSx3[_nPosArr,3]=="D"
	cFiltra := "DTOC(" + _cAlias + "->" + AllTrim(_aCpoSx3[_nPosArr,2]) + ")"
EndIf

//Posi��es do array - 1: Titulo, 2: Campo , 3: Tipo, 4: Tamanho, 5: Decimal
If _aCpoSx3[_nPosArr,3]=="C"
	If _nCboTipo=="Parcial"
		cFiltra := "'" + AllTrim(_cConteudo) + "' $ " + cFiltra
	Else
		cFiltra += " == " + "'" + AllTrim(_cConteudo) + "'"
	EndIf
ElseIf _aCpoSx3[_nPosArr,3]=="N"
	If _nCboTipo=="Parcial"
		cFiltra := _cConteudo + " $ " + cFiltra
	Else
		cFiltra += " == " + "" + _cConteudo + ""
	EndIf
ElseIf _aCpoSx3[_nPosArr,3]=="D"
	_cAux  := CTOD(_cConteudo)
	_cType := Type("_cAux")
	
	If _cType == "D" .And. !Empty(_cAux) .And. !Empty(_cConteudo)
		If _nCboTipo=="Parcial"
			cFiltra := "'" + AllTrim(_cConteudo) + "' $ " + cFiltra
		Else
			cFiltra += " == " + "'" + AllTrim(_cConteudo) + "'"
		EndIf
	ElseIf _cType <> "D" .Or. (Empty(_cAux) .And. !Empty(_cConteudo))
		MsgAlert("Formato inv�lido, para campo do tipo data utilize o seguinte formato DD/MM/AAAA!",_cRotina+"_001")
		cFiltra := ""
		Fechar() //Chama a fun��o respons�vel por fechar a janela de consulta avan�ada
	EndIf
EndIf

//Verifico se o filtro est� em formato condizente com o esperado
If Valtype(cFiltra) == "C" .AND. !Empty(cFiltra)
	
	bFiltraBrw := {|| FilBrowse(_cAlias,@aIndexSA1,@cFiltra)}
	Eval(bFiltraBrw)
	
	mBrowse( 6, 1,22,75,_cAlias)
EndIf

Fechar() //Chama a fun��o respons�vel por fechar a janela de consulta avan�ada

//Restauro a �rea de trabalho original
RestArea(_aSavSx3)
RestArea(_aSavArea)

Return()