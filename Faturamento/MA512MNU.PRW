#INCLUDE 'Protheus.ch'
#INCLUDE 'RwMake.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MA512MNU  �Autor  �J�lio Soares       � Data �  08/08/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada utilizado para adicionar bot�es ao aRotina���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - ARCOLOR                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MA512MNU()

aadd(aRotina,{'Coleta','U_RFATE055()' ,0 ,4 ,0 ,NIL})

Return()

/*
aadd(aRotina,{'TEXTO DO BOT�O','NOME DA FUN��O' , 0 , 3,0,NIL})
ONDE:Parametros do array a Rotina:
1. Nome a aparecer no cabecalho
2. Nome da Rotina associada
3. Reservado
4. Tipo de transa��o a ser efetuada: 	
		1 - Pesquisa e posiciona em um banco de dados
		2 - Apenas mostra os campos
		3 - Inclui registros no bancos de dados
		4 - Altera o registro corrente
		5 - Remove o registro corrente do banco de dados
5. N�vel de acesso
6. Habilita Menu Funcional
*/