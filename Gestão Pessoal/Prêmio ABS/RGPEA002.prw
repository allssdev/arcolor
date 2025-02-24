#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
/*--------------------------------------------------------------------------------------------------------------------------------------------------------*\
|Programa: RGPEA002 - Cálculo Prêmio Absenteísmo                                                                                                          |
|Data Aplicação: 01/2016 - Autor: ALL SYSTEM SOLUTIONS - Ronaldo Silva                                                                                             |
|Validado por: Adriana / Verônica                                                                                                                          |
|----------------------------------------------------------------------------------------------------------------------------------------------------------|
|Data Alteração:   /  /2016  -  Resposável: ALL SYSTEM SOLUTIONS - Ronaldo Silva                                                                                   |
|Motivo:                                                                                                                                                   |
|Validado por:                                                                                                                                             |
\*--------------------------------------------------------------------------------------------------------------------------------------------------------*/
user function RGPEA002() //ADT ???? / FOL ???? / RES ????			//user function PREMIOABS()

/***********************************************************************
* TROCAR OS PARAMETROS DE USUARIO PARA CAMPOS NO CADASTRO DE SINDICATO 
***********************************************************************/
//----------------------------------------------------------------------------------------------------------------------------------------------------------
// DECLARAÇÃO DE VARIÁVEIS
//----------------------------------------------------------------------------------------------------------------------------------------------------------
Local cArea     := GetArea()
Local cAnMeFol  := SuperGetMV("MV_FOLMES",,)
Local cMesFol   := Right(SuperGetMV("MV_FOLMES",,),2)
Local cAnMePon  := IIF (cMesFol=="01",cValToChar(Val(Left(SuperGetMV("MV_FOLMES",,),4))-1)+"12",cValToChar(Val(SuperGetMV("MV_FOLMES",,))-1))
Local cAnMeAdm  := SubString(DtoS(SRA->RA_ADMISSA),1,6)
Local cAfast    := "NAO"
Local nHrPrev   := 0.00
Local nHrAuse   := 0.00

//----------------------------------------------------------------------------------------------------------------------------------------------------------
// PERDEU POR SALÁRIO OU ADMISSÃO
//----------------------------------------------------------------------------------------------------------------------------------------------------------
If SALARIO < SuperGetMV("AR_ABSSAL",,1.00) .and. cAnMeAdm < cAnMePon
	//------------------------------------------------------------------------------------------------------------------------------------------------------
	// PERDEU POR AFASTAMENTO NO PERÍODO DO PONTO
	//------------------------------------------------------------------------------------------------------------------------------------------------------
	DbSelectArea("SR8")
	SR8->(DbSetOrder(1))
	SR8->(DbGoTop())
	If SR8->(MsSeek(SRA->RA_FILIAL+SRA->RA_MAT , .T.,.F.))
		While SR8->(!Eof()) .and. SR8->R8_FILIAL == SRA->RA_FILIAL .AND. SR8->R8_MAT == SRA->RA_MAT .and. cAfast == "NAO"
			If SR8->R8_DATAINI <= LastDay(StoD(cAnMePon+"01")) .and. (Empty(SR8->R8_DATAFIM) .or. SR8->R8_DATAFIM >= FirstDay(StoD(cAnMePon+"01"))) .and. SR8->R8_TIPO <> "F"
				cAfast := "SIM"
			EndIf
			DbSelectArea("SR8")
			SR8->(DbSetOrder(1))
			SR8->(DbSkip())
		EndDo
		DbSelectArea("SR8")
		SR8->(DbCloseArea())
	EndIf	
	If cAfast == "NAO"
		//--------------------------------------------------------------------------------------------------------------------------------------------------
		// SELEÇÃO DE REGISTROS
		//--------------------------------------------------------------------------------------------------------------------------------------------------
		IF Select("QRY1") <> 0
			DbSelectArea("QRY1")
			DbCloseArea()
		Endif
		BeginSql Alias "QRY1"
				SELECT PC_FILIAL FILIAL, PC_MAT MAT, PC_DATA DATA, 
						P9_IDPON IDPON, PC_PD CEVENTO, P9_DESC DEVENTO, P9_BHORAS BHORAS, P9_CODFOL CODFOL, P9_TIPOCOD TIPO, P9_CLASEV CLASSE, PC_QUANTC QEVENTO, 
						PC_PDI PDI, PC_QUANTC QEVENTOI, 
						P6__ABS ABSENT, PC_ABONO CABONO, P6_DESC DABONO, P6_EVENTO DESCFOL, PC_QTABONO QABONO 
				FROM %table:SPC% AS SPC 
					LEFT JOIN %table:SP9% AS SP9 ON P9_FILIAL = %xFilial:SP9% AND P9_IDPON <> '' AND PC_PD = P9_CODIGO AND SP9.%NotDel%
					LEFT JOIN %table:SP6% AS SP6 ON P6_FILIAL = %xFilial:SP6% AND (PC_ABONO = P6_CODIGO OR P6_CODIGO IS NULL) AND SP6.%NotDel%
				WHERE PC_FILIAL = %Exp:SRA->RA_FILIAL%
				  AND PC_MAT = %Exp:SRA->RA_MAT% 
				  AND PC_DATA BETWEEN %Exp:DtoS(FirstDay(StoD(cAnMePon+"01")))% AND %Exp:DtoS(LastDay(StoD(cAnMePon+"01")))%
				  AND SPC.%NotDel% 
			UNION ALL
				SELECT PH_FILIAL FILIAL, PH_MAT MAT, PH_DATA DATA, 
						P9_IDPON IDPON, PH_PD CEVENTO, P9_DESC DEVENTO, P9_BHORAS BHORAS, P9_CODFOL CODFOL, P9_TIPOCOD TIPO, P9_CLASEV CLASSE, PH_QUANTC QEVENTO, 
						PH_PDI PDI, PH_QUANTI QEVENTOI, 
						P6__ABS ABSENT, PH_ABONO CABONO, P6_DESC DABONO, P6_EVENTO DESCFOL, PH_QTABONO QABONO 
				FROM %table:SPH% AS SPH 
					LEFT JOIN %table:SP9% AS SP9 ON P9_FILIAL = %xFilial:SP9% AND P9_IDPON <> '' AND PH_PD = P9_CODIGO AND SP9.%NotDel% 
					LEFT JOIN %table:SP6% AS SP6 ON P6_FILIAL = %xFilial:SP6% AND (PH_ABONO = P6_CODIGO OR P6_CODIGO IS NULL) AND SP6.%NotDel% 
				WHERE PH_FILIAL = %Exp:SRA->RA_FILIAL%
				  AND PH_MAT    = %Exp:SRA->RA_MAT% 
				  AND PH_DATA BETWEEN %Exp:DtoS(FirstDay(StoD(cAnMePon+"01")))% AND %Exp:DtoS(LastDay(StoD(cAnMePon+"01")))%
				  AND SPH.%NotDel%
			ORDER BY FILIAL, MAT, DATA, CEVENTO 
		EndSql
		//--------------------------------------------------------------------------------------------------------------------------------------------------
		// PROCESSAMENTO
		//--------------------------------------------------------------------------------------------------------------------------------------------------
		DbSelectArea("QRY1")
		QRY1->(DbGoTop())
		Do While !QRY1->(EOF())
			IF QRY1->IDPON$("001A,026A")
				nHrPrev := SomaHoras(QRY1->QEVENTO,nHrPrev)
			ElseIf QRY1->IDPON$("005A,006A")
				nHrAuse := SomaHoras(QRY1->QEVENTO,nHrAuse)
			ElseIf QRY1->ABSENT == "S"
				nHrAuse := SubHoras(QRY1->QEVENTO,nHrAuse)
			EndIf
			QRY1->(DbSkip())
		EndDo
		DbSelectArea("QRY1")
		QRY1->(DbCloseArea())
		//--------------------------------------------------------------------------------------------------------------------------------------------------
		// GERA VERBA
		//--------------------------------------------------------------------------------------------------------------------------------------------------
		If nHrAuse <= SuperGetMv("AR_ABSHRS",,4.00)
			//fGeraVerba(SuperGetMv("AR_ABSPD",,"395"),FBUSCAACM(aCodFol[0031,1],,FirstDay(StoD(cAnMePon+"01")),LastDay(StoD(cAnMePon+"01")),"V",)*SuperGetMv("AR_ABSPERC",,0.05 ),,,,,,,,,.T.)
			fGeraVerba("395",FBUSCAACM(aCodFol[0031,1],,FirstDay(StoD(cAnMePon+"01")),LastDay(StoD(cAnMePon+"01")),"V",)*(SuperGetMv("AR_ABSPERC",,0.05 )/100),,,,,,,,,.T.)
		EndIf
	EndIf
EndIf

RestArea(cArea)

return