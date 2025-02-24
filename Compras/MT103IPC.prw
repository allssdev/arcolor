#include "totvs.ch"
/*/{Protheus.doc} ³MT103IPC
@description Atualiza os campos especificos dos itens do documento de saida na atualizacao dos itens via botao Pedido ou Item.Ped.
@author Thiago Silva de Almeida
@since 11/03/2013
@version 1.0.0
@type function
@history 04/09/2013, Júlio Soares, Incluido o campo D1_PRECO2 que apresenta o preco conforme conversão na segunda unidade de medida, esse campo é importado para a entrada da nota no momento da busca pelo item ou pedido.
@history 12/01/2021, Anderson Coelho (ALLSS Soluções em Sistemas), Documentação da rotina e inclusão da chamada do ExecBlock "RCOME013" para correto disparo dos gatilhos e validações de D1_TES.
@see https://allss.com.br
/*/
user function MT103IPC()
//    Local _cRotina  := " MT103IPC "
    Local _aSavArea := GetArea()
    Local _aSavASB1 := SB1->(GetArea()) // - Incluido por Anderson Coelho em 12/01/2021.
    Local _aSavASF1 := SF1->(GetArea()) // - Incluido por Júlio Soares em 04/09/2013.
    Local _aSavASD1 := SD1->(GetArea()) // - Incluido por Júlio Soares em 04/09/2013.
    Local _aSavASC7 := SC7->(GetArea()) // - Incluido por Júlio Soares em 04/09/2013.
//  Local _lRet     := .T.
//  Local _nPosPro  := aScan(aHeader,{|x|Alltrim(x[2]) == "D1_COD"      })
    Local _nPosDes  := aScan(aHeader,{|x|Alltrim(x[2]) == "D1_DESCR"    })
//  Local _nPosDe2  := aScan(aHeader,{|x|Alltrim(x[2])== "D1_DESCESP"})
    Local _nPrec2   := aScan(aHeader,{|x|Alltrim(x[2]) == "D1_PRECO2"   }) // - Incluido por Júlio Soares em 04/09/2013 para imprlementar a importação do preço na segunda unidade de medida.
   // _cCodPro                    := aCols[PARAMIXB[1]][_nPosPro]
    aCols[PARAMIXB[1],_nPosDes]   := SC7->C7_DESCRI
    //aCols[PARAMIXB[1],_nPosDe2] := SC7->C7_DESCESP
    aCols[PARAMIXB[1],_nPrec2]    := SC7->C7_PRECO2		// - Incluido por Júlio Soares em 04/09/2013 para implementar a importação do preço na segunda unidade de medida.
    if ExistBlock("RCOME013")
        U_RCOME013(SC7->C7_TES)
    endif
    RestArea(_aSavASB1) // - Incluido por Anderson Coelho em 12/01/2021.
    RestArea(_aSavASC7) // - Incluido por Júlio Soares em 04/09/2013.
    RestArea(_aSavASF1) // - Incluido por Anderson em 26/01/2015.
    RestArea(_aSavASD1) // - Incluido por Júlio Soares em 04/09/2013.
    RestArea(_aSavArea)
//return _lRet
return .T.
