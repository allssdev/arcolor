#include "rwmake.ch"                                                               
#include "protheus.ch"   

/*/{Protheus.doc} RPCPC006
    Função responsavel pela Tela para cadastro dos operadores responsaveis pelos apontamentos.
    @author Diego Rodrigues - ALLSS
    @since 26/06/2024
    @type class
    @version P12.1.33
    /*/
User Function RPCPC006()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "ZZB"

dbSelectArea("ZZB")
dbSetOrder(1)
AxCadastro(cString,"Cadastro Operadores x Operações",cVldExc,cVldAlt)

Return()
