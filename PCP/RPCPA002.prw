#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} RPCPA002
@description fonte para a gerar ordem de producao atraves de produto tipo MO documento de entrada.
@author Eduardo M Antunes (ALL System Solutions)
@since 11/10/2018
@version 1.0

@type function
@see https://allss.com.br
/*/
user function RPCPA002(_cPRODUTO,_nQTD)
	Local   _aSavArea   := GetArea()
	Local   _aSavSC2    := SC2->(GetArea())
	Local   _aSavSD3    := SD3->(GetArea())
	Local   _aSavSB1    := SB1->(GetArea())
	Local _nOpc 	  	:= 3				//Variável de controle da função execauto - 1 = Pesquisa. 2 = Visualização. 3 = Inclusão. 4 = Alteração. 5 = Exclusão. 
	Local _cNum         := ""				// GetSx8Num("SC2","C2_NUM")
	
	Private _cRotina	:= "RPCPA002"   
	Private lMsErroAuto := .F.

	Default _cPRODUTO   := ""
	Default _nQTD       := 0

	If Empty(_cPRODUTO) .OR. _nQTD <= 0
		RestArea(_aSavSB1)
		RestArea(_aSavSD3)
		RestArea(_aSavSC2)
		RestArea(_aSavArea)
		return
	EndIf
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If !SB1->(MsSeek(xFilial("SB1") + _cProduto,.T.,.F.))
		MsgStop("Atenção! Produto '"+AllTrim(_cProduto)+"' não localizado!",_cRotina+"_001")
		RestArea(_aSavSB1)
		RestArea(_aSavSD3)
		RestArea(_aSavSC2)
		RestArea(_aSavArea)
		return
	EndIf
	_aRotAuto :=   {{"C2_PRODUTO" , _cPRODUTO      , Nil},;
            		{"C2_LOCAL"   , SB1->B1_LOCPAD , Nil},;
            		{"C2_QUANT"   , _nQTD          , Nil},;
            		{"C2_DATPRI"  , DDATABASE      , Nil},;
            		{"C2_DATPRF"  , DDATABASE      , Nil},;
            		{"C2_EMISSAO" , DDATABASE      , Nil},; 
            		{"AUTEXPLODE" , "S"            , Nil} }

	//Exclui a ordem de produção
	MSExecAuto({|x,y| mata650(x,y)},_aRotAuto,_nOpc)

	//Verifica processamento do execauto
	If lMsErroAuto
		MsgStop("Atenção houve uma falha na rotina e isso impacta nos empenhos do sistema, informe ao Administrador imediatamente, os detalhes do erro serão exibidos a seguir.",_cRotina+"_002")
		MostraErro()
	Else
		MsgInfo("A Ordem de Produção '" + AllTrim(SC2->C2_NUM) + "' foi gerada com sucesso! Agora, o sistema procederá a sua(s) baixa(s).",_cRotina+"_003")
		Processa( {|| Aponta(SC2->C2_NUM,_cPRODUTO,_nQTD,@lEnd) }, "Apontamento da OP '"+AllTrim(SC2->C2_NUM)+"'","Processando apontamentos...",.F.)
	EndIf
	RestArea(_aSavSB1)
	RestArea(_aSavSD3)
	RestArea(_aSavSC2)
	RestArea(_aSavArea)
return
static function Aponta(_cNum,_cPRODUTO,_nQTD,lEnd)
	Local   aVetor      := {}
	Local   nOpc        := 3 //-Opção de execução da rotina,
	Local   _cOp        := ""
//	Local   _cCodMv     := ""
	Local   _cTmPad     := AllTrim(SuperGetMv("MV_TMPAD" ,,"010"))

	Private lMsErroAuto := .F.

	Default _cNum       := SC2->C2_NUM

	BeginSql Alias "TEMPSC2"
		Select C2_FILIAL,C2_NUM,C2_ITEM,C2_SEQUEN, C2_PRODUTO, C2_QUANT, C2_LOCAL, C2_EMISSAO
			FROM %Table:SC2% SC2 (NOLOCK)
			WHERE SC2.C2_FILIAL = %xFilial:SC2%
			  AND SC2.C2_NUM    =  %Exp:_cNum%
			  AND SC2.%notdel%
			ORDER BY C2_SEQUEN DESC
	EndSql
	If __cUserId == "000000"
		MemoWrite(GetTempPath()+_cRotina+"_001.txt",GetLastQuery()[02])
	EndIf
	dbSelectArea("TEMPSC2")
	ProcRegua(TEMPSC2->(RecCount()))
	While !TEMPSC2->(EOF()) .AND. !lEnd
		_cOp   := AllTrim(TEMPSC2->(C2_NUM+C2_ITEM+C2_SEQUEN))
		IncProc("Processando baixa da OP '"+_cOp+"'...")
		aVetor := { {"D3_FILIAL" , xFilial("SD3")      , NIL},;
					{"D3_TM"     , _cTmPad             , NIL},;
					{"D3_OP"     , _cOp                , NIL},;
					{"D3_COD"    , TEMPSC2->C2_PRODUTO , NIL},;
					{"D3_QUANT"  , TEMPSC2->C2_QUANT   , NIL} } // {"D3_PARCTOT" , "P" ,NIL},;

		MSExecAuto({|x, y| mata250(x, y)},aVetor, nOpc )
		If lMsErroAuto
			MostraErro()
		Else
			MsgInfo("Apontamento da OP '"+_cOp+"' realizados com sucesso!" ,_cRotina+"_004")
		EndIf
		dbSelectArea("TEMPSC2")
		TEMPSC2->(dbSkip())
	EndDo
	dbSelectArea("TEMPSC2")
	TEMPSC2->(dbCloseArea())
return