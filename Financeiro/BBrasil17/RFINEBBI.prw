#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFINEBBI  �Autor  �Anderson C. P. Coelho � Data �  20/12/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock para o retorno das instru��es de cobran�a do     ���
���          �t�tulo a receber ou dos par�metros bancos, caso o primeiro  ���
���          �n�o esteja preenchido.                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function RFINEBBI(_cNumIns)
	Local _aSavArea		:= GetArea()
	Local _cRet			:= ""
	Local _nDias		:= ""
	
	// FB - RELEASE 12.1.23
	Local _lRFINEBBI    := EXISTBLOCK("RFINEBBI")
	Local _bZIDIASPRO   := "Type('SZI->ZI_DIASPRO')"
	Local _bE1DIASPRO   := "Type('SE1->E1_DIASPRO')"
	// FIM FB
	
	default _cNumIns	:= "1"		//N�mero da instru��o de cobran�a

	If !Empty(_cNumIns)
		If _cNumIns == "P"
			_cOcorr := ""
			If EXISTBLOCK("RFINEBBO")
				_cOcorr := U_RFINEBBO()
			ElseIf !Empty(SE1->E1_OCORREN)
				_cOcorr := SE1->E1_OCORREN
			Else
				_cOcorr := SEE->EE_OCORREN
			EndIf
			_cRet := ""
			for _k := 1 to 2
				_cInstr := ""
				If !Empty(_cOcorr) .AND. _cOcorr == "01"
					/* FB - RELEASE 12.1.23
					If EXISTBLOCK("RFINEBBI")
					*/
					If _lRFINEBBI
						_cInstr := U_RFINEBBI("1")
					ElseIf !Empty(SE1->E1_INSTR1)
						_cInstr := SE1->E1_INSTR1
					Else
						_cInstr := SEE->EE_INSTPRI
					EndIf
				Else
					_cInstr := ""
				EndIf
				If Select("SZI") > 0
					If !Empty(_cInstr)
						dbSelectArea("SZI")
						//SZI->(dbSetOrder(3))	//ZI_FILIAL+ZI_OCORREN+ZI_CODINST+ZI_BANCO+ZI_AGENCIA+ZI_CONTA
						//SZI->(dbSetOrder(14))	//ZI_FILIAL+ZI_OCORREN+ZI_CODINST+ZI_DIASPRO
						SZI->(dbOrderNickName("ZI_OCORRE5"))
						_nDias := SE1->E1_DIASPRO // - Inserido em 02/12/2015 por J�lio Soares.
						//If SZI->(dbSeek(xFilial("SZI") + _cOcorr + _cInstr))
						If SZI->(MsSeek(xFilial("SZI") + _cOcorr + _cInstr + _nDias))
							/* FB - RELEASE 12.1.23
							If Type("SZI->ZI_DIASPRO")<>"U"
							*/
							If &(_bZIDIASPRO) <> "U"							
								If SZI->ZI_DIASPRO > 0		//O preenchimento deste campo � que indicar� se a informa��o de dias para protesto ser� carregada ou n�o
									/* FB - RELEASE 12.1.23
									If Type("SE1->E1_DIASPRO")<>"U" .AND. SE1->E1_DIASPRO > 0
									*/
									If &(_bE1DIASPRO) <> "U" .AND. SE1->E1_DIASPRO > 0
										_cRet := StrZero(SE1->E1_DIASPRO,02)
									Else
										_cRet := StrZero(SEE->EE_DIASPRO,02)
									EndIf
									Exit
								EndIf
							EndIf
						EndIf
					EndIf
				Else
					Exit
				EndIf
			next
		Else
			_cRet := StrZero(VAL(&("SE1->E1_INSTR"+_cNumIns)),2)
			If Empty(_cRet)
				If _cNumIns == "1"
					_cNumIns := "PRI"
				ElseIf _cNumIns == "2"
					_cNumIns := "SEC"
				EndIf
				_cRet := StrZero(VAL(&("SEE->EE_INST"+_cNumIns)),2)
			EndIf
		EndIf
	EndIf
	RestArea(_aSavArea)
return(_cRet)