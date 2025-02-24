#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa � RFINE018 �Autor  � Adriano L. de Souza � Data �  23/04/2014  ���
��������������������������������������������������������������������������͹��
���Desc.   � Fun��o desenvolvida para calcular o prazo m�dio da condi��o de ��
���Desc.   � pagamento.                                                    ���
��������������������������������������������������������������������������͹��
���Uso P11  � Uso espec�fico Arcolor                                       ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������ͱ����
����������������������������������������������������������������������������*/

User Function RFINE018(cCond,nValTot,nVIPI,dData,nVSol)

Local _aSavArea 	:= GetArea()
Local _aParcelas    := {}
Local _nPrzMed		:= 0
Local _dDataAux		:= dDataBase
Local _nSomPrz		:= 0

//Defino os valores default dos par�metros para os casos em que s� ser�o considerados os vencimentos, independente de valor
Default nValTot		:= 1000
Default nVIPI		:= 0
Default dData		:= dDataBase
Default nVSol		:= 0

If (nValTot <> Nil .And. cCond <> Nil .And. nVIPI <> Nil .And. nVSol <> Nil)
	
	_aParcelas := Condicao(nValTot,cCond,nVIPI,dData,nVSol) //Fun��o padr�o que retorna um array com os vencimentos de acordo com a condi��o de pagamento escolhida
	
	For _nCont := 1 To Len(_aParcelas)
		_nSomPrz  += _aParcelas[_nCont,1] - _dDataAux
	Next
	
	_nPrzMed := Round(_nSomPrz/(Len(_aParcelas)),0) //Arredondo o valor para inteiro
	
EndIf

RestArea(_aSavArea)

Return(_nPrzMed)