#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณRAFATR040 บAutor  ณMarcelo               บ Data ณ  28/03/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescri็ใo ณ Rotina de impressao de etiquetas termicas, especifico para บฑฑ
ฑฑบDescri็ใo ณ a impressora Argox OS214TT.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para a empresa Arcolor.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
           
User Function RFATR009()

aArea       := GetArea()
aAreaSC5    := SC5->(GetArea())
aAreaSC6    := SC6->(GetArea())
aAreaSC9    := SC9->(GetArea())
aAreaSF2    := SF2->(GetArea())
aAreaSD2    := SD2->(GetArea())
aAreaSE1    := SE1->(GetArea())
aAreaSB1    := SB1->(GetArea())
aAreaSA1    := SA1->(GetArea()) 
aAreaSA2    := SA2->(GetArea()) 
Titulo		:= "Etiqueta ARGOX - NF" 
aPerg       := {}

Private cPerg  := "RFATR040"

ValidPerg()
If !Pergunte(cPerg,.T.)
	Return()
EndIf	
	Processa({|lEnd| Proces()},Titulo,"Aguarde... Processando a impressใo...",.T.)
	

/*

AADD(aPerg,{"ETIQAR","01","De Nota Fiscal  ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aPerg,{"ETIQAR","02","Ate Nota Fiscal ?","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aPerg,{"ETIQAR","03","Serie           ?","","","mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})

CreateSX1(aPerg)


If Pergunte("ETIQAR",.T.)
	//+--------------------------------------------------------------+
	//ฆ Envia controle para a funcao SETPRINT                        ฆ
	//+--------------------------------------------------------------+
//	SetPrint("ETIQAR",Titulo,"ETIQAR",080,.F.,.T.,,.T.)

//	SetDefault()

	Processa({|lEnd| Process()},Titulo,"Aguarde... Processsando a impressใo...",.T.)
//	RptStatus({|lEnd| Process(@lEnd)},Titulo)
EndIf


EndPrint()


*/

RestArea(aAreaSC5)
RestArea(aAreaSC6)
RestArea(aAreaSC9)
RestArea(aAreaSF2)
RestArea(aAreaSD2)
RestArea(aAreaSE1)
RestArea(aAreaSB1)
RestArea(aAreaSA1) 
RestArea(aAreaSA2) 
RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณProcess   บAutor  ณAnderson C. P. Coelho บ Data ณ  28/11/09 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescri็ใo ณ Processamento da rotina.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ First - Especํfico para a empresa CRC.                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณProces   บAlterado por  ณAlex Matos      บ Data ณ  20/02/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescri็ใo ณ Processamento da rotina.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para a empresa CRC.               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function Proces()
Local	_cNota	:=	""
Local	_cSerie	:=	""
Local	_nVolume:=	""
Local	_nAux := 1        
Local	_cCodbar:= ""

#DEFINE DMPAPER_ENV_10 20

Private oFont1	:= TFont():New("Verdana",,15,,.F.,,,,,.F. )
Private oFont2	:= TFont():New("Verdana",,15,,.T.,,,,,.F. )
Private oFont3	:= TFont():New("Verdana",,15,,.F.,,,,,.F. )
Private oPrn	:= TMSPrinter():New("DATAMAX")
Private _nCol   := 1      

oPrn:SetPaperSize(DMPAPER_ENV_10)																		// Tamanho/Tipo do Papel
oPrn:SetPortRait()																				// Impressใo em formato "retrato"
oPrn:Setup()

cArq := CriaTrab(NIL,.F.)
INDREGUA("SF2",cArq,"F2_FILIAL + F2_SERIE + F2_DOC ",,,"Criando Arquivo Temporario...")

DbSelectArea("SF2")
nIndex := RetIndex("SF2")
#IFNDEF TOP
	DbSetIndex(cArq+OrdBagExt())
#ENDIF
DbSetOrder(nIndex+1)
dbGoTop()

ProcRegua(RecCount("SF2"))

Set SoftSeek ON
dbSeek(xFilial("SF2") + MV_PAR03 + MV_PAR01)
Set SoftSeek OFF
While !EOF() .AND. SF2->F2_SERIE == MV_PAR03 .AND. SF2->F2_DOC <= MV_PAR02 
	_cNota	:=	SF2->F2_DOC
	_cSerie	:=	SF2->F2_SERIE
	_nVolume:=	SF2->F2_VOLUME1 
	_cCodbar:=  ""
	_cCodBar := _cNota  + _cSerie + cValToChar(_nAux)
	If AllTrim(SF2->F2_TIPO) $ "D/B"
			dbSelectArea("SA2")
			dbSetOrder(1)
			If dbSeek(xFilial("SA2") + SF2->F2_CLIENTE + SF2->F2_LOJA)
				_cRazao := SA2->A2_NOME
			EndIf
	Else
			dbSelectarea("SA1")
			dbSetOrder(1)
			If dbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA)
				_cRazao := SA1->A1_NOME
			EndIf
	EndIf                     
	
	If _nVolume >0
	For _nAux := 1 To _nVolume 
	   //	If _nCol == 1 
	   		MSBAR3("CODE128",0.3,0.1,AllTrim(_cCodBar),oPrn,.F.,NIL,NIL,0.02,0.4,NIL,NIL,NIL,.F.)  
			oPrn:Say(025,0590, Alltrim (_cNota)           ,oFont2,100,,,3)	   		
			oPrn:Say(070,0400, "VOLUME(S):    " + Alltrim (CValToChar(_nAux)+"/"+cValToChar(_nVolume))           ,oFont2,100,,,3)
			oPrn:Say(0120,020, SubStr(AllTrim(_cRazao),01,40)           										,oFont1,100,,,3)
			oPrn:Say(0180,020, SubStr(AllTrim(_cRazao),41,40)												           ,oFont1,100,,,3)
			_nCol++
	   /*	ElseIf _nCol == 2
			oPrn:Say(015,425, "Cod:    " + Alltrim(SD2->D2_COD)           ,oFont2,100,,,3)
			oPrn:Say(060,425, SubStr(AllTrim(Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC")),01,20)           ,oFont1,100,,,3)
			oPrn:Say(105,425, SubStr(AllTrim(Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC")),21,20)           ,oFont1,100,,,3)
			oPrn:Say(150,425, "Qtd:    " + TRANSFORM(SD2->D2_QUANT,"@E 99999"),oFont2,100,,,3)
			oPrn:Say(200,425, "NF.:    " + AllTrim(SD2->D2_DOC)               ,oFont1,100,,,3)
			_nCol++
		ElseIf _nCol == 3
			oPrn:Say(015,835, "Cod:    " + Alltrim(SD2->D2_COD)           ,oFont2,100,,,3)
			oPrn:Say(060,835, SubStr(AllTrim(Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC")),01,20)           ,oFont1,100,,,3)
			oPrn:Say(105,835, SubStr(AllTrim(Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC")),21,20)           ,oFont1,100,,,3)
			oPrn:Say(150,835, "Qtd:    " + TRANSFORM(SD2->D2_QUANT,"@E 99999"),oFont2,100,,,3)
			oPrn:Say(200,835, "NF.:    " + AllTrim(SD2->D2_DOC)               ,oFont1,100,,,3)
            */
			oPrn:EndPage()
			oPrn:StartPage()
			_nCol := 1
	
		Next  
	Else
		Alert("Atencao!!! Ocorreram problemas durante a impressao. Reimprima as etiquetas, se necessario!")
		Return
	EndIf
  
	
	IncProc()

	DbSelectArea("SD2")
	DbSkip()
EndDo

oPrn:EndPage()
oPrn:Preview()

SET DEVICE TO SCREEN
MS_FLUSH()

dbSelectArea("SD2")
dbCloseArea()
FERASE(cArq+OrdBagExt())

Return() 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg บAutor  ณAlex Matosณ Data ณ 20/02/13              บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณTratamento das perguntas na SX1.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณProtheus11 - CRC NATURAL FORJA                              บฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/       


Static Function ValidPerg()

_sAlias := GetArea()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg   := PADR(cPerg,10)
aRegs   := {}

AADD(aRegs,{cPerg,"01","De Nota    ?","","","mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SF2","",""})
AADD(aRegs,{cPerg,"02","Ate Nota    ?","","","mv_ch2","C",09,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SF2","",""})
AADD(aRegs,{cPerg,"03","Serie     ?","","","mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
//AADD(aRegs,{cPerg,"04","ate Serie     ?","","","mv_ch4","C",01,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","",""})


For i := 1 To Len(aRegs)
    If !dbSeek(cPerg+aRegs[i,2])
        RecLock("SX1",.T.)
        For j := 1 To FCount()
            If j <= Len(aRegs[i])
                FieldPut(j,aRegs[i,j])
            Else
               Exit
            EndIf
        Next
        MsUnlock()
    EndIf
Next

dbSelectArea(_sAlias)

Return