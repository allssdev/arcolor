#include "protheus.ch"                                                
#include "rwmake.ch"
/*/{Protheus.doc} RFATE066
@description Rotina utilizada para efetuar a importação dos arquivos PDF contendo os canhotos da nota fiscal, para anexar ao banco de conhecimento dos documentos de entrada. Estes arquivos podem estar em qualquer extensão, mas devem estar no caminho informado no parâmetro "MV_ARQCANH" ou, em não existindo, no caminho "C:\CANHOTO\"
@author Renan Santos / Anderson C. P. Coelho - ALL SYSTEM SOLUTIONS
@since 19/07/2017
@version 1.00
@type function

@param MV_ARQCANH, Informe o caminho onde os arquivos de canhotos a serem importados estarão.
@param MV_SERFATA, Traz a série das notas fiscais, utilizada normalmente pelo cliente, para o preenchimento automático pela rotina, caso não seja informado no nome do arquivo a ser importado.

@return null, Sem retorno esperado.

@see https://allss.com.br
/*/
user function RFATE066()
	Private _cRotina  := "RFATE066"
	Private _cPasta   := Alltrim(SuperGetMv("MV_ARQCANH",,"c:\canhotos\"))
	Private _bFech    := {|| Close(oDlg01), Processa( {|lEnd| ImpArq(@lEnd)}, "["+_cRotina+"] Importação de Canhotos", "Processando arquivos em '"+_cPasta+"*.*'...", .T.)}
	Static oDlg01
		@ 132,92 To 275,523 Dialog oDlg01 Title "["+_cRotina+"] Importação de Canhotos"
		@ 04,011 To 70,205
		@ 07,018 Say "Esta rotina é utilizada para importar os canhotos de entrega das Notas  " Size 173,8
		@ 15,020 Say "fiscais de saída para o banco de conhecimento. Para tanto, coloque os   " Size 173,8
		@ 23,020 Say "arquivos a serem importados no seguinte caminho: '"+_cPasta+"'.         " Size 173,8
		@ 33,018 Say "Estes devem ser nomeados da seguinte maneira: 'NNNNNNNNNSSS.PDF', sendo:" Size 173,8
		@ 45,020 Say " N = NF ("+cValToChar(TamSx3("F2_DOC")[01])+" caracteres)  |  S = Série ("+cValToChar(TamSx3("F2_SERIE")[01])+" caracteres)  | .PDF = Extensão" Size 173,8
		@ 55,100 BmpButton Type 1 Action EVAL(_bFech)
		@ 55,130 BmpButton Type 2 Action Close(oDlg01)
	Activate Dialog oDlg01 CENTERED
return
static function ImpArq(lEnd)
	Local   _aFiles   := {}
	Local   _cDoc     := ""
	Local   _cSerie   := ""
	Local   _cCli     := ""
	Local   _cLoja    := ""
	Local   _cFilial  := ""
	Local   _cPastaLg := ""
	Local   _cNmArq   := "log_imp_canhotos_"+DTOS(date())+StrTran(Time(),":","")+".txt"
	Local   _cArq     := ""
	Local   _nArq     := 0
	Local   _nX       := 0
	Local   _nProcOK  := 0
	Private cDriveE, cDirE, cNomeE, cExtE
	Private _cSERFATA := SuperGetMV("MV_SERFATA",,"1")
	Private _cDIRDOC  := SuperGetMv("MV_DIRDOC",,"\dirdoc")
	If SubStr(_cPasta,len(_cPasta),1) <> "\"
		_cPasta += "\"
	EndIf
	If !ExistDir(_cPasta) .AND. MakeDir(_cPasta, , .T.) <> 0
		MsgAlert("Atenção! O diretório '"+_cPasta+"' não foi encontrado e nem foi possível criá-lo. Por favor, verifique, uma vez que a rotina depende dessa pasta para início dos processos!",_cRotina+"_001")
	EndIf
	_cPastaLg := _cPasta+"log\"
	If !ExistDir(_cPastaLg) .AND. MakeDir(_cPastaLg, , .T.) <> 0
		MsgAlert("Atenção! O diretório '"+_cPastaLg+"' não foi encontrado e nem foi possível criá-lo. Por favor, verifique, uma vez que a rotina depende dessa pasta para início dos processos!",_cRotina+"_002")
	EndIf
	_cArq := CriaTrab(nil, .F.)
	_nArq := FCreate(_cPastaLg + _cNmArq)
	If _nArq == -1
		MsgAlert("Não foi possível criar o arquivo de log '"+_cNmArq+"'!",_cRotina+"_003")
		MEMOWRITE(_cPastaLg+_cNmArq+".txt","["+DTOC(date())+" - "+Time()+"] Não foi possível criar o arquivo de log!")  
		return
	EndIf
	SplitPath((_cPasta + _cNmArq), @cDriveE, @cDirE, @cNomeE, @cExtE)
	_aFiles := Directory(_cPasta+"*.*", cDriveE)
	If len(_aFiles) > 0
		ProcRegua(len(_aFiles))
		for _nX := 1 to len(_aFiles)
			IncProc("Processando arquivo '"+AllTrim(_aFiles[_nX,1])+"'...")
			If lEnd
				MsgStop("Processamento abortado pelo usuário!",_cRotina+"_004")
				exit
			EndIf
			SplitPath((_cPasta + _aFiles[_nX,1]), @cDriveE, @cDirE, @cNomeE, @cExtE)
			_cDoc 	:= Padr(SubStr(cNomeE,01                    ,TamSx3("F2_DOC"  )[01]),TamSx3("F2_DOC"  )[01])
			_cSerie := Padr(SubStr(cNomeE,TamSx3("F2_DOC")[01]+1,TamSx3("F2_SERIE")[01]),TamSx3("F2_SERIE")[01])
		//	If _cSerie <> SuperGetMV("MV_SERFATZ",,"ZZZ")								//Serie CD
			If Empty(_cSerie)
				_cSerie := Padr(_cSERFATA,TamSx3("F2_SERIE")[01])	//Serie da nota fiscal
			EndIf
			If len(_cDoc) == TamSx3("F2_DOC")[01]
				BeginSql Alias "TMPSF2" 
					SELECT F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA 
					FROM %table:SF2% SF2 (NOLOCK)
					 WHERE SF2.F2_FILIAL = %xFilial:SF2%
					   AND SF2.F2_DOC    = %exp:_cDoc%
					   AND SF2.F2_SERIE  = %exp:_cSerie%
					   AND SF2.%NotDel%
				EndSql   
				//MemoWrite( "\2.MemoWrite\"+_cRotina+"_QRY1.txt",GETLastQuery()[2])
				dbSelectArea("TMPSF2")  
					_cFilial := TMPSF2->F2_FILIAL
					_cCli    := TMPSF2->F2_CLIENTE
					_cLoja   := TMPSF2->F2_LOJA 
					_cDoc    := TMPSF2->F2_DOC
					_cSerie  := TMPSF2->F2_SERIE
				TMPSF2->(dbCloseArea())
				If !empty(_cCli+_cLoja)
					Begin Transaction
						dbSelectarea("ACB")
						ACB->(dbSetOrder(2))			//FILIAL +OBJETO
						If !ACB->(dbSeek(xFilial("ACB") + _aFiles[_nX,1]))
							dbSelectarea("AC9")
							AC9->(dbSetOrder(1))		//FILIAL +OBJETO
							If !AC9->(dbSeek(xFilial("AC9") + _cDoc +_cSerie +_cCli + _cLoja))
								If ExistDir(AllTrim(_cDIRDOC)+"\co"+SubStr(cNumEmp,1,2)+"\shared\") .AND. CpyT2S(_cPasta+_aFiles[_nX,1],AllTrim(_cDIRDOC)+"\co"+SubStr(cNumEmp,1,2)+"\shared\",.T.,.T.) 
									dbSelectArea("ACB")
									while !RecLock("ACB",.T.) ; enddo
										ACB->ACB_FILIAL := IIF(Empty(xFilial("ACB")).OR.Empty(_cFilial),xFilial("ACB"),_cFilial)
										ACB->ACB_CODOBJ := GetSXENum("ACB", "ACB_CODOBJ")
										ACB->ACB_OBJETO := _aFiles[_nX,1]
										ACB->ACB_DESCRI := "NF_"+_aFiles[_nX,1]
									ACB->(MSUNLOCK())
									ACB->(ConfirmSx8())
									dbSelectArea("AC9")
									while !RecLock("AC9",.T.) ; enddo
										AC9->AC9_FILIAL := IIF(Empty(xFilial("AC9")).OR.Empty(_cFilial),xFilial("AC9"),_cFilial)
										AC9->AC9_FILENT := _cFilial 
										AC9->AC9_ENTIDA := "SF2"
										AC9->AC9_CODOBJ := ACB->ACB_CODOBJ
										AC9->AC9_CODENT := _cDoc +_cSerie +_cCli + _cLoja
									AC9->(MSUNLOCK())
									dbSelectArea("ACC")
									while !RecLock("ACC",.T.) ; enddo
										ACC->ACC_FILIAL := IIF(Empty(xFilial("ACC")).OR.Empty(_cFilial),xFilial("ACC"),_cFilial)
										ACC->ACC_CODOBJ := ACB->ACB_CODOBJ
										ACC->ACC_KEYWRD := "CANHOTO_"+_aFiles[_nX,1]
									ACC->(MSUNLOCK())
									_nProcOK++
									FWrite(_nArq,"["+DTOC(date())+" - "+Time()+": "+_aFiles[_nX,1]+"] O arquivo foi processado com sucesso para a o banco de conhecimento!"+chr(13)+chr(10))
									If ExistDir(_cPasta+"ok\") .OR. MakeDir(_cPasta+"ok\", , .T.) <> 0
										If FRename((_cPasta+_aFiles[_nX,1]), _cPasta+"ok\"+_aFiles[_nX,1],, .F.) == 0
											FERASE(_cPasta+_aFiles[_nX,1])
										EndIf
									Else
										FERASE(_cPasta+_aFiles[_nX,1])
									EndIf
								Else
									FWrite(_nArq,"["+DTOC(date())+" - "+Time()+": "+_aFiles[_nX,1]+"] O arquivo não foi copiado para a o banco de conhecimento!"+chr(13)+chr(10))
								EndIf
							Else
								FWrite(_nArq,"["+DTOC(date())+" - "+Time()+": "+_aFiles[_nX,1]+"] Arquivo já vinculado anteriormente no banco de conhecimento!"+chr(13)+chr(10))
							EndIf
						Else
							FWrite(_nArq,"["+DTOC(date())+" - "+Time()+": "+_aFiles[_nX,1]+"] Arquivo já existente no banco de conhecimento!"+chr(13)+chr(10))		 
						EndIf
					End Transaction
				Else
					FWrite(_nArq,"["+DTOC(date())+" - "+Time()+": "+_aFiles[_nX,1]+"] Arquivo não encontrado!"+chr(13)+chr(10)) 
				EndIf	
			Else 
				FWrite(_nArq,"["+DTOC(date())+" - "+Time()+": "+_aFiles[_nX,1]+"] Arquivo com nomenclatura fora do padrão. Verifique!"+chr(13)+chr(10))
			EndIf	
		next nX
		MsgInfo(cValToChar(_nProcOK)+" arquivos, do total "+cValToChar(len(_aFiles))+" processados, foram vinculados com sucesso a seus documentos de saída!",_cRotina+"_005")
	Else
		MsgAlert("Nenhum arquivo a processar!",_cRotina+"_006")
	EndIf
	FClose(_nArq)
return