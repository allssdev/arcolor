#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa �RPCPR001  �Autor �Anderson C. P. Coelho   � Data �  21/03/13 ���
���         �Alterado: �Autor �Thiago Silva de Almeida � Data �  02/04/13 ���
�������������������������������������������������������������������������͹��
���Descricao � Impressao da Ordem de Producao, separando os demais        ���
���          � produtos dos produtos do tipo 'EM'.                        ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Especifico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function RPCPR007()

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local cDesc1	:= "Este programa tem como objetivo imprimir relatorio "
Local cDesc2	:= "de acordo com os parametros informados pelo usuario."
Local cDesc3	:= "Ordens de Producao"
//Local cPict		:= ""
Local titulo	:= "Ordens de Producao"
Local Cabec1	:= "PRODUTO          DESCRICAO                      ARM       QUANT.      SALD EST."
//                     XXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXX   XX  999,999,999.99   999,999,999.99
//                     0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                     0         10        20        30        40        50        60        70        80        90        100       110       120
Local Cabec2	:= ""
Local nLin		:= 80
//Local imprime	:= .T.
//Local aOrd		:= {}

Private CbTxt		:= ""
Private tamanho		:= "P"
Private nomeprog	:= "RPCPR007" // Coloque aqui o nome do programa para impressao no cabecalho
Private cString		:= "SC2"
Private cbtxt		:= Space(10)
Private cbcont		:= 00
Private CONTFL		:= 01
Private wnrel		:= nomeprog // Coloque aqui o nome do arquivo usado para impressao em disco
Private cPerg		:= nomeprog
Private _cRotina	:= nomeprog
Private _cMsg       := ""
Private _cValidUsr  := SuperGetMv("MV_ORDPIMP",,"000000")
Private nTipo		:= 18
Private nLastKey	:= 0
Private m_pag		:= 01
Private _nImp		:= 0
Private aReturn		:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private lEnd		:= .F.
Private lAbortPrint	:= .F.
Private limite		:= 80
Private _lEnt       := CHR(13) + CHR(10)

ValidPerg()
If !Pergunte(cPerg,.T.)
	Return()
EndIf

dbSelectArea("SC2")
SC2->(dbSetOrder(1))
//TRATAMENTO INICIADO PARA BLOQUEIO DE IMPRESS�ES
If SC2->(MsSeek(xFilial("SC2")+MV_PAR01,.T.,.F.))
	While !SC2->(EOF()) .AND. SC2->C2_FILIAL == xFilial("SC2") .AND. SC2->(C2_NUM+C2_ITEM+C2_SEQUEN) <= MV_PAR02
		If SC2->C2_NUMPAGS >= 1
			_cMsg += Alltrim(SC2->(C2_NUM+C2_ITEM+C2_SEQUEN))
			_cMsg += _lEnt
			If Len(_cMsg) >= 999999
				MSGBOX("Falha na quantidade de informa��es a serem apresentadas! Selecione um range menor de Ordens para impress�o.",_cRotina+"_001","STOP")
				Return()
			EndIf
		EndIf
		dbSelectArea("SC2")
		SC2->(dbSetOrder(1))
		SC2->(dbSkip())
	EndDo
	If !Empty(_cMsg)
		If !MSGBOX("As Ordens de produ��o abaixo j� foram impressas e s� poder�o ser emitidas novamente por um usu�rio autorizado."+_lEnt+_cMsg+_lEnt+"Deseja prosseguir?",_cRotina+"_002","YESNO")
			Return()
		EndIf
	EndIf
EndIf
                                  
//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,/*aOrd*/,.F.,Tamanho,,.T.)

If nLastKey == 27
	Return()
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return()
Endif

nTipo := If(aReturn[4]==1,15,18)

//���������������������������������������������������������������������Ŀ
//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
//�����������������������������������������������������������������������
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RunReport � Autor �Anderson C. P. Coelho � Data �  21/03/13 ���
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

//Local nOrdem
Local _lImpEm := .F.

dbSelectArea("SC2")
SC2->(dbSetOrder(1))
SetRegua(RecCount())
If SC2->(MsSeek(xFilial("SC2") + MV_PAR01,.F.,.F.))
	While !SC2->(EOF()) .AND. SC2->C2_FILIAL == xFilial("SC2") .AND. (SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN) <= MV_PAR02
		// - INICIADO TRATAMENTO PARA BLOQUEIO DE NUMERA��O DE P�GINAS
		If SC2->C2_NUMPAGS >= 1 .AND. !__cUserId $ _cValidUsr
			dbSelectArea("SC2")
			SC2->(dbSetOrder(1))
			SC2->(dbSkip())
			Loop
		EndIf
		// - FIM
		_cAlias := "SD4TMP"
		For _x := 1 To 2
			_cQry := " SELECT * "
			_cQry += " FROM "  + RetSqlName("SB1") + " SB1 (NOLOCK) where SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
			If _x == 1
				_cQry += "                                          AND SB1.B1_TIPO   <> 'EM' "
			Else
				_cQry += "                                          AND SB1.B1_TIPO    = 'EM' "
			EndIf
			_cQry += "                                              AND SB1.D_E_L_E_T_ = '' "
			_cQry += " and 	SB1.B1_COD = '" + SC2->C2_PRODUTO + "' "
				/*
			If __cUserId == "000000"
				MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_00"+cValToChar(_x)+".TXT",_cQry)
			EndIf
			*/
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cAlias,.T.,.F.)
			dbSelectArea(_cAlias)
			(_cAlias)->(dbGoTop())
			If !(_cAlias)->(EOF())
				dbSelectArea("SB1")
				SB1->(dbSetOrder(1))
				SB1->(MsSeek(xFilial("SB1") + SC2->C2_PRODUTO,.T.,.F.))
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
				@nLin,000 PSAY "OP:" + AllTrim(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN) + " - Produto:" + AllTrim(SC2->C2_PRODUTO) + " - " + AllTrim(SB1->B1_DESC)
				nLin++
				@nLin,000 PSAY "Prev. In�cio: " + DTOC(SC2->C2_DATPRI) + "  -  Prev. T�rmino: " + DTOC(SC2->C2_DATPRF)
				nLin++
				@nLin,000 PSAY Replicate("_",Limite)
				nLin += 2
				dbSelectArea(_cAlias)
				While !(_cAlias)->(EOF())
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
					If nLin > 55 // Salto de P�gina. Neste caso o formulario tem 55 linhas...
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin := 8
					EndIf
					If !_lImpEm 
					   If AllTrim((_cAlias)->B1_TIPO) == "EM"
					   	  _lImpEm := .T.
					   EndIf
					EndIf
					@nLin,000 PSAY Alltrim(SubStr((_cAlias)->B1_COD,1,13))
					@nLin,014 PSAY AllTrim(SubStr((_cAlias)->B1_DESC,1,30))
					@nLin,046 PSAY AllTrim(SubStr((_cAlias)->B1_LOCPAD,1,2))
					@nLin,048 PSAY SC2->C2_QUANT   PICTURE "@e 999,999,999.9999"
					dbSelectArea("SB2")
					dbSetOrder(1)
					If MsSeek(xFilial("SB2") + (_cAlias)->B1_COD + (_cAlias)->B1_LOCPAD,.T.,.F.)
						@nLin,062 PSAY SaldoSb2()         PICTURE "@e 999,999,999.9999"
					Else
						@nLin,062 PSAY 0                  PICTURE "@e 999,999,999.9999"
					EndIf
					nLin++
					dbSelectArea(_cAlias)
					(_cAlias)->(dbSkip())
				EndDo
			 //INICIO - ALTERADO - Thiago Silva de Almeida - 02/04/2013
			 nLin+=2
			 @nLin,000 PSAY "QUANTIDADE TOTAL OP:"		 			 		 
			 @nLin,016 PSAY SC2->C2_QUANT PICTURE "@e 999,999,999.9999"
			 @nLin,040 PSAY "Data Emiss�o:"
			 @nLin,054 PSAY SC2->C2_EMISSAO
			 nLin+=2
			If !_lImpEm 
				@nLin,000 PSAY "OBSERVA��ES"		 			 
			 	nLin++
			 	_cAux    := Alltrim(SB1->B1_OBSM)
			 	_nLinhas := Len(_cAux)/80 
				If _nLinhas <> Int(Len(_cAux)/80)
					_nLinhas++          
				EndIf
				For _nX := 1 To _nLinhas
		 			@nLin,000 PSAY SubStr(SB1->B1_OBSM,(_nX - 1) * 80,79)
		 			nLin++
		 		Next
			Else
				@nLin,000 PSAY "Composi��o"
				nLin++
				@nLin,000 PSAY SB1->B1_COMPOS
			 	nLin+=2
			 	@nLin,000 PSAY "Aplica��o:"
				nLin++
				@nLin,000 PSAY SB1->B1_APLIC
				nLin+=2 	
				@nLin,000 PSAY "Minist�rio da Sa�de:"
				nLin++
				@nLin,000 PSAY SB1->B1_MS
				nLin+=2
				@nLin,000 PSAY "Validade:"
				@nLin,012 PSAY (SB1->B1_PRVALID / 30)
				@nLin,014 PSAY "Meses"
				@nLin,040 PSAY "Embalagem:"
				@nLin,051 PSAY SB1->B1_DESEMB
				nLin+=2		
				@nLin,000 PSAY "Volume Prim."
				@nLin,016 PSAY SB1->B1_VOPRIN
				@nLin,040 PSAY "Cod. Barras 1:"
				@nLin,056 PSAY SB1->B1_CODBAR
				nLin++
				@nLin,000 PSAY "Volume Sec."
				@nLin,016 PSAY SB1->B1_VOSEC
				@nLin,040 PSAY "Cod. Barras 2:"
				@nLin,056 PSAY SB1->B1_CODBAR2
			EndIf 
			nLin+=2 	
			@nLin,000 PSAY "________________________________________________________________________________"
			nLin++ 	
			@nLin,000 PSAY "|   Quantidade  |    Data    |       Conferente            |     Lan�amento    |"			
	        @nLin,000 PSAY "________________________________________________________________________________"
	  		nLin++                                                                                                                
	  		@nLin,000 PSAY "|               |            |                             |                   |"         
			@nLin,000 PSAY "________________________________________________________________________________"
			nLin++
	  		@nLin,000 PSAY "|               |            |                             |                   |"         
			@nLin,000 PSAY "________________________________________________________________________________"
			nLin++
	  		@nLin,000 PSAY "|               |            |                             |                   |"         
			@nLin,000 PSAY "________________________________________________________________________________"
			nLin++
	  		@nLin,000 PSAY "|               |            |                             |                   |"         
			@nLin,000 PSAY "________________________________________________________________________________"
			/*
			nLin++
	  		@nLin,000 PSAY "|               |            |                             |                   |"         
			@nLin,000 PSAY "________________________________________________________________________________"
			*/
			/*
			nLin+=	2
			@nLin,000 PSAY "CONTROLE DE QUALIDADE"
	        nLin++
	        @nLin,000 PSAY "( _ )APROVADO"		 
	        @nLin,020 PSAY "( _ )REPROVADO"		 
	        @nLin,037 PSAY "___/___/___"
	        @nLin,050 PSAY "Visto: _______________________" */ // Ajuste solicitado pelo Sr.Ronie em 01/02/2018  

			nLin+=	2
			@nLin,000 PSAY "1 - CONTROLE DE EMBALAGEM - ( _ )APROVADO    ( _ )REPROVADO    ___/___/___ "
	        nLin+=  2 
	        @nLin,000 PSAY "Entregue Por:__________________________"		 
	        @nLin,040 PSAY "Recebido Por:__________________________"		 
			nLin+=	3

			@nLin,000 PSAY "2 - CONTROLE DE QUALIDADE(AMOSTRA) - ( _ )APROVADO ( _ )REPROVADO    ___/___/___ "
   	        nLin+=  2 
	        @nLin,000 PSAY "Entregue Por:__________________________"		 
	        @nLin,040 PSAY "Recebido Por:__________________________"		 

			_lImpEm := .F.
			If nLin >= 55
				nLin := 55
			Else
				nLin += 2
			EndIf
			@nLin,055 PSAY "Impress�o controlada N� "+cValToChar(SC2->C2_NUMPAGS + 1)+"."
			//FIM - ALTERADO - Thiago Silva de Almeida - 02/04/2013
			EndIf
			dbSelectArea(_cAlias)
			(_cAlias)->(dbCloseArea())
		Next
		dbSelectArea("SC2")
		SC2->(dbSetOrder(1))
		Reclock("SC2",.F.)
			SC2->C2_NUMPAGS += 1
		SC2->(MsUnLock())
		SC2->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	EndDo
Else
	MSGBOX("Ordem de produ��o n�o encontrada",_cRotina+"_003","ALERT")
	Return()
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

// - Trecho inserido por J�lio Soares em 16/11/2015 para controlar o n�mero de c�pias de impress�o.
/*
dbSelectArea("SC2")
dbSetOrder(1)
If MsSeek(xFilial("SC2")+MV_PAR01,.T.,.F.)
	If __cUserId $ SuperGetMv("MV_ORDPIMP",,"000000")
		MS_FLUSH()
	Else
		_nImp := SC2->(C2_NUMPAGS)
		If _nImp <= 1
			If MSGBOX("A impress�o das ordens de produ��o � limitada a uma c�pia, deseja realmente imprimir as Ordem de "+(MV_PAR01)+" at� "+(MV_PAR02)+" ? "+CHR(13)+CHR(10)+"Somente usu�rios autorizados poder�o reimprimir uma ordem.",_cRotina + "_002","YESNO")
				While !(SC2->(EOF())) .And. SC2->(C2_NUM)+SC2->(C2_ITEM)+SC2->(C2_SEQUEN) >= MV_PAR01 .And. SC2->(C2_NUM)+SC2->(C2_ITEM)+SC2->(C2_SEQUEN) <= MV_PAR02
					Reclock("SC2",.F.)
						SC2->C2_NUMPAGS := _nImp += 1
					SC2->(MsUnlock())
					SC2->(DbSkip())
					_nImp := SC2->(C2_NUMPAGS)
				EndDo
				MS_FLUSH()
			EndIf
		Else	
			MSGBOX("Essa Ordem de produ��o j� foi impressa, somente pessoas autorizadas podem imprimi-la novamente.",_cRotina+"_003","ALERT")
			Return()
		EndIf
	EndIf
EndIf
*/
// - FIM do trecho incluido.

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValidPerg � Autor �Anderson C. P. Coelho � Data �  21/03/13 ���
�������������������������������������������������������������������������͹��
���Desc.     �Tratamento das perguntas na SX1.                            ���
�������������������������������������������������������������������������͹��
���Uso       �Programa Principal                                          ���
�����������������������������������������������������������������������������
*/

Static Function ValidPerg()

Local _aAlias := GetArea()
Local aRegs   := {}
Local i       := 0

cPerg   := PADR(cPerg,10)

AADD(aRegs,{cPerg,"01","Da OP     ?","","","mv_ch1","C",11,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SC2","",""})
AADD(aRegs,{cPerg,"02","Ate a OP  ?","","","mv_ch2","C",11,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SC2","",""})

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
RestArea(_aAlias)

Return()
