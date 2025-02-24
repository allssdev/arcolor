#Include "Protheus.ch"

/*/{Protheus.doc} MT120FIM
    LOCALIZAÇÃO: O ponto se encontra no final da função A120PEDIDO
    EM QUE PONTO: Após a restauração do filtro da FilBrowse depois de fechar a operação realizada no pedido de compras, 
    é a ultima instrução da função A120Pedido.
    @type  Function
    @author user
    @since 08/12/2023
    /*/
User Function MT120FIM()
Local _nOpcA      := PARAMIXB[3]   // Indica se a ação foi Cancelada = 0  ou Confirmada = 1.CODIGO DE APLICAÇÃO DO USUARIO.....
Local _nposCodPrd := aScan(aHeader,{|x|AllTrim(x[02])=="C7_PRODUTO"})
Local _nItPed     := 0

    if (_nOpcA) 
        for _nItPed := 1 to len(aCols) 
            if !(Acols[_nItPed][len(Acols[_nItPed])] == .T.)
                _cCodPrd := aCols[_nItPed][_nposCodPrd]

                dbSelectArea("SA5")
                dbSetOrder(1) //A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO+A5_FABR+A5_FALOJA+A5_REFGRD
                if !dbSeek(FWXFilial("SA5")+cA120Forn+cA120Loj+_cCodPrd)
                    U_RCOMA005(_cCodPrd, cA120Forn, cA120Loj)
                endif
            endif
        next
    endif

    _cUpd:= "UPDATE SA5010 SET "
	_cUpd += "  A5_SITU = 'A' "
	_cUpd += " , A5_SKPLOT = '01' "
    _cUpd += " , A5_TEMPLIM = '1' "
    _cUpd += " , A5_FABREV = '1' "
	_cUpd += "  FROM SA5010 SA5 (NOLOCK) " 
	_cUpd += "  INNER JOIN SB1010 SB1 (NOLOCK) ON SB1.D_E_L_E_T_ = '' AND B1_COD = A5_PRODUTO AND B1_TIPO NOT IN ('MC') AND B1_TIPOCQ = 'Q' "
    _cUpd += "  WHERE SA5.D_E_L_E_T_ = '' AND (A5_SITU = '' OR A5_SKPLOT = '') " 

     TCSQLExec(_cUpd)

Return

