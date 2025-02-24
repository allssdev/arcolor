#INCLUDE "PONR010.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"
#DEFINE _CRFL CHR(13) + CHR(10)

/*/{Protheus.doc} PONCALR
@description  Considerando que a existência desse Ponto de Entrada fará com que o sistema desconsidere a função de Apuração de Refeições do Sistema todo o Tratamento de Refeições deverá ser feito pelo Ponto de Entrada. Segue abaixo Modelo para a confeção do Ponto de Entrada.
Rotina utilizada para calculo da refeição.
@author Livia Della Corte(ALL System Solutions)
@since 31/12/2022
@version 1.0
@type function
@see https://allss.com.br
@history 11/03/2023,  Diego Rodrigues (diego.rodrigues@allss.com.br) - Adequação da query para considerar apenas um registro da tabela de forma única
/*/ 

User Function PONCALR()

local cQry := ""
local nMaxMarc := val(getMaxMarc())
local aPonMes :=StrTokArr(AllTrim(GetMv("MV_PONMES")),"/")
local cPerIni := aPonMes[1]
local cPerFim := aPonMes[2]
local nX := 1
local cEvento := ""
local nEvento := 0
local cCodVerRef :=  SuperGetMV("PON_REFPD",,"499")  // Codigo Verba para tabela de SPB para evento de Refeição

Private aEvento:= StrTokArr(SuperGetMV("PON_REFEVT",,"001/330") ,"/") 


for nX:= 1 to len(aEvento)
	if nX == len(aEvento)
		cEvento+= aEvento[nX]
	else		
		cEvento+= aEvento[nX] +"' , '"
	end 
next


cAliasA	:= GetNextAlias() 
	cQry 	+= " 	 SELECT FILIAL, substring(DATA,1,6) PONMES" +_CRFL
	cQry 	+= " 	 	, MATRICULA " +_CRFL
	cQry 	+= " 	 	, SUM( CONTADOR)  EVENTOS " +_CRFL
	cQry 	+= " 	  	, ISNULL(PB_HORAS , 999)  PB_HORAS " +_CRFL
	cQry 	+= " 		, RA_CC " +_CRFL
	cQry 	+= " 	 	FROM (SELECT  FILIAL, DATA "+_CRFL
	cQry 	+= " 	        			, MATRICULA, SUM(TOTAL_HORAS) TOTAL_HORAS "+_CRFL
 	cQry 	+= " 	 	  				, SUM(LANCAMENTOS) LANCAMENTOS  "+_CRFL
	cQry 	+= " 	 			    	, CASE when  PC_QUANTC >= P9_BHNDE THEN 1 else 0 end CONTADOR  from ("+_CRFL
	/*	Adequação para remover os eventos duplicados.	
	For nX:= 1 to  nMaxMarc
		If nX <> 1
			cQry 	+= " 	UNION ALL " +_CRFL
		endIf
		cQry 	+= " 		 SELECT P8_FILIAL FILIAL , P8_DATA DATA, P8_MAT MATRICULA, Max(P8_HORA) - MIN(P8_HORA) TOTAL_HORAS, COUNT(*) LANCAMENTOS " +_CRFL
		cQry 	+= " 			FROM "+RetSqlName("SP8")+" SP8 " +_CRFL
		cQry 	+= " 			JOIN "+RetSqlName("SRA")+" SRA  on RA_FILIAL = P8_FILIAL AND RA_MAT= P8_MAT AND (RA_DEMISSA = '' OR  RA_DEMISSA <= P8_DATA) " +_CRFL  // and RA_MAT = '"+ cMatFunc + "'" 
		cQry 	+= " 			WHERE P8_TPMARCA IN ('"+cvaltochar(nX)+ "E','"+ cvaltochar(nX)+"S') AND SP8.D_E_L_E_T_ = '' AND SP8.P8_TPMCREP <> 'D' " +_CRFL
		cQry 	+= " 			GROUP BY P8_FILIAL, P8_DATA,  P8_MAT HAVING COUNT(*) =2 " +_CRFL
	next nX
	*/
	For nX:= 1 to  nMaxMarc
		If nX <> 1
			cQry 	+= " 	UNION ALL " +_CRFL
		endIf
		cQry 	+= " 		 SELECT SP8A.P8_FILIAL FILIAL , SP8A.P8_DATA DATA, SP8A.P8_MAT MATRICULA, Max(SP8A.H_MAX) - MIN(SP8A.H_MIN) TOTAL_HORAS, COUNT(*) LANCAMENTOS " +_CRFL
		cQry 	+= " 			FROM (SELECT DISTINCT P8_FILIAL, P8_DATA, P8_MAT, Max(P8_HORA) H_MAX, MIN(P8_HORA) H_MIN" +_CRFL
		cQry 	+= "			FROM "+RetSqlName("SP8")+" SP8 " +_CRFL	
		cQry 	+= " 			JOIN "+RetSqlName("SRA")+" SRA  on RA_FILIAL = P8_FILIAL AND RA_MAT= P8_MAT AND (RA_DEMISSA = '' OR  RA_DEMISSA <= P8_DATA) " +_CRFL  // and RA_MAT = '"+ cMatFunc + "'" 
		cQry 	+= " 			WHERE P8_TPMARCA IN ('"+cvaltochar(nX)+ "E','"+ cvaltochar(nX)+"S') AND SP8.D_E_L_E_T_ = '' AND SP8.P8_TPMCREP <> 'D' " +_CRFL
		cQry 	+= " 			GROUP BY P8_FILIAL, P8_DATA,  P8_MAT ) SP8A " +_CRFL
		cQry 	+= " 			GROUP BY SP8A.P8_FILIAL, SP8A.P8_DATA,  SP8A.P8_MAT HAVING COUNT(*) = 1 " +_CRFL
	next nX

	cQry 	+= " 		 ) AS PONTO   "+_CRFL
	cQry 	+= " 		 	JOIN "+RetSqlName("SPC")+" SPC  ON PC_FILIAL = FILIAL AND  PC_DATA = PONTO.DATA AND PC_MAT = PONTO.MATRICULA  AND SPC.D_E_L_E_T_ = '' " +_CRFL
//	cQry 	+= " 		 	JOIN "+RetSqlName("SPC")+" SPC  ON PC_FILIAL = FILIAL AND  PC_DATA = PONTO.DATA AND PC_MAT = PONTO.MATRICULA AND PC_PD in ('001','330') AND D_E_L_E_T_ = '' " +_CRFL
	cQry 	+= " 			JOIN "+RetSqlName("SP9")+" SP9 ON P9_FILIAL = '' AND   PC_PD = P9_CODIGO AND SP9.D_E_L_E_T_ = '' AND  PC_PD in ('" +  cEvento  + "' )   " +_CRFL

 
	cQry 	+= " 		GROUP BY FILIAL , DATA, MATRICULA,P9_BHNDE, PC_QUANTC " +_CRFL
	cQry 	+= " 		) AS  REFEICAO   " +_CRFL
	cQry 	+= " 			JOIN "+RetSqlName("SRA")+" SRA  on RA_MAT= MATRICULA " +_CRFL 	
	cQry 	+= " 			LEFT jOIN "+RetSqlName("SPB")+" SPB  ON  MATRICULA = PB_MAT AND SUBSTRING(PB_DATA,1,6) =  substring(DATA,1,6)  AND PB_PD IN ( '499','490') AND SPB.D_E_L_E_T_ ='' " + _CRFL
	cQry 	+= " 			group by  FILIAL, substring(DATA,1,6) , MATRICULA ,PB_HORAS 	, RA_CC "
	cQry 	+= " 			order by FILIAL , MATRICULA, substring(DATA,1,6) "


If Select( cAliasA ) > 0
   dbSelectArea( cAliasA )
   dbCloseArea()
EndIf 
cAliasA	:= GetNextAlias()   
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQry), cAliasA , .F., .T.)  


dbSelectArea(cAliasA) 
ProcRegua((cAliasA)->(LastRec()))
dbGoTop() 
//verificar periodo
While !(cAliasA)->(Eof()) 
	If (cAliasA)->PONMES == SubStr(cPerIni, 1, 6) .and. (cAliasA)->PONMES == SubStr(cPerFim, 1, 6)
				
			dbSelectArea("SPB") //é dessa forma para refazer a SPB sempre que executado calculo mensal
			If	dbSeek(xFilial("SPB") + (cAliasA)->MATRICULA +cCodVerRef)			
				RecLock("SPB", .F.)
					dbDelete()
				MsUnlock()  
			EndIf

			If	!dbSeek(xFilial("SPB") + (cAliasA)->MATRICULA +cCodVerRef)				
				RecLock("SPB", .T.)
				SPB->PB_FILIAL	:= (cAliasA)->FILIAL 
				SPB->PB_MAT		:= (cAliasA)->MATRICULA
				SPB->PB_PD		:= cCodVerRef
				SPB->PB_TIPO1	:= "D"
				SPB->PB_HORAS	:= (cAliasA)->EVENTOS
				SPB->PB_DATA	:= stod((cAliasA)->PONMES  +"01")
				SPB->PB_CC		:= (cAliasA)->RA_CC
				SPB->PB_TIPO2	:= "G"
				MsUnlock()	
			endif
	ElseIf SubStr(cPerIni, 5, 2) == "12" .and. Substr((cAliasA)->PONMES,5,2) == "12"
		If (cAliasA)->PONMES == SubStr(cPerIni, 1, 6) 
				
			dbSelectArea("SPB") //é dessa forma para refazer a SPB sempre que executado calculo mensal
			If	dbSeek(xFilial("SPB") + (cAliasA)->MATRICULA +cCodVerRef)			
				RecLock("SPB", .F.)
					dbDelete()
				MsUnlock()  
			EndIf
			nEvento := (cAliasA)->EVENTOS

		/*elseif (cAliasA)->PONMES == SubStr(cPerFim, 1, 6)
				
			dbSelectArea("SPB") //é dessa forma para refazer a SPB sempre que executado calculo mensal
			If	dbSeek(xFilial("SPB") + (cAliasA)->MATRICULA +cCodVerRef)			
				RecLock("SPB", .F.)
					dbDelete()
				MsUnlock()  
			EndIf

			If	!dbSeek(xFilial("SPB") + (cAliasA)->MATRICULA +cCodVerRef)				
				RecLock("SPB", .T.)
				SPB->PB_FILIAL	:= (cAliasA)->FILIAL 
				SPB->PB_MAT		:= (cAliasA)->MATRICULA
				SPB->PB_PD		:= cCodVerRef
				SPB->PB_TIPO1	:= "D"
				SPB->PB_HORAS	:= (cAliasA)->EVENTOS + nEvento
				SPB->PB_DATA	:= stod((cAliasA)->PONMES  +"01")
				SPB->PB_CC		:= (cAliasA)->RA_CC
				SPB->PB_TIPO2	:= "G"
				MsUnlock()	
			endif*/
		EndIf 
	ElseIf  (cAliasA)->PONMES == SubStr(cPerFim, 1, 6) 

			dbSelectArea("SPB") //é dessa forma para refazer a SPB sempre que executado calculo mensal
			If	dbSeek(xFilial("SPB") + (cAliasA)->MATRICULA +cCodVerRef)			
				RecLock("SPB", .F.)
					dbDelete()
				MsUnlock()  
			EndIf

			If	!dbSeek(xFilial("SPB") + (cAliasA)->MATRICULA +cCodVerRef)				
				RecLock("SPB", .T.)
				SPB->PB_FILIAL	:= (cAliasA)->FILIAL 
				SPB->PB_MAT		:= (cAliasA)->MATRICULA
				SPB->PB_PD		:= cCodVerRef
				SPB->PB_TIPO1	:= "D"
				SPB->PB_HORAS	:= (cAliasA)->EVENTOS+nEvento
				SPB->PB_DATA	:= stod((cAliasA)->PONMES  +"01")
				SPB->PB_CC		:= (cAliasA)->RA_CC
				SPB->PB_TIPO2	:= "G"
				MsUnlock()	
			endif
	Else
		MsgAlert("Período divergente para calculo de Refeições!","Atenção")
		exit
	endIf
	 (cAliasA)->(dbSkip())
endDo

If Select( cAliasA ) > 0
   dbSelectArea( cAliasA )
   dbCloseArea()
EndIf   


Return()

static function getMaxMarc()

local cQry 		:= ""
local cAliasB	:= GetNextAlias() 
local nMaxMar	:= 1
If Select( cAliasB ) > 0
   dbSelectArea( cAliasB )
   dbCloseArea()
EndIf   

cQry	:="SELECT   MAX(substring(P8_TPMARCA,1,1)) MAXMARC FROM " +RetSqlName("SP8")+" SP8  WHERE D_E_L_E_T_ = '' " 
 
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQry), cAliasB , .F., .T.)  
dbSelectArea(cAliasB) 
ProcRegua((cAliasB)->(LastRec()))
dbGoTop()
nMaxMar:= (cAliasB)->MAXMARC

If Select( cAliasB ) > 0
   dbSelectArea( cAliasB )
   dbCloseArea()
EndIf   


return(nMaxMar)
