#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} RCOME002
@description Rotina responsável por iniciar os consumos zerados na tabela consumo médio dos produtos que não tiveram movimentação.
@author Adriano Leonardo
@since 27/05/2013
@version 1.0
@return ${return}, ${return_description}
@type function
@see https://allss.com.br
/*/
user function RCOME002()
local _aSavArea     := GetArea()
local _cAnoMes		:= SUBSTR(DtoS(dDataBase),1,6)

private _cRotina 	:= "RCOME002"
private _cTabela	:= "SB3TMP"
private _nCont		:= 0

if MsgYesNo("Deseja iniciar os saldos zerados para os produtos que não tiveram nenhuma movimentação?",_cRotina)
	Processa({ |lEnd| IniciaSB3(@lEnd) }, "["+_cRotina+"] Atualizando dados","Aguarde...",.F.)
endif
RestArea(_aSavArea)
return
/*/{Protheus.doc} IniciaSB3
@description Processamento da rotina "RCOME002".
@author Adriano Leonardo
@since 27/05/2013
@version 1.0
@return ${return}, ${return_description}
@type function
@see https://allss.com.br
/*/
static function IniciaSB3()
local _MVGRVSZG := SuperGetMv("MV_GRVSZG" ,,.F.)		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema não tenha de ficar consultando o conteúdo do parâmetro.
local _nQuant	:= 0 //Gerar Consumo Zerado

BeginSql Alias "SB3TMP"
	SELECT SB1.B1_FILIAL AS [B3_FILIAL], SB1.B1_COD AS [B3_COD]
	FROM %table:SB3% SB3 (NOLOCK)
	     FULL JOIN %table:SB1% SB1 (NOLOCK) ON SB1.B1_FILIAL = %xFilial:SB1% AND SB1.B1_COD    = SB3.B3_COD AND SB1.%NotDel%
	WHERE SB3.B3_FILIAL  = %xFilial:SB3% AND SB3.B3_COD IS NULL AND SB3.%NotDel%
EndSql

dbSelectArea(_cTabela)
(_cTabela)->(dbSetOrder(0))

while !(_cTabela)->(EOF())
	//Início - Trecho adicionado por Adriano Leonardo em 12/12/2013 para armazenamento do histórico do consumo mensal na tabela SZG (Específico)
		if _MVGRVSZG			//Determina se a gravação do histórico do consumo mensal está ativa na SZG (consumo médio - específico)		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: SuperGetMv("MV_GRVSZG" ,,.F.)
			u_reste009(SB3->B3_COD , _nQuant,_cRotina)				
		endif
	//Fim - Trecho adicionado por Adriano Leonardo em 12/12/2013 para armazenamento do histórico do consumo mensal na tabela SZG (Específico)
	_nCont++
	dbSelectArea(_cTabela)
	(_cTabela)->(dbSetOrder(0))
	(_cTabela)->(dbSkip())
EndDo

If _nCont>0
	MsgInfo("Foram gerados consumo zerados para " + AllTrim(Str(_nCont)) + " produtos.","Processo finalizado com sucesso!",_cRotina + "001")
Else 
	MsgInfo("Não foi necessário iniciar o consumo de nenhum produto.","Processo finalizado com sucesso!",_cRotina + "002")
EndIf

dbSelectArea(_cTabela)
(_cTabela)->(dbCloseArea())
return