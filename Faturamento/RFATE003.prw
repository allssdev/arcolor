#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATE003  ºAutor  ³Anderson C. P. Coelho º Data ³  14/12/12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina utilizada para trazer o código do Cliente e Fornece-º±±
±±º          ³dor, etc. de forma automática, dentro do conceito de loja   º±±
±±º          ³                                                            º±±
±±º          ³Para correto funcionamento, este Execblock deve ser inseridoº±±
±±º          ³na validação do campo de CNPJ do cadastro desejado, sendo   º±±
±±º          ³passados os seguintes parâmetros:                           º±±
±±º          ³  * _cAlias  - String com o alias da tabela a ser trabalhadaº±±
±±º          ³               (ex.: "SA1")                                 º±±
±±º          ³  * _cCNPJ   - Conteudo do CNPJ a ser pesquisado no cadastroº±±
±±º          ³               (ex.: M->A1_CGC)                             º±±
±±º          ³  * _cIniCpo - Inicial do campo (ex.: "A1")                 º±±
±±º          ³                                                            º±±
±±º          ³Além disso, deve-se utilizar a numeração automática pela    º±±
±±º          ³SXE/SXF, no inicializador padrão do campo.                  º±±
±±º          ³ (ex.: )                                                    º±±
±±º          ³Deve-se também utilizar o inicializador padrão "01" no campoº±±
±±º          ³relativo a loja do cadastro pretendido.                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFATE003(_cAlias,_cCNPJ,_cIniCpo)

Local _aSavArea  := GetArea()
//Local _cRotina   := "RFATE003"
Local _cQry      := ""
Local _cCod      := ""
Local _cLoja     := ""
Local _cReadVBk  := ReadVar()
Local _lRet      := .T.
Local _lValid    := .T.

Default _cAlias  := ""
Default _cIniCpo := ""
Default _cCNPJ   := ""

If INCLUI
	If !Empty(_cAlias)
		If Empty(_cIniCpo)
			If SubStr(_cAlias,1,1) == "S"
				_cIniCpo := SubStr(_cAlias,2,2)
			Else
				_cIniCpo := AllTrim(_cAlias)
			EndIf
		EndIf
		If Empty(_cCNPJ)
			_cCNPJ := AllTrim("M->"+_cIniCpo+"_CGC")
		EndIf
		If !Empty(_cCNPJ)              .AND. ;
			Len(AllTrim(_cCNPJ)) == 14 .AND. ;
			Replicate("0",14)<>_cCNPJ  .AND. ;
			Replicate("1",14)<>_cCNPJ  .AND. ;
			Replicate("2",14)<>_cCNPJ  .AND. ;
			Replicate("3",14)<>_cCNPJ  .AND. ;
			Replicate("4",14)<>_cCNPJ  .AND. ;
			Replicate("5",14)<>_cCNPJ  .AND. ;
			Replicate("6",14)<>_cCNPJ  .AND. ;
			Replicate("7",14)<>_cCNPJ  .AND. ;
			Replicate("8",14)<>_cCNPJ  .AND. ;
			Replicate("9",14)<>_cCNPJ
			_cQry := " SELECT MAX(" + _cAlias+"."+_cIniCpo+"_COD + '|' + " + _cAlias+"."+_cIniCpo+"_LOJA) COD "
			_cQry += " FROM   " + RetSqlName(_cAlias) + " " + _cAlias
			_cQry += " WHERE  " + _cAlias+"."+"D_E_L_E_T_<>'*' "
			_cQry += "   AND  " + _cAlias+"."+_cIniCpo+"_FILIAL             = '" + xFilial(_cAlias)   + "' "
			_cQry += "   AND  SUBSTRING(" + _cAlias+"."+_cIniCpo+"_CGC,1,8) = '" + SubStr(_cCNPJ,1,8) + "' "
			If __cUserId == "000000"
			//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001",_cQry)
			EndIf
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"TCNPJ",.F.,.T.)
			dbSelectArea("TCNPJ")
			If !TCNPJ->(EOF())
				_cCod  := Padr(SubStr(TCNPJ->COD,1,AT("|",TCNPJ->COD)-1),TamSx3(_cIniCpo+"_COD" )[01])
				_cLoja := Padr(SubStr(TCNPJ->COD,AT("|",TCNPJ->COD)+1  ),TamSx3(_cIniCpo+"_LOJA")[01])
			EndIf
			TCNPJ->(dbCloseArea())
		EndIf
	EndIf
	
	//Inicio - Trecho adicionado por Adriano Leonardo em 15/05/2014 para correção da numeração na SA2
	If _cIniCpo=="A2" .And. Empty(_cCod)
		_cCod := M->A2_COD
		_cLoja:= M->A2_LOJA
	EndIf
	//Final  - Trecho adicionado por Adriano Leonardo em 15/05/2014 para correção da numeração na SA2
	
	__ReadVar := "M->"+_cIniCpo+"_COD"
	If !Empty(_cCod)
		&(__ReadVar) := _cCod
	//Else	//If Empty(&(__ReadVar))
	//	&(__ReadVar) := GETSX8NUM(_cAlias,_cIniCpo+"_COD")
	EndIf
	__ReadVar := "M->"+_cIniCpo+"_LOJA"
	If !Empty(_cCod) .AND. !Empty(_cLoja)
		&(__ReadVar) := Soma1(_cLoja)
	Else
		&(__ReadVar) := "01"
	EndIf
	_lValid   := .T.
	__ReadVar := "M->"+_cIniCpo+"_COD"

	_cAliasSX3 := "SX3_"+GetNextAlias()
	OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
	dbSelectArea(_cAliasSX3)
	(_cAliasSX3)->(dbSetOrder(2))

	If (_cAliasSX3)->(MsSeek(_cIniCpo+"_COD",.T.,.F.))
		If !Empty((_cAliasSX3)->X3_VALID + " " + (_cAliasSX3)->X3_VLDUSER)
			_lValid := &(AllTrim((_cAliasSX3)->X3_VALID)+IIF(!Empty((_cAliasSX3)->X3_VALID).AND.!Empty((_cAliasSX3)->X3_VLDUSER),".AND.","")+AllTrim((_cAliasSX3)->X3_VLDUSER)) //Validação do campo
		EndIf
		//Validação do campo + gatilho
		If _lValid .AND. ExistTrigger(_cIniCpo+"_COD")
			RunTrigger(1)
			EvalTrigger()
		EndIf
	EndIf
	_lValid   := .T.
	__ReadVar := "M->"+_cIniCpo+"_LOJA"


	If (_cAliasSX3)->(MsSeek(_cIniCpo+"_LOJA",.T.,.F.))
		If !Empty((_cAliasSX3)->X3_VALID + " " + (_cAliasSX3)->X3_VLDUSER)
			_lValid := &(AllTrim((_cAliasSX3)->X3_VALID)+IIF(!Empty((_cAliasSX3)->X3_VALID).AND.!Empty((_cAliasSX3)->X3_VLDUSER),".AND.","")+AllTrim((_cAliasSX3)->X3_VLDUSER)) //Validação do campo
		EndIf
		//Validação do campo + gatilho
		If _lValid .AND. ExistTrigger(_cIniCpo+"_LOJA")
			RunTrigger(1)
			EvalTrigger()
		EndIf
	EndIf
//Else //Linha comentada por Adriano Leonardo em 28/08/2013 - para correção
//	MsgStop("Atenção! Problemas com a parametrização. por favor, informe o administrador!",_cRotina+"_001") //Linha comentada por Adriano Leonardo em 28/08/2013 - para correção
EndIf

__ReadVar := _cReadVBk

RestArea(_aSavArea)

Return(_lRet)
