#INCLUDE "PROTHEUS.CH"  
#Include "TOPCONN.CH" 
#Include "RwMake.CH"  
#include "Fileio.ch"
#Define CRLF CHR(13)+CHR(10)

/*
|===========================================================================|
| Programa  | NSGPEP17()| Autor| Valdemir Miranda       | Data : 15/06/2018 |
|===========================================================================|
| Descrição : Roteiro de Cálculo de Saldo de Salário Arcolor                |
|===========================================================================|
|           ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL.               |
|===========================================================================|
|  Programador | Data   | BOPS |  Motivo da Alteracao                       | 
|==============|========|======|============================================|
|              |        |      | Tente Primeiro: MV_DIASRES=2               |
|              |        |      |    e Mnemônico: P_DIASRES=2                |
|              |        |      |                                            |
|              |        |      |                                            |
|===========================================================================|
*/
USER FUNCTION RGPEP001() 
Private cVBRes   :="180"   
Private cAliasB  :=""
Private nValHS184:=0.00
Private nValVB184:=0.00  
Private nSalBase :=SRA->RA_SALARIO

// *** Pega Código da Verba a partir do Id de Cálculo *** //
cAliasB:=""   
xAreax:=getarea()
cQry := "SELECT SRV.RV_COD,SRV.RV_DESC,SRV.RV_TIPOCOD,SRV.RV_IR,SRV.RV_CODFOL,SRV.RV_REFFER,SRV.RV_ADIANTA,SRV.RV_REF13  "
cQry += " FROM "+RetSqlName("SRV")+" SRV "
cQry += "  WHERE SRV.RV_FILIAL = '"+xFilial("SRV")+"' "
cQry += "  AND SRV.RV_CODFOL = '0048' "
cQry += "  AND SRV.D_E_L_E_T_='' "
 
cAliasB:=GetNextAlias() 
If Select( cAliasB ) > 0
   dbSelectArea(cAliasB)
   (cAliasB)->(dbCloseArea())
EndIf

// *** Abre Tabelas *** // 
cQuery := ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN', TCGENQRY(,,cQuery), cAliasB , .F., .T.)  
    
// ***
dbSelectArea(cAliasB) 
ProcRegua((cAliasB)->(LastRec()))
dbGoTop()

// *** Pega Código da Verba *** //   
Do While .not. eof() 
   if (cAliasB)->RV_CODFOL = "0048"
      cVBRes:= (cAliasB)->RV_COD
   endif
   dbskip()
enddo 
dbSelectArea(cAliasB)
(cAliasB)->(dbCloseArea())
Restarea(xAreax)   

nDIASTRAB1:=Diastrab  
nValVB184 :=((nSalBase/30)*nDIASTRAB1) 

//alert("Verba: "+cVBRes+"  Saldo de Salário: "+str(nSalBase)+" / 30 * "+str(nValHS184)+" = "+str(nValVB184)) 

// *** Ajuste do Cálculo de Saldo de Salário *** // 
cTipox2:=RGPEVERB2(cVBRes)
if (nValVB184) > 0.00 .and. cTipox2 <> "I"

   if Flocaliapd(cVBRes)>0
      //APD[FlocaliAPD(cVBRes),9]:="D"
   endif   
   
   // *** Saldo de Salário New Space*** //
   //Fgeraverba(cVBRes,nValVB184 ,nDIASTRAB1,,,"V",,0,,dData_Pgto,.t.) 
   
endif 
Return

/*
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||          |          |       |                       |      |          |||
|||Programa  |RGPEVERB  | Autor | Valdemir Miranda      | Data |19/07/2018|||
|||          |          |       |                       |      |          |||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||Descrição | Pega Tipo de Verba, se Informada ou não                    |||  
|||          |                                                            ||| 
|||          |                                                            |||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||   
*/
Static Function RGPEVERB2(cVerb1)   

Local cAliasA:=""
Local cTipo2 :=""
Local cVerba :=cVerb1

cQry	:="Select * "
cQry 	+= " FROM  "+RetSqlName("RGB")+" RGB " 
cQry 	 += " WHERE RGB.D_E_L_E_T_='' "    
 
cQry += " AND RGB.RGB_FILIAL = '" + SRA->RA_FILIAL + "' " 
cQry += " AND RGB.RGB_MAT = '" + SRA->RA_MAT + "' "
cQry += " AND RGB.RGB_PERIOD = '" + mv_par03 + "' "
cQry += " AND RGB.RGB_PD = '" + cVerba+ "' "  

cAliasA	:= GetNextAlias() 
If Select( cAliasA ) > 0
   dbSelectArea( cAliasA )
   dbCloseArea()
EndIf   
 
// *** Abre Tabelas *** //
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQry), cAliasA , .F., .T.)  

// *** Inicio do Processamento de Funcionários em Atrazo *** //
dbSelectArea(cAliasA) 
ProcRegua((cAliasA)->(LastRec()))
dbGoTop()   

// ***
cTipo2:=" "
Do While .not. eof() 
   cTipo2:=(cAliasA)->RGB_TIPO2
   DBSKIP()
Enddo 

// *** Fecha Query *** //
dbSelectArea(cAliasA)
use
Return(cTipo2)
   