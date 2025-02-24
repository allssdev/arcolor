#include 'totvs.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} MT100GE2
@description Ponto de entrada para gravação complementar nos títulos a pagar.
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 03/03/2017
@version 1.0
@type function
@see https://allss.com.br
/*/
user function MT100GE2()
	local   _aSavArea := GetArea()
	local   _aSavSA2  := SA2->(GetArea())
	local   _aSavSA3  := SA3->(GetArea())
	local   _aSavSF1  := SF1->(GetArea())
	local   _aSavSD1  := SD1->(GetArea())
	local   _aSavSE2  := SE2->(GetArea())
//	local   aCols     := PARAMIXB[1]
	local   nOpc      := PARAMIXB[2]
//	local   aHeadSE2  := PARAMIXB[3]
	local   _cRotina  := "MT100GE2"
	local   _cTABABAT := GetNextAlias()
	if nOpc == 1 //Inclusão
		if !SF1->F1_TIPO $ "/D/B/"
			dbSelectArea("SA3")
			if SA3->(dbOrderNickName("A3_FORNECE"))
				if SA3->(MsSeek(xFilial("SA3")+SE2->(E2_FORNECE+E2_LOJA),.T.,.F.)) .AND. AllTrim(UPPER(SA3->A3_GERASE2))=="P"
					if SA3->A3_JUROS > 0
						SE2->E2_PORCJUR	:= SA3->A3_JUROS //SuperGetMv("MV_PJURCOM",,0.7)
					endif
					if Select(_cTABABAT) > 0
						(_cTABABAT)->(dbCloseArea())
					endif
					BeginSql Alias _cTABABAT
						%noparser%
						SELECT MAX(C7_MOTABAT) C7_MOTABAT, SUM(C7_ABATIM) C7_ABATIM
						FROM %table:SC7% SC7 (NOLOCK)
								INNER JOIN %table:SD1% SD1 ON SD1.D1_FILIAL  = %xFilial:SD1%
														  AND SD1.D1_DOC     = %Exp:SE2->E2_NUM%
														  AND SD1.D1_SERIE   = %Exp:SE2->E2_PREFIXO%
														  AND SD1.D1_PEDIDO  = SC7.C7_NUM
														  AND SD1.D1_ITEMPC  = SC7.C7_ITEM
														  AND SD1.D1_FORNECE = SC7.C7_FORNECE
														  AND SD1.D1_LOJA    = SC7.C7_LOJA
														  AND SD1.%NotDel%
						WHERE SC7.C7_FILIAL  = %xFilial:SC7%
						  AND SC7.C7_FORNECE = %Exp:SE2->E2_FORNECE%
						  AND SC7.C7_LOJA    = %Exp:SE2->E2_LOJA%
						  AND SC7.%NotDel%
					EndSql
					dbSelectArea(_cTABABAT)
					if !(_cTABABAT)->(EOF()) .AND. (_cTABABAT)->C7_ABATIM > 0
						SE2->E2_DECRESC += (_cTABABAT)->C7_ABATIM
						SE2->E2_SDDECRE += (_cTABABAT)->C7_ABATIM
						SE2->E2_OBS     := "Motivo ref. abatimento/decréscimo (ref. comissão): " + AllTrim((_cTABABAT)->C7_MOTABAT) + CHR(13)+CHR(10) + SE2->E2_OBS
						SE2->E2_HIST    := "Comissão " + AllTrim(SA3->A3_NOME)
					endif
					if Select(_cTABABAT) > 0
						(_cTABABAT)->(dbCloseArea())
					endif
				endif
			else
				MsgAlert("Atenção! Problemas foram encontrados no sistema. Reporte a seguinte mensagem ao Administrador (sua operação será realizada sem preocupações): "+_cRotina+"_001",_cRotina+"_001")
			endif
		endif
	endif
	RestArea(_aSavSA2)
	RestArea(_aSavSA3)
	RestArea(_aSavSF1)
	RestArea(_aSavSD1)
	RestArea(_aSavSE2)
	RestArea(_aSavArea)
return