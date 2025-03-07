#INCLUDE "TbiConn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"


/*/{Protheus.doc} F330EXCOMP
@description Ponto de Entrada para estorno/exclus�o.
@description O ponto de entrada F330EXCOMP efetua valida��es adicionais na exclus�o/estorno da compensa��o de Contas a receber. 
Este ponto de entrada identifica atrav�s do terceiro par�metro em qual opera��o est� sendo realizada (5=Estorno e 4=Exclus�o).
@author Diego Rodrigues Pereira (ALLSS Solu��es em Sistemas)
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
            //MsgAlert("Este titulo ser� estornado na mesma data da baixa original","Aten��o")	       
            lRet := .T.	     
        Else
            MsgAlert("Este titulo n�o ser� estornado/excluido porque a data est� diferente da baixa original","Aten��o")	       
            lRet := .F.	   
        EndIf		
    ElseIf nOpcao == 4 
           //Exclusao	    
        If aTit[1][06] == DTOC(ddatabase)
            //MsgAlert("Este titulo ser� excluido na mesma data da baixa original","Aten��o")	       
            lRet := .T.	     
        Else
            MsgAlert("Este titulo n�o ser� excluido porque a data est� diferente da baixa original","Aten��o")	       
            lRet := .F.	   
        EndIf		
    EndIf	
EndIf
   
Return lRet
