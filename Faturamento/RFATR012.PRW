#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE CENT CHR(13) + CHR(10)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATR012  � Autor �Anderson C. P. Coelho � Data �  06/06/13 ���
�������������������������������������������������������������������������͹��
���Descricao � Relat�rio de pedidos pendentes                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
user function RFATR012()
	Relat()
	/*
	If ExistBlock("RFATR036") .AND. FindFunction("TRepInUse") .AND. TRepInUse()
		ExecBlock("RFATR036")
	Else
		Relat()
	EndIf
	*/
return
static function Relat()
	//���������������������������������������������������������������������Ŀ
	//� Declaracao de Variaveis                                             �
	//�����������������������������������������������������������������������
	Local cDesc1       := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       := "de acordo com os parametros informados pelo usuario."
	Local cDesc3       := "Relat�rio de Pedidos Pendentes"
	Local cPict        := ""
	Local titulo       := "Pedidos"
	Local nLin         := 80
	Local Cabec1       := "Emiss�o    Pedido Cliente                                            Valor Total"
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
	Private nomeprog   := "RFATR012" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo      := 18
	Private aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private _aTpOper   := {}
	Private nLastKey   := 0
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := nomeprog // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _cRotina   := nomeprog
	Private cPerg      := nomeprog
	Private cString    := "SC5"

	ValidPerg()
	If !Pergunte(cPerg,.T.)
		return
	EndIf
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	//���������������������������������������������������������������������Ŀ
	//� Monta a interface padrao com o usuario...                           �
	//�����������������������������������������������������������������������
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,/*aOrd*/,.T.,Tamanho,,.T.)
	If nLastKey == 27
		Return
	EndIf
	SetDefault(aReturn,cString)
	If nLastKey == 27
	   return
	EndIf
	nTipo := If(aReturn[4]==1,15,18)
	If MV_PAR01 == 1		//PENDENTES
		Titulo := AllTrim(Titulo) + " - PENDENTES"
	ElseIf MV_PAR01 == 2	//SALDO
		Titulo := AllTrim(Titulo) + " - SALDOS"
	ElseIf MV_PAR01 == 3	//AMBOS
		Titulo := AllTrim(Titulo) + " - AMBOS"
	ElseIf MV_PAR01 == 4	//FATURADO
		Titulo := AllTrim(Titulo) + " - FATURADOS"
	ElseIf MV_PAR01 == 5	//CANCELADOS
		Titulo := AllTrim(Titulo) + " - CANCELADOS"
	EndIf
	//���������������������������������������������������������������������Ŀ
	//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
	//�����������������������������������������������������������������������
	If Len(_aTpOper := aClone(U_SELMARQ())) > 0
		RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	EndIf
return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor �Anderson C. P. Coelho � Data �  06/06/13 ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
static function RunReport(Cabec1,Cabec2,Titulo,nLin)
	Local _x
	Local nOrdem
	Local oExcel
	Local cString := "TBTMP"
	Local _nVTot  := 0
	Local _nVTotV := 0
	Local _nPVs   := 0

	_cQry := " SELECT C5_EMISSAO EMISSAO, " + CENT
	_cQry += " 	      C5_NUM     PEDIDO,  " + CENT
	_cQry += " 	      C5_VEND1   VENDEDOR," + CENT
	_cQry += " 	      C5_CLIENTE CLIENTE, " + CENT
	_cQry += " 	      C5_LOJACLI LOJA,    " + CENT
	_cQry += " 	      NOME,               " + CENT
	//_cQry += " 	      SUM(QUANT) QUANT,   " + CENT
	_cQry += " 	      SUM(TOTAL) TOTAL    " + CENT
	_cQry += " FROM ( " + CENT
	_cQry += " 		SELECT C5_EMISSAO, C5_NUM, C5_VEND1, C5_CLIENTE, C5_LOJACLI,  " + CENT
	_cQry += " 				(CASE  " + CENT
	_cQry += " 					WHEN C5_TIPO IN ('D','B')  " + CENT
	_cQry += " 						THEN (	SELECT A2_NOME  " + CENT
	_cQry += " 								FROM " + RetSqlName("SA2") + " SA2  " + CENT
	_cQry += " 								WHERE SA2.A2_FILIAL  = '" + xFilial("SA2") + "' " + CENT
	_cQry += " 								  AND SA2.A2_COD     = SC5.C5_CLIENTE  " + CENT
	_cQry += " 								  AND SA2.A2_LOJA    = SC5.C5_LOJACLI  " + CENT
	_cQry += " 								  AND SA2.D_E_L_E_T_ = '') " + CENT
	_cQry += " 						ELSE (	SELECT A1_NOME  " + CENT
	_cQry += " 								FROM " + RetSqlName("SA1") + " SA1  " + CENT
	_cQry += " 								WHERE SA1.A1_FILIAL  = '" + xFilial("SA1") + "' " + CENT
	_cQry += " 								  AND SA1.A1_COD     = SC5.C5_CLIENTE  " + CENT
	_cQry += " 								  AND SA1.A1_LOJA    = SC5.C5_LOJACLI  " + CENT
	_cQry += " 								  AND SA1.D_E_L_E_T_ = '') " + CENT
	_cQry += " 				END) NOME, " + CENT
	//_cQry += " 				( SC6.C6_QTDVEN - SC6.C6_QTDENT) QUANT,  " + CENT
	If MV_PAR01 == 4	//FATURADO
		_cQry += " 				(SC6.C6_QTDENT * SC6.C6_PRCVEN) TOTAL " + CENT
	Else
		_cQry += " 				((SC6.C6_QTDVEN - SC6.C6_QTDENT) * SC6.C6_PRCVEN) TOTAL " + CENT
	EndIf
	_cQry += " 		FROM " + RetSqlName("SC5") + " SC5 " + CENT
	_cQry += " 		 INNER JOIN " + RetSqlName("SC6") + " SC6 ON SC6.C6_FILIAL   = '" + xFilial("SC6") + "' " + CENT
	If MV_PAR01 == 1		//PENDENTES
	/*
		//Trecho comentado por Adriano Leonardo em 29/08/2013 para melhoria na rotina (desempenho)
		_cQry += " 		  AND SC5.C5_NUM NOT IN (SELECT DISTINCT D2_PEDIDO " + CENT
		_cQry += " 		                         FROM " + RetSqlName("SD2") + " SD2 " + CENT
		_cQry += " 		                         WHERE SD2.D_E_L_E_T_ = '' " + CENT
		_cQry += " 		                           AND SD2.D2_PEDIDO  = SC5.C5_NUM)  " + CENT
	*/
		_cQry += " 		  AND SC6.C6_QTDENT < SC6.C6_QTDVEN " + CENT
		_cQry += " 		  AND (SELECT SUM(SC6A.C6_QTDENT) " + CENT
		_cQry += "             FROM " + RetSqlName("SC6") + " SC6A " + CENT
		_cQry += " 		       WHERE SC6A.C6_FILIAL  = '" + xFilial("SC6") +  "' " + CENT
		_cQry += " 		         AND SC6A.C6_NUM     = SC5.C5_NUM " + CENT
		_cQry += " 		         AND SC6A.D_E_L_E_T_ = '' " + CENT
		_cQry += " 		       ) = 0 " + CENT
		_cQry += " 		  AND SC6.C6_BLQ <> 'R' " + CENT	//Linha adicionada por Adriano Leonardo em 29/08/2013 para melhoria na rotina	
		_cQry += " 		  AND SUBSTRING(C5_NOTA,1,1) <> 'X' " + CENT	//Linha inserida por J�lio Soares em 18/10/2013 para ajustar itens eliminados por res�duo no relat�rio
	ElseIf MV_PAR01 == 2	//SALDO
		_cQry += " 		  AND SC6.C6_QTDENT < SC6.C6_QTDVEN  " + CENT
		_cQry += " 		  AND (SELECT SUM(SC6A.C6_QTDENT) " + CENT
		_cQry += " 		       FROM " + RetSqlName("SC6") + " SC6A " + CENT
		_cQry += " 		       WHERE SC6A.C6_FILIAL  = '" + xFilial("SC6") + "' " + CENT
		_cQry += " 		         AND SC6A.C6_NUM     = SC5.C5_NUM " + CENT
		_cQry += " 		         AND SC6A.D_E_L_E_T_ = '' " + CENT
		_cQry += " 		       ) > 0 " + CENT
		_cQry += " 		  AND SC6.C6_BLQ <> 'R' " + CENT //Linha adicionada por Adriano Leonardo em 29/08/2013 para melhoria na rotina
		_cQry += " 		  AND SUBSTRING(C5_NOTA,1,1) <> 'X' " + CENT //Linha inserida por J�lio Soares em 18/10/2013 para ajustar itens eliminados por res�duo no relat�rio
	/*	
		//Trecho comentado por Adriano Leonardo em 29/08/2013 para melhoria na rotina (desempenho)
		_cQry += " 		  AND SC5.C5_NUM IN (SELECT DISTINCT D2_PEDIDO " + CENT
		_cQry += " 		                     FROM " + RetSqlName("SD2") + " SD2 " + CENT
		_cQry += " 		                     WHERE SD2.D_E_L_E_T_  = '' " + CENT
		_cQry += " 		                       AND SD2.D2_EMISSAO >= SC5.C5_EMISSAO) " + CENT //Linha adicionada por Adriano Leonardo em 29/08/2013 para melhoria na rotina	_cQry += " 		                       AND SD2.D2_PEDIDO = SC5.C5_NUM)  "
	*/
	ElseIf MV_PAR01 == 3 /*.OR. MV_PAR01 == 5*/	//AMBOS
		_cQry += " 		  AND SC6.C6_QTDENT < SC6.C6_QTDVEN " + CENT
		_cQry += " 		  AND SC6.C6_BLQ <> 'R' " + CENT 				//Linha adicionada por Adriano Leonardo em 22/10/2013 para corre��o da rotina
		_cQry += " 		  AND SUBSTRING(C5_NOTA,1,1) <> 'X' " + CENT 	//Linha adicionada por Adriano Leonardo em 22/10/2013 para corre��o da rotina
	ElseIf MV_PAR01 == 4	//FATURADO
	//	_cQry += " 		  AND SC6.C6_QTDENT >= SC6.C6_QTDVEN " + CENT
		_cQry += " 		  AND SC6.C6_QTDENT > 0 " + CENT
	EndIf
	//Trecho adicionado por Adriano Leonardo em 15/08/2013
	If MV_PAR01 == 5 // RES�DUOS
	//Trecho alterado por J�lio Soares em 18/10/2013 para implementar o tratamento de pedidos eliminados por res�duo.
		_cQry += " 	  AND (SC6.C6_BLQ = 'R' OR SUBSTRING(C5_NOTA,1,1)  = 'X') " + CENT
	ElseIf MV_PAR01 <> 4	//FATURADO                                        
		_cQry += " 	  AND (SC6.C6_BLQ<> 'R' OR SUBSTRING(C5_NOTA,1,1) <> 'X') " + CENT
	EndIf
	//Final do trecho adicionado por Adriano Leonardo em 15/08/2013
	_cQry += " 		  AND SC6.C6_NUM     = SC5.C5_NUM " + CENT
	_cQry += " 		  AND SC6.D_E_L_E_T_ = '' " + CENT
	/*
	_cQry += " 		 INNER JOIN " + RetSqlName("SF4") + " SF4 ON SF4.D_E_L_E_T_ = '' " + CENT
	_cQry += " 		  AND SF4.F4_FILIAL   = '" + xFilial("SF4") + "' " + CENT
	_cQry += " 		  AND SF4.F4_DUPLIC   = 'S' " + CENT
	_cQry += " 		  AND SF4.F4_CODIGO   = SC6.C6_TES " + CENT
	*/
	_cQry += " 		WHERE SC5.C5_FILIAL        = '" + xFilial("SC5") + "' " + CENT
	_cQry += " 		  AND SC5.C5_EMISSAO BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "' " + CENT
	_cQry += "        AND (SC5.C5_TIPO = 'N' OR SC5.C5_TIPO = 'P') " + CENT
	// Trecho inserido por J�lio Soares em 18/10/2013 para implementar o vendedor como par�metro no filtro.
	_cQry += " 		  AND SC5.C5_VEND1   BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "' " + CENT
	// Final do trecho inserido por J�lio Soares em 18/10/2013 para implementar o vendedor como par�metro no filtro.
	_cQry += "        AND SC5.C5_TPOPER       IN ('"
	For _x := 1 To Len(_aTpOper)
		If _x > 1
			_cQry += "','"
		EndIf
		_cQry += _aTpOper[_x]
	Next
	_cQry += "')" + CENT
	_cQry += "        AND SC5.D_E_L_E_T_       = '' " + CENT
	_cQry += " 	) PV " + CENT
	// - Trecho alterado em 23/11/2015 por J�lio Soares para altera��o da ordena��o a pedido do Sr. Scott.
	//_cQry += " GROUP BY C5_EMISSAO, C5_VEND1, C5_NUM, C5_CLIENTE, C5_LOJACLI, NOME " + CENT
	//_cQry += " ORDER BY C5_EMISSAO, C5_VEND1, C5_CLIENTE, C5_LOJACLI, NOME, C5_NUM " + CENT
	_cQry += " GROUP BY C5_VEND1, C5_EMISSAO, C5_NUM, C5_CLIENTE, C5_LOJACLI, NOME " + CENT
	_cQry += " ORDER BY C5_VEND1, C5_EMISSAO, C5_CLIENTE, C5_LOJACLI, NOME, C5_NUM " + CENT
	//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.txt",_cQry)
	_cQry := ChangeQuery(_cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cString,.T.,.F.)
	dbSelectArea(cString)
	SetRegua(RecCount())
	(cString)->(dbGoTop())
	If !(cString)->(EOF())
		oExcel := FWMSExcel():New()
		oExcel:AddWorkSheet(Titulo)
		oExcel:AddTable(Titulo,"Listagem1")
		oExcel:AddColumn(Titulo,"Listagem1","Emiss�o",2,1,.F.)
		oExcel:AddColumn(Titulo,"Listagem1","Pedido" ,2,1,.F.)
		oExcel:AddColumn(Titulo,"Listagem1","Cliente",1,1,.F.)
		oExcel:AddColumn(Titulo,"Listagem1","Valor"  ,3,2,.T.)
		_cVend := (cString)->VENDEDOR
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin    := 8

		// Altera��o - Fernando Bombardi - ALLSS - 02/03/2022
		//@nLin,000 PSAY "VENDEDOR: " + (cString)->VENDEDOR + " - " + POSICIONE("SA3",1,xFilial("SA3")+(cString)->VENDEDOR,"A3_NOME")
		@nLin,000 PSAY "REPRESENTANTE: " + (cString)->VENDEDOR + " - " + POSICIONE("SA3",1,xFilial("SA3")+(cString)->VENDEDOR,"A3_NOME")
		// Fim - Fernando Bombardi - ALLSS - 02/03/2022

		nLin++
		While !(cString)->(EOF())
			//���������������������������������������������������������������������Ŀ
			//� Verifica o cancelamento pelo usuario...                             �
			//�����������������������������������������������������������������������
			If lAbortPrint
				@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			EndIf
			//���������������������������������������������������������������������Ŀ
			//� Impressao do cabecalho do relatorio. . .                            �
			//�����������������������������������������������������������������������
			If _cVend <> (cString)->VENDEDOR

				// Altera��o - Fernando Bombardi - ALLSS - 02/03/2022
				//@nLin,000 PSAY "Sub-Total Vendedor " + _cVend + " - " + SubStr(POSICIONE("SA3",1,xFilial("SA3")+_cVend,"A3_NOME"),1,30)
				@nLin,000 PSAY "Sub-Total Representante " + _cVend + " - " + SubStr(POSICIONE("SA3",1,xFilial("SA3")+_cVend,"A3_NOME"),1,30)
				// Fim - Fernando Bombardi - ALLSS - 02/03/2022
				
				@nLin,062 PSAY _nVTotV        Picture "@E 999,999,999,999.99"
				_nVTotV := 0
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin    := 8

				// Altera��o - Fernando Bombardi - ALLSS - 02/03/2022
				//@nLin,000 PSAY "VENDEDOR: " + (cString)->VENDEDOR + " - " + POSICIONE("SA3",1,xFilial("SA3")+(cString)->VENDEDOR,"A3_NOME")
				@nLin,000 PSAY "REPRESENTANTE: " + (cString)->VENDEDOR + " - " + POSICIONE("SA3",1,xFilial("SA3")+(cString)->VENDEDOR,"A3_NOME")
				// Fim - Fernando Bombardi - ALLSS - 02/03/2022

				nLin++
			ElseIf nLin > 55
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin    := 8
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
			_nPVs++
			_nVTot  += (cString)->TOTAL
			_nVTotV += (cString)->TOTAL
			_cVend  := (cString)->VENDEDOR
			_aRow   := {DTOC(STOD((cString)->EMISSAO))                            ,;
						(cString)->PEDIDO                                         ,;
						((cString)->CLIENTE+(cString)->LOJA+" - "+(cString)->NOME),;
						(cString)->TOTAL                                           }
			oExcel:AddRow(Titulo,"Listagem1",_aRow)
			(cString)->(dbSkip())
		EndDo
		If _nVTot > 0
			//���������������������������������������������������������������������Ŀ
			//� Verifica o cancelamento pelo usuario...                             �
			//�����������������������������������������������������������������������
			If lAbortPrint
				@nLin,000 PSAY "*** CANCELADO PELO OPERADOR ***"
			EndIf
			//���������������������������������������������������������������������Ŀ
			//� Impressao do cabecalho do relatorio. . .                            �
			//�����������������������������������������������������������������������
			If nLin > 55
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin    := 8
			EndIf
			// Altera��o - Fernando Bombardi - ALLSS - 02/03/2022
			//@nLin,000 PSAY "Sub-Total Vendedor " + _cVend + " - " + SubStr(POSICIONE("SA3",1,xFilial("SA3")+_cVend,"A3_NOME"),1,30)
			@nLin,000 PSAY "Sub-Total Representante " + _cVend + " - " + SubStr(POSICIONE("SA3",1,xFilial("SA3")+_cVend,"A3_NOME"),1,30)
			// Fim - Fernando Bombardi - ALLSS - 02/03/2022
			
			@nLin,062 PSAY _nVTotV        Picture "@E 999,999,999,999.99"
			nLin++
			//���������������������������������������������������������������������Ŀ
			//� Impressao do cabecalho do relatorio. . .                            �
			//�����������������������������������������������������������������������
			If nLin > 55
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin    := 8
			EndIf
			nLin++
			@nLin,000 PSAY Replicate("_",Limite)
			nLin++
			@nLin,000 PSAY "TOTAL ("+cValToChar(_nPVs)+" pedido"+IIF(_nPVs>1,"s","")+")"
			@nLin,062 PSAY _nVTot         Picture "@E 999,999,999,999.99"
		EndIf
		oExcel:Activate()
		_cArq    := _cRotina+" - "+Titulo+".xml"
		_cDirTmp := GetTempPath()
		oExcel:GetXmlFile(_cArq)
		If File(_cArq) .AND. __CopyFile(_cArq,_cDirTmp+_cArq)
			FErase(_cArq)
		//	oExcelApp := MsExcel():New()
		//	oExcelApp:WorkBooks:Open(_cDirTmp+_cArq)
		//	oExcelApp:SetVisible(.T.)
		EndIF
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
	EndIf
	MS_FLUSH()
	dbSelectArea(cString)
	(cString)->(dbCloseArea())
return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VALIDPERG �Autor  �Anderson C. P. Coelho � Data �  06/06/13 ���
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
Local aRegs   := {}

cPerg         := PADR(cPerg,10)
AADD(aRegs,{cPerg,"01","Status?"      ,"","","mv_ch1","N",01,0,0,"C","","mv_par01","Pendentes","","","","","Saldo","","","","","Ambos","","","","","Faturados","","","","","Cancelados","","","",""   ,""})
AADD(aRegs,{cPerg,"02","De  Emisss�o?","","","mv_ch2","D",08,0,0,"G","","mv_par02",""         ,"","","","",""     ,"","","","",""     ,"","","","",""         ,"","","","",""          ,"","","",""   ,""})
AADD(aRegs,{cPerg,"03","At� Emisss�o?","","","mv_ch3","D",08,0,0,"G","","mv_par03",""         ,"","","","",""     ,"","","","",""     ,"","","","",""         ,"","","","",""          ,"","","",""   ,""})

// Altera��o - Fernando Bombardi - ALLSS - 02/03/2022
//AADD(aRegs,{cPerg,"04","De Vendedor?" ,"","","mv_ch4","C",06,0,0,"G","","mv_par04",""         ,"","","","",""     ,"","","","",""     ,"","","","",""         ,"","","","",""          ,"","","","SA3",""})
//AADD(aRegs,{cPerg,"05","At� Vendedor?","","","mv_ch5","C",06,0,0,"G","","mv_par05",""         ,"","","","",""     ,"","","","",""     ,"","","","",""         ,"","","","",""          ,"","","","SA3",""})

AADD(aRegs,{cPerg,"04","De Representante?" ,"","","mv_ch4","C",06,0,0,"G","","mv_par04",""         ,"","","","",""     ,"","","","",""     ,"","","","",""         ,"","","","",""          ,"","","","SA3",""})
AADD(aRegs,{cPerg,"05","At� Representante?","","","mv_ch5","C",06,0,0,"G","","mv_par05",""         ,"","","","",""     ,"","","","",""     ,"","","","",""         ,"","","","",""          ,"","","","SA3",""})
// Fim - Fernando Bombardi - ALLSS - 02/03/2022

dbSelectArea("SX1")
SX1->(dbSetOrder(1))
For i := 1 To Len(aRegs)
	If !SX1->(MsSeek(cPerg+aRegs[i,2],.T.,.F.))
		RecLock("SX1",.T.)
		For j := 1 To FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Else              
				Exit
			EndIf
		Next
		SX1->(MsUnLock())
	EndIf
Next

RestArea(_sAlias)

Return
