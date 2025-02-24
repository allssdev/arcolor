#Include 'Protheus.ch'
#Include 'Rwmake.ch'
#INCLUDE "TBICONN.CH
#INCLUDE "TOTVS.CH
#INCLUDE "SHELL.CH

#DEFINE _CLRF CHR(13)+CHR(10)

// Tabela de op��es de exibi��o da janela da aplica��o executada
#define SW_HIDE             0 // Escondido
#define SW_SHOWNORMAL       1 // Normal
#define SW_NORMAL           1 // Normal
#define SW_SHOWMINIMIZED    2 // Minimizada
#define SW_SHOWMAXIMIZED    3 // Maximizada
#define SW_MAXIMIZE         3 // Maximizada
#define SW_SHOWNOACTIVATE   4 // Na Ativa��o
#define SW_SHOW             5 // Mostra na posi��o mais recente da janela
#define SW_MINIMIZE         6 // Minimizada
#define SW_SHOWMINNOACTIVE  7 // Minimizada
#define SW_SHOWNA           8 // Esconde a barra de tarefas
#define SW_RESTORE          9 // Restaura a posi��o anterior
#define SW_SHOWDEFAULT      10// Posi��o padr�o da aplica��o
#define SW_FORCEMINIMIZE    11// For�a minimiza��o independente da aplica��o executada
#define SW_MAX              11// Maximizada

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RTMKI005  �Autor  �Anderson C. P. Coelho � Data �  25/11/15 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina respons�vel por chamar a rotina RTMKI004 de         ���
���          �convers�o de arquivos XLS para CSV, relativo aos pedidos dos���
���          �representantes para o Call Center, por meio de JOB.         ���
���          �A rotina chama um arquivo ".BAT".                           ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function RTMKI005(aParams)
	Local _cRotina  := "RTMKI005"
	Local _cCaminho := ""
	Local _cUnidExc := ""
	Local _cEmp     := ""
	Local _cFil     := ""
	//Local _cUnid    := ""
	//Local _cMap     := ""
	Local _cTime    := Time()
	Local _nX       := 0
	Private cDrive, cDir, cNome, cExt

	default aParams := {GetPvProfString("CONVERTE_CSV","PARAM1"    ,"",GetAdv97()),;
						GetPvProfString("CONVERTE_CSV","PARAM4"    ,"",GetAdv97()),;
						GetPvProfString("CONVERTE_CSV","PARAM2"    ,"",GetAdv97()),;
						GetPvProfString("CONVERTE_CSV","PARAM3"    ,"",GetAdv97())}

	If _cTime < GetPvProfString("CONVERTE_CSV","START_TIME" ,"",GetAdv97()) .OR. _cTime > GetPvProfString("CONVERTE_CSV","FINISH_TIME","",GetAdv97())
		return
	EndIf
	//CONOUT("["+_cRotina+"_001 - "+DTOC(Date())+" - "+StrTran(Time(),":","_")+"] IN�CIO da chamada da rotina de convers�o de arquivos XLS para CSV...")
	If type("aParams")=="A".AND.Len(aParams)>0
		//CONOUT("["+_cRotina+"_002] Parametros: "+_CLRF+aParams[01]+_CLRF+aParams[02]+_CLRF+aParams[03]+_CLRF+aParams[04])
	Else
		//CONOUT("["+_cRotina+"_003] Carregando par�metros...")
	/*
		aParams := {"D:\Planilhas12\z_config\ConvXlsCsv.bat",;
					"D:\",;
					"01",;
					"01"}
	*/
		aParams := {GetPvProfString("CONVERTE_CSV","PARAM1"    ,"",GetAdv97()),;
					GetPvProfString("CONVERTE_CSV","PARAM4"    ,"",GetAdv97()),;
					GetPvProfString("CONVERTE_CSV","PARAM2"    ,"",GetAdv97()),;
					GetPvProfString("CONVERTE_CSV","PARAM3"    ,"",GetAdv97())}
	EndIf
	varinfo(">>> Conte�do de aParams: ", aParams)
	If len(aParams) == 0
		//CONOUT("["+_cRotina+"_004] Parametros n�o carregados!")
		return
	EndIf
	for _nX := 1 to len(aParams)
		If empty(aParams[_nX])
			//CONOUT("["+_cRotina+"_004] Problemas com os parametros carregados!")
			return
		EndIf
	next
	_cCaminho := aParams[01]
	_cUnidExc := aParams[02]
	_cEmp     := aParams[03]
	_cFil     := aParams[04]
	SplitPath(_cCaminho, @cDrive, @cDir, @cNome, @cExt)
	//CONOUT("["+_cRotina+"_004] Chamando arquivo '"+_cCaminho+"'...")
	If WaitRunSrv( _cCaminho, .F., _cUnidExc )
		//CONOUT("["+_cRotina+"_005] Arquivo " + _cCaminho + " chamado com sucesso!")
	Else
		//CONOUT("["+_cRotina+"_006] PROBLEMAS na chamada de execu��o do arquivo " + _cCaminho + "!")
	EndIf
	//CONOUT("["+_cRotina+"_001 - "+DTOC(Date())+" - "+StrTran(Time(),":","_")+"] T�RMINO DE PROCESSAMENTO da rotina de convers�o de arquivos XLS para CSV!") 
return