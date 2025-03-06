#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWBROWSE.CH"

#DEFINE _CRLF   CHR(13)+CHR(10)
/*/{Protheus.doc} RTMKC002
@description MBrowse para administração do follow up de vendas, substitui a rotina anterio onde salvamos o fonte no arquivo RTMKC004.
@author Diego Rodrigues (ALL System Solutions)
@since 23/10/2024
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RTMKC002()
	Private oBrowse
    Private oTempTable
    Private _cRotina    := 'RTMKC002'
    Private _cTabZZB := "ZZBV"+GetNextAlias()
    Private cCadastro := "Historico de Clientes"
	Private aRotina := {{"Pesquisar" ,"AxPesqui",0,1} ,;
                        { "&Refresh" ,"U_ATUTELA()",0,3,0,.F.},;
			            {"Visualizar","U_HISTZZB((_cTabZZB)->ZD_CODCLI,(_cTabZZB)->ZD_LOJA,(_cTabZZB)->ZD_NOMECLI)",0,2} ,;
			            {"Incluir"   ,"U_ATUZZB()",0,3}}
//                            Título              Campo        Tipo                     Tamanho                  Decimais                 Picture
    private	aColunas := {	{ "FILIAL"           ,"ZD_FILIAL" ,TamSX3("ZD_FILIAL")[03]  ,TamSX3("ZD_FILIAL")[01],TamSX3("ZD_FILIAL")[02],""     },;
                            { "Cliente"          ,"ZD_CODCLI ",TamSX3("ZD_CODCLI ")[03] ,TamSX3("ZD_CODCLI ")[01],TamSX3("ZD_CODCLI ")[02],""     },;
                            { "Loja"             ,"ZD_LOJA"   ,TamSX3("ZD_LOJA" )[03]   ,TamSX3("ZD_LOJA" )[01],TamSX3("ZD_LOJA" )[02],""     },;
                            { "Nome Cliente"     ,"ZD_NOMECLI",TamSX3("ZD_NOMECLI")[03] ,TamSX3("ZD_NOMECLI")[01],TamSX3("ZD_NOMECLI")[02],""     }}
    
    //aRegistro := GetDadosAgrupadosPorCliente()
    DadosZZB()
	// Instanciamento da Classe de Browse
	oBrowse   := FwMBrowse():New(cCadastro)
	// Definição da tabela do Browse
	oBrowse:SetAlias(_cTabZZB)
    //Definição das informações apresentadas em Tela
    //oBrowse:SetArray(aRegistro)
    //seta as colunas para o browse
	oBrowse:SetFields(aColunas)
	// Titulo da Browse
	oBrowse:SetDescription('Historico de Clientes')
    // Opcionalmente pode ser desligado a exibição dos detalhes
	//oBrowse:DisableDetails()
    oBrowse:SetWalkThru(.F.)
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetUseCaseFilter(.T.)
	oBrowse:OptionReport(.T.)
	// Ativação da Classe
	oBrowse:Activate()

    oTempTable:Delete()
Return

// Função para recuperar os dados agrupados por cliente para montagem da Tela
Static Function DadosZZB()
    Local aFields := {}
    
    if Select(_cTabZZB) > 0
        dbSelectArea(_cTabZZB)
		(_cTabZZB)->(dbCloseArea())
	endif
    //Cria a temporária
    oTempTable := FWTemporaryTable():New(_cTabZZB)
    
    //Adiciona no array das colunas as que serão incluidas (Nome do Campo, Tipo do Campo, Tamanho, Decimais)
    aFields := {}
    _aTam := TamSX3("ZD_FILIAL ")
	AADD(aFields,{ "ZD_FILIAL ",_aTam[3],_aTam[1],_aTam[2] } )
	_aTam := TamSX3("ZD_CODCLI ")
	AADD(aFields,{ "ZD_CODCLI ",_aTam[3],_aTam[1],_aTam[2] } )
	_aTam := TamSX3("ZD_LOJA" )
	AADD(aFields,{ "ZD_LOJA" ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam := TamSX3("ZD_NOMECLI")
	AADD(aFields,{ "ZD_NOMECLI",_aTam[3],_aTam[1],_aTam[2] } )
	//_aTam := TamSX3("ZD_DATA "   )
	//AADD(aFields,{ "ZD_DATA "   ,_aTam[3],_aTam[1],_aTam[2] } )
    
    //Define as colunas usadas
    oTempTable:SetFields( aFields )
    
    //Cria índice com colunas setadas anteriormente
    oTempTable:AddIndex("1", {"ZD_FILIAL", "ZD_CODCLI","ZD_LOJA"} )
    
    //Efetua a criação da tabela
    oTempTable:Create()

    BeginSQl Alias "ZZDALIAS"
     
        SELECT DISTINCT ZD_CODCLI,ZD_LOJA,ZD_NOMECLI,ZD_FILIAL
        FROM SZD010 SZD (NOLOCK)
        WHERE SZD.D_E_L_E_T_ = ''
	    GROUP BY ZD_FILIAL, ZD_CODCLI,ZD_LOJA,ZD_NOMECLI
	    ORDER BY ZD_CODCLI, ZD_LOJA 
    EndSql
    

    While ZZDALIAS->(!EOF())
        while !RecLock(_cTabZZB,.T.) ; enddo
        //RecLock((_cTabZZB),.T.)
            (_cTabZZB)->ZD_FILIAL := ZZDALIAS->ZD_FILIAL
            (_cTabZZB)->ZD_CODCLI := ZZDALIAS->ZD_CODCLI
            (_cTabZZB)->ZD_LOJA   := ZZDALIAS->ZD_LOJA
            (_cTabZZB)->ZD_NOMECLI := ZZDALIAS->ZD_NOMECLI
            //ZZBV->ZD_DATA := STOD(ZZDALIAS->ZD_DATA)
        (_cTabZZB)->(MsUnLock())
        ZZDALIAS->(dbSkip())
    EndDo
    ZZDALIAS->(dbCloseArea())

Return

/*/{Protheus.doc} HISTZZB
@description Rotina de visualização do historico do cliente
@author Diego Rodrigues (ALL System Solutions)
@since 23/10/2024
@version 1.0
@param _cCli   , caracter, Codigo do cliente
@param _cLoj    , caracter, Loja do cliente
@param _cNome   , caracter, Nome do cliente
@type function
@see https://allss.com.br
/*/
User function HISTZZB(_cCli,_cLoj,_cNome)
	local _oButton1L,_oButton2L,_oButton3L, _oGroup1L, _oSayL
	local _oObj        := GetObjBrow()
	local _cCodCli     := _cCli
	//local _cNome       := _cNome

	private _cRotina   := "HISTZZB"
	private _cAlias    := "SZD"
	private _aSavLGer  := GetArea()
	private _aSavLLOG  := {}
	private _aAux1L    := {}
	private _cCliente  := _cCli
    Private _cLoja     := _cLoj

	dbSelectArea(_cAlias)
	_aSavLLOG  := (_cAlias)->(GetArea())
    (_cAlias)->(dbSetOrder(1))
    (_cAlias)->(dbGoTop())
    If !Empty(_cCodCli)
		static _oDlgL
		DEFINE MSDIALOG _oDlgL TITLE "["+_cRotina+"] Historico de Contatos com o Cliente"           												FROM 000,000 TO 555,0950         COLORS 0, 16777215     PIXEL
			@ 003, 003 GROUP  _oGroup1L  TO 272, 472 PROMPT " HISTORICO  "                                                          					OF _oDlgL COLOR  0, 16777215          				PIXEL
			@ 020, 010 SAY    _oSayL                 PROMPT "CÓDIGO: " + _cCodCli + "  -  LOJA: " + _cLoja + "  -  NOME CLIENTE: " + _cNome  			SIZE 200, 007 OF _oDlgL COLORS 0, 16777215          PIXEL
			@ 017, 410 BUTTON _oButton1L             PROMPT "&Sair"  				ACTION Close(_oDlgL) 															SIZE 050, 012 OF _oDlgL                 PIXEL
			@ 017, 350 BUTTON _oButton2L             PROMPT "Incluir Follow UP"  	ACTION U_ATUZZB() 																SIZE 050, 012 OF _oDlgL                 PIXEL
			@ 037, 410 BUTTON _oButton3L             PROMPT "Refresh"  				ACTION AtuGet1()																SIZE 050, 012 OF _oDlgL                 PIXEL
			fMSNewGe1()
		ACTIVATE MSDIALOG _oDlgL CENTERED
	else
		MsgStop("Sem Historico a apresentar!",_cRotina+"_002")
	endif
	RestArea(_aSavLLOG)
	RestArea(_aSavLGer)
	if Type("_oObj")=="O"
		_oObj:Default()
		_oObj:Refresh()
	endif
     if type("oBrowse")=="O"
		oBrowse:Refresh()
	endif
return
/*/{Protheus.doc} fMSNewGe1
@description Montagem da GetDados 1 para apresentação do historico do cliente
@obs Rotina principal: HISTZZB
@author Diego Rodrigues (ALL System Solutions)
@since 23/10/2024
@version 1.0
@type function
@see https://allss.com.br
/*/
static function fMSNewGe1()
Local _aColsExL      := {}
Local _aHeaderExL    := {}
Local _aFieldFillL   := {}
Local _aAlterFieldsL := {}
Local _cAliasSX3     := ""

Static _oMSNewGe1L

_cAliasSX3 := "SX3"

if Select(_cAliasSX3) > 0
	(_cAliasSX3)->(dbCloseArea())
endif

OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)

dbSelectArea(_cAliasSX3)
(_cAliasSX3)->(dbSetOrder(1))
(_cAliasSX3)->(MsSeek(_cAlias))
while !(_cAliasSX3)->(EOF()) .AND. AllTrim((_cAliasSX3)->X3_ARQUIVO) == _cAlias
	if cNivel >= (_cAliasSX3)->X3_NIVEL //após alguma atulização recente de dicionario (27/08/2019) o campo USADO mudou.
		Aadd(_aHeaderExL, {AllTrim(X3TITULO()),(_cAliasSX3)->X3_CAMPO,(_cAliasSX3)->X3_PICTURE,(_cAliasSX3)->X3_TAMANHO,(_cAliasSX3)->X3_DECIMAL,(_cAliasSX3)->X3_VALID,;
							(_cAliasSX3)->X3_USADO,(_cAliasSX3)->X3_TIPO,(_cAliasSX3)->X3_F3,(_cAliasSX3)->X3_CONTEXT,(_cAliasSX3)->X3_CBOX,(_cAliasSX3)->X3_RELACAO})
		Aadd(_aFieldFillL, CriaVar((_cAliasSX3)->X3_CAMPO))
	endif
	dbSelectArea(_cAliasSX3)
	(_cAliasSX3)->(dbSetOrder(1))
	(_cAliasSX3)->(dbSkip())
enddo
Aadd(_aFieldFillL, .F.)
Aadd(_aColsExL, _aFieldFillL)

_aAux1L     := aClone(_aColsExL)
_oMSNewGe1L := MsNewGetDados():New( 060, 007, 274, 467, /*GD_UPDATE*/, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", _aAlterFieldsL,, 999, "AllwaysTrue", "", "AllwaysTrue", _oDlgL, _aHeaderExL, _aColsExL)

AtuGet1()
if Select(_cAliasSX3) > 0
	(_cAliasSX3)->(dbCloseArea())
endif
if type("oBrowse")=="O"
		oBrowse:Refresh()
endif

return
/*/{Protheus.doc} AtuGet1
@description Funcao de atualização do Get Dados 1 para montagem da tela de historico do cliente
@obs Rotina principal: HISTZZB
@author Diego Rodrigues (ALL System Solutions)
@since 23/10/2024
@version 1.0
@type function
@see https://allss.com.br
/*/
static function AtuGet1()
	local _x        := 0//
//	local _nPos     := 0
	local _cQry     := ""
	local _cTABLOG  := GetNextAlias()

	_oMSNewGe1L:aCols := {}

	_cQry := " SELECT TABLOG.R_E_C_N_O_ RECLOG " + _CRLF
	_cQry += " FROM " + RetSqlName(_cAlias) + " TABLOG (NOLOCK) " + _CRLF
	_cQry += " WHERE TABLOG.ZD_FILIAL = '" + xFilial(_cAlias) + "' " + _CRLF
	if !Empty(_cCliente)
		_cQry += "AND	TABLOG.ZD_CODCLI = '" + _cCliente + "' " + _CRLF
	endif
	if !Empty(_cLoja) 
		_cQry += "AND	TABLOG.ZD_LOJA = '" + _cLoja + "' " + _CRLF
	endif
	_cQry += "  AND TABLOG.D_E_L_E_T_ = '' " + _CRLF
	_cQry += " ORDER BY " + StrTran(StrTran(SZD->(IndexKey(1)),"+",","),"DTOS(ZD_DATA)","ZD_DATA") + _CRLF
	//MemoWrite("\2.Memowrite\"+_cRotina+"_QRY_001.txt",_cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cTABLOG,.F.,.F.)
	TCSETFIELD(_cTABLOG,IIF(Substr(_cAlias,1,1)=="S",SubStr(_cAlias,2,2),_cAlias)+"_DATA","D",08,0)
	dbSelectArea(_cTABLOG)
	if !(_cTABLOG)->(EOF())
		while !(_cTABLOG)->(EOF())
			dbSelectArea(_cAlias)
			(_cAlias)->(dbGoTo((_cTABLOG)->RECLOG))
			_aCpos1 := {}
			for _x := 1 To Len(_oMSNewGe1L:aHeader)
				AADD(_aCpos1,&(_cAlias+"->"+_oMSNewGe1L:aHeader[_x][02]))
			next
			AADD(_aCpos1,.F.)
			AADD(_oMSNewGe1L:aCols,_aCpos1)
			dbSelectArea(_cTABLOG)
			(_cTABLOG)->(dbSkip())
		enddo
	endif
	dbSelectArea(_cTABLOG)
	(_cTABLOG)->(dbCloseArea())
	if Empty(_oMSNewGe1L:aCols)
		_oMSNewGe1L:aCols := aClone(_aAux1L)
	endif
	_oMSNewGe1L:Refresh()
return .T.

/*/{Protheus.doc} ATUZZB
@description Funcao de inclusão do historico do cliente
@obs Rotina principal: RTMKC002
@author Diego Rodrigues (ALL System Solutions)
@since 23/10/2024
@version 1.0
@type function
@see https://allss.com.br
/*/
User Function ATUZZB()

Local _aSavArea := GetArea()
Local _aSavZZB  := (_cTabZZB)->(GetArea())
Local cCodCli
Local cLojaCli
Local dDtConta
Local dDtProxi


Local oGroup1
//Local oGroup2
Local oGroup3
Local oCancela
Local oConfirma
Local CodCli
Local LojaCli
Local Nomcli
Local dDtCont
Local dDtProx
Local mObsPad

Private oLojaCli
Private oNomCli
Private oDlgZZB
Private _cCodCli    := (_cTabZZB)->ZD_CODCLI
Private _cLojaCli   := (_cTabZZB)->ZD_LOJA
Private _cNomcli    := (_cTabZZB)->ZD_NOMECLI
Private _cObsPad    := ""
Private _dDtContato := CTOD(" / / ")
Private _dDtProxi   := CTOD(" / / ")

//Static oDlgZZB

  DEFINE MSDIALOG oDlgZZB TITLE "Follow-up de vendas" FROM 000, 000  TO 500, 495 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME
	oDlgZZB:lEscClose := .F.
	
    @ 002, 004 GROUP oGroup1 TO 222, 247 PROMPT "Inseri as informações referente ao contato com o Cliente." OF oDlgZZB COLOR 8404992, 16777215                             PIXEL

    @ 017, 007 SAY   CodCli              PROMPT "Cliente:"                              SIZE 042, 010 OF oDlgZZB COLORS 0, 16777215                                    PIXEL
    @ 017, 099 SAY   LojaCli             PROMPT "Loja:"                                 SIZE 027, 010 OF oDlgZZB COLORS 0, 16777215   PIXEL
    
    @ 015, 050 MSGET cCodCli             VAR _cCodCli                                   SIZE 037, 012 OF oDlgZZB COLORS 0, 16777215   F3 "SA1"                          PIXEL
    @ 015, 126 MSGET cLojaCli            VAR _cLojaCli                                 SIZE 035, 012 Valid PesqCli(_cCodCli,_cLojaCli) OF oDlgZZB COLORS 0, 16777215         PIXEL
    
    @ 035, 007 SAY   Nomcli              PROMPT "Nome:"                                SIZE 030, 010 OF oDlgZZB COLORS 0, 16777215                                   PIXEL
    @ 033, 050 MSGET oNomCli             VAR _cNomcli                                  SIZE 192, 012 OF oDlgZZB COLORS 0, 16777215                   PIXEL
    
    @ 060, 007  SAY   dDtCont			 PROMPT "Data Contato:"                     SIZE 037, 007 OF oDlgZZB                                                	COLORS 0, 16777215 PIXEL
    @ 057, 050 MSGET   dDtConta          VAR _dDtContato                            SIZE 070, 010 OF oDlgZZB PICTURE PesqPict("SZD","ZD_DATA")           VALID NAOVAZIO()  COLORS 0, 16777215 PIXEL

    @ 080, 007  SAY   dDtProx			 PROMPT "Proximo Contato:"                     SIZE 037, 007 OF oDlgZZB                                                	COLORS 0, 16777215 PIXEL
    @ 077, 050 MSGET   dDtProxi          VAR _dDtProxi                           SIZE 070, 010 OF oDlgZZB PICTURE PesqPict("SZD","ZD_DATA")           VALID NAOVAZIO()  COLORS 0, 16777215 PIXEL

	@ 130, 006 GROUP oGroup3 TO 219, 245 PROMPT "Comentarios do Contato com o Cliente"			  OF oDlgZZB COLOR 8404992, 16777215                                                          PIXEL
    @ 142, 008 GET   mObsPad             VAR _cObsPad OF oDlgZZB MULTILINE                SIZE 235, 070 COLORS 0, 16777215 HSCROLL                                    PIXEL

    @ 225, 126 BUTTON oCancela           PROMPT "Cancela"                              SIZE 050, 012 OF oDlgZZB ACTION Cancelar()                                     PIXEL
    @ 225, 189 BUTTON oConfirma          PROMPT "Confirmar"                            SIZE 050, 012 OF oDlgZZB ACTION Confirmar()                                    PIXEL

  ACTIVATE MSDIALOG oDlgZZB CENTERED

RestArea(_aSavZZB)
RestArea(_aSavArea)

Return

/*/{Protheus.doc} AtuGet1
@description Funcao de inclusão do historico do cliente
@obs Rotina principal: HISTZZB
@author Diego Rodrigues (ALL System Solutions)
@since 23/10/2024
@version 1.0
@type function
@see https://allss.com.br
/*/
Static Function Confirmar()

If MsgYesNo("Deseja confirmar a gravação das alterações? ",_cRotina+"_002")

	dbSelectArea("SZD")
	SZD->(dbSetOrder(1))
	If !Empty(_cObsPad)
		RecLock('SZD',.T.) 
            SZD->ZD_DATA    := _dDtContato
            SZD->ZD_DATAPRO := _dDtProxi
			SZD->ZD_CODCLI  := _cCodCli
			SZD->ZD_LOJA    := _cLojaCli
			SZD->ZD_NOMECLI := _cNomcli
            SZD->ZD_CODUSER := UsrRetName(__cUserId)
			SZD->ZD_HISTORI := _cObsPad

		SZD->(MsUnLock())
    Else
       MsgInfo('Nenhuma observação informada!!!',_cRotina+'_001','ATENÇÃO')
        Close(oDlgZZB)
    EndIf
    Close(oDlgZZB)
EndIf
if type("oBrowse")=="O"
    oBrowse:Refresh()
endif
Return
/*/{Protheus.doc} AtuGet1
@description Funcao de cancelamento do cadastro de historico do cliente
@obs Rotina principal: HISTZZB
@author Diego Rodrigues (ALL System Solutions)
@since 23/10/2024
@version 1.0
@type function
@see https://allss.com.br
/*/
Static Function Cancelar()

Close(oDlgZZB)
MsgInfo("Alteração não realizada. ",_cRotina+"_001","Atenção")

if type("oBrowse")=="O"
    oBrowse:Refresh()
endif
Return

/*/{Protheus.doc} PesqCli
@description Funcao de cancelamento do cadastro de historico do cliente
@obs Rotina principal: ATUZZB
@author Diego Rodrigues (ALL System Solutions)
@since 23/10/2024
@version 1.0
@type function
@see https://allss.com.br
/*/

Static Function PesqCli(_cCodCli,_cLojaCli)
    
    Local cQry := GetNextAlias()
    _cNomclic := ""
	cCodProd := ""

    BeginSql Alias cQry
		SELECT
			A1_NOME
		FROM
			%Table:SA1% SA1 (NOLOCK)
		WHERE
			SA1.A1_FILIAL = %Xfilial:SA1%
			AND SA1.A1_COD = %Exp:_cCodCli%
            AND SA1.A1_LOJA = %Exp:_cLojaCli%
			AND SA1.%NotDel%
	EndSql

    _cNomcli := Alltrim((cQry)->A1_NOME)

	oNomCli:cText := _cNomcli
	oNomCli:Refresh()
	oNomCli:SetFocus()

Return()

/*/{Protheus.doc} ATUTELA
@description Rotina responsável por chamar o refresh da tela tela.
@author Diego Rodrigues
@since 23/10/2024
@version 1.0
@type function
@see https://allss.com.br
/*/
user function ATUTELA()
	local   _cFNBkp    := FunName()

	dbSelectArea(_cTabZZB)
	MsgRun("Aguarde... Atualizando informações...",_cRotina,{ || DadosZZB() })
	SetFunName(_cFNBkp)
    if type("oBrowse")=="O"
        oBrowse:Refresh()
    endif
return


