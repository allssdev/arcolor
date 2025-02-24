#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*/{Protheus.doc} SD3250I
@description Encerramento automatico das ordens de produção para produto com o campo B5_XENCAUT ativado
@author Diego Rodrigues
@since 09/11/2023
@version 1.0
@type function
@see https://allss.com.br
/*/

//

User Function RPCPE011(_cOP, _cProd, _cLocal)
Local aVetor := {}
Local nOpc   := 7 //-Opção de execução da rotina, informado nos parametros quais as opções possiveis
Local cOp    := _cOP
Local cCod   := _cProd
Local cLocal := _cLocal
Local cChave :=  ""
lMsErroAuto  := .F.
  
cChave :=  xFilial("SD3") + cOp + cCod + cLocal
 
DbSelectArea("SD3")
SD3->(DbSetOrder(1))
If SD3->(DbSeek(cChave))
//Estou montando meu array aVetor com os campos do índice enviado na última posição, no caso 1. 
    aVetor := {;             
            {"D3_FILIAL",xFilial("SD3")  ,NIL},;
            {"D3_OP"    ,cOp            ,NIL},;
            {"D3_COD"   ,cCod          ,NIL},;
            {"D3_LOCAL" ,cLocal         ,NIL},;
            {"INDEX"    ,1               ,NIL}}
                     
    MSExecAuto({|x, y| mata250(x, y)},aVetor, nOpc )
  
    If lMsErroAuto
		MsgInfo("Encerramento da ordem de produção não concluido. Avise o PCP",_cRotina+"_ATENÇÃO")
        Mostraerro()
    Endif
EndIf
  
Return
