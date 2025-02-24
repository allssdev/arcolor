#INCLUDE "PROTHEUS.CH"  
#Include "TOPCONN.CH" 
#Include "RwMake.CH"  
#include "Fileio.ch"
#Define CRLF CHR(13)+CHR(10) 

/*
|===========================================================================|
| Programa  | RGPEP009   | Autor| Valdemir Miranda       | Data : 26/09/2018|
|===========================================================================|
| Descrição : Cálculo do Vale Transporte                                    |
|===========================================================================|
|           ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL.               |
|===========================================================================|
|  Programador | Data   | BOPS |  Motivo da Alteracao                       | 
|==============|========|======|============================================|
|              |        |      |                                            |
|              |        |      |                                            |
|              |        |      |                                            |
|              |        |      |                                            |
|===========================================================================|
*/

* ...
User Function RGPEP009() 
    
Private mv_par01    :=""
Private mv_par02    :="" 
Private mv_par03    :=""
Private mv_par04    :="" 
Private mv_par05    :=""  
Private mv_par06    :=""
Private mv_par07    :="" 
Private mv_par08    :=""
Private mv_par09    :="" 
Private mv_par10    :=""
Private mv_par11    :=""  
Private mv_par12    :=""
Private cRoteirox   :="VTR"
Private cDataFimx   :=""
Private nValVTransp :=0.00
Private nValVTFunc  :=0.00
Private nValVTEmp   :=0.00 
Private cAliasA     :=""
Private cAliasB     :=""   
Private nCalEfetuado:="N"
Public  dDt01       :=ctod("") 
Public  dDt02       :=ctod("") 
Public dDatCalc 	:=ctod("")   
Public dDatCalc1 	:=ctod("")
Public dDatCalc2 	:=ctod("")
Public  nQTDdiasProp:=0    
Public  nDiasFer    :=0


// ... Inicializa Parametros ...     
lPerg  :=lTemreg :=.f.
If lPerg ==.F.
   PGNSGPEP07() 
Endif        

// ...
lParametro:=Pergunte("NSPGPEP7",.T.)

If !lParametro
	Return
EndIf
lPerg:=.t. 

Processa({||CalcVTns()}, "Calculo de Vale Transporte"+time() ) 
 
if nCalEfetuado = "S"
  Alert("Calculo do Vale Transporte Efetuado com Sucesso")
endif
Return
            
/*
|===========================================================================|
| Programa  | GeraArqTexto|Autor| Valdemir Miranda       | Data : 26/09/2018|
|===========================================================================|
| Descrição : Importação de Valores Variaveis                               |
|===========================================================================|
*/
Static Function CalcVTns()

  // *** Definer variaveis com Situação e Categoria do Funcionário *** //
Private cSituacao  := fSqlInNS(mv_par07,1)
Private cCategoria := fSqlInNS(mv_par08,1) 
     
******************************************************************************
* ... Processamento de Calculo de Vale Transporte                         ...*
******************************************************************************   
cQry	:="Select SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_NOME,SRA.RA_CC,SRA.RA_ADMISSA,SRA.RA_SALARIO, SM7.M7_FILIAL,SM7.M7_MAT,SM7.M7_CODIGO,SM7.M7_QDIAINF,SM7.M7_COMPL,SM7.M7_TPCALC, "
cQry	+=" SRN.RN_COD,SRN.RN_DESC,SRN.RN_VUNIATU, "
cQry	+=" RCF.RCF_DUTILT "
cQry    += " FROM  "+RetSqlName("SRA")+" SRA"

cQry	+=" LEFT JOIN " + RetSqlName("SM7") + " SM7"
cQry	+=" ON SM7.M7_FILIAL = SRA.RA_FILIAL "
cQry	+=" AND SM7.M7_MAT = SRA.RA_MAT "
cQry	+=" AND SM7.D_E_L_E_T_ = '' "
 
cQry	+=" LEFT JOIN " + RetSqlName("SRN") + " SRN" 
cQry	+=" ON SRN.RN_COD = SM7.M7_CODIGO"
cQry	+=" AND SRN.D_E_L_E_T_ = ''"

cQry	+=" LEFT JOIN " + RetSqlName("RCF") + " RCF"
cQry	+=" ON RCF.RCF_PER = '" + mv_par09 + "' " 
cQry	+=" AND RCF.RCF_PROCES = '00001' " // O processo sempre será '00001' 
cQry	+=" AND SRN.D_E_L_E_T_ = ''

cQry	+=" WHERE SRA.D_E_L_E_T_ =''
if .not. empty(mv_par01) 
	cQry += " AND SRA.RA_FILIAL >= '" + mv_par01 + "' " 
	cQry += " AND SRA.RA_FILIAL <= '" + mv_par02 + "' "  
endif

if .not. empty(mv_par03)
	cQry += " AND SRA.RA_CC >= '" + mv_par03 + "' " 
	cQry += " AND SRA.RA_CC <= '" + mv_par04 + "' "  
endif   

if .not. empty(mv_par05)
	cQry += " AND SRA.RA_MAT >= '" + mv_par05 + "' " 
	cQry += " AND SRA.RA_MAT <= '" + mv_par06 + "' "  
endif  

cQry	+= " AND SRA.RA_SITFOLH <> 'T' " 
cQry	+= " AND SRA.RA_SITFOLH <> 'D' "
cQry    += " AND SRA.RA_SITFOLH IN("+cSituacao+")"
cQry    += " AND SRA.RA_CATFUNC IN("+cCategoria+")" 


cAliasA	:= GetNextAlias() 
If Select( cAliasA ) > 0
   dbSelectArea( cAliasA )
   dbCloseArea()
EndIf

// *** Abre Tabelas *** // 
cQuery := ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN', TCGENQRY(,,cQuery), cAliasA , .F., .T.)  
    
// ***
dbSelectArea(cAliasA) 
ProcRegua((cAliasA)->(LastRec()))
dbGoTop()
  
// ***   
Do While .not. eof()

   // ***                                                               
   dbSelectArea(cAliasA) 
   IncProc("Colaborador: " + (cAliasA)->RA_MAT+" - "+(cAliasA)->RA_NOME)
   
   // *** Calcula quantidade de Dias Proporcional a Admissão *** //   
   cDataFimx:=""
   nQTDdiasProp:=0 
   nDiasFer    :=0 
   dDt01  :=ctod("01/"+substr((cAliasA)->RA_ADMISSA,5,2)+"/"+substr((cAliasA)->RA_ADMISSA,1,4)) 
   nQtdFim:=(val(substr((cAliasA)->RA_ADMISSA,5,2)))
   if mv_par10 = 1
      if left((cAliasA)->RA_ADMISSA,6) = mv_par09
              
         ndiaAdmis:=substr((cAliasA)->RA_ADMISSA,7,2) 
         // *** Calcula quantidade de Dias Proporcionais a Admissão *** // 
         nQTDIni1:=substr((cAliasA)->RA_ADMISSA,7,2) 
         if substr(mv_par09,5,2) $"02"
            nQtdDFim:=29
         elseif substr(mv_par09,5,2) $"01/03/05/07/08/10/12"  
            nQtdDFim:=31
         elseif substr(mv_par09,5,2) $"04/06/09/11"  
            nQtdDFim:=30
         endif   
         
         dDt01  :=CTOD(ndiaAdmis+"/"+SUBSTR(mv_par09,5,2)+"/"+SUBSTR(mv_par09,1,4))
         dDt02  :=CTOD(strzero(nQtdDFim,2)+"/"+SUBSTR(mv_par09,5,2)+"/"+SUBSTR(mv_par09,1,4)) 
         dDatCalc1:=dDt01
         dDatCalc2:=dDt02 
               
         //// *** Calcula quantidade de Dias Proporcionais a Férias/Afastamento *** // 
         dDatCalc:=dDt01
         for ix1:=dDt01 to dDt02
             IF DOW(dDt01) > 1 .AND. DOW(dDt01) < 7
                nQTDdiasProp:=nQTDdiasProp+1  
             ENDIF  
             dDt01:=dDt01+1
         next ix1
      endif 
   endif  
   
   // *** Calcula quantidade de Dias Proporcional a Férias e Afastamentos *** //
   if mv_par11 = 1 
      PgAfastFer01() 
   endif 
   
   // *** Verifica se teve calculo de dias Proporcionais ***
   if nQTDdiasProp = 0
      nQTDdiasProp:=(cAliasA)->RCF_DUTILT
   endif
   
   // *** Verifica se tem dias de Vale Transp a Deduzir *** //
   if val(mv_par12) > 0
      nQTDdiasProp:=nQTDdiasProp-val(mv_par12)
   endif
   
   nVal6pcent := ((( ((cAliasA)->RA_SALARIO/30) * nQTDdiasProp ) * 6)/100)
   nValVTransp:=( ((cAliasA)->RN_VUNIATU * nQTDdiasProp) * (cAliasA)->M7_QDIAINF)
   
   if nVal6pcent > nValVTransp
      nValVTFunc := nValVTransp
      nValVTEmp  := 0.00
   else         
      nValVTFunc := nVal6pcent
      nValVTEmp  := (nValVTransp - nVal6pcent)
   endif 
   
   cMensag1x:=(cAliasA)->RA_MAT+" - "+(cAliasA)->RA_NOME+" - S.Base: "+alltrim(str((cAliasA)->RA_SALARIO))+" Qtd.Dias: "+alltrim(str(nQTDdiasProp))
   cMensag1x:=cMensag1x+" Val.VT.: "+alltrim(str(nValVTransp))+" VT Func.: "+alltrim(str(nValVTFunc))+" VT Emp.: "+alltrim(str(nValVTEmp))
   cMensag1x:=cMensag1x+"   Val.6%.:  "+alltrim(str(nVal6pcent))
   //ALERT(cMensag1x)
   
   // *** Grava Valor do Vale Transporte na Tabela RG2 *** //
   if nValVTransp > 0.00
      GRVTabRG2()
   endif
   
   // ***
   dbSelectArea(cAliasA)  
   DBSKIP()
Enddo 
dbSelectArea(cAliasA)  
use   
Return 

/*
|===========================================================================|
| Programa  | PgAfastFer01|Autor| Valdemir Miranda       | Data : 26/09/2018|
|===========================================================================|
| Descrição : Grava Dados na Tabela RG2-Vale Transporte                     |
|===========================================================================|
*/
Static Function GRVTabRG2() 
 
// *** Monta Chave de Pesquisa da Tabela RG2 *** //
cPSQRG2:=(cAliasA)->RA_FILIAL+(cAliasA)->M7_MAT+"01"+(cAliasA)->M7_CODIGO+mv_par09+   "01"+      "VTR"

/*                 
// ***
cAliasRG2x:=GETAREA()
Dbselectarea("RG2")
dbsetorder(1)
Set Filter to RG2_FILIAL = (cAliasA)->RA_FILIAL .AND. RG2_MAT = (cAliasA)->M7_MAT .AND. RG2_TPVALE = "0" .AND. RG2_CODIGO = (cAliasA)->M7_CODIGO .AND. RG2_PERIOD = mv_par09 .AND. RG2_NROPGT = "01" .AND. RG2_ROTEIR = "VTR"  
dbgotop()                                                                                     
if eof()
   RecLock("RG2",.T.) 
else
   RecLock("RG2",.F.)
endif      

RG2->RG2_FILIAL	:=(cAliasA)->RA_FILIAL 
RG2->RG2_MAT	:=(cAliasA)->RA_MAT
RG2->RG2_PERIOD	:=mv_par09    
RG2->RG2_NROPGT :="01"  
RG2->RG2_ANOMES :=mv_par09
RG2->RG2_ROTEIR :="VTR"
RG2->RG2_VTDUTE :=(cAliasA)->M7_QDIAINF  
RG2->RG2_DUTILM :=nQTDdiasProp 
RG2->RG2_DIACAL :=(nQTDdiasProp * (cAliasA)->M7_QDIAINF )    
RG2->RG2_VALCAL :=nValVTransp 
RG2->RG2_CUSUNI :=(cAliasA)->RN_VUNIATU 
RG2->RG2_CUSFUN :=nValVTFunc  
RG2->RG2_CUSEMP :=nValVTEmp     
//RG2->RG2_PERC   :=6.00  
RG2->RG2_SALBSE :=(cAliasA)->RA_SALARIO   
RG2->RG2_CC		:=(cAliasA)->RA_CC
RG2->RG2_TPBEN	:="01" 
RG2->RG2_TPVALE	:="0" 
RG2->RG2_CODIGO	:=(cAliasA)->M7_CODIGO
RG2->RG2_FERIAS	:=nDiasFer  //Numerico
RG2->RG2_PEDIDO	:=1
RG2->RG2_NROPED :="0000000001"  
nCalEfetuado    :="S"
MsUnlock() 
Dbunlock()  
Restarea(cAliasRG2x)
Set Filter To
  
*/

// *** Monta Chave de Pesquisa da Tabela SR0 *** //
cPSQSR0:=(cAliasA)->RA_FILIAL+(cAliasA)->M7_MAT+"0"+(cAliasA)->M7_CODIGO

// ***
cAliasSR0x:=GETAREA()
Dbselectarea("SR0")
dbsetorder(3)
dbseek(cPSQSR0)
if eof()
   RecLock("SR0",.T.)
else
   RecLock("SR0",.F.)
endif  

// *** Ajusta quantidade de Dias de Afastamento
if nDiasFer > 0
   if nDiasFer > 20 
      if nDiasFer < 31 
         nDiasFer:=30
      else
        nDiasFer:=30
      endif
   else
      nDiasFer:=20
   endif 
else
   nDiasFer:=0
endif
 
SR0->R0_FILIAL	:=(cAliasA)->RA_FILIAL 
SR0->R0_MAT 	:=(cAliasA)->RA_MAT  
SR0->R0_QDIAINF :=(cAliasA)->M7_QDIAINF  
SR0->R0_QDIACAL :=(nQTDdiasProp * (cAliasA)->M7_QDIAINF )
SR0->R0_VALCAL	:=nValVTransp    
SR0->R0_CC		:=(cAliasA)->RA_CC   
SR0->R0_SALBASE	:=(cAliasA)->RA_SALARIO  
SR0->R0_TPVALE	:="0"   
SR0->R0_CODIGO	:=(cAliasA)->M7_CODIGO
SR0->R0_VLRVALE :=(cAliasA)->RN_VUNIATU 
SR0->R0_VLRFUNC :=nValVTFunc 
SR0->R0_VLREMP  :=nValVTEmp
SR0->R0_FERIAS  :=int(nDiasFer)     
SR0->R0_DUTILM 	:=nQTDdiasProp 
SR0->R0_TPCALC 	:="1" 
SR0->R0_PERIOD	:=mv_par09 
SR0->R0_NROPGT 	:="01"  
SR0->R0_ROTEIR 	:="VTR" 
SR0->R0_ANOMES 	:=mv_par09 
SR0->R0_PEDIDO	:="1"
SR0->R0_NROPED :="0000000001" 
SR0->R0_DTREFI	:=dDatCalc1           
SR0->R0_DTREFF	:=dDatCalc2 
nCalEfetuado    :="S"
MsUnlock() 
Dbunlock() 
Restarea(cAliasSR0x)

Return

/*
|===========================================================================|
| Programa  | PgAfastFer01|Autor| Valdemir Miranda       | Data : 26/09/2018|
|===========================================================================|
| Descrição : Calcula quantidade de Dias Proporcionais de Férias/Afastamento|
|===========================================================================|
*/
Static Function PgAfastFer01() 
Local cQuery :="" 
        
cQuery :="Select SR8.R8_FILIAL,SR8.R8_MAT,SR8.R8_DATA,SR8.R8_DATAINI,SR8.R8_DATAFIM,SR8.R8_PROCES,SR8.R8_DURACAO " 
cQuery +=" FROM " + RetSqlName("SR8") + " SR8"   
cQuery +=" WHERE SR8.D_E_L_E_T_ = '' "
cQuery +=" AND SR8.R8_FILIAL = '" + (cAliasA)->RA_FILIAL + "' " 
cQuery +=" AND SR8.R8_MAT = '" + (cAliasA)->RA_MAT + "' " 
cQuery +=" AND SR8.R8_PROCES = '00001' "  

cAliasB	:= GetNextAlias() 
If Select( cAliasB ) > 0
   dbSelectArea( cAliasB )
   dbCloseArea()
EndIf   

// *** Abre Tabelas *** // 
cQry2 := ChangeQuery(cQuery)
dbUseArea(.T.,'TOPCONN', TCGENQRY(,,cQry2), cAliasB , .F., .T.)  

// ***
dbSelectArea(cAliasB) 
ProcRegua((cAliasB)->(LastRec()))
dbGoTop()
  
// ***  
cCalcula1:="N" 
Do While .not. eof() 
  
  // ***
  if SUBSTR((cAliasB)->R8_DATA,1,6) =  mv_par09  
     cCalcula1:="S" 
  endif
  
  // ***
  if SUBSTR((cAliasB)->R8_DATAINI,1,6) =  mv_par09  
     cCalcula1:="S" 
  endif
  
  // ***
  if SUBSTR((cAliasB)->R8_DATAFIM,1,6) =  mv_par09  
     cCalcula1:="S" 
  endif   
  
  if cCalcula1 = "S" 
   cDataIniFx:=(cAliasB)->R8_DATAINI
   cDataFimx :=(cAliasB)->R8_DATAFIM    
   nDiasFer  :=(cAliasB)->R8_DURACAO
          
   // *** Calcula quantidade de Dias Proporcionais de Férias/Afastamento *** // 
   if left(cDataFimx,6) > mv_par09  
      nQTDIni1:=substr((cAliasB)->R8_DATAINI,7,2)
      if substr(mv_par09,5,2) $"02"
         nQtdDFim:=29
      elseif substr(mv_par09,5,2) $"01/03/05/07/08/10/12"  
         nQtdDFim:=31
      elseif substr(mv_par09,5,2) $"04/06/09/11"  
         nQtdDFim:=30
      endif
   else 
      nQTDIni1:=substr((cAliasB)->R8_DATAFIM,7,2)
      if substr(cDataFimx,5,2) $"02"
         nQtdDFim:=29
      elseif substr(cDataFimx,5,2) $"01/03/05/07/08/10/12"  
         nQtdDFim:=31
      elseif substr(cDataFimx,5,2) $"04/06/09/11"  
         nQtdDFim:=30
      endif
   endif 
                          
   cCalc01:="N"
   if left((cAliasB)->R8_DATAINI,6) = mv_par09    
   
      if val(substr((cAliasB)->R8_DATAINI,7,2)) > 1 
         dDt01  :=CTOD("01"+"/"+SUBSTR((cAliasB)->R8_DATAINI,5,2)+"/"+SUBSTR((cAliasB)->R8_DATAINI,1,4))
         dDatCalc1:=dDt01
         if left((cAliasB)->R8_DATAFIM,6) <> mv_par09 
            dDt02  :=CTOD(substr((cAliasB)->R8_DATAINI,7,2)+"/"+SUBSTR(mv_par09,5,2)+"/"+SUBSTR(mv_par09,1,4))
            dDatCalc2:=dDt02 
            cCalc01:="S"
         endif  
         
         if left((cAliasB)->R8_DATAFIM,6) = mv_par09 
            if val(substr((cAliasB)->R8_DATAFIM,7,2)) < nQtdDFim                           
               dDt02  :=CTOD(substr((cAliasB)->R8_DATAINI,7,2)+"/"+SUBSTR(mv_par09,5,2)+"/"+SUBSTR(mv_par09,1,4)) 
               dDatCalc2:=dDt02
               dDt02:=dDt02-1      
               cCalc01:="S" 
            endif
         endif
                  
         // *** Calcula Quantidade de Dias *** //  
         if cCalc01 = "S"
            CalVTProporc() 
         endif 
                           
         if val(substr((cAliasB)->R8_DATAFIM,7,2)) < nQtdDFim  .and. left((cAliasB)->R8_DATAFIM,6) = mv_par09 
            dDt01  :=CTOD(substr((cAliasB)->R8_DATAFIM,7,2)+"/"+SUBSTR(mv_par09,5,2)+"/"+SUBSTR(mv_par09,1,4)) 
            dDt02  :=CTOD(strzero(nQtdDFim,2)+"/"+"/"+SUBSTR(mv_par09,5,2)+"/"+SUBSTR(mv_par09,1,4)) 
            
            dDatCalc1:=dDt01
            dDatCalc2:=dDt02   
            
            // *** Calcula Quantidade de Dias *** //
            CalVTProporc() 
                 
         endif
      endif 
   else
      dDt01  :=CTOD(nQTDIni1+"/"+SUBSTR(mv_par09,5,2)+"/"+SUBSTR(mv_par09,1,4))
      dDt02  :=CTOD(strzero(nQtdDFim,2)+"/"+SUBSTR(mv_par09,5,2)+"/"+SUBSTR(mv_par09,1,4))
      
      dDatCalc1:=dDt01
      dDatCalc2:=dDt02  
      
      // *** Calcula Quantidade de Dias *** //
      CalVTProporc()  
   endif
   
  endif
   
  // ***
  dbSelectArea(cAliasB)
  DBSKIP()
Enddo 

// **
dbSelectArea(cAliasB)
use
Return

/*
|===========================================================================|
| Programa  | CalVTProporc| Autor| Valdemir Miranda      | Data : 26/09/2018|
|===========================================================================|
| Descrição : Função de Cálculo da Quantidade de Dias de Vale Transporte    |
|===========================================================================|
*/
Static Function CalVTProporc()
dDatCalc:=dDt01
for ix1:=dDt01 to dDt02
    IF DOW(dDt01) > 1 .AND. DOW(dDt01) < 7
       nQTDdiasProp:=nQTDdiasProp+1  
    ENDIF  
    dDt01:=dDt01+1
next ix1
Return  


/*
|===========================================================================|
| Programa  | PGNSGPEP07 | Autor| Valdemir Miranda       | Data : 26/09/2018|
|===========================================================================|
| Descrição : Acessa o Modulo de Montagem dos Parâmetros                    |
|===========================================================================|
*/
Static Function PGNSGPEP07()   

Local _sAlias := Alias()
Local cPerg := PADR("NSPGPEP7",10)
Local aRegs :={}
Local nX      

lPerg  :=lTemreg :=.t.    

aAdd(aRegs,{"Filial       De ?","¨Forneced. De?","From Bank ?","mv_ch1","C",2,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SM0",""})  
aAdd(aRegs,{"Filial       Ate?","¨Forneced.Ate?","From Bank ?","mv_ch2","C",2,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SM0",""})   
aAdd(aRegs,{"C.Custo      De ?","¨Forneced. De?","From Bank ?","mv_ch3","C",9,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","CTT",""})  
aAdd(aRegs,{"C.Custo      Ate?","¨Forneced.Ate?","From Bank ?","mv_ch4","C",9,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","CTT",""})   
aAdd(aRegs,{"Matricula    De ?","¨Forneced. De?","From Bank ?","mv_ch5","C",6,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SRA",""})  
aAdd(aRegs,{"Matricula    Ate?","¨Forneced.Ate?","From Bank ?","mv_ch6","C",6,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SRA",""})   
aAdd(aRegs,{"Situação do Func?","¨Forneced. De?","From Bank ?","mv_ch7","C",20,0,0,"G","fSituacao","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""})  
aAdd(aRegs,{"Categoria       ?","¨Categoria   ?","Categoria ?","mv_ch8","C",30,0,0,"G","fCategoria","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","",""})   
aAdd(aRegs,{"Periodo (AAAAMM)?","¨C.Custo Ate?","From Bank  ?","mv_ch9","C",6,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","",""})   
aAdd(aRegs,{"Proporc.Admissão?","¨Tipo de Rel.?","Tipo Rel. ?","mv_cha","N",1,0,0,"C","","mv_par10","Sim","Sim","Sim","","","Não","Não","Não","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{"Proporc.Fer/Afas?","¨Tipo de Rel.?","Tipo Rel. ?","mv_chb","N",1,0,0,"C","","mv_par11","Sim","Sim","Sim","","","Não","Não","Não","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{"Qtd.Vales Deduzi?","¨C.Custo Ate?","From Bank  ?","mv_chc","C",2,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","",""})   

_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
dbSelectArea(_cAliasSX1)
(_cAliasSX1)->(dbSetOrder(1))


For nX:=1 to Len(aRegs)
	If !(_cAliasSX1)->(dbSeek(cPerg+StrZero(nx,2)))
		RecLock(_cAliasSX1,.T.)
		(_cAliasSX1)->X1_GRUPO	:= cPerg
		(_cAliasSX1)->X1_ORDEM   	:= StrZero(nx,2)
		(_cAliasSX1)->x1_pergunt 	:= aRegs[nx][01]
		(_cAliasSX1)->x1_perspa	:= aRegs[nx][02]
		(_cAliasSX1)->x1_pereng	:= aRegs[nx][03]
		(_cAliasSX1)->x1_variavl	:= aRegs[nx][04]
		(_cAliasSX1)->x1_tipo		:= aRegs[nx][05]
		(_cAliasSX1)->x1_tamanho	:= aRegs[nx][06]
		(_cAliasSX1)->x1_decimal	:= aRegs[nx][07]
		(_cAliasSX1)->x1_presel	:= aRegs[nx][08]
		(_cAliasSX1)->x1_gsc		:= aRegs[nx][09]
		(_cAliasSX1)->x1_valid	:= aRegs[nx][10]
		(_cAliasSX1)->x1_var01	:= aRegs[nx][11]
		(_cAliasSX1)->x1_def01	:= aRegs[nx][12]
		(_cAliasSX1)->x1_defspa1	:= aRegs[nx][13]
		(_cAliasSX1)->x1_defeng1	:= aRegs[nx][14]
		(_cAliasSX1)->x1_cnt01	:= aRegs[nx][15]
		(_cAliasSX1)->x1_var02	:= aRegs[nx][16]
		(_cAliasSX1)->x1_def02	:= aRegs[nx][17]
		(_cAliasSX1)->x1_defspa2	:= aRegs[nx][18]
		(_cAliasSX1)->x1_defeng2	:= aRegs[nx][19]
		//-
		(_cAliasSX1)->x1_cnt02  	:= aRegs[nx][20]
		(_cAliasSX1)->x1_var03	:= aRegs[nx][21]
		(_cAliasSX1)->x1_def03	:= aRegs[nx][22]
		(_cAliasSX1)->x1_defspa3	:= aRegs[nx][23]
		(_cAliasSX1)->x1_defeng3	:= aRegs[nx][24]
		(_cAliasSX1)->x1_cnt03  	:= aRegs[nx][25]
		(_cAliasSX1)->x1_var04	:= aRegs[nx][26]
		(_cAliasSX1)->x1_def04	:= aRegs[nx][27]
		(_cAliasSX1)->x1_defspa4	:= aRegs[nx][28]
		(_cAliasSX1)->x1_defeng4	:= aRegs[nx][29]
		(_cAliasSX1)->x1_cnt04  	:= aRegs[nx][30]
		(_cAliasSX1)->x1_var05	:= aRegs[nx][31]
		(_cAliasSX1)->x1_def05	:= aRegs[nx][32]
		(_cAliasSX1)->x1_defspa5	:= aRegs[nx][33]
		(_cAliasSX1)->x1_defeng5	:= aRegs[nx][34]
		(_cAliasSX1)->x1_cnt05  	:= aRegs[nx][35]
		(_cAliasSX1)->x1_f3     	:= aRegs[nx][36]
		(_cAliasSX1)->x1_grpsxg 	:= aRegs[nx][37]
		MsUnlock() 
		Dbunlock()
	Endif
Next nX
dbSelectArea(_sAlias)
   
Return      

/*
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Programa  |fSqlINCFNS|Autor  | VALDEMIR MIRANDA   | Data |  26/09/2018  ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Desc.     | Funcao para Montar a Selecao da Clausula IN do SQL          ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Uso       | FOLHA DE PAGAMENTO / RECUSRSOS HUMANOS                      ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
*/              
Static Function fSqlInNS( cTextoy, nStep )

Local cRet := ""
Local i

cTextoy := Rtrim( cTextoy )

If Len( cTextoy ) > 0
	For i := 1 To Len( cTextoy ) Step nStep
		cRet += "'" + SubStr( cTextoy, i, nStep ) + "'"
		
		If i + nStep <= Len( cTextoy )
			cRet += ","
		EndIf
	Next
EndIf
Return( cRet )