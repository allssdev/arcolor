#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �OM200MNU     �Autor  �RENAN SANTOS     � Data �  09/19/16   ��� //analisar
�������������������������������������������������������������������������͹��
���Desc.     � PE Para inclusao de Bot�o e Valida��o da rotina de         ���
���          � de cargas                                                  ���
�������������������������������������������������������������������������͹��
���Uso       � AP11 - ARCOLOR                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function OM200MNU ()
	//aadd(aRotina,{'Manut 2','u_AlteraZZZ' , 0 , 4,0,NIL})
	If  EXISTBLOCK("ROMSE001")
		aRotina[aScan(aRotina,{|x| ValType(x[2]) == "A"})][02][aScan(aRotina[aScan(aRotina,{|x| ValType(x[2]) == "A"})][02], {|y| AllTrim(UPPER(y[2])) == "OS200MANUT"})][02] := "U_ROMSE001"  
	EndIf
return