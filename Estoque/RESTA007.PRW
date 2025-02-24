#INCLUDE "TOTVS.CH"
#include 'topconn.ch'

/*/{Protheus.doc} RESTA007
@description Rotina para alteração da numeração das ordens de produção previstas geradas pelo mrp
@obs 
@author Diego Rodrigues Pereira (ALL System Solutions)
@since 04/08/2021
@version 1.0
@return null
@type function
@see https://allss.com.br
/*/
 
User Function RESTA007()

    Local cAliasQry := GetNextAlias()
    Local cOrigem   := "PCPA144"
    Local _cDadosAux  := "GETSC2"
    Local _cQry 	  := ""
    //
    //SC2 - Ordens de Produção
    //
    BeginSql Alias cAliasQry
      SELECT C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN
        FROM %Table:SC2% (NOLOCK)
       WHERE C2_TPOP = 'P'
         AND %notDel%
    EndSql

      //Busca a numeração das ordens de produção prevista
    _cQry 	  := " SELECT ISNULL(MAX(C2_NUM)+1,'900001') AS [C2_NUM] "
    _cQry 	  += " FROM " + RetSqlName("SC2") + "(NOLOCK)"
    _cQry 	  += " WHERE C2_EMISSAO > '20210601' "
    _cQry 	  += "   AND C2_FILIAL  = '" + xFilial("SC2") + "' "
    _cQry 	  += "   AND SUBSTRING(C2_NUM,1,1) = '9' "
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cDadosAux,.F.,.T.)
    dbSelectArea(_cDadosAux)
    _cRet := AllTrim(Str((_cDadosAux)->C2_NUM))
    (_cDadosAux)->(dbCloseArea())
 
    While (cAliasQry)->(!Eof())
        //Percorre todos os registros gerados no processamento
        Conout("SC2 - Documento: " + (cAliasQry)->C2_FILIAL + (cAliasQry)->C2_NUM + (cAliasQry)->C2_ITEM + (cAliasQry)->C2_SEQUEN)
      
      dbSelectArea("SC2")
			SC2 ->(dbSetOrder(1))
			if SC2->(DbSeek(xFilial("SC2") + (cAliasQry)->C2_NUM + (cAliasQry)->C2_ITEM + (cAliasQry)->C2_SEQUEN))
			
         RecLock("SC2",.F.) 
								SC2->C2_FILIAL  := xFilial("SC2")
							  SC2->C2_NUM := _cRet
                SC2->C2_ITEM := '01'
                SC2->C2_SEQUEN := '001'
							
          SC2->(MSUNLOCK())
				
        _cRet := AllTrim(Str(VAL(_cRet)+1))		
      Endif
      
        (cAliasQry)->(dbSkip())
    
    EndDo
    (cAliasQry)->(dbCloseArea())
 
  
Return
