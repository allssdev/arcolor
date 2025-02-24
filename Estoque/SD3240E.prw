#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � SD3240E  �Autor  �Adriano Leonardo      � Data �  11/12/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada ap�s o estorno do movimento interno, uti- ���
���          � lizado para atualizar o consumo mensal do produto na tabela���
���          � SZG (hist�rico do consumo mensal - espec�fico).            ���
�������������������������������������������������������������������������͹��
���Uso       �Protheus 11 - Espec�fico para empresa Arcolor.              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function SD3240E()


//Salvo a �rea de trabalho atual
Local _aSavArea  := GetArea()
Local _aSavSB3	 := SB3->(GetArea())
Local _aSavSF5	 := SF5->(GetArea())
Local _aSavSZG	 := SZG->(GetArea())

//Vari�veis auxiliares                aA
local _cRotina	 := "SD3240E"
local _lRotAtiva :=	.T. //AllTrim(__cUserId)=='000000' //Rotina ativa?
local _lCongCon  := .T. //Define se o consumo ser� congelado nesse movimento ou se ser� alterado (padr�o do sistema)
local _cEntSaid  := ""                          
local _cCampo	 := "B3_Q" + STRZERO(MONTH(DDATABASE),2) //Campo a ser utilizado como macro
local lGrvSzg    := SuperGetMv("MV_GRVSZG" ,,.F.) 

//Verifica se a rotina est� ativa
If !_lRotAtiva
	Return()
EndIf
//Avalia o cadastro do tipo de movimenta��o SF5
dbSelectArea("SF5")
SF5->(dbSetOrder(1))
If SF5->(MsSeek(xFilial("SF5")+M->D3_TM,.T.,.F.))  //No estorno deve se considerar a vari�vel de mem�ria (M->)
	If SF5->F5_CONSUMO<>'N'
		_lCongCon := .F.
	EndIf
	If SF5->F5_CODIGO <= "500"
		_cEntSaid  := "S" //Por ser estorno considera sempre o movimento inverso
	Else
		_cEntSaid  := "E"
	EndIf
EndIf
If _lCongCon
	dbSelectArea("SB3")
	SB3->(dbSelectArea(1))
	If SB3->(dbSeek(xFilial("SB3")+SD3->D3_COD))
		//Estorna a quantidade movimentada, considerando se o movimento foi de entrada ou sa�da //pOSSIVEL ERRO AQUI
		RecLock("SB3",.F.)
			//Se o movimento foi de entrada, soma a quantidade subtra�da
			If _cEntSaid=="E"
				SB3->(&_cCampo) := (SB3->&_cCampo) + (SD3->D3_QUANT)
			//Sen�o subtrai a quantidade somada
			Else
				SB3->(&_cCampo) := (SB3->&_cCampo) - (SD3->D3_QUANT)
			EndIf
		SB3->(MsUnlock())
	EndIf		
	
If lGrvSzg //Determina se a grava��o do hist�rico do consumo mensal est� ativa na SZG (consumo m�dio - espec�fico)
	If SB3->(dbSeek(xFilial("SB3")+SD3->D3_COD)) 
		u_reste009(SB3->B3_COD , SB3->(&_cCampo),_cRotina)		
	EndIf	
EndIf	
	
EndIf


//Restauro as �reas armazenadas originalmente
RestArea(_aSavSZG)
RestArea(_aSavSF5)
RestArea(_aSavSB3)
RestArea(_aSavArea)

Return()