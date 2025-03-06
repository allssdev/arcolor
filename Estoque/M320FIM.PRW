#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} M320FIM
TODO Executada após a calculo do custo de reposição, ponto de entrada  utilizado para realizar customizações no final da rotina de custo de reposição.
@description LOCALIZAÇÃO   :  Function MA320Process() - Função utilizada para processar o calculo do custo de reposição.
@author Júlio Soares
@since 14/10/2024
@version 1.0
@history 14/10/2024, Diego Rodrigues (ALL System Solutions),Desenvolvimento do relatorio para atualizar o preço futuro no campo B1_FATLUC após o calculo do custo de reposição.
@type function
@see https://allss.com.br
/*/

User Function M320FIM()

Local _cQry := ""

//-- Customizações
    
    _cQry   := " UPDATE " + RetSqlName("SB1")+ "  SET"
    _cQry   += " B1_FATLUC = B1_UPRC"
    _cQry   += " FROM " + RetSqlName("SB1")    + " SB1 "
    _cQry   += " WHERE SB1.D_E_L_E_T_ = '' AND B1_TIPO NOT IN ('PA') "

    If TCSQLExec(_cQry) < 0
		_cQry+=  TCSQLError() 
		MemoWrite("\2.MemoWrite\ERRO\Update_preco_futuro_compra.TXT",_cQry)
	EndIf

    _cQry := ""

    _cQry   := " UPDATE " + RetSqlName("SB1")+ "  SET"
    _cQry   += " B1_FATLUC = B1_CUSTD"
    _cQry   += " FROM " + RetSqlName("SB1")    + " SB1 "
    _cQry   += " WHERE SB1.D_E_L_E_T_ = '' AND B1_TIPO IN ('PA','PI') "

    If TCSQLExec(_cQry) < 0
		_cQry+=  TCSQLError() 
		MemoWrite("\2.MemoWrite\ERRO\Update_preco_futuro_produzido.TXT",_cQry)
	EndIf
Return Nil 
