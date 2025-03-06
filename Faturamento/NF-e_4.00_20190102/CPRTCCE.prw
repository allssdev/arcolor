#include "protheus.ch"
#include "rwmake.ch"
#include "font.ch"
#include "colors.ch"
#include "totvs.ch"
#Include "TOPCONN.CH"
/*/{Protheus.doc} RESTR004
@description Relatório Necessidades Materiais, conforme PMP.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 30/07/2012
@version 1.0
@type function
@see https://allss.com.br
/*/
user function CPRTCCE() 
	local   iw1,iw2,nLin 
	local   aArea    := GetArea()
	local   xBitMap  := FisxLogo("1")     ///Logotipo da empresa
	local   MMEMO1   := ""
	local   MMEMO2   := ""
	local   xCGC     := ""
	local   cQry     := ""
	local   _cTMP    := GetNextAlias()

	private _cRotina := "CPRNCCE"
	private cPerg    := Padr(_cRotina,10)
	private nHErp    := AdvConnection() //Armazena a conexão atual
	private cDBTSS   := GetPvProfString("RCOMW001_001","BANCOTSSDataBase","",GetAdv97())+"/"+GetPvProfString("RCOMW001_001","BANCOTSS","",GetAdv97())				//"MSSQL7/TSSP12_PRODUCAO"  //Nome do serviço/Nome da base
	private cSrvTSS  := GetPvProfString("RCOMW001_001","BANCOTSSServer","",GetAdv97())																				//"192.168.1.213"	//	private cSrvOra := AllTrim(getServerIP())		//"192.168.1.106"  // IP do servidor
	private cDBPRD   := GetPvProfString("RCOMW001_001","BANCOPRDDataBase","",GetAdv97())+"/"+GetPvProfString("RCOMW001_001","BANCOPRD","",GetAdv97())				//"MSSQL7/TSSP12_PRODUCAO"  //Nome do serviço/Nome da base
	private cSrvPRD  := GetPvProfString("RCOMW001_001","BANCOPRDServer","",GetAdv97())																				//"192.168.1.213"	//	private cSrvOra := AllTrim(getServerIP())		//"192.168.1.106"  // IP do servidor

	private nHndOra  := 0

	ValidPerg()
	if !Pergunte(cPerg,.T.)
		return
	endif
	if MV_PAR04 == "E"
		dbSelectArea("SF1")
		SF1->(dbSetOrder(1))
//		Set SoftSeek ON
		SF1->(MsSeek(xFilial("SF1")+mv_par02+mv_par01,.F.,.F.))
//		Set SoftSeek OFF
		if !SF1->(EOF())
			// Cria um novo objeto para impressao
			oPrint   := TMSPrinter():New("Impressão da Carta de Correção Eletronica - CC-e")
			// Cria os objetos com as configuracoes das fontes
			// Negrito  Subl  Italico
			oFont08  := TFont():New( "Times New Roman",,08,,.f.,,,,,.f.,.f. )
			oFont08b := TFont():New( "Times New Roman",,08,,.t.,,,,,.f.,.f. )
			oFont09  := TFont():New( "Times New Roman",,09,,.f.,,,,,.f.,.f. )
			oFont10  := TFont():New( "Times New Roman",,10,,.f.,,,,,.f.,.f. )
			oFont10b := TFont():New( "Times New Roman",,10,,.t.,,,,,.f.,.f. )
			oFont10b := TFont():New( "Times New Roman",,10,,.t.,,,,,.f.,.f. )
			oFont11  := TFont():New( "Times New Roman",,11,,.f.,,,,,.f.,.f. )
			oFont11b := TFont():New( "Times New Roman",,11,,.t.,,,,,.f.,.f. )
			oFont12  := TFont():New( "Times New Roman",,12,,.f.,,,,,.f.,.f. )
			oFont12b := TFont():New( "Times New Roman",,12,,.t.,,,,,.f.,.f. )
			oFont13b := TFont():New( "Times New Roman",,13,,.t.,,,,,.f.,.f. )
			oFont14  := TFont():New( "Times New Roman",,14,,.f.,,,,,.f.,.f. )
			oFont24b := TFont():New( "Times New Roman",,24,,.t.,,,,,.f.,.f. )
			// Mostra a tela de Setup
			oPrint:Setup()
			oPrint:SetPortrait()
			oPrint:SetPaperSize(9)       ///(DMPAPER_A4)
			//while !SF2->(EOF())                               .AND. ; 
			while !SF1->(EOF())                                 .AND. ;
					SF1->F1_FILIAL         == xFilial("SF1")    .AND. ;
					AllTrim(SF1->F1_SERIE) == AllTrim(MV_PAR01) .AND. ;
					AllTrim(SF1->F1_DOC)   <= AllTrim(MV_PAR03)
				xDestinatario := ""
				xCGC          := ""
				MMEMO1        := ""              ///Relativo ao envio
				MMEMO2        := ""              ///Retorno da SEFAZ
				MNFE_CHV      := ""
				MID_EVENTO    := ""
				MTPEVENTO     := ""
				MSEQEVENTO    := ""
				MAMBIENTE     := ""
				MDATE_EVEN    := ""
				MTIME_EVEN    := ""
				MVERSAO       := ""
				MVEREVENTO    := ""
				MVERTPEVEN    := ""
				MVERAPLIC     := ""
				MCORGAO       := ""
				MCSTATEVEN    := ""
				MCMOTEVEN     := ""
				MPROTOCOLO    := ""
				cChvNfe       := SF1->F1_CHVNFE			//SF2->F2_CHVNFE
				dEmissao      := SF1->F1_EMISSAO		//SF2->F2_EMISSAO
				if empty(cChvNfe)
					//MsgStop("Atencao! Nota Fiscal " + SF2->F2_DOC + "  " + SF2->F2_SERIE + " não e eletrônica ou foi inutilizada!") 
					MsgStop("Atencao! Nota Fiscal " + SF1->F1_DOC + "  " + SF1->F1_SERIE + " não e eletrônica ou foi inutilizada!")
					dbSelectArea("SF1")
					SF1->(dbSetOrder(1))
					SF1->(dbSkip())
					Loop
				endif
				//If AllTrim(SF2->F2_TIPO) $ "D/B" 
				if AllTrim(SF1->F1_TIPO) $ "D/B"
					dbSelectArea("SA2")
					SA2->(dbSetOrder(1))
					SA2->(MsSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,.T.,.F.))
					xDestinatario := SA2->A2_NOME
					If !empty(SA2->A2_CGC)
						xCGC := IIF(len(SA2->A2_CGC) > 11 , TRANSF(SA2->A2_CGC,"@R 99.999.999/9999-99"), TRANSF(SA2->A2_CGC,"@R 999.999.999-99") )
					endif
				else
					dbSelectArea("SA2")
					SA2->(dbSetOrder(1))
					SA2->(MsSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,.T.,.F.))
					xDestinatario := SA2->A2_NOME
					If !empty(SA2->A2_CGC)
						xCGC := IIF(len(SA2->A2_CGC) > 11 , TRANSF(SA2->A2_CGC,"@R 99.999.999/9999-99") , TRANSF(SA2->A2_CGC,"@R 999.999.999-99") )
					endif
				endif
				///
				///TOP 1 - para pegar sempre a ultima carta de correção da nf-e
				///
				//cQry := "SELECT TOP 1 ID_EVENTO,TPEVENTO,SEQEVENTO,AMBIENTE,DATE_EVEN,TIME_EVEN,VERSAO,VEREVENTO,VERTPEVEN,VERAPLIC,CORGAO,CSTATEVEN,CMOTEVEN,"
				cQry := "SELECT ID_EVENTO,TPEVENTO,SEQEVENTO,AMBIENTE,DATE_EVEN,TIME_EVEN,VERSAO,VEREVENTO,VERTPEVEN,VERAPLIC,CORGAO,CSTATEVEN,CMOTEVEN,"
				cQry += "PROTOCOLO,NFE_CHV,ISNULL(CONVERT(VARCHAR(2024),CONVERT(VARBINARY(2024),XML_ERP)),'') AS TMEMO1,"
				cQry += "ISNULL(CONVERT(VARCHAR(2024),CONVERT(VARBINARY(2024),XML_RET)),'') AS TMEMO2 "
				cQry += "FROM SPED150 (NOLOCK) "
				cQry += "WHERE NFE_CHV = '"+cChvNfe+"' AND STATUS = 6 AND D_E_L_E_T_ = '' "
				// Incluido por Júlio Soares em 08/07/2013 para imprimir sempre a ultima sequencia do envio da carta -  verificar o mesmo tratamento na linha 455
				cQry += "AND (SELECT MAX(SEQEVENTO) FROM SPED150 (NOLOCK) WHERE NFE_CHV = '"+cChvNfe+"') = SEQEVENTO"
				cQry += "ORDER BY LOTE DESC"
				cQry := ChangeQuery(cQry)
				//Trecho adicionado por Adriano Leonardo em 25/09/2013 para tratamento da conexão - Tabela SPED150 em outro ODBC
					//Seta o TopConn atual				                               
					tcSetConn(nHErp)   //Neste momento faço com que o sistema permaneca na base atual que o usuario logou 
					//Seto a nova conexão que desejo utilizar
					nHndOra := TcLink(cDBTSS,cSrvTSS,7890)
					//Verifica o status da conexão
					if nHndOra < 0
						Msgstop("Falha na conexão na base SPED150, informar o Administrador do Sistema!",_cRotina+"_001")
						return
					endif
					if Select(_cTMP) > 0
						(_cTMP)->(dbCloseArea())
					endif
					dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQry), _cTMP, .T., .T.)
					//Final do trecho adicionado por Adriano Leonardo em 25/09/2013 para tratamento da conexão - Tabela SPED150 em outro ODBC
					TcSetField(_cTMP,"DATE_EVEN","D",08,0)
					dbSelectArea(_cTMP)
					(_cTMP)->(dbGoTop())
					if !(_cTMP)->(EOF())
						MMEMO1     := (_cTMP)->TMEMO1     ///Relativo ao envio
						MMEMO2     := (_cTMP)->TMEMO2     ///Retorno da SEFAZ
						MNFE_CHV   := (_cTMP)->NFE_CHV
						MID_EVENTO := (_cTMP)->ID_EVENTO
						MTPEVENTO  := STR((_cTMP)->TPEVENTO,6)
						MSEQEVENTO := STR((_cTMP)->SEQEVENTO,1)
						MAMBIENTE  := STR((_cTMP)->AMBIENTE,1)+IIF((_cTMP)->AMBIENTE==1," - Producao", IIF((_cTMP)->AMBIENTE==2," - Homologacao" , ""))
						MDATE_EVEN := DTOC((_cTMP)->DATE_EVEN)
						MTIME_EVEN := (_cTMP)->TIME_EVEN
						MVERSAO    := STR((_cTMP)->VERSAO,4,2)
						MVEREVENTO := STR((_cTMP)->VEREVENTO,4,2)
						MVERTPEVEN := STR((_cTMP)->VERTPEVEN,4,2)
						MVERAPLIC  := (_cTMP)->VERAPLIC
						MCORGAO    := STR((_cTMP)->CORGAO,2)+IIF((_cTMP)->CORGAO==13 , " - AMAZONAS",IIF((_cTMP)->CORGAO==35 , " - SAO PAULO" , ""))
						MCSTATEVEN := STR((_cTMP)->CSTATEVEN,3)
						MCMOTEVEN  := (_cTMP)->CMOTEVEN
						MPROTOCOLO := STR((_cTMP)->PROTOCOLO,15)
					else
						MsgStop("Atencao! Não existe Carta de Correção para a Nota Fiscal " + SF2->F2_DOC + "  " + SF2->F2_SERIE + " informada!")
						//dbSelectArea("SF2")
						dbSelectArea("SF1")
						SF1->(dbSetOrder(1))
						SF1->(dbSkip())
						Loop
					endif
					if Select(_cTMP) > 0
						(_cTMP)->(dbCloseArea())
					endif            
					//Trecho adicionado por Adriano Leonardo em 25/09/2013 para tratamento da conexão - Tabela SPED150 em outro ODBC
					//Restauro a conexão original
					//tcSetConn(nHErp)
					//Encerro a conexão temporária
					//TcUnlink(nHndOra)
					//Final do trecho adicionado por Adriano Leonardo em 25/09/2013 para tratamento da conexão - Tabela SPED150 em outro ODBC
					xFone   := RTRIM(SM0->M0_TEL)
					xFone   := STRTRAN(xFone,"(","")
					xFone   := STRTRAN(xFone,")","")
					xFone   := STRTRAN(xFone,"-","")
					xFone   := STRTRAN(xFone," ","")
					*
					xFax    := RTRIM(SM0->M0_FAX)
					xFax    := STRTRAN(xFax,"(","")
					xFax    := STRTRAN(xFax,")","")
					xFax    := STRTRAN(xFax,"-","")
					xFax    := STRTRAN(xFax," ","")
					*
					xRazSoc := RTRIM(SM0->M0_NOMECOM)
					xEnder  := RTRIM(SM0->M0_ENDENT) + " - " + RTRIM(SM0->M0_BAIRENT) + " - " + RTRIM(SM0->M0_CIDENT) + "/" + SM0->M0_ESTENT
					xFone   := "Fone / Fax: " + TRANSF(xFone,"@R (99)9999-9999") + IIF(!empty(SM0->M0_FAX) , " / " + TRANSF(xFax,"@R (99)9999-9999") , "" )
					xCnpj   := "C.N.P.J.: "   + TRANSF(SM0->M0_CGC,"@R 99.999.999/9999-99")
					xIE     := "I.Estadual: " + SM0->M0_INSC
					////
					////Extrai dados do Memo
					////
					MDHEVENTO := ""
					iw1 := AT("<dhRegEvento>" , MMEMO2 )
					iw2 := AT("</dhRegEvento>" , MMEMO2 )
					if ( iw1 > 0 )
						iw3 := ( iw2 - iw1 )
						MDHEVENTO += SUBS(MMEMO2 , ( iw1+13 ) , ( iw2 - ( iw1 + 13 ) ) )
					endif
					*
					MDESCEVEN := ""
					iw1 := AT("<xEvento>" , MMEMO2 )
					iw2 := AT("</xEvento>" , MMEMO2 )
					if ( iw1 > 0 )
						iw3 := ( iw2 - iw1 )
						MDESCEVEN += SUBS(MMEMO2 , ( iw1+9 ) , ( iw2 - ( iw1 + 9 ) ) )
					endif
					*
					aCorrec   := {}
					MCORRECAO := ""
					iw1 := AT("<xCorrecao>" , MMEMO1 )
					iw2 := AT("</xCorrecao>" , MMEMO1 )
					if ( iw1 > 0 )
						iw3 := ( iw2 - iw1 )
						MCORRECAO += SUBS(MMEMO1 , ( iw1+11 ) , ( iw2 - ( iw1 + 11 ) ) ) 
						MCORRECAO += SPACE(10)
						iw1 := 1
						while !empty(SUBS(MCORRECAO,iw1,10))
							AADD(aCorrec , SUBS(MCORRECAO,iw1,100) )
							iw1 += 100     ///Nro de caracteres da linha - fica a criterio
						enddo
					endif
					*
					aCondic   := {}
					MCONDICAO := ""
					iw1       := AT("<xCondUso>" , MMEMO1 )
					iw2       := AT("</xCondUso>" , MMEMO1 )
					if ( iw1 > 0 )
						///As linha comentadas abaixo retirei pois não achei bom qdo impressa
						///
						///iw3 := ( iw2 - iw1 )
						///MCONDICAO += SUBS(MMEMO1 , ( iw1+10 ) , ( iw2 - ( iw1 + 10 ) ) )
						///MCONDICAO += SPACE(10)
						///iw1 := 1
						///DO while !empty(SUBS(MCONDICAO,iw1,10))
						///	AADD(aCondic , SUBS(MCONDICAO,iw1,137) )  
						///	iw1 += 137     ///Nro de caracteres da linha
						///enddo
	 					AADD(aCondic , "A Carta de Correção e disciplinada pelo parágrafo 1°-A do art. 7o do Convênio S/N, de 15 de dezembro de 1970 e pode ser utilizada para" )
						AADD(aCondic , "regularização  de  erro ocorrido na  emissão de  documento  fiscal, desde que o erro não esteja relacionado com:  I - as variáveis que" )
						AADD(aCondic , "determinam o valor do imposto tais como: base de cálculo, alíquota, diferença de preço, quantidade, valor da operação ou da prestação;" )
						AADD(aCondic , "II - a correção de dados cadastrais que implique mudanca do remetente ou do destinatario; III - a data de emissão ou de saída.        " )
					endif
					// Inicia uma nova pagina
					oPrint:StartPage()
					oPrint:SetFont(oFont24b)
					// Imprime o cabeçalho
					// oPrint:SayBitMap(100,115,xBitMap,600,280)
					oPrint:Box(100,050,390,1750)
					oPrint:Say(120,050,xRazSoc                                               ,oFont13b,140)
					oPrint:Say(180,050,xEnder                                                ,oFont11 ,140)
					oPrint:Say(230,050,xFone                                                 ,oFont11 ,140)
					oPrint:Say(280,050,xCnpj                                                 ,oFont11 ,140)
					oPrint:Say(330,050,xIE                                                   ,oFont11 ,140)
	                /*
					oPrint:Box(100,1800,390,2400)
					oPrint:Line(150,1800,150,2400)
					oPrint:Say(104,2000,"Carta de Correcao"                                  ,oFont11b,160)
					oPrint:Say(170,1920,"Serie: "      + SF1->F1_SERIE                       ,oFont11b,100)
					oPrint:Say(240,1920,"N.Fiscal: "   + SF1->F1_DOC                         ,oFont11b,100)
					oPrint:Say(310,1920,"Dt.Emissao: " + DTOC(SF1->F1_EMISSAO)               ,oFont11b,100)
	                */
					oPrint:Box(100,1800,390,2300)
					oPrint:Line(150,1800,150,2300)
					oPrint:Say(104,1850,"Carta de Correção"                                  ,oFont11b,160)
					oPrint:Say(170,1850,"Serie: "      + SF1->F1_SERIE                       ,oFont11b,100)
					oPrint:Say(240,1850,"N.Fiscal: "   + SF1->F1_DOC                         ,oFont11b,100)
					oPrint:Say(310,1850,"Dt.Emissão: " + DTOC(SF1->F1_EMISSAO)               ,oFont11b,100)
	                /*
					oPrint:Box(420,045,2000,2400)
					oPrint:Say(440,050,"Tipo do evento"                                      ,oFont12b,100)
					oPrint:Say(440,850,"Data e hora"                                         ,oFont12b,100)
					oPrint:Say(440,1800,"Protocolo"                                          ,oFont12b,100)
					oPrint:Say(490,050,"Carta de Correção NFe"                               ,oFont11 ,100)
					oPrint:Say(490,850,MDATE_EVEN+"  "+MTIME_EVEN                            ,oFont11 ,140)
					oPrint:Say(490,1800,MPROTOCOLO                                           ,oFont11 ,140)
	                */
					oPrint:Box(420,045,2000,2300)                                            
					oPrint:Say(440,055,"Tipo do evento"                                      ,oFont12b,100)
					oPrint:Say(440,500,"Data e hora"                                         ,oFont12b,100)			
					oPrint:Say(440,875,"Protocolo"                                           ,oFont12b,100)			
					oPrint:Say(490,055,"Carta de Correção NFe"                               ,oFont11 ,100)
					oPrint:Say(490,500,MDATE_EVEN+"  "+MTIME_EVEN                            ,oFont11 ,140)
					oPrint:Say(490,875,MPROTOCOLO                                            ,oFont11 ,140)
					//Imprime código de barras
					oPrint:Box(420,1250,575,2300)
					MSBAR("INT25",4.25,11.75,Alltrim(MNFE_CHV),oPrint,.F.,NIL,.T.,0.021,0.85,NIL,NIL,NIL,.F.,,)
					oPrint:Line(575,045,575,2300)
				    /*            
					oPrint:Say(580,050,"Identificacao do destinatario"                       ,oFont11b,200)
					oPrint:Say(580,1600,"CNPJ/CPF"                                           ,oFont11b,200)
					oPrint:Say(630,050,xDestinatario                                         ,oFont11b,800)
					oPrint:Say(630,1600,xCGC                                                 ,oFont11b,260)                
	                */
		            // Imprime  quadro Identificação do destinatário
					oPrint:Say(585,055,"Identificação do destinatário"                       ,oFont11b,200)
					oPrint:Say(585,1600,"CNPJ/CPF"                                           ,oFont11b,200)
					oPrint:Say(635,055,xDestinatario                                         ,oFont11b,800)
					oPrint:Say(635,1600,xCGC                                                 ,oFont11b,260)
		            oPrint:Line(730,045,730,2300)
	                /*
					oPrint:Say(740,050,"DADOS DO EVENTO DA CARTA DE CORRECAO"                ,oFont11b,250)
					oPrint:Say(800,050,"Versão do evento"                                    ,oFont11b,100)
					oPrint:Say(800,670,"Id evento"                                           ,oFont11b,100)
					oPrint:Say(800,1800,"Tipo do evento"                                     ,oFont11b,100)
					oPrint:Say(850,050,MVERSAO                                               ,oFont11 ,080)
					oPrint:Say(850,670,MID_EVENTO                                            ,oFont11 ,400)
					oPrint:Say(850,1800,MTPEVENTO                                            ,oFont11 ,120)
					oPrint:Say(940,050 ,"Identificacao do ambiente"                          ,oFont11b,140)
					oPrint:Say(940,670 ,"Codigo do orgao de recepcao do evento"              ,oFont11b,240)
					oPrint:Say(940,1430,"Chave de acesso da NF-e vinculada ao evento"        ,oFont11b,250)
					oPrint:Say(990,050,MAMBIENTE                                             ,oFont11 ,080)
					oPrint:Say(990,670,MCORGAO                                               ,oFont11 ,240)
					oPrint:Say(990,1430,MNFE_CHV                                             ,oFont11 ,880)
					oPrint:Say(1050,050,"Data e hora do recebimento do evento"               ,oFont11b,400)
					oPrint:Say(1050,1430,"Sequencial do evento"                              ,oFont11b,100)
					oPrint:Say(1050,1800,"Versao do tipo do evento"                          ,oFont11b,200)
					oPrint:Say(1100,050,MDHEVENTO                                            ,oFont11 ,200)
					oPrint:Say(1100,1430,MSEQEVENTO                                          ,oFont11 ,020)
					oPrint:Say(1100,1800,MVERTPEVEN                                          ,oFont11 ,200)
					oPrint:Say(1170,050,"Versao do aplicativo que"                           ,oFont11b,100)
					oPrint:Say(1210,050,"recebeu o evento"                                   ,oFont11b,100)
					oPrint:Say(1170,670,"Codigo de status do registro do evento"             ,oFont11b,300)
					oPrint:Say(1170,1430,"Descricao literal do status de registro do evento" ,oFont11b,300)
					oPrint:Say(1260,050,MVERAPLIC                                            ,oFont11 ,080)
					oPrint:Say(1220,670,MCSTATEVEN                                           ,oFont11 ,060)
					oPrint:Say(1220,1430,MCMOTEVEN                                           ,oFont11 ,300)
					oPrint:Say(1340,050,"Descricao do evento"                                ,oFont11b,100)
					oPrint:Say(1390,050,MDESCEVEN                                            ,oFont11 ,100)
					///Deixei um gap de 4 linhas para o texto - se o texto for maior terá que alterar a linha onde comeca a Condicao de Uso
	                */
		            // Imprime quadro dos dados do evento
					oPrint:Say(740,055,"DADOS DO EVENTO DA CARTA DE CORRECAO"                ,oFont11b,250)
					oPrint:Say(800,055,"Versão do evento"                                    ,oFont11b,100)
					oPrint:Say(800,650,"Id evento"                                           ,oFont11b,100)
					oPrint:Say(800,1780,"Tipo do evento"                                     ,oFont11b,100)
					oPrint:Say(850,055,MVERSAO                                               ,oFont11 ,080)
					oPrint:Say(850,650,MID_EVENTO                                            ,oFont11 ,400)
					oPrint:Say(850,1780,MTPEVENTO                                            ,oFont11 ,120)
					oPrint:Say(940,055 ,"Identificacao do ambiente"                          ,oFont11b,140)
					oPrint:Say(940,650 ,"Codigo do orgao de recepcao do evento"              ,oFont11b,240)
					oPrint:Say(940,1400,"Chave de acesso da NF-e vinculada ao evento"        ,oFont11b,250)
					oPrint:Say(990,055,MAMBIENTE                                             ,oFont11 ,080)
					oPrint:Say(990,650,MCORGAO                                               ,oFont11 ,240)
					oPrint:Say(990,1400,MNFE_CHV                                             ,oFont11 ,880)
					oPrint:Say(1050,055,"Data e hora do recebimento do evento"               ,oFont11b,400)
					oPrint:Say(1050,1400,"Sequencial do evento"                              ,oFont11b,100)
					oPrint:Say(1050,1780,"Versao do tipo do evento"                          ,oFont11b,200)
					oPrint:Say(1100,055,MDHEVENTO                                            ,oFont11 ,200)
					oPrint:Say(1100,1400,MSEQEVENTO                                          ,oFont11 ,020)
					oPrint:Say(1100,1780,MVERTPEVEN                                          ,oFont11 ,200)
					oPrint:Say(1170,055,"Versao do aplicativo que"                           ,oFont11b,100)
					oPrint:Say(1210,055,"recebeu o evento"                                   ,oFont11b,100)
					oPrint:Say(1170,650,"Codigo de status do registro do evento"             ,oFont11b,300)
					oPrint:Say(1170,1400,"Descricao literal do status de registro do evento" ,oFont11b,300)
					oPrint:Say(1260,055,MVERAPLIC                                            ,oFont11 ,080)
					oPrint:Say(1220,650,MCSTATEVEN                                           ,oFont11 ,060)
					oPrint:Say(1220,1400,MCMOTEVEN                                           ,oFont11 ,300)
					oPrint:Say(1340,055,"Descricao do evento"                                ,oFont11b,100)
					oPrint:Say(1390,055,MDESCEVEN                                            ,oFont11 ,100)
					///Deixei um gap de 4 linhas para o texto - se o texto for maior terá que alterar a linha onde comeca a Condicao de Uso
		            oPrint:Line(1450,045,1450,2300)
	                /*
					oPrint:Say(1450,050,"Texto da Carta de Correcao",oFont11b ,300)
					nLin := 1450
					for iw1:=1 to len(aCorrec)
						 nLin += 50
						 oPrint:Say(nLin,050,aCorrec[iw1],oFont11 ,2000)
					next
	                */
		            // Imprime o texto da carta de correção
					oPrint:Say(1500,055,"Texto da Carta de Correção",oFont11b,300)
					nLin := 1500
					for iw1 := 1 to len(aCorrec)
						nLin += 50
						// oPrint:Say(nLin,050,aCorrec[iw1],oFont11 ,2000)
						oPrint:Say(nLin,055,aCorrec[iw1],oFont11 ,1700)
					next
					oPrint:Line(1675,045,1675,2300)
	                /*
					oPrint:Say(1700,050,"Condicoes de uso",oFont11b ,100)
					nLin := 1700
					for iw2:=1 to len(aCondic)
						 nLin += 50
						 oPrint:Say(nLin,050,aCondic[iw2],oFont11 ,2000)
					next
	                */
			        // Imprime condições de uso
					oPrint:Say(1700,055,"Condições de uso",oFont11b ,100)
					nLin := 1700
					for iw2 := 1 to len(aCondic)
						nLin += 50
						oPrint:Say(nLin,055,aCondic[iw2],oFont11 ,1800)
					next
	                /*
					//Alteração específica para CLiente Arcolor para inserção de quadros específicos no rodapé da impressão.
					oPrint:Box(2020,045,2200,2400) //Box Dizeres específico
					oPrint:Box(2200,045,2500,1400) //Box "ATENCIOSAMENTE"
					oPrint:Box(2500,045,2800,1400) //Box "ACUSAMOS O ..."
					oPrint:Box(2200,1400,2800,2200) //Box "Observações" ALTERADO
					oPrint:Line(2425,150,2425,1350) //Linha do Carimbo e assinatura.
					oPrint:Line(2725,150,2725,650) //Linha local e data
					oPrint:Line(2725,750,2725,1350) //Linha Carimbo e assinatura
					oPrint:Say(2040,110," Para evitar-se qualquer sanção fiscal, solicitamos acusarem o recebimento desta, na cópia que a acompanha, devendo a via de ",oFont11 ,100)
					oPrint:Say(2090,110," V.S.(as) ficar arquivada juntamente com o documento fiscal em questão. ",oFont11 ,100)
					oPrint:Say(2205,120," ATENCIOSAMENTE ",oFont11 ,100)
					oPrint:Say(2450,500," Carimbo e assinatura",oFont11 ,100)
					oPrint:Say(2505,110," ACUSAMOS O RECEBIMENTO DA 1 VIA ",oFont11b ,100)
					oPrint:Say(2750,300," local e data ",oFont11 ,100)
					oPrint:Say(2750,920," Carimbo e assinatura ",oFont11 ,100)
					oPrint:Say(2210,1415," Observações",oFont11b ,100)	        
					//Fim do trecho inserido.		
					*/
					//Alteração específica para CLiente Arcolor para inserção de quadros específicos no rodapé da impressão.
						oPrint:Box(2020,045,2200,2300)  //Box Dizeres específico
						oPrint:Box(2200,045,2500,1400)  //Box "ATENCIOSAMENTE"
						oPrint:Box(2500,045,2800,1400)  //Box "ACUSAMOS O ..."
						oPrint:Box(2200,1400,2800,2300) //Box "Observações"
						oPrint:Line(2425,150,2425,1350) //Linha do Carimbo e assinatura.
						oPrint:Line(2725,150,2725,650)  //Linha local e data
						oPrint:Line(2725,750,2725,1350) //Linha Carimbo e assinatura
						oPrint:Say(2040,050, " Para evitar-se qualquer sanção fiscal, solicitamos acusarem o recebimento desta, na cópia que a acompanha, devendo a via de ",oFont11 ,100)
						oPrint:Say(2090,050, " V.S.(as) ficar arquivada juntamente com o documento fiscal em questão. ",oFont11 ,100)
						oPrint:Say(2205,120, " ATENCIOSAMENTE ",oFont11 ,100)
						oPrint:Say(2450,500, " Carimbo e assinatura",oFont11 ,100)
						oPrint:Say(2505,110, " ACUSAMOS O RECEBIMENTO DA 1° VIA ",oFont11b ,100)
						oPrint:Say(2750,300, " local e data ",oFont11 ,100)
						oPrint:Say(2750,900, " Carimbo e assinatura ",oFont11 ,100)
						oPrint:Say(2210,1415," Observações:",oFont11b ,100)
				//Fim do trecho inserido.
				oPrint:EndPage()
				dbSelectArea("SF1")
				SF1->(dbSetOrder(1))
				SF1->(dbSkip())
			enddo
			oPrint:Preview()
			//Restauro a conexão original
			tcSetConn(nHErp)
			//Encerro a conexão temporária
			TcUnlink(nHndOra)	
		else
			MsgAlert("Nada a processar!",_cRotina+"_003")
		endif
	//Saída		
	else
		dbSelectArea("SF2")
		SF2->(dbSetOrder(1))
	//	Set SoftSeek ON
		SF2->(MsSeek(xFilial("SF2")+mv_par02+mv_par01,.F.,.F.))
	//	Set SoftSeek OFF
		if !SF2->(EOF())
			// Cria um novo objeto para impressao
			oPrint := TMSPrinter():New("Impressão da Carta de Correção Eletronica - CC-e")
			// Cria os objetos com as configuracoes das fontes
			//                                              Negrito  Subl  Italico
			oFont08  := TFont():New( "Times New Roman",,08,,.f.,,,,,.f.,.f. )
			oFont08b := TFont():New( "Times New Roman",,08,,.t.,,,,,.f.,.f. )
			oFont09  := TFont():New( "Times New Roman",,09,,.f.,,,,,.f.,.f. )
			oFont10  := TFont():New( "Times New Roman",,10,,.f.,,,,,.f.,.f. )
			oFont10b := TFont():New( "Times New Roman",,10,,.t.,,,,,.f.,.f. )
			oFont10b := TFont():New( "Times New Roman",,10,,.t.,,,,,.f.,.f. )
			oFont11  := TFont():New( "Times New Roman",,11,,.f.,,,,,.f.,.f. )
			oFont11b := TFont():New( "Times New Roman",,11,,.t.,,,,,.f.,.f. )
			oFont12  := TFont():New( "Times New Roman",,12,,.f.,,,,,.f.,.f. )
			oFont12b := TFont():New( "Times New Roman",,12,,.t.,,,,,.f.,.f. )
			oFont13b := TFont():New( "Times New Roman",,13,,.t.,,,,,.f.,.f. )
			oFont14  := TFont():New( "Times New Roman",,14,,.f.,,,,,.f.,.f. )
			oFont24b := TFont():New( "Times New Roman",,24,,.t.,,,,,.f.,.f. )
			// Mostra a tela de Setup
			oPrint:Setup()
			oPrint:SetPortrait()
			oPrint:SetPaperSize(9)       ///(DMPAPER_A4)
			while !SF2->(EOF())                               .AND. ;
					SF2->F2_FILIAL         == xFilial("SF2")    .AND. ;
					AllTrim(SF2->F2_SERIE) == AllTrim(MV_PAR01) .AND. ;
					AllTrim(SF2->F2_DOC)   <= AllTrim(MV_PAR03)
				xDestinatario := ""
				xCGC          := ""
				MMEMO1        := ""              ///Relativo ao envio
				MMEMO2        := ""              ///Retorno da SEFAZ
				MNFE_CHV      := ""
				MID_EVENTO    := ""
				MTPEVENTO     := ""
				MSEQEVENTO    := ""
				MAMBIENTE     := ""
				MDATE_EVEN    := ""
				MTIME_EVEN    := ""
				MVERSAO       := ""
				MVEREVENTO    := ""
				MVERTPEVEN    := ""
				MVERAPLIC     := ""
				MCORGAO       := ""
				MCSTATEVEN    := ""
				MCMOTEVEN     := ""
				MPROTOCOLO    := ""
				cChvNfe       := SF2->F2_CHVNFE
				dEmissao      := SF2->F2_EMISSAO
				If empty(cChvNfe)
					MsgStop("Atencao! Nota Fiscal " + SF2->F2_DOC + "  " + SF2->F2_SERIE + " não e eletrônica ou foi inutilizada!")
					dbSelectArea("SF2")
					SF2->(dbSetOrder(1))
					SF2->(dbSkip())
					Loop
				endif
				if AllTrim(SF2->F2_TIPO) $ "D/B"
					dbSelectArea("SA2")
					SA2->(dbSetOrder(1))
					SA2->(MsSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.,.F.))
					xDestinatario := SA2->A2_NOME
					If ( !empty(SA2->A2_CGC) )
						xCGC := IIF(len(SA2->A2_CGC) > 11 , TRANSF(SA2->A2_CGC,"@R 99.999.999/9999-99"), TRANSF(SA2->A2_CGC,"@R 999.999.999-99") )
					endif
				else
					dbSelectArea("SA1")
					SA1->(dbSetOrder(1))
					SA1->(MsSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.,.F.))
					xDestinatario := SA1->A1_NOME
					If ( !empty(SA1->A1_CGC) )
						xCGC := IIF(len(SA1->A1_CGC) > 11 , TRANSF(SA1->A1_CGC,"@R 99.999.999/9999-99") , TRANSF(SA1->A1_CGC,"@R 999.999.999-99") )
					endif
				endif
				///
				///TOP 1 - para pegar sempre a ultima carta de correção da nf-e
				///
				//cQry := "SELECT TOP 1 ID_EVENTO,TPEVENTO,SEQEVENTO,AMBIENTE,DATE_EVEN,TIME_EVEN,VERSAO,VEREVENTO,VERTPEVEN,VERAPLIC,CORGAO,CSTATEVEN,CMOTEVEN,"
				cQry := "SELECT ID_EVENTO,TPEVENTO,SEQEVENTO,AMBIENTE,DATE_EVEN,TIME_EVEN,VERSAO,VEREVENTO,VERTPEVEN,VERAPLIC,CORGAO,CSTATEVEN,CMOTEVEN,"
				cQry += "PROTOCOLO,NFE_CHV,ISNULL(CONVERT(VARCHAR(2024),CONVERT(VARBINARY(2024),XML_ERP)),'') AS TMEMO1,"
				cQry += "ISNULL(CONVERT(VARCHAR(2024),CONVERT(VARBINARY(2024),XML_RET)),'') AS TMEMO2 "
				cQry += "FROM SPED150 (NOLOCK) "
				cQry += "WHERE NFE_CHV = '"+cChvNfe+"' AND STATUS = 6 AND D_E_L_E_T_ = '' "
				// Incluido por Júlio Soares em 08/07/2013 para imprimir sempre a ultima sequencia do envio da carta - verificar o mesmo tratamento na linha 138
				cQry += "AND (SELECT MAX(SEQEVENTO) FROM SPED150 (NOLOCK) WHERE NFE_CHV = '"+cChvNfe+"') = SEQEVENTO "
				cQry += "ORDER BY LOTE DESC"
				cQry := ChangeQuery(cQry)
				//Trecho adicionado por Adriano Leonardo em 25/09/2013 para tratamento da conexão - Tabela SPED150 em outro ODBC
				//Seta o TopConn atual
				tcSetConn(nHErp)   //Neste momento faço com que o sistema permaneca na base atual que o usuario logou 
				//Seto a nova conexão que desejo utilizar
				nHndOra := TcLink(cDBTSS,cSrvTSS,7890)
				//Verifica o status da conexão
				if nHndOra < 0
					MsgStop("Falha na conexão na base SPED150, informar o Administrador do Sistema!",_cRotina+"_001")
					return 				
				endif
				if Select(_cTMP) > 0
					(_cTMP)->(dbCloseArea())
				endif
				dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQry), _cTMP, .T., .T.)
				//Final do trecho adicionado por Adriano Leonardo em 25/09/2013 para tratamento da conexão - Tabela SPED150 em outro ODBC
				//TcSetField(_cTMP,"DATE_EVEN","D",08,0)
			
				dbSelectArea(_cTMP)
				(_cTMP)->(dbGoTop())
				If !(_cTMP)->(EOF())
					MMEMO1     := (_cTMP)->TMEMO1     ///Relativo ao envio
					MMEMO2     := (_cTMP)->TMEMO2     ///Retorno da SEFAZ
					MNFE_CHV   := (_cTMP)->NFE_CHV
					MID_EVENTO := (_cTMP)->ID_EVENTO
					MTPEVENTO  := STR((_cTMP)->TPEVENTO,6)
					MSEQEVENTO := STR((_cTMP)->SEQEVENTO,1)
					MAMBIENTE  := STR((_cTMP)->AMBIENTE,1)+IIF((_cTMP)->AMBIENTE==1," - Producao", IIF((_cTMP)->AMBIENTE==2," - Homologacao" , ""))
					MDATE_EVEN := (_cTMP)->DATE_EVEN
					MTIME_EVEN := (_cTMP)->TIME_EVEN
					MVERSAO    := STR((_cTMP)->VERSAO,4,2)
					MVEREVENTO := STR((_cTMP)->VEREVENTO,4,2)
					MVERTPEVEN := STR((_cTMP)->VERTPEVEN,4,2)
					MVERAPLIC  := (_cTMP)->VERAPLIC
					MCORGAO    := STR((_cTMP)->CORGAO,2)+IIF((_cTMP)->CORGAO==13 , " - AMAZONAS",IIF((_cTMP)->CORGAO==35 , " - SAO PAULO" , ""))
					MCSTATEVEN := STR((_cTMP)->CSTATEVEN,3)
					MCMOTEVEN  := (_cTMP)->CMOTEVEN
					MPROTOCOLO := STR((_cTMP)->PROTOCOLO,15)
				else
					MsgStop("Atencao! Não existe Carta de Correção para a Nota Fiscal " + SF2->F2_DOC + "  " + SF2->F2_SERIE + " informada!")
					dbSelectArea("SF2")
					SF2->(dbSetOrder(1))
					SF2->(dbSkip())
					Loop
				endif
				if Select(_cTMP) > 0
					(_cTMP)->(dbCloseArea())
				endif
				xFone   := RTRIM(SM0->M0_TEL)
				xFone   := STRTRAN(xFone,"(","")
				xFone   := STRTRAN(xFone,")","")
				xFone   := STRTRAN(xFone,"-","")
				xFone   := STRTRAN(xFone," ","")
				*
				xFax    := RTRIM(SM0->M0_FAX)
				xFax    := STRTRAN(xFax,"(","")
				xFax    := STRTRAN(xFax,")","")
				xFax    := STRTRAN(xFax,"-","")
				xFax    := STRTRAN(xFax," ","")
				*
				xRazSoc := RTRIM(SM0->M0_NOMECOM)
				xEnder  := RTRIM(SM0->M0_ENDENT) + " - " + RTRIM(SM0->M0_BAIRENT) + " - " + RTRIM(SM0->M0_CIDENT) + "/" + SM0->M0_ESTENT
				xFone   := "Fone / Fax: " + TRANSF(xFone,"@R (99)9999-9999") + IIF(!empty(SM0->M0_FAX) , " / " + TRANSF(xFax,"@R (99)9999-9999") , "" )
				xCnpj   := "C.N.P.J.: "   + TRANSF(SM0->M0_CGC,"@R 99.999.999/9999-99")
				xIE     := "I.Estadual: " + SM0->M0_INSC
				*
				////
				////Extrai dados do Memo
				////
				MDHEVENTO := ""
				iw1 := AT("<dhRegEvento>"  , MMEMO2 )
				iw2 := AT("</dhRegEvento>" , MMEMO2 )
				IF ( iw1 > 0 )
					iw3 := ( iw2 - iw1 )
					MDHEVENTO += SUBS(MMEMO2 , ( iw1+13 ) , ( iw2 - ( iw1 + 13 ) ) )
				endif
				*
				MDESCEVEN := ""
				iw1 := AT("<xEvento>"  , MMEMO2 )
				iw2 := AT("</xEvento>" , MMEMO2 )
				IF ( iw1 > 0 )
					iw3 := ( iw2 - iw1 )
					MDESCEVEN += SUBS(MMEMO2 , ( iw1+9 ) , ( iw2 - ( iw1 + 9 ) ) )
				endif
				*
				aCorrec   := {}
				MCORRECAO := ""
				iw1 := AT("<xCorrecao>"  , MMEMO1 )
				iw2 := AT("</xCorrecao>" , MMEMO1 )
				if ( iw1 > 0 )
					iw3 := ( iw2 - iw1 )
					MCORRECAO += SUBS(MMEMO1 , ( iw1+11 ) , ( iw2 - ( iw1 + 11 ) ) ) 
					MCORRECAO += SPACE(10)
					iw1 := 1
					while !empty(SUBS(MCORRECAO,iw1,10))
						AADD(aCorrec , SUBS(MCORRECAO,iw1,100) )
						iw1 += 100     ///Nro de caracteres da linha - fica a criterio
					enddo
				endif
				*
				aCondic   := {}
				MCONDICAO := ""
				iw1       := AT("<xCondUso>"  , MMEMO1 )
				iw2       := AT("</xCondUso>" , MMEMO1 )
				if ( iw1 > 0 )
					///As linha comentadas abaixo retirei pois não achei bom qdo impressa
					///
					///iw3 := ( iw2 - iw1 )
					///MCONDICAO += SUBS(MMEMO1 , ( iw1+10 ) , ( iw2 - ( iw1 + 10 ) ) )
					///MCONDICAO += SPACE(10)
					///iw1 := 1
					///DO while !empty(SUBS(MCONDICAO,iw1,10))
					///	AADD(aCondic , SUBS(MCONDICAO,iw1,137) )
					///	iw1 += 137     ///Nro de caracteres da linha
					///enddo
					AADD(aCondic , "A Carta de Correção e disciplinada pelo parágrafo 1°-A do art. 7o do Convênio S/N, de 15 de dezembro de 1970 e pode ser utilizada para" )
					AADD(aCondic , "regularização  de  erro ocorrido na  emissão de  documento  fiscal, desde que o erro não esteja relacionado com:  I - as variáveis que" )
					AADD(aCondic , "determinam o valor do imposto tais como: base de cálculo, alíquota, diferença de preço, quantidade, valor da operação ou da prestação;" )
					AADD(aCondic , "II - a correção de dados cadastrais que implique mudança do remetente ou do destinatário; III - a data de emissão ou de saída.        " )
				endif
				// Inicia uma nova pagina
				oPrint:StartPage()
				oPrint:SetFont(oFont24b)
				*
				oPrint:Box(100,050,390,1775)	
				oPrint:Say(120,075,xRazSoc                                               ,oFont13b,140)
				oPrint:Say(180,075,xEnder                                                ,oFont11 ,140)
				oPrint:Say(230,075,xFone                                                 ,oFont11 ,140)
				oPrint:Say(280,075,xCnpj                                                 ,oFont11 ,140)
				oPrint:Say(330,075,xIE                                                   ,oFont11 ,140)
				*
				oPrint:Box(100,1800,390,2300)
				oPrint:Line(150,1800,150,2300)
				oPrint:Say(104,1850,"Carta de Correção"                                  ,oFont11b,160)
				oPrint:Say(170,1850,"Série: "      + SF2->F2_SERIE                       ,oFont11b,100)
				oPrint:Say(240,1850,"N.Fiscal: "   + SF2->F2_DOC                         ,oFont11b,100)
				oPrint:Say(310,1850,"Dt.Emissão: " + DTOC(SF2->F2_EMISSAO)               ,oFont11b,100)
				*
				oPrint:Box(420,045,2000,2300)                                            
				oPrint:Say(440,055,"Tipo do evento"                                      ,oFont12b,100)
				//oPrint:Say(440,850,"Data e hora"                                         ,oFont12b,100)
				oPrint:Say(440,500,"Data e hora"                                         ,oFont12b,100)			
				//oPrint:Say(440,1800,"Protocolo"                                          ,oFont12b,100)
				oPrint:Say(440,875,"Protocolo"                                           ,oFont12b,100)			
				oPrint:Say(490,055,"Carta de Correção NFe"                               ,oFont11 ,100)
				//oPrint:Say(490,850,MDATE_EVEN+"  "+MTIME_EVEN                            ,oFont11 ,140)
				oPrint:Say(490,500,MDATE_EVEN+"  "+MTIME_EVEN                            ,oFont11 ,140)
				//oPrint:Say(490,1800,MPROTOCOLO                                           ,oFont11 ,140)
				oPrint:Say(490,875,MPROTOCOLO                                            ,oFont11 ,140)
				//Imprime código de barras
				oPrint:Box(420,1250,575,2300)
				MSBAR("INT25",3.75,11.75,Alltrim(MNFE_CHV),oPrint,.F.,NIL,.T.,0.021,0.85,NIL,NIL,NIL,.F.,,)
				oPrint:Line(575,045,575,2300)
				*
	            // Imprime  quadro Identificação do destinatário
				oPrint:Say(585,055,"Identificação do destinatário"                       ,oFont11b,200)
				oPrint:Say(585,1600,"CNPJ/CPF"                                           ,oFont11b,200)
				oPrint:Say(635,055,xDestinatario                                         ,oFont11b,800)
				oPrint:Say(635,1600,xCGC                                                 ,oFont11b,260)
	            oPrint:Line(730,045,730,2300)
	            *
	            // Imprime quadro dos dados do evento
				oPrint:Say(740,055,"DADOS DO EVENTO DA CARTA DE CORRECAO"                ,oFont11b,250)
				oPrint:Say(800,055,"Versão do evento"                                    ,oFont11b,100)
				oPrint:Say(800,650,"Id evento"                                           ,oFont11b,100)
				oPrint:Say(800,1780,"Tipo do evento"                                     ,oFont11b,100)
				oPrint:Say(850,055,MVERSAO                                               ,oFont11 ,080)
				oPrint:Say(850,650,MID_EVENTO                                            ,oFont11 ,400)
				oPrint:Say(850,1780,MTPEVENTO                                            ,oFont11 ,120)
				oPrint:Say(940,055 ,"Identificação do ambiente"                          ,oFont11b,140)
				oPrint:Say(940,650 ,"Código do orgão de recepção do evento"              ,oFont11b,240)
				oPrint:Say(940,1400,"Chave de acesso da NF-e vinculada ao evento"        ,oFont11b,250)
				oPrint:Say(990,055,MAMBIENTE                                             ,oFont11 ,080)
				oPrint:Say(990,650,MCORGAO                                               ,oFont11 ,240)
				oPrint:Say(990,1400,MNFE_CHV                                             ,oFont11 ,880)
				oPrint:Say(1050,055,"Data e hora do recebimento do evento"               ,oFont11b,400)
				oPrint:Say(1050,1400,"Sequencial do evento"                              ,oFont11b,100)
				oPrint:Say(1050,1780,"Versão do tipo do evento"                          ,oFont11b,200)
				oPrint:Say(1100,055,MDHEVENTO                                            ,oFont11 ,200)
				oPrint:Say(1100,1400,MSEQEVENTO                                          ,oFont11 ,020)
				oPrint:Say(1100,1780,MVERTPEVEN                                          ,oFont11 ,200)
				oPrint:Say(1170,055,"Versão do aplicativo que"                           ,oFont11b,100)
				oPrint:Say(1210,055,"recebeu o evento"                                   ,oFont11b,100)
				oPrint:Say(1170,650,"Código de status do registro do evento"             ,oFont11b,300)
				oPrint:Say(1170,1400,"Descrição literal do status de registro do evento" ,oFont11b,300)
				oPrint:Say(1260,055,MVERAPLIC                                            ,oFont11 ,080)
				oPrint:Say(1220,650,MCSTATEVEN                                           ,oFont11 ,060)
				oPrint:Say(1220,1400,MCMOTEVEN                                           ,oFont11 ,300)
				oPrint:Say(1340,055,"Descriçao do evento"                                ,oFont11b,100)
				oPrint:Say(1390,055,MDESCEVEN                                            ,oFont11 ,100)
				///Deixei um gap de 4 linhas para o texto - se o texto for maior terá que alterar a linha onde comeca a Condicao de Uso
	            oPrint:Line(1450,045,1450,2300)
	            *
	            // Imprime o texto da carta de correção
				oPrint:Say(1500,055,"Texto da Carta de Correção",oFont11b,300)
				nLin := 1500
				for iw1 := 1 to len(aCorrec)
					 nLin += 50
					 // oPrint:Say(nLin,050,aCorrec[iw1],oFont11 ,2000)
					 oPrint:Say(nLin,055,aCorrec[iw1],oFont11 ,1700)
				next
				oPrint:Line(1675,045,1675,2300)
				*
		        // Imprime condições de uso
				oPrint:Say(1700,055,"Condições de uso",oFont11b ,100)
				nLin := 1700
				for iw2 := 1 to len(aCondic)
					nLin += 50
					oPrint:Say(nLin,055,aCondic[iw2],oFont11 ,1800)
				next
				//Alteração específica para CLiente Arcolor para inserção de quadros específicos no rodapé da impressão.
					oPrint:Box(2020,045,2200,2300)  //Box Dizeres específico
					oPrint:Box(2200,045,2500,1400)  //Box "ATENCIOSAMENTE"
					oPrint:Box(2500,045,2800,1400)  //Box "ACUSAMOS O ..."
					oPrint:Box(2200,1400,2800,2300) //Box "Observações"
					oPrint:Line(2425,150,2425,1350) //Linha do Carimbo e assinatura.
					oPrint:Line(2725,150,2725,650)  //Linha local e data
					oPrint:Line(2725,750,2725,1350) //Linha Carimbo e assinatura
					oPrint:Say(2040,050, " Para evitar-se qualquer sanção fiscal, solicitamos acusarem o recebimento desta, na cópia que a acompanha, devendo a via de ",oFont11 ,100)
					oPrint:Say(2090,050, " V.S.(as) ficar arquivada juntamente com o documento fiscal em questão. ",oFont11 ,100)
					oPrint:Say(2205,120, " ATENCIOSAMENTE ",oFont11 ,100)
					oPrint:Say(2450,500, " Carimbo e assinatura",oFont11 ,100)
					oPrint:Say(2505,110, " ACUSAMOS O RECEBIMENTO DA 1° VIA ",oFont11b ,100)
					oPrint:Say(2750,300, " local e data ",oFont11 ,100)
					oPrint:Say(2750,900, " Carimbo e assinatura ",oFont11 ,100)
					oPrint:Say(2210,1415," Observações:",oFont11b ,100)	        
				//Fim do trecho inserido.
				oPrint:EndPage()
				dbSelectArea("SF2")
				SF2->(dbSetOrder(1))
				SF2->(dbSkip())
			enddo
			oPrint:Preview()
			//Restauro a conexão original
			tcSetConn(nHErp)
			//Encerro a conexão temporária
			TcUnlink(nHndOra)
			
		else
			MsgAlert("Não há documentos a serem processados.",_cRotina+"_002")
		endif
	endif
	RestArea(aArea)
return
/*/{Protheus.doc} ValidPerg
@description Sub-rotina chamada no programa RESTE008. Verifica a existencia das perguntas criando-as caso seja necessario (caso nao existam).
@author Anderson C. P. Coelho (ALL System Solutions)
@since 17/04/2017
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	local _sArea     := GetArea()
	local aRegs      := {}				//Grupo|Ordem| Pegunt                         | perspa | pereng | VariaVL  | tipo| Tamanho|Decimal| Presel| GSC | Valid         |   var01   | Def01          | DefSPA1 | DefEng1 | CNT01 | var02 | Def02           | DefSPA2 | DefEng2 | CNT02 | var03 | Def03    | DefSPA3 | DefEng3 | CNT03 | var04 | Def04 | DefSPA4 | DefEng4 | CNT04 | var05 | Def05 | DefSPA5 | DefEng5 | CNT05 | F3    | GRPSX5 |
	local _aTam      := {}
	local i          := 0
	local j          := 0
	local _cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()

	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	cPerg := PADR(cPerg,len((_cAliasSX1)->X1_GRUPO))

	_aTam  := TamSx3("F2_SERIE")
	AADD(aRegs,{cPerg,"01","Serie                       ?","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G",""              ,"mv_par01",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""      ,"",""})
	_aTam  := TamSx3("F2_DOC" )
	AADD(aRegs,{cPerg,"02","Da Nota Fiscal              ?","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G",""              ,"mv_par02",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SF2"   ,"",""})
	AADD(aRegs,{cPerg,"03","Ate a Nota Fiscal           ?","","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G","naovazio()"    ,"mv_par03",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SF2"   ,"",""})
	_aTam  := {01,00,"C"}
	aAdd(aRegs,{cPerg,"04","(E) Nfe-ent /(S) Nfe-Said   ?","","","mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G","Pertence('ES')","mv_par04",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""      ,"",""})
	for i := 1 to len(aRegs)
		if !(_cAliasSX1)->(dbSeek(cPerg+aRegs[i,2]))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				for j := 1 to FCount()
					if j <= len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					else
						Exit
					endif
				next
			(_cAliasSX1)->(MsUnLock())
		endif
	next
	RestArea(_sArea)
return
