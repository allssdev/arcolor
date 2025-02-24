#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณFA60FIL   บAutor  ณ บ Data  ณ   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ

ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especifico para empresa Arcolor              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*/{Protheus.doc} FA60FIL
@description Ponto de entrada para filtrar os titulos na gera็ใo do bordero a ser enviado para o banco.
@author Thiago S. de Almeida
@since 15/01/2013
@version 1.0
@return ${return}, ${return_description}
@type function
@see https://allss.com.br
/*/
user function FA60FIL()
	local   _aSavArea := GetArea()
	local   _aPergBkp := {}
	local   _bTYPE    := ""

	private cPerg     := "FA60FI"
	private _cFiltro  := ""
	private _nSqPerg  := 1

	/* FB - RELEASE 12.1.23
	While Type("MV_PAR"+StrZero(_nSqPerg,2))<>"U"
		AADD(_aPergBkp,{("MV_PAR"+StrZero(_nSqPerg,2)),&("MV_PAR"+StrZero(_nSqPerg,2))})
		_nSqPerg++
	EndDo
	*/
	_bTYPE := "Type('MV_PAR'+StrZero(_nSqPerg,2))"
	while &(_bTYPE) <> "U"
		AADD(_aPergBkp,{("MV_PAR"+StrZero(_nSqPerg,2)),&("MV_PAR"+StrZero(_nSqPerg,2))})
		_nSqPerg++
	enddo
	//------------------------------------------------------
	//ณ Variaveis utilizadas para parametros                        
	// mv_par01        	// Banco	                            
	// mv_par02        	// Agencia	                        
	// mv_par03       	// Conta
	// mv_par04        	// SubConta
	//------------------------------------------------------
	dbSelectArea("SE1")
	_cFiltro := SE1->(dbFilter())
	//------------------------------------------------------
	// Verifica as perguntas selecionadas                   
	//------------------------------------------------------
	ValidPerg()
	if !Pergunte(cPerg,.T.)
		return _cFiltro
	endif
	//_cFiltro := AllTrim(_cFiltro) + "E1_NUMBCO<>''.AND.E1_PORTADO==MV_PAR01.AND.E1_AGEDEP==MV_PAR02.AND.E1_CONTA==MV_PAR03.AND.E1_CARTEIR==MV_PAR04.AND.E1_VENCTO>(E1_EMISSAO+1)"
	// - Alterado em 22/02/2016 por J๚lio Soares para acrescer o bloqueio de tํtulos que ainda nใo foram gerados Danfe.
	//_cFiltro := AllTrim(_cFiltro) + "E1_PORTADO==MV_PAR01 .AND. E1_AGEDEP==MV_PAR02 .AND. E1_CONTA==MV_PAR03 .AND. E1_CARTEIR==MV_PAR04 .AND. E1_VENCTO>(E1_EMISSAO+1)"
	_cFiltro := AllTrim(_cFiltro)+ " "
	_cFiltro += "SE1->E1_PORTADO == '" + Padr(MV_PAR01,Len(SE1->E1_PORTADO)) + "' .AND. "
	_cFiltro += "SE1->E1_AGEDEP  == '" + Padr(MV_PAR02,Len(SE1->E1_AGEDEP )) + "' .AND. "
	_cFiltro += "SE1->E1_CONTA   == '" + Padr(MV_PAR03,Len(SE1->E1_CONTA  )) + "' .AND. "
	_cFiltro += "SE1->E1_CARTEIR == '" + Padr(MV_PAR04,Len(SE1->E1_CARTEIR)) + "' .AND. "
	_cFiltro += "SE1->E1_FLUXO   == 'S' .AND. SE1->E1_VENCTO   > (SE1->E1_EMISSAO+1) "
	/*
	SET FILTER TO _cFiltro +  SE1->E1_PORTADO==MV_PAR01.AND.;
							SE1->E1_AGEDEP==MV_PAR02.AND.;
							SE1->E1_CONTA==MV_PAR03.AND.;
							SE1->E1_CARTEIR==MV_PAR04.AND.;
							SE1->E1_VENCTO>(SE1->E1_EMISSAO+1) .AND.;
							SE1->E1_FLUXO == "S"
	*/
	dbSelectArea("SE1")
	SE1->(dbClearFilter())
	SE1->(dbSetFilter( { || &(_cFiltro) }, _cFiltro ))
	_cFiltro := SE1->(dbFilter())
	for _p    := 1 to len(_aPergBkp)
		&(_aPergBkp[_p][01]) := _aPergBkp[_p][02]
	next
	RestArea(_aSavArea)
return _cFiltro
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFun็ใo    ณVALIDPERG บ Autor ณAnderson C. P. Coelho บ Data ณ  17/11/08 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescri็ใo ณ Verifica a exist๊ncia das perguntas de parโmetros, as      บฑฑ
ฑฑบ          ณ criando caso nใo existam na "SX1".                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especifico para empresa Arcolor              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ValidPerg()

Local _sAlias := GetArea()
Local aRegs   := {}

cPerg         := PADR(cPerg,10)

AADD(aRegs,{cPerg,"01","Banco     ?","","","mv_ch1","C",03,0,0,"G","NaoVazio().and.ExistCPO('SA6')","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SA6","",""})
AADD(aRegs,{cPerg,"02","Agencia   ?","","","mv_ch2","C",05,0,0,"G","NaoVazio()					  ","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"03","Conta     ?","","","mv_ch4","C",10,0,0,"G","NaoVazio()					  ","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"04","Carteira  ?","","","mv_ch6","C",06,0,0,"G","NaoVazio()					  ","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SEE","",""})

For I := 1 To Len(aRegs)
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If !MsSeek(cPerg + aRegs[i,2],.T.,.F.)
		while !RecLock("SX1",.T.) ; enddo
			For J := 1 To FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Else
					Exit
				EndIf
			Next
		SX1->(MSUNLOCK())
	EndIf
Next    

RestArea(_sAlias)

Return()