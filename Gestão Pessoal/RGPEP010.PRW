// *** Calculo de INSS, quando Férias dentro do Mês da Folha *** //
/*
|===========================================================================|
| Programa  | RGPEP010  | Autor| Valdemir Miranda       | Data : 05/09/2018 |
|===========================================================================|
| Descrição : Calculo de IRRF de Férias                                     |
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
user Function RGPEP010()

Private nValBIRRF  :=0.00 
Private nValINSS   :=0.00  
Private nPerccent  :=0.00 
Private cAliasx51  :=GETAREA()    
Private nQtdDepteIr:=val(SRA->RA_DEPIR)       
Private cPerAtual  :=mv_par03
Private nBaseir    :=0.00  
Private nValir     := 0.00
                               
// *** Monta Query da Tabela de Verbas *** // 
cAliasB:=""
cQry := "SELECT SRV.RV_COD,SRV.RV_DESC,SRV.RV_TIPOCOD,SRV.RV_IR,SRV.RV_CODFOL,SRV.RV_REFFER,SRV.RV_ADIANTA,SRV.RV_REF13  "
cQry += " FROM "+RetSqlName("SRV")+" SRV"

cQry += "  WHERE SRV.D_E_L_E_T_='' "
cQry += "  AND SRV.RV_IR = 'S' "
cQry += "  AND SRV.RV_CODFOL <> '0043' "
cQry += "  AND SRV.RV_ADIANTA = 'N' "  
cQry += "  AND SRV.RV_REF13 = 'N' "
 
cAliasB:=GetNextAlias() 
If Select( cAliasB ) > 0
   dbSelectArea( cAliasB )
   dbCloseArea()
EndIf

// *** Abre Tabelas *** // 
cQuery := ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN', TCGENQRY(,,cQuery), cAliasB , .F., .T.)  
    
// ***
dbSelectArea(cAliasB) 
ProcRegua((cAliasB)->(LastRec()))
dbGoTop()
  
// *** Pega Base IRRF e Valor do IRRF do Mês Anterior *** //   
Do While .not. eof() 
   
   // *** Quando o Funcionário em situação de Férias *** //
   nVal01x:=fbuscapd((cAliasB)->RV_COD) 
   if nVal01x > 0.00 
      if (cAliasB)->RV_TIPOCOD = '1' .and. (cAliasB)->RV_IR = "S" .and. (cAliasB)->RV_REFFER = "S" .AND. (cAliasB)->RV_CODFOL <> "0043"
          nValBIRRF:=nValBIRRF+nVal01x
      endif 
   endif
   
   dbskip()
enddo 
dbSelectArea(cAliasB)
USE  
Restarea(cAliasx51)
 
nValDepd:=(( (-1)*FBUSCAPD("746") ) * nQtdDepteIr)
nValBIRRF:=(nValBIRRF - ((-1)*FBUSCAPD("402"))) 
nValBIRRF:=(nValBIRRF - ((-1)*FBUSCAPD("406")))
nValVBIRRF:=nValBIRRF   
nBaseir   :=nValBIRRF  

// *** Calcula IRRF da Folha *** //
cAliasB:="" 
cAliasx51:=GETAREA() 
xAreax:=getarea()
cQry := " SELECT * "
cQry += " FROM "+RetSqlName("RCC")+" RCC"
cQry += " WHERE D_E_L_E_T_=''  "
cQry += " AND RCC_CODIGO = 'S002' "
cQry += " AND SUBSTRING(RCC_CONTEU,1,4) = '" + SUBSTR(mv_par03,1,4) + "' " 
cQry += " ORDER BY RCC_CODIGO,RCC_SEQUEN ASC "   

cAliasB:=GetNextAlias() 
If Select( cAliasB ) > 0
   dbSelectArea( cAliasB )
   dbCloseArea()
EndIf

// *** Abre Tabelas *** // 
cQuery := ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN', TCGENQRY(,,cQuery), cAliasB , .F., .T.)  
    
// ***
dbSelectArea(cAliasB) 
ProcRegua((cAliasB)->(LastRec()))
dbGoTop()   
  
// *** Pega Base IRRF e Valor do IRRF do Mês Anterior *** // 
nValir:=0.00  
Do While .not. eof() 
   
   nValorDe1 :=val(substr((cAliasB)->RCC_CONTEU,15,10))
   nValorAte1:=val(substr((cAliasB)->RCC_CONTEU,27,10)) 
   nPercen1  :=val(substr((cAliasB)->RCC_CONTEU,38,5))
   nParcDedu1:=val(substr((cAliasB)->RCC_CONTEU,45,8)) 
   
   nValorDe2 :=nValorAte1+0.01
   nValorAte2:=val(substr((cAliasB)->RCC_CONTEU,58,10)) 
   nPercen2  :=val(substr((cAliasB)->RCC_CONTEU,69,5))
   nParcDedu2:=val(substr((cAliasB)->RCC_CONTEU,76,8))
   
   nValorDe3 :=nValorAte2+0.01
   nValorAte3:=val(substr((cAliasB)->RCC_CONTEU,89,10)) 
   nPercen3  :=val(substr((cAliasB)->RCC_CONTEU,100,5))
   nParcDedu3:=val(substr((cAliasB)->RCC_CONTEU,107,8))
   
   nValorDe4 :=nValorAte3+0.01
   nValorAte4:=val(substr((cAliasB)->RCC_CONTEU,118,12)) 
   nPercen4  :=val(substr((cAliasB)->RCC_CONTEU,131,5))
   nParcDedu4:=val(substr((cAliasB)->RCC_CONTEU,138,8))  
   nValpDepen:=val(substr((cAliasB)->RCC_CONTEU,153,8)) 
   nValpDepen:=val(substr((cAliasB)->RCC_CONTEU,153,8))
   nValMax   :=val(substr((cAliasB)->RCC_CONTEU,169,6)) 
      
   if nQtdDepteIr > 0
      nValpDepen:=nValpDepen * nQtdDepteIr
   else
      nValpDepen:=0.00
   endif
      
   nBaseir:=(((nValVBIRRF-nValpDepen)))  
   if  nBaseir >= nValorDe1 .and.  nBaseir <= nValorAte1
      nPercetu1:=nPercen1
      nValir:= ( ((nBaseir * nPercen1)/100) - nParcDedu1 )
   endif
   
   if  nBaseir >= nValorDe2 .and.  nBaseir <= nValorAte2 
      nPercetu1:=nPercen2
      nValir:= ( ((nBaseir * nPercen2)/100) - nParcDedu2 )
   endif
  
   if  nBaseir >= nValorDe3 .and.  nBaseir <= nValorAte3  
      nPercetu1:=nPercen3
      nValir:= ( ((nBaseir * nPercen3)/100) - nParcDedu3 )
   endif
   
   if  nBaseir >= nValorDe4 .and.  nBaseir <= nValorAte4  
      nPercetu1:=nPercen4
      nValir:= ( ((nBaseir * nPercen4)/100) - nParcDedu4 )
   endif
  
   if nValir < nValMax
      nValir:=0.00 
   endif
   
   dbskip() 
   exit
enddo 
dbSelectArea(cAliasB)
USE
Restarea(cAliasx51) 
   
if nValir >0.00     

   // ***
   if Flocaliapd("412")>0
      APD[FlocaliAPD("412"),9]:="D"
   endif
   
   // ***
   if Flocaliapd("715")>0
      APD[FlocaliAPD("715"),9]:="D"
   endif

   Fgeraverba("412",nValir ,nPercetu1,,,"V",,0,,dData_Pgto,.t.) 
   Fgeraverba("715",nBaseir,0,,,"V",,0,,dData_Pgto,.t.)
endif   
RESTAREA(cAliasx51) 
Return  
   
  


