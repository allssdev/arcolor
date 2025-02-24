#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "VKEY.CH"
#INCLUDE "TBICONN.CH
#INCLUDE "RWMAKE.CH"

User Function RTMKA003()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".F." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "SA1"
Private cTitulo := "Clientes"

	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" FUNNAME "RTMKA003"		
	

dbSelectArea(cString)
(cString)->(dbSetOrder(1))
AxCadastro(cString,cTitulo,cVldAlt,cVldExc )

Return .t.