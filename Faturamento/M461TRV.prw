#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} M461TRV
@description A finalidade do Ponto de Entrada M461TRV � desativar o LOCK de registros da tabela "SB2 - Saldos F�sicos e Financeiros" no momento da gera��o do Documento de Sa�da (fonte: http://tdn.totvs.com/display/public/PROT/M461TRV+-+Libera+a+trava+dos+registros+da+tabela+SB2).
@obs Existem outros Pontos de Entrada para o mesmo tratamento, por�m em outros pontos, a exemplo do MT261TRV (fonte: http://tdn.totvs.com/display/public/PROT/TUDMJ7_DT_PONTO_DE_ENTRADA_MT261TRV) - Em ambientes com alto volume de movimenta��es para uma gama pequena de produtos, podemos ter situa��es em que uma rotina reserva o registro do produto na tabela SB2 para realizar a atualiza��o, e quando uma segunda rotina tenta reservar o mesmo registro dispara o alerta de �MultLock�. Este tipo de situa��o pode ocorrer no sistema e se trata de uma caracter�stica, levando em considera��o que a atualiza��o dos saldos na tabela SB2 ocorre de maneira on-line.
	 Hoje ao incluirmos ou estornamos uma Transfer�ncia M�ltipla (MATA261), ao confirmar o processo a rotina realiza o MultLock dos registros que ser�o atualizados nas tabelas SB2 e SD3 antes de iniciar o processo de grava��o ou estorno.
	 Conforme j� dispon�vel hoje nas rotinas de Documento de Entrada (MT103TRV) e Documento de Sa�da (M461TRV), estamos incluindo na rotina de Transfer�ncias M�ltiplas (MATA261) o ponto de entrada MT261TRV, onde ser� poss�vel definir se ser� realizado o MultLock ou n�o dos registros das tabelas SB2 e SD3. Ao compilar o ponto de entrada com retorno falso, a rotina n�o realizar� o MultLock antes de iniciar o processo de inclus�o ou estorno. A reserva dos registros s� ser� feita no momento de sua grava��o.
	 Esta altera��o visa atenuar as situa��es de concorr�ncia entre processos que atualizam a tabela SB2, por�m em ambiente com alto volume de movimenta��es para um mesmo produto/armaz�m a situa��o ainda pode ocorrer. No Ponto de Entrada ficam dispon�veis os registros que seriam reservados na tabela SB2 pelo �ndice 1 no PARAMIXB[1], e os registros que seriam reservados na tabela SD3 (apenas no estorno) pelo �ndice 3 no PARAMIXB[2].
@author Anderson C. P. Coelho (ALL System Solutions)
@since 05/11/2018
@version 1.0
@return l�gico, .T. - Trava os registros  /  .F. - Desativa a trava dos registros
@type function
@see https://allss.com.br
/*/
user function M461TRV() ; return .F.