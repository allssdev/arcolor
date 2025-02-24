#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � M461SB3  �Autor  �Adriano Leonardo      � Data �  09/12/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada utilizado para validar se o consumo mensal���
���          � do produto ser� atualizado com base na nota fiscal de sa�da���
�������������������������������������������������������������������������͹��
���Uso       �Protheus 11 - Espec�fico para empresa Arcolor.              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function M461SB3()
	                         
//Salvo a �rea de trabalho atual
Local _aSavArea  := GetArea()
Local _aSavSB3	 := SB3->(GetArea())
Local _aSavSZG	 := SZG->(GetArea())
Local _lRet		 := .T.	//O retorno sempre ser� .T. - ponto de entrada n�o est� validando o movimento
Local _cAnoMes	 := SUBSTR(DtoS(SD2->D2_EMISSAO),1,6) 	       //AnoMes no formato (AAAAMM)
Local _cCampo	 := "B3_Q" + STRZERO(MONTH(SD2->D2_EMISSAO),2) //Vari�vel para utiliza��o de macro
Local lGrvSzg    := SuperGetMv("MV_GRVSZG" ,,.F.) 
local _QtdCons   := 0
private _cRotina := "M461SB3"

_QtdCons:= Iif(SD2->D2_TIPO $ ("D") , (SB3->&_cCampo) - SD2->D2_QUANT,  iif(SD2->D2_TIPO $ ("N"),(SB3->&_cCampo) + SD2->D2_QUANT,(SB3->&_cCampo) ))

If lGrvSzg //Determina se a grava��o do hist�rico do consumo mensal est� ativa na SZG (consumo m�dio - espec�fico)
	u_reste009(SB3->B3_COD , _QtdCons ,_cRotina,SD2->D2_EMISSAO)			
EndIf		

//Restauro as �reas armazenadas originalmente
RestArea(_aSavSZG)
RestArea(_aSavSB3)
RestArea(_aSavArea)

Return(_lRet)