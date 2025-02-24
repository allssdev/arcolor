#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH
#INCLUDE "SHELL.CH

#DEFINE _CLRF CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณRTMKI003  บAutor  ณAnderson C. P. Coelho บ Data ณ  25/11/15 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina responsแvel por converter planilhas em XLS para CSV.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Data     ณAutor          ณ Descri็ใo                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ   /  /   ณ               ณ                                            บฑฑ
ฑฑบ   /  /   ณ               ณ                                            บฑฑ
ฑฑบ   /  /   ณ               ณ                                            บฑฑ
ฑฑบ   /  /   ณ               ณ                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RTMKI003()

Local oGroup1
Local oSay1
Local oSay2
Local oSay3
Local oSButton1
Local oSButton2
Local oSButton3

Private cDrive, cDir, cNome, cExt
Private cDriveM, cDirM, cNomeM, cExtM
Private _cRotina     := "RTMKI003"
Private cTitulo      := "Conversใo de arquivos XLS para CSV (Excel)"
Private cCadastro    := cTitulo
Private _cDst        := Lower(GetTempPath())
Private _cPathMc     := "\xla\"
Private _cArqMc      := Lower(_cRotina+".XLA")
Private _cExtDst     := ".csv"
Private _cArqOri     := ""
Private _nOpc        := 0
Private bOk          := { || _nOpc := 1, oDlg:End()                  }
Private bCancel      := { || oDlg:End()                              }
Private bDir         := { || _cArqOri := Lower(AllTrim(Lower(SelDirArq()))) }

Static oDlg

  DEFINE MSDIALOG oDlg TITLE "["+_cRotina+"] "+cTitulo FROM 000, 000  TO 220, 750 COLORS 0, 16777215 PIXEL

    @ 004, 003 GROUP oGroup1 TO 104, 371 PROMPT " IMPORTANTE " OF oDlg COLOR 0, 16777215 PIXEL
    @ 025, 010 SAY oSay1 PROMPT "Esta rotina ้ utilizada para a conversใo de arquivos XLS em CSV. Selecione o arquivo XLS para que possa ser processado pela rotina.      " SIZE 350, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 038, 010 SAY oSay2 PROMPT "                                                                                                                                         " SIZE 350, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 050, 010 SAY oSay3 PROMPT "Ap๓s selecionar o arquivo, clique em confirmar.                                                                                          " SIZE 350, 007 OF oDlg COLORS 0, 16777215 PIXEL
    DEFINE SBUTTON oSButton1 FROM 087, 237 TYPE 14 OF oDlg ENABLE  ACTION Eval(bDir   )
    DEFINE SBUTTON oSButton2 FROM 087, 280 TYPE 01 OF oDlg ENABLE  ACTION Eval(bOk    )
    DEFINE SBUTTON oSButton3 FROM 087, 320 TYPE 02 OF oDlg ENABLE  ACTION Eval(bCancel)

  ACTIVATE MSDIALOG oDlg CENTERED

If _nOpc == 1
	Processa( { |lEnd| Converter(@lEnd) }, "["+_cRotina+"] "+cTitulo, "Processando...",.T.)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณConverter บAutor  ณAnderson C. P. Coelho บ Data ณ  25/11/15 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Processamento da rotina...                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Converter(lEnd)

Local _aArqXls := {}
Local _lProc   := .T.
Local _cCaminh := ""
Local _nOk     := 0
Local _nEr     := 0

SplitPath(_cArqOri, @cDrive, @cDir, @cNome, @cExt)
_cCaminh := (cDrive+cDir)
//Confirma็๕es iniciais
If !MsgYesNo("Confirma a conversใo dos arquivos da pasta '" + _cCaminh + "' selecionada?",_cRotina+"_001")
	MsgStop("Opera็ใo cancelada!",_cRotina+"_002")
	//CONOUT("["+_cRotina+"_002] Opera็ใo cancelada!")
	_lProc := .F.
EndIf
If _lProc .AND. !ApOleClient('MsExcel')
	MsgStop("Excel nใo instalado!",_cRotina+"_003")
	//CONOUT("["+_cRotina+"_003] Excel nใo instalado!")
	_lProc := .F.
EndIf
If _lProc
//XLA - Copio o Arquivo de Macro para a pasta temporแria do terminal do usuแrio
	SplitPath( (_cPathMc+_cArqMc), @cDriveM, @cDirM, @cNomeM, @cExtM )
	If !File(cDriveM+cDirM+cNomeM+cExtM) .OR. ".XLA"<>UPPER(cExtM)
		MsgStop("O arquivo '" + (cDriveM+cDirM+cNomeM+cExtM) + "' de Macro nใo foi encontrado ou encontra-se em formato divergente. A importa็ใo serแ abortada!",_cRotina+"_004")
		//CONOUT("["+_cRotina+"_004] O arquivo '" + (cDriveM+cDirM+cNomeM+cExtM) + "' de Macro nใo foi encontrado ou encontra-se em formato divergente. A importa็ใo serแ abortada!")
		_lProc := .F.
	Else
		CpyS2T( (cDriveM+cDirM+cNomeM+cExtM), _cDst, .F. )
		SplitPath( (_cDst+_cArqMc), @cDriveM, @cDirM, @cNomeM, @cExtM )
		If (!File(cDriveM+cDirM+cNomeM+cExtM) .OR. ".XLA"<>UPPER(cExtM))
			MsgStop("O arquivo '" + (cDriveM+cDirM+cNomeM+cExtM) + "' de Macro nใo foi copiado corretamente para o servidor. Contate o Administrador!",_cRotina+"_005")
			//CONOUT("["+_cRotina+"_005] O arquivo '" + (cDriveM+cDirM+cNomeM+cExtM) + "' de Macro nใo foi copiado corretamente para o servidor. Contate o Administrador!")
			_lProc := .F.
		EndIf
	EndIf
EndIf
If _lProc
	_aArqXls := Directory(_cCaminh + "*.XLS")
	ProcRegua(Len(_aArqXls))
	For _x := 1 To Len(_aArqXls)
		_cArqOri := LOWER(_cCaminh+_aArqXls[_x][01])  //StrTran(StrTran(StrTran(_cCaminh+LOWER(_aArqXls[_x][01]),".","")," ",""),"-","")
		SplitPath(_cArqOri, @cDrive, @cDir, @cNome, @cExt)
		If "."$cNome
			If fRename((cDrive+cDir+cNome+cExt),(cDrive+cDir+StrTran(cNome,".","")+cExt)) == 0
				_cArqOri := (cDrive+cDir+StrTran(cNome,".","")+cExt)
				SplitPath(_cArqOri, @cDrive, @cDir, @cNome, @cExt)
			Else
				//_lProc := .F.
				Loop
			EndIf
		EndIf
		IncProc("Processando arquivo "+_cArqOri+"...")
	//Transforma็ใo do arquivo XLS em CSV (a Macro ้ quem executa esta opera็ใo)
		//Inicializa o objeto para executar a macro
		oExcelApp := MsExcel():New()
		//define qual o caminho da macro a ser executada
		oExcelApp:WorkBooks:Open(Lower(cDriveM+cDirM+cNomeM+cExtM))
		oExcelApp:Run( Lower(cNomeM+cExtM+"!"+_cRotina), (cDrive+cDir), cNome, cExt, _cExtDst )
		//fecha a macro sem salvar
		//oExcelApp:WorkBooks:Close('savechanges:=False')
		//sai do arquivo e destr๓i o objeto
		oExcelApp:Quit()
		oExcelApp:Destroy()
	//CSV - Arquivo transformado - Verifica็ใo e c๓pia para o destino, para posterior importa็ใo para o sistema
		If _lProc .AND. !File(cDrive+cDir+cNome+_cExtDst)
			MsgStop("Problemas ao ler/converter o arquivo '" + (cDrive+cDir+cNome+_cExtDst) + "'. A importa็ใo serแ abortada. Verifique o formato do arquivo, permiss๕es e outros padr๕es que possam impedir esta opera็ใo. Em caso de d๚vidas, contate o administrador!",_cRotina+"_007")
			//CONOUT("["+_cRotina+"_007] Problemas ao ler/converter o arquivo '" + (cDrive+cDir+cNome+_cExtDst) + "'. A importa็ใo serแ abortada. Verifique o formato do arquivo, permiss๕es e outros padr๕es que possam impedir esta opera็ใo. Em caso de d๚vidas, contate o administrador!")
			//_lProc := .F.
			_nEr++
		Else
			_nOk++
			//CONOUT("["+_cRotina+"_008] Arquivo '" + (cDrive+cDir+cNome+_cExtDst) + "' convertido com sucesso!")
		EndIf
	Next
//Exclusใo da Macro no caminho temporแrio (depois de utilizada)
	If File(cDriveM+cDirM+cNomeM+cExtM)
		FErase(cDriveM+cDirM+cNomeM+cExtM)
	EndIf
EndIf

MsgInfo("T้rmino do processamento."+_CLRF+"* OK..: "+cValToChar(_nOk)+_CLRF+"* Erro: "+cValToChar(_nEr),_cRotina+"_009")
//CONOUT("["+_cRotina+"_009] T้rmino do processamento."+_CLRF+"* OK..: "+cValToChar(_nOk)+_CLRF+"* Erro: "+cValToChar(_nEr))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณSelDirArq บAutor  ณAnderson C. P. Coelho บ Data ณ  25/11/15 บฑฑ
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

Local _cTipo := "Arquivos Excel do tipo XLS | *.XLS"

_cArqOri     := cGetFile(_cTipo, "Selecione o arquivo a ser importado ",0,"C:\",.T.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY)

Return(_cArqOri)