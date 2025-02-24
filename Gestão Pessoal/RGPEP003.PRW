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
USER FUNCTION RGPEP003() 
Private cVBRes   :="180"   
Private cAliasB  :=""
Private nValHS184:=0.00
Private nValVB184:=0.00  
Private nSalBase :=SRA->RA_SALARIO
 

// *** Pega Código da Verba a partir do Id de Cálculo *** //
cAliasB:=""   
xAreax:=getarea()
cQry := "SELECT SRV.RV_COD,SRV.RV_DESC,SRV.RV_TIPOCOD,SRV.RV_IR,SRV.RV_CODFOL,SRV.RV_REFFER,SRV.RV_ADIANTA,SRV.RV_REF13  "
cQry += " FROM "+RetSqlName("SRV")+" SRV"

cQry += "  WHERE SRV.D_E_L_E_T_='' "
cQry += "  AND SRV.RV_CODFOL = '0048' "
 
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
  
// *** Pega Código da Verba *** //   
Do While .not. eof() 
   if (cAliasB)->RV_CODFOL = "0048"
      cVBRes:= (cAliasB)->RV_COD
   endif
   dbskip()
enddo 
dbSelectArea(cAliasB)
USE  
Restarea(xAreax)   

nValHS184:=Diastrab  
nValVB184:=((nSalBase/30)*nValHS184) 

//alert("Verba: "+cVBRes+"  Saldo de Salário: "+str(nSalBase)+" / 30 * "+str(nValHS184)+" = "+str(nValVB184)) 

// *** Ajuste do Cálculo de Saldo de Salário *** //
if (nValVB184) > 0.00

   if Flocaliapd(cVBRes)>0
      APD[FlocaliAPD(cVBRes),9]:="D"
   endif   
   
   // *** Saldo de Salário New Space*** //
   Fgeraverba(cVBRes,nValVB184 ,nValHS184,,,"V",,0,,dData_Pgto,.t.) 
   
endif 
Return