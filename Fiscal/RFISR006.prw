#Include "PROTHEUS.CH" 
#Include "TOPCONN.CH"

/*/{Protheus.doc} RFISR006
@description Monitor NFE
@obs relatório com base nos livros fiscais e situação das notas fiscais eletrônicas.
@author Livia Della Corte (ALL System Solutions)
@since 05/11/2018
@version 1.0
@return lógico, .T. - Trava os registros  /  .F. - Desativa a trava dos registros
@type function
@see https://allss.com.br
/*/

User Function RFISR006()

Local oButton1,oButton2,oFil1,oFil2,oCombo,oDt1,oDt2,oArqNome
Local oFont1 := TFont():New("ARIAL",,016,,.T.,,,,,.F.,.F.)
Local oSay1,oSay2,oSay3,oSay4,oSay5

Private nCombo //:= 6
Private _cFil1 := "01"
Private _cFil2 := "01"
Private dDt1 := Date() - 100
Private dDt2 := Date()   
Private cArqNome  := "MonitorNfe"
Private aItens    := {"1 - Inutilização Não Transmitida","2 - Cancelamento Não Transmitido","3 - Rejeição","4 - Danfe Não Impressa", "5 - Cancelamento Homologado","6 - Inutilização Homologada","7 - Todos"}
//                     1        						  2            						  3 			4         	              5


Static oDlg

DEFINE MSDIALOG oDlg TITLE "Monitor - Nota Fiscal Eletrônica" FROM 000, 000  TO 220, 680 COLORS 1, 16777215 PIXEL

@ 012, 016 SAY  oSay1 PROMPT "Data de:"     SIZE 035, 009 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
@ 012, 180 SAY  oSay2 PROMPT "Data até:"    SIZE 035, 009 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
@ 033, 016 SAY  oSay3 PROMPT "Filial de:"  SIZE 040, 011 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
@ 033, 179 SAY  oSay4 PROMPT "Filial até:" SIZE 044, 009 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
@ 055, 016 SAY  oSay5 PROMPT "Situação NFe:"      SIZE 066, 009 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
//@ 077, 016 SAY  oSay5 PROMPT "Nome do Arquivo:"      SIZE 066, 009 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL

@ 012, 084 MSGET oDt1  VAR dDt1  SIZE 083, 012 OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL
@ 012, 245 MSGET oDt2  VAR dDt2  SIZE 084, 012 OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL
@ 032, 084 MSGET oFil1 VAR _cFil1 SIZE 083, 012 OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL
@ 034, 245 MSGET oFil2 VAR _cFil2 SIZE 083, 012 OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL
//@ 074, 084 MSGET oArqNome VAR cArqNome SIZE 083, 012 OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL
@ 055, 084 MSCOMBOBOX oCombo VAR nCombo ITEMS aItens SIZE 200, 012 OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

@ 080, 285 BUTTON oButton1 PROMPT "Processar" SIZE 044, 012 OF oDlg FONT oFont1 ACTION (oDlg:End(),Processa({||U_FISR06A()})) PIXEL
@ 080, 195 BUTTON oButton2 PROMPT "Cancelar"  SIZE 046, 012 OF oDlg FONT oFont1 ACTION oDlg:End() PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

Return

User Function FISR06A()


Local cSheet := "Monitor - Nota Fiscal Eletrônica"
Local cTable := "NFe"
Local cOpc   := SubStr(nCombo,1,1)
Local _cFil3  := ""
Local cEmissao  :=""
Local nNumero := 1 
Local nNumOld := 1
Local cSerie    :=""
Local cSeFAz    :=""
Local cCodSefaz := ""
Local cForne	:=""
Local oFont2 := TFont():New("ARIAL",,016,,.T.,,,,,.F.,.F.)	
Local aItens1 := {}    
Local lImprime := .T.		 
Local cObs := ""
Local cHora := ""
Local cFuncao := ""


Private oExcel := FWMSEXCEL():New()

oExcel:AddworkSheet(cSheet)
oExcel:AddTable (cSheet,cTable)
oExcel:AddColumn(cSheet,cTable,"Filial"    ,1,1)
oExcel:AddColumn(cSheet,cTable,"Emissão"  ,1,1)
oExcel:AddColumn(cSheet,cTable,"Número"      ,1,1)
oExcel:AddColumn(cSheet,cTable,"Série"    ,1,1)
oExcel:AddColumn(cSheet,cTable,"Código Sefaz",1,1)
oExcel:AddColumn(cSheet,cTable,"Descrição Sefaz",1,1)
oExcel:AddColumn(cSheet,cTable,"Observação",1,1)
oExcel:AddColumn(cSheet,cTable,"Hora",1,1)
oExcel:AddColumn(cSheet,cTable,"Função",1,1)


aLinha:={}

if cOpc <> "1"

cAliasTop := GetNextAlias()

  cQuery:= " 	SELECT  DISTINCT F3_FILIAL FILIAL" 																				+ CHR(13) + CHR(10)
  cQuery+= " 		, SUBSTRING(F3_EMISSAO,7,2)+'/'+SUBSTRING(F3_EMISSAO,5,2)+'/'+SUBSTRING(F3_EMISSAO,1,4)   emissao "			+ CHR(13) + CHR(10)
  cQuery+= " 		, F3_NFISCAL numero   "          																			+ CHR(13) + CHR(10)                                                                                            
  cQuery+= " 		, F3_SERIE serie" 																							+ CHR(13) + CHR(10)
  cQuery+= " 		, F3_CODRSEF Codsefaz" 																						+ CHR(13) + CHR(10)
  cQuery+= " 		, X5_DESCRI  sefaz"																							+ CHR(13) + CHR(10)
  cQuery+= " 		, F3_DTCANC  " 																							    + CHR(13) + CHR(10)
  cQuery+= " 		, ZL_DATA, ZL_HORA HORA , ZL_FUNNAME FUNCAO 	"															+ CHR(13) + CHR(10)
  cQuery+= "  FROM  "     + RetSqlName("SF3") + " SF3 "   													+ CHR(13) + CHR(10)      
  cQuery+= "  LEFT JOIN " + RetSqlName("SX5")    +  " ON X5_TABELA = 'ZC' and X5_CHAVE = F3_CODRSEF "  	    + CHR(13) + CHR(10)
  cQuery+= "  LEFT JOIN " + RetSqlName("SZL")    + " ON LEFT(RIGHT( RTRIM(ZL_LOG),14),9)  = F3_NFISCAL"		+ CHR(13) + CHR(10)
  cQuery+= "  WHERE                                "														+ CHR(13) + CHR(10)
  cQuery+= "  	 F3_EMISSAO between '" + dtos(dDt1) + "' and  '" + dtos(dDt2) + "'"							+ CHR(13) + CHR(10)
  cQuery+= "  	and F3_ESPECIE = 'SPED'  and SUBSTRing(F3_CFO,1,1) > '4' "									+ CHR(13) + CHR(10)				
  cQuery+= "  	and SF3.D_E_L_E_T_ = ' ' and F3_CODRSEF <> ' ' "   											+ CHR(13) + CHR(10)

  If cOpc = "2"         //  cancelamento nao transmitido/Não autorizado
	cQuery+= " AND   ( F3_CODRSEF = '100' OR F3_CODRSEF = '501') and F3_DTCANC <> ' ' " + CHR(13) + CHR(10)
  EndIf
 
  If cOpc = "3"
	cQuery+= " AND F3_CODRSEF not in ( ' ', '100','101', '102', '501', '103')" + CHR(13) + CHR(10)  // Rejeições
  EndIf                         
 
  If cOpc = "4"
	cQuery+= " AND F3_CODRSEF = '103' "  + CHR(13) + CHR(10) // Sem monitoração.
  EndIf   
   
  If cOpc = "5"
	cQuery+= " AND F3_CODRSEF = '101' "  + CHR(13) + CHR(10) // Cancelamento
  EndIf 
 
  If cOpc = "6"
	cQuery+= " AND F3_CODRSEF = '102' "  + CHR(13) + CHR(10) // Inutilizações 
  EndIf 
                   
  cQuery+= " GROUP BY   F3_FILIAL  , SUBSTRING(F3_EMISSAO,7,2)+'/'+SUBSTRING(F3_EMISSAO,5,2)+'/'+SUBSTRING(F3_EMISSAO,1,4)  , F3_NFISCAL , F3_SERIE , F3_DTCANC, F3_CODRSEF, X5_DESCRI "  //, zcr_descr                                                         
  
  cQuery+= " , ZL_DATA, ZL_HORA, ZL_FUNNAME " + CHR(13) + CHR(10)
  
  cQuery+= " ORDER BY   F3_FILIAL  , SUBSTRING(F3_EMISSAO,7,2)+'/'+SUBSTRING(F3_EMISSAO,5,2)+'/'+SUBSTRING(F3_EMISSAO,1,4)  , F3_NFISCAL , F3_SERIE"      + CHR(13) + CHR(10)                                                                                               
                                                     
  
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
dbSelectArea(cAliasTop)                                                                              
Do While (cAliasTop)->(!Eof())

	_cFil3   := (cAliasTop)->FILIAL
	cEmissao := (cAliasTop)->EMISSAO
	nNumero  := (cAliasTop)->numero
	cSerie   := (cAliasTop)->serie
  	cCodSeFAz   := trim((cAliasTop)->codsefaz) 
  	cSeFAz  := trim((cAliasTop)->sefaz)
  	

  	If len(alltrim((cAliasTop)->f3_dtcanc)) > 0  
  		If "100"$trim((cAliasTop)->codsefaz) 
  		 	cObs 	 :=  "Cancelamento não transmitido. Nfe Cancelada em: " + SUBSTR((cAliasTop)->f3_dtcanc,7,2)+ "/" + SUBSTR((cAliasTop)->f3_dtcanc,5,2)+ "/" +SUBSTR((cAliasTop)->f3_dtcanc,1,4)                                     		 	
  		 else
  		 	cObs 	 :=  "Nfe Cancelada em: " + SUBSTR((cAliasTop)->f3_dtcanc,7,2)+ "/" + SUBSTR((cAliasTop)->f3_dtcanc,5,2)+ "/" +SUBSTR((cAliasTop)->f3_dtcanc,1,4)                                    
  		 EndIf 
  	Else
  	    cObs     := ""
  	EndIf
	
	cHora   := (cAliasTop)->HORA
  	cFuncao :=  (cAliasTop)->funcao	
	oExcel:AddRow(cSheet,cTable,{_cFil3,cEmissao  ,nNumero ,cSerie, cCodSEFAZ, cSEFAZ, cObs, cHora, cFuncao }) 

	aLinha:={}
	AAdd(aLinha, _cFil3) 	
	AAdd(aLinha, cEmissao) 	
	AAdd(aLinha, nNumero) 	
	AAdd(aLinha, cSerie)   
	AAdd(aLinha, cCodSEFAZ)	
	AAdd(aLinha, cSEFAZ)      
	AAdd(aLinha, cObs)   
	AAdd(aLinha, cHora)      
	AAdd(aLinha, cFuncao)   			                                   	

	(cAliasTop)->(dbSkip()) 
	aadd(aItens1,aLinha)
	cObs:= ""
	 		
EndDo   
(cAliasTop)->(DbCloseArea())                                                                 
EndIf


if cOpc == "1" .OR. cOpc == "7" 

	cAliasInut := GetNextAlias()
	  cQuery:= " 	select  DISTINCT FT_FILIAL filial" 								+ CHR(13) + CHR(10)
	  cQuery+= " 		, FT_EMISSAO   emissao " 									+ CHR(13) + CHR(10)
	  cQuery+= " 		, min (FT_NFISCAL) numMin "          						+ CHR(13) + CHR(10)                  
	  cQuery+= " 		, max (FT_NFISCAL) numMax  " 								+ CHR(13) + CHR(10)
	  cQuery+= " 		, FT_SERIE serie"  											+ CHR(13) + CHR(10)
	  cQuery+= "  from " + RetSqlName("SFT")   										+ CHR(13) + CHR(10)
	  cQuery+= "  where  "  														+ CHR(13) + CHR(10)                           
	  cQuery+= "  	FT_FILIAL between '" + _cFil1 + "' and  '" + _cFil2 + "'" 		        + CHR(13) + CHR(10)
	  cQuery+= "  	and FT_EMISSAO between '" + dtos(dDt1) + "' and  '" + dtos(dDt2) + "'"  + CHR(13) + CHR(10)
	  cQuery+= "  	and FT_ESPECIE = 'SPED'  and SUBSTRING(FT_CFOP,1,1) > '4' " 		    + CHR(13) + CHR(10)
	  cQuery+= "  	and D_E_L_E_T_ = ' ' "                                          + CHR(13) + CHR(10)
	  cQuery+= " group by  FT_FILIAL , FT_EMISSAO, FT_SERIE  "                      + CHR(13) + CHR(10)
	  cQuery+= " order by   FT_FILIAL , FT_EMISSAO,FT_SERIE  "                      + CHR(13) + CHR(10)                                                     
	  
	  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasInut,.T.,.T.)
	  dbSelectArea(cAliasInut) 	  	
	  
	Do While (cAliasInut)->(!Eof())  //Inutilização  	 		
		_cFil3    := (cAliasInut)->filial
		cEmissao  := (cAliasInut)->emissao
		nNumero   := val((cAliasInut)->numMin)  
		nNumOld   := val((cAliasInut)->numMax)
		cSerie    := (cAliasInut)->serie
		cCodSefaz := ""
		cHora := ""
		cFuncao:= ""
			
		While nNumOld - nNumero > 1
		 
				cNumero:= alltrim(str(nNumero))  
				cNUmero:= replicate("0", 9-len(cNumero)) + cNUmero  
				lImprime := U_FISR06C(_cFil3 ,cEmissao,cNumero ,cSerie)		
	
				IF lImprime 
					nNumero +=1		
				ELse
					
					cCodSEFAZ := ""
			 		cSeFAz := ""
			 		cObs  := "Inutilização Não Transmitida""
			 		
			 		//cEmissao := ""
			   		oExcel:AddRow(cSheet,cTable,{_cFil3, stod(cEmissao) ,cNumero ,cSerie, cCodSEFAZ, cSeFAz, cObs, cHora, cFuncao }) 
			   			aLinha:= {}
			   			AAdd(aLinha, _cFil3) 	
						AAdd(aLinha, stod(cEmissao)) 	
						AAdd(aLinha, cNumero) 	
						AAdd(aLinha, cSerie)   
						AAdd(aLinha, cCodSEFAZ) 						  
						AAdd(aLinha, cSEFAZ)    
						AAdd(aLinha, cObs )	        
						AAdd(aLinha, cHora)    
						AAdd(aLinha, cFuncao )	        
						                           
						aadd(aItens1,aLinha) 
						
						nNumero +=1		   		
				EndIf 	
				   		
		loop
		EndDo 
	
		(cAliasInut)->(dbSkip())
	loop	 	
	EndDo
  
EndIf



//ordenaall
//ASort(aItens1,2, , { | x,y | x > y } )
ASort(aItens1)
//Monta tela
u_FISR06D(aItens1)

 
    
                                                                   
Return(.t.)


User Function FISR06B()  
Local lret
Local lshow
Local nRet := ""
Local cHora01  := replace(time(),":","")

cArqNome := "MonitorNfe_" + dtos(date()) + cHora01     

lRet := ExistDir('C:\temp\')    
                           
if  !lRet   	
	nRet := MakeDir( "C:\temp" ) 
	lRet:= .T.	 
EndIf

If lRet
	oExcel:Activate()                                                     
	oExcel:GetXMLFile("C:\temp\"  + trim(cArqNome) + ".xls")   
	oExcelApp := MsExcel():New()  	
	lShow:= MsgYesNo( "Arquivo: " + cArqNome + ".xls gerado!" +CHR(13)+CHR(10) +"Deseja abrir o arquivo?", "Monitor Nfe" )
	If lShow
		oExcelApp:WorkBooks:Open( "C:\temp\" + trim(cArqNome) + ".xls" )
		oExcelApp:SetVisible(.T.)    
	 EndIf 
	 

EndIf
	 
Return

/*@ verifica salto de numeração da especie SPED*/

User Function FISR06C(_cFil3 ,cEmissao  ,cNumero ,cSerie)

Local cQuery 
Local cAlias
Private lReturn := .F.  

cAlias:= GetNextAlias()
  cQuery:= " 	select  count(*) count "             + CHR(13) + CHR(10)
  cQuery+= "  from " + RetSqlName("SFT")             + CHR(13) + CHR(10)
  cQuery+= "  where     "      					     + CHR(13) + CHR(10)                            "
  cQuery+= "  	FT_ESPECIE = 'SPED'  "               + CHR(13) + CHR(10)  // and SUBSTR(FT_cfop,1,1) > '4' "  desconsidero CFOP por notas de entrada com formulario proprio
  cQuery+= "  	and FT_FILIAL = '" + _cFil3 + "'"    + CHR(13) + CHR(10)
  cQuery+= "  	and FT_NFISCAL = '" + cNumero + "'"  + CHR(13) + CHR(10)
  cQuery+= "  	and FT_SERIE = '" + cSerie + "'"     + CHR(13) + CHR(10)
  cQuery+= "  	and FT_EMISSAO <= '" + dtos(dDt2) + "'"  + CHR(13) + CHR(10)
  cQuery+= "  	and D_E_L_E_T_ = ' ' "               + CHR(13) + CHR(10)     
  cQuery+= " group by  FT_FILIAL , FT_EMISSAO  "     + CHR(13) + CHR(10)                                                
 dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

dbSelectArea(cAlias)                                                                              
Do While (cAlias)->(!Eof())	  	
		if   (cAlias)->count >=1
			lReturn := .T.
		EndIf
		(cAlias)->(dbSkip())
	loop
EndDO  
(cAlias)->(DbCloseArea()) 	                   

Return (lReturn)



/*@ verifica salto de numeração da especie SPED*/

User Function FISR06D(aItens1)


If len(aItens1)>0                                              

	DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
	DEFINE MSDIALOG oDlgx FROM 000,000  TO 450,1000 TITLE OemToAnsi("Monitor - Nota Fiscal Eletrônica") Of oMainWnd PIXEL
		 
	_atit_cab1:= 	{"Filial","Emissão","Numero","Série","Código Sefaz", "Descrição", "Observação", "Hora", "Função"} 
	oListBox2 := TWBrowse():New( 32 ,002,500,190                              ,,_atit_cab1, ,oDlgx,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )  	
	oListBox2:AddColumn(TCColumn():New( "Filial"  		,{|| aItens1[ oListBox2:nAt, 01 ] },,,,'LEFT',,.F.,.F.,,,,.F.,))        //1
	oListBox2:AddColumn(TCColumn():New( "Emissão"  		,{|| aItens1[ oListBox2:nAt, 02 ] },,,,'RIGHT',,.F.,.F.,,,,.F.,)) 		//2
	oListBox2:AddColumn(TCColumn():New( "Numero" 		,{|| aItens1[ oListBox2:nAt, 03 ] },,,,'RIGHT',,.F.,.F.,,,,.F.,))   	//3
	oListBox2:AddColumn(TCColumn():New( "Série"  		,{|| aItens1[ oListBox2:nAt, 04 ] },,,,'RIGHT',,.F.,.F.,,,,.F.,)) 		//4
	oListBox2:AddColumn(TCColumn():New( "Código Sefaz"	,{|| aItens1[ oListBox2:nAt, 05 ] },,,,'LEFT',,.F.,.F.,,,,.F.,)) 		//5
	oListBox2:AddColumn(TCColumn():New( "Descrição"		,{|| aItens1[ oListBox2:nAt, 06 ] },,,,'LEFT',,.F.,.F.,,,,.F.,)) 		//7
	oListBox2:AddColumn(TCColumn():New( "Observação"	,{|| aItens1[ oListBox2:nAt, 07 ] },,,,'LEFT',,.F.,.F.,,,,.F.,)) 		//8
	oListBox2:AddColumn(TCColumn():New( "Hora"		,{|| aItens1[ oListBox2:nAt, 08 ] },,,,'LEFT',,.F.,.F.,,,,.F.,)) 		//9
	oListBox2:AddColumn(TCColumn():New( "Função"	,{|| aItens1[ oListBox2:nAt, 09 ] },,,,'LEFT',,.F.,.F.,,,,.F.,)) 		//10
    oListBox2:SetArray(aitens1)	

	@ 007,905 	BTNBMP oBtn2 RESOURCE "SDUFIND" 		SIZE 30,30 ACTION (oDlgx:End(),Processa({||oDlgx:End(),U_RFISR006()}))   		MESSAGE "Retorna Parametros"
	@ 007,940 	BTNBMP oBtn2 RESOURCE "Salvar" 			SIZE 30,30 ACTION U_FISR06B()     		MESSAGE "Salvar Excel"
	@ 007,973	BTNBMP oBtn6 RESOURCE "Final" 			SIZE 30,30 ACTION (oDlgx:End()) 	 	MESSAGE "Sair"
	    
	ACTIVATE MSDIALOG oDlgx CENTERED

  
	
Else
	MSGALERT( "Não há Dados!", "Monitor - Nota Fiscal Eletrônica" ) 
	//oDlgx:End()
	u_RFISR006()
EndIf
 
 
   
                                                                   
Return
