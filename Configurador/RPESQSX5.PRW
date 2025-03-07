#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RPESQSX5  �Autor  � J�lio Soares      � Data �  06/24/16   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina respons�vel por fazer a pr�via sele��o das op��es a ���
���          � serem apresentadas no browser de pesquisa.                 ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RPESQSX5(_cChav,_nInd,_lOpc)
/*
_cChav - Chave da pesquisa X5_CHAVE
_nInd  - Indice da tabela, caso n�o informado ser� atribuido o indice 1
_lOpc  - Permite a sele��o de mais de um item ou n�o
*/
Local _cOpcoes	:= ""
Local _cRotina	:= "RPESQSX5"
Local _cTitCol	:= ""
Local _uVarRet

Private _aOpcoes	:={}
Private _cChav
Private _nInd
Private _lOpc		:= If (_lOpc == Nil,.F.,.T.)
Private _lTpRet	:= .T.

aSavArea := GetArea()

If _lTpRet
	_uVarRet:=&(Alltrim(ReadVar()))	// Carrega Nome da Variavel do Get em Questao
	mvRet:=Alltrim(ReadVar())		// Iguala Nome da Variavel ao Nome variavel de Retorno
EndIf

If !Empty(_cChav)
	If Empty(_nInd)
		_nInd := 1
	EndIf
Else
	MSGBOX('N�o foram encontrados par�metros v�lidos para executar a rotina.',_cRotina+'_001','STOP')
	Return()
EndIf

DbSelectArea("SX5")
DbSetOrder(_nInd)
If MsSeek(xFilial("SX5")+"00"+_cChav,.T.,.F.)
   _cTitCol := Alltrim(Left(x5Descri(),Len(Alltrim(x5Descri()))))
Endif
// Seleciona as op��es na SX5
If MsSeek(xFilial("SX5")+_cChav,.T.,.F.)
	While !Eof() .And. SX5->X5_Tabela == _cChav
		Aadd(_aOpcoes,Left(SX5->X5_CHAVE,Len(Alltrim(X5_CHAVE))) + " - " + Alltrim(x5Descri()))
		_cOpcoes +=   Left(SX5->X5_CHAVE,Len(Alltrim(X5_CHAVE)))
		SX5->(dbSkip())
	Enddo
Endif
/*
_uVarRet - Variavel de Retorno
_cTitCol - Titulo da Coluna com as opcoes
_aOpcoes - Opcoes de Escolha (Array de Opcoes)
_cOpcoes - String de Opcoes para Retorno
_lOpc    - Se a Selecao sera de apenas 1 Elemento por vez, APRESENTA OU N�O OS BOT�ES
_nTam    - Tamanho da Chave
_nElmRet - N� maximo de elementos na variavel de retorno
_lMltSel - Inclui Botoes para Selecao de Multiplos Itens
_lCmbBox - Se as opcoes serao montadas a partir de ComboBox de Campo (X3_CBOX)
_cCampo  - Qual o Campo para a Montagem do _aOpcoes
_lNotOrd - Nao Permite a Ordenacao
_lNotPsq - Nao Permite a Pesquisa
_lRetArr - Forca o Retorno Como Array
_cConsF3 - Consulta F3
*/
If _lTpRet
	If U_RPESQBROW(@_uVarRet,_cTitCol,_aOpcoes,_cOpcoes,_lOpc)
		&MvRet := _uVarRet
	EndIf
EndIf

RestArea(aSavArea)

Return(If(_lTpRet,.T.,_cOpcoes))