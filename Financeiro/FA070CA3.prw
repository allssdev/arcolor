#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} FA070CA3
@description Ponto de Entrada utilizado. para validar se será possível excluir/cancelar a baixa do título a receber. Está sendo utilizado aqui para não permitir esta operação, caso o eventual título "NCC" gerado automaticamente com base neste tiver sido utilizado. Vide o Ponto de Entrada "SACI008".
@author Eduardo M Antunes (ALL System Solutions)
@since 27/09/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
user function FA070CA3()
	Local   _aSavArea    := GetArea()
	Local   _aSavSE1     := SE1->(GetArea()) 
	Local   _aSavFIE     := FIE->(GetArea()) 
	Local   _aSavSZH     := SZH->(GetArea()) 
	Local   _aArray      := {}
	Local   _cAlias      := "SE1"
	Local 	_cRotina     := "FA070CA3"
	Local   _cCliente    := SE1->E1_CLIENTE
	Local   _cLoja		 := SE1->E1_LOJA  
	Local   _cPrefixo    := SE1->E1_PREFIXO
	Local  	_cNum        := SE1->E1_NUM
	Local  	_cParcNCC    := SE1->E1_PARCELA
	Local  	_cTipo       := AllTrim(SuperGetMv("MV_TIPOPG" ,,"BOL"))
	Local  	_lRet 		 := .T.
	Private lMsErroAuto  := .F.
	If AllTrim(SE1->E1_TIPO) == _cTipo
		BeginSql Alias "QTEMPARQ"
			SELECT TOP 1 *
			FROM (
						SELECT FIE_FILIAL,FIE_CART
						FROM %Table:FIE% FIE (NOLOCK)
						WHERE	    FIE.FIE_FILIAL = %xFilial:FIE%
								AND FIE.FIE_CART   = %Exp:'R'%
								AND FIE.FIE_NUM    = %Exp:_cNum% 
								AND FIE.FIE_TIPO   = %Exp:'NCC'%     
								AND FIE.FIE_PREFIX = %Exp:_cPrefixo%   
								AND FIE.FIE_PARCEL = %Exp:_cParcNCC%   
						        AND FIE.FIE_CLIENT = %Exp:_cCliente% 
						 		AND FIE.FIE_LOJA   = %Exp:_cLoja% 
								AND FIE.%notdel%
					UNION ALL
						SELECT ZH_FILIAL,ZH_CART
						FROM %Table:SZH% SZH (NOLOCK)
						WHERE	    SZH.ZH_FILIAL  = %xFilial:SZH%
								AND SZH.ZH_CART    = %Exp:'R'%
								AND SZH.ZH_NUM     = %Exp:_cNum%  	 
								AND SZH.ZH_TIPO    = %Exp:'NCC'%        
								AND SZH.ZH_PREFIX  = %Exp:_cPrefixo%   
								AND SZH.ZH_PARCEL  = %Exp:_cParcNCC%   
						     	AND SZH.ZH_CLIENT  = %Exp:_cCliente% 
								AND SZH.ZH_LOJA    = %Exp:_cLoja% 
								AND SZH.%notdel%
				) XXX
		EndSql
		If __cUserId == "000000"
			MemoWrite(GetTempPath()+_cRotina+"_001.txt",GetLastQuery()[02])
		EndIf
		dbSelectArea("QTEMPARQ")
		If !Empty(QTEMPARQ->REG)
			dbSelectArea("SE1")
			SE1->(dbSetOrder(1))
			If SE1->(dbSeek(xFilial("SE1")+_cPrefixo+_cNum+_cParcNCC+"NCC"+_cCliente+_cLoja))
				If SE1->E1_SALDO < SE1->E1_VLCRUZ
					MsgStop("Atenção! Existe um 'NCC' vinculado a este título que já sofreu algum tipo de compensação e/ou baixa. Para excluir a sua baixa, ele não poderá estar vinculado a algum pedido de vendas e/ou não poderá ter sofrido alguma baixa. Regularize isto antes de prosseguir com o estorno/cancelamento da baixa deste título a receber!",_cRotina+"_001")
					_lRet := .F.
				Else
					_aArray := { { "E1_FILIAL"	, SE1->E1_FILIAL                , NIL },;
								 { "E1_PREFIXO"	, SE1->E1_PREFIXO               , NIL },;
								 { "E1_NUM"      , SE1->E1_NUM           		, NIL },;  
								 { "E1_PARCELA"  , _cParcNCC	        		, NIL },;  
								 { "E1_TIPO"     , "NCC"             			, NIL },;
								 { "E1_CLIENTE"  , SE1->E1_CLIENTE 			   	, NIL },;
								 { "E1_LOJA"     , SE1->E1_LOJA  			   	, NIL } }
					MsExecAuto(  { |x,y| FINA040(x,y)} , aArray, 5)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
					If lMsErroAuto
						MsgInfo("Atenção! Problemas na tentativa de eliminação do título 'NCC' vinculado a este registro. Verifique os motivos a seguir e proceda a esta eliminação manualmente, se for o caso!",_cRotina+"_003")
						MostraErro()
					Else
						MsgInfo("Atenção! O 'NCC' vinculado a este título foi eliminado com sucesso!",_cRotina+"_004")
					EndIf
			   EndIf
			EndIf
		Else
			MsgStop("Atenção! Existe um 'NCC' vinculado a um pedido de vendas deste cliente. Para estornar/cancelar a sua baixa, ele não poderá estar vinculado a algum pedido de vendas e/ou não poderá ter sofrido alguma compensação ou baixa. Regularize isto antes de prosseguir!",_cRotina+"_003")
			_lRet := .F.
		EndIf
		dbSelectArea("QTEMPARQ")
		QTEMPARQ->(dbCloseArea())
	EndIf		
	RestArea(_aSavFIE)
	RestArea(_aSavSZH)
	RestArea(_aSavSE1)
	RestArea(_aSavArea)
return _lRet