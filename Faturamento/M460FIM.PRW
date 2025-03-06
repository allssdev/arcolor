#include "totvs.ch"
/*/{Protheus.doc} M460FIM
    @description Este P.E. é chamado após a Gravação da NF de Saida, e fora da transação.
    @author Fernando Bombardi (ALLSS Soluções em Sistemas)
    @since 22/01/2020
    @version 1.0
    @type Function
    @see https://allss.com.br
	@history 16/05/2023, Diego Rodrigues (Allss System) - diego.rodrigues@allss.com.br, Adequação do fonte para utilizar sempre a ultima data do mês na geração da SRK
/*/
user function M460FIM()
	local   _aSvArea    :=  GetArea()
	local   _aSvSF2     :=  SF2->(GetArea())
	local   _aSvSD2     :=  SD2->(GetArea())
	local   _aSvSA1     :=  SA1->(GetArea())
	local   _aSvSA2     :=  SA2->(GetArea())
	local   _aSvSE1     :=  SE1->(GetArea())
	local   _aSvSRK     :=  SRK->(GetArea())
	local   _aSvSC5     :=  SC5->(GetArea())
	local   _aSvSC6     :=  SC6->(GetArea())
	local   _aSvSC9     :=  SC9->(GetArea())
	local   oM460FIM    :=  nil
	oM460FIM        := M460FIM():NEW()
	if !empty(SF2->F2_DUPL)	//Para somente registros que gerem o contas a receber, gero os valores futuros aos funcionários
		oM460FIM:GerarValoresFuturos()
	endif

	DbSelectArea("SD2")
	DbSetOrder(3)
	If DbSeek(xFilial("SD2") + SF2->F2_DOC+SF2->F2_SERIE)
		if !empty(SD2->D2_LOTECTL)
			oM460FIM:GravaFabricao()
		EndiF
	EndIf
	if !SF2->F2_TIPO$"B/D" //Apenas notas de devolução devem ter mais de 2 casas decimais no d2_prcven - *regra arcolor*
		oM460FIM:GravaArred()
	endif


	oM460FIM            := nil
	RestArea(_aSvSF2)
	RestArea(_aSvSD2)
	RestArea(_aSvSA1)
	RestArea(_aSvSA2)
	RestArea(_aSvSE1)
	RestArea(_aSvSRK)
	RestArea(_aSvSC5)
	RestArea(_aSvSC6)
	RestArea(_aSvSC9)
	RestArea(_aSvArea)
return
/*/{Protheus.doc} M460FIM
    @description Classe para manipulacao de dados apos faturamento
    @author Fernando Bombardi (ALLSS Soluções em Sistemas)
    @since 22/01/2020
    @version 1.0
    @type Class
    @see https://allss.com.br
/*/
class M460FIM	
    data _cRotina    as string
	data _nSeq       as numeric
	data _nStart     as numeric

    Method New() CONSTRUCTOR
    Method GerarValoresFuturos()
	Method GravaFabricao()
	Method GravaArred()	
endclass
/*/{Protheus.doc} New
    @description Metodo construtor 
    @author Fernando Bombardi (ALLSS Soluções em Sistemas)
    @since 22/01/2020
    @version 1.0
    @type Method
    @see https://allss.com.br
/*/
Method New() class M460FIM
	::_cRotina   := "M460FIM"
	::_nSeq      := 1
	::_nStart    := Seconds()
return
/*/{Protheus.doc} IncluirValoresFuturos
    Metodo para geracao dos Valores Futuros para venda a funcionarios
    @author Fernando Bombardi (ALLSS Soluções em Sistemas)
    @since 22/01/2020
    @version 1.0
    @type Method
    @see https://allss.com.br
/*/
Method GerarValoresFuturos() class M460FIM
	local   _aCab       := {}
	local   _aItens     := {}
//	local   _aLog       := {}
	local   _aLinha     := {}
	local   _cError     := ""
	local   _cFUNC      := GetNextAlias()
	local   _cFINA      := GetNextAlias()
	local   _cVERBA     := PadR(SuperGetMV("MV_XVERBAVF",,"505"      ),TamSx3("RV_COD"    )[1])
	local   _nParcela   := 0

	private lMsErroAuto := .F.

	if Select(_cFUNC) > 0
		(_cFUNC)->(dbCloseArea())
	endif
	BeginSql Alias _cFUNC
		%noparser%
		SELECT TOP 1 RA_MAT
		FROM %table:SRA% SRA (NOLOCK)
		WHERE RA_FILIAL  = %xFilial:SRA% 
		  AND RA_CLIENTE = %exp:SF2->F2_CLIENTE%
		  AND RA_LOJACLI = %exp:SF2->F2_LOJA%
		  AND RA_MSBLQL  = %exp:'2'%
		  AND (CASE WHEN RA_SITFOLH  = %exp:'D'% THEN 0 ELSE 1 END) = 1
		  AND SRA.%notDel%
	EndSql
	dbSelectArea(_cFUNC)
	if !(_cFUNC)->(EOF())
		Aadd(_aCab, {"RA_MAT"   , (_cFUNC)->RA_MAT, NIL })
		Aadd(_aCab, {"RA_FILIAL", FwFilial("SRA") , NIL })
		BeginSql Alias _cFINA
			%noparser%
			SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA, E1_VALOR, E1_VENCTO
			FROM %table:SE1% SE1 (NOLOCK)
			WHERE E1_FILIAL  = %xFilial:SE1% 
			  AND E1_TIPO    = %exp:'NF'%
			  AND E1_CLIENTE = %exp:SF2->F2_CLIENTE%
			  AND E1_LOJA    = %exp:SF2->F2_LOJA%
			  AND E1_PREFIXO = %exp:SF2->F2_PREFIXO%
			  AND E1_NUM     = %exp:SF2->F2_DUPL%
			  AND SE1.%notDel%
		EndSql
		dbSelectArea(_cFINA)
		if !(_cFINA)->(EOF())
			while !(_cFINA)->(EOF())
				_aLinha := {}
				_nParcela++
				Aadd(_aLinha,{ "RK_FILIAL" , FwFilial("SRK")                , NIL})
				Aadd(_aLinha,{ "RK_PD"     , _cVERBA                        , NIL})
				Aadd(_aLinha,{ "RK_VALORTO", (_cFINA)->E1_VALOR             , NIL})
				Aadd(_aLinha,{ "RK_PARCELA", _nParcela                      , NIL})
				//Aadd(_aLinha,{ "RK_DTVENC" , STOD((_cFINA)->E1_VENCTO)      , NIL})
				//Aadd(_aLinha,{ "RK_PERINI" , SUBSTR((_cFINA)->E1_VENCTO,1,6), NIL})
				Aadd(_aLinha,{ "RK_DTVENC" , LastDate(ddatabase)      , NIL})
				Aadd(_aLinha,{ "RK_PERINI" , Substr(Dtos(LastDate(ddatabase)),1,6), NIL})
				Aadd(_aLinha,{ "RK_DOCUMEN", SUBSTR((_cFINA)->E1_NUM,4,9)	, NIL})
				Aadd(_aLinha,{ "RK_XDOC"   , (_cFINA)->E1_NUM               , NIL})
				Aadd(_aLinha,{ "RK_XSERIE" , (_cFINA)->E1_PREFIXO           , NIL})
				Aadd(_aLinha,{ "RK_XPARC"  , (_cFINA)->E1_PARCELA           , NIL})
				Aadd(_aItens,_aLinha)
				(_cFINA)->(dbSkip())
			enddo
		endif
		if Select(_cFINA) > 0
			(_cFINA)->(dbCloseArea())
		endif
		
				
		MSExecAuto({|a, b, c| GPEA110(a, b, c) }, 3, _aCab, _aItens)
			
		
		if !lMsErroAuto
			FwLogMsg(	"INFO",;
						nil,;					//cTransactionId
						::_cRotina,;
						::_cRotina+"_LOG",;
						::_cRotina+"_LOG_"+StrZero(::_nSeq),;
						StrZero(::_nSeq),;
						("### Valor Futuro incluído com sucesso. Documento: " + SF2->F2_SERIE + " - " + SF2->F2_DOC),;
						0,;
						(Seconds()-::_nStart),;
						{} ) ; ::_nSeq++
		else
		//	_aLog := getAutoGrLog()
			_cError := ""
			if !IsBlind()
				MostraErro()
			else
				_cError := MostraErro("/system", "error_acd.log")
			endif
			FwLogMsg(	"ERROR",;
						nil,;					//cTransactionId
						::_cRotina,;
						::_cRotina+"_LOG",;
						::_cRotina+"_LOG_"+StrZero(::_nSeq),;
						StrZero(::_nSeq),;
						("### Erro na inclusão do Valor Futuro. Documento: " + SF2->F2_SERIE + " - " + SF2->F2_DOC + ". --> "+_cError),;
						0,;
						(Seconds()-::_nStart),;
						{} ) ; ::_nSeq++
		endif
	endif
	if Select(_cFUNC) > 0
		(_cFUNC)->(dbCloseArea())
	endif
return

/*/{Protheus.doc} GravaLote
    Metodo para gravação do lote na tabela SD2
    @author Diego Rodrigues (ALLSS Soluções em Sistemas)
    @since 07/04/2023
    @version 1.0
    @type Method
    @see https://allss.com.br
/*/
Method GravaFabricao() class M460FIM
	Local cNunNf  	:= SF2->F2_DOC
	Local cSerNf  	:= SF2->F2_SERIE
	Local cClien  	:= SF2->F2_CLIENTE
	Local cLoja   	:= SF2->F2_LOJA
	Local cQry 		:= ""
		

		cQry := " UPDATE "+RetSQLName("SD2")
		cQry += " SET D2_DFABRIC = B8_DFABRIC , D2_PRCVEN= round(D2_PRCVEN,2)"
		cQry += " FROM SD2010 D2"
		cQry += " INNER JOIN F0A010 F0 ON F0.D_E_L_E_T_ = '' "
		cQry += " AND F0A_DOC = D2_DOC AND F0A_SERIE = D2_SERIE AND F0A_COD = D2_COD AND F0A_ITEM = D2_ITEM"
		cQry += " INNER JOIN SB8010 B8 ON B8.D_E_L_E_T_ = '' AND B8_PRODUTO = D2_COD AND B8_LOTECTL = D2_LOTECTL"
		cQry += " WHERE D2.D_E_L_E_T_ = ''"
		cQry += " AND D2_FILIAL = '"+xFilial("SD2")+"'"
		cQry += " AND D2_DOC = '"+cNunNf+"'"
		cQry += " AND D2_SERIE = '"+cSerNf+"'"
		cQry += " AND D2_LOJA = '"+cLoja+"'"
		cQry += " AND D2_CLIENTE = '"+cClien+"'"
		cQry += " AND D2_LOTECTL <> ''"
		cQry += " AND D2_DFABRIC = '';"
		
		cQry += " UPDATE "+RetSQLName("F0A")
		cQry += " SET F0A_FABRIC = B8_DFABRIC"
		cQry += " FROM F0A010 F0"
		cQry += " INNER JOIN SD2010 D2 ON D2.D_E_L_E_T_ = '' "
		cQry += " AND F0A_DOC = D2_DOC AND F0A_SERIE = D2_SERIE AND F0A_COD = D2_COD AND F0A_ITEM = D2_ITEM AND F0A_FABRIC = ''"
		cQry += " INNER JOIN SB8010 B8 ON B8.D_E_L_E_T_ = '' AND B8_PRODUTO = D2_COD AND B8_LOTECTL = D2_LOTECTL"
		cQry += " WHERE D2.D_E_L_E_T_ = ''"
		cQry += " AND D2_FILIAL = '"+xFilial("SD2")+"'"
		cQry += " AND D2_DOC = '"+cNunNf+"'"
		cQry += " AND D2_SERIE = '"+cSerNf+"'"
		cQry += " AND D2_LOJA = '"+cLoja+"'"
		cQry += " AND D2_CLIENTE = '"+cClien+"'"
		cQry += " AND D2_LOTECTL <> ''"
		
		
		TcSQLExec(cQry)

	
return

/*/{Protheus.doc} GravaLote
    Metodo para gravação do lote na tabela SD2
    @author Diego Rodrigues (ALLSS Soluções em Sistemas)
    @since 07/04/2023
    @version 1.0
    @type Method
    @see https://allss.com.br
/*/
Method GravaArred() class M460FIM
	Local cNunNf  	:= SF2->F2_DOC
	Local cSerNf  	:= SF2->F2_SERIE
	Local cClien  	:= SF2->F2_CLIENTE
	Local cLoja   	:= SF2->F2_LOJA
	Local cQry 		:= ""
		

		cQry := " UPDATE "+RetSQLName("SD2")
		cQry += " SET D2_PRCVEN= round(D2_PRCVEN,2)"
		cQry += " FROM SD2010 D2"
		cQry += " WHERE D2.D_E_L_E_T_ = ''"
		cQry += " AND D2_FILIAL = '"+xFilial("SD2")+"'"
		cQry += " AND D2_DOC = '"+cNunNf+"'"
		cQry += " AND D2_SERIE = '"+cSerNf+"'"
		cQry += " AND D2_LOJA = '"+cLoja+"'"
		cQry += " AND D2_CLIENTE = '"+cClien+"' ;"
		//cQry += " AND D2_LOTECTL <> ''"
		//cQry += " AND D2_DFABRIC = '';"

		
		TcSQLExec(cQry)

	
return
