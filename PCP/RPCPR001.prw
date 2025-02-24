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
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���06/09/2021� Fernando B.   � Impress�o OP pela Gest�o OP Prevista       ���
��������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Especifico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
user function RPCPR001(cOPIni, cOPFim,_aOpImp)
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

Local _cOpIn    := ""
Local _nOpIn    := 1

//Private CbTxt		:= ""
Private tamanho		:= "P"
Private nomeprog	:= "RPCPR001" // Coloque aqui o nome do programa para impressao no cabecalho
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
//**************************************************************************
// INICIO
// ARCOLOR - tratativa para impress�o quando a impress�o for chamada por 
// meio da Gest�o de OPs Previstas
// FERNANDO BOMBARDI em 06/09/2021
//**************************************************************************
if AllTrim(FunName()) == "RPCPA003" .AND. !Empty(cOPIni) .AND. !Empty(cOPFim)
	MV_PAR01 := cOPIni
	MV_PAR02 := cOPFim
elseif AllTrim(FunName()) <> "RPCPA001"
	ValidPerg()
	If !Pergunte(cPerg,.T.)
		Return()
	EndIf
else
	//Tratar impressao quando a rotina de Gest�o de OPs Previstas
	if type("_aOpImp") <> "U"
		for _nOpIn := 1 to len(_aOpImp)
			if _nOpIn > 1
				_cOpIn += ",'" + _aOpImp[_nOpIn,1] + _aOpImp[_nOpIn,2] + _aOpImp[_nOpIn,3] + "'"
			else
				_cOpIn += "'" + _aOpImp[_nOpIn,1] + _aOpImp[_nOpIn,2] + _aOpImp[_nOpIn,3] + "'"			
			endif
		next _nOpIn
	endif
endif
// FIM
//**************************************************************************
//dbSelectArea("SC2")
//SC2->(dbSetOrder(1))
//TRATAMENTO INICIADO PARA BLOQUEIO DE IMPRESS�ES

_cQry := "SELECT * "
_cQry += "	FROM " + RetSqlName("SC2") + " (NOLOCK) "
_cQry += "	WHERE C2_FILIAL = '" + xFilial("SC2") + "' "
if !empty(_cOpIn)
	_cQry += "	AND C2_NUM+C2_ITEM+C2_SEQUEN IN (" + _cOpIn + ") "
else
	_cQry += "	AND C2_NUM+C2_ITEM+C2_SEQUEN BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
endif
_cQry += "	AND D_E_L_E_T_ = '' "
_cQry += "	ORDER BY  C2_NUM, C2_ITEM, C2_SEQUEN "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"SC2OP",.T.,.F.)

If !SC2OP->(EOF())
	While !SC2OP->(EOF()) .AND. SC2OP->C2_FILIAL == xFilial("SC2") .AND. SC2OP->(C2_NUM+C2_ITEM+C2_SEQUEN) <= MV_PAR02
		If SC2OP->C2_NUMPAGS >= 1
			_cMsg += Alltrim(SC2OP->(C2_NUM+C2_ITEM+C2_SEQUEN))
			_cMsg += _lEnt
			If Len(_cMsg) >= 999999
				MSGBOX("Falha na quantidade de informa��es a serem apresentadas! Selecione um range menor de Ordens para impress�o.",_cRotina+"_001","STOP")
				Return()
			EndIf
		EndIf
		dbSelectArea("SC2OP")
		SC2OP->(dbSkip())
	EndDo
	If !Empty(_cMsg)
		If !MSGBOX("As Ordens de produ��o abaixo j� foram impressas e s� poder�o ser emitidas novamente por um usu�rio autorizado."+_lEnt+_cMsg+_lEnt+"Deseja prosseguir?",_cRotina+"_002","YESNO")
			Return()
		EndIf
	EndIf
Else
	MsgAlert("Ordem de produ��o n�o encontrada",_cRotina+"_003")
	SC2OP->(dbCloseArea())
	Return()
EndIf

SC2OP->(dbCloseArea())

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
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin,_cOpIn) },Titulo)

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

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin,_cOpIn)

//Local nOrdem
Local _lImpEm := .F.
Local nTotOps:= 0
Local _cVld := ""
local _x   := 0
local _nX  := 0

 
/*
dbSelectArea("SC2")
SC2OP->(dbSetOrder(1))
*/

_cQry := "SELECT * "
_cQry += "	FROM " + RetSqlName("SC2") + " (NOLOCK) "
_cQry += "	WHERE C2_FILIAL = '" + xFilial("SC2") + "' "
if !empty(_cOpIn)
	_cQry += "	AND C2_NUM+C2_ITEM+C2_SEQUEN IN (" + _cOpIn + ") "
else
	_cQry += "	AND C2_NUM+C2_ITEM+C2_SEQUEN BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
endif
_cQry += "	AND D_E_L_E_T_ = '' "
_cQry += "	ORDER BY  C2_NUM, C2_ITEM, C2_SEQUEN "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"SC2OP",.T.,.F.)
dbSelectArea("SC2OP")
SetRegua(RecCount())
SC2OP->(dbGoTop())

If !SC2OP->(EOF())
	While !SC2OP->(EOF()) .AND. SC2OP->C2_FILIAL == xFilial("SC2") .AND. (SC2OP->C2_NUM+SC2OP->C2_ITEM+SC2OP->C2_SEQUEN) <= MV_PAR02
		// - INICIADO TRATAMENTO PARA BLOQUEIO DE NUMERA��O DE P�GINAS
		If SC2OP->C2_NUMPAGS >= 1 .AND. !__cUserId $ _cValidUsr
			dbSelectArea("SC2OP")
			SC2OP->(dbSkip())
			Loop
		EndIf
		// - FIM
		_cAlias := "SD4TMP"
		For _x := 1 To 2
			_cQry := " SELECT * "
			_cQry += " FROM " + RetSqlName("SD4") + " SD4 (NOLOCK)  " 
			_cQry += "      INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
			If _x == 1
				_cQry += "                                          AND SB1.B1_TIPO   <> 'EM' "
			Else
				_cQry += "                                          AND SB1.B1_TIPO    = 'EM' "
			EndIf
			_cQry += "                                              AND SB1.B1_COD     = SD4.D4_COD "
			_cQry += "                                              AND SB1.D_E_L_E_T_ = '' "
			_cQry += " WHERE SD4.D4_FILIAL  = '"+xFilial("SD4")+"' "
			_cQry += "   AND SD4.D4_OP      = '" + (SC2OP->C2_NUM+SC2OP->C2_ITEM+SC2OP->C2_SEQUEN) + "' "
			_cQry += "   AND SD4.D_E_L_E_T_ = '' "
			_cQry += " ORDER BY D4_FILIAL, D4_OP, D4_COD, D4_LOCAL "
			/*
			If __cUserId == "000000"
				MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_00"+cValToChar(_x)+".TXT",_cQry)
			EndIf
			*/
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cAlias,.T.,.F.)
			dbSelectArea(_cAlias)						
			(_cAlias)->(dbGoTop())
			
			nTotOps:= (_cAlias)->(RecCount())
			
		//	If nTotOps == 0	.And. !SC2OP->(EOF()) .And. _x == 1			
		//		MsgStop("OP: " +  AllTrim(SC2OP->C2_NUM+SC2OP->C2_ITEM+SC2OP->C2_SEQUEN)  + " Sem Estrutura! Impress�o Cancelada.",_cRotina+"_005")
		//	EndiF

			If !(_cAlias)->(EOF())
				dbSelectArea("SB1")
				SB1->(dbSetOrder(1))
				SB1->(MsSeek(xFilial("SB1") + SC2OP->C2_PRODUTO,.T.,.F.))
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
				@nLin,000 PSAY "OP:" + AllTrim(SC2OP->C2_NUM+SC2OP->C2_ITEM+SC2OP->C2_SEQUEN) + " - Produto:" + AllTrim(SC2OP->C2_PRODUTO) + " - " + AllTrim(SB1->B1_DESC)
				nLin++
				@nLin,000 PSAY "Prev. In�cio: " + DTOC(STOD(SC2OP->C2_DATPRI)) + "  -  Prev. T�rmino: " + DTOC(STOD(SC2OP->C2_DATPRF))
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
					@nLin,000 PSAY Alltrim(SubStr((_cAlias)->D4_COD,1,13))
					@nLin,014 PSAY AllTrim(SubStr((_cAlias)->B1_DESC,1,30))
					@nLin,046 PSAY AllTrim(SubStr((_cAlias)->D4_LOCAL,1,2))
					@nLin,048 PSAY (_cAlias)->D4_QUANT    PICTURE "@e 999,999,999.9999"
					dbSelectArea("SB2")
					dbSetOrder(1)
					If MsSeek(xFilial("SB2") + (_cAlias)->D4_COD + (_cAlias)->D4_LOCAL,.T.,.F.)
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
			 @nLin,016 PSAY SC2OP->C2_QUANT PICTURE "@e 999,999,999.9999"
			 @nLin,040 PSAY "Data Emiss�o:"
			 @nLin,054 PSAY DTOC(STOD(SC2OP->C2_EMISSAO))
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
				@nLin,012 PSAY cVAltoChar(SB1->B1_PRVALID/30) 			
				//_cVld:= dtos(stod(SUBSTR(dtos(SC2OP->C2_DATPRF),1,6)+"28")+ (SB1->B1_PRVALID)) //Mes de producao deve ser desprezado.	
				_cVld:= dtos(stod(SUBSTR(SC2OP->C2_DATPRF,1,6)+"28")+ (SB1->B1_PRVALID)) //Mes de producao deve ser desprezado.	
				
				@nLin,014 PSAY " Meses " + IIF(SB1->B1_PRVALID <> 0,  " - "  + substr( _cVld ,5,2) + "/" + substr( _cVld ,1,4) , "")  
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
			@nLin,055 PSAY "Impress�o controlada N� "+cValToChar(SC2OP->C2_NUMPAGS + 1)+"."
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
		SC2OP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
		
	EndDo
Else
	MsgAlert("Ordem de produ��o n�o encontrada",_cRotina+"_003")
	SC2OP->(dbCloseArea())
	Return()
EndIf

SC2OP->(dbCloseArea())

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
		_nImp := SC2OP->(C2_NUMPAGS)
		If _nImp <= 1
			If MSGBOX("A impress�o das ordens de produ��o � limitada a uma c�pia, deseja realmente imprimir as Ordem de "+(MV_PAR01)+" at� "+(MV_PAR02)+" ? "+CHR(13)+CHR(10)+"Somente usu�rios autorizados poder�o reimprimir uma ordem.",_cRotina + "_002","YESNO")
				While !(SC2OP->(EOF())) .And. SC2OP->(C2_NUM)+SC2OP->(C2_ITEM)+SC2OP->(C2_SEQUEN) >= MV_PAR01 .And. SC2OP->(C2_NUM)+SC2OP->(C2_ITEM)+SC2OP->(C2_SEQUEN) <= MV_PAR02
					Reclock("SC2",.F.)
						SC2OP->C2_NUMPAGS := _nImp += 1
					SC2OP->(MsUnlock())
					SC2OP->(DbSkip())
					_nImp := SC2OP->(C2_NUMPAGS)
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

Local _aAlias 	:= GetArea()
Local aRegs   	:= {}
Local i       	:= 0
local J			:= 0
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
