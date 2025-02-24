// *** Calculo de INSS, quando Férias dentro do Mês da Folha *** //
/*
|===========================================================================|
| Programa  | RGPEP005()| Autor| Valdemir Miranda       | Data : 27/08/2018 |
|===========================================================================|
| Descrição : Calculo de INSS, quando Férias dentro do Mês da Folha         |
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
user Function RGPEP005()   

Private nVB402   :=((-1) * FBUSCAPD("402"))
Private nVB406   :=((-1) * FBUSCAPD("406"))
Private nPerc    :=((-1) * FBUSCAPD("401","H"))
Private nBaseInss:=FBUSCAPD("701") 
Private nBInss   :=0.00    
Private nPercINSS:=0.00    

// ***
cArea51:=GETAREA()
cPesqRGB:=SRA->RA_FILIAL+SRA->RA_MAT+"401"+mv_par03 
Dbselectarea("RGB")
DBSETORDER(1)
DBSEEK(cPesqRGB)
if .not. eof()
   if RGB->RGB_TIPO2 = "I" 
      nPerc   :=RGB->RGB_HORAS    
      nValINSS:=RGB->RGB_VALOR
      if Flocaliapd("401")>0
         APD[FlocaliAPD("401"),9]:="D"
      endif
      Fgeraverba("401",ROUND(nValINSS,2),nPerc,,,"V",,0,,dData_Pgto,.t.)
      Restarea(cArea51)
      Return
   endif
endif
Restarea(cArea51)
              
// *** Cálculo de INSS da Folha, quando funcionário em situação de Férias *** //
if ALLTRIM(SRA->RA_SITFOLH) = "F"  

   // ***   
   cArea52:=GETAREA()
   DbSelectarea("SRV")
   DBSETORDER(1)
   DBGOTOP()
   do while .not. eof() 
      cVerbax:=SRV->RV_COD
      if SRV->RV_TIPOCOD = "1" 
         if SRV->RV_REFFER = "S"
            if SRV->RV_CODFOL $"0072/0077/0075/0082/0084/0074/0079/0622/0623/1304/1306/1320/1322/1300/1302/1316/1318/1308/1324/1310/1326/1296/1298/1312/1314/0094/0095/1450"
               if SRV->RV_INSS = "S"
                  nBInss:=nBInss+FBUSCAPD(cVerbax) 
               endif
            endif
         else   
            if .not. cVerbax$"065/436"   
               if SRV->RV_INSS = "S"
                  nBInss:=nBInss+FBUSCAPD(cVerbax)
               endif 
            endif
         endif
      endif
      dbSkip()
   enddo  
   Restarea(cArea52)
        
   // ***
   if (nVB402+nVB406) > 0.00  
               
      // ***
      if nBInss > 0.00
         nBaseInss:=nBInss
      endif
      
      // ***
      cArea52:=GETAREA()
      nValBINSS:=nBaseInss
	  DBSELECTAREA("RCC") 
	  DBSETORDER(1)
	  Set Filter to SUBSTR(RCC_CONTEU,1,4) = SUBSTR(mv_par03,1,4) .AND. RCC_CODIGO = "S001"
	  dbGoTop()
  
	  // *** Pega Base INSS e Valor do INSS do Mês Anterior *** //
	  nVTeto:=nBaseInss 
	  nPercINSS :=0.00
	  Do While .not. eof() 
         
         if alltrim(RCC->RCC_SEQUENC) = "041" .or. alltrim(RCC->RCC_SEQUENC) = "001"  
      		nValorDe1 :=val(substr(RCC->RCC_CONTEU,14,11))
      		if nValBINSS <= nValorDe1
         		nPercINSS :=val(substr(RCC->RCC_CONTEU,25,6))    
            endif
         endif 
   
         if alltrim(RCC->RCC_SEQUENC) = "042" .and. nPercINSS = 0.00 
   
            nValorDe2 :=val(substr(RCC->RCC_CONTEU,14,11))
            if nValBINSS > nValorDe1 .and. nValBINSS <= nValorDe2
               nPercINSS :=val(substr(RCC->RCC_CONTEU,25,6))
            endif 
         endif 
   
   	     if alltrim(RCC->RCC_SEQUENC) = "043" .and. nPercINSS = 0.00
      		nValorDe3 :=val(substr(RCC->RCC_CONTEU,14,11))
      		nVTeto    :=val(substr(RCC->RCC_CONTEU,14,11))
      		if nValBINSS >= nValorDe2 .and. nValBINSS <= nValorDe3 
         		nPercINSS :=val(substr(RCC->RCC_CONTEU,25,6)) 
      		else
         		nPercINSS :=val(substr(RCC->RCC_CONTEU,25,6)) 
      		endif   
      	 endif
       
   		 if alltrim(RCC->RCC_SEQUENC) = "044" .and. nPercINSS = 0.00
      		nValorDe4 :=val(substr(RCC->RCC_CONTEU,14,11))
      		nVTeto    :=val(substr(RCC->RCC_CONTEU,14,11))
      
      		if nValBINSS > nValorDe3 .and. nValBINSS <= nValorDe4
         		nPercINSS :=val(substr(RCC->RCC_CONTEU,25,6))
      		else
         		nPercINSS :=val(substr(RCC->RCC_CONTEU,25,6))
      		endif  
   		 endif
   
         // ***  
   	     dbSelectArea("RCC")
   	     dbskip()
	  enddo 
   	  Restarea(cArea52)
      
      // ***
      if nPercINSS > 0.00
         nPerc:=nPercINSS
      endif
     
      // ***    
      if nBaseInss > nVTeto
         nBaseInss:=nVTeto
      endif  
      
      // ***
      nValInss:=((nBaseInss*nPerc)/100)
      nValInss:=(nValInss - (nVB402))  
      
      // ***    
      if nValInss > 0.00
         if Flocaliapd("401")>0
            APD[FlocaliAPD("401"),9]:="D"
         endif
         Fgeraverba("401",ROUND(nValInss,2),nPerc,,,"V",,0,,dData_Pgto,.t.)
         
         if Flocaliapd("701")>0
            APD[FlocaliAPD("701"),9]:="D"
         endif
         Fgeraverba("701",ROUND(nBaseInss,2),0,,,"V",,0,,dData_Pgto,.t.)
      endif
   endif
endif   
Return
                                
