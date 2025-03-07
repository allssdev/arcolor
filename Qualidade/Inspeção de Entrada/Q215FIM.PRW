#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"


/*/{Protheus.doc} 
@description ste ponto de entrada envia os dados "Cod.Produto / Revis�o produto / Cod.Fornecedor / Loja Fornecedor / Data Entrada / Lote / Nr Nota / Serie NF / Item NF / Tipo NF e Op��o do Menu" referente � entrada / libera��o do resultado ap�s efetivar a grava��o do mesmo. Ponto de chamada : na fun��o Q215GrvAll do QIEA215.PRW.  Este ponto � id�ntico ao Q215GRVA, por�m, atua fora do ponto de transa��o (Begin/End Transaction).
@author		Livia Della Corte email: livia.dcorte@allss.com.br
@since 		18/06/2023
@version 	1.01
@see 		https://allss.com.br
/*/


User Function Q215FIM()	

//LOCAL cProd  := PARAMIXB[1]	// Cod.Produto
//LOCAL cRevpr := PARAMIXB[2]	// Revis�o produto
//LOCAL cForn  := PARAMIXB[3]	// Cod.Fornecedor
//LOCAL cLjFor := PARAMIXB[4]	// Loja Fornecedor       
//LOCAL cDtent := dtos(PARAMIXB[5])	// Data Entrada
//LOCAL cLote  := PARAMIXB[6]	// Lote	
//LOCAL cNtfis := PARAMIXB[7]	// Nr Nota
//LOCAL cSerNF := PARAMIXB[8]	// Serie NF
//LOCAL cItNF  := PARAMIXB[9]	// Item NF
//LOCAL cTpNF  := PARAMIXB[10]	// Tipo NF
//LOCAL cOpc   := PARAMIXB[11]  //Op��o do Menu
Local _aUsrEtq := SuperGetMv("MV_XUSETQA" ,,"000089" )
Local _cTpLibCQ := supergetmv("MV_XTPACQ",,"2/3/4/5/6/9")
/*Executado ap�s a libera��o no Inspe��o de Entradas.*/

if QEK->QEK_SITENT$_cTpLibCQ  //1=Laudo Pend;2=Laudo Aprov;3=Laudo Reprov;4=Liber Urgen;5=Laudo Cond;6=Permissao de Uso;7=Laudo Med Pend;8=Laudo Lab Pend;      
	If msgYesNo( "Deseja imprimir o Certificado?","Certificado_Q215FIM" )
		QIER050()
	endIf
endIf

if QEK->QEK_SITENT$_cTpLibCQ  .and. Upper(AllTrim(__cUserId)) $ _aUsrEtq //1=Laudo Pend;2=Laudo Aprov;3=Laudo Reprov;4=Liber Urgen;5=Laudo Cond;6=Permissao de Uso;7=Laudo Med Pend;8=Laudo Lab Pend;      
	If msgYesNo( "Deseja imprimir etiqueta?" )
		U_PesqENt(QEK->QEK_NTFISC,QEK->QEK_SERINF,QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_PRODUT,QEK->QEK_LOTE)
	endIf
endIf


Return .T.
