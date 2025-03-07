#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH' 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FT560FIL   �Autor  �J�lio Soares      � Data �  28/03/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada utilizado para filtrar o Browser de acordo���
���          � com solicita��es do cliente.                               ���
���          � Espec�fico para filtrar os movimentos de acordo com os     ���
���          � setores de cada usu�rio.                                   ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa Arcolor                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FT560FIL()

Local _aSavArea   := GetArea()
Local _aSavSEU    := SEU->(GetArea())
Local _aCores     := {}
Local _cAlias     := "SEU"
Local _cFilSEU    := ""
Local _cUserId    := __cUserId

Private _cUserPer  := SuperGetMV('MV_USRCXIL',,"")
Private _cUserPer  := SuperGetMV('MV_USRCXIF',,"")
Private _aIndexSEU := {}

If _cUserId $ (AllTrim(SuperGetMV("MV_USRCXIL",,"")))
	_cFilSEU := " EU_CARGA <> '' .AND. Empty(EU_BAIXA) "
ElseIf _cUserId $ (Alltrim(SuperGetMV("MV_USRCXIF","","")))
	_cFilSEU := " Empty(EU_CARGA) "
Else
	_cFilSEU := ""
EndIf

_aCores := {{ 'EU_TIPO="00"     .AND. Empty(EU_BAIXA) .AND. Empty(EU_NROADIA)','ENABLE'    },; // Despesas nao baixadas
			{ 'EU_TIPO="00"     .AND. Empty(EU_BAIXA)'                        ,'BR_AZUL'   },; // Despesas de adiantamento nao baixadas
			{ 'EU_TIPO="01"     .AND. EU_SLDADIA>0'                           ,'BR_AMARELO'},; // Adiantamento com saldo (em aberto)
			{ 'EU_TIPO="03"'                                                  ,'BR_MARRON' },; // Complemento de adiantamento
			{ '!Empty(EU_BAIXA)'                                              ,'DISABLE'   } } // despesas baixadas e outros movimentos

If Valtype(_cFilSEU) == "C" .AND. !Empty(_cFilSEU)
	bFiltraBrw := {|| FilBrowse(_cAlias,@_aIndexSEU,@_cFilSEU)}
	Eval(bFiltraBrw)
EndIf

RestArea(_aSavSEU)
RestArea(_aSavArea)

Return() 