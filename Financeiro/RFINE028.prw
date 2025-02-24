#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFINE028  �Autor  � J�lio Soares      � Data �  14/12/15   ���
�������������������������������������������������������������������������͹��
���          �                                                            ���
���          � ###   DESATIVADO EM 05/04/2016   ###                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Desc.     � Este Ecexcblock tem o objetido de calcular o valor de juros���
���          � quando h� a altera��o do vencimento do t�tulo.             ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa ARCOLOR                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
// - Criar gatilho para atualiza��o do campo de acr�scimo com o retorno do execblock

User Function RFINE028()

Local _sAlias		:= GetArea()

Private _cRotina	:= 'RFINE028'
// - FONTE DESATIVADO A PEDIDO DO SR. MARIO EM 05/04/2016
/*
Private _nValJur	:= 0

If ALTERA
	Processa({|lEnd| CalcJur(@lEnd)},_cRotina,' Calculando juros...   Por favor aguarde.',.T.)
EndIf

RestArea(_sAlias)

Return(_nValJur)
*/
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CalcJur  �Autor  � J�lio Soares       � Data �  14/12/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina respons�vel por realizar o c�lculo do valor dos     ���
���          � juros conforme dias em atraso.                             ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa ARCOLOR                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function CalcJur()

Local _cTpJur	:= SuperGetMV('MV_JURTIPO',,'',)
Local _nDias	:= 0
Local _nValor	:= 0

If !(M->E1_TIPO) $ 'RA/PA/NCC/NDF'
	//_nDias := ((dDataBase) - (M->(E1_VENCREAL)))
	_nDias := (M->(E1_VENCREAL) - SE1->(E1_VENCREAL))
	//Quando n�o houver percentual de juros indicado no t�tulo, o juro ser� calculado pela taxa de perman�ncia  da seguinte forma:
	If !(Empty(M->E1_PORCJUR)) .And. _nDias > 0
		//Juros Simples (par�metro MV_JURTIPO = S)
		If _cTpJur == 'S'
			//Juros = Saldo do Titulo *(1+(dias de atraso *(taxa de juros/100)))
			_nValJur := Round((M->(E1_SALDO))*(1+(_nDias *((M->E1_PORCJUR)/100))),2) - SE1->(E1_SALDO)
		//Juros Compostos (par�metro MV_JURTIPO = C)
		ElseIf _cTpJur == 'C'
			//Juros = Saldo do Titulo *((1+(taxa de juros/100))**dias de atraso)
			_nValJur := Round(M->(E1_SALDO) * ((1+(M->E1_PORCJUR/100))**_nDias),2) - SE1->(E1_SALDO)
		//Juros Mistos (par�metro MV_JURTIPO = M)Este tipo de juro � a combina��o do simples com o composto:
		ElseIf _cTpJur == 'M'
			//At� 30 dias, � calculado o juro simples:
			If _nDias <= 30
				//Juros = Saldo do Titulo *(1+(dias de atraso*(taxa de juros/100)))
				_nValJur := Round((M->(E1_SALDO))*(1+(_nDias *((M->E1_PORCJUR)/100))),2) - SE1->(E1_SALDO)
			//Acima de 30 dias, calcula-se o juro composto:
			Else
				//Juros = Saldo do titulo *(1+(30*(taxa de juros/100)))*((1+(taxa de juros/100))**dias de atraso-30) 
				_nValJur := Round((M->E1_SALDO) *(1+(30*((M->E1_PORCJUR)/100)))*((1+((M->E1_PORCJUR)/100))**(_nDias-30)),2) - SE1->(E1_SALDO)
			EndIf
		EndIf
	ElseIf !(Empty(SE1->E1_VALJUR))
		//Juros = Valor da Taxa de Perman�ncia * dias de atraso
		_nValJur := Round((M->E1_VALJUR) * (_nDias),2)
	EndIf
	If _nValJur > 0
		If !MSGBOX('A altera��o do vencimento gerou um acr�scimo ao t�tulo de R$ '+cValToChar(_nValJur)+' Confirmar o valor?',_cRotina+'_001','YESNO')
			_nValJur = 0
		EndIf
	EndIf
EndIf

Return(_nValJur)