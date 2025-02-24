#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
/*/{Protheus.doc} FA200FIL
Ponto de entrada executado em substituição à rotina de pesquisa padrão do título do arquivo de retorno do banco,
na tabela de contas a receber SE1, que realiza o IDCNAB ou chave do título.
Nesta rotina de pesquisa padrão, também é realizada a validação da espécie do título com a tabela 17.
CNAB - COBRANCA - FILTRO - DESCONTO
@author Thiago S. de Almeida
@since 21/12/2012
@version P11
@type Function
@obs Sem observações
@see https://allss.com.br
@history 03/01/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Revisão de código-fonte em função da migração de release P12.1.33.
@history 05/01/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Revisão/correção pontual de código-fonte para atendimento à baixas parciais.
/*/
user function FA200FIL()
local _aAreaSE1 := SE1->(GetArea())
lHelp          	:= .T.
if AllTrim(cNumTit) == "NAO ENCONTRADO!"
	cNumTit := ""
endif
if lHelp .AND. !Empty(cNumTit)
	dbSelectArea("SE1")
	SE1->(dbSetOrder(16)) //E1_FILIAL+E1_IDCNAB
	if SE1->(dbSeek(FwFilial("SE1") + Padr(cNumTit,Tamsx3("E1_IDCNAB")[1])))
		lHelp    := .F.
		if Empty(cNumTit)
			if !Empty(SE1->E1_IDCNAB)
				cNumTit  	:= Padr(SE1->E1_IDCNAB,Len(cNumTit))
			else
				cNumTit  	:= Padr(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA),Len(cNumTit))
			endif
		endif
	else
		cNumTit  	:= Space(15)
		RestArea(_aAreaSE1)
	endif
endif
cNsNUM     := AllTrim(cNsNUM)
if !Empty(cNsNUM) .AND. SubStr(cNsNUM,3,1) == " "
	cNsNUM := AllTrim(SubStr(cNsNUM,3))
endif
If lHelp .AND. !Empty(cNsNUM)
	dbSelectArea("SE1")
	SE1->(dbOrderNickName("E1_NUMBCO")) //E1_FILIAL+E1_NUMBCO+E1_PEDIDO+E1_NOMCLI
	_cChave   := Padr(cNsNUM,Tamsx3("E1_NUMBCO")[1])
	_lAchou   := Len(cNsNUM) >= 15		//Regra especifica para a carteira 18, para que haja a busca aproximada
	if _lAchou
		SE1->(dbSeek(FwFilial("SE1") + _cChave,.F.,.F.))
	else
		_lAchou := SE1->(dbSeek(FwFilial("SE1") + _cChave,.T.,.F.))
	endif
	if _lAchou
		lHelp := .F.
		if Empty(cNumTit)
			if !Empty(SE1->E1_IDCNAB)
				cNumTit  := Padr(SE1->E1_IDCNAB,Len(cNumTit))
			else
				cNumTit  := Padr(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA),Len(cNumTit))
			endif
		endif
	else
		RestArea(_aAreaSE1)
	endif
endif
if lHelp .AND. !Empty(cNumTit) .AND. !Empty(SubStr(cNumTit,Len(AllTrim(cNumTit))-TamSx3("E1_IDCNAB")[01]+1,TamSx3("E1_IDCNAB")[01]))
	dbSelectArea("SE1")
	SE1->(dbSetOrder(16)) //E1_FILIAL+E1_IDCNAB
	if SE1->(dbSeek(FwFilial("SE1") + Padr(SubStr(cNumTit,Len(AllTrim(cNumTit)) - TamSx3("E1_IDCNAB")[01] + 1,TamSx3("E1_IDCNAB")[01]),Tamsx3("E1_IDCNAB")[01]),.T.,.F.))
		lHelp    := .F.
		if Empty(cNumTit)
			if !Empty(SE1->E1_IDCNAB)
				cNumTit  := Padr(SE1->E1_IDCNAB,Len(cNumTit))
			else
				cNumTit  := Padr(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA),Len(cNumTit))
			endif
		endif
	else
		RestArea(_aAreaSE1)
	endif
endif
lAchouTit := !lHelp
//26/11/2013 - Trecho utilizado para tratar os recebimentos que vieram no CNAB a Receber com desconto, conforme solicitaao do Sr. Mrio.
if lAchouTit
	if nDescont > 0
		//If SE1->E1_DESCFIN == 0 .OR. dDataBase > (SE1->E1_VENCTO-SE1->E1_DIADESC) .OR. NoRound(((nValRec+nDescont+nAbatim-nDespes-nJuros-nMulta-nOutrDesp) * (SE1->E1_DESCFIN/100)), 0) <> NoRound(nDescont, 0)
		//19/06/2017 - Anderson C. P. Coelho - Para o Banco Ita, carteira 109, como a tarifa est sendo cobrada na baixa, tivemos de refazer a regra de forma a somar o valor da taxa ao valor recebido, para chegar-se ao valor principal (proporcional a baixa), para aplicao do desconto tido no campo E1_DESCFIN, para assim verificarmos se o desconto aplicado est de acordo com o previsto.
		//                                      importante lembrar que estamos considerando aqui os centavos, para a verificao (anlise com valores arredondados em 02 decimais).
		if SE1->E1_DESCFIN == 0 .OR. dBaixa > DATAVALIDA((SE1->E1_VENCREA-SE1->E1_DIADESC),.T.) .OR. Round(((nValRec+nDescont+nAbatim+nDespes-nJuros-nMulta-nOutrDesp) * (SE1->E1_DESCFIN/100)), 2) <> Round(nDescont, 2)
			nDescont  	:= 0
			lAchouTit 	:= .F.
		endif
	endif
else
	RestArea(_aAreaSE1)
endif
//Fim do trecho inserido em 26/11/2013
return
