#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RTMKE016 บAutor  ณAdriano Leonardo    บ Data ณ  18/12/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina responsแvel por replicar o valor do desconto do itemบฑฑ
ฑฑบ          ณ do atendimento (Call Center) em campo auxiliar.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para a empresa Arcolor.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function RTMKE016(_lGatil)

Local _aSavArea := GetArea()
Local _cRotina	:= "RTMKE016"
Local _lRet		:= .T.
Default _lGatil	:= .F. //Variแvel auxiliar para determinar se a chamada da rotina estแ sendo feita por gatilho, por conta do retorno

//Resgato as posi็๕es das colunas no aCols
_nPValDesc := aScan(aHeader,{|x|AllTrim(x[02])==AllTrim("UB_VALDESC")})
_nPPValDAu := aScan(aHeader,{|x|AllTrim(x[02])==AllTrim("UB_VALDAUX")})

//Verifico se houve mudan็a
If aCols[n,_nPPValDAu] <> aCols[n,_nPValDesc]
	aCols[n,_nPPValDAu] := aCols[n,_nPValDesc]
EndIf

If _lGatil
	_lRet := aCols[n,_nPValDesc]
EndIf

RestArea(_aSavArea)

Return(_lRet)