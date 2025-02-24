#include "protheus.ch"
#include "rwmake.ch"
#include "totvs.ch"
#include "fwmvcdef.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSELMARQ   บAutor  ณJ๚lio Soares        บ Data ณ  04/02/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina utilizada para selecionar os tipos de opera็ใo      บฑฑ
ฑฑบ          ณ atrav้s de uma janela com op็๕es da tabela X5-DJ para que  บฑฑ
ฑฑบ          ณ o relat๓rio de Faturamento em Excel seja filtrado          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico empresa ARCOLOR                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function SELMARQ()

Local   aArea         := GetArea() 
Local   aCampos       := {}
Local   aSeek         := {}
Local   _cTit         := "Sele็ใo dos Tipos de Opera็ใo"
Local   cIndice1      := ""
Local   cIndice2      := ""
Local   lMarcar       := .F.

Private oMark
Private _cAlias       := "TRCTMP"
Private _cRotina      := "SELMARQ"
Private _aSelect      := {}

#IFDEF TOP
	If !(TcSrvType()=="AS/400") .And. !("POSTGRES" $ TCGetDB())
		_cAlias := GetNextAlias()
	EndIf
#ENDIF

//Se o alias estiver aberto, fechar para evitar erros com alias aberto
If Select(_cAlias) <> 0
    dbSelectArea(_cAlias)
    (_cAlias)->(dbCloseArea())
EndIf
//Monto a estrutura da tabela temporแria
_aStru1 := {}
AADD(_aStru1,{"TC_OK"  ,"C",02,0})
AADD(_aStru1,{"TC_COD" ,"C",02,0})
AADD(_aStru1,{"TC_DESC","C",40,0})

/*
_cArq1 := CriaTrab(_aStru1,.T.)
//Criar indices
cIndice1 := cIndice2 := Alltrim(CriaTrab(,.F.))
cIndice1 := Left(cIndice1,5) + Right(cIndice1,2) + "A"
cIndice2 := Left(cIndice2,5) + Right(cIndice2,2) + "B"
//Se indice existir excluir
If File(cIndice1+OrdBagExt())
    FErase(cIndice1+OrdBagExt())
EndIf
If File(cIndice2+OrdBagExt())
    FErase(cIndice2+OrdBagExt())
EndIf
//A fun็ใo dbUseArea abre uma tabela de dados na แrea de trabalho atual ou na primeira แrea de trabalho disponํvel
dbUseArea(.T.,,_cArq1,_cAlias,.T.,.F.)
//A fun็ใo IndRegua cria um ํndice temporแrio para o alias especificado, podendo ou nใo ter um filtro
IndRegua(_cAlias,cIndice1,"TC_COD" ,,,"Criando ํndice temporario...")
IndRegua(_cAlias,cIndice2,"TC_DESC",,,"Criando ํndice temporario...")
//Fecha todos os ํndices da แrea de trabalho corrente.
dbClearIndex()
//Acrescenta uma ou mais ordens de determinado ํndice de ordens ativas da แrea de trabalho.
dbSetIndex(cIndice1+OrdBagExt())
dbSetIndex(cIndice2+OrdBagExt())
*/

//-------------------
//Criacao do objeto
//-------------------
_cAlias    := GetNextAlias()
oTempTable := FWTemporaryTable():New( _cAlias )
	
oTemptable:SetFields( _aStru1 )
oTempTable:AddIndex("indice1", {"TC_COD"} )
oTempTable:AddIndex("indice2", {"TC_DESC"} )

//------------------
//Criacao da tabela
//------------------
oTempTable:Create()

//Irei criar a pesquisa que serแ apresentada na tela
aAdd(aSeek,{"C๓digo"   ,{{"","C",002,0,"C๓digo"	  ,"@!"}} } )
aAdd(aSeek,{"Descri็ใo",{{"","C",040,0,"Descri็ใo","@!"}} } )
// - FORMACAO DA QUERY PARA VERIFICAR A TABELA X5-DJ
BeginSql Alias "SX5MARK"
	SELECT X5_CHAVE [OPERACAO], X5_DESCRI [DESCRICAO]
	FROM %table:SX5% SX5
	WHERE SX5.X5_FILIAL  = %xFilial:SX5%
	  AND SX5.X5_TABELA  = 'DJ'
	  AND SX5.%NotDel%
	ORDER BY X5_CHAVE
EndSql
//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",GetLastQuery()[02])
// - INSERE EM TABELA TEMPORARIA AS OPวีES SELECIONADAS
dbSelectArea("SX5MARK")//TEMPORARIA
SX5MARK->(dbGoTop())
While !SX5MARK->(EOF())
	RecLock(_cAlias,.T.)
		(_cAlias)->TC_OK      := "  "
		(_cAlias)->TC_COD     := SX5MARK->OPERACAO
		(_cAlias)->TC_DESC    := SX5MARK->DESCRICAO
	(_cAlias)->(MsUnLock())
	dbSelectArea("SX5MARK")
	SX5MARK->(dbSkip())
EndDo
dbSelectArea("SX5MARK")
SX5MARK->(dbCloseArea())
//Campos da tela
/*
Array contendo o objeto FWBrwColumn ou um array com a seguinte estrutura:
[n][01] Tํtulo da coluna
[n][02] Code-Block de carga dos dados
[n][03] Tipo de dados
[n][04] Mแscara
[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
[n][06] Tamanho
[n][07] Decimal
[n][08] Indica se permite a edi็ใo
[n][09] Code-Block de valida็ใo da coluna ap๓s a edi็ใo
[n][10] Indica se exibe imagem
[n][11] Code-Block de execu็ใo do duplo clique
[n][12] Variแvel a ser utilizada na edi็ใo (ReadVar)
[n][13] Code-Block de execu็ใo do clique no header
[n][14] Indica se a coluna estแ deletada
[n][15] Indica se a coluna serแ exibida nos detalhes do Browse
[n][16] Op็๕es de carga dos dados (Ex: 1=Sim, 2=Nใo)
*/
AADD(aCampos,{	"C๓digo",;
 				{|| (_cAlias)->TC_COD},;
 				ValType((_cAlias)->TC_COD),;
 				"@!",;
 				1,;
 				Len((_cAlias)->TC_COD),;
 				0,; 
				.F.,;
				{||.T.},;
				.F.,;
				{||.T.},;
				NIL,;
				{||.T.},;
				.F.,;
				.F.,;
				{} } )
AADD(aCampos,{	"Descri็ใo",;
 				{|| (_cAlias)->TC_DESC},;
 				ValType((_cAlias)->TC_DESC),;
 				"@!",;
 				1,;
 				Len((_cAlias)->TC_DESC),;
 				0,; 
				.F.,;
				{||.T.},;
				.F.,;
				{||.T.},;
				NIL,;
				{||.T.},;
				.F.,;
				.F.,;
				{} } )
//------------------------------------------------------------------------------------------------------------//
//estanciamento da classe mark
oMark := FWMarkBrowse():New()
//Titulo
oMark:SetDescription( _cTit )
//tabela que sera utilizada
oMark:SetAlias( _cAlias )
//colunas
oMark:SetColumns(aCampos)
//Indica que o Browse utiliza tabela temporแria
oMark:SetTemporary()
//campo que recebera a marca
oMark:SetFieldMark( "TC_OK" )
//
oMark:oBrowse:SetDBFFilter(.F.)
//Habilita a utiliza็ใo do filtro no Browse
oMark:oBrowse:SetUseFilter(.F.)
//Indica o filtro padrใo do Browse
oMark:oBrowse:SetFilterDefault("")
//
oMark:oBrowse:SetFixedBrowse(.T.)
//Habilita a utiliza็ใo da funcionalidade Walk-Thru no Browse
oMark:SetWalkThru(.F.)
//Habilita a utiliza็ใo da funcionalidade Ambiente no Browse
oMark:SetAmbiente(.F.)
//Habilita a utiliza็ใo da pesquisa de registros no Browse
oMark:oBrowse:SetSeek(.T.,aSeek)
//Defini็ใo dos bot๕es
oMark:AddButton("Confirmar"      , {|| SELDADOSTMP() }, , 4, /*< nVerify >*/)
//Na marca็ใo de um registro
oMark:SetAfterMark({ || FUNMARK(oMark:Mark(),lMarcar := !lMarcar ), oMark:Refresh(.T.)  })
//No clique duplo de um registro
oMark:SetDoubleClick({ || FUNMARK(oMark:Mark(),lMarcar := !lMarcar ), oMark:Refresh(.T.)  })
//Indica o Code-Block executado no clique do header da coluna de marca/desmarca
oMark:bAllMark := { || FUNMARKALL(oMark:Mark(),lMarcar := !lMarcar ), oMark:Refresh(.T.)  }
//Ativa
oMark:Activate()
//Seta o foco na grade
oMark:oBrowse:Setfocus()
//------------------------------------------------------------------------------------------------------------//
//Deleto a tabela temporแria
If Select(_cAlias) > 0
	dbSelectArea(_cAlias)
	(_cAlias)->(dbSetOrder(1))
	(_cAlias)->(dbCloseArea())
EndIf

oMark := NIL

RestArea(aArea)

Return(_aSelect)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณSELDADOSTMPบAutor  ณAnderson C. P. Coelho บ Data ณ 19/05/10 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณRotina utilizada para trazer os itens selecionados.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SELDADOSTMP()

_aSelect := {}

dbSelectArea(_cAlias)
(_cAlias)->(dbSetOrder(1))
(_cAlias)->(dbGoTop())
If !(_cAlias)->(EOF())
	While !(_cAlias)->(EOF())
		If !Empty((_cAlias)->TC_OK)
			AADD(_aSelect,(_cAlias)->TC_COD)
		EndIf
		dbSelectArea(_cAlias)
		(_cAlias)->(dbSetOrder(1))
		(_cAlias)->(dbSkip())
	EndDo
Else
	MSGBOX("Nenhuma opera็ใo selecionada!",_cRotina+"_001","STOP")
EndIf
oMark:Refresh()
dbSelectArea(_cAlias)
(_cAlias)->(dbSetOrder(1))
//oMark:DeActivate()
//oMark:oBrowse:DeActivate()
//If cVersao == "11"
//	(_cAlias)->(CloseBrowse())
//Else
	oMark:oBrowse:Hide()
	(_cAlias)->(CloseBrowse())
//EndIf	
//FreeObj(oMark)

return(_aSelect)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณFUNMARKALL บAutor  ณAnderson C. P. Coelhoบ Data ณ 19/05/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณMarca todos os itens do browse                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FUNMARKALL(cMarca,lMarcar)

Local _aArea    := GetArea()
Local _aAreaTmp := (_cAlias)->(GetArea())

dbSelectArea(_cAlias)
(_cAlias)->(dbGoTop())
While !(_cAlias)->(EOF())
	RecLock(_cAlias, .F.)
		(_cAlias)->TC_OK := IIf(lMarcar, cMarca, '  ')
	(_cAlias)->(MsUnLock())
	(_cAlias)->(dbSkip())
EndDo

oMark:Refresh()

RestArea( _aAreaTmp )
RestArea( _aArea )

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณFUNMARKALL บAutor  ณAnderson C. P. Coelhoบ Data ณ 19/05/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณMarca todos os itens do browse                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FUNMARK(cMarca,lMarcar)

dbSelectArea(_cAlias)
RecLock(_cAlias, .F.)
(_cAlias)->TC_OK := IIf(lMarcar, cMarca, '  ')
(_cAlias)->(MsUnLock())

oMark:Refresh()

Return(.T.)