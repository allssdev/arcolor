#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RFINE008  บAutor  ณ Adriano Leonardo   บ Data ณ 17/04/13   บฑฑ
ฑฑบ          ณ           บAutor  ณ J๚lio Soares       บ Data ณ 18/06/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina responsแvel por remontar as parcelas do tํtulos a   บฑฑ
ฑฑบ          ณ receber                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ Implementado bloqueio de seguran็a caso a rotina nใo seja  บฑฑ
ฑฑบ          ณ executada.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para a empresa Arcolor 			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user function RFINE008(_cNumPed, _dDtNota)

//Foi criado o campo E1_REMONTA para marcar se a parcela jแ foi remontada ou se serแ considerada para remontagem
Local _aSavArea 	:= GetArea()
Local _aSavSE1		:= SE1->(GetArea())
Local _lRet			:= .T.
Private _cRotina    := "RFINE008"
Private _cTab1		:= "TabTmp1"
Private _aVencim	:= {}
Private _aDeletar 	:= {}
Private _nTtlParc	:= 0
Private _nTotal1  	:= 0
Private _nTotal2	:= 0 
Private _aCampos 	:= {}
Private _cPrefNF	:= ""
Private _cPrefZZ	:= ""
Private _cNumeNF	:= ""
Private _cNumeZZ	:= ""
Private _nNumPNF	:= 1
Private _nNumPZZ	:= 1
Private _aCpoSom	:= {}
Private _aValorN	:= {}
Private _aValorZ	:= {}
Default _cNumPed    := "" //N๚mero do pedido
Default _dDtNota	:= "" //Data de emissใo da nota

/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณCampos que serใo somados na aglutina็ใo das parcelas    ณ
//ณATENวรO: Seguir sempre essa sintaxe                     ณ
//ณAADD(_aCpoSom,"NOME DO CAMPO")				           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
*/
AADD(_aCpoSom,"E1_ISS"		)
AADD(_aCpoSom,"E1_IRRF"		)
AADD(_aCpoSom,"E1_INSS"		)
AADD(_aCpoSom,"E1_CSLL"		)
AADD(_aCpoSom,"E1_COFINS"	)
AADD(_aCpoSom,"E1_PIS"		)
AADD(_aCpoSom,"E1_ACRESC"	)
AADD(_aCpoSom,"E1_DECRESC"	)
AADD(_aCpoSom,"E1_FETHAB"	)
AADD(_aCpoSom,"E1_MDMULT"	)
AADD(_aCpoSom,"E1_MDBONI"	)
AADD(_aCpoSom,"E1_MDDESC"	)
AADD(_aCpoSom,"E1_RETCNTR"	)
AADD(_aCpoSom,"E1_VALCOM1"	)
AADD(_aCpoSom,"E1_BASCOM1"	)
AADD(_aCpoSom,"E1_VALCOM2"	)
AADD(_aCpoSom,"E1_BASCOM2"	)
AADD(_aCpoSom,"E1_VALCOM3"	)
AADD(_aCpoSom,"E1_BASCOM3"	)
AADD(_aCpoSom,"E1_VALCOM4"	)
AADD(_aCpoSom,"E1_BASCOM4"	)
AADD(_aCpoSom,"E1_VALCOM5"	)
AADD(_aCpoSom,"E1_BASCOM5"	)
AADD(_aCpoSom,"E1_BASEIRF"	)

//Inicializo os arrays de valores
For _nCont := 1 To Len(_aCpoSom)
	AADD(_aValorN,0)
	AADD(_aValorZ,0)
Next

//Query responsแvel por trazer os tํtulos a receber que deverใo ser refeitos
_cQuery := "SELECT * "
_cQuery += "FROM " + RetSqlName("SE1") + " SE1 WITH (NOLOCK) "
_cQuery += "	WHERE SE1.D_E_L_E_T_ = '' "
_cQuery += "		AND SE1.E1_FILIAL='" + xFilial("SE1") + "' "
_cQuery += "		AND SE1.E1_EMISSAO = '" + _dDtNota + "' "
_cQuery += "		AND SE1.E1_PARCELA <> '' "
_cQuery += "		AND "
_cQuery += "			(SELECT COUNT(SE1A.E1_PREFIXO) "
_cQuery += "				FROM " + RetSqlName("SE1") + " SE1A WITH (NOLOCK) "
_cQuery += "				WHERE SE1A.D_E_L_E_T_      = '' "
_cQuery += "						AND SE1A.E1_FILIAL   = '" + xFilial("SE1") + "' "
_cQuery += "						AND SE1A.E1_PEDIDO  <> '' "
_cQuery += "						AND SE1A.E1_PARCELA <> '' "
_cQuery += " 						AND SE1A.E1_REMONTA <> 'N' "
_cQuery += "						AND SE1A.E1_PREFIXO IN "
_cQuery += " 							(SELECT DISTINCT SE1D.E1_PREFIXO FROM " + RetSqlName("SE1") + " SE1D WITH (NOLOCK) "
_cQuery += " 							WHERE SE1D.D_E_L_E_T_ = '' "
_cQuery += " 							AND SE1D.E1_FILIAL='" + xFilial("SE1") + "' "
_cQuery += " 							AND SE1D.E1_REMONTA <> 'N' "
_cQuery += " 							AND SE1D.E1_PREFIXO NOT LIKE '%Z%'    "
_cQuery += " 							AND SE1D.E1_PREFIXO NOT LIKE '%ST%')  "
_cQuery += "					      	AND SE1A.E1_PEDIDO   = SE1.E1_PEDIDO  "
_cQuery += "					      	AND SE1A.E1_EMISSAO  = SE1.E1_EMISSAO "
_cQuery += "				GROUP BY SE1A.E1_PEDIDO "
_cQuery += "			)>0 "
_cQuery += "		AND "
_cQuery += "			(SELECT COUNT(E1_PREFIXO) "
_cQuery += "				FROM " + RetSqlName("SE1") + " SE1B WITH (NOLOCK) "
_cQuery += "				WHERE SE1B.D_E_L_E_T_ = '' "
_cQuery += "						AND SE1B.E1_FILIAL='" + xFilial("SE1") + "' "
_cQuery += "						AND SE1B.E1_PEDIDO <> '' "
_cQuery += "						AND SE1B.E1_PARCELA <> '' "
_cQuery += " 						AND SE1B.E1_REMONTA <> 'N' "
_cQuery += "						AND SE1B.E1_PREFIXO LIKE '%Z%' "
_cQuery += "						AND SE1B.E1_PEDIDO=SE1.E1_PEDIDO AND SE1B.E1_EMISSAO = SE1.E1_EMISSAO "
_cQuery += "				GROUP BY SE1B.E1_PEDIDO "
_cQuery += "			)>0 "
_cQuery += "			AND "
_cQuery += "			(SELECT COUNT(*) "
_cQuery += "				FROM " + RetSqlName("SE1") + " SE1C WITH (NOLOCK) "
_cQuery += "					WHERE "
_cQuery += "						SE1C.D_E_L_E_T_ = '' "
_cQuery += "						AND SE1C.E1_FILIAL='" + xFilial("SE1") + "' "
_cQuery += "						AND SE1C.E1_EMISSAO  = '" + _dDtNota + "' "
_cQuery += "						AND SE1C.E1_PEDIDO   <> '' "
_cQuery += "						AND SE1C.E1_PARCELA <> '' "
_cQuery += " 						AND SE1C.E1_REMONTA<>'N' "
_cQuery += "						AND (SE1C.E1_PREFIXO LIKE '%Z%' OR SE1C.E1_PREFIXO IN "
_cQuery += " 							(SELECT DISTINCT SE1D.E1_PREFIXO FROM " + RetSqlName("SE1") + " SE1D WITH (NOLOCK) "
_cQuery += " 							WHERE SE1D.D_E_L_E_T_ = '' "
_cQuery += " 							AND SE1D.E1_FILIAL='" + xFilial("SE1") + "' "
_cQuery += " 							AND SE1D.E1_REMONTA<>'N' "
_cQuery += " 							AND SE1D.E1_PREFIXO NOT LIKE '%Z%' "
_cQuery += " 							AND SE1D.E1_PREFIXO NOT LIKE '%ST%') "
_cQuery += "							AND SE1C.E1_PEDIDO=SE1.E1_PEDIDO AND SE1C.E1_EMISSAO = SE1.E1_EMISSAO) "
_cQuery += "						AND SE1C.E1_BAIXA<>'' "
_cQuery += "						AND SE1C.E1_PEDIDO=SE1.E1_PEDIDO AND SE1C.E1_EMISSAO = SE1.E1_EMISSAO)=0 "
_cQuery += " AND SE1.E1_PEDIDO   = '" + _cNumPed + "' "
_cQuery += " AND SE1.E1_REMONTA <> 'N' "
_cQuery += " AND SE1.E1_EMISSAO  = '" + _dDtNota + "' "
_cQuery += " ORDER BY SE1.E1_PEDIDO, SE1.E1_PREFIXO, SE1.E1_PARCELA "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cTab1,.F.,.T.)
dbSelectArea(_cTab1)
_cNumPed	:= (_cTab1)->E1_PEDIDO


_cSERFATA := GetMV("MV_SERFATA")
_bTYPE    := "TYPE(STR((_cTab1)->&(_aCpoSom[_nCont])))"


While (_cTab1)->(!EOF())
	If _cNumPed	== (_cTab1)->E1_PEDIDO
		AADD(_aDeletar,(_cTab1)->R_E_C_N_O_)
		/* FB - RELASE 12.1.23
		If AllTrim((_cTab1)->E1_PREFIXO)==GetMV("MV_SERFATA") //Parโmetro com a s้rie de nota sendo utilizada no momento (RFATA002 - Confer๊ncia de Separa็ใo)		//SuperGetMV("MV_SERFATA",,"1")
		*/
		If AllTrim((_cTab1)->E1_PREFIXO) == _cSERFATA //Parโmetro com a s้rie de nota sendo utilizada no momento (RFATA002 - Confer๊ncia de Separa็ใo)			
			_nTotal1 += (_cTab1)->E1_SALDO
			For _nCont:= 1 To Len(_aCpoSom)
				/* FB - RELEASE 12.1.23
				_aValorN[_nCont] += IIF(TYPE(STR((_cTab1)->&(_aCpoSom[_nCont])))=="N",(_cTab1)->&(_aCpoSom[_nCont]),0)
				*/
				_aValorN[_nCont] += IIF( &(_bTYPE) == "N",(_cTab1)->&(_aCpoSom[_nCont]),0)
			Next
			_cPrefNF	:= (_cTab1)->E1_PREFIXO
			_cNumeNF	:= (_cTab1)->E1_NUM
			AADD(_aVencim,{(_cTab1)->E1_VENCTO,(_cTab1)->E1_VENCREA})
		Else
			_nTotal2 += (_cTab1)->E1_SALDO
			_cPrefZZ	:= (_cTab1)->E1_PREFIXO
			_cNumeZZ	:= (_cTab1)->E1_NUM
			For _nCont:= 1 To Len(_aCpoSom)
				/* FB - RELEASE 12.1.23
				_aValorZ[_nCont] += IIF(TYPE(STR((_cTab1)->&(_aCpoSom[_nCont])))=="N",(_cTab1)->&(_aCpoSom[_nCont]),0)
				*/
				_aValorZ[_nCont] += IIF( &(_bTYPE) == "N",(_cTab1)->&(_aCpoSom[_nCont]),0)
			Next
		EndIf
	EndIf
	dbSelectArea(_cTab1)
	(_cTab1)->(dbSkip())
EndDo
//Chamo a fun็ใo para refazer as parcelas
_nTtlParc := Len(_aDeletar)
Remontar()

//Resetar as variแveis auxiliares

//Valor total
_nTotal1  	:= 0
_nTotal2  	:= 0

_aVencim  	:= {}

dbSelectArea(_cTab1)
(_cTab1)->(dbCloseArea())

RestArea(_aSavSE1)
RestArea(_aSavArea)

Return(_lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDeletar   บAutor  ณAdriano Leonardo    บ Data ณ 18/04/13    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc. ณFun็ใo utilizada para deletar as parcelas dos tํtulos a receber บฑฑ
ฑฑบDesc. ณque serใo remontadas.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Fun็ใo Principal                   		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function Deletar()
	for _nCont := 1 to Len(_aDeletar)
		dbSelectArea("SE1")
		SE1->(dbSetOrder(0))
		SE1->(dbGoTo(_aDeletar[_nCont]))
		while !RecLock("SE1",.F.) ; enddo
			Delete
		SE1->(MsUnlock())
	next
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRemontar  บAutor  ณAdriano Leonardo    บ Data ณ 18/04/13    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc. ณFun็ใo utilizada para remontar as parcelas dos tํtulos a receberบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Fun็ใo Principal                   		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Remontar()
Local _cAliasSX3 := ""

	_nParcNF := Int(_nTtlParc/4)
	_nParcZZ := Int(_nTtlParc/2) - _nParcNF
	_nVlrNF  := Round(_nTotal1/_nParcNF,2)
	_nVlrZZ  := Round(_nTotal2/_nParcZZ,2)
	For _nCont1 := 1 To Len(_aDeletar)
		dbSelectArea("SE1")
		SE1->(dbSetOrder(0))
		SE1->(dbGoTo(_aDeletar[_nCont1]))
		while !RecLock("SE1",.F.) ; enddo
			SE1->E1_TIPO := 'DEL' //Evita chave duplicada
		SE1->(MsUnlock())
	Next
	//Insere as novas parcelas
	For _nCont := 1 To Len(_aDeletar)
		dbSelectArea("SE1")
		SE1->(dbSetOrder(0))
		SE1->(dbGoTo(_aDeletar[_nCont]))
		_cAliasSX3 := "SX3_"+GetNextAlias()
		OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
		dbSelectArea(_cAliasSX3)
		(_cAliasSX3)->(dbSetOrder(1))
		If (_cAliasSX3)->(MsSeek("SE1",.T.,.F.))
			While !(_cAliasSX3)->(EOF()) .AND. (_cAliasSX3)->X3_ARQUIVO == "SE1"
				If (_cAliasSX3)->X3_CONTEXT <> "V";
					.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_SALDO"  	;
					.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_VALOR"  	;
					.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_VENCTO" 	;
					.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_VENCREA"	;
					.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_PREFIXO"	;
					.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_SERIE"  	;
					.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_NUM"    	;
					.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_PARCELA"	;
					.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_REMONTA"	;
					.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_FILIAL"	;
					.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_VLCRUZ"	;
					.And. AllTrim((_cAliasSX3)->X3_CAMPO)<>"E1_TIPO"		;
					.And. aScan(_aCpoSom,AllTrim((_cAliasSX3)->X3_CAMPO))<=0
					
					AADD(_aCampos, {AllTrim((_cAliasSX3)->X3_CAMPO), SE1->&((_cAliasSX3)->X3_CAMPO)})
				EndIf
				dbSelectArea(_cAliasSX3)
				(_cAliasSX3)->(dbSetOrder(1))
				(_cAliasSX3)->(dbSkip())
			EndDo
		EndIf
		
		If _nCont <= _nParcZZ
			//Verifica se ้ a ๚ltima parcela para eliminar a possํvel diferen็a de valor por conta de arredondamentos
			If _nParcZZ == _nCont
				AADD(_aCampos, {"E1_SALDO"	, _nTotal2-(_nVlrZZ*(_nCont-1)) 		})
				AADD(_aCampos, {"E1_VALOR"	, _nTotal2-(_nVlrZZ*(_nCont-1)) 		})
				AADD(_aCampos, {"E1_VLCRUZ"	, _nTotal2-(_nVlrZZ*(_nCont-1)) 		})
			Else
				AADD(_aCampos, {"E1_SALDO"	, _nVlrZZ 								})
				AADD(_aCampos, {"E1_VALOR"	, _nVlrZZ 								})
				AADD(_aCampos, {"E1_VLCRUZ"	, _nVlrZZ 								})
			EndIf
			AADD(_aCampos, {"E1_NUM"		, _cNumeZZ								})
			AADD(_aCampos, {"E1_PREFIXO"	, _cPrefZZ								})
			AADD(_aCampos, {"E1_SERIE"		, _cPrefZZ								})
			AADD(_aCampos, {"E1_PARCELA"	, AllTrim(Str(_nNumPZZ))				})
			AADD(_aCampos, {"E1_VENCTO"		, STOD(_aVencim[_nCont][1])				})
			AADD(_aCampos, {"E1_VENCREA"	, STOD(_aVencim[_nCont][2])				})
			AADD(_aCampos, {"E1_REMONTA"	, 'N'									})
			For _nCont1:= 1 To Len(_aCpoSom)
				AADD(_aCampos, {_aCpoSom[_nCont1], ((_aValorN[_nCont1])/(_nParcZZ))})
			Next
			_nNumPZZ++
		ElseIf _nCont-_nParcZZ <= _nParcNF
			//Verifica se ้ a ๚ltima parcela para eliminar a possํvel diferen็a de valor por conta de arredondamentos
			If (_nParcZZ + _nParcNF) == _nCont
				AADD(_aCampos, {"E1_SALDO"	, _nTotal1-(_nVlrNF*(_nCont-1-_nParcZZ))})
				AADD(_aCampos, {"E1_VALOR"	, _nTotal1-(_nVlrNF*(_nCont-1-_nParcZZ))})
				AADD(_aCampos, {"E1_VLCRUZ"	, _nTotal1-(_nVlrNF*(_nCont-1-_nParcZZ))})
			Else
				AADD(_aCampos, {"E1_SALDO"	, _nVlrNF 								})
				AADD(_aCampos, {"E1_VALOR"	, _nVlrNF 								})
				AADD(_aCampos, {"E1_VLCRUZ"	, _nVlrNF 								})
			EndIf
			AADD(_aCampos, {"E1_NUM"		, _cNumeNF								})
			AADD(_aCampos, {"E1_PREFIXO"	, _cPrefNF								})
			AADD(_aCampos, {"E1_SERIE"		, _cPrefNF								})
			AADD(_aCampos, {"E1_PARCELA"	, AllTrim(Str(_nNumPNF))				})
			AADD(_aCampos, {"E1_VENCTO"		, STOD(_aVencim[_nCont][1])				})
			AADD(_aCampos, {"E1_VENCREA"	, STOD(_aVencim[_nCont][2])				})
			AADD(_aCampos, {"E1_REMONTA"	, 'N'									})
			For _nCont1:= 1 To Len(_aCpoSom)
				AADD(_aCampos, {_aCpoSom[_nCont1], ((_aValorZ[_nCont1])/(_nParcNF))	})
			Next
			_nNumPNF++
		EndIf
		while !RecLock("SE1",.F.) ; enddo
			Delete
		SE1->(MsUnLock())
		//CUSTOM. ALL - DATA: 18/06/2015 - INอCIO - AUTOR: JฺLIO SOARES
		// - Trecho inserido para validar se o processo passou pela remontagem de parcelas.
		// - (NHR) - Nใo Houve Remontagem
		// - (RPF) - Remontagem Parcela Finalizado
		// - Trecho inserido para inserir valida็ใo de seguran็a para a remontagem de parcelas
		dbSelectArea("SF2")
		SF2->(dbSetOrder(1))
		If SF2->(MsSeek(xFilial("SF2") + SE1->(E1_NUM) + SE1->(E1_PREFIXO),.T.,.F.))
			If SF2->(FieldPos("F2_REMPARC"))>0
				If SF2->F2_REMPARC == "NHR"
					while !RecLock("SF2",.F.) ; enddo
						SF2->F2_REMPARC := "RPF"
					SF2->(MsUnLock())
				EndIf
			Else
				MSGBOX("O campo F2_REMPARC nใo existe no banco de dados. INFORME O ADMINISTRADOR DO SISTEMA",_cRotina + "_001","STOP")
			EndIf
		EndIf
		//CUSTOM. ALL - DATA: 18/06/2015 - FIM - AUTOR: JฺLIO SOARES
		//RestArea(_aSavSE1)
		If _nCont <= ((Len(_aDeletar)+1)/2)
			while !RecLock("SE1",.T.) ; enddo
				SE1->E1_FILIAL 	:= xFilial("SE1")
				SE1->E1_TIPO	:= "NF"
				For _nPos := 1 To Len(_aCampos)
					&(_aCampos[_nPos][1]) := _aCampos[_nPos][2]
				Next
			SE1->(MsUnLock())
		EndIf
	Next
	Deletar()
	_aDeletar := {}
return