#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณROMSR001  บ Autor ณ J๚lio Soares       บ Data ณ  05/11/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Esse relat๓rio tem por objetivo imprimir as cargas conformeบฑฑ
ฑฑบ          ณ parโmetros informados pelo sistema                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para a empresa Arcolor.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ROMSR001()

Private cDesc1         	:= "Este programa tem como objetivo imprimir relatorio "
Private cDesc2         	:= "de acordo com os parametros informados pelo usuario."
Private cDesc3         	:= "Rela็ใo de cargas por nota"
Private titulo       	:= "Rela็ใo de cargas por nota"
Private nLin           	:= 0080
Private lEnd         	:= .F.
Private lAbortPrint  	:= .F.
Private CbTxt        	:= ""
Private limite       	:= 132 						//Limite da pแgina: 80 - 132 - 220 // P - M - G
Private tamanho      	:= "G"
Private nomeprog     	:= "ROMSR001"
Private nTipo        	:= 18
Private aReturn      	:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     	:= 0
Private cbtxt        	:= Space(10)
Private cbcont       	:= 00
Private CONTFL       	:= 01
Private m_pag        	:= 01
Private cString      	:= "DAI"
Private wnrel        	:= nomeprog
Private cPerg		 	:= nomeprog
Private _cRotina     	:= nomeprog
Private aCol		 	:= {}
Private _nNumPagina	 	:= 0
Private _nTotal         := 0
Private _nPeso          := 0
Private _nVolm          := 0
Private _nFrete         := 0
Private _nDesp          := 0
Private _lEnt           := + CHR(13) + CHR(10)

dbSelectArea("DAI")
DAI->(dbSetOrder(1))
ValidPerg()
if Pergunte( cPerg,.T. )
	Processa({|| RunReport()},Titulo,"Aguarde... processando impressao...",.F.)
endIf 

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณ RunReport บ Autor ณJ๚lio Soares         บ Data ณ  25/03/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Processamento e impressใo do relat๓rio					  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RunReport()

Private _cNumCarg := ""
Private oPrn      := TMSPrinter():New()
Private oFont1    := TFont():New( "Arial",,07,,.T.,,,,,.F. ) //-ok Ne
Private oFont2    := TFont():New( "Arial",,10,,.F.,,,,,.F. ) //-ok
Private oFont3    := TFont():New( "Arial",,12,,.T.,,,,,.F. ) //-ok Ne
Private oFont4    := TFont():New( "Arial",,10,,.T.,,,,,.F. ) //-ok Ne
Private oFont5    := TFont():New( "Arial",,18,,.F.,,,,,.F. ) //-ok
Private oFont6    := TFont():New( "Arial",,12,,.F.,,,,,.F. ) //-ok 

Private nLinAd    := 0005
Private nLinAdj   := 0035

_cQuery := " SELECT DAK_PTOENT,DAI_COD,DAI_CLIENT,DAI_LOJA, "                                                                             +_lEnt
_cQuery += "       (CASE WHEN F2_TIPO = 'N' THEN A1_NOME "                                                                                +_lEnt
_cQuery += "                                ELSE A2_NOME "                                                                                +_lEnt
_cQuery += "                                END         ) [A1_NOME] , "                                                                   +_lEnt
_cQuery += "       (CASE WHEN F2_TIPO = 'N' THEN A1_BAIRRO "                                                                              +_lEnt
_cQuery += "                                ELSE A2_BAIRRO "                                                                              +_lEnt
_cQuery += "                                END         ) [A1_BAIRRO] , "                                                                 +_lEnt
_cQuery += "       (CASE WHEN F2_TIPO = 'N' THEN A1_MUN "                                                                                 +_lEnt
_cQuery += "                                ELSE A2_MUN "                                                                                 +_lEnt
_cQuery += "                                END         ) [A1_MUN] , "                                                                    +_lEnt
_cQuery += " DAI_PEDIDO,DAI_NFISC2,DAI_SERIE2,"                                                                                           +_lEnt
_cQuery += " DAK_CAMINH,DAK_MOTORI,ISNULL(DA4_NOME,'')[DA4_NOME],ISNULL(DA3_PLACA,'')[DA3_PLACA], ISNULL(DA3_VLFRET,0) [DA3_VLFRET],"     +_lEnt

//_cQuery += " (CASE WHEN DAI_SEQCAR <> '" + Replicate("Z",Len(DAI->DAI_SEQCAR)) + "' THEN DAI_PESO2          ELSE 0 END) DAI_PESO2 , "     +_lEnt
_cQuery += " (CASE	WHEN (	SELECT COUNT(*)[CONT] "                               +_lEnt
_cQuery += " 				FROM (	SELECT D2_SERIE,D2_DOC,D2_EMISSAO "           +_lEnt
_cQuery += " 						FROM "+RetSqlName("SD2")+" SD2 "              +_lEnt
_cQuery += " 						WHERE SD2.D_E_L_E_T_ = '' "                   +_lEnt
_cQuery += " 						AND SD2.D2_PEDIDO = DAI_PEDIDO "              +_lEnt
_cQuery += " 						GROUP BY D2_SERIE,D2_DOC,D2_EMISSAO "         +_lEnt
_cQuery += " 					  )DX) > 1  AND DAI_SERIE2 = '1' THEN DAI_PESO2 " +_lEnt
_cQuery += " 		WHEN (	SELECT COUNT(*)[CONT] "                               +_lEnt
_cQuery += " 				FROM (	SELECT D2_SERIE,D2_DOC,D2_EMISSAO "           +_lEnt
_cQuery += " 						FROM "+RetSqlName("SD2")+" SD2 "              +_lEnt
_cQuery += " 						WHERE SD2.D_E_L_E_T_ = '' "                   +_lEnt
_cQuery += " 						AND SD2.D2_PEDIDO = DAI_PEDIDO "              +_lEnt
_cQuery += " 						GROUP BY D2_SERIE,D2_DOC,D2_EMISSAO "         +_lEnt
_cQuery += " 					  )DX) = 1  THEN DAI_PESO2 "                      +_lEnt
_cQuery += " 		ELSE 0 END) DAI_PESO2 , "                                     +_lEnt
//_cQuery += " (CASE WHEN DAI_SEQCAR <> '" + Replicate("Z",Len(DAI->DAI_SEQCAR)) + "' THEN DAI_VOLUM2         ELSE 0 END) DAI_VOLUM2, "     +_lEnt
_cQuery += " (CASE	WHEN (	SELECT COUNT(*)[CONT] "                               +_lEnt
_cQuery += " 				FROM(	SELECT D2_SERIE,D2_DOC,D2_EMISSAO "           +_lEnt
_cQuery += " 						FROM "+RetSqlName("SD2")+" SD2 "              +_lEnt
_cQuery += " 						WHERE SD2.D_E_L_E_T_ = '' "                   +_lEnt
_cQuery += " 						AND SD2.D2_PEDIDO = DAI_PEDIDO "              +_lEnt
_cQuery += " 						GROUP BY D2_SERIE,D2_DOC,D2_EMISSAO "         +_lEnt
_cQuery += " 					  )DX) > 1  AND DAI_SERIE2 = '1' THEN DAI_VOLUM2 "+_lEnt
_cQuery += " 		WHEN  (	SELECT COUNT(*)[CONT] "                               +_lEnt
_cQuery += " 				FROM (	SELECT D2_SERIE,D2_DOC,D2_EMISSAO "           +_lEnt
_cQuery += " 						FROM "+RetSqlName("SD2")+" SD2 "              +_lEnt
_cQuery += " 						WHERE SD2.D_E_L_E_T_ = '' "                   +_lEnt
_cQuery += " 						AND SD2.D2_PEDIDO = DAI_PEDIDO "              +_lEnt
_cQuery += " 						GROUP BY D2_SERIE,D2_DOC,D2_EMISSAO "         +_lEnt
_cQuery += " 					  )DX) = 1  THEN DAI_VOLUM2 "                     +_lEnt
_cQuery += " 		ELSE 0 END) DAI_VOLUM2, "                                     +_lEnt

_cQuery += " (CASE WHEN DAI_SEQCAR <> '" + Replicate("Z",Len(DAI->DAI_SEQCAR)) + "' THEN DAI_VALOR2         ELSE 0 END) DAI_VALOR2, "     +_lEnt
_cQuery += " (CASE WHEN DAI_SEQCAR <> '" + Replicate("Z",Len(DAI->DAI_SEQCAR)) + "' THEN ISNULL(E1_VALOR,0) ELSE 0 END) E1_VALOR  , "     +_lEnt
_cQuery += " DAK_DATA,DAK_HORA,F2_TIPO "                                                                                                  +_lEnt
_cQuery += " FROM " + RetSqlName("DAI") + " DAI "                                                                                         +_lEnt
_cQuery += " 	LEFT JOIN " + RetSqlName("SF2") + " SF2  ON SF2.D_E_L_E_T_ = '' "                                                         +_lEnt
_cQuery += " 		AND SF2.F2_FILIAL  = '" + xFilial("SF2") + "' "                                                                       +_lEnt
//_cQuery += " 		AND SF2.F2_CLIENTE = DAI.DAI_CLIENT "                                                                                 +_lEnt
//_cQuery += " 		AND SF2.F2_LOJA    = DAI.DAI_LOJA "                                                                                   +_lEnt
_cQuery += " 		AND SF2.F2_DOC     = DAI.DAI_NFISC2 "                                                                                 +_lEnt
_cQuery += " 		AND SF2.F2_SERIE   = DAI.DAI_SERIE2 "                                                                                 +_lEnt
_cQuery += " 	LEFT JOIN " + RetSqlName("DAK") + " DAK ON DAK.D_E_L_E_T_ = '' "                                                          +_lEnt
_cQuery += " 		AND DAK.DAK_FILIAL = '" + xFilial("DAK") + "' "                                                                       +_lEnt
_cQuery += "  		AND DAK.DAK_COD    = DAI.DAI_COD "                                                                                    +_lEnt
_cQuery += " 	LEFT JOIN " + RetSqlName("SA1") + " SA1  ON SA1.D_E_L_E_T_ = '' "                                                         +_lEnt
_cQuery += "  		AND SA1.A1_FILIAL  = '" + xFilial("SA1") + "' "                                                                       +_lEnt
_cQuery += " 		AND SA1.A1_COD     = SF2.F2_CLIENTE "                                                                                 +_lEnt
_cQuery += "  		AND SA1.A1_LOJA    = SF2.F2_LOJA "                                                                                    +_lEnt
_cQuery += " 	LEFT JOIN " + RetSqlName("SA2") + " SA2  ON SA2.D_E_L_E_T_ = '' "                                                         +_lEnt
_cQuery += "  		AND SA2.A2_FILIAL  = '" + xFilial("SA2") + "' "                                                                       +_lEnt
_cQuery += " 		AND SA2.A2_COD     = SF2.F2_CLIENTE "                                                                                 +_lEnt
_cQuery += "  		AND SA2.A2_LOJA    = SF2.F2_LOJA "                                                                                    +_lEnt
_cQuery += " 	LEFT JOIN " + RetSqlName("DA4") + " DA4 ON DA4.D_E_L_E_T_ = '' "                                                          +_lEnt
_cQuery += " 		AND DA4_FILIAL     = '" + xFilial("DA4") + "' "                                                                       +_lEnt
_cQuery += " 		AND DA4_COD        = DAK_MOTORI "                                                                                     +_lEnt
_cQuery += " 	LEFT JOIN " + RetSqlName("DA3") + " DA3 ON DA3.D_E_L_E_T_ = '' "                                                          +_lEnt
_cQuery += " 		AND DA3.DA3_FILIAL = '" + xFilial("DA3") + "' "                                                                       +_lEnt
_cQuery += " 		AND DA3.DA3_COD    = DAK.DAK_CAMINH "                                                                                 +_lEnt
_cQuery += " 	LEFT JOIN ( SELECT E1_CLIENTE,E1_LOJA,E1_EMISSAO,E1_PEDIDO,E1_PREFIXO,E1_NUM,SUM(E1_VALOR)[E1_VALOR] "                    +_lEnt
_cQuery += " 				FROM " + RetSqlName("SE1") + " SE1 "                                                                          +_lEnt
_cQuery += " 				WHERE SE1.D_E_L_E_T_ = '' "                                                                                   +_lEnt
_cQuery += " 				AND SE1.E1_FILIAL    = '" + xFilial("SE1") + "'"                                                              +_lEnt
_cQuery += " 				AND SE1.E1_TIPO      = 'NF'"                                                                                  +_lEnt
_cQuery += " 				GROUP BY E1_CLIENTE,E1_LOJA,E1_EMISSAO,E1_PEDIDO,E1_PREFIXO,E1_NUM "                                          +_lEnt
_cQuery += " 				) SE1 "                                                                                                       +_lEnt
_cQuery += " 		ON  DAI.DAI_CLIENT     = SE1.E1_CLIENTE "                                                                             +_lEnt
_cQuery += " 			AND DAI.DAI_LOJA   = SE1.E1_LOJA "                                                                                +_lEnt
_cQuery += " 			AND DAI.DAI_PEDIDO = SE1.E1_PEDIDO "                                                                              +_lEnt
_cQuery += " 			AND SF2.F2_EMISSAO = SE1.E1_EMISSAO "                                                                             +_lEnt
_cQuery += " 			AND SF2.F2_PREFIXO = SE1.E1_PREFIXO "                                                                             +_lEnt
_cQuery += " 			AND SF2.F2_DUPL    = SE1.E1_NUM "                                                                                 +_lEnt
_cQuery += " WHERE DAI.D_E_L_E_T_    = '' "                                                                                               +_lEnt
_cQuery += "   AND DAI.DAI_FILIAL    = '" + xFilial("DAI") + "' "                                                                         +_lEnt
_cQuery += "   AND DAI.DAI_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "                                                        +_lEnt
_cQuery += " GROUP BY DAK_PTOENT,DAI_COD,DAI_CLIENT,DAI_LOJA,A1_NOME,A2_NOME,A1_BAIRRO,A2_BAIRRO,A1_MUN,A2_MUN,DAI_PEDIDO, "              +_lEnt
_cQuery += "          DAI_NFISC2,DAI_SERIE2,DAI_PESO2, DAI_VOLUM2, DAI_SEQCAR, "                                                          +_lEnt
_cQuery += "          DAK_CAMINH,DAK_MOTORI,DA4_NOME,DA3_PLACA,DA3_VLFRET,SE1.E1_VALOR,DAI.DAI_VALOR2,DAK_DATA,DAK_HORA,F2_TIPO "         +_lEnt
_cQuery += " ORDER BY DAI_COD,DAI_PEDIDO,DAI_NFISC2 "                                                                                     +_lEnt
//MemoWrite("\2.MemoWrite\"+_cRotina+" - "+Alltrim(MV_PAR01)+" a "+Alltrim(MV_PAR02)+" - "+"_QRY_001.txt",_cQuery)
_cQuery := ChangeQuery(_cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"TRATMP",.T.,.F.)  
dbSelectArea("TRATMP")
ProcRegua(RecCount())
TRATMP->(dbGoTop())
If !TRATMP->(EOF())
	oPrn:Setup()
	oPrn:SetPaperSize(9) 			// Ajusta o tamanho da pแgina
	//oPrn:SetPortRait()
	oPrn:SetLandscape()
	While !TRATMP->(EOF()) .AND. _cNumCarg <> TRATMP->DAI_COD
		IncProc()
		oPrn:StartPage()
		_nNumPagina := 1

		// Chamada do cabe็alho
		ImpCab()
		nLin+=0050
		oPrn:line(nLin,0060,nLin,3300)	//Cria uma linha

	    // Imprime o subcabe็alho da impressใo
	    nLin+=0100
		oPrn:Say(nLin,0060,"ROMANEIO DE ENTREGAS: " ,oFont3,100,,,3)
		nLin+=0100
	    oPrn:Say(nLin,0060,"MOTORISTA: "     + AllTrim(TRATMP->DA4_NOME                      )                                ,oFont3,100,,,3)
		oPrn:Say(nLin,1700,"PLACA: "         + Alltrim(TRATMP->DA3_PLACA                     )                                ,oFont3,100,,,3)
		oPrn:Say(nLin,2150,"COD. CARGA: "    + Alltrim(TRATMP->DAI_COD                       )                                ,oFont3,100,,,3)
		oPrn:Say(nLin,2700,"Ptos de Entrg: " + Transform(TRATMP->DAK_PTOENT,"@E 999999"      )                                ,oFont3,100,,,3)
		nLin+=0100
	    oPrn:line(nLin,0060,nLin,3300)	//Cria uma linha
	   	_nVez     := 0
		_cNumCarg := TRATMP->DAI_COD
		While !TRATMP->(EOF()) .AND. _cNumCarg == TRATMP->DAI_COD
			_nValNf := 0
			_nPesNf := 0
			_cVolNf := ""
			_cPedNf := TRATMP->DAI_PEDIDO
			_cNf2Nf := TRATMP->DAI_NFISC2 
			While !TRATMP->(EOF()) .AND. _cNumCarg == TRATMP->DAI_COD .AND. _cPedNf == TRATMP->DAI_PEDIDO .AND. _cNf2Nf == TRATMP->DAI_NFISC2  
				// Impressao do cabecalho dos itens. . .
				_nVez++
				If _nVez == 1
				    nLin += 0020
		        	ImpItens()
				EndIf
			    nLin += 0100
			    // Quebra de pแgina
				If nLin > 2100
					SaltPag()
					RodPe()
					oPrn:EndPage()
					oPrn:StartPage()
					ImpCab()
					nLin+=0050
					oPrn:line(nLin,0060,nLin,3300)	//Cria uma linha
					nLin += 0100
					ImpItens()
					nLin += 0100
				EndIf
				// Popula o array para preenchimento nas colunas
			    oPrn:Say(nLin,acol[1,1],TRATMP->DAI_NFISC2                                         ,oFont2,100,,,3)
			    oPrn:Say(nLin,acol[2,1],TRATMP->DAI_CLIENT                                         ,oFont2,100,,,3)
			    oPrn:Say(nLin,acol[3,1],TRATMP->DAI_LOJA                                           ,oFont2,100,,,3)
			    oPrn:Say(nLin,acol[4,1],Substr(TRATMP->A1_NOME  ,1,40)                             ,oFont2,100,,,3)
			    oPrn:Say(nLin,acol[5,1],Substr(TRATMP->A1_BAIRRO,1,12)                             ,oFont2,100,,,3)
			    oPrn:Say(nLin,acol[6,1],Substr(TRATMP->A1_MUN   ,1,18)                             ,oFont2,100,,,3)
				If TRATMP->E1_VALOR > 0
					//oPrn:Say(nLin,acol[7,1],'R$ '+Transform(TRATMP->E1_VALOR    ,"@E 999,999,999.99")  ,oFont2,100,,,3)
				    _nValNf += TRATMP->E1_VALOR
				Else
					//oPrn:Say(nLin,acol[7,1],'R$ '+Transform(TRATMP->DAI_VALOR2  ,"@E 999,999,999.99")  ,oFont2,100,,,3)
				    _nValNf += TRATMP->DAI_VALOR2
				EndIf

			    //oPrn:Say(nLin,acol[8,1],Transform(TRATMP->DAI_PESO2       ,"@E 999,999.99")            ,oFont2,100,,,3)
			    _nPesNf := TRATMP->DAI_PESO2
			    
			    //oPrn:Say(nLin,acol[9,1],Transform(TRATMP->DAI_VOLUM2      ,"@E 9999.99")               ,oFont2,100,,,3)
			    _cVolNf := TRATMP->DAI_VOLUM2
			    
			    oPrn:Say(nLin,acol[10,1]," ____________________ "                                      ,oFont2,100,,,3)

                // - TOTAIS
				If TRATMP->E1_VALOR > 0
					_nTotal += TRATMP->E1_VALOR		//acol[7,1]
				Else
					_nTotal += TRATMP->DAI_VALOR2   //acol[7,1]
				EndIf
				_nPeso  += TRATMP->DAI_PESO2  //acol[8,1]
				_nVolm  += TRATMP->DAI_VOLUM2 //acol[9,1]
				_nFrete := TRATMP->DA3_VLFRET
				dbSelectArea("TRATMP")
				TRATMP->(dbSkip())
			EndDo
			oPrn:Say(nLin,acol[7,1],'R$ ' + Transform(_nValNf ,"@E 999,999,999.99")  ,oFont2,100,,,3)
			oPrn:Say(nLin,acol[8,1],        Transform(_nPesNf ,"@E 999,999.99"    )  ,oFont2,100,,,3)
			oPrn:Say(nLin,acol[9,1],        Transform(_cVolNf ,"@E 9999.99"       )  ,oFont2,100,,,3)
		EndDo
		// - IMPRIMO OS TOTAIS NO RODAPษ
		Totais()
		// - ZERA OS TOTAIS APำS IMPRESSรO PARA PASSAR PARA PRำXIMA PมGINA
		_nTotal := 0 //(TRATMP->(E1_VALOR))   //acol[7,1]
		_nPeso  := 0 //(TRATMP->(DAI_PESO2))  //acol[8,1]
		_nVolm  := 0 //(TRATMP->(DAI_VOLUM2)) //acol[9,1]        
		RodPe()
		oPrn:EndPage()	
	EndDo
	oPrn:Preview()
EndIf

dbSelectArea("TRATMP")
TRATMP->(dbCloseArea())

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSaltPag   บAutor  ณJ๚lio Soares        บ Data ณ  26/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc	   	 ณFuncao para imprimir a expressใo Continua	  	              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPrograma Principal                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/            

Static Function SaltPag()

nLin := 2200
nLin += 0045
oPrn:Say(nLin,2750," -------------------- continua pแgina --------------------  ", oFont1,100,,,3)
_nNumPagina++

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpProduto       บAutor  ณJ๚lio Soares บ Data ณ  26/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc	   	 ณFuncao para imprimir o cabe็alho dos itens 	              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPrograma Principal                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ImpItens()

aCol 	:= {{0060,"DOC."          ,3},;
 			{0280,"CLIENTE"       ,3},;
			{0450,"LOJA"          ,3},;
			{0580,"RAZรO SOCIAL"  ,3},;
			{1500,"BAIRRO"        ,3},;
 			{1800,"CIDADE"        ,3},;
 			{2200,"VALOR"         ,3},;
 			{2500,"PESO"          ,3},;
 			{2700,"VOLUME"        ,3},;
 			{2900,"OBS"           ,3}}

For _x:=1 To Len(aCol)
	oPrn:Say(nLin,aCol[_x,1],aCol[_x,2],oFont4,100,,,aCol[_x,3])
Next		    

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpCab    บAutor  ณJ๚lio Soares        บ Data ณ  25/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de Impressใo do Cabe็alho							  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ImpCab()

Local   _cLogo       := FisxLogo("1")

Private _dData       := STOD(TRATMP->(DAK_DATA))//STOD(DAK_DATA)
Private _dHora       := (TRATMP->(DAK_HORA))

nLin 	             := 120

//Quadro superior esquerdo (Logotipo)
oPrn:Box(nLin,0050,nLin+0150,0700)//QUADRO DO LOGO

//Quadro superior central
oPrn:Box(nLin,0725,nLin+0150,2875)//QUADRO CENTRAL
oPrn:Say(nLin+0050,1700,"RELAวรO DE DOCUMENTOS POR CARGA",          oFont5,100,CLR_RED,,2)
                                                                         
//Quadro superior direito
oPrn:Box(nLin,2900,nLin+0150,3300)//QUADRO DA DIREITA
oPrn:Say(nLin+0010,3100,(nomeprog),                                 oFont3,100,CLR_RED,,2)
oPrn:Say(nLin+0060,3100,DTOC(_dData) + " - " + (_dHora),            oFont2,100,       ,,2)
oPrn:Say(nLin+0090,3100,"Pแgina " + AllTrim(Str(_nNumPagina)),      oFont2,100,       ,,2)
nLin 	+= 0150
nLinAd	:= 1000
      
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTotais   บAutor  ณJ๚lio Soares         บ Data ณ  21/11/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc	   	 ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPrograma Principal                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Totais()

_cQry := " SELECT EU_CARGA,SUM(CASE WHEN EU_TIPO = '02' THEN EU_VALOR*(-1) ELSE EU_VALOR END)[VALOR] " +_lEnt
_cQry += " FROM " + RetSqlName("SEU") + " SEU "               +_lEnt
_cQry += " WHERE SEU.D_E_L_E_T_ = '' "                        +_lEnt
_cQry += "   AND SEU.EU_FILIAL  = '" + xFilial("SEU") + "' "  +_lEnt
_cQry += "   AND SEU.EU_CARGA   = '" + (_cNumCarg)    + "' "  +_lEnt
_cQry += " GROUP BY EU_CARGA "
//If __cUserId=="000000"
//	MemoWrite("\2.MemoWrite\"+_cRotina+" - "+Alltrim(MV_PAR01)+" a "+Alltrim(MV_PAR02)+" - "+"_QRY_002.txt",_cQry)
//EndIf
_cQry := ChangeQuery(_cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"TRBTMP",.T.,.F.)  

nLin := 2200

dbSelectArea("TRBTMP")
TRBTMP->(dbGoTop())
While !(TRBTMP->(EOF()))
	If (_cNumCarg) == (TRBTMP->(EU_CARGA))
		_nDesp  += (TRBTMP->(VALOR))
	EndIf
	TRBTMP->(dbSkip())
EndDo
TRBTMP->(dbCloseArea())

oPrn:Say(nLin,0050,"VALOR FRETE: "                                   ,oFont3,100,,,3)
oPrn:Say(nLin,0400,'R$ '+ Transform(_nFrete,"@E 999,999.99")         ,oFont2,100,,,3)

oPrn:Say(nLin,0720,"VALOR DESPESAS: "                                ,oFont3,100,,,3)
oPrn:Say(nLin,1180,'R$ '+ Transform(_nDesp,"@E 999,999.99")          ,oFont2,100,,,3)

oPrn:Say(nLin,1450,"VALOR TOTAL: "                                   ,oFont3,100,,,3)
oPrn:Say(nLin,1750,'R$ '+ Transform(_nTotal,"@E 999,999,999.99")     ,oFont2,100,,,3)

oPrn:Say(nLin,2150,"PESO TOTAL: "                                    ,oFont3,100,,,3)
oPrn:Say(nLin,2430,Transform(_nPeso ,"@E 999,999.99")                ,oFont2,100,,,3)

oPrn:Say(nLin,2660,"VOLUME TOTAL: "                                  ,oFont3,100,,,3)
oPrn:Say(nLin,3100,Transform(_nVolm,"@E 9999.99")                    ,oFont2,100,,,3)

_nDesp := 0

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRodPe  บAutor  ณJ๚lio Soares           บ Data ณ  25/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime o rodap้ das paginas                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RodPe()

nLin := 2300
//_nNumPagina ++
oPrn:Box(nLin,0050,nLin+0075,3300)
oPrn:Say(nLin+10,0100,"Impresso em: " + DTOC(DATE()) + " - " + TIME() + " por " + AllTrim(cUserName), oFont2,100,,,3)

Return()
    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg      บAutor  ณ J๚lio Soares  บ Data ณ  25/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se as perguntas existem na tabela SX1, as criando บฑฑ
ฑฑบ          ณcaso nใo existam.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ValidPerg()

Local _sAlias := GetArea()
Local aRegs   := {}
Local _cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()

if select(_cAliasSX1)>0
	(_cAliasSX1)->(dbCloseArea())
endif

cPerg := PADR(cPerg,10)

AADD(aRegs,{cPerg,"01","De Carga?" 	,"","","mv_ch1","C",06,0,0,"G",""          ,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","DAK",""})
AADD(aRegs,{cPerg,"02","At้ Carga?"	,"","","mv_ch2","C",06,0,0,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","DAK",""})
	  	
For x := 1 To Len(aRegs)

OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
dbSelectArea(_cAliasSX1)
(_cAliasSX1)->(dbSetOrder(1))

	If !SX1->(MsSeek(cPerg+aRegs[x,2],.T.,.F.))
		RecLock("SX1",.T.)
		For y := 1 To FCount()
			If y <= Len(aRegs[x])
				FieldPut(y,aRegs[x,y])
			Else
				Exit
			EndIf
		Next
		SX1->(MsUnlock())
	EndIf
Next

RestArea(_sAlias)

Return()
