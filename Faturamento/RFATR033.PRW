#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} RFATR033
Envio de e-mail aos representantes com a rela็ใo de clientes ativos (em html).
@author Rodrigo Telecio (rodrigo.telecio@allss.com.br)
@since 31/01/2022
@version P12
@type Function
@obs Sem observa็๕es
@see https://allss.com.br
@history 31/01/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Adi็ใo de coluna com data da ultima compra do cliente.
@history 23/04/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), adequa็ใo do titulo do e-mail removendo as palavras maiscuslas devido a restri็๕es da localweb
/*/
user function RFATR033()
private _cRotina := "RFATR033"
private cPerg    := _cRotina
If MsgYesNo("Deseja enviar o e-mail aos representantes com a sua rela็ใo de clientes neste momento?",_cRotina+"_001")
	ValidPerg()
	If Pergunte(cPerg,.T.)
		Processa( { |lEnd| RotEnvMail(lEnd) }, "[" + _cRotina + "] Envio de e-mail aos representantes com os clientes ativos", "Processando informa็๕es...", .T.)
	EndIf
EndIf
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณRotEnvMailบAutor  ณAnderson C. P. Coelho บ Data ณ  22/10/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณProcessamento da rotina                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RotEnvMail(lEnd)
Local Titulo    := ""	//"[Arcolor] Lista de Clientes com CNPJ por Representante"
Local _cMsg     := ""
Local _cMail    := ""
Local _cAnexo   := ""
Local _cFromOri := ""
Local _cBCC     := ""
Local _cQry     := ""
Local _cLogOK   := ""
Local _cLogErro := ""
Local _x        := 0
Local _nLogOK   := 0
Local _nLogErro := 0
Local _nContMsg := 0
Local _nTotMsg  := 1000
Local _nSeqMsg  := 1
Local _lRCFGM001 := ExistBlock("RCFGM001")
/*
_cQry := " SELECT * "
_cQry += " FROM " + RetSqlName("SA3") + " SA3 "
_cQry += "      INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_    = ''   "
_cQry += "                                              AND SA1.A1_FILIAL     = '" + xFilial("SA1") + "' "
_cQry += "                                              AND SA1.A1_MSBLQL    <> '1'  "
_cQry += "                                              AND SA1.A1_CGC       <> ''   "
_cQry += "                                              AND SA1.A1_EST       <> 'EX' "
_cQry += "                                              AND SA1.A1_COD  BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR05 + "' "
_cQry += "                                              AND SA1.A1_LOJA BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "' "
_cQry += "                                              AND SA1.A1_VEND       = SA3.A3_COD "
_cQry += " WHERE SA3.D_E_L_E_T_ = '' "
_cQry += "   AND SA3.A3_FILIAL  = '" + xFilial("SA3") + "' "
_cQry += "   AND SA3.A3_MSBLQL <> '1'  "
_cQry += "   AND LEN(SA3.A3_EMAIL) > 3 "
_cQry += "   AND SA3.A3_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
_cQry += " ORDER BY A3_FILIAL, A3_COD, A1_FILIAL, A1_NOME, A1_END, A1_CGC "
If __cUserId == "000000"
	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",_cQry)
EndIf
_cQry := ChangeQuery(_cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"SA3TMP",.F.,.T.)
*/
BeginSql Alias "SA3TMP"
	SELECT *
	FROM %table:SA3% SA3
		INNER JOIN %table:SA1% SA1 ON SA1.A1_FILIAL     = %xFilial:SA1%
					  AND SA1.A1_MSBLQL    <> '1' 
					  AND SA1.A1_CGC       <> ''
					  AND SA1.A1_EST       <> 'EX'
					  AND SA1.A1_COD  BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR05%
					  AND SA1.A1_LOJA BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR06%
					  AND SA1.A1_VEND       = SA3.A3_COD
					  AND SA1.%NotDel%
	WHERE SA3.A3_FILIAL  = %xFilial:SA3%
	  AND SA3.A3_MSBLQL <> '1'
	  AND LEN(SA3.A3_EMAIL) > 3
	  AND SA3.A3_COD BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
	  AND SA3.%NotDel%
	ORDER BY A3_FILIAL, A3_COD, A1_FILIAL, A1_NOME, A1_END, A1_CGC
EndSql
dbSelectArea("SA3TMP")
ProcRegua(SA3TMP->(RecCount()))
SA3TMP->(dbGoTop())

_cMail := UsrRetMail(RetCodUsr())//Lower(AllTrim(SA3TMP->A3_EMAIL))

While !SA3TMP->(EOF()) .AND. !lEnd
	_nContMsg := _nSeqMsg  := 1
	_cVend    := (SA3TMP->A3_COD+" "+SA3TMP->A3_NOME)
	alert(_cMail)
	&("_cMsg"+cValToChar(_nSeqMsg))  := ""
//	&("_cMsg"+cValToChar(_nSeqMsg))  := " <html>"
//	&("_cMsg"+cValToChar(_nSeqMsg))  += "		<body>"
	&("_cMsg"+cValToChar(_nSeqMsg))  += "			<table border='1'>"
//	&("_cMsg"+cValToChar(_nSeqMsg))  += "			<table border='5' cellspacing='1' cellpadding='0'>"
	&("_cMsg"+cValToChar(_nSeqMsg))  += "			<h3>Representante: " + Alltrim(_cVend) //+ "  -  " + AllTrim(_cMail) + "</h3>"
//	&("_cMsg"+cValToChar(_nSeqMsg))  += "			<table>"
	&("_cMsg"+cValToChar(_nSeqMsg))  += "			<p>Prezado representante,</p>"
	&("_cMsg"+cValToChar(_nSeqMsg))  += "			<p>     Voc๊ estแ recebendo a listagem de seus clientes com o respectivo CNPJ. A partir deste momento, envie os pedidos com esta informa็ใo pois, caso os pedidos recebidos nใo tiverem o CNPJ, estes nใo entrarใo em nosso sistema.</p>"
/*
	&("_cMsg"+cValToChar(_nSeqMsg))  += "				<tr>"
//	&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td width='80%' align='center'><b>CLIENTE</b></td>"
//	&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td width='20%' align='center'><b>CNPJ</b></td>"
	&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td align='center'><b>CLIENTE</b></td>"
	&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td align='center'><b>CNPJ</b></td>"
	&("_cMsg"+cValToChar(_nSeqMsg))  += "				</tr>"
*/
	&("_cMsg"+cValToChar(_nSeqMsg))  += "				<tr>
	&("_cMsg"+cValToChar(_nSeqMsg))  += "					<th id='ex31a_col_cliente' >CLIENTE</th>
	&("_cMsg"+cValToChar(_nSeqMsg))  += "					<th id='ex31a_col_cliente' >MUNICIPIO</th>
	&("_cMsg"+cValToChar(_nSeqMsg))  += "					<th id='ex31a_col_cliente' >ESTADO</th>
	&("_cMsg"+cValToChar(_nSeqMsg))  += "					<th id='ex31a_col_cnpj'    >CNPJ</th>
	&("_cMsg"+cValToChar(_nSeqMsg))  += "					<th id='ex31a_col_mail'    >E-MAIL</th>
	&("_cMsg"+cValToChar(_nSeqMsg))  += "					<th id='ex31a_col_telefone'>TELEFONE</th>
	&("_cMsg"+cValToChar(_nSeqMsg))  += "					<th id='ex31a_col_ultcom'  >ฺLTIMA COMPRA</th>
	&("_cMsg"+cValToChar(_nSeqMsg))  += "				</tr>
	While !SA3TMP->(EOF()) .AND. !lEnd .AND. _cVend == (SA3TMP->A3_COD+" "+SA3TMP->A3_NOME)
//		IncProc("Vendedor " + SA3TMP->A3_COD/*+" "+SA3TMP->A3_NOME*/ + ", Cliente " + SA3TMP->A1_COD+" "+SA3TMP->A1_LOJA+" "+SA3TMP->A1_NOME)

		// Altera็ใo - Fernando Bombardi - ALLSS - 03/03/2022
		//IncProc("Vendedor " + _cVend + ", Cliente " + SA3TMP->A1_COD+" "+SA3TMP->A1_LOJA+" "+SA3TMP->A1_NOME)
		IncProc("Representante " + _cVend + ", Cliente " + SA3TMP->A1_COD+" "+SA3TMP->A1_LOJA+" "+SA3TMP->A1_NOME)
		// Fim - Fernando Bombardi - ALLSS - 03/03/2022

		If _nContMsg >= _nTotMsg
			_nContMsg := 0
			_nSeqMsg++
			&("_cMsg"+cValToChar(_nSeqMsg))  := ""
		EndIf
		_nContMsg++
		&("_cMsg"+cValToChar(_nSeqMsg))  += "				<tr>"
		&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td width='80%' headers='ex31a_col_cliente'                >" + AllTrim(SA3TMP->A1_NOME) + " - " + Alltrim(SA3TMP->A1_END)    + "</td>"
		&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td width='20%' align='center' headers='ex31a_col_municipio'  >" + AllTrim(SA3TMP->A1_MUN)			                          + "</td>"
		&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td width='20%' align='center' headers='ex31a_col_estado'  >" + AllTrim(SA3TMP->A1_EST)		  	                        	  + "</td>"
		&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td width='20%' align='center' headers='ex31a_col_cnpj'    >" + Transform(AllTrim(SA3TMP->A1_CGC),PesqPict("SA1","A1_CGC"))   + "</td>"
		&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td width='20%' align='center' headers='ex31a_col_mail'    >" + AllTrim(Lower(SA3TMP->A1_EMAIL))                              + "</td>"
		&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td width='20%' align='center' headers='ex31a_col_telefone'>" + "("+AllTrim(SA3TMP->A1_DDD)+") "+AllTrim(SA3TMP->A1_TEL)      + "</td>"
		&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td width='20%' align='center' headers='ex31a_col_ultcom'  >" + AllTrim(DtoC(StoD(SA3TMP->A1_ULTCOM)))                        + "</td>"
		
//		&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td width='80%'               >" + AllTrim(SA3TMP->A1_NOME) + " - " + Alltrim(SA3TMP->A1_END) + "</td>"
//		&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td width='20%' align='center'>" + Transform(AllTrim(SA3TMP->A1_CGC),PesqPict("SA1","A1_CGC"))   + "</td>"
//		&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td               >" + SA3TMP->A1_NOME + "</td>"
//		&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td               >" + Alltrim(SA3TMP->A1_END) + "</td>"
//		&("_cMsg"+cValToChar(_nSeqMsg))  += "					<td align='center'>" + Transform(AllTrim(SA3TMP->A1_CGC),PesqPict("SA1","A1_CGC"))   + "</td>"
		&("_cMsg"+cValToChar(_nSeqMsg))  += "				</tr>"
		dbSelectArea("SA3TMP")
		SA3TMP->(dbSkip())
	EndDo
	&("_cMsg"+cValToChar(_nSeqMsg))  += "			</table>"
	&("_cMsg"+cValToChar(_nSeqMsg))  += "			<br>"
	&("_cMsg"+cValToChar(_nSeqMsg))  += "			<p>     Qualquer d๚vida, por gentileza entre em contato conosco.</p>"
	&("_cMsg"+cValToChar(_nSeqMsg))  += "			<p>Atenciosamente,</p>"
//	&("_cMsg"+cValToChar(_nSeqMsg))  += "			<h4>" + AllTrim(SM0->M0_NOMECOM) + "</h4>"
	&("_cMsg"+cValToChar(_nSeqMsg))  += "			<h4>Departamento Comercial</h4>"
	&("_cMsg"+cValToChar(_nSeqMsg))  += "			<h4>ARCำLOR</h4>"
//	&("_cMsg"+cValToChar(_nSeqMsg))  += "		</body>"
//	&("_cMsg"+cValToChar(_nSeqMsg))  += "	</html>"
	_cMsgFim := ""
	For _x := 1 To _nSeqMsg
		If _x > 1
			_cMsgFim += "+"
		EndIf
		_cMsgFim += ("_cMsg"+cValToChar(_x))
	Next
//	If ExistBlock("RFATR033") .AND. U_RCFGM001(Titulo,_cMsg      ,_cMail,""     ,""/*"vendas@arcolor.com.br"*/,""                           ,"[ARCOLOR - U R G E N T E] Pedidos com CNPJ"            ,.T.      ,.T.    )
//					  RCFGM001(Titulo,_cMsg      ,_cMail,_cAnexo,_cFromOri                    ,_cBCC                        ,_cAssunto                                               ,_lExcAnex,_lAlert)
	If _lRCFGM001 //.AND. U_RCFGM001(Titulo,&(_cMsgFim),_cMail,""     ,"info@arcolor.com.br"        ,"marco.mendes@arcolor.com.br","[ARCำLOR - U R G E N T E] Pedidos com CNPJ - " + _cVend,.T.      ,.T.    )
		U_RCFGM001(Titulo,&(_cMsgFim),_cMail,"",_cFromOri,_cMail+";marco.mendes@arcolor.com.br","[Arcolor - Urgente] Pedidos com CNPJ - " + _cVend) //Chamada da rotina responsแvel pelo envio de e-mails
		_cLogOK   += _cVend + CHR(13) + CHR(10)
		_nLogOK++
	Else
		_cLogErro += _cVend + CHR(13) + CHR(10)
		_nLogErro++
	EndIf
	For _x := 1 To _nSeqMsg
		&("_cMsg"+cValToChar(_x)) := ""
	Next
	dbSelectArea("SA3TMP")
EndDo
dbSelectArea("SA3TMP")
SA3TMP->(dbCloseArea())
If lEnd
	MsgAlert("Processamento abortado!",_cRotina+"_002")
EndIf
If !Empty(_cLogOK)
	MemoWrite("\2.MemoWrite\"+_cRotina+"_LogOK.txt","Registros enviados com sucesso: " + _cLogOK)
	If File("\2.MemoWrite\"+_cRotina+"_LogOK.txt")
		FOpen("\2.MemoWrite\"+_cRotina+"_LogOK.txt")
	EndIf
EndIf
If !Empty(_cLogOK)
	MemoWrite("\2.MemoWrite\"+_cRotina+"_LogERRO.txt","Registros com ERRO no envio: " + _cLogErro)
	If File("\2.MemoWrite\"+_cRotina+"_LogERRO.txt")
		FOpen("\2.MemoWrite\"+_cRotina+"_LogERRO.txt")
	EndIf
EndIf

// Altera็ใo - Fernando Bombardi - ALLSS - 03/03/2022
//MsgInfo("Fim do processamento." + "Vendedores com ๊xito: " + cValToChar(_nLogOK) + CHR(13) + CHR(10) + "Vendedores com problemas: " + cValToChar(_nLogErro) + CHR(13) + CHR(10),_cRotina+"_003")
MsgInfo("Fim do processamento." + "Representantes com ๊xito: " + cValToChar(_nLogOK) + CHR(13) + CHR(10) + "Representantes com problemas: " + cValToChar(_nLogErro) + CHR(13) + CHR(10),_cRotina+"_003")
// Fim - Fernando Bombardi - ALLSS - 03/03/2022


Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg  บAutor  ณAnderson C. P. Coelho บ Data ณ  22/10/14บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se as perguntas existem na SX1. Caso nใo existam,  บฑฑ
ฑฑบ          ณas cria.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidPerg()
Local _aArea := GetArea()
Local aRegs  := {}
Local _aTam  := {}
dbSelectArea("SX1")
dbSetOrder(1)
cPerg  := PADR(cPerg,10)
_aTam  := TamSx3("A3_COD" )

// Altera็ใo - Fernando Bombardi - ALLSS - 03/03/2022
//AADD(aRegs,{cPerg,"01","Do Vendedor           ?","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par01",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
//AADD(aRegs,{cPerg,"02","At้ o Vendedor        ?","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par02",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})

AADD(aRegs,{cPerg,"01","Do Representante        ?","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par01",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
AADD(aRegs,{cPerg,"02","At้ o Representante     ?","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par02",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
// Altera็ใo - Fernando Bombardi - ALLSS - 03/03/2022


_aTam  := TamSx3("A1_COD" )
AADD(aRegs,{cPerg,"03","Do Cliente            ?","","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par03",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA1","",""})
_aTam  := TamSx3("A1_LOJA")
AADD(aRegs,{cPerg,"04","Da Loja               ?","","","mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par04",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})
_aTam  := TamSx3("A1_COD" )
AADD(aRegs,{cPerg,"05","At้ o Cliente         ?","","","mv_ch5",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par05",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA1","",""})
_aTam  := TamSx3("A1_LOJA")
AADD(aRegs,{cPerg,"06","At้ a Loja            ?","","","mv_ch6",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par06",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})
For i := 1 To Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j := 1 To FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Else
				Exit
			EndIf
		Next
		SX1->(MsUnlock())
	EndIf
Next
RestArea(_aArea)
Return
