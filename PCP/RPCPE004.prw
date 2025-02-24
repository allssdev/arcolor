#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RPCPE004  ºAutor  ³Alex Matos        º Data ³  18/12/14     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina criada para a criação automática de armazem  baseadosº±±
±±º          ³no preenchimento dos campos PRODUTO, ARMAZEM  no apontamentoº±±
±±º          ³da Ordem de Producao										  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico Arcolor                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RPCPE004()

Private _cProd := ""
Private _cLocal:= ""
Private _lRet  := .F.


_cProd := M->D3_COD
_cLocal := M->D3_LOCAL

If !Empty(_cProd) .AND. !Empty(_cLocal) 
	DbSelectArea("SB2")
	DbSetOrder(1)
	If DbSeek(xFilial("SB2")+_cProd+_cLocal)
		_lRet := .T.
	Else
	     _lRet:= ExistCpo("NNR") .AND. MsgYesNo("Armazém não existe, deseja criar??")
	     If _lRet = .T.
	     	CRIASB2(_cProd,_cLocal)//produto, local
	     Else
	     	MsgInfo("Operacão cancelada pelo usuário - Armazém Inválido")
	     EndIf
	EndIf
Else
	MsgAlert("Produto ou Armazém não informado!!!")
    _lRet := .F.
EndIf

RETURN(_lRet)