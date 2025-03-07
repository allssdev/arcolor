#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} M320FIM
TODO Executada ap�s a calculo do custo de reposi��o, ponto de entrada  utilizado para realizar customiza��es no final da rotina de custo de reposi��o.
@description LOCALIZA��O   :  Function MA320Process() - Fun��o utilizada para processar o calculo do custo de reposi��o.
@author J�lio Soares
@since 14/10/2024
@version 1.0
@history 14/10/2024, Diego Rodrigues (ALL System Solutions),Desenvolvimento do relatorio para atualizar o pre�o futuro no campo B1_FATLUC ap�s o calculo do custo de reposi��o.
@type function
@see https://allss.com.br
/*/

User Function M320FIM()

Local _cQry := ""

//-- Customiza��es
    
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
