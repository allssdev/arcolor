#include "rwmake.ch"
#include "ap5mail.ch"
#include "topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "PROTHEUS.CH"
#include "MSGRAPHI.CH" 
#include 'topconn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"                           
#INCLUDE "JPEG.CH"
#INCLUDE "AVPRINT.CH"
#INCLUDE "FONT.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "VKEY.CH"  
/*/{Protheus.doc} FACDC001
@description Classe de divisão do faturamento entre a Arcolor e a BColor.
@author      Fernando Bombardi (ALL System Solutions)
@since       17/10/2018
@version     1.0
@see         https://allss.com.br
/*/
class FACDC001
	method new() constructor
	method DivideFaturamento()
	method AnalisarProduto()
	method EstornarPedido()
	method LiberarPedido()
	method CriarPedido()
	method AjustarPedido()
endclass
/*/{Protheus.doc} new
@description Metodo construtor
@author      Fernando Bombardi (ALL System Solutions)
@since       17/10/2018
@version     1.0
@see         https://allss.com.br
/*/
method new() class FACDC001
return
/*/{Protheus.doc} DivideFaturamento
@description Metodo para divisao do faturamento para Produtos A e B
@author      Fernando Bombardi (ALL System Solutions)
@since       17/10/2018
@version     1.0
@see         https://allss.com.br
/*/
method DivideFaturamento(_cCb7Ped) class FACDC001
	if ::AnalisarProduto(_cCb7Ped)
		if ::EstornarPedido(_cCb7Ped)
			if ::CriarPedido(_cCb7Ped)
				::LiberarPedido(_cCb7Ped)
			endif
		endif
	endif
return
/*/{Protheus.doc} AnalisarProduto
@description Metodo para verificar se o pedido de venda possui Produtos A e B
@author      Fernando Bombardi (ALL System Solutions)
@since       17/10/2018
@version     1.0
@see         https://allss.com.br
/*/
method AnalisarProduto(_cCb7Ped) class FACDC001
	local _lRet   := .F.
	local _aArea  := GetArea()
	local _cPRODB := GetNextAlias()

	if Select(_cPRODB) > 0
		(_cPRODB)->(dbCloseArea())
	endif
	BeginSql Alias _cPRODB
		SELECT B1_XPROPRI
		FROM %table:SC6% SC6 (NOLOCK)
			INNER JOIN %table:SB1% SB1 (NOLOCK) ON B1_FILIAL = %xFilial:SB1% AND B1_XPROPRI = 'B' AND C6_PRODUTO = B1_COD AND SB1.%NotDel%
		WHERE C6_FILIAL = %xFilial:SC6%
		  AND C6_NUM        = %Exp:_cCb7Ped%			  
		  AND C6_NOTA       = ''
		  AND SC6.%NotDel%
	EndSql
	dbSelectArea(_cPRODB)
	if !(_cPRODB)->(EOF())
		_lRet := .T.
	endif
	if Select(_cPRODB) > 0
		(_cPRODB)->(dbCloseArea())
	endif
	RestArea(_aArea)
return _lRet
/*/{Protheus.doc} EstornarPedido
@description Metodo para estornar o pedido de venda para separacao de produtos A e B.
@author      Fernando Bombardi (ALL System Solutions)
@since       17/10/2018
@version     1.0
@see         https://allss.com.br
/*/
/*/
method EstornarPedido(_cCb7Ped) class FACDC001
local cAlias     := "SC5"
local _cQry      := ""
local _cFunNBkp  := FunName()

	SetFunName("MATA410")
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	SC5->(dbGoTop())
	if dbSeek(XFILIAL("SC5")+_cCb7Ped)
		MaAvalSC5("SC5",4)
		MaAvalSC5("SC5",9)
		if SoftLock(cAlias)
			Begin Transaction
					DbSelectArea("SC9")
					SC9->(DbSetOrder(1))
					SC9->(MsSeek(xFilial("SC5") + SC5->C5_NUM, .T., .F.))
					while SC9->(!Eof()) .AND. SC9->C9_FILIAL == xFilial("SC5") .AND. SC9->C9_PEDIDO == SC5->C5_NUM
			    		SC9->(A460Estorna(.T.,.T.))
			    		SC9->(DbSkip())
			    	enddo
			End Transaction
		endif
	endif

	SetFunName(_cFunNBkp)

return(.T.)
*/
/*/{Protheus.doc} CriarPedido
@description Metodo para criar novo pedido de venda com os produtos A B.
@author      Fernando Bombardi (ALL System Solutions)
@since       22/10/2018
@version     1.0
@see         https://allss.com.br
/*/
method CriarPedido(_cCb7Ped) class FACDC001
	local   _aArea     := GetArea()
	local   _lRet      := .T.
	local   _cTabPV    := GetNextAlias()
	local   _cAliasSX3 := "SX3_"+GetNextAlias()

	private _cPathErr := "\divisao\erro\"

	if Select(_cTabPV)
		(_cTabPV)->(dbCloseArea())
	endif
	BeginSql Alias _cTabPV
		SELECT *, SC6.R_E_C_N_O_ AS C6_RECNO
		FROM %table:SC6% SC6 (NOLOCK)
			INNER JOIN %table:SC5% SC5 (NOLOCK) ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM AND SC5.%NotDel%
			INNER JOIN %table:SB1% SB1 (NOLOCK)	ON B1_FILIAL = %xFilial% AND B1_XPROPRI = 'B' AND B1_COD = C6_PRODUTO AND SB1.%NotDel%
		WHERE SC6.C6_FILIAL = %xFilial:SC6%
		  AND SC6.C6_NUM    = %Exp:_cCb7Ped%			  
		  AND SC6.C6_NOTA   = %Exp:''%
		  AND SC6.%NotDel%
	EndSql
	dbSelectArea(_cTabPV)
	if !(_cTabPV)->(EOF())
		if Select(_cAliasSX3) > 0
			(_cAliasSX3)->(dbCloseArea())
		endif
		OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
		dbSelectArea(_cAliasSX3)
		(_cAliasSX3)->(dbSetOrder(1))
		_aCabC5 := {}
		_aCab   := {}    
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		SC5->(MsSeek(xFilial("SC5")+_cCb7Ped,.T.,.F.))
		/*
		_aCabC5 := {{"C5_FILIAL",xFilial("SC5")	,nil},;
					{"C5_NUM"    ,"999999"        		,nil},; // Nro.do Pedido
					{"C5_TIPO"   ,'C'          			,nil},; //Tipo de Pedido
					{"C5_CLIENTE",SC5->C5_CLIENTE		,nil},; //Cod. Cliente
					{"C5_LOJACLI",SC5->C5_LOJACLI		,nil},; //Loja Cliente
					{"C5_CLIENT" ,SC5->C5_CLIENTE		,nil},; //Cod. Cliente
					{"C5_LOJAENT",SC5->C5_LOJACLI 		,nil},; //Loja Cliente
					{"C5_TRANSP",SPACE(6)       		,nil},;	
					{"C5_CONDPAG",SC5->C5_CONDPAG 		,nil}}
		*/
		(_cAliasSX3)->(dbSetOrder(1))
		(_cAliasSX3)->(dbGoTop())
		if (_cAliasSX3)->(MsSeek("SC5"))
			while !(_cAliasSX3)->(EOF()) .AND. AllTrim((_cAliasSX3)->X3_ARQUIVO) == "SC5"
				if AllTrim((_cAliasSX3)->X3_CAMPO) $ ("C5_NUM/C5_OBSSEP/C5_OBSER/C5_OBSBLQ") .OR. (_cAliasSX3)->X3_TIPO == "M"
					(_cAliasSX3)->(dbSkip())
					loop
				endif
				if ALLTRIM((_cAliasSX3)->X3_CAMPO) $ ALLTRIM("C5_TIPLIB/C5_SLENVT")
					AADD(_aCab,{(_cAliasSX3)->X3_CAMPO,"2",NIL})
					(_cAliasSX3)->(dbSkip())
					loop
				endif
				if ALLTRIM((_cAliasSX3)->X3_CAMPO) $ ALLTRIM("C5_VENDRES/C5_RET20G")
					AADD(_aCab,{(_cAliasSX3)->X3_CAMPO,"N",NIL})
					(_cAliasSX3)->(dbSkip())
					loop
				endif								
				if AllTrim((_cAliasSX3)->X3_CONTEXT) <> "V" .AND. X3USO(X3_USADO) .AND. cNivel >= (_cAliasSX3)->X3_NIVEL
					AADD(_aCab,{(_cAliasSX3)->X3_CAMPO,&("SC5->"+AllTrim((_cAliasSX3)->X3_CAMPO)),NIL})
				endif
				(_cAliasSX3)->(dbSetOrder(1))
				(_cAliasSX3)->(dbSkip())
			enddo
		endif
		//AADD(_aCabC5,_aCab)
		_aItC6 := {}
		_nCtItem := 0
		while !(_cTabPV)->(EOF())
			_nCtItem++
			dbSelectArea("SC6")
			SC6->(dbSetOrder(1))
			SC6->(dbGoTo((_cTabPV)->C6_RECNO))
			_aItens := {}
			aadd(_aItens,{"C6_ITEM",StrZero(_nCtItem,2),Nil})
			(_cAliasSX3)->(dbSetOrder(1))
			if (_cAliasSX3)->(MsSeek("SC6"))
				while !(_cAliasSX3)->(EOF()) .AND. AllTrim((_cAliasSX3)->X3_ARQUIVO) == "SC6"
					if AllTrim((_cAliasSX3)->X3_CAMPO) $ "C6_ALMTERC/C6_VDMOST/C6_CODFAB/C6_LOJAFA/C6_BLQ/C6_IPIDEV/C6_NUM/C6_ITEM/C6_QTDENT2/C6_UNSVEN/C6_QTDLIB2/C6_LOCALIZ/C6_SEGUM/C6_VALOR" .OR.;
					 (_cAliasSX3)->X3_TIPO == "M" .OR. (_cAliasSX3)->X3_VISUAL == "V"
						(_cAliasSX3)->(dbSkip())
						loop
					endif
					if AllTrim((_cAliasSX3)->X3_CAMPO) == "C6_PRUNIT"
						AADD(_aItens,{(_cAliasSX3)->X3_CAMPO,SC6->C6_PRCVEN,NIL})
						(_cAliasSX3)->(dbSkip())
						loop
					endif
					/*
					if AllTrim((_cAliasSX3)->X3_CAMPO) == "C6_VALOR"
						AADD(_aItens,{(_cAliasSX3)->X3_CAMPO,NoRound(SC6->C6_PRCVEN * SC6->C6_QTDVEN, 2),NIL})
						(_cAliasSX3)->(dbSkip())
						loop
					endif
					*/
					if AllTrim((_cAliasSX3)->X3_CONTEXT) <> "V" .AND. X3USO(X3_USADO) .AND. cNivel >= (_cAliasSX3)->X3_NIVEL
						AADD(_aItens,{(_cAliasSX3)->X3_CAMPO,&("SC6->"+AllTrim((_cAliasSX3)->X3_CAMPO)),NIL})
					endif
					(_cAliasSX3)->(dbSetOrder(1))
					(_cAliasSX3)->(dbSkip())
				enddo
			endif
			AADD(_aItC6,_aItens)
			dbSelectArea(_cTabPV)
			(_cTabPV)->(dbSkip())
		enddo
		if Select(_cTabPV) > 0
			(_cTabPV)->(dbCloseArea())
		endif
		if Select(_cAliasSX3) > 0
			(_cAliasSX3)->(dbCloseArea())
		endif
		if len(_aCab) > 0 .AND. len(_aItC) > 0
			PREPARE ENVIRONMENT EMPRESA "01" FILIAL "02" MODULO "FAT" TABLES "SC5","SC6","SA1","SA2","SB1","SB2","SF4"
				lMsErroAuto := .F.
				MSExecAuto({|x,y,z|mata410(x,y,z)},_aCab,_aItC6,3)
				if !lMsErroAuto
					if !::LiberarPedido(SC5->C5_NUM)
						_lRet := .F.
					endif
				else
					MostraErro(_cPathErr,_cCb7Ped+"_"+DTOS(dDatabase)+"_"+StrTran(Time(),":","")+".log")
					_lRet := .F.
				endif
			RESET ENVIRONMENT
		
			PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "FAT" TABLES "SC5","SC6","SA1","SA2","SB1","SB2","SF4"
		endif
		RestArea(_aArea)
		if !_lRet //Erro geracao novo pedido d evenda
			if !::AjustarPedido(_cCb7Ped) 
				_lRet := .F. //Erro Ajuste do pedido de venda
			endif
		endif
	endif
return _lRet
/*/{Protheus.doc} AjustarPedido
@description Metodo para ajustar o pedido de venda original com os produtos A.
@author      Fernando Bombardi (ALL System Solutions)
@since       22/10/2018
@version     1.0
@see         https://allss.com.br
/*/
method AjustarPedido(_cCb7Ped) class FACDC001
	local _lRet := .T.
	Begin Transaction
		_CQrySC6    := " DELETE " + RetSqlName("SC6") + " SC6 INNER JOIN "+ RetSqlName("SB1") +" SB1 "
		_CQrySC6    += " ON C6_FILIAL = B1_FILIAL AND C6_PRODUTO = B1_COD "	 
		_CQrySC6    += " WHERE SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
		_CQrySC6    += "   AND SC6.C6_NUM = '" + _cCb7Ped + "' "
		_CQrySC6    += "   AND SC6.C6_NOTA = '' "
		_CQrySC6    += "   AND SC6.D_E_L_E_T_ = '' "
		_CQrySC6    += "   AND B1_XPROPRI = 'B' " 
		_CQrySC6    += "   AND SB1.D_E_L_E_T_ = '' "
		if TCSQLExec(_CQrySC6) < 0
			//MsgAlert("Problemas para voltar o status da ordem de separação!",_cRotina+"_002")
			_lRet := .F.
			DisarmTransaction()
			break
		endif
		TcRefresh("SC6")
	End Transaction
return _lRet
/*/{Protheus.doc} EstornarPedido
@description Metodo para liberar o pedido de venda para separacao de produtos A e B.
@author      Fernando Bombardi (ALL System Solutions)
@since       22/10/2018
@version     1.0
@see         https://allss.com.br
/*/
method LiberarPedido() class FACDC001
	local _lRet := .T.

	dbSelectArea("SC6")
	SC6->(dbSetOrder(1))
	SC6->(MsSeek(xFilial("SC6") + cNumPed,.T.,.F.))
	nValTot := 0
	while !SC6->(EOF()) .AND. SC6->C6_NUM == cNumPed .AND. SC6->C6_FILIAL == xFilial("SC6")
		nValTot += SC6->C6_VALOR
		dbSelectArea("SF4")
		SF4->(dBSetOrder(1))
		SF4->(MsSeek( xFilial("SF4") + SC6->C6_TES,.T.,.F.))
		if RecLock("SC5")
			nQtdLib := SC6->C6_QTDLIB
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Recalcula a Quantidade Liberada                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("SC6") //Forca a atualizacao do Buffer no Top
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Libera por Item de Pedido                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Begin Transaction
				MaLibDoFat(SC6->(RecNo()),@nQtdLib,.F.,.T.,.F.,.T.,.F.,.F.)
	          End Transaction
	     endif
	     SC6->(MsUnLock())
	     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	     //³Atualiza o Flag do Pedido de Venda                                      ³
	     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	     Begin Transaction
	     	SC6->(MaLiberOk({cNumPed},.F.))
	     End Transaction
	     dbSelectArea("SC6")
	     SC6->(dbSkip())
	enddo
	SC6->(dbCloseArea())
return