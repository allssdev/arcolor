#include 'totvs.ch'
#include "tbiconn.ch"
#include "shell.ch"
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
WaitRunSrv( cCommandLine , lWaitRun , cPath ) : lSuccess

Onde: 

cCommandLine : Instru��o a ser executada
lWaitRun     : Se deve aguardar o t�rmino da Execu��o
Path         : Onde, no server, a fun��o dever� ser executada
Retorna      : .T. Se conseguiu executar o Comando, caso contr�rio, .F.

Read more: http://www.blacktdn.com.br/2011/04/protheus-executando-aplicacoes-externas.html#ixzz3q56owRhD
*/
/*/{Protheus.doc} RTMKI002
@description Rotina respons�vel por chamar a rotina RTMKI001 de importa��o da planilha em XLS (Excel) dos pedidos dos representantes para o Call Center, por meio de JOB. A rotina chama um arquivo ".BAT".
@author Anderson C. P. Coelho (ALLSS Solu��es em Sistemas)
@since 30/10/2015
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RTMKI002(aParams)
	Local _cRotina  := "RTMKI002"
	Local _cCaminho := ""
	Local _cUnidExc := ""
	Local _cEmp     := ""
	Local _cFil     := ""
//	Local _cUnid    := ""
//	Local _cMap     := ""
	Local _nX       := 0
	Private cDrive, cDir, cNome, cExt
	/*
	default aParams := {"D:\Planilhas\z_config\ImpPed.bat",;
						"D:\",;
						"01",;
						"01"}
	*/
	default aParams := {GetPvProfString("PEDIDOS_TMK","ARQ_BAT"   ,"",GetAdv97()),;
						GetPvProfString("PEDIDOS_TMK","DIRETORIO" ,"",GetAdv97()),;
						GetPvProfString("PEDIDOS_TMK","EMPRESA"   ,"",GetAdv97()),;
						GetPvProfString("PEDIDOS_TMK","FILIAL"    ,"",GetAdv97())}
	If valtype(aParams) == "U" .OR. len(aParams) == 0
		return
	EndIf
	varinfo(">>> Conte�do de aParams: ", aParams)
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
	//RpcClearEnv()
	//WFPrepEnv( <cEmpresa>, <cFilial>, <cFunname>, <aTabelas> <cModulo>)
	//WFPrepEnv( _cEmp, _cFil)
	//CONOUT("["+_cRotina+"_001] In�cio da chamada da importa��o das planilhas...")
	SplitPath(_cCaminho, @cDrive, @cDir, @cNome, @cExt)
	//ShellExecute("Open", _cCaminho, "", cDrive, 1 )
	//WinExec(_cCaminho)
	//If WaitRun( _cCaminho )
	If WaitRunSrv( _cCaminho, .F., _cUnidExc )
		//CONOUT("["+_cRotina+"_002] Arquivo " + _cCaminho + " chamado com sucesso!")
	Else
		//CONOUT("["+_cRotina+"_003] PROBLEMAS na chamada de execu��o do arquivo " + _cCaminho + "!")
	EndIf
return