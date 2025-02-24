#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE _lEnt CHR(13) + CHR (10)
/*/{Protheus.doc} MT410ACE
@decription Ponto de Entrada para validação de alteração do pedido de vendas.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 21/03/2013
@version 1.0
@type function
@return _lRet, lógico, Permite (.T.) a edição do pedido de vendas ou não (.F.).
@history 22/10/2019, Anderson C. P. Coelho (ALL System Solutions), Retirado o lock customizado do registro que minimizava os riscos na liberação dos pedidos de vendas pois, conforme relatado pela consultora Lívia, o risco foi praticamente eliminado pós migração do release P12.1.17 para o P12.1.25.
@see https://allss.com.br
/*/
user function MT410ACE()
	local _aSavArea := GetArea()
	local _aSavSC9  := SC9->(GetArea())//iif( FunName()<>"MATA030",SC9->(GetArea()),)
	local _aSavSC5  := SC5->(GetArea())//iif( FunName()<>"MATA030",SC5->(GetArea()),)
	local _aSavCB8  := CB8->(GetArea())//iif( FunName()<>"MATA030",CB8->(GetArea()),)
	local _aSavCB7  := CB7->(GetArea())//iif( FunName()<>"MATA030",CB7->(GetArea()),)
//	local _nPVerRn  := aScan(aHeader,{|x|AllTrim(x[02])=="C6_VERIFRN"}) //Linha comentada por Adriano Leonardo em 31/07/13 para correção
	local _lRet     := .T.
	local _cLogx    := ""
//	local _cRotina  := "MT410ACE"
//	local _cLockR   := "PEDIDO_"+SC5->C5_NUM+"_"+DTOS(Date())
	local _cLog     := ""
	local  nOpc     := iif( FunName()<>"MATA030",iif(altera,3,iif(inclui,4,99)),99)
	local _cCSC9    := GetNextAlias()
	if nOpc == 3 .OR. nOpc == 4
/*
		if !MayIUseCode(_cLockR,__cUserId) 		//!LockByName(_cLockR,.T.,.T.)		//Bloqueio realizado pelos P.E.s MA440VLD e MT410ACE e Desbloqueio realizado pelos P.E.s M440STTS e M410STTS
			_lRet := .F.
			MsgAlert("A rotina está sendo executada por outro usuário!",_cRotina+"_001")
			return _lRet
		endif
*/
		if Select(_cCSC9) > 0
			(_cCSC9)->(dbCloseArea())
		endif
		BeginSql Alias _cCSC9
			SELECT COUNT(*) CONTSC9, C9_ORDSEP
			FROM %table:SC9% SC9 (NOLOCK)
			WHERE SC9.C9_FILIAL   = %xFilial:SC9%
			  AND SC9.C9_PEDIDO   = %Exp:SC5->C5_NUM%
			  AND SC9.C9_BLEST    = ''
			  AND SC9.C9_BLCRED   = ''
			  AND SC9.C9_BLOQUEI  = ''
			  AND SC9.%NotDel%
			GROUP BY C9_ORDSEP
		EndSql
		dbSelectArea(_cCSC9)
		if (_cCSC9)->CONTSC9 > 0
			CB7->(dbSetOrder(2))
			if CB7->(dbSeek(xFilial("CB7") + SC5->C5_NUM)) .AND. !empty((_cCSC9)->C9_ORDSEP)
				//Conteúdo do Status: "0-Inicio;1-Separando;2-Sep.Final;3-Embalando;4-Emb.Final;5-Gera Nota;6-Imp.nota;7-Imp.Vol;8-Embarcado;9-Embarque Finalizado"
				_lRet  :=  .F. //AllTrim(CB7->CB7_STATUS) <= "1" //Trecho comentado por Adriano Leonardo em 20/09/2013 para correcao
				_cLogx := "Ordem de Separação já gerada!"
			else
				dbSelectArea("CB8")
				CB8->(dbSetOrder(2))
				If CB8->(MsSeek(xFilial("CB8") + SC5->C5_NUM,.T.,.F.))
					while !CB8->(EOF()) .AND. _lRet .AND. CB8->CB8_FILIAL == xFilial("CB8") .AND. CB8->CB8_PEDIDO == SC5->C5_NUM
						dbSelectArea("CB7")
						CB7->(dbSetOrder(1))
						If CB7->(MsSeek(xFilial("CB7") + CB8->CB8_ORDSEP,.T.,.F.)) .AND. !empty((_cCSC9)->C9_ORDSEP)
							//Conteúdo do Status: "0-Inicio;1-Separando;2-Sep.Final;3-Embalando;4-Emb.Final;5-Gera Nota;6-Imp.nota;7-Imp.Vol;8-Embarcado;9-Embarque Finalizado"
							_lRet  := .F. //AllTrim(CB7->CB7_STATUS) <= "1" //Trecho comentado por Adriano Leonardo em 20/09/2013 para correcao
							_cLogx := "Ordem de Separação já gerada!"
						endif
						dbSelectArea("CB8")
						CB8->(dbSetOrder(2))
						CB8->(dbSkip())
					enddo
				endif
			endif
			/*
			if !_lRet .AND. AllTrim(__cUserId) <> "000000"
				_cLogx := "Não é possível alterar este pedido de vendas! " + _cLogx
				MsgAlert(_cLogx, _cRotina + "_002")
			else
				_lRet := .T.
			endif
			*/
		endif
		if Select(_cCSC9) > 0
			(_cCSC9)->(dbCloseArea())
		endif
	endif
	//Trecho inserido por Júlio Soares em 01/11/2013 para adaptações no campo de observações de log de processos para o Callcenter.
	if _lRet .AND. ( nOpc == 3 .OR. nOpc == 4) //.AND. AllTrim(__cUserId) <> '000000'
		if !empty(_cLogx)
			_cLogx += " / "
		endif
		_cLogx += "Pedido Alterado."
		dbSelectArea("SUA")
		SUA->(dbOrderNickName("UA_NUMSC5"))
		If SUA->(FieldPos("UA_LOGSTAT")) > 0 .AND. SUA->(MsSeek(xFilial("SUA") + SC5->C5_NUM,.T.,.F.))
			_cLog := Alltrim(SUA->UA_LOGSTAT)
			while !RecLock("SUA",.F.) ; enddo
				SUA->UA_LOGSTAT :=	_cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " + UsrRetName(__cUserId) + ;
									_lEnt + _cLogx
			SUA->(MsUnLock())
		endif
		// - Inserido em 24/03/2014 por Júlio Soares para gravar status também no quadro de vendas.
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		if SC5->(FieldPos("C5_LOGSTAT")) > 0 //.AND. SC5->(dbSeek(xFilial("SC5") + SC5->C5_NUM))
			_cLog := Alltrim(SC5->C5_LOGSTAT)
			while !RecLock("SC5",.F.) ; enddo
				SC5->C5_LOGSTAT :=	_cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " + UsrRetName(__cUserId) + ;
									_lEnt + _cLogx
			SC5->(MsUnLock())
		endif
	endif
	//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
	/*
	If (INCLUI .OR. ALTERA) .AND. ExistBlock("RFATL001")
		U_RFATL001(	SC5->C5_NUM  ,;
					,;
					_cLogx     ,;
					_cRotina    )
	endif
	*/
	RestArea(_aSavSC9)
	RestArea(_aSavSC5)
	RestArea(_aSavCB7)
	RestArea(_aSavCB8)
	RestArea(_aSavArea)
return _lRet