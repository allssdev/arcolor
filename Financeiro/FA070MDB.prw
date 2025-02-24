#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA070MDB 	บAutor  ณThiago S. de Almeida บData ณ  21/12/12   บฑฑ
ฑฑบPrograma  ณ          บAutor  ณAdriano Leonardo     บData ณ  15/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de Entrada executado na confirma็ใo da tela de baixa บฑฑ
ฑฑบ          ณ dos titulos a receber, para valida็ใo no tipo de baixa.    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para a empresa Arcolor.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function FA070MDB()

Local _aSavArea := GetArea()
Local _cRotina  := "FA070MDB"
Local _lRet     := .T.

dbSelectArea("SZ3")
dbSetOrder(1)
If MsSeek(xFilial("SZ3") + __cUserId,.T.,.F.)
	If __cUserId $ SZ3->Z3_USERREC
		dbSelectArea("SE1")
		dbSetOrder(1)
		IF !((__cUserId $ SuperGetMv("MV_BXFULL" ,,"000000" )+'/000000')) .And. !MovBanco()
			MsgAlert("Motivo de baixa nใo permitido para este usuแrio!",_cRotina+"_001")
			//Para incluir permissใo para novos usuแrios acrescente o id do usuแrio no parโmetro MV_BXFULL
			_lRet := .F.
   		EndIF
   	EndIf
EndIf

RestArea(_aSavArea)

Return(_lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MOVBANCO บAutor  ณAdriano Leonardo    บ Data ณ  15/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsแvel por verificar se o motivo de baixa      บฑฑ
ฑฑบ          ณ escolhido movimenta banco (retorno l๓gico).                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especํfico - ARCOLOR - Programa Principal                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function MovBanco() 

	Local _aSavTemp := GetArea()
	Local _cMotBxa := ""
    Local _cDrive  := ""
    Local _cDir	   := CurDir() //Retorna o diret๓rio configurado no INI do AppServer
    Local _cNome   := "SIGAADV"
    Local _cExt	   := ".MOT"
    Local _lRet	   := .T.
    
	_cMotBxa := CMOTBX
	
	//Faz a leitura do arquivo de configura็ใo dos motivos de baixa (SIGAADV.MOT da pasta System)
	FT_FUSE(_cDrive+_cDir+_cNome+_cExt)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	
	If !FT_FEOF()
		While !FT_FEOF()
			_cMotAux := AllTrim(SubStr(FT_FREADLN(),4 ,10))
			If _cMotBxa == _cMotAux //Verifica se ้ o motivo selecionado ้ o escolhido pelo usuแrio
				_cMovBan := SubStr(FT_FREADLN(),15,1)
				If _cMovBan=='N'    //Verifica se o motivo escolhido movimenta banco
					_lRet := .F.
				EndIf
				Exit
			EndIf
			FT_FSKIP()
		EndDo
	EndIf
	FT_FUSE()
RestArea(_aSavTemp)

Return(_lRet)