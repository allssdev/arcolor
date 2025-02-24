#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFATR015  บAutor  ณJ๚lio Soares        บ Data ณ  07/26/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Relat๓rio de auditoria de faturamento por pedidos de venda บฑฑ
ฑฑบ          ณ onde ้ apresentado, atrav้s de parโmetros, tudo que foi    บฑฑ
ฑฑบ          ณ faturado com a NรO atualiza็ใo do estoque ou gera็ใo de    บฑฑ
ฑฑบ          ณ duplicatas no financeiro                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especํfico para a empresa - ARCOLOR                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER FUNCTION RFATR015()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local cDesc1       := "Este programa tem como objetivo imprimir relatorio  "
Local cDesc2       := "de acordo com os parametros informados pelo usuario."
Local cDesc3       := "Relat๓rio de Faturamento sem Estoque e/ou duplicata "
Local cPict        := ""
Local titulo       := "Relat๓rio de auditoria de faturamento"
Local nLin         := 80
Local Cabec1       := "N.Pedido  Cod + Loja    Nome                                  S้rie + Doc       Dt.Fatur.  Valor Documento"
Local Cabec2       := ""
					// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
					// 0         10        20        30        40        50        60        70        80        90        100       110       120
Local imprime      := .T.
Local aOrd         := {}
Local _Total       := 0

Private lEnd       := .F.
Private lAbortPrint:= .F.
Private CbTxt      := ""
Private limite     := 80
Private tamanho    := "M"
Private nomeprog   := "RFATR015" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo      := 18
Private aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey   := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "RFATR015" // Coloque aqui o nome do arquivo usado para impressao em disco
Private _cRotina   := "RFATR015"
Private cPerg      := "RFATR015"
Private cString    := "SC5"

// Apresenta tela dos parโmetros ao iniciar o relat๓rio
ValidPerg()
If !Pergunte(cPerg,.T.)
	Return
EndIf

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

If MV_PAR09 == 1		//PENDENTES
	Titulo := AllTrim(Titulo) + " - AMBOS"
ElseIf MV_PAR09 == 2	//SALDO
	Titulo := AllTrim(Titulo) + " - FINANCEIRO"
ElseIf MV_PAR09 == 3	//AMBOS
	Titulo := AllTrim(Titulo) + " - ESTOQUE"
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
ฑฑบFuno    ณRUNREPORT บ Autor ณAnderson C. P. Coelho บ Data ณ  06/06/13 บฑฑ
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
Local _nValTot := 0

If      MV_PAR10 == 1
	If MV_PAR11 == 1
	//	_cQry := " SELECT DISTINCT C6_NUM, C6_CLI, C5_LOJACLI, C6_LOJA, C5_NOMCLI, C5_EMISSAO, F2_VALBRUT, C6_SERIE, C6_NOTA, C6_DATFAT "
		_cQry := " SELECT C6_NUM, C6_CLI, C5_LOJACLI, C6_LOJA, C5_NOMCLI, C5_EMISSAO, F2_VALBRUT, C6_SERIE, C6_NOTA, C6_DATFAT "	

	ElseIf MV_PAR11 == 2
		_cQry := " SELECT C6_NUM, C6_CLI, C5_LOJACLI, C6_LOJA, C5_NOMCLI, C5_EMISSAO, F2_VALBRUT, C6_SERIE, C6_NOTA, C6_DATFAT "	

    ElseIf MV_PAR11 == 3
		_cQry := " SELECT C6_NUM, C6_CLI, C5_LOJACLI, C6_LOJA, C5_NOMCLI, C5_EMISSAO, F2_VALBRUT, C6_SERIE, C6_NOTA, C6_DATFAT, C6_TES "
    EndIf

ElseIf  MV_PAR10 == 2
	_cQry := " SELECT C6_NUM, C6_CLI, C5_CLIENTE,C5_LOJACLI, C6_LOJA, C5_NOMCLI, C5_EMISSAO, F2_VALBRUT, C6_ITEM, C6_PRODUTO, C6_DESCRI, C6_QTDVEN, C6_PRCVEN, C6_VALOR, C6_TES, F4_TEXTO, C6_UM, C6_QTDVEN, C6_QTDENT, C6_SERIE, C6_NOTA, C6_DATFAT "
EndIf

_cQry += " FROM " + RetSqlName("SC5") + " SC5 "
_cQry += "    INNER JOIN " + RetSqlName("SC6") + " SC6 ON SC6.D_E_L_E_T_ = '' "
_cQry += " 	      AND C5_TIPO  = 'N' "
_cQry += " 	      AND C6_NUM   = C5_NUM "
_cQry += " 	      AND C6_CLI   = C5_CLIENTE "
_cQry += " 	      AND C6_LOJA  = C5_LOJACLI "
_cQry += "    INNER JOIN " + RetSqlName("SF4") + " SF4 ON SF4.D_E_L_E_T_ = '' "
_cQry += "        AND C6_TES   = F4_CODIGO "
_cQry += " 	      AND C6_NOTA  <> '' "
_cQry += "    INNER JOIN " + RetSqlName("SF2") + " SF2 ON SF2.D_E_L_E_T_ = '' "
_cQry += "        AND C6_SERIE = F2_SERIE "
_cQry += "        AND C6_NOTA  = F2_DOC "
_cQry += " WHERE SC5.D_E_L_E_T_ = '' "
_cQry += "        AND C5_FILIAL = '" + xFilial("SC5") + "' "
_cQry += "        AND C5_NUM   BETWEEN '" + (mv_par03) + "' AND '" + (mv_par04) + "' "
_cQry += "        AND C6_SERIE BETWEEN '" + (mv_par05) + "' AND '" + (mv_par06) + "' "
_cQry += "        AND C6_NOTA  BETWEEN '" + (mv_par07) + "' AND '" + (mv_par08) + "' "

If     MV_PAR09 == 1
	_cQry += "        AND (F4_DUPLIC  <> 'S' AND C6_DATFAT BETWEEN '" + (DTOS(mv_par01)) + "' AND '" + (DTOS(mv_par02)) + "') OR (F4_ESTOQUE <> 'S' AND C6_DATFAT BETWEEN '" + (DTOS(mv_par01)) + "' AND '" + (DTOS(mv_par02)) + "') "

ElseIf MV_PAR09 == 2
	_cQry += " 	      AND F4_DUPLIC  <> 'S' AND C6_DATFAT BETWEEN '" + (DTOS(mv_par01)) + "' AND '" + (DTOS(mv_par02)) + "' "

ElseIf MV_PAR09 == 3
	_cQry += " 	      AND F4_ESTOQUE <> 'S' AND C6_DATFAT BETWEEN '" + (DTOS(mv_par01)) + "' AND '" + (DTOS(mv_par02)) + "' "
EndIf

// Verifica os parโmetros de ordem do relat๓rio de acordo com o tipo de relat๓rio, se analํtico ou sint้tico.
If MV_PAR10 == 1
	If     MV_PAR11 == 1
		_cQry += " GROUP BY C6_NUM, C6_CLI, C5_LOJACLI, C6_LOJA, C5_NOMCLI, C5_EMISSAO, F2_VALBRUT, C6_SERIE, C6_NOTA, C6_DATFAT "
//		_cQry += " ORDER BY C6_NUM, C6_CLI, C5_LOJACLI, C6_LOJA "
		_cQry += " ORDER BY C6_CLI, C6_LOJA, C6_NUM "
	ElseIf MV_PAR11 == 2
		_cQry += " GROUP BY C6_NUM, C6_CLI, C5_LOJACLI, C6_LOJA, C5_NOMCLI, C5_EMISSAO, F2_VALBRUT, C6_SERIE, C6_NOTA, C6_DATFAT "
		_cQry += " ORDER BY C6_DATFAT, C6_CLI, C6_LOJA, C6_NUM "
	ElseIf MV_PAR11 == 3
		_cQry += " GROUP BY C6_NUM, C6_CLI, C5_LOJACLI, C6_LOJA, C5_NOMCLI, C5_EMISSAO, F2_VALBRUT, C6_SERIE, C6_NOTA, C6_DATFAT "
		_cQry += " ORDER BY C6_TES, C6_CLI, C6_LOJA "
	EndIf 
ElseIf MV_PAR10 == 2
	If     MV_PAR11 == 1
		_cQry += " ORDER BY C5_CLIENTE, C6_LOJA, C6_NUM, C6_ITEM "
	ElseIf MV_PAR11 == 2
		_cQry += " ORDER BY C6_DATFAT, C6_NUM, C6_ITEM, C6_CLI, C6_LOJA "
	ElseIf MV_PAR11 == 3
		_cQry += " ORDER BY C6_TES, F4_TEXTO, C6_CLI, C6_LOJA "
	EndIf
EndIf
_cQry := ChangeQuery(_cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"TRA",.T.,.F.)

dbSelectArea("TRA")
TRA->(dbSetOrder(0))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SetRegua(RecCount())

TRA->(dbGoTop())
While !(TRA->(EOF()))
   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณ Verifica o cancelamento pelo usuario...                             ณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lAbortPrint
		@nLin,000 PSay "CANCELADO PELO OPERADOR"
		Exit
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Impressao do cabecalho do relatorio. . .                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

			// 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
			// 0         10        20        30        40        50        60        70        80        90        100       110       120       130

	_oCabec1 := "N.Pedido  Cod + Loja    Nome                                  S้rie + Doc       Dt.Fatur.  Valor Documento"
	_oCabec2 := " Item    Produto    Descri็ใo                              Qtd.         Prc.Unit.    Total      TES     Tipo de venda  "
	_cPed := ''
	
	If nLin > 60
		nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Endif
	If MV_PAR10 == 1 // Sint้tico
		nLin ++
		@ nLin, 002 PSay TRA->C6_NUM
		@ nLin, 010 PSay (Alltrim(TRA->C6_CLI)) + " / " + (Alltrim(C6_LOJA))
		@ nLin, 022 PSay TRA->C5_NOMCLI
		@ nLin, 065 PSay (Alltrim(TRA->C6_SERIE)) + "-" + (Alltrim(TRA->C6_NOTA))
		@ nLin, 080 PSay TRA->(STOD(C6_DATFAT))
		@ nLin, 090 PSay TRA->(F2_VALBRUT) Picture "@E 9,999,999,999.99"		
		nLin ++
		@ nLin, 000 PSay REPLICATE ("_",130)
        nLin++
        _nValTot += (TRA->(F2_VALBRUT))

	ElseIf MV_PAR10 == 2 // Analํtico
		If _cPed <> TRA->C6_NUM
			If nLin > 60
				nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			Endif

			nLin ++
			@ nLin, 002 PSay _ocabec1

			nLin ++
			@ nLin, 002 PSay TRA->C6_NUM
			@ nLin, 010 PSay (Alltrim(TRA->C6_CLI)) + " / " + (Alltrim(C6_LOJA))
			@ nLin, 022 PSay TRA->C5_NOMCLI
			@ nLin, 065 PSay (Alltrim(TRA->C6_SERIE)) + "-" + (Alltrim(TRA->C6_NOTA))
			@ nLin, 080 PSay TRA->(STOD(C6_DATFAT))
			@ nLin, 090 PSay TRA->(F2_VALBRUT) Picture "@E 9,999,999,999.99"
			@ nLin, 000 PSay REPLICATE ("_",130)

	        nLin++
	        _nValTot += (TRA->(F2_VALBRUT))

			nLin ++
			@ nLin, 000 PSay ""

			nLin ++
			@ nLin, 000 PSAy _oCabec2

			nLin ++
			_cPed := TRA->C6_NUM

			While !(TRA->(EOF())) .and. _cPed == TRA->(C6_NUM)
				If nLin > 60
					nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
				Endif
				@ nLin, 002 PSay TRA->C6_ITEM
				@ nLin, 010 PSay TRA->C6_PRODUTO
				@ nLin, 020 PSay TRA->C6_DESCRI
				@ nLin, 060 PSay TRA->C6_QTDVEN
				@ nLin, 065 PSay TRA->C6_PRCVEN   Picture "@E 9,999,999,999.99"
				@ nLin, 075 PSay TRA->C6_VALOR    Picture "@E 9,999,999,999.99"
				@ nLin, 095 PSay TRA->C6_TES
				@ nLin, 105 PSay TRA->F4_TEXTO		
				//@ nLin, 120 PSay TRA->C6_NUM
				nLin ++
				TRA->(dbSkip())
			EndDo
		EndIf
	EndIf

dbSelectArea("TRA")
TRA->(dbSetOrder(0))
TRA->(dbSkip())
EndDo
// - Totalizadores
If _nValTot > 0
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica o cancelamento pelo usuario...                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lAbortPrint
		@nLin,000 PSay "CANCELADO PELO OPERADOR"
	EndIf
	If nLin > 60
		nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Endif
	@ nLin, 000 PSay REPLICATE ("_",130)	
	nLin++	            
	@nLin, 070 Psay "VALOR TOTAL "
	@nLin, 095 Psay "R$ "	
	@nLin, 100 Psay (_nValTot) Picture "@E 999,999,999,999.99"
	nLin++	            
EndIf
// - Totalizadores

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

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Seleciono a tabela temporแria e com a mesma posicionada fecho a tabela ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

dbSelectArea("TRA")
TRA->(dbCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณVALIDPERG บAutor  ณJ๚lio Soares          บ Data ณ  26/07/13 บฑฑ
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

AADD(aRegs,{cPerg,"01","De  Emisssใo?"  ,"","","mv_ch1" ,"D",08,0,0,"G",""           ,"mv_par01",""                ,"","","","",""                ,"","","","",""                ,"","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","At้ Emisssใo?"  ,"","","mv_ch2" ,"D",08,0,0,"G","NaoVazio() ","mv_par02",""                ,"","","","",""                ,"","","","",""                ,"","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","De  Pedido?"    ,"","","mv_ch3" ,"C",06,0,0,"G",""           ,"mv_par03",""                ,"","","","",""                ,"","","","",""                ,"","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","At้ Pedido?"    ,"","","mv_ch4" ,"C",06,0,0,"G","NaoVazio()" ,"mv_par04",""                ,"","","","",""                ,"","","","",""                ,"","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"05","De  Serie?"     ,"","","mv_ch5" ,"C",03,0,0,"G",""           ,"mv_par05",""                ,"","","","",""                ,"","","","",""                ,"","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"06","At้ Serie?"     ,"","","mv_ch6" ,"C",03,0,0,"G","NaoVazio()" ,"mv_par06",""                ,"","","","",""                ,"","","","",""                ,"","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"07","De  Documento?" ,"","","mv_ch7" ,"C",09,0,0,"G",""           ,"mv_par07",""                ,"","","","",""                ,"","","","",""                ,"","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"08","At้ Documento?" ,"","","mv_ch8" ,"C",09,0,0,"G","NaoVazio()" ,"mv_par08",""                ,"","","","",""                ,"","","","",""                ,"","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"09","Quanto a TES?"  ,"","","mv_ch9" ,"N",01,0,0,"C","NaoVazio()" ,"mv_par09","Ambos"           ,"","","","","Sem Duplicata"   ,"","","","","Sem Estoque"     ,"","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"10","Tp. Relat๓rio?" ,"","","mv_cha" ,"N",01,0,0,"C","NใoVazio()" ,"mv_par10","Sint้tico"       ,"","","","","Analํtico"       ,"","","","",""                ,"","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"11","Ordem Relat?"   ,"","","mv_chb" ,"N",01,0,0,"C","NใoVazio()" ,"mv_par11","Cliente + Pedid" ,"","","","","Dt. Fatur + Ped" ,"","","","","Tipo TES + Clie" ,"","","","","","","","","","","","","","",""})

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

Return()
