#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE _CRLF CHR(13) + CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA030BRW  ºAutor  ³Júlio Soares        º Data ³  17/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada utilizado para apresentar teclas de atalhoº±±
±±º          ³ para diversas funções no Browse do Cadastro de Clientes.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º F2       ³ Abre Banco de conhecimento cliente.                        º±±
±±º F6       ³ Abre o Histórico de Cliente (SZD).                         º±±
±±º F7       ³ Abre o Histórico de Cobrança (SZC).                        º±±
±±º F8       ³ Abre o cadastro do cliente para alteração dos dados.       º±±
±±º F9       ³ Abre a tela de informações com os pedidos do cliente.      º±±
±±º F10      ³ Abre a tela de informações com os faturamentos do cliente. º±±
±±º F11      ³ Abre a ficha financeira (Específico Arcolor) conforme      º±±
±±º          ³ cliente posicionado.                                       º±±
±±º F12      ³ PADRÃO DO SISTEMA - NÃO ALTERAR                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRFATE058  ³ Fonte utilizado para atualizar a média de vendas e         º±±
±±º          ³ faturamento do cliente em um período de um ano. Essa rotinaº±±
±±º          ³ somente é executada uma vez por mês conforme parametrizaçãoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MA030BRW()

Local _aSavArea := GetArea()
Public _cRotina := 'MA030BRW'

If Type("aTmpFil")=="U"
	Public aTmpFil := {}
EndIf
If Type("aSelFil")=="U"
	Public aSelFil := {}
EndIf
If ExistBlock("RTMKC002")
	// DESATIVADO ALTERAÇÃO EM 21/08/15 POR JÚLIO SOARES APÓS SOLICITAÇÃO DO SR. MARIO
	SetKey(VK_F6 , { || U_RTMKC002() }) // - Tecla de atalho para abrir o Histórico de Clientes.
    // Teclas alterada em 19/08/15 por Júlio Soares para não conflitar com as teclas de atalho padrão.
	//SetKey( VK_F6,{|| MsgAlert( "Tecla [ F6 ] foi alterada para [ Ctrl + F6 ]" , "Protheus11" )})
	//SetKey( K_CTRL_F6, { || })
	//SetKey( K_CTRL_F6, { || U_RTMKC002()})
	RestArea(_aSavArea)
EndIf
If ExistBlock("RTMKC001")
	// DESATIVADO ALTERAÇÃO EM 21/08/15 POR JÚLIO SOARES APÓS SOLICITAÇÃO DO SR. MARIO
	SetKey(VK_F7 , { || U_RTMKC001() }) // - Tecla de atalho para abrir o Histórico de Cobrança.
    // Teclas alterada em 19/08/15 por Júlio Soares para não conflitar com as teclas de atalho padrão.
	//SetKey( VK_F7,{|| MsgAlert( "Tecla [ F7 ] foi alterada para [ Ctrl + F7 ]" , "Protheus11" )})
	//SetKey( K_CTRL_F7, { || })
	//SetKey( K_CTRL_F7, { || U_RTMKC001()})
	RestArea(_aSavArea)
EndIf
// DESATIVADO ALTERAÇÃO EM 21/08/15 POR JÚLIO SOARES APÓS SOLICITAÇÃO DO SR. MARIO
//SetKey(VK_F8 , { || _ALTER()      }) // - Tecla de atalho para abrir o cadastro para alterações
// Teclas alterada em 19/08/15 por Júlio Soares para não conflitar com as teclas de atalho padrão.
//SetKey( VK_F8,{|| MsgAlert( "Tecla [ F8 ] foi alterada para [ Ctrl + F8 ]" , "Protheus11" )})
//SetKey( K_CTRL_F8, { || })
//SetKey( K_CTRL_F8, { || _ALTER()})
RestArea(_aSavArea)
// DESATIVADO ALTERAÇÃO EM 21/08/15 POR JÚLIO SOARES APÓS SOLICITAÇÃO DO SR. MARIO
SetKey(VK_F9 , { || FICHCON("PED")}) // - Tecla de atalho para abrir os pedidos da consulta do cliente
// Teclas alterada em 19/08/15 por Júlio Soares para não conflitar com as teclas de atalho padrão.
//SetKey( VK_F9,{|| MsgAlert( "Tecla [ F9 ] foi alterada para [ Ctrl + F9 ]" , "Protheus11" )})
//SetKey( K_CTRL_F9, { || })
//SetKey( K_CTRL_F9, { || FICHCON("PED")})
RestArea(_aSavArea)
// DESATIVADO ALTERAÇÃO EM 21/08/15 POR JÚLIO SOARES APÓS SOLICITAÇÃO DO SR. MARIO
SetKey(VK_F10, { || FICHCON("FAT")}) // - Tecla de atalho para abrir os faturamentos da consulta do cliente
// Teclas alterada em 19/08/15 por Júlio Soares para não conflitar com as teclas de atalho padrão.
//SetKey( VK_F10,{|| MsgAlert( "Tecla [ F10 ] foi alterada para [ Ctrl + F10 ]" , "Protheus11" )})
//SetKey( K_CTRL_F10, { || })
//SetKey( K_CTRL_F10, { || FICHCON("FAT")})
RestArea(_aSavArea)
// DESATIVADO ALTERAÇÃO EM 21/08/15 POR JÚLIO SOARES APÓS SOLICITAÇÃO DO SR. MARIO
SetKey(VK_F11, { || FICHFINAN()   }) // - Tecla de atalho para abrir a ficha financeira (customizada) do cliente
// Teclas alterada em 19/08/15 por Júlio Soares para não conflitar com as teclas de atalho padrão.
//SetKey( VK_F11,{|| MsgAlert( "Tecla [ F11 ] foi alterada para [ Ctrl + F11 ]" , "Protheus11" )})
//SetKey( K_CTRL_F11, { || })
//SetKey( K_CTRL_F11, { || FICHFINAN()})
RestArea(_aSavArea)

//05/10/2015 - Chamada modificada para que
//MsgRun("Selecionando dados... Por favor AGUARDE. ",_cTitulo,{ || SelectQry() })	
//Processa({ || U_RFATE058() },"RFATE058"," Atualizando média dos clientes... Por favor aguarde.",.T.) 


//Tecla F2 para abertura do Banco de Conhecimento do cliente posicionado, inserido por Arthur Silva em 01/08/2016 conforme solicitação da Sra. Alecssandra

SetKey(VK_F2, { || MsDocument('SA1',Recno(),6)})
RestArea(_aSavArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ _Alter  ºAutor  ³Júlio Soares         º Data ³  23/12/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tecla de atalho para realizar a alteração do cadastro      º±±
±±º          ³ posicionado.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal.                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// - F8
Static Function _ALTER()
Local   _aSavArea := GetArea()
 
 
 dbSelectArea(_aSavArea)
If MSGBOX('Deseja alterar o cadastro do cliente '+Alltrim(SA1->A1_NOME)+'?',_cRotina + '_001','YESNO')
	A030Altera('SA1',(Recno()),3)
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FICHCON  ºAutor  ³Júlio Soares        º Data ³  23/12/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Abre a posicao do cliente.                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal.                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// - F9/F10
Static Function FICHCON(_Tp)

Local   _aSavArea := GetArea()
Local   _aSavSa1  := SA1->(GetArea())
Local   _aSavSc5  := SC5->(GetArea())
Local   _aSavSc9  := SC9->(GetArea())
Local   cCliente  := ""
Local   cLoja     := ""

DEFAULT _Tp       := "PED"

lPergunte     := Pergunte("FIC010",FunName()=="FINC010")		
nBrowse       := 0
aAlias        := {}
aGet          := {"","","","","","","",""}
aParam        := {}
lExibe        := .T. // - Informa se a pesquisa deve ser exibida.
lRelat        := .F. 
//Public nCasas := GetMv("MV_CENT")
nCasas        := SuperGetMv("MV_CENT",,"2")
If lPergunte .Or. FunName()<>"FINC010"
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
// Identifica por onde a rotina está sendo chamada para determinar os parâmetros do cliente posicionado
dbSelectArea("SC5")
SC5->(dbSetOrder(1))
If UPPER(AllTrim(FunName()))=="MATA030"      // Tela de cadastro de clientes
	cCliente := SA1->A1_COD
	cLoja    := SA1->A1_LOJA
ElseIf UPPER(Alltrim(FunName()))=="MATA450"  // Tela de análise de crédito do pedido
	If SC5->(MsSeek(xFilial("SC5") + SC9->C9_PEDIDO,.T.,.F.))
		cCliente := SC5->C5_CLIENTE
		cLoja    := SC5->C5_LOJACLI
	EndIf
ElseIf UPPER(Alltrim(FunName()))=="MATA450A" // Tela de análise de crédido do cliente
	cCliente := SA1->A1_COD
	cLoja    := SA1->A1_LOJA
EndIf
dbSelectArea("SA1")
SA1->(dbSetOrder(1))
If !Empty(cCliente) .AND. SA1->(MsSeek(xFilial("SA1") + cCliente + cLoja))
	If _Tp == "PED"
		nBrowse := 3
		aAlias  := {}
	//	Fc010Con(cAlias,nRecno,nOpcx) // - Apresenta a tela da posição do cliente
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
EndIf

RestArea(_aSavSc5)
RestArea(_aSavSc9)
RestArea(_aSavSa1)
RestArea(_aSavArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FICHFINAN ºAutor  ³Júlio Soares       º Data ³  17/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Execblock utilizado para montar a ficha financeira do      º±±
±±º          ³ cliente.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal.                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FICHFINAN()
// - F11
If ExistBlock("RFINE011")
	U_RFINE011("F11")
Else
	MSGBOX('FUNÇÃO NÃO ENCONTRADA. INFORME O ADMINISTRADOR DO SISTEMA!',_cRotina + '_002','ALERT')
EndIf

Return()
//Fc010Con() // - Apresenta a tela da posição do cliente
//A030Visual("SA1",SA1->(RecNo()),1) - Visualiza cadastro de cliente posicionado