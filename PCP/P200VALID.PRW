#Include "Totvs.ch"

#define _CLRF CHR(13)+CHR(10)
 
User Function P200VALID()
    Local oModel := ParamixB[1]  //Modelo Principal (Mestre)
    Local oDados := ParamixB[2]  //Objeto Json com todas as alterações realizadas na estrutura
    Local lRet   := .T.
    Private _nBasNew := 0
/*
    oDados                                     -> Json com as alterações
    oDados["oLinDel"]                          -> Json com as linhas que foram alteradas (indicando se foi excluída)
    oDados["oLinDel"][<Pai+Comp+Trt>]          -> Se estiver como .T., indica que o componente foi removido durante a execução
    oDados["oLines" ]                          -> Json com as linhas que foram alteradas (com os novos valores que serão gravados)
    oDados["oLines" ][<Pai+Comp+Trt>]          -> Array com os valores que serão salvos em cada campo do campo do cadastro (as posições devem ser resgatadas através do oDados["oFields"])
    oDados["oLines" ][<Pai+Comp+Trt>][<Field>] -> Novo valor para o campo (se não foi alterado, retornará o valor atual)
    oDados["oFields"]                          -> Json com os campos do cadastro para buscar seus respectivos índices do array contido em oDados["oLines"]
    oDados["oFields"][<Field>]                 -> Índice do campo (Field) no array das alterações (oDados["oLines"])
*/
    //Valida o modelo principal (SG1_MASTER)
    If !VldMaster(oModel)
        lRet := .F.
    EndIf
    */
    //Valida os componentes que tiveram alteração
    /*If lRet .And. !VldAlters(oDados)
        lRet := .F.
    EndIf
    */
    VldAlters(oDados)
 
Return lRet
 
//----------------------------------------//
// Valida o modelo principal (SG1_MASTER) //
//----------------------------------------//
Static Function VldMaster(oModel)
    Local lRet := .T.
    
    _nBasNew := oModel:GetModel("SG1_MASTER"):GetValue("NQTBASE")
Return lRet
 
//---------------------------------------------//
// Valida os componentes que tiveram alteração //
//---------------------------------------------//
Static Function VldAlters(oDados)
    Local aLines  := {}
    Local lRet    := .T.
    Local nIndex  := 0
    Local oLinDel := oDados["oLinDel"] //Identifica os componentes que foram excluídos
    Local oLines  := oDados["oLines"]  //Identifica os componentes que foram alterados
    Local oFields := oDados["oFields"] //Campos da grid de componentes
    local _cMail          := ""
    local _cAnexo         := ""
    local _cCC 	          := ""
    local _cBCC           := ""
    local _cHtml          := ""
    local _cAssunto       := ""
    local _cFromOri       := "naoresponda@arcolor.com.br"
    local _lExcAnex       := .F.
    local _lAlert         := .T.
    local _lHtmlOk        := .F.
    


    _cMail          := SuperGetMV("MV_XFRESTR"  ,.F.,'diego.rodrigues@allss.com.br')
    _cCC 	        := SuperGetMV("MV_XCCESTR"  ,.F.,'diego.rodrigues@allss.com.br')
    _cBCC           := SuperGetMV("MV_XBCESTR"  ,.F.,'diego.rodrigues@allss.com.br')


    _cAssunto       := "[Arcolor] - Alteração na estrutura: " + SB1->B1_COD + " "
    _cHtml          := "<h2> Alteração na estrutura: " + SB1->B1_COD + "</h2>" + _CLRF
    _cHtml          += "<h3> Alterado por: " + UsrFullName(__cUserId) + "</h3>" + _CLRF
    If _nBasNew <> SB1->B1_QB
        _cHtml      += "<h4> Quantidade Base alterada de " + cValTochar(SB1->B1_QB) + " para " +cValTochar(_nBasNew)+"</h3>" + _CLRF
    EndIf
    _cHtml          += "<br><br>"                                                                   + _CLRF
    _cHtml          += "<table border='1' bgcolor='#FFFFFF'> "                                      + _CLRF
    _cHtml          += " 	<thead bgcolor='#808080'> "                                             + _CLRF
    _cHtml          += " 		<tr border='1'> "                                                   + _CLRF
    _cHtml          += " 			<th border='1' align='center' width='50'>Código     </th> "    + _CLRF
    _cHtml          += " 			<td border='1' align='center' width='450'>Descrição  </td> "    + _CLRF
    _cHtml          += " 			<td border='1' align='center' width='150'>Nova Quantidade </td> "  + _CLRF
    _cHtml          += " 			<td border='1' align='center' width='150'>Status     </td> "    + _CLRF
    _cHtml          += " 		</tr> "                                                             + _CLRF
    _cHtml          += " 	</thead> "                                                              + _CLRF
    _cHtml          += " 	<tbody> "  

    //Busca todos os componentes que podem ter sido alterados
    aLines := oLines:GetNames()
 
    //Percorre cada componente
    For nIndex := 1 To Len(aLines)
         //Verifica se o componente realmente foi alterado
        If !Empty(oLines[aLines[nIndex]])
            BeginSql Alias "SG1PROD"
                SELECT G1_FILIAL, G1_REVFIM, G1_COD, G1_COMP, G1_QUANT
                FROM %table:SG1% SG1 (NOLOCK)
                WHERE 
                    SG1.G1_FILIAL = %xFilial:SG1%  
                    AND SG1.G1_COD = %exp:oLines[aLines[nIndex]][oFields["G1_COD"]]%
                    AND SG1.D_E_L_E_T_ = ''
                    AND G1_COMP = %exp:oLines[aLines[nIndex]][oFields["G1_COMP"]]%
                GROUP BY G1_FILIAL, G1_REVFIM, G1_COD, G1_COMP,G1_QUANT
                HAVING SG1.G1_REVFIM = (SELECT MAX(G1_REVFIM) FROM %table:SG1% (NOLOCK) WHERE G1_COD = SG1.G1_COD AND D_E_L_E_T_ = '')
            EndSql
            //Verifica se o componente foi removido
            If oLinDel[aLines[nIndex]]
                _cHtml   	    += " <tr> " + _CLRF
                _cHtml   	    += " <th valign='top' align='center' border='1' width='50'>" + oLines[aLines[nIndex]][oFields["G1_COMP"]] + "</th> "    + _CLRF
                _cHtml   	    += " <td valign='top' align='center' border='1' width='450'>" + Posicione("SB1",1,XFILIAL("SB1")+oLines[aLines[nIndex]][oFields["G1_COMP"]],"B1_DESC") + "</td> " + _CLRF
                _cHtml   	    += " <td valign='top' align='center' border='1' width='150'>" + Transform(oLines[aLines[nIndex]][oFields["G1_QUANT"]]   , "@E 999,999,999,999.99") + "</td> " + _CLRF
                _cHtml   	    += " <td valign='top' align='center' border='1' width='150'>" + "Excluido" + "</td> " + _CLRF
                _cHtml   	    += " </tr> " + _CLRF
            EndIf
 
            //Verifica se o componente foi incluido
            If !oLinDel[aLines[nIndex]] .AND. oLines[aLines[nIndex]][oFields["G1_INI"]] == dDataBase .and. if(SG1PROD->(EOF()),.T.,.F.)
                _cHtml   	    += " <tr> " + _CLRF
                _cHtml   	    += " <th valign='top' align='center' border='1' width='50'>" + oLines[aLines[nIndex]][oFields["G1_COMP"]] + "</th> "    + _CLRF
                _cHtml   	    += " <td valign='top' align='center' border='1' width='450'>" + Posicione("SB1",1,XFILIAL("SB1")+oLines[aLines[nIndex]][oFields["G1_COMP"]],"B1_DESC") + "</td> " + _CLRF
                _cHtml   	    += " <td valign='top' align='center' border='1' width='150'>" + Transform(oLines[aLines[nIndex]][oFields["G1_QUANT"]]   , "@E 999,999,999,999.99") + "</td> " + _CLRF
                _cHtml   	    += " <td valign='top' align='center' border='1' width='150'>" + "Incluido" + "</td> " + _CLRF
                _cHtml   	    += " </tr> " + _CLRF
            EndIf

            //Verifica se o componente foi alterado
            If !oLinDel[aLines[nIndex]] .AND. oLines[aLines[nIndex]][oFields["G1_QUANT"]] <> SG1PROD->G1_QUANT .and. oLines[aLines[nIndex]][oFields["G1_REVFIM"]] == cValToChar(STRZERO(Val(SG1PROD->G1_REVFIM)+ 1,3))
                _cHtml   	    += " <tr> " + _CLRF
                _cHtml   	    += " <th valign='top' align='center' border='1' width='50'>" + oLines[aLines[nIndex]][oFields["G1_COMP"]] + "</th> "    + _CLRF
                _cHtml   	    += " <td valign='top' align='center' border='1' width='450'>" + Posicione("SB1",1,XFILIAL("SB1")+oLines[aLines[nIndex]][oFields["G1_COMP"]],"B1_DESC") + "</td> " + _CLRF
                _cHtml   	    += " <td valign='top' align='center' border='1' width='150'>" + Transform(oLines[aLines[nIndex]][oFields["G1_QUANT"]]   , "@E 999,999,999,999.99") + "</td> " + _CLRF
                _cHtml   	    += " <td valign='top' align='center' border='1' width='150'>" + "Alterado" + "</td> " + _CLRF
                _cHtml   	    += " </tr> " + _CLRF
            EndIf
        EndIf
        SG1PROD->(dbCloseArea())
    Next nIndex
    _cHtml += "</table><br>" + _CLRF
    _cHtml := StrTran(_cHtml,_CLRF,"")

    
    lRetMail := U_RCFGM001(/*cTitulo*/"",_cHtml,_cMail,_cAnexo,_cFromOri,_cBCC,_cAssunto,_lExcAnex,_lAlert,_lHtmlOk,_cCC)
    if !lRetMail //Se ocorrer erro uma nova tentativa de envio do e-mail
        U_RCFGM001(/*cTitulo*/"",_cHtml,_cMail,_cAnexo,_cFromOri,_cBCC,_cAssunto,_lExcAnex,_lAlert,_lHtmlOk,_cCC)
    endif
 
Return lRet
