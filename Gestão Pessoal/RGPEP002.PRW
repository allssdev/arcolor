#include "rwmake.ch"
#include "protheus.ch"
/*/{Protheus.doc} RGPEP002
Rotina utilizada no Roteiro de cálculo FOL, para o cálculo do DSR sobre Horas Extras e Adicionais, para os funcionários que apresentaram afastamento no decorrer do mês, uma vez que o sistema considera o dia 31 do mês como Útil, mas a Arcolor, mesmo para o cálculo destes DSRs, não considerar como sendo Útil e nem como DSR.
@obs Rotina de cálculo do DSR sobre Horas Extras e Adicionais anteriormente feita pelo consultor Valdemir Miranda descontinuada pois os cálculos propostos passaram a ser feitos corretamente pelo padrão do sistema, a não ser nos casos de funcionários que apresentaram afastamento. Sendo assim, a rotina precisou ser refeita. Foi inserido o parâmetro customizado "MV_XATVDSR" que permite .T. = Ativar o uso desta customização, ou .T. = utilizar-se o padrão do Protheus.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 07/03/2019
@version P12.1.17 - rev.002
@type functiona
@history 21/09/2020, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Ajuste do tamanho do mês para o calculo do DSR sobre horas extras
@history 24/09/2020, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Ajuste do tamanho do mês para o calculo do DSR proporcional a admissão
@history 17/02/2021, Diego Rodrigues , Ajuste na condição de dias uteis de forma a atender a alteração para 30 dias no calculo do DSR
@history 01/08/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Alteração da regra de preenchimento da referencia da verba para correto comportamento do sistema em suas demais rotinas
@see https://allss.com.br
/*/
user function RGPEP002()
	local   _aSavArea := GetArea()
	local   _aSavSR8  := SR8->(GetArea())
	local   _aSavSRA  := SRA->(GetArea())
	local   _aSavSRV  := SRV->(GetArea())
	local   _aSavSRC  := SRC->(GetArea())
	local   _aSavRGB  := RGB->(GetArea())
	local   _aSavRCF  := RCF->(GetArea())
	local   _aSavRCG  := RCG->(GetArea())
	local   _aSavRCA  := RCA->(GetArea())
	local   _aSavSRR  := SRR->(GetArea())
	local   _aSavSRF  := SRF->(GetArea())
	local   _aPdBkp   := IIF(type("aPd")=="A",aClone(aPd),{})
//	local   _aMnemos  := {}
	local   _aPdTmp   := {}
	local   _lAtiva   := SuperGetMv("MV_XATVDSR",,.F.)
	local   _lD2501   := AllTrim(SuperGetMv("MV_DIA2501",,"N"))<>"N"			//Paga Licença Remunerada para os dias 25/12, 01/01, etc.?
	local   _nQtLRem  := IIF(!_lD2501, 0, fBuscaPd(FGETCODFOL("0103"),"H"))		//Soma a quantia de Licença remunerada computada
	local   _nVlLRem  := IIF(!_lD2501, 0, fBuscaPd(FGETCODFOL("0103"),"V"))		//Soma o valor de Licença remunerada computada
	local   _x        := 0
	local   _nVlHE    := 0
	local   _nDUteis  := 0
	local   _nDDSR    := 0
	local   _nDAfast  := 0
//	local   _nPos     := 0
//	local   _DEDATA   := mv_par03+"01"
//	local   _ATDATA   := LastDay(_ATDATA)
	local   _PERIODO  := cPeriodo			//mv_par03
	local   _cTab     := ""
	local   _cTab2    := ""
	local   _cPd      := ""
	local   _cPdDSRA  := ""

	private _cRotina  := "RGPEP002"

	//SetMnemonicos( xFilial( "RCA" ) , @_aMnemos , .T. )
	//_nPos := aScan(_aMnemos, {|x| AllTrim(x[1]) == 'P_DIASMES'})		//_nPos := aScan(_aMnemos, {|x| AllTrim(x[1]) == 'P_QTDIAMES'})
	if _lAtiva .AND. !empty(_PERIODO) //.AND. AllTrim(SuperGetMv("MV_DIASMES",,""))=="N" .AND. _nPos > 0 .AND. AllTrim(_aMnemos[_nPos][03]) == '"N"'		//Mnemônico 'P_DIASMES' e parâmetro 'MV_DIASMES' apontando para o mês com 30 dias e NÃƒO para o numero de dias conforme o tamanho do mes.
		//_nPos   := aScan(_aMnemos, {|x| x[1] == 'P_CPROPDSR'})
		if .T.	//_nPos > 0 .AND. !"0"$SubStr(_aMnemos[_nPos][03],2,1)				//Calculo proporcional do DSR
			//aPd   := aClone(_aPdBkp)
			_cTab := GetNextAlias()
			//Busco os Dias Úteis e Dias de DSR da Matrícula, sem considerar o dia 31 como dia Útil
			//INICIO CUSTOM. ALL - 08/04/2019 - Anderson Coelho - Tratamento específico para funcionários que tiveram licença remunerada, mas e afastamentos, de maneira que a somatória dos dias úteis + dias de DSR + dias de afastamento do mês ultrapassam o número de dias reais do mês
				//A query abaixo foi alterada para que o dia 31 fosse filtrado, para efeito de dias úteis e/ou dsr, mas não para o cômputo dos dias de afastamento/mês.
				/*
				BeginSql Alias _cTab
					SELECT 	SUM(CASE WHEN RCG_TIPDIA IN ('1','2') AND R8_PER IS NULL THEN 1 ELSE 0 END) UTEIS
						  , SUM(CASE WHEN RCG_TIPDIA IN ('3','4') AND R8_PER IS NULL THEN 1 ELSE 0 END) DSR
						  , SUM(CASE WHEN R8_PER IS NULL                             THEN 0 ELSE 1 END) AFASTAMENTO
					FROM %table:RCG% RCG (NOLOCK)
						INNER JOIN      %table:RCF% RCF (NOLOCK) ON RCF.RCF_FILIAL   = %xFilial:RCF%
														   AND RCF.RCF_PER      = RCG.RCG_PER
														   AND RCF.RCF_PROCES   = RCG.RCG_PROCES
														   AND RCF.%NotDel%
						INNER JOIN      %table:SRA% SRA (NOLOCK) ON SRA.RA_FILIAL    = %xFilial:SRA%
														   AND SRA.RA_MAT       = %Exp:SRA->RA_MAT%
														   AND SRA.RA_ADMISSA  <= RCG.RCG_DIAMES
														   AND (SRA.RA_DEMISSA  = '' OR SRA.RA_DEMISSA  > RCG.RCG_DIAMES)
														   AND SRA.%NotDel%
						LEFT OUTER JOIN %table:SR8% SR8 (NOLOCK) ON SR8.R8_FILIAL    = %xFilial:SR8%
														   AND SR8.R8_MAT       = SRA.RA_MAT
														   AND RCG.RCG_DIAMES  BETWEEN SR8.R8_DATAINI AND SR8.R8_DATAFIM
														   AND SR8.%NotDel% 
					WHERE RCG.RCG_FILIAL = %xFilial:RCG%
					  AND RCG.RCG_PROCES = %Exp:SRA->RA_PROCES%
					//AND RCG.RCG_DIAMES BETWEEN %Exp:DTOS(_DEDATA)% AND %Exp:DTOS(_ATDATA)%
					  AND RCG.RCG_PER    = %Exp:_PERIODO%
					  AND SUBSTRING(RCG.RCG_DIAMES,7,2) <> '31'							//DESCONTIDERO O DIA 31 como sendo Útil, quando for o caso
					  AND RCG.%NotDel%
				EndSql
				*/
				BeginSql Alias _cTab
					//INICIO - ALLSS - 21/09/2020 - Rodrigo Telecio - Percebemos que houve uma alteração quanto ao tamanho do mês por parte do DJ para calculo do DSR sobre horas extras - de 30 para 31 dias (variando assim de acordo com o tamanho do mês)
					//SELECT 	SUM(CASE WHEN RCG_TIPDIA IN ('1','2') AND R8_PER IS NULL AND SUBSTRING(RCG.RCG_DIAMES,7,2) <> '31' THEN 1 ELSE 0 END) UTEIS		//DIAS ÚTEIS  - DESCONTIDERO O DIA 31 como sendo Útil, quando for o caso
					SELECT 	SUM(CASE WHEN RCG_TIPDIA IN ('1','2') AND R8_PER IS NULL THEN 1 ELSE 0 END) UTEIS													//DIAS ÚTEIS  - DESCONTIDERO O DIA 31 como sendo Útil, quando for o caso
						  //, SUM(CASE WHEN RCG_TIPDIA IN ('3','4') AND R8_PER IS NULL AND SUBSTRING(RCG.RCG_DIAMES,7,2) <> '31' THEN 1 ELSE 0 END) DSR			//DIAS DE DSR - DESCONTIDERO O DIA 31 como sendo Útil, quando for o caso
						  , SUM(CASE WHEN RCG_TIPDIA IN ('3','4') AND R8_PER IS NULL THEN 1 ELSE 0 END) DSR														//DIAS DE DSR - DESCONTIDERO O DIA 31 como sendo Útil, quando for o caso
				    //FIM - ALLSS - 21/09/2020 - Rodrigo Telecio - Percebemos que houve uma alteração quanto ao tamanho do mês por parte do DJ para calculo do DSR sobre horas extras - de 30 para 31 dias (variando assim de acordo com o tamanho do mês)						  
						  , SUM(CASE WHEN R8_PER IS NULL                                                                       THEN 0 ELSE 1 END) AFAST			//DIAS DE AFASTAMENTO
						  , MAX(CASE WHEN SUBSTRING(RCG.RCG_DIAMES,5,2) = '02' THEN (SUBSTRING(RCG.RCG_DIAMES,7,2)) + 2 ELSE (SUBSTRING(RCG.RCG_DIAMES,7,2)) - 1 END ) DIAS_MES 																					//DIAS TOTAIS (TAMANHO) DO MÊS
					FROM %table:RCG% RCG (NOLOCK)
						INNER JOIN      %table:RCF% RCF (NOLOCK) ON RCF.RCF_FILIAL  = %xFilial:RCF%
															   AND RCF.RCF_PER      = RCG.RCG_PER
															   AND RCF.RCF_PROCES   = RCG.RCG_PROCES
															   AND RCF.%NotDel%
						INNER JOIN      %table:SRA% SRA (NOLOCK) ON SRA.RA_FILIAL   = %xFilial:SRA%
															   AND SRA.RA_MAT       = %Exp:SRA->RA_MAT%
															   AND SRA.RA_ADMISSA  <= RCG.RCG_DIAMES
															   AND (SRA.RA_DEMISSA  = '' OR SRA.RA_DEMISSA  > RCG.RCG_DIAMES)
															   AND SRA.%NotDel%
						LEFT OUTER JOIN %table:SR8% SR8 (NOLOCK) ON SR8.R8_FILIAL   = %xFilial:SR8%
															   AND SR8.R8_MAT       = SRA.RA_MAT
															   AND RCG.RCG_DIAMES  BETWEEN SR8.R8_DATAINI AND SR8.R8_DATAFIM
															   AND SR8.%NotDel% 
					WHERE RCG.RCG_FILIAL = %xFilial:RCG%
					  AND RCG.RCG_PROCES = %Exp:SRA->RA_PROCES%
					//AND RCG.RCG_DIAMES BETWEEN %Exp:DTOS(_DEDATA)% AND %Exp:DTOS(_ATDATA)%
					  AND RCG.RCG_PER    = %Exp:_PERIODO%
					//AND SUBSTRING(RCG.RCG_DIAMES,7,2) <> '31'							//DESCONTIDERO O DIA 31 como sendo Útil, quando for o caso
					  AND RCG.%NotDel%
				EndSql
				if __cUserId == "000000"
					MemoWrite(GetTempPath()+_cRotina+"_QRY_001.txt",GetLastQuery()[02])
				endif
			//FIM CUSTOM. ALL - 08/04/2019 - Anderson Coelho - Tratamento específico para funcionários que tiveram licença remunerada, mas e afastamentos, de maneira que a somatória dos dias úteis + dias de DSR + dias de afastamento do mês ultrapassam o número de dias reais do mês
			dbSelectArea(_cTab)
			if !(_cTab)->(EOF())
				/*
				if (_cTab)->AFAST == 0										//Se a matrícula não apresentou afastamento no período, saio da rotina, para que o padrão do sistema seja obedecido.
					(_cTab)->(dbCloseArea())
					RestArea(_aSavSRR)
					RestArea(_aSavSRF)
					RestArea(_aSavSR8)
					RestArea(_aSavSRA)
					RestArea(_aSavSRV)
					RestArea(_aSavSRC)
					RestArea(_aSavRGB)
					RestArea(_aSavRCF)
					RestArea(_aSavRCG)
					RestArea(_aSavRCA)
					RestArea(_aSavArea)
					return
				endif
				*/
				//INICIO - ALLSS - 17/02/2021 - Diego Rodrigues - Ajuste na condição de dias uteis de forma a atender a alteração para 30 dias no calculo do DSR
				_nDUteis := ((_cTab)->DIAS_MES) - ((_cTab)->DSR) //(_cTab)->UTEIS	
				//FIM										//Dias Úteis no mês
				_nDDSR   := (_cTab)->DSR											//Dias de DSR no mês
				//INICIO - ALLSS - 24/09/2020 - Rodrigo Telecio - Ajuste do tamanho do mês para o calculo do DSR proporcional a admissão			
				if SubStr(AllTrim(_PERIODO),5,2) == "02"											
					if (_nDUteis+_nDDSR) < 30
						_nDUteis := 30 -_nDDSR
					endif
				endif
				//FIM - ALLSS - 24/09/2020 - Rodrigo Telecio - Ajuste do tamanho do mês para o calculo do DSR proporcional a admissão		
				//INICIO CUSTOM. ALL - 08/04/2019 - Anderson Coelho - Tratamento específico para funcionários que tiveram licença remunerada, mas e afastamentos, de maneira que a somatória dos dias úteis + dias de DSR + dias de afastamento do mês ultrapassam o número de dias reais do mês
					_nDAfast := (_cTab)->AFAST										//Dias de Afastamento no mês
					_nDMes   := ((_cTab)->DIAS_MES)								//Número máximo de dias do mês
					if (_nDMes+_nDAfast) < 30
						_nDMes := 30-_nDAfast
					endif
				//FIM CUSTOM. ALL - 08/04/2019 - Anderson Coelho - Tratamento específico para funcionários que tiveram licença remunerada, mas e afastamentos, de maneira que a somatória dos dias úteis + dias de DSR + dias de afastamento do mês ultrapassam o número de dias reais do mês
			endif
			(_cTab)->(dbCloseArea())
			if _lD2501																//Se houver Licença Remunerada, soma o dia para composição dos dias úteis, para critério de pagamento do DSR sobre Horas Extras
				if _nQtLRem > 0														//Pego pelos dias de Licenca Remunerada
					_nDUteis += _nQtLRem											//Somo o número de dias de Licença Remunerada nos Dias Úteis
					if _nDAfast > 0
						_nDAfast -= _nQtLRem										//Deduzo o dia de licença remunerada dos dias de afastamento (quando for o caso), pois é considerado como "dia útil.
					endif
				elseif _nVlLRem > 0													//Senao, considero o valor e, se maior que zero, considero 1 dia
					_nDUteis += 1													//Somo 1 dia de Licença Remunerada nos Dias Úteis
					if _nDAfast > 0
						_nDAfast -= 1												//Deduzo o dia de licença remunerada dos dias de afastamento (quando for o caso), pois é considerado como "dia útil.
					endif
				endif
				//INICIO CUSTOM. ALL - 08/04/2019 - Anderson Coelho - Tratamento específico para funcionários que tiveram licença remunerada, mas e afastamentos, de maneira que a somatória dos dias úteis + dias de DSR + dias de afastamento do mês ultrapassam o número de dias reais do mês
					if (_nDUteis+_nDDSR) > 0 .AND. (_nDUteis+_nDDSR+_nDAfast) > _nDMes
						_nDUteis := _nDUteis - ((_nDUteis+_nDDSR+_nDAfast) - _nDMes)
					endif
				//FIM CUSTOM. ALL - 08/04/2019 - Anderson Coelho - Tratamento específico para funcionários que tiveram licença remunerada, mas e afastamentos, de maneira que a somatória dos dias úteis + dias de DSR + dias de afastamento do mês ultrapassam o número de dias reais do mês
			endif
			_cTab := GetNextAlias()
			_cPd  := ""
			//Busco as Verbas de Horas Extras que poderao gerar DSR sobre elas
			BeginSql Alias _cTab
				SELECT RV_COD
				FROM %table:SRV% SRV (NOLOCK) 
				WHERE RV_FILIAL  = %xFilial:SRV% 
				  AND RV_TIPOCOD = '1' 
				  AND RV_HE      = 'S' 
				  AND RV_DSRHE   = 'S' 
				  AND RV_CODDSR  = ''
				  AND SRV.%NotDel% 
				ORDER BY RV_COD
			EndSql
			if __cUserId == "000000"
				MemoWrite(GetTempPath()+_cRotina+"_QRY_002.txt",GetLastQuery()[02])
			endif
			dbSelectArea(_cTab)
			while !(_cTab)->(EOF())
				if !empty(_cPd)
					_cPd += ","
				endif
				_cPd += (_cTab)->RV_COD											//Concateno as verbas de Horas Extras em uma variável para posterior utilizaÃ§Ã£o/soma
				dbSelectArea(_cTab)
				(_cTab)->(dbSkip())
			enddo
			(_cTab)->(dbCloseArea())
			if !empty(_cPd)														//So continuo se encontrar alguma verba de hora extra
				_nVlHE := 0
				if ','$_cPd
					_aPdTmp := Separa(_cPd,",")
					for _x  := 1 to len(_aPdTmp)
						_nVlHE += fBuscaPD(_aPdTmp[_x],"V")						//Busco os Valores das Horas Extras que deverao gerar DSR
					next aPd
				else
					_nVlHE  := fBuscaPD(_cPd,"V")								//Busco os Valores das Horas Extras que deverao gerar DSR
				endif
				if _nVlHE > 0													//So continuo se tiver valor de Hora Extra
					if _nDUteis > 0												//So continuo se tiver Dias Uteis
						_cTab := GetNextAlias()
						BeginSql Alias _cTab
							SELECT COUNT(*) REG
							FROM %table:RGB% RGB (NOLOCK)
							WHERE RGB.RGB_FILIAL = %xFilial:RGB% 
							  AND RGB.RGB_MAT    = %Exp:SRA->RA_MAT%
							  AND RGB.RGB_PERIOD = %Exp:mv_par03%
							  AND RGB.RGB_PD     = %Exp:FGETCODFOL("0035")%
							  AND RGB.RGB_TIPO2  = %Exp:"I"%
							  AND RGB.%NotDel%
						EndSql
						if __cUserId == "000000"
							MemoWrite(GetTempPath()+_cRotina+"_QRY_003.txt",GetLastQuery()[02])
						endif
						dbSelectArea(_cTab)
						if (_cTab)->REG == 0									//Verifico se há lançamento manual de DSR sobre Horas Extras. Já gero o novo cálculo, se não houver lançamento manual desta verba na RGB.
							// *** Grava DSR sobre Horas Extras *** //
							//fDelPd(FGETCODFOL("0035"))
							if len(aPd) > 0 .AND. Flocaliapd(FGETCODFOL("0035")) > 0 .AND. aPd[FlocaliAPD(FGETCODFOL("0035")),9] <> "D"
								//aPd[FlocaliAPD(FGETCODFOL("0035")),9] := "D"
								//*************************************************************************************************************
								// INICIO
								// ARCOLOR - Alteração da regra de preenchimento da referencia da verba para correto comportamento do sistema
								// em suas demais rotinas
								// RODRIGO TELECIO EM 01/08/2022
								//*************************************************************************************************************
								//aPd[FlocaliAPD(FGETCODFOL("0035")),4] := _nDDSR
								aPd[FlocaliAPD(FGETCODFOL("0035")),4] := (Round((_nVlHE / _nDUteis * _nDDSR),TamSx3("RC_VALOR")[02]) / SalHora)
								// FIM								
								//*************************************************************************************************************
								aPd[FlocaliAPD(FGETCODFOL("0035")),5] := Round((_nVlHE / _nDUteis * _nDDSR),TamSx3("RC_VALOR")[02])
							else
								//*************************************************************************************************************
								// INICIO
								// ARCOLOR - Alteração da regra de preenchimento da referencia da verba para correto comportamento do sistema
								// em suas demais rotinas
								// RODRIGO TELECIO EM 01/08/2022
								//*************************************************************************************************************
								/*							
								fGeraVerba(	FGETCODFOL("0035") ;
											, Round((_nVlHE/_nDUteis*_nDDSR),TamSx3("RC_VALOR")[02]) ;
											, _nDDSR ;
											, ;
											, ;
											, ;
											, ;
											, ;
											, ;
											, ;
											,.T.)
								*/
								fGeraVerba(	FGETCODFOL("0035") 															,;
											Round((_nVlHE/_nDUteis*_nDDSR),TamSx3("RC_VALOR")[02]) 						,;
											(Round((_nVlHE/_nDUteis*_nDDSR),TamSx3("RC_VALOR")[02]) / SalHora) 			,;
																														,;
																														,;
																														,;
																														,;
																														,;
																														,;
																														,;
											.T.																			)
								// FIM								
								//*************************************************************************************************************											
							endif
						endif
						(_cTab)->(dbCloseArea())
					elseif fBuscaPd(FGETCODFOL("0035")) <> 0					//Deleto a verba de DSR sobre Horas Extras, caso não existam Horas Extras e/ou Dias Úteis no mês
						fDelPd(FGETCODFOL("0035"))
					endif
				endif
			endif
			//DSR sobre verbas definidas no campo RV_CODDSR (Adicionais)
			_cTab := GetNextAlias()
			//Busco as Verbas de Adicionais que poderao gerar DSR sobre elas
			BeginSql Alias _cTab
				SELECT RV_CODDSR, RV_COD
				FROM %table:SRV% SRV (NOLOCK) 
				WHERE RV_FILIAL  = %xFilial:SRV% 
				  AND RV_TIPOCOD = '1' 
				  AND RV_CODDSR <> ''
				  AND SRV.%NotDel% 
				ORDER BY RV_CODDSR, RV_COD
			EndSql
			if __cUserId == "000000"
				MemoWrite(GetTempPath()+_cRotina+"_QRY_004.txt",GetLastQuery()[02])
			endif
			dbSelectArea(_cTab)
			while !(_cTab)->(EOF())
				_cPd     := ""
				_cPdDSRA := (_cTab)->RV_CODDSR
				while !(_cTab)->(EOF()) .AND. _cPdDSRA == (_cTab)->RV_CODDSR
					if !empty(_cPd)
						_cPd += ","
					endif
					_cPd += (_cTab)->RV_COD											//Concateno as verbas de Horas Extras em uma variável para posterior utilizaÃ§Ã£o/soma
					dbSelectArea(_cTab)
					(_cTab)->(dbSkip())
				enddo
				if !empty(_cPd)														//So continuo se encontrar alguma verba de adicional
					_nVlHE := 0
					if ','$_cPd
						_aPdTmp := Separa(_cPd,",")
						for _x  := 1 to len(_aPdTmp)
							_nVlHE += fBuscaPD(_aPdTmp[_x],"V")						//Busco os Valores dos Adicionais que deverao gerar DSR
						next
					else
						_nVlHE  := fBuscaPD(_cPd,"V")								//Busco os Valores dos Adicionais que deverao gerar DSR
					endif
					if _nVlHE > 0													//So continuo se tiver valor de Adicionais
						if _nDUteis > 0												//So continuo se tiver Dias Uteis
							_cTab2 := GetNextAlias()
							BeginSql Alias _cTab2
								SELECT COUNT(*) REG
								FROM %table:RGB% RGB (NOLOCK)
								WHERE RGB.RGB_FILIAL = %xFilial:RGB% 
								  AND RGB.RGB_MAT    = %Exp:SRA->RA_MAT%
								  AND RGB.RGB_PERIOD = %Exp:mv_par03%
								  AND RGB.RGB_PD     = %Exp:_cPdDSRA%
								  AND RGB.RGB_TIPO2  = %Exp:"I"%
								  AND RGB.%NotDel%
							EndSql
							if __cUserId == "000000"
								MemoWrite(GetTempPath()+_cRotina+"_QRY_005.txt",GetLastQuery()[02])
							endif
							dbSelectArea(_cTab2)
							if (_cTab2)->REG == 0										//Verifico se há lançamento manual de DSR sobre Adicionais. Já gero o novo cálculo, se não houver lançamento manual desta verba na RGB.
								// *** Grava DSR sobre Adicionais *** //
								//fDelPd(_cPdDSRA)
								if len(aPd) > 0 .AND. Flocaliapd(_cPdDSRA) > 0 .AND. aPd[FlocaliAPD(_cPdDSRA),9] <> "D"
									//aPd[FlocaliAPD(_cPdDSRA),9] := "D"
									//*************************************************************************************************************
									// INICIO
									// ARCOLOR - Alteração da regra de preenchimento da referencia da verba para correto comportamento do sistema
									// em suas demais rotinas
									// RODRIGO TELECIO EM 01/08/2022
									//*************************************************************************************************************
									//aPd[FlocaliAPD(_cPdDSRA),4] := _nDDSR
									aPd[FlocaliAPD(_cPdDSRA),4] := (Round((_nVlHE / _nDUteis * _nDDSR),TamSx3("RC_VALOR")[02]) / SalHora)
									// FIM								
									//*************************************************************************************************************
									aPd[FlocaliAPD(_cPdDSRA),5] := Round((_nVlHE / _nDUteis * _nDDSR),TamSx3("RC_VALOR")[02])
								else
									//*************************************************************************************************************
									// INICIO
									// ARCOLOR - Alteração da regra de preenchimento da referencia da verba para correto comportamento do sistema
									// em suas demais rotinas
									// RODRIGO TELECIO EM 01/08/2022
									//*************************************************************************************************************
									/*
									fGeraVerba(	_cPdDSRA ;
												, Round((_nVlHE/_nDUteis*_nDDSR),TamSx3("RC_VALOR")[02]) ;
												, _nDDSR ;
												, ;
												, ;
												, ;
												, ;
												, ;
												, ;
												, ;
												,.T.)
									*/
									fGeraVerba(	_cPdDSRA 																	,;
												Round((_nVlHE / _nDUteis * _nDDSR),TamSx3("RC_VALOR")[02]) 					,;
												(Round((_nVlHE / _nDUteis * _nDDSR),TamSx3("RC_VALOR")[02]) / SalHora) 		,;
																															,;
																															,;
																															,;
																															,;
																															,;
																															,;
																															,;
												.T.																			)
									// FIM								
									//*************************************************************************************************************
								endif
							endif
							(_cTab2)->(dbCloseArea())
						elseif fBuscaPd(_cPdDSRA) <> 0							//Deleto a verba de DSR sobre Horas Extras, caso não existam Horas Extras e/ou Dias Úteis no mês
							fDelPd(_cPdDSRA)
						endif
					endif
				endif
			enddo
			(_cTab)->(dbCloseArea())
		else																	//Nao proporcionaliza o calculo do DSR
			//SEM ALTERAÇÕES NO PADRÃO DO PROTHEUS
			aPd   := aClone(_aPdBkp)
		endif
	else
		aPd   := aClone(_aPdBkp)
	endif
	RestArea(_aSavSRR)
	RestArea(_aSavSRF)
	RestArea(_aSavSR8)
	RestArea(_aSavSRA)
	RestArea(_aSavSRV)
	RestArea(_aSavSRC)
	RestArea(_aSavRGB)
	RestArea(_aSavRCF)
	RestArea(_aSavRCG)
	RestArea(_aSavRCA)
	RestArea(_aSavArea)
return
/*
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||          |          |       |                       |      |          |||
|||Programa  |RGPEP002  | Autor | Valdemir Miranda      | Data |27/06/2018|||
|||          |          |       |                       |      |          |||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||DescriÃ§Ã£o | FunÃ§Ã£o Utilizada para Calculo de DSR sobre Horas Extras    |||  
|||          |                                                            ||| 
|||          |                                                            |||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
*/
/*
static function fontedesativado()
// *** Inicializa Variaveis de memÃ³ria *** //  
Private nDiasUt01  :=0.00 
Private nDiasDSR01 :=0.00
Private nVerba029  := 0.00
Private nVerba080  :=fbuscapd("080")  // *** Hora Extra 80 %
Private nVerba082  :=fbuscapd("082")  // *** Hora Extra 130 % 
Private nVerba019  :=fbuscapd("019")  // *** Adicional Noturno 
Private nVerba109  :=fbuscapd("109")  // *** Licença Remunerada

Private cProcesso  :=SRA->RA_PROCES
Private cRC_PERIODO:=""
Private cRC_ROTEIR :=""
Private cRC_SEMANA :=""  
Private cRCH_PER   :=RCH->RCH_PER
Private cRA_PROCESS:=SRA->RA_PROCES 

// *** Private CTESTE:=mv_par01+" "+mv_par02+" "+mv_par03+" "+mv_par04   

cMeses:="01/03/05/07/08/10/12"

// *** Pega Dados da Tabela RCF *** //
dbselectarea("RCF")
DBSETORDER(1)
SET FILTER TO RCF_PER = mv_par03 .AND. RCF_PROCES = mv_par01 .and. RCF_ANO+RCF_MES = mv_par03
DBGOTOP()

cRCH_PER    := RCF->RCF_PER
cRA_PROCESS := RCF->RCF_PROCES 

if .not. eof()  
	//Colho o número de dias Ãºteis do cadastro de perÃ­odos
		nDiasUt01  := RCF->RCF_DUTEIS			//(RCF_DCALCM - RCF->RCF_DIADSR)   // *** RCF->RCF_DUTEIS
		nDiasDSR01 := RCF->RCF_DIADSR
	//Quando o mes tiver 31 dias subtraio 1, sendo: quando houver a verba "109" (Licença Remunerada), do DSR  | Quando contrÃ¡rio, reduzo os dias Ãºteis
		if SubStr(mv_par03,05,02) $ cMeses
			if nVerba109 > 0
			//	nDiasUt01 += 1
				nDiasDSR01 -= 1
			else
				nDiasUt01 -= 1
			endif
		endif
endif  
SET FILTER TO

// *** Calculo de DSR sobre Bonus *** // 
//nDiasUt01:=30 - nDiasDSR01  

// ***
if  nDiasUt01 > 0.00 .AND. nDiasDSR01> 0.00 

   if nVerba080 > 0.00 .or. nVerba082 > 0.00 .or. nVerba019 > 0.00

      // *** Calcula DSR sobre Bonus *** //   
      nVerba029:= ( ( (nVerba080+nVerba082) / nDiasUt01) * nDiasDSR01)  
      nVBadcNot:= ((nVerba019 / nDiasUt01) * nDiasDSR01)  
      
      //alert("( ( ("+str(nVerba080)+" + "+str(nVerba082)+" )  / "+str(nDiasUt01)+" ) * "+str(nDiasDSR01)+" ) = "+str(nVerba029))
      
      // *** Grava DSR sobre Horas Extras *** //
      cProcessa:=RGPEVERB("029")
      if nVerba029 > 0.00 .and. cProcessa <> "I"
         if Flocaliapd("029")>0
            APD[FlocaliAPD("029"),9]:="D"
         endif
         Fgeraverba("029",nVerba029 ,nDiasDSR01,,,"V",,0,,dData_Pgto,.t.)  
      endif 
      
      // *** Grava DSR sobre Adicional Noturno *** // 
      cProcessa:=RGPEVERB("031")
      if nVBadcNot > 0.00 .and. cProcessa <> "I"
         if Flocaliapd("031")>0
            APD[FlocaliAPD("031"),9]:="D"
         endif
         Fgeraverba("031",nVBadcNot ,nDiasDSR01,,,"V",,0,,dData_Pgto,.t.)  
      endif 
      
   endif
endif
RETURN  
*/
/*
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||          |          |       |                       |      |          |||
|||Programa  |RGPEVERB  | Autor | Valdemir Miranda      | Data |19/07/2018|||
|||          |          |       |                       |      |          |||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||DescriÃ§Ã£o | Pega Tipo de Verba, se Informada ou não                  |||  
|||          |                                                            ||| 
|||          |                                                            |||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||   
*/
/*
Static Function RGPEVERB(cVerb1)   

Local cAliasA:=""
Local cTipo2 :=""
Local cVerba :=cVerb1

cQry	:="Select * "
cQry 	+= " FROM  "+RetSqlName("RGB")+" RGB (NOLOCK) " 
cQry 	 += " WHERE RGB.D_E_L_E_T_='' "    
 
cQry += " AND RGB.RGB_FILIAL = '" + SRA->RA_FILIAL + "' " 
cQry += " AND RGB.RGB_MAT = '" + SRA->RA_MAT + "' "
cQry += " AND RGB.RGB_PERIOD = '" + mv_par03 + "' "
cQry += " AND RGB.RGB_PD = '" + cVerba+ "' "  

cAliasA	:= GetNextAlias() 
If Select( cAliasA ) > 0
   dbSelectArea( cAliasA )
   dbCloseArea()
EndIf   
 
// *** Abre Tabelas *** //
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQry), cAliasA , .F., .T.)  

// *** Inicio do Processamento de funcionários em Atrazo *** //
dbSelectArea(cAliasA) 
ProcRegua((cAliasA)->(LastRec()))
dbGoTop()   

// ***
cTipo2:=" "
Do While .not. eof() 
   cTipo2:=(cAliasA)->RGB_TIPO2
   DBSKIP()
Enddo 

// *** Fecha Query *** //
dbSelectArea(cAliasA)
use
return(cTipo2)
*/
