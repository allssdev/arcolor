#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RTMKE015 ºAutor  ³Adriano Leonardo    º Data ³  17/12/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina responsável por replicar o percentual ou valor dos  º±±
±±º          ³ campos de desconto e acréscimo para que estes sejam preser_º±±
±±º          ³ vados ao se alterar o tipo de operação do atendimento.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function RTMKE015()

Local _aSavArea := GetArea()
Local _cRotina	:= "RTMKE015"
Local _lRet    := .T.      

If AllTrim(ReadVar()) == "M->UB_VALDESC" //Campo padrão valor do desconto
	If M->UB_VALDESC<>aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_VALDESC"})]
		aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_VALDAUX"})] := M->UB_VALDESCC //Campo auxiliar valor do desconto
		aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCAUX"})] := 0              //Campo auxiliar percentual do desconto
	EndIf
ElseIf AllTrim(ReadVar()) == "M->UB_DESC" //Campo padrão percentual de desconto
	If M->UB_DESC<>aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESC"   })]
		aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCAUX"})] := M->UB_DESC    //Campo auxiliar percentual do desconto
		aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_VALDAUX"})] := 0             //Campo auxiliar valor do desconto
	EndIf
EndIf
If AllTrim(ReadVar()) == "M->UB_VALACRE" //Campo padrão valor do acréscimo
	If M->UB_VALACRE<>aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_VALACRE"})]
		aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_ACREVAL"})] := M->UB_VALACRE //Campo auxiliar valor do acréscimo
		aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_ACREPOR"})] := 0             //Campo auxiliar percentual do acréscimo
	EndIf
ElseIf AllTrim(ReadVar()) == "M->UB_ACRE" //Campo padrão percentual de acréscimo
	If M->UB_ACRE<>aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_ACRE"   })]
		aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_ACREPOR"})] := M->UB_ACRE    //Campo auxiliar percentual do acréscimo
		aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_ACREVAL"})] := 0             //Campo auxiliar valor do acréscimo
	EndIf
EndIf

RestArea(_aSavArea)

Return(_lRet)