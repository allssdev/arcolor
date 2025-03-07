#include 'protheus.ch'

User function fPutHelp1()
	Local cFilePor  := "SIGAHLP.HLP"
	Local cFileEng  := "SIGAHLE.HLE"
	Local cFileSpa  := "SIGAHLS.HLS"
	Local nRet      := 0

	Local cKey    := "P.RFATR03506."
    Local cHelp := ""
	Local lUpdate := .T.

    cHelp    := "Informe o tipo opera��o a ser           "  
	cHelp    += "considerado, sendo:                     " 
	cHelp    += "  1) Somento Vendas (desconsidera-se os " 
	cHelp    += "     registros que n�o geram financeiro," 
	cHelp    += "     os itenficados como trocas);       " 
	cHelp    += "  2) N�o Vendas (consideram-se aqui     " 
	cHelp    += "     somente as trocas e os registros   " 
	cHelp    += "     que n�o geraram financeiro).       " 
	cHelp    += "  3) Ambos (consideram-se aqui todas os " 
	cHelp    += "     documentos de sa�da com exe��o 	  "
	cHelp    += "     da Opera��o VC).                   " 
	cHelp    += "  4) Consignado (consideram-se aqui	  "
	cHelp    += "     somente as vendas de consigna��o   " 
	cHelp    += "     da opera��o 06) 					  " 
	cHelp    += "  5) Venda consignada (consideram-se    " 
	cHelp    += "     somente o faturamento de  	  	  "
	cHelp    += "     consigna��o da Opera��o VC).       " 
	cHelp    += "*� importante observar que as devolu��es" 
	cHelp    += "n�o s�o aqui consideradas.              " 

	//Se a Chave ou o Help estiverem em branco
	if empty(cKey) .OR. empty(cHelp)
		return
	endif
	//**************************** Portugu�s
	nRet := SPF_SEEK(cFilePor, cKey, 1)
	//Se n�o encontrar, ser� inclus�o
	if nRet < 0
		SPF_INSERT(cFilePor, cKey, , , cHelp)
	//Sen�o, ser� atualiza��o
	else
		if lUpdate
			SPF_UPDATE(cFilePor, nRet, cKey, , , cHelp)
		endif
	endif
	//**************************** Ingl�s
	nRet := SPF_SEEK(cFileEng, cKey, 1)
	//Se n�o encontrar, ser� inclus�o
	if nRet < 0
		SPF_INSERT(cFileEng, cKey, , , cHelp)
	//Sen�o, ser� atualiza��o
	else
		if lUpdate
			SPF_UPDATE(cFileEng, nRet, cKey, , , cHelp)
		endif
	endif
	//**************************** Espanhol
	nRet := SPF_SEEK(cFileSpa, cKey, 1)
	//Se n�o encontrar, ser� inclus�o
	if nRet < 0
		SPF_INSERT(cFileSpa, cKey, , , cHelp)
	//Sen�o, ser� atualiza��o
	else
		if lUpdate
			SPF_UPDATE(cFileSpa, nRet, cKey, , , cHelp)
		endif
	endif
return
