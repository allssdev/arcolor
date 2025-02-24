#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"              

/*/{Protheus.doc} MT120FOL
@description Ponto de entrada utilizado popular os campos customizados no rodapé dos pedidos de compras. Esse ponto de entrada é utilizado juntamente com os PEs: MT120TEL,MTA120G2 
@author  Adriano Leonardo
@since   16/04/2013
@version P12.1.25 - 1.00
@see https://allss.com.br
@history 03/02/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Adequação do fonte devido a rotina se comportar diferente na release 12.1.2210
/*/

User Function MT120FOL()

Local _aArea   := GetArea()
Local nOpc    := PARAMIXB[1]
Local aPosGet := PARAMIXB[2]
Local _oMemo  := ""

Public _cAux := SC7->C7_OBSERVE 

If nOpc <> 1 
	@ 006,aPosGet[1,1] SAY OemToAnsi('Observacoes do pedido:') OF oFolder:aDialogs[7] PIXEL SIZE 070,009
	If !Inclui .Or. (!Inclui .And. !Altera) .or. nOpc == 6
		_oMemo := tMultiGet():New(015,aPosGet[1,1],{|U|If(PCount()>0,_cAux:=U,SC7->C7_OBSERVE)},oFolder:aDialogs[7],200,041,,,,,,.T.)
	Else
		_cAux := ""
		_oMemo := tMultiGet():New(015,aPosGet[1,1],{|U|If(PCount()>0,_cAux:=U,_cAux)},oFolder:aDialogs[7],200,041,,,,,,.T.)
	EndIf
EndIf
      
RestArea(_aArea)
      
Return Nil
