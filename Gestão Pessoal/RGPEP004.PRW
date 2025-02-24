/*
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||          |          |       |                       |      |          |||
|||Programa  |RGPEP002  | Autor | Valdemir Miranda      | Data |07/08/2018|||
|||          |          |       |                       |      |          |||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||Descrição | Função Utilizada para Capturar as Férias do Mês e do Mês   |||  
|||          | Seguinte, e levá-las para a Folha de Pagamento             ||| 
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
*/
User Function RGPEP004()

// *** Inicializa Variaveis de memória contendo os Identificadores de Cálculos de Férias *** //
//RCF_PER = mv_par03   
Private cAliasA    :=""
Private cIdCalc    :=""
Private cTipoCod   :=""
Private cTipo      :=""   
Private nTotFer    :=0.00
Private nTotDescFer:=0.00 
Private nTotLiqFer :=0.00                                                                                                                           
Private nValorRGB  :=0.00 
Private cTipo2x    :=""
Private cVarFerMes :="0072/0077/0065/0075/0082/0084/0623/1304/1306/1320/1322/1300/1302/1316/1318/1308/1324/1310/1326/1296/1298/1312/1314/0094/0095/1450"
Private cVarFerMSeg:="0073/0078/0232/0076/0083/0085/0205/0206/0633/0634/1305/1307/1321/1323/1301/1303/1317/1319/1309/1325/1311/1327/1297/1299/1313/1315/0207/0208/1451"
Private cTemFerias :="N" 
Private cAliasx51  :=GETAREA()
//Private cVarFerMes :="0072/0077/0065/0075/0082/0084/0074/0079/0622/0623/1304/1306/1320/1322/1300/1302/1316/1318/1308/1324/1310/1326/1296/1298/1312/1314/0094/0095/1450"
  
// *** Se o Funcionário não estiver de Ferias, despresa o Cálculo *** //
if ALLTRIM(SRA->RA_SITFOLH) <> "F"   

   // *** Verifica se teve Ferias do mês Seguinte *** //
   cTemFerias:="N" 
   VerFerMSeg()
   
   // ***
   Restarea(cAliasx51)
   if cTemFerias="N"
      Return 
   endif
endif 

/*
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||Acessa Função que Pega as Férias do Mês Corrente                       |||  
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
*/  
cAliasA :=""
cQry	:="Select * "
cQry 	+= " FROM  "+RetSqlName("SRH")+" SRH " 
cQry 	 += " WHERE SRH.D_E_L_E_T_='' "    
 
cQry += " AND SRH.RH_FILIAL = '" + SRA->RA_FILIAL + "' " 
cQry += " AND SRH.RH_MAT = '" + SRA->RA_MAT + "' "
cQry += " AND SRH.RH_PERIODO = '" + mv_par03 + "' "

cAliasA	:= GetNextAlias() 
If Select( cAliasA ) > 0
   dbSelectArea( cAliasA )
   dbCloseArea()
EndIf   
 
// *** Abre Tabelas *** //
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQry), cAliasA , .F., .T.)  

// *** Inicio do Processamento de Captura das Verbas de Férias *** //
dbSelectArea(cAliasA) 
ProcRegua((cAliasA)->(LastRec()))
dbGoTop()   

// ***
Do While .not. eof() 
   
   
   cQry	:="Select * "
   cQry += " FROM  "+RetSqlName("SRR")+" SRR " 
   cQry += " WHERE SRR.D_E_L_E_T_='' "    
 
   cQry += " AND SRR.RR_FILIAL = '" + (cAliasA)->RH_FILIAL + "' " 
   cQry += " AND SRR.RR_MAT = '" + (cAliasA)->RH_MAT + "' "
   cQry += " AND SRR.RR_PERIODO = '" + mv_par03 + "' " 
   cQry += " AND SRR.RR_TIPO3 = 'F' "  

   cAliasB	:= GetNextAlias() 
   If Select( cAliasB ) > 0
      dbSelectArea( cAliasB )
      dbCloseArea()
   EndIf   
 
   // *** Abre Tabelas *** //
   dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQry), cAliasB , .F., .T.) 

   // *** Inicio do Processamento de Captura das Férias *** //
   dbSelectArea(cAliasB) 
   ProcRegua((cAliasB)->(LastRec()))
   dbGoTop()
      
   // ***
   Do While .not. eof() 
   
      // *** Pega ID de Calculo *** //
      cIdCalc  :=""
   	  cTipoCod :="" 
   	  cTipo    :=""
      PegaIdCalc((cAliasB)->RR_PD) 
              
      // *** Pega Férias do Mês / Mês Seguinte*** //
      GrvFer:= "N"
      if LEFT((cAliasA)->RH_DATAINI,6) = LEFT(mv_par03,6) .and. cIdCalc $cVarFerMes
         GrvFer:= "S"  
      elseif LEFT((cAliasA)->RH_DATAFIM,6) = LEFT(mv_par03,6) .and. cIdCalc $cVarFerMSeg
         GrvFer:= "S"
      endif 
         
      // *** Grava Verba de Férias na Folha de Pagamento *** //
      nValorRGB :=0.00 
      nValHorasx:=0.00
      cTipo2x:=RGPVERB1((cAliasB)->RR_PD)
      if GrvFer = "S" .and. cTipo2x <> "I"   
      
         if (cAliasB)->RR_VALOR > 0.00 
            if Flocaliapd((cAliasB)->RR_PD)>0
               APD[FlocaliAPD((cAliasB)->RR_PD),9]:="D"
            endif
            Fgeraverba((cAliasB)->RR_PD,(cAliasB)->RR_VALOR,(cAliasB)->RR_HORAS,,,"V",,0,,dData_Pgto,.t.) 
           
            if cTipoCod = "1" 
               nTotFer    :=nTotFer+(cAliasB)->RR_VALOR 
            elseif cTipoCod = "2" .AND. (cAliasB)->RR_PD <> "440"
		       nTotDescFer:=nTotDescFer+(cAliasB)->RR_VALOR  
		    endif
         endif 
      else
         if cTipoCod = "1" .and. GrvFer = "S"
            if cTipo2x <> "I" 
               nTotFer    :=nTotFer+(cAliasB)->RR_VALOR 
            else 
               if Flocaliapd((cAliasB)->RR_PD)>0
                  APD[FlocaliAPD((cAliasB)->RR_PD),9]:="D"
               endif
               Fgeraverba((cAliasB)->RR_PD,nValorRGB,nValHorasx,,,"V",,0,,dData_Pgto,.t.) 
            
               nTotFer    :=nTotFer+nValorRGB 
            endif   
            
         elseif cTipoCod = "2" .AND. (cAliasB)->RR_PD <> "440" .and. GrvFer = "S"
         
            if cTipo2x <> "I"
		       nTotDescFer:=nTotDescFer+(cAliasB)->RR_VALOR
		    else
		       nTotDescFer:=nTotDescFer+nValorRGB
		    endif
		 endif
      endif 
       
      // *** Calcula Líquido de Férias *** //
      if GrvFer = "S" .and. cIdCalc $cVarFerMes
         if cTipoCod = "1" .and. cTipo2x <> "I"      
                              
            nTotLiqFer:=nTotLiqFer+(cAliasB)->RR_VALOR 
            
         elseif cTipoCod = "1" .and. cTipo2x = "I" 
         
            nTotLiqFer:=nTotLiqFer+nValorRGB
         endif
      endif 
          
      // ***
      dbSelectArea(cAliasB) 
      dbskip()
   Enddo
    
   // *** Fecha Tabela do SQL-QUERY *** //
   dbSelectArea(cAliasB)
   use
   
   // ***
   dbSelectArea(cAliasA)
   DBSKIP()
Enddo

// *** Fecha Tabela do SQL-QUERY *** //
dbSelectArea(cAliasA)
use  
Restarea(cAliasx51)

// *** Grava Liquido de Férias *** //
xDigitado:=RGPVERB1("440")
if nTotFer > 0.00    

   // ***
   if Flocaliapd("440")>0
      APD[FlocaliAPD("440"),9]:="D"
   endif
   
   // ***          
   if nValorRGB > 0 .and. cTipo2x = "I" 
      Fgeraverba("440",nValorRGB,0,,,"V",,0,,dData_Pgto,.t.)      
   else     
      Fgeraverba("440",nTotLiqFer,0,,,"V",,0,,dData_Pgto,.t.) 
   endif 
endif   

/*
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||Pega Férias do Mês Seguinte                                            |||  
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||   
*/               
PGFerMesSeg() 
Restarea(cAliasx51)
RETURN  

/*
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||          |          |       |                       |      |          |||
|||Programa  |RGPEVERB  | Autor | Valdemir Miranda      | Data |07/09/2018|||
|||          |          |       |                       |      |          |||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||Descrição | Pega Identificador de Cálculo                              |||  
|||          |                                                            ||| 
|||          |                                                            |||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||   
*/
Static Function PegaIdCalc(cVerb1)   

Local cAliasC:=""
Local cVerba :=cVerb1

cQry	:="Select * "
cQry 	+= " FROM  "+RetSqlName("SRV")+" SRV " 
cQry 	 += " WHERE SRV.D_E_L_E_T_='' "    
cQry += " AND SRV.RV_COD = '" + cVerba+ "' "  

cAliasC	:= GetNextAlias() 
If Select( cAliasC ) > 0
   dbSelectArea( cAliasC )
   dbCloseArea()
EndIf   
 
// *** Abre Tabelas *** //
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQry), cAliasC , .F., .T.)  

// *** Inicio do Processamento de Funcionários em Atrazo *** //
dbSelectArea(cAliasC) 
ProcRegua((cAliasC)->(LastRec()))
dbGoTop()   

// ***
cIdCalc  :=" " 
cTipoCod :=""
Do While .not. eof() 
   cIdCalc  :=(cAliasC)->RV_CODFOL
   cTipoCod :=(cAliasC)->RV_TIPOCOD 
   cTipo    :=(cAliasC)->RV_TIPO  
   DBSKIP()
Enddo 

// *** Fecha Query *** //
dbSelectArea(cAliasC)
use   
Restarea(cAliasx51)
Return(.T.)  

/*
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||          |          |       |                       |      |          |||
|||Programa  |RGPEVERB  | Autor | Valdemir Miranda      | Data |07/08/2018|||
|||          |          |       |                       |      |          |||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||Descrição | Pega Tipo de Verba, se Informada ou não                    |||  
|||          |                                                            ||| 
|||          |                                                            |||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||   
*/
Static Function RGPVERB1(cVerb1)   

Local cAliasD:=""
Local cTipo2 :=""
Local cVerba :=cVerb1

cQry	:="Select * "
cQry 	+= " FROM  "+RetSqlName("RGB")+" RGB " 
cQry 	 += " WHERE RGB.D_E_L_E_T_='' "    
 
cQry += " AND RGB.RGB_FILIAL = '" + SRA->RA_FILIAL + "' " 
cQry += " AND RGB.RGB_MAT = '" + SRA->RA_MAT + "' "
cQry += " AND RGB.RGB_PERIOD = '" + mv_par03 + "' "
cQry += " AND RGB.RGB_PD = '" + cVerba+ "' "  

cAliasD	:= GetNextAlias() 
If Select( cAliasD ) > 0
   dbSelectArea( cAliasD )
   dbCloseArea()
EndIf   
 
// *** Abre Tabelas *** //
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQry), cAliasD , .F., .T.)  

// *** Inicio do Processamento de Funcionários em Atrazo *** //
dbSelectArea(cAliasD) 
ProcRegua((cAliasD)->(LastRec()))
dbGoTop()   

// ***
cTipo2:=" "
Do While .not. eof() 
   cTipo2 :=(cAliasD)->RGB_TIPO2  
   cTipo2x:= (cAliasD)->RGB_TIPO2  
   nValHorasx:=(cAliasD)->RGB_HORAS
   nValorRGB:=(cAliasD)->RGB_VALOR
   DBSKIP()
Enddo 

// *** Fecha Query *** //
dbSelectArea(cAliasD)
use                
Restarea(cAliasx51)
Return(cTipo2)


/*
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||Acessa Função que Pega as Férias do Mês Seginte                        |||  
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
*/   
Static Function PGFerMesSeg() 

// ***
Private cAno    :=SUBSTR(mv_par03,1,4)
Private cMes    :=SUBSTR(mv_par03,5,2)
Private nMesx   := ""
Private cAnoMes1:=""
Private nHsInss   :=0.00 
Private nVINSSMANT:=0.00  

// ***
nMesx:= (val(cMes)-1)


//*** Monta Periodo do mês Seguinte *** //
if nMesx > 0
   cAnoMes1:=SUBSTR(cAno,1,4)+strzero(nMesx,2)
else
   cAnoMes1:= strzero((val(cAno)-1),4)+"12"
endif

cQry	:="Select * "
cQry 	+= " FROM  "+RetSqlName("SRH")+" SRH " 
cQry 	 += " WHERE SRH.D_E_L_E_T_='' "    
 
cQry += " AND SRH.RH_FILIAL = '" + SRA->RA_FILIAL + "' " 
cQry += " AND SRH.RH_MAT = '" + SRA->RA_MAT + "' "
cQry += " AND SRH.RH_PERIODO = '" + cAnoMes1 + "' "

cAliasA	:= GetNextAlias() 
If Select( cAliasA ) > 0
   dbSelectArea( cAliasA )
   dbCloseArea()
EndIf   
 
// *** Abre Tabelas *** //
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQry), cAliasA , .F., .T.)  

// *** Inicio do Processamento de Captura das Verbas de Férias *** //
dbSelectArea(cAliasA) 
ProcRegua((cAliasA)->(LastRec()))
dbGoTop()   

// ***
Do While .not. eof() 

   cQry	:="Select * "
   cQry += " FROM  "+RetSqlName("SRR")+" SRR " 
   cQry += " WHERE SRR.D_E_L_E_T_='' "    
 
   cQry += " AND SRR.RR_FILIAL = '" + (cAliasA)->RH_FILIAL + "' " 
   cQry += " AND SRR.RR_MAT = '" + (cAliasA)->RH_MAT + "' "
   cQry += " AND SRR.RR_PERIODO = '" + cAnoMes1 + "' " 
   cQry += " AND SRR.RR_TIPO3 = 'F' "  

   cAliasB	:= GetNextAlias() 
   If Select( cAliasB ) > 0
      dbSelectArea( cAliasB )
      dbCloseArea()
   EndIf   
 
   // *** Abre Tabelas *** //
   dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQry), cAliasB , .F., .T.) 

   // *** Inicio do Processamento de Captura das Férias *** //
   dbSelectArea(cAliasB) 
   ProcRegua((cAliasB)->(LastRec()))
   dbGoTop() 
      
   // ***
   Do While .not. eof() 
   
      // *** Pega ID de Calculo *** //
      cIdCalc  :=""
   	  cTipoCod :="" 
   	  cTipo    :=""
      PegaIdCalc((cAliasB)->RR_PD)  
      
      // *** Pega Valor do Inss *** //
      if (cAliasB)->RR_PD = "402"
        nHsInss   :=(cAliasB)->RR_HORAS 
        nVINSSMANT:=(cAliasB)->RR_VALOR
      endif
              
      // *** Pega Férias do Mês / Mês Seguinte*** //
      GrvFer:= "N" 
      if LEFT((cAliasB)->RR_PERIODO,6) = LEFT(cAnoMes1,6) .and. cIdCalc $cVarFerMSeg
         GrvFer:= "S"
      endif 
         
      // *** Grava Verba de Férias na Folha de Pagamento *** //
      nValorRGB :=0.00 
      nValHorasx:=0.00
      cTipo2x:=RGPVERB1((cAliasB)->RR_PD) 
      
      if GrvFer = "S" .and. cTipo2x <> "I"   
      
         if (cAliasB)->RR_VALOR > 0.00 
            if Flocaliapd((cAliasB)->RR_PD)>0
               APD[FlocaliAPD((cAliasB)->RR_PD),9]:="D"
            endif
            Fgeraverba((cAliasB)->RR_PD,(cAliasB)->RR_VALOR,(cAliasB)->RR_HORAS,,,"V",,0,,dData_Pgto,.t.) 
           
            if cTipoCod = "1" 
               nTotFer    :=nTotFer+(cAliasB)->RR_VALOR 
            elseif cTipoCod = "2" .AND. (cAliasB)->RR_PD <> "440"
		       nTotDescFer:=nTotDescFer+(cAliasB)->RR_VALOR  
		    endif
         endif 
      else
         if cTipoCod = "1" .and. GrvFer = "S"
            if cTipo2x <> "I" 
               nTotFer    :=nTotFer+(cAliasB)->RR_VALOR 
            else 
               if Flocaliapd((cAliasB)->RR_PD)>0
                  APD[FlocaliAPD((cAliasB)->RR_PD),9]:="D"
               endif
               Fgeraverba((cAliasB)->RR_PD,nValorRGB,nValHorasx,,,"V",,0,,dData_Pgto,.t.) 
            
               nTotFer    :=nTotFer+nValorRGB 
            endif   
            
         elseif cTipoCod = "2" .AND. (cAliasB)->RR_PD <> "440" .and. GrvFer = "S"
         
            if cTipo2x <> "I"
		       nTotDescFer:=nTotDescFer+(cAliasB)->RR_VALOR
		    else
		       nTotDescFer:=nTotDescFer+nValorRGB
		    endif
		 endif
      endif 
       
      // *** Calcula Líquido de Férias *** //
      if GrvFer = "S" .and. cIdCalc $cVarFerMSeg
         if cTipoCod = "1" .and. cTipo2x <> "I"      
                              
            nTotLiqFer:=nTotLiqFer+(cAliasB)->RR_VALOR 
            
         elseif cTipoCod = "1" .and. cTipo2x = "I" 
         
            nTotLiqFer:=nTotLiqFer+nValorRGB
         endif
      endif 
          
      // ***
      dbSelectArea(cAliasB) 
      dbskip()
   Enddo
    
   // *** Fecha Tabela do SQL-QUERY *** //
   dbSelectArea(cAliasB)
   use
   
   // ***
   dbSelectArea(cAliasA)
   DBSKIP()
Enddo

// *** Fecha Tabela do SQL-QUERY *** //
dbSelectArea(cAliasA)
use                
Restarea(cAliasx51)

// *** Grava Liquido de Férias *** //
xDigitado:=RGPVERB1("440")
if nTotFer > 0.00  

   // ***
   if Flocaliapd("401")> 0 .and. nVINSSMANT > 0.00 .and. fbuscapd("117") = 0
      APD[FlocaliAPD("401"),9]:="D"
      Fgeraverba("401",nVINSSMANT,nHsInss,,,"V",,0,,dData_Pgto,.t.)
   endif 
   
   // ***
   if Flocaliapd("440")>0
      APD[FlocaliAPD("440"),9]:="D"
   endif 
   
   // ***          
   if nValorRGB > 0 .and. cTipo2x = "I" 
      nValorRGB:=(nValorRGB-((-1)*FBUSCAPD("406")))  
      Fgeraverba("440",nValorRGB,0,,,"V",,0,,dData_Pgto,.t.)      
   else  
   
      nTotLiqFer:=((nTotLiqFer-((-1)*FBUSCAPD("402")))) 
      Fgeraverba("440",nTotLiqFer,0,,,"V",,0,,dData_Pgto,.t.) 
   endif 
   
endif              
Restarea(cAliasx51)                             
Return


/*
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||          |          |       |                       |      |          |||
|||Programa  |VerFeeMSeg| Autor | Valdemir Miranda      | Data |27/08/2018|||
|||          |          |       |                       |      |          |||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||Descrição | Pega Tipo de Verba, se Informada ou não                    |||  
|||          |                                                            ||| 
|||          |                                                            |||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||   
*/
Static Function VerFerMSeg()  

cQry	:="Select * "
cQry 	+= " FROM  "+RetSqlName("SRH")+" SRH " 
cQry 	 += " WHERE SRH.D_E_L_E_T_='' "    
 
cQry += " AND SRH.RH_FILIAL = '" + SRA->RA_FILIAL + "' " 
cQry += " AND SRH.RH_MAT = '" + SRA->RA_MAT + "' "
cQry += " AND SUBSTRING(SRH.RH_DATAFIM,1,6) = '" + mv_par03 + "' "

cAliasA	:= GetNextAlias() 
If Select( cAliasA ) > 0
   dbSelectArea( cAliasA )
   dbCloseArea()
EndIf   
 
// *** Abre Tabelas *** //
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQry), cAliasA , .F., .T.)  

// *** Inicio do Processamento de Captura das Verbas de Férias *** //
dbSelectArea(cAliasA) 
ProcRegua((cAliasA)->(LastRec()))
dbGoTop() 
    
// ***
cTemFerias:="N" 
Do While .not. eof()
   if LEFT((cAliasA)->RH_DATAFIM,6) = LEFT(mv_par03,6)
      cTemFerias:="S" 
   endif  
Enddo
      
// *** Fecha Tabela do SQL-QUERY *** //
dbSelectArea(cAliasA)
use      
Restarea(cAliasx51)
Return

