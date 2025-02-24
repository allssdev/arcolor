#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  TLVENT   ºAutor  ³Renan Felipe        º Data ³  29/12/12     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Na abertura do browse do televenda para verificar se o      º±±
±±           ³orçamento se trata de uma cópia.                            º±±
±±		   	 ºPONTO DE ENTRADA APOS O CARREGAMENTO DE UM ATENDIMENTO PARA º±±
±±º           ALTERAÇÃO NA  ROTINA DE TELEVENDAS (ANTES DE APRESENTAR O   º±±
±±º           ACOLS, MAS COM ESTE JA MONTADO).                            º±±  
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP11 -Específico para a empresa Arcolor                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TLVENT(_cNumAt)

Local _aArea    := GetArea()
Local _nPVerRn  := aScan(aHeader,{|x|AllTrim(x[02])=="UB_VERIFRN"})

If ExistBlock("RTMKE007")
	If AllTrim(SUA->UA_COPY) == "S" .AND. (SuperGetMV("MV_ATUCPY",,.F.) .OR. (SUA->UA_CLIENTE <> SUA->UA_CLIORCP .AND. SUA->UA_LOJA <> SUA->UA_LJORCP))
		ExecBlock("RTMKE007")
	Else
		If ALTERA .AND. _nPVerRn > 0
			For _x := 1 To Len(aCols)
				aCols[_x][_nPVerRn] := ""
			Next
		EndIf
	EndIf
EndIf

RestArea(_aArea)
	
Return()