#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATE014  ºAutor  ³Adriano Leonardo    º Data ³  08/01/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ ExecBlock responsável por realizar a validação do campo    º±±
±±º          ³ para definir se o mesmo será editável para o usuário.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function RFATE014(_cCampo)		//RFATE014(_cGrupo)                
	Local _aSavArea := GetArea()
	Local _aGrp     := {}
	Local _lRet     := .T.
	Default _cCampo := ""
	/*
	Local _nGrp     := 0
	Local _cGrp     := ""

	Default _cGrupo := ""

	If ExistBlock("RFATE013")
		U_RFATE013()
	EndIf

	//Remove os campos separadores
	_cGrupo := StrTran(_cGrupo,'#','')

	//Descriptografa o campo
	//_cGrp := Decode64(_cGrp)
	If UnCompress(@_cGrp,@_nGrp,_cGrupo,Len(_cGrupo))
		//Verifica se o grupo do usuário atual tem permissão para alterar o campo
		_lRet := !UsrRetGrp(UsrRetName(RetCodUsr()))[1]$_cGrp
	EndIf
	*/
	_aGrp := UsrRetGrp(UsrRetName(RetCodUsr()))
	If Len(_aGrp) == 0
		AADD(_aGrp,"")
	EndIf
	BeginSql Alias "SZ5TMP"
		SELECT COUNT(*) REG
		FROM %table:SZ5% SZ5
		WHERE SZ5.Z5_FILIAL = %xFilial:SZ5%
		  AND SZ5.Z5_GRUPO  = %Exp:_aGrp[1]%
		  AND SZ5.Z5_CAMPO  = %Exp:_cCampo%		//%Exp:AllTrim(StrTran(__ReadVar,"M->",""))%
		  AND SZ5.%NotDel%
	EndSql
	dbSelectArea("SZ5TMP")
	_lRet := SZ5TMP->REG == 0
	SZ5TMP->(dbCloseArea())
	RestArea(_aSavArea)
return(_lRet)