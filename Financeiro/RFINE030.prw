#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*/{Protheus.doc} RFINE030
@description ExecBlock feito para Visualização do Banco de Conhecimento do Cliente posicionado ao apertar a tecla "F2" (MA450MNU).
@author Arthur Silva (ALLSS Soluções em Sistemas)
@since 01/08/2016
@version 1.0
@type function
@history 18/02/2020, Anderson C. P. Coelho (ALLSS Soluções em Sistemas), Correção de error.log provocado pela falta de posicionamento correto dos registros.
@see https://allss.com.br
/*/
user function RFINE030()
	local  _aSavArea := GetArea()
	local  _aSavSA1  := SA1->(GetArea())
	local  _aSavSA2  := SA2->(GetArea())
	local  _aSavSC5  := SC5->(GetArea())
	local  _aSavSC9  := SC9->(GetArea())
//	local _cRotina   := 'RFINE030'
//	local _cFNamBkp  := FunName()
	local _lProc     := .F.
	if Alias() == "SA1" .OR. Alias() == "SA2"
		//SetFunName("MATA030")
		//MsDocument(Alias(),Recno(),4)	//Visualização do Banco de Conhecimento do Cliente/Fornecedor posicionado
		MsDocument(Alias(),Recno(),3)	//Visualização do Banco de Conhecimento do Cliente/Fornecedor posicionado
	else
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		if SC5->(MsSeek(FWFilial("SC5") + SC9->C9_PEDIDO,.T.,.F.))
			if !AllTrim(SC5->C5_TIPO)$"/D/B/"
				dbSelectArea("SA1")
				SA1->(dbSetOrder(1))
				_lProc := SA1->(MsSeek(FWFilial("SA1")+SC9->C9_CLIENTE+SC9->C9_LOJA,.T.,.F.))
			else
				dbSelectArea("SA2")
				SA2->(dbSetOrder(1))
				_lProc := SA2->(MsSeek(FWFilial("SA2")+SC9->C9_CLIENTE+SC9->C9_LOJA,.T.,.F.))
			endif
			if _lProc
				//MsDocument(Alias(),Recno(),4)	//Visualização do Banco de Conhecimento do Cliente/Fornecedor posicionado
				MsDocument(Alias(),Recno(),3)	//Visualização do Banco de Conhecimento do Cliente/Fornecedor posicionado
			endif
		endif
	endif
	//SetFunName(_cFNamBkp)
	RestArea(_aSavSC5)
	RestArea(_aSavSC9)
	RestArea(_aSavSA1)
	RestArea(_aSavSA2)
	RestArea(_aSavArea)
return