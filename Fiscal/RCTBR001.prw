#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*/{Protheus.doc} RCTBR001
@description Relação de notas fiscais de saída e entrada por item, dentro do período específicado.
@author Anderson C. P. Coelho (ALL SYSTEM SOLUTIONS)
@since 18/01/2016
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RCTBR001()
	Local   oReport
	Local   _aSavArea  := GetArea()
	Private oSection
	Private _cRotina   := "RCTBR001"
	Private cPerg      := _cRotina
	Private _cAliTmp   := "SD2TMP"
	Private cTitulo    := "Relação de notas fiscais por item, dentro do período especificado"
	Private _cTitSec   := "NFs do Período"
	Private _aOrd      := {}
	Private _aTables   := {"SD2","SB1"}
	//Array _aCpos:
	//	Pos.1 = Tabela
	//	Pos.2 = Campo
	//	Pos.3 = Break
	//	Pos.4 = Totaliza         -- CAMPO NÃO UTILIZADO
	//	Pos.5 = Alinhamento
	//	Pos.6 = Tipo de SubTotal
	//  Pos.7 = Título do campo (quando não existir na SX3)
	//  Pos.8 = Tamanho do campo (quando não existir na SX3)
	Private _aCpos     := {	{""   ,"TIPO"      ,.T.,.F.,"CENTER",""     ,"Tipo",04},;
							{"SD2","D2_EMISSAO",.F.,.F.,"CENTER",""     ,""    ,00},;
							{"SD2","D2_COD"    ,.F.,.F.,""      ,""     ,""    ,00},;
							{"SB1","B1_DESC"   ,.F.,.F.,""      ,""     ,""    ,00},;
							{"SB1","B1_POSIPI" ,.F.,.F.,"CENTER",""     ,""    ,00},;
							{"SD2","D2_DOC"    ,.F.,.F.,""      ,""     ,""    ,00},;
							{"SD2","D2_SERIE"  ,.F.,.F.,"CENTER",""     ,""    ,00},;
							{"SD2","D2_CF"     ,.F.,.F.,"CENTER",""     ,""    ,00},;
							{"SD2","D2_PRCVEN" ,.F.,.F.,"RIGHT" ,""     ,""    ,00},;
							{"SD2","D2_QUANT"  ,.F.,.T.,"RIGHT" ,"SUM"  ,""    ,00},;
							{"SD2","D2_TOTAL"  ,.F.,.T.,"RIGHT" ,"SUM"  ,""    ,00},; 
							{"SD2","D2_QTDEDEV",.F.,.T.,"RIGHT" ,"SUM"  ,""    ,00},; 
							{"SD2","D2_VALDEV" ,.F.,.T.,"RIGHT" ,"SUM"  ,""    ,00},; 
							{"SB1","B1_DESC"   ,.F.,.F.,"CENTER" ,""    ,""    ,00},; 
							{"SB1","B1_POSIPI" ,.F.,.T.,"RIGHT" ,"SUM"  ,""    ,00},; 
							{"SF4","F4_CSTPIS" ,.F.,.F.,"CENTER","SUM"  ,""    ,00},; 
							{"SD2","D2_VALIMP6",.F.,.T.,"RIGHT" ,"SUM"  ,""    ,00},; 
							{"SF4","F4_CSTCOF" ,.F.,.F.,"CENTER",""     ,""    ,00},; 
							{"SD2","D2_VALIMP5",.F.,.T.,"RIGHT" ,"SUM"  ,""    ,00},; 
							{"SD2","D2_CLASFIS",.F.,.F.,"CENTER",""     ,""    ,00},; 
							{"SD2","D2_VALICM" ,.F.,.T.,"RIGHT" ,"SUM"  ,""    ,00},; 
							{"SD2","D2_ICMSRET",.F.,.T.,"RIGHT" ,"SUM"  ,""    ,00},; 
							{"SD2","D2_VALIPI" ,.F.,.T.,"RIGHT" ,"SUM"  ,""    ,00},; 
							{"SF4","F4_CTIPI"  ,.F.,.F.,"CENTER",""     ,""    ,00} }
	If !(SubStr(cAcesso,160,1) == "S" .AND. SubStr(cAcesso,168,1) == "S" .AND. SubStr(cAcesso,170,1) == "S")
		MsgStop('Usuário sem permissão para exportar dados para Excel, informe o Administrador!',_cRotina +"001")
		Return(Nil)
	EndIf
	If !ApOleClient('MsExcel')
		MsgStop('Excel não instalado!',_cRotina +"002")
		Return(Nil)
	EndIf
	If FindFunction("TRepInUse") //.AND. TRepInUse()
		ValidPerg()
		If Pergunte(cPerg,.T.)
			oReport := ReportDef()
			oReport:PrintDialog()
		EndIf
	EndIf
	RestArea(_aSavArea)
return
/*/{Protheus.doc} ReportDef
@description A funcao estatica ReportDef devera ser criada para todos os relatorios que poderao ser agendados pelo usuario.
@author Anderson C. P. Coelho (ALL SYSTEM SOLUTIONS)
@since 18/01/2016
@version 1.0
@type function
@return ExpO1, objeto, Objeto do relatório
@see https://allss.com.br
/*/
static function ReportDef()
	Local oReport
	Local _nSqBrk := 0
	Local _nSeqSb := 0

	oReport := TReport():New(_cRotina,cTitulo,cPerg,{|oReport| PrintReport(oReport)},"Emissao do relatório, de acordo com o intervalo informado na opção de Parâmetros.")
	oReport:SetLandscape() 
	oReport:SetTotalInLine(.F.)
	Pergunte(oReport:uParam,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Secao 1                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection := TRSection():New(oReport,_cTitSec,_aTables,_aOrd/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection:SetTotalInLine(.F.)
	For _x := 1 To Len(_aCpos)
		//Array _aCpos:
		//	Pos.1 = Tabela
		//	Pos.2 = Campo
		//	Pos.3 = Break
		//	Pos.4 = Totaliza
		//	Pos.5 = Alinhamento
		//	Pos.6 = Tipo de SubTotal
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Definição dos campos                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(_aCpos[_x][07])
			&("TRCell():New(oSection,'"+_aCpos[_x][02]+"','"+_cAliTmp+"',RetTitle('"+_aCpos[_x][02]+"'),PesqPict('"+_aCpos[_x][01]+"','"+_aCpos[_x][02]+"'),"+IIF(_aCpos[_x][08]>0,cValToChar(_aCpos[_x][08]),"TamSx3('"+_aCpos[_x][02]+"')[1]")+", ,{|| "+_cAliTmp+"->"+_aCpos[_x][02]+" })")
		Else
			&("TRCell():New(oSection,'"+_aCpos[_x][02]+"','"+_cAliTmp+"','"+_aCpos[_x][07]+"'          ,                                                   ,"+IIF(_aCpos[_x][08]>0,cValToChar(_aCpos[_x][08]),"TamSx3('"+_aCpos[_x][02]+"')[1]")+", ,{|| "+_cAliTmp+"->"+_aCpos[_x][02]+" })")
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alinhamento central das colunas                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSection:Cell(_aCpos[_x][02]):SetHeaderAlign(_aCpos[_x][05])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Definição de quebra para sub-totalização.                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If _aCpos[_x][03]
			_nSqBrk++
			If Empty(_aCpos[_x][07])
				&("oBreak"+cValToChar(_nSqBrk)) := TRBreak():New(oSection,oSection:Cell(_aCpos[_x][02]),RetTitle(_aCpos[_x][02]))
			Else
				&("oBreak"+cValToChar(_nSqBrk)) := TRBreak():New(oSection,oSection:Cell(_aCpos[_x][02]),_aCpos[_x][07]          )
			EndIf
		EndIf
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sub-total                                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_xSeqSB := Type("oBreak"+cValToChar(_nSeqSb))
	For _x := 1 To Len(_aCpos)
		If !Empty(_aCpos[_x][06])
			If _nSqBrk > 0
				While _nSqBrk > _nSeqSb
					_nSeqSb++
					If _xSeqSB <> "U"
						TRFunction():New(oSection:Cell(_aCpos[_x][02]),NIL,_aCpos[_x][06],&("oBreak"+cValToChar(_nSeqSb)))
					EndIf
				EndDo
			Else
				TRFunction():New(oSection:Cell(_aCpos[_x][02]),NIL,_aCpos[_x][06])
			EndIf
		EndIf
	Next
return oReport
/*/{Protheus.doc} PrintReport
@description Processamento das informações para impressão (Print).
@author Anderson C. P. Coelho (ALL SYSTEM SOLUTIONS)
@since 18/01/2016
@version 1.0
@type function
@param oReport, objeto, Objeto do relatório
@see https://allss.com.br
/*/
static function PrintReport(oReport)
	If Empty(MV_PAR02) .OR. MV_PAR01 > MV_PAR02
		MsgStop("Parâmetros informados incorretamente!",_cRotina+"_001")
		return
	EndIf
	MakeSqlExpr(oReport:uParam)
	If MV_PAR03 == 1			//SAÍDAS
		oSection:BeginQuery()
			BeginSql Alias _cAliTmp
				SELECT *
				FROM (
							SELECT 'NFS' TIPO, D2_EMISSAO, D2_COD, D2_DOC, D2_SERIE, D2_ITEM, D2_CF
								 , D2_PRCVEN, D2_QUANT, D2_TOTAL, D2_QTDEDEV, D2_VALDEV
								 , B1_DESC, B1_POSIPI
								 , F4_CSTPIS, D2_VALIMP6, F4_CSTCOF, D2_VALIMP5, D2_CLASFIS, D2_VALICM, D2_ICMSRET, D2_VALIPI, F4_CTIPI  
							FROM %table:SD2% SD2 (NOLOCK)		//WITH (INDEX=[SD2010_01_TMP_IDX_006], NOLOCK)
									INNER JOIN %table:SB1% SB1 (NOLOCK) ON SB1.B1_FILIAL = %xFilial:SB1%
															  AND SB1.B1_COD    = SD2.D2_COD
															  AND SB1.%NotDel%
									INNER JOIN %table:SF4% SF4 (NOLOCK) ON SF4.F4_FILIAL = %xFilial:SF4%
															  AND SF4.F4_CODIGO = SD2.D2_TES
															  AND SF4.%NotDel%
							WHERE SD2.D2_FILIAL        = %xFilial:SD2%
							  AND SD2.D2_SCOA          = %Exp:''%													//Filtra as notas importadas do Scoa
							  AND SD2.D2_EMISSAO BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
							  AND SD2.%NotDel%
						UNION ALL
							SELECT 'DEV' TIPO, D1_DTDIGIT D2_EMISSAO, D1_COD D2_COD, D1_DOC D2_DOC, D1_SERIE D2_SERIE, D1_ITEM D2_ITEM, D1_CF D2_CF
								 , D1_VUNIT D2_PRCVEN, D1_QUANT D2_QUANT, D1_TOTAL D2_TOTAL, 0 D2_QTDEDEV, 0 D2_VALDEV
								 , B1_DESC, B1_POSIPI
								 , F4_CSTPIS, D1_VALIMP6 D2_VALIMP6, F4_CSTCOF, D1_VALIMP5 D2_VALIMP5, D1_CLASFIS D2_CLASFIS, D1_VALICM D2_VALICM, D1_ICMSRET D2_ICMSRET, D1_VALIPI D2_VALIPI, F4_CTIPI
							FROM %table:SD1% SD1 (NOLOCK)
									INNER JOIN %table:SB1% SB1 (NOLOCK) ON SB1.B1_FILIAL = %xFilial:SB1%
															  AND SB1.B1_COD    = SD1.D1_COD
															  AND SB1.%NotDel%
									INNER JOIN %table:SF4% SF4 (NOLOCK) ON SF4.F4_FILIAL = %xFilial:SF4%
															  AND SF4.F4_CODIGO = SD1.D1_TES
															  AND SF4.%NotDel%
							WHERE SD1.D1_FILIAL        = %xFilial:SD1%
							  AND SD1.D1_SCOA          = %Exp:''%													//Filtra as notas importadas do Scoa
							  AND SD1.D1_DTDIGIT BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
							  AND SD1.D1_TIPO         IN ('D','B')
							  AND SD1.%NotDel%
					 ) TEMP
				ORDER BY TIPO, D2_EMISSAO, D2_SERIE, D2_DOC, D2_ITEM
			EndSql
		oSection:EndQuery()
	Else						//ENTRADAS
		oSection:BeginQuery()
			BeginSql Alias _cAliTmp
				SELECT *
				FROM (
							SELECT 'NFE' TIPO, D1_DTDIGIT D2_EMISSAO, D1_COD D2_COD, D1_DOC D2_DOC, D1_SERIE D2_SERIE, D1_ITEM D2_ITEM, D1_CF D2_CF
								 , D1_VUNIT D2_PRCVEN, D1_QUANT D2_QUANT, D1_TOTAL D2_TOTAL, D1_QTDEDEV D2_QTDEDEV, D1_VALDEV D2_VALDEV
								 , B1_DESC, B1_POSIPI
								 , F4_CSTPIS, D1_VALIMP6 D2_VALIMP6, F4_CSTCOF, D1_VALIMP5 D2_VALIMP5, D1_CLASFIS D2_CLASFIS, D1_VALICM D2_VALICM, D1_ICMSRET D2_ICMSRET, D1_VALIPI D2_VALIPI, F4_CTIPI  
							FROM %table:SD1% SD1 (NOLOCK)
									INNER JOIN %table:SB1% SB1 (NOLOCK) ON SB1.B1_FILIAL = %xFilial:SB1%
															  AND SB1.B1_COD    = SD1.D1_COD
															  AND SB1.%NotDel%
									INNER JOIN %table:SF4% SF4 (NOLOCK) ON SF4.F4_FILIAL = %xFilial:SF4%
															  AND SF4.F4_CODIGO = SD1.D1_TES
															  AND SF4.%NotDel%
							WHERE SD1.D1_FILIAL        = %xFilial:SD1%
							  AND SD1.D1_SCOA          = %Exp:''%													//Filtra as notas importadas do Scoa
							  AND SD1.D1_DTDIGIT BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
							  AND SD1.%NotDel%
						UNION ALL
							SELECT 'DEV' TIPO, D2_EMISSAO, D2_COD, D2_DOC, D2_SERIE, D2_ITEM, D2_CF
								 , D2_PRCVEN, D2_QUANT, D2_TOTAL, 0 D2_QTDEDEV, 0 D2_VALDEV
								 , B1_DESC, B1_POSIPI
								 , F4_CSTPIS, D2_VALIMP6, F4_CSTCOF, D2_VALIMP5, D2_CLASFIS, D2_VALICM, D2_ICMSRET, D2_VALIPI, F4_CTIPI
							FROM %table:SD2% SD2 (NOLOCK)
									INNER JOIN %table:SB1% SB1 (NOLOCK) ON SB1.B1_FILIAL = %xFilial:SB1%
															  AND SB1.B1_COD    = SD2.D2_COD
															  AND SB1.%NotDel%
									INNER JOIN %table:SF4% SF4 (NOLOCK) ON SF4.F4_FILIAL = %xFilial:SF4%
															  AND SF4.F4_CODIGO = SD2.D2_TES
															  AND SF4.%NotDel%
							WHERE SD2.D2_FILIAL        = %xFilial:SD2%
							  AND SD2.D2_SCOA          = %Exp:''%													//Filtra as notas importadas do Scoa
							  AND SD2.D2_EMISSAO BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
							  AND SD2.D2_TIPO         IN ('D','B')
							  AND SD2.%NotDel%
					 ) TEMP
				ORDER BY TIPO, D2_EMISSAO, D2_SERIE, D2_DOC, D2_ITEM
			EndSql
		oSection:EndQuery()
	EndIf
	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.txt",oSection:CQUERY)
	oSection:Print()
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg º Autor ³Adriano Leonardo      º Data ³  18/06/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função responsável pela inclusão de parâmetros na rotina.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*/{Protheus.doc} ValidPerg
@description Função responsável pela inclusão de parâmetros na rotina.
@author Anderson C. P. Coelho (ALL SYSTEM SOLUTIONS)
@since 18/01/2016
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	Local _sAlias := GetArea()
	Local aRegs   := {}
	Local i       := 0
	Local j       := 0

	_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	cPerg         := PADR(cPerg,len((_cAliasSX1)->X1_GRUPO))
	AADD(aRegs,{cPerg,"01","De Data?" 	  		    ,"","","mv_ch1","D",08,0,0,"G","NaoVazio()","mv_par01",""     ,"","","20130401","",""       ,"","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Até Data?"	  		    ,"","","mv_ch2","D",08,0,0,"G","NaoVazio()","mv_par02",""     ,"","","20491231","",""       ,"","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Tipo    ?"	  		    ,"","","mv_ch3","N",01,0,0,"C","NaoVazio()","mv_par03","Saída","","",""        ,"","Entrada","","","","","","","","","","","","","","","","","","","",""})
	For i := 1 To Len(aRegs)
		If !(_cAliasSX1)->(dbSeek(cPerg+aRegs[i,2]))
			RecLock(_cAliasSX1,.T.)
			For j:=1 To FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Else
					Exit
				EndIf
			Next
			(_cAliasSX1)->(MsUnlock())
		EndIf
	Next
	RestArea(_sAlias)
return