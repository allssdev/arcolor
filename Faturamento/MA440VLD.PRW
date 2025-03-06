#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE _lEnt CHR(13)+CHR(10)
/*/{Protheus.doc} MA440VLD
@description Ponto de entrada utilizado para validar a liberação do pedido de venda.
@author Adriano Leonardo
@since 13/12/2012
@history 17/03/2014, Júlio Soares, Inserido trecho para atualização do status de log para acompanhamento do Call-center quando esse é liberado para faturamento.
@version 1.0
@return _lRet, lógico, Permite (.T.) ou não (.F.) a liberação do pedido de vendas.
@type function
@history 22/10/2019, Anderson C. P. Coelho (ALL System Solutions), Retirado o lock customizado do registro que minimizava os riscos na liberação dos pedidos de vendas pois, conforme relatado pela consultora Lívia, o risco foi praticamente eliminado pós migração do release P12.1.17 para o P12.1.25.
@see https://allss.com.br
/*/
user function MA440VLD()
	local _aSavArea  := GetArea()
	local _aSavSC5   := SC5->(GetArea())
	local _aSavSC6   := SC6->(GetArea())
	local _aSavSC9   := SC9->(GetArea())
	local _lRet      := .T.
	local _x         := 0
	local _nPQtLib   := aScan(aHeader,{|x|AllTrim(x[02])=="C6_QTDLIB"})
	local _cLogx     := ""
	Local _CodPrd := ""

	private cPergOri
	private _cRotina := "MA440VLD"
	private lLock   := .F.			
	private _cLog    := ""
	private _cLogp	 := ""
	private _cLockR  := "PEDIDO_"+SC5->C5_NUM
	public _lRetVld  := .F.

	lLock:= LockByName(_cLockR,.T.,.T.)		

	if lLock 	
		Pergunte("MTA440",.F.)
		lLiber := MV_PAR02 == 1
		

		//27/10/2014 (Anderson Coelho) - Trecho utilizado para reajustar as quantidades liberadas, conformeo máximo possível, uma vez que o sistema apresentou duas falhas:
		//             1) A primeira é que a rotina A440LIBERA foi utilizada em outro ponto no sistema (no menu da rotina MATA410) e, com isso, quando o usuário liberava o pedido mais de uma vez, o sistema duplicava a liberação na SC9.
		//             2) O sistema não reconheceu o Ponto de Entrada MT440LIB, que poderia ter sido utilizado para esta correção.
		for _x := 1 to len(aCols)
			if !aCols[_x][Len(aHeader)+1] .AND. aCols[_x][Len(aHeader)] > 0
				dbSelectArea("SC6")
				SC6->(dbGoTo(aCols[_x][Len(aHeader)]))	//A última coluna do aCols se refere ao Recno na SC6
				if aCols[_x ][_nPQtLib]  > (SC6->C6_QTDVEN - ( SC6->C6_QTDEMP + SC6->C6_QTDENT)) 
					aCols[_x][_nPQtLib] := (SC6->C6_QTDVEN - ( SC6->C6_QTDEMP + SC6->C6_QTDENT))
				endif				
			endif
		  /*If SC6->C6_COMIS1 <= 0 //Em validação
				_lRet:= .F.
				_CodPrd +=  SC6->C6_PRODUTO  + " - " 
			EndIf*/
		next
						
		//Verifica se pedido está bloqueado (campo customizado)
		if !_lRet
			MsgStop("Pedido não foi Liberado. Produto(s): "+ _CodPrd + " sem REGRA DE COMISSAO!",_cRotina+"_01")
		endif
		
		//Chama a rotina de validação do pedido de vendas*
		if ExistBlock("RFATE002") .and.  _lRet
			_lRet := U_RFATE002(.T.,"")
		endif
        
        If !_lRet
        	MsgStop("Pedido não está apto a Liberação!",_cRotina+"_02")
        EndIf

		//  - Trecho inserido por Júlio Soares em 25/10/2013 para implementar a inclusão de log de registro para liberação do pedido
		if _lRet
			_cLogx := "Pedido liberado para avaliação de crédito."
		//	_lRetVld := .T.		//Trecho desativado em 22/01/2015, sendo substituido pela chamada da rotina "MT410INC()" abaixo
			if ExistBlock("MT410INC")
				ExecBlock("MT410INC")
			endif
			dbSelectArea('SUA')
			SUA->(dbOrderNickName("UA_NUMSC5"))
			if SUA->(MsSeek(xFilial("SUA") + SC5->C5_NUM,.T.,.F.))
				if SUA->(FieldPos("UA_LOGSTAT"))<>0
					_cLog := Alltrim(SUA->UA_LOGSTAT)
					while !RecLock("SUA",.F.) ; enddo
			    		SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " + UsrRetName(__cUserId) +;
			    							_lEnt + _cLogx
					SUA->(MsUnLock())
				endif
			endif
			//Trecho inserido por Renan em 16/08/2016 para gravação do log no campo C5_LOGSTAT
			if SC5->(FieldPos("C5_LOGSTAT")) <> 0
					_cLog := Alltrim(M->C5_LOGSTAT)
					M->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " + UsrRetName(__cUserId) +;
									_lEnt + _cLogx
			endif
			//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
			if ExistBlock("RFATL001")
				U_RFATL001(	M->C5_NUM  ,;
							SUA->UA_NUM,;
							_cLogx     ,;
							_cRotina    )
			endif
						//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
			if ExistBlock("RFATR049")
				U_RFATR049(	M->C5_NUM )
			endif
			
			//17/10/2024 - Diego Rodrigues - Melhoria para validar pedidos que não foram atualizados e possuem produtos da linha industrial
			BeginSql Alias "LINDSC5"
				SELECT
					B5_XLINPRO
				FROM SC6010 SC6 (NOLOCK)
				INNER JOIN SB5010 SB5 (NOLOCK) ON SB5.D_E_L_E_T_ = '' AND B5_COD = C6_PRODUTO 
												AND B5_FILIAL = C6_FILIAL AND B5_XLINPRO = '1'
				INNER JOIN SC5010 SC5 (NOLOCK) ON SC5.D_E_L_E_T_ = '' AND C5_NUM = C6_NUM AND C5_XLININD = '2'
				WHERE SC6.D_E_L_E_T_ = ''
					AND C6_NUM = %Exp:M->C5_NUM%
				GROUP BY B5_XLINPRO, C6_NUM
			EndSql

			if LINDSC5->(!EOF())
				while !RecLock("SC5",.F.) ; enddo
					SC5->C5_XLININD := LINDSC5->B5_XLINPRO
				SC5->(MsUnLock()) 
			endif
			LINDSC5->(dbCloseArea())


			//19/07/2024 - Diego Rodrigues - Envio de e-mail para pedidos da linha Industrial
			if ExistBlock("RFATE072") .and. SC5->C5_XLININD == '1' .and. SC5->C5_TPOPER == '01'
				U_RFATE072(	M->C5_NUM,1,{})
			endif
		endif
			
		Pergunte("MTA410",.F.)
	Else 
		    MsgAlert("A rotina está sendo executada por outro usuário!",_cRotina+"_001")
	    return _lRet
	EndIf
	
	RestArea(_aSavSC9)
	RestArea(_aSavSC6)
	RestArea(_aSavSC5)
	RestArea(_aSavArea)
return _lRet
