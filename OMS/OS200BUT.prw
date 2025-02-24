#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OS200BUT  ºAutor  ³Júlio Soares        º Data ³  17/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para incluir botões na EnchoiBar da rotinaº±±
±±º          ³ de montagem de carga (OMSA200).                            º±±
±±º          ³ Este ponto é utilizado aqui para adicionar a tecla de      º±±
±±º          ³ atalho "F12" para a pesquisa dos pedidos de vendas na tela º±±
±±º          ³ de montagem de cargas.                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico para a empresa Arcolor.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function OS200BUT()
	Local aCampos  := {}
	Local aCpoBrw  := {}
	//nTipo        := oCpo:nAt,OmsChgPict(nTipo,aCampos,aCpo,@xPesq,oPesq,@cCpo)
	Local nTipo    := 1
	Local _cRotina := 'OS200BUT'

	//SetKey(VK_F12, { || OmsPesqPed("TRBPED",aCampos,aCpoBrw) })
	// Teclas alterada em 19/08/15 por Júlio Soares para não conflitar com as teclas de atalho padrão.
	SetKey( VK_F12,{|| MsgAlert( "Tecla [ F12 ] foi alterada para [ Ctrl + F12 ]" , "Protheus11" )})
	SetKey( K_CTRL_F12, { || })
	SetKey( K_CTRL_F12, { || OmsPesqPed("TRBPED",aCampos,aCpoBrw) })
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OmsPesqPed³ Autor ³ DL                    ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Pesquisa registro em um arquivo temporario                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 : Array com a estrutura do TRB                         ³±±
±±³          ³ExpA2 : Array com os dados de exibicao do TRB                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Esta rotina tem como objetivo cancelar as movimentacoes      ³±±
±±³          ³feitas do cliente                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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
	//A variável pública '_aCpoBrw' foi alimentada por meio do Ponto de Entrada 'DL200BRW' com o conteúdo da variável Local 'aCpoBrw' utilizada pela rotina
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
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OmsChgPict³ Autor ³ DL                    ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Tratamento da pesquisa de arquivos temporarios               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Posicao do campo no Array                            ³±±
±±³          ³ExpA2 : Array com a estrutura do arquivo                     ³±±
±±³          ³ExpA3 : Array com os campos e labels do arquivo              ³±±
±±³          ³ExpX4 : Variavel de pesquisa                                 ³±±
±±³          ³ExpN5 : Objeto da variavel de pesquisa                       ³±±
±±³          ³ExpC6 : Nome do campo por referencia para ser pesquisado     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Esta rotina tem como objetivo tratar a pesquisa a ser reali  ³±±
±±³          ³zada no arquivo temporario                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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
//	AAdd( _PARAMIXB, { '99', 'Exibiçao de Mensagem', MsgStop('Ignorando as Formas de Pagamento Escolhidas...'), {|| .T.} })
//aadd( _PARAMIXB ,{"procura", {|| OmsPesqPed(cAliasTRB,aCampos,aCpoBrw) )})})
//Set Key VK_F12 To OmsPesqPed("TRBPED",aCampos,aCpoBrw)
//SetKey(VK_F12, {|| ( OmsPesqPed())})	
//Return(_PARAMIXB)
// Rotina padrão para procura -- OmsPesqPed(cAliasTRB,aCampos,aCpoBrw)
//SetKey(VK_F12,{|| OmsPesqPed()})
/*

Private _aBotoes := PARAMIXB
{'12','Exibiçao de Mensagem','MsgStop("Ignorando as Formas dePagamento Escolhidas...")', {|| .T.} }
//aAdd(_aBotoes,{"Seleciona a nota"  , { || OmsPesqPed("TRBPED",aCampos,aCpoBrw) } ," Notas "})
{ "F12", { || OmsPesqPed("TRBPED",aCampos,aCpoBrw)}, "F12-1", "F12-2" }

/*
Menu de Funções <F12>
Esse ponto de entrada permite manipular a tecla F12, podendo customizar todas as 
rotinas a serem utilizadas no Menu de Funções.
Para utilizar o F12 para uma rotina específica, coloque-a dentro do PE e retorne 
um array nulo.
Exemplo de uma rotina para a exibição de uma mensagem:
aArray := { '99', 'Exibiçao de Mensagem', 'MsgStop('Ignorando as Formas de 
Pagamento Escolhidas...')', {|| .T.} }
Caso queira que seja a única a ser exibida, retorne:
Return ( { aArray } )
Para adicioná-la às rotinas existentes:
AAdd( PARAMIXB, aArray )
Return( PARAMIXB )
FRTFUNCOES - Manipula a tecla F12 customizando rotinas ( [ ExpA1 ] ) --> Array
ExpA1   Array of Record
Linha 1 - String com o número de referência na chamada 
do Menu
Linha 2 - String com o nome a ser exibido no Menu
Linha 3 - Codblock com retorno. True = Ignorar as formas de pagamento selecionadas e retornar à 
digitação do produto 
Array(array_of_record) Retorno da Função F12
*/