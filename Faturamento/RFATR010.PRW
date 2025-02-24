#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณRFATR010  บ Autor ณAnderson C. P. Coelho บ Data ณ  19/04/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Relat๓rio de pedidos pendentes - Itens                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para a empresa Arcolor.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function RFATR010()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cDesc1       := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2       := "de acordo com os parametros informados pelo usuario."
Local cDesc3       := "Relat๓rio de Pedidos Pendentes"
Local cPict        := ""
Local titulo       := "Ped. Pendentes"
Local nLin         := 80
Local Cabec1       := "Emissใo    Pedido Cliente                                            Valor Total"
Local Cabec2       := ""
					// 99/99/9999|XXXXXX|XXXXXX XX|XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX | 999,999,999.99
					// 012345678901234567890123456789012345678901234567890123456789012345678901234567890
					// 0         10        20        30        40        50        60        70        80
Local imprime      := .T.
Local aOrd         := {}

Private lEnd       := .F.
Private lAbortPrint:= .F.
Private CbTxt      := ""
Private limite     := 80
Private tamanho    := "P"
Private nomeprog   := "RFATR010" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo      := 18
Private aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey   := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "RFATR010" // Coloque aqui o nome do arquivo usado para impressao em disco
Private _cRotina   := "RFATR010"
Private cPerg      := "RFATR010"
Private cString    := "SC5"

ValidPerg()
If !Pergunte(cPerg,.T.)
	Return
EndIf

dbSelectArea("SC5")
dbSetOrder(1)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,/*aOrd*/,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

If MV_PAR01 == 1		//PENDENTES NมO SALDO
	Titulo := AllTrim(Titulo) + " - NAO SALDO"
ElseIf MV_PAR01 == 2	//PENDENTE SALDO
	Titulo := AllTrim(Titulo) + " - SALDO"
ElseIf MV_PAR01 == 3	//PENDENTE AMBOS
	Titulo := AllTrim(Titulo) + " - SALDO OU NAO"
ElseIf MV_PAR01 == 4	//FATURADO
	Titulo := AllTrim(Titulo) + " - FATURADOS"
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณAnderson C. P. Coelho บ Data ณ  19/04/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem
Local cString := "TBTMP"
Local _nVTot  := 0

_cQry := " SELECT C5_EMISSAO EMISSAO, "
_cQry += " 	      C5_NUM     PEDIDO,  "
_cQry += " 	      C5_CLIENTE CLIENTE, "
_cQry += " 	      C5_LOJACLI LOJA,    "
_cQry += " 	      NOME,               "
_cQry += " 	      SUM(QUANT) QUANT,   "
_cQry += " 	      SUM(TOTAL) TOTAL    "
_cQry += " FROM ( "
_cQry += " 		SELECT C5_EMISSAO, C5_NUM, C5_CLIENTE, C5_LOJACLI,  "
_cQry += " 				(CASE  "
_cQry += " 					WHEN C5_TIPO IN ('D','B')  "
_cQry += " 						THEN (	SELECT A2_NOME  "
_cQry += " 								FROM " + RetSqlName("SA2") + " SA2  "
_cQry += " 								WHERE SA2.D_E_L_E_T_<>'*' "
_cQry += " 								  AND SA2.A2_FILIAL = '' "
_cQry += " 								  AND SA2.A2_COD    = SC5.C5_CLIENTE  "
_cQry += " 								  AND SA2.A2_LOJA   = SC5.C5_LOJACLI) "
_cQry += " 						ELSE (	SELECT A1_NOME  "
_cQry += " 								FROM " + RetSqlName("SA1") + " SA1  "
_cQry += " 								WHERE SA1.D_E_L_E_T_<>'*' "
_cQry += " 								  AND SA1.A1_FILIAL = '' "
_cQry += " 								  AND SA1.A1_COD    = SC5.C5_CLIENTE  "
_cQry += " 								  AND SA1.A1_LOJA   = SC5.C5_LOJACLI) "
_cQry += " 				END) NOME, "
_cQry += " 				(SC6.C6_QTDVEN - SC6.C6_QTDENT) QUANT, "
If MV_PAR01 == 4	//FATURADO
	_cQry += " 			(SC6.C6_QTDENT * SC6.C6_PRCVEN) TOTAL "
Else
	_cQry += " 			((SC6.C6_QTDVEN - SC6.C6_QTDENT) * SC6.C6_PRCVEN) TOTAL "
EndIf
_cQry += " 		FROM " + RetSqlName("SC5") + " SC5, "
_cQry +=               + RetSqlName("SC6") + " SC6  "
_cQry += " 		WHERE SC5.D_E_L_E_T_ <> '*' "
_cQry += " 		  AND SC5.C5_FILIAL   = '" + xFilial("SC5") + "' "
_cQry += " 		  AND SC5.C5_TIPO     = 'N' "
_cQry += " 		  AND SC5.C5_EMISSAO BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "' "
_cQry += " 		  AND SC6.D_E_L_E_T_ <> '*' "
_cQry += " 		  AND SC6.C6_FILIAL   = '" + xFilial("SC6") + "' "
_cQry += " 		  AND SC6.C6_BLQ     <> 'R' "
If MV_PAR01 == 1		//PENDENTES NAO SALDO
	_cQry += " 		  AND SC6.C6_QTDENT = 0 "
/*
	_cQry += " 		  AND  ( "
	_cQry += " 		          SELECT (CASE WHEN SUM(C6_QTDENT) > 0 THEN  "
	_cQry += " 		          FROM " + RetSqlName("SC6")   + " SC6X "
	_cQry += " 		          WHERE SC6X.D_E_L_E_T_ <> '*' "
	_cQry += " 		            AND SC6X.C6_FILIAL   = '" + xFilial("SC6") + "' "
	_cQry += " 		            AND SC6X.C6_BLQ     <> 'R' "
	_cQry += " 		            AND SC6X.C6_NUM      = SC6.C6_NUM "
	_cQry += " 		          GROUP BY C6_NUM "
	_cQry += " 		        ) = 0"
*/
ElseIf MV_PAR01 == 2	//PENDENTE SALDO
	_cQry += " 		  AND SC6.C6_QTDENT  > 0 AND SC6.C6_QTDENT < SC6.C6_QTDVEN "
/*
	_cQry += " 		  AND  ( "
	_cQry += " 		          SELECT C6_NUM, SUM(C6_QTDENT) > 0 "
	_cQry += " 		          FROM " + RetSqlName("SC6")   + " SC6X "
	_cQry += " 		          WHERE SC6X.D_E_L_E_T_ <> '*' "
	_cQry += " 		            AND SC6X.C6_FILIAL   = '" + xFilial("SC6") + "' "
	_cQry += " 		            AND SC6X.C6_BLQ     <> 'R' "
	_cQry += " 		            AND SC6X.C6_NUM      = SC6.C6_NUM "
	_cQry += " 		          GROUP BY C6_NUM "
	_cQry += " 		        ) > 0"
*/
ElseIf MV_PAR01 == 3	//PENDENTE AMBOS
	_cQry += " 		  AND SC6.C6_QTDENT < SC6.C6_QTDVEN "
ElseIf MV_PAR01 == 4	//FATURADO
	_cQry += " 		  AND SC6.C6_QTDENT >= SC6.C6_QTDVEN "
EndIf
_cQry += " 		  AND SC5.C5_NUM      = SC6.C6_NUM "
_cQry += " 	) PV "
_cQry += " GROUP BY C5_EMISSAO, C5_NUM, C5_CLIENTE, C5_LOJACLI, NOME "
_cQry += " ORDER BY C5_EMISSAO, C5_NUM, C5_CLIENTE, C5_LOJACLI, NOME "
_cQry := ChangeQuery(_cQry)
If __cUserId=="000000"
//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.txt",_cQry)
EndIf
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cString,.T.,.F.)

dbSelectArea(cString)
SetRegua(RecCount())
(cString)->(dbGoTop())
While !(cString)->(EOF())
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica o cancelamento pelo usuario...                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Impressao do cabecalho do relatorio. . .                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	EndIf
	@nLin,000 PSAY DTOC(STOD((cString)->EMISSAO))
	@nLin,010 PSAY "|"
	@nLin,011 PSAY (cString)->PEDIDO
	@nLin,017 PSAY "|"
	@nLin,018 PSAY (cString)->CLIENTE
	@nLin,025 PSAY (cString)->LOJA
	@nLin,027 PSAY "|"
	@nLin,028 PSAY SubStr((cString)->NOME,1,35)
	@nLin,064 PSAY "|"
	@nLin,066 PSAY (cString)->TOTAL                         Picture "@E 999,999,999.99"
	nLin++
	_nVTot += (cString)->TOTAL
	(cString)->(dbSkip())
EndDo

If _nVTot > 0
	nLin++
	@nLin,000 PSAY Replicate("_",Limite)
	nLin++
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica o cancelamento pelo usuario...                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lAbortPrint
		@nLin,000 PSAY "*** CANCELADO PELO OPERADOR ***"
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Impressao do cabecalho do relatorio. . .                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	EndIf
	@nLin,062 PSAY _nVTot         Picture "@E 999,999,999,999.99"
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
EndIf

MS_FLUSH()

dbSelectArea(cString)
(cString)->(dbCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณVALIDPERG บAutor  ณAnderson C. P. Coelho บ Data ณ  26/04/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se as perguntas estใo criadas no arquivo SX1 e caso บฑฑ
ฑฑบ          ณ nใo as encontre ele as cria.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ValidPerg()

Local _sAlias := GetArea()
Local aRegs :={}
cPerg := PADR(cPerg,10)

AADD(aRegs,{cPerg,"01","Status      ?","","","mv_ch1","N",01,0,0,"C","","mv_par01","Pendente Nใo Saldo","","","","","Pendente Saldo","","","","","Pendente - Ambos","","","","","Faturados","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","De  Emisssใo?","","","mv_ch2","D",08,0,0,"G","","mv_par02",""                  ,"","","","",""              ,"","","","",""                ,"","","","",""         ,"","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","At้ Emisssใo?","","","mv_ch3","D",08,0,0,"G","","mv_par03",""                  ,"","","","",""              ,"","","","",""                ,"","","","",""         ,"","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Forma       ?","","","mv_ch4","N",01,0,0,"C","","mv_par04","Por Item"          ,"","","","","Por Pedido"    ,"","","","",""                ,"","","","",""         ,"","","","","","","","","",""})

For i := 1 To Len(aRegs)
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If !SX1->(MsSeek(cPerg+aRegs[i,2],.T.,.F.))
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

RestArea(_sAlias)

Return