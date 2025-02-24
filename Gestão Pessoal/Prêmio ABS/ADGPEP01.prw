#INCLUDE "PROTHEUS.CH"  
#Include "TOPCONN.CH" 
#Include "RwMake.CH"  
#include "Fileio.ch"
#Define CRLF CHR(13)+CHR(10) 

/*
|===========================================================================|
| Programa  | ADGPEP01 | Autor: Valdemir Miranda       | Data : 20/12/2016 |
|===========================================================================|
| Descrição : Modulo de Fechamento da Folha de Pagamento                    |
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
User Function ADGPEP01() 

Private lEnd		:=.F.   
Private cxRoteiro   :=" "
  
// ... Inicializa Parametros ...     
lPerg  :=lTemreg :=.f.
If lPerg ==.F.
   PGPARFECTO() 
Endif        

// ...
lParametro:=Pergunte("FPGPEP06",.T.)
If !lParametro
	Return
EndIf
lPerg:=.t.

Processa({||FechtoFol01()}, "Fechamento da Folha de Pagamento "+time() )          

Return  


/*
|===========================================================================|
| Programa  | FechtoFol01 | Autor| Valdemir Miranda     | Data : 02/05/2016 |
|===========================================================================|
| Descrição : Função de Fechamento da Folha de Pagamento                    |
|                                                                           |
|===========================================================================|
*/
Static Function FechtoFol01()

Local cRoteiro:=""
Private aAreax01:=Getarea()

// *** Monta Variável com Roteiros a serem Fechados *** //
if mv_par03 =1 
   cxRoteiro:="ADI" 
elseif mv_par03 =2   
   cxRoteiro:="AUT"
elseif mv_par03 =3
   cxRoteiro:="RES"
elseif mv_par03 =4  
   cxRoteiro:="FER"
elseif mv_par03 =5 
   cxRoteiro:="FOL"
elseif mv_par03 =6
     cxRoteiro:="Todos"
endif  

// ***
DBSELECTAREA("SRA")
DBSETORDER(1) 
ProcRegua(SRA->(LastRec()))
DBGOTOP()  

// ***
DO WHILE .NOT. EOF()
   
   // ***                 
   IncProc("Colaborador: " + SRA->RA_MAT+" - "+SRA->RA_NOME) 
      
   // *** Seleciona Tabela de Movimento da Folha de Pagamento *** //            
   DBSELECTAREA("SRC")
   DBSETORDER(1)      
   DBSEEK(SRA->RA_FILIAL+SRA->RA_MAT)
   IF .NOT. EOF()
      DO WHILE .NOT. EOF() 
      
         cxGrv1:="S"
         if .not. empty(mv_par01)
            if Left(mv_par02,1) $"z/Z"
            else  
               if SRA->RA_FILIAL >= mv_par01 .AND. SRA->RA_FILIAL <= mv_par02
                  cxGrv1:="S"
               else
                  cxGrv1:="N" 
               endif
            endif  
         endif
                      
         if SRC->RC_PERIODO >= mv_par04 .and. SRC->RC_PERIODO <=mv_par05 .and. cxGrv1 = "S"
            if SRC->RC_ROTEIR = cxRoteiro .or. cxRoteiro = "Todos"  
               GRVFICHASRD()
            endif 
         endif
         
         dbselectarea("SRC")
         DBSKIP()
         IF .NOT. EOF() 
            IF SRC->RC_FILIAL+SRC->RC_MAT = SRA->RA_FILIAL+SRA->RA_MAT
               LOOP
            ENDIF
         ENDIF
         EXIT   
      ENDDO
   ENDIF   
      
   // ***
   DBSELECTAREA("SRA")
   DBSKIP()
ENDDO    
Restarea(aAreax01)


// *** Exclui Registros Fechados *** // 
AxArea1:=Getarea()
DBSELECTAREA("SRA")
DBSETORDER(1)
ProcRegua(SRA->(LastRec()))
DBGOTOP()  

// ***
DO WHILE .NOT. EOF() 
   
   // ***                 
   IncProc(" *** Aguarde, Finalizando Fechamento ==> "+ SRA->RA_MAT+" - "+SRA->RA_NOME) 
   
   // *** Seleciona Tabela de Movimento da Folha de Pagamento *** // 
   cxGrv1:="S" 
   aAreaSRC0:=GETAREA()         
   DBSELECTAREA("SRC")
   DBSETORDER(1)      
   DBSEEK(SRA->RA_FILIAL+SRA->RA_MAT)
   IF .NOT. EOF()
      DO WHILE .NOT. EOF()  
            
         cxGrv1:="S"
         if .not. empty(mv_par01)
            if mv_par02 <> "zzzzzzz" .or. mv_par02 <> "ZZZZZZ" 
               if SRA->RA_FILIAL >= mv_par01 .AND. SRA->RA_FILIAL <= mv_par02
                  cxGrv1:="S"
               else
                  cxGrv1:="N" 
               endif
            endif  
         endif
                              
         if SRC->RC_PERIODO >= mv_par04 .and. SRC->RC_PERIODO <=mv_par05 .and. cxGrv1 = "S" 
            if SRC->RC_ROTEIR = cxRoteiro .or. cxRoteiro = "Todos"
               if SRC->RC_FILIAL = SRA->RA_FILIAL   
                                     
                  // *** Atualiza Data de Fechamento da folha ***// 
                  aAreaRCH:=Getarea()
   			      DBSELECTAREA("RCH")
   			      DBSETORDER(1) 
   			      DBGOTOP()
   			      DO WHILE .NOT. EOF()  
   			          
   			         DBSELECTAREA("RCH")			         
   			         IF LEFT(RCH->RCH_FILIAL,4) = LEFT(SRC->RC_FILIAL,4) .AND. RCH->RCH_PROCES = SRC->RC_PROCES .AND. RCH->RCH_ROTEIR = SRC->RC_ROTEIR
   			            IF RCH->RCH_PER = SRC->RC_PERIODO 
   			            
   			               IF EMPTY(RCH->RCH_DTFECH)
   			                  RecLock("RCH",.F.) 
                              RCH->RCH_DTFECH:=SRC->RC_DATA
                              RCH->RCH_PERSEL:="2"
                              RCH->RCH_STATUS:="5"
                              
                              DBSELECTAREA("RCH")
                              MsUnlock() 
   			                  Dbunlock() 
   			                  EXIT
   			               ENDIF
   			            
   			            ENDIF
   			         ENDIF
   			         
   			         DBSELECTAREA("RCH")
   			         DBSKIP()
   			      ENDDO   
   			      Restarea(aAreaRCH)
   			        
   			      // *** Monta Chave de Pesquisa que será utilizada na Tabela RGB *** //
   			      DBSELECTAREA("SRC")
   			      cPesqRGB:=SRC->RC_FILIAL+SRC->RC_PD+SRA->RA_PROCES+SRC->RC_PERIODO+SRC->RC_ROTEIR+SRC->RC_MAT
   			      
   			      // *** Exclui informação da Tabela de Lançamento da Folha *** //
   			      aAreaRGB:=GETAREA() 
   			      DBSELECTAREA("RGB")
   			      DBSETORDER(8)
   			      DBSEEK(cPesqRGB)
   			      if .not. eof()
   			         RecLock("RGB",.F.)
                     DELE
                     MsUnlock() 
   			         Dbunlock()
   			      endif  
   			      Restarea(aAreaRGB)  
   			      
   			      // *** Exclui informação da Tabela de Lançamento da Folha *** //
   			      DBSELECTAREA("RFQ")
   			      DBSETORDER(1)
   			      cPesqRFQ:=XFILIAL("RFQ")+SRC->RC_PROCES+SRC->RC_PERIODO
   			      aAreaRFQ:=GETAREA() 
   			       
   			      // *** Localiza Registro *** //
   			      DBSEEK(cPesqRFQ)
   			      if .not. eof()
   			         RecLock("RFQ",.F.)
                     RFQ->RFQ_STATUS:="2"
                     MsUnlock() 
   			         Dbunlock()
   			      endif  
   			      Restarea(aAreaRFQ) 
   			      
   			         			      
   			      // *** Exclui informação do Movimento da Folha *** //
   			      DBSELECTAREA("SRC")
   			      aAreaSRC:=GETAREA()
   			      RecLock("SRC",.F.)
                  DELE
                  MsUnlock() 
   			      Dbunlock() 
   			      Restarea(aAreaRCH)
   			      
   			   endif
            endif 
         endif
         
         dbselectarea("SRC")
         DBSKIP()
         IF .NOT. EOF() 
            IF SRC->RC_FILIAL+SRC->RC_MAT = SRA->RA_FILIAL+SRA->RA_MAT
               LOOP
            ENDIF
         ENDIF
         EXIT   
      ENDDO
   ENDIF   
   Restarea(aAreaSRC0)
      
   // ***
   DBSELECTAREA("SRA")
   DBSKIP()
ENDDO
Restarea(AxArea1)    
Return     


/*
|===========================================================================|
| Programa  | GRVFICHASRD |Autor| Valdemir Miranda      | Data : 02/05/2016 |
|===========================================================================|
| Descrição : Função de Gravação do Acumulados Anuais (Ficha Financeira)    |
|             (Ficha Financeira)                                            |
|===========================================================================|
*/

* ...
Static Function GRVFICHASRD() 
         
Local cInss:=""
Local cIrrf:=""
Local cFGTS:=""   
Local cxfilial01:=SRA->RA_FILIAL  
Local cMatx     :=SRA->RA_MAT
Local cVerbaPT1 :=SRC->RC_PD  
Local nValorEv1 :=SRC->RC_VALOR 
Local cTipoVerba:="V"
        
// ***  
aAliasx1:=GETAREA()
if SRC->RC_VALOR > 0
   
   // *** Seleciona Tabela SRV-Cadastro de Verbas *** // 
   aAreax2:=Getarea()
   cTipoVerba:="V"
   DBSELECTAREA("SRV")
   DBSETORDER(1)
   DBSEEK(XFILIAL("SRV")+cVerbaPT1)
   if .not. eof()
      cTipoVerba:=SRV->RV_TIPO
      cInss:=SRV->RV_INSS
      cIrrf:=SRV->RV_IR
      cFGTS:=SRV->RV_FGTS
   endif
   Restarea(aAreax2)     
      
   //*** Monta Chave de Pesquisa *** //         Período        Datarq      Verba
   cPesqSRD:=SRA->RA_FILIAL+SRA->RA_MAT+SRC->RC_PERIODO+SRC->RC_PERIODO+SRC->RC_PD
                        
   // *** Grava Dados na Tabela SRD (Ficha Financeira) *** //
   aAreax2:=Getarea()
   DBSELECTAREA("SRD")
   DBSETORDER(3)
   DBSEEK(cPesqSRD)
   if .not. eof()
      RecLock("SRD",.F.) 
   else
      RecLock("SRD",.T.)
   endif 
   
   dDataPgto1:=SRC->RC_DATA
      
   SRD->RD_FILIAL		:=SRA->RA_FILIAL 
   SRD->RD_MAT			:=SRA->RA_MAT
   SRD->RD_PD			:=SRC->RC_PD
   SRD->RD_TIPO1		:=SRC->RC_TIPO1
   SRD->RD_TIPO2		:=SRC->RC_TIPO1
   SRD->RD_HORINFO		:=SRC->RC_HORAS
   SRD->RD_HORAS	   	:=SRC->RC_HORAS
   SRD->RD_VALINFO		:=SRC->RC_VALOR 
   SRD->RD_VALOR		:=SRC->RC_VALOR 
   SRD->RD_DATARQ		:=SRC->RC_PERIODO
   SRD->RD_DATPGT		:=SRC->RC_DATA
   SRD->RD_MES			:=ALLTRIM(STR(MONTH(SRC->RC_DTREF)))   
   SRD->RD_STATUS		:="A"
   SRD->RD_DTREF        :=SRC->RC_DTREF
   SRD->RD_PROCES		:=SRC->RC_PROCES  
   SRD->RD_SEMANA		:=SRC->RC_SEMANA
   SRD->RD_EMPRESA		:="01"
   SRD->RD_CC			:=SRA->RA_CC
   SRD->RD_INSS			:=cInss 
   SRD->RD_IR			:=cIrrf
   SRD->RD_FGTS			:=cFGTS 
   SRD->RD_DEPTO 		:=SRA->RA_DEPTO   
   SRD->RD_PERIODO   	:=SRC->RC_PERIODO
   SRD->RD_ROTEIR		:=SRC->RC_ROTEIR 
   SRD->RD_CODB1T       :=SRC->RC_CODB1T
   SRD->RD_VALORBA      :=SRC->RC_VALORBA
            
   MsUnlock() 
   Dbunlock()  
   Restarea(aAreax2)    
   
endif

Restarea(aAliasx1)
Return


/*
|===========================================================================|
| Programa  | PGPARFECTO| Autor| Valdemir Miranda       | Data : 02/05/2016 |
|===========================================================================|
| Descrição : Acessa o Modulo de Montagem do Menu Principal                 |
|                                                                           |
|===========================================================================|
*/
Static Function PGPARFECTO()    

Local _sAlias := Alias()
Local cPerg := PADR("FPGPEP06",10)
Local aRegs :={}                       
Local nX  

lPerg  :=lTemreg :=.t.    
aAdd(aRegs,{"Filial       De ?","¨Forneced. De?","From Bank ?","mv_ch1","C",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SM0",""})  
aAdd(aRegs,{"Filial       Ate?","¨Forneced.Ate?","From Bank ?","mv_ch2","C",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SM0",""})   
aAdd(aRegs,{"Roteiro         ?","¨Roteiro     ?","Roteiro   ?","mv_ch3","N",1,0,0,"C","","mv_par03","ADI","ADI","ADI","","","AUT","AUT","AUT","","","RES","RES","RES","","","FER","FER","FER","","","FOL","FOL","FOL",,"","","Todos","Todos","Todos","",""})
aAdd(aRegs,{"Periodo de      ?","¨Periodo de  ?","Periodo de?","mv_ch4","C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})  
aAdd(aRegs,{"Periodo Até     ?","¨Periodo Até ?","Periodo At?","mv_ch5","C",6,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})  

_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
dbSelectArea(_cAliasSX1)
(_cAliasSX1)->(dbSetOrder(1))

For nX:=1 to Len(aRegs)
	If !(_cAliasSX1)->(dbSeek(cPerg+StrZero(nx,2)))
		RecLock("SX1",.T.)
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