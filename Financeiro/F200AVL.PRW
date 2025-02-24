#include "totvs.ch"
/*/{Protheus.doc} F200AVL
O Array passado como parâmetro permitirá que qualquer exceção ou necessidade seja tratada através do ponto 
de entrada. No momento da chamada do ponto de entrada, as tabelas SEE e SA6 estão posicionadas. O ponto de 
entrada prevê retorno de um valor lógico (verdadeiro ou falso) sendo: quando retorno for verdadeiro, 
continua a execução da rotina normalmente; quando retorno for falso, a rotina executará um "Loop", ou seja,
o processamento da linha atual do arquivo de retorno será abortado e a rotina continuará executando a 
partir da linha seguinte.
@type Function
@author Fernando Bombardi - ALLSS
@since 25/05/2022
@version P12.1.33
@obs Sem observações
@see https://allss.com.br/
@history 20/07/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Alterações/melhorias para identificar e demonstrar títulos com pagamentos sem juros devidos.
@history 26/07/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Inserção de chave para ativar ou não a baixa do título com inconsistência de juros, inserção de validação da ocorrência retornada pelo Banco, correção do calculo de juros para vencidos acima de 30 dias, aumento na tolerância de valor para juros calculados e ajustes nos textos da mensagem e e-mail.
@history 27/07/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Inserção de chave para ativar/desativar apresentação de mensagens deste ponto de entrada durante execução da rotina.
@history 19/05/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Remoção da função datavalida devido não estar considerando os dias não uteis no calculo do juros e o banco está considerando gerando diferenças
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
[01] - Número do Título
[02] - Data da Baixa
[03] - Tipo do TÃ­tulo
[04] - Nosso Número
[05] - Valor da Despesa
[06] - Valor do Desconto
[07] - Valor do Abatimento
[08] - Valor Recebido
[09] - Juros
[10] - Multa
[11] - Outras Despesas
[12] - Valor do CrÃ©dito
[13] - Data Crédito
[14] - Ocorrência
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
                                    OEMtoAnsi('O título com Prefixo ' + AllTrim(SE1->E1_PREFIXO) + ' - Número ' + AllTrim(SE1->E1_NUM) + ' - Parcela ' + AllTrim(SE1->E1_PARCELA) + ' - Cliente ' + AllTrim(SE1->E1_NOMERAZ) + ' possui valor de juros zerado ou diferente do devido.'  +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    'Valor de juros no arquivo retorno: R$ '                             + AllTrim(Transform(_nJuros,'@E 999,999,999.99'))                                                                                                                              +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    'Valor de juros calculado: R$ '                                      + Alltrim(Transform(_nCalcJuros,'@E 999,999,999.99'))                                                                                                                          +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    'Tolerancia (para mais ou para menos): R$ '                          + AllTrim(Transform(_nTolerancia,'@E 999,999,999.99'))                                                                                                                         +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    'Por conta desta validação, este título NÃO será baixado de forma automática e ficará pendente para posterior verificação/baixa. Ainda, um e-mail de notificação será enviado para ' + AllTrim(_cMail) + ' para registro e histórico da operação.')    ,;
                                    {'&Ok'},3,OEMToAnsi('Inconsistência com valores de juros devidos'))
                    endif
                else
                    if _lAtivaMsg
                        Aviso(      '[' + _cRotina + ']'                                                                                                                                                                                                                                   ,;
                                    OEMtoAnsi('O título com Prefixo ' + AllTrim(SE1->E1_PREFIXO) + ' - Número ' + AllTrim(SE1->E1_NUM) + ' - Parcela ' + AllTrim(SE1->E1_PARCELA) + ' - Cliente ' + AllTrim(SE1->E1_NOMERAZ) + ' possui valor de juros zerado ou diferente do devido.'  +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    'Valor de juros no arquivo retorno: R$ '                             + AllTrim(Transform(_nJuros,'@E 999,999,999.99'))                                                                                                                              +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    'Valor de juros calculado: R$ '                                      + AllTrim(Transform(_nCalcJuros,'@E 999,999,999.99'))                                                                                                                          +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    'Tolerancia (para mais ou para menos): R$ '                          + AllTrim(Transform(_nTolerancia,'@E 999,999,999.99'))                                                                                                                         +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    CHR(10) + CHR(13)                                                                                                                                                                                                                                   +   ;
                                    'Apesar desta notificação em tela, um e-mail será enviado para ' + AllTrim(_cMail) + ' para registro e histórico da operação. Este título será baixado normalmente de forma automática.')                                                              ,;
                                    {'&Ok'},3,OEMtoAnsi('Inconsistência com valores de juros devidos'))
                    endif
                endif
                if _lRCFGM001
                    do case
                        case StrZero(Month(dDataBase), 2) = '01'
                            _cMes := "Janeiro"
                        case StrZero(Month(dDataBase), 2) = '02'
                            _cMes := "Fevereiro"
                        case StrZero(Month(dDataBase), 2) = '03'
                            _cMes := "Março"
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
                    _cSubject           := '[Workflow - ' + AllTrim(FWGrpName()) + '/' + AllTrim(FWFilialName()) + '] Baixa Automática via CNAB - Inconsistência com valores de juros devidos - Prefixo ' + AllTrim(SE1->E1_PREFIXO) + ' - Número ' + AllTrim(SE1->E1_NUM) + ' - Parcela ' + AllTrim(SE1->E1_PARCELA) + ' - Cliente ' + AllTrim(SE1->E1_CLIENTE) + '/' + AllTrim(SE1->E1_LOJA) + '-' + AllTrim(SE1->E1_NOMERAZ)
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
                    _cBody 			    += "<p><font face='TAHOMA' size='2' color='#828282'>" + OEMToAnsi("Este é um e-mail automatico para notificar que houve algum problema com relação aos juros devidos durante a baixa do título a seguir do cliente ") + AllTrim(SE1->E1_CLIENTE) + '/' + AllTrim(SE1->E1_LOJA) + '-' + AllTrim(SE1->E1_NOMERAZ) + ":</font></p>"
                    _cBody 		        += "<table>"
                    _cBody 		        += "        <tr style='background-color:#999999'><font face='TAHOMA' size='2' color='#FFFFFF'><b>"
                    _cBody 		        += "				<td>" + OEMToAnsi("Prefixo")                                                + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi("Numero")                                                 + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi("Parcela")                                                + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi("Tipo do título")                                         + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi("Data de vencimento")                                     + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi("Data do pagamento")                                      + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi("Valor original (R$)")                                    + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi("Juros calculados (R$)")                                  + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi("Juros no arquivo CNAB (R$)")                             + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi("Portador")                                               + "</td>"
                    _cBody 		        += "				<td>" + OEMToAnsi("Ocorrência do Portador")                                 + "</td>"
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
                        _cBody 			+= "<p><font face='TAHOMA' size='2' color='#828282'>" + OEMToAnsi("Reforçamos que, por conta deste evento, o título em questão NÃO foi baixado de forma automática pelo processamento do arquivo retorno de recebimentos (CNAB), ficando pendente para análise e tratativas posteriores.") + "</font></p>"
                    else
                        _cBody 			+= "<p><font face='TAHOMA' size='2' color='#828282'>" + OEMToAnsi("Apesar desta notificação, informamos que este título será baixado normalmente de forma automática pelo processamento do arquivo retorno de recebimentos (CNAB).") + "</font></p>"
                    endif
                    _cBody 				+= "<br></br>"
                    _cBody 				+= "<p><font face='TAHOMA' size='2' color='#1C1C1C'><b>" + OEMToAnsi("Atenciosamente,") + "</b></font></p>"
                    _cBody 				+= "<p><font face='TAHOMA' size='2' color='#1C1C1C'><b>" + OEMToAnsi("Administrador do Sistema") + "</b></font></p>"
                    _cBody 				+= "<p><font face='TAHOMA' size='2' color='#1C1C1C'><b>" + OEMToAnsi(" * Mensagem gerada automaticamente pelo ERP Protheus ") + AllTrim(GetRPORelease()) + OEMToAnsi(" - Build ") + AllTrim(GetBuild(.F.)) + OEMToAnsi(" - Internal Control Enterprise. Por favor, não responda essa mensagem.") + "</b></font></p><!--mstheme--></font>"
                    _cBody				+= "<br></br>"
                    _cBody 				+= "<p align='center'><a href='https://allss.com.br'><img style='border: none; width: 60px; max-width: 60px !important; height: 20px; max-height: 20px !important;' src='http://mail.allss.com.br/allssmail.jpg' alt='ALLSS Soluções em Sistemas'/></a><br><a href='https://allss.com.br'><i><font face='Arial' size=1 color='#828282'>" + OEMToAnsi("Powered by ALLSS Soluções em Sistemas") + "</font></i></a></p>'
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
