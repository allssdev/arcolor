#include 'totvs.ch'
/*/{Protheus.doc} RTMKE018
@description ExecBlock utilizado para sugerir descontos nos Atendimentos Call Center. Chamado pelo P.E. TK271BOK.
@author Júlio Nascimento
@since ??/??/????
@version 1.0
@return _lRet, boolean, Válido ou não
@type function
@history 30/10/2020, Anderson C. P. Coelho (ALLSS Soluções em Sistemas), Realizada a documentação básica da rotina.
@see https://allss.com.br
/*/
user function RTMKE018()
	local   _aSavArea  := GetArea()
	local   _aSavACS   := ACS->(GetArea())
	local   _aSavACN   := ACN->(GetArea())
	local   _lRet      := .T.
	local   _cProd     := ''
	local   _cDesc1    := ''
	local   _cDesc2    := ''
	local   _cDesc3    := ''
	local   _cDesc4    := ''
	private _cRotina   := "TK271BOK"
	private _cBloq     := Alltrim(SA1->A1_MSBLQL)
	private _cAtend    := M->UA_NUM
	private _cOper     := M->UA_OPER
	private _cCodreg   := ""
	private _nPDesc    := aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESC"   })
	private _nPFator   := aScan(aHeader,{|x|AllTrim(x[02])=="UB_CODFATR"})
	dbSelectArea("ACS")
	ACS->(dbOrderNickName("ACS_CODCLI")) //ACO_FILIAL+ACO_CODCLI+ACO_LOJA //Foi criado um indice de cliente + loja para tratamento da rotina na tabela.
	if ACS->(MsSeek(xFilial("ACS") + Padr(M->UA_CLIENTE,TamSx3("ACS_CODCLI")[01]) + Padr(M->UA_LOJA,TamSx3("ACS_LOJA")[01]),.T.,.F.))
		dbSelectArea("ACN")
		ACN->(dbOrderNickName("ACN_CODREG"))      //ACN_FILIAL+ACN_CODREG+ACN_CODPRO // Foi criado um indice de código de regra por cliente.
		if ACN->(MsSeek(xFilial("ACN") + Padr(ACS->ACS_CODREG,Len(ACN->ACN_CODREG)) + Padr(M->UB_PRODUTO,Len(ACN->ACN_CODPRO)),.T.,.F.))
			aCols[n][_nPFator] := ACN->ACN_CODFATR
			aCols[n][] := ACN->ACN_DESCV1
			aCols[n][] := ACN->ACN_DESCV2
			aCols[n][] := ACN->ACN_DESCV3
			aCols[n][] := ACN->ACN_DESCV4
			aCols[n][] := ACN->ACN_DESCON
		endif
	endif
	RestArea(_aSavACS)
	RestArea(_aSavACN)
	RestArea(_aSavArea)
return _lRet