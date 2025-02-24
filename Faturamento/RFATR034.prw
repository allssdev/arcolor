#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณRFATR034  บAutor  ณAnderson C. P. Coelho บ Data ณ  26/11/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณEnvio de e-mail em html aos clientes com uma imagem padrใo  บฑฑ
ฑฑบ          ณem jpg.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico para a empresa Arcolor.            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RFATR034()

Local oGroup1
Local oSay1
Local oSay2
Local oSay3
Local oSButton1
Local oSButton2
Local oSButton3

Private cDrive, cDir, cNome, cExt
Private cTitulo  := "Envio imagem comunicado por e-mail a clientes"
Private _cRotina := "RFATR034"
Private cPerg    := _cRotina
Private _cArqOri := ""
Private _cDst    := "\workflow\"
Private _nOpc    := 0
Private bOk      := { || _nOpc := 1, oDlg:End()                         }
Private bCancel  := { || oDlg:End()                                     }
Private bDir     := { || _cArqOri := Lower(AllTrim(Lower(SelDirArq()))), Pergunte(cPerg,.T.) }

ValidPerg()
If Pergunte(cPerg,.T.)
	Static oDlg

	  DEFINE MSDIALOG oDlg TITLE "["+_cRotina+"] "+cTitulo FROM 000, 000  TO 220, 750 COLORS 0, 16777215 PIXEL

	    @ 004, 003 GROUP oGroup1 TO 104, 371 PROMPT " I M P O R T A N T E " OF oDlg COLOR 0, 16777215 PIXEL
	    @ 025, 010 SAY oSay1 PROMPT "Esta rotina ้ utilizada para o envio de e-mail aos clientes em HTML com a imagem em formato JPG em seu corpo. Tenha cuidado com a        " SIZE 350, 007 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 038, 010 SAY oSay2 PROMPT "informa็ใo que serแ enviada, pois o processo serแ irreversํvel!                                                                          " SIZE 350, 007 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 050, 010 SAY oSay3 PROMPT "Ap๓s selecionar o arquivo, clique em confirmar.                                                                                          " SIZE 350, 007 OF oDlg COLORS 0, 16777215 PIXEL
	    DEFINE SBUTTON oSButton1 FROM 087, 237 TYPE 14 OF oDlg ENABLE  ACTION Eval(bDir   )
	    DEFINE SBUTTON oSButton2 FROM 087, 280 TYPE 01 OF oDlg ENABLE  ACTION Eval(bOk    )
	    DEFINE SBUTTON oSButton3 FROM 087, 320 TYPE 02 OF oDlg ENABLE  ACTION Eval(bCancel)

	  ACTIVATE MSDIALOG oDlg CENTERED
EndIf

If _nOpc == 1
	If !Empty(_cArqOri) .AND. File(_cArqOri)
		If ConfImg()
			SplitPath( _cArqOri, @cDrive, @cDir, @cNome, @cExt )
			CpyT2S( (cDrive+cDir+cNome+cExt), _cDst, .F. )
			If !File(_cDst+cNome+cExt)
				_cDst := _cArqOri
			Else
				_cDst := _cDst+cNome+cExt
				SplitPath( _cDst, @cDrive, @cDir, @cNome, @cExt )
			EndIf
			Processa( { |lEnd| RotEnvMail(lEnd) }, "[" + _cRotina + "] " + cTitulo, "Processando informa็๕es...", .T.)
			If Lower(AllTrim(_cDst)) <> Lower(AllTrim(_cArqOri)) .AND. File(_cDst)
				FErase(_cDst)
			EndIf
		Else
			MsgStop("Arquivo de imagem " + _cArqOri + " nใo confirmado pelo usuแrio. Processamento abortado!", _cRotina+"_005")
		EndIf
	Else
		MsgStop("Arquivo de imagem " + _cArqOri + " nใo encontrado. Processamento abortado!", _cRotina+"_004")
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณConfImg   บAutor  ณAnderson C. P. Coelho บ Data ณ  26/11/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณRotina de confirma็ใo da imagem selecionada.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ConfImg()

Local oGroupImg
Local oSButSim
Local oSButNao
Local oBitmap1
Local oFont1   := TFont():New("MS Sans Serif",,026,,.T.,,,,,.F.,.F.)
Local _nOpc2   := 0
Local bOk2     := { || _nOpc2 := 1, oDlg2:End() }
Local bCancel2 := { || oDlg2:End()              }

Static oDlg2

  DEFINE MSDIALOG oDlg2 TITLE "["+_cRotina+"] "+cTitulo FROM 000, 000  TO 500, 750 COLORS 0, 16777215 PIXEL

    @ 004, 007 GROUP oGroupImg TO 245, 365 PROMPT " ENVIA ESTA IMAGEM? " OF oDlg2 COLOR 255, 16777215 PIXEL

    @ 020, 015 BITMAP oBitmap1 SIZE 340, 197 OF oDlg2 FILENAME _cArqOri NOBORDER ADJUST PIXEL

    @ 225, 110 BUTTON oButSim PROMPT "&NAO" SIZE 037, 012 OF oDlg2 PIXEL  ACTION Eval(bCancel2)
    @ 225, 220 BUTTON oButNao PROMPT "SIM"  SIZE 037, 012 OF oDlg2 PIXEL  ACTION Eval(bOk2    )

  ACTIVATE MSDIALOG oDlg2 CENTERED

Return(_nOpc2 == 1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณRotEnvMailบAutor  ณAnderson C. P. Coelho บ Data ณ  26/11/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณProcessamento da rotina                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RotEnvMail(lEnd)

Local Titulo    := ""
Local _cMsg     := ""
Local _cMail    := ""
Local _cAnexo   := ""
Local _cFromOri := ""
Local _cBCC     := ""
Local _cQry     := ""
Local _cLogOK   := ""
Local _cLogErro := ""
Local _nLogOK   := 0
Local _nLogErro := 0
Local _nTotMsg  := 1000
Local _nContMsg := 0
Local _nSeqMsg  := 1
Local _lRCFGM001 := ExistBlock("RCFGM001")

_cQry := " SELECT * "
_cQry += " FROM " + RetSqlName("SA1") + " SA1 "
_cQry += " WHERE SA1.A1_FILIAL     = '" + xFilial("SA1") + "' "
_cQry += "   AND SA1.A1_MSBLQL     = '2'  "
_cQry += "   AND LEN(SA1.A1_EMAIL) > 3 "
_cQry += "   AND SA1.A1_COD  BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR05 + "' "
_cQry += "   AND SA1.A1_LOJA BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "' "
_cQry += "   AND SA1.A1_VEND BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
_cQry += "   AND SA1.D_E_L_E_T_    = '' "
_cQry += " ORDER BY A1_FILIAL, A1_COD, A1_LOJA "
//If __cUserId == "000000"
//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",_cQry)
//EndIf
_cQry := ChangeQuery(_cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"SA1TMP",.F.,.T.)
dbSelectArea("SA1TMP")
ProcRegua(SA1TMP->(RecCount()))
SA1TMP->(dbGoTop())
If !SA1TMP->(EOF()) .AND. !lEnd
	_cAnexo  := (cDrive+cDir+cNome+cExt)
	_cMsgFim := '<img src="' + 'cid:ID_' + _cAnexo + '" alt="Aviso Importante!" title="AVISO IMPORTANTE"/>'
	While !SA1TMP->(EOF()) .AND. !lEnd
		IncProc()
		_cMail   := Lower(AllTrim(SA1TMP->A1_EMAIL))
		If _lRCFGM001 .AND. U_RCFGM001(Titulo,_cMsgFim,_cMail,_cAnexo,"info@arcolor.com.br","","[Arcolor] Comunicado - " + SA1TMP->A1_NOME,.F.)
			_cLogOK   += SA1TMP->A1_COD+SA1TMP->A1_LOJA+" - "+SA1TMP->A1_NOME + CHR(13) + CHR(10)
			_nLogOK++
		Else
			_cLogErro += SA1TMP->A1_COD+SA1TMP->A1_LOJA+" - "+SA1TMP->A1_NOME + CHR(13) + CHR(10)
			_nLogErro++
		EndIf
		dbSelectArea("SA1TMP")
		SA1TMP->(dbSkip())
	EndDo
Else
	_cLogErro += "Nada a Processar!"
	_nLogErro++
	MsgAlert(_cLogErro,_cRotina+"_006")
EndIf
dbSelectArea("SA1TMP")
SA1TMP->(dbCloseArea())
If lEnd
	MsgAlert("Processamento abortado!",_cRotina+"_002")
EndIf
If !Empty(_cLogOK)
	MemoWrite("\2.MemoWrite\"+_cRotina+"_LogOK.txt","Registros enviados com sucesso: " + _cLogOK)
	If File("\2.MemoWrite\"+_cRotina+"_LogOK.txt")
		FOpen("\2.MemoWrite\"+_cRotina+"_LogOK.txt")
	EndIf
EndIf
If !Empty(_cLogOK)
	MemoWrite("\2.MemoWrite\"+_cRotina+"_LogERRO.txt","Registros com ERRO no envio: " + _cLogErro)
	If File("\2.MemoWrite\"+_cRotina+"_LogERRO.txt")
		FOpen("\2.MemoWrite\"+_cRotina+"_LogERRO.txt")
	EndIf
EndIf

MsgInfo("Fim do processamento." + "Clientes com ๊xito: " + cValToChar(_nLogOK) + CHR(13) + CHR(10) + "Clientes com problemas: " + cValToChar(_nLogErro) + CHR(13) + CHR(10),_cRotina+"_003")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณSelDirArq บAutor  ณAnderson C. P. Coelho บ Data ณ  26/11/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Sele็ao de arquivo em diretorio.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SelDirArq()

Local _cTipo := "Arquivos de imagem do tipo JPG | *.JPG"

_cArqOri     := cGetFile(_cTipo, "Selecione o arquivo a ser enviado...",0,"C:\",.T.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY)

Return(_cArqOri)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg  บAutor  ณAnderson C. P. Coelho บ Data ณ  22/10/14บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se as perguntas existem na SX1. Caso nใo existam,  บฑฑ
ฑฑบ          ณas cria.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ValidPerg()

Local _aArea := GetArea()
Local aRegs  := {}
Local _aTam  := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg  := PADR(cPerg,10)

_aTam  := TamSx3("A3_COD" )

// Altera็ใo - Fernando Bombardi - ALLSS - 03/03/2022
//AADD(aRegs,{cPerg,"01","Do Vendedor           ?","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par01",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
//AADD(aRegs,{cPerg,"02","At้ o Vendedor        ?","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par02",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})

AADD(aRegs,{cPerg,"01","Do Representante        ?","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par01",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
AADD(aRegs,{cPerg,"02","At้ o Representante     ?","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par02",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
// Altera็ใo - Fernando Bombardi - ALLSS - 03/03/2022

_aTam  := TamSx3("A1_COD" )
AADD(aRegs,{cPerg,"03","Do Cliente            ?","","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par03",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA1","",""})
_aTam  := TamSx3("A1_LOJA")
AADD(aRegs,{cPerg,"04","Da Loja               ?","","","mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par04",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})
_aTam  := TamSx3("A1_COD" )
AADD(aRegs,{cPerg,"05","At้ o Cliente         ?","","","mv_ch5",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par05",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA1","",""})
_aTam  := TamSx3("A1_LOJA")
AADD(aRegs,{cPerg,"06","At้ a Loja            ?","","","mv_ch6",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par06",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})
For i := 1 To Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j := 1 To FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Else
				Exit
			EndIf
		Next
		SX1->(MsUnlock())
	EndIf
Next

RestArea(_aArea)

Return
