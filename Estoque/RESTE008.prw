#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
#include 'tbiconn.ch'
#include 'shell.ch'
#include 'parmtype.ch'
#include 'fileio.ch'

#define _clrf CHR(13) + CHR(10)

/*/{Protheus.doc} RESTE008
@description Rotina utilizada para o preenchimento automático da GetDados da rotina de transferência entre armazéns, conforme o arquivo CSV importado pelo usuário ou conforme os parâmetros digitados pelo mesmo (conforme chamada da rotina - vide a área de "parâmetros" deste documento). No caso da importação do arquivo CSV, os dados sugeridos para confirmação da transferência serão os mencionados no arquivo. No caso do preenchimento dos parâmetros pelo usuário, a transferência será sugerida inicialmente com a quantidade em estoque (saldo por lote/endereço/saldo atual, conforme o caso) para os produtos selecionados, conforme o seu armazém de origem.
@obs A rotina não está preparada para utilização com produtos que controlem endereçamento.
@author Anderson C. P. Coelho
@since 25/02/2019
@version 1.0
@param _nTp, Numérico, Tipo de rotina, sendo: 1) Importação de CSV; 2) Preenchimento da tela (aCols), conforme preenchimento de parâmetros
@type function
@see https://allss.com.br
@history 22/08/2023, Diego Rodrigues (diego.rodrigues@allss.com.br) - Adequação do fonte para ao transferir do armazem 90 para o 01, a rotina traga a informação correta de endereço do armazem 01.
/*/
user function RESTE008(_nTp)
	local _aSavArea  := GetArea()
	local _aSavSD3   := SD3->(GetArea())
	local _aSavSB1   := SB1->(GetArea())
	local _aSavSB2   := SB2->(GetArea())
	local _aSavSB8   := SB8->(GetArea())
	local _aSavSBF   := SBF->(GetArea())
	local _aSavSBM   := SBM->(GetArea())
	local _aSavNNR   := NNR->(GetArea())
	local _aSavSX1   := SX1->(GetArea())
	local _aSavSX5   := SX5->(GetArea())
	local _cRVarBkp  := __READVAR

	private _nPPrdOr := aScan(aHeader,{|x| UPPER(AllTrim(x[01])) == UPPER('Prod.Orig.'      )})
	private _nPDesOr := aScan(aHeader,{|x| UPPER(AllTrim(x[01])) == UPPER('Desc.Orig.'      )})
	private _nPUMOr  := aScan(aHeader,{|x| UPPER(AllTrim(x[01])) == UPPER('UM Orig.'        )})
	private _nPArmOr := aScan(aHeader,{|x| UPPER(AllTrim(x[01])) == UPPER('Armazem Orig.'   )})
	private _nPLczOr := aScan(aHeader,{|x| UPPER(AllTrim(x[01])) == UPPER('Endereco Orig.'  )})
	private _nPLotOr := aScan(aHeader,{|x| UPPER(AllTrim(x[01])) == UPPER('Lote'            )})
	private _nPValOr := aScan(aHeader,{|x| UPPER(AllTrim(x[01])) == UPPER('Validade'        )})

	private _nPPrdDs := aScan(aHeader,{|x| UPPER(AllTrim(x[01])) == UPPER('Prod.Destino'    )})
	private _nPDesDs := aScan(aHeader,{|x| UPPER(AllTrim(x[01])) == UPPER('Desc.Destino'    )})
	private _nPUMDs  := aScan(aHeader,{|x| UPPER(AllTrim(x[01])) == UPPER('UM Destino'      )})
	private _nPArmDs := aScan(aHeader,{|x| UPPER(AllTrim(x[01])) == UPPER('Armazem Destino' )})
	private _nPLczDs := aScan(aHeader,{|x| UPPER(AllTrim(x[01])) == UPPER('Endereco Destino')})
	private _nPLotDs := aScan(aHeader,{|x| UPPER(AllTrim(x[01])) == UPPER('Lote Destino'    )})
	private _nPValDs := aScan(aHeader,{|x| UPPER(AllTrim(x[01])) == UPPER('Validade Destino')})

	private _nPNSer  := aScan(aHeader,{|x| AllTrim(x[02]) == 'D3_NUMSERI'})
	private _nPNLot  := aScan(aHeader,{|x| AllTrim(x[02]) == 'D3_NUMLOTE'})
	private _nPPot   := aScan(aHeader,{|x| AllTrim(x[02]) == 'D3_POTENCI'})
	private _nPQtd1  := aScan(aHeader,{|x| AllTrim(x[02]) == 'D3_QUANT'  })
	private _nPQtd2  := aScan(aHeader,{|x| AllTrim(x[02]) == 'D3_QTSEGUM'})
//	private _nPEst   := aScan(aHeader,{|x| AllTrim(x[02]) == 'D3_ESTORNO'})
//	private _nPNSeq  := aScan(aHeader,{|x| AllTrim(x[02]) == 'D3_NUMSEQ' })
//	private _nPServ  := aScan(aHeader,{|x| AllTrim(x[02]) == 'D3_SERVIC' })
//	private _nPItGr  := aScan(aHeader,{|x| AllTrim(x[02]) == 'D3_ITEMGRD'})
//	private _nPCodL  := aScan(aHeader,{|x| AllTrim(x[02]) == 'D3_CODLAN' })

	private _cRotina := "RESTE008"
	private cPerg    := _cRotina

	default _nTp     := 1

	if AllTrim(FunName()) == "MATA261" .AND. INCLUI
		if _nTp == 2		//Preechimento do aCols, conforme os parâmetros
			MsgInfo("Atenção! Esta rotina é utilizada para o preenchimento automático dos itens, para a transferência entre armazéns."+CHR(13)+CHR(10)+"Para correto funcionamento, atente a nomenclatura dos campos. Caso hajam divergências, informe imediatamente o administrador do sistema!",_cRotina+"_001")
			ValidPerg()
			if Pergunte(cPerg,.T.) .AND. MsgYesNo("Deseja preencher a Grid com as informações preenchidas no parâmetro informado, neste momento?",_cRotina+"_002")
				Processa( {|lEnd| AtuGetDados(@lEnd) }, "["+_cRotina+"] Rotina de Transferência Automática", "Processando informações...", .T.)
			endif
		elseif _nTp == 1		//Preechimento do aCols, conforme o arquivo CSV
			Pergunte(cPerg,.F.)
			ImpCSVSD3()
		endif
	endif
	__READVAR := _cRVarBkp
	Pergunte("MTA260",.F.)
	RestArea(_aSavNNR)
	RestArea(_aSavSB1)
	RestArea(_aSavSB2)
	RestArea(_aSavSB8)
	RestArea(_aSavSBF)
	RestArea(_aSavSBM)
	RestArea(_aSavSX1)
	RestArea(_aSavSX5)
	RestArea(_aSavSD3)
	RestArea(_aSavArea)
return
/*/{Protheus.doc} AtuGetDados
@description Sub-rotina chamada no programa RESTE008. Processamento da rotina, para o preenchimento automático da GetDados da Transferência entre armazéns (mod.2).
@author Anderson C. P. Coelho (ALL System Solutions)
@since 25/02/2019
@version 1.0
@type function
@see https://allss.com.br
/*/
static function AtuGetDados(lEnd, _DE_LOTE, _PARA_LOTE, _DE_ENDERECO, _PARA_ENDERECO)
//	local   _aSvCols       := aClone(aCols)
	local   _x             := 0

	/*
	Private cDocumento := CriaVar('D3_DOC')
	Private dA261Data  := dDataBase
	Private nOpca      := 0
	Private nPosNSer   := 11
	Private nPosLotCTL := 12
	Private nPosLote   := 13
	Private nPosDValid := 14
	Private nPos261Loc := 05
	Private nPos261Qtd := 16
	Private nPosLotDes := 20	//Lote Destino
	Private nPosDtVldD := 21	//Data Valida de Destino
	Private aCols      := {}
	Private aHeader    := {}
	*/

	default _DE_LOTE       := nil
	default _PARA_LOTE     := nil
	default _DE_ENDERECO   := nil
	default _PARA_ENDERECO := nil
	if !Empty(MV_PAR02) .AND. !Empty(MV_PAR04) .AND. !Empty(MV_PAR06) .AND. !Empty(MV_PAR07) .AND. !Empty(MV_PAR08)
		//VALIDAÇÕES DE INTEGRIDADE DA ROTINA
		if _nPQtd1 == 0
			MsgAlert("Atenção! O campo de Quantidade não foi localizado. Não será possível prosseguir. Informe o administrador, por gentileza!",_cRotina+"_003")
			return
		endif
		if _nPPrdOr == 0
			MsgAlert("Atenção! O campo de Produto de Origem não foi localizado. Não será possível prosseguir. Informe o administrador, por gentileza!",_cRotina+"_004")
			return
		endif
		if _nPArmOr == 0
			MsgAlert("Atenção! O campo de Armazém de Origem não foi localizado. Não será possível prosseguir. Informe o administrador, por gentileza!",_cRotina+"_005")
			return
		endif
		if _nPLotOr == 0
			MsgAlert("Atenção! O campo de Lote de Origem não foi localizado. Não será possível prosseguir. Informe o administrador, por gentileza!",_cRotina+"_006")
			return
		endif
		if _nPLczOr == 0
			MsgAlert("Atenção! O campo de Endereço de Origem não foi localizado. Não será possível prosseguir. Informe o administrador, por gentileza!",_cRotina+"_026")
			return
		endif
		if _nPLczDs == 0
			MsgAlert("Atenção! O campo de Endereço de Destino não foi localizado. Não será possível prosseguir. Informe o administrador, por gentileza!",_cRotina+"_027")
			return
		endif
		if _nPNSer == 0
			MsgAlert("Atenção! O campo de Número de Série não foi localizado. Não será possível prosseguir. Informe o administrador, por gentileza!",_cRotina+"_028")
			return
		endif
		if _nPNLot == 0
			MsgAlert("Atenção! O campo de Número do SubLote não foi localizado. Não será possível prosseguir. Informe o administrador, por gentileza!",_cRotina+"_029")
			return
		endif
		if _nPValOr == 0
			MsgAlert("Atenção! O campo de Validade do Lote de Origem não foi localizado. Não será possível prosseguir. Informe o administrador, por gentileza!",_cRotina+"_007")
			return
		endif
		if _nPPrdDs == 0
			MsgAlert("Atenção! O campo de Produto de Destino não foi localizado. Não será possível prosseguir. Informe o administrador, por gentileza!",_cRotina+"_008")
			return
		endif
		if _nPArmDs == 0
			MsgAlert("Atenção! O campo de Armazém de Destino não foi localizado. Não será possível prosseguir. Informe o administrador, por gentileza!",_cRotina+"_009")
			return
		endif
		if _nPLotDs == 0
			MsgAlert("Atenção! O campo de Lote de Destino não foi localizado. Não será possível prosseguir. Informe o administrador, por gentileza!",_cRotina+"_010")
			return
		endif
		if _nPValDs == 0
			MsgAlert("Atenção! O campo de Validade do Lote de Destino não foi localizado. Não será possível prosseguir. Informe o administrador, por gentileza!",_cRotina+"_011")
			return
		endif
		if !EXISTCPO('NNR',MV_PAR07) .OR. AllTrim(MV_PAR07) == AllTrim(SuperGetMv("MV_CQ",,"98"))
			MsgAlert("Atenção! Problemas no preenchimento do parâmetro 7!",_cRotina+"_012")
			return
		endif
		if !EXISTCPO('NNR',MV_PAR08) .OR. AllTrim(MV_PAR08) == AllTrim(SuperGetMv("MV_CQ",,"98"))
			MsgAlert("Atenção! Problemas no preenchimento do parâmetro 8!",_cRotina+"_013")
			return
		endif
		//if AllTrim(MV_PAR07) == AllTrim(MV_PAR08)
		//	MsgAlert("Atenção! Os armazéns selecionados não podem ser iguais. Preencha os parâmetros corretamente, antes de continuar!",_cRotina+"_014")
		//	return
		//endif
		//MONTAGEM DOS DADOS
		_cQry := ""
		if (_DE_LOTE == nil .OR. empty(_DE_LOTE)) .AND. (_DE_ENDERECO == nil .OR. empty(_DE_ENDERECO))
			_cQry += " SELECT B2_COD D3_COD, B1_DESC D3_DESCRI, B1_UM D3_UM, (B2_QATU-B2_RESERVA-B2_QEMP) D3_QUANT, B1_SEGUM D3_SEGUM, B2_QTSEGUM D3_QTSEGUM, '' D3_LOTECTL, '' D3_NUMLOTE, '' D3_DTVALID, B1_POTENCI D3_POTENCI, '' D3_LOCALIZ, '' D3_NUMSERI " + _clrf
			_cQry += " FROM " + RetSqlName("SB2") + " SB2 (NOLOCK) " + _clrf
			_cQry += "      INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON SB1.D_E_L_E_T_       = '' " + _clrf
			_cQry += "                        AND SB1.B1_FILIAL        = '" + xFilial("SB1") + "' " + _clrf
			_cQry += "                        AND SB1.B1_RASTRO        = 'N' " + _clrf
			_cQry += "                        AND SB1.B1_LOCALIZ      <> 'S' " + _clrf		//NO MOMENTO, ESTAMOS INIBUNDO A UTILIZAÇÃO DA ROTINA QUE CONTROLE RASTREABILIDADE. SE FOR NECESSÁRIO HABILITAR, A ROTINA DEVERÁ SER ALTERADA
			_cQry += "                        AND SB1.B1_MSBLQL       <> '1' "
			_cQry += " 						  AND SB1.B1_COD     BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + _clrf
			_cQry += " 						  AND SB1.B1_TIPO    BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " + _clrf
			_cQry += " 						  AND SB1.B1_GRUPO   BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " + _clrf
			_cQry += " 						  AND SB1.B1_COD           = SB2.B2_COD " + _clrf
			_cQry += " WHERE SB2.D_E_L_E_T_ = '' " + _clrf
			_cQry += "   AND SB2.B2_FILIAL  = '" + xFilial("SB2") + "' " + _clrf
			_cQry += "   AND SB2.B2_LOCAL   = '" + MV_PAR07 + "' " + _clrf
			_cQry += "   AND (SB2.B2_QATU-SB2.B2_RESERVA-SB2.B2_QEMP) > 0 " + _clrf
			_cQry += "  " + _clrf
		endif
		if (_DE_ENDERECO == nil .OR. !empty(_DE_ENDERECO))
			if !empty(_cQry)
				_cQry += " UNION ALL " + _clrf
			endif
			_cQry += "  " + _clrf
			_cQry += " SELECT BF_PRODUTO D3_COD, B1_DESC D3_DESCRI, B1_UM D3_UM, (BF_QUANT-BF_EMPENHO) D3_QUANT, B1_SEGUM D3_SEGUM, BF_QTSEGUM D3_QTSEGUM, BF_LOTECTL D3_LOTECTL, BF_NUMLOTE D3_NUMLOTE, BF_DATAVEN D3_DTVALID, B1_POTENCI D3_POTENCI, BF_LOCALIZ D3_LOCALIZ, BF_NUMSERI D3_NUMSERI " + _clrf
			_cQry += " FROM " + RetSqlName("SBF") + " SBF (NOLOCK) " + _clrf
			_cQry += "      INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON SB1.D_E_L_E_T_       = '' " + _clrf
			_cQry += "                        AND SB1.B1_FILIAL        = '" + xFilial("SB1") + "' " + _clrf
			_cQry += "                        AND SB1.B1_LOCALIZ       = 'S' " + _clrf		//NO MOMENTO, ESTAMOS INIBUNDO A UTILIZAÇÃO DA ROTINA QUE CONTROLE RASTREABILIDADE. SE FOR NECESSÁRIO HABILITAR, A ROTINA DEVERÁ SER ALTERADA
			_cQry += "                        AND SB1.B1_MSBLQL       <> '1' "
			_cQry += " 						  AND SB1.B1_COD     BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + _clrf
			_cQry += " 						  AND SB1.B1_TIPO    BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " + _clrf
			_cQry += " 						  AND SB1.B1_GRUPO   BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " + _clrf
			_cQry += " 						  AND SB1.B1_COD           = SBF.BF_PRODUTO " + _clrf
			_cQry += " WHERE SBF.D_E_L_E_T_ = '' " + _clrf
			_cQry += "   AND SBF.BF_FILIAL  = '" + xFilial("SBF") + "' " + _clrf
			_cQry += "   AND SBF.BF_LOCAL   = '" + MV_PAR07 + "' " + _clrf
			_cQry += "   AND (SBF.BF_QUANT-SBF.BF_EMPENHO) > 0 " + _clrf
			if _DE_LOTE <> nil
				_cQry += "   AND SBF.BF_LOTECTL = '"+_DE_LOTE    +"' " + _clrf
			endif
			if _DE_ENDERECO <> nil
				_cQry += "   AND SBF.BF_LOCALIZ = '"+_DE_ENDERECO+"' " + _clrf
			endif
			_cQry += "  " + _clrf
		endif
		if (_DE_LOTE == nil .OR. !empty(_DE_LOTE))
			if !empty(_cQry)
				_cQry += " UNION ALL " + _clrf
			endif
			_cQry += "  " + _clrf
			_cQry += " SELECT B8_PRODUTO D3_COD, B1_DESC D3_DESCRI, B1_UM D3_UM, (B8_SALDO-B8_EMPENHO) D3_QUANT, B1_SEGUM D3_SEGUM, B8_SALDO2 D3_QTSEGUM, B8_LOTECTL D3_LOTECTL, B8_NUMLOTE D3_NUMLOTE, B8_DTVALID D3_DTVALID, B1_POTENCI D3_POTENCI, '' D3_LOCALIZ, '' D3_NUMSERI " + _clrf
			_cQry += " FROM " + RetSqlName("SB8") + " SB8 (NOLOCK) " + _clrf
			_cQry += "      INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON SB1.D_E_L_E_T_       = '' " + _clrf
			_cQry += "                        AND SB1.B1_FILIAL        = '" + xFilial("SB1") + "' " + _clrf
			_cQry += "                        AND SB1.B1_RASTRO        = 'L' " + _clrf
			_cQry += "                        AND SB1.B1_LOCALIZ      <> 'S' " + _clrf		//NO MOMENTO, ESTAMOS INIBUNDO A UTILIZAÇÃO DA ROTINA QUE CONTROLE RASTREABILIDADE. SE FOR NECESSÁRIO HABILITAR, A ROTINA DEVERÁ SER ALTERADA
			_cQry += "                        AND SB1.B1_MSBLQL       <> '1' "
			_cQry += " 						  AND SB1.B1_COD     BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + _clrf
			_cQry += " 						  AND SB1.B1_TIPO    BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " + _clrf
			_cQry += " 						  AND SB1.B1_GRUPO   BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " + _clrf
			_cQry += " 						  AND SB1.B1_COD           = SB8.B8_PRODUTO " + _clrf
			_cQry += " WHERE SB8.D_E_L_E_T_ = '' " + _clrf
			_cQry += "   AND SB8.B8_FILIAL  = '" + xFilial("SB8") + "' " + _clrf
			_cQry += "   AND SB8.B8_LOCAL   = '" + MV_PAR07 + "' " + _clrf
			_cQry += "   AND (SB8.B8_SALDO-SB8.B8_EMPENHO)   > 0 " + _clrf
			if _DE_LOTE <> nil
				_cQry += "   AND SB8.B8_LOTECTL = '"+_DE_LOTE    +"' " + _clrf
			endif
			_cQry += "  " + _clrf
		endif
		_cQry += " ORDER BY D3_COD, D3_LOCALIZ, D3_NUMSERI, D3_LOTECTL, D3_NUMLOTE, D3_DTVALID, D3_QUANT "
		if __cUserId == "000000"
			MemoWrite(GetTempPath()+_cRotina+"_QRY_001.TXT",_cQry)
		endif
		_cQry := ChangeQuery(_cQry)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"PRODTMP",.F.,.T.)
		dbSelectArea("PRODTMP")
		ProcRegua(PRODTMP->(RecCount()))
		if !PRODTMP->(EOF())
			while !PRODTMP->(EOF()) .AND. !lEnd
				//Se o produto e armazém
				if aScan(aCols,{|x| AllTrim(x[_nPPrdOr])==AllTrim(PRODTMP->D3_COD)             .AND. ;
									AllTrim(x[_nPArmOr])==AllTrim(MV_PAR07)                    .AND. ;
									AllTrim(x[_nPLotOr])==AllTrim(PRODTMP->D3_LOTECTL)         .AND. ;
									AllTrim(x[_nPNLot ])==AllTrim(PRODTMP->D3_NUMLOTE)         .AND. ;
									AllTrim(x[_nPLczOr])==AllTrim(PRODTMP->D3_LOCALIZ)         .AND. ;
									AllTrim(x[_nPNSer ])==AllTrim(PRODTMP->D3_NUMSERI) } ) > 0
					IncProc("Processando...")
					dbSelectArea("PRODTMP")
					PRODTMP->(dbSkip())
					loop
				Else
					IncProc("Incluindo produto " + AllTrim(PRODTMP->D3_COD) + "...")
				endif
				//Crio nova linha vazia no aCols
				_nLin  := len(aCols)
				if !Empty(aCols[_nLin][01])
					AADD(aCols,ARRAY(len(aCols[01])))
					_nLin  := len(aCols)
					for _x := 1 to (len(aHeader)-2)
						aCols[_nLin][_x] := CriaVar(aHeader[_x][02])
					next
					aCols[_nLin][len(aHeader)-1] := "SD3"
					aCols[_nLin][len(aHeader)  ] := 0
					aCols[_nLin][len(aHeader)+1] := MV_PAR09 == 1
				endif
				dbSelectArea("SB2")
				SB2->(dbSetOrder(1))
				if !SB2->(MsSeek(xFilial("SB2") + PRODTMP->D3_COD + MV_PAR08,.T.,.F.))
					CriaSB2(PRODTMP->D3_COD, MV_PAR08)
				endif
				//Informações de Origem
				lAadd                  := .T.
				aCols[_nLin][_nPPrdOr] := M->D3_COD     := cCodOrig := cPrdOrig := PRODTMP->D3_COD
				aCols[_nLin][_nPDesOr] := M->D3_DESCRI  := PRODTMP->D3_DESCRI
				aCols[_nLin][_nPUMOr ] := M->D3_UM      := PRODTMP->D3_UM
				aCols[_nLin][_nPArmOr] := M->D3_LOCAL   := cLocOrig := MV_PAR07
				aCols[_nLin][_nPLotOr] := M->D3_LOTECTL := PRODTMP->D3_LOTECTL
				aCols[_nLin][_nPValOr] := M->D3_DTVALID := STOD(PRODTMP->D3_DTVALID)
				aCols[_nLin][_nPLczOr] := M->D3_LOCALIZ := cLoclzOrig := PRODTMP->D3_LOCALIZ
				 dbSelectArea("CBJ")
				CBJ->(dbSetOrder(1))
				if CBJ->(dbSeek(FwFilial("CBJ") + PRODTMP->D3_COD + MV_PAR08 )) //CBJ_FILIAL+CBJ_CODPRO+CBJ_ARMAZ+CBJ_ENDERE
					cEndDest := CBJ->CBJ_ENDERE
				endif
				//Informações de Destino
				aCols[_nLin][_nPPrdDs] := M->D3_COD     := cCodDest := cPrdDest := PRODTMP->D3_COD
				aCols[_nLin][_nPDesDs] := M->D3_DESCRI  := PRODTMP->D3_DESCRI
				aCols[_nLin][_nPUMDs ] := M->D3_UM      := PRODTMP->D3_UM
				aCols[_nLin][_nPArmDs] := M->D3_LOCAL   := MV_PAR08
				if (_PARA_LOTE <> nil .AND. !empty(_PARA_LOTE))
					aCols[_nLin][_nPLotDs] := M->D3_LOTECTL := _PARA_LOTE
				else
					aCols[_nLin][_nPLotDs] := M->D3_LOTECTL := PRODTMP->D3_LOTECTL
				endif
				aCols[_nLin][_nPValDs] := M->D3_DTVALID := STOD(PRODTMP->D3_DTVALID)
				if (_PARA_ENDERECO <> nil .AND. !empty(_PARA_ENDERECO))
					aCols[_nLin][_nPLczDs] := M->D3_LOCALIZ := cLoclzDest := _PARA_ENDERECO
				else
					//aCols[_nLin][_nPLczDs] := M->D3_LOCALIZ := cLoclzDest := PRODTMP->D3_LOCALIZ
					aCols[_nLin][_nPLczDs] := M->D3_LOCALIZ := cLoclzDest := cEndDest
				endif
				//Demais informações
				aCols[_nLin][_nPNLot ] := M->D3_NUMLOTE := PRODTMP->D3_NUMLOTE
				aCols[_nLin][_nPPot  ] := M->D3_POTENCI := PRODTMP->D3_POTENCI
				aCols[_nLin][_nPNSer ] := M->D3_NUMSERI := cNumSerie := PRODTMP->D3_NUMSERI
				__cReadVar := "M->D3_QUANT"
				aCols[_nLin][_nPQtd1 ] := M->D3_QUANT   := nQuant261 := nQuant := PRODTMP->D3_QUANT
				aCols[_nLin][_nPQtd2 ] := M->D3_QTSEGUM := nQuant2UM := PRODTMP->D3_QTSEGUM
				dbSelectArea("PRODTMP")
				PRODTMP->(dbSkip())
			enddo
		else
			MsgAlert("Nada a Processar!",_cRotina+"_015")
		endif
		PRODTMP->(dbCloseArea())
	else
		MsgAlert("Atenção! Problemas com o preenchimento dos parâmetros.",_cRotina+"_016")
	endif
return
static function ImpCSVSD3()
	Local oGroup1
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSButton1
	Local oSButton2
	Local oSButton3

	Private cDrive, cDir, cNome, cExt
	Private _cArqLog     := GetTempPath()+_cRotina+"_Transf_Prod_"+DTOS(Date())+"_"+StrTran(Time(),":","")+".csv"
	Private cTitulo      := "Transferência de Produtos (CSV)"
	Private cCadastro    := cTitulo
	Private _cArqOri     := ""
	Private _nOpc        := 0
	Private _lProc       := .T.
	Private _aSvAr       := GetArea()
	Private bOk          := { || IIF(!Empty(_cArqOri),_nOpc := 1, _nOpc := 0), IIF(_nOpc == 1,oDlg:End(),MsgAlert("Arquivo não escolhido!",_cRotina+"_017"))                  }
	Private bCancel      := { || oDlg:End()                              }
	Private bDir         := { || _cArqOri := Lower(AllTrim(Lower(SelDirArq()))) }

	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "["+_cRotina+"] "+cTitulo FROM 000, 000  TO 220, 750 COLORS 0, 16777215 PIXEL

	    @ 004, 003 GROUP oGroup1 TO 104, 371 PROMPT " TRANSFERÊCIA (CSV) " OF oDlg COLOR 0, 16777215 PIXEL
	    @ 025, 010 SAY oSay1 PROMPT "Esta rotina é utilizada para a do arquivo CSV contendo os registros dos produtos a serem transferidos.                                   " SIZE 350, 007 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 038, 010 SAY oSay2 PROMPT "                                                                                                                                         " SIZE 350, 007 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 050, 010 SAY oSay3 PROMPT "Após selecionar o arquivo, clique em confirmar.                                                                                          " SIZE 350, 007 OF oDlg COLORS 0, 16777215 PIXEL
	    DEFINE SBUTTON oSButton1 FROM 087, 237 TYPE 14 OF oDlg ENABLE  ACTION Eval(bDir   )
	    DEFINE SBUTTON oSButton2 FROM 087, 280 TYPE 01 OF oDlg ENABLE  ACTION Eval(bOk    )
	    DEFINE SBUTTON oSButton3 FROM 087, 320 TYPE 02 OF oDlg ENABLE  ACTION Eval(bCancel)

	ACTIVATE MSDIALOG oDlg CENTERED
	If _nOpc == 1
		ProcRotIni()
		MsgInfo("Processamento concluído!", _cRotina+"_018")
	EndIf
return
static function SelDirArq()
	local _cTipo := "Arquivos do tipo CSV | *.CSV"
	_cArqOri     := cGetFile(_cTipo, "Selecione o arquivo a ser importado ",0,"C:\",.T.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY)
return(_cArqOri)
static function ProcRotIni()
	If !_lProc .OR. _nOpc <> 1 //.OR. (!MsgYesNo("Confirma a importação do arquivo '" + _cArqOri + "' selecionado?",_cRotina+"_020"))
		MsgStop("Operação cancelada!",_cRotina+"_021")
		//CONOUT("["+_cRotina+"_021] Operação cancelada!")
		_lProc := .F.
	EndIf
	If _lProc
		SplitPath( _cArqOri, @cDrive, @cDir, @cNome, @cExt)
		Processa( { |lEnd| _lProc := ProcArq(@lEnd, (cDrive+cDir+cNome+cExt)) }, "["+_cRotina+"] "+cTitulo, "Processando arquivo " + (cDrive+cDir+cNome+cExt) + "...", .T. )
	EndIf
	RestArea(_aSvAr)
return(_lProc)
static function ProcArq(lEnd,_cArqTxt)
	local   _aMatriz       := {  {"PRODUTO"      ,_nPPrdOr,0},;
								 {"DE_LOCAL"     ,_nPArmOr,0},;
								 {"DE_LOTE"      ,_nPLotOr,0},;
								 {"DE_ENDERECO"  ,_nPLczOr,0},;
								 {"PARA_LOCAL"   ,_nPArmDs,0},;
								 {"PARA_LOTE"    ,_nPLotDs,0},;
								 {"PARA_ENDERECO",_nPLczDs,0} }
	local   _aLinha        := {}
	local   _aTam          := {}
	local   _cLin          := ""
	local   _nLin          := 1
	local   _nPos          := 0
	local   _lGeraLog      := .T.

	local   _DE_LOTE       := nil
	local   _PARA_LOTE     := nil
	local   _DE_ENDERECO   := nil
	local   _PARA_ENDERECO := nil

	private lMsErroAuto  := .F.
	private nHandle      := 0

	default lEnd         := .T.
	default _cArqTxt     := ""

	if File(_cArqLog)
		FErase(_cArqLog)
	endif
	MemoWrite(_cArqLog, "")
	nHandle := fOpen(_cArqLog , FO_READWRITE + FO_SHARED )
	if nHandle == -1
		MsgStop('Erro de abertura do arquivo de log ("'+_cArqLog+'"): FERROR '+str(ferror(),4),_cRotina+"_022")
		_lGeraLog := .F.
	endif
	FT_FUSE(_cArqTxt)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	if _lGeraLog .AND. !FT_FEOF()
		while !FT_FEOF() .AND. !lEnd
			IncProc('Lendo linha ' + cValToChar(_nLin) + ' do arquivo ' + _cArqTxt + '...')
			_cLin   := FT_FREADLN()
			if     ";"$_cLin
				_aLinha := Separa(_cLin,";")
			elseif ","$_cLin
				_aLinha := Separa(_cLin,",")
			elseif "|"$_cLin
				_aLinha := Separa(_cLin,"|")
			else
				if _nLin == 1
					MsgStop("Arquivo com formato indevido. Processamento abortado!",_cRotina+"_023")
				endif
				exit
			endif
			if !empty(_cLin) .AND. len(_aLinha) >= 3
				if _nLin == 1
					for _x := 1 to len(_aLinha)
						_nPos := aScan(_aMatriz,{|x| AllTrim(x[01]) == AllTrim(_aLinha[_x])})
						if _nPos > 0
							_aMatriz[_nPos][03] := _x
						endif
					next
				else
					_aTam          := TamSx3("B1_COD"   )
					MV_PAR01       := Replicate(" ",_aTam[1])
					MV_PAR02       := Replicate(" ",_aTam[1])
					_aTam          := TamSx3("B1_TIPO"  )
					MV_PAR03       := Replicate(" ",_aTam[1])
					MV_PAR04       := Replicate("Z",_aTam[1])
					_aTam          := TamSx3("B1_GRUPO" )
					MV_PAR05       := Replicate(" ",_aTam[1])
					MV_PAR06       := Replicate("Z",_aTam[1])
					_aTam          := TamSx3("B1_LOCPAD" )
					MV_PAR07       := Replicate(" ",_aTam[1])
					MV_PAR08       := Replicate(" ",_aTam[1])
					MV_PAR09       := 2
					_DE_LOTE       := nil
					_PARA_LOTE     := nil
					_DE_ENDERECO   := nil
					_PARA_ENDERECO := nil
					for _x := 1 to len(_aMatriz)
						if _aMatriz[_x][03] > 0
							if AllTrim(_aMatriz[_x][01]) == "PRODUTO"
								MV_PAR01       := MV_PAR02 := Padr(_aLinha[_aMatriz[_x][03]],TamSx3("B1_COD")[1])
							elseif AllTrim(_aMatriz[_x][01]) == "DE_LOCAL"
								MV_PAR07       := Padr(_aLinha[_aMatriz[_x][03]],TamSx3("B1_LOCPAD" )[1])
							elseif AllTrim(_aMatriz[_x][01]) == "PARA_LOCAL"
								MV_PAR08       := Padr(_aLinha[_aMatriz[_x][03]],TamSx3("B1_LOCPAD" )[1])
							elseif AllTrim(_aMatriz[_x][01]) == "DE_LOTE"
								_DE_LOTE       := Padr(_aLinha[_aMatriz[_x][03]],TamSx3("B8_LOTECTL")[1])
							elseif AllTrim(_aMatriz[_x][01]) == "PARA_LOTE"
								_PARA_LOTE     := Padr(_aLinha[_aMatriz[_x][03]],TamSx3("B8_LOTECTL")[1])
							elseif AllTrim(_aMatriz[_x][01]) == "DE_ENDERECO"
								_DE_ENDERECO   := Padr(_aLinha[_aMatriz[_x][03]],TamSx3("BF_LOCALIZ")[1])
							elseif AllTrim(_aMatriz[_x][01]) == "PARA_ENDERECO"
								_PARA_ENDERECO := Padr(_aLinha[_aMatriz[_x][03]],TamSx3("BF_LOCALIZ")[1])
							endif
						endif
					next
					Processa( {|lEnd| AtuGetDados(@lEnd, _DE_LOTE, _PARA_LOTE, _DE_ENDERECO, _PARA_ENDERECO) }, "["+_cRotina+"] Rotina de Transferência (Produto '"+AllTrim(MV_PAR01)+"')", "Processando informações...", .F.)
					if lEnd
						exit
					endif
				endif
			else
				MsgStop("Problemas com a estrutura do arquivo. Processamento abortado!",_cRotina+"_024")
				exit
			endif			
			FT_FSKIP() ; _nLin++
		enddo
	else
		_lProc := .F.
		MsgStop("Arquivo " + _cArqTxt + " vazio ou com problemas. Nada a importar!",_cRotina+"_025")
		//CONOUT("["+_cRotina+"_023] Arquivo " + _cArqTxt + " vazio. Nada a importar!")
	endif
	FT_FUSE()
	fClose(nHandle)                   // Fecha arquivo de log
return(_lProc)
/*/{Protheus.doc} ValidPerg
@description Sub-rotina chamada no programa RESTE008. Verifica a existencia das perguntas criando-as caso seja necessario (caso nao existam).
@author Anderson C. P. Coelho (ALL System Solutions)
@since 25/02/2019
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	local _sArea     := GetArea()
	local aRegs      := {}
	local _aTam      := {}
	local i          := 0
	local j          := 0
	local _cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()

	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	cPerg := PADR(cPerg,len((_cAliasSX1)->X1_GRUPO))

	_aTam := TamSx3("B1_COD"   )
	AAdd(aRegs,{cPerg,"01","Do Produto          ?","","","mv_ch1",_aTam[3],_aTam[1],_aTam[2],0,"G",""                                            ,"mv_par01",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SB1"})
	AAdd(aRegs,{cPerg,"02","Ate o Produto       ?","","","mv_ch2",_aTam[3],_aTam[1],_aTam[2],0,"G","NAOVAZIO()"                                  ,"mv_par02",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SB1"})
	_aTam := TamSx3("B1_TIPO"  )
	AAdd(aRegs,{cPerg,"03","Do Tipo             ?","","","mv_ch3",_aTam[3],_aTam[1],_aTam[2],0,"G",""                                            ,"mv_par03",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","02" })
	AAdd(aRegs,{cPerg,"04","Ate o Tipo          ?","","","mv_ch4",_aTam[3],_aTam[1],_aTam[2],0,"G","NAOVAZIO()"                                  ,"mv_par04",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","02" })
	_aTam := TamSx3("B1_GRUPO" )
	AAdd(aRegs,{cPerg,"05","Do Grupo            ?","","","mv_ch5",_aTam[3],_aTam[1],_aTam[2],0,"G",""                                            ,"mv_par05",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SBM"})
	AAdd(aRegs,{cPerg,"06","Ate o Grupo         ?","","","mv_ch6",_aTam[3],_aTam[1],_aTam[2],0,"G","NAOVAZIO()"                                  ,"mv_par06",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SBM"})
	_aTam := TamSx3("B1_LOCPAD")
	AAdd(aRegs,{cPerg,"07","Armazém ORIGEM      ?","","","mv_ch7",_aTam[3],_aTam[1],_aTam[2],0,"G","NAOVAZIO().AND.EXISTCPO('NNR',MV_PAR07)"     ,"mv_par07",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","NNR"})
	AAdd(aRegs,{cPerg,"08","Armazém DESTINO     ?","","","mv_ch8",_aTam[3],_aTam[1],_aTam[2],0,"G","NAOVAZIO().AND.EXISTCPO('NNR',MV_PAR08)"     ,"mv_par08",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","NNR"})
	_aTam := {01,00,"N"}
	AAdd(aRegs,{cPerg,"09","Traz itens deletados?","","","mv_ch9",_aTam[3],_aTam[1],_aTam[2],0,"C","NAOVAZIO()"                                  ,"mv_par09","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","",""   })
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
