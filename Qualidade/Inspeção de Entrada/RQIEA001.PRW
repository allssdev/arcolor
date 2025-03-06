#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"

/*/{Protheus.doc} 
@description Etiqueta Inspeção após aprovação na qualidade
@author		Livia Della Corte email: livia.dcorte@allss.com.br
@since 		18/06/2023
@version 	1.01
@see 		https://allss.com.br
/*/
user function RQIEA001(nOpc) 

Local cCadastro	:= OemtoAnsi("Etiqueta de Resultados Qualidade")
Local aMensagem	:={}
Local aBotoes   :={}

Private _cRotina := "RQIEA001"
Private _cPerg    := "RQIEA001"
Private cProduto  := ""	
Private cRevpr := ""
Private cForn  := ""
Private cLjFor := ""
Private cDtent := ""
Private cLote  := ""	
Private cNtfis := ""
Private cSerNF := ""	
Private cItNF  := ""
Private cTpNF  := ""	
Private cOpc   := ""	
Private lUsQA  := .F. 
private cUsQA := supergetmv("MV_XUSETQA",,"000000")
Private cUserId		:= RetCodUsr()

default nOpc := 2

if cUserId$cUsQA
	lUsQA:= .t.
endIf
U_ValidPerg()
If !Funname() $ "Q215FIM" .and. nOpc==1 
	cFornece := MV_PAR01 := QEK->QEK_FORNEC
	cLoja    := MV_PAR02 := QEK->QEK_LOJFOR
	cNtfis   := MV_PAR03 := QEK->QEK_NTFISC
	cSerNF   := MV_PAR04 := QEK->QEK_SERINF
	cProduto := QEK->QEK_PRODUT
	cLote 	 := QEK->QEK_LOTE
else
	cFornece := QEK->QEK_FORNEC
	cLoja    := QEK->QEK_LOJFOR
	cNtfis   := QEK->QEK_NTFISC
	cSerNF   := QEK->QEK_SERINF
	cProduto := QEK->QEK_PRODUT
	cLote 	 := QEK->QEK_LOTE
EndIf

If !Funname() $ "Q215FIM" .and. nOpc==1 
	AADD(aMensagem,OemToAnsi("Etiqueta da Qualidade, para resultado selecionado no Browse") ) 
	AADD(aMensagem,OemToAnsi("Nota: "+ alltrim(QEK->QEK_NTFISC) + " Série: " + alltrim(QEK->QEK_SERINF)+"." ))
	AADD(aMensagem,OemToAnsi("Produto: "+ alltrim(QEK->QEK_PRODUT) + " Lote: " + alltrim(QEK->QEK_LOTE)+"." ))
	AADD(aMensagem,OemToAnsi(" "))
	AADD(aMensagem,OemToAnsi(" "))
	AADD(aMensagem,OemToAnsi("Acesse o botao de parametros, caso queira alterar."))
	AADD(aBotoes, { 6,.T.,{|o| FechaBatch()}})
	//AADD(aBotoes, { 6,.T.,{|o|  U_PesqENt(cNtfis,cSerNF, cFornece,cLoja),FechaBatch()}})
	AADD(aBotoes, { 5,.T.,{||  Pergunte(_cPerg,.T. ) }})
	AADD(aBotoes, { 2,.T.,{|o| FechaBatch() }} )
	FormBatch( cCadastro, aMensagem, aBotoes )
endIf

	  U_PesqENt(cNtfis,cSerNF, cFornece,cLoja,cProduto,cLote)
	//U_PesqENt(cNtfis,cSerNF, cFornece,cLoja)

Return

User Function PesqENt( cNota,cSerie, cFornece,cLoja,cProduto,cLote)
	//local _cPnum := "RQIAE1"
	local nY:= 1
	local nCopias := 1
	Local _nQtdEti := 0
	Local _cTpLibCQ := supergetmv("MV_XTPACQ",,"3/2/9/6")
	Private aArea     := GetArea()
	Private cAliasPro := GetNextAlias()
If empty(cProduto) .and. empty(cLote)  
	BEGINSQL ALIAS cAliasPro
		SELECT  QEL.QEL_DTLAUD	 AS DATA_APRO
				, MAX(QEL.QEL_HRLAUD) AS HORA_APRO
				//, QEL.QEL_QTDAPR as QTDAPR0
				, SD7.D7_QTDE	 AS QTDMOV
				//, QEL.QEL_DTVAL  as DTVLAPRO
				, SB8.B8_DTVALID AS DTVLAPRO
				, SB1.B1_UM		 as UNID
				, QEK.QEK_FORNEC as CODFOR
				, QEK.QEK_LOJFOR as LOJFOR
				, SA2.A2_NOME 	 AS NOME
				, SB1.B1_DESC 	 AS PRD_DESC
				, SB1.B1_COD	 AS PRD
				, QEK.QEK_LOTE   as LOTE
				, SB8.B8_LOTEFOR as LOTEFOR
				, QEK.QEK_PEDIDO AS PEDIDO
				, QEK.QEK_SITENT as STATUS
				, SD7.D7_TIPO AS LIBREJ
				, QEK.QEK_TAMLOT AS TAMLOT
		FROM    %table:QEK% QEK (NOLOCK)
			LEFT  JOIN %table:QEL% QEL (NOLOCK) on QEK.QEK_FILIAL = QEL.QEL_FILIAL AND QEK.QEK_LOTE = QEL.QEL_LOTE AND QEL.%NotDel% 
			INNER JOIN %table:SB1% SB1 (NOLOCK) on SB1.B1_COD = QEK.QEK_PRODUT 	AND SB1.%NotDel%	
			INNER JOIN %table:SA2% SA2 (NOLOCK) on SA2.A2_COD= QEK.QEK_FORNEC AND SA2.A2_LOJA= QEK.QEK_LOJFOR	AND SA2.%NotDel%
			INNER JOIN SD7010 SD7 (NOLOCK) on SD7.D7_PRODUTO = QEK.QEK_PRODUT AND QEK.QEK_FORNEC = SD7.D7_FORNECE AND SD7.D7_LOJA = QEK.QEK_LOJFOR
									AND QEK.QEK_NTFISC = SD7.D7_DOC AND QEK.QEK_SERINF = SD7.D7_SERIE AND SD7.D7_LOTECTL = QEK.QEK_LOTE
									AND SD7.D7_TIPO <> 0
			INNER JOIN SB8010 SB8 (NOLOCK) ON SB8.B8_PRODUTO = QEK.QEK_PRODUT AND SB8.B8_LOTECTL = QEK_LOTE AND SB8.B8_LOCAL = QEK_LOCORI
		WHERE	QEK.QEK_FILIAL = %xFilial:QEK%
				AND QEK.QEK_NTFISC   = %exp:cNota%
				AND QEK.QEK_SERINF   = %exp:cSerie%
				aND QEK.QEK_FORNEC   = %exp:cFornece%	
				AND QEK.QEK_LOJFOR 	 = %exp:cLoja%
				//AND QEK.QEK_PRODUT   = %exp:cProduto%
				//AND QEK.QEK_LOTE     = %exp:cLote%	
		GROUP BY QEL.QEL_DTLAUD	 , QEL.QEL_QTDAPR, QEL.QEL_DTVAL, SB1.B1_UM,QEK.QEK_FORNEC,QEK.QEK_LOJFOR, SA2.A2_NOME
		, SB1.B1_DESC, SB1.B1_COD, QEK.QEK_LOTE, QEK.QEK_PEDIDO, QEK.QEK_SITENT, SD7.D7_QTDE, SD7.D7_TIPO, QEK.QEK_TAMLOT,B8_DTVALID,B8_LOTEFOR
		//removido do group by: QEL.QEL_QTDAPR,

	ENDSQL
else
		BEGINSQL ALIAS cAliasPro
		SELECT  QEL.QEL_DTLAUD	 AS DATA_APRO
				, MAX(QEL.QEL_HRLAUD) AS HORA_APRO
				//, QEL.QEL_QTDAPR as QTDAPR0
				, SD7.D7_QTDE	 AS QTDMOV
				//, QEL.QEL_DTVAL  as DTVLAPRO
				, SB8.B8_DTVALID AS DTVLAPRO
				, SB1.B1_UM		 as UNID
				, QEK.QEK_FORNEC as CODFOR
				, QEK.QEK_LOJFOR as LOJFOR
				, SA2.A2_NOME 	 AS NOME
				, SB1.B1_DESC 	 AS PRD_DESC
				, SB1.B1_COD	 AS PRD
				, QEK.QEK_LOTE   as LOTE
				, SB8.B8_LOTEFOR as LOTEFOR
				, QEK.QEK_PEDIDO AS PEDIDO
				, QEK.QEK_SITENT as STATUS
				, SD7.D7_TIPO AS LIBREJ
				, QEK.QEK_TAMLOT AS TAMLOT
		FROM    %table:QEK% QEK (NOLOCK)
			LEFT  JOIN %table:QEL% QEL (NOLOCK) on QEK.QEK_FILIAL   = QEL.QEL_FILIAL AND QEK.QEK_LOTE = QEL.QEL_LOTE AND QEL.%NotDel% 
											  AND QEK.QEK_NTFISC+QEK_SERINF = SUBSTRING(QEL_NISERI,1,12)
			INNER JOIN %table:SB1% SB1 (NOLOCK) on SB1.B1_COD = QEK.QEK_PRODUT 	AND SB1.%NotDel%	
			INNER JOIN %table:SA2% SA2 (NOLOCK) on SA2.A2_COD= QEK.QEK_FORNEC AND SA2.A2_LOJA= QEK.QEK_LOJFOR	AND SA2.%NotDel%
			INNER JOIN %table:SD7% SD7 (NOLOCK) on SD7.D7_PRODUTO = QEK.QEK_PRODUT AND QEK.QEK_FORNEC = SD7.D7_FORNECE AND SD7.D7_LOJA = QEK.QEK_LOJFOR
											  AND QEK.QEK_NTFISC = SD7.D7_DOC AND QEK.QEK_SERINF = SD7.D7_SERIE AND SD7.D7_LOTECTL = QEK.QEK_LOTE
											  AND SD7.D7_TIPO <> 0
			INNER JOIN %table:SB8% SB8 (NOLOCK) ON SB8.B8_PRODUTO = QEK.QEK_PRODUT AND SB8.B8_LOTECTL = QEK_LOTE AND SB8.B8_LOCAL = QEK_LOCORI
		WHERE	QEK.QEK_FILIAL = %xFilial:QEK%
				AND QEK.QEK_NTFISC   = %exp:cNota%
				AND QEK.QEK_SERINF   = %exp:cSerie%
				aND QEK.QEK_FORNEC   = %exp:cFornece%	
				AND QEK.QEK_LOJFOR 	 = %exp:cLoja%
				AND QEK.QEK_PRODUT   = %exp:cProduto%
				AND QEK.QEK_LOTE     = %exp:cLote%	
		GROUP BY QEL.QEL_DTLAUD,  QEL.QEL_DTVAL, SB1.B1_UM,QEK.QEK_FORNEC,QEK.QEK_LOJFOR, SA2.A2_NOME
		, SB1.B1_DESC, SB1.B1_COD, QEK.QEK_LOTE, QEK.QEK_PEDIDO, QEK.QEK_SITENT, SD7.D7_QTDE, SD7.D7_TIPO, QEK.QEK_TAMLOT,B8_DTVALID,B8_LOTEFOR
		//removido do group by: QEL.QEL_QTDAPR,
	ENDSQL
EndIf	



	While !(cAliasPro)->(EOF())
	//1-Laud pend;2=Laudo Aprov;3=Laudo Reprov;4=Liber Urgen;5=Laudo Cond;6=Permissao de Uso;7=Laudo Med Pend;8=Laudo Lab Pend;    
		If  (cAliasPro)->STATUS$_cTpLibCQ .or. ((cAliasPro)->STATUS=="5" .and. lUsQA)
			dDtApro    := IIF(EMPTy((cAliasPro)->DATA_APRO),DTOS(DDATABASE), (cAliasPro)->DATA_APRO)
			cHrAPro    :=  IIF(EMPTy( (cAliasPro)->HORA_APRO),TIME(), (cAliasPro)->HORA_APRO)
			//cQtdApro   :=  IIF(EMPTy(cvaltochar((cAliasPro)->QTDAPR0)), "100",(cAliasPro)->QTDAPR0) 
			cQtdApro   :=  IIF(EMPTY(cvaltochar((cAliasPro)->QTDMOV)), "100",(cAliasPro)->QTDMOV) 
			cDtVAlid   := substr((cAliasPro)->DTVLAPRO,5,2)+"/"+substr((cAliasPro)->DTVLAPRO,1,4)
			cUnidMed   := (cAliasPro)->UNID
			cNome      := (cAliasPro)->NOME
			cPrdDesc   := (cAliasPro)->PRD_DESC
			cProduto   := (cAliasPro)->PRD
			cLote      := (cAliasPro)->LOTE
			cLotFor    := (cAliasPro)->LOTEFOR
			cPedido    := (cAliasPro)->PEDIDO
			cCodFor	   := (cAliasPro)->CODFOR
			cLojFor	   := (cAliasPro)->LOJFOR

			If (cAliasPro)->STATUS = '1'  
				cStatus	   := "PENDENTE"
			ElseIf (cAliasPro)->STATUS = '2'
				cStatus	   := "APROVADO"
			ElseIf (cAliasPro)->STATUS = '3'
				cStatus	   := "REPROVADO"
			ElseIf (cAliasPro)->STATUS = '4'
				cStatus	   := "LIB. URGENTE"
			ElseIf (cAliasPro)->STATUS = '5'
				cStatus	   := "APROV. COND"
			ElseIf (cAliasPro)->STATUS = '6'	
				cStatus	   := "APROVADO"
			ElseIf (cAliasPro)->STATUS = '7'
				cStatus	   := "MED PEND"
			ElseIf (cAliasPro)->STATUS = '8'
				cStatus	   := "LAB PEND"
			ElseIf (cAliasPro)->STATUS = '9'
				cStatus	   := "APROVADO"
			else 
				cStatus	   := "PENDENTE"
			end
			//nCopias := pergunte(_cPerg,.T.)
	
			nCopias := QtdImp()
			
			_nQtdEti := QtdEti()
			If _nQtdEti > 0
				cQtdApro := _nQtdEti
			EndIf
			for nY:=1 to nCopias	
				U_ImpEtQA(cProduto,cPrdDesc,cLote,cLotFor,cNota,cSerie, cFornece,cLoja,cNome,dDtApro,cHrAPro,cQtdApro,cUnidMed,cPedido,cDtVAlid,cStatus) 
			next nY
		Endif
   	(cAliasPro)->(DBSKIP())
	EndDo

restarea(aArea)

Return()


User Function ImpEtQA(cProduto,cPrdDesc,cLote,cLotFor,cNota,cSerie, cFornece,cLoja,cNome,dDtApro,cHrAPro,cQtdApro,cUnidMed,cPedido,cDtVAlid,cStatus)

	Private _cPorta   := "LPT1:"
	
/*Fornecedor/NOme
Nfiscal/Serie
Pedido
Cod Prod
Descricao Produto
Qtd e Unidade
data e hora da Aprovação
Lote
validade*/

	//cQuant := Alltrim(Transform(nVolume,"@E 999,9999,999"))

	MSCBPRINTER("ZEBRA",_cPorta,,210) //Seta tipo de impressora no padrao ZPL

	MSCBCHKStatus(.F.)
	MSCBBEGIN(1,4)
	MSCBSAY(010,005,"FORNECEDOR","N","C","25,0",.T.) 
	MSCBSAY(045,005,"LOTE FOR:","N","C","25,0",.T.) 
	MSCBSAY(060,005,Alltrim(cLotFor),"N","C","25,0",.T.)
	MSCBSAY(010,008,Alltrim(cFornece)+'-'+Alltrim(cLoja)+'-'+Alltrim(cNome),"N","C","25,0",.T.) 
    MSCBLineH(005,012,90)
	MSCBSAY(010,016,'CODPROD', "N","C","25,0")
	MSCBSAY(010,021,Alltrim(cProduto),"N","C","35,0",.T.)
    //MSCBLineH(058,02,200)
	MSCBSAY(045,016,'N.FISCAL ', "N","C","25,0")
	MSCBSAY(060,016,+ Alltrim(cNota)+'/'+ Alltrim(cSerie), "N","C","25,0")
    //MSCBLineH(027,102,200)
	MSCBSAY(045,021,'PEDIDO', "N","C","25,0")
	MSCBSAY(065,021,Alltrim(cPedido) , "N","C","25,0")
    //MSCBLineH(037,102,200)
	MSCBSAY(010,028,cPrdDesc, "N","C","35,0")
    MSCBLineH(010,040,100)
	MSCBSAY(020,038,'QTD', "N","C","25,0")
    MSCBSAY(065,038,'UND', "N","C","25,0")
    //MSCBLineH(010,044,100)
    //MSCBLineH(065,044,100)	
	MSCBSAY(020,042,Alltrim(Str(cQtdApro)), "N","C","35,0")
	MSCBSAY(065,042,cUnidMed, "N","C","35,0")

    MSCBSAY(035,046,'STATUS ATUAL', "N","C","35,0")
    MSCBSAY(010,051,cStatus, "N","C","70,0")

    MSCBSAY(010,062,'DATA APROVACAO', "N","C","25,0")
	MSCBSAY(010,067,Substr(dDtApro,7,2)+"/"+Substr(dDtApro,5,2)+"/"+Substr(dDtApro,1,4)+ ' '+Substr(cHrAPro,1,5),"N","C","30,0")
    //MSCBLineH(097,002,200)
    MSCBSAY(065,062,'VALIDADE', "N","C","25,0")
	MSCBSAY(060,067,cDtVAlid,"N","C","45,0")

    MSCBSAY(010,074,'LOTE', "N","C","25,0")
	MSCBSAY(010,078,cLote,"N","C","45,0")
	//MSCBSAY(005,078,'9999999999',"N","C","45,0")

	MSCBSAY(055,074,'Abertura em:', "N","C","25,0")
	MSCBSAY(065,079,'      /     /     ',"N","C","35,0")
	MSCBLineH(055,082,100)
	

	MSCBSAY(055,084,'Val. Abertura:', "N","C","25,0")
	MSCBSAY(065,089,'     /     /',"N","C","35,0")
	MSCBLineH(055,092,100)
	

	MSCBSAY(010,084,'Aberto por:', "N","C","25,0")
	MSCBLineH(010,092,60)
	
	MSCBEND()
	MSCBCLOSEPRINTER()		

Return

/*/{Protheus.doc} ValidPerg
@description Verifica as perguntas no dicionário SX1, as criando, caso não existam.
@author Diego Rodrigues Pereira (ALLSS Soluções em Sistemas)
@since 22/06/2021
@type function
@version 1.00
@see https://allss.com.br
/*/
user function ValidPerg()
	local _aArea     := GetArea()
	local _aTam      := {}
	local _aRegs     := {}
	local i          := 0
	local j          := 0
	local _cQrySX1 := "SX1"

	OpenSxs(,,,,FWCodEmp(),_cQrySX1,"SX1",,.F.)
	dbSelectArea(_cQrySX1)
	(_cQrySX1)->(dbSetOrder(1))
		
		_cPerg := PADR(_cPerg,len((_cQrySX1)->X1_GRUPO))
		_aTam  := TamSX3("A2_COD")
		AADD(_aRegs,{_cPerg,"01","Fornecedor"        ,"","","mv_ch1",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SA2","",""})
		_aTam  := TamSX3("A2_LOJA")
		AADD(_aRegs,{_cPerg,"02","Loja?"        ,"","","mv_ch2",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
		_aTam  := TamSX3("F1_DOC")
		AADD(_aRegs,{_cPerg,"03","Nota Fiscal?"        ,"","","mv_ch3",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
		_aTam  := TamSX3("F1_SERIE")
		AADD(_aRegs,{_cPerg,"04","Serie?"        ,"","","mv_ch4",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
	for i := 1 to len(_aRegs)
		if !(_cQrySX1)->(dbSeek(_cPerg+_aRegs[i,2]))
			while !RecLock(_cQrySX1,.T.) ; enddo
				for j := 1 to FCount()
					if j <= Len(_aRegs[i])
						FieldPut(j,_aRegs[i,j])
					else
						Exit
					endif
				next
			(_cQrySX1)->(MsUnLock())
		endif
	next
	RestArea(_aArea)
return


static function QtdImp()

Local oGetv1
Local oGroupv1
Local oSayv1
Local oSButtonv1
Local oSButtonv2

Private _nGetImp  := 0.000

static oDlgv

  DEFINE MSDIALOG oDlgv TITLE "Informe o numero de Etiquetas"          FROM 000, 000 TO 130, 240                                             COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME

    @ 007, 003 GROUP oGroupv1 TO 058, 116 PROMPT " Informe o numero de Etiquetas " OF oDlgv   COLOR  0, 16777215 PIXEL
    @ 021, 005   SAY   oSayv1 PROMPT "Quantidade:"   SIZE 037, 007 OF oDlgv                            COLORS 0, 16777215 PIXEL
    @ 019, 045 MSGET   oGetv1    VAR _nGetImp     SIZE 070, 010 OF oDlgv PICTURE "999" VALID NAOVAZIO()  COLORS 0, 16777215 PIXEL
	 
	DEFINE SBUTTON oSButtonv1 FROM 039, 048 TYPE 1 ACTION (oDlgv:End())  ENABLE OF oDlgv
	DEFINE SBUTTON oSButtonv2 FROM 039,074 TYPE 2 ACTION ( oDlgv:End()) ENABLE OF oDlgv

  ACTIVATE MSDIALOG oDlgv CENTERED
  
return(_nGetImp)

//Função para a quantidade impressa na etiqueta
static function QtdEti()

Local oGetv1
Local oGroupv1
Local oSayv1
Local oSButtonv1
Local oSButtonv2

Private _nGetEti  := 0.0000

static oDlgv

  DEFINE MSDIALOG oDlgv TITLE "Informe a Quantidade na Etiqueta"          FROM 000, 000 TO 130, 240                                             COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME

    @ 007, 003 GROUP oGroupv1 TO 058, 116 PROMPT " Informe a Quantidade do Produto " OF oDlgv   COLOR  0, 16777215 PIXEL
    @ 021, 005   SAY   oSayv1 PROMPT "Quantidade:"   SIZE 037, 007 OF oDlgv                            COLORS 0, 16777215 PIXEL
    @ 019, 045 MSGET   oGetv1    VAR _nGetEti     SIZE 070, 010 OF oDlgv PICTURE "@E 999,999,999.99999"  COLORS 0, 16777215 PIXEL
	 
	DEFINE SBUTTON oSButtonv1 FROM 039, 048 TYPE 1 ACTION (oDlgv:End())  ENABLE OF oDlgv
	DEFINE SBUTTON oSButtonv2 FROM 039,074 TYPE 2 ACTION ( oDlgv:End()) ENABLE OF oDlgv

  ACTIVATE MSDIALOG oDlgv CENTERED
  
return(_nGetEti)


/*
user Function AtuSx1Qie()
	Local _cPnum    := ""   
	_cPnum:="RQIAE1"

	If !SX1->(DbSeek(_cPnum))
		PutSx1( _cPnum, "01", "Numero de Copias ?", " ", " ", "mv_ch1" , "N", 4,0,0,"G","","",,,"mv_par01")
	EndIf

Return 
*/




