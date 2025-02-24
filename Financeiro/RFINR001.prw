#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFINR001  บ Autor ณ J๚lio Soares       บ Data ณ  18/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Programa responsแvel pela impressใo do relat๓rio de recibo บฑฑ
ฑฑบ          ณ de acordo com os parametros informados pelo usuario.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico empresa Arcolor                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function RFINR001()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local cDesc1		:= "Este programa tem como objetivo imprimir o recibo"
Local cDesc2		:= "de acordo com os parametros informados pelo usuario."
Local cDesc3		:= "Recibo - Arcolor"
Local cPict			:= ""
Local titulo		:= "Recibo - Arcolor"
Local nLin			:= 80
Local Cabec1		:= ""
Local Cabec2		:= ""
Local imprime		:= .T.
Local aOrd			:= {}
Private lEnd		:= .F.
Private lAbortPrint	:= .F.
Private CbTxt		:= ""
Private limite		:= 220
Private tamanho		:= "M"
Private nomeprog	:= "RFINR001" // nome do programa para impressao no cabecalho
Private nTipo		:= 15
Private aReturn		:= { "Zebrado", 1, "Financeiro", 2, 3, 1, "", 1}
Private nLastKey	:= 0
Private cbtxt		:= Space(10)
Private cbcont		:= 00
Private CONTFL		:= 01
Private m_pag		:= 01
Private wnrel		:= "RFINR001" // nome do arquivo usado para impressao em disco

Private cString		:= "SE1"

cPerg := "RFINR001"

oPrn:=TMSPrinter():New()
oFont0	:= TFont():New( "Arial",,08,,.T.,,,,,.f. )
oFont1	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
oFont2	:= TFont():New( "Arial",,13,,.T.,,,,,.f. )
oFont3	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
oFont4	:= TFont():New( "Arial",,14,,.f.,,,,,.f. )

dbSelectArea("SE1")
dbSetOrder(1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

ValidPerg()
Pergunte(cPerg,.F.)               // Pergunta na SX1
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo	:= If(aReturn[4]==1,15,18)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Marcelo Henrique   บ Data ณ  06/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
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

nCa		:= 010
nCb		:= 100
nCc		:= 655
nCd		:= 830
nCe		:= 1005
nCf		:= 1180
nCg		:= 1355
nCh		:= 1530
nCi		:= 1705
nCj		:= 1880
nCk		:= 2055
nCl		:= 2370
_nLin		:= 0050
_nImp		:= 0

dbSelectArea("SE1")
dbSetOrder(1)
MsSeek(xFilial("SE1") + mv_par03 + mv_par01,.F.,.F.)
While !Eof() .and. SE1->E1_PREFIXO + SE1->E1_NUM <= MV_PAR03 + MV_PAR02
	dbSelectArea("SF2")
	dbSetOrder(1)
	MsSeek(xFilial("SF2") + SE1->E1_NUM + SE1->E1_PREFIXO,.F.,.F.)
		
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFun็ใo responsavel por duplicar a pแginaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	For z:=1 to 2
		DbSelectArea("SA1")
		DbSetOrder(1)
		MsSeek(xFilial("SA1")+SE1->E1_CLIENTE + SE1->E1_LOJA,.T.,.F.)
		_nImp++
		If _nImp == 1
			oPrn:StartPage()
		Endif
	 	cBitMap1:= ("arcolorlg") + (".bmp")
		oPrn:BOX(0050,050,0352,552)	//teste do tamanho da Imagem
		oPrn:SayBitmap(0051,051,cBitMap1,500,300)
		_nLadd	:= 50        
      oPrn:Box(0050,600,0300,2370)	//Box Cabe็alho
      oPrn:Say(_nLin+=_nLadd,nCc+0500,"RECIBO ARCOLOR",ofont2,100,,,3)
		oPrn:Say(_nLin+=_nLadd,nCc+0300,Alltrim(SM0->M0_ENDENT) + " - " + Alltrim(SM0->M0_BAIRENT),ofont1,100,,,3)
		oPrn:Say(_nLin+=_nLadd,nCc+0300,(SM0->M0_CIDENT) + " - " +(SM0->M0_ESTENT) + " CEP: " + (SM0->M0_CEPENT) + " FONE: " + (SM0->M0_TEL),ofont1,100,,,3) 
		oPrn:Say(_nLin+=_nLadd,nCc+0300,"CNPJ: " + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99") + "INSC.ESTD: " + Transform(SM0->M0_INSC,"@R 999.999.999.999"),ofont1,100,,,3)
		oPrn:Say(_nLin+=_nLadd,nCc+0500,"Data de emissใo: " + dToc(SE1->E1_EMISSAO),ofont1,100,,,3)		
		
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ                                                                                   ณ
//ณTratamento para impressใo condicional se for duplicata via Hecaplast ou via Clienteณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		If _nImp == 1
			oPrn:Say(_nLin+=_nLadd,nCc+1400,"Via Arcolor",ofont1,100,,,3)		
		Else                                                                                         
			oPrn:Say(_nLin+=_nLadd,nCc+1400,"Via Cliente",ofont1,100,,,3)		
		EndIf	
		
		_nLin += 50
		_nLadd	:= 220
		oPrn:Box(_nLin,050,_nLin+60,800)//Ci Li Cf Lf
		oPrn:Say(_nLin+10,250,"NOTA FISCAL FATURA",ofont1,100,,,3)
		oPrn:Box(_nLin,800,_nLin+60,1550)//Ci Li Cf Lf
		oPrn:Say(_nLin+10,1050,"DUPLICATA",ofont1,100,,,3)
		oPrn:Box(_nLin+60,050,_nLin+120,370)//Ci Li Cf Lf
		oPrn:Say(_nLin+70,120,"VALOR R$" ,ofont1,100,,,3)
		oPrn:Box(_nLin+60,370,_nLin+120,800)//Ci Li Cf Lf 
		oPrn:Say(_nLin+70,500,"NUMERO" ,ofont1,100,,,3)
		oPrn:Box(_nLin+60,800,_nLin+120,1175)//Ci Li Cf Lf
		oPrn:Say(_nLin+70,900,"VALOR R$" ,ofont1,100,,,3)
		oPrn:Box(_nLin+60,1175,_nLin+120,1550)//Ci Li Cf Lf
		oPrn:Say(_nLin+70,1200,"Nบ DE ORDEM" ,ofont1,100,,,3)
		oPrn:Box(_nLin,1550,_nLin+120,1950)//Ci Li Cf Lf 
		oPrn:Say(_nLin+15,1600,"VENCIMENTO" ,ofont1,100,,,3)
		oPrn:Box(_nLin,1950,_nLin+280,2370)//Ci Li Cf Lf
		oPrn:Say(_nLin+10,2010,"  Para uso da" ,ofont0,100,,,3)
		oPrn:Say(_nLin+40,2000,"Inst. Financeira" ,ofont0,100,,,3)
		oPrn:Box(_nLin+210,050,_nLin+280,1950)//Ci Li Cf Lf
		oPrn:Say(_nLin+230,100,"OBSERVAวรO:",ofont1,100,,,3)
		_nLin+=110
		_nValor	:=0
		oPrn:Box(_nLin+10,050,_nLin+100,370) //Valor Fatura   
		oPrn:Say(_nLin+20,060,Transform(SF2->F2_VALFAT, "@E 999,999,999.99"),ofont2,100,,,3)    //verificar o que signific o 3 do final
	  	oPrn:Box(_nLin+10,370,_nLin+100,800) //N๚mero Fatura   
		oPrn:Say(_nLin+20,450,Alltrim(SE1->E1_NUM),ofont2,100,,,3)
		oPrn:Box(_nLin+10,800,_nLin+100,1175) //Valor Duplicata
		oPrn:Say(_nLin+20,1100,Transform(SE1->E1_VALOR,"@E 999,999,999.99"),ofont2,100,,,1)
		oPrn:Box(_nLin+10,1175,_nLin+100,1550) //N de Ordem
		oPrn:Say(_nLin+20,1200,Alltrim(SE1->E1_NUM) + Iif(!Empty(SE1->E1_PARCELA)," - "+ SE1->E1_PARCELA,""),ofont2,100,,,3)
		oPrn:Box(_nLin+100,1550,_nLin+100,1950) //Vencimento
		oPrn:Say(_nLin+20,1650,dToc(SE1->E1_VENCREA) ,ofont2,100,,,3)
		oPrn:Say(_nLin+120,120,Alltrim(SE1->E1_HIST) ,ofont1,100,,,3)
		_nValor	:= SE1->E1_VALOR
		_nLin+=50//110
		_nValor	:=0
		_nLin += _nLadd
		_nLadd	:= 50 //60		
		oPrn:Say(_nLin,nCc+30,"Nome do Sacado:" ,ofont1,100,,,3)
		oPrn:Say(_nLin,nCd+250,SA1->A1_NOME ,ofont3,100,,,3)
		_nLin+= _nLadd
		oPrn:Say(_nLin+10,nCc+30,"Endere็o:" ,ofont1,100,,,3)
		oPrn:Say(_nLin+10,nCd+250,SA1->A1_END ,ofont3,100,,,3)
		_nLin+= _nLadd
		oPrn:Say(_nLin+10,nCc+30,"Bairro:" ,ofont1,100,,,3)
		oPrn:Say(_nLin+10,nCd+250,SA1->A1_BAIRRO ,ofont3,100,,,3)
		oPrn:Say(_nLin+10,nCi+30 ,"CEP:" ,ofont1,100,,,3)
		oPrn:Say(_nLin+10,nCi+150,Transform(SA1->A1_CEP,"@R 99.999-999") ,ofont3,100,,,3)
		_nLin+= _nLadd
		oPrn:Say(_nLin+10,nCc+30 ,"Municํpio:" ,ofont1,100,,,3)
		oPrn:Say(_nLin+10,nCd+250 ,SA1->A1_MUN ,ofont3,100,,,3)
		oPrn:Say(_nLin+10,nCi+30 ,"Estado:" ,ofont1,100,,,3)
		oPrn:Say(_nLin+10,nCi+250,SA1->A1_EST ,ofont3,100,,,3)
		_nLin+= _nLadd
		oPrn:Say(_nLin+10,nCc+30,"Pra็a Pagto:" ,ofont1,100,,,3)
		oPrn:Say(_nLin+10,nCd+250,SA1->A1_ENDCOB,ofont3,100,,,3)
			If Empty (SA1->A1_ENDCOB)
				oPrn:Say(_nLin+10,nCd+250,"O MESMO",ofont3,100,,,3)
			EndIf
		_nLin+= _nLadd //50
		oPrn:Say(_nLin+10,nCc+30,"CNPJ:" ,ofont1,100,,,3)
		oPrn:Say(_nLin+10,nCd+140,Transform(SA1->A1_CGC,"@R 99.999.999/9999-99") ,ofont3,100,,,3)
		oPrn:Say(_nLin+10,nCg+30,"Inscr. Est.:" ,ofont1,100,,,3)
		oPrn:Say(_nLin+10,nCh+80,Transform(SA1->A1_INSCR,"@R 999.999.999.999") ,ofont3,100,,,3)
		_nLin+= _nLadd
		_nLadd := 140
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTratamento para escrita por extensoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oPrn:Box(_nLin+2,655,_nLin+142,900)
		oPrn:Box(_nLin+2,900,_nLin+142,2370)		
		oPrn:Say(_nLin+12,nCc+30,"VALOR POR" ,ofont3,100,,,3)
		oPrn:Say(_nLin+62,nCc+30,"EXTENSO:" ,ofont3,100,,,3)
		oPrn:Say(_nLin+22,920,Subs(RTRIM(SUBS(Extenso(SE1->E1_VALOR),1,50)) + REPLICATE("*",100),1,50),ofont2,100,,,3)
		oPrn:Say(_nLin+72,920,Subs(RTRIM(SUBS(Extenso(SE1->E1_VALOR),51,100)) + REPLICATE("*",100),1,50),ofont2,100,,,3)
		_nLinhas := MLCOUNT(Extenso(SE1->E1_VALOR),50,)
		_nSoma := 0
		For i:= 1 to _nLinhas
			If i == 1
				_nSoma +=10
			Else
				_nSoma +=40
			Endif
			oPrn:Say(_nLin+_nSoma,nCd+90,Memoline(Extenso(_nValor),50,i) ,ofont1,100,,,3)
		Next
		_nLin += 100
		If _nImp == 1
			If Empty (SE1->E1_PARCELA)
				oPrn:Say(_nLin+60,nCc+1430,"X",ofont3,100,,,3)
			Else
				oPrn:Say(_nLin+60,nCc+1675,"X",ofont3,100,,,3)
			EndIf
		oPrn:Say(_nLin+60,nCc+10,"Reconhe็o(emos) a exatidใo deste recibo    de venda mercantil com pagamento ๚nico(    ), Parcelado(    )," ,ofont3,100,,,3)
		_nLin += 50
		oPrn:Say(_nLin+60,nCc+10,"na importโncia acima que pagarei(emos)เ" + Alltrim(SM0->M0_NOMECOM) + ", ou เ sua " ,ofont3,100,,,3)
		_nLin += 50
		oPrn:Say(_nLin+60,nCc+10,"ordem na pra็a e vencimentos acima indicados. Em  ....../....../...........     ...................................................." ,ofont3,100,,,3)
		_nLin += 50
		oPrn:Say(_nLin+60,nCc+1250,"Assinatura do Sacado" ,ofont3,100,,,3)
		EndIf
		_nLin+=100
		If _nImp == 1
			oPrn:Box(720,050,_nLin+100,nCc-50) 						// Box assinatura emitente
			oPrn:SayBitmap(0750,500,"assinatura.bmp",0100,0700 )	// Imprime assinatura
			oPrn:SayBitmap(0750,070,"arcolor.bmp",0120,0700)        // Imprime Nome Hecaplast
			oPrn:Box(750,nCc-180,_nLin+95,nCc-180)					// Linha vertical da assinatura do emitente
			oPrn:Box(020,020,_nLin+120,nCl+20)						// Box Principal                      
		Else
			_nCc:=655
		cBitMap1:= ("arcolorlg") + (".bmp")
		oPrn:BOX(_nLin-1202,050,_nLin-0902,552)			//Box Logomarca
		oPrn:BOX(_nLin-1202,600,_nLin-0982,2370)		//Box Cabe็alho via Cliente
		oPrn:SayBitmap(_nLin-1198,051,cBitMap1,500,295) //Logo
		oPrn:Box(1620,020,_nLin+120,nCl+20) 			//Box Principal
		Endif
		If _nImp == 2
			Oprn:EndPage()
			_nLin := 0050
			_nImp := 0
		Else
			_nLin += 200
		Endif
	Next
	dbSelectArea("SE1")
	dbSetOrder(1)
	dbSkip()
Enddo
Oprn:Preview()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

/*
If aReturn[5]==1
dbCommitAll()
SET PRINTER TO
OurSpool(wnrel)
Endif
*/

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFINR001  บAutor  ณJ๚lio Soares        บ Data ณ  03/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCabec1 - cabe็alho                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณProtheus11 - Especํfico empresa Arcolor                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Cabec1()
	_nLadd := 150
	//oPrn:Box(_nLin,nCa,_nLin+_nLadd,nCj) //x1 y1 x2 y2
	oPrn:Say(_nLin+20,nCa+20,SM0->M0_NOMECOM,ofont1,100,,,3)
	oPrn:Say(_nLin+60,nCa+20,"FONE" + SM0->M0_TEL,ofont1,100,,,3)
	oPrn:Say(_nLin+100,nCa+20,"www.arcolor.com.br",ofont1,100,,,3)
	oPrn:Say(_nLin+20,nCe,"CONFIRMAวรO DE",ofont3,100,,,3)
	oPrn:Say(_nLin+70,nCe,"PEDIDO/COBRANวA",ofont3,100,,,3)
	oPrn:Say(_nLin+20,nCg,"a/c Contas",ofont3,100,,,3)
	oPrn:Say(_nLin+70,nCg,"a Pagar",ofont3,100,,,3)
	cBitMap1:=("arcolorlg") + (".bmp")
	oPrn:SayBitmap( _nLin+10,nCi-50,cBitMap1,0200,0070 )// Imprime logo
	_nLin+=_nLadd
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg บAutor  ณJ๚lio Soares		  บ Data ณ  06/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidPerg()

_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs :={}

AADD(aRegs,{cPerg,"01","Da Duplicata ?","","","mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SE1","",""})
AADD(aRegs,{cPerg,"02","At้ Duplicata?","","","mv_ch2","C",09,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SE1","",""})
AADD(aRegs,{cPerg,"03","Prefixo      ?","","","mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","   ","",""})

For i := 1 to Len(aRegs)
	If !MsSeek(cPerg+aRegs[i,2],.T.,.F.)
		RecLock("SX1",.T.)
		For j := 1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Else
				exit
			Endif
		Next
		MsUnlock()
	Endif
Next
dbSelectArea(_sAlias)

Return
