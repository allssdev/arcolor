#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} RQIEE001
@description Execblock utilizado para preenchimento automatico dos parametros na emiss�o do certificado da qualidade
@obs Deve ser preenchido temb�m o campo X1_VALID na tabela SX1 para os grupos e perguntas espec�ficas(QER050) de arquivo de entrada a fun��o .
IIF(EXISTBLOCK("RQIEE001"),U_RQIEE001("QER050"),.T.)
OBS.: cPerg � o grupo de perguntas da SX1. Esta vari�vel "cPerg" dever� conter os espa�os necess�rios, conforme o tamanho total do campo "X1_GRUPO".
@author Diego Rodrigues
@since 28/07/2023
@version 1.0
@param cPerg, characters, Pergunta, conforme o grupo de perguntas da tabela SX1 (dever� conter inclusive os espa�os, complementando assim o tamanho total definido no campo "X1_GRUPO").
@see https://allss.com.br
/*/
user function RQIEE001(cPerg)
	//local   _cRotina  := 'RQIEE001'
If funname()= "QIEA215"
	mv_par01 := QEK->QEK_FORNEC	
    mv_par02 := QEK->QEK_LOJFOR
    mv_par03 := QEK->QEK_PRODUT
    mv_par04 := QEK->QEK_DTENTR
    mv_par05 := QEK->QEK_LOTE 			
    mv_par06 := QEK->QEK_NTFISC  
    mv_par07 := QEK->QEK_SERINF 
    mv_par08 := QEK->QEK_ITEMNF	
    mv_par09 := QEK->QEK_NUMSEQ
    mv_par10 := 1
    mv_par11 := 2
EndIf
return()
