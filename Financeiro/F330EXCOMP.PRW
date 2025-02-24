#INCLUDE "TbiConn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"


/*/{Protheus.doc} F330EXCOMP
@description Ponto de Entrada para estorno/exclusão.
@description O ponto de entrada F330EXCOMP efetua validações adicionais na exclusão/estorno da compensação de Contas a receber. 
Este ponto de entrada identifica através do terceiro parâmetro em qual operação está sendo realizada (5=Estorno e 4=Exclusão).
@author Diego Rodrigues Pereira (ALLSS Soluções em Sistemas)
@since 18/05/2021
@type function
@version 1.00
@see https://allss.com.br
/*/


User Function F330EXCOMP()

Local aTit	:= aClone(ParamIxb[1])
Local aReg	:= aClone(ParamIxb[2])    
Local nOpcao:= ParamIxb[3]    
Local lRet := .F.
Private  _cRotina  := "F330EXCOMP"

If Len(aTit) > 0 .And. Len(aReg) > 0	
    If nOpcao == 5  
      //Estorno		    
        If aTit[1][06] == DTOC(ddatabase)
            //MsgAlert("Este titulo será estornado na mesma data da baixa original","Atenção")	       
            lRet := .T.	     
        Else
            MsgAlert("Este titulo não será estornado/excluido porque a data está diferente da baixa original","Atenção")	       
            lRet := .F.	   
        EndIf		
    ElseIf nOpcao == 4 
           //Exclusao	    
        If aTit[1][06] == DTOC(ddatabase)
            //MsgAlert("Este titulo será excluido na mesma data da baixa original","Atenção")	       
            lRet := .T.	     
        Else
            MsgAlert("Este titulo não será excluido porque a data está diferente da baixa original","Atenção")	       
            lRet := .F.	   
        EndIf		
    EndIf	
EndIf
   
Return lRet
