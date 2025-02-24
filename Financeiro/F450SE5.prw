#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F450SE5	�Autor  �Arthur F. da Silva	 � Data �  11/07/16   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada para atualiza��o da data de emiss�o de	  ���
���          � Todos os t�tulos de comiss�es emitidos, conforme par�metros���
���          � Informados na compensa��o entre carteiras.				  ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function F450SE5()

Local _aSavArea := GetArea()
Local _aSavSE1  := SE1->(GetArea())
Local _aSavSE2  := SE2->(GetArea())
Local _aSavSE3  := SE3->(GetArea())
Local _aSavSE5  := SE5->(GetArea())
Local _cRotina  := "F450SE5"
Local _cNum     := (SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA))  // padrao -> cPrefixo + cNum + cParcela

//***************************************************************************************************
//11/07/2016 - ARTHUR, AVALIAR A QUEST�O DO POSIIONAMENTO INICIAL DA SE1.
//VERIFICAR SE N�O TEREMOS PROBLEMAS, UMA VEZ QUE A DOCUMENTA��O DO P.E. PREV�
//O POSICIONAMENTO INICIAL DA SE5 (E N�O DA SE1).
//UMA ID�IA SERIA DE COLOCAR A CHAVE DA SE5. CONTUDO, AVALIAR OS IMPACTOS, POIS PODE SER QUE
//A SE5 APRESENTADA SEJA DO T�TULO A PAGAR. AVALIAR BEM ESTE PONTO. PODE AT� SER QUE A CHAVE PELA
//SE1 ESTEJA CORRETA, MAS AVALIAR MELHOR, PARA N�O TERMOS IMPACTOS FUTUROS. 
//
//                                         ATT, ANDERSON COELHO - 11/07/2016
//***************************************************************************************************

Local _cTipo    := SE1->(E1_TIPO)
Local _dBaixa   := dBaixa          // Transforma o conte�do do par�metro padr�o em vari�vel

If Upper(AllTrim(FunName())) == "FINA450" 
	If !_cTipo $ "RA|NCC"
		dbSelectArea("SE3")
		SE3->(dbSetOrder(1))
		If SE3->(MsSeek(xFilial("SE3")+_cNum,.T.,.F.))
			While !SE3->(EOF()) .AND. SE3->E3_FILIAL == xFilial("SE3") .AND. (SE3->(E3_PREFIXO+E3_NUM+E3_PARCELA)) == _cNum
				while !RecLock("SE3",.F.) ; enddo
	          		SE3->E3_EMISSAO := _dBaixa
				SE3->(MSUNLOCK())
				dbSelectArea("SE3")
				SE3->(dbSetOrder(1))				
				SE3->(dbSkip())
			EndDo			
		EndIf
	EndIf
EndIf
                  
RestArea(_aSavSE5)
RestArea(_aSavSE3)
RestArea(_aSavSE2)
RestArea(_aSavSE1)
RestArea(_aSavArea)

Return()