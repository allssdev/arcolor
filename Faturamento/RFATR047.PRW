#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE _lEnt CHR(13) + CHR(10)
/*/{Protheus.doc} RFATR047
@description Envio de e-mail aos representantes com a relação de clientes ativos (em html).
@author Lívia Della Corte (ALL System Solutions)
@since 17/09/2018
@version 1.0
@type function
@see https://allss.com.br
@history 23/04/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), adequação do titulo do e-mail removendo as palavras maiscuslas devido a restrições da localweb
/*/
user function RFATR047()
	Private _cRotina := "RFATR047"
	Private cPerg    := _cRotina
	/*
	RpcSetEnv("01", "01")
	RPCSetType(3)
	//EnvMailDescon()
	RotEnvMail()
	*/
	if MsgYesNo("Deseja enviar o e-mail aos representantes com a sua relação de clientes neste momento?",_cRotina+"_000")
		ValidPerg()
		If Pergunte(cPerg,.T.)
			RotEnvMail(@lEnd)
			//	Processa( { |lEnd| RotEnvMail(@lEnd) }, "[" + _cRotina + "] Envio de e-mail aos representantes com os clientes ativos", "Processando informações...", .T.)
		EndIf
	EndIf
return
/*/{Protheus.doc} RotEnvMail
@description Processamento da rotina.
@obs Sub-rotina de RFATR047.
@author Lívia Della Corte (ALL System Solutions)
@since 20/09/2018
@version 1.0
@type sub-function de RFATR047.
@see https://allss.com.br
/*/
//static function EnvMailDescon(lEnd)
static function RotEnvMail(lEnd)
	Local Titulo    := ""
	Local _cMail    := ""
	Local _cFromOri := ""
	Local _cLogOK   := ""
	Local _cLogErro := ""
	Local _cCGC     := ""
	Local _cMsgFim  := ""
	Local _x        := 0
	Local _nLogOK   := 0
	Local _nLogErro := 0
	Local _nContMsg := 0
	Local _nTotMsg  := 1000
	Local _nSeqMsg  := 1
	Local _cQry		:= ""
	Local _cVend    := ""
	//local MV_PAR01 := "000177"
	//local MV_PAR02 := "000177"
	//local MV_PAR03 := ""
	//local MV_PAR04 := ""
	//local MV_PAR05 := "ZZZZZZ"
	//local MV_PAR06 := "ZZ"
	Local _tAlias := "SA3TMP"
	//limitacao de variavel
	_cQry := " 			SELECT top 1000  ACN.* , SA1.A1_NOME ,SA1.A1_COD , SA1.A1_LOJA, SA3.A3_COD, SA3.A3_NOME, SB1.B1_DESC, SA1.A1_CGC , ACS.ACS_FILIAL  ,ACN.ACN_DESCV1  " + _lEnt
	_cQry += " 			, ACN.ACN_DESCV2 , ACN.ACN_DESCV3 , ACN.ACN_DESCV4 " + _lEnt
	_cQry += " 			FROM " + RetSqlName("SA3") + " SA3 (NOLOCK) " + _lEnt
	_cQry += " 				INNER JOIN " + RetSqlName("SA1") + " SA1 (NOLOCK) ON SA1.A1_FILIAL     = '' " + _lEnt
	_cQry += " 												 	AND SA1.A1_MSBLQL    <> '1'  " + _lEnt
	_cQry += " 												  	AND SA1.A1_CGC       <> '' " + _lEnt
	_cQry += " 												  	AND SA1.A1_EST       <> 'EX' " + _lEnt
	_cQry += " 												  	AND SA1.A1_COD  BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR05 + "'  " + _lEnt
	_cQry += " 												  	AND SA1.A1_LOJA BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "'  " + _lEnt
	_cQry += " 												  	AND SA1.A1_VEND       = SA3.A3_COD " + _lEnt
	_cQry += " 												  	AND SA1.D_E_L_E_T_ = '' " + _lEnt
	_cQry += " 				 LEFT JOIN " + RetSqlName("ACS") + " ACS (NOLOCK) ON  ACS.ACS_FILIAL  = '01' 	AND ((ACS.ACS_CODCLI = SA1.A1_COD AND ACS.ACS_LOJA = SA1.A1_LOJA) OR SA1.A1_GRPVEN = ACS.ACS_GRPVEN) AND ACS.D_E_L_E_T_ = ''  " + _lEnt
	_cQry += " 				 LEFT JOIN " + RetSqlName("ACN") + " ACN (NOLOCK) ON  ACN.ACN_FILIAL  = '01'	AND   ACS.ACS_CODREG = ACN.ACN_CODREG AND ACN.D_E_L_E_T_ = ''  " + _lEnt
	_cQry += " 				 LEFT JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON  SB1.B1_FILIAL   = '01'	AND  SB1.B1_COD     = ACN.ACN_CODPRO  AND SB1.D_E_L_E_T_ = ''  " + _lEnt
	_cQry += " 			WHERE SA3.A3_FILIAL      = ''  " + _lEnt
	_cQry += " 			  AND SA3.A3_MSBLQL     <> '1'  " + _lEnt
	_cQry += " 			  AND LEN(SA3.A3_EMAIL)  > 3  " + _lEnt
	_cQry += " 			  AND SA3.A3_COD   BETWEEN '" + MV_PAR01 + "'  AND '" + MV_PAR02 + "'   " + _lEnt
	_cQry += " 			  AND SA3.D_E_L_E_T_ = ''  " + _lEnt
	_cQry += " 			ORDER BY A3_FILIAL, A3_COD, A1_FILIAL, A1_NOME, A1_END, A1_CGC, B1_COD, ACN_QUANTI  " + _lEnt
	If len(_cQry) > 0
		_cQry := ChangeQuery(_cQry)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_tAlias,.T.,.F.)  
	EndIf	
	_cMail    := UsrRetMail(RetCodUsr())
	MsgInfo("Será enviado para o e-mail "+_cMail,_cRotina+"_001")	
	dbSelectArea(_tAlias)
	ProcRegua(RecCount())
	(_tAlias)->(dbGoTop())
	While !(_tAlias)->(EOF()) .AND. !lEnd // .AND. (_cVend == "" .OR. _cVend == ((_tAlias)->A3_COD + " - " + (_tAlias)->A3_NOME))
		_nContMsg := _nSeqMsg  := 1
		_cVend    := ((_tAlias)->A3_COD + " - " + (_tAlias)->A3_NOME)
		&("_cMsg"+cValToChar(_nSeqMsg))  := ""
		&("_cMsg"+cValToChar(_nSeqMsg))  += "			<br><table>"	
		&("_cMsg"+cValToChar(_nSeqMsg))  += "			<tr><td width='100%'><h3> Desconto Cliente X Produto </td></tr>"  
		&("_cMsg"+cValToChar(_nSeqMsg))  += "			<tr><td width='100%'><h3>Representante: " + Alltrim(_cVend) +" </td></tr>"  
		&("_cMsg"+cValToChar(_nSeqMsg))  += "			</table>"
		&("_cMsg"+cValToChar(_nSeqMsg))  += "			<table border='1' width='100%' >"
		&("_cMsg"+cValToChar(_nSeqMsg))  += "				<tr>
		&("_cMsg"+cValToChar(_nSeqMsg))  += "					<th id='ex31a_col_cliente' >Cliente 						</th>
		&("_cMsg"+cValToChar(_nSeqMsg))  += "					<th id='ex31a_col_cnpj'    > CNPJ 							</th>
	    &("_cMsg"+cValToChar(_nSeqMsg))  += "					<th id='ex31a_col_descont' > Desconto por Regra de Negócio	</th>
		&("_cMsg"+cValToChar(_nSeqMsg))  += "				</tr>
		While !(_tAlias)->(EOF()) .AND. !lEnd .AND. _cVend == ((_tAlias)->A3_COD+" - "+(_tAlias)->A3_NOME)
			// Alteração - Fernando Bombardi - ALLSS - 03/03/2022
			//IncProc("Vendedor " + _cVend + ", Cliente " + (_tAlias)->A1_COD+" "+(_tAlias)->A1_LOJA+" "+(_tAlias)->A1_NOME+"...")
			IncProc("Representante " + _cVend + ", Cliente " + (_tAlias)->A1_COD+" "+(_tAlias)->A1_LOJA+" "+(_tAlias)->A1_NOME+"...")
			// Fim - Fernando Bombardi - ALLSS - 03/03/2022

			If _nContMsg >= _nTotMsg
				_nContMsg := 0
				_nSeqMsg++
				&("_cMsg"+cValToChar(_nSeqMsg))  := ""		
			EndIf
			_nContMsg++
			&("_cMsg"+cValToChar(_nSeqMsg))  += "				<tr>"
			&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td width='30%' align='left' VALIGN = TOP headers='ex31a_col_cliente' >" +  AllTrim((_tAlias)->A1_NOME)     								  + "</td>"
			&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td width='15%' align='left' VALIGN = TOP headers='ex31a_col_cnpj'    >" +  Transform(AllTrim((_tAlias)->A1_CGC),PesqPict("SA1","A1_CGC"))   + "</td>"
			_cCGC                            := (_tAlias)->A1_CGC  
			if LEN(alltrim((_tAlias)->ACS_FILIAL)) > 0
				&("_cMsg"+cValToChar(_nSeqMsg))  += "		<td width='55%' align='center' headers='ex31a_col_descont' >" 		
				&("_cMsg"+cValToChar(_nSeqMsg))  += "			   <table border='1'>"
				&("_cMsg"+cValToChar(_nSeqMsg))  += "				<tr>
				&("_cMsg"+cValToChar(_nSeqMsg))  += "					<th id='ex31a_col_cod'    > Código  		</th>
				&("_cMsg"+cValToChar(_nSeqMsg))  += "					<th id='ex31a_col_prod'   > Produto 		</th>
				&("_cMsg"+cValToChar(_nSeqMsg))  += "					<th id='ex31a_col_qtd'    > Qtd. Mínima     </th>
				&("_cMsg"+cValToChar(_nSeqMsg))  += "					<th id='ex31a_col_des1'    > Desconto 1 		</th>
				&("_cMsg"+cValToChar(_nSeqMsg))  += "					<th id='ex31a_col_des2'    > Desconto 2		</th>
				&("_cMsg"+cValToChar(_nSeqMsg))  += "					<th id='ex31a_col_des3'    > Desconto 3 		</th>
				&("_cMsg"+cValToChar(_nSeqMsg))  += "					<th id='ex31a_col_des4'    > Desconto 4		</th>
				&("_cMsg"+cValToChar(_nSeqMsg))  += "					<th id='ex31a_col_des'    > Desconto  		</th>
				&("_cMsg"+cValToChar(_nSeqMsg))  += "				</tr>
				while !(_tAlias)->(EOF())
					If _nContMsg >= _nTotMsg
						_nContMsg := 0
						_nSeqMsg++
						&("_cMsg"+cValToChar(_nSeqMsg))  := ""
					EndIf
					_nContMsg++
					if  alltrim((_tAlias)->A1_CGC) == alltrim(_cCGC)
						&("_cMsg"+cValToChar(_nSeqMsg))  += "				<tr>	
						&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td width='20%' align='center' headers='ex31a_col_cod'  >" + AllTrim((_tAlias)->ACN_CODPRO)	 + "</td>"
						&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td width='60%' align='left' headers='ex31a_col_prod'  >" + AllTrim((_tAlias)->B1_DESC)	     + "</td>"
						&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td width='10%' align='center' headers='ex31a_col_qtd' >" +   cvaltochar((_tAlias)->ACN_QUANTI)  + "</td>"
						&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td width='10%' align='center' headers='ex31a_col_des1' >" +  cvaltochar((_tAlias)->ACN_DESCV1)  + "</td>"
					    &("_cMsg"+cValToChar(_nSeqMsg))  += "					<td width='10%' align='center' headers='ex31a_col_des2' >" +  cvaltochar((_tAlias)->ACN_DESCV2)  + "</td>"
						&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td width='10%' align='center' headers='ex31a_col_des3' >" +  cvaltochar((_tAlias)->ACN_DESCV3)  + "</td>"
						&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td width='10%' align='center' headers='ex31a_col_des4' >" +  cvaltochar((_tAlias)->ACN_DESCV4)  + "</td>"
						&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td width='10%' align='center' headers='ex31a_col_des'  >" +  cvaltochar((_tAlias)->ACN_DESCON)  + "</td>"
						&("_cMsg"+cValToChar(_nSeqMsg))  += "				</tr>"
	    			 	_nContMsg++
						_cCGC := (_tAlias)->A1_CGC
						(_tAlias)->(dbSkip())
					Else 
						Exit
					EndIf	
				Enddo
				_cCGC := ""
				&("_cMsg"+cValToChar(_nSeqMsg))  += "			</table></td>"
			Else	
				If _nContMsg >= _nTotMsg
					_nContMsg := 0
					_nSeqMsg++
					&("_cMsg"+cValToChar(_nSeqMsg))  := ""
				EndIf
				_nContMsg++
				&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td width='55%' align='center' headers='ex31a_col_descont' > N/A </td>" 
			EndIf	
			If _nContMsg >= _nTotMsg
				_nContMsg := 0
				_nSeqMsg++
				&("_cMsg"+cValToChar(_nSeqMsg))  := ""
			EndIf	
			_nContMsg++
			&("_cMsg"+cValToChar(_nSeqMsg))  += "				</td>"			
			&("_cMsg"+cValToChar(_nSeqMsg))  += "			</tr>"
			dbSelectArea(_tAlias)
			(_tAlias)->(dbSkip())
		EndDo	
		If _nContMsg >= _nTotMsg
			_nContMsg := 0
			_nSeqMsg++
			&("_cMsg"+cValToChar(_nSeqMsg))  := ""
		EndIf
		_nContMsg++
		&("_cMsg"+cValToChar(_nSeqMsg))  += "			</table>"	
		&("_cMsg"+cValToChar(_nSeqMsg))  += "			<br>"
		&("_cMsg"+cValToChar(_nSeqMsg))  += "			<p>     Qualquer dúvida, por gentileza entre em contato conosco.</p>"
		&("_cMsg"+cValToChar(_nSeqMsg))  += "			<p>Atenciosamente,</p>"
		&("_cMsg"+cValToChar(_nSeqMsg))  += "			<h4>Departamento Comercial</h4>"
		&("_cMsg"+cValToChar(_nSeqMsg))  += "			<h4>ARCOLOR</h4>"
		_cMsgFim := ""
		_cLogOK  += _cVend + CHR(13) + CHR(10)
		_nLogOK++
		//dbSelectArea("_tAlias")
	EndDo
	For _x := 1 To _nSeqMsg
		If _x > 1
			_cMsgFim += "+"
		EndIf
		_cMsgFim += ("_cMsg"+cValToChar(_x))
	Next
	MemoWrite("\2.MemoWrite\"+_cRotina+"_LogOK.xls", &(_cMsgFim))
	If ExistBlock("RCFGM001")
		U_RCFGM001(Titulo,&(_cMsgFim),_cMail,"\2.MemoWrite\"+_cRotina+"_LogOK.xls",_cFromOri,"anderson.coelho@allss.com.br;rodrigo.telecio@allss.com.br","[Arcolor] Desconto por CNPJ - Vendedor: " + _cVend) //Chamada da rotina responsável pelo envio de e-mails
	EndIf
	dbSelectArea(_tAlias)
	(_tAlias)->(dbCloseArea())
	If lEnd
		MsgAlert("Processamento abortado!",_cRotina+"_002")
	EndIf
	If !Empty(_cLogOK)
		MemoWrite("\2.MemoWrite\"+_cRotina+"_LogOK.txt","Registros enviados com sucesso: " + _cLogOK + &(_cMsgFim))
		MemoWrite(GetTempPath()+_cRotina+"_LogOK.xls", &(_cMsgFim))
	EndIf
	If !Empty(_cLogOK)
		MemoWrite("\2.MemoWrite\"+_cRotina+"_LogERRO.txt","Registros com ERRO no envio: " + _cLogErro)
	EndIf

	// Alteração - Fernando Bombardi - ALLSS - 03/03/2022
	//MsgInfo("Fim do processamento." + "Vendedores com êxito: " + cValToChar(_nLogOK) + _lEnt + "Vendedores com problemas: " + cValToChar(_nLogErro) + CHR(13) + CHR(10),_cRotina+"_003")
	MsgInfo("Fim do processamento." + "Representantes com êxito: " + cValToChar(_nLogOK) + _lEnt + "Representantes com problemas: " + cValToChar(_nLogErro) + CHR(13) + CHR(10),_cRotina+"_003")
	// Fim - Fernando Bombardi - ALLSS - 03/03/2022

return
/*/{Protheus.doc} ValidPerg
@description Verifica se as perguntas existem na SX1. Caso não existam, as cria.
@obs Sub-rotina de RFATR047.
@author Lívia Della Corte (ALL System Solutions)
@since 20/09/2018
@version 1.0
@type sub-function de RFATR047.
@see https://allss.com.br
/*/
static function ValidPerg()
	Local _aArea := GetArea()
	Local aRegs  := {}
	Local _aTam  := {}
	Local i, j

	_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	cPerg  := PADR(cPerg,len((_cAliasSX1)->X1_GRUPO))
	_aTam  := TamSx3("A3_COD" )

	// Alteração - Fernando Bombardi - ALLSS - 03/03/2022
	//AADD(aRegs,{cPerg,"01","Do Vendedor           ?","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par01",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
	//AADD(aRegs,{cPerg,"02","Até o Vendedor        ?","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par02",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})

	AADD(aRegs,{cPerg,"01","Do Representante        ?","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par01",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
	AADD(aRegs,{cPerg,"02","Até o Representante     ?","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par02",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
	// Fim - Fernando Bombardi - ALLSS - 03/03/2022

	_aTam  := TamSx3("A1_COD" )
	AADD(aRegs,{cPerg,"03","Do Cliente            ?","","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par03",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA1","",""})
	_aTam  := TamSx3("A1_LOJA")
	AADD(aRegs,{cPerg,"04","Da Loja               ?","","","mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par04",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})
	_aTam  := TamSx3("A1_COD" )
	AADD(aRegs,{cPerg,"05","Até o Cliente         ?","","","mv_ch5",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par05",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA1","",""})
	_aTam  := TamSx3("A1_LOJA")
	AADD(aRegs,{cPerg,"06","Até a Loja            ?","","","mv_ch6",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par06",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})
	For i := 1 To Len(aRegs)
		If !(_cAliasSX1)->(dbSeek(cPerg+aRegs[i,2]))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				For j := 1 To FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					Else
						Exit
					EndIf
				Next
			(_cAliasSX1)->(MsUnLock())
		EndIf
	Next
	RestArea(_aArea)
return
