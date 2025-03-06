#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณRFATR017  บ Autor ณJ๚lio Soares          บ Data ณ  04/10/13 บฑฑ
ฑฑบPrograma  ณQuery     บ Autor ณJ๚lio Soares          บ Data ณ  13/01/14 บฑฑ
ฑฑบPrograma  ณClasse    บ Autor ณJ๚lio Soares          บ Data ณ  30/01/14 บฑฑ
ฑฑบPrograma  ณRFATR017  บ Autor ณAnderson C. P. Coelho บ Data ณ  30/01/14 บฑฑ
ฑฑบPrograma  ณEstoque   บ Autor ณJ๚lio Soares          บ Data ณ  06/03/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Relat๓rio de rela็ใo de faturamento totalizado por produto,บฑฑ
ฑฑบ          ณ por cliente, por vendedor, por estado e por emissใo        บฑฑ
ฑฑบ          ณ conforme informa็๕es dos parโmetros solicitados.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบQuery     ณ Foi realizado tratamento na Query na altera็ใo de filtros  บฑฑ
ฑฑบ          ณ devido diverg๊ncia nos valores faturados devido o tipo de  บฑฑ
ฑฑบ          ณ divisใo na quebra do item.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบClasse    ณ Foi realizada a reestrutura็ใo do relat๓rio sendo alterado บฑฑ
ฑฑบ          ณ a classe de constru็ใo do mesmo para melhoria de           บฑฑ
ฑฑบ          ณ funcionalidade na exporta็ใo para Excel, melhoria de layoutบฑฑ
ฑฑบ          ณ e melhoria de desempenho.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบEstoque   ณ Alterado forma de tratamento para quantidades de estoque   บฑฑ
ฑฑบ          ณ para itens dos documentos importados.                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para empresa ARCOLOR              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RFATR017()

Local   _aSavArea  := GetArea()
Private _cRotina   := "RFATR017"
Private cPerg      := _cRotina
Private _cTitulo   := ""
Private _cTitulo2  := ""
Private _cQuery    := ""
Private _tAlias	   := "TMPRFT17"
Private _cTempo    := ""
Private _aCpos     := {}		//Campos a serem atualizados
Private _lEnt      := + CHR(13) + CHR(10)
Private _lRet      := .T.
Private aSizFrm    := MsAdvSize()

// - TELA DE PARยMETROS
ValidPerg()

//If __cUserID == '000000'
	U_SELMARQ()
//EndIf
//MsgRun("Selecionando cadastro de clientes... Por favor AGUARDE. ",_cTitulo,{|| U_RFATE045()})
//	U_RFATE045()
//Selecao()
// - INICIO DO MARK

IF !Pergunte(cPerg,.T.)
	If MsgYesNo("Deseja cancelar a emissใo do relat๓rio?",_cRotina+"_01")
//		MSGBOX("Fun็ใo cancelada pelo usuแrio!",'CANCELADO','STOP')
		Return()
	EndIf
ENDIF
_cTempo := "Inicio: " + DTOC(Date()) + " - " + Time() + CHR(13) + CHR(10)
// - VERIFICA SE USUมRIO TEM PERMISSรO PARA GERAR DADOS EM EXCEL
If !(SubStr(cAcesso,160,1) == "S" .AND. SubStr(cAcesso,168,1) == "S" .AND. SubStr(cAcesso,170,1) == "S")
	MSGBOX('Usuแrio sem permissใo para gerar relat๓rio em Excel. Informe o Administrador.',_cRotina +"02",'STOP')
   Return(Nil)
EndIf
// - VERIFICA SE Hม O EXCEL INSTALADO NA MมQUINA EM USO
If __cUserID <> '000000'
	If !ApOleClient('MsExcel')
		Msgbox('Excel nใo instalado.',_cRotina +"03",'ALERT')
	   Return(Nil)
	EndIf
EndIf
_cTitulo  := ("Rela็ใo de " + (IIf (MV_PAR18 == 1,'Faturamento',(IIf (MV_PAR18 == 2,'Devolu็ใo','Ambos')))) + " - " +;
(IIf (MV_PAR19 == 1,'Sint้tico','Analํtico')) + " - de " + (DTOC(mv_par01)) + " at้ " + (DTOC(mv_par02)) + " - " + _cRotina)
_cTitulo2 := ("PARยMETROS")

// CHAMA FUNวรO DE CONSULTA CONFORME PARยMETROS DEFINIDO PELO USUมRIO
//Processa({|| SelectQry()},_cTitulo,"Selecionando dados... Por favor AGUARDE. ",.T.)
MsgRun("Selecionando dados... Por favor AGUARDE. ",_cTitulo,{ || SelectQry() })

// - CHAMA A FUNวรO PARA EMITIR OS DADOS EM PLANILHA
Processa({ || Geraxls() },_cRotina,' Gerando relat๓rio em Excel...   Por favor aguarde.',.T.)
//MsgRun(" Gerando relat๓rio em Excel...   Por favor aguarde.",_cRotina,{ || Geraxls() })

// - SE A TABELA APRESENTAR DADOS FECHA A MESMA APำS O USO
If Select (_tAlias) > 0
   (_tAlias)->(dbCloseArea())
EndIf

dbCloseArea(_tAlias)

RestArea(_aSavArea)

_cTempo += "Termino: " + DTOC(Date()) + " - " + Time()

If __cUserId == "000000"
	Alert("Tempo computado: " + CHR(13) + CHR(10) + _cTempo)
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ RFATR017  บ Autor ณJ๚lio Soares         บ Data ณ  04/10/13 บฑฑ
ฑฑบPrograma  ณ RFATR017  บ Autor ณJ๚lio Soares         บ Data ณ  13/01/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsแvel pela sele็ใo dos dados a partir da      บฑฑ
ฑฑบ          ณ consulta .                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ Implementado ajustes na consulta.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para empresa ARCOLOR              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SelectQry()


//DESCOBRIR FORMA DE CONTAR OS MESES
//Private _cNumMes   := ''

Local _aSelect := {}
Local _cQuery  := ""		//Query final
Local _cEmSD1  := " AND SD1.D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "	+_lEnt	//Para o filtro de/ate data (SD1)
Local _cEmSD2  := " AND SD2.D2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "	+_lEnt	//Para o filtro de/ate data (SD2)
Local _cSelFat := ""		//Select Faturamento
Local _cQryFat := ""		//Query  Faturamento
Local _cGrpFat := ""		//Group  Faturamento
Local _cOrdFat := ""		//Order  Faturamento

Local _cSlFtDv := ""		//Select Faturamento para as Devolucoes

Local _cSelDev := ""		//Select Devolucao
Local _cQryDev := ""		//Query  Devolucao
Local _cGrpDev := ""		//Group  Devolucao
Local _cOrdDev := ""		//Order  Devolucao
/*
_cDeMes    := SUBSTR(DTOS(MV_PAR01),5,2)
_cAteMes   := SUBSTR(DTOS(MV_PAR02),5,2)
_cMesAux   := SUBSTR(DTOS(MV_PAR01),5,2)
_dMeses    := {'01','02','03','04','05','06','07','08','09','10','11','12'}
_cNomMes   := {}
	AAdd(_cNomMes,{'01','JAN/'})
	AAdd(_cNomMes,{'02','FEV/'})
	AAdd(_cNomMes,{'03','MAR/'})
	AAdd(_cNomMes,{'04','ABR/'})
	AAdd(_cNomMes,{'05','MAI/'})
	AAdd(_cNomMes,{'06','JUN/'})
	AAdd(_cNomMes,{'07','JUL/'})
	AAdd(_cNomMes,{'08','AGO/'})
	AAdd(_cNomMes,{'09','SET/'})
	AAdd(_cNomMes,{'10','OUT/'})
	AAdd(_cNomMes,{'11','NOV/'})
	AAdd(_cNomMes,{'12','DEZ/'})
_nAnoAux := SUBSTR(DTOS(MV_PAR01),1,4)
_nNumMeses := 12
*/
/*
_nPosArr := aScan(_dMeses,_cMesAux)
	
For _nCont := 1 To _nNumMeses
	_cMesAux  := _dMeses[_nPosArr]
	_cMesAno  := AllTrim((_nAnoAux)) + _cMesAux
	_cAnoBase := AllTrim((_nAnoAux-1)) + _cMesAux	
	If _nPosArr == 01
		_nPosArr := 12
		_cMesAux := _dMeses[_nPosArr]
		_nAnoAux++
	Else
		_nPosArr--
	EndIf
Next	
*/


//Construcao da ordem dos campos do Excel
If (MV_PAR19) == 2 .OR. (MV_PAR03) == 2
	AADD(_aCpos,{"EMISSAO"       ,"(_tAlias)->EMISSAO" ,2,4,.F.})
EndIf
If (MV_PAR19) == 2 .OR. !Empty(MV_PAR09)
	AADD(_aCpos,{"ESTADO"        ,"(_tAlias)->ESTADO"  ,2,1,.F.})
EndIf
If (MV_PAR19) == 2 .OR. !Empty(MV_PAR11)

	// Altera็ใo - Fernando Bombardi - ALLSS - 02/03/2022
	AADD(_aCpos,{"REPRESENTANTE" ,"(_tAlias)->VENDEDOR",2,1,.F.})
	AADD(_aCpos,{"NOME REP."     ,"(_tAlias)->DESCVEND",1,1,.F.})

	//AADD(_aCpos,{"VENDEDOR"      ,"(_tAlias)->VENDEDOR",2,1,.F.})
	//AADD(_aCpos,{"NOME VEND."    ,"(_tAlias)->DESCVEND",1,1,.F.})
	// Fim - Fernando Bombardi - ALLSS - 02/03/2022

EndIf

If (MV_PAR19) == 2 .OR. (!Empty(MV_PAR06) .AND. !Empty(MV_PAR07))
// ADICIONADO EM 05/02 2014
	AADD(_aCpos,{"CNPJ_CENT"     ,"(_tAlias)->CNPJ_CENT",2,1,.F.})
	AADD(_aCpos,{"CNPJ"          ,"(_tAlias)->CNPJ"     ,2,1,.F.})
	AADD(_aCpos,{"CLIENTE"       ,"(_tAlias)->CLIENTE"  ,2,1,.F.})
	AADD(_aCpos,{"LOJA"          ,"(_tAlias)->LOJA"     ,2,1,.F.})
	AADD(_aCpos,{"NOME"          ,"(_tAlias)->NOME"     ,1,1,.F.})
EndIf

AADD(_aCpos,{"FAMILIA"           ,"(_tAlias)->FAMILIA" ,2,1,.F.})

If (MV_PAR19) == 2
	AADD(_aCpos,{"DOCUMENTO"     ,"(_tAlias)->DOC"     ,1,1,.F.})
	AADD(_aCpos,{"SษRIE"         ,"(_tAlias)->SERIE"   ,1,1,.F.})
EndIf

AADD(_aCpos,{"PRODUTO"           ,"(_tAlias)->CODIGO"  ,2,1,.F.})
AADD(_aCpos,{"DESCRIวรO"         ,"(_tAlias)->PRODUTO" ,1,1,.F.})
AADD(_aCpos,{"TIPO"              ,"(_tAlias)->TIPO"    ,1,1,.F.})
AADD(_aCpos,{"1ฐUM"              ,"(_tAlias)->UM"      ,2,1,.F.})

If (MV_PAR18) == 1 .OR. (MV_PAR18) == 3
	AADD(_aCpos,{"QTD.FAT.(1ฐUM)","(_tAlias)->QTD_FAT" ,3,2,.T.})
EndIf

If (MV_PAR18) == 2 .OR. (MV_PAR18) == 3
	AADD(_aCpos,{"QTD.DEV.(1ฐUM)","(_tAlias)->QTD_DEV" ,3,2,.T.})
EndIf

AADD(_aCpos,{"2ฐUM"              ,"(_tAlias)->UM2"     ,2,1,.F.})

If (MV_PAR18) == 1 .OR. (MV_PAR18) == 3
	AADD(_aCpos,{"QTD.FAT.(2ฐUM)","(_tAlias)->QTD2_FAT",3,2,.T.})
EndIf

If (MV_PAR18) == 2 .OR. (MV_PAR18) == 3
	AADD(_aCpos,{"QTD.DEV.(2ฐUM)","(_tAlias)->QTD2_DEV",3,2,.T.})
EndIf

AADD(_aCpos,{"UM.COM"        ,"(_tAlias)->UMCOM"       ,2,1,.F.})

If (MV_PAR18) == 1 .OR. (MV_PAR18) == 3
	AADD(_aCpos,{"PESO COM. FAT.","(_tAlias)->PCOM_FAT",3,2,.T.})
EndIf

If (MV_PAR18) == 2 .OR. (MV_PAR18) == 3
	AADD(_aCpos,{"PESO COM. DEV.","(_tAlias)->PCOM_DEV",3,2,.T.})
EndIf

If (MV_PAR18) == 1 .OR. (MV_PAR18) == 3
	AADD(_aCpos,{"VAL.FAT."      ,"(_tAlias)->VAL_FAT" ,3,2,.T.})
EndIf

If (MV_PAR18) == 2 .OR. (MV_PAR18) == 3
	AADD(_aCpos,{"VAL.DEV."      ,"(_tAlias)->VAL_DEV" ,3,2,.T.})
EndIf

If (MV_PAR18) == 1 .OR. (MV_PAR18) == 3
	AADD(_aCpos,{"ICMS FAT."     ,"(_tAlias)->ICM_FAT" ,3,2,.T.})
EndIf

If (MV_PAR18) == 2 .OR. (MV_PAR18) == 3
	AADD(_aCpos,{"ICMS DEV."     ,"(_tAlias)->ICM_DEV" ,3,2,.T.})
EndIf

If (MV_PAR18) == 1 .OR. (MV_PAR18) == 3
	AADD(_aCpos,{"IPI FAT."      ,"(_tAlias)->IPI_FAT" ,3,2,.T.})
EndIf

If (MV_PAR18) == 2 .OR. (MV_PAR18) == 3
	AADD(_aCpos,{"IPI DEV."      ,"(_tAlias)->IPI_DEV" ,3,2,.T.})
EndIf

//ANALITICO - ORIGINAL SEM SOMA POR PRODUTOS IMPRIME RELATORIO POR ITEM
If (MV_PAR19) == 2 // ANALอTICO
		_cSelFat := " SELECT " +_lEnt
		_cSelFat += " (SUBSTRING(D2_EMISSAO,7,2) + '/' + SUBSTRING(D2_EMISSAO,5,2) + '/' + SUBSTRING(D2_EMISSAO,1,4))[EMISSAO], " +_lEnt
		If (MV_PAR19) == 2 .OR. !Empty(MV_PAR09)
			_cSelFat += " D2_EST[ESTADO], " +_lEnt
		EndIf
		If (MV_PAR19) == 2 .OR. !Empty(MV_PAR11)
			_cSelFat += " F2_VEND1[VENDEDOR], ISNULL(A3_NOME,'')[DESCVEND], " +_lEnt
		EndIf
		If (MV_PAR19) == 2 .OR. (!Empty(MV_PAR06) .AND. !Empty(MV_PAR07))
//			_cSelFat += " D2_CLIENTE[CLIENTE], D2_LOJA[LOJA], D2_NOMCLI[NOME], "
			_cSelFat += " A1_CGCCENT[CNPJ_CENT], A1_CGC[CNPJ], D2_CLIENTE[CLIENTE], D2_LOJA[LOJA], D2_NOMCLI[NOME], " +_lEnt
		EndIf
		_cSelFat += " D2_GRUPO[FAMILIA], " +_lEnt
		If (MV_PAR19) == 2
			_cSelFat += " D2_DOC[DOC], D2_SERIE[SERIE], " +_lEnt
		EndIf
		_cSelFat += " D2_COD[CODIGO],  SB1.B1_DESC[PRODUTO], SB1.B1_TIPO[TIPO], " +_lEnt
		// OR (SD2.D2_TES = '601' AND SD2.D2_SCOA <> '') 
//		_cSelFat += " D2_UM[UM]      , (CASE WHEN SF4.F4_ESTOQUE = 'S' THEN D2_QUANT   ELSE 0 END)[QTD_FAT] , 0 [QTD_DEV ]  "
		_cSelFat += " D2_UM[UM]      , (CASE WHEN SF4.F4_ESTOQUE = 'S' OR (SD2.D2_TES = '601' AND SD2.D2_SCOA <> '') THEN D2_QUANT   ELSE 0 END)[QTD_FAT] , 0 [QTD_DEV ],  " +_lEnt

//		_cSelFat += " D2_SEGUM[UM2]  , (CASE WHEN SF4.F4_ESTOQUE = 'S' THEN D2_QTSEGUM ELSE 0 END)[QTD2_FAT], 0 [QTD2_DEV] "
		_cSelFat += " D2_SEGUM[UM2]  , (CASE WHEN SF4.F4_ESTOQUE = 'S' OR (SD2.D2_TES = '601' AND SD2.D2_SCOA <> '') THEN D2_QTSEGUM ELSE 0 END)[QTD2_FAT], 0 [QTD2_DEV], " +_lEnt
		_cSelFat += " SB1.B1_UMCOMER[UMCOM], " +_lEnt
//		_cSelFat += " ((CASE WHEN SF4.F4_ESTOQUE = 'S' THEN D2_QUANT ELSE 0 END)*B1_PCOMERC)[PCOM_FAT], 0 [PCOM_DEV] "
		_cSelFat += " ((CASE WHEN SF4.F4_ESTOQUE = 'S' OR (SD2.D2_TES = '601' AND SD2.D2_SCOA <> '') THEN D2_QUANT ELSE 0 END)*SB1.B1_PCOMERC)[PCOM_FAT], 0 [PCOM_DEV], " +_lEnt
		_cSelFat += " D2_TOTAL [VAL_FAT] , 0 [VAL_DEV], " +_lEnt
		_cSelFat += " D2_VALICM [ICM_FAT], 0 [ICM_DEV], " +_lEnt
		_cSelFat += " D2_VALIPI [IPI_FAT], 0 [IPI_DEV]  " +_lEnt

//SINTETICO - VERIFICA OS PROXIMOS PARAMETROS
ElseIf (MV_PAR19) == 1 
	_cSelFat := " SELECT " +_lEnt
	// VERIFICA PARAMETRO PARA EXPORTAR COLUNA DA DATA DE EMISSรO. 
	If (MV_PAR19) == 2 .OR. (MV_PAR03) == 2
		_cSelFat += " (SUBSTRING(D2_EMISSAO,7,2) + '/' + SUBSTRING(D2_EMISSAO,5,2) + '/' + SUBSTRING(D2_EMISSAO,1,4))[EMISSAO], " +_lEnt
	EndIf
	// SE PARยMETRO "ATษ ESTADO" ESTIVER PREENCHIDO
	If (MV_PAR19) == 2 .OR. !Empty(MV_PAR09)
		_cSelFat += " D2_EST[ESTADO], " +_lEnt
	EndIf
	// SE PARยMETRO "ATษ VENDEDOR" ESTIVER PREENCHIDO
	If (MV_PAR19) == 2 .OR. !Empty(MV_PAR11)
		_cSelFat += " F2_VEND1[VENDEDOR], ISNULL(A3_NOME,'')[DESCVEND], " +_lEnt
//		_cSelFat += " F2_VEND1[VENDEDOR], A3_NOME[DESCVEND], "
	EndIf
	// SE PARยMETRO "ATษ CLIENTE/LOJA" ESTIVER PREENCHIDO
	If (MV_PAR19) == 2 .OR. (!Empty(MV_PAR06) .AND. !Empty(MV_PAR07))
//		_cSelFat += " D2_CLIENTE[CLIENTE], D2_LOJA[LOJA], D2_NOMCLI[NOME], "
		_cSelFat += " A1_CGCCENT[CNPJ_CENT], A1_CGC[CNPJ], D2_CLIENTE[CLIENTE], D2_LOJA[LOJA], D2_NOMCLI[NOME], " +_lEnt
	EndIf
	_cSelFat += " D2_GRUPO[FAMILIA], " +_lEnt
	_cSelFat += " D2_COD[CODIGO], SB1.B1_DESC[PRODUTO], SB1.B1_TIPO[TIPO], " +_lEnt
	_cSelFat += " SB1.B1_UMCOMER[UMCOM], " +_lEnt
//	_cSelFat += " ROUND(SUM((CASE WHEN SF4.F4_ESTOQUE = 'S' THEN D2_QUANT   ELSE 0 END)*),3)[PCOM_FAT], 0 [PCOM_DEV], "
	_cSelFat += " ROUND(SUM((CASE WHEN SF4.F4_ESTOQUE = 'S' OR (SD2.D2_TES = '601' AND SD2.D2_SCOA <> '') THEN D2_QUANT   ELSE 0 END)* SB1.B1_PCOMERC),3)[PCOM_FAT], 0 [PCOM_DEV], " +_lEnt
	_cSelFat += " D2_UM[UM], " +_lEnt
//	_cSelFat += " ROUND(SUM( CASE WHEN SF4.F4_ESTOQUE = 'S' THEN D2_QUANT   ELSE 0 END),2)[QTD_FAT], 0 [QTD_DEV], "
	_cSelFat += " ROUND(SUM( CASE WHEN SF4.F4_ESTOQUE = 'S' OR (SD2.D2_TES = '601' AND SD2.D2_SCOA <> '') THEN D2_QUANT   ELSE 0 END),2)[QTD_FAT], 0 [QTD_DEV], " +_lEnt
	_cSelFat += " D2_SEGUM[UM2], " +_lEnt
//	_cSelFat += " ROUND(SUM( CASE WHEN SF4.F4_ESTOQUE = 'S' THEN D2_QTSEGUM ELSE 0 END),2)[QTD2_FAT], 0 [QTD2_DEV], "
	_cSelFat += " ROUND(SUM( CASE WHEN SF4.F4_ESTOQUE = 'S' OR (SD2.D2_TES = '601' AND SD2.D2_SCOA <> '') THEN D2_QTSEGUM ELSE 0 END),2)[QTD2_FAT], 0 [QTD2_DEV], "	 +_lEnt
	_cSelFat += " ROUND(SUM(D2_TOTAL) ,2)[VAL_FAT], 0 [VAL_DEV], " +_lEnt
	_cSelFat += " ROUND(SUM(D2_VALICM),2)[ICM_FAT], 0 [ICM_DEV], " +_lEnt
	_cSelFat += " ROUND(SUM(D2_VALIPI),2)[IPI_FAT], 0 [IPI_DEV]  " +_lEnt
EndIf
_cQryFat := " FROM " + RetSqlName("SD2") + " SD2 " +_lEnt

_cQryFat += " 	INNER JOIN " + RetSqlName("SF4") + " SF4 (NOLOCK)  ON SF4.D_E_L_E_T_ = '' " +_lEnt
_cQryFat += " 		AND SF4.F4_FILIAL  = '" + xFilial("SF4") + "' " +_lEnt
If MV_PAR25 == 1
	_cQryFat += " 		AND SF4.F4_DUPLIC  = 'S' " +_lEnt
ElseIf MV_PAR25 == 2
	_cQryFat += " 		AND SF4.F4_DUPLIC  = 'N' " +_lEnt
EndIf
_cQryFat += "		AND SF4.F4_CODIGO  = SD2.D2_TES " +_lEnt
_cQryFat += " 	INNER JOIN " + RetSqlName("SF2") + " SF2 (NOLOCK)  ON SF2.D_E_L_E_T_ = '' " +_lEnt
_cQryFat += " 		 AND SF2.F2_FILIAL        = '" + xFilial("SF2") + "' " +_lEnt

// - Trecho alterado em 14/05/2014 por J๚lio Soares para implementar o Markbrowse para sele็ใo de clientes
//Trecho anterior

If !Empty(MV_PAR06) .And. !Empty(MV_PAR07) // ATษ CLIENTE + LOJA
	_cQryFat += "    AND SF2.F2_CLIENTE BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "' " +_lEnt
	_cQryFat += "    AND SF2.F2_LOJA    BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "' " +_lEnt
Else
	_cQryFat += "    AND SF2.F2_CLIENTE BETWEEN '' AND '"+Replicate("Z",TamSx3("F2_CLIENTE")[01])+"' " +_lEnt
	_cQryFat += "    AND SF2.F2_LOJA    BETWEEN '' AND '"+Replicate("Z",TamSx3("F2_LOJA"   )[01])+"' " +_lEnt
EndIf

/*
If Len(_aSelCli) > 0
	For _x := 1 To Len(_aSelCli)
		If _x == 1
			_cQryFat += " AND SF2.F2_CLIENTE + SF2.F2_LOJA IN ("
		Else
			_cQryFat += ","
		EndIf
		_cQryFat += "'" + _aSelCli[_x,1] + _aSelCli[_x,2] +"'"
	Next
	_cQryFat += ") " +_lEnt
EndIf
*/

If !Empty(MV_PAR11) // ATษ VENDEDOR
	_cQryFat += "    AND SF2.F2_VEND1   BETWEEN '" + MV_PAR10 + "' AND '" + MV_PAR11 + "' " +_lEnt
Else
	_cQryFat += "    AND SF2.F2_VEND1   BETWEEN '' AND '"+Replicate("Z",TamSx3("F2_VEND1")[01])+"' " +_lEnt
EndIf

_cQryFat += " 		 AND SF2.F2_DOC     = SD2.D2_DOC " +_lEnt
_cQryFat += " 		 AND SF2.F2_SERIE   = SD2.D2_SERIE " +_lEnt

_cQryFat += " 		 AND SF2.F2_CLIENTE = SD2.D2_CLIENTE " +_lEnt
_cQryFat += " 		 AND SF2.F2_LOJA    = SD2.D2_LOJA "   +_lEnt

// - INSERIDO PARA TRAZER NOME DO VENDEDOR CONFORME SOLICITAวรO DO SR. SCOOT
If (MV_PAR19) == 2 .OR. !Empty(MV_PAR11)
	_cQryFat += " 	INNER JOIN " + RetSqlName("SA3") + " SA3 (NOLOCK) ON SA3.D_E_L_E_T_ = '' " +_lEnt
	_cQryFat += " 		AND SA3.A3_FILIAL  = '" + xFilial("SA3") + "' " +_lEnt
	_cQryFat += " 		AND SA3.A3_COD     = SF2.F2_VEND1 " +_lEnt
EndIf
_cQryFat += " 	INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK)  ON SB1.D_E_L_E_T_ = '' " +_lEnt
_cQryFat += " 		AND SB1.B1_FILIAL      = '" + xFilial("SB1") + "' " +_lEnt
_cQryFat += "       AND SB1.B1_GRUPO BETWEEN '" + MV_PAR12 + "' AND '" + MV_PAR13 + "' " +_lEnt
_cQryFat += "       AND SB1.B1_COD   BETWEEN '" + MV_PAR14 + "' AND '" + MV_PAR15 + "' " +_lEnt
_cQryFat += "       AND SB1.B1_TIPO  BETWEEN '" + MV_PAR16 + "' AND '" + MV_PAR17 + "' " +_lEnt
_cQryFat += " 		AND SB1.B1_COD         = SD2.D2_COD " +_lEnt

_cQryFat += " 	INNER JOIN " + RetSqlName("SA1") + " SA1  (NOLOCK) ON SA1.D_E_L_E_T_ = '' " +_lEnt
_cQryFat += " 		AND SA1.A1_FILIAL      = '" + xFilial("SA1") + "' " +_lEnt
_cQryFat += " 		AND SA1.A1_COD         =  SD2.D2_CLIENTE " +_lEnt
_cQryFat += " 		AND SA1.A1_LOJA        =  SD2.D2_LOJA " +_lEnt

_cQryFat += " WHERE SD2.D_E_L_E_T_ = '' " +_lEnt
_cQryFat += " AND SD2.D2_FILIAL    = '" + xFilial("SD2") + "' " +_lEnt
_cQryFat += " AND SD2.D2_TIPO	   = 'N' " +_lEnt

// ALTERADO POR JฺLIO SOARES APำS SOLICITAวรO DE ALTERAวีES DE QUAIS TIPOS DE OPERAวรO SERรO UTILIZADOS

If Len(_aSelect) > 0
	For _x := 1 To Len(_aSelect)
		If _x == 1
			_cQryFat += " AND ( "
		Else
			_cQryFat += " OR "
		EndIf
		_cQryFat += "SD2.D2_TIPOPER = '"+_aSelect[_x]+"' "
	Next
	_cQryFat += ") " +_lEnt
EndIf
/*
If (MV_PAR25) == 1 // - NรO CONSIDERA FATURAMENTO DE TROCAS
	_cQryFat += " AND SD2.D2_TIPOPER = '' "
ElseIf (MV_PAR25) == 2
	_cQryFat += " "
EndIf
*/
If !Empty(MV_PAR09) // ATษ ESTADO
	_cQryFat += " AND SD2.D2_EST     BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "' " +_lEnt
Else
	_cQryFat += " AND SD2.D2_EST     BETWEEN '' AND '"+Replicate("Z",TamSx3("D2_EST")[01])+"' " +_lEnt
EndIf

If !Empty(MV_PAR21) .And. !Empty(MV_PAR22) // ATษ DOCUMENTO + SษRIE
	_cQryFat += " AND SD2.D2_DOC     BETWEEN '" + MV_PAR21 + "' AND '" + MV_PAR23 + "' " +_lEnt
	_cQryFat += " AND SD2.D2_SERIE   BETWEEN '" + MV_PAR22 + "' AND '" + MV_PAR24 + "' " +_lEnt
Else
	_cQryFat += " AND SD2.D2_DOC     BETWEEN '' AND '"+Replicate("Z",TamSx3("D2_DOC"  )[01])+"' " +_lEnt
	_cQryFat += " AND SD2.D2_SERIE   BETWEEN '' AND '"+Replicate("Z",TamSx3("D2_SERIE")[01])+"' " +_lEnt
EndIf

// SE ANALITICO IMPRIME RELATORIO APENAS POR PRODUTO
If (MV_PAR19) == 2     
	_cOrdFat := " ORDER BY D2_EMISSAO, " +_lEnt
//	If (MV_PAR19) == 2 .OR. !Empty(MV_PAR09)
		_cOrdFat += " D2_EST, " +_lEnt
//	EndIf
//	If (MV_PAR19) == 2 .OR. !Empty(MV_PAR11)
		_cOrdFat += " F2_VEND1, " +_lEnt
//	EndIf
//	If (MV_PAR19) == 2 .OR. (!Empty(MV_PAR06) .AND. !Empty(MV_PAR07))
		_cOrdFat += " D2_CLIENTE, D2_LOJA, " +_lEnt
//	EndIf
	_cOrdFat += " D2_GRUPO, D2_COD " +_lEnt

// SE SINTETICO VERIFICA OS PROXIMOS PARAMETROS
ElseIf (MV_PAR19) == 1
	_cGrpFat := " GROUP BY " +_lEnt
	// CONSIDERA A DATA DE EMISSรO PARA GERAวAO DO RELATำRIO
	If (MV_PAR19) == 2 .OR. (MV_PAR03) == 2
		_cGrpFat += " D2_EMISSAO, " +_lEnt
	EndIf
	// NรO TRAZ COLUNA ESTADO SE O PARยMETRO ESTIVER PREENCHIDO
	If (MV_PAR19) == 2 .OR. !Empty(MV_PAR09)
		_cGrpFat += " D2_EST, " +_lEnt
	EndIf
	// NรO TRAZ A COLUNA DE VENDEDOR SE O PARยMETRO ESTIVER EM BRANCO
	If (MV_PAR19) == 2 .OR. !Empty(MV_PAR11)
		_cGrpFat += " F2_VEND1, A3_NOME, " +_lEnt
//		_cGrpFat += " F2_VEND1, "
	EndIf
	// NรO TRAZ COLUNA DE CLIENTE/LOJA SE PARยMETRO ESTIVER EM BRANCO
	If (MV_PAR19) == 2 .OR. (!Empty(MV_PAR06) .AND. !Empty(MV_PAR07))
//		_cGrpFat += " D2_CLIENTE, D2_LOJA, D2_NOMCLI, "
		_cGrpFat += " A1_CGCCENT, A1_CGC, D2_CLIENTE, D2_LOJA, D2_NOMCLI, " +_lEnt
	EndIf
	_cGrpFat += " B1_UMCOMER, " +_lEnt
	_cGrpFat += " D2_GRUPO, " +_lEnt
	_cGrpFat += " D2_COD, SB1.B1_DESC, SB1.B1_TIPO, " +_lEnt
	_cGrpFat += " D2_UM, " +_lEnt
	_cGrpFat += " SB1.B1_PCOMERC, " +_lEnt
	_cGrpFat += " D2_SEGUM    " +_lEnt

	_cOrdFat := " ORDER BY " +_lEnt
	// CONSIDERA A DATA DE EMISSรO PARA GERAวAO DO RELATำRIO
	If (MV_PAR19) == 2 .OR. (MV_PAR03) == 2
		_cOrdFat += " D2_EMISSAO, " +_lEnt
	EndIf
	// CONSIDERA ESTADO SE O PARยMETRO ESTIVER PREENCHIDO
	If (MV_PAR19) == 2 .OR. !Empty(MV_PAR09)
		_cOrdFat += " D2_EST, " +_lEnt
	EndIf
	// CONSIDERA VENDEDOR SE O PARยMETRO ESTIVER PREENCHIDO
	If (MV_PAR19) == 2 .OR. !Empty(MV_PAR11)
		_cOrdFat += " F2_VEND1, " +_lEnt
	EndIf
	// CONSIDERA CLIENTE SE O PARยMETRO ESTIVER PREENCHIDO
	If (MV_PAR19) == 2 .OR. (!Empty(MV_PAR06) .AND. !Empty(MV_PAR07))
		_cOrdFat += " D2_CLIENTE, D2_LOJA, D2_NOMCLI, " +_lEnt
	EndIf
	_cOrdFat += " D2_GRUPO, " +_lEnt
	_cOrdFat += " D2_COD " +_lEnt
EndIf

// 2 - DEVOLUวรO OU AMBOS
If (MV_PAR18) == 2 .OR. (MV_PAR18) == 3
	//Campos do documento de saida que serao utilizado para as entradas
//	_cSlFtDv := "  D2_EST, F2_VEND1, A3_NOME, D2_CLIENTE, D2_LOJA, D2_NOMCLI"
	_cSlFtDv := "  D2_EST, F2_VEND1, D2_CLIENTE, D2_LOJA, D2_NOMCLI" +_lEnt
	_cSlFtDv += ", D2_DOC, D2_SERIE, D2_COD, D2_ITEM" +_lEnt
	_cSlFtDv += ", SB1.B1_DESC, SB1.B1_TIPO, SB1.B1_GRUPO, SB1.B1_UMCOMER, SB1.B1_PCOMERC " +_lEnt

	//ANALITICO - ORIGINAL SEM SOMA POR PRODUTOS IMPRIME RELATORIO POR ITEM
	If (MV_PAR19) == 2 // ANALอTICO
		_cSelDev := " SELECT " +_lEnt
//		_cSelDev += " (SUBSTRING(D1_EMISSAO,7,2) + '/' + SUBSTRING(D1_EMISSAO,5,2) + '/' + SUBSTRING(D1_EMISSAO,1,4))[EMISSAO], "
		_cSelDev += " (SUBSTRING(D1_DTDIGIT,7,2) + '/' + SUBSTRING(D1_DTDIGIT,5,2) + '/' + SUBSTRING(D1_DTDIGIT,1,4))[EMISSAO], " +_lEnt
		If (MV_PAR19) == 2 .OR. !Empty(MV_PAR09)
			_cSelDev += " D2_EST[ESTADO], " +_lEnt
		EndIf
		If (MV_PAR19) == 2 .OR. !Empty(MV_PAR11)
//			_cSelDev += " F2_VEND1[VENDEDOR],A3_NOME[DESCVEND], "
			_cSelDev += " F2_VEND1[VENDEDOR], ISNULL(A3_NOME,'')[DESCVEND], " +_lEnt
		EndIf
		If (MV_PAR19) == 2 .OR. (!Empty(MV_PAR06) .AND. !Empty(MV_PAR07))
			_cSelDev += " A1_CGCCENT[CNPJ_CENT], A1_CGC[CNPJ], D1_FORNECE[CLIENTE], D1_LOJA[LOJA], D2_NOMCLI[NOME], " +_lEnt
//			_cSelDev += " D1_FORNECE[CLIENTE],D1_LOJA[LOJA],D2_NOMCLI[NOME], "
		EndIf
		_cSelDev += " SB1.B1_GRUPO[FAMILIA], " +_lEnt
		If (MV_PAR19) == 2
			_cSelDev += " D1_DOC[DOC], D1_SERIE[SERIE], " +_lEnt
		EndIf
		_cSelDev += " D1_COD[CODIGO], SB1.B1_DESC[PRODUTO], SB1.B1_TIPO[TIPO], " +_lEnt
		_cSelDev += " SB1.B1_UM[UM] , 0 [QTD_FAT], D1_QUANT[QTD_DEV], " +_lEnt
		_cSelDev += " SB1.B1_SEGUM[UM2] , 0 [QTD2_FAT], D1_QTSEGUM[QTD2_DEV], " +_lEnt
		_cSelDev += " SB1.B1_UCOM[UMCOM] , " +_lEnt
		_cSelDev += " 0 [PCOM_FAT], (D1_QUANT*SB1.B1_PCOMERC)[PCOM_DEV], " +_lEnt
		_cSelDev += " 0 [VAL_FAT] , D1_TOTAL[VAL_DEV] ," +_lEnt
		_cSelDev += " 0 [ICM_FAT] , D1_VALICM[ICM_DEV]," +_lEnt
		_cSelDev += " 0 [IPI_FAT] , D1_VALIPI[IPI_DEV] " +_lEnt

	//SINTETICO - VERIFICA OS PROXIMOS PARAMETROS
	ElseIf (MV_PAR19) == 1 
		_cSelDev := " SELECT " +_lEnt
		// VERIFICA PARAMETRO PARA EXPORTAR COLUNA DA DATA DE EMISSรO. 
		If (MV_PAR19) == 2 .OR. (MV_PAR03) == 2
			_cSelDev  += " (SUBSTRING(D1_DTDIGIT,7,2) + '/' + SUBSTRING(D1_DTDIGIT,5,2) + '/' + SUBSTRING(D1_DTDIGIT,1,4))[EMISSAO], " +_lEnt
		EndIf
		// SE PARยMETRO "ATษ ESTADO" ESTIVER PREENCHIDO
		If (MV_PAR19) == 2 .OR. !Empty(MV_PAR09)
			_cSelDev += " D2_EST[ESTADO], " +_lEnt
		EndIf
		// SE PARยMETRO "ATษ VENDEDOR" ESTIVER PREENCHIDO
		If (MV_PAR19) == 2 .OR. !Empty(MV_PAR11)
			_cSelDev += " F2_VEND1[VENDEDOR], ISNULL(A3_NOME,'')[DESCVEND], " +_lEnt
		EndIf
		// SE PARยMETRO "ATษ CLIENTE/LOJA" ESTIVER PREENCHIDO
		If (MV_PAR19) == 2 .OR. (!Empty(MV_PAR06) .AND. !Empty(MV_PAR07))
//			_cSelDev += " D1_FORNECE[CLIENTE], D1_LOJA[LOJA], D2_NOMCLI[NOME], "
			_cSelDev += " A1_CGCCENT[CNPJ_CENT],A1_CGC[CNPJ],D1_FORNECE[CLIENTE], D1_LOJA[LOJA], D2_NOMCLI[NOME], " +_lEnt
		EndIf
		_cSelDev += " D1_GRUPO[FAMILIA], " +_lEnt
		_cSelDev += " D1_COD[CODIGO], SB1.B1_DESC[PRODUTO], SB1.B1_TIPO[TIPO], " +_lEnt

		_cSelDev += " SB1.B1_UMCOMER[UMCOM], " +_lEnt
//		_cSelDev += " D1_UM[UM], "

		_cSelDev += " 0 [PCOM_FAT], ROUND(SUM((D1_QUANT* SB1.B1_PCOMERC)),3)[PCOM_DEV], " +_lEnt

		_cSelDev += " D1_UM[UM], " +_lEnt
		_cSelDev += " 0 [QTD_FAT], ROUND(SUM(D1_QUANT),2)[QTD_DEV], " +_lEnt
		_cSelDev += " D1_SEGUM[UM2], " +_lEnt
		_cSelDev += " 0 [QTD2_FAT], ROUND(SUM(D1_QTSEGUM),2)[QTD2_DEV], " +_lEnt
//		_cSelDev += " B1_UMCOMER[UMCOM], "
//		_cSelDev += " 0 [PCOM_DEV], ROUND(SUM((D1_QUANT*B1_PCOMERC)),3)[PCOM_DEV], "
		_cSelDev += " 0 [VAL_FAT] , ROUND(SUM(D1_TOTAL) ,2)[VAL_DEV], " +_lEnt
		_cSelDev += " 0 [ICM_FAT] , ROUND(SUM(D1_VALICM),2)[ICM_DEV], " +_lEnt
		_cSelDev += " 0 [IPI_FAT] , ROUND(SUM(D1_VALIPI),2)[IPI_DEV]  " +_lEnt
	EndIf
	_cQryDev := " FROM " + RetSqlName('SD1') + " SD1 (NOLOCK) " +_lEnt
	_cQryDev += "    INNER JOIN (SELECT "+(_cSlFtDv+_cQryFat)+") SD2ORI ON " +_lEnt
	_cQryDev += "                           SD2ORI.D2_DOC     = SD1.D1_NFORI " +_lEnt
	_cQryDev += "                       AND SD2ORI.D2_SERIE   = SD1.D1_SERIORI " +_lEnt
	_cQryDev += "                       AND SD2ORI.D2_ITEM    = SD1.D1_ITEMORI " +_lEnt
	_cQryDev += "                       AND SD2ORI.D2_COD     = SD1.D1_COD " +_lEnt
	_cQryDev += "                       AND SD2ORI.D2_CLIENTE = SD1.D1_FORNECE " +_lEnt
	_cQryDev += "                       AND SD2ORI.D2_LOJA    = SD1.D1_LOJA " +_lEnt

	_cQryDev += " 	INNER JOIN " + RetSqlName('SA1') + " SA1B (NOLOCK) ON SA1B.D_E_L_E_T_ = '' " +_lEnt
	_cQryDev += " 		AND SD1.D1_FILIAL  = '" + xFilial("SD1") + "' " +_lEnt
	_cQryDev += " 		AND SD1.D1_FORNECE = SA1B.A1_COD " +_lEnt
	_cQryDev += " 		AND SD1.D1_LOJA    = SA1B.A1_LOJA " +_lEnt

	_cQryDev += " 	INNER JOIN " + RetSqlName('SA3') + " SA3B (NOLOCK) ON SA3B.D_E_L_E_T_ = '' " +_lEnt
	_cQryDev += " 		AND SA3B.A3_FILIAL = '" + xFilial("SA3") + "' " +_lEnt
	_cQryDev += " 		AND SA3B.A3_COD    = SD2ORI.F2_VEND1 " +_lEnt

	_cQryDev += " 	INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON SB1.D_E_L_E_T_ = '' " +_lEnt
	_cQryDev += " 		AND SB1.B1_FILIAL      = '" + xFilial("SB1") + "' " +_lEnt
	_cQryDev += "       AND SB1.B1_GRUPO BETWEEN '" + MV_PAR12 + "' AND '" + MV_PAR13 + "' " +_lEnt
	_cQryDev += "       AND SB1.B1_COD   BETWEEN '" + MV_PAR14 + "' AND '" + MV_PAR15 + "' " +_lEnt
	_cQryDev += "       AND SB1.B1_TIPO  BETWEEN '" + MV_PAR16 + "' AND '" + MV_PAR17 + "' " +_lEnt
	_cQryDev += " 		AND SB1.B1_COD         = SD1.D1_COD " +_lEnt

	_cQryDev += " WHERE SD1.D_E_L_E_T_ = '' " +_lEnt
	_cQryDev += " 	AND SD1.D1_FILIAL  = '" + xFilial("SD1") + "' " +_lEnt
	_cQryDev += " 	AND SD1.D1_TIPO    = 'D' " +_lEnt
// - GROUP BY
	// SE ANALITICO IMPRIME RELATORIO APENAS POR PRODUTO
	If (MV_PAR19) == 2     
		_cOrdDev := " ORDER BY D1_DTDIGIT, " +_lEnt
		If (MV_PAR19) == 2 .OR. !Empty(MV_PAR09)
			_cOrdDev += " D2_EST, " +_lEnt
		EndIf
		If (MV_PAR19) == 2 .OR. !Empty(MV_PAR11)
			_cOrdDev += " F2_VEND1, " +_lEnt
		EndIf
		_cOrdDev += " D1_FORNECE, D1_LOJA, D1_GRUPO, D1_COD " +_lEnt
	// SE SINTETICO VERIFICA OS PROXIMOS PARAMETROS
	ElseIf (MV_PAR19) == 1
		_cGrpDev := " GROUP BY " +_lEnt
		// CONSIDERA A DATA DE EMISSรO PARA GERAวAO DO RELATำRIO
		If (MV_PAR19) == 2 .OR. (MV_PAR03) == 2
			_cGrpDev += " D1_DTDIGIT, " +_lEnt
		EndIf
		// NรO TRAZ COLUNA ESTADO SE O PARยMETRO ESTIVER PREENCHIDO
		If (MV_PAR19) == 2 .OR. !Empty(MV_PAR09)
			_cGrpDev += " D2_EST, " +_lEnt
		EndIf
		// NรO TRAZ A COLUNA DE VENDEDOR SE O PARยMETRO ESTIVER EM BRANCO
		If (MV_PAR19) == 2 .OR. !Empty(MV_PAR11)
			_cGrpDev += " F2_VEND1, A3_NOME, " +_lEnt
//			_cGrpDev += " F2_VEND1, "
		EndIf
		// NรO TRAZ COLUNA DE CLIENTE/LOJA SE PARยMETRO ESTIVER EM BRANCO
		If (MV_PAR19) == 2 .OR. (!Empty(MV_PAR06) .AND. !Empty(MV_PAR07))
//			_cGrpDev += " D1_FORNECE, D1_LOJA, D2_NOMCLI, "
			_cGrpDev += " A1_CGCCENT,A1_CGC,D1_FORNECE, D1_LOJA, D2_NOMCLI, " +_lEnt

		EndIf
		_cGrpDev += " SB1.B1_UMCOMER, " +_lEnt
		_cGrpDev += " D1_GRUPO, " +_lEnt
		_cGrpDev += " D1_COD, SB1.B1_DESC, SB1.B1_TIPO, " +_lEnt
		_cGrpDev += " D1_UM, " +_lEnt
		_cGrpDev += " SB1.B1_PCOMERC, " +_lEnt
		_cGrpDev += " D1_SEGUM " +_lEnt
	
// - ORDER BY
		_cOrdDev := " ORDER BY " +_lEnt
		// CONSIDERA A DATA DE EMISSรO PARA GERAวAO DO RELATำRIO
		If (MV_PAR19) == 2 .OR. (MV_PAR03) == 2
			_cOrdDev += " D1_DTDIGIT, " +_lEnt
		EndIf
		// CONSIDERA ESTADO SE O PARยMETRO ESTIVER PREENCHIDO
		If (MV_PAR19) == 2 .OR. !Empty(MV_PAR09)
			_cOrdDev += " D2_EST, " +_lEnt
		EndIf
		// CONSIDERA VENDEDOR SE O PARยMETRO ESTIVER PREENCHIDO
		If (MV_PAR19) == 2 .OR. !Empty(MV_PAR11)
			_cOrdDev += " F2_VEND1, " +_lEnt
		EndIf
		// CONSIDERA CLIENTE SE O PARยMETRO ESTIVER PREENCHIDO
		If (MV_PAR19) == 2 .OR. (!Empty(MV_PAR06) .AND. !Empty(MV_PAR07))
			_cOrdDev += " D1_FORNECE, D1_LOJA, D2_NOMCLI, " +_lEnt
		EndIf
		_cOrdDev += " D1_GRUPO, " +_lEnt
		_cOrdDev += " D1_COD " +_lEnt
    EndIf
	// - MSGBOX("Parโmetro para considerar apenas devolu็๕es ainda em desenvolvimento",_cRotina,"STOP")
EndIf

//Formacao da Query Final, conforme os parametros
If (MV_PAR18) == 1			//Faturamento
	_cQuery  := _cSelFat+_cQryFat+_cEmSD2+_cGrpFat+_cOrdFat
ElseIf (MV_PAR18) == 2		//Devolucoes
	_cQuery  := _cSelDev+_cQryDev+_cEmSD1+_cGrpDev+_cOrdDev
ElseIf (MV_PAR18) == 3		//Ambos

	_cQuery  := " SELECT * FROM ( " +_lEnt
	_cQuery  += _cSelFat+_cQryFat+_cEmSD2+_cGrpFat
	_cQuery  += " UNION ALL " +_lEnt
	_cQuery  += _cSelDev+_cQryDev+_cEmSD1+_cGrpDev
	_cQuery  += "               ) AMBOS " +_lEnt
	// - ORDER BY
	_cQuery += " ORDER BY " +_lEnt
	// CONSIDERA A DATA DE EMISSรO PARA GERAวAO DO RELATำRIO
	If (MV_PAR19) == 2 .OR. (MV_PAR03) == 2
		_cQuery += " EMISSAO, " +_lEnt
	EndIf
	// CONSIDERA ESTADO SE O PARยMETRO ESTIVER PREENCHIDO
	If (MV_PAR19) == 2 .OR. !Empty(MV_PAR09)
		_cQuery += " ESTADO, " +_lEnt
	EndIf
	// CONSIDERA VENDEDOR SE O PARยMETRO ESTIVER PREENCHIDO
	If (MV_PAR19) == 2 .OR. !Empty(MV_PAR11)
		_cQuery += " VENDEDOR, " +_lEnt
	EndIf
	// CONSIDERA CLIENTE SE O PARยMETRO ESTIVER PREENCHIDO
	If (MV_PAR19) == 2 .OR. (!Empty(MV_PAR06) .AND. !Empty(MV_PAR07))
//		_cQuery += " CLIENTE, LOJA, "
		_cQuery += " CLIENTE, LOJA, " +_lEnt
	EndIf
	_cQuery += " FAMILIA, PRODUTO " +_lEnt
EndIf

//MemoWrite("\2.Memowrite\"+_cRotina+"_QRY_01.TXT",_cQuery)

If (Len(_cQuery) ) >0
	_cQuery := ChangeQuery(_cQuery) // incluido para tratamento no novo processo.
Else
	MSGBOX('CONSULTA NรO GERADA ','*** ***','STOP')
	Return()	
EndIf

// - GERA A QUERY FORMADA
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_tAlias,.T.,.F.)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFATR017  บAutor  ณMicrosiga           บ Data ณ  15/01/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsใvel por gerar a planilha conforme dados     บฑฑ
ฑฑบ          ณ obtidos da consulta formada de acordo com parโmetros       บฑฑ
ฑฑบ          ณ inseridos pelo usuแrio.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para empresa ARCOLOR              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Geraxls()

Local _x
Local oExcel
Local _cSheet1  := (DTOC(mv_par01)) + " ~ " + (DTOC(mv_par02))
Local _cSheet2  := 'PARยMETROS'
Local _cFileTMP := ""
Local _cFile    := ""

Private _aPar   := {}

dbSelectArea(_tAlias)
ProcRegua(((_tAlias)->(RecCount())*2)+1)
(_tAlias)->(dbGoTop())
If !(_tAlias)->(EOF())
	oExcel := FWMSEXCEL():New()
	oExcel:AddWorkSheet(_cSheet1)
	oExcel:AddTable(_cSheet1,_cTitulo)
	For _x := 1 To Len(_aCpos)
		oExcel:AddColumn(_cSheet1,_cTitulo,_aCpos[_x][01],_aCpos[_x][03],_aCpos[_x][04],_aCpos[_x][05])
	Next
	// - ACRESCENTA AS LINHAS COM INFORMAวีES WHILE ! TEMP ->(EOF())
	While !(_tAlias)->(EOF())
		IncProc('PROCESSANDO PRODUTO: '+ AllTrim((_tAlias)->PRODUTO) + '...')	
		_aAux := {}
		For _x := 1 To Len(_aCpos)
		    AADD(_aAux, &(_aCpos[_x][02]))
		Next
		oExcel:AddRow(_cSheet1, _cTitulo, _aAux )
		(_tAlias)->(dbSkip())
	EndDo
	// - INCLUI UMA ABA COM AS INFORMAวีES DOS PARAMETROS
	oExcel:AddWorkSheet(_cSheet2)
	oExcel:AddTable(_cSheet2,_cTitulo2)
	oExcel:AddColumn(_cSheet2,_cTitulo2,"DESCRIวรO" ,1,1,.F.)
	oExcel:AddColumn(_cSheet2,_cTitulo2,"CONTEฺDO"  ,1,1,.F.)

	_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	cPerg := PADR(cPerg,10)
	If (_cAliasSX1)->(dbSeek(cPerg))
		While !EOF() .And. (_cAliasSX1)->X1_GRUPO==cPerg
			IncProc('PROCESSANDO PARAMETROS...')
			If AllTrim((_cAliasSX1)->X1_GSC)=="C"
				AAdd(_aPar,{ (_cAliasSX1)->X1_PERGUNT,&("(_cAliasSX1)->X1_DEF"+StrZero(&((_cAliasSX1)->X1_VAR01),2)) })
			Else
				AAdd(_aPar,{ (_cAliasSX1)->X1_PERGUNT,&((_cAliasSX1)->X1_VAR01) })
			EndIf
			dbSelectArea(_cAliasSX1)
			(_cAliasSX1)->(dbSkip())
		EndDo
	EndIf
	If Len(_aPar) > 0
		For _nPosPar := 1 To Len(_aPar)
			oExcel:AddRow(_cSheet2, _cTitulo2, _aPar[_nPosPar])
		Next
	EndIf
	// - IMPRIME O RELATำRIO NO EXCEL
	IncProc("ABRINDO ARQUIVO...")
	oExcel:Activate()
	_cFile := (CriaTrab(NIL, .F.) + ".xml")
	While File(_cFile)
		_cFile := (CriaTrab(NIL, .F.) + ".xml")
	EndDo
	oExcel:GetXMLFile(_cFile)
	oExcel:DeActivate()
	If !(File(_cFile))
		_cFile := ""
		Break
	EndIf
	_cFileTMP := (GetTempPath() + _cFile)
	If !(__CopyFile(_cFile , _cFileTMP))
		fErase( _cFile )
		_cFile := ""
		Break
	EndIf
	fErase(_cFile)
	_cFile := _cFileTMP
	If !(File(_cFile))
		_cFile := ""
		Break
	EndIf
	oMsExcel:= MsExcel():New()
	oMsExcel:WorkBooks:Open(_cFile)
	oMsExcel:SetVisible(.T.)
	IncProc('RELATำRIO GERADO COM SUCESSO!')
	MSGBOX('Relat๓rio gerado, VERIFIQUE!!!',_cRotina+'_04','ALERT')
	oMsExcel:= oMsExcel:Destroy()
Else
	MSGBOX('Nใo hแ dados a serem apresentados. Informe o Administrador do sistema.',_cRotina+'_05','ALERT')
	Return()
EndIf

FreeObj(oExcel)
oExcel := NIL

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ ValidPerg บ Autor ณJ๚lio Soares         บ Data ณ  04/10/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsแvel pela inclusใo de parโmetros na rotina.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para empresa ARCOLOR              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ValidPerg()

Local _x
Local _y
_cAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg   := PADR(cPerg,10)
aRegs   :={}

AADD(aRegs,{cPerg,"01","De Data?"              ,"","","mv_ch1","D",08,0,0,"G","NaoVazio()","mv_par01",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{cPerg,"02","At้ Data?"             ,"","","mv_ch2","D",08,0,0,"G","NaoVazio()","mv_par02",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{cPerg,"03","Imprime Data Emissใo?" ,"","","mv_ch3","N",01,0,0,"C","NaoVazio()","mv_par03","Nใo"        ,"","","","","Sim"      ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{cPerg,"04","De Cliente?"           ,"","","mv_ch4","C",06,0,0,"G",""          ,"mv_par04",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SA1","","","",""})
AADD(aRegs,{cPerg,"05","De Loja?"              ,"","","mv_ch5","C",02,0,0,"G",""          ,"mv_par05",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{cPerg,"06","At้ Cliente?"          ,"","","mv_ch6","C",06,0,0,"G",""          ,"mv_par06",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SA1","","","",""})
AADD(aRegs,{cPerg,"07","At้ Loja?"             ,"","","mv_ch7","C",02,0,0,"G",""          ,"mv_par07",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{cPerg,"08","De Estado?"            ,"","","mv_ch8","C",02,0,0,"G",""          ,"mv_par08",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","12" ,"","","",""})
AADD(aRegs,{cPerg,"09","At้ Estado?"           ,"","","mv_ch9","C",02,0,0,"G",""          ,"mv_par09",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","12" ,"","","",""})

// Altera็ใo - Fernando Bombardi - ALLSS - 02/03/2022
//AADD(aRegs,{cPerg,"10","De Vendedor?"          ,"","","mv_cha","C",06,0,0,"G",""          ,"mv_par10",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SA3","","","",""})
//AADD(aRegs,{cPerg,"11","At้ Vendedor?"         ,"","","mv_chb","C",06,0,0,"G",""          ,"mv_par11",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SA3","","","",""})

AADD(aRegs,{cPerg,"10","De Representante?"          ,"","","mv_cha","C",06,0,0,"G",""          ,"mv_par10",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SA3","","","",""})
AADD(aRegs,{cPerg,"11","At้ Representante?"         ,"","","mv_chb","C",06,0,0,"G",""          ,"mv_par11",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SA3","","","",""})
// Fim - Fernando Bombardi - ALLSS - 02/03/2022

AADD(aRegs,{cPerg,"12","De Grupo de Produto?"  ,"","","mv_chc","C",04,0,0,"G",""          ,"mv_par12",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SBM","","","",""})
AADD(aRegs,{cPerg,"13","At้ Grupo de Produto?" ,"","","mv_chd","C",04,0,0,"G","NaoVazio()","mv_par13",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SBM","","","",""})
AADD(aRegs,{cPerg,"14","De Produto?"           ,"","","mv_che","C",06,0,0,"G",""          ,"mv_par14",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SB1","","","",""})
AADD(aRegs,{cPerg,"15","At้ Produto?"          ,"","","mv_chf","C",06,0,0,"G","NaoVazio()","mv_par15",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SB1","","","",""})
AADD(aRegs,{cPerg,"16","De Tipo? "             ,"","","mv_chg","C",02,0,0,"G",""          ,"mv_par16",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","02" ,"","","",""})
AADD(aRegs,{cPerg,"17","At้ Tipo?"             ,"","","mv_chh","C",02,0,0,"G","NaoVazio()","mv_par17",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","02" ,"","","",""})
AADD(aRegs,{cPerg,"18","Imprime?"              ,"","","mv_chi","N",01,0,0,"C",""          ,"mv_par18","Faturamento","","","","","Devolu็ใo","","","","","Ambos","","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{cPerg,"19","Sint้tico/Analํtico?"  ,"","","mv_chj","N",01,0,0,"C","NaoVazio()","mv_par19","Sint้tico"  ,"","","","","Analํtico","","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{cPerg,"20","Range Top?"            ,"","","mv_chk","N",04,0,0,"G",""          ,"mv_par20",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{cPerg,"21","De Documento?"         ,"","","mv_chl","C",09,0,0,"G",""          ,"mv_par21",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SF2","","","",""})
AADD(aRegs,{cPerg,"22","De Serie?"             ,"","","mv_chm","C",03,0,0,"G",""          ,"mv_par22",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{cPerg,"23","At้ Documento?"        ,"","","mv_chn","C",09,0,0,"G","NaoVazio()","mv_par23",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SF2","","","",""})
AADD(aRegs,{cPerg,"24","At้ Serie?"            ,"","","mv_chp","C",03,0,0,"G","NaoVazio()","mv_par24",""           ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{cPerg,"25","Gera Financeiro?"      ,"","","mv_chq","N",01,0,0,"C","NaoVazio()","mv_par25","Somente"    ,"","","","","Nใo"      ,"","","","","Ambos","","","","","","","","","","","","","",""   ,"","","",""})

For _x := 1 to Len(aRegs)
	If !MsSeek(cPerg+aRegs[_x,2],.T.,.F.)
		RecLock("SX1",.T.)
		For _y := 1 to FCount()
			If _y <= Len(aRegs[_x])
				FieldPut(_y,aRegs[_x,_y])
			Else
				Exit
			Endif
		Next
		MsUnlock()
	Endif
Next
dbSelectArea(_cAlias)

Return()

