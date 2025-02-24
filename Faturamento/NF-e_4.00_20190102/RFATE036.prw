#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "FONT.CH"
#include "COLORS.CH"
#include "TOTVS.CH"
#Include "TOPCONN.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RFATE036 º Autor ³ Adriano Leonardo    º Data ³ 04/02/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Execblock utilizado em botão específico de transmissão de  º±±
±±º          ³ nota posicionada na tela do NFe Sefaz, chamado no fonte    º±±
±±º          ³ FISTRFNFE.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function RFATE036()

Local _aSavArea  := GetArea()
Local _aSavSF1   := SF1->(GetArea())
Local _aSavSF2   := SF2->(GetArea())
Local aPerg      := {}
Local _aSavPar   := {}
Local aParam     := {Space(Len(SF2->F2_SERIE)),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC))}
Local cParNfeRem := SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDNFEREM"
Local _bPAR := "Type('MV_PAR'+StrZero(_nSeq,2))"

private nHErp    := AdvConnection() //Armazena a conexão atual
private cDBTSS   := GetPvProfString("RCOMW001_001","BANCOTSSDataBase","",GetAdv97())+"/"+GetPvProfString("RCOMW001_001","BANCOTSS","",GetAdv97())				//"MSSQL7/TSSP12_PRODUCAO"  //Nome do serviço/Nome da base
private cSrvTSS  := GetPvProfString("RCOMW001_001","BANCOTSSServer","",GetAdv97())																				//"192.168.1.213"	//	private cSrvOra := AllTrim(getServerIP())		//"192.168.1.106"  // IP do servidor
private cDBPRD   := GetPvProfString("RCOMW001_001","BANCOPRDDataBase","",GetAdv97())+"/"+GetPvProfString("RCOMW001_001","BANCOPRD","",GetAdv97())				//"MSSQL7/TSSP12_PRODUCAO"  //Nome do serviço/Nome da base
private cSrvPRD  := GetPvProfString("RCOMW001_001","BANCOPRDServer","",GetAdv97())																				//"192.168.1.213"	//	private cSrvOra := AllTrim(getServerIP())		//"192.168.1.106"  // IP do servidor
private nHndOra  := 0

Private _nSeq      := 1
/* FB - RELEASE 12.1.23
While Type("MV_PAR"+StrZero(_nSeq,2))<>"U"
*/
While &(_bPAR) <> "U"
	AADD(_aSavPar,{("MV_PAR"+StrZero(_nSeq,2)),&("MV_PAR"+StrZero(_nSeq,2))})
	_nSeq++
EndDo

MV_PAR01 := aParam[01] := PadR(ParamLoad(cParNfeRem,aPerg,1,aParam[01]),Len(SF2->F2_SERIE))
MV_PAR02 := aParam[02] := PadR(ParamLoad(cParNfeRem,aPerg,2,aParam[02]),Len(SF2->F2_DOC  ))
MV_PAR03 := aParam[03] := PadR(ParamLoad(cParNfeRem,aPerg,3,aParam[03]),Len(SF2->F2_DOC  ))

  //Neste momento faço com que o sistema permaneca na base atual que o usuario logou 
//Seto a nova conexão que desejo utilizar
nHndOra := TcLink(cDBPRD,cSrvPRD,7890)
tcSetConn(nHndOra) 

SpedNFeRe2(IIF(SubStr(MV_PAR01,1,1)=="1",SF2->F2_SERIE,SF1->F1_SERIE),IIF(SubStr(MV_PAR01,1,1)=="1",SF2->F2_DOC,SF1->F1_DOC),IIF(SubStr(MV_PAR01,1,1)=="1",SF2->F2_DOC,SF1->F1_DOC),.F.,.F.)
If Len(_aSavPar) > 0
	For _x := 1 To Len(_aSavPar)
		&(_aSavPar[_x][01]) := _aSavPar[_x][02]
	Next
endif

RestArea(_aSavSF1)
RestArea(_aSavSF2)
RestArea(_aSavArea)

Return()