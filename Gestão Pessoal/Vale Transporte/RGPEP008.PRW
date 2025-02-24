#INCLUDE "PROTHEUS.CH"  
#Include "TOPCONN.CH" 
#Include "RwMake.CH"  
#include "Fileio.ch"
#Define CRLF CHR(13)+CHR(10) 

/*
|===========================================================================|
| Programa  | RGPEP008   | Autor| Valdemir Miranda       | Data : 26/09/2018|
|===========================================================================|
| Descrição : Gerar arquivo de Compra de Vale Transporte em Formato Texto   |
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
User Function RGPEP008() 
Private cArea52     :=GETAREA()                        
Private cAliasA  	:="" 
Private cAliasB     :=""
Private wTexto 		:=""
Private cTexto      :=""
Private nColuna01   :=1 
Private cTextTotais :="" 
Private cTextEnd    :=""  
Private cQuebra		:=""    
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
Private xarquivox   :="" 
Private cSituacao   :=""
Private cCategoria  :=""
Private WHORAX1		:=LEFT(TIME(),2)+"_"+SUBSTR(TIME(),4,2)  
Private wxhorax 	:=LEFT(TIME(),2)+"_"+SUBSTR(TIME(),4,2)+"_"+SUBSTR(TIME(),7,2)  
Private nLinha      :=0
Public  aLinha      := {} 
Public  aLinha2     := {} 

// ... Inicializa Parametros ...     
lPerg  :=lTemreg :=.f.
If lPerg ==.F.
   PGNSGPEP08() 
Endif        

// ...
lParametro:=Pergunte("NSPGPEP8",.T.)

If !lParametro
	Return
EndIf
lPerg:=.t. 

Processa({||GeraArqVT1()}, "Gera Arquivo de Compra de Vale Transporte"+time() )
Return
            
/*
;===========================================================================;
; Programa  ; GeraArqTexto;Autor; Valdemir Miranda       ; Data : 26/09/2018;
;===========================================================================;
; Descrição : Exportação de Arquivo de Vale Transporte                      ;
;===========================================================================;
*/
Static Function GeraArqVT1()

  // *** Definer variaveis com Situação e Categoria do Funcionário *** //
Private cSituacao  := fSqlICFNS1(mv_par07,1)
Private cCategoria := fSqlICFNS1(mv_par08,1) 
     
******************************************************************************
* ... Processamento da Geração de Arquivo de Vale Transporte em Texto     ...*
******************************************************************************
  
cQuery ="Select * "
cQuery +=" from  "+RetSqlName("SRA")+" SRA" 

cQuery +=" WHERE D_E_L_E_T_= '' "

if .not. empty(mv_par01) 
	cQuery += " AND SRA.RA_FILIAL >= '" + mv_par01 + "' " 
	cQuery += " AND SRA.RA_FILIAL <= '" + mv_par02 + "' "  
endif 

if .not. empty(mv_par03)
	cQuery += " AND SRA.RA_CC >= '" + mv_par03 + "' " 
	cQuery += " AND SRA.RA_CC <= '" + mv_par04 + "' "  
endif 
  
if .not. empty(mv_par05)
	cQuery += " AND SRA.RA_MAT >= '" + mv_par05 + "' " 
	cQuery += " AND SRA.RA_MAT <= '" + mv_par06 + "' "  
endif 
//cQuery +=" AND SR0.R0_PERIOD =  '" + mv_par09 + "' "  

//cQuery += " AND RA_SITFOLH IN("+cSituacao+")"
//cQuery += " AND RA_CATFUNC IN("+cCategoria+")"     

cQuery += " ORDER BY SRA.RA_FILIAL,SRA.RA_MAT ASC " 

cAliasA	:= GetNextAlias() 
If Select( cAliasA ) > 0
   dbSelectArea( cAliasA )
   dbCloseArea()
EndIf   

// *** Abre Tabelas *** // 
cQry2 := ChangeQuery(cQuery)
dbUseArea(.T.,'TOPCONN', TCGENQRY(,,cQry2), cAliasA , .F., .T.)  

// ***
dbSelectArea(cAliasA) 
ProcRegua((cAliasA)->(LastRec()))
dbGoTop()   
 
// *** 
nColuna01:=1
cQuebra  :=""   
cTexto1  :=""
cTexto2  :="" 

Do While .not. eof()
            
   // ***
   IncProc("Colaborador: " + (cAliasA)->RA_MAT+" - "+(cAliasA)->RA_NOME) 
   
   // ***
   cAliasB	:=""
   cPesqSR0:=(cAliasA)->RA_FILIAL+(cAliasA)->RA_MAT+"0"
   aAreax51:=GETAREA()
   cQuery ="Select * "
   cQuery +=" from  "+RetSqlName("SR0")+" SR0" 
   cQuery +=" WHERE D_E_L_E_T_= '' " 
   
   cQuery +=" AND SR0.R0_FILIAL = '" + (cAliasA)->RA_FILIAL + "' "
   cQuery +=" AND SR0.R0_MAT = '" + (cAliasA)->RA_MAT + "' " 
   cQuery +=" AND SR0.R0_TPVALE = '0' " 
   
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
   do while .not. eof()        
   
      cPeriodo:=(cAliasB)->R0_PERIOD
      if alltrim(cPeriodo) =  alltrim(mv_par09)     
     
        // ***
        IncProc("Colaborador: " + (cAliasA)->RA_MAT+" - "+(cAliasA)->RA_NOME) 
     
        // *** Monta Quebra *** //
        if cQuebra <> (cAliasA)->RA_FILIAL+(cAliasA)->RA_MAT+"0"
         cQuebra:=(cAliasB)->R0_FILIAL+(cAliasB)->R0_MAT+(cAliasB)->R0_TPVALE    
         
         // ***
         IncProc("Colaborador: " + (cAliasA)->RA_MAT+" - "+(cAliasA)->RA_NOME) 
          
      
         // *** Ajusta Compo de RG *** //   
         cRG    :=""       
         cConvRG:=(cAliasA)->RA_RG
         convRG()
         cConvRG:=substr(cRG,1,9) 
         cDGRG  :=substr(cRG,10,1) 
              
         // *** Pega Endereço do Trabalho *** //
         cArea51:=GETAREA()  
         cEndTrab:=""
         dbSelectArea("SM0")
         cEndTrab:=SM0->M0_ENDCOB+";"+SM0->M0_ENDENT
         Restarea(cArea51)
          
         cRA_NASC:=(cAliasA)->RA_NASC
         cData1:=substr(cRA_NASC,7,2) +"/"+substr(cRA_NASC,5,2)+"/"+substr(cRA_NASC,1,4) 
         cTexto1:=cTexto1+(cAliasA)->RA_NOME+SPACE(10)+"|"+(cAliasA)->RA_MAE+"|"+cData1+"|"  
                
         cData2:=(cAliasA)->RA_DTRGEXP 
      
         if .not. empty(cData2)
            cData2:=substr(cData2,7,2)+"/"+substr(cData2,5,2)+"/"+substr(cData2,1,4) 
         else
            cData2:=space(8)
         endif 
               
         cTexto1:=cTexto1+(cAliasA)->RA_SEXO+"|"+cConvRG+";"+cDGRG+"|"+cData2+"|" 
      
         cTexto1:=cTexto1+(cAliasA)->RA_RGORG+"|"+(cAliasA)->RA_RGUF+"|"+strzero(val((cAliasA)->RA_CIC),11)+"|"+(cAliasA)->RA_PIS+"|"+(cAliasA)->RA_CEP+"|"
         cTexto1:=cTexto1+(cAliasA)->RA_ENDEREC+"|"+(cAliasA)->RA_LOGRNUM+"|"+(cAliasA)->RA_COMPLEM+"|"+(cAliasA)->RA_BAIRRO+"|"+(cAliasA)->RA_ESTADO+"|"+(cAliasA)->RA_MUNICIP
         cTexto1:=cTexto1+cEndTrab+"|"+(cAliasA)->RA_SPTRANS
         aadd(aLinha, cTexto1) 
        endif
     
        cTexto2:=cTexto2+(cAliasA)->RA_SPTRANS+"|"+alltrim(STR((cAliasB)->R0_QDIAINF))+"|"+TRANSFORM(((cAliasB)->R0_VLRVALE+(cAliasB)->R0_VLREMP),"@E 9999999.99")+"|"+(cAliasA)->RA_NOME 
        aadd(aLinha2, cTexto2) 
      endif
           
      // ***
      dbSelectArea(cAliasB)
      DBSKIP()  
   enddo
   set filter to  
   // ***                              
   dbSelectArea(cAliasB)
   use  
   Restarea(aAreax51)
   cAliasB:=""
   
   // *** Pula para o Próximo Registro *** // 
   dbSelectArea(cAliasA)  
   dbskip()
enddo 
 
// ***                              
dbSelectArea(cAliasA)
use  
Restarea(cArea52)

// *** Cria pasta onde será gravado o arquivo do Vale Transporte *** //
IF !ExistDir("C:\RELATORIOS")
   MakeDir("C:\RELATORIOS")
EndIF 

IF !ExistDir("C:\RELATORIOS\FOLHA")
   MakeDir("C:\RELATORIOS\FOLHA")
EndIF 
           

// --- GRAVA ARQUIVO --- //    
cGrava1:=""
if mv_par10 = 1
   wtam:=len(aLinha)
   if wtam >= 1 
      cGrava1:="1"
      GRVVTRAN1() 
      xarquivox :="COMPFUNCVT_"+wxhorax+"-"+substr(mv_par09,5,2)+"-"+substr(mv_par09,1,4)+".TXT"               
      alert("Foi criado a pasta C:\RELATORIOS\FOLHA\, contendo arquivo denominado "+xarquivox+", no formato TXT")  
   endif
endif

// *** Grava Compra do VT *** // 
wtam:=len(aLinha2) 
cResult:=alinha2[1][1]
alert("Qtd. Itens.: "+str(len(alinha2))+" => 2 => "+cTexto2)  
alert("Passo 6.00"+cResult)      
if wtam >= 1  
   cGrava1:="2"
   GRVVTRAN2()     
   
   alert("Passo 6.1")
   
   xarquivox :="COMPRAVT_"+wxhorax+"-"+substr(mv_par09,5,2)+"-"+substr(mv_par09,1,4)+".TXT"               
   alert("Foi criado a pasta C:\RELATORIOS\FOLHA\, contendo arquivo denominado "+xarquivox+", no formato TXT")   
   alert("Passo 5.1")
endif 
Return 

/*
;===========================================================================;
; Programa  ; convRG     ; Autor; Valdemir Miranda       ; Data : 12/07/2017;
;===========================================================================;
; Descrição : Ajusta número do RG                                           ;
;===========================================================================;
*/
Static Function convRG()

cRG    :=""       
cConvRG:=alltrim((cAliasA)->RA_RG)
nQtdRG :=len(cConvRG)
for ix1:=1 to nQtdRG
    if substr(cConvRG,ix1,1) $"./,/-" 
    else
       cRG:=cRG+substr(cConvRG,ix1,1)
    endif
next ix1
cRG:=RIGHT('000000000000000'+LTRIM(RTRIM(cRG)),10)
Return   

/*
;===========================================================================;
; Programa  ; GRVVTRAN1  ; Autor; Valdemir Miranda       ; Data : 16/10/2018;
;===========================================================================;
; Descrição : Grava Arquivo de Compra de Vale Transporte                    ;
;===========================================================================;
*/  

Static Function GRVVTRAN1()

alert("Texto 1.1.2: "+aLinha[1][1])
xarquivox :="C:\RELATORIOS\FOLHA\COMPFUNCVT_"+wxhorax+"-"+substr(mv_par09,5,2)+substr(mv_par09,1,4)+".TXT"  
nArquivo := fcreate(xarquivox, FC_NORMAL)
if ferror() # 0
   msgalert ("ERRO AO CRIAR O ARQUIVO, ERRO: " + str(ferror()))
   lFalha := .t.
else
   for nLinha := 1 to len(aLinha)
   
    alert("Gravando Texto 1.1.2: "+aLinha[1][1])
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Programa  ;GRVVTRAN2  ;Autor ; VALDEMIR MIRANDA   ; Data ;  26/10/2018  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Desc.     ; Grava Arquivo Texto                                         ;;
;;           ;                                                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Uso       ; FOLHA DE PAGAMENTO / RECUSRSOS HUMANOS                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
*/
Static Function GRVVTRAN2()

alert("Texto 2.1.2: "+aLinha2[1][1])                             
xarquivox :="COMPRAVT_"+wxhorax+"-"+substr(mv_par09,5,2)+"-"+substr(mv_par09,1,4)+".TXT"
nArquivo := fcreate(xarquivox, FC_NORMAL)
if ferror() # 0
   msgalert ("ERRO AO CRIAR O ARQUIVO, ERRO: " + str(ferror()))
   lFalha := .t.
else
   for nLinha := 1 to len(aLinha2)  
    alert("Gravando Texto 2.1.2: "+aLinha2[1][1])
    fwrite(nArquivo, aLinha2[nLinha] + chr(13) + chr(10))
    if ferror() # 0
       msgalert ("ERRO GRAVANDO ARQUIVO, ERRO: " + str(ferror()))
       lFalha := .t.
    endif
   next
endif
fclose(nArquivo) 
RETURN

/*
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Programa  ;fSqlICFNS1;Autor  ; VALDEMIR MIRANDA   ; Data ;  12/07/2017  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Desc.     ; Funcao para Montar a Selecao da Clausula IN do SQL          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Uso       ; FOLHA DE PAGAMENTO / RECUSRSOS HUMANOS                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
*/              
Static Function fSqlICFNS1( cTextoy, nStep )

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
     
/*
;===========================================================================;
; Programa  ; PGNSGPEP06 ; Autor; Valdemir Miranda       ; Data : 12/07/2017;
;===========================================================================;
; Descrição : Acessa o Modulo de Montagem dos Parâmetros                    ;
;===========================================================================;
*/
Static Function PGNSGPEP08()   

Local _sAlias := Alias()
Local cPerg := PADR("NSPGPEP8",10)
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
aAdd(aRegs,{"Periodo (AAAAMM)?","¨C.Custo Ate ?","From Bank  ?","mv_ch9","C",6,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","",""})   
aAdd(aRegs,{"Grv Reg.do Func.?","¨GrvReg.Func.?","Tipo Rel. ?","mv_cha","N",1,0,0,"C","","mv_par10","Sim","Sim","Sim","","","Não","Não","Não","","","","","","","","","","","","","","","","","",""})

_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
dbSelectArea(_cAliasSX1)
(_cAliasSX1)->(dbSetOrder(2))

For nX:=1 to Len(aRegs)
	If !(dbSeek(cPerg+StrZero(nx,2)))
		RecLock(_cAliasSX1,.T.)
		(_cAliasSX1)->X1_GRUPO	:=cPerg
		(_cAliasSX1)->X1_ORDEM   	:=StrZero(nx,2)
		(_cAliasSX1)->x1_pergunt 	:=aRegs[nx][01]
		(_cAliasSX1)->x1_perspa	:=aRegs[nx][02]
		(_cAliasSX1)->x1_pereng	:=aRegs[nx][03]
		(_cAliasSX1)->x1_variavl	:=aRegs[nx][04]
		(_cAliasSX1)->x1_tipo		:=aRegs[nx][05]
		(_cAliasSX1)->x1_tamanho	:=aRegs[nx][06]
		(_cAliasSX1)->x1_decimal	:=aRegs[nx][07]
		(_cAliasSX1)->x1_presel	:=aRegs[nx][08]
		(_cAliasSX1)->x1_gsc		:=aRegs[nx][09]
		(_cAliasSX1)->x1_valid	:=aRegs[nx][10]
		(_cAliasSX1)->x1_var01	:=aRegs[nx][11]
		(_cAliasSX1)->x1_def01	:=aRegs[nx][12]
		(_cAliasSX1)->x1_defspa1	:=aRegs[nx][13]
		(_cAliasSX1)->x1_defeng1	:=aRegs[nx][14]
		(_cAliasSX1)->x1_cnt01	:=aRegs[nx][15]
		(_cAliasSX1)->x1_var02	:=aRegs[nx][16]
		(_cAliasSX1)->x1_def02	:=aRegs[nx][17]
		(_cAliasSX1)->x1_defspa2	:=aRegs[nx][18]
		(_cAliasSX1)->x1_defeng2	:=aRegs[nx][19]
		//-
		(_cAliasSX1)->x1_cnt02  	:=aRegs[nx][20]
		(_cAliasSX1)->x1_var03	:=aRegs[nx][21]
		(_cAliasSX1)->x1_def03	:=aRegs[nx][22]
		(_cAliasSX1)->x1_defspa3	:=aRegs[nx][23]
		(_cAliasSX1)->x1_defeng3	:=aRegs[nx][24]
		(_cAliasSX1)->x1_cnt03  	:=aRegs[nx][25]
		(_cAliasSX1)->x1_var04	:=aRegs[nx][26]
		(_cAliasSX1)->x1_def04	:=aRegs[nx][27]
		(_cAliasSX1)->x1_defspa4	:=aRegs[nx][28]
		(_cAliasSX1)->x1_defeng4	:=aRegs[nx][29]
		(_cAliasSX1)->x1_cnt04  	:=aRegs[nx][30]
		(_cAliasSX1)->x1_var05	:=aRegs[nx][31]
		(_cAliasSX1)->x1_def05	:=aRegs[nx][32]
		(_cAliasSX1)->x1_defspa5	:=aRegs[nx][33]
		(_cAliasSX1)->x1_defeng5	:=aRegs[nx][34]
		(_cAliasSX1)->x1_cnt05  	:=aRegs[nx][35]
		(_cAliasSX1)->x1_f3     	:=aRegs[nx][36]
		(_cAliasSX1)->x1_grpsxg 	:=aRegs[nx][37]
		MsUnlock() 
		Dbunlock()
	Endif
Next nX
dbSelectArea(_sAlias)
   
Return      
