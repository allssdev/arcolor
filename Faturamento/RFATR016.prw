#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATR016  � Autor � J�lio Soares       � Data �  13/09/13   ���
�������������������������������������������������������������������������͹��
���Descricao � Relat�rio de pedidos em aberto por produto.                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Espec�fico Arcolor                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function RFATR016()


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de acordo com os parametros informados pelo usuario."
Local cDesc3        := "Pedidos por produto"
Local cPict         := ""
Local titulo        := "Pedidos por produto"
Local nLin          := 80
Local Cabec1        := ""
Local Cabec2        := ""

Local imprime       := .T.
Local aOrd          := {}
Local _nTotal       := 0

Private lEnd        := .F.
Private lAbortPrint := .F.
Private CbTxt       := ""
Private limite      := 80
Private tamanho     := "M"
Private nomeprog    := "RFATR016" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 18
Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "RFATR016" // Coloque aqui o nome do arquivo usado para impressao em disco
Private _cRotina    := " RFATR016 "
Private cPerg       := "RFATR016"
Private cString     := "SC5"


// Apresenta tela dos par�metros ao iniciar o relat�rio
ValidPerg()
If !Pergunte(cPerg,.T.)
	Return
EndIf

//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//�������������������������������������������������������������������������T�
//�Personaliza o titulo do relat�rio de acordo com os par�metros escolhidos�
//�������������������������������������������������������������������������T�

If MV_PAR05 == 1     // Analitico
	If MV_PAR06 == 1 // Produto
		Titulo := AllTrim(Titulo) + " - Analitico por Produto"
    ElseIf MV_PAR06 == 2 // Cliente
		Titulo := AllTrim(Titulo) + " - Analitico por Cliente"
    ElseIf MV_PAR06 == 3 // Vendedor
		// Altera��o - Fernando Bombardi - ALLSS - 02/03/2022
		//Titulo := AllTrim(Titulo) + " - Analitico por Vendedor"		
		Titulo := AllTrim(Titulo) + " - Analitico por Representante"		
		// Fim - Fernando Bombardi - ALLSS - 02/03/2022
	EndIf
ElseIf MV_PAR05 == 2 // Sint�tico
	If MV_PAR06 == 1 // Produto
		Titulo := AllTrim(Titulo) + " - Sint�tico por Produto"
    ElseIf MV_PAR06 == 2 // Cliente
		Titulo := AllTrim(Titulo) + " - Sint�tico por Cliente"
    ElseIf MV_PAR06 == 3 // Vendedor
		// Altera��o - Fernando Bombardi - ALLSS - 02/03/2022
		//Titulo := AllTrim(Titulo) + " - Sint�tico por Vendedor"		
		Titulo := AllTrim(Titulo) + " - Sint�tico por Representante"		
		// Fim - Fernando Bombardi - ALLSS - 02/03/2022
	EndIf	
EndIf

//���������������������������������������������������������������������Ŀ
//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
//�����������������������������������������������������������������������

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � AP6 IDE            � Data �  13/09/13   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local _nValProd := 0
Local _nQtdProd := 0
Local _nValTot  := 0
Local _nQtdTot  := 0

/*
"De  Emisss�o?" ,"mv_ch1" ,"mv_par01"
"At� Emisss�o?" ,"mv_ch2" ,"mv_par02"
"De  Produto?"  ,"mv_ch3" ,"mv_par03"
"At� Produto?"  ,"mv_ch4" ,"mv_par04"
"Anal�tico?"    ,"mv_ch5" ,"mv_par05"
"Ordem?"        ,"mv_ch6" ,"mv_par06"
"De  Cliente?"  ,"mv_ch7" ,"mv_par07"
"De  Loja?"     ,"mv_ch8" ,"mv_par08"
"At� Cliente?"  ,"mv_ch9" ,"mv_par09"
"At� Loja?"     ,"mv_cha" ,"mv_par10"
"De Vendedor?"  ,"mv_chb" ,"mv_par11"
"At� Vendedor?" ,"mv_chc" ,"mv_par12"
*/

If MV_PAR05 == 1 // ANALITICO = 1
	If MV_PAR06 == 3 //VENDEDOR
		_cQry := " SELECT C6_CLI,C6_LOJA,C5_NOMCLI,C6_EMISSAO,C6_NUM,C6_PRODUTO,C6_DESCRI,C6_QTDVEN,C6_PRCVEN,C6_VALOR,C5_VEND1,C5_DESCVEN "
	Else
		_cQry := " SELECT C6_CLI,C6_LOJA,C5_NOMCLI,C6_EMISSAO,C6_NUM,C6_PRODUTO,C6_DESCRI,C6_QTDVEN,C6_PRCVEN,C6_VALOR "
	EndIf
ElseIf MV_PAR05 == 2  // SINTETICO = 2
	If MV_PAR06 == 1
		_cQry := " SELECT C6_PRODUTO,C6_DESCRI,SUM (C6_QTDVEN)[C6_QTDVEN], SUM (C6_VALOR)[C6_VALOR] "
	ElseIf MV_PAR06 == 2
		_cQry := " SELECT C6_CLI,C6_LOJA,C6_NUM,C6_PRODUTO,C6_DESCRI,SUM (C6_QTDVEN)[C6_QTDVEN], SUM (C6_VALOR)[C6_VALOR] "
	ElseIf MV_PAR06 == 3 // Vendedor
		_cQry := " SELECT C6_CLI,C6_LOJA,C6_NUM,C6_PRODUTO,C6_DESCRI,SUM (C6_QTDVEN)[C6_QTDVEN], SUM (C6_VALOR)[C6_VALOR] "
	EndIf
EndIf

_cQry += " FROM " + RetSqlName("SC6") + " SC6 "
_cQry += "    INNER JOIN "+ RetSqlName("SC5") +" SC5 ON SC5.D_E_L_E_T_ = '' "
_cQry += "       AND C5_NUM     = C6_NUM "
_cQry += " 	     AND C5_CLIENTE = C6_CLI "
_cQry += " 	     AND C5_LOJACLI = C6_LOJA "
_cQry += " 	     AND C5_TIPO    = 'N' "
//_cQry += " 	     AND C5_NOTA    = '' "
_cQry += " 	     AND C5_VEND1   BETWEEN '" + (mv_par11) + "' AND '" + (mv_par12) + "' "
_cQry += " WHERE SC6.D_E_L_E_T_ = '' "
_cQry += "       AND C6_FILIAL = '" + xFilial("SC6") + "' "
_cQry += " 	     AND C6_PRODUTO BETWEEN '" + (mv_par03) + "' AND '" + (mv_par04) + "' "
_cQry += "       AND C6_BLQ     <> 'R'
//_cQry += " 	     AND C6_NOTA    = '' "
_cQry += " 	     AND C6_QTDVEN  <> C6_QTDENT "
_cQry += " 	     AND (C6_QTDVEN - C6_QTDENT) <> 0 "
_cQry += " 	     AND C6_EMISSAO BETWEEN '" + (DTOS(mv_par01)) + "' AND  '" + (DTOS(mv_par02)) + "' "
_cQry += " 	     AND C6_CLI     BETWEEN '" + (mv_par07) + "' AND '" + (mv_par09) + "' "
_cQry += " 	     AND C6_LOJA    BETWEEN '" + (mv_par08) + "' AND '" + (mv_par10) + "' "


If MV_PAR05 == 1 // ANALITICO
	If MV_PAR06 == 1 // PRODUTO
		_cQry += " ORDER BY C6_PRODUTO,C6_CLI,C6_LOJA,C6_NUM "
	ElseIf MV_PAR06 == 2// CLIENTE
		_cQry += " ORDER BY C6_CLI,C6_LOJA,C6_NUM,C6_PRODUTO "
	ElseIf MV_PAR06 == 3// VENDEDOR
		_cQry += " ORDER BY C5_VEND1,C6_NUM,C6_PRODUTO "
	EndIf
ElseIf MV_PAR05 == 2 // SINTETICO
	If MV_PAR06 == 1
		_cQry += " GROUP BY C6_PRODUTO,C6_DESCRI "
		_cQry += " ORDER BY C6_PRODUTO "
	ElseIf MV_PAR06 == 2// CLIENTE
		_cQry += " GROUP BY C6_CLI,C6_LOJA,C6_NUM,C6_PRODUTO,C6_DESCRI "
		_cQry += " ORDER BY C6_CLI,C6_LOJA,C6_NUM,C6_PRODUTO "
	ElseIf MV_PAR06 == 3// VENDEDOR
		_cQry += " GROUP BY C5_VEND1,C6_CLI,C6_LOJA,C6_NUM,C6_PRODUTO,C6_DESCRI "
		_cQry += " ORDER BY C5_VEND1,C6_NUM,C6_PRODUTO "
	EndIf
EndIf

_cQry += ""

/*
If TCSQLExec(_cQry) < 0
	//MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_01")
	MSGBOX("Nenhum dado encontrado conforme par�metros para a forma��o do relat�rio ", _cRotina+ "_01","ALERT")
EndIf
*/

_cQry := ChangeQuery(_cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"TRA",.T.,.F.)
dbSelectArea("TRA")
TRA->(dbSetOrder(0))

//���������������������������������������������������������������������Ŀ
//� SETREGUA -> Indica quantos registros serao processados para a regua �
//�����������������������������������������������������������������������

SetRegua(LastRec()) // substituido RecCount por LastRec por atualiza��es da TOTVS.
TRA->(dbGoTop())
While !(TRA->(EOF()))
	//���������������������������������������������������������������������Ŀ
	//� Verifica o cancelamento pelo usuario...                             �
	//�����������������������������������������������������������������������
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	//���������������������������������������������������������������������Ŀ
	//� Impressao do cabecalho do relatorio. . .                            �
	//�����������������������������������������������������������������������
	_cPed   := ''
	_cProd  := ''
	_cCli   := ''
	_cVend  := ''
	If MV_PAR05 == 1 // ANAL�TICO
		// PRODUTO
		If MV_PAR06 == 1 // 1=PRODUTO
			Cabec1 := "  C�DIGO     DESCRI��O "
			//Cabec2 := ""
			If _cProd <> (TRA->(C6_PRODUTO))
				//Imprime o cabe�alho de cada p�gina.
				If nLin > 60
					nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
				EndIf
				nLin ++
				@ nLin, 002 PSay (TRA->(C6_PRODUTO))
				@ nLin, 012 Psay (TRA->(C6_DESCRI ))
				@ nLin, 000 PSay REPLICATE ("_",130)
				nLin ++
				@ nLin, 002 Psay "PEDIDO"
				@ nLin, 012 Psay "C�DIGO"
				@ nLin, 022 Psay "LOJA"
				@ nLin, 028 Psay "NOME DO CLIENTE"
				@ nLin, 080 Psay "QTD. VENDA"
				@ nLin, 100 Psay "PRC. VENDA"
				@ nLin, 120 Psay "TOTAL"
				@ nLin, 000 PSay REPLICATE ("_",130)   
				nLin ++			
				_cProd := (TRA->(C6_PRODUTO))
				While !(TRA->(EOF())) .and. _cProd == TRA->(C6_PRODUTO)
					If nLin > 60
						nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
						nLin ++
						@ nLin, 002 PSay (TRA->(C6_PRODUTO))
						@ nLin, 012 Psay (TRA->(C6_DESCRI ))
						@ nLin, 000 PSay REPLICATE ("_",130)
						nLin ++
						@ nLin, 002 Psay "PEDIDO"
						@ nLin, 012 Psay "C�DIGO"
						@ nLin, 022 Psay "LOJA"
						@ nLin, 028 Psay "NOME DO CLIENTE"
						@ nLin, 080 Psay "QTD. VENDA"
						@ nLin, 100 Psay "PRC. VENDA"
						@ nLin, 120 Psay "TOTAL"
						@ nLin, 000 PSay REPLICATE ("_",130)   
						nLin ++								
					Endif
					@ nLin, 002 PSay (TRA->(C6_NUM    ))
					@ nLin, 012 PSay (TRA->(C6_CLI    ))
					@ nLin, 022 PSay (TRA->(C6_LOJA   ))
					@ nLin, 028 PSay (TRA->(C5_NOMCLI ))
					@ nLin, 070 PSay (TRA->(C6_QTDVEN )) Picture "@E 999,999,999.99"
					@ nLin, 090 PSay (TRA->(C6_PRCVEN )) Picture "@E 999,999,999.99"
					@ nLin, 110 PSay (TRA->(C6_VALOR  )) Picture "@E 999,999,999.99"
					_nQtdProd += (TRA->(C6_QTDVEN))
					_nValProd += (TRA->(C6_VALOR))
					_nQtdTot  += (TRA->(C6_QTDVEN))
					_nValTot  += (TRA->(C6_VALOR))				
					nLin ++
					(TRA->(dbSkip()))
				EndDo
				@ nLin, 000 PSay REPLICATE ("_",130)
				nLin ++
				@ nLin, 055 Psay "Qtd SubTotal"
				@ nLin, 070 Psay (_nQtdProd) Picture "@E 99,999,999.99"
				@ nLin, 090 Psay "Val. SubTotal"
				@ nLin, 105 Psay "R$ "	
				@ nLin, 110 Psay (_nValProd) Picture "@E 99,999,999.99"
				nLin ++
			EndIf
			_nQtdProd := 0
			_nValProd := 0
		// CLIENTE
	    ElseIf MV_PAR06 == 2 // 2=CLIENTE
			Cabec1 := "  C�DIGO  LOJA      DESCRI��O                              PEDIDO "
			//Cabec2 := ""
	    	If _cPed <> (TRA->(C6_CLI)) + (TRA->(C6_LOJA)) + (TRA->(C6_NUM))
	    	//If _cPed <> (TRA->(C6_NUM))
				If nLin > 56
					nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
				Endif		
				nLin ++
				@ nLin, 002 PSay (TRA->(C6_CLI    ))
				@ nLin, 010 PSay (TRA->(C6_LOJA   ))
				@ nLin, 020 PSay (TRA->(C5_NOMCLI ))
				@ nLin, 060 PSay (TRA->(C6_NUM    ))
				nLin ++
				@ nLin, 000 PSay REPLICATE ("_",130)
				@ nLin, 008 Psay "PRODUTO "
				@ nLin, 020 Psay "DESCRICAO "
				@ nLin, 080 Psay "QTD. PEDIDA "
				@ nLin, 100 Psay "PRC. VEND "
				@ nLin, 120 Psay "TOTAL "
				nLin ++
				_cPed := (TRA->(C6_CLI)) + (TRA->(C6_LOJA)) + (TRA->(C6_NUM))
				//_cPed := (TRA->(C6_NUM))
				While !(TRA->(EOF())) .and. _cPed == (TRA->(C6_CLI)) + (TRA->(C6_LOJA)) + (TRA->(C6_NUM))
					If nLin > 56
						nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
						nLin ++
						@ nLin, 002 PSay (TRA->(C6_CLI    ))
						@ nLin, 010 PSay (TRA->(C6_LOJA   ))
						@ nLin, 020 PSay (TRA->(C5_NOMCLI ))
						@ nLin, 060 PSay (TRA->(C6_NUM    ))
						nLin ++
						@ nLin, 000 PSay REPLICATE ("_",130)
						@ nLin, 008 Psay "PRODUTO "
						@ nLin, 020 Psay "DESCRICAO "
						@ nLin, 080 Psay "QTD. PEDIDA "
						@ nLin, 100 Psay "PRC. VEND "
						@ nLin, 120 Psay "TOTAL "
						nLin ++			
					Endif
					@ nLin, 008 PSay (TRA->(C6_PRODUTO))
					@ nLin, 020 Psay (TRA->(C6_DESCRI ))
					@ nLin, 070 PSay (TRA->(C6_QTDVEN )) Picture "@E 9,999,999,999.99"
					@ nLin, 090 PSay (TRA->(C6_PRCVEN )) Picture "@E 9,999,999,999.99"
					@ nLin, 110 PSay (TRA->(C6_VALOR  )) Picture "@E 9,999,999,999.99"
					_nQtdTot += (TRA->(C6_QTDVEN))
					_nValTot += (TRA->(C6_VALOR))
					nLin ++
					(TRA->(dbSkip()))
				EndDo
				@ nLin, 000 PSay REPLICATE ("_",130)
				/*nLin ++
				@ nLin, 055 Psay "QUANTIDADE TOTAL "
				@ nLin, 070 Psay (_nQtdTot) Picture "@E 99,999,999.99"
				@ nLin, 090 Psay "VALOR TOTAL "
				@ nLin, 105 Psay "R$ "	
				@ nLin, 110 Psay (_nValTot) Picture "@E 99,999,999.99"
				nLin ++
				@ nLin, 000 PSay REPLICATE ("_",130)*/			
			EndIf
		// - VENDEDOR
	    ElseIf MV_PAR06 == 3 // 3 = Vendedor

			// Altera��o - Fernando Bombardi - ALLSS - 02/03/2022
			//Cabec1 := "  VENDEDOR       PEDIDO  "
			Cabec1 := "  REPRESEN       PEDIDO  "
			// Fim - Fernando Bombardi - ALLSS - 02/03/2022

			If _cVend <> (TRA->(C5_VEND1))
				//Imprime o cabe�alho de cada p�gina.
				If nLin > 60
					nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
				EndIf
				nLin++
				@ nLin, 002 PSay (TRA->(C5_VEND1))
				@ nLin, 012 Psay (TRA->(C5_DESCVEN))
				@ nLin, 000 PSay REPLICATE ("_",130)
				nLin++
				@ nLin, 002 Psay "PEDIDO"
				@ nLin, 012 Psay "C�DIGO"
				@ nLin, 022 Psay "LOJA"
				@ nLin, 028 Psay "NOME DO CLIENTE"
				@ nLin, 080 Psay "QTD. VENDA"
				@ nLin, 100 Psay "PRC. VENDA"
				@ nLin, 120 Psay "TOTAL"
				@ nLin, 000 PSay REPLICATE ("_",130)
				nLin++
				_cVend := (TRA->(C5_VEND1))
				While !(TRA->(EOF())) .and. _cVend == TRA->(C5_VEND1)
					If nLin > 60
						nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
						nLin++
	  					@ nLin, 002 PSay (TRA->(C5_VEND1))
						@ nLin, 012 Psay (TRA->(C5_DESCVEN ))
						@ nLin, 000 PSay REPLICATE ("_",130)
						nLin++
						@ nLin, 002 Psay "PEDIDO"
						@ nLin, 012 Psay "C�DIGO"
						@ nLin, 022 Psay "LOJA"
						@ nLin, 028 Psay "NOME DO CLIENTE"
						@ nLin, 080 Psay "QTD. VENDA"
						@ nLin, 100 Psay "PRC. VENDA"
						@ nLin, 120 Psay "TOTAL"
						@ nLin, 000 PSay REPLICATE ("_",130)   
						nLin++								
					Endif
					//@ nLin, 012 PSay (TRA->(C6_CLI    ))
					//@ nLin, 022 PSay (TRA->(C6_LOJA   ))
					//@ nLin, 028 PSay (TRA->(C5_NOMCLI ))
					//@ nLin, 002 PSay (TRA->(C6_PRODUTO))
					///@ nLin, 012 Psay (TRA->(C6_DESCRI ))
					//@ nLin, 070 PSay (TRA->(C6_QTDVEN )) Picture "@E 999,999,999.99"
					//@ nLin, 090 PSay (TRA->(C6_PRCVEN )) Picture "@E 999,999,999.99"
					//@ nLin, 110 PSay (TRA->(C6_VALOR  )) Picture "@E 999,999,999.99"
	//				_nQtdTot  += (TRA->(C6_QTDVEN))
	//				_nValTot  += (TRA->(C6_VALOR))				
					nLin++
					(TRA->(dbSkip()))
				EndDo
	/*			@ nLin, 000 PSay REPLICATE ("_",130)
				nLin ++
				@ nLin, 055 Psay "Qtd SubTotal"
				@ nLin, 070 Psay (_nQtdProd) Picture "@E 99,999,999.99"
				@ nLin, 090 Psay "Val. SubTotal"
				@ nLin, 105 Psay "R$ "	
				@ nLin, 110 Psay (_nValProd) Picture "@E 99,999,999.99"
				nLin++*/
			EndIf
	//		_nQtdProd := 0
	//		_nValProd := 0
		EndIf
	ElseIf MV_PAR05 == 2 // SINT�TICO
		If MV_PAR06 == 1 // 1=PRODUTO
		Cabec1 := "   C�DIGO     DESCRI��O                                                     QTD. VENDA        VALOR TOTAL"
		Cabec2 := ""
			If _cProd <> (TRA->(C6_PRODUTO))
				If nLin > 60
					nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
				EndIf
			Endif
		    nLin++
			@ nLin, 005 PSay (TRA->(C6_PRODUTO))
			@ nLin, 015 Psay (TRA->(C6_DESCRI ))
			//@ nLin, 065 Psay (TRA->(C6_UN)) - verificar 
			@ nLin, 070 PSay (TRA->(C6_QTDVEN )) Picture "@E 9,999,999,999.99"
			@ nLin, 090 PSay (TRA->(C6_VALOR  )) Picture "@E 9,999,999,999.99"
			@ nLin, 000 PSay REPLICATE ("_",130)   
			nLin++
			_nQtdTot += (TRA->(C6_QTDVEN))
			_nValTot += (TRA->(C6_VALOR ))		
		ElseIf MV_PAR06 == 2 // 2=CLIENTE
			@ nLin, 002 PSay (TRA->(C6_CLI))
			@ nLin, 010 Psay (TRA->(C6_LOJA ))
			@ nLin, 020 Psay POSICIONE("SA1",1,xFilial("SA1")+TRA->(C6_CLI+C6_LOJA),"A1_NOME")
			@ nLin, 059 PSay (TRA->(C6_NUM ))
			@ nLin, 000 PSay REPLICATE ("_",130)   
		EndIf
	EndIf
	dbSelectArea("TRA")
	TRA->(dbSetOrder(0))	
	TRA->(dbSkip()) // Avanca o ponteiro do registro no arquivo
EndDo

// - Totalizadores
If _nValTot > 0 .or. _nQtdTot > 0
//���������������������������������������������������������������������Ŀ
//� Verifica o cancelamento pelo usuario...                             �
//�����������������������������������������������������������������������
	If lAbortPrint
		@nLin,000 PSay "CANCELADO PELO OPERADOR"
	EndIf
	If nLin > 60
		nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Endif
	nLin++
	@ nLin, 000 PSay REPLICATE ("_",130)
	@ nLin, 055 Psay "QUANTIDADE TOTAL "
	@ nLin, 070 Psay (_nQtdTot) Picture "@E 99,999,999.99"

	@ nLin, 090 Psay "VALOR TOTAL "
	@ nLin, 105 Psay "R$ "	
	@ nLin, 110 Psay (_nValTot) Picture "@E 99,999,999.99"
	nLin++
EndIf

//���������������������������������������������������������������������Ŀ
//� Finaliza a execucao do relatorio...                                 �
//�����������������������������������������������������������������������

SET DEVICE TO SCREEN

//���������������������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenciador de impressao...          �
//�����������������������������������������������������������������������

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VALIDPERG �Autor  �J�lio Soares          � Data �  26/07/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida se as perguntas est�o criadas no arquivo SX1 e caso ���
���          � n�o as encontre ele as cria.                               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ValidPerg()

Local i
Local j
Local _sAlias := GetArea()
Local aRegs :={}
cPerg := PADR(cPerg,10)

AADD(aRegs,{cPerg,"01","De  Emisss�o?" ,"","","mv_ch1" ,"D",08,0,0,"G",""           ,"mv_par01",""       ,"","","","",""       ,"","","","",""        ,"","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"02","At� Emisss�o?" ,"","","mv_ch2" ,"D",08,0,0,"G","NaoVazio()" ,"mv_par02",""       ,"","","","",""       ,"","","","",""        ,"","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"03","De  Produto?"  ,"","","mv_ch3" ,"C",06,0,0,"G",""           ,"mv_par03",""       ,"","","","",""       ,"","","","",""        ,"","","","","","","","","","","","","","SB1",""})
AADD(aRegs,{cPerg,"04","At� Produto?"  ,"","","mv_ch4" ,"C",06,0,0,"G","NaoVazio()" ,"mv_par04",""       ,"","","","",""       ,"","","","",""        ,"","","","","","","","","","","","","","SB1",""})
AADD(aRegs,{cPerg,"05","Anal�tico?"    ,"","","mv_ch5" ,"C",01,0,0,"C",""           ,"mv_par05","SIM"    ,"","","","","NAO"    ,"","","","",""        ,"","","","","","","","","","","","","",""   ,""})

// Altera��o - Fernando Bombardi - ALLSS - 02/03/2022
//AADD(aRegs,{cPerg,"06","Ordem?"        ,"","","mv_ch6" ,"C",01,0,0,"C",""           ,"mv_par06","PRODUTO","","","","","CLIENTE","","","","","VENDEDOR","","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"06","Ordem?"        ,"","","mv_ch6" ,"C",01,0,0,"C",""           ,"mv_par06","PRODUTO","","","","","CLIENTE","","","","","REPRESENTANTE","","","","","","","","","","","","","",""   ,""})
// Fim - Fernando Bombardi - ALLSS - 02/03/2022

AADD(aRegs,{cPerg,"07","De  Cliente?"  ,"","","mv_ch7" ,"C",06,0,0,"G",""           ,"mv_par07",""       ,"","","","",""       ,"","","","",""        ,"","","","","","","","","","","","","","SA1",""})
AADD(aRegs,{cPerg,"08","De  Loja?"     ,"","","mv_ch8" ,"C",02,0,0,"G",""           ,"mv_par08",""       ,"","","","",""       ,"","","","",""        ,"","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"09","At� Cliente?"  ,"","","mv_ch9" ,"C",06,0,0,"G","NaoVazio()" ,"mv_par09",""       ,"","","","",""       ,"","","","",""        ,"","","","","","","","","","","","","","SA1",""})
AADD(aRegs,{cPerg,"10","At� Loja?"     ,"","","mv_cha" ,"C",02,0,0,"G","NaoVazio()" ,"mv_par10",""       ,"","","","",""       ,"","","","",""        ,"","","","","","","","","","","","","",""   ,""})

// Altera��o - Fernando Bombardi - ALLSS - 02/03/2022
//AADD(aRegs,{cPerg,"11","De Vendedor?"  ,"","","mv_chb" ,"C",06,0,0,"G",""           ,"mv_par11",""       ,"","","","",""       ,"","","","",""        ,"","","","","","","","","","","","","","SA3",""})
//AADD(aRegs,{cPerg,"12","At� Vendedor?" ,"","","mv_chc" ,"C",06,0,0,"G","NaoVazio()" ,"mv_par12",""       ,"","","","",""       ,"","","","",""        ,"","","","","","","","","","","","","","SA3",""})

AADD(aRegs,{cPerg,"11","De Representante?"  ,"","","mv_chb" ,"C",06,0,0,"G",""           ,"mv_par11",""       ,"","","","",""       ,"","","","",""        ,"","","","","","","","","","","","","","SA3",""})
AADD(aRegs,{cPerg,"12","At� Representante?" ,"","","mv_chc" ,"C",06,0,0,"G","NaoVazio()" ,"mv_par12",""       ,"","","","",""       ,"","","","",""        ,"","","","","","","","","","","","","","SA3",""})
// Fim - Fernando Bombardi - ALLSS - 02/03/2022

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

Return
