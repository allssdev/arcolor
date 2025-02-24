#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RFINE028  ºAutor  ³ Júlio Soares      º Data ³  14/12/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³                                                            º±±
±±º          ³ ###   DESATIVADO EM 05/04/2016   ###                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Este Ecexcblock tem o objetido de calcular o valor de jurosº±±
±±º          ³ quando há a alteração do vencimento do título.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico empresa ARCOLOR                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// - Criar gatilho para atualização do campo de acréscimo com o retorno do execblock

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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CalcJur  ºAutor  ³ Júlio Soares       º Data ³  14/12/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina responsável por realizar o cálculo do valor dos     º±±
±±º          ³ juros conforme dias em atraso.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico empresa ARCOLOR                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CalcJur()

Local _cTpJur	:= SuperGetMV('MV_JURTIPO',,'',)
Local _nDias	:= 0
Local _nValor	:= 0

If !(M->E1_TIPO) $ 'RA/PA/NCC/NDF'
	//_nDias := ((dDataBase) - (M->(E1_VENCREAL)))
	_nDias := (M->(E1_VENCREAL) - SE1->(E1_VENCREAL))
	//Quando não houver percentual de juros indicado no título, o juro será calculado pela taxa de permanência  da seguinte forma:
	If !(Empty(M->E1_PORCJUR)) .And. _nDias > 0
		//Juros Simples (parâmetro MV_JURTIPO = S)
		If _cTpJur == 'S'
			//Juros = Saldo do Titulo *(1+(dias de atraso *(taxa de juros/100)))
			_nValJur := Round((M->(E1_SALDO))*(1+(_nDias *((M->E1_PORCJUR)/100))),2) - SE1->(E1_SALDO)
		//Juros Compostos (parâmetro MV_JURTIPO = C)
		ElseIf _cTpJur == 'C'
			//Juros = Saldo do Titulo *((1+(taxa de juros/100))**dias de atraso)
			_nValJur := Round(M->(E1_SALDO) * ((1+(M->E1_PORCJUR/100))**_nDias),2) - SE1->(E1_SALDO)
		//Juros Mistos (parâmetro MV_JURTIPO = M)Este tipo de juro é a combinação do simples com o composto:
		ElseIf _cTpJur == 'M'
			//Até 30 dias, é calculado o juro simples:
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
		//Juros = Valor da Taxa de Permanência * dias de atraso
		_nValJur := Round((M->E1_VALJUR) * (_nDias),2)
	EndIf
	If _nValJur > 0
		If !MSGBOX('A alteração do vencimento gerou um acréscimo ao título de R$ '+cValToChar(_nValJur)+' Confirmar o valor?',_cRotina+'_001','YESNO')
			_nValJur = 0
		EndIf
	EndIf
EndIf

Return(_nValJur)