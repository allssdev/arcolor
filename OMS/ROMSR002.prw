#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ROMSR002  º Autor ³Anderson C. P. Coelho º Data ³  05/06/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de relação de movimentos do caixinha por carga,  º±±
±±º          ³ por data.                                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ROMSR002()

Local cDesc1       := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2       := "de acordo com os parametros informados pelo usuario."
Local cDesc3       := "Relação de movimentos do caixinha por carga por data"
Local titulo       := "Relação de movimentos do caixinha por carga por data"
Local cPict        := ""
Local nLin         := 80
Local Cabec1       := "CARGA   DATA                 VALOR TIPO            HISTÓRICO "
					// XXXXXX 99/99/9999   999,999,999.99 XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
					// 012345678901234567890123456789012345678901234567890123456789012345678901234567890
					// 0         10        20        30        40        50        60        70        80
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd         := {}

Private lEnd        := .F.
Private lAbortPrint := .F.
Private CbTxt       := ""
Private limite      := 80
Private tamanho     := "P"
Private nomeprog    := "ROMSR002" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 18
Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey    := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := nomeprog
Private _cRotina   := nomeprog
Private cPerg      := nomeprog
Private cString    := "SEU"
Private _lEnt      := CHR(13) + CHR(10)

dbSelectArea(cString)
(cString)->(dbSetOrder(1))
ValidPerg()
If !Pergunte(cPerg,.T.)
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,/*aOrd*/,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
EndIf

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|lAbortPrint| RunReport(Cabec1,Cabec2,Titulo,nLin,lAbortPrint) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  05/06/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin,lAbortPrint)

Local nOrdem
Local _nTotC  := 0
Local _nTotG  := 0
Local _nTotCx := 0
Local _nPTp   := 0
Local _cCx    := ""
Local _cCarga := ""
Local _aTpMv  := {}

_cAliasSX3 := "SX3_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
dbSelectArea(_cAliasSX3)
(_cAliasSX3)->(dbSetOrder(2))
If (_cAliasSX3)->(dbSeek("EU_TIPO"))
	_aTpMv := Separa((_cAliasSX3)->X3_CBOX,";")
EndIf

_cQry := " SELECT EU_CAIXA,EU_CARGA,EU_DTDIGIT,EU_TIPO,EU_HISTOR,"                              +_lEnt
_cQry += "        (CASE WHEN EU_TIPO = '02' THEN EU_VALOR*(-1) ELSE EU_VALOR END) EU_VALOR "    +_lEnt
_cQry += " FROM " + RetSqlName("SEU") + " SEU "                                                 +_lEnt
_cQry += " WHERE SEU.D_E_L_E_T_       = '' "                                                    +_lEnt
_cQry += "   AND SEU.EU_FILIAL        = '" + xFilial("SEU") + "' "                              +_lEnt
_cQry += "   AND SEU.EU_CARGA        <> '' "                                                    +_lEnt
_cQry += "   AND SEU.EU_CARGA   BETWEEN '" + MV_PAR01       + "' AND '" + MV_PAR02       + "' " +_lEnt
_cQry += "   AND SEU.EU_CAIXA   BETWEEN '" + MV_PAR05       + "' AND '" + MV_PAR06       + "' " +_lEnt
_cQry += "   AND SEU.EU_DTDIGIT BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' " +_lEnt
_cQry += " ORDER BY EU_CAIXA, EU_CARGA, EU_DTDIGIT, EU_SEQCXA "
/*
If __cUserId=="000000"
	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.txt",_cQry)
EndIf
*/
_cQry := ChangeQuery(_cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"TRBTMP",.T.,.F.)

dbSelectArea("TRBTMP")
SetRegua(RecCount())
TRBTMP->(dbGoTop())
If !TRBTMP->(EOF())
	While !TRBTMP->(EOF())
		nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
		_cCx := TRBTMP->EU_CAIXA
		@nLin,000 PSAY "C A I X A  " + TRBTMP->EU_CAIXA
		nLin++
		While !TRBTMP->(EOF()) .AND. _cCx == TRBTMP->EU_CAIXA
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o cancelamento pelo usuario...                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lAbortPrint
				@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			EndIf
			If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
				nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 8
			EndIf
			@nLin,000 PSAY TRBTMP->EU_CARGA
			@nLin,007 PSAY STOD(TRBTMP->EU_DTDIGIT)
			@nLin,020 PSAY TRBTMP->EU_VALOR               PICTURE "@E 999,999,999.99"
			_nPTp := aScan(_aTpMv,AllTrim(TRBTMP->EU_TIPO))
			If _nPTp > 0
				@nLin,035 PSAY SubStr(_aTpMv[_nPTp]  ,1,15)
			Else
				@nLin,035 PSAY SubStr(TRBTMP->EU_TIPO,1,15)
			EndIf
			@nLin,051 PSAY SubStr(TRBTMP->EU_HISTOR  ,1,30)
			nLin++
			_cCarga := TRBTMP->EU_CARGA
			_nTotC  += TRBTMP->EU_VALOR
			_nTotG  += TRBTMP->EU_VALOR
			_nTotCx += TRBTMP->EU_VALOR
			TRBTMP->(dbSkip())
			If _cCarga <> TRBTMP->EU_CARGA
				nLin++
				@nLin,000 PSAY "*TOTAL DA CARGA " + _cCarga
				@nLin,020 PSAY _nTotC                     PICTURE "@E 999,999,999.99"
				_nTotC := 0
				nLin   += 2
			EndIf
		EndDo
		@nLin,000 PSAY "**TOTAL DO CAIXA " + _cCx
		@nLin,020 PSAY _nTotCx                            PICTURE "@E 999,999,999.99"
		_nTotCx := 0
		nLin    += 2
	EndDo
	@nLin,000 PSAY "***TOTAL GERAL "
	@nLin,020 PSAY _nTotG                             PICTURE "@E 999,999,999.99"
Else
	MsgAlert("Nada processado!",_cRotina+"_001")
EndIf
TRBTMP->(dbCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
EndIf

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg ºAutor  ³Anderson C. P. Coelho º Data ³  05/06/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se as perguntas existem na tabela SX1, as criando º±±
±±º          ³caso não existam.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ValidPerg()

Local _sAlias := GetArea()
Local aRegs   := {}
Local _aTam   := {}

cPerg := PADR(cPerg,10)

_aTam := TamSx3("EU_CARGA")
AADD(aRegs,{cPerg,"01","De Carga? "	,"","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","Vazio()"   ,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","DAK",""})
AADD(aRegs,{cPerg,"02","Até Carga?"	,"","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","DAK",""})
_aTam := TamSx3("EU_DTDIGIT")
AADD(aRegs,{cPerg,"03","Da Data?  " ,"","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"04","Até Data? " ,"","","mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G","NaoVazio()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
_aTam := TamSx3("EU_CAIXA")
AADD(aRegs,{cPerg,"05","Do Caixa? " ,"","","mv_ch5",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SET",""})
AADD(aRegs,{cPerg,"06","Até Caixa?" ,"","","mv_ch6",_aTam[03],_aTam[01],_aTam[02],0,"G","NaoVazio()","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SET",""})
	  	
For x := 1 To Len(aRegs)
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If !SX1->(MsSeek(cPerg+aRegs[x,2],.T.,.F.))
		RecLock("SX1",.T.)
		For y:=1 To FCount()
			If y <= Len(aRegs[x])
				FieldPut(y,aRegs[x,y])
			Else
				Exit
			EndIf
		Next
		SX1->(MsUnlock())
	EndIf
Next

RestArea(_sAlias)

Return()