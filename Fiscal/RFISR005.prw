#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE _CRFL CHR(13) + CHR(10)
/*
Verificar o GETXML Danfeii
*/
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �          � Autor �                       � Data �   /  /   ���
�������������������������������������������������������������������������Ĵ��
���Descricao �                                                            ���
���          �                                                            ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������           
*/

User Function RFISR005()

Local oReport

Private oSection
Private _cRotina := "RFISR005"
Private cPerg    := _cRotina
Private nTamCod

If FindFunction("TRepInUse") .AND. TRepInUse() //.AND. Pergunte(cPerg,.T.)
	ValidPerg()
	/*
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
	*/
	oReport:= ReportDef()
	oReport:PrintDialog()
EndIf

Return()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �                       � Data �  /  /    ���
�������������������������������������������������������������������������Ĵ��
���Descricao �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Programa Principal.                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ReportDef()

Local oReport
Local oSection // Secao 1
Local oSection1 // Secao 2
Local cTitle    := OemToAnsi("Relat�rio de auditoria de produtos espec.")
Private nTamCod := 0
//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������
oReport := TReport():New(_cRotina,cTitle,cPerg, {|oReport| ReportPrint(oReport)},"Emissao do relat�rio, de acordo com o intervalo informado na op��o de Par�metros.")
oReport:SetLandscape() //Define a orientacao de pagina do relatorio como paisagem.
//oReport:SetPortrait() //Define a orientacao de pagina do relatorio como retrato.
nTamCod := 0
//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte(oReport:GetParam(),.F.)
//Pergunte(oReport:uParam,.F.)
//������������������������������������������������������������������������Ŀ
//�Criacao das secoes utilizadas pelo relatorio                            �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//��������������������������������������������������������������������������
//�������������������������������������������������������������Ŀ
//� Section 1 - Produtos Pai                                    �
//���������������������������������������������������������������
oSection1 := TRSection():New(oReport,"Relat�rio de auditoria de produtos",{"SD2","SC6","SC5","SFT"},/*Ordem*/) //"Estruturas"
//oSection1:SetHeaderBreak()
TRCell():New(oSection1,"_dEmiss"  ,/*Alias*/,"Emiss�o"    ,/*Picture*/,TamSX3("D2_EMISSAO")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"_cDoc"    ,/*Alias*/,"Documento"  ,/*Picture*/,TamSX3("D2_DOC"    )[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"_cSerie"  ,/*Alias*/,"S�rie"      ,/*Picture*/,TamSX3("D2_SERIE"  )[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"_cPed"    ,/*Alias*/,"Pedido"     ,/*Picture*/,TamSX3("D2_PEDIDO" )[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"_cItem"   ,/*Alias*/,"Item"       ,/*Picture*/,TamSX3("D2_ITEM"   )[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"_cProdD2" ,/*Alias*/,"Prod DANFe" ,/*Picture*/,TamSX3("D2_COD"    )[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"_cProdFT" ,/*Alias*/,"Prod Livro" ,/*Picture*/,TamSX3("FT_PRODUTO")[1],/*lPixel*/,/*{|| code-block de impressao }*/)

//�������������������������������������������������������������Ŀ
//� Section 2 - Componentes                                     �
//���������������������������������������������������������������
//oSection2 := TRSection():New(oSection1,STR0020,{"SG1","SB1","SC1","SD4","SC7","SC2","SC6","SB3","SB2"},/*Ordem*/) //"Produtos"
//oSection2:SetHeaderPage()
//TRCell():New(oSection2,'B1_COD'  	,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell(D):New(oSection2,'B1_DESC' 	,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():New(oSection2,'B1_TIPO' 	,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint � Autor �                     � Data �  /  /    ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportPrint devera ser criada para todos  ���
���          �os relatorios que poderao ser agendados pelo usuario.       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relatorio                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Programa Principal.                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ReportPrint(oReport)

Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(1):Section(1)
Local oBreak, oBreak2
Local oFunction
Local cFilter
Local nCntFor
Local _cAlias := 'TMPTRA'

//��������������������������������������������������������������Ŀ
//� Variaveis usadas na impressao dos componentes da Estrutura   �
//����������������������������������������������������������������
//Private nSaldoEst := nEmp:=nSCPro:=nPCPro:=nOPPro:=nPVPro:=0
//Private dUsai     := CtoD("  /  /  ") 

_cQry := ""
//_cQry += " SELECT D2_EMISSAO[EMISS],D2_DOC[DOC],D2_SERIE[SERIE],D2_PEDIDO[PED],D2_COD[PRODD2],FT_PRODUTO[PRODFT] " + _CRFL
_cQry += " SELECT * " + _CRFL
_cQry += " FROM ( SELECT D2_EMISSAO[EMISS],D2_DOC[DOC],D2_SERIE[SERIE],D2_PEDIDO[PED],D2_COD[CODD2] " + _CRFL
_cQry += " ,FT_PRODUTO[CODFT],FT_ORGPRD[PRD],D2_ITEMPV[ITPV],D2_ITEM[ITD2],FT_ITEM[ITFT] " + _CRFL
_cQry += " 		  FROM "+(RetSqlName("SD2"))+" SD2 " + _CRFL
_cQry += " 			  LEFT JOIN "+(RetSqlName("SFT"))+" SFT " + _CRFL
_cQry += " 				  ON SFT.D_E_L_E_T_  = '' " + _CRFL
_cQry += " 				  AND SFT.FT_FILIAL  = '"+(xFilial("SFT"))+"' " + _CRFL
_cQry += " 				  AND SFT.FT_NFISCAL = SD2.D2_DOC " + _CRFL
_cQry += " 				  AND SFT.FT_SERIE   = SD2.D2_SERIE " + _CRFL
_cQry += " 				  AND SFT.FT_ITEM    = SD2.D2_ITEM " + _CRFL
_cQry += " 		  WHERE SD2.D_E_L_E_T_ = '' " + _CRFL
_cQry += " 		  AND SD2.D2_FILIAL  = '"+(xFilial("SD2"))+"' " + _CRFL
_cQry += " 		  AND SD2.D2_COD     = FT_PRODUTO " + _CRFL
_cQry += " 		  AND SD2.D2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' " + _CRFL
_cQry += " 		  AND SD2.D2_DOC     BETWEEN '"+    (MV_PAR03)+"' AND '"+    (MV_PAR04)+"' " + _CRFL
_cQry += " 		  AND SD2.D2_SERIE   BETWEEN '"+    (MV_PAR05)+"' AND '"+    (MV_PAR06)+"' " + _CRFL
_cQry += " 		  AND SD2.D2_CLIENTE BETWEEN '"+    (MV_PAR07)+"' AND '"+    (MV_PAR09)+"' " + _CRFL
_cQry += " 		  AND SD2.D2_LOJA    BETWEEN '"+    (MV_PAR08)+"' AND '"+    (MV_PAR10)+"' " + _CRFL
_cQry += " 		  ) SD2X " + _CRFL
_cQry += " 		  INNER JOIN  " + _CRFL
_cQry += " 		  (SELECT C5_NUM,C6_PRODUTO,C6_ITEM " + _CRFL
_cQry += " 		   FROM "+(RetSqlName("SC5"))+" SC5 " + _CRFL
_cQry += " 			  INNER JOIN "+(RetSqlName("SC6"))+" SC6 " + _CRFL
_cQry += " 			  ON SC6.D_E_L_E_T_     = '' " + _CRFL
_cQry += " 				  AND SC6.C6_FILIAL = '"+(xFilial("SC6"))+"' " + _CRFL
_cQry += " 				  AND SC6.C6_NUM    = SC5.C5_NUM " + _CRFL
_cQry += " 				  AND SC6.C6_TPCALC = 'V' " + _CRFL
_cQry += " 		  WHERE SC5.D_E_L_E_T_ = '' " + _CRFL
_cQry += " 		  AND SC5.C5_FILIAL    = '"+(xFilial("SC5"))+"' " + _CRFL
_cQry += " 		  AND (SC5.C5_TPDIV    = '1' OR SC5.C5_TPDIV = '2' OR SC5.C5_TPDIV = '3') " + _CRFL
_cQry += " 		  )SC5X " + _CRFL
_cQry += " ON SC5X.C5_NUM      = SD2X.PED " + _CRFL
_cQry += " AND SC5X.C6_PRODUTO = SD2X.CODD2 " + _CRFL
_cQry += " AND SC5X.C6_ITEM    = SD2X.ITD2 " + _CRFL
/*
_cQry += " ON SC5X.C5_NUM      = SD2X.D2_PEDIDO " + _CRFL
_cQry += " AND SC5X.C6_PRODUTO = SD2X.D2_COD " + _CRFL
_cQry += " AND SC5X.C6_ITEM    = SD2X.D2_ITEMPV " + _CRFL
*/
/*
If __cUserId == "000000"
	MemoWrite("\"+_cRotina+"_QRY_001",_cQry)
EndIf
*/
_cQry := ChangeQuery(_cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cAlias,.T.,.T.)
dbSelectArea(_cAlias)
(_cAlias)->(dbGoTop())

If !(_cAlias)->(EOF())
	//oBreak  := TRBreak():New(oSection1,oSection1:Cell((_cProd)->DOC),NIL,.F.)
	oReport:SetMeter((_cAlias)->(RecCount()))
	oSection1:Init()
	While !oReport:Cancel() .And. !(_cAlias)->(Eof())
		oReport:IncMeter()

		oSection1:Cell("_dEmiss" ):SetValue((_cAlias)->EMISS)
		oSection1:Cell("_cDoc"   ):SetValue((_cAlias)->DOC)
		oSection1:Cell("_cSerie" ):SetValue((_cAlias)->SERIE)
		oSection1:Cell("_cPed"   ):SetValue((_cAlias)->PED)
		oSection1:Cell("_cItem"  ):SetValue((_cAlias)->ITPV)
		oSection1:Cell("_cProdD2"):SetValue((_cAlias)->CODD2)
		oSection1:Cell("_cProdFT"):SetValue((_cAlias)->CODFT)

		oReport:SkipLine()
		oSection1:PrintLine() // Impressao da secao 1
		(_cAlias)->(dbSkip())
	EndDo
Else
	MsgAlert("Nada a imprimir!",_cRotina+"_001")
EndIf
oSection1:Finish()
(_cAlias)->(dbCloseArea())

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ValidPerg � Autor �                       � Data �  /  /    ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Cria as perguntas na SX1, caso n�o existam.                 ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Programa Principal.                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ValidPerg()

//Alert("Crie as perguntas!")
Local _aArea := GetArea()
Local aRegs  := {}
Local _aTam  := {}

cPerg := PADR(cPerg,10)

_aTam := TamSx3("D2_EMISSAO"    )
AADD(aRegs,{cPerg,"01","De Emiss�o?"    ,"","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"02","At� Emiss�o?"   ,"","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"",""})
_aTam := TamSx3("D2_DOC")
AADD(aRegs,{cPerg,"03","De Documento?"  ,"","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SF2","",""})
AADD(aRegs,{cPerg,"04","At� Documento?" ,"","","mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SF2","",""})
_aTam := TamSx3("D2_SERIE")
AADD(aRegs,{cPerg,"05","De S�rie?"      ,"","","mv_ch5",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"06","At� S�rie?"     ,"","","mv_ch6",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"",""})
_aTam := TamSx3("A1_COD"    )
AADD(aRegs,{cPerg,"07","Do Cliente?"    ,"","","mv_ch7",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SA1","",""})
_aTam := TamSx3("A1_LOJA"   )
AADD(aRegs,{cPerg,"08","Da Loja?"       ,"","","mv_ch8",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par08","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"",""})
_aTam := TamSx3("A1_COD"    )
AADD(aRegs,{cPerg,"09","At� o Cliente?" ,"","","mv_ch9",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","SA1","",""})
_aTam := TamSx3("A1_LOJA"   )
AADD(aRegs,{cPerg,"10","At� a Loja?"    ,"","","mv_cha",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"",""})

For i := 1 To Len(aRegs)
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If !SX1->(dbSeek(cPerg+aRegs[i,2]))
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

RestArea(_aArea)

Return