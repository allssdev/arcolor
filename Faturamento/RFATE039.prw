#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ RFATE039 บ Autor ณAdriano Leonardo      บ Data ณ  18/03/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Rotina criada para permitir busca avan็ada na tela de      บฑฑ
ฑฑบ          ณ cadastro de clientes.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para a empresa Arcolor.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

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
Private _aCpoSX3 	:= {} //Posi็๕es do array - 1: Titulo, 2: Campo , 3: Tipo, 4: Tamanho, 5: Decimal
Static oDlg

If FunName()<>"MATA030" //Cadastro de clientes
	Return()
EndIf

//Inibe a tecla de atalho para prevenir duplicidade da abertura da janela
SetKey(VK_F5,{|| })

  DEFINE MSDIALOG oDlg TITLE "Busca Avan็ada" FROM 000, 000  TO 170, 600 COLORS 0, 16777215 PIXEL
	
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

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ RFATE039 บ Autor ณAdriano Leonardo      บ Data ณ  18/03/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsแvel por fechar a tela de busca avan็ada e   บฑฑ
ฑฑบ          ณ restaurar a tecla de atalho (F5).                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para a empresa Arcolor.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function Fechar()
	
	Close(oDlg)
	
	//Restaura a tecla de atalho ao fechar a janela de busca
	SetKey(VK_F5,{|| })
	SetKey(VK_F5,{|| U_RFATE039() })
	
Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ RFATE039 บ Autor ณAdriano Leonardo      บ Data ณ  18/03/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsแvel por selecionar quais campos serใo dispo-บฑฑ
ฑฑบ          ณ nibilizados para edi็ใo do filtro pelo usuแrio.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para a empresa Arcolor.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function ListarCampos()

Local _aSavArea	:= GetArea()
//Local _aSavSx3 	:= SX3->(GetArea())

_cAliasSX3 := "SX3_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
dbSelectArea(_cAliasSX3)
(_cAliasSX3)->(dbSetOrder(1))

If (_cAliasSX3)->(dbSeek(_cAlias))
	While ! (_cAliasSX3)->(EOF()) .And. (_cAliasSX3)->X3_ARQUIVO==_cAlias
		
		//Certifico que o campo ้ real e esteja disponํvel no browse
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

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ RFATE039 บ Autor ณAdriano Leonardo      บ Data ณ  18/03/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsแvel por aplicar o filtro do usuแrio na tela บฑฑ
ฑฑบ          ณ do atendimento do Call Center.                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para a empresa Arcolor.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function Filtrar()
         
Local _aSavArea		:= GetArea()
Local _aSavSx3		:= SX3->(GetArea())
Local aIndex 		:= {}
Local aCores2		:= IIF(ExistBlock("TK271COR"),U_TK271COR(),{}) //Ponto de entrada para manipula็ใo das cores da legenda do atendimento
Private aIndexSA1	:= {}
Static cFiltra 		:= ""

dbSelectArea(_cAlias)

_nPosArr := aScan(_aCpoSX3,{|x|AllTrim(x[01])==AllTrim(_nCboCampo)})

cFiltra := "AllTrim(" + _cAlias + "->" + AllTrim(_aCpoSx3[_nPosArr,2]) + ")"

If _aCpoSx3[_nPosArr,3]=="D"
	cFiltra := "DTOC(" + _cAlias + "->" + AllTrim(_aCpoSx3[_nPosArr,2]) + ")"
EndIf

//Posi็๕es do array - 1: Titulo, 2: Campo , 3: Tipo, 4: Tamanho, 5: Decimal
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
		MsgAlert("Formato invแlido, para campo do tipo data utilize o seguinte formato DD/MM/AAAA!",_cRotina+"_001")
		cFiltra := ""
		Fechar() //Chama a fun็ใo responsแvel por fechar a janela de consulta avan็ada
	EndIf
EndIf

//Verifico se o filtro estแ em formato condizente com o esperado
If Valtype(cFiltra) == "C" .AND. !Empty(cFiltra)
	
	bFiltraBrw := {|| FilBrowse(_cAlias,@aIndexSA1,@cFiltra)}
	Eval(bFiltraBrw)
	
	mBrowse( 6, 1,22,75,_cAlias)
EndIf

Fechar() //Chama a fun็ใo responsแvel por fechar a janela de consulta avan็ada

//Restauro a แrea de trabalho original
RestArea(_aSavSx3)
RestArea(_aSavArea)

Return()