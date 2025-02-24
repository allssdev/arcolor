#include "totvs.ch"

/*/{Protheus.doc} RPCP001
    Classe para alterar componente
    @author Fernando Bombardi - ALLSS
    @since 02/06/2022
    @type class
    @version P12.1.33
    /*/
Class RPCPC001 

    Method New() CONSTRUCTOR
    Method FormularioComponente()
    Method CarregarComponentes()
    Method GravarDados()
    Method DefinirMenu()

EndClass

/*/{Protheus.doc} New
    Metodo construtor da classe
    @author Fernando Bombardi - ALLSS
    @since 02/06/2022
    @type class
    @version P12.1.33
    /*/
Method New() class RPCPC001
    
Return

/*/{Protheus.doc} AlterarComponentes
    Metodo para criação do formulário para alteraçõa do componente da estrutura.
    @author Fernando Bombardi - ALLSS
    @since 02/06/2022
    @type class
    @version P12.1.33
    /*/
Method FormularioComponente(_nOPCAO,_cCodPai) class RPCPC001
Local   _aArea       := GetArea()
Local   _nX          := 1
Private aSizeAut     := MsAdvSize(,.F.,400)
Private nX           := 0
Private oDlgComp
Private aPosGet
Private oFont        := TFont():New('Geomanist',,-15,.T.)
Private oFont2       := TFont():New('Calibri',,-15,.T.)
Private _cErros      := ""
Private _aITENSCBO   := {}
Private _cCODPRD     := ""

Private _aHeaderCom := {}
Private _aColsCom   := {}

Public _oGetComp := Nil
Public _aNames       := {}

Public _oGetValor := Nil

    dbSelectArea("SG1")
    dbSetOrder(1)
    if !dbSeek(xFilial("SG1")+_cCodPai)
        MsgAlert("O produto não foi localizado!","[RPCPA05D_001] - Atenção")
        Return
    endif    

	//+--------------------------------------------------------------+
	// Carrega _aHeader
	//+--------------------------------------------------------------+	
	OpenSxs(,,,,,"SX3DIC","SX3",,.F.)
	If Select("SX3DIC") > 0

        //+--------------------------------------------------------------+
        // Carrega _aHeader Componentes
        //+--------------------------------------------------------------+	
        SX3DIC->(DbSetOrder(2)) // Campo
        IF SX3DIC->(dbSeek("G1_COMP"))
            Aadd(_aHeaderCom,{ AllTrim(FWX3Titulo(SX3DIC->X3_CAMPO)),;
            SX3DIC->X3_CAMPO  ,;
            SX3DIC->X3_PICTURE,;
            SX3DIC->X3_TAMANHO,;
            SX3DIC->X3_DECIMAL,;
            SX3DIC->X3_VALID  ,;
            SX3DIC->X3_USADO  ,;
            SX3DIC->X3_TIPO   ,;
            SX3DIC->X3_F3     ,;
            SX3DIC->X3_CONTEXT,;
            SX3DIC->X3_CBOX   ,;
            SX3DIC->X3_RELACAO})
        ENDIF

        SX3DIC->(DbSetOrder(2)) // Campo
        IF SX3DIC->(dbSeek("B1_DESC"))
            Aadd(_aHeaderCom,{ AllTrim(FWX3Titulo(SX3DIC->X3_CAMPO)),;
            SX3DIC->X3_CAMPO  ,;
            SX3DIC->X3_PICTURE,;
            SX3DIC->X3_TAMANHO,;
            SX3DIC->X3_DECIMAL,;
            SX3DIC->X3_VALID  ,;
            SX3DIC->X3_USADO  ,;
            SX3DIC->X3_TIPO   ,;
            SX3DIC->X3_F3     ,;
            SX3DIC->X3_CONTEXT,;
            SX3DIC->X3_CBOX   ,;
            SX3DIC->X3_RELACAO})
        ENDIF

        SX3DIC->(DbSetOrder(2)) // Campo
        IF SX3DIC->(dbSeek("G1_XEMBREC"))
            Aadd(_aHeaderCom,{ AllTrim(FWX3Titulo(SX3DIC->X3_CAMPO)),;
            SX3DIC->X3_CAMPO  ,;
            SX3DIC->X3_PICTURE,;
            SX3DIC->X3_TAMANHO,;
            SX3DIC->X3_DECIMAL,;
            SX3DIC->X3_VALID  ,;
            SX3DIC->X3_USADO  ,;
            SX3DIC->X3_TIPO   ,;
            SX3DIC->X3_F3     ,;
            SX3DIC->X3_CONTEXT,;
            SX3DIC->X3_CBOX   ,;
            SX3DIC->X3_RELACAO})
        ENDIF

        nUsado := Len(_aHeaderCom)
        aAdd(_aColsCom,Array(Len(_aHeaderCom)+1))
        For _nX := 1 To Len(_aHeaderCom)
            _aColsCom[1,_nX] := CriaVar(_aHeaderCom[_nX,2])
        Next
	    _aColsCom[Len(_aColsCom), Len(_aHeaderCom)+1] := .F.

	ENDIF

	aObjects := {}
	AAdd( aObjects, { 0,    41, .T., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],305,;
	{{10,40,105,140,200,234,275,200,225,260,285,265},;
	If(cPaisLoc<>"PTG",{10,40,105,140,200,234,63},{10,40,101,120,175,205,63,250,270}),;
	Iif(cPaisLoc<>"PTG",{5,70,160,205,295},{5,50,120,145,205,245,293}),;
	{6,34,200,215},;
	{6,34,80,113,160,185},;
	{6,34,245,268,260},;
	{10,50,150,190},;
	{273,130,190},;
	{8,45,80,103,139,173,200,235,270},;
	{133,190,144,190,289,293},;
	{142,293,140},;
	{9,47,188,148,9,146} })

    oDlgComp := TDialog():New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],"Embalagem Reciclável",,,,,CLR_BLACK,CLR_WHITE,,oMainWnd,.T.)

    _cDescPrc := 'Produto: ' + Alltrim(_cCodPai) + " - " + POSICIONE("SB1",1,XFILIAL("SB1")+_cCodPai,"B1_DESC")

	otMultiBtn := tMultiBtn():New( 10,10, _cDescPrc ,oDlgComp,,aPosObj[2,4]-30,150,'PCOIMG32',0,'Mensagem',3 )
	otMultiBtn:SetFonts('Geomanist',19,'Geomanist',10)
	IF _nOPCAO == 3 .OR. _nOPCAO == 4
		otMultiBtn:AddButton("Salvar")
	ENDIF
	otMultiBtn:AddButton('Sair')
    otMultiBtn:bAction := {|x,y| ::DefinirMenu(y,_nOPCAO,_cCodPai) }

	::CarregarComponentes(_cCodPai)

	_aAlterPerg :=  {'G1_XEMBREC'}
	_oGetComp   := MsNewGetDados():New(aPosObj[1,1]+40,aPosObj[1,2]-3,aPosObj[1,3]+380,aPosObj[1,4]+5,;
	GD_UPDATE,;
	"AllWaysTrue","AllwaysTrue","",_aAlterPerg,,LEN(_aColsCom),,,,oDlgComp,_aHeaderCom,_aColsCom)
    
	oDlgComp:Activate(,,,.T.)

	RestArea(_aArea)
RETURN

/*/{Protheus.doc} CarregarComponentes
    Metodo para carregar os componentes conforme o produto pai.
    @author Fernando Bombardi - ALLSS
    @since 02/06/2022
    @version P12.1.33
    @type class
    /*/
Method CarregarComponentes(_cCodPai) class RPCPC001
Local _nCnt := 1
Local _nCPO      := 0

    BeginSql alias 'COMP'
        SELECT
            G1_COMP,
            B1_DESC,
            G1_XEMBREC
        FROM
            %table:SG1% SG1 INNER JOIN %table:SB1% SB1
            ON SG1.G1_COMP = SB1.B1_COD
        WHERE
            SG1.G1_FILIAL = %xfilial:SG1%
            AND SG1.G1_COD = %exp:_cCodPai%
            AND SB1.B1_TIPO = 'EM'
            AND SG1.%notDel%
            AND SB1.%notDel%            
    EndSql
    _aQry := GetLastQuery()
    dbSelectArea("COMP")
    IF COMP->(!Eof())
        WHILE COMP->(!Eof())

            IF _nCnt > 1
                aADD(_aColsCom,Array(len(_aHeaderCom)+1))
            ENDIF

            FOR _nCPO := 1 to len(_aHeaderCom)
                _aColsCom[len(_aColsCom),_nCPO] := &("COMP->"+ALLTRIM(_aHeaderCom[_nCPO][2]))
            NEXT

            _aColsCom[len(_aColsCom),len(_aHeaderCom)+1] := .F.

            _nCnt++

            COMP->(dbSkip())
        ENDDO
    ENDIF
    COMP->(dbCloseArea())

Return


/*/{Protheus.doc} Gravar
    Metodo para gravar dados 
    @author Fernando Bombardi - ALLSS
    @since 03/06/2022
    @version P12.1.33
    @type class
    /*/
Method GravarDados(_CCODPAI) class RPCPC001
Local _aArea := GetArea()
LOCAL _nCPO  := 0
LOCAL _nITEM := 0
Local _nPOSCOMP := aScan(_aHeaderCom,{|x| AllTrim(Upper(x[2]))=="G1_COMP"   })
Local _nPOSEMBA := aScan(_aHeaderCom,{|x| AllTrim(Upper(x[2]))=="G1_XEMBREC"})

	//Grava dados
	FOR _nITEM := 1 TO LEN(_oGetComp:aCOLS)
		if !_oGetComp:aCols[_nITEM,len(_aHeaderCom)+1]
			dbSelectArea("SG1")
			dbSetOrder(1)
			if dbSeek(XFILIAL("SG1")+_cCodPai+_oGetComp:aCOLS[_nITEM][_nPOSCOMP])
				RecLock("SG1",.F.)

                FOR _nCPO := 1 to len(_aHeaderCom)
                    if ALLTRIM(_aHeaderCom[_nCPO][2]) == "G1_XEMBREC"
                        &("SG1->"+ALLTRIM(_aHeaderCom[_nCPO][2])) := _oGetComp:aCOLS[_nITEM][_nCPO]
                    endif
                NEXT

			    SG1->(MsUnlock())
            endif

            dbSelectArea("TRB")
            TRB->(dbSetOrder(3))
            if dbSeek(_cCodPai+_oGetComp:aCOLS[_nITEM][_nPOSCOMP])
				RecLock("TRB",.F.)
                TRB->TRB_EMBREC := _oGetComp:aCOLS[_nITEM][_nPOSEMBA]
    			TRB->(MsUnlock())
            endif
        endif
	NEXT

    RestArea(_aArea)

    oMarkBrow:Refresh()

Return

/*/{Protheus.doc} DefinirMenu
//TODO Metodo para definir a rotina que sera executada na selecao dos botoes.
@author Fernando Bombardi (ALLSS)
@since 02/06/2022
@version P12.1.33
@type method
/*/
method DefinirMenu(_nOPCBT,_nORIGEM,_CCODPAI) class RPCPC001
Private _lRETFEC := .T.

	IF _nORIGEM <> 1

		DO CASE
			CASE _nOPCBT == 1
				IF _nORIGEM <> 1 
					IF MSGYESNO( "Deseja realmente salvar as informações?", "[RPCPC001_002] - Atenção" )

						::GravarDados(_CCODPAI) //Grava dados da cotacao

						oDlgComp:End()

						MsgInfo("Dados foram alterados com sucesso!","[RPCPC001_003] - Aviso")

					ENDIF
				ELSE

					IF MSGYESNO( "Deseja realmente SAIR?", "[TLFATC01_M03] - Atenção" )

						oDlgComp:End()

					ENDIF

				ENDIF

			CASE _nOPCBT == 2
				IF MSGYESNO( "Deseja realmente SAIR?", "[TLFATC01_M03] - Atenção" )

					oDlgComp:End()

				ENDIF
		END CASE

	ELSE

		IF MSGYESNO( "Deseja realmente SAIR?", "[TLFATC01_M03] - Atenção" )
			oDlgComp:End()
		ENDIF

	ENDIF

Return
