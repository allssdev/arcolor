#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �OS200BUT  �Autor  �J�lio Soares        � Data �  17/10/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada para incluir bot�es na EnchoiBar da rotina���
���          � de montagem de carga (OMSA200).                            ���
���          � Este ponto � utilizado aqui para adicionar a tecla de      ���
���          � atalho "F12" para a pesquisa dos pedidos de vendas na tela ���
���          � de montagem de cargas.                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function OS200BUT()
	Local aCampos  := {}
	Local aCpoBrw  := {}
	//nTipo        := oCpo:nAt,OmsChgPict(nTipo,aCampos,aCpo,@xPesq,oPesq,@cCpo)
	Local nTipo    := 1
	Local _cRotina := 'OS200BUT'

	//SetKey(VK_F12, { || OmsPesqPed("TRBPED",aCampos,aCpoBrw) })
	// Teclas alterada em 19/08/15 por J�lio Soares para n�o conflitar com as teclas de atalho padr�o.
	SetKey( VK_F12,{|| MsgAlert( "Tecla [ F12 ] foi alterada para [ Ctrl + F12 ]" , "Protheus11" )})
	SetKey( K_CTRL_F12, { || })
	SetKey( K_CTRL_F12, { || OmsPesqPed("TRBPED",aCampos,aCpoBrw) })
Return
/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �OmsPesqPed� Autor � DL                    � Data �08.08.2001 ���
��������������������������������������������������������������������������Ĵ��
���          �Pesquisa registro em um arquivo temporario                   ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ExpA1 : Array com a estrutura do TRB                         ���
���          �ExpA2 : Array com os dados de exibicao do TRB                ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Descricao �Esta rotina tem como objetivo cancelar as movimentacoes      ���
���          �feitas do cliente                                            ���
��������������������������������������������������������������������������Ĵ��
���Uso       � APDL                                                        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
static function OmsPesqPed(cAliasTRB,aCampos,aCpoBrw)
	Local aCpoLbl  := {}
	Local aCpo     := {}
	Local cCpoLbl  := ""
	Local cCpo     := ""
	Local xPesq    := Space(20)
	Local nX       := 0
	Local nTipo    := 1
	Local nOpca    := 0
	Local nRegTRB  := TRBPED->(Recno())

	//Static _oDlgBt
	Private _oDlgBt

	//erro esta
	//A vari�vel p�blica '_aCpoBrw' foi alimentada por meio do Ponto de Entrada 'DL200BRW' com o conte�do da vari�vel Local 'aCpoBrw' utilizada pela rotina
	aCpoBrw := aClone(_aCpoBrw)
	//AAdd(aCpoLbl,aCpoBrw[17][3])
	//AAdd(aCpo,aCpoBrw[17][1])
	For nX := 1 to Len(aCpoBrw)
		If aCpoBrw[nX][1] == "PED_NOTA"
			AAdd(aCpoLbl,aCpoBrw[nX][3])
			AAdd(aCpo,aCpoBrw[nX][1])
		EndIf
	Next nX
	DEFINE MSDIALOG _oDlgBt TITLE OemtoAnsi("Pesquisa de Pedidos/Notas")  FROM 09,0 TO 20,50 OF oMainWnd
		//@ 000, 0 BITMAP oBmp RESNAME "PROJETOAP" OF _oDlgBt SIZE 30, 1000 NOBORDER WHEN .F. PIXEL ADJUST
		@ 014,035 SAY OemtoAnsi("Pesquisar por ->") OF _oDlgBt PIXEL
		@ 014,075 MSCOMBOBOX oCpo VAR cCpoLbl ITEMS aCpoLbl SIZE 55, 65 OF _oDlgBt PIXEL ON CHANGE (nTipo := oCpo:nAt,OmsChgPict(nTipo,aCampos,aCpo,@xPesq,oPesq,@cCpo))
		@ 028,035 SAY OemtoAnsi("Igual a: ") OF _oDlgBt PIXEL
		@ 028,075 MSGET oPesq VAR xPesq Picture "@!" SIZE 113, 10 OF _oDlgBt PIXEL
		oPesq:SetFocus()
		DEFINE SBUTTON oBut1 FROM 062, 130 TYPE 1 ACTION ( nOpca := 1, _oDlgBt:End() ) ENABLE OF _oDlgBt
		DEFINE SBUTTON oBut1 FROM 062, 160 TYPE 2 ACTION ( nOpca := 0, _oDlgBt:End() ) ENABLE OF _oDlgBt
	ACTIVATE MSDIALOG _oDlgBt CENTERED ON INIT OmsChgPict(nTipo, aCampos, aCpo, @xPesq, oPesq, @cCpo)
	If nOpca == 1
		DbSelectArea(cAliasTRB)
		(cAliasTRB)->(DbGoTop())
		While !(cAliasTRB)->(Eof()) .And. FieldGet(FieldPos(cCpo)) != xPesq
			(cAliasTRB)->(DbSkip())
		EndDo
		If (cAliasTRB)->(Eof())
			(cAliasTRB)->(MsGoto(nRegTRB))
		EndIf
		oMark:oBrowse:SetFocus()
	EndIf
return
/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �OmsChgPict� Autor � DL                    � Data �08.08.2001 ���
��������������������������������������������������������������������������Ĵ��
���          �Tratamento da pesquisa de arquivos temporarios               ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ExpN1 : Posicao do campo no Array                            ���
���          �ExpA2 : Array com a estrutura do arquivo                     ���
���          �ExpA3 : Array com os campos e labels do arquivo              ���
���          �ExpX4 : Variavel de pesquisa                                 ���
���          �ExpN5 : Objeto da variavel de pesquisa                       ���
���          �ExpC6 : Nome do campo por referencia para ser pesquisado     ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Descricao �Esta rotina tem como objetivo tratar a pesquisa a ser reali  ���
���          �zada no arquivo temporario                                   ���
��������������������������������������������������������������������������Ĵ��
���Uso       � APDL                                                        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
static function OmsChgPict(nTipo,aCampos,aCpo,xPesq,oPesq,cCpo)
	Local nPosCpo := 0
	Local cPict   := ""

	If Type("aCampos")<>"A" .OR. (Type("aCampos")=="A" .AND. Len(aCampos) == 0)
		aCampos := aClone(IIF(Type("_aCpo200")=="A",_aCpo200,{}))
	EndIf
	nPosCpo := Ascan(aCampos,{|x| x[1] == Alltrim(aCpo[nTipo])})
	If nPosCpo > 0
		cCpo  := aCampos[nPosCpo][1]
		Do Case
		Case aCampos[nPosCpo][2] == "N"
			xPesq := 0
			cPict := "@E 99,999,999.99"
		Case aCampos[nPosCpo][2] == "D"
			xPesq := dDataBase
			cPict := "@D"
		Case aCampos[nPosCpo][2] == "C"
			xPesq := Space(aCampos[nPosCpo][3])
			cPict := Replicate("!",aCampos[nPosCpo][3])
		EndCase
	EndIf
	oPesq:oGet:Picture := cPict
	oPesq:Refresh()
return
//Local _cBotoes := PARAMIXB
//Local _PARAMIXB := {}
//	AAdd( _PARAMIXB, { '99', 'Exibi�ao de Mensagem', MsgStop('Ignorando as Formas de Pagamento Escolhidas...'), {|| .T.} })
//aadd( _PARAMIXB ,{"procura", {|| OmsPesqPed(cAliasTRB,aCampos,aCpoBrw) )})})
//Set Key VK_F12 To OmsPesqPed("TRBPED",aCampos,aCpoBrw)
//SetKey(VK_F12, {|| ( OmsPesqPed())})	
//Return(_PARAMIXB)
// Rotina padr�o para procura -- OmsPesqPed(cAliasTRB,aCampos,aCpoBrw)
//SetKey(VK_F12,{|| OmsPesqPed()})
/*

Private _aBotoes := PARAMIXB
{'12','Exibi�ao de Mensagem','MsgStop("Ignorando as Formas dePagamento Escolhidas...")', {|| .T.} }
//aAdd(_aBotoes,{"Seleciona a nota"  , { || OmsPesqPed("TRBPED",aCampos,aCpoBrw) } ," Notas "})
{ "F12", { || OmsPesqPed("TRBPED",aCampos,aCpoBrw)}, "F12-1", "F12-2" }

/*
Menu de Fun��es <F12>
Esse ponto de entrada permite manipular a tecla F12, podendo customizar todas as 
rotinas a serem utilizadas no Menu de Fun��es.
Para utilizar o F12 para uma rotina espec�fica, coloque-a dentro do PE e retorne 
um array nulo.
Exemplo de uma rotina para a exibi��o de uma mensagem:
aArray := { '99', 'Exibi�ao de Mensagem', 'MsgStop('Ignorando as Formas de 
Pagamento Escolhidas...')', {|| .T.} }
Caso queira que seja a �nica a ser exibida, retorne:
Return ( { aArray } )
Para adicion�-la �s rotinas existentes:
AAdd( PARAMIXB, aArray )
Return( PARAMIXB )
FRTFUNCOES - Manipula a tecla F12 customizando rotinas ( [ ExpA1 ] ) --> Array
ExpA1   Array of Record
Linha 1 - String com o n�mero de refer�ncia na chamada 
do Menu
Linha 2 - String com o nome a ser exibido no Menu
Linha 3 - Codblock com retorno. True = Ignorar as formas de pagamento selecionadas e retornar � 
digita��o do produto 
Array(array_of_record) Retorno da Fun��o F12
*/