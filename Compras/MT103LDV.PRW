#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT103LDV
Responsável por verificar os itens que podem ser devolvidos do documento selecionado
@type     function preencher o campo lote e data de validade conforme a nota de origem
@author      Diego Rodrigues
@since       04/07/2024
/*/

User Function MT103LDV()
Local aLinha    := ParamIXB[1] 
//Local cAliasSD2 := ParamIXB[2]
Local _nPosIto  := aScan(aLinha,{|x|AllTrim(x[01])=="D1_ITEMORI"})
Local _nPosDoc  := aScan(aLinha,{|x|AllTrim(x[01])=="D1_NFORI"  })
Local _nPosCod  := aScan(aLinha,{|x|AllTrim(x[01])=="D1_COD"    })
Local _nPosQtd  := aScan(aLinha,{|x|AllTrim(x[01])=="D1_QUANT"  })
Local _nPosArmz := aScan(aLinha,{|x|AllTrim(x[01])=="D1_LOCAL"  })

    BeginSql Alias "NFDEV"
        SELECT
        D2_COD, D2_LOTECTL, D2_DTVALID,'VC' ARMZ, D2_TIPOPER
        FROM SD2010 SD2 (NOLOCK)
        WHERE SD2.D_E_L_E_T_ = ''
        AND D2_DOC =%Exp:alinha[_nPosDoc][2]%
        AND D2_COD = %Exp:alinha[_nPosCod][2]%
        AND D2_QUANT = %Exp:alinha[_nPosQtd][2]%
        AND D2_ITEM = %Exp:alinha[_nPosIto][2]%
    EndSql

    if NFDEV->(!EOF()) 
        If NFDEV->D2_TIPOPER == '06'
            alinha[_nPosArmz][2] := 'VC'
        EndIf
        aAdd(aLinha, {"D1_LOTECTL", NFDEV->D2_LOTECTL       , NIL })
        aAdd(aLinha, {"D1_DTVALID", STOD(NFDEV->D2_DTVALID) , NIL })
    Endif
    NFDEV->(dbCloseArea())

Return(aLinha)
