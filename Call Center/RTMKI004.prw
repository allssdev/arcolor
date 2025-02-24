#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "FILEIO.CH"
#DEFINE _CLRF CHR(13)+CHR(10)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RTMKI004  �Autor  �Anderson C. P. Coelho � Data �  25/11/15 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina respons�vel por converter planilhas em XLS para CSV.���
�������������������������������������������������������������������������͹��
��� Data     �Autor          � Descri��o                                  ���
�������������������������������������������������������������������������͹��
��� 20/03/18 �               �                                            ���
���   /  /   �               �                                            ���
���   /  /   �               �                                            ���
���   /  /   �               �                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
//	Private cTitulo      := "Convers�o de arquivos XLS para CSV (Excel)"
//	Private cCadastro    := cTitulo
	Private _cRotina     := "RTMKI004"
	Private _cDst        := Lower(GetTempPath())
	Private _cPathMc     := "\xla\"
	Private _cArqMc      := Lower(_cRotina+".XLA")
	Private _cExtDst     := ".csv"
	Private _cArqOri     := GetPvProfString("CONVERTE_CSV","ARQ_ORIXLS"    ,"",GetAdv97())			//"D:\PLANILHAS\ENTRADA\IMPORTACAO\"
	Private _cDstXls     := GetPvProfString("CONVERTE_CSV","ARQ_DSTXLS"    ,"",GetAdv97())			//"D:\PLANILHAS\ENTRADA\CONFERENCIA\"
	Private _cDstCsv     := GetPvProfString("CONVERTE_CSV","ARQ_DSTCSV"    ,"",GetAdv97())			//"D:\PLANILHAS\ENTRADA\"
	//CONOUT("["+_cRotina+"_001a - "+DTOC(Date())+" - "+StrTran(Time(),":","_")+"] INICIANDO ROTINA '"+_cRotina+"' DE CONVERS�O DE 'XLS' PARA 'CSV'...")
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
		//CONOUT("["+_cRotina+"_002] Extens�o incorreta para o aquivo ('"+AllTrim(_cArqOri)+"')!")
		_lProc := .F.
	EndIf
	If _lProc .AND. !ApOleClient('MsExcel')
		//CONOUT("["+_cRotina+"_003] Excel n�o instalado!")
		_lProc := .F.
	EndIf
	*/
	If _lProc .AND. !(_lProc := ApOleClient('MsExcel'))
		//06/11/2015 - Inserida recursividade para que o sistema tente localizar a instala��o do Excel por 10 vezes - Isso foi necess�rio dado a uma falha de relacionamento do MS Office 2013 com o Windows
		_nTentXls := 0
		While !_lProc .AND. _nTentXls <= 10
			_nTentXls++
			_lProc := ApOleClient('MsExcel')
		EndDo
		If !(_lProc := ApOleClient('MsExcel'))
			//MsgStop("Excel n�o instalado!",_cRotina+"_003")
			//CONOUT("["+_cRotina+"_004] Excel n�o instalado!")
		EndIf
	EndIf
	If _lProc
	//XLA - Copio o Arquivo de Macro para a pasta tempor�ria do terminal do usu�rio
		SplitPath( (_cPathMc+_cArqMc), @cDriveM, @cDirM, @cNomeM, @cExtM )
		If !File(cDriveM+cDirM+cNomeM+cExtM) .OR. ".XLA"<>UPPER(cExtM)
			//CONOUT("["+_cRotina+"_005] O arquivo '" + (cDriveM+cDirM+cNomeM+cExtM) + "' de Macro n�o foi encontrado ou encontra-se em formato divergente. A importa��o ser� abortada!")
			_lProc := .F.
		Else
			CpyS2T( (cDriveM+cDirM+cNomeM+cExtM), _cDst, .F. )
			SplitPath( (_cDst+_cArqMc), @cDriveM, @cDirM, @cNomeM, @cExtM )
			If (!File(cDriveM+cDirM+cNomeM+cExtM) .OR. ".XLA"<>UPPER(cExtM))
				//CONOUT("["+_cRotina+"_006] O arquivo '" + (cDriveM+cDirM+cNomeM+cExtM) + "' de Macro n�o foi copiado corretamente para o servidor. Contate o Administrador!")
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
			//CONOUT("["+_cRotina+"_008] Verificando extens�o do arquivo '"+_cArqOri+"'...")
			////CONOUT("["+_cRotina+"_009] Extens�o: " + @cExt)
			//CONOUT("["+_cRotina+"_009] Extens�o: " + cExt)
			//If AllTrim(UPPER(@cExt)) <> ".XLS"
			If Empty(StrTran(cExt,".","")) .OR. AllTrim(UPPER(cExt))<>".XLS"
				_nEr++
				//CONOUT("["+_cRotina+"_010] Arquivo '"+_cArqOri+"' com extens�o incorreta sem possibilidade de ser processado!")
				Loop
			EndIf
			//CONOUT("["+_cRotina+"_011] Verificando exclusividade de acesso ao arquivo'"+_cArqOri+"'...")
			If (nH := fOpen(_cArqOri , /*FO_READWRITE + FO_SHARED +*/ FO_EXCLUSIVE)) == -1
				_nEr++
				//CONOUT("["+_cRotina+"_012] N�o foi poss�vel obter acesso exclusivo ao arquivo '"+_cArqOri+"'... portanto, ele n�o ser� processado!")
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
			//CONOUT("["+_cRotina+"_014] Iniciando chamada da macro de convers�o...")
		//Transforma��o do arquivo XLS em CSV (a Macro � quem executa esta opera��o)
			//Inicializa o objeto para executar a macro
			oExcelApp := MsExcel():New()
			//define qual o caminho da macro a ser executada
			oExcelApp:WorkBooks:Open(Lower(cDriveM+cDirM+cNomeM+cExtM))
			oExcelApp:Run( Lower(cNomeM+cExtM+"!"+_cRotina), (cDrive+cDir), cNome, cExt, _cExtDst )
			//fecha a macro sem salvar
			//oExcelApp:WorkBooks:Close('savechanges:=False')
			//sai do arquivo e destr�i o objeto
			oExcelApp:Quit()
			oExcelApp:Destroy()
		//CSV - Arquivo transformado - Verifica��o e c�pia para o destino, para posterior importa��o para o sistema
			If _lProc .AND. !File(cDrive+cDir+cNome+_cExtDst)
				_nEr++
				//CONOUT("["+_cRotina+"_015] Problemas ao ler/converter o arquivo '" + (cDrive+cDir+cNome+_cExtDst) + "'. A importa��o ser� abortada. Verifique o formato do arquivo, permiss�es e outros padr�es que possam impedir esta opera��o. Em caso de d�vidas, contate o administrador!")
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
	//Exclus�o da Macro no caminho tempor�rio (depois de utilizada)
		If File(cDriveM+cDirM+cNomeM+cExtM)
			//CONOUT("["+_cRotina+"_023] Excluindo macro '" + (cDriveM+cDirM+cNomeM+cExtM) + "'...")
			FErase(cDriveM+cDirM+cNomeM+cExtM)
		EndIf
	EndIf
	//CONOUT("["+_cRotina+"_024] T�rmino do processamento."+_CLRF+"* OK..: "+cValToChar(_nOk)+_CLRF+"* Erro: "+cValToChar(_nEr))
return
/*
static function SelDirArq()
	Local _cTipo := "Arquivos Excel do tipo XLS | *.XLS"
	_cArqOri     := cGetFile(_cTipo, "Selecione o arquivo a ser importado ",0,"C:\",.T.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY)
return(_cArqOri)
*/