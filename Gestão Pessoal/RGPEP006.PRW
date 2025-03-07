/*
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||          |          |       |                       |      |          |||
|||Programa  |RGPEP006  | Autor | Valdemir Miranda      | Data |07/08/2018|||
|||          |          |       |                       |      |          |||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||Descri��o | Fun��o Ajusta C�lculo de Liquido de F�rias na Folha de Pagto||  
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
*/
User Function RGPEP006()

// *** Inicializa Variaveis de mem�ria contendo os Identificadores de C�lculos de F�rias *** //
//RCF_PER = mv_par03   
Private cAliasX    :=""
Private cIdCalc    :=""
Private cTipoCod   :=""
Private cTipo      :=""   
Private nTotFer    :=0.00
Private nTotDescFer:=0.00                                                                                                                           
Private nValorRGB  :=0.00 
Private cTipo2x    :=""
Private cVarFerMes :="0072/0077/0065/0075/0082/0084/0623/1304/1306/1320/1322/1300/1302/1316/1318/1308/1324/1310/1326/1296/1298/1312/1314/0094/0095/1450"
Private cVarFerMSeg:="0073/0078/0232/0076/0083/0085/0205/0206/0633/0634/1305/1307/1321/1323/1301/1303/1317/1319/1309/1325/1311/1327/1297/1299/1313/1315/0207/0208/1451"
Private cTemFerias :="N"
Private cAliasx51  :=GETAREA()
Private nTotLiqFer:=((-1)* FBUSCAPD("440"))
  
// *** Se o Funcion�rio n�o estiver de Ferias, despresa o C�lculo *** //
if ALLTRIM(SRA->RA_SITFOLH) <> "F"    

   // *** Verifica se teve Ferias do m�s Seguinte *** //
   if nTotLiqFer > 0.00 
      cTemFerias:="N" 
      VerFerMS02()
   
     // ***         
     Restarea(cAliasx51)
     if cTemFerias="N"
        Return 
     endif
  endif 
endif

/*
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||Acessa Fun��o que Pega as F�rias do M�s Corrente                       |||  
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
*/  
cAliasX :=""
cQry	:="Select * "
cQry 	+= " FROM  "+RetSqlName("SRH")+" SRH " 
cQry 	 += " WHERE SRH.D_E_L_E_T_='' "    
 
cQry += " AND SRH.RH_FILIAL = '" + SRA->RA_FILIAL + "' " 
cQry += " AND SRH.RH_MAT = '" + SRA->RA_MAT + "' "
cQry += " AND SRH.RH_PERIODO = '" + mv_par03 + "' "

cAliasX	:= GetNextAlias() 
If Select( cAliasX ) > 0
   dbSelectArea( cAliasX )
   dbCloseArea()
EndIf   
 
// *** Abre Tabelas *** //
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQry), cAliasX , .F., .T.)  

// *** Inicio do Processamento de Captura das Verbas de F�rias *** //
dbSelectArea(cAliasX) 
ProcRegua((cAliasX)->(LastRec()))
dbGoTop()   

// *** 
GrvFer:= "N"  
cDatFerMes:=""
Do While .not. eof()   

   // *** Pega F�rias do M�s / M�s Seguinte*** //
   GrvFer:= "N"
   if LEFT((cAliasX)->RH_DATAINI,6) = LEFT(mv_par03,6) .and. cIdCalc $cVarFerMes
      GrvFer:= "S"  
   elseif LEFT((cAliasX)->RH_DATAFIM,6) = LEFT(mv_par03,6) .and. cIdCalc $cVarFerMSeg
      GrvFer:= "S"  
      cDatFerMes:=LEFT((cAliasX)->RH_DATAFIM,6)
   endif
   
   // ***
   dbSelectArea(cAliasX)
   DBSKIP()
Enddo

// *** Fecha Tabela do SQL-QUERY *** //
dbSelectArea(cAliasX)
use
Restarea(cAliasx51)

// *** Pega Liquido de F�rias *** // 
nTotLiqFer:=((-1)* FBUSCAPD("440")) 
nVlIRFer  := ((-1)* FBUSCAPD("412")) + ((-1)* FBUSCAPD("406"))

if nTotLiqFer > 0.00 .and. nVlIRFer > 0.00 //.and. GrvFer = "S"   

   // ***
   if Flocaliapd("440")>0
      APD[FlocaliAPD("440"),9]:="D"
   endif
   
   // *** 
   nTotLiqFer:=nTotLiqFer-nVlIRFer        
   if nTotLiqFer > 0.00
      Fgeraverba("440",nTotLiqFer,0,,,"V",,0,,dData_Pgto,.t.)   
      
      // *** Base de IR de F�rias *** //
      if Flocaliapd("715")>0
         APD[FlocaliAPD("715"),9]:="D" 
         Fgeraverba("715",nTotLiqFer,0,,,"V",,0,,dData_Pgto,.t.) 
      endif    
      
   endif 
endif    
Restarea(cAliasx51)
Return

/*
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||Programa  |VerFeeMS02| Autor | Valdemir Miranda      | Data |04/09/2018|||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||Descri��o | Pega Tipo de Verba, se Informada ou n�o                    |||  
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||   
*/
Static Function VerFerMS02()  
Private cAliasK1:=""

cQry	:="Select * "
cQry 	+= " FROM  "+RetSqlName("SRH")+" SRH " 
cQry 	 += " WHERE SRH.D_E_L_E_T_='' "    
 
cQry += " AND SRH.RH_FILIAL = '" + SRA->RA_FILIAL + "' " 
cQry += " AND SRH.RH_MAT = '" + SRA->RA_MAT + "' "
cQry += " AND SUBSTRING(SRH.RH_DATAFIM,1,6) = '" + mv_par03 + "' "

cAliasK1	:= GetNextAlias() 
If Select( cAliasK1 ) > 0
   dbSelectArea( cAliasK1 )
   dbCloseArea()
EndIf   
 
// *** Abre Tabelas *** //
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQry), cAliasK1 , .F., .T.)  

// *** Inicio do Processamento de Captura das Verbas de F�rias *** //
dbSelectArea(cAliasK1) 
ProcRegua((cAliasK1)->(LastRec()))
dbGoTop()  
    
// ***
cTemFerias:="N" 
Do While .not. eof()
   if LEFT((cAliasK1)->RH_DATAFIM,6) = LEFT(mv_par03,6)
      cTemFerias:="S" 
   endif  
Enddo
      
// *** Fecha Tabela do SQL-QUERY *** //
dbSelectArea(cAliasK1)
use  
Restarea(cAliasx51)
Return

