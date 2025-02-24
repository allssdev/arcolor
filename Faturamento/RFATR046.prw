#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFATR046 � Autor � Arthur Silva       � Data �  23/10/2017 ���
�������������������������������������������������������������������������͹��
���Descricao � Relat�rio de Clientes Por Vendedor e Envio Por Email em    ���
���				Excel.										              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFATR046()

Local oExcel
Local _cTitulo   := "Clientes Ativos"
Local _cRotina   := "RFATR046"
Local _cQry      := ""
Local cString    := "QRYTMP"
Local _cNomVen   := ""
Local _cMailVen  := ""
Local _cCodVen   := ""
Local _cFromOri  := ""
Local _cMsg		 := ""
Local _cText1	 := "Prezado representante,"
Local _cText2    := "Voc� esta recebendo a rela��o de seus clientes ativos para a valida��o dos e-mails de remessa de NFE. Este processo � muito importante,"
Local _cText3	 := "pois h� uma determina��o do SEFAZ que obriga o envio de todas as NFE�s aos seus destinat�rios atrav�s arquivo."  
Local _cText4	 := "Ap�s realizar a atualiza��o dos e-mails, esse arquivo deve ser enviado � Arc�lor, para regulariza��o do cadastro."
Local _cText5	 := "PRAZO DE RETORNO AT� 20 DE NOVEMBRO DE 2.017!"
Local _cText6	 := "Desde j� agradecemos a sua colabora��o."
Local _cText7	 := "Atenciosamente,"
Local _cText8	 := "Gerencia Comercial."

Local _cMsg		 := ""

Private cPerg    := _cRotina
Private _lRCFGM001 := ExistBlock("RCFGM001")


//Verifica as perguntas selecionadas.
ValidPerg()
If !Pergunte(cPerg,.T.)
	Return
EndIf

If MsgYesNo("Deseja Realmente enviar o relat�rio aos representantes?",_cRotina+"_001")
	_cMsg += "<HTML><HEAD><TITLE></TITLE>"
	_cMsg += "<META http-equiv=Content-Type content='text/html; charset=windows-1252'>"
	_cMsg += "<META content='MSHTML 6.00.6000.16735' name=GENERATOR></HEAD>"
	_cMsg += "<BODY>"   		 //Inicia conteudo do e-mail
	_cMsg += "<H3><Font Face = 'Arial' Size = '2'><P> </P>"
	_cMsg += "<P><b> " + _cText1 +"</b> <BR>"
	_cMsg += "<P> " + _cText2 +" <BR>"
	_cMsg += "<P> " + _cText3 + "<BR>"
	_cMsg += "<P> " + _cText4 + "<BR>"
	_cMsg += "<P> <mark> " + _cText5 + " </mark> <BR>"
	_cMsg += "<P> " + _cText6 + "<BR>"
	_cMsg += "<P> " + _cText7 + "<BR>"
	_cMsg += "<P> " + _cText8 + "<BR>"
	_cMsg += "<P><I>Este e-mail foi enviado automaticamente pelo sistema Protheus. (N�o responder)</I></P></H3><BR>"
	_cMsg += "<P>&nbsp;</P>"
	_cMsg += "</A></P></BODY>" //Finaliza conteudo do e-mail
	
	
	
	
	_cQry   := " SELECT A1_VEND, A1_COD, A1_LOJA, A1_NOME,A1_NREDUZ, A1_CGC, A1_EMAIL, A3_EMAIL,A3_NOME,A3_COD	"
	_cQry   += " FROM " + RetSqlName ("SA1") + " SA1 											"
	_cQry   += "	INNER JOIN " + RetSqlName ("SA3")+ " SA3 ON SA3.A3_FILIAL = SA1.A1_FILIAL   "
	_cQry   += "					AND SA3.A3_COD = SA1.A1_VEND            					"
	_cQry   += "					AND SA3.A3_MSBLQL = 2                   					"
	_cQry   += "					AND SA3.D_E_L_E_T_ = ''                 					"
	_cQry   += "	WHERE SA1.A1_VEND BETWEEN   '" + mv_par01 + "' AND '" + mv_par02 + "' "     "
	_cQry   += "		AND SA1.A1_COD BETWEEN  '" + mv_par03 + "' AND '" + mv_par05 + "' "     "
	_cQry   += "		AND SA1.A1_LOJA BETWEEN '" + mv_par04 + "' AND '" + mv_par06 + "' "     "
	_cQry   += "		AND SA1.A1_MSBLQL = 2                               					"
	_cQry   += "		AND SA1.D_E_L_E_T_ = ''                             					"
	_cQry   += " ORDER BY A1_VEND                                           					"
	
	_cQry   := ChangeQuery (_cQry)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cString,.T.,.F.)
	
	//Loop para inclus�o das linhas de dados no Excel
	dbSelectArea("QRYTMP")
	ProcRegua(QRYTMP->(RecCount()))
	QRYTMP->(dbGoTop())
	
	While !QRYTMP->(EOF())
		oExcel     := FWMSExcel():New()
		//Defino a Sheet/Plan
		oExcel:AddWorkSheet("Clientes")
		//Defino o T�tulo da tabela no Excel
		oExcel:AddTable("Clientes",_cTitulo)
		//Crio o cabe�alho das colunas do relat�rio
		oExcel:AddColumn("Clientes",_cTitulo,"Cod. Cliente"  ,2,1,.F.)        //A1_COD
		oExcel:AddColumn("Clientes",_cTitulo,"Loja"          ,2,1,.F.)        //A1_LOJA
		oExcel:AddColumn("Clientes",_cTitulo,"Nome"          ,2,1,.F.)        //A1_NOME
		oExcel:AddColumn("Clientes",_cTitulo,"Nome Fantasia" ,2,1,.F.)        //A1_NOME
		oExcel:AddColumn("Clientes",_cTitulo,"CNPJ"          ,2,1,.F.)        //A1_CGC
		oExcel:AddColumn("Clientes",_cTitulo,"Email Para Envio da NFE",2,1,.F.)        //A1_EMAIL
		
		_cNomVen  := QRYTMP->A3_NOME
		_cMailVen := QRYTMP->A3_EMAIL
		_cCodVen  := QRYTMP->A3_COD
	
		While !QRYTMP->(EOF()) .AND. _cCodVen == QRYTMP->A3_COD
			oExcel :AddRow("Clientes",_cTitulo, {	QRYTMP->A1_COD    ,;
													QRYTMP->A1_LOJA   ,;
													QRYTMP->A1_NOME   ,;
													QRYTMP->A1_NREDUZ ,;
													QRYTMP->A1_CGC    ,;
													QRYTMP->A1_EMAIL  })
			QRYTMP->(dbSkip())
		EndDo												
		//Ativo o Excel
		oExcel:Activate()
		//Pego o caminho da pasta de tempor�rios da m�quina do usu�rio
		_cDirTmp := GetTempPath()
		//Defino o nome do arquivo do Excel a ser gerado
		_cArq    := "Clientes_"+ alltrim(_cNomVen)+".xml"
		//Gero o Excel com o nome que defini anteriormente no servidor
		oExcel:GetXmlFile(_cArq)
		//Desativo o Excel (pois a planilha j� foi gerada)
		oExcel:DeActivate()
		//Se o arquivo foi criado com sucesso, copio para a pasta tempor�ria na m�quina do usu�rio
		If File(_cArq)
			If _lRCFGM001 //RCFGM001(Titulo,_cMsg,_cMail,_cAnexo,_cFromOri,_cBCC,_cAssunto,_lExcAnex,_lAlert)
				U_RCFGM001(_cTitulo,_cMsg,Alltrim(_cMailVen),"\system\"+_cArq,_cFromOri,"anderson.coelho@allss.com.br","[Arcolor] " + _cNomVen) //Chamada da rotina respons�vel pelo envio de e-mails
	    	EndIf
			//Apago o arquivo de Excel original do Servidor                
			FErase(_cArq)
		EndIf
	EndDo
	//Fecho a query
	QRYTMP->(dbCloseArea())
	MsgInfo("Processo Finalizado!",_cRotina+"_002")
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValidPerg  �Autor �Arthur F. da Silva    � Data �  19/03/15 ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica/cria as perguntas de usu�rio na tabela SX1.       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ValidPerg()

Local _aAlias := GetArea()
Local aRegs   := {}

cPerg   := PADR(cPerg,10)

_aTam  := TamSx3("A3_COD" )

// Altera��o - Fernando Bombardi - ALLSS - 03/03/2022
//AADD(aRegs,{cPerg,"01","Do Vendedor           ?","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par01",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
//AADD(aRegs,{cPerg,"02","At� o Vendedor        ?","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par02",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})

AADD(aRegs,{cPerg,"01","Do Representante     ?","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par01",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
AADD(aRegs,{cPerg,"02","At� o Representante  ?","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par02",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
// Fim - Fernando Bombardi - ALLSS - 03/03/2022

_aTam  := TamSx3("A1_COD" )
AADD(aRegs,{cPerg,"03","Do Cliente            ?","","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par03",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA1","",""})
_aTam  := TamSx3("A1_LOJA")
AADD(aRegs,{cPerg,"04","Da Loja               ?","","","mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par04",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})
_aTam  := TamSx3("A1_COD" )
AADD(aRegs,{cPerg,"05","At� o Cliente         ?","","","mv_ch5",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par05",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA1","",""})
_aTam  := TamSx3("A1_LOJA")
AADD(aRegs,{cPerg,"06","At� a Loja            ?","","","mv_ch6",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par06",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})

For i := 1 To Len(aRegs)
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If !SX1->(MsSeek(cPerg+aRegs[i,2],.T.,.F.))
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

RestArea(_aAlias)

Return
