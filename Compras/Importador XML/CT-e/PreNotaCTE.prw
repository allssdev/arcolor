#INCLUDE "PROTHEUS.CH"
#include "RWMAKE.ch"
#include "Colors.ch"
#include "Font.ch"
#Include "HBUTTON.CH"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE 'parmtype.ch'
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH
#INCLUDE "SHELL.CH
#DEFINE _CRLF CHR(13) + CHR(10)

User Function PreNotaCTE(_cEmp,_cFilial,cArq)


Default _cFilial := "01"
Default _cEmp := "01"
private _cRotina:= "PRENOTACTE"
If Type("cFilAnt")=="U"
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" FUNNAME _cRotina
EndIf
private cDirINN := SuperGetMV("MV_NGINN",.F.,"\XML\NGINN\")+'CTE\'
private _cInArq2 := ""
private _aArqEnt :={}
private cDirLog	  := SuperGetMV("MV_NGLIDOS",.F.,"\XML\NGLIDOS\")+'CTE\log.txt'
private cDirLIDOS := SuperGetMV("MV_NGLIDOS",.F.,"\XML\NGLIDOS\")+'CTE\'
private nHandle  := "0"
private xFile:= ""
private aFiles
private aSizes
private cDirLog	  := SuperGetMV("MV_NGLIDOS",.F.,"\XML\NGLIDOS\")+'CTE\log.txt'
private _clog:= MemoRead( cDirLog )
private _nAte:= 0

nHandle  := MemoRead( cDirLog ) 
if nHandle < "0"
   nHandle:= FCREATE(cDirLog)
   FCLOSE(nHandle)     
else
  _clog:= MemoRead( nHandle )
  FCLOSE(nHandle) 
endif

_aArqEnt  := Directory(cDirINN+ "*.XML")
_nAte:= iif(len(_aArqEnt)<5, len(_aArqEnt)	, 5)	

If !empty(_aArqEnt) .And. EMPTY(cArq)
	for _nXi := 1 to  _nAte
	    _cInArq2:= cDirINN+LOWER(_aArqEnt[_nXi][01])
		if file(_cInArq2)
		  	_clog:= U_ImpXMLCte(_cInArq2)
		EndIf		
		_nXi++	
	Next 
Elseif !EMPTY(cArq)
  	_clog:= U_ImpXMLCte(cFile)
Else
  _clog:= _CRLF +"[INFO][DATA] " + cValtoChar(DATE()) + " [HORA] " +  cValtoChar(Time()) + " [ARQUIVO]  NULL  [AVISO] Diretório VAZIO: \XML\NGINN\ " + _clog     
EndIf
	MemoWrite(cDirLog,_clog) 
	FCLOSE(cDirLog)
	PutMV("MV_PCNFE",.T.)
Return()


User Function ImpXMLCte(cFile)

Private cCgc := ""
Private _nNum := "0"
Private _cProd:= SuperGetMV("MV_XPRDCTE",.F., "SE0020") //Criar Parametro
Private _cTes := SuperGetMV("MV_XTESCTE",.F.,"410" ) 	  //Criar Parametro
Private _cCdPg := SuperGetMV("MV_XPAGCTE",.F.,"524")    //Criar Parametro
Private _oDlg

Private aFields  := {}
Private aFields2 := {}
Private cArq
Private cArq2
Private	_cArqErro := ""
Private _cErroTemp:= ""

Private _cNfeori := ""
private cProduto:= ""
Private _cMarca  := GetMark()
private cNCM

nTipo := 1
cCodBar := Space(100)		
Private nHdl    := fOpen(cFile,0)	
aCamposPE:={}	
If nHdl == -1
	Return(_clog)
Endif	
nTamFile := fSeek(nHdl,0,2)
fSeek(nHdl,0,0)
cBuffer  := Space(nTamFile)                // Variavel para criacao da linha do registro para leitura
nBtLidos := fRead(nHdl,@cBuffer,nTamFile)  // Leitura  do arquivo XML
fClose(nHdl)
cAviso := ""
cErro  := ""
oNfe := XmlParser(cBuffer,"_",@cAviso,@cErro)

Private oNF
Private oNFChv
If Type("oNFe:_CteProc")<> "U"
		oNF := oNFe:_CteProc:_cte
		oNFChv:=  oNFe:_cteProc:_protCTe
ElseIf type("oNFe:_Cte")<> "U"
	oNF := oNFe:_Cte  
	oNFChv:=  oNFe:_cteProc:_protCTe
Else 
    _clog:= "[ERRO][DATA] " + cValtoChar(DATE())     + "  [HORA] " +  cValtoChar(Time()) + "   [CHAVE] " + cChvNfe +  " [ARQUIVO] " + cFile + "  Arquivo Inválido."    + _CRLF +_clog	
	xFile := STRTRAN(cFile,  cDirINN,"\XML\ERRO\")
	COPY FILE &cFile TO &xFile	
	fErase( cFile )	
	Return(_clog)
Endif

Private oEmitente  := oNF:_InfCTe:_emit
Private oIdent     := oNF:_InfCTe:_IDE
Private oDestino   := oNF:_InfCTe:_Dest
Private ovPrest    := oNF:_InfCTe:_vPrest
Private oImp       := oNF:_InfCTe:_Imp
Private cChvNfe    := oNFChv:_infProt:_ChCte:TEXT
Private oPrest     := oNF:_InfCTe:_vPrest	
cCgc := AllTrim(IIf(Type("oEmitente:_CPF")=="U",oEmitente:_CNPJ:TEXT,oEmitente:_CPF:TEXT))
If !SA2->(dbSetOrder(3), dbSeek(xFilial("SA2")+cCgc))
    _clog:= "[ERRO][DATA] " + cValtoChar(DATE())     + "  [HORA] " +  cValtoChar(Time()) + "   [CHAVE] " + cChvNfe +  " [ARQUIVO] " + cFile  + "   [MENSAGEM]   CNPJ: " + cCgc + " Origem Não Localizado."  + _CRLF +_clog
    xFile := STRTRAN(cFile,  cDirINN,"\XML\ERRO\")
	COPY FILE &cFile TO &xFile	
	fErase( cFile )	
    Return(_clog)
Endif
		
If SF1->(DbSeek(XFilial("SF1")+Right("000000000"+Alltrim(OIdent:_nCT:TEXT),9)+Right("000"+Alltrim(OIdent:_serie:TEXT),3)+SA2->A2_COD+SA2->A2_LOJA))
	_clog := "[ERRO][DATA] " + cValtoChar(DATE())     + "  [HORA] " +  cValtoChar(Time()) + "   [CHAVE] " + cChvNfe +  " [ARQUIVO] " + cFile + "   [MENSAGEM]   Nota No.: "+Right("000000000"+Alltrim(OIdent:_nCT:TEXT),9)+"/"+OIdent:_serie:TEXT+" do Fornec. "+SA2->A2_COD+"/"+SA2->A2_LOJA+" Ja Existe."   + _CRLF +_clog	
	xFile := STRTRAN(cFile,  cDirINN,"\XML\ERRO\")
	COPY FILE &cFile TO &xFile	
	fErase( cFile )	
	Return(_clog)
EndIf
  
_nNum :=Right("000000000"+Alltrim(OIdent:_nCT:TEXT),9)
aCabec := {}
aItens := {}
aadd(aCabec,{"F1_TIPO"   ,"N",Nil,Nil})
aadd(aCabec,{"F1_FORMUL" ,"N",Nil,Nil})
aadd(aCabec,{"F1_DOC"    , _nNum ,Nil,Nil})	
aadd(aCabec,{"F1_SERIE"  ,Right("000"+OIdent:_serie:TEXT,3),Nil,Nil})
cData:=substr(Alltrim(OIdent:_dhEmi:TEXT),1,10)
dData:=CTOD(Right(cData,2)+'/'+Substr(cData,6,2)+'/'+Left(cData,4))
aadd(aCabec,{"F1_EMISSAO",dData,Nil,Nil})
aadd(aCabec,{"F1_FORNECE",SA2->A2_COD,Nil,Nil})
aadd(aCabec,{"F1_LOJA"   ,SA2->A2_LOJA,Nil,Nil})
aadd(aCabec,{"F1_COND",_cCdPg,Nil,Nil})	
aadd(aCabec,{"F1_ESPECIE","CTE ",Nil,Nil})		
aadd(aCabec,{"F1_TPCTE", "N",Nil,Nil})	
aadd(aCabec,{"F1_TOTAL",val(oPrest:_vTPrest:TEXT),Nil,Nil})
aadd(aCabec,{"F1_CHVNFE",cChvNfe,Nil,Nil})
cProds := ''
aPedIte:={}

AAdd(aPedIte,{_cProd,1,val(ovPrest:_vTPrest:TEXT),VAL(ovPrest:_vTPrest:TEXT)})		
					
aLinha := {}
aadd(aLinha,{"D1_QUANT",1,Nil,Nil})				
aadd(aLinha,{"D1_VUNIT",val(oPrest:_vTPrest:TEXT),Nil,Nil})
aadd(aLinha,{"D1_TOTAL",val(oPrest:_vTPrest:TEXT),Nil,Nil})
aadd(aLinha,{"D1_COD",_cProd,Nil,Nil})
Do Case
	Case Type("oImp:_ICMS:_ICMS00")<> "U"
		oICM:=oImp:_ICMS:_ICMS00
	Case Type("oImp:_ICMS:_ICMS10")<> "U"
		oICM:=oImp:_ICMS:_ICMS10
	Case Type("oImp:_ICMS:_ICMS20")<> "U"
		oICM:=oImp:_ICMS:_ICMS20
	Case Type("oImp:_ICMS:_ICMS30")<> "U"
		oICM:=oImp:_ICMS:_ICMS30
	Case Type("oImp:_ICMS:_ICMS40")<> "U"
		oICM:=oImp:_ICMS:_ICMS40
	Case Type("oImp:_ICMS:_ICMS51")<> "U"
		oICM:=oImp:_ICMS:_ICMS51
	Case Type("oImp:_ICMS:_ICMS60")<> "U"
		oICM:=oImp:_ICMS:_ICMS60
	Case Type("oImp:_ICMS:_ICMS70")<> "U"
		oICM:=oImp:_ICMS:_ICMS70
	Case Type("oImp:_ICMS:_ICMS90")<> "U"
		oICM:=oImp:_ICMS:_ICMS90
EndCase
If Type("oICM:_orig:TEXT")<> "U" .And. Type("oICM:_CST:TEXT")<> "U"
	CST_Aux:="0"+Alltrim(oICM:_CST:TEXT)
	aadd(aLinha,{"D1_CLASFIS",CST_Aux,Nil,Nil})
Endif	
aadd(aLinha,{"D1_VALDESC",0,Nil,Nil})
aadd(aLinha,{"D1_TESACLA",_cTES,Nil,Nil})            
aadd(aLinha,{"D1_VALDESC",0,Nil,Nil})  
aadd(aLinha,{"D1_TES",_cTES,Nil,Nil}) 

cPedCom:= u_fGetPCom(SA2->A2_COD, SA2->A2_LOJA, val(oPrest:_vTPrest:TEXT))

If !empty(cPedCom)
	aadd(aLinha,{"D1_PEDIDO",substring(cPedCom,1,6),Nil,Nil})
	aadd(aLinha,{"D1_ITEMPC",substring(cPedCom,7,10),Nil,Nil})
EndIf
 
aadd(aItens,aLinha)		

cx=1                             
If Len(aItens) > 0
	Private lMsErroAuto := .f.
	Private lMsHelpAuto := .T.
	SB1->( dbSetOrder(1) )
	SA2->( dbSetOrder(1) )	
	nModulo := 4  //ESTOQUE
	PutMV("MV_PCNFE",.f.)
	MsAguarde({|| MSExecAuto({|x,y,z|Mata140(x,y,z)},aCabec,aItens,3)}, "Importando XML de Ct-e", "Processando Registros...")	
	IF lMsErroAuto     			
		_cArqErro := cFile+ "_erro" + ".log"
		_cErroTemp:= MostraErro("\XML\erro\"+_cArqErro, _cArqErro) 
		_clog :=  "[ERRO] [DATA] " + cValtoChar(DATE())  + "  [HORA] " +  cValtoChar(Time()) + "[CHAVE] " + cChvNfe +   " [ARQUIVO] " + cFile + " [MENSAGEM] "+  _cErroTemp  + _CRLF +_clog	
		xFile := STRTRAN(cFile,  cDirINN,"\XML\ERRO\")
		COPY FILE &cFile TO &xFile	
		fErase( cFile )				
	Else
		If Alltrim(SF1->F1_DOC) == _nNum
			//ConfirmSX8()  	
			_clog := "[INFO][DATA] " + cValtoChar(DATE()) + " [HORA] " +  cValtoChar(Time()) + " [CHAVE] " + cChvNfe +  " [ARQUIVO] " + cFile  + " [MENSAGEM] Nota No.: "+Right("000000000"+Alltrim(OIdent:_nCT:TEXT),9)+"/"+OIdent:_serie:TEXT+" do Fornec. "+SA2->A2_COD+"/"+SA2->A2_LOJA+"  INCLUÍDA!"  + _CRLF +_clog 			
			xFile := STRTRAN(cFile,  cDirINN,cDirLIDOS)
			COPY FILE &cFile TO &xFile	
			fErase( cFile )							
		EndIf
	EndIf
Endif
Return(_clog)

User Function fGetPCom(cForn, cLoja, nVal)

Local _cQry := ""
Local cAliPC := getnextalias()
local _cRet:= ""


_cQry := ""
_cQry += " SELECT  MIN(C7_NUM+'/'+C7_ITEM)  PED_ITEM   "
_cQry += " FROM " + RetSqlName("SC7") + " SC7 (NOLOCK) "
_cQry += " WHERE C7_FILIAL = '" + xFilial("SC7") + "' "
_cQry += " AND SC7.D_E_L_E_T_ = ' ' "
_cQry += " AND C7_QUANT > C7_QUJE  "
_cQry += " AND C7_RESIDUO = ' '  "
_cQry += " AND C7_CONAPRO <> 'B'  "
_cQry += " AND C7_ENCER = ' ' "
_cQry += " AND C7_FORNECE = '" + cForn  + "' "
_cQry += " AND C7_LOJA = '" + cLoja + "' "
_cQry += " AND C7_PRODUTO = '" + _cProd + " '"
_cQry += " AND C7_TOTAL =  "+ cvaltochar(nVal) +""

_cQry := ChangeQuery(_cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cAliPC,.T.,.T.)
Dbselectarea(cAliPC)

 _cRet:= (cAliPC)->PED_ITEM

DbCloseArea(cAliPC)

return(_cRet)
