#include 'protheus.ch'

User function fPutHelp1()
	Local cFilePor  := "SIGAHLP.HLP"
	Local cFileEng  := "SIGAHLE.HLE"
	Local cFileSpa  := "SIGAHLS.HLS"
	Local nRet      := 0

	Local cKey    := "P.RFATR03506."
    Local cHelp := ""
	Local lUpdate := .T.

    cHelp    := "Informe o tipo operaÁ„o a ser           "  
	cHelp    += "considerado, sendo:                     " 
	cHelp    += "  1) Somento Vendas (desconsidera-se os " 
	cHelp    += "     registros que n„o geram financeiro," 
	cHelp    += "     os itenficados como trocas);       " 
	cHelp    += "  2) N„o Vendas (consideram-se aqui     " 
	cHelp    += "     somente as trocas e os registros   " 
	cHelp    += "     que n„o geraram financeiro).       " 
	cHelp    += "  3) Ambos (consideram-se aqui todas os " 
	cHelp    += "     documentos de saÌda com exeÁ„o 	  "
	cHelp    += "     da OperaÁ„o VC).                   " 
	cHelp    += "  4) Consignado (consideram-se aqui	  "
	cHelp    += "     somente as vendas de consignaÁ„o   " 
	cHelp    += "     da operaÁ„o 06) 					  " 
	cHelp    += "  5) Venda consignada (consideram-se    " 
	cHelp    += "     somente o faturamento de  	  	  "
	cHelp    += "     consignaÁ„o da OperaÁ„o VC).       " 
	cHelp    += "*… importante observar que as devoluÁıes" 
	cHelp    += "n„o s„o aqui consideradas.              " 

	//Se a Chave ou o Help estiverem em branco
	if empty(cKey) .OR. empty(cHelp)
		return
	endif
	//**************************** Portuguùs
	nRet := SPF_SEEK(cFilePor, cKey, 1)
	//Se nùo encontrar, serù inclusùo
	if nRet < 0
		SPF_INSERT(cFilePor, cKey, , , cHelp)
	//Senùo, serù atualizaùùo
	else
		if lUpdate
			SPF_UPDATE(cFilePor, nRet, cKey, , , cHelp)
		endif
	endif
	//**************************** Inglùs
	nRet := SPF_SEEK(cFileEng, cKey, 1)
	//Se nùo encontrar, serù inclusùo
	if nRet < 0
		SPF_INSERT(cFileEng, cKey, , , cHelp)
	//Senùo, serù atualizaùùo
	else
		if lUpdate
			SPF_UPDATE(cFileEng, nRet, cKey, , , cHelp)
		endif
	endif
	//**************************** Espanhol
	nRet := SPF_SEEK(cFileSpa, cKey, 1)
	//Se nùo encontrar, serù inclusùo
	if nRet < 0
		SPF_INSERT(cFileSpa, cKey, , , cHelp)
	//Senùo, serù atualizaùùo
	else
		if lUpdate
			SPF_UPDATE(cFileSpa, nRet, cKey, , , cHelp)
		endif
	endif
return
