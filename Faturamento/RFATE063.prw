#include "Protheus.ch"
#include "RWMake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATE063  ºAutor  º Renan              º Data ³  22/07/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Verificação de Valor Titulos x Notas                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico para a empresa Arcolor.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
       
User function RFATE063(_cPed)

Local _sAlias  := GetArea()
Local _nValSE1 := 0
Local _nValSD2 := 0
Local _cRotina := "RFATE063"
Local _cPedido,_cCliente,_cLoja,_cEmissao

Private cQry := ""
Private lRet := .T.
Private _cTit		:= "Divergencia Valor faturado x Titulos"
Private _cMsg		:= ""
Private _cDestMail	:= GetMV("MV_MAILDFT")			//SuperGetMV("MV_MAILDFT",,"")
Private _cAnexo		:= ""
Private _cFromOri	:= ""
Private _cCco		:= ""
Private _cAssunt	:= "[WF Totvs] Mensagem Automatica - "+_cRotina+"_Divergencia Titulos x NFs"
Private _cDestMsg 	:= ""   
Private _cPrior 	:= "0"
Private _lRCFGM001  := ExistBlock("RCFGM001")

BeginSQL Alias "QRY"
	SELECT SD2.D2_PEDIDO, SD2.D2_DOC, SD2.D2_SERIE, SUM(D2_VALBRUT)as VLRTOTD2, SE1X.VLRTOTE1   
    FROM %table:SD2% SD2 (NOLOCK)
    	INNER JOIN  %table:SF4% AS SF4 (NOLOCK) ON SF4.%NotDel% 				
								 		AND SF4.F4_FILIAL = %xFilial:SF4%
								 		AND SF4.F4_CODIGO = SD2.D2_TES
								 		AND SF4.F4_DUPLIC = 'S' 			    														
 	INNER JOIN (SELECT  SE1.E1_NUM,SE1.E1_PREFIXO,SE1.E1_CLIENTE,SE1.E1_LOJA,SUM(SE1.E1_VLCRUZ) AS VLRTOTE1
 				FROM  %table:SE1% SE1 (NOLOCK)
 				WHERE SE1.E1_FILIAL = %xFilial:SE1%  
 				 // AND SE1.E1_PEDIDO = %exp:_cPed%
 				  AND SE1.%NotDel%
 				GROUP BY  SE1.E1_NUM,SE1.E1_PREFIXO,SE1.E1_CLIENTE,SE1.E1_LOJA
 				) SE1X ON SD2.D2_DOC     = SE1X.E1_NUM
					  AND SD2.D2_CLIENTE = SE1X.E1_CLIENTE
					  AND SD2.D2_LOJA    = SE1X.E1_LOJA
					  AND SD2.D2_SERIE   = SE1X.E1_PREFIXO
					  AND SD2.D2_PEDIDO  = %exp:_cPed%
 		WHERE SD2.D2_FILIAL = %xFilial:SD2% AND SD2.%NotDel%																		
	GROUP BY D2_PEDIDO, SE1X.VLRTOTE1 ,SD2.D2_DOC, SD2.D2_SERIE
EndSql

dbSelectArea("QRY")
ProcRegua(RecCount())
QRY->(dbGoTop())
If !QRY->(EOF())
	_nValSD2 := 0
	_nValSE1 := 0
	While !QRY->(EOF())
		_nValSD2     += QRY->VLRTOTD2
		_nValSE1     += QRY->VLRTOTE1 
		If  _nValSD2 == _nValSE1
			lRet     := .T.
		Else
			_cMsg    := " ATENÇÃO - O Faturamento do pedido '"+ QRY->D2_PEDIDO + "' apresentou divergencias entre os valores Financeiros x Valor total Faturado, estorne o documento de saida e gere novamente para correção do problema!" + CHR(13) + CHR(10) + CHR(13) + CHR(10) + "Somatoria de valores dos Titulos: " + TRANSFORM(_nValSE1,"@E 999,999,999.99")+ CHR(13) + CHR(10) + "Somatoria de valores das Notas Fiscais: " + TRANSFORM(_nValSD2,"@E 999,999,999.99")
			If !Empty(_cDestMail) .AND. _lRCFGM001 
				U_RCFGM001(_cTit,_cMsg,_cDestMail,_cAnexo,_cFromOri,_cCco,_cAssunt) //Chamada da rotina responsável pelo envio de e-mails
			EndIf
			If Select("QRY") > 0
				QRY->(dbCloseArea())
			EndIf
			RestArea(_sAlias)
			lRet := .F.
			Exit
		EndIf
		QRY->(Dbskip())
	Enddo 			 
EndIf	
If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf
RestArea(_sAlias)
return(lRet)
