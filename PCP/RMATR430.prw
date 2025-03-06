#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
#include "fileio.ch"
//#INCLUDE "MATR430.CH"

///////////////////////////////////////////////////////////////////////////////////
//                                                                               //
// As altera��es neste fonte est�o identificadas da seguinte maneira:            //
// DD/MM/AAAA - Altera��o ALLSS - Descritivo das altera��es realizadas no trecho //
//                                                                               //
///////////////////////////////////////////////////////////////////////////////////

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RMATR430  � Autor � Ricardo Berti         � Data �07.07.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao da Planilha de Formacao de Precos                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function RMATR430()

Local oReport

If FindFunction("TRepInUse") //.And. TRepInUse()
	//������������������������������������������������������������������������Ŀ
	//�Interface de impressao                                                  �
	//��������������������������������������������������������������������������
	oReport := ReportDef()
	oReport:PrintDialog()
//Else
//	MATR430R3()
EndIf

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Ricardo Berti 		� Data �07.07.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relatorio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR430                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

//Local oCell         
Local cPerg	:= "MTR430"
Local oReport 
Local oSection
//Local nI
Local cPicQuant	:=PesqPictQt("G1_QUANT",13)
Local cPicUnit	:=PesqPict("SB1","B1_CUSTD",18)
Local cPicTot	:=PesqPict("SB1","B1_CUSTD",19)

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport := TReport():New("MATR430","Forma��o de Pre�os",cPerg, {|oReport| ReportPrint(oReport)},"Emite um relatorio com os calculos da planilha selecionada pa-"+" "+"ra cada produto. Os valores calculados sao os mesmos  referen-"+" "+"tes as formulas da planilha.")

AjustaSx1()
//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte(cPerg,.F.)
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01     // Produto inicial                              �
//� mv_par02     // Produto final                                �
//� mv_par03     // Nome da planilha utilizada                   �
//� mv_par04     // Imprime estrutura : Sim / Nao                �
//� mv_par05     // Moeda Secundaria  : 1 2 3 4 5                �
//� mv_par06     // Nivel de detalhamento da estrutura           �
//� mv_par07     // Qual a Quantidade Basica                     �
//� mv_par08     // Considera Qtde Neg na estrutura: Sim/Nao     �
//� mv_par09     // Considera Estrutura / Pre Estrutura          �
//� mv_par10     // Revisao da Estrutura 				         �
//����������������������������������������������������������������
//����������������������������������������������������������������Ŀ
//� Forca utilizacao da estrutura caso nao tenha SGG               �
//������������������������������������������������������������������
If Select("SGG") == 0
	mv_par09 := 1
EndIf
oSection := TRSection():New(oReport,"Produtos",{"SB1"})
oSection:SetHeaderPage()

TRCell():New(oSection,"CEL"		,"","Cel."/*Titulo*/,"99999"/*Picture*/,5/*Tamanho*/,/*lPixel*/,/*{|| Code block }*/)
TRCell():New(oSection,"NIVEL"	,"",RetTitle("G1_NIV"),"XXXXXX",6)
TRCell():New(oSection,"B1_COD"	,"SB1")
TRCell():New(oSection,"B1_DESC"	,"SB1",,,30)
TRCell():New(oSection,"B1_UM"	,"SB1")
TRCell():New(oSection,"QUANT"	,"",RetTitle("G1_QUANT"),cPicQuant)
TRCell():New(oSection,"VALUNI"	,"","Valor Unitario",cPicUnit)
TRCell():New(oSection,"VALTOT"	,"","Valor Total",cPicTot)
TRCell():New(oSection,"VALUNI2" ,"","Valor Unitario",cPicUnit)
TRCell():New(oSection,"VALTOT2" ,"","Valor Total",cPicTot)
TRCell():New(oSection,"PERCENT","","% Part","999.999",7)

Return(oReport)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor � Ricardo Berti 		� Data �07.07.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relatorio                           ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport)

Local aArray	:= {}
Local aArray1	:= {}
Local aPar		:= Array(20)
Local aParC010	:= Array(20)
Local lFirstCb	:= .T.
Local nReg
Local nI, nX
Local oSection  := oReport:Section(1)
LOCAL cCondFiltr:= ""

//��������������������������������������������������������������Ŀ
//� Variaveis privadas exclusivas deste programa                 �
//����������������������������������������������������������������
PRIVATE cProg:="R430"  // Usada na funcao externa MontStru()

//����������������������������������������������������������������Ŀ
//� Custo a ser considerado nos calculos                           �
//� 1 = STANDARD    2 = MEDIO     3 = MOEDA2     4 = MOEDA3        �
//� 5 = MOEDA4      6 = MOEDA5    7 = ULTPRECO   8 = PLANILHA      �
//������������������������������������������������������������������
PRIVATE nQualCusto := 1

//��������������������������������������������������������������Ŀ
//� Vetor declarado para inversao do calculo do Valor Unitario   �
//� Utilizado no MATC010X -> M010Forma e CalcTot                 �
//����������������������������������������������������������������
PRIVATE aAuxCusto

//����������������������������������������������������������������Ŀ
//� Nome do arquivo que contem a memoria de calculo desta planilha �
//������������������������������������������������������������������
PRIVATE cArqMemo := "STANDARD"

//����������������������������������������������������������������Ŀ
//� Direcao do calculo .T. para baixo .F. para cima                �
//������������������������������������������������������������������
PRIVATE lDirecao := .T.

PRIVATE lConsNeg := (mv_par08 = 1)     // Esta variavel sera' usada na funcao MC010FORMA

//Salvar variaveis existentes
For nI := 1 to 20
	aPar[nI] := &("mv_par"+StrZero(nI,2))
Next nI
//���������������������������������������������������������������Ŀ
//� Inclui pergunta no SX1                                        �
//�����������������������������������������������������������������
//03/01/2019 - Altera��o ALLSS - Trecho comentado pois, ap�s atualiza��o do sistema, come�ou a gerar error.log
//MTC010SX1()
Pergunte("MTC010", .F.)
//����������������������������������������������������������������Ŀ
//� Forca utilizacao da estrutura caso nao tenha SGG               �
//������������������������������������������������������������������
If Select("SGG") == 0
	mv_par09 := 1
EndIf
//Salvar variaveis existentes
For nI := 1 to 20
	aParC010[nI] := &("mv_par"+StrZero(nI,2))
Next nI
//Forca mesmo valor do relatorio na pergunta 09
mv_par09     := aPar[09]
aParC010[09] := aPar[09]

// Restaura parametros MTR430
For nI := 1 to 20
	&("mv_par"+StrZero(nI,2)) := aPar[nI]
Next nI

oReport:NoUserFilter()  // Desabilita a aplicacao do filtro do usuario no filtro/query das secoes

dbSelectArea("SB1")
//������������������������������������������������������������������������Ŀ
//�Filtragem do relatorio                                                  �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao Advpl                          �
//��������������������������������������������������������������������������
MakeAdvplExpr(oReport:uParam)

//��������������������������������������������������������������������������Ŀ
//� Mantem o Cad.Produtos posicionado para cada linha impressa da planilha   � 
//����������������������������������������������������������������������������
TRPosition():New(oSection,"SB1",1,{|| xFilial("SB1") + aArray[nX][04] })

//��������������������������������������������������������������������������Ŀ
//� Inicializa o nome padrao da planilha com o nome selecionado pelo usuario � 
//����������������������������������������������������������������������������
cArqMemo := apar[03]

If MR430Plan(.T.,aPar)

	If apar[05] == 1
		oSection:Cell("VALUNI2"):Disable()
		oSection:Cell("VALTOT2"):Disable()
	EndIf	
	//������������������������������������������������������������������������Ŀ
	//�Inicio da impressao do fluxo do relatorio                               �
	//��������������������������������������������������������������������������
	oReport:SetMeter(SB1->(LastRec()))
	dbSeek(xFilial("SB1")+apar[01],.T.)

	oSection:Init() 

	//����������������������������������������������������������������������Ŀ
	//� Este procedimento e' necessario p/ transformar o filtro selecionado  �
	//� pelo usuario em uma condicao de IF, isto porque o filtro age em todo �
	//� o arquivo e devido `a posterior explosao de niveis da estrutura, em  �
	//� MATC010X-> M010Forma(), o filtro deve ser validado apenas no While   �
	//� principal															 �
	//������������������������������������������������������������������������
	cCondFiltr := oSection:GetAdvplExp()
	If Empty(cCondFiltr)
		cCondFiltr := ".T."
	EndIf

	While !oReport:Cancel() .And. !SB1->(Eof()) .And. ;
		SB1->B1_FILIAL == xFilial("SB1") .And. SB1->B1_COD <= apar[02]
		If oReport:Cancel()
			Exit
		EndIf
		//��������������������������������������������������������������Ŀ
		//� Considera filtro escolhido                                   �
		//����������������������������������������������������������������
		If &(cCondFiltr)
			nReg := Recno()

			// Restaura parametros MTC010
			For nI := 1 to 20
				&("mv_par"+StrZero(nI,2)) := aParc010[nI]
			Next nI

			aArray1 := MC010Forma("SB1",nReg,99,apar[07],,.F.,apar[10])
			
			// Restaura parametros MTR430
			For nI := 1 to 20
				&("mv_par"+StrZero(nI,2)) := aPar[nI]
			Next nI

			If Len(aArray1) > 0
				aArray	:= aClone(aArray1[2])
				MR430ImpTR(aArray1[1],aArray1[2],aArray1[3],oReport,aPar,aParC010,@nx,@lFirstCb)
			EndIf

			dbSelectArea("SB1")
			dbGoTo(nReg)
		EndIf
		dbSkip()
		oReport:IncMeter()
	EndDo
	oSection:Finish()
EndIf
dbSelectArea("SB1")
dbClearFilter()
dbSetOrder(1) 

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MR430ImpTR� Autor � Ricardo Berti 		� Data �07.07.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime os dados ja' calculados                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MR430ImpTR(ExpC1,ExpA1,ExpN1,ExpO1,ExpA2,ExpA3,ExpN2)      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Titulo do custo utilizado                          ���
���          � ExpA1 = Array com os dados ja' calculados                  ���
���          � ExpN1 = Numero do elemento inicial a imprimir              ���
���          � ExpO1 = obj Report                                         ���
���          � ExpA2 = Array com os parametros de MTR430                  ���
���          � ExpA2 = Array com os parametros de MTC010                  ���
���          � ExpN2 = elemento do aArray, passado por referencia		  ���
���          � ExpL1 = indica primeiro acesso, para montagem de cabec.	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR430                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static function MR430ImpTR(cCusto,aArray,nPosForm,oReport,aPar,aParC010,nx,lFirstCb)

Local oSection  := oReport:Section(1)
LOCAL cMoeda1,cMoeda2
LOCAL nDecimal	:=0
Local lFirst	:= .T.
Local cOldAlias
Local nOrder
Local nRecno
Local nValUnit, nCotacao
Local cTit1,cTit2,cTit3,cTit4                                             

DEFAULT lFirstCb := .T.

cCusto := If(cCusto=Nil,'',AllTrim(Upper(cCusto)))
If cCusto == 'ULT PRECO'
	nDecimal := TamSX3('B1_UPRC')[2]
ElseIf cCusto == 'PRECO_FUTURO'
	nDecimal := TamSX3('B1_FATLUC')[2]
ElseIf 'MEDIO' $ cCusto
	nDecimal := TamSX3('B2_CM1')[2]
Else
	nDecimal := TamSX3('B1_CUSTD')[2]
EndIf

//��������������������������������������������������������������Ŀ
//� De acordo com o custo da planilha lida monta a cotacao de    �
//� conversao e a variavel cMoeda1 usada no cabecalho.           �
//����������������������������������������������������������������
//If Str(nQualCusto,1) $ "3/4/5/6"
If Str(nQualCusto,1) $ "3/4/5" //07/10/2024 - Diego Rodrigues - Adequa��o para atender ao processo de pre�o futuro dos custos
	nCotacao:=ConvMoeda(dDataBase,,1,Str(nQualCusto-1,1))
	cMoeda1	:=GetMV("MV_SIMB"+Str(nQualCusto-1,1,0))
	If Empty(cMoeda1)
		cMoeda1	:=GetMV("MV_MOEDA"+Str(nQualCusto-1,1,0))
	EndIf
Else
	nCotacao:=1
	cMoeda1	:=GetMV("MV_SIMB1")
EndIf

If lFirstCb
	cMoeda1	:= PADC(Alltrim(cMoeda1),12)
	cTit1:=oSection:Cell("VALUNI"):Title()
	cTit2:=oSection:Cell("VALTOT"):Title()
	oSection:Cell("VALUNI"):SetTitle(cTit1+CRLF+cMoeda1) //"Valor Unitario"
	oSection:Cell("VALTOT"):SetTitle(cTit2+CRLF+cMoeda1) //"Valor Total"
	lFirstCb := .F.
EndIf

If apar[05] <> 1
	//��������������������������������������������������������������Ŀ
	//� De acordo com o parametro da segunda moeda (mv_par05) remonta�
	//� os titulos de valores no cabecalho p/ moeda secundaria		 �
	//����������������������������������������������������������������
	cMoeda2	:= GetMV("MV_SIMB"+Str(apar[05],1,0))
	If Empty(cMoeda2)
		cMoeda2 := GetMV("MV_MOEDA"+Str(apar[05],1,0))
	EndIf           
	cMoeda2	:= PADC(Alltrim(cMoeda2),12)
	cTit3:= oSection:Cell("VALUNI2"):Title()
	cTit4:= oSection:Cell("VALTOT2"):Title()
	oSection:Cell("VALUNI2"):SetTitle(cTit3+CRLF+PadC(AllTrim(cMoeda2),12)) //"Valor Unitario"
	oSection:Cell("VALTOT2"):SetTitle(cTit4+CRLF+PadC(AllTrim(cMoeda2),12)) //"Valor Total"
EndIf

For nX := 1 To Len(aArray)
	//���������������������������������������������������������Ŀ
	//� Verifica o nivel da estrutura para ser impresso ou nao  �
	//�����������������������������������������������������������
	If apar[04] == 1
		If Val(apar[06]) != 0
			If Val(aArray[nX,2]) > Val(apar[06])
				Loop
			Endif
		Endif
	Endif

	If If( (Len(aArray[ nX ])==12),aArray[nX,12],.T. )

		If lFirst
			oReport:SkipLine()
			lFirst := .F.
		EndIf
		oSection:Cell("CEL"):SetValue(aArray[nX][01])
		oSection:Cell("NIVEL"):SetValue(aArray[nX][02])
		oSection:Cell("B1_COD"):SetValue(aArray[nX][04])
		oSection:Cell("B1_DESC"):SetValue(aArray[nX][03])
		If aArray[nX][04] == Replicate("-",15)
			oSection:Cell("VALTOT"):Hide()
			oSection:Cell("PERCENT"):Hide()
			If apar[05] <> 1
				oSection:Cell("VALUNI2"):Hide()
				oSection:Cell("VALTOT2"):Hide()
			EndIf
		Else
			If nX < nPosForm-1
				If aParc010[02] == 1
					nValUnit := Round(aAuxCusto[nX]/aArray[nX][05], nDecimal)
				Else
					nValUnit := NoRound(aAuxCusto[nX]/aArray[nX][05], nDecimal)
				EndIf
			EndIf
			oSection:Cell("VALTOT"):SetValue(aArray[nX][06])
			oSection:Cell("PERCENT"):SetValue(aArray[nX][07])
			oSection:Cell("VALTOT"):Show()
			oSection:Cell("PERCENT"):Show()
			If apar[05] <> 1
				If nX < nPosForm-1
					oSection:Cell("VALUNI2"):SetValue(Round(ConvMoeda(dDataBase,,nValUnit/nCotacao,Str(apar[05],1)), nDecimal))
					oSection:Cell("VALUNI2"):Show()
				Else
					oSection:Cell("VALUNI2"):Hide()
				EndIf
				oSection:Cell("VALTOT2"):SetValue(ConvMoeda(dDataBase,,(aArray[nX][06]/nCotacao),Str(apar[05],1)))
				oSection:Cell("VALTOT2"):Show()
			EndIf	
		EndIf
		If aArray[nX][04] == Replicate("-",15) .Or. nX >= nPosForm-1
			oSection:Cell("B1_UM"):Hide()
			oSection:Cell("QUANT"):Hide()
			oSection:Cell("VALUNI"):Hide()
		Else
			oSection:Cell("B1_UM"):Show()
			oSection:Cell("QUANT"):Show()
			oSection:Cell("VALUNI"):Show()
			cOldAlias:=Alias()
			dbSelectArea("SB1")
			nOrder:=IndexOrd()
			nRecno:=Recno()
			dbSetOrder(1)
			dbSeek(xFilial()+aArray[nX][04])
			oSection:Cell("B1_UM"):SetValue(SB1->B1_UM)
			dbSetOrder(nOrder)
			dbGoTo(nRecno)
			dbSelectArea(cOldAlias)
			oSection:Cell("QUANT"):SetValue(aArray[nX][05])
			oSection:Cell("VALUNI"):SetValue(nValUnit)
		EndIf

		oSection:PrintLine()

		If nX == 1 .And. apar[04] == 2
			nX += (nPosForm-3)
		EndIf
	EndIf
Next
If !lFirst
	oReport:ThinLine()
EndIf	

Return NIL
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MR430Plan � Autor � Eveli Morasco         � Data � 30/03/93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se a Planilha escolhida existe                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR430                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static function MR430Plan(lGravado,aPar)
Local cArq := ""     
Local lRet := .T.
DEFAULT lGravado:=.F.
cArq:=AllTrim(If(lGravado,apar[03],&(ReadVar())))+".PDV"
If !File(cArq)
	Help(" ",1,"MR430NOPLA")
	lRet := .F.
EndIf
Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AjustaSX1    �Autor � Ricardo Berti        �Data�07/07/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ajusta perguntas do SX1                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AjustaSX1()

//Local aHelpPor	:= {}
//Local aHelpEng	:= {}
//Local aHelpSpa	:= {}
Local aArea		:=GetArea()
Local nTamSX1
Local nTamCONOME := TamSX3("CO_NOME")[1]
/*
//-----------------------MV_PAR09--------------------------//
Aadd( aHelpPor, "Identifica se a montagem da composicao  " )
Aadd( aHelpPor, "do produto deve ser feita pela estrutura" )
Aadd( aHelpPor, " ou pela pre-estrutura.                 " )

Aadd( aHelpEng, "Identifies if the product composition   " )
Aadd( aHelpEng, "preparation must be made by the         " )
Aadd( aHelpEng, "structure or by the pre-structure.      " )

Aadd( aHelpSpa, "Identifica si el montaje de composicion " )
Aadd( aHelpSpa, "del producto debe ser hecha por la      " )
Aadd( aHelpSpa, "estructura o por la pre-estructura.     " )

PutSX1("MTR430","09","Mostra ?","�Muestra?","Show?","mv_ch9","N",1,0,1,"C","","","","N","mv_par09",;
"Estrutura","Estructura","Structure","","Pre-Estrutura","Estructura Previa","Previous Structure","","","","","","","","","")

PutSX1Help("P.MTR43009.",aHelpPor,aHelpEng,aHelpSpa)	 
*/

_cPerg     := "MTR430"
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := "Estrutura"
_cDef02   := "Pre-Estrutura"
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Identifica se a montagem da composicao do produto deve ser feita pela estrutura ou pela pre-estrutura."     
U_RGENA001(_cPerg, "09","Mostra ?", "MV_PAR09", "mv_ch9", "N", 1, 0, "C",_cValid,_cF3,_cPicture,_cDef01,_cDef02,_cDef03,_cDef04,_cDef05,_cHelp)

/*
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}

//-----------------------MV_PAR10--------------------------//
Aadd( aHelpPor, "Informar a Revisao da Estrutura do      " )
Aadd( aHelpPor, "Produto                                 " )
      
Aadd( aHelpEng, "Enter the Product Structure Revision    " )

Aadd( aHelpSpa, "Informe la Revision de la Estructura del" )
Aadd( aHelpSpa, "Producto                                " )

PutSX1("MTR430","10","Qual Revisao da Estrutura ?","�Que Revis.Estruct. ?","Structure Revision ?","mv_chA","C",TamSX3("B1_REVATU")[1],0,0,"G","","",;
"","N","mv_par10","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
*/

_cPerg    := "MTR430"
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := ""
_cDef02   := ""
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Informar a Revisao da Estrutura do Produto."     
U_RGENA001(_cPerg, "10","Mostra ?", "MV_PAR10", "mv_cha", "C", TamSX3("B1_REVATU")[1], 0, "G",_cValid,_cF3,_cPicture,_cDef01,_cDef02,_cDef03,_cDef04,_cDef05,_cHelp)

_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
dbSelectArea(_cAliasSX1)
(_cAliasSX1)->(dbSetOrder(1))
nTamSX1 := Len((_cAliasSX1)->X1_GRUPO)
If dbSeek(PADR("MTR430",nTamSX1)+"06",.F.)
	If X1_TAMANHO < 3
		RecLock((_cAliasSX1),.F.)
		(_cAliasSX1)->X1_TAMANHO := 3
		(_cAliasSX1)->X1_CNT01   := "999"
		MsUnlock()
	EndIf
EndIf

// Nome da planilha
If DbSeek(PADR("MTR430",nTamSX1)+"03",.F.)
	If X1_TAMANHO <> nTamCONOME
		RecLock(_cAliasSX1,.F.)
		(_cAliasSX1)->X1_TAMANHO := nTamCONOME
		MsUnlock()
	EndIf
EndIf

RestArea(aArea)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MC010Forma� Autor � Eveli Morasco         � Data � 22/06/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Mostra toda estrutura de um item selecionado com todos seus���
���          � custos , permitindo simulacoes diversas                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MC010Forma(ExpC1,ExpN1,ExpN2,ExpN3,ExpN4,ExpL1,ExpC2)      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada. Se neste campo estiver���
���          �         o valor 99 , significa que esta funcao foi chamada ���
���          �         pela rotina de impressao da planilha (MATR430) ,se ���
���          �         estiver o valor 98 ,significa que foi chamada pela ���
���          �         rotina de atualizacao de precos (MATA420)          ���
���          � ExpN3 = Quantidade Basica (Somente ExpN2 == 99)            ���
���          � ExpN4 =                                                    ���
���          � ExpL1 = Exibir mensagem de processamento                   ���
���          � ExpC2 = Revisao passada pelo MATR430		                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATC010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MC010Forma(cAlias,nReg,nOpcx,nQtdBas,nTipo,lMostra,cRevExt)
Local nSavRec,cPictQuant,nX,cArq:=Trim(cArqMemo)+".PDV", cPictVal, cOpc
Local nUltNivel,cProduto,nMatPrima,nQuant := nNivel := 1
Local nTamReg:=143,nHdl1,nTamArq,nRegs,cBuffer,cLayout,nIni,nFim,nY,nDif,aFormulas:={}
Local cTitulo,aPreco, nTamDif
Local xIdent, xNivel, xDesc, xCod, xQuant, xCusto, xPart, xAlt, xTipo, xDigit, xSz
Local nOrder:=IndexOrd()
Local cNivInv
Local nTamFormula
Local i := 0
Local nQuantPe := 1
Local aMC010Alt := {}

PRIVATE aInv:={} //Array usado para calculo do custo de reposicao
PRIVATE nOldCusto:=nQualcusto
PRIVATE cProdPai:=""

DEFAULT nTipo   := 1
DEFAULT lMostra := .T.
DEFAULT cRevExt := ""

//�����������������������������������������������������������������Ŀ
//� Funcao utilizada para verificar a ultima versao do fonte		�
//� SIGACUSB.PRX aplicado no rpo do cliente, assim verificando		|
//| a necessidade de uma atualizacao neste fonte. NAO REMOVER !!!	�
//�������������������������������������������������������������������
If !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20090204)
	Final("Atualizar SIGACUSB.PRX !!!")
EndIf

dbSetOrder(1)	// Ordem correta para montar a estrutura
aArray := {}
aHeader:={}
aTotais:={}


If nQualcusto == 8 
	cArqMemo := "STANDARD"
	cArq := Trim(cArqMemo)+".PDV"
	nQualCusto := 1
EndIf

If nOpcx >= 90
	//����������������������������������������������������������������Ŀ
	//� Esta variavel devera' ficar com .F. quando esta funcao for cha-�
	//� mada de um programa que nao seja a propria consulta. Ela inibi-�
	//� ra' as mensagens de help.                                      �
	//������������������������������������������������������������������
	lExibeHelp := .F.
	lConsNeg := If(nOpcx = 98 .or. Type("lConsNeg") # "L", .T., lConsNeg)
Else
	lConsNeg := mv_par03 = 1
EndIf

//��������������������������������������������������������������Ŀ
//� Verifica se existe algum dado no arquivo                     �
//����������������������������������������������������������������
dbSelectArea( cAlias )
If RecCount() == 0
	Return .T.
EndIf

If cAlias <> "SB1"
	dbSelectArea("SB1")
Endif	
//��������������������������������������������������������������Ŀ
//� Verifica se esta' na filial correta                          �
//����������������������������������������������������������������
If cFilial != SB1->B1_FILIAL
	Help(" ",1,"A000FI")
	Return .T.
EndIf

//����������������������������������������������������������������Ŀ
//� Tenta abrir o arquivo de memorias de calculo                   �
//������������������������������������������������������������������
nHdl1 := FOpen(cArq,FO_READWRITE+FO_SHARED)
If nHdl1 < 0
	Help(" ",1,"MC010FORMU")
	Return .T.
EndIf

//������������������������������������������������������������������Ŀ
//� Pega a primeira posicao do arquivo que identifica o NOVO Lay-Out �
//��������������������������������������������������������������������
FSeek(nHdl1,0,0)
cLayout := Space(1)
Fread(nHdl1,@cLayout,1)

If .Not. (cLayout == "P")
	If .Not. (cLayout == "N")
		nHdl1 := MC010Conv(nHdl1, cArq)
		If nHdl1 < 0
			Return .F.
		EndIf
	EndIf

	FSeek(nHdl1,0,0)
	cBuffer := Space(3)
	Fread(nHdl1,@cBuffer,3)
	cLayout := Left(cBuffer,1)
	If Val(Right(cBuffer,1)) < 8  // So' ha' conversao para layout "P" caso nao seja arq. binario
		nHdl1 := MC010ConvP(nHdl1, cArq)
		If nHdl1 < 0
			Return .F.
		EndIf
	EndIf
EndIf

//����������������������������������������������������������������Ŀ
//� Pega o tamanho do arquivo e o numero de registros              �
//������������������������������������������������������������������
nTamArq := Fseek(nHdl1,0,2)
nRegs   := Int((nTamArq-5)/nTamReg)

//�����������������������������������������������������������������������Ŀ
//� Pega a segunda posicao do arquivo que identifica a direcao do calculo �
//�������������������������������������������������������������������������
Fseek(nHdl1,0,0)
cBuffer := Space(2)
Fread(nHdl1,@cBuffer,2)
lDirecao := .T.
If Subst(cBuffer,2,1) == "1"
	lDirecao := .F.
EndIf

//�����������������������������������������������������������������������Ŀ
//� Pega a terceira posicao do arquivo que identifica o custo selecionado �
//�������������������������������������������������������������������������
cBuffer := Space(1)
Fread(nHdl1,@cBuffer,1)
nQualCusto := Val(cBuffer)
nQualCusto := IIf(cArqMemo = "PRECO_FUTURO",6,nQualCusto) //07/10/2024 - Diego Rodrigues - Adequa��o para atender ao processo de pre�o futuro dos custos
If nQualCusto < 1 .Or. nQualCusto > 8
	nQualCusto := 1
EndIf

//����������������������������������������������������������������������Ŀ
//� Pega a 4a e a 5a posicao do arquivo para identificar quantas linhas  �
//� de totais existem na planilha.                                       �
//������������������������������������������������������������������������
cBuffer := Space(2)
Fread(nHdl1,@cBuffer,2)
nQtdTotais := Val(cBuffer)

//��������������������������������������������������������������Ŀ
//� Inicializa o nome do custo                                   �
//����������������������������������������������������������������
If nQualCusto     == 1
	cCusto := "STANDARD"
ElseIf nQualCusto == 2
	cCusto := "MEDIO "+MV_MOEDA1
ElseIf nQualCusto == 3
	cCusto := "MEDIO "+MV_MOEDA2
ElseIf nQualCusto == 4
	cCusto := "MEDIO "+MV_MOEDA3
ElseIf nQualCusto == 5
	cCusto := "MEDIO "+MV_MOEDA4
ElseIf nQualCusto == 6
	//cCusto := "MEDIO "+MV_MOEDA5
	cCusto := "PRECO_FUTURO"	//07/10/2024 - Diego Rodrigues - Adequa��o para atender ao processo de pre�o futuro dos custos
ElseIf nQualCusto == 7
	cCusto := "ULT PRECO"
ElseIf nQualCusto == 8
	cCusto := "PLANILHA"
EndIf

//��������������������������������������������������������������Ŀ
//� Recupera a tela de formacao de precos                        �
//����������������������������������������������������������������

cTitulo := " Planilha "+cArqMemo+" - Custo "+cCusto+" "
nSavRec := RecNo()
If nQualCusto < 8
	//�������������������������������������������������������������Ŀ
	//� Recuperacao padrao de arquivos                              �
	//���������������������������������������������������������������
	cProduto  := SB1->B1_COD
	cProdPai  := SB1->B1_COD

	//�������������������������������������������������������������Ŀ
	//� Trabalha com a Quantidade Basica do mv_par07 (MATR430)      �
	//���������������������������������������������������������������
	If nOpcx==99 .Or. nTipo == 2
		nQuant := nQtdBas
	EndIf
	//�������������������������������������������������������������Ŀ
	//� Ponto de Entrada para manipular a quantidade basica         �
	//���������������������������������������������������������������	
	If (ExistBlock('MC010QTD'))
		nQuantPe := ExecBlock('MC010QTD',.F.,.F.,{SB1->B1_COD})
		If ValType(nQuantPe) == "N" 
			nQuant := nQuantPe
		Endif
	Endif		

	//��������������������������������������������������������������Ŀ
	//� Adiciona o primeiro elemento da estrutura , ou seja , o Pai  �
	//����������������������������������������������������������������
	AddArray(nQuant,nNivel,.F.,.T.,NIL)
	AAdd(aInv,{SB1->B1_COD,"100",1,0,0,"0",Len(aInv)+1})
	If mv_par12 == 1
		cOpc := SeleOpc(4,"MATC010",SB1->B1_COD,,,,,,nQuant,dDataBase,If(Empty(mv_par04),SB1->B1_REVATU,mv_par04),mv_par09==2)
	Else
		cOpc := RetFldProd(SB1->B1_COD,"B1_OPC")
	EndIf
	If lMostra	
		MsAguarde( {|lEnd| MontStru(cProduto,nQuant,nNivel+1,cOpc,If(nOpcx==99,If(Empty(cRevExt),SB1->B1_REVATU,cRevExt),If(Empty(mv_par04),SB1->B1_REVATU,mv_par04))) }, ;
		"STR0012", "STR0013", .F. )
	Else
		MontStru(cProduto,nQuant,nNivel+1,cOpc,If(nOpcx==99,If(Empty(cRevExt),SB1->B1_REVATU,cRevExt),If(Empty(mv_par04),SB1->B1_REVATU,mv_par04)),,lMostra,cRevExt)
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Validacao utilizada para nao permitir B1_TIPO = 'SE', porque �
	//� 'SE' e uma palavra reservada utilizada nas formulas.		 �
	//����������������������������������������������������������������
	For nX:= 1 to Len(aArray)
		If aArray[nX,9] $ "SE"
			Aviso("MATC010","STR0010"+"STR0011",{"Ok"})
			Return (.F.)
		EndIf
	Next nX

	//����������������������������������������������������������Ŀ
	//� ExecBlock Para Inserir Elementos na Estrutura - MC010Add �
	//� Retorno: 1 - Nivel (C/6)                                 �
	//�          2 - Codigo (C/6)                                �
	//�          3 - Descricao (C/50)                            �
	//�          4 - Quantidade (N)                              �
	//�          5 - Tipo do Produto (C/2)                       �
	//�          6 - G1_TRT - Sequencia (C/3)                    �
	//�          7 - "F"ixo ou "V"ariavel                        �
	//������������������������������������������������������������
	If (ExistBlock('MC010ADD'))
		aMC010Add := ExecBlock('MC010ADD',.F.,.F.,cProduto)
		If ValType(aMC010Add) == "A" .And. (Len(aMC010Add)>0)
			For nX := 1 To Len(aMC010Add)
				AAdd(aArray, { Len(aArray)+1,;
									aMC010Add[nX][1],;						// 1 - Nivel
									SubStr(aMC010Add[nX][3],1,38),;	 	// 3 - B1_DESC
									aMC010Add[nX][2],;						// 2 - B1_COD
									aMC010Add[nX][4],;						// 4 - Quantidade
									0,;
									0,;
									.T.,;
									aMC010Add[nX][5],;						// 5 - B1_TIPO
									.F.,;
									aMC010Add[nX][6],;						// 6 - G1_TRT
									IIF(Subs(cAcesso,39,1) != "S",.F.,.T.),;
									aMC010Add[nX][7]})						// 7 - G1_FIXVAR
			Next
		EndIf
	EndIf
	// Ponto de entrada para permitir altera��o na estrutura do produto atrav�s do array aArray
	If (ExistBlock('MC010ALT'))
		aMC010Alt := ExecBlock ('MC010ALT',.F.,.F.,{aArray})
		If ValType(aMC010Alt) == "A"
			aArray := aClone(aMC010Alt)
		EndIf
	EndIf                      

	//��������������������������������������������������������������Ŀ
	//� Este vetor (aAuxCusto) deve ser declarado somente no MATR430 �
	//����������������������������������������������������������������
	If nOpcx==99
		aAuxCusto := Array(Len(aArray))
		AFill(aAuxCusto, 0)
	EndIf

	cPictQuant := x3Picture(If(mv_par09==1,"G1_QUANT","GG_QUANT"))
	If Subs(cPictQuant,1,1) == "@"
		cPictQuant := Subs(cPictQuant,1,1)+"Z"+Subs(cPictQuant,2,Len(cPictQuant))
	Else
		cPictQuant := "@Z "+cPictQuant
	EndIf

	If nQualCusto     == 2
		cPictVal := x3Picture('B2_CM1')
	ElseIf nQualCusto == 3
		cPictVal := x3Picture('B2_CM2')
	ElseIf nQualCusto == 4
		cPictVal := x3Picture('B2_CM3')
	ElseIf nQualCusto == 5
		cPictVal := x3Picture('B2_CM4')
	ElseIf nQualCusto == 6
		//cPictVal := x3Picture('B2_CM5')
		cPictVal := x3Picture('B1_FATLUC') //07/10/2024 - Diego Rodrigues - Adequa��o para atender ao processo de pre�o futuro dos custos
	ElseIf nQualCusto == 7
		cPictVal := x3Picture('B1_UPRC')
	Else
		cPictVal := x3Picture('B1_CUSTD')
	EndIf

	If Subs(cPictVal,1,1) == "@"
		cPictVal := Subs(cPictVal,1,1)+"Z"+Subs(cPictVal,2,Len(cPictVal))
	Else
		cPictVal := "@Z "+cPictVal
	EndIf
	AAdd(aHeader,{"Cel"	       , "99999"})
	AAdd(aHeader,{"Niv" 	   , "@9" })
	AAdd(aHeader,{"Descri��o"  , "@X" })
	AAdd(aHeader,{"Codigo"	   , "@!" })
	AAdd(aHeader,{"Quantd"	   , cPictQuant })
	AAdd(aHeader,{"Valor Total", cPictVal })
	AAdd(aHeader,{"%Part"      , "@Z 999.99" })

	AAdd(aArray,{   (Len(aArray)+1),;
					"------",;
					Replicate("-",30),;
					Replicate("-",Len(SB1->B1_COD)),;
					0,0,0,.F.,"  ",.F.," ",.T.," " } )  

	//��������������������������������������������������������������Ŀ
	//� Define a primeira linha com formulas                         �
	//����������������������������������������������������������������
	nMatPrima := Len(aArray)+1

	For nX := 1 To nQtdTotais
		cBuffer := Space(nTamReg)
		Fread(nHdl1,@cBuffer,nTamReg)
		AAdd(aTotais,SubStr(cBuffer,36,100))
		AAdd(aArray, { Len(aArray)+1,"------",;
		SubStr(cBuffer,6,30),;
		Replicate(".",Len(SB1->B1_COD)),0,0,0,.F.,"MP",.F.," ",.T.," " } )
	Next nX

	AAdd(aArray,{  Len(aArray)+1,;
					"------",;
					Replicate("-",30),;
					Replicate("-",Len(SB1->B1_COD)),;
					0,0,0,.F.,"  ",.F.," ",.T.," " } )

	//��������������������������������������������������������������Ŀ
	//� Le as formulas do arquivo (PDV)                              �
	//����������������������������������������������������������������
	nQtdFormula := nRegs-nQtdTotais
	For nX := 1 To nQtdFormula
		cBuffer := Space(nTamReg)
		Fread(nHdl1,@cBuffer,nTamReg)
		If nDif == NIL
			nDif := nMatPrima - (Val(SubStr(cBuffer,1,5)) - (nQtdTotais+1))
		EndIf
		AAdd(aFormulas,{SubStr(cBuffer,36,100),Substr(cBuffer,136,6)})
		If AT("#",aFormulas[nX,1]) > 0
			nTamFormula := Len(aFormulas[nX,1])
			For nY := 1 To Len(aFormulas[nX,1])
				If SubStr(aFormulas[nX,1],nY,1) == "#"
					nFim := nIni := nY+1
					While (IsDigit(SubStr(aFormulas[nX,1],nFim,1)))
						nFim++
					EndDo
					cNum := AllTrim(Str(Val(SubStr(aFormulas[nX,1],nIni,nFim-nIni))+nDif,5))
					aFormulas[nX,1]:=SubStr(aFormulas[nX,1],1,nIni-1)+cNum+SubStr(aFormulas[nX,1],nFim)
					//Ajusta Tamanho do Campo para 100 posicoes.
					If Len(aFormulas[nX,1]) < 100
						nTamDif := 100 - len(aFormulas[nX,1])
						aFormulas[nX,1] := aFormulas[nX,1] + Space(nTamDif)
					ElseIf Len(aFormulas[nX,1]) > 100
						aFormulas[nX,1] := Substr(aFormulas[nX,1],1,100)
					EndIf
				EndIf
			Next nY
		EndIf
		If AT("#",aFormulas[nX,2]) > 0
			nTamFormula := Len(aFormulas[nX,2])
			For nY := 1 To Len(Trim(aFormulas[nX,2]))
				If SubStr(aFormulas[nX,2],nY,1) == "#"
					nFim := nIni := nY+1
					While (IsDigit(SubStr(aFormulas[nX,2],nFim,1)))
						nFim++
					EndDo
					cNum := AllTrim(Str(Val(SubStr(aFormulas[nX,2],nIni,nFim-nIni))+nDif,5))
					aFormulas[nX,2]:=SubStr(aFormulas[nX,2],1,nIni-1)+cNum+SubStr(aFormulas[nX,2],nFim)
					aFormulas[nx,2]:=aFormulas[nx,2]+Space(6-Len(aFormulas[nx,2]))
					//Ajusta Tamanho do Campo para 6 posicoes.
					If Len(aFormulas[nX,2]) < 6
						nTamDif := 6 - len(aFormulas[nX,2])
						aFormulas[nX,2] := aFormulas[nX,2] + Space(nTamDif)
					ElseIf Len(aFormulas[nX,2]) > 6
						aFormulas[nX,2] := Substr(aFormulas[nX,2],1,6)
					EndIf
				EndIf
			Next nY
		EndIf
		AAdd(aArray, { Len(aArray)+1,"------",;
		SubStr(cBuffer,6,30),;
		Replicate(".",Len(SB1->B1_COD)),0,0,0,.T.,"  ",.F.," ",.T.," " } )
	Next nX

	//FClose(nHdl1)

	AAdd(aArray, { Len(aArray)+1,;
					"------",;
					Replicate("-",30),;
					Replicate("-",Len(SB1->B1_COD)),;
					0,0,0,.F.,"  ",.F.," ",.T.," " } )
Else
	//��������������������������������������������������Ŀ
	//� Recuperacao de Arquivos tipo PLANILHA            �
	//����������������������������������������������������
	cBuffer := Space(2)
	FRead(nHdl1,@cBuffer,2)
	nLen := Bin2I(cBuffer)

	//��������������������������������������������������Ŀ
	//� Montagem do array aArray                         �
	//����������������������������������������������������
	For i:= 1 To nLen
		cBuffer := Space(2)
		FRead(nHdl1,@cBuffer,2)
		xIdent := Bin2I(cBuffer)
		xNivel := Space(6)
		FRead(nHdl1,@xNivel,6)

		cBuffer := Space(2)
		FRead(nHdl1,@cBuffer,2)
		xSz := Bin2I(cBuffer)
		xDesc := Space(xSz)
		FRead(nHdl1,@xDesc,xSz)

		cBuffer := Space(2)
		FRead(nHdl1,@cBuffer,2)
		xSz := Bin2I(cBuffer)
		xCod := Space(xSz)
		FRead(nHdl1,@xCod,xSz)

		cBuffer := Space(2)
		FRead(nHdl1,@cBuffer,2)
		xSz := Bin2I(cBuffer)

		cBuffer := Space(xSz)
		FRead(nHdl1,@cBuffer,xSz)
		xQuant := Val(cBuffer)

		cBuffer := Space(2)
		FRead(nHdl1,@cBuffer,2)
		xSz := Bin2I(cBuffer)
		cBuffer := Space(xSz)
		FRead(nHdl1,@cBuffer,xSz)
		xCusto := Val(cBuffer)
		cBuffer := Space(2)
		FRead(nHdl1,@cBuffer,2)
		xSz := Bin2I(cBuffer)
		cBuffer := Space(xSz)
		FRead(nHdl1,@cBuffer,xSz)
		xPart := Val(cBuffer)
		cBuffer := Space(1)
		FRead(nHdl1,@cBuffer,1)
		xAlt := if(cBuffer=="T",.T.,.F.)
		cBuffer := Space(2)
		FRead(nHdl1,@cBuffer,2)
		xSz := Bin2I(cBuffer)
		xTipo := Space(xSz)
		FRead(nHdl1,@xTipo,xSz)
		cBuffer := Space(1)
		FRead(nHdl1,@cBuffer,1)
		xDigit := if(cBuffer=="T",.T.,.F.)
		AAdd(aArray,{xIdent,xNivel,xDesc,xCod,xQuant,xCusto,xPart,xAlt,xTipo,xDigit,criavar(If(mv_par09==1,"G1_TRT","GG_TRT")), (Subs(cAcesso,39,1)=='S'), CriaVar(If(mv_par09==1,"G1_FIXVAR","GG_FIXVAR"))})
		If xNivel != Replicate("-",Len(xNivel))
			cNivInv:=StrZero(101-Val(Alltrim(xNivel)),3,0)
			AAdd(aInv,{xCod,cNivInv,xQuant,xCusto,0,"0",Len(aInv)+1})
		EndIf
	Next
	cBuffer := Space(2)
	FRead(nHdl1,@cBuffer,2)
	nMatPrima := Bin2I(cBuffer)

	//��������������������������������������������������Ŀ
	//� Monta o array aTotais                            �
	//����������������������������������������������������
	cBuffer := Space(2)
	FRead(nHdl1,@cBuffer,2)
	nLen := Bin2I(cBuffer)
	For i:= 1 To nLen
		cBuffer := Space(100)
		FRead(nHdl1,@cBuffer,100)
		AAdd(aTotais,cBuffer)
	Next
	//��������������������������������������������������Ŀ
	//� Monta o array aFormulas                          �
	//����������������������������������������������������
	cBuffer := Space(2)
	FRead(nHdl1,@cBuffer,2)
	nLen        := Bin2I(cBuffer)
	nQtdFormula := nLen
	For i:= 1 To nLen
		cBuffer := Space(If(cLayout=="P",106,105))
		FRead(nHdl1,@cBuffer,If(cLayout=="P",106,105))
		If cLayout=="P"
			AAdd(aFormulas,{Left(cBuffer,100), Right(cBuffer,6)})
		Else
			AAdd(aFormulas,{Left(cBuffer,100), Right(cBuffer,5)+" "})
		EndIf
	Next

	//��������������������������������������������������Ŀ
	//� Montagem do array aHeader                        �
	//����������������������������������������������������
	cPictQuant := x3Picture(If(mv_par09==1,"G1_QUANT","GG_QUANT"))
	If Subs(cPictQuant,1,1) == "@"
		cPictQuant := Subs(cPictQuant,1,1)+"Z"+Subs(cPictQuant,2,Len(cPictQuant))
	Else
		cPictQuant := "@Z "+cPictQuant
	EndIf

	If nQualCusto     == 2
		cPictVal := x3Picture('B2_CM1')
	ElseIf nQualCusto == 3
		cPictVal := x3Picture('B2_CM2')
	ElseIf nQualCusto == 4
		cPictVal := x3Picture('B2_CM3')
	ElseIf nQualCusto == 5
		cPictVal := x3Picture('B2_CM4')
	ElseIf nQualCusto == 6
		//cPictVal := x3Picture('B2_CM5')
		cPictVal := x3Picture('B1_FATLUC')  //07/10/2024 - Diego Rodrigues - Adequa��o para atender ao processo de pre�o futuro dos custos
	ElseIf nQualCusto == 7
		cPictVal := x3Picture('B1_UPRC')
	Else
		cPictVal := x3Picture('B1_CUSTD')
	EndIf

	If Subs(cPictVal,1,1) == "@"
		cPictVal := Subs(cPictVal,1,1)+"Z"+Subs(cPictVal,2,Len(cPictVal))
	Else
		cPictVal := "@Z "+cPictVal
	EndIf

	AAdd(aHeader,{"Cel"	, "99999"	})
	AAdd(aHeader,{"Niv"	, "@9" })
	AAdd(aHeader,{"Descri��o"	, "@X" })
	AAdd(aHeader,{"Codigo"	, "@!" })
	AAdd(aHeader,{"Quantd"	, cPictQuant })
	AAdd(aHeader,{"Valor Total"	, cPictVal })
	AAdd(aHeader,{"%Part"	, "@Z 999.99" })

	//��������������������������������������������������������������Ŀ
	//� Este vetor (aAuxCusto) deve ser declarado somente no MATR430 �
	//����������������������������������������������������������������
	If nOpcx==99
		aAuxCusto := Array(Len(aArray))
		AFill(aAuxCusto, 0)
	EndIf

EndIf

FClose(nHdl1)

nUltNivel := CalcUltNiv()
CalcTot(nMatPrima,nUltNivel,aFormulas,, nOpcx)
RecalcTot(nMatPrima)
CalcForm(aFormulas,nMatPrima)

If nOpcx < 90 .Or. nTipo == 2
	Browplanw(nMatPrima,@aFormulas,nTipo)
EndIf

If nOpcx == 99
	aPreco := {cCusto,aArray,nMatPrima}
	Return (aPreco)
ElseIf nOpcx == 98
	Return aArray
EndIf
dbSelectArea(cAlias)
dbSetOrder(nOrder)
dbGoTo(nSavRec)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� DATA   � BOPS �Prograd.�ALTERACAO                                     ���
�������������������������������������������������������������������������Ĵ��
���22.12.98�MELHOR�Bruno   �Modificacao do array de retorno do MC010Form()���
���        �      �        �(aumento do string da descricao do produto).  ���
���30.04.99�21387A�Fernando�Montar corretamente o aArray quando o PDV for ���
���        �      �        �do tipo PLANILHA.                             ���
���02.07.99�18443A�Fernando� Utilizar a Picture de Valores correta.       ���
���22/07/99�22152A�CesarVal�Passar mv_par07 (QtdBas) p/ Mc010Forma().     ���
���        �      �        �Somente Quando de (MATR430).                  ���
���30/08/99�21448A�CesarVal�Fazer a inversao do calculo do Valor          ���
���        �      �        �Unitario com o maximo de casas decimais.      ���
���        �      �        �Somente Quando de (MATR430).                  ���
���13/10/99�22282A�CesarVal�Novo Lay-Out com Celula Percentual com 4      ���
���        �      �        �Digitos e Formula com 100 Caracteres.         ���
���02/01/00�  2082�CesarVal�Inclusao do P.E. MC010ADD P/ Inserir Elementos���
���        �      �        �Na Estrutura do Produto.                      ���
���23/08/00�  5742�Iuspa   �Var lConsNeg Considera/nao quant neg estrutura���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Descri��o � PLANO DE MELHORIA CONTINUA                    MATC010X.PRX ���
�������������������������������������������������������������������������Ĵ��
���ITEM PMC  � Responsavel              � Data       � BOPS               ���
�������������������������������������������������������������������������Ĵ��
���      01  �Marcos V. Ferreira        �03/08/2006  �00000100434         ���
���      02  �Flavio Luiz Vicco         �26/04/2006  �00000097637         ���
���      03  �                          �            �                    ���
���      04  �                          �            �                    ���
���      05  �Marcos V. Ferreira        �03/08/2006  �00000100434         ���
���      06  �Nereu Humberto Junior     �14/08/2006  �00000098126         ���
���      07  �Nereu Humberto Junior     �14/08/2006  �00000098126         ���
���      08  �                          �            �                    ���
���      09  �                          �            �                    ���
���      10  �Flavio Luiz Vicco         �26/04/2006  �00000097637         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   � MontStru � Autor � Ary Medeiros          � Data � 19/10/93 ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o� Monta um array com a estrutura do produto                  ���
�������������������������������������������������������������������������Ĵ��
��� Sintaxe  � MontStru(ExpC1,ExpN1,ExpN2,ExpC2,ExpC3,ExpL1,ExpL2,ExpC4)  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo do produto a ser explodido                  ���
���          � ExpN1 = Quantidade base a ser explodida                    ���
���          � ExpN2 = Contador de niveis da estrutura                    ���
���          � ExpC2 = String com os opcionais default do produto pai     ���
���          � ExpC3 =                                                    ���
���          � ExpL1 =                                                    ���
���          � ExpL2 = Exibir mensagem de processamento                   ���
���          � ExpC4 = Revisao passada pelo MATR430                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATC010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MontStru(cProduto,nQuant,nNivel,cOpcionais,cRevisao,lSomouComp,lMostra,cRevExt)
Local nReg,nQuantItem, lAcesso := .T.,cRoteiro:=""
Local lRel        :=If(cProg$"R430A420",.T.,.F.)
Local aArea       :=GetArea()
Local aAreaSG2    :=SG2->(GetArea())
Local aAreaSB1    :=SB1->(GetArea())
Local aAreaSH1    :=SH1->(GetArea())
Local lOkExec     :=ExistBlock("MC010PR")
Local nRetorno    :=0
Local nPosOri     :=0,nPosOriInv:=0
Local lPassaComp  :=.F.
Local cWhile      :=IF(mv_par09==1,"G1_FILIAL+G1_COD","GG_FILIAL+GG_COD")
Local cAliasWhile :=IF(mv_par09==1,"SG1","SGG")
Local cAliasComp  :=""
Local cAliasCod   :=""
Local cAliasTRT   :=""
Local cAliasNivInv:=""
Local cProdMod    :=""
Local lMc010Est   :=ExistBlock("MC010EST")
Local lRetPE      := .T.
Local lFilSG2     := .F.

Static nI := 0

PRIVATE cTipoTemp	:=SuperGetMV("MV_TPHR")

DEFAULT lMostra := .T.
DEFAULT cRevExt := ""

lAcesso   :=IIf(Subs(cAcesso,39,1) != "S",.F.,.T.) // Forma��o de pre�os todos n�veis
cRevisao  :=IIf(cRevisao==NIL,"",cRevisao)
cOpcionais:=IIf(cOpcionais==NIL,"",cOpcionais)

//�������������������������������Ŀ
//� - Messagem de Processamento - �
//���������������������������������
If lMostra
	nI := (nI+1) % 4
	MsProcTxt("STR0013"+Replicate(".",nI+1))
	ProcessMessage()
EndIf

//���������������������������������������������������������Ŀ
//� Posiciona no produto desejado                           �
//�����������������������������������������������������������
dbSelectArea(cAliasWhile)
dbSeek(cFilial+cProduto)

//�������������������������������������������������Ŀ
//� Verifica se o produto MOD deve ser considerado  �
//� do roteiro de operacoes.                        �
//���������������������������������������������������
If mv_par05 == 2 .Or. mv_par05 == 3
	dbSelectArea("SB1")
	dbSetOrder(1)
	If dbSeek(xFilial("SB1")+cProduto)
		If !Empty(mv_par06)
			cRoteiro:=mv_par06
		ElseIf !Empty(SB1->B1_OPERPAD)
			cRoteiro:=SB1->B1_OPERPAD
		EndIf
		
		_lMCFILSG2 := ExistBlock('MCFILSG2')
		
		dbSelectArea("SG2")
		dbSetOrder(1)
		dbSeek(xFilial("SG2")+cProduto+If(Empty(cRoteiro),"01",cRoteiro))
		While !Eof() .And.	xFilial("SG2")+cProduto+If(Empty(cRoteiro),"01",cRoteiro) == G2_FILIAL+G2_PRODUTO+G2_CODIGO
            If _lMCFILSG2
  		   		lFilSG2 := ExecBlock("MCFILSG2",.F.,.F.,)
		   		If Valtype(lRetPE) == "L" .And. !lFilSG2
			   		dbSkip()
			   		Loop
		   		EndIf	
			EndIf
			dbSelectArea("SH1")
			dbSetorder(1)
			If dbSeek(xFilial("SH1")+SG2->G2_RECURSO)
				// Calcula Tempo de Dura��o baseado no Tipo de Operacao
				If SG2->G2_TPOPER $ " 1"
					nTemp := Round((nQuant * ( If(mv_par07 == 3,A690HoraCt(SG2->G2_SETUP) / IIf( SG2->G2_LOTEPAD == 0, 1, SG2->G2_LOTEPAD ), 0) + IIf( SG2->G2_TEMPAD == 0, 1,A690HoraCt(SG2->G2_TEMPAD)) / IIf( SG2->G2_LOTEPAD == 0, 1, SG2->G2_LOTEPAD ))+If(mv_par07 == 2, A690HoraCt(SG2->G2_SETUP), 0) ),5)
					If SH1->H1_MAOOBRA # 0
						nTemp :=Round( nTemp / SH1->H1_MAOOBRA,5)
					EndIf
				ElseIf SG2->G2_TPOPER == "4"
					nQuantAloc:=nQuant % IIf(SG2->G2_LOTEPAD == 0, 1, SG2->G2_LOTEPAD)
					nQuantAloc:=Int(nQuant)+If(nQuantAloc>0,IIf(SG2->G2_LOTEPAD == 0, 1, SG2->G2_LOTEPAD)-nQuantAloc,0)
					nTemp := Round(nQuantAloc * ( IIf( SG2->G2_TEMPAD == 0, 1,A690HoraCt(SG2->G2_TEMPAD)) / IIf( SG2->G2_LOTEPAD == 0, 1, SG2->G2_LOTEPAD ) ),5)
					If SH1->H1_MAOOBRA # 0
						nTemp :=Round( nTemp / SH1->H1_MAOOBRA,5)
					EndIf
				ElseIf SG2->G2_TPOPER == "2" .Or. SG2->G2_TPOPER == "3"
					nTemp := IIf( SG2->G2_TEMPAD == 0 , 1 ,A690HoraCt(SG2->G2_TEMPAD) )
				EndIf
				nTemp:=nTemp*If(Empty(SG2->G2_MAOOBRA),1,SG2->G2_MAOOBRA)
				//��������������������������������������������������Ŀ
				//� Posiciona no produto da Mao de Obra.             �
				//����������������������������������������������������
				cProdMod:=APrModRec(SH1->H1_CODIGO)
				SB1->(dbSetOrder(1))
				If SB1->(dbSeek(xFilial("SB1")+cProdMod))
					// Inclui componente no array
					AddArray(nTemp,nNivel,.F.,lAcesso,SG2->G2_OPERAC)
					AAdd(aInv,{	SB1->B1_COD,PADL(99,3,"0"),;
					nTemp,QualCusto(SB1->B1_COD),0,	"0",Len(aInv)+1,lAcesso})
					aArray[Len(aArray)][8]:=.T.
					aInv[Len(aInv),6]:= "1"
				EndIf
			EndIf
			dbSelectArea("SG2")
			dbSkip()
		End
	EndIf
	RestArea(aAreaSG2)
	RestArea(aAreaSB1)
	RestArea(aAreaSH1)
EndIf

If (cAliasWhile)->(Eof())
	aArray[1][8] := .T.
Else
	
	_xConsNeg := Type("lConsNeg")
	
	dbSelectArea(cAliasWhile)
	While !Eof() .And. &(cWhile) == cFilial+cProduto
		cAliasComp  :=If(mv_par09==1,SG1->G1_COMP,SGG->GG_COMP)
		cAliasCod   :=If(mv_par09==1,SG1->G1_COD,SGG->GG_COD)
		cAliasTRT   :=If(mv_par09==1,SG1->G1_TRT,SGG->GG_TRT)
		cAliasNivInv:=If(mv_par09==1,SG1->G1_NIVINV,SGG->GG_NIVINV)

		//���������������������������������������������������������Ŀ
		//� Funcao que devolve a quantidade utilizada do componente �
		//�����������������������������������������������������������
		nQuantItem := ExplEstr(nQuant,NIL,cOpcionais,cRevisao,NIL,mv_par09==2,mv_par10==1)
		If ALLTRIM(_xConsNeg) = "L" .And. (!lConsNeg) .and. QtdComp(nQuantItem,.T.) < QtdComp(0)
			dbSelectArea(cAliasWhile)
			dbSkip()
			Loop
		EndIf

		//�������������������������������������������������Ŀ
		//� Verifica se o produto MOD deve ser considerado  �
		//���������������������������������������������������
		If mv_par05 == 2 .And. IsProdMod(cAliasComp)
			dbSelectArea(cAliasWhile)
			dbSkip()
			Loop
		EndIf
		//����������������������������������������������������������������Ŀ
		//� Executa ponto de Entrada para filtrar componentes da estrutura �
		//������������������������������������������������������������������		
		If lMc010Est
			lRetPE := ExecBlock("MC010EST",.F.,.F.,{cAliasWhile,cAliasCod,cAliasComp})
			If Valtype(lRetPE) == "L" .And. !lRetPE
				dbSelectArea(cAliasWhile)
				dbSkip()
				Loop			
			Endif
		Endif
		//����������������������������������������Ŀ
		//� Posiciona SB1                          �
		//������������������������������������������
		dbSelectArea("SB1")
		dbSeek(cFilial+cAliasComp)

		dbSelectArea(cAliasWhile)
		//����������������������������������������Ŀ
		//� Executa P.E.                           �
		//������������������������������������������
		If (QtdComp(nQuantItem,.T.) == QtdComp(0)) .And. lOkExec	
			nRetorno:=ExecBlock("MC010PR",.F.,.F.,{cAliasCod,cAliasComp,cAliasTRT,nQuant,Recno()})
			If Valtype(nRetorno) == "N"
				nQuantItem:=nRetorno
			EndIf
		EndIf
		If (QtdComp(nQuantItem,.T.) != QtdComp(0))
			dbSelectArea(cAliasWhile)
			nReg := Recno()
			If SB1->B1_FANTASM $ " N" .Or. (SB1->B1_FANTASM == "S" .And. mv_par08 == 1)
				lSomouComp:=.T.
				AddArray(nQuantItem,nNivel,.F.,lAcesso,NIL)
				AAdd(aInv,{cAliasComp,;
				PADL(cAliasNivInv,3,"0"),;
				nQuantItem,;
				QualCusto(cAliasComp),;
				0,;
				"0",;
				Len(aInv)+1,;
				lAcesso			})
			EndIf
			//�������������������������������������������������Ŀ
			//� Verifica se o filho tem estrutura               �
			//���������������������������������������������������
			dbSeek(cFilial+cAliasComp)
			If Eof()
				aArray[Len(aArray)][8]:= .T.
				aInv[Len(aInv),6]	   := "1"
			Else
				nPosOri:=Len(aArray)
				nPosOriInv:=Len(aArray)
				lPassaComp:=.F.
				MontStru(cAliasComp,nQuantItem,nNivel+1,cOpcionais,If(lRel,If(Empty(cRevExt),SB1->B1_REVATU,cRevExt),If(Empty(mv_par04),SB1->B1_REVATU,mv_par04)),@lPassaComp,lMostra,cRevExt)
				If !lPassaComp
					aArray[nPosOri][8]:= .T.
					aInv[nPosOriInv,6]:= "1"
				EndIf
			EndIf
			dbGoTo(nReg)
		EndIf
		dbSkip()
	EndDo
EndIf
RestArea(aArea)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   � AddArray � Autor � Jorge Queiroz         � Data � 19/06/92 ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o� Adiciona um elemento ao Array                              ���
�������������������������������������������������������������������������Ĵ��
��� Sintaxe  � AddArray(ExpN1,ExpN2,ExpL1)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Quantidade da estrutura                            ���
���          � ExpN2 = Nivel do item                                      ���
���          � ExpL1 = Inicializa elemento 8 do aArray (aArray[n][8])     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATC010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AddArray(nQuantItem,nNivel,lAltera,lAcesso,cOperac)
Local cNivEstr
Local cAliasTRT   :=If(mv_par09==1,SG1->G1_TRT,SGG->GG_TRT)
Local cAliasFixVar:=If(mv_par09==1,SG1->G1_FIXVAR,SGG->GG_FIXVAR)
Local cDescProd   :=SB1->B1_DESC
                                                                                          
Default cOperac:=""

If (ExistBlock('MC010DES'))
	cDescProd := ExecBlock('MC010DES',.F.,.F.,{SB1->B1_COD})
	If ValType(cDescProd) <> "C" 
		cDescProd := SB1->B1_DESC
	Endif
Endif	

// Verifica o Nivel de Estrutura
If Empty(mv_par11) .Or. (mv_par11==0)
	mv_par11 := 999
EndIf

lAcesso :=If((lAcesso == NIL),.T.,lAcesso)
cNivEstr:=Space(IIf(nNivel<=5,nNivel-1,4))+LTRIM(STR(nNivel,2))
dbSelectArea(If(mv_par09==1,"SG1","SGG"))
If nNivel <= mv_par11
	AAdd(aArray, { Len(aArray)+1,;						//1
	               cNivEstr+Space(6-Len(cNivEstr)),;   //2
    	           SubStr(cDescProd,1,38),;				//3
        	       SB1->B1_COD,;						//4
            	   nQuantItem,;							//5
	               0,;									//6
    	           0,;									//7
        	       lAltera,;							//8
            	   SB1->B1_TIPO,;						//9
	               .F.,;								//10
    	           cAliasTRT,;							//11
        	       lAcesso,cAliasFixVar,cOperac})		//12,13,14
EndIf

return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ExplEstr � Autor � Eveli Morasco         � Data � 20/08/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula a quantidade usada de um componente da estrutura   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpN1 := ExplEstr(ExpN2,ExpD1,ExpC1,ExpC2)                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Quantidade utilizada pelo componente               ���
���          � ExpD1 = Data para validacao do componente na estrutura     ���
���          � ExpC1 = String contendo os opcionais utilizados            ���
���          � ExpC2 = Revisao da estrutura utilizada                     ���
���          � ExpN2 = Variavel com valor numerico que justifica o motivo ���
���          �         pelo qual a quantidade esta zerada.                ���
���          �         1 - Componente fora das datas inicio / fim         ���
���          �         2 - Componente fora dos grupos de opcionais        ���
���          �         3 - Componente fora das revisoes                   ���
���          � ExpL1 = Indica se processa preestrutura                    ���
���          � ExpL2 = Indica se processa o tipo de decimais da OP        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ExplEstr(nQuant,dDataStru,cOpcionais,cRevisao,nMotivo,lPreEstr,lTipoDec)
LOCAL nQuantItem:=0,cUnidMod,nG1Quant:=0,nQBase:=0,nDecimal:=0,nBack:=0
LOCAL aTamSX3:={}
LOCAL cAlias:=Alias(),nRecno:=Recno(),nOrder:=IndexOrd()
LOCAL lOk:=.T.
LOCAL nDecOrig:=Set(3,8)
LOCAL cCodigo
LOCAL cComponente
LOCAL cOpcArq
LOCAL dDataIni
LOCAL dDataFim
LOCAL nQtdCampo
LOCAL nQtdPerda
LOCAL cFixVar
LOCAL cTRT
LOCAL aVldEstr := {.T.,.T.,.T.} //na ordem, indica se valida datas, grupo de opc. e revisoes na estrutura
LOCAL aUsrVlEstr := {}
LOCAL nI := 0
LOCAL nAltPer := 0

DEFAULT nMotivo:=0
DEFAULT lPreEstr:=.F.
DEFAULT lTipoDec:=.T.

cCodigo    :=If(lPreEstr,SGG->GG_COD,SG1->G1_COD)
cComponente:=If(lPreEstr,SGG->GG_COMP,SG1->G1_COMP)
cOpcArq    :=If(lPreEstr,SGG->GG_GROPC+SGG->GG_OPC,SG1->G1_GROPC+SG1->G1_OPC)
dDataIni   :=If(lPreEstr,SGG->GG_INI,SG1->G1_INI)
dDataFim   :=If(lPreEstr,SGG->GG_FIM,SG1->G1_FIM)
nG1Quant   :=If(lPreEstr,SGG->GG_QUANT,SG1->G1_QUANT)
nQtdCampo  :=If(lPreEstr,SGG->GG_QUANT,SG1->G1_QUANT)
nQtdPerda  :=If(lPreEstr,SGG->GG_PERDA,SG1->G1_PERDA)
cFixVar    :=If(lPreEstr,SGG->GG_FIXVAR,SG1->G1_FIXVAR)
cTRT       :=If(lPreEstr,SGG->GG_TRT,SG1->G1_TRT)

If lPreEstr
	aTamSX3:=TamSX3("GG_QUANT")
Else
	aTamSX3:=TamSX3("G1_QUANT")
EndIf
nDecimal:=aTamSX3[2]

// Verifica os opcionais cadastrados na Estrutura
cOpcionais:= If((cOpcionais == NIL),"",cOpcionais)

// Verifica a Revisao Atual do Componente
cRevisao:= If((cRevisao == NIL),"",cRevisao)

// Verifica a data de validade
dDataStru := If((dDataStru == NIL),dDataBase,dDataStru)

If ExistBlock("USRVLESTR")
	aUsrVlEstr := ExecBlock("USRVLESTR",.F.,.F.,{cCodigo,cComponente,cTRT})
	For nI := 1 To 3
		If ValType(aUsrVlEstr[nI]) == "L"
			aVldEstr[nI] := aUsrVlEstr[nI]
		EndIf
	Next nI
EndIf

dbSelectArea("SB1")
dbSetOrder(1)
If dbSeek(xFilial("SB1")+cCodigo)
	If Empty(cOpcionais) .And. !Empty(RetFldProd(SB1->B1_COD,"B1_OPC"))
		cOpcionais:=RetFldProd(SB1->B1_COD,"B1_OPC")
	EndIf
	If Empty(cRevisao) .And. !Empty(B1_REVATU)
		cRevisao:=B1_REVATU
	EndIf
	If aVldEstr[1] .And. !(dDataStru >= dDataIni .And. dDataStru <= dDataFim)
		nMotivo:=1 // Componente fora das datas inicio / fim
		lOk:=.F.
	EndIf
	If aVldEstr[2] .And. lOk .And. !Empty(cOpcionais) .And. !Empty(cOpcArq) .And. !(cOpcArq $ cOpcionais)
		nMotivo:=2  // Componente fora dos grupos de opcionais
		lOk:=.F.
	EndIf
	If aVldEstr[3] .And. lOk .And. !lPreEstr .And. !Empty(cRevisao) .And. (SG1->G1_REVINI > cRevisao .Or. SG1->G1_REVFIM < cRevisao)
		nMotivo:=3	// Componente fora das revisoes
		lOk:=.F.
	EndIf
EndIf

dbSelectArea(cAlias)
dbSetOrder(nOrder)
dbGoto(nRecno)

If lOk
	cUnidMod := GetMv("MV_UNIDMOD")
	SB1->(dbSeek(xFilial("SB1")+cCodigo))
	nQBase:=RetFldProd(SB1->B1_COD,If(lPreEstr.And.SB1->(FieldPos("B1_QBP"))>0,"B1_QBP","B1_QB"))

	//��������������������������������������������������������Ŀ
	//� Ponto de Entrada p/ alterar qtde. base da estrutura    �
	//����������������������������������������������������������
	If ExistBlock('MQTBASEST')
		nAltPer:=ExecBlock('MQTBASEST', .F., .F., {nQBase})
		IF Valtype(nAltPer) == 'N'
			nQBase := nAltPer
		EndIf
	EndIf

	SB1->(dbSeek(xFilial("SB1")+cComponente))
	If IsProdMod(cComponente)
		cTpHr := GetMv("MV_TPHR")
		If cTpHr == "N"
			nG1Quant := Int(nG1Quant)
			nG1Quant += ((nQtdCampo-nG1Quant)/60)*100
		EndIf
	EndIf
	
	If cFixVar $ " V"
		If IsProdMod(cComponente) .And. cUnidMOD != "H"
			nQuantItem := ((nQuant / nG1Quant) / (100 - nQtdPerda)) * 100
		Else
			nQuantItem := ((nQuant * nG1Quant) / (100 - nQtdPerda)) * 100
		EndIf
		nQuantItem := nQuantItem / Iif(nQBase <= 0,1,nQBase)
	Else
		If IsProdMod(cComponente) .And. cUnidMOD != "H"
			nQuantItem := (nG1Quant / (100 - nQtdPerda)) * 100
		Else
			nQuantItem := (nG1Quant / (100 - nQtdPerda)) * 100
		EndIf
	Endif
//26/06/2017 - Altera��o ALLSS para que os itens com decimal inferior a definida na 
//				m�scara do campo tamb�m sejam apresentados, para apresenta��o correta 
//				do custo para o produto pai.
//	nQuantItem:=Round(nQuantitem,nDecimal)
EndIf

//��������������������������������������������������������Ŀ
//� Ponto de Entrada p/ alterar qtde. do componente        �
//����������������������������������������������������������
If ExistBlock('MQTDESTR')
	nAltPer:=ExecBlock('MQTDESTR', .F., .F., {nQuant})
	If Valtype (nAltPer) == 'N'
		nQuantItem:= nAltPer
	EndIf
EndIf

Do Case
	Case (SB1->B1_TIPODEC == "A" .And. lTipoDec)
		nBack := Round( nQuantItem,0 )
	Case (SB1->B1_TIPODEC == "I" .And. lTipoDec)
		nBack := Int(nQuantItem)+If(((nQuantItem-Int(nQuantItem)) > 0),1,0)
	Case (SB1->B1_TIPODEC == "T" .And. lTipoDec)
		nBack := Int( nQuantItem )
	OtherWise
		nBack := nQuantItem
EndCase

Set(3,nDecOrig)

Return( nBack )
