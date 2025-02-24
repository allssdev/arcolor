#include 'totvs.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
#include 'apwebsrv.ch'
#include 'restful.ch'
#include 'xmlxfun.ch'
#include 'tbiconn.ch'
#include 'fileio.ch'
#include 'ap5mail.ch'

/*/{Protheus.doc} RFINW003
@description Rotina de consumo do web services RFINW002 para a atualização das moedas no Protheus - chamada por RFINW001.
@author Anderson C. P. Coelho
@since 27/08/2018
@version P12.1.17 - 001

@type function
@return array, Array com a moeda consultada.

@see https://allss.com.br
/*/

User Function RFINW003(_nCodMoeda)
	//Variaveis Locais
	Local oCotacaoMoedas 	:= Nil
	Local oXMLCotMoeda		:= Nil
	Local cRetCotMoeda 		:= ""
	Local cAvisos			:= ""
	Local cErros			:= ""
	Local cReplace			:= ""

	Default _nCodMoeda      := 10813	//Codigos: 10813 - Dolar (Compra) | 21620 - Euro (compra) | 21622 - Iene | 

	//Instanciacao do WsClient de Moeda do Fonte WCCotacaoMoedas.prw
	oCotacaoMoedas 	:= WSFachadaWSSGSService():New()

	//Setado o Codigo 10813 respectivo ao Dolar (Compra)
	oCotacaoMoedas:nin0 := _nCodMoeda

	//Verificamos se o metodo getUltimoValorXML do WsClient WSFachadaWSSGSService foi consumido com sucesso
	If oCotacaoMoedas:getUltimoValorXML()

		//Obtem o retorno de cotacao da Moeda no formato XML
		cRetCotMoeda := oCotacaoMoedas:cGetUltimoValorXMLReturn 

		//Utiliza a funcao XmlParser para converter o retorno XML do WS para uma variavel do Tipo Objeto
		oXMLCotMoeda :=  XmlParser(cRetCotMoeda, cReplace, @cErros, @cAvisos)	

		// Se for Cotação Antiga (De outro mês)
		if (oXMLCotMoeda:_RESPOSTA:_SERIE:_DATA:_ANO:TEXT + iif(len(oXMLCotMoeda:_RESPOSTA:_SERIE:_DATA:_MES:TEXT) > 1,oXMLCotMoeda:_RESPOSTA:_SERIE:_DATA:_MES:TEXT, "0" + oXMLCotMoeda:_RESPOSTA:_SERIE:_DATA:_MES:TEXT)) < SUBSTR(DTOS(DATE()-1),1,6)
			return nil
		endif

		//Verifica se houve erro ao consumir o WS
		If Empty(cErros)
/*
			//Obtem a Data da Ultima Cotacao
			dDataCotacao := StoD(oXMLCotMoeda:_RESPOSTA:_SERIE:_DATA:_ANO:TEXT + oXMLCotMoeda:_RESPOSTA:_SERIE:_DATA:_MES:TEXT + oXMLCotMoeda:_RESPOSTA:_SERIE:_DATA:_DIA:TEXT)

			//Obtem o Valor da Ultima Cotacao
			nCotacaoMoeda := Val(StrTran(oXMLCotMoeda:_RESPOSTA:_SERIE:_VALOR:TEXT, ",", "."))

			//Abre o Ordena a Tabela de Moedas - SM2
			dBSelectArea("SM2")
			SM2->(dbSetOrder(1))

			//Verifaca se ja existe ou nao, a Cotacao na Data obtida no consumo do WS
			IIF(dbSeek(FWFilial("SM2") + DtoS(dDataCotacao)),  RecLock("SM2", .F.), RecLock("SM2", .T.)) 

			//Atualiza a Data, Valor (no caso o Dolar e a Moeda 2, mas isso depende da configuracao), e a nao abertura da Tela de Cotacao na entrada do sistema
			SM2->M2_DATA	:= dDataCotacao
			SM2->M2_MOEDA2	:= nCotacaoMoeda
			SM2->M2_INFORM	:= "S"

			//Libera o registro alterado
			SM2->(MsUnLock())
			//Operacao realizada com sucesso
			lAtzDolar := .T.
*/
		EndIf
	EndIf
//Return(lAtzDolar)
return oXMLCotMoeda