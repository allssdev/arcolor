 #INCLUDE "PROTHEUS.CH" 
#Include "TOPCONN.CH" 
#Include "RwMake.CH"  
#include "Fileio.ch"

/*
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Programa  |RGPER003   |Autor | VALDEMIR MIRANDA   | Data |  30/06/2018  ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Desc.     | Planilha de Eventos Ponto Eletr๔nico                        ||
||           |                                                             ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Uso       | FOLHA DE PAGAMENTO / RECUSRSOS HUMANOS                      ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
*/

User Function RGPER003()

Private oFont09N,oFont09,oFont20N,oFont20,oFont18N,oFont18,oFont16N,oFont16,oFont14N,oFont12N,oFont10N,oFont14,oFont12,oFont10,oFont08,oFontC08,oFontC10
Public WHORAX1:=LEFT(TIME(),2)+"_"+SUBSTR(TIME(),4,2),WHORA1:=SPACE(5),WHORA2:=SPACE(5)        
Public oPrint 
Private wLi     := 100
Private wxhorax :=LEFT(TIME(),2)+"_"+SUBSTR(TIME(),4,2)+"_"+SUBSTR(TIME(),7,2)    
Private _cTemp:= "",WXCABEC:="",WPAG:=0, xquebra:=""
Private aLinha := {}     
Private lEnd     := .F.
Private nLastKey := 0
Private cPerg    :="FPGPER01"
Private XMES:=MONTH(DDATABASE)
Private Meses   :={{"JANEIRO","FEVEREIRO","MARวO","ABRIL","MAIO","JUNHO","JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"}}
Private WDATAEXT:=SUBSTR(DTOC(DDATABASE),1,2)+" DE "+MESES[1][XMES] +" DE "+SUBSTR(DTOS(DDATABASE),1,4)   
Private cAliasA:=""
Private cQuebraCC:=""
Private cCusto  :=""  
Private Quebracc:=""
Private WHORAS  :=0.00  
Private WHORA1  :=0.00
Private WHORA2  :=0.00
    
// ***
WVIA    := 0 
wli     := 5000  
cFig    :="" 
cFig2   :="" 
cFig := GetSrvProfString("StartPath","")
cfig2:= GetSrvProfString("StartPath","") 

// ... Inicia uma nova pagina da TMSPRINTER ... //  
oPrint:= TMSPrinter():New("Resumo de Tributos, Pis e FGTs") 
oPrint:Setup()

oPrint:SetLandscape()   // Sempre Paisagem	
//oPrint:SetPortrait()  // Sempre Retrato  
oPrint:SETPAPERSIZE(9)  // 1 - Papel Carta = 9 - A4  

// ... Definicao dos Fontes Utilizados ... // 
oFont08N	:= TFont():New("Times New Roman",10,10,,.T.,,,,.T.,.F.)
oFont10N	:= TFont():New("Times New Roman",10,10,,.T.,,,,.T.,.F.)
oFont12	    := TFont():New("Times New Roman",12,12,,.F.,,,,.T.,.F.)
oFont12N	:= TFont():New("Times New Roman",12,12,,.T.,,,,.T.,.F.)
oFont14N	:= TFont():New("Times New Roman",14,14,,.T.,,,,.T.,.F.) 

oFontB12	:= TFont():New("Arial Black",12,12,,.T.,,,,.T.,.F.)
oFontB14	:= TFont():New("Arial Black",14,14,,.T.,,,,.T.,.F.) 
oFontB16	:= TFont():New("Arial Black",16,16,,.T.,,,,.T.,.F.) 
oFontB25	:= TFont():New("Arial Black",25,25,,.T.,,,,.T.,.F.)

// ... Inicializa Parametros ...     
lPerg  :=lTemreg :=.f.
If lPerg ==.F.
   PgRGPER003() 
Endif        

// ...
lParametro:=Pergunte("RGPER003",.T.)

If !lParametro
	Return
EndIf
lPerg:=.t.

* ...
XAREA    :=GETAREA()
If nLastKey == 27
	Set Filter to
	Return
Endif   
             
Processa({||RRGPER003()}, "Planilha de Eventos Ponto Eletr๔nico"+time() )   

Return      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPgRGPER003  บAutor ณ Valdemir Miranda  บ Data ณ  30/06/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Parโmetros da Planilha de Eventos Ponto Eletr๔nico         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FOLHA DE PAGAMENTO / RECUSRSOS HUMANOS                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function  PgRGPER003() 
Local _sAlias := Alias()
Local cPerg := PADR("RGPER003",10)
Local aRegs :={}                       
Local nX  

lPerg  :=lTemreg :=.t.    
aAdd(aRegs,{"Dt.de Referencia?","จDt. do Ponto?","Dt.de Pagto ?","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})  
aAdd(aRegs,{"Filial       De ?","จForneced. De?","From Bank ?","mv_ch2","C",2,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SM0",""})  
aAdd(aRegs,{"Filial       Ate?","จForneced.Ate?","From Bank ?","mv_ch3","C",2,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SM0",""})   
aAdd(aRegs,{"C.de Custo   De ?","จForneced. De?","From Bank ?","mv_ch4","C",9,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","CTT",""})  
aAdd(aRegs,{"C.de Custo   Ate?","จForneced.Ate?","From Bank ?","mv_ch5","C",9,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","CTT",""})   
aAdd(aRegs,{"Matricula    De ?","จForneced. De?","From Bank ?","mv_ch6","C",6,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SRA",""})  
aAdd(aRegs,{"Matricula    Ate?","จForneced.Ate?","From Bank ?","mv_ch7","C",6,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SRA",""})   
aAdd(aRegs,{"Situa็ใo do Func?","จSitua็ใo    ?","Categoria ?","mv_ch9","C",20,0,0,"G","fSituacao","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{"Categoria       ?","จCategoria   ?","Categoria ?","mv_ch9","C",20,0,0,"G","fCategoria","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","",""})   

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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRGPER003  บAutor  ณValdemir Miranda   บ Data ณ 30/06/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPlanilha de Eventos Ponto Eletr๔nico                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ARS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RRGPER003()

// ***
Private cxsituacao :=" "
Private cxcategoria:="M" 
Private wopx1	   :="" 
Private wxprimvxyz :=0
Private nHE60 	   := 0.00
Private nHE130	   := 0.00
Private nHE420	   := 0.00 
Private nHE535	   := 0.00
Private nHE421	   := 0.00
Private nHE018	   := 0.00 
Private Quebracc   :=""

// *** Prepara Variavel com Situa็ใo do Funcionแrio *** //
wopx1:="" 
wxprimvxyz:=0
for ix1:=1 to len(mv_par08)
    if substr(mv_par08,ix1,1)<>"*" 
       if wxprimvxyz = 0
          wopx1:=wopx1+substr(mv_par08,ix1,1)+"/" 
          wxprimvxyz:=1
       else
          if substr(mv_par08,ix1,1) <> " " .and. substr(mv_par08,ix1,1) <> "*" 
             wopx1:=wopx1+substr(mv_par08,ix1,1)+"/" 
          endif
       endif
    endif
next ix1                                                                 
csituacao1:= wopx1    

// *** Prepara Variavel com Categoria do Funcionแrio *** //
wopx1:="" 
wxprimvxyz:=0
for ix1:=1 to len(mv_par09)
    if substr(mv_par09,ix1,1)<>"*" 
       if wxprimvxyz = 0
          wopx1:=wopx1+substr(mv_par09,ix1,1)+"/" 
          wxprimvxyz:=1
       else
          if substr(mv_par09,ix1,1) <> " " .and. substr(mv_par09,ix1,1) <> "*" 
             wopx1:=wopx1+substr(mv_par09,ix1,1)+"/" 
          endif
       endif
    endif
next ix1 
cxcategoria:=wopx1


// *** Monta Query de Processamento *** //   
cQry     := "SELECT * ,CTT.CTT_CUSTO,CTT.CTT_DESC01 "
cQry 	 += " FROM  "+RetSqlName("SRA")+" SRA " 

cQry 	 += " LEFT JOIN "+RetSqlName("CTT")+" CTT " 
cQry 	 += " ON CTT.CTT_CUSTO = SRA.RA_CC "
cQry 	 += " AND CTT.D_E_L_E_T_='' "  

cQry 	 += " LEFT JOIN "+RetSqlName("SRJ")+" SRJ " 
cQry 	 += " ON SRJ.RJ_FUNCAO = SRA.RA_CODFUNC "
cQry 	 += " AND SRJ.D_E_L_E_T_='' "
  
cQry 	 += " WHERE SRA.D_E_L_E_T_='' "    
  
cQry 	 += " AND SRA.RA_SITFOLH <> 'D' " 
cQry 	 += " AND SRA.RA_SITFOLH <> 'T' "
 
if .not. empty(mv_par02) 
   cQry += " AND SRA.RA_FILIAL >= '" + mv_par02 + "' " 
   cQry += " AND SRA.RA_FILIAL <= '" + mv_par03 + "' "  
endif  
 
if .not. empty(mv_par04)
	cQry += " AND SRA.RA_CC >= '" + mv_par04 + "' " 
	cQry += " AND SRA.RA_CC <= '" + mv_par05 + "' "  
endif

if .not. empty(mv_par06)
	cQry += " AND SRA.RA_MAT >= '" + mv_par06 + "' " 
	cQry += " AND SRA.RA_MAT <= '" + mv_par07 + "' "  
endif 
 
cQry 	 += " ORDER BY SRA.RA_FILIAL,SRA.RA_CC,SRA.RA_NOME,SRA.RA_MAT ASC "

cAliasA	:= GetNextAlias() 
If Select( cAliasA ) > 0
   dbSelectArea( cAliasA )
   dbCloseArea()
EndIf   
 
// *** Abre Tabelas *** //
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQry), cAliasA , .F., .T.) 
                 

// *** 
WXTEXTO:= "_______________________________________________________________________________________________________________________________________" 
aadd(aLinha, WXTEXTO) 

WXTEXTO:= "" +";"+"" +";"+"Planilha de Eventos Ponto Eletr๔nico" +";"+""+";"+"" +";"+ ""+";"+ ""+";"+""
aadd(aLinha, WXTEXTO)    

WXTEXTO:= "_______________________________________________________________________________________________________________________________________" 
aadd(aLinha, WXTEXTO)    

WXTEXTO:= "Matrํcula" +";"+"Nome" +";"+"Hora Extra 60%" +";"+"Horas extras 130%" +";"+"Faltas" +";"+ "D.S.R."+";"+ "Atrasos"+";"+"Adic .Noturno"
aadd(aLinha, WXTEXTO) 
cCusto:=CTT->CTT_DESC01 

// *** Inicio do Processamento de Funcionแrios em Atrazo *** //
dbSelectArea(cAliasA) 
ProcRegua((cAliasA)->(LastRec()))
dbGoTop()   

wli     :=5000 
xytlinha:=wli 
wquebCcusto:="" 
cQuebccFunc:=""
Do While .not. eof()

   IncProc("Colaborador: " + (cAliasA)->RA_MAT+" - "+(cAliasA)->RA_NOME) 
      
   // *** Verifica se a Situa็ใo/Status do Funcionแrio esta de acordo com os parโmetros selecionados *** //
   wimprime:="N" 
   if LEFT((cAliasA)->RA_SITFOLH,1) $csituacao1
      wimprime:="S"
   endif 
   
   // *** Verifica se a Categoria do Funcionแrio esta de acordo com os parโmetros selecionados *** //
   if wimprime = "S"
      if LEFT((cAliasA)->RA_CATFUNC,1) $cxcategoria
         wimprime:="S" 
      else
         wimprime:="N" 
      endif  
   endif
       
   // ***
   if wimprime == "S" 
      
      // *** Prepara Variavel de Pesquisa *** //
      cDtRefer:=left(dtos(mv_par01),6)
      cDtBase :=left(dtos(Ddatabase),6) 
      
      // *** Monta Query da tabela SRB *** // 
      cQry2 := "SELECT * "
      cQry2 += " FROM  "+RetSqlName("SPB")+" SPB "  
      cQry2 += " WHERE SPB.D_E_L_E_T_='' "   
      cQry2 += " AND SPB.PB_FILIAL = '" +(cAliasA)->RA_FILIAL + "' " 
      cQry2 += " AND SPB.PB_MAT = '" +(cAliasA)->RA_MAT + "' "   
      cQry2 += " AND SPB.PB_DATA = '" +dtos(mv_par01) + "' "
      cQry2 += " ORDER BY SPB.PB_FILIAL,SPB.PB_MAT,SPB.PB_PD ASC "

	  cAliasB	:= GetNextAlias() 
	  If Select( cAliasB ) > 0
  	     dbSelectArea( cAliasB )
         dbCloseArea() 
      endif     
        
      // *** Abre Tabelas *** //
	  dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQry2), cAliasB , .F., .T.)
	  
	  // ***
      nHE60 :=0.00
      nHE130:=0.00
      nHE420:=0.00
      nHE535:=0.00
      nHE421:=0.00
      nHE018:=0.00 
      
      // *** Inicio do Processamento dos Eventos *** //
	  dbSelectArea(cAliasB) 
	  ProcRegua((cAliasB)->(LastRec()))
	  dbGoTop() 
	  do while .not. eof()
	    
	     // *** Horas Extras 60% *** //
	     if (cAliasB)->PB_PD = "080" 
	        WHORA1:=alltrim(str(nHE60)) 
            WHORA2:=alltrim(str((cAliasB)->PB_HORAS))
            cCalcHoras1()
            nHE60:=WHORAS 
         endif 
	     
	     // *** Horas Extras 130% *** //
	     if (cAliasB)->PB_PD = "082"  
	        WHORA1:=alltrim(str((nHE130))) 
            WHORA2:=alltrim(str((cAliasB)->PB_HORAS))
            cCalcHoras1()
            nHE130:=WHORAS   
	     endif 
	      
	     // *** Faltas *** // 
	     if (cAliasB)->PB_PD ="420" 
	        nHE420:=(nHE420+(cAliasB)->PB_HORAS)
	     endif
	     
	     // *** DSR *** // 
	     if (cAliasB)->PB_PD = "535"
	        nHE535:=nHE535+((cAliasB)->PB_HORAS)  
	     endif 
	     
	      // *** Atrasos *** // 
	     if (cAliasB)->PB_PD ="421" 
	        WHORA1:=alltrim(str((nHE421))) 
            WHORA2:=alltrim(str((cAliasB)->PB_HORAS))
            cCalcHoras1()
            nHE421:=WHORAS
	     endif
	     
	     // *** ADICIONAL NOTURNO *** // 
	     if (cAliasB)->PB_PD ="018" .OR. (cAliasB)->PB_PD = "019"
	        WHORA1:=alltrim(str((nHE018))) 
            WHORA2:=alltrim(str((cAliasB)->PB_HORAS))
            cCalcHoras1()
            nHE018:=WHORAS
	     endif       
	     
	     // ***
	     dbselectarea(cAliasB)  
	     Dbskip()
	     if eof() .or. (cAliasB)->PB_MAT <>(cAliasA)->RA_MAT 
	        exit
	     endif
	  enddo    
	  
	  // **
	  dbselectarea(cAliasB)
      DBCLOSEAREA()
      
      // *** Soma Total de Horas *** //             
      nTotal:=nHE60 +nHE130+nHE420+nHE535+nHE421+nHE018
         
      // *** CABECALHO NO EXCEL *** // 
      if Quebracc <> ALLTRIM((cAliasA)->RA_CC) .and. nTotal > 0.00
         
         // ***
         cCusto:=(cAliasA)->CTT_DESC01
         Quebracc:=ALLTRIM((cAliasA)->RA_CC)
         
         WXTEXTO:= "_______________________________________________________________________________________________________________________________________" 
		 aadd(aLinha, WXTEXTO) 
		 
         cCusto:=cPagaCCusto(ALLTRIM((cAliasA)->RA_CC))  
         WXTEXTO:= cCusto +";"+"" +";"+"" +";"+""+";"+"" +";"+ ""+";"+ ""+";"+""
         aadd(aLinha, WXTEXTO)
         
         WXTEXTO:= "_______________________________________________________________________________________________________________________________________" 
		 aadd(aLinha, WXTEXTO)  

      endif 
      
      // *** Pula para a Pr๓xima Pแgina se a linha for igual ou maior que 2260 *** //
      if wli >= 2260 .and. nTotal > 0.00
      
         // ***  
         CbRelAnalCC()
          
         // ***
         oPrint:Say(wli,1500, cCusto, oFontB14)  
         
         wli:=wli+60
         oPrint:Line(wli,60,wli,3300)
	     wli:=wli+50 
      endif
   
      // *** Gera informa็๕es para cria็ใo de Arquivo no Formato Excel *** 
      if nTotal > 0.00	  
         
         // *** Converte Horas para centensimal *** //  
         //nHE60 :=cCovertHoras(nHE60)
      	 //nHE130:=cCovertHoras(nHE130)		 
      	 //nHE420:=cCovertHoras(nHE420)
      	 //nHE535:=cCovertHoras(nHE535)
      	 //nHE421:=cCovertHoras(nHE421)
      	 //nHE018:=cCovertHoras(nHE018)
      	 																	
         WXTEXTO:= "'"+(cAliasA)->RA_MAT +";"+(cAliasA)->RA_NOME +";"+ConVlrVirgula(nHE60)+";"+ConVlrVirgula(nHE130)+";"+ConVlrVirgula(nHE420)+";"+ ConVlrVirgula(nHE535)+";"+ConVlrVirgula(nHE421)+";"+ConVlrVirgulacPagaCCusto(nHE018)
         aadd(aLinha, WXTEXTO) 
         
         // *** Imprime Linha Detalhe *** //
         oPrint:Say(wli,90,(cAliasA)->RA_MAT , oFont10N)  
	     oPrint:Say(wli,300, (cAliasA)->RA_NOME, oFont10N)
	     oPrint:Say(wli,1500, TRANSFORM(nHE60,"@E 999,999.99"), oFont10N) 
	     oPrint:Say(wli,1900, TRANSFORM(nHE130,"@E 999,999.99"), oFont10N)
	     oPrint:Say(wli,2200, TRANSFORM(nHE420,"@E 999,999.99"), oFont10N)
	     oPrint:Say(wli,2500, TRANSFORM(nHE535,"@E 999,999.99"), oFont10N)
	     oPrint:Say(wli,2800, TRANSFORM(nHE421,"@E 999,999.99"), oFont10N) 
	     oPrint:Say(wli,3100, TRANSFORM(nHE018,"@E 999,999.99"), oFont10N)
         wli:=wli+40    
      endif
       
      // ***
      nHE60 :=0.00
      nHE130:=0.00
      nHE420:=0.00
      nHE535:=0.00
      nHE421:=0.00
      nHE018:=0.00
   endif 
   
   // ***
   if wli >= 2260 
      ImpLinhas()  
      wli:=wli+40
   endif
   
   // *** Pula para o Pr๓ximo Registro *** //
   DBSELECTAREA(cAliasA)
   dbskip()  
   if .not. eof()
      IncProc("Colaborador: " + (cAliasA)->RA_MAT+" - "+(cAliasA)->RA_NOME)
   endif
   
enddo 

// *** 
xytlinha:=wli
oPrint:EndPage()   
oPrint:Preview()  

DBSELECTAREA(cAliasA)
DBCLOSEAREA() 

Restarea(xarea) 
Set device to Screen 

// *** 
WXTEXTO:= "_______________________________________________________________________________________________________________________________________" 
aadd(aLinha, WXTEXTO)  

IF !ExistDir("C:\RELATORIOS")
   MakeDir("C:\RELATORIOS")
EndIF 

IF !ExistDir("C:\RELATORIOS\FOLHA")
   MakeDir("C:\RELATORIOS\FOLHA")
EndIF 

// --- GRAVA ARQUIVO NO PADRTรO EXCEL --- // 
xarquivox :="Planilha de Eventos Ponto Eletr๔nico  - "+wxhorax+" - "+DTOC(mv_par01)+".CSV"
wtam:=len(aLinha)
if wtam >1
   GrvFPGPER01()
endif                     
alert("Foi criado a pasta C:\RELATORIOS\FOLHA\, contendo arquivo denominado "+xarquivox+", no formato excel") 

oPrint:EndPage()  

//*** ------------------------------------------ *** //
//GERAวรO DO ARQUIVO *.CSV
//---------------------------------------------- 
xarquivox:="C:\RELATORIOS\FOLHA\Planilha de Eventos Ponto Eletr๔nico  - "+wxhorax+" - "+WDATAEXT+".CSV"
/*If ! ApOleClient( 'MsExcel' )
	MsgAlert( 'MsExcel nao instalado')
	Return
Else
	ShellExecute( "Open" , xarquivox ,"", "" , 3 )
EndIf

fClose(xarquivox)*/
MsgAlert( "Arquivo Gerado!" )
Return .T.
  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCbRelAnalCC  บAutor ณValdemir Miranda    บ Data ณ 03/07/2015บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCabe็alho de Centro de Custo                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ARS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CbRelAnalCC() 
                                         
   // ... 
   if wli >= 2260

	  oPrint:EndPage()
	  cFig := GetSrvProfString("StartPath","")
      cfig2:= GetSrvProfString("StartPath","") 
      cFig :=cFig+"Logo_Folha_Pagto.BMP " 
	  cFig2:=cfig2+"Logo_Folha_Pagto.BMP" 	     

      If File(cFig)
         _CopyFile(Substr(cFig,1,Len(cFig)-4)+".BKP",Substr(cFig,1,Len(cFig)-4)+".JPG") 
      Endif

	  // *** Imprime Cabecalho *** //  
	  Set Century On      
	  oPrint:StartPage() 		// Inicia uma nova pagina
	  wvia:=wvia+1         
	  wli:=90   
	  
      // ... Monta Quadro ... //    
	  oPrint:Line(90,60,90,3300) 
	  oPrint:Line(90,60,2300,60)  
	  oPrint:Line(2300,60,2300,3300) 
	     
	  // ... Desenha Quadro Principal ... //
      ImpBox(oPrint,90,60, 2300, 3300,6)
	 	   
	  // ... Divisao Vertical ... //
	  oPrint:Line(90,680,390,680)
	  oPrint:Line(90,2900,390,2900)  
	  
	  // ... Imprime Logotipo ... //
	  oPrint:SayBitmap(120,90,cFig,580,200)     
	  
	  wxdatax:=  SUBSTR(DTOS(mv_par01),7,2)+"/"+SUBSTR(DTOS(mv_par01),5,2)+"/"+LEFT(DTOS(mv_par01),4) 
	                            
	  // ... Imprime Razao Social ... // 
	  oPrint:Say(170,1000,SM0->M0_NOMECOM , oFontB16)
	  //oPrint:Say(170,1400,"MAXIPARK", oFontB25)  
	  oPrint:Say(129,2950, "Pag. : "+strzero(wvia,4) , oFont12N)  
	  oPrint:Say(180,2950, "Data : "+wxdatax , oFont12N)   
	  oPrint:Say(220,2950,"Hora : "+LEFT(TIME(),5) , oFont12N) 

	  oPrint:Line(280,2900,280,3300) 
	  oPrint:Say(310,2950,"RGPER003.PRW" , oFont12N)
	  oPrint:Line(390,60,390,3300)    
	  
	  mxmex1:=month(mv_par01)
	  wdt1:=SUBSTR(DTOS(mv_par01),7,2)+"/"+MESES[1][mxmex1]+"/"+LEFT(DTOS(mv_par01),4) 
	  
	    
	  WTITULO:="Planilha de Eventos Ponto Eletr๔nico "+wdt1
      oPrint:Say(395,700,WTITULO, oFontB14)
	                                  
	  oPrint:Line(470,60,470,3300)
	  wli:=50  
	  
	  //*** Imprime Cabecalho do Centro de Custo ***// 
	  oPrint:Say(510,90,"Matrํcula" , oFont10N)  
	  oPrint:Say(510,300, "Nome", oFont10N)
	  oPrint:Say(510,1500, "Horas extras 60%", oFont10N) 
	  oPrint:Say(510,1900, "Horas extras 130%", oFont10N)
	  oPrint:Say(510,2200, "Faltas", oFont10N)
	  oPrint:Say(510,2500, "DSR", oFont10N)
	  oPrint:Say(510,2800, "Atrasos", oFont10N)
	  oPrint:Say(510,3100, "Adic .Noturno", oFont10N) 
      oPrint:Line(550,60,550,3300)
	  wli     :=600 
	  xytlinha:=470 
   endif	  
Return

// ***
/*
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Programa  |GrvFPGPER01|Autor | VALDEMIR MIRANDA   | Data |  27/05/2016  ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Desc.     | Imprime Tra็o Vertical                                      ||
||           |                                                             ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Uso       | FOLHA DE PAGAMENTO / RECUSRSOS HUMANOS                      ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
*/  
Static function ImpLinhas() 

// ... Imprime Cabecalho dos Itens das F้rias... // 
wtxlin:=wli  
oPrint:Line(xytlinha,290,wtxlin,290)
oPrint:Line(xytlinha,1490,wtxlin,1490) 
oPrint:Line(xytlinha,1890,wtxlin,1890)
oPrint:Line(xytlinha,2190,wtxlin,2190)
oPrint:Line(xytlinha,2490,wtxlin,2490)
oPrint:Line(xytlinha,2790,wtxlin,2790)
oPrint:Line(xytlinha,3090,wtxlin,3090)
Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpBox    บAutor  ณValdemir Miranda    บ Data ณ 11/10/2007  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime um box simulando o negrito                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ARS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ImpBox(oObj,nLin,nCol,nLinF,nColF,nPixel)
Local nwnk 
For nwnk := 1 to nPixel
	oObj:Box(nLin,nCol,nLinF,nColF)
	nLin++
	nCol++
	nLinF--
	nColF--
Next

Return 


/*
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Programa  |GrvFPGPER01|Autor | VALDEMIR MIRANDA   | Data |  27/05/2016  ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Desc.     | Grava Arquivo Texto                                         ||
||           |                                                             ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Uso       | FOLHA DE PAGAMENTO / RECUSRSOS HUMANOS                      ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
*/
Static Function GrvFPGPER01()
                             
xarquivox :="C:\RELATORIOS\FOLHA\Planilha de Eventos Ponto Eletr๔nico  - "+wxhorax+" - "+WDATAEXT+".CSV"
nArquivo := fcreate(xarquivox, FC_NORMAL)
if ferror() # 0
   msgalert ("ERRO AO CRIAR O ARQUIVO, ERRO: " + str(ferror()))
   lFalha := .t.
else
   for nLinha := 1 to len(aLinha)
    fwrite(nArquivo, aLinha[nLinha] + chr(13) + chr(10))
    if ferror() # 0
       msgalert ("ERRO GRAVANDO ARQUIVO, ERRO: " + str(ferror()))
       lFalha := .t.
    endif
   next
endif
fclose(nArquivo) 
RETURN


/*
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Programa  |cCovertHoras|Autor | VALDEMIR MIRANDA   | Data |  03/07/2018 ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Desc.     | Grava Arquivo Texto                                         ||
||           |                                                             ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Uso       | FOLHA DE PAGAMENTO / RECUSRSOS HUMANOS                      ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
*/
Static Function cCovertHoras(nHsx1)
Local nHorasx1:=nHsx1 
Local nMinutos:=0.00   
                                   
cHorasx1:=alltrim(str(nHorasx1,10,2))
cMinutos:="0."+right(alltrim(str(nHorasx1)),2) 
cminuto:=right(alltrim(str(nHorasx1,10,2)),2)

// *** Verifica se minutos ้ igual a zero *** //
if val(cminuto) < 1 
   Return(nHsx1)
endif

chsx1:=""
for kx1:=1 to len(cHorasx1)
    if substr(cHorasx1,kx1,1) <> "." 
       if substr(cHorasx1,kx1,1) <> ","
          chsx1:=chsx1+substr(cHorasx1,kx1,1) 
       else
          exit
       endif
    else
       exit
    endif
Next kx1 

// ***
nHorasx1:=val(chsx1)  
nMinutos2:=val("0."+alltrim(str(ROUND(VAL(cMinutos)*60,0))))
nHorasx2:=nHorasx1+nMinutos2
nHorasx1:=nHsx1 
nMinutos:=0.00

Return(nHorasx2)   

/*
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Programa  |cPagaCCusto |Autor | VALDEMIR MIRANDA   | Data |  02/08/2018 ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Desc.     | Captura Descri็ใo do Centro de Custo                        ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Uso       | FOLHA DE PAGAMENTO / RECUSRSOS HUMANOS                      ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
*/
Static Function cPagaCCusto(cCCusto1)  
Local cDescCCusto:=""
Local cArax51x:=Getarea()  

// ***
dbselectarea("CTT")
dbsetorder(1)
set filter to CTT_CUSTO = cCCusto1 
dbgotop() 
if .not. eof()
   cDescCCusto:=CTT->CTT_DESC01 
endif
Set Filter to  
Restarea(cArax51x)
Return(cDescCCusto) 

/*
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Programa  |cPagaCCusto |Autor | VALDEMIR MIRANDA   | Data |  02/08/2018 ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Desc.     | Converte ponto para Virgula nos Valores da Planilha Excel   ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Uso       | FOLHA DE PAGAMENTO / RECUSRSOS HUMANOS                      ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
*/
Static Function ConVlrVirgula(nValHoras)  
Local cValhoras:=alltrim(str(nValHoras,10,2))
Local nQtdVal  := len(cValhoras)
Local cVal001  :=""
Local cArax51x :=Getarea()  

// *** Localiza Centro de Custo *** //
For ixik:=1 to nQtdVal
    if substr(cValhoras,ixik,1) <> "."
       cVal001:=cVal001+substr(cValhoras,ixik,1)
    else
       cVal001:=cVal001+","
    endif
Next ixik

Return(cVal001)  


/*
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Programa  |cCalcHoras1 |Autor | VALDEMIR MIRANDA   | Data |  29/10/2018 ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Desc.     | Cแlculo de Horas                                            ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|| Uso       | FOLHA DE PAGAMENTO / RECUSRSOS HUMANOS                      ||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
*/
Static Function cCalcHoras1()      

        // *** ... Calcula Hora ... ***  /      
        WATRAZO:= 0.00
        WHORAS := 0.00
        WMI1   :=""
        WMI2   :=""
        
        // ***
        WQ:=LEN(alltrim(WHORA1))
        whs1:=""   
        cEnt1:="S"     
        for xk1:=1 to WQ
           if substr(WHORA1,xk1,1) <> "." .and. cEnt1 = "S"
              WHS1:=WHS1+substr(WHORA1,xk1,1) 
           else
              cEnt1:= "N" 
              WMI1:=WMI1+substr(WHORA1,xk1,1)
           endif                 
        next xk1
        
        // ***     
        cQTDMin1:=0.00
        if val(WMI1) > 0 
           cMin1:="0"+WMI1+"999"
           cQTDMin1:=round(60 * val(cMin1),2)
           WMI11:=alltrim(str(cQTDMin1))
           cMin:=""
           for kxi:=1 to len(WMI11)
               if substr(WMI11,kxi,1)<>"."
                  cMin1:=cMin+substr(WMI11,kxi,1)
               endif
           next kxi
           cMin:="0."+cMin1 
           cQTDMin1:=round(val(cMin1),2)
           WMI1:=str(cQTDMin1)
        endif
         
        // *** Minutos da Hora 2 *** //
        WQ:=LEN(alltrim(WHORA2))
        WHS2:=""
        cEnt1:="S"
        for xk1:=1 to WQ
           if substr(WHORA2,xk1,1) <> "." .and. cEnt1 = "S"
              WHS2:=WHS2+substr(WHORA2,xk1,1) 
           else
              cEnt1:= "N" 
              WMI2:=WMI2+substr(WHORA2,xk1,1)
           endif
        next xk1          
        
        // *** Converte Minutos para Centesimal *** // 
        cQTDMin:=0.00
        if val(WMI2) > 0  
           cMin1:="0"+WMI2+"999"
           cQTDMin:=round(60 * val(cMin1),2)
           WMI21:=alltrim(str(cQTDMin))
           cMin:=""
           for kxi:=1 to len(WMI2)
               if substr(WMI21,kxi,1)<>"."
                  cMin:=cMin+substr(WMI21,kxi,1)
               endif
           next kxi
           cMin:="0."+cMin 
           cQTDMin:=round(val(cMin),2)
           WMI2:=str(cQTDMin)
           
        endif  
        
        WMI2:=cQTDMin
        whs:=WHS1+WHS2 
        WMINUTO:=val(WMI1)+WMI2 
        if WMINUTO > 60
           WMINUTO:=WMINUTO - 60
           whs:=whs + 1
           if WMINUTO > 60
              WMINUTO:=WMINUTO - 60
              whs:=whs + 1    
              whs:=iif(type("whs")="N",whs,val(whs))
              WMINUTO:=iif(type("WMINUTO")="N",WMINUTO,val(WMINUTO))
           else  
              whs:=iif(type("whs")="N",whs,val(whs))
              WMINUTO:=iif(type("WMINUTO")="N",WMINUTO,val(WMINUTO))
           endif 
        else    
           whs:=iif(type("whs")="N",whs,val(whs))
           WMINUTO:=iif(type("WMINUTO")="N",WMINUTO,val(WMINUTO))
        endif 
          
        // ***
        WHORAS :=whs+WMINUTO
        WATRAZO:= str(WHORAS,5,2) 
        WHORAS :=val(WATRAZO)
        
        //alert((cAliasb)->PB_PD+" ==> Horas: "+str(WHORAS)+"  Minuto: "+str(WMINUTO))
         
 Return          




