#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATR006  º Autor ³ Renan              º Data ³  16/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao   ³ Relatório de notas fiscais canceladas                    º±±
±±ºImplantação ³ Júlio Soares - 26/04/2013                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso         ³ Protheus11 - Específico empresa ARCOLOR                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RFATR014()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿           
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1 := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2 := "de acordo com os parametros informados pelo usuario."
Local cDesc3 := ""
Local cPict  := ""
Local titulo := "Notas Canceladas"
Local nLin   := 80
/*
                         ....5...10...15...20...25...30...35...40...45...50...55...60...65...70...75...80...85...90...95...100..105..110..115..120..125..130..135..140..145..150..155..160..165..170..175..180..185..190..195..200..205..210..215..220
	                     nota fiscal   sr    cliente                                    lj   dt em     dt canc    valor                                                                       
		                 ______________________________________________________________________________________________________________                                                                                                                                     
                         xxxxxxxxxxxbbbxxxbbbxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxbbbxxbbbxxxxxxxbbbxxxxxxxxbbbxxxxxxxxxxxxxx
*/
Local _savArea       := GetArea()
Local Cabec1       	 := "  Notas fiscais canceladas"
Local Cabec2         := " NFiscal Serie Cod.Cli    Nome do Cliente                             Est  Dt.Emiss    Dt. Cancel    Valor Total   Motivo do Cancelamento"
Local imprime      	 := .T.
Local aOrd 			 := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 132
Private tamanho      := "M"
Private nomeprog     := "RFATR014" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "RFATR014" // Coloque aqui o nome do arquivo usado para impressao em disco
Private CPERG		 := "RFATR014"
Private cString      := "SF3"

VALIDPERG()

Pergunte (cPerg,.F.)

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif
SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local nOrdem

dbSelectArea("SF3")
dbSetOrder(1)
//Set Softseek on
MsSeek(xFilial("SF3") + DTOS (MV_PAR01),.F.,.F.)
//Set Softseek Off
While ! SF3->(EOF()) .AND. SF3->F3_EMISSAO <= MV_PAR02 .AND. xFilial("SF3") == SF3->F3_FILIAL 
	If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
		nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin++
	Endif
	If Empty(SF3->F3_DTCANC)
		dbSelectArea("SF3")
		dbSetOrder(1)
		dbSkip()
		Loop
	Endif
		_cCliente := ""
	If SF3->F3_CFO > '5000 '
		If SF3->F3_TIPO #"B" .AND. SF3->F3_TIPO #"D"
			Dbselectarea("SA1")  //cadastro de clientes
			DbSetOrder(1)        //filial+codigo
			If MsSeek(xfilial("SA1") + SF3->F3_CLIEFOR + SF3->F3_LOJA,.T.,.F.)
				_cCodCli  := SA1->A1_COD
				_cCliente := SUBSTR(SA1->A1_NOME,1,45)
				_cEst     := SA1->A1_EST
			Endif
		Else
			Dbselectarea("SA2")  //cadastro de fornecedor
			DbSetOrder(1)        //filial+codigo
			If MsSeek(xfilial("SA2") + SF3->F3_CLIEFOR + SF3->F3_LOJA,.T.,.F.)
				_cCodCli  := SA2->A2_COD
				_cCliente := SUBSTR(SA2->A2_NOME,1,45)
				_cEst     := SA2->A2_EST
			Endif
		Endif
	Else                                                                                      	
		If SF3->F3_TIPO =="B" .Or. SF3->F3_TIPO =="D"
			Dbselectarea("SA1")  //cadastro de clientes
			DbSetOrder(1)        //filial+codigo
			If MsSeek(xFilial("SA1") + SF3->F3_CLIEFOR + SF3->F3_LOJA,.T.,.F.)
				_cCodCli  := SA1->A1_COD
				_cCliente := SUBSTR(SA1->A1_NOME,1,45)
				_cEst     := SA1->A1_EST
			Endif
		Else
			Dbselectarea("SA2")  //cadastro de fornecedor
			DbSetOrder(1)        //filial+codigo
			If MsSeek(xFilial("SA2") + SF3->F3_CLIEFOR + SF3->F3_LOJA,.T.,.F.)
				_cCodCli  := SA2->A2_COD
				_cCliente := SUBSTR(SA2->A2_NOME,1,45)
				_cEst     := SA2->A2_EST
			Endif
		Endif
	Endif    
	_cNota     := SF3->F3_NFISCAL
	_cSerie    := SF3->F3_SERIE
	_dEmiss    := SF3->F3_EMISSAO
	_dCanc     := SF3->F3_DTCANC     
	_cText     := ""
	_nSubtotal := 0
	_nTotal    := 0
	dbSelectArea("SF3")
	While !SF3->(EOF()) .AND. SF3->F3_NFISCAL + SF3->F3_SERIE == _cNota + _cSerie
		_nSubtotal 	:= SF3->F3_VALCONT
		_nTotal		:= _nTotal + _nSubtotal
		dbSelectArea("SF2")
		dbSetOrder(1)
			If (SF2->F2_DOC == _cNota .AND. SF2->F2_SERIE == _cSerie)
				_cText := SF2->F2_MOTEXCL
			Else 
				_cText := "Motivo da exclusão n preenchido"
			EndIf
		SF3->(dbSkip()) // Avanca o ponteiro do registro no arquivo
//		dbSelectArea("SF3")
//		dbSetOrder(1)
//		dbSkip() // Avanca o ponteiro do registro no arquivo		
	EndDo

	@nLin,002 PSAY _cNota
	@nLin,013 PSAY _cSerie
	@nLin,016 PSAY _cCodCli
	@nLin,024 PSAY _cCliente
	@nLin,071 PSAY _cEst
	@nLin,075 PSAY _dEmiss
	@nLin,087 PSAY _dCanc
	@nLin,099 PSAY _nTotal  PICTURE "@E 999,999,999.99"
	@nLin,114 PSAY _cText
	nLin ++
EndDo

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif
MS_FLUSH()
Return
                                      
//---------------------------------------------------------------------------------------------------

Static Function ValidPerg()

_sAlias := Alias()

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs :={}

AADD(aRegs,{cPerg,"01","De Dt Emissao  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Ate Dt Emissao ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !MsSeek(cPerg+aRegs[i,2],.T.,.F.)
		RecLock("SX1",.T.)
		For j:=1 to FCount()
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
Return()