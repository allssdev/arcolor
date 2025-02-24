#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณRFINE016  บAutor  ณJ๚lio Soares          บ Data ณ  20/03/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Monta tela da ficha financeira conforme dados solicitados  บฑฑ
ฑฑบ          ณ pelo cliente.                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico para a empresa Arcolor             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RFINE016(_cOrigem)

Local aArea      := GetArea()
Local _cRotina   := "RFINE016"
Local aStruSE2   := SE2->(dbStruct())
Local aDados     := {}
Local _aSize     := {}
Local cAliasTop  := "SE210"
Local cFornce    := ""
Local cLoja      := ""
Local _cLegen    := ""
Local cNFOrig    := ""
Local cQuery     := ""
Local nX, nPos

Private oDlg
Private oLbx
Private _o00     := LoadBitmap( GetResources(), "BR_MARROM"  )
Private _o01     := LoadBitmap( GetResources(), "BR_VERDE"   )
Private _o02     := LoadBitmap( GetResources(), "BR_BRANCO"  )
Private _o03     := LoadBitmap( GetResources(), "BR_AZUL"    )
Private _o04     := LoadBitmap( GetResources(), "BR_VERMELHO")
Private _o05     := LoadBitmap( GetResources(), "BR_PRETO"   )
Private _o06     := LoadBitmap( GetResources(), "BR_AMARELO" )
Private cPerg    := "FIC030"
Private _lEnt    := + CHR(13) + CHR(10)
Private _aTamDlg := MsAdvSize()

Default _cOrigem := ""

//SetKey(VK_F11, { || })

dbSelectArea("SE2")
_aSE2 := SE2->(GetArea())
dbSelectArea("SA2")
_aSA2 := SA2->(GetArea())
ValidPerg()
// validando o usuแrio que nใo precisa que a tela dos parโmetros seja apresentada.
If AllTrim(_cOrigem) == "F11" .OR. __cUserId $ SuperGetMV("MV_FICHFIN",,"000000")
	Pergunte(cPerg,.F.)
Else
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
EndIf
If Type("cFilAux")=="U"
	Public cFilAux := xFilial()
EndIf
// Identifica por onde a rotina estแ sendo chamada para determinar os parโmetros do cliente posicionado
If UPPER(AllTrim(FunName()))=="MATA020"      // Tela de cadastro de clientes
	cFornce := SA2->(A2_COD)
	cLoja   := SA2->(A2_LOJA)
ElseIf UPPER(Alltrim(FunName()))=="MATA450"  // Tela de anแlise de cr้dito do pedido
	cFornce := SC5->(C5_CLIENTE)
	cLoja   := SC5->(C5_LOJACLI)
ElseIf UPPER(Alltrim(FunName()))=="MATA450A" // Tela de anแlise de cr้dido do cliente
	cFornce := _cClir
	cLoja   := _cLojr
EndIf
dbSelectArea("SE2")
SE2->(dbSetOrder(1))
cQuery := " SELECT *, R_E_C_N_O_ RECSE2 "                                                       + _lEnt
cQuery += " FROM " + RetSqlName("SE2")+ " SE2 "                                                 + _lEnt
cQuery += " WHERE SE2.D_E_L_E_T_  = '' "                                                        + _lEnt
cQuery += "   AND SE2.E2_FILIAL   = '" + xFilial("SE2") + "' "                                  + _lEnt
cQuery += "   AND SE2.E2_FORNECE  = '" + cFornce + "' "                                         + _lEnt
cQuery += "   AND SE2.E2_LOJA     = '" + cLoja   + "' "                                         + _lEnt
cQuery += "   AND SE2.E2_EMISSAO BETWEEN '"+ DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' " + _lEnt
cQuery += "   AND SE2.E2_VENCREA BETWEEN '"+ DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' " + _lEnt
If MV_PAR05 == 2
	cQuery += "   AND SE2.E2_TIPO <> 'PR' "                                                     + _lEnt
EndIf
cQuery += " ORDER BY E2_VENCTO DESC, E2_EMISSAO DESC, E2_PREFIXO, E2_NUM, E2_PARCELA "          + _lEnt
//MemoWrite("\2.MemoWrite\"+_cRotina+"_cQuery_001.TXT",cQuery)
cQuery := ChangeQuery(cQuery)
MsAguarde({|| dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasTop,.F.,.T.)},"Aguarde...","Processando Tํtulos...")
For nX := 1 To Len(aStruSE2)
	If aStruSE2[nX][2] <> "C" .And. FieldPos(aStruSE2[nX][1]) <> 0
		TcSetField(cAliasTop,aStruSE2[nX][1],aStruSE2[nX][2],aStruSE2[nX][3],aStruSE2[nX][4])
	EndIf
Next nX
dbSelectArea(cAliasTop)
(cAliasTop)->(dbGoTop())
If (cAliasTop)->(EOF())
	Aviso("ATENวรO !","Nใo existem tํtulos para este fornecedor.",{" <<< &Voltar"},2,"Nใo hแ tํtulos!")
	(cAliasTop)->(dbCloseArea())
Else
	_aSize := {	02                              , ;
				TamSx3("E2_PREFIXO")[01]+15     , ;
				TamSx3("E2_NUM"    )[01]+25     , ;
				TamSx3("E2_PARCELA")[01]+10     , ;
				TamSx3("E2_TIPO"   )[01]+10     , ;
				TamSx3("E2_EMISSAO")[01]+25     , ;
				TamSx3("E2_VALOR"  )[01]+25     , ;
				TamSx3("E2_SALDO"  )[01]+25     , ;
				TamSx3("E2_VENCTO" )[01]+25     , ;
				TamSx3("E2_BAIXA"  )[01]+25     , ;
				TamSx3("E2_NUMBCO" )[01]+25     , ;
				TamSx3("E2_FORNECE")[01]+25     , ;
				TamSx3("E2_LOJA"   )[01]+25     , ;
				TamSx3("E2_NOMFOR" )[01]+25     , ;
				10                                }
	While !(cAliasTop)->(EOF())
		_cLeg := "00"
		If (cAliasTop)->E2_SALDO == (cAliasTop)->E2_VALOR .AND. Empty((cAliasTop)->E2_BAIXA) .AND. !AllTrim((cAliasTop)->E2_TIPO) $ "PA/NDF"
			_cLeg := "01"		//VERDE    - Tํtulo em Aberto
		ElseIf (cAliasTop)->E2_SALDO == (cAliasTop)->E2_VALOR .AND. Empty((cAliasTop)->E2_BAIXA) .AND. AllTrim((cAliasTop)->E2_TIPO) $ "PA/NDF"
			_cLeg := "02"		//BRANCO   - Tํtulo do tipo NDF ou PA, em aberto
		ElseIf (cAliasTop)->E2_SALDO > 0 .AND. (cAliasTop)->E2_SALDO < (cAliasTop)->E2_VALOR
			_cLeg := "03"		//AZUL     - Tํtulo baixado parcialmente
		ElseIf (cAliasTop)->E2_SALDO == 0 .AND. !AllTrim((cAliasTop)->E2_TIPO) $ "PA/NDF"
			_cLeg := "04"		//VERMELHO - Titulo totalmente baixado
		ElseIf (cAliasTop)->E2_SALDO == 0 .AND. AllTrim((cAliasTop)->E2_TIPO) $ "PA/NDF"
			_cLeg := "05"		//PRETO    - Tํtulo a receber com baixa total por compensa็ใo com um NDF ou o pr๓prio tํtulo do tipo NDF que encontra-se totalmente baixado (resolvido).
		EndIf
		aAdd(aDados,{	_cLeg                                              , ;
						(cAliasTop)->E2_PREFIXO                            , ;
						(cAliasTop)->E2_NUM                                , ;
						(cAliasTop)->E2_PARCELA                            , ;
						(cAliasTop)->E2_TIPO                               , ;
						(cAliasTop)->E2_EMISSAO                            , ;
						(cAliasTop)->E2_VALOR                              , ;
						(cAliasTop)->E2_SALDO                              , ;
						(cAliasTop)->E2_VENCTO                             , ;
						(cAliasTop)->(IIF(E2_SALDO == 0,E2_BAIXA,STOD(""))), ;
						(cAliasTop)->E2_NUMBCO                             , ;
						(cAliasTop)->E2_FORNECE                            , ;
						(cAliasTop)->E2_LOJA                               , ;
						(cAliasTop)->E2_NOMFOR                             , ;
						(cAliasTop)->RECSE2 } )
		(cAliasTop)->(dbSkip())
	EndDo
	(cAliasTop)->(dbCloseArea())
/*
[1] Linha inicial แrea trabalho
[2] Coluna inicial แrea trabalho
[3] Linha final แrea trabalho
[4] Coluna final แrea trabalho
[5] Coluna final dialog (janela)
[6] Linha final dialog (janela)
[7] Linha inicial dialog (janela)
*/
//	Define MsDialog oDlg Title "Ficha Financeira - (Perํodo de " + DtoC(mv_par01) + " a " + DtoC(mv_par02) + ")" From  0, 0 To 500,1200 Colors 0, 16777215 Pixel STYLE DS_MODALFRAME// Inibe o botao "X" da tela
	Define MsDialog oDlg Title "Ficha Financeira - (Perํodo de " + DtoC(mv_par01) + " a " + DtoC(mv_par02) + ")" From  (_aTamDlg[1]), (_aTamDlg[2]) To (_aTamDlg[6]-50),(_aTamDlg[5]-225) Colors 0, 16777215 Pixel STYLE DS_MODALFRAME// Inibe o botao "X" da tela
	oDlg:lEscClose := .F.//Nใo permite fechar a tela com o "Esc"

	@ (_aTamDlg[1]+05), (_aTamDlg[1] + 05) ListBox oLbx Fields Header	"  ",;
										OemToAnsi("Prfx"       ),;
										OemToAnsi("Titulo"     ),;
										OemToAnsi("Parc"       ),;
										OemToAnsi("Tipo"       ),;
										OemToAnsi("Emiss"      ),;
										OemToAnsi("Valor Orig."),;
										OemToAnsi("Saldo"      ),;
										OemToAnsi("Vencimento" ),;
										OemToAnsi("Dt Pagto"   ),;
										OemToAnsi("Nosso Num"  ),;
										OemToAnsi("Fornecedor" ),;
										OemToAnsi("Loja"       ),;
										OemToAnsi("Nome"       ) ;
										Size (_aTamDlg[6]-55),(_aTamDlg[5]-675) Pixel
		//								Size (_aTamDlg[6]-75),(_aTamDlg[5]-675) Pixel
  		oLbx:SetArray(aDados)
		oLbx:bLine := {|| { &("_o" + AllTrim(aDados[oLbx:nAT,01])),;
											(aDados[oLbx:nAT,02]), ;
											(aDados[oLbx:nAT,03]), ;
											(aDados[oLbx:nAT,04]), ;
											(aDados[oLbx:nAT,05]), ;
										DTOC(aDados[oLbx:nAt,06]), ;
							  Padl(Transform(aDados[oLbx:nAT,07],"@E 999,999,999.99"),TamSx3("E2_VALOR")[01]), ;
							  Padl(Transform(aDados[oLbx:nAT,08],"@E 999,999,999.99"),TamSx3("E2_SALDO")[01]), ;
										DTOC(aDados[oLbx:nAT,09]), ;
										DTOC(aDados[oLbx:nAT,10]), ;
											(aDados[oLbx:nAT,11]), ;
											(aDados[oLbx:nAT,12]), ;
											(aDados[oLbx:nAT,13]), ;
											(aDados[oLbx:nAT,14]), ;
											(aDados[oLbx:nAT,15])} }

	//Fa050Legenda("SE2")
	Define SButton From (_aTamDlg[3]-150),280 Type 15 Enable Of oDlg Action {||SE2->(dbGoTo(aDados[oLbx:nAT,15])),FC050Con()}
	Define SButton From (_aTamDlg[3]-180),310 Type 01 Enable Of oDlg Action ( oDlg:End())
	oLbx:ACOLSIZES := aClone(_aSize)
	Activate MsDialog oDlg Centered
EndIf

RestArea(_aSA2)
RestArea(_aSE2)
RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg บAutor  ณJ๚lio Soares        บ Data ณ  10/10/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa para informar os parโmetros da rotina a ser       บฑฑ
ฑฑบ          ณ utilizada pela rotina principal                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ValidPerg()        

Local _aAlias := GetArea()
Local aRegs   := {}

cPerg         := PADR(cPerg,10)   //FINC030

AADD(aRegs,{cPerg,"01","Da Emissao ?                  ","","","mv_ch1","D",08,0,0,"G","","mv_emis_de" ,""               ,""                ,""               ,"","",""             ,""             ,""           ,"","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Ate a Emissao ?               ","","","mv_ch2","D",08,0,0,"G","","mv_emis_ate",""               ,""                ,""               ,"","",""             ,""             ,""           ,"","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Do Vencimento ?               ","","","mv_ch3","D",08,0,0,"G","","mv_ven_de"  ,""               ,""                ,""               ,"","",""             ,""             ,""           ,"","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Ate o Vencimento ?            ","","","mv_ch4","D",08,0,0,"G","","mv_ven_ate" ,""               ,""                ,""               ,"","",""             ,""             ,""           ,"","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"05","Considera Provisor. ?         ","","","mv_ch5","N",01,0,1,"C","","mv_par05"   ,"Sim"            ,"Si"              ,"Yes"            ,"","","Nao"          ,"No"           ,"No"         ,"","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"06","Considera Faturados ?         ","","","mv_ch6","N",01,0,1,"C","","mv_par06"   ,"Sim"            ,"Si"              ,"Yes"            ,"","","Nao"          ,"No"           ,"No"         ,"","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"07","Considera Pedidos de Compra ? ","","","mv_ch7","N",01,0,1,"C","","mv_par07"   ,"Todos"          ,"Todos"           ,"All"            ,"","","Em Aberto"    ,"Pendiente(s)" ,"Pending"    ,"","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"08","Historico completo ?          ","","","MV_Ch8","N",01,0,1,"C","","mv_par08"   ,"Sim"            ,"Si"              ,"Yes"            ,"","","Nao"          ,"No"           ,"No"         ,"","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"09","Conv.mov. na moeda sel.pela ? ","","","MV_CH9","N",01,0,1,"C","","mv_par09"   ,"Data Movimento" ,"Fecha Movimient" ,"Transaction Dt" ,"","","Data de Hoje" ,"Fecha de Hoy" ,"Todayดs Dt" ,"","","","","","","","","","","","","","","","","","","",""})

For i := 1 To Len(aRegs)
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If !SX1->(MsSeek(cPerg+aRegs[i,2]))
		RecLock("SX1",.T.)
		For j := 1 To FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Else              
				Exit
			EndIf
		Next
		SX1->(MsUnlock())
	EndIf
Next

RestArea(_aAlias)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFechar    บAutor  ณJulio Soares        บ Data ณ  20/03/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ NรO UTILIZADO                                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal  -  DESATIVADO                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Fechar()

oDlg:End()

// DESATIVADO ALTERAวรO EM 21/08/15 POR JฺLIO SOARES APำS SOLICITAวรO DO SR. MARIO
SetKey(VK_F11, { || FICHAFINAN() })
// Teclas alterada em 19/08/15 por J๚lio Soares para nใo conflitar com as teclas de atalho padrใo.
//SetKey( VK_F11,{|| MsgAlert( "Tecla [ F11 ] foi alterada para [ Ctrl + F11 ]" , "Protheus11" )})
//SetKey( K_CTRL_F11, { || })
//SetKey( K_CTRL_F11, { || FICHAFINAN()})

Return()