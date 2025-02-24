#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "FILEIO.CH"
#DEFINE _CLRF CHR(13)+CHR(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณRTMKI004  บAutor  ณAnderson C. P. Coelho บ Data ณ  25/11/15 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina responsแvel por converter planilhas em XLS para CSV.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Data     ณAutor          ณ Descri็ใo                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ 20/03/18 ณ               ณ                                            บฑฑ
ฑฑบ   /  /   ณ               ณ                                            บฑฑ
ฑฑบ   /  /   ณ               ณ                                            บฑฑ
ฑฑบ   /  /   ณ               ณ                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user function RTMKI004()
//	Local oGroup1
//	Local oSay1
//	Local oSay2
//	Local oSay3
//	Local oSButton1
//	Local oSButton2
//	Local oSButton3
	Private cDrive, cDir, cNome, cExt
	Private cDriveM, cDirM, cNomeM, cExtM
//	Private _nOpc        := 0
//	Private cTitulo      := "Conversใo de arquivos XLS para CSV (Excel)"
//	Private cCadastro    := cTitulo
	Private _cRotina     := "RTMKI004"
	Private _cDst        := Lower(GetTempPath())
	Private _cPathMc     := "\xla\"
	Private _cArqMc      := Lower(_cRotina+".XLA")
	Private _cExtDst     := ".csv"
	Private _cArqOri     := GetPvProfString("CONVERTE_CSV","ARQ_ORIXLS"    ,"",GetAdv97())			//"D:\PLANILHAS\ENTRADA\IMPORTACAO\"
	Private _cDstXls     := GetPvProfString("CONVERTE_CSV","ARQ_DSTXLS"    ,"",GetAdv97())			//"D:\PLANILHAS\ENTRADA\CONFERENCIA\"
	Private _cDstCsv     := GetPvProfString("CONVERTE_CSV","ARQ_DSTCSV"    ,"",GetAdv97())			//"D:\PLANILHAS\ENTRADA\"
	//CONOUT("["+_cRotina+"_001a - "+DTOC(Date())+" - "+StrTran(Time(),":","_")+"] INICIANDO ROTINA '"+_cRotina+"' DE CONVERSรO DE 'XLS' PARA 'CSV'...")
	If !Empty(_cArqOri) .AND. !Empty(_cDstXls) .AND. !Empty(_cDstCsv)
		Converter()
	Else
		//CONOUT("["+_cRotina+"_001b - "+DTOC(Date())+" - "+StrTran(Time(),":","_")+"] Problemas ao encontrar o caminho dos arquivos no appserver.ini. Processamento abortado!")
	EndIf
	//CONOUT("["+_cRotina+"_015 - "+DTOC(Date())+" - "+StrTran(Time(),":","_")+"] ROTINA '"+_cRotina+"' FINALIZADA COM SUCESSO!")
return
static function Converter()
	Local _aArqXls  := {}
	Local _lProc    := .T.
	Local _cCaminh  := ""
	Local _nTentXls := 0
	Local _nOk      := 0
	Local _nEr      := 0
	Local _x        := 0
	SplitPath(_cArqOri, @cDrive, @cDir, @cNome, @cExt)
	_cCaminh := (cDrive+cDir)
	/*
	If Empty(cExt) .OR. AllTrim(UPPER(cExt))<>"XLS"
		//CONOUT("["+_cRotina+"_002] Extensใo incorreta para o aquivo ('"+AllTrim(_cArqOri)+"')!")
		_lProc := .F.
	EndIf
	If _lProc .AND. !ApOleClient('MsExcel')
		//CONOUT("["+_cRotina+"_003] Excel nใo instalado!")
		_lProc := .F.
	EndIf
	*/
	If _lProc .AND. !(_lProc := ApOleClient('MsExcel'))
		//06/11/2015 - Inserida recursividade para que o sistema tente localizar a instala็ใo do Excel por 10 vezes - Isso foi necessแrio dado a uma falha de relacionamento do MS Office 2013 com o Windows
		_nTentXls := 0
		While !_lProc .AND. _nTentXls <= 10
			_nTentXls++
			_lProc := ApOleClient('MsExcel')
		EndDo
		If !(_lProc := ApOleClient('MsExcel'))
			//MsgStop("Excel nใo instalado!",_cRotina+"_003")
			//CONOUT("["+_cRotina+"_004] Excel nใo instalado!")
		EndIf
	EndIf
	If _lProc
	//XLA - Copio o Arquivo de Macro para a pasta temporแria do terminal do usuแrio
		SplitPath( (_cPathMc+_cArqMc), @cDriveM, @cDirM, @cNomeM, @cExtM )
		If !File(cDriveM+cDirM+cNomeM+cExtM) .OR. ".XLA"<>UPPER(cExtM)
			//CONOUT("["+_cRotina+"_005] O arquivo '" + (cDriveM+cDirM+cNomeM+cExtM) + "' de Macro nใo foi encontrado ou encontra-se em formato divergente. A importa็ใo serแ abortada!")
			_lProc := .F.
		Else
			CpyS2T( (cDriveM+cDirM+cNomeM+cExtM), _cDst, .F. )
			SplitPath( (_cDst+_cArqMc), @cDriveM, @cDirM, @cNomeM, @cExtM )
			If (!File(cDriveM+cDirM+cNomeM+cExtM) .OR. ".XLA"<>UPPER(cExtM))
				//CONOUT("["+_cRotina+"_006] O arquivo '" + (cDriveM+cDirM+cNomeM+cExtM) + "' de Macro nใo foi copiado corretamente para o servidor. Contate o Administrador!")
				_lProc := .F.
			EndIf
		EndIf
	EndIf
	If _lProc
		_aArqXls := Directory(_cCaminh + "*.XLS")
		//CONOUT("["+_cRotina+"_007] Processando '" + cValToChar(Len(_aArqXls)) + "' arquivos...")
		for _x := 1 to len(_aArqXls)
			_cArqOri := LOWER(_cCaminh+_aArqXls[_x][01])  //StrTran(StrTran(StrTran(_cCaminh+LOWER(_aArqXls[_x][01]),".","")," ",""),"-","")
			cDrive := cDir := cNome := cExt := ""
			SplitPath(_cArqOri, @cDrive, @cDir, @cNome, @cExt)
			//CONOUT("["+_cRotina+"_008] Verificando extensใo do arquivo '"+_cArqOri+"'...")
			////CONOUT("["+_cRotina+"_009] Extensใo: " + @cExt)
			//CONOUT("["+_cRotina+"_009] Extensใo: " + cExt)
			//If AllTrim(UPPER(@cExt)) <> ".XLS"
			If Empty(StrTran(cExt,".","")) .OR. AllTrim(UPPER(cExt))<>".XLS"
				_nEr++
				//CONOUT("["+_cRotina+"_010] Arquivo '"+_cArqOri+"' com extensใo incorreta sem possibilidade de ser processado!")
				Loop
			EndIf
			//CONOUT("["+_cRotina+"_011] Verificando exclusividade de acesso ao arquivo'"+_cArqOri+"'...")
			If (nH := fOpen(_cArqOri , /*FO_READWRITE + FO_SHARED +*/ FO_EXCLUSIVE)) == -1
				_nEr++
				//CONOUT("["+_cRotina+"_012] Nใo foi possํvel obter acesso exclusivo ao arquivo '"+_cArqOri+"'... portanto, ele nใo serแ processado!")
				Loop
			Else
				fClose(nH)
			EndIf
			If "."$cNome
				If fRename((cDrive+cDir+cNome+cExt),(cDrive+cDir+StrTran(cNome,".","")+cExt)) == 0
					_cArqOri := (cDrive+cDir+StrTran(cNome,".","")+cExt)
					SplitPath(_cArqOri, @cDrive, @cDir, @cNome, @cExt)
				Else
					//_lProc := .F.
					Loop
				EndIf
			EndIf
			//CONOUT("["+_cRotina+"_013] Processando arquivo '" + _cArqOri + "'...")
			//CONOUT("["+_cRotina+"_014] Iniciando chamada da macro de conversใo...")
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
				_nEr++
				//CONOUT("["+_cRotina+"_015] Problemas ao ler/converter o arquivo '" + (cDrive+cDir+cNome+_cExtDst) + "'. A importa็ใo serแ abortada. Verifique o formato do arquivo, permiss๕es e outros padr๕es que possam impedir esta opera็ใo. Em caso de d๚vidas, contate o administrador!")
				_lProc := .F.
				Loop
			Else
				_nOk++
				//CONOUT("["+_cRotina+"_016] Arquivo '" + (cDrive+cDir+cNome+_cExtDst) + "' convertido com sucesso!")
				//CONOUT("["+_cRotina+"_017] Enviando arquivo '" + (cDrive+cDir+cNome+_cExtDst) + "' para '"+_cDstCsv+"'...")
				If fRename((cDrive+cDir+cNome+_cExtDst),(_cDstCsv+cNome+_cExtDst)) == 0
					//CONOUT("["+_cRotina+"_018] Arquivo '" + (cDrive+cDir+cNome+_cExtDst) + "' enviado com sucesso para '"+_cDstCsv+"'...")
					//CONOUT("["+_cRotina+"_019] Enviando arquivo '" + (cDrive+cDir+cNome+cExt) + "' para '"+_cDstXls+"'...")
					If fRename((cDrive+cDir+cNome+cExt),(_cDstXls+cNome+cExt)) == 0
						//CONOUT("["+_cRotina+"_020] Arquivo '" + (cDrive+cDir+cNome+cExt) + "' enviado com sucesso para '"+_cDstXls+"'...")
					Else
						//CONOUT("["+_cRotina+"_021] Problemas no envio do arquivo '" + (cDrive+cDir+cNome+cExt) + "' para '"+_cDstXls+"'...")
					EndIf
				Else
					//CONOUT("["+_cRotina+"_022] Problemas no envio do arquivo '" + (cDrive+cDir+cNome+_cExtDst) + "' para '"+_cDstCsv+"'...")
				EndIf
			EndIf
		next
	//Exclusใo da Macro no caminho temporแrio (depois de utilizada)
		If File(cDriveM+cDirM+cNomeM+cExtM)
			//CONOUT("["+_cRotina+"_023] Excluindo macro '" + (cDriveM+cDirM+cNomeM+cExtM) + "'...")
			FErase(cDriveM+cDirM+cNomeM+cExtM)
		EndIf
	EndIf
	//CONOUT("["+_cRotina+"_024] T้rmino do processamento."+_CLRF+"* OK..: "+cValToChar(_nOk)+_CLRF+"* Erro: "+cValToChar(_nEr))
return
/*
static function SelDirArq()
	Local _cTipo := "Arquivos Excel do tipo XLS | *.XLS"
	_cArqOri     := cGetFile(_cTipo, "Selecione o arquivo a ser importado ",0,"C:\",.T.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY)
return(_cArqOri)
*/