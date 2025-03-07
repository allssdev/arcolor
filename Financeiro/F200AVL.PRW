#include "totvs.ch"
/*/{Protheus.doc} F200AVL
O Array passado como par�metro permitir� que qualquer exce��o ou necessidade seja tratada atrav�s do ponto 
de entrada. No momento da chamada do ponto de entrada, as tabelas SEE e SA6 est�o posicionadas. O ponto de 
entrada prev� retorno de um valor l�gico (verdadeiro ou falso) sendo: quando retorno for verdadeiro, 
continua a execu��o da rotina normalmente; quando retorno for falso, a rotina executar� um "Loop", ou seja,
o processamento da linha atual do arquivo de retorno ser� abortado e a rotina continuar� executando a 
partir da linha seguinte.
@type Function
@author Fernando Bombardi - ALLSS
@since 25/05/2022
@version P12.1.33
@obs Sem observa��es
@see https://allss.com.br/
@history 20/07/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Altera��es/melhorias para identificar e demonstrar t�tulos com pagamentos sem juros devidos.
@history 26/07/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Inser��o de chave para ativar ou n�o a baixa do t�tulo com inconsist�ncia de juros, inser��o de valida��o da ocorr�ncia retornada pelo Banco, corre��o do calculo de juros para vencidos acima de 30 dias, aumento na toler�ncia de valor para juros calculados e ajustes nos textos da mensagem e e-mail.
@history 27/07/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Inser��o de chave para ativar/desativar apresenta��o de mensagens deste ponto de entrada durante execu��o da rotina.
@history 19/05/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Remo��o da fun��o datavalida devido n�o estar considerando os dias n�o uteis no calculo do juros e o banco est� considerando gerando diferen�as
/*/
user function F200AVL()
local _aArea        := GetArea()
local _cTitulo      := AllTrim(PARAMIXB[1][1])
local _dDataBx      := PARAMIXB[1][2]
local _nJuros       := PARAMIXB[1][9]
local _cOcorrencia  := AllTrim(PARAMIXB[1][14])
local _cRotina      := 'F200AVL'
local _TpJuros      := SuperGetMv('MV_JURTIPO',.F.,'M')
local _nTolerancia  := SuperGetMv('MV_XTOLJUR',.F.,0.10)
local _cVldOcorr    := SuperGetMv('MV_XVLDOCO',.F.,'00/06')
local _lAtivaBx     := SuperGetMv('MV_XATVBX' ,.F.,.T.)
local _lAtivaMsg    := SuperGetMv('MV_XATVMSG',.F.,.F.)
local _nDiasAtraso  := 0
local _nQtdArred    := 2
local _nJurSimp     := 0
local _nMonSimp     := 0
local _nMonComp     := 0
local _nCalcJuros   := 0
local _lRet         := .T.
local _lRCFGM001    := ExistBlock('RCFGM001')
local _cSubject     := ""
local _cBody        := ""
local _cMail        := SuperGetMv('MV_XEMLJUR',.F.,'rodrigo.telecio@allss.com.br')
local _cAnexo   	:= ""
local _cFromOri     := ""
local _aSM0Data     := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CIDENT'})
local _cDia     	:= (StrZero(Day(dDataBase), 2))
local _cMes  		:= ""
local _cAno 		:= (StrZero(Year(dDataBase), 4))
/*
Estrutura do Array:
[01] - N�mero do T�tulo
[02] - Data da Baixa
[03] - Tipo do Título
[04] - Nosso N�mero
[05] - Valor da Despesa
[06] - Valor do Desconto
[07] - Valor do Abatimento
[08] - Valor Recebido
[09] - Juros
[10] - Multa
[11] - Outras Despesas
[12] - Valor do Crédito
[13] - Data Cr�dito
[14] - Ocorr�ncia
[15] - Motivo da Baixa
[16] - Linha Inteira
[17] - Data de Vencto
*/
if _cOcorrencia $ _cVldOcorr
    dbSelectArea("SE1")
    dbSetOrder(19) //E1_IDCNAB
    if dbSeek(_cTitulo)
        //if DataValida(_dDataBx) > DataValida(SE1->E1_VENCTO)
        if DataValida(_dDataBx) > SE1->E1_VENCTO
            //Juros Simples
            if _TpJuros == "S"
                //_nDiasAtraso    := DataValida(_dDataBx) - DataValida(SE1->E1_VENCTO)
                _nDiasAtraso    := DataValida(_dDataBx) - SE1->E1_VENCTO
                _nMonSimp       := Round(SE1->E1_SALDO * (1 + (_nDiasAtraso * (SE1->E1_PORCJUR) / 100)),_nQtdArred)
                _nCalcJuros     := _nMonSimp - SE1->E1_SALDO
            //Juros Compostos
            elseif _TpJuros == "C"
                //_nDiasAtraso    := DataValida(_dDataBx) - DataValida(SE1->E1_VENCTO)
                _nDiasAtraso    := DataValida(_dDataBx) - SE1->E1_VENCTO
                _nMonComp       := Round(SE1->E1_SALDO * ((1 + (SE1->E1_PORCJUR / 100)) ^ (_nDiasAtraso - 30)),_nQtdArred)
                _nCalcJuros     := _nMonComp - SE1->E1_SALDO
            //Juros Mistos (Simples e Compostos)
            elseif _TpJuros == "M"
                //_nDiasAtraso := DataValida(_dDataBx) - DataValida(SE1->E1_VENCTO)
                _nDiasAtraso := DataValida(_dDataBx) - SE1->E1_VENCTO
                //Juros         = Saldo do Titulo *(1+(dias de atraso*(taxa de juros/100)))
                if _nDiasAtraso <= 30
                    _nMonSimp   := Round(SE1->E1_SALDO * (1 + (_nDiasAtraso * (SE1->E1_PORCJUR) / 100)),_nQtdArred)
                    _nCalcJuros := _nMonSimp - SE1->E1_SALDO
                //Juros Simples = Saldo do titulo *(1+(30*(taxa de juros/100)))
                //Juros         = Juros Simples*((1+(taxa de juros/100))**dias de atraso-30)
                else
                    _nJurSimp   := Round(((SE1->E1_SALDO * SE1->E1_PORCJUR) / 100) * 30,_nQtdArred)
                    _nMonSimp   := SE1->E1_SALDO + _nJurSimp
                    _nMonComp   := Round(_nMonSimp * ((1 + (SE1->E1_PORCJUR / 100)) ^ (_nDiasAtraso - 30)),_nQtdArred)
                    _nCalcJuros := _nMonComp - SE1->E1_SALDO
                endif
            endif
            if _nJuros == 0 .OR. !(_nJuros > (_nCalcJuros - _nTolerancia) .AND. _nJuros < (_nCalcJuros + _nTolerancia))
                if _lAtivaBx
                    if _lAtivaMsg
                        Aviso(      '[' + _cRotina + ']'                                                                                                                                                                                                                                   ,;
                                    OEMtoAnsi('O t�tulo com Prefixo ' + AllTrim(SE1->E1_PREFIXO) + ' - N�mero ' + AllTrim(SE1->E1_NUM) + ' - Parcela ' + AllTrim(SE1->E1_PARCELA) + ' - Cliente ' + AllTrim(SE1->E1_NOMERAZ) + ' possui valor de juros zerado ou diferente do devido.'  +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    'Valor de juros no arquivo retorno: R$ '                             + AllTrim(Transform(_nJuros,'@E 999,999,999.99'))                                                                                                                              +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    'Valor de juros calculado: R$ '                                      + Alltrim(Transform(_nCalcJuros,'@E 999,999,999.99'))                                                                                                                          +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    'Tolerancia (para mais ou para menos): R$ '                          + AllTrim(Transform(_nTolerancia,'@E 999,999,999.99'))                                                                                                                         +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    'Por conta desta valida��o, este t�tulo N�O ser� baixado de forma autom�tica e ficar� pendente para posterior verifica��o/baixa. Ainda, um e-mail de notifica��o ser� enviado para ' + AllTrim(_cMail) + ' para registro e hist�rico da opera��o.')    ,;
                                    {'&Ok'},3,OEMToAnsi('Inconsist�ncia com valores de juros devidos'))
                    endif
                else
                    if _lAtivaMsg
                        Aviso(      '[' + _cRotina + ']'                                                                                                                                                                                                                                   ,;
                                    OEMtoAnsi('O t�tulo com Prefixo ' + AllTrim(SE1->E1_PREFIXO) + ' - N�mero ' + AllTrim(SE1->E1_NUM) + ' - Parcela ' + AllTrim(SE1->E1_PARCELA) + ' - Cliente ' + AllTrim(SE1->E1_NOMERAZ) + ' possui valor de juros zerado ou diferente do devido.'  +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    'Valor de juros no arquivo retorno: R$ '                             + AllTrim(Transform(_nJuros,'@E 999,999,999.99'))                                                                                                                              +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    'Valor de juros calculado: R$ '                                      + AllTrim(Transform(_nCalcJuros,'@E 999,999,999.99'))                                                                                                                          +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    'Tolerancia (para mais ou para menos): R$ '                          + AllTrim(Transform(_nTolerancia,'@E 999,999,999.99'))                                                                                                                         +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    'Apesar desta notifica��o em tela, um e-mail ser� enviado para ' + AllTrim(_cMail) + ' para registro e hist�rico da opera��o. Este t�tulo ser� baixado normalmente de forma autom�tica.')                                                              ,;
                                    {'&Ok'},3,OEMtoAnsi('Inconsist�ncia com valores de juros devidos'))
                    endif
                endif
                if _lRCFGM001
                    do case
                        case StrZero(Month(dDataBase), 2) = '01'
                            _cMes := "Janeiro"
                        case StrZero(Month(dDataBase), 2) = '02'
                            _cMes := "Fevereiro"
                        case StrZero(Month(dDataBase), 2) = '03'
                            _cMes := "Mar�o"
                        case StrZero(Month(dDataBase), 2) = '04'
                            _cMes := "Abril"
                        case StrZero(Month(dDataBase), 2) = '05'
                            _cMes := "Maio"
                        case StrZero(Month(dDataBase), 2) = '06'
                            _cMes := "Junho"
                        case StrZero(Month(dDataBase), 2) = '07'
                            _cMes := "Julho"
                        case StrZero(Month(dDataBase), 2) = '08'
                            _cMes := "Agosto"
                        case StrZero(Month(dDataBase), 2) = '09'
                            _cMes := "Setembro"
                        case StrZero(Month(dDataBase), 2) = '10'
                            _cMes := "Outubro"
                        case StrZero(Month(dDataBase), 2) = '11'
                            _cMes := "Novembro"
                        case StrZero(Month(dDataBase), 2) = '12'
                            _cMes := "Dezembro"
                    endcase
                    _cSubject           := '[Workflow - ' + AllTrim(FWGrpName()) + '/' + AllTrim(FWFilialName()) + '] Baixa Autom�tica via CNAB - Inconsist�ncia com valores de juros devidos - Prefixo ' + AllTrim(SE1->E1_PREFIXO) + ' - N�mero ' + AllTrim(SE1->E1_NUM) + ' - Parcela ' + AllTrim(SE1->E1_PARCELA) + ' - Cliente ' + AllTrim(SE1->E1_CLIENTE) + '/' + AllTrim(SE1->E1_LOJA) + '-' + AllTrim(SE1->E1_NOMERAZ)
                    _cBody				:= ""
                    _cBody 				+='<html>'
                    _cBody 				+='<head>'
                    _cBody 				+='<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
                    _cBody 				+='<meta http-equiv="Content-Language" content="pt-br">'
                    _cBody 				+='<title>' + _cSubject + '</title>'
                    _cBody 				+= "<meta name='Microsoft Theme' content='compass 1011, default'>"
                    _cBody 				+= "<meta name='Microsoft Border' content='tlb, default'>"
                    _cBody 				+= "</head>"
                    _cBody 				+= "<body>"
                    _cBody 				+= "<p><font face='TAHOMA' size='2' color='#1C1C1C'><b>" + AllTrim(_aSM0Data[1,2]) + ", " + AllTrim(_cDia) + " de " + AllTrim(_cMes) + " de " + AllTrim(_cAno) + "</b></font></p>"
                    _cBody 			    += "<p><font face='TAHOMA' size='2' color='#828282'>" + OEMToAnsi("Prezado(a),") + "</font></p>"
                    _cBody 			    += "<p><font face='TAHOMA' size='2' color='#828282'>" + OEMToAnsi("Este � um e-mail automatico para notificar que houve algum problema com rela��o aos juros devidos durante a baixa do t�tulo a seguir do cliente ") + AllTrim(SE1->E1_CLIENTE) + '/' + AllTrim(SE1->E1_LOJA) + '-' + AllTrim(SE1->E1_NOMERAZ) + ":</font></p>"
                    _cBody 		        += "<table>"
                    _cBody 		        += "        <tr style='background-color:#999999'><font face='TAHOMA' size='2' color='#FFFFFF'><b>"
                    _cBody 		        += "				<td>" + OEMToAnsi("Prefixo")                                                + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi("Numero")                                                 + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi("Parcela")                                                + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi("Tipo do t�tulo")                                         + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi("Data de vencimento")                                     + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi("Data do pagamento")                                      + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi("Valor original (R$)")                                    + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi("Juros calculados (R$)")                                  + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi("Juros no arquivo CNAB (R$)")                             + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi("Portador")                                               + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi("Ocorr�ncia do Portador")                                 + "</td>"
                    _cBody 		        += "        </b></font></tr>"
                    _cBody 		        += "        <tr style='background-color:#E9E9E9'><font face='TAHOMA' size='2' color='#1C1C1C'><b>"
                    _cBody 		        += "				<td>" + OEMToAnsi(AllTrim(SE1->E1_PREFIXO))                                 + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi(AllTrim(SE1->E1_NUM))                                     + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi(AllTrim(SE1->E1_PARCELA))                                 + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi(AllTrim(SE1->E1_TIPO))                                    + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi(DtoC(SE1->E1_VENCTO))                                     + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi(DtoC(_dDataBx))                                           + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi(AllTrim(Str(SE1->E1_SALDO)))                              + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi(AllTrim(Transform(_nCalcJuros,'@E 999,999,999.99')))      + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi(AllTrim(Transform(_nJuros,'@E 999,999,999.99')))          + "</td>"                
                    _cBody 		        += "				<td>" + OEMToAnsi(AllTrim(SE1->E1_PORTADO))                                 + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi(AllTrim(_cOcorrencia))                                    + "</td>"
                    _cBody 		        += "        </b></font></tr>"
                    _cBody 		        += "</table>"
                    if _lAtivaBx
                        _cBody 			+= "<p><font face='TAHOMA' size='2' color='#828282'>" + OEMToAnsi("Refor�amos que, por conta deste evento, o t�tulo em quest�o N�O foi baixado de forma autom�tica pelo processamento do arquivo retorno de recebimentos (CNAB), ficando pendente para an�lise e tratativas posteriores.") + "</font></p>"
                    else
                        _cBody 			+= "<p><font face='TAHOMA' size='2' color='#828282'>" + OEMToAnsi("Apesar desta notifica��o, informamos que este t�tulo ser� baixado normalmente de forma autom�tica pelo processamento do arquivo retorno de recebimentos (CNAB).") + "</font></p>"
                    endif
                    _cBody 				+= "<br></br>"
                    _cBody 				+= "<p><font face='TAHOMA' size='2' color='#1C1C1C'><b>" + OEMToAnsi("Atenciosamente,") + "</b></font></p>"
                    _cBody 				+= "<p><font face='TAHOMA' size='2' color='#1C1C1C'><b>" + OEMToAnsi("Administrador do Sistema") + "</b></font></p>"
                    _cBody 				+= "<p><font face='TAHOMA' size='2' color='#1C1C1C'><b>" + OEMToAnsi(" * Mensagem gerada automaticamente pelo ERP Protheus ") + AllTrim(GetRPORelease()) + OEMToAnsi(" - Build ") + AllTrim(GetBuild(.F.)) + OEMToAnsi(" - Internal Control Enterprise. Por favor, n�o responda essa mensagem.") + "</b></font></p><!--mstheme--></font>"
                    _cBody				+= "<br></br>"
                    _cBody 				+= "<p align='center'><a href='https://allss.com.br'><img style='border: none; width: 60px; max-width: 60px !important; height: 20px; max-height: 20px !important;' src='http://mail.allss.com.br/allssmail.jpg' alt='ALLSS Solu��es em Sistemas'/></a><br><a href='https://allss.com.br'><i><font face='Arial' size=1 color='#828282'>" + OEMToAnsi("Powered by ALLSS Solu��es em Sistemas") + "</font></i></a></p>'
                    _cBody 				+= "</body>"
                    _cBody 				+= "</html>"
                    U_RCFGM001(_cSubject,_cBody,_cMail,_cAnexo,_cFromOri,"","",.F.,.F.)
                endif
                if _lAtivaBx
                    _lRet               := .F.
                endif
            endif
        endif
    endif
endif
RestArea(_aArea)
return(_lRet)
