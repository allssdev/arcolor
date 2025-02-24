#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} M461TRV
@description A finalidade do Ponto de Entrada M461TRV é desativar o LOCK de registros da tabela "SB2 - Saldos Físicos e Financeiros" no momento da geração do Documento de Saída (fonte: http://tdn.totvs.com/display/public/PROT/M461TRV+-+Libera+a+trava+dos+registros+da+tabela+SB2).
@obs Existem outros Pontos de Entrada para o mesmo tratamento, porém em outros pontos, a exemplo do MT261TRV (fonte: http://tdn.totvs.com/display/public/PROT/TUDMJ7_DT_PONTO_DE_ENTRADA_MT261TRV) - Em ambientes com alto volume de movimentações para uma gama pequena de produtos, podemos ter situações em que uma rotina reserva o registro do produto na tabela SB2 para realizar a atualização, e quando uma segunda rotina tenta reservar o mesmo registro dispara o alerta de “MultLock”. Este tipo de situação pode ocorrer no sistema e se trata de uma característica, levando em consideração que a atualização dos saldos na tabela SB2 ocorre de maneira on-line.
	 Hoje ao incluirmos ou estornamos uma Transferência Múltipla (MATA261), ao confirmar o processo a rotina realiza o MultLock dos registros que serão atualizados nas tabelas SB2 e SD3 antes de iniciar o processo de gravação ou estorno.
	 Conforme já disponível hoje nas rotinas de Documento de Entrada (MT103TRV) e Documento de Saída (M461TRV), estamos incluindo na rotina de Transferências Múltiplas (MATA261) o ponto de entrada MT261TRV, onde será possível definir se será realizado o MultLock ou não dos registros das tabelas SB2 e SD3. Ao compilar o ponto de entrada com retorno falso, a rotina não realizará o MultLock antes de iniciar o processo de inclusão ou estorno. A reserva dos registros só será feita no momento de sua gravação.
	 Esta alteração visa atenuar as situações de concorrência entre processos que atualizam a tabela SB2, porém em ambiente com alto volume de movimentações para um mesmo produto/armazém a situação ainda pode ocorrer. No Ponto de Entrada ficam disponíveis os registros que seriam reservados na tabela SB2 pelo índice 1 no PARAMIXB[1], e os registros que seriam reservados na tabela SD3 (apenas no estorno) pelo índice 3 no PARAMIXB[2].
@author Anderson C. P. Coelho (ALL System Solutions)
@since 05/11/2018
@version 1.0
@return lógico, .T. - Trava os registros  /  .F. - Desativa a trava dos registros
@type function
@see https://allss.com.br
/*/
user function M461TRV() ; return .F.