#INCLUDE "rwmake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATR002  º Autor ³ ALESSANDRO VILLAR   º Data ³  26/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ RELATÓRIO DE ORDEM DE SEPARAÇÃO.                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FATURAMENTO                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RFATR002()
                                                                                         

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "ORDEM DE SEPARAÇÃO"
Local cPict          := ""
Local titulo       	 := "ORDEM DE SEPARAÇÃO"
Local nLin           := 80
//                   ITEM  PRODUTO                          DESCRIÇÃO                       QUANTIDADE    ARMAZEM  ENDEREÇO  LOTE        STATUS
//                   XX    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXX  XX       XXXXXX    XXXXXXXXXX  [    ]
//                   01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//                             10        20        30        40        50        60        70        80        90        100       110       120       130
Local Cabec1       	 := ""
Local Cabec2       	 := ""
Local imprime      	 := .T.
Local aOrd           := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 132 //Limite da página: 80 - 132 - 220 // P - M - G
Private tamanho      := "M"
Private nomeprog     := FunName()
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "RFAT004" 
Private cPerg		 := "RFAT004"
Private cString      := "CB7"

dbSelectArea("CB7")
dbSetOrder(1)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

//Pergunte(cPerg,.T.)
// Verifica as perguntas selecionadas
ValidPerg()
pergunte(cPerg,.T.)

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo) 

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o  ³RUNREPORT º Autor ³ ALESSANDRO VILLAR    º Data ³  26/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ RELATÓRIO DE ORDEM DE SEPARAÇÃO                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FATURAMENTO                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
  
Local nOrdem 

	cQuery1 := " SELECT DISTINCT CB7.CB7_ORDSEP, CB8.CB8_PEDIDO, CB7.CB7_DTINIS, CB7.CB7_DTEMIS, CB7.CB7_HRINIS, CB7.CB7_HREMIS, CB7.CB7_CLIENT, SA1.A1_NOME, CB7.CB7_CODOPE, CB7.CB7_CODOP2, "
   	cQuery1 += "				 CB7.CB7_NOMOP1, CB7.CB7_NOMOP2, CB8.CB8_ORDSEP,CB8.CB8_ITEM, CB8.CB8_PROD, SB1.B1_DESC, CB8.CB8_QTDORI, CB8.CB8_LOCAL, SB1.B1_ENDPAD, CB8.CB8_LOTECT, "
   	cQuery1 += "				 CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),CB7.CB7_OBS1)) CB7_OBS1 "
	cQuery1 += " FROM       "+ RetSqlName ("CB7")  +" CB7 " 
	cQuery1 += " INNER JOIN "+ RetSqlName ("CB8")  +" CB8 "
	cQuery1 += " ON CB7.CB7_ORDSEP = CB8.CB8_ORDSEP " 
//	cQuery1 += " INNER JOIN "+ RetSqlName ("CB1")  +" CB1 ON CB1.CB1_CODOPE = CB7.CB7_CODOPE "
	cQuery1 += " LEFT JOIN "+ RetSqlName ("SB1")  +" SB1 ON SB1.B1_COD = CB8.CB8_PROD   "
	cQuery1 += " LEFT JOIN "+ RetSqlName ("SA1")  +" SA1 ON SA1.A1_COD = CB7.CB7_CLIENT "
	cQuery1 += " AND SA1.A1_LOJA=CB7.CB7_LOJA "
	cQuery1 += " WHERE CB7.D_E_L_E_T_ <>'*' "	
	cQuery1 += " AND CB8.D_E_L_E_T_ <>'*' "
	cQuery1 += " AND SB1.D_E_L_E_T_ <>'*' "
	cQuery1 += " AND SA1.D_E_L_E_T_ <>'*' "	
	cQuery1 += " AND SB1.B1_FILIAL='" + xFilial("SB1") + "' "
	cQuery1 += " AND SA1.A1_FILIAL='" + xFilial("SA1") + "' "
	cQuery1 += "	AND CB7.CB7_FILIAL =       '" + xFilial ("CB7") +"' "
	cQuery1 += "	AND CB7.CB7_ORDSEP BETWEEN '" + (mv_par01)      +"'  AND '"+ (mv_par02)     +"' " 			// De Separação, Até Separação
    cQuery1 += "	AND CB7.CB7_DTINIS BETWEEN '" + DTOS(mv_par03)  +"'  AND '"+ DTOS(mv_par04) +"' "			// De Data, Até Data 
    cQuery1 += "	AND CB7.CB7_CLIENT BETWEEN '" + (mv_par05)      +"'  AND '"+ (mv_par06)     +"' "			// De Cliente, Até Cliente
    cQuery1 += "    AND CB8.D_E_L_E_T_ <>'*' "         
	cQuery1 += "    AND CB8.CB8_FILIAL =       '"+ xFilial ("CB8") + "' "  
    cQuery1 += " ORDER BY CB7.CB7_ORDSEP, SB1.B1_ENDPAD, SB1.B1_DESC, CB8.CB8_ITEM, CB8.CB8_PROD "
    
    cQuery1 := ChangeQuery(cQuery1)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),"TRB",.T.,.F.)  
	
	
	
dbSelectArea("TRB")
                                                                    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetRegua(RecCount())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicionamento do primeiro registro e loop principal. Pode-se criar ³
//³ a logica da seguinte maneira: Posiciona-se na filial corrente e pro ³
//³ cessa enquanto a filial do registro for a filial corrente. Por exem ³
//³ plo, substitua o dbGoTop() e o While !EOF() abaixo pela sintaxe:    ³
//³                                                                     ³
//³ dbSeek(xFilial())                                                   ³
//³ While !EOF() .And. xFilial() == A1_FILIAL                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbGoTop()

_cNumOrd := ""

While !EOF()

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica o cancelamento pelo usuario...                             ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao do cabecalho do relatorio. . .                            ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
           nLin := 8
   Endif
   
   If _cNumOrd <> TRB->CB7_ORDSEP  // IMPRIME O CABEÇALHO QUANDO FOR DIFERENTE E NÃO REPETE O CABELHAÇO
   
   If _cNumOrd <> ""
   
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)  // colocar o cabeçalho nesse trecho, irá imprimir uma Ordem de Separação por página
           nLin := 8

   EndIf
   
    // N. Separação:                      Pedido:                                  Data:                                  Hora:
    // XXXXXX                             XXXXXX                                   XXXXXXXX                               XXXXXX
    // 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
    //           10        20        30        40        50        60        70        80        90        100       110       120       130 
   	@nLin,00     PSAY "N. SEPARACAO:  " + TRB->CB7_ORDSEP 
   //	@nLin,35     PSAY "PEDIDO:  " + TRB->CB8_PEDIDO
	@nLin,70     PSAY "CLIENTE:      " + TRB->A1_NOME 
		nLin++ 
		
	// CLIENTE:                                                                    CONFERENTE:                                 
    // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX                                    XXXXXX 
    // 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
    //           10        20        30        40        50        60        70        80        90        100       110       120       130 
   // @nLin,00     PSAY "DATA:  " + DTOC(STOD(TRB->CB7_DTINIS)) // TRATAMENTO PARA DATA
   //	@nLin,35     PSAY "HORA:  " + TRB->CB7_HRINIS
	@nLin,00     PSAY "CONFERENTE:  " + TRB->CB7_NOMOP2
		nLin++
    @nLin,00     PSAY "OBSERVAÇÕES:  " + TRB->CB7_OBS1
   	nLin++
    @nLin,00     PSAY Replicate("_",132)
   	nLin++   
   	@nLin,00     PSAY "N. SEPARACAO:  " + TRB->CB7_ORDSEP 
	//@nLin,35     PSAY "PEDIDO:       " + TRB->CB8_PEDIDO 
	@nLin,70     PSAY "CLIENTE:      " + TRB->A1_NOME 
		nLin++
    @nLin,00     PSAY "SEPARADOR:  " + TRB->CB7_NOMOP1
	@nLin,36     PSAY "DATA INÍCIO:  " + DTOC(STOD(TRB->CB7_DTEMIS)) // TRATAMENTO PARA DATA      
	@nLin,70     PSAY "HORA INÍCIO:  "+ TRB->CB7_HREMIS	 
    	nLin++
   	@nLin,00     PSAY "OBSERVAÇÕES:  " + TRB->CB7_OBS1 
   
    _cNumOrd := TRB->CB7_ORDSEP         
    
    nLin++     
    @nLin,00     PSAY Replicate("_",132)
   	nLin+= 2  
   	  	
    @nLin,00     PSAY "ITEM    PEDIDO    PRODUTO            DESCRIÇÃO                         QUANTIDADE      ARMAZEM   ENDEREÇO     LOTE         STATUS"        
	nLin++
	      
   EndIf  
    
    // ITEM    PEDIDO    PRODUTO            DESCRIÇÃO                         QUANTIDADE      ARMAZEM   ENDEREÇO     LOTE         STATUS
    //  XX     XXXXXX    XXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    XXXXXXXXXXXX       XX     XXXXXXXXXX   XXXXXXXXXX   [    ]
    // 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
    //           10        20        30        40        50        60        70        80        90        100       110       120       130
    @nLin,01     PSAY TRB->CB8_ITEM 
	@nLin,08     PSAY TRB->CB8_PEDIDO   	
	@nLin,18     PSAY TRB->CB8_PROD
	@nLin,37     PSAY TRB->B1_DESC
    @nLin,67     PSAY TRB->CB8_QTDORI Picture '@E 999,999,999.99' //12
	@nLin,90     PSAY TRB->CB8_LOCAL                                
    @nLin,97     PSAY TRB->B1_ENDPAD
	@nLin,110    PSAY TRB->CB8_LOTECT
	@nLin,123    PSAY "[    ]" 	  
      
    nLin++
    @nLin,00     PSAY Replicate("-",132)  // Nesse trecho irá pontilhar abaixo de cada item descrito na relação                            
    nLin++ 
   	            
   dbSkip() // Avanca o ponteiro do registro no arquivo  
EndDo                                  

dbSelectArea("TRB")
dbCloseArea()

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
Endif

MS_FLUSH()

Return    

    
//**************************************************************************************
//                                 Valida Perguntas
//**************************************************************************************
Static Function ValidPerg()

_sAlias := Alias()
DbSelectArea("SX1")
DbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs :={}

//--------------------------------------------------------------------------------------
// Variáveis utilizadas para parametros 

// mv_par01	   De Separação
// mv_par02    Até Separação
// mv_par03	   De Data
// mv_par04    Até Data
// mv_par05	   De Cliente
// mv_par06    Até Cliente
//--------------------------------------------------------------------------------------  
AADD(aRegs,{cPerg,"01","De Separação?" 	  		,"","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","      ","","","","","","","","","","","","","","","","","","","","","CB7",""})
AADD(aRegs,{cPerg,"02","Até Separação?"	  		,"","","mv_ch2","C",06,0,0,"G","NaoVazio()","mv_par02","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","CB7",""}) 
AADD(aRegs,{cPerg,"03","De Data?" 	  		    ,"","","mv_ch3","D",08,0,0,"G","NaoVazio()","mv_par03","","","","20000101","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Até Data?"	  		    ,"","","mv_ch4","D",08,0,0,"G","NaoVazio()","mv_par04","","","","20491231","","","","","","","","","","","","","","","","","","","","","",""}) 
AADD(aRegs,{cPerg,"05","De Cliente?" 	  		,"","","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","CB7",""})
AADD(aRegs,{cPerg,"06","Até Cliente?"	  		,"","","mv_ch6","C",06,0,0,"G","NaoVazio()","mv_par06","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","CB7",""})

	  	
For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Else
				Exit
			EndIf
		Next
		MsUnlock()
	EndIf
Next

DbSelectArea(_sAlias)

Return