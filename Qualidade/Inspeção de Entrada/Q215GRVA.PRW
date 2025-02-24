USER FUNCTION Q215GRVA()	

//LOCAL cProd  := PARAMIXB[1]	
//LOCAL cRevpr := PARAMIXB[2]	
//LOCAL cForn  := PARAMIXB[3]	
//LOCAL cLjFor := PARAMIXB[4]	
//LOCAL cDtent := dtos(PARAMIXB[5])	
//LOCAL cLote  := PARAMIXB[6]		
//LOCAL cNtfis := PARAMIXB[7]	
//LOCAL cSerNF := PARAMIXB[8]	
//LOCAL cItNF  := PARAMIXB[9]	
//LOCAL cTpNF  := PARAMIXB[10]	
//LOCAL nOpc   := PARAMIXB[11]	

//alert ('O produto : '+cProd+' do Fornecedor : '+cForn+' Lote : '+cLote+' recebeu apontamentos de resultados Liberados')
/*
_lSaldo := Q215SldCQ(cProd,QEK->QEK_CERFOR,If(nOpc==4,.T.,.F.))
If !_lSaldo .and. !Empty(M->QEL_LAUDO)
    QEK->QEK_SITENT := "9" 
EndIf
*/

if QEK->QEK_SITENT$"6"  //1=Laudo Pend;2=Laudo Aprov;3=Laudo Reprov;4=Liber Urgen;5=Laudo Cond;6=Permissao de Uso;7=Laudo Med Pend;8=Laudo Lab Pend;      
	If MSGYESNO( "Deseja imprimir o Certificado?","Certificado_Q215GRVA" )
		QIER050()
	endIf
endIf
RETURN .T.
