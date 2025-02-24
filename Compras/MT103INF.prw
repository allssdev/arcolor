#include "rwmake.ch"
#include "protheus.ch"
/*/{Protheus.doc} ³MT103INF
Ponto de Entrada chamado na atualização dos itens do Documento de Entrada, através do carregamento da Nota Fiscal
de Saída (Original), para os casos de retorno/devolução. Estamos o utilizando para, quando do processo de devolução/
retorno de documentos de saída, o sistema sobrescreva o TES informado pelo usuário, conforme o TES amarrado como TES de
devolução no TES de Saída.
@author Anderson C. P. Coelho - ALLSS Soluções em Sistemas (anderson.coelho@allss.com.br)
@since 27/04/2015
@version P12.1.33
@type Function
@obs Sem observações
@see https://allss.com.br
@history 27/04/2015, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Versão inicial de rotina.
@history 27/04/2021, Anderson Coelho (anderson.coelho@allss.com.br), Inclusão da CFOP baseado na TES de devolução.
@history 20/05/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Correção para atribuição do CFOP correto de acordo com a origem da operação.
/*/
User Function MT103INF()
Local _aSavArea := GetArea()
Local _aSavSF1  := SF1->(GetArea())
Local _aSavSD1  := SD1->(GetArea())
Local _aSavSF2  := SF2->(GetArea())
Local _aSavSD2  := SD2->(GetArea())
Local _aSavSF4  := SF4->(GetArea())
Local _nLin     := ParamIxb[1]
Local _nPTES    := aScan(aHeader, {|x| AllTrim(x[2])=="D1_TES"    })
Local _nPCF     := aScan(aHeader, {|x| AllTrim(x[2])=="D1_CF"    })
Local _nPNfOri  := aScan(aHeader, {|x| AllTrim(x[2])=="D1_NFORI"  })
Local _nPSrOri  := aScan(aHeader, {|x| AllTrim(x[2])=="D1_SERIORI"})
Local _nPItOri  := aScan(aHeader, {|x| AllTrim(x[2])=="D1_ITEMORI"})
Local _cTesDv   := ""
If _nLin > 0 .AND. _nLin <= Len(aCols) .AND. _nPTES > 0 .AND. _nPNfOri > 0 .AND. _nPSrOri > 0 .AND. _nPItOri > 0
	If !Empty(aCols[_nLin][_nPNfOri]) .AND. !Empty(aCols[_nLin][_nPSrOri]) .AND. !Empty(aCols[_nLin][_nPItOri])
		dbSelectArea("SF4")
		SF4->(dbSetOrder(1))
		If SF4->(MsSeek(xFilial("SF4") + SD2->D2_TES,.T.,.F.))
			_cTesDv := SF4->F4_TESDV
			If !Empty(_cTesDv) .AND. SF4->(MsSeek(xFilial("SF4") + _cTesDv,.T.,.F.)) .AND. SF4->F4_TIPO == "E"
	  			aCols[_nLin][_nPTES] 		:= _cTesDv
				//-------------------------------------------------------------------------
				//INICIO
				//ARCOLOR - CORREÇÃO PARA CORRETA ATRIBUIÇÃO DO CFOP DE ACORDO COM A ORIGEM
				//RODRIGO TELECIO EM 20/05/2022
				//-------------------------------------------------------------------------
				if Upper(AllTrim(cUFOrig)) == "EX" 													//EXTERIOR
					aCols[_nLin][_nPCF] 	:= "3" + SubStr(AllTrim(SF4->F4_CF),2)
				elseif Upper(AllTrim(SuperGetMV("MV_ESTADO",.F.,"SP"))) <> Upper(AllTrim(cUFOrig))	//FORA DO ESTADO
					aCols[_nLin][_nPCF] 	:= "2" + SubStr(AllTrim(SF4->F4_CF),2)
				else																				//DENTRO DO ESTADO
					aCols[_nLin][_nPCF] 	:= "1" + SubStr(AllTrim(SF4->F4_CF),2)
				endif
				//FIM
				//-------------------------------------------------------------------------
	  			MaFisAlt("IT_TES", _cTesDv, _nLin)
				//MaFisToCols(aHeader,aCols,,"MT100")
	  		EndIf
		EndIf
	EndIf
EndIf
RestArea(_aSavSF4)
RestArea(_aSavSD2)
RestArea(_aSavSF2)
RestArea(_aSavSF1)
RestArea(_aSavSD1)
RestArea(_aSavArea)
Return NIL
