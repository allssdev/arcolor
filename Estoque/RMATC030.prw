//#INCLUDE "MATC030.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE USADO CHR(0)+CHR(0)+CHR(1)

/*/{Protheus.doc} RMATC030
@description Consulta do Kardex/dia somente em quantidade.
@obs Manipula��o da rotina padr�o MATC030, para este fim.
     Os seguintes pontos de entrada est�o vinculados a esta funcionalidade:
      * MC030ARR;
      * MC050BUT;
      Somente os IDs de usu�rios relacionados no par�metro MV_CUSKARD poder�o visualizar o custo dos materiais no Kardex.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 22/05/2015
@version 1.0
@type function
@see https://allss.com.br
/*/
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATC030  � Autor � Paulo Boschetti       � Data � 18/03/93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta do Kardex                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Patricia Sal�03/08/00�PROTHE� Revisao Geral do Programa            .   ���
���Fernando M. �23.08.00�xxxxxx� Mostrar fatura ao classificar guia(Loc.  ���
���            �        �      � Chile) e ajuste de tela                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Descri�ao � PLANO DE MELHORIA CONTINUA        �Programa: MATC030.PRX	  ���
�������������������������������������������������������������������������Ĵ��
���ITEM PMC  � Responsavel              � Data                            ���
�������������������������������������������������������������������������Ĵ��
���      01  � Marcos V. Ferreira       � 15/05/2006 - Bops: 00000098568  ���
���      02  � Marcos V. Ferreira       � 25/01/2006                      ���
���      03  �                          �                                 ���
���      04  � Ricardo Berti            � 31/10/2006 - Bops: 00000110514  ���
���      05  � Erike Yuri da Silva      � 09/02/2006 - Bops: 00000091779  ���
���      06  � Marcos V. Ferreira       � 15/05/2006 - Bops: 00000098568  ���
���      07  � Marcos V. Ferreira       � 25/01/2006                      ���
���      08  � Erike Yuri da Silva      � 09/02/2006 - Bops: 00000091779  ���
���      09  � Nereu Humberto Junior    � 27/11/2006 - Bops: 00000114134  ���
���      10  � Ricardo Berti            � 31/10/2006 - Bops: 00000110514  ���
���      11  � Marco A. Abramo Vieira   � 17/04/2008 - Bops: 00000144401  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function RMATC030(_nOpc)
local cProdMNT  := GetMV("MV_PRODMNT")
local cProdTER  := GetMV("MV_PRODTER")
local lProIsMNT	:= 	MTC030IsMNT()
local cFiltraSB1:= ""
local cMc030Fil := ""
local aProdsMNT := {}
local nX        := 0
                      
Default _nOpc   := 0

//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
If ("#"+__cUserId+"#")$SuperGetMv("MV_CUSKARD",,"#000000#000019#000045#000046#000047#000023#")
	SetFunName("MATC030")
//	MC030Con()
	MATC030()
Else
	PRIVATE aRotina := MenuDef()
	//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
	/*
	aRotina := {	{OemToAnsi("Pesquisar"),"AxPesqui", 0 , 1},;
					{OemToAnsi("Consulta"),"MC030Con", 0 , 2}}
	*/
	//��������������������������������������������������������������Ŀ
	//� Verifica se utiliza custo unificado por Empresa/Filial       �
	//����������������������������������������������������������������
	PRIVATE lCusUnif := IIf(FindFunction("A330CusFil"),A330CusFil(),GetNewPar("MV_CUSFIL",.F.))
	PRIVATE cFiltro := ""
	PRIVATE aIndFiltro := {}
	PRIVATE bFiltro	:= { || FilBrowse( "SB1", @aIndFiltro, @cFiltraSB1 ) }

	// FB - RELEASE 12.1.23
	_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	// FIM FB
	
	//��������������������������������������������������������������Ŀ
	//� Ajusta perguntas no SX1 a fim de preparar o relatorio p/     �
	//� custo unificado por empresa                                  �
	//����������������������������������������������������������������
	If lCusUnif
		MTC030CUnf()
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Ajusta as perguntas do MTC030							     �
	//����������������������������������������������������������������
	AjustaSX1()

	//��������������������������������������������������������������Ŀ
	//� Recupera o desenho padrao de atualizacoes                    �
	//����������������������������������������������������������������
	cCadastro := OemtoAnsi("Consulta ao Kardex")

	//����������������������������������������������������������������Ŀ
	//� Ativa tecla F12 para acessar os parametros                     �
	//������������������������������������������������������������������
	SetKey( VK_F12,{ || pergunte("MTC030",.T.) } )

	//��������������������������������������������������������������Ŀ
	//� Verifica as perguntas selecionadas                           �
	//����������������������������������������������������������������
	//��������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros                         �
	//� mv_par01        // Data inicial                              �
	//� mv_par02        // Data final                                �
	//� mv_par03        // Qual Almoxarifado                         �
	//� mv_par04        // Saldo item a item : Sim / Nao             �
	//� mv_par05        // Qual Moeda ? 1 2 3 4 5                    |
	//� mv_par06        // Imprime Localizacao: Sim / Nao            �
	//� mv_par07        // Sequencia Impressao : Digitacao / Calculo �
	//� mv_par08         // Lista Transf Locali (Sim/Nao)            �
	//����������������������������������������������������������������
	If Pergunte("MTC030",.T.)
		If lProIsMNT
			cFiltraSB1 := "B1_FILIAL == '" + xFilial("SB1") + "' "
			If FindFunction("NGProdMNT")
				aProdsMNT := aClone(NGProdMNT())
				For nX := 1 To Len(aProdsMNT)
					cFiltraSB1 += " .And. B1_COD <> '" + aProdsMNT[nX] + "' "
				Next nX
			Else
				cFiltraSB1 += " .And. B1_COD <> '" + cProdMNT + "' "
				cFiltraSB1 += " .And. B1_COD <> '" + cProdTER + "' "
			EndIf
			MsAguarde({|| Eval(bFiltro)},"Aguarde. Filtrando registros.")
		EndIf	
		If (ExistBlock("MC030FIL"))
			cMc030Fil := ExecBlock("MC030FIL",.F.,.F.,{cFiltraSB1})
			If ( ValType(cMc030Fil) == "C" ) .And. !Empty(cMc030Fil)
				cFiltraSB1 := cMc030Fil
			EndIf
			MsAguarde({|| Eval(bFiltro)},"Aguarde. Filtrando registros.")
		EndIf
		//��������������������������������������������������������������Ŀ
		//� Endereca a funcao de BROWSE                                  �
		//����������������������������������������������������������������
		mBrowse( 6, 1,22,75,"SB1")

		If lProIsMNT
			EndFilBrw("SB1",aIndFiltro)	
		EndIf	
		If ( Len(aIndFiltro)>0 )
			//������������������������������������������������������������������������Ŀ
			//� Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       �
			//��������������������������������������������������������������������������
			EndFilBrw("SB1",aIndFiltro)	
		EndIf				
		//��������������������������������������������������������������Ŀ
		//� Desativa tecla F12                                           �
		//����������������������������������������������������������������
		Set Key VK_F12 To

		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
	EndIf
EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MC030Con � Autor � Paulo Boschetti       � Data � 18/03/93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Envia para funcao que monta o arquivo de trabalho com as   ���
���          � movimentacoes e mostra-o na tela                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATC030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function Mc030Con(_cOrigem)
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
	local bKeyF12 := SetKey( VK_F12 )
	If Type("_cOrigem")=="U".OR.AllTrim(_cOrigem)=="PE"
		//��������������������������������������������������������������Ŀ
		//� Verifica se utiliza custo unificado por Empresa/Filial       �
		//����������������������������������������������������������������
		PRIVATE lCusUnif := IIf(FindFunction("A330CusFil"),A330CusFil(),GetNewPar("MV_CUSFIL",.F.))
		//��������������������������������������������������������������Ŀ
		//� Ajusta perguntas no SX1 a fim de preparar o relatorio p/     �
		//� custo unificado por empresa                                  �
		//����������������������������������������������������������������
		If lCusUnif
			MTC030CUnf()
		EndIf
		If Pergunte("MTC030",.T.)
			Set Key VK_F12 To
			SetKey( VK_F12, { || pergunte("MTC030",.T.) } )
			ProcConsulta()
			Set Key VK_F12 To
			SetKey( VK_F12, { || pergunte("MTC050",.T.) } )	
		EndIf
		Pergunte("MTC050",.F.)
		Set Key VK_F12 To
	Else
		ProcConsulta()
	EndIf

	Return

	Static Function ProcConsulta()
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
local aSalTel := {} ,nCusMed := 0 ,aSalIni := {}
local aArea:=GetArea()
local bKeyF12	:=  SetKey( VK_F12 )
PRIVATE aGraph  := {}
PRIVATE aTrbP   := {}
PRIVATE aTrbTmp := {}
PRIVATE aTela   := {}
PRIVATE aSalAtu := { 0,0,0,0,0,0,0 }
PRIVATE cPictTotQT:=PesqPictQt("B2_QATU")
PRIVATE nTotSda := nTotEnt :=  nTotvSda := nTotvEnt  := 0
PRIVATE cTRBSD1 := CriaTrab(,.F.)
PRIVATE cTRBSD2 := Subs(cTRBSD1,1,7)+"A"
PRIVATE cTRBSD3 := Subs(cTRBSD1,1,7)+"B"
PRIVATE cPictQT := PesqPict("SB2","B2_QATU",18) 

//��������������������������������������������������������������Ŀ
//� Desativa tecla F12                                           �
//����������������������������������������������������������������
Set Key VK_F12 To

//��������������������������������������������������������������Ŀ
//� Grava as movimentacoes no arquivo de trabalho                �
//����������������������������������������������������������������
Processa({|| aSalTel := MC030Monta()},, cCadastro)

If Len(aTrbP) > 0
	
	If aSalTel[1] > 0 .AND. aSalTel[mv_par05+1] > 0
		nCusMed := aSalTel[mv_par05+1]/aSalTel[1]
	ElseIf aSalTel[1] == 0 .AND. aSalTel[mv_par05+1] == 0
		nCusMed := 0
	ElseIf aSalTel[1] < 0 .AND. aSalTel[mv_par05+1] < 0
		nCusMed := aSalTel[mv_par05+1]/aSalTel[1]		
	Else
		nCusMed := aSalTel[mv_par05+1]
	Endif
	aAdd(aSalIni,Transf(aSaltel[1],PesqPict("SD1","D1_QUANT",18)))
	aAdd(aSalIni,Transf(nCusMed,PesqPict("SB2","B2_CM1")))
	aAdd(aSalIni,Transf(aSaltel[mv_par05+1],PesqPict("SB9","B9_VINI1")))
	MW030Brows(aSalIni)
	//������������������������������������������������Ŀ
	//� Apaga Arquivos Temporarios                     �
	//��������������������������������������������������
	FERASE(cTrbSD1+GetDBExtension())
	FERASE(cTrbSD1+OrdbagExt())
	FERASE(cTrbSD2+GetDBExtension())
	FERASE(cTrbSD2+OrdbagExt())
	FERASE(cTrbSD3+GetDBExtension())
	FERASE(cTrbSD3+OrdbagExt())
Else
	Help("",1,"MC030NOREC")
EndIf
//��������������������������������������������������������������Ŀ
//� Recupera a Ordem Original do arquivo principal               �
//����������������������������������������������������������������
dbSelectArea("SD1")
SD1->(dbSetOrder(1))
dbSelectArea("SD2")
SD2->(dbSetOrder(1))
dbSelectArea("SD3")
SD3->(dbSetOrder(1))
RestArea(aArea)

//�������������������������������������������Ŀ
//� Ativa tecla F12 para acessar os parametros�
//���������������������������������������������
SetKey( VK_F12,bKeyF12)
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MC030Monta� Autor � Paulo Boschetti       � Data � 18/03/93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava arquivo de trabalho                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum 						                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpA1 = Array do saldo inicial	                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Marcio Lopes�17/04/06�96428 � Foi incluso a verificacao quando eh      ���
���			   �		�	   � emitida a nota sobre cupom, ou seja, nao ���
���			   �		�	   � eh para ser apresentada no Kardex essa   ���
���			   �		�	   � nota.                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

STATIC Function MC030Monta()
Static lIxbConTes  := NIL
local dCntData
local nCusMed   := 0
local cIdent    := ""
local aSaldoIni := {}
local cDocumento:=""
local aRetorno  := {cPictQT, cPictTotQT}
local nInd,cCondicao
local cNumSeqTr := "" , nRegTr := 0
local cAlias    := "", cSeqIni := ""
local i         := 0
local aDados	:= {}
//��������������������������������������������������������������Ŀ
//� Verifica se existe ponto de entrada                          �
//����������������������������������������������������������������
local lTesNEst  := .F.
local lMc030Idmv:= ExistBlock("MC030IDMV")

// Indica se esta listando relatorio do almox. de processo
local lLocProc  := mv_par03 == SuperGetMV("MV_LOCPROC")
// Indica se deve imprimir movimento invertido (almox. de processo)
local lInverteMov:= .F.
local cProdMNT	 := GetMv("MV_PRODMNT")
local cDepTrf    := SuperGetMv("MV_DEPTRANS",.F.,"95")	// Dep.transferencia
local lTranSB2   := SuperGetMv("MV_TRANSB2",.F.,.F.)	// Atualiza saldos de transferencia
//���������������������������������������������������������������������Ŀ
//�  Indica produto MANUTENCAO (MV_PRODMNT) qdo integrado com MNT       �
//�����������������������������������������������������������������������
local lProIsMNT	:= 	MTC030IsMNT()
local cAliasSD2 := "SD2" // por default deve ser a tabela SD2
local cQuerySD2 := ""
local lQuerySD2 := .F.    
local aProdsMNT := {}

ProcRegua(mv_par02 - mv_par01)
      
lIxbConTes := IF(lIxbConTes == NIL,ExistBlock("MTAAVLTES"),lIxbConTes)
       
//��������������������������������������������������������������Ŀ
//� Verifica se utiliza custo unificado por Empresa/Filial       �
//����������������������������������������������������������������
PRIVATE lCusUnif := IIf(FindFunction("A330CusFil"),A330CusFil(),SuperGetMV("MV_CUSFIL",.F.))
lCusUnif:=lCusUnif .And. "*" $ mv_par03


//������������������������������������������������Ŀ
//� Calcula o Saldo Inicial do Produto             �
//��������������������������������������������������
If lCusUnif
	aArea:=GetArea()
	dbSelectArea("SB2")
	SB2->(dbSetOrder(1))
	SB2->(MsSeek(xFilial("SB2")+SB1->B1_COD,.T.,.F.))
	While !SB2->(Eof()) .And. B2_FILIAL+B2_COD == xFilial()+SB1->B1_COD
		aSalAlmox := CalcEst(SB1->B1_COD,SB2->B2_LOCAL,mv_par01)
		For i:=1 to Len(aSalAtu)
			aSalAtu[i] += aSalAlmox[i]
		Next i
		dbSelectArea("SB2")
		SB2->(dbSetOrder(1))
		SB2->(dbSkip())
	EndDo
	RestArea(aArea)
Else
	aSalAtu  := CalcEst(SB1->B1_COD,mv_par03,mv_par01)
EndIf
aSaldoIni:= ACLONE(aSalAtu)

//������������������������������������������������Ŀ
//� Ponto de entrada para Altera��o de Picture.    �
//��������������������������������������������������
If ExistBlock('MC030PIC')
	aRetorno := ExecBlock('MC030PIC', .F., .F., aRetorno)
	If ValType(aRetorno) == 'A'
		cPictQT    := aRetorno[1]
		cPictTotQT := aRetorno[2]
	EndIf
EndIf
dCntData  := mv_par01
dbSelectArea("SD1")
If mv_par07 == 1
	//��������������������������������������������������������������Ŀ
	//� Cria Indice condicional p/ Custo Unificado                   �
	//����������������������������������������������������������������
	If lCusUnif
		dbSelectArea("SD1")
		cIndice:="D1_FILIAL+D1_COD+DTOS(D1_DTDIGIT)+D1_NUMSEQ"
		cFiltro:=dbFilter()
		IndRegua("SD1",cTrbSD1,cIndice,,"D1_COD == '" + SB1->B1_COD + "'" + If(!Empty(cFiltro)," .AND. " + cFiltro,""),"Selecionando Registros...")
		nInd := RetIndex("SD1")
		#IFNDEF TOP
			dbSetIndex(cTrbSD1+OrdBagExt())
		#ENDIF
		SD1->(dbSetOrder(nInd+1))
	Else
		SD1->(dbSetOrder(7))
	EndIf
Else
	If lCusUnif
		cIndice:="D1_FILIAL+D1_COD+DTOS(D1_DTDIGIT)+D1_SEQCALC+D1_NUMSEQ"
	Else
		cIndice:="D1_FILIAL+D1_COD+D1_LOCAL+DTOS(D1_DTDIGIT)+D1_SEQCALC+D1_NUMSEQ"
	EndIf
	cFiltro:=dbFilter()
	IndRegua("SD1",cTRBSD1,cIndice,,"D1_COD == '" + SB1->B1_COD + "'" + If(!Empty(cFiltro)," .AND. " + cFiltro,""),"Selecionando Registros...")
	nInd := RetIndex("SD1")
	#IFNDEF TOP
		dbSetIndex(cTRBSD1+OrdBagExt())
	#ENDIF
	SD1->(dbSetOrder(nInd+1))
Endif
dbSeek(cFilial+SB1->B1_COD+If(lCusUnif,"",mv_par03)+dtos(dCntData),.T.)
         
#IFDEF TOP
	cQuerySD2 := "SELECT SD2.D2_FILIAL, SD2.D2_COD, SD2.D2_EMISSAO "
	cQuerySD2 +=     " , SD2.D2_NUMSEQ, SD2.D2_LOCAL, SD2.D2_SEQCALC, SD2.D2_ORIGLAN "
	cQuerySD2 +=     " , SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA "
	cQuerySD2 +=     " , SD2.D2_REMITO, SD2.D2_TPDCENV, SD2.D2_TES, SD2.R_E_C_N_O_ RECSD2 "
	cQuerySD2 +=  " FROM "+ RetSQLTab('SD2') + "(NOLOCK) "
	cQuerySD2 += " WHERE SD2.D2_FILIAL = '"+xFilial("SD2")+"' "
	cQuerySD2 +=   " AND SD2.D2_COD = '" + SB1->B1_COD + "' "
	If !lCusUnif
		cQuerySD2 += " AND SD2.D2_local = '" + mv_par03 + "' "
	EndIf
	cQuerySD2 += " AND SD2.D2_EMISSAO >= '" + DToS(dCntData) + "' "
	cQuerySD2 += " AND SD2.D2_EMISSAO <= '" + DToS(mv_par02) + "' "
	cQuerySD2 += " AND SD2.D_E_L_E_T_ = ' ' "

	If mv_par07 == 1
		// Ordem de digitacao
		If lCusUnif
			cQuerySD2 += " ORDER BY SD2.D2_FILIAL, SD2.D2_COD, SD2.D2_EMISSAO, SD2.D2_NUMSEQ "
		Else
			cQuerySD2 += " ORDER BY SD2.D2_FILIAL, SD2.D2_COD, SD2.D2_LOCAL, SD2.D2_EMISSAO, SD2.D2_NUMSEQ "
		EndIf
	Else
		// Ordem de calculo
		If lCusUnif
			cQuerySD2 += " ORDER BY SD2.D2_FILIAL, SD2.D2_COD, SD2.D2_EMISSAO, SD2.D2_SEQCALC, SD2.D2_NUMSEQ "
		Else
			cQuerySD2 += " ORDER BY SD2.D2_FILIAL, SD2.D2_COD, SD2.D2_LOCAL, SD2.D2_EMISSAO, SD2.D2_SEQCALC, SD2.D2_NUMSEQ "
		EndIf
	EndIf
	lQuerySD2 := .T.
	cAliasSD2 := GetNextAlias()
	cQuerySD2 := ChangeQuery( cQuerySD2 )
	DbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuerySD2), cAliasSD2, .T., .F. )
#ELSE
	dbSelectArea(cAliasSD2)
	If mv_par07 == 1
		//��������������������������������������������������������������Ŀ
		//� Cria Indice condicional p/ Custo Unificado                   �
		//����������������������������������������������������������������
		If lCusUnif
			cIndice:="D2_FILIAL+D2_COD+DTOS(D2_EMISSAO)+D2_NUMSEQ"
		Else
			cIndice:="D2_FILIAL+D2_COD+D2_LOCAL+DTOS(D2_EMISSAO)+D2_NUMSEQ"
		EndIf
		cFiltro:=dbFilter()
		IndRegua("SD2",cTrbSD2,cIndice,,"D2_COD == '" + SB1->B1_COD + "'" + If(!Empty(cFiltro)," .AND. " + cFiltro,""),"Selecionando Registros...")
		nInd := RetIndex("SD2")
		dbSetIndex(cTrbSD2+OrdBagExt())
		SD2->(dbSetOrder(nInd+1))
	Else
		If lCusUnif
			cIndice:="D2_FILIAL+D2_COD+DTOS(D2_EMISSAO)+D2_SEQCALC+D2_NUMSEQ"
		Else
			cIndice:="D2_FILIAL+D2_COD+D2_LOCAL+DTOS(D2_EMISSAO)+D2_SEQCALC+D2_NUMSEQ"
		EndIf
		cFiltro:=dbFilter()
		IndRegua("SD2",cTRBSD2,cIndice,,"D2_COD == '" + SB1->B1_COD + "'" + If(!Empty(cFiltro)," .AND. " + cFiltro,""),"Selecionando Registros...")
		nInd := RetIndex("SD2")
		dbSetIndex(cTRBSD2+OrdBagExt())
		SD2->(dbSetOrder(nInd+1))
	EndIf
	dbSeek(cFilial+SB1->B1_COD+If(lCusUnif,"",mv_par03)+dtos(dCntData),.T.)
#ENDIF

dbSelectArea("SD3")
If mv_par07 ==1
	//��������������������������������������������������������������Ŀ
	//� Cria Indice condicional p/ Custo Unificado ou Aprop.Indireta �
	//����������������������������������������������������������������
	If lCusUnif .Or. lLocProc
		dbSelectArea("SD3")
		cIndice:="D3_FILIAL+D3_COD+DTOS(D3_EMISSAO)+D3_NUMSEQ"
		cFiltro:=dbFilter()
		IndRegua("SD3",cTrbSD3,cIndice,,"D3_COD == '" + SB1->B1_COD + "'" + If(!Empty(cFiltro)," .AND. " + cFiltro,""),"Selecionando Registros...")
		nInd := RetIndex("SD3")
		#IFNDEF TOP
			dbSetIndex(cTrbSD3+OrdBagExt())
		#ENDIF
		SD3->(dbSetOrder(nInd+1))
	Else
		SD3->(dbSetOrder(7))
	EndIf
Else
	If lCusUnif .Or. lLocProc
		cIndice:="D3_FILIAL+D3_COD+DTOS(D3_EMISSAO)+D3_SEQCALC+D3_NUMSEQ"
	Else
		cIndice:="D3_FILIAL+D3_COD+D3_LOCAL+DTOS(D3_EMISSAO)+D3_SEQCALC+D3_NUMSEQ"
	EndIf
	cFiltro:=dbFilter()
	IndRegua("SD3",cTRBSD3,cIndice,,"D3_COD == '" + SB1->B1_COD + "'" + If(!Empty(cFiltro)," .AND. " + cFiltro,""),"Selecionando Registros...")
	nInd := RetIndex("SD3")
	#IFNDEF  TOP
		dbSetIndex(cTRBSD3+OrdBagExt())
	#ENDIF
	SD3->(dbSetOrder(nInd+1))
EndIf
dbSeek(cFilial+SB1->B1_COD+If(lCusUnif.Or.lLocProc,"",mv_par03)+dtos(dCntData),.T.)

While .T.
	cSeqIni := ""
	cAlias  := ""
	IncProc()

	dbSelectArea("SD1")
	Do While !Eof() .AND. D1_FILIAL == cFilial .AND. D1_DTDIGIT == dCntData .AND. D1_COD == SB1->B1_COD .AND. If(lCusUnif,.T.,D1_local == mv_par03)
		If D1_ORIGLAN $ "LF"
			dbSkip()
			Loop
		EndIf
		//����������������������������������������������������������������������������Ŀ
		//� Nao imprimir o produto MANUTENCAO (MV_PRODMNT) qdo integrado com MNT.      �
		//������������������������������������������������������������������������������
		If lProIsMNT
			If FindFunction("NGProdMNT")
				aProdsMNT := aClone(NGProdMNT("M"))
				If aScan(aProdsMNT, {|x| AllTrim(x) == AllTrim(SD1->D1_COD) }) > 0
					dbSkip()
					Loop
				EndIf
			ElseIf AllTrim(SD1->D1_COD) == AllTrim(cProdMNT)
				dbSkip()
				Loop
			EndIf
		EndIf
		//��������������������������������������������������������������Ŀ
		//� Despreza Notas Fiscais com Remitos                           �
		//����������������������������������������������������������������
		If cPaisloc<>"BRA" .AND. !Empty(D1_REMITO)
			dbSkip()
			Loop
		EndIf
		SF4->(dbSeek(cFilial+SD1->D1_TES))
		If SF4->F4_ESTOQUE # "S"
			dbSkip()
			Loop
		EndIf
		cSeqIni  := If(mv_par07==1,D1_NUMSEQ,D1_SEQCALC+D1_NUMSEQ)
		cAlias   := Alias()
		aAdd(aDados,{cAlias,dCntData,cSeqIni,Recno(),.F.,""})
		dbSkip()
		Loop
	EndDo
	
	dbSelectArea("SD3")
	Do While !Eof() .AND. D3_FILIAL == cFilial .AND. D3_EMISSAO == dCntData .AND. D3_COD == SB1->B1_COD .AND. If(lCusUnif.Or.lLocProc,.T.,D3_local == mv_par03)
		If !D3Valido()
			dbSkip()
			Loop
		EndIf
		//����������������������������������������������������������������������������Ŀ
		//� Nao imprimir os produtos que estao no armazem de transito                  �
		//������������������������������������������������������������������������������
		If cPaisLoc <> "BRA" .And. !lTranSB2 .And. AllTrim(SD3->D3_LOCAL) == AllTrim(cDepTrf)
			dbSkip()
			Loop
		EndIf	
		//����������������������������������������������������������������������������Ŀ
		//� Nao imprimir o produto MANUTENCAO (MV_PRODMNT) qdo integrado com MNT.      �
		//������������������������������������������������������������������������������
		If lProIsMNT
			If FindFunction("NGProdMNT")
				aProdsMNT := aClone(NGProdMNT("M"))
				If aScan(aProdsMNT, {|x| AllTrim(x) == AllTrim(SD3->D3_COD) }) > 0
					dbSkip()
					Loop
				EndIf
			ElseIf AllTrim(SD3->D3_COD) == AllTrim(cProdMNT)
				dbSkip()
				Loop
			EndIf
		EndIf
		//����������������������������������������������������������������Ŀ
		//� Quando movimento ref apropr. indireta, so considera os         �
		//� movimentos com destino ao almoxarifado de apropriacao indireta.�
		//������������������������������������������������������������������
		lInverteMov:=.F.
		If D3_local <> mv_par03 .Or. lCusUnif
			If !(Substr(D3_CF,3,1) == "3")
				If !lCusUnif
					dbSkip()
					Loop
				EndIf
			Else
				lInverteMov:=.T.
			EndIf
		EndIf
		//����������������������������������������������������������������Ŀ
		//� Caso seja uma transferencia de localizacao verifica se lista   �
		//� o movimento ou nao                                             �
		//������������������������������������������������������������������
		If mv_par08 == 2 .AND. Substr(D3_CF,3,1) == "4"
			cNumSeqTr := SD3->D3_COD+SD3->D3_NUMSEQ+SD3->D3_LOCAL
			nRegTr    := Recno()
			dbSkip()
			If SD3->D3_COD+SD3->D3_NUMSEQ+SD3->D3_local == cNumSeqTr
				dbSkip()
				Loop		
			Else
				dbGoto(nRegTr)
			EndIf
		EndIf
		cSeqIni  := If(mv_par07==1,D3_NUMSEQ,D3_SEQCALC+D3_NUMSEQ)
		cAlias   := Alias()
		aAdd(aDados,{cAlias,dCntData,cSeqIni,Recno(),lInverteMov,If(D3_CF == "RE5","02","")})
		dbSkip()
	EndDo
	
	dbSelectArea(cAliasSD2)
	Do While !Eof() .AND. (cAliasSD2)->D2_FILIAL == xFilial("SD2") .AND. (cAliasSD2)->D2_EMISSAO == IIf(lQuerySD2, DToS(dCntData),dCntData) .AND. (cAliasSD2)->D2_COD == SB1->B1_COD .AND. If(lCusUnif,.T.,(cAliasSD2)->D2_local == mv_par03)
		If (cAliasSD2)->D2_ORIGLAN $ "LF" 
			dbSkip()
			Loop
		EndIf
		//����������������������������������������������������������������������������Ŀ
		//� Nao imprimir o produto MANUTENCAO (MV_PRODMNT) qdo integrado com MNT.      �
		//������������������������������������������������������������������������������
		If lProIsMNT
			If FindFunction("NGProdMNT")
				aProdsMNT := aClone(NGProdMNT("M"))
				If aScan(aProdsMNT, {|x| AllTrim(x) == AllTrim((cAliasSD2)->D2_COD) }) > 0
					dbSkip()
					Loop
				EndIf
			ElseIf AllTrim((cAliasSD2)->D2_COD) == AllTrim(cProdMNT)
				dbSkip()
				Loop
			EndIf
		EndIf
		If nModulo = 12
			SF2->(dbSetOrder(1))
			If SF2->(dbSeek(xFilial("SF2") + (cAliasSD2)->D2_DOC  + (cAliasSD2)->D2_SERIE + (cAliasSD2)->D2_CLIENTE + (cAliasSD2)->D2_LOJA ))
				If !Empty(SF2->F2_NFCUPOM) .AND. Alltrim(Upper(SF2->F2_ESPECIE)) == Alltrim(Upper(MVNOTAFIS))
					(cAliasSD2)->(dbSkip())
					Loop
				EndIf
			EndIf
		EndIf

		//��������������������������������������������������������������Ŀ
		//� Despreza Notas Fiscais com Remitos                           �
		//����������������������������������������������������������������
		If cPaisLoc<> "BRA" .AND. !Empty((cAliasSD2)->D2_REMITO)
			If !((cAliasSD2)->D2_TPDCENV $ '1A')
				(cAliasSD2)->(dbSkip())
				Loop
			EndIf
		EndIf
        
        SF4->(dbSeek(cFilial+(cAliasSD2)->D2_TES))
		If SF4->F4_ESTOQUE # "S"
			dbSkip()
			Loop
		EndIf
		cSeqIni  := If(mv_par07==1,(cAliasSD2)->D2_NUMSEQ,(cAliasSD2)->D2_SEQCALC+(cAliasSD2)->D2_NUMSEQ)
		cAlias	 := "SD2"
		#IFNDEF TOP
			aAdd(aDados,{cAlias,dCntData,cSeqIni,Recno(),.F.,""})
		#ELSE
			aAdd(aDados,{cAlias,dCntData,cSeqIni,(cAliasSD2)->RECSD2,.F.,""})
		#ENDIF
		dbSkip()
	EndDo
	
	//��������������������������������������������������������������Ŀ
	//� Caso seja fim de arquivo no SD1, SD2 e SD3 nao continua o    �
	//� processamento.                                               �
	//����������������������������������������������������������������
	If SD1->(Eof()) .AND. (cAliasSD2)->(Eof()) .AND. SD3->(Eof())
		Exit
	Endif  

	If Empty(cAlias)
		dCntData++
	EndIf	
	cCondicao:=dCntData>mv_par02
	If mv_par07==2 .AND. !lCusUnif
		cCondicao:=cCondicao .OR. (	SD1->D1_COD + SD1->D1_local <> SB1->B1_COD + mv_par03 .AND. ;
									(cAliasSD2)->D2_COD + (cAliasSD2)->D2_local <> SB1->B1_COD + mv_par03 .AND. ;
									SD3->D3_COD <> SB1->B1_COD )
	Endif
	If cCondicao
		Exit
	EndIf

EndDo

//�����������������������������������������������������������������Ŀ
//� Ordena os registros a serem processados conforme a configuracao |
//� do parametro mv_par07 (Digitacao ou Calculo).					|
//�������������������������������������������������������������������
If Len(aDados) > 1
	//-- Passado o elemento 6 no array devido a problemas com o aSort
	ASORT(aDados,,, { |x, y| DTOS(x[2])+x[3]+x[6] < DTOS(y[2])+y[3]+y[6] })
EndIf	

//�����������������������������������������������������������������Ŀ
//� Processa os registros do Array aDados							|
//�������������������������������������������������������������������
For i := 1 to Len(aDados)
	If aDados[i,1] == "SD1"
		dbSelectArea("SD1")
		MsGoto(aDados[i,4])
		If cPaisLoc == "BRA"
			//������������������������������������������������Ŀ
			//� Verifica se o TES atualiza estoque             �
			//��������������������������������������������������
			dbSelectArea("SF4")
			dbSeek(cFilial+SD1->D1_TES)
			dbSelectArea("SD1")
			//��������������������������������������������������������������Ŀ
			//� Executa ponto de entrada para verificar se considera TES que �
			//� NAO ATUALIZA saldos em estoque.                              �
			//����������������������������������������������������������������
			If lIxbConTes .AND. SF4->F4_ESTOQUE <> "S"
				lTesNEst := ExecBlock("MTAAVLTES",.F.,.F.)
				lTesNEst := If(ValType(lTesNEst) # "L",.F.,lTesNEst)
			EndIf
			If (SF4->F4_ESTOQUE <> "S" .AND. !lTesNEst)
				Loop
			EndIf
			If D1_TES <= "500"
				aSalAtu[1] += D1_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//				aSalAtu[mv_par05+1] += IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
				aSalAtu[7] += D1_QTSEGUM
				nTotEnt    += D1_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//				nTotvEnt   += IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
			Else
				aSalAtu[1] -= D1_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//				aSalAtu[mv_par05+1] -= IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
				aSalAtu[7] -= D1_QTSEGUM
				nTotSda    += D1_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//				nTotvSda   += IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
			EndIf
			
			//������������������������������������������������Ŀ
			//� Calcula o Custo Medio do Produto               �
			//��������������������������������������������������
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//			nCusmed := CalcCMed(aSalAtu)
			nCusmed := 0
			cIdent := If(Empty(D1_OP),D1_FORNECE, D1_OP)
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
// 			AddArray({SD1->D1_DTDIGIT,SUBS(SD1->D1_TES,1,3),SD1->D1_CF,SD1->D1_DOC," "," ",cIdent,TRANSF(SD1->D1_QUANT,cPictQT),TRANSF((IIF(mv_par05=1,SD1->D1_CUSTO,&("SD1->D1_CUSTO"+Str(mv_par05,1,0)))/SD1->D1_QUANT),PesqPict("SB2","B2_CM1")),TRANSF(IIF(mv_par05=1,SD1->D1_CUSTO,&("SD1->D1_CUSTO"+Str(mv_par05,1,0))),PesqPict("SD1","D1_CUSTO")),SD1->D1_LOTECTL,SD1->D1_NUMLOTE },aDados[i,1])
 			AddArray({SD1->D1_DTDIGIT,SUBS(SD1->D1_TES,1,3),SD1->D1_CF,SD1->D1_DOC," "," ",cIdent,TRANSF(SD1->D1_QUANT,cPictQT),TRANSF(0,PesqPict("SB2","B2_CM1")),TRANSF(0,PesqPict("SD1","D1_CUSTO")),SD1->D1_LOTECTL,SD1->D1_NUMLOTE },aDados[i,1])
			//������������������������������������������������Ŀ
			//� Verifica se Lista Localizacao                  �
			//��������������������������������������������������
			If mv_par06 == 1
				dbSelectArea("SDB")
				dbSeek(cFilial+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_NUMSEQ)
				While !Eof() .AND. DB_FILIAL == cFilial .AND. DB_PRODUTO == SB1->B1_COD .AND. If(lCusUnif,.T.,DB_local == mv_par03) .AND. DB_NUMSEQ == SD1->D1_NUMSEQ
					If SDB->DB_ESTORNO == "S"
						dbSkip()
						Loop
					EndIf   
					AddArray({" "," "," "," ",SDB->DB_LOCALIZ,SDB->DB_NUMSERI," ",TRANSF(SDB->DB_QUANT,cPictQT)," "," ",SDB->DB_LOTECTL,SDB->DB_NUMLOTE },aDados[i,1])
					SDB->(DbSkip())
				EndDo
			EndIf
			//������������������������������������������������Ŀ
			//� Verifica se Lista Saldo item a item            �
			//��������������������������������������������������						
			If mv_par04 == 1
				AddArray({"Saldo"," "," "," "," "," "," ",Transf(aSalAtu[1],cPictQT),Transf(nCusMed,PesqPict("SB2","B2_CM1")),Transf(aSalAtu[mv_par05+1],PesqPict("SB9","B9_VINI1"))," ", " " },aDados[i,1])
			EndIf
			aAdd(aGraph,{MC030Data("SD1"),aSalAtu[1],nCusMed,aSalAtu[mv_par05+1]} )
		Else
			//������������������������������������������������Ŀ
			//� Verifica se o TES atualiza estoque             �
			//��������������������������������������������������
			dbSelectArea("SF4")
			dbSeek(cFilial+SD1->D1_TES)
			dbSelectArea("SD1")
			//��������������������������������������������������������������Ŀ
			//� Executa ponto de entrada para verificar se considera TES que �
			//� NAO ATUALIZA saldos em estoque.                              �
			//����������������������������������������������������������������
			If lIxbConTes .AND. SF4->F4_ESTOQUE <> "S"
				lTesNEst := ExecBlock("MTAAVLTES",.F.,.F.)
				lTesNEst := If(ValType(lTesNEst) # "L",.F.,lTesNEst)
			EndIf
			If (SF4->F4_ESTOQUE <> "S" .AND. !lTesNEst)
				Loop
			EndIf
			
			SF1->(DbSetOrder(1))
			SF1->(DbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
			If cPaisLoc != "BRA" .AND. AllTrim(D1_ESPECIE) == "RCN" .AND. !Empty(SF1->F1_HAWB) 
				Loop
			EndIf
				
			If D1_TIPO_NF == "5" 		//Invoice FOB 
				aSaldoExp := MTC030NFExp(SD1->D1_COD)
				aSalAtu[1] += aSaldoExp[1]
				aSalAtu[mv_par05+1] += aSaldoExp[2]
				aSalAtu[7] += aSaldoExp[3]
				nTotEnt    += aSaldoExp[1]
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//				nTotvEnt   += IIF(mv_par05=1,aSaldoExp[2],&("D1_CUSTO"+Str(mv_par05,1,0)))						
			Else			
				If D1_TES <= "500"
					aSalAtu[1] += D1_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//					aSalAtu[mv_par05+1] += IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
					aSalAtu[7] += D1_QTSEGUM
					nTotEnt    += D1_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//					nTotvEnt   += IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
				Else
					aSalAtu[1] -= D1_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//					aSalAtu[mv_par05+1] -= IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
					aSalAtu[7] -= D1_QTSEGUM
					nTotSda    += D1_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//					nTotvSda   += IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
				EndIf
			EndIf
			
			//������������������������������������������������Ŀ
			//� Calcula o Custo Medio do Produto               �
			//��������������������������������������������������
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//			nCusmed := CalcCMed(aSalAtu)
			nCusmed := 0
			cIdent := If(Empty(D1_OP),D1_FORNECE, D1_OP)
			
			cDocumento:=SD1->D1_DOC            				
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//			AddArray({SD1->D1_DTDIGIT,SD1->D1_TES,If(IsRemito(1,'SD1->D1_TIPODOC'),Substr(GetDescRem(),1,3)," FAC "),cDocumento," "," ",cIdent,TRANSF(SD1->D1_QUANT,cPictQT),TRANSF((IIF(mv_par05=1,SD1->D1_CUSTO,&("SD1->D1_CUSTO"+Str(mv_par05,1,0)))/SD1->D1_QUANT),PesqPict("SB2","B2_CM1")),TRANSF(IIF(mv_par05=1,SD1->D1_CUSTO,&("SD1->D1_CUSTO"+Str(mv_par05,1,0))),PesqPict("SD1","D1_CUSTO")),SD1->D1_LOTECTL,SD1->D1_NUMLOTE },aDados[i,1])
			AddArray({SD1->D1_DTDIGIT,SD1->D1_TES,If(IsRemito(1,'SD1->D1_TIPODOC'),Substr(GetDescRem(),1,3)," FAC "),cDocumento," "," ",cIdent,TRANSF(SD1->D1_QUANT,cPictQT),TRANSF(0,PesqPict("SB2","B2_CM1")),TRANSF(0,PesqPict("SD1","D1_CUSTO")),SD1->D1_LOTECTL,SD1->D1_NUMLOTE },aDados[i,1])
			//������������������������������������������������Ŀ
			//� Verifica se Lista Localizacao                  �
			//��������������������������������������������������
			If mv_par06 == 1
				dbSelectArea("SDB")
				dbSeek(cFilial+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_NUMSEQ)
				While !Eof() .AND. DB_FILIAL == cFilial .AND. DB_PRODUTO == SB1->B1_COD .AND. If(lCusUnif,.T.,DB_local == mv_par03) .AND. DB_NUMSEQ == SD1->D1_NUMSEQ
					If SDB->DB_ESTORNO == "S"
						dbSkip()
						Loop
					EndIf   				
					AddArray({" "," "," "," ",SDB->DB_LOCALIZ,SDB->DB_NUMSERI," ",TRANSF(SDB->DB_QUANT,cPictQT)," "," " ,SDB->DB_LOTECTL,SDB->DB_NUMLOTE},aDados[i,1])
					SDB->(dbSkip())
				EndDo
			EndIf
			//������������������������������������������������Ŀ
			//� Verifica se Lista Saldo item a item            �
			//��������������������������������������������������						
			If mv_par04 == 1
				AddArray({"Saldo"," "," "," "," "," "," ",Transf(aSalAtu[1],cPictQT),Transf(nCusMed,PesqPict("SB2","B2_CM1")),Transf(aSalAtu[mv_par05+1],PesqPict("SB9","B9_VINI1"))," "," " },aDados[i,1])
			EndIf
			aAdd(aGraph,{MC030Data("SD1"),aSalAtu[1],nCusMed,aSalAtu[mv_par05+1]} )
		EndIf
	EndIf
	If aDados[i,1] == "SD3"
		dbSelectArea("SD3")
		MsGoto(aDados[i,4])
		If aDados[i,5]  //lInverteMov
			If D3_TM > "500"
				aSalAtu[1] += D3_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//				aSalAtu[mv_par05+1] += &("D3_CUSTO"+Str(mv_par05,1,0))
				aSalAtu[7] += D3_QTSEGUM
				nTotEnt    += D3_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//				nTotvEnt   += &("D3_CUSTO"+Str(mv_par05,1,0))
			Else
				aSalAtu[1] -= D3_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//				aSalAtu[mv_par05+1] -= &("D3_CUSTO"+Str(mv_par05,1,0))
				aSalAtu[7] -= D3_QTSEGUM
				nTotSda    += D3_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//				nTotvSda   += &("D3_CUSTO"+Str(mv_par05,1,0))
			EndIf
		Else	
			If D3_TM <= "500"
				aSalAtu[1] += D3_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//				aSalAtu[mv_par05+1] += &("D3_CUSTO"+Str(mv_par05,1,0))
				aSalAtu[7] += D3_QTSEGUM
				nTotEnt    += D3_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//				nTotvEnt   += &("D3_CUSTO"+Str(mv_par05,1,0))
			Else
				aSalAtu[1] -= D3_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//				aSalAtu[mv_par05+1] -= &("D3_CUSTO"+Str(mv_par05,1,0))
				aSalAtu[7] -= D3_QTSEGUM
				nTotSda    += D3_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//				nTotvSda   += &("D3_CUSTO"+Str(mv_par05,1,0))
			EndIf
		EndIf
		cIdent := If(Empty(D3_OP),D3_CC, D3_OP)
		If lMc030Idmv
			cIdent := ExecBlock("MC030IDMV",.F.,.F.,{D3_OP,D3_CC})
		EndIf	
		//������������������������������������������������Ŀ
		//� Calcula o Custo Medio do Produto               �
		//��������������������������������������������������
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//		nCusmed := CalcCMed(aSalAtu)
		nCusmed := 0
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//		AddArray({SD3->D3_EMISSAO,SUBS(SD3->D3_TM,1,3),SD3->D3_CF+If(aDados[i,5],"*",""),SD3->D3_DOC,SD3->D3_LOCALIZ,SD3->D3_NUMSERI,cIdent,TRANSF(SD3->D3_QUANT,cPictQT),TRANSF((&("SD3->D3_CUSTO"+Str(mv_par05,1,0))/SD3->D3_QUANT),PesqPict("SB2","B2_CM1")),TRANSF(&("SD3->D3_CUSTO"+Str(mv_par05,1,0)),PesqPict("SD1","D1_CUSTO")),SD3->D3_LOTECTL,SD3->D3_NUMLOTE},aDados[i,1])
		AddArray({SD3->D3_EMISSAO,SUBS(SD3->D3_TM,1,3),SD3->D3_CF+If(aDados[i,5],"*",""),SD3->D3_DOC,SD3->D3_LOCALIZ,SD3->D3_NUMSERI,cIdent,TRANSF(SD3->D3_QUANT,cPictQT),TRANSF(0,PesqPict("SB2","B2_CM1")),TRANSF(0,PesqPict("SD1","D1_CUSTO")),SD3->D3_LOTECTL,SD3->D3_NUMLOTE},aDados[i,1])
		//������������������������������������������������Ŀ
		//� Verifica se Lista Localizacao                  �
		//��������������������������������������������������
	   	If mv_par06 == 1
			dbSelectArea("SDB")
			dbSeek(cFilial+SD3->D3_COD+SD3->D3_LOCAL+SD3->D3_NUMSEQ)
			While !Eof() .AND. DB_FILIAL == cFilial .AND. DB_PRODUTO == SB1->B1_COD .AND. If(lCusUnif,.T.,DB_local == mv_par03)	.AND. DB_NUMSEQ == SD3->D3_NUMSEQ
				If SDB->DB_ESTORNO == "S"
					dbSkip()
					Loop
				EndIf
				AddArray({" "," "," "," ",SDB->DB_LOCALIZ,SDB->DB_NUMSERI," ",TRANSF(SDB->DB_QUANT,cPictQT)," "," ",SDB->DB_LOTECTL,SDB->DB_NUMLOTE },aDados[i,1])
				SDB->(dbSkip())
			EndDo
		EndIf

		//������������������������������������������������Ŀ
		//� Verifica se Lista Saldo item a item            �
		//��������������������������������������������������					
		If mv_par04 == 1
			AddArray({"Saldo"," "," "," "," "," "," ",Transf(aSalAtu[1],cPictQT),Transf(nCusMed,PesqPict("SB2","B2_CM1")),Transf(aSalAtu[mv_par05+1],PesqPict("SB9","B9_VINI1"))," "," " },aDados[i,1])
		EndIf
	    aAdd(aGraph,{MC030Data("SD3"),aSalAtu[1],nCusMed,aSalAtu[mv_par05+1]} )
	EndIf
	If aDados[i,1] == "SD2"
		dbSelectArea("SD2")
		MsGoto(aDados[i,4])
		If cPaisLoc == "BRA"
			//������������������������������������������������Ŀ
			//� Verifica se o TES atualiza estoque             �
			//��������������������������������������������������
			dbSelectArea("SF4")
			dbSeek(cFilial+SD2->D2_TES)
			dbSelectArea("SD2")
			//��������������������������������������������������������������Ŀ
			//� Executa ponto de entrada para verificar se considera TES que �
			//� NAO ATUALIZA saldos em estoque.                              �
			//����������������������������������������������������������������
			If lIxbConTes .AND. SF4->F4_ESTOQUE <> "S"
				lTesNEst := ExecBlock("MTAAVLTES",.F.,.F.)
				lTesNEst := If(ValType(lTesNEst) # "L",.F.,lTesNEst)
			EndIf
			If (SF4->F4_ESTOQUE <> "S" .AND. !lTesNEst)
				Loop
			EndIf
			
			If D2_TES <= "500"
				aSalAtu[1] += D2_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//				aSalAtu[mv_par05+1] += &("D2_CUSTO"+Str(mv_par05,1,0))
				aSalAtu[7] += D2_QTSEGUM
				nTotEnt    += D2_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//				nTotvEnt   += &("D2_CUSTO"+Str(mv_par05,1,0))
			Else
				aSalAtu[1] -= D2_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//				aSalAtu[mv_par05+1] -= &("D2_CUSTO"+Str(mv_par05,1,0))
				aSalAtu[7] -= D2_QTSEGUM
				nTotSda    += D2_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//				nTotvSda   += &("D2_CUSTO"+Str(mv_par05,1,0))
			EndIf
			
			cIdent := If(Empty(D2_OP),D2_CLIENTE, D2_OP)
			
			//������������������������������������������������Ŀ
			//� Calcula o Custo Medio do Produto               �
			//��������������������������������������������������
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//			nCusmed := CalcCMed(aSalAtu)
			nCusmed := 0
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
// 			AddArray({SD2->D2_EMISSAO,SUBS(SD2->D2_TES,1,3),SD2->D2_CF,SD2->D2_DOC," "," ",cIdent,TRANSF(SD2->D2_QUANT,cPictQT),TRANSF((&("SD2->D2_CUSTO"+Str(mv_par05,1,0))/SD2->D2_QUANT),PesqPict("SB2","B2_CM1")),TRANSF(&("SD2->D2_CUSTO"+Str(mv_par05,1,0)),PesqPict("SD1","D1_CUSTO")),SD2->D2_LOTECTL,SD2->D2_NUMLOTE },aDados[i,1])
 			AddArray({SD2->D2_EMISSAO,SUBS(SD2->D2_TES,1,3),SD2->D2_CF,SD2->D2_DOC," "," ",cIdent,TRANSF(SD2->D2_QUANT,cPictQT),TRANSF(0,PesqPict("SB2","B2_CM1")),TRANSF(0,PesqPict("SD1","D1_CUSTO")),SD2->D2_LOTECTL,SD2->D2_NUMLOTE },aDados[i,1])
			//������������������������������������������������Ŀ
			//� Verifica se Lista Localizacao                  �
			//��������������������������������������������������
			If mv_par06 == 1
				dbSelectArea("SDB")
				dbSeek(cFilial+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_NUMSEQ)
				While !Eof() .AND. DB_FILIAL == cFilial .AND. DB_PRODUTO == SB1->B1_COD .AND. If(lCusUnif,.T.,DB_local == mv_par03)	.AND. DB_NUMSEQ == SD2->D2_NUMSEQ
					If SDB->DB_ESTORNO == "S"
						dbSkip()
						Loop
					EndIf   				
					AddArray({" "," "," "," ",SDB->DB_LOCALIZ,SDB->DB_NUMSERI," ",TRANSF(SDB->DB_QUANT,cPictQT)," "," ",SDB->DB_LOTECTL,SDB->DB_NUMLOTE },aDados[i,1])
					SDB->(dbSkip())
				EndDo
			EndIf
			
			//������������������������������������������������Ŀ
			//� Verifica se Lista Saldo item a item            �
			//��������������������������������������������������						
			If mv_par04 == 1
				AddArray({"Saldo"," "," "," "," "," "," ",Transf(aSalAtu[1],cPictQT),Transf(nCusMed,PesqPict("SB2","B2_CM1")),Transf(aSalAtu[mv_par05+1],PesqPict("SB9","B9_VINI1"))," ", " " },aDados[i,1])
			EndIf
			aAdd(aGraph,{MC030Data("SD2"),aSalAtu[1],nCusMed,aSalAtu[mv_par05+1]} )
		Else
			//������������������������������������������������Ŀ
			//� Verifica se o TES atualiza estoque             �
			//��������������������������������������������������
			dbSelectArea("SF4")
			dbSeek(cFilial+SD2->D2_TES)
			dbSelectArea("SD2")
			//��������������������������������������������������������������Ŀ
			//� Executa ponto de entrada para verificar se considera TES que �
			//� NAO ATUALIZA saldos em estoque.                              �
			//����������������������������������������������������������������
			If lIxbConTes .AND. SF4->F4_ESTOQUE <> "S"
				lTesNEst := ExecBlock("MTAAVLTES",.F.,.F.)
				lTesNEst := If(ValType(lTesNEst) # "L",.F.,lTesNEst)
			EndIf
			If (SF4->F4_ESTOQUE <> "S" .AND. !lTesNEst)
				Loop
			EndIf
			
			If D2_TES <= "500"
				aSalAtu[1] += D2_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//				aSalAtu[mv_par05+1] += &("D2_CUSTO"+Str(mv_par05,1,0))
				aSalAtu[7] += D2_QTSEGUM
				nTotEnt    += D2_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//				nTotvEnt   += &("D2_CUSTO"+Str(mv_par05,1,0))
			Else
				aSalAtu[1] -= D2_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//				aSalAtu[mv_par05+1] -= &("D2_CUSTO"+Str(mv_par05,1,0))
				aSalAtu[7] -= D2_QTSEGUM
				nTotSda    += D2_QUANT
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//				nTotvSda   += &("D2_CUSTO"+Str(mv_par05,1,0))
			EndIf
			
			cIdent := If(Empty(D2_OP),D2_CLIENTE, D2_OP)
			
			//������������������������������������������������Ŀ
			//� Calcula o Custo Medio do Produto               �
			//��������������������������������������������������
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//			nCusmed := CalcCMed(aSalAtu)
			nCusmed := 0
			//�������������������������������������������������������Ŀ
			//� Verifica o pais para verificar o tamanho do documento �
			//���������������������������������������������������������
			cDocumento := SD2->D2_DOC				
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//			AddArray({ SD2->D2_EMISSAO,SD2->D2_TES,If(IsRemito(1,'SD2->D2_TIPODOC'),Substr(GetDescRem(),1,3)," FAC "),cDocumento," "," ",cIdent,TRANSF(SD2->D2_QUANT,cPictQT),TRANSF((&("SD2->D2_CUSTO"+Str(mv_par05,1,0))/SD2->D2_QUANT),PesqPict("SB2","B2_CM1")),TRANSF(&("SD2->D2_CUSTO"+Str(mv_par05,1,0)),PesqPict("SD1","D1_CUSTO")),SD2->D2_LOTECTL,SD2->D2_NUMLOTE },aDados[i,1])
			AddArray({ SD2->D2_EMISSAO,SD2->D2_TES,If(IsRemito(1,'SD2->D2_TIPODOC'),Substr(GetDescRem(),1,3)," FAC "),cDocumento," "," ",cIdent,TRANSF(SD2->D2_QUANT,cPictQT),TRANSF(0,PesqPict("SB2","B2_CM1")),TRANSF(0,PesqPict("SD1","D1_CUSTO")),SD2->D2_LOTECTL,SD2->D2_NUMLOTE },aDados[i,1])
			//������������������������������������������������Ŀ
			//� Verifica se Lista Localizacao                  �
			//��������������������������������������������������
			If mv_par06 == 1
				dbSelectArea("SDB")
				dbSeek(cFilial+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_NUMSEQ)
				While !Eof() .AND. DB_FILIAL == cFilial .AND. DB_PRODUTO == SB1->B1_COD .AND. If(lCusUnif,.T.,DB_local == mv_par03)	.AND. DB_NUMSEQ == SD2->D2_NUMSEQ
					If SDB->DB_ESTORNO == "S"
						dbSkip()
						Loop
					EndIf   				
					AddArray({" "," "," "," ",SDB->DB_LOCALIZ,SDB->DB_NUMSERI," ",TRANSF(SDB->DB_QUANT,cPictQT)," "," ",SDB->DB_LOTECTL,SDB->DB_NUMLOTE },aDados[i,1])
					SDB->(dbSkip())
				EndDo
			EndIf
			
			//������������������������������������������������Ŀ
			//� Verifica se Lista Saldo item a item            �
			//��������������������������������������������������						
			If mv_par04 == 1
				AddArray({"Saldo"," "," "," "," "," "," ",Transf(aSalAtu[1],cPictQT),Transf(nCusMed,PesqPict("SB2","B2_CM1")),Transf(aSalAtu[mv_par05+1],PesqPict("SB9","B9_VINI1"))," "," " },aDados[i,1])
			EndIf
			aAdd(aGraph,{MC030Data("SD2"),aSalAtu[1],nCusMed,aSalAtu[mv_par05+1]} )
		EndIf
	EndIf
Next i

If Len(aTrbTmp)>0
	AADD(aTrbP,aTrbTmp)
	aTrbTmp:={}
EndIf

//������������������������������������������������Ŀ
//� Limpando os filtros da IndRegua()              �
//��������������������������������������������������
dbSelectArea("SD1")
dbClearFilter()
#IFDEF TOP
	(cAliasSD2)->( DbCloseArea() )
#ELSE
	dbSelectArea("SD2")
	dbClearFilter()
#ENDIF
dbSelectArea("SD3")
dbClearFilter()

Return aSaldoIni

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CalcCMed � Autor � Paulo Boschetti       � Data � 22.03.93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula o Custo Medio do Produto                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpN1 := CalcCMed(ExpA1)   		                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 = Array do saldo atual                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpN1 = custo medio calculado                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CalcCMed(aSalAtu)

local nCusmed := 0

If QtdComp(aSalAtu[1]) == QtdComp(0)
	nCusMed := 0
Else
	nCusMed := aSalAtu[mv_par05+1]/aSalAtu[1]
EndIf

Return nCusmed

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CW030Brow � Autor � Cristina M. Ogura     � Data � 07.02.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta o Browse para o Windows                               ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MW030Brows(ExpA1) 		  		                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 = Array do saldo inicial 	                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATC030                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MW030Brows(aSalIni)

local cCadastro := OemtoAnsi("Consulta ao Kardex em "+SuperGetMV('MV_MOEDA'+Str(mv_par05,1,0)))
local oDlg, oQual, nX

local cSavAlias := Alias()
local aStru     := {}
local aAreaAnt  := {}
local cArqTmp   := ''
local aSize     := MsAdvSize()
local nTop      := 23
local nLeft     := 5
local nBottom   := aSize[6]
local nRight    := aSize[5]
local nY        := 0
local lDescArm  := .F.
local lRastro	:= Rastro(SB1->B1_COD)
local lRastroS	:= If(lRastro,Rastro(SB1->B1_COD,"S"),.F.)
local aFields	:= {}

local aRetCabec := {}
local na        := 0
local nLinaMais := 0
local nLinhaAtu := 21
local lMc030Prd :=.F.
local cTextSay  :=""

//��������������������������������������������������������������Ŀ
//� Verifica se existe ponto de entrada                          �
//����������������������������������������������������������������
local lMc030Grv:= ExistBlock("MC030GRV")
local lMc030PRJ:= ExistBlock("MC030PRJ")
local aRetPrj  := {}

Private aCols   := {}
Private aHeader := {}

//��������������������������������������Ŀ
//� Montagem do AHeader (Visualiza��o)   �
//����������������������������������������
aHeader := {}
aTam := TamSX3('D3_EMISSAO'); Aadd(aHeader, {'Data', 'D3_EMISSAO', PesqPict('SD3', 'D3_EMISSAO', aTam[1] ), aTam[1], aTam[2], , USADO, 'C', 'SD3', ''})
aTam := TamSX3('D3_TM'     ); Aadd(aHeader, {'TES', 'D3_TM'     , PesqPict('SD3', 'D3_TM'     , aTam[1] ), aTam[1], aTam[2], , USADO, 'C', 'SD3', ''})
aTam := TamSX3('D1_CF'     ); Aadd(aHeader, {'CFO', 'D1_CF'     , PesqPict('SD1', 'D1_CF'     , aTam[1] ), aTam[1], aTam[2], , USADO, 'C', 'SD1', ''})
aTam := TamSX3('D3_DOC'    ); Aadd(aHeader, {'Docmto.'+If(cPaisLoc=='MEX',Space(aTam[1]-Len('Docmto.')),''), 'D3_DOC'    , PesqPict('SD3', 'D3_DOC'    , aTam[1] ), aTam[1], aTam[2], , USADO, 'C', 'SD3', ''})
If mv_par06 == 1
	aTam := TamSX3('D3_LOCALIZ'); Aadd(aHeader, {'Localizacao', 'D3_LOCALIZ', PesqPict('SD3', 'D3_LOCALIZ', aTam[1] ), aTam[1], aTam[2], , USADO, 'C', 'SD3', ''})
	aTam := TamSX3('D3_NUMSERI'); Aadd(aHeader, {'Serie', 'D3_NUMSERI', PesqPict('SD3', 'D3_NUMSERI', aTam[1] ), aTam[1], aTam[2], , USADO, 'C', 'SD3', ''})
EndIf	
If lRastro
	aTam := TamSX3('D3_LOTECTL'); Aadd(aHeader, {'Lote', 'D3_LOTECTL', PesqPict('SD3', 'D3_LOTECTL', aTam[1] ), aTam[1], aTam[2], , USADO, 'C', 'SD3', ''})
EndIf
If lRastroS
	aTam := TamSX3('D3_NUMLOTE'); Aadd(aHeader, {'Sub-Lote', 'D3_NUMLOTE', PesqPict('SD3', 'D3_NUMLOTE', aTam[1] ), aTam[1], aTam[2], , USADO, 'C', 'SD3', ''})
EndIf

aTam := TamSX3('D3_IDENT'  ); Aadd(aHeader, {'Ident', 'D3_IDENT'  , PesqPict('SD3', 'D3_IDENT'  , aTam[1] ), aTam[1], aTam[2], , USADO, 'C', 'SD3', ''})
aTam := TamSX3('D3_QUANT'  ); Aadd(aHeader, {'Qtde.', 'D3_QUANT'  , ""                                      , aTam[1], aTam[2], , USADO, 'C', 'SD3', ''})
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//aTam := TamSX3('D3_CUSTO1' ); Aadd(aHeader, {'Custo Medio', 'D3_CUSTO1' , ""                                      , aTam[1], aTam[2], , USADO, 'C', 'SD3', ''})
//aTam := TamSX3('B9_VINI1'  ); Aadd(aHeader, {'Custo Total', 'D3_CUSTO1' , ""                                      , aTam[1], aTam[2], , USADO, 'C', 'SD3', ''})

//������������������������������������������������������������������������Ŀ
//� Cria arquivo temporario que recebe os dados do arquivo TXT ou do array �
//��������������������������������������������������������������������������
aAreaAnt:= GetArea()
Aadd(aStru,{ "EMISSAO","C",10,0 })
aTam := TamSX3("D3_TM")
Aadd(aStru,{ "TES",    "C",aTam[1],aTam[2] })
aTam := TamSX3("D1_CF")
Aadd(aStru,{ "CF",     "C",aTam[1]+1,aTam[2] })
aTam := TamSX3("D3_DOC")
Aadd(aStru,{ "DOC",    "C",aTam[1],aTam[2] })
If mv_par06 == 1
	aTam := TamSX3("D3_LOCALIZ")
	Aadd(aStru,{ "LOCALI","C",aTam[1],aTam[2] })
	aTam := TamSX3("D3_NUMSERI")
	Aadd(aStru,{ "NUMSER","C",aTam[1],aTam[2] })
EndIf	
If lRastro
	aTam := TamSX3("D3_LOTECTL")
	Aadd(aStru,{ "LOTECTL","C",aTam[1],aTam[2] })
EndIf
If lRastroS
	aTam := TamSX3("D3_NUMLOTE")
	Aadd(aStru,{ "NUMLOTE","C",aTam[1],aTam[2] })
EndIf
aTam := TamSX3("D3_CC")               
Aadd(aStru,{ "IDENT",  "C",aTam[1],aTam[2] })
Aadd(aStru,{ "QUANT",  "C",18,0 })
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//Aadd(aStru,{ "CMEDIO", "C",18,0 })
//Aadd(aStru,{ "CTOTAL", "C",18,0 })

//���������������������������������������������������������������������Ŀ
//� Ponto de entrada para alteracao da estrutura do arq. dbf temporario �
//�����������������������������������������������������������������������
If ExistBlock('MC030IDE')                          
	aRetIdent := ExecBlock('MC030IDE', .F., .F.,{aStru})
	If ValType(aRetIdent) == 'A'
		aStru := aRetIdent
	EndIf
EndIf

/* FB - RELEASE 12.1.23
cArqTmp := CriaTrab(aStru,.T.)					// Cria arq. dbf temporario
cArqInd := CriaTrab(Nil,.F.)
USE &cArqTmp ALIAS KDX NEW
IndRegua("KDX",cArqInd,"RECNO()",,,OemToAnsi("Selecionando Registros..."))
*/
//-------------------
//Criacao do objeto
//-------------------
oTempTable := FWTemporaryTable():New( "KDX" )

oTemptable:SetFields( aStru )
//------------------
//Criacao da tabela
//------------------
oTempTable:Create()


RestArea(aAreaAnt)
	
lDescArm := SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+mv_par03)) .AND. !Empty(SB2->B2_LOCALIZ)

//�����������������������������������������������������������Ŀ
//� Ponto de entrada para incluir informacoes adicionais      �
//| A linha comporta 150 caracteres                           |
//| Devera retornar um vetor com as linhas que devem aparecer:|
//| avetor[n]:=Linha que devera aparecer na tela              |
//�������������������������������������������������������������
If ExistBlock('MC030PRD')
	aRetCabec := ExecBlock('MC030PRD', .F., .F.)
	If Valtype(aRetCabec) == "A"
		For na:=1 To Len(aRetCabec)
			If Valtype(aRetCabec[na]) == "C"
				nLinAmais+=8
				lMc030Prd:=.T.
			EndIf
		Next na
	EndIf
EndIf

nTop   -=nLinAmais     
nBottom+=nLinAmais     

DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL From nTop,nLeft To nBottom,nRight
@ 005,005 SAY OemtoAnsi("Produto:") SIZE 25,07 OF oDlg PIXEL
If SuperGetMV("MV_VEICULO") == "S"
	@ 005,033 SAY AllTrim(SB1->B1_CODITE) +" - "+ SB1->B1_DESC SIZE 300,07 OF oDlg PIXEL
Else
	@ 005,033 SAY AllTrim(SB1->B1_COD) +" - "+ SB1->B1_DESC SIZE 300,07 OF oDlg PIXEL
EndIf                        
@ 013,005 SAY OemToAnsi("Almoxarifado: ") + mv_par03 + IIF(lDescArm," - "+SB2->B2_LOCALIZ,"") SIZE 90,07 OF oDlg PIXEL
@ 013,100 SAY OemtoAnsi("Tipo:") SIZE 25,07 OF oDlg PIXEL
@ 013,120 SAY SB1->B1_TIPO SIZE 15,07 OF oDlg PIXEL
@ 013,154 SAY OemtoAnsi("Unidade:") SIZE 20,07 OF oDlg PIXEL
@ 013,180 SAY SB1->B1_UM SIZE 15,07 OF oDlg PIXEL
@ 013,245 SAY OemtoAnsi("Grupo:") SIZE 22,07 OF oDlg PIXEL
@ 013,270 SAY SB1->B1_GRUPO SIZE 20,07 OF oDlg PIXEL
//�������������������������������������������������������Ŀ
//� Executa o Ponto de entrada para incluir informacoes   �
//���������������������������������������������������������
If lMc030Prd
	For na:=1 To Len(aRetCabec)
		If Valtype(aRetCabec[na]) == "C"
			cTextSay:= "{||'"+aRetcabec[na]+"'}"		
			TSay():New(nLinhaAtu,005,MontaBlock(cTextSay),oDlg,,,,,,.T.,CLR_BLACK,,,,,,,,)
			nLinhaAtu+=8
		EndIf
	Next na
EndIf
@ 021+nLinAmais,005 SAY OemtoAnsi("Saldos Iniciais:") SIZE 40,07 OF oDlg PIXEL
@ 021+nLinAmais,058 SAY OemtoAnsi("Quantidade") SIZE 40,07 OF oDlg PIXEL
@ 021+nLinAmais,096 SAY aSalIni[1] SIZE 50,07 OF oDlg PIXEL
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//@ 021+nLinAmais,154 SAY OemtoAnsi("Custo Medio") SIZE 40,07 OF oDlg PIXEL
//@ 021+nLinAmais,192 SAY aSalIni[2] SIZE 50,07 OF oDlg PIXEL
//@ 021+nLinAmais,245 SAY OemtoAnsi("Custo Total") SIZE 40,07 OF oDlg PIXEL
//@ 021+nLinAmais,283 SAY aSalIni[3] SIZE 95,07 OF oDlg PIXEL
@ 029+nLinAmais,005 SAY "Saldo Final" SIZE 40,07 OF oDlg PIXEL
@ 029+nLinAmais,058 SAY OemtoAnsi("Quantidade")+" : " SIZE 040,07 OF oDlg PIXEL
@ 029+nLinAmais,096 SAY TRANSF(aSalAtu[1],cPictTotQT) SIZE 050,07 OF oDlg PIXEL
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//@ 029+nLinAmais,154 SAY OemToAnsi("Custo Medio") + " : " SIZE 040,07 OF oDlg PIXEL
//@ 029+nLinAmais,192 SAY IIF(aSalAtu[1] <> 0,TRANSF(aSalAtu[mv_par05+1]/aSalAtu[1],PesqPict("SB2","B2_CM1")),TRANSF(0,PesqPict("SB2","B2_CM1"))) SIZE 050,07 OF oDlg PIXEL
//@ 029+nLinAmais,245 SAY OemToAnsi("Custo Total") + " : " SIZE 040,07 OF oDlg PIXEL
//@ 029+nLinAmais,283 SAY TRANSF(aSalAtu[mv_par05+1],PesqPict("SB9","B9_VINI1"))  SIZE 095,07 OF oDlg PIXEL
@ 037+nLinAmais,005 SAY "Totais de Entrada" SIZE 50,07 OF oDlg PIXEL
@ 037+nLinAmais,058 SAY OemtoAnsi("Quantidade")+" : " SIZE 040,07 OF oDlg PIXEL
@ 037+nLinAmais,096 SAY TRANSF(nTotEnt,cPictTotQT) SIZE 050,07 OF oDlg PIXEL
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//@ 037+nLinAmais,245 SAY OemtoAnsi("Custo Total") + " : "  SIZE 040,07 OF oDlg PIXEL
//@ 037+nLinAmais,283 SAY TRANSF(nTotVEnt,PesqPict("SB9","B9_VINI1")) SIZE 050,07 OF oDlg PIXEL
@ 045+nLinAmais,005 SAY "Totais de Saida" SIZE 50,07 OF oDlg PIXEL
@ 045+nLinAmais,058 SAY OemtoAnsi("Quantidade") SIZE 40,07 OF oDlg PIXEL
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
@ 045+nLinAmais,096 SAY TRANSF(nTotSda,cPictTotQT) SIZE 050,07 OF oDlg PIXEL 
//@ 045+nLinAmais,245 SAY "Custo Total" SIZE 40,07 OF oDlg PIXEL
//@ 045+nLinAmais,283 SAY TRANSF(nTotVSda,PesqPict("SB9","B9_VINI1")) SIZE 050,07 OF oDlg PIXEL

If Len(aTrbTmp)>0
	AADD(aTrbP,aTrbTmp)
	aTrbTmp:={}
EndIf

dbSelectArea("KDX")

For nY := 1 To Len(aTrbP)
	For nX := 1 to Len(aTrbP[nY])
		RecLock("KDX",.T.)

		If ValType(aTrbP[nY,nX,1])$'D'
			aTrbP[nY,nX,1] := DtoC(aTrbP[nY,nX,1])
		EndIf
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO	
/*
		Replace EMISSAO With aTrbP[nY,nX,1],;
		        TES     With aTrbP[nY,nX,2],;
		        CF      With aTrbP[nY,nX,3],;
		        DOC	    With aTrbP[nY,nX,4],;
		        IDENT   With aTrbP[nY,nX,7],;
		        QUANT   With aTrbP[nY,nX,8],;
		        CMEDIO  With aTrbP[nY,nX,9],;
		        CTOTAL  With aTrbP[nY,nX,10]
*/
		Replace EMISSAO With aTrbP[nY,nX,1],;
		        TES     With aTrbP[nY,nX,2],;
		        CF      With aTrbP[nY,nX,3],;
		        DOC	    With aTrbP[nY,nX,4],;
		        IDENT   With aTrbP[nY,nX,7],;
		        QUANT   With aTrbP[nY,nX,8]
		If mv_par06 == 1
			Replace LOCALI With aTrbP[nY,nX,5],;
				    NUMSER With aTrbP[nY,nX,6]
		EndIf
		If lRastro
			Replace LOTECTL With aTrbP[nY,nX,11]		
		EndIf                                   
		If lRastroS
			Replace NUMLOTE With aTrbP[nY,nX,12]				
		EndIf
		If lMc030Grv
			ExecBlock('MC030GRV', .F., .F., {"KDX",aStru,aTrbP[nY,nX]})
		EndIf	
		MsUnlock()	    
	Next nX
Next nY
             
//��������������������������������������Ŀ
//� Montagem do ACols (Visualiza��o)     �
//����������������������������������������
aCols := {}
dbGoTop()
While !EOF()
	AADD(aCols,Array(Len(aHeader)))
	aCols[Len(aCols)][1] := EMISSAO
	aCols[Len(aCols)][2] := TES
	aCols[Len(aCols)][3] := CF
	aCols[Len(aCols)][4] := DOC
	nX := 4
	If mv_par06 == 1
		aCols[Len(aCols)][++nX] := LOCALI
		aCols[Len(aCols)][++nX] := NUMSER
	EndIf   
	If lRastro
		aCols[Len(aCols)][++nX] := LOTECTL	
	EndIf
	If lRastroS
		aCols[Len(aCols)][++nX] := NUMLOTE
	EndIf	
	aCols[Len(aCols)][++nX] := IDENT  
	aCols[Len(aCols)][++nX] := QUANT  
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO	
//	aCols[Len(aCols)][++nX] := CMEDIO 
//	aCols[Len(aCols)][++nX] := CTOTAL 
	If lMc030Prj
		aRetPrj := ExecBlock('MC030PRJ', .F., .F., {"KDX",aHeader,aCols[len(aCols)]})
		
		If valtype(aRetPrj) == "A"
			if len(aRetPrj) >= 1 .And. valtype(aRetPrj[1]) == "A"
				aHeader := aRetPrj[1]
			EndIf
			if len(aRetPrj) >= 2 .And. valtype(aRetPrj[2]) == "A"
				aCols[len(aCols)] := aRetPrj[2]
			EndIf			
		EndIf
	EndIf	
	
	dbSkip()
EndDo    

For nX:=1 To Len(aHeader)
	aadd(aFields,aHeader[nX,1])
Next nX                                                               

oQual :=  TWBrowse():New( 55+nLinAmais, 005, (nRight-nLeft-20)/2, ((nBottom-nTop-150)/2)-(nLinaMais*1.5), , aFields,, oDlg,,,,,,,,,,,,,,.T.)

oQual:SetArray(aCols)
oQual:bLine := { || aCols[oQual:nAT] }

DEFINE SBUTTON FROM (nBottom-50)/2,(nRight-220)/2 TYPE 1  ACTION (oDlg:End())	ENABLE OF oDlg PIXEL
DEFINE SBUTTON FROM (nBottom-50)/2,(nRight-160)/2 TYPE 6  ACTION (a030Imp(aSalIni),oDlg:End()) ENABLE OF oDlg PIXEL
DEFINE SBUTTON FROM (nBottom-50)/2,(nRight-100)/2 TYPE 23 ACTION A030Graph(aGraph,1) ENABLE OF oDlg PIXEL
ACTIVATE MSDIALOG oDlg CENTERED

dbSelectArea('KDX')
dbCloseArea()
//Ferase(cArqTmp+GetDBExtension())
//Ferase(cArqInd+OrdBagExt())
dbSelectArea(cSavAlias)

Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � a030Imp  � Autor � Marcelo Pimentel      � Data � 18/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Envia para funcao que faz a impressao da consulta.         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � a030Imp(ExpA1)  			  		                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 = Array do saldo inicial 	                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATC030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function a030Imp(aSalIni)

local cTitulo   := OemToAnsi("CONSULTA AO KARDEX")
local cDesc1    := OemToAnsi("Este programa ira imprimir a Consulta do Produto selecionado")
local cDesc2    := OemToAnsi("informando as movimentacoes de estoque com seus respectivos")
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//local cDesc3    := OemToAnsi("custos, saldos iniciais e saldos finais.")
local cDesc3    := OemToAnsi("saldos iniciais e saldos finais.")
local cString   :="SD1"
local wnrel     :="MATC030"   
local Tamanho   := If(mv_par06==1,"G","M")
PRIVATE cPerg   :="      "
PRIVATE aReturn := { OemToAnsi("Zebrado"), 1,OemToAnsi("Administracao"), 2, 2, 1, "",1 }
PRIVATE nLastKey:=0
                                    
wnRel:= SetPrint(cString,wnrel,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,Tamanho) 

If nLastKey <> 27
	SetDefault(aReturn,cString)
	If nLastKey <> 27

		RptStatus({|lEnd| C030Imp(@lEnd,wnRel,tamanho,ctitulo,aSalIni)},ctitulo)

	EndIf
EndIf
Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � C030Imp  � Autor � Marcelo Pimentel      � Data � 19/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Envia para funcao que faz a impressao da consulta.         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � C030Imp(ExpL1,ExpC1,ExpC2,ExpC3,ExpA1)                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpL1 = var. p/ controle de interrupcao pelo usuario 	  ���
���          � ExpC1 = codigo do relatorio                                ���
���          � ExpC2 = codigo ref. ao tamanho do relatorio (P/M/G)        ���
���          � ExpC3 = titulo do relatorio                                ���
���          � ExpA1 = Array do saldo inicial 	                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATC030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function C030Imp(lEnd,wnRel,cTamanho,ctitulo,aSalIni)

local cCabec1  :=""
local cCabec2  :=""
local nTipo     := If(aReturn[4]==1,15,18)
local cbtxt    := SPACE(10)
local cbcont   := 0
local aSaldoAnt:={'','',''}
local nX    
local nCol,nColQtdTot
local lDescArm := SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+mv_par03)) .AND. !Empty(SB2->B2_LOCALIZ)
local lRastro	:= Rastro(SB1->B1_COD)
local lRastroS	:= If(lRastro,Rastro(SB1->B1_COD,"S"),.F.)
local nIncCol	:= If(cPaisLoc=='MEX',8,0)

For nX:=1 To Len(aHeader)
	cCabec1 += OemtoAnsi(aHeader[nX,1])+" "
Next
nCol:= 35 + nIncCol
nX	:= 4
If mv_par06 == 1
	nX++
	nCol	+= Max(Len(aHeader[nX,1]),aHeader[nX,4]+2)
	nX++  
	nCol	+= Max(Len(aHeader[nX,1]),aHeader[nX,4]+2)
EndIf                   
If lRastro
	nX++
	nCol	+= Max(Len(aHeader[nX,1]),aHeader[nX,4]+2)	
EndIf
If lRastroS
	nX++
	nCol	+= Max(Len(aHeader[nX,1]),aHeader[nX,4]+4)
EndIf
nX++     
nCol	+= Max(Len(aHeader[nX,1]),aHeader[nX,4]+2)   
nColQtdTot := nCol      
li       := 80
m_pag    := 1

Li++ 
dbSelectArea('KDX')
dbGoTop()
While !Eof()
	If li > 58
		cabec(cTitulo,cCabec1,cCabec2,wnRel,cTamanho,nTipo,,.F.)
		@ li, 00 pSay 'Produto: ' + Left(AllTrim(SB1->B1_COD), TamSX3("B1_COD")[1]) + ' - ' + Left(SB1->B1_DESC, 30)
		LI++
		@ li, 00 pSay 'Tipo: ' + Left(SB1->B1_TIPO, 2)
		@ li, 12 pSay 'Unidade: ' + Left(SB1->B1_UM, 2)
		@ li, 27 pSay 'Grupo: ' + SB1->B1_GRUPO
		li ++
		@ li, 00 pSay 'Almoxarifado: ' + mv_par03 + IIF(lDescArm," - "+SB2->B2_LOCALIZ,"")
		li ++
		@ li, 00 pSay "Saldos Iniciais:"
		@ li, nColQtdTot	pSay aSalIni[1]	// Quant
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//		@ li, nColQtdTot+20	psay aSalIni[2]	// Custo Medio
//		@ li, nColQtdTot+38	pSay aSalIni[3]	// Custo Total
		If !aSaldoAnt[1]=='' .AND. !aSaldoAnt[2]==''
			li++
			@ li,00 PSay "Saldo pagina Anterior"
			@ li,nColQtdTot		PSay aSalAtu[1] PICTURE PesqPict("SB2","B2_QATU",18)// Quant
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//			@ li,nColQtdTot+20	PSay aSaldoAnt[2] // Custo Medio
//			@ li,nColQtdTot+38	PSay aSaldoAnt[3] // Custo Total
			li += 2
		Else 
			li += 3                           
		EndIf
	EndIf
	@ li,000 PSay EMISSAO
	@ li,011 PSay TES
	@ li,015 PSay CF
	@ li,021 PSay DOC

	nCol:= 35 + nIncCol
	nX	:= 4
	// �������������������������������������������������������Ŀ
	// �Verifica se imprime Localizacao                        �
	// ���������������������������������������������������������
	If mv_par06 == 1
		@ li,nCol PSay LOCALI         
		nX++
		nCol	+= Max(Len(aHeader[nX,1]),aHeader[nX,4]+2)
		@ li,nCol PSay NUMSER             
		nX++  
		nCol	+= Max(Len(aHeader[nX,1]),aHeader[nX,4]+2)
	EndIf                   
	If lRastro
		@ li,nCol PSay LOTECTL  
		nX++
		nCol	+= Max(Len(aHeader[nX,1]),aHeader[nX,4]+2)	
	EndIf
	If lRastroS
		@ li,nCol PSay NUMLOTE                              
		nX++
		nCol	+= Max(Len(aHeader[nX,1]),aHeader[nX,4]+4)
	EndIf
	
	@ li,nCol PSay IDENT     // Ident                    
	nX++     
	If Empty(nColQtdTot)
		nCol	+= Max(Len(aHeader[nX,1]),aHeader[nX,4]+2)   
		nColQtdTot := nCol      
	EndIf
	@ li,nColQtdTot		PSay QUANT    // Quant                     
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//	@ li,nColQtdTot+20 	PSay CMEDIO   // Custo Medio 
//	@ li,nColQtdTot+38 	PSay CTOTAL   // Custo Total

	If SubStr(EMISSAO,1,1) == "S"
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO	
//		aSaldoAnt := {QUANT,CMEDIO,CTOTAL}
		aSaldoAnt := {QUANT,'',''}
	EndIf

	li++
	dbSkip()
EndDo

li+=4

If li > 58
	cabec(cTitulo,cCabec1,cCabec2,wnRel,cTamanho,nTipo)
	li += 2
EndIf

@ li,00 			PSAY "Saldos Finais"
@ li,nColQtdTot+02 	PSay aSalAtu[1] PICTURE PesqPict("SB2","B2_QATU",18)
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO	
//@ li,nColQtdTot+20	PSay IIF(aSalAtu[1] <> 0,TRANSF(aSalAtu[mv_par05+1]/aSalAtu[1],PesqPictQT("B2_VATU1")),TRANSF(0,PesqPictQt("B2_VATU1")))
//@ li,nColQtdTot+38	PSay TRANSF(aSalAtu[mv_par05+1],PesqPict("SB2","B2_VATU1")) 
li++
@ li,00 			PSAY "Totais das Entradas"
@ li,nColQtdTot+02	PSay TRANSF(nTotEnt,PesqPict("SB2","B2_QATU",18))
@ li,nColQtdTot+38	PSay TRANSF(nTotVEnt,PesqPict("SB2","B2_VATU1")) 
li++
@ li,00 			PSAY "Totais das Saidas"
@ li,nColQtdTot+02	PSay TRANSF(nTotSda,PesqPict("SB2","B2_QATU",18))
@ li,nColQtdTot+38	PSay TRANSF(nTotVSda,PesqPict("SB2","B2_VATU1")) 

If li <> 80
	li++
	roda(cbcont,cbtxt,cTamanho)
EndIf

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
EndIf

MS_Flush()

Return (.T.)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MTC030CUnf � Autor �Rodrigo de A. Sartorio � Data �27/06/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Ajusta grupo de perguntas p/ Custo Unificado                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATC030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MTC030CUnf()

local aSvAlias:=GetArea()
local nTamSX1 := Len((_cAliasSX1)->X1_GRUPO)

If dbSeek(PADR("MTC030",nTamSX1)+"03",.F.)
	If !("MTC030VAlm" $ (_cAliasSX1)->X1_VALID)
		while !RecLock(_cAliasSX1,.F.) ; enddo
			If Empty((_cAliasSX1)->X1_VALID)
				(_cAliasSX1)->X1_VALID := "MTC030VAlm"
			Else
				(_cAliasSX1)->X1_VALID := (_cAliasSX1)->X1_VALID+".AND.MTC030VAlm"
			EndIf
		(_cAliasSX1)->(MsUnlock())
	EndIf
	If lCusUnif .AND. (_cAliasSX1)->X1_CNT01 <> "**"
		while !RecLock(_cAliasSX1,.F.) ; enddo
			(_cAliasSX1)->X1_CNT01 := "**"
		(_cAliasSX1)->(MsUnlock())
	EndIf
Endif

RestArea(aSvAlias)
Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MTC030VAlm � Autor �Rodrigo de A. Sartorio � Data �27/06/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida Almoxarifado do KARDEX com relacao a custo unificado ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T. / .F.                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATC030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MTC030VAlm()
local lRet:=.T.
local cConteudo:=&(ReadVar())
local nOpc:=2
If lCusUnif .And. cConteudo <> "**"
	nOpc := Aviso("Aten��o","Ao alterar o almoxarifado o custo medio unificado sera desconsiderado.",{"Confirma","Abandona"})
	If nOpc == 2
		lRet:=.F.
	EndIf
EndIf
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A030Graph  � Autor �Rodrigo de A. Sartorio � Data �16/05/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta array para grafico da consulta ao Kardex e efetua a   ���
���          �chamada para a funcao generica de montagem de dados.        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A030Graph(ExpA1,ExpN1)	  		                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 = Array com os dados para o grafico				  ���
���          � ExpN1 = No.da opcao do grafico (1=qtde/2=c.medio/3=c.total)���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATC030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A030Graph(aGraph,nOpcao)
local aDados:={}
local nz:=0
local dData
local cTitulo:="Gr�fico"+" - "
local oRadio,oDlg2

//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
/*
//DEFAULT nOpcao:= 1 // QUANTIDADE
// Monta Dialog para selecionar tipo de grafico
DEFINE MSDIALOG oDlg2 TITLE "Dados do Grafico" From 150,70 To 250,300 OF oMainWnd PIXEL
@12,08 RADIO oRadio VAR nOpcao SIZE 50,12 PIXEL PROMPT STR0011,STR0015,STR0016
DEFINE SBUTTON FROM 020,070 TYPE 1 ACTION oDlg2:End() ENABLE OF oDlg2 PIXEL
ACTIVATE MSDIALOG oDlg2 CENTERED

// Quantidade
If(nOpcao) == 1
	cTitulo+="Quantidade"+" X "+Alltrim("Data")
 Custo Medio
21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
ElseIf(nOpcao) == 2
    cTitulo+=STR0015+" X "+Alltrim(STR0017)
 Custo total
ElseIf(nOpcao) == 3
    cTitulo+=STR0016+" X "+Alltrim(STR0017)
EndIf
*/
nOpcao := 1 // QUANTIDADE
cTitulo+="Quantidade"+" X "+Alltrim("Data")

For nz:=1 to Len(aGraph)
	If ValType(aGraph[nz,1]) == "D"
		If dData # aGraph[nz,1]
			dData:=aGraph[nz,1]
			AADD(aDados,{DTOC(dData),aGraph[nz,nOpcao+1]})	
		Else
			AADD(aDados,{"",aGraph[nz,nOpcao+1]})	
		EndIf
	EndIf
Next nz
// Chama funcao generica para montagem de grafico
MatGraph(cTitulo,.F.,.T.,.T.,1,6,aDados)
Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �AddArray   � Autor �Armando Pereira Waiteman� Data �Set/2001 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Adiciona array mantendo tamanho maximo de elementos por      ���
���          �dimensao                                                     ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � AddArray(ExpA1)			  		                           ���
��������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 = Array dos dados dos itens da consulta			   ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                      ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � MATC030                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function AddArray(aItem,cAlias)

local aRetPE  := {}
local aItemPE := aClone(aItem)   

DEFAULT cAlias := ""

If ExistBlock('MC030ARR')                          
	aRetPE := ExecBlock('MC030ARR', .F., .F.,{aItemPE,cAlias})
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//	If ValType(aRetPE) == 'A'
	If ValType(aRetPE) == 'A' .AND. Len(aRetPE) > 0
		aItem := aRetPE
	EndIf
EndIf

aAdd(aTrbTmp, aItem)

If Len(aTrbTmp) >= 65000
	AADD(aTrbp,aTrbtmp)
	aTrbTmp:= {}
EndIf

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MC030Data  � Autor �Marcelo Iuspa          � Data �Set/2001 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Obtem a data a partir do dos arrays aTrbTmp e aTrbP         ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpD1 := MC030Data(ExpC1)	 	                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arq. de movimento						  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpD1 = Data do arq.mov. ou dos arrays aTrbTmp e aTrbP     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATC030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MC030Data(cAlias)
local dData
Default cAlias := Nil
If mv_par04==1 .AND. Len(aTrbTmp) == 0
	dData := aTrbP  [Len(aTrbp)]  [Len(aTrbp[Len(aTrbP)])-1] [1]
ElseIf mv_par04==1 .AND. Len(aTrbTmp) == 1
	dData := aTrbP  [Len(aTrbp)]  [Len(aTrbp[Len(aTrbP)])-0] [1]
ElseIf mv_par04==2 .AND. Len(aTrbTmp) == 0
	dData := aTrbP  [Len(aTrbp)]  [Len(aTrbp[Len(aTrbP)])-0] [1]
ElseIf mv_par04==2 .AND. Len(aTrbTmp) == 1
	dData:=aTrbTmp[Len(aTrbTmp)] [1]
Else 
	dData:=aTrbTmp[Len(aTrbTmp)-If(mv_par04==1,1,0)][1]
Endif
If mv_par06 == 1
    If cAlias == "SD1"
       dData := SD1->D1_DTDIGIT
    ElseIf cAlias == "SD2"
       dData := SD2->D2_EMISSAO   
    ElseIf cAlias == "SD3"
       dData := SD3->D3_EMISSAO   
    Endif	
EndIf
	
Return(dData)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AjustaSX1� Autor � Marcos V. Ferreira    � Data �16/08/2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Altera descricao da pergunta no SX1                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATC030			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
static function AjustaSX1()
	local aArea   := GetArea()
	local aPerg   := {}
	local cPerg   := "MTC030" 
	local nTamSX1 := Len((_cAliasSX1)->X1_GRUPO)

	Aadd(aPerg,{"Digitacao","Digitacion","Typing"})
	Aadd(aPerg,{"Calculo","Calculo","Calculation"})
	If (_cAliasSX1)->(dbSeek(PADR(cPerg,nTamSX1)+"07"))
		while !RecLock(_cAliasSX1,.F.) ; enddo
			(_cAliasSX1)->X1_DEF01 	 := aPerg[1][1]
			(_cAliasSX1)->X1_DEFSPA1 := aPerg[1][2]
			(_cAliasSX1)->X1_DEFENG1 := aPerg[1][3]
			(_cAliasSX1)->X1_DEF02 	 := aPerg[2][1]
			(_cAliasSX1)->X1_DEFSPA2 := aPerg[2][2]
			(_cAliasSX1)->X1_DEFENG2 := aPerg[2][3]
		(_cAliasSX1)->(MsUnLock())
	EndIf
	RestArea( aArea )
return
/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Fabio Alves Silva     � Data �05/10/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
Static Function MenuDef()     
Private aRotina	:= {	{"&Pesquisar","AxPesqui", 0 , 1,0,.F.},;
				  		{"&Consulta","U_MC030Con('MENU')", 0 , 2,0,NIL}}
If ExistBlock ("MTC030MNU")					  		    
	ExecBlock ("MTC030MNU",.F.,.F.)
Endif	
Return (aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MTC030IsMNT� Autor � Lucas                � Data � 03.10.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se h� integra��o com o modulo SigaMNT/NG          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T. = Se existir o produto do parametro MV_PRODMNT	      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATC030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MTC030IsMNT()
local aArea
local aAreaSB1
local aProdsMNT := {}
local cProdMNT	 := ""
local nX := 0
local lIntegrMNT := .F.

//Esta funcao encontra-se no modulo Manutencao de Ativos (NGUTIL05.PRX), e retorna os produtos (pode ser MAIS de UM), dos parametros de
//Manutencao - "M" (MV_PRODMNT) / Terceiro - "T" (MV_PRODTER) / ou Ambos - "*" ou em branco
If FindFunction("NGProdMNT")
	aProdsMNT := aClone(NGProdMNT("M"))
	If Len(aProdsMNT) > 0
		aArea	 := GetArea()
		aAreaSB1 := SB1->(GetArea())
		
		SB1->(dbSelectArea( "SB1" ))
		SB1->(dbSetOrder(1))
		For nX := 1 To Len(aProdsMNT)
			If SB1->(dbSeek( xFilial("SB1") + aProdsMNT[nX] ))
				lIntegrMNT := .T.
				Exit
			EndIf 
		Next nX
		
		RestArea(aAreaSB1)
		RestArea(aArea)
	EndIf
Else //Se a funcao nao existir, processa com o parametro aceitando 1 (UM) Produto
	cProdMNT := GetMv("MV_PRODMNT")
	cProdMNT := cProdMNT + Space(15-Len(cProdMNT))
	If !Empty(cProdMNT)
		aArea	 := GetArea()
		aAreaSB1 := SB1->(GetArea())
		SB1->(dbSelectArea( "SB1" ))
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek( xFilial('SB1') + cProdMNT ))
			lIntegrMNT := .T.
		EndIf 
		RestArea(aAreaSB1)
		RestArea(aArea)
	EndIf
EndIf
Return( lIntegrMNT )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MTC030NFExp � Autor �Lucas				r  � Data �29/04/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Pega Custo das NF de Importacao         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATC030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MTC030NFExp(cProd)
local aSvAreaSF1:=SF1->(GetArea())
local aSvAreaSD1:=SD1->(GetArea()) 
local cHawb := ""
local aSaldoExp := { SD1->D1_QUANT, 0.00, SD1->D1_QTSEGUM }
DbSelectArea("SF1")
SF1->(DbSetOrder(1))
If SF1->(DbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
   	
  		cHawb := SF1->F1_HAWB
	
		If !Empty(cHawb) 
	
			DbSelectArea("SF1")
			SF1->(DbSetOrder(5))
			SF1->(DbSeek(xFilial("SF1")+cHawb))

        	While !Eof() .and. SF1->F1_HAWB == cHawb

				If Empty(SF1->F1_REMITO) .AND. ! SF1->F1_TIPO_NF $ "9A"  
			
					DbSelectArea("SD1")
					SD1->(DbSetOrder(1))
					If SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+cProd))
			
						If AllTrim(SD1->D1_ESPECIE) == "NF"
							If mv_par05 == 1
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//								aSaldoExp[2] := SD1->D1_CUSTO
								aSaldoExp[2] := 0
							ElseIf mv_par05 == 2	
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//								aSaldoExp[2] := SD1->D1_CUSTO2
								aSaldoExp[2] := 0
							ElseIf mv_par05 == 3
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//								aSaldoExp[2] := SD1->D1_CUSTO3
								aSaldoExp[2] := 0
							ElseIf mv_par05 == 4	
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//								aSaldoExp[2] := SD1->D1_CUSTO4
								aSaldoExp[2] := 0
							ElseIf mv_par05 == 5	
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//								aSaldoExp[2] := SD1->D1_CUSTO5
								aSaldoExp[2] := 0
							EndIf																								
						EndIf	
					EndIf
				Else	
					DbSelectArea("SD1")
					SD1->(DbSetOrder(1))
					If SD1->(DbSeek(xFilial("SD1")+SF1->F1_REMITO+"RI "+SF1->F1_FORNECE+SF1->F1_LOJA+cProd))

						If AllTrim(SD1->D1_ESPECIE) == "RCN"
							If mv_par05 == 1
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//								aSaldoExp[2] := SD1->D1_CUSTO
								aSaldoExp[2] := 0
							ElseIf mv_par05 == 2	
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//								aSaldoExp[2] := SD1->D1_CUSTO2
								aSaldoExp[2] := 0
							ElseIf mv_par05 == 3
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//								aSaldoExp[2] := SD1->D1_CUSTO3
								aSaldoExp[2] := 0
							ElseIf mv_par05 == 4	
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//								aSaldoExp[2] := SD1->D1_CUSTO4
								aSaldoExp[2] := 0
							ElseIf mv_par05 == 5	
//21/05/2015 - ALTERA��O ALL SYSTEM SOLUTIONS - ANDERSON C. P. COELHO
//								aSaldoExp[2] := SD1->D1_CUSTO5
								aSaldoExp[2] := 0
							EndIf																								
						EndIf	
					EndIf	
				EndIf					
				DbSelectArea("SF1")
				DbSkip()
			End	
		EndIf
EndIf

RestArea(aSvAreaSF1)
RestArea(aSvAreaSD1)
Return(aSaldoExp)
