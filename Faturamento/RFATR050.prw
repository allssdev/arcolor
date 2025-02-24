#include 'totvs.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
#include "topconn.ch"
#include "tbiconn.ch"
#include "RPTDef.ch"
#include "FWPrintSetup.ch"

#define PAD_LEFT    0
#define PAD_RIGHT   1
#define PAD_CENTER  2
#define CLRF CHR(13)+CHR(10)
/*/{Protheus.doc} RFATR050
@description Rotina automática para envio de e-mail de meta de vendas para representantes comerciais, 
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 15/08/2020
@version 1.0
@param _cTipo, , descricao
@type function
/*/
user function RFATR050(_cTipo)
/*COMENTADO ESTA ROTINA PARA EVITAR ENVIO INCORRETOS.
	local   _nAntes  := 2
	local   _dDeData := STOD(SubStr(DTOS(DataValida(dDataBase-_nAntes,.F.)),1,6)+"01")
	local   _dAtData := LastDay(DataValida(dDataBase-_nAntes,.F.),0)

	private _cRotina := "RFATR050"
	private cTitulo  := "Acompanhamento das Metas de Vendas"

	default _cTipo   := "M"

	if type("cNumEmp")=="C"
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "FAT"
	endif

	Processa({|lEnd| ProcMail1(_cTipo,_dDeData,_dAtData,@lEnd)},"["+_cRotina+"] "+cTitulo,"Processando...",.T.)
	//tstFactory()
	//zTeste()
*/
return	
static function ProcMail1(_cTipo,_dDeData,_dAtData,lEnd)
	local   _cAliQry  := GetNextAlias()
	local   _cView    := "%[P12_VIEWPRODUCAO].[dbo].[RFATA050_"+cNumEmp+"]%"
	local   _cMail    := ""
	local   _cAnexo   := ""
	local   _cBCC     := ""
	local   _cHtml    := ""
	local   _cAssunto := cTitulo
	local   cSMTPAddr := SuperGetMv("MV_RELSERV"  ,,"" )		 // Endereco do servidor SMTP
	local   cSMTPPort := SuperGetMv("MV_RELPORS"  ,,587)		 // Porta do servidor SMTP
	local   cUser     := SuperGetMv("MV_RELAUSR"  ,,"" )		 // Usuario que ira realizar a autenticação
	local   cPass     := SuperGetMv("MV_RELAPSW"  ,,"" )		 // Senha do usuario
	local   _cFromOri := "naoresponda@arcolor.com.br"			 //SuperGetMv("MV_RELFROM"  ,,"" )		 // Remetente da mensagem
	local   _lExcAnex := .F.
	local   _lAlert   := .F.
	local   _lHtmlOk  := .F.
	local   _lSSL     := SuperGetMv("MV_RELSSL"   ,,.F.)         // Usa SSL Seguro
	local   _lTLS     := SuperGetMv("MV_RELTLS"   ,,.F.)         // Usa TLS Seguro
	local   _lRegiao  := .F.
	local   _lTipo    := .F.
	local   _lGrupo   := .F.
	local   _lCateg   := .F.
	local   _lProd    := .F.
	local   _oMail    := IIF(ExistBlock("RCFGM001"), nil, TBIMailSender():New())
	local   _aMes     := {}
	local   _dDia     := _dDeData
	local   _nSeq     := 0
	local   _nX       := 0

	while _dDia <= _dAtData
		if aScan(_aMes,RetSem(_dDia)) == 0
			AADD(_aMes,RetSem(_dDia))
		endif
		_dDia++
	enddo
	if ValType(_oMail)=="O"
		FreeObj(@_oMail)
	endif
	if Select(_cAliQry) > 0
		(_cAliQry)->(dbCloseArea())
	endif
	BeginSql Alias _cAliQry
		%noparser%
		SELECT A3_EMAIL, CT_VEND, A3_NOME, CT_DATA, CT_REGIAO, CT_TIPO, CT_GRUPO, CT_CATEGO, CT_PRODUTO, CT_QUANT, CT_VALOR
			 , C5_EMISSAO
			 , (CASE WHEN CT_REGIAO  = '' THEN '' ELSE A1_REGIAO  END) A1_REGIAO
			 , (CASE WHEN CT_TIPO    = '' THEN '' ELSE B1_TIPO    END) B1_TIPO
			 , (CASE WHEN CT_GRUPO   = '' THEN '' ELSE B1_GRUPO   END) B1_GRUPO
			 , (CASE WHEN CT_CATEGO  = '' THEN '' ELSE B1_CATEG   END) B1_CATEG
			 , (CASE WHEN CT_PRODUTO = '' THEN '' ELSE C6_PRODUTO END) C6_PRODUTO
			 , SUM(C6_QTDVEN) C6_QTDVEN, SUM(C6_VALOR) C6_VALOR
		FROM (
				SELECT A3_EMAIL, CT_VEND, A3_NOME, CT_DATA, CT_REGIAO, CT_TIPO, CT_GRUPO, CT_CATEGO, CT_PRODUTO
					 , SUM(CT_QUANT) CT_QUANT, SUM(CT_VALOR) CT_VALOR
				FROM %table:SCT% SCT (NOLOCK)
					INNER JOIN %table:SA3% SA3 (NOLOCK) ON SA3.A3_FILIAL  = %xFilial:SA3% 
													   AND SA3.A3_COD     = CT_VEND 
													   AND (CASE WHEN A3_EMAIL  = '' THEN 0 ELSE 1 END) = 1 
													   AND SA3.%notdel%
				WHERE SCT.CT_FILIAL       = %xFilial:SCT% 
				  AND SCT.CT_MSBLQL       = %Exp:'2'%
				  AND (CASE WHEN CT_VEND  = '' THEN 0 ELSE 1 END) = 1
				  AND SCT.CT_DATA   BETWEEN %Exp:DTOS(_dDeData)% AND %Exp:DTOS(_dAtData)%
				  AND SCT.%notdel%
				GROUP BY A3_EMAIL, CT_VEND, A3_NOME, CT_DATA, CT_REGIAO, CT_TIPO, CT_GRUPO, CT_CATEGO, CT_PRODUTO
			) META
			LEFT OUTER JOIN %Exp:_cView% VDAS ON C5_EMISSAO BETWEEN %Exp:DTOS(_dDeData)% AND CT_DATA
											 AND (	C5_VEND1 = CT_VEND
												OR 
													C5_VEND2 = CT_VEND
												OR 
													C5_VEND3 = CT_VEND
												OR 
													C5_VEND4 = CT_VEND
												OR 
													C5_VEND5 = CT_VEND
												)
											 AND (CASE WHEN CT_REGIAO  = '' OR CT_REGIAO  = A1_REGIAO  THEN 1 ELSE 0 END) = 1
											 AND (CASE WHEN CT_TIPO    = '' OR CT_TIPO    = B1_TIPO    THEN 1 ELSE 0 END) = 1
											 AND (CASE WHEN CT_GRUPO   = '' OR CT_GRUPO   = B1_GRUPO   THEN 1 ELSE 0 END) = 1
											 AND (CASE WHEN CT_CATEGO  = '' OR CT_CATEGO  = B1_CATEG   THEN 1 ELSE 0 END) = 1
											 AND (CASE WHEN CT_PRODUTO = '' OR CT_PRODUTO = C6_PRODUTO THEN 1 ELSE 0 END) = 1
		GROUP BY A3_EMAIL, CT_VEND, A3_NOME, CT_DATA, CT_REGIAO, CT_TIPO, CT_GRUPO, CT_CATEGO, CT_PRODUTO, CT_QUANT, CT_VALOR
				, C5_EMISSAO, A1_REGIAO, B1_TIPO, B1_GRUPO, B1_CATEG, C6_PRODUTO
		ORDER BY CT_VEND, CT_DATA, C5_EMISSAO, CT_REGIAO, CT_TIPO, CT_GRUPO, CT_CATEGO, CT_PRODUTO, A1_REGIAO, B1_TIPO, B1_GRUPO, B1_CATEG, C6_PRODUTO
	EndSql
	dbSelectArea(_cAliQry)
	ProcRegua((_cAliQry)->(RecCount()))
	while !(_cAliQry)->(EOF()) .AND. !lEnd
		//IncProc("Processando vendedor '"+(_cAliQry)->CT_VEND+"'...")
		IncProc("Processando Representante '"+(_cAliQry)->CT_VEND+"'...")
		_nSeq    := 0
		_cVend   := (_cAliQry)->CT_VEND
		_cMail   := AllTrim((_cAliQry)->A3_EMAIL)
		//_cHtml   := "<H2>Acompanhamento de Vendas no período de "+DTOC(_dDeData)+" a "+DTOC(_dAtData)+" - Vendedor: "+AllTrim((_cAliQry)->A3_NOME)+"</H2> "+CLRF

		// Alteração - Fernando Bombardi - ALLSS - 03/03/2022
		//_cHtml   := "<H2>Acompanhamento de Vendas no período de "+DTOC(_dDeData)+" a "+DTOC(_dAtData)+" - Vendedor: "+AllTrim((_cAliQry)->A3_NOME)+CLRF
		_cHtml   := "<H2>Acompanhamento de Vendas no período de "+DTOC(_dDeData)+" a "+DTOC(_dAtData)+" - Representante: "+AllTrim((_cAliQry)->A3_NOME)+CLRF
		// Fim - Fernando Bombardi - ALLSS - 03/03/2022

		_cHtml   += "<BR><BR>"+CLRF
		_cHtml   += "<table border='1' bgcolor='#FFFFFF'> "+CLRF
		_cHtml   += " 	<thead bgcolor='#808080'> "+CLRF
		_cHtml   += " 		<tr border='1'> "+CLRF
		_cHtml   += " 			<th border='1' align='center'>#</th> "+CLRF
		if _lRegiao  := !empty((_cAliQry)->CT_REGIAO)
			_cHtml   += " 			<td border='1' align='center' width='080'>REGIÃO      </td> "+CLRF
		endif
		if _lTipo    := !empty((_cAliQry)->CT_TIPO)
			_cHtml   += " 			<td border='1' align='center' width='050'>TIPO        </td> "+CLRF
		endif
		if _lGrupo   := !empty((_cAliQry)->CT_GRUPO)
			_cHtml   += " 			<td border='1' align='center' width='080'>GRUPO       </td> "+CLRF
		endif
		if _lCateg   := !empty((_cAliQry)->CT_CATEGO)
			_cHtml   += " 			<td border='1' align='center' width='150'>CATEGORIA   </td> "+CLRF
		endif
		if _lProd    := !empty((_cAliQry)->CT_PRODUTO)
			_cHtml   += " 			<td border='1' align='center' width='250'>PRODUTO     </td> "+CLRF
		endif
		_cHtml   += " 			<th border='1' align='center' width='080'>SEMANA   </th> "+CLRF
		_cHtml   += " 			<td border='1' align='center' width='150'>REALIZADO</td> "+CLRF
		_cHtml   += " 			<td border='1' align='center' width='150'>META     </td> "+CLRF
		_cHtml   += " 			<td border='1' align='center' width='150'>SALDO    </td> "+CLRF
		_cHtml   += " 		</tr> "+CLRF
		_cHtml   += " 	</thead> "+CLRF
		_cHtml   += " 	<tbody> "+CLRF
		while !(_cAliQry)->(EOF()) .AND. !lEnd .AND. _cVend == (_cAliQry)->CT_VEND
			_nReal   := 0
			_nMeta   := (_cAliQry)->CT_VALOR
			_nSaldo  := (_cAliQry)->CT_VALOR
			_cRegiao := (_cAliQry)->CT_REGIAO
			_cTipo   := (_cAliQry)->CT_TIPO
			_cGrupo  := (_cAliQry)->CT_GRUPO
			_cCateg  := (_cAliQry)->CT_CATEGO
			_cProd   := (_cAliQry)->CT_PRODUTO
			while !(_cAliQry)->(EOF()) .AND. !lEnd .AND. _cVend == (_cAliQry)->CT_VEND .AND. _cRegiao == (_cAliQry)->CT_REGIAO .AND. _cTipo == (_cAliQry)->CT_TIPO .AND. _cGrupo == (_cAliQry)->CT_GRUPO .AND. _cCateg == (_cAliQry)->CT_CATEGO .AND. _cProd == (_cAliQry)->CT_PRODUTO
				_nMeta  := (_cAliQry)->CT_VALOR
				_nSaldo := (_cAliQry)->CT_VALOR
				for _nX := 1 to len(_aMes)
					_nReal := 0
					while !(_cAliQry)->(EOF()) .AND. !lEnd .AND. _cVend == (_cAliQry)->CT_VEND .AND. _cRegiao == (_cAliQry)->CT_REGIAO .AND. _cTipo == (_cAliQry)->CT_TIPO .AND. _cGrupo == (_cAliQry)->CT_GRUPO .AND. _cCateg == (_cAliQry)->CT_CATEGO .AND. _cProd == (_cAliQry)->CT_PRODUTO .AND. RetSem(STOD((_cAliQry)->C5_EMISSAO)) == _aMes[_nX]
						_nReal  += (_cAliQry)->C6_VALOR
						(_cAliQry)->(dbSkip())
					enddo
					_nSaldo := _nMeta-_nReal
					_nSeq++
					_cHtml   += " 		<tr> "+CLRF
					_cHtml   += " 			<th border='1' valign='top' align='center'>"+cValToChar(_nSeq)+"</th> "+CLRF
					if _lRegiao
						_cHtml   += " 			<td border='1' valign='top' align='left' width='080'>"+_cRegiao+"</td> "+CLRF
					endif
					if _lTipo
						_cHtml   += " 			<td border='1' valign='top' align='center' width='050'>"+_cTipo+"</td> "+CLRF
					endif
					if _lGrupo
						_cHtml   += " 			<td border='1' valign='top' align='left' width='080'>"+_cGrupo+"</td> "+CLRF
					endif
					if _lCateg
						_cHtml   += " 			<td border='1' valign='top' align='left' width='150'>"+_cCateg+"</td> "+CLRF
					endif
					if _lProd
						_cHtml   += " 			<td border='1' valign='top' align='left' width='250'>"+_cProd+"</td> "+CLRF
					endif
					_cHtml   += " 			<th valign='top' align='center' border='1' width='080'>"+cValToChar(_aMes[_nX])+"</th> "+CLRF
				//	_cHtml   += " 			<td valign='top' align='right'  border='1'>"+Transform(_nReal , PesqPictQt("C6_VALOR"))+"</td> "+CLRF
				//	_cHtml   += " 			<td valign='top' align='right'  border='1'>"+Transform(_nMeta , PesqPictQt("CT_VALOR"))+"</td> "+CLRF
				//	_cHtml   += " 			<td valign='top' align='right'  border='1'>"+Transform(_nSaldo, PesqPictQt("CT_VALOR"))+"</td> "+CLRF
					_cHtml   += " 			<td valign='top' align='right'  border='1' width='150'>R$ "+Transform(_nReal , "@E 999,999,999,999.99")+"</td> "+CLRF
					_cHtml   += " 			<td valign='top' align='right'  border='1' width='150'>R$ "+Transform(_nMeta , "@E 999,999,999,999.99")+"</td> "+CLRF
					_cHtml   += " 			<td valign='top' align='right'  border='1' width='150'>R$ "+Transform(_nSaldo, "@E 999,999,999,999.99")+"</td> "+CLRF
					_cHtml   += " 		</tr> "+CLRF
					_nMeta   := _nSaldo
				next
			enddo
		enddo
		_cHtml   += " 	</tbody> "+CLRF
		_cHtml   += "</table> "+CLRF
		_cHtml   += "</H2> <BR> "+CLRF
		_cHtml   := StrTran(_cHtml,CLRF,"")
		_cMail   := "anderson.coelho@allss.com.br;rodrigo.telecio@allss.com.br;marco.mendes@arcolor.com.br"		//TEMPORÁRIO PARA TESTES
		if _oMail == nil
			U_RCFGM001(/*cTitulo*/"",_cHtml,_cMail,_cAnexo,_cFromOri,_cBCC,_cAssunto,_lExcAnex,_lAlert,_lHtmlOk)
		else
			_oMail:setSSL(_lSSL)
			_oMail:setTLS(_lTLS)
			_oMail:setServidor( cSMTPAddr, cSMTPPort )
			_oMail:setConta(_cFromOri)
			_oMail:setUsuario( cUser, cPass)
		//	_oMail:SendMessage(serverSMTP, conta    , autUsuario, autSenha, cto   , assunto  ,corpo ,anexos  )
			_oMail:SendMessage(cSMTPAddr , _cFromOri, cUser     , cPass   , _cMail, _cAssunto,_cHtml,{}      )
		endif
		dbSelectArea(_cAliQry)
	enddo
	if ValType(_oMail)=="O"
		FreeObj(@_oMail)
	endif
	if Select(_cAliQry) > 0
		(_cAliQry)->(dbCloseArea())
	endif
return
/*
static Function tstFactory()
    Local oDlg
    Local oChart
    Local oPanel
    Local oPanel2
    DEFINE DIALOG oDlg TITLE "Teste novos graficos" SIZE 800,800 PIXEL

    oPanel:= TPanel():New( , ,,oDlg,,,,,, 0,  50)
    oPanel:Align := CONTROL_ALIGN_TOP

    oPanel2:= TPanel():New( , ,,oDlg,,,,,, 0,  0)
    oPanel2:Align := CONTROL_ALIGN_ALLCLIENT
    TButton():New( 10, 10, "Refresh",oPanel,{||BtnClick(oChart)},45,15,,,.F.,.T.,.F.,,.F.,,,.F. )
    oChart := FWChartFactory():New()
    oChart:SetOwner(oPanel2)

    //Para graficos multi serie, definir a descricao pelo SetxAxis e passar array no addSerie
    oChart:SetXAxis( {"periodo um", "periodo dois", "periodo tres"} )

    oChart:addSerie('Apresentação teste', {  96, 33, 10 } )
    oChart:addSerie('Qualificação teste', {  100, 33, 10 } )
    oChart:addSerie('Fechamento teste', {  99, 36, 10 } )
    oChart:addSerie('Pós Venda', { 80, 100, 10 } )

    //----------------------------------------------
    //Picture
    //----------------------------------------------
    oChart:setPicture("@E 999,999,999.99")

    //----------------------------------------------
    //Mascara
    //----------------------------------------------
    oChart:setMask("R$ *@*")

    //----------------------------------------------
    //Adiciona Legenda
    //opções de alinhamento da legenda:
    //CONTROL_ALIGN_RIGHT | CONTROL_ALIGN_LEFT |
    //CONTROL_ALIGN_TOP | CONTROL_ALIGN_BOTTOM
    //----------------------------------------------
    oChart:SetLegend(CONTROL_ALIGN_LEFT)

    //----------------------------------------------
    //Titulo
    //opções de alinhamento do titulo:
    //CONTROL_ALIGN_RIGHT | CONTROL_ALIGN_LEFT | CONTROL_ALIGN_CENTER
    //----------------------------------------------
    oChart:setTitle("Titulo do Grafico", CONTROL_ALIGN_CENTER) //"Oportunidades por fase"

    //----------------------------------------------
    //Opções de alinhamento dos labels(disponível somente no gráfico de funil):
    //CONTROL_ALIGN_RIGHT | CONTROL_ALIGN_LEFT | CONTROL_ALIGN_CENTER
    //----------------------------------------------
    oChart:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)

    //Desativa menu que permite troca do tipo de gráfico pelo usuário
    oChart:EnableMenu(.T.)

    //Define o tipo do gráfico
    //oChart:SetChartDefault(FUNNELCHART)
    //oChart:SetChartDefault(RADARCHART)
    oChart:SetChartDefault(NEWLINECHART)
    //-----------------------------------------
    // Opções disponiveis
    // RADARCHART
    // FUNNELCHART 
    // COLUMNCHART 
    // NEWPIECHART 
    // NEWLINECHART
    //-----------------------------------------
    oChart:Activate()
     
    ACTIVATE DIALOG oDlg CENTERED
Return
Static function BtnClick(oChart)
        oChart:DeActivate()
        //Para graficos multi serie, definir a descricao pelo SetxAxis e passar array no addSerie
        oChart:SetXAxis( {"periodo um", "periodo dois", "periodo tres"} )
        oChart:addSerie('WApresentação teste', {  Randomize(1,20), Randomize(1,20), Randomize(1,20) } )
        oChart:addSerie('AQualificação teste', {  Randomize(1,20), Randomize(1,20), Randomize(1,20) } )
        oChart:addSerie('EFechamento teste', {  Randomize(1,20), Randomize(1,20), Randomize(1,20) } )
        oChart:addSerie('BPós Venda', { Randomize(1,20), Randomize(1,20), Randomize(1,20) } )
      oChart:Activate()
Return









Static Function zTeste()
    Local aArea       := GetArea()
    Local cNomeRel    := "rel_teste_"+dToS(Date())+StrTran(Time(), ':', '-')
    Local cDiretorio  := GetTempPath()
    Local nLinCab     := 025
    Local nAltur      := 250
    Local nLargur     := 1050
    Local aRand       := {}
    Private cHoraEx    := Time()
    Private nPagAtu    := 1
    Private oPrintPvt
    //Fontes
    Private cNomeFont  := "Arial"
    Private oFontRod   := TFont():New(cNomeFont, , -06, , .F.)
    Private oFontTit   := TFont():New(cNomeFont, , -20, , .T.)
    Private oFontSubN  := TFont():New(cNomeFont, , -17, , .T.)
    //Linhas e colunas
    Private nLinAtu     := 0
    Private nLinFin     := 820
    Private nColIni     := 010
    Private nColFin     := 550
    Private nColMeio    := (nColFin-nColIni)/2
     
    //Criando o objeto de impressão
    //oPrintPvt := FWMSPrinter():New(cNomeRel, IMP_PDF, .F., cStartPath, .T., , @oPrintPvt, , , , , .T.)
    oPrintPvt := FWMSPrinter():New(cNomeRel, IMP_PDF, .F., , .T., , @oPrintPvt, , , , , .T.)
    oPrintPvt:cPathPDF := GetTempPath()
    oPrintPvt:SetResolution(72)
    oPrintPvt:SetPortrait()
    oPrintPvt:SetPaperSize(DMPAPER_A4)
    oPrintPvt:SetMargin(60, 60, 60, 60)
    oPrintPvt:StartPage()
     
    //Cabeçalho
    oPrintPvt:SayAlign(nLinCab, nColMeio-150, "Relatório Teste de Gráfico", oFontTit, 300, 20, RGB(0,0,255), PAD_CENTER, 0)
    nLinCab += 35
    nLinAtu := nLinCab
     
    //Se o arquivo existir, exclui ele
    If File(cDiretorio+"_grafico.png")
        FErase(cDiretorio+"_grafico.png")
    EndIf
     
    //Cria a Janela
    DEFINE MSDIALOG oDlgChar PIXEL FROM 0,0 TO nAltur,nLargur
        //Instância a classe
        oChart := FWChartBar():New()
          
        //Inicializa pertencendo a janela
        oChart:Init(oDlgChar, .T., .T. )
          
        //Seta o título do gráfico
        oChart:SetTitle("Título", CONTROL_ALIGN_CENTER)
          
        //Adiciona as séries, com as descrições e valores
        oChart:addSerie("Ano 2011", 20044453.50)
        oChart:addSerie("Ano 2012", 21044453.35)
        oChart:addSerie("Ano 2013", 22044453.15)
        oChart:addSerie("Ano 2014", 23044453.10)
        oChart:addSerie("Ano 2015", 25544453.01)
          
        //Define que a legenda será mostrada na esquerda
        oChart:setLegend( CONTROL_ALIGN_LEFT )
          
        //Seta a máscara mostrada na régua
        oChart:cPicture := "@E 999,999,999,999,999.99"
          
        //Define as cores que serão utilizadas no gráfico
        aAdd(aRand, {"084,120,164", "007,013,017"})
        aAdd(aRand, {"171,225,108", "017,019,010"})
        aAdd(aRand, {"207,136,077", "020,020,006"})
        aAdd(aRand, {"166,085,082", "017,007,007"})
        aAdd(aRand, {"130,130,130", "008,008,008"})
          
        //Seta as cores utilizadas
        oChart:oFWChartColor:aRandom := aRand
        oChart:oFWChartColor:SetColor("Random")
          
        //Constrói o gráfico
        oChart:Build()
    ACTIVATE MSDIALOG oDlgChar CENTERED ON INIT (oChart:SaveToPng(0, 0, nLargur, nAltur, cDiretorio+"_grafico.png"), oDlgChar:End())
     
    oPrintPvt:SayBitmap(nLinAtu, nColIni, cDiretorio+"_grafico.png", nLargur/2, nAltur/1.6)
    nLinAtu += nAltur/1.6 + 3
     
    oPrintPvt:SayAlign(nLinAtu, nColIni+020, "Teste FWMSPrinter",                            oFontSubN, 100, 07, , PAD_LEFT, )
     
    //Impressão do Rodapé
    fImpRod()
     
    //Gera o pdf para visualização
    oPrintPvt:Preview()
     
    RestArea(aArea)
Return
 
//*---------------------------------------------------------------------*
//| Func:  fImpRod                                                      |
//| Desc:  Função para impressão do rodapé                              |
//*---------------------------------------------------------------------*
 
Static Function fImpRod()
    Local nLinRod := nLinFin + 10
    Local cTexto  := ""
 
    //Linha Separatória
    oPrintPvt:Line(nLinRod, nColIni, nLinRod, nColFin, RGB(200, 200, 200))
    nLinRod += 3
     
    //Dados da Esquerda
    cTexto := "Relatório Teste    |    "+dToC(dDataBase)+"     "+cHoraEx+"     "+FunName()+"     "+cUserName
    oPrintPvt:SayAlign(nLinRod, nColIni,    cTexto, oFontRod, 250, 07, , PAD_LEFT, )
     
    //Direita
    cTexto := "Página "+cValToChar(nPagAtu)
    oPrintPvt:SayAlign(nLinRod, nColFin-40, cTexto, oFontRod, 040, 07, , PAD_RIGHT, )
     
    //Finalizando a página e somando mais um
    oPrintPvt:EndPage()
    nPagAtu++
Return
*/
