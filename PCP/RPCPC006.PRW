#include "rwmake.ch"                                                               
#include "protheus.ch"   

/*/{Protheus.doc} RPCPC006
    Fun豫o responsavel pela Tela para cadastro dos operadores responsaveis pelos apontamentos.
    @author Diego Rodrigues - ALLSS
    @since 26/06/2024
    @type class
    @version P12.1.33
    /*/
User Function RPCPC006()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de Variaveis                                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
Local aRotAdic 	:= {}
Private cString := "ZZB"

dbSelectArea("ZZB")
dbSetOrder(1)

aAdd(aRotAdic,{ "Bloqueio Usu�rio","U_RPCPE017", 0 , 1 }) //Chamada da tela para bloqueio do usu�rio
aAdd(aRotAdic,{ "Copiar Usu�rio"  ,"U_RPCPE018", 0 , 1 }) //Chamada da tela para copia dos usu�rio informado replicando suas opera寤es.

AxCadastro(cString,"Cadastro Operadores x Opera寤es",cVldExc,cVldAlt, aRotAdic)

Return()
