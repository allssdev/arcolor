#Include 'Protheus.ch'
#Include 'Rwmake.ch'
#INCLUDE "TBICONN.CH
#INCLUDE "TOTVS.CH
#INCLUDE "SHELL.CH

#DEFINE _CLRF CHR(13)+CHR(10)

// Tabela de op็๕es de exibi็ใo da janela da aplica็ใo executada
#define SW_HIDE             0 // Escondido
#define SW_SHOWNORMAL       1 // Normal
#define SW_NORMAL           1 // Normal
#define SW_SHOWMINIMIZED    2 // Minimizada
#define SW_SHOWMAXIMIZED    3 // Maximizada
#define SW_MAXIMIZE         3 // Maximizada
#define SW_SHOWNOACTIVATE   4 // Na Ativa็ใo
#define SW_SHOW             5 // Mostra na posi็ใo mais recente da janela
#define SW_MINIMIZE         6 // Minimizada
#define SW_SHOWMINNOACTIVE  7 // Minimizada
#define SW_SHOWNA           8 // Esconde a barra de tarefas
#define SW_RESTORE          9 // Restaura a posi็ใo anterior
#define SW_SHOWDEFAULT      10// Posi็ใo padrใo da aplica็ใo
#define SW_FORCEMINIMIZE    11// For็a minimiza็ใo independente da aplica็ใo executada
#define SW_MAX              11// Maximizada

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณRTMKI005  บAutor  ณAnderson C. P. Coelho บ Data ณ  25/11/15 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina responsแvel por chamar a rotina RTMKI004 de         บฑฑ
ฑฑบ          ณconversใo de arquivos XLS para CSV, relativo aos pedidos dosบฑฑ
ฑฑบ          ณrepresentantes para o Call Center, por meio de JOB.         บฑฑ
ฑฑบ          ณA rotina chama um arquivo ".BAT".                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico para a empresa Arcolor.            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
	//CONOUT("["+_cRotina+"_001 - "+DTOC(Date())+" - "+StrTran(Time(),":","_")+"] INอCIO da chamada da rotina de conversใo de arquivos XLS para CSV...")
	If type("aParams")=="A".AND.Len(aParams)>0
		//CONOUT("["+_cRotina+"_002] Parametros: "+_CLRF+aParams[01]+_CLRF+aParams[02]+_CLRF+aParams[03]+_CLRF+aParams[04])
	Else
		//CONOUT("["+_cRotina+"_003] Carregando parโmetros...")
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
	varinfo(">>> Conte๚do de aParams: ", aParams)
	If len(aParams) == 0
		//CONOUT("["+_cRotina+"_004] Parametros nใo carregados!")
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
		//CONOUT("["+_cRotina+"_006] PROBLEMAS na chamada de execu็ใo do arquivo " + _cCaminho + "!")
	EndIf
	//CONOUT("["+_cRotina+"_001 - "+DTOC(Date())+" - "+StrTran(Time(),":","_")+"] TษRMINO DE PROCESSAMENTO da rotina de conversใo de arquivos XLS para CSV!") 
return