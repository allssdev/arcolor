#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE _lEnt CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RESTA005  ºAutor  ³Anderson C. P. Coelho º Data ³  09/04/15 º±±
±±º          ³          ºAutor  ³ Júlio Soares         º Data ³  13/05/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina que chama a rotina padrão de recálculo do custo de  º±±
±±º          ³ entrada, para execução posterior da identificação do últimoº±±
±±º          ³ preço de compra do cadastro de produtos.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Alterações realizadas para tratar os documentos de         º±±
±±º          ³ complemento de impostos e preço.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico para a empresa Arcolor.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RESTA005()

Private _cRotina	:= "RESTA005"
Private _cDocIni	:= ""
Private _cDocFim	:= ""
Private _dDtIni 	:= ""
Private _dTdFim 	:= ""

//SetFunName("MATA190")
//MATA190()

If Pergunte("MTA190",.T.)
	If MV_PAR01 == 1
		_cDocIni	:= MV_PAR02
		_cDocFim	:= MV_PAR03
		_dDtIni		:= MV_PAR04
		_dDtFim		:= MV_PAR05
		Processa({ |lEnd| AtuB1_UPRC(@lEnd) },_cRotina + "_001",'Atualizando último custo de compra dos produtos.'+_lEnt+'Por favor aguarde...',.T.)
	EndIf
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtuB1_UPRCºAutor  ³Anderson C. P. Coelho º Data ³  09/04/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processamento de atualização do último custo de entrada no º±±
±±º          ³campo B1_UPRC.                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal.                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AtuB1_UPRC(lEnd)

Local _aSavArea := GetArea()
Local _aSavSB1	:= SB1->(GetArea())
Local _aSavSF1	:= SF1->(GetArea())
Local _aSavSD1	:= SD1->(GetArea())
Local _cQry		:= ""


_cQry += " UPDATE SB1 "
_cQry += " SET B1_UPRC = ROUND(((SD1ATU.D1_CUSTO + ISNULL((	SELECT SUM(SD1C.D1_CUSTO) " + CHR(13) + CHR(10)
_cQry += " 													FROM " + RetSqlName("SD1") + " SD1C WITH (NOLOCK) " + CHR(13) + CHR(10)
_cQry += " 													WHERE  SD1C.D1_FILIAL   = SD1ATU.D1_FILIAL " + CHR(13) + CHR(10)
_cQry += " 													  AND  SD1C.D1_NFORI    = SD1ATU.D1_DOC " + CHR(13) + CHR(10)
_cQry += " 													  AND  SD1C.D1_SERIORI  = SD1ATU.D1_SERIE " + CHR(13) + CHR(10)
_cQry += " 													  AND  SD1C.D1_ITEMORI  = SD1ATU.D1_ITEM " + CHR(13) + CHR(10)
_cQry += " 													  AND  SD1C.D1_COD      = SD1ATU.D1_COD " + CHR(13) + CHR(10)
_cQry += " 													  AND  SD1C.D1_FORNECE  = SD1ATU.D1_FORNECE " + CHR(13) + CHR(10)
_cQry += " 													  AND  SD1C.D1_LOJA     = SD1ATU.D1_LOJA " + CHR(13) + CHR(10)
_cQry += " 													  AND  SD1C.D1_DTDIGIT >= SD1ATU.D1_DTDIGIT " + CHR(13) + CHR(10)
_cQry += " 													  AND  SD1C.D1_CUSTO   <> 0 " + CHR(13) + CHR(10)
_cQry += " 													  AND  SD1C.D1_TIPO    IN ('I','P','C') " + CHR(13) + CHR(10)
_cQry += " 													  AND  SD1C.D_E_L_E_T_ = '' " + CHR(13) + CHR(10)
_cQry += " 													),0)) /  SD1ATU.D1_QUANT), "+cValToChar(TamSx3("B1_UPRC")[02])+") " + CHR(13) + CHR(10)
_cQry += " FROM " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) " + CHR(13) + CHR(10)
_cQry += " 	INNER JOIN " + RetSqlName("SD1") + " SD1ATU  WITH (NOLOCK) ON  " + CHR(13) + CHR(10)
_cQry += " 					SD1ATU.D1_FILIAL = (CASE WHEN SD1ATU.D1_FILIAL = '' THEN '' ELSE (CASE WHEN SB1.B1_FILIAL = '' THEN '" + xFilial("SD1") + "' ELSE SB1.B1_FILIAL END) END) " + CHR(13) + CHR(10)
_cQry += " 					AND D1_COD = SB1.B1_COD "  + CHR(13) + CHR(10)
_cQry += " 					AND SD1ATU.D_E_L_E_T_ = '' "  + CHR(13) + CHR(10)
_cQry += " 	INNER JOIN ( "  + CHR(13) + CHR(10)
_cQry += " 				SELECT SD1.D1_FILIAL, SD1.D1_COD, MAX(SD1.D1_DTDIGIT+'_'+CAST(SD1.R_E_C_N_O_ AS NVARCHAR(999))) REG "  + CHR(13) + CHR(10)
_cQry += " 				FROM " + RetSqlName("SD1") + " SD1 WITH (NOLOCK) "  + CHR(13) + CHR(10)
_cQry += " 					INNER JOIN " + RetSqlName("SF4") + " SF4 WITH (NOLOCK) ON "  + CHR(13) + CHR(10)
_cQry += " 							SF4.F4_FILIAL = (CASE WHEN SF4.F4_FILIAL = '' THEN '' ELSE (CASE WHEN SD1.D1_FILIAL = '' THEN '"+xFilial("SF4")+"' ELSE SD1.D1_FILIAL END) END) "  + CHR(13) + CHR(10)
_cQry += " 						AND SF4.F4_UPRC   = 'S' "  + CHR(13) + CHR(10)
_cQry += " 						AND SF4.F4_CODIGO = SD1.D1_TES "  + CHR(13) + CHR(10)
_cQry += " 						AND SF4.D_E_L_E_T_ = '' "  + CHR(13) + CHR(10)
_cQry += " 				WHERE SD1.D1_CUSTO  <> 0 "  + CHR(13) + CHR(10)
_cQry += " 				  AND SD1.D1_TIPO   IN ('N','D','B') "  + CHR(13) + CHR(10)
_cQry += " 				  AND SD1.D1_DOC     BETWEEN '" + _cDocIni      + "' AND '" + _cDocFim      + "' "  + CHR(13) + CHR(10)
_cQry += " 				  AND SD1.D1_DTDIGIT BETWEEN '" + DTOS(_dDtIni) + "' AND '" + DTOS(_dDtFim) + "' "  + CHR(13) + CHR(10)
_cQry += " 				  AND SD1.D_E_L_E_T_ = '' " + CHR(13) + CHR(10)
_cQry += " 				GROUP BY SD1.D1_FILIAL, SD1.D1_COD " + CHR(13) + CHR(10)
_cQry += " 			) SD1COMP ON SD1COMP.D1_FILIAL = SD1ATU.D1_FILIAL " + CHR(13) + CHR(10)
_cQry += " 					 AND SD1COMP.D1_COD    = SD1ATU.D1_COD " + CHR(13) + CHR(10)
_cQry += " 					 AND SD1COMP.REG       = (SD1ATU.D1_DTDIGIT+'_'+CAST(SD1ATU.R_E_C_N_O_ AS NVARCHAR(999))) "  + CHR(13) + CHR(10)
_cQry += " WHERE SB1.B1_FILIAL  = '" + xFilial("SB1") + "' " + CHR(13) + CHR(10)
_cQry += "   AND SB1.D_E_L_E_T_ = '' "  + CHR(13) + CHR(10)
If TCSQLExec(_cQry) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_002")
EndIf

RestArea(_aSavSB1)
RestArea(_aSavSD1)
RestArea(_aSavSF1)
RestArea(_aSavArea)

Return()
