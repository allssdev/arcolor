#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM450AROT  บAutor  ณJ๚lio Soares        บ Data ณ  17/10/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada para adi็ใo de bot๕es na tela de anแlise  บฑฑ
ฑฑบ          ณde cr้dito do pedido/cliente.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ F8       ณ Abre o cadastro do cliente para altera็ใo dos dados.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ F9       ณ Abre a tela de informa็๕es com os pedidos do cliente.      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ F10      ณ Abre a tela de informa็๕es com os faturamentos do cliente. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ F11      ณ Abre a ficha financeira (Especํfico Arcolor) conforme      บฑฑ
ฑฑบ          ณ cliente posicionado.                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para a empresa Arcolor.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
// - Analise de Cr้dito do cliente.
User Function M450AROT()

Local _aSavArea := GetArea()

Public _cRotina := 'M450AROT'

If Type("aTmpFil")=="U"
	Public aTmpFil := {}
EndIf
If Type("aSelFil")=="U"
	Public aSelFil := {}
EndIf

// DESATIVADO ALTERAวรO EM 21/08/15 POR JฺLIO SOARES APำS SOLICITAวรO DO SR. MARIO
SetKey(VK_F8 , { || _ALTER()      }) // - Tecla de atalho para abrir o cadastro para altera็๕es
// Teclas alterada em 19/08/15 por J๚lio Soares para nใo conflitar com as teclas de atalho padrใo.
//SetKey( VK_F8,{|| MsgAlert( "Tecla [ F8 ] foi alterada para [ Ctrl + F8 ]" , "Protheus11" )})
//SetKey( K_CTRL_F8, { || })
//SetKey( K_CTRL_F8, { || _ALTER()})
RestArea(_aSavArea)

// DESATIVADO ALTERAวรO EM 21/08/15 POR JฺLIO SOARES APำS SOLICITAวรO DO SR. MARIO
SetKey(VK_F9 , { || FICHCON("PED")}) // - Tecla de atalho para abrir os pedidos da consulta do cliente
// Teclas alterada em 19/08/15 por J๚lio Soares para nใo conflitar com as teclas de atalho padrใo.
//SetKey( VK_F9,{|| MsgAlert( "Tecla [ F9 ] foi alterada para [ Ctrl + F9 ]" , "Protheus11" )})
//SetKey( K_CTRL_F9, { || })
//SetKey( K_CTRL_F9, { || FICHCON("PED")})
RestArea(_aSavArea)

// DESATIVADO ALTERAวรO EM 21/08/15 POR JฺLIO SOARES APำS SOLICITAวรO DO SR. MARIO
SetKey(VK_F10, { || FICHCON("FAT")}) // - Tecla de atalho para abrir os faturamentos da consulta do cliente
// Teclas alterada em 19/08/15 por J๚lio Soares para nใo conflitar com as teclas de atalho padrใo.
//SetKey( VK_F10,{|| MsgAlert( "Tecla [ F10 ] foi alterada para [ Ctrl + F10 ]" , "Protheus11" )})
//SetKey( K_CTRL_F10, { || })
//SetKey( K_CTRL_F10, { || FICHCON("FAT")})
RestArea(_aSavArea)

// DESATIVADO ALTERAวรO EM 21/08/15 POR JฺLIO SOARES APำS SOLICITAวรO DO SR. MARIO
SetKey(VK_F11, { || FICHFINAN()   }) // - Tecla de atalho para abrir a ficha financeira (customizada) do cliente
// Teclas alterada em 19/08/15 por J๚lio Soares para nใo conflitar com as teclas de atalho padrใo.
//SetKey( VK_F11,{|| MsgAlert( "Tecla [ F11 ] foi alterada para [ Ctrl + F11 ]" , "Protheus11" )})
//SetKey( K_CTRL_F11, { || })
//SetKey( K_CTRL_F11, { || FICHFINAN()})
RestArea(_aSavArea)

//SetKey(VK_F10, { || AltCli()})
//SetKey(VK_F11, { || MA030BRWA()})

//Inํcio - Trecho adicionado por Adriano Leonardo 17/07/2014
If ExistBlock("RFINE021") //Rotina de Adiantamentos (Pedido de venda)
	//	SetKey(VK_F6, { || U_RFINE021(.T.)    })
	// Teclas alterada em 19/08/15 por J๚lio Soares para nใo conflitar com as teclas de atalho padrใo.
	SetKey( VK_F6,{|| MsgAlert( "Tecla [ F6 ] foi alterada para [ Ctrl + F6 ]" , "Protheus11" )})
	SetKey( K_CTRL_F6, { || })
	SetKey( K_CTRL_F6, { || U_RFINE021(.T.)})

	//ValidPerg() //Chama fun็ใo de parโmetros da rotina de adintamentos (customizada)

	//SetKey(VK_F12,{ || Pergunte(cPerg,.T.)})
    // Teclas alterada em 19/08/15 por J๚lio Soares para nใo conflitar com as teclas de atalho padrใo.
	SetKey( VK_F12,{|| MsgAlert( "Tecla [ F12 ] foi alterada para [ Ctrl + F12 ]" , "Protheus11" )})
	SetKey( K_CTRL_F12, { || })
	SetKey( K_CTRL_F12, { || IIF(Type("cPerg")=="U",Pergunte('MA450MNU',.T.),Pergunte(cPerg,.T.))})
EndIf
//Final  - Trecho adicionado por Adriano Leonardo 17/07/2014

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ _ALTER   บAutor  ณJ๚lio Soares        บ Data ณ  17/10/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Altera o cadastro do cliente dentro da rotina de analise deบฑฑ
ฑฑบ          ณ cr้dito do cliente atrav้s da tecla de atalho F10.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
Static Function _ALTER()

If MSGBOX('Deseja alterar o cadastro do cliente '+_cNome+'?',_cRotina + '_001','YESNO')
	A030Altera('SA1',(Recno()),3)
Endif

Return()
*/
Static Function _ALTER()

Local _aSavArea  := GetArea()
Local _lIncui    := INCLUI
Local _lAltera   := ALTERA

Private _cCli    := A1_COD
Private _cLoja   := A1_LOJA
Private _cNome   := A1_NOME
Private aRotAuto := Nil

dbSelectArea("SA1")
_aSavSA1 := SA1->(GetArea())
SA1->(dbSetOrder(1))
If MSGBOX('Deseja alterar o cadastro do cliente '+ Alltrim(_cNome) +'?',_cRotina + '_001','YESNO')
	If SA1->(MsSeek(xFilial("SA1")+_cCli+_cLoja,.T.,.F.))
		nReg   := SA1->(Recno())
		INCLUI := .F.
		ALTERA := .T.
	//	A030Altera("SA1",nReg,4)
		AxAltera("SA1",nReg,4)
	Else
		MSGBOX('Cliente' + _cCli +' - ' + Alltrim(_cNome) + ' Nใo encontrado, INFORME O ADMINISTRADOR DO SISTEMA.',_cRotina + '_002','ALERT')
	EndIf
	INCLUI := _lIncui
	ALTERA := _lAltera
Endif

RestArea(_aSavSA1 )
RestArea(_aSavArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FICHCON  บAutor  ณJ๚lio Soares        บ Data ณ  23/12/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
// - F9/F10
Static Function FICHCON(_Tp)

Local   _aSavArea := GetArea()
Private _cCli     := A1_COD
Private _cLoja    := A1_LOJA
Private _cNome    := A1_NOME

DEFAULT _Tp := "PED"

lPergunte := Pergunte("FIC010",FunName()=="FINC010")		
nBrowse   := 0
aAlias    := {}
aGet      := {"","","","","","","",""}
aParam    := {}
lExibe    := .T. // - Informa se a pesquisa deve ser exibida.
lRelat    := .F. 
//Public nCasas    := GetMv("MV_CENT")
nCasas    := SuperGetMv("MV_CENT",,"2")

If lPergunte .OR. FunName()<>"FINC010"
	aadd(aParam,MV_PAR01)
	aadd(aParam,MV_PAR02)
	aadd(aParam,MV_PAR03)
	aadd(aParam,MV_PAR04)
	aadd(aParam,MV_PAR05)                   
	aadd(aParam,MV_PAR06)
	aadd(aParam,MV_PAR07)
	aadd(aParam,MV_PAR08)
	aadd(aParam,MV_PAR09)
	aadd(aParam,MV_PAR10)
	aadd(aParam,MV_PAR11)
	aadd(aParam,MV_PAR12)
	aadd(aParam,MV_PAR13)
	aadd(aParam,MV_PAR14)
	aadd(aParam,MV_PAR15)
EndIf
If UPPER(AllTrim(FunName())) == "MATA450"
	dbSelectArea("SC9")
	If !SC9->(EOF)
		_cCli  := SC9->C9_CLIENTE
		_cLoja := SC9->C9_LOJA
	EndIf
EndIf
dbSelectArea('SA1')
SA1->(dbSetOrder(1))
//If MsSeek(xFilial("SA1")+_cCli+_cLoja,.T.,.F.)
If SA1->(dbSeek(xFilial("SA1")+_cCli+_cLoja,.T.))
	If _Tp == "PED"
		nBrowse := 3
		aAlias  := {}
	//	Fc010Con(cAlias,nRecno,nOpcx) // - Apresenta a tela da posi็ใo do cliente
		Fc010Brow(nBrowse,@aAlias,aParam,.T.,aGet)
		For _x := 1 To Len(aAlias)
			dbSelectArea(aAlias[_x][01])
			(aAlias[_x][01])->(dbCloseArea())
			If File(aAlias[_x][02]+OrdBagExt())
				FErase(aAlias[_x][02]+OrdBagExt())
			EndIf
		Next
		nBrowse := 0
		aAlias  := {}
		aParam  := {}	
	ElseIf _Tp == "FAT"
		nBrowse := 4
		aAlias  := {}
		Fc010Brow(nBrowse,@aAlias,aParam,.T.,aGet)
		For _x := 1 To Len(aAlias)
			dbSelectArea(aAlias[_x][01])
			(aAlias[_x][01])->(dbCloseArea())
			If File(aAlias[_x][02]+OrdBagExt())
				FErase(aAlias[_x][02]+OrdBagExt())
			EndIf
		Next
		nBrowse := 0
		aAlias  := {}
		aParam  := {}
	EndIf
Else
	MSGBOX('Cliente nใo encontrado',_cRotina+'_003','INFO')
EndIf
RestArea(_aSavArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FICHFINANบAutor  ณJ๚lio Soares        บ Data ณ  17/10/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Execblock utilizado para montar a ficha financeira do      บฑฑ
ฑฑบ          ณ cliente.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FICHFINAN()

Local _aSvArea := GetArea()
Local _aSvSA1  := SA1->(GetArea())
Local _aSvSC5  := SC5->(GetArea())
Local _aSvSC9  := SC9->(GetArea())

If Alias() == "SC5"
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	SA1->(MsSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
ElseIf Alias() == "SC9"
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	SA1->(MsSeek(xFilial("SA1") + SC9->C9_CLIENTE + SC9->C9_LOJA,.T.,.F.))
ElseIf Alias() == "TRB"
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	SA1->(MsSeek(xFilial("SA1") + TRB->A1_COD + TRB->A1_LOJA,.T.,.F.))
EndIf

Public _cClir := SA1->A1_COD
Public _cLojr := SA1->A1_LOJA
Public _cNomr := SA1->A1_NOME
Public _cCGCr := SA1->A1_CGCCENT

If ExistBlock("RFINE011")
	ExecBlock("RFINE011")
Else
	MSGBOX('FUNวรO NรO ENCONTRADA. INFORME O ADMINISTRADOR DO SISTEMA!',_cRotina + '_004','ALERT')
EndIf

_cClir := ''
_cLojr := ''
_cNomr := ''
_cCGCr := ''

RestArea(_aSvSC5)
RestArea(_aSvSC9)
RestArea(_aSvSA1)
RestArea(_aSvArea)

Return()