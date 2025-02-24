#include 'protheus.ch'
#include 'parmtype.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFATR043 �Autor  � Arthur Silva		    � Data � 12/12/16 ���
�������������������������������������������������������������������������͹��
���Desc.     � Relat�rio de representantes com a rela��o de clientes	  ���
���          � Ativos.													  ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arcolor.			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
///////////////////////////ATEN��O!!!/////////////////////////////////////////
//O NOME DA EMPRESA 'ARCOLOR' EST� CHUMABO NESTE FONTE, POIS N�O EST� NA SM0//
//////////////////////////////////////////////////////////////////////////////
User Function RFATR043()

Private oReport, oSection
Private cTitulo  := OemToAnsi("Relat�rio de Clientes Ativos do(a) Representante ")
Private _cRotina := "RFATR043"
Private cPerg    := _cRotina

If FindFunction("TRepInUse") .And. TRepInUse()
	ValidPerg()
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Arthur Silva		    � Data � 12/12/16 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ReportDef()

Local _aOrd    := {"Representante + Cliente"}		//{"Solicita��o + Produto","Nome + ..."}

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������

oReport := TReport():New(_cRotina,cTitulo,cPerg,{|oReport| PrintReport(oReport)},"Estamos lhe enviando a rela��o de seus clientes."+CHR(13)+CHR(10)+"Bons Neg�cios!"+CHR(13)+CHR(10)+"ARCOLOR")
oReport:SetLandscape()			//Paisagem
oReport:SetTotalInLine(.F.)
Pergunte(oReport:uParam,.F.)

//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�                                                                        �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : //X3TITULO()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//� Secao dos itens do Pedido de Vendas                                    �
//��������������������������������������������������������������������������

oSection := TRSection():New(oReport,"Informa��es",{"SA1","SA3"},_aOrd/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSection:SetTotalInLine(.F.)

//Defini��o das colunas do relat�rio
//TRCell():New(oSection,"A3_NOME"    		,"SA3TMP","Representante"         ,PesqPict  ("SA3","A3_NOME" ),TamSx3("A3_NOME"  )[1]	 ,/*lPixel*/,{|| SA3TMP->A3_NOME        })	// NOME REPRESENTANTE
TRCell():New(oSection,"A1_NOME"    		,"SA3TMP","Cliente" 	          ,PesqPict  ("SA1","A1_NOME" ),TamSx3("A1_NOME"  )[1]	 ,/*lPixel*/,{|| SA3TMP->A1_NOME        })	// NOME CLIENTE
TRCell():New(oSection,"A1_END"    		,"SA3TMP",RetTitle("A1_END"	)	  ,PesqPict  ("SA1","A1_END"  ),TamSx3("A1_END"   )[1]-5 ,/*lPixel*/,{|| SA3TMP->A1_END       	})	// ENDERE�O
TRCell():New(oSection,"A1_CGC"    		,"SA3TMP",RetTitle("A1_CGC"	)	  ,"@R 99.999.999/9999-99"	   ,TamSx3("A1_CGC"   )[1]+21,/*lPixel*/,{|| SA3TMP->A1_CGC       	})	// CGC
TRCell():New(oSection,"A1_EMAIL"    	,"SA3TMP",RetTitle("A1_EMAIL")	  ,PesqPict  ("SA1","A1_EMAIL"),TamSx3("A1_EMAIL" )[1]-10,/*lPixel*/,{|| SA3TMP->A1_EMAIL		})	// EMAIL
TRCell():New(oSection,"A1_DDD"  		,"SA3TMP",RetTitle("A1_DDD"	)	  ,PesqPict  ("SA1","A1_DDD"  ),TamSx3("A1_DDD"   )[1]	 ,/*lPixel*/,{|| SA3TMP->A1_DDD  	  	})	// DDD
TRCell():New(oSection,"A1_TEL"  		,"SA3TMP",RetTitle("A1_TEL"	)	  ,PesqPict  ("SA1","A1_TEL"  ),TamSx3("A1_TEL"	  )[1]	 ,/*lPixel*/,{|| SA3TMP->A1_TEL     	})	// TELEFONE

/*
oSection:SetEdit(.T.)
oSection:SetUseQuery(.T.)
oSection:SetEditCell(.T.)
//oSection:DelUserCell(.F.)
*/

//oBreak := TRBreak():New(oSection,oSection:Cell("A3_NOME"),"Representante...")

//TRFunction():New(oSection:Cell("CAMPO"),NIL,"COUNT",oBreak) // Totalizador

//������������������������������������������������������������������������Ŀ
//� Troca descricao do total dos itens                                     �
//��������������������������������������������������������������������������

//oReport:Section(1):SetTotalText("Descri��o Totalizador")

//oReport:Section(1):SetEdit(.T.) 
//oReport:Section(1):SetUseQuery(.T.) // Novo componente tReport para adcionar campos de usuario no relatorio qdo utiliza query

//������������������������������������������������������������������������Ŀ
//� Alinhamento a direita as colunas de valor                              �
//��������������������������������������������������������������������������
//oSection:Cell("CAMPO"):SetHeaderAlign("RIGHT")

Return(oReport)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PrintReport�Autor �Arthur Silva		   � Data �  12/12/16 ���
�������������������������������������������������������������������������͹��
���Desc.     �Processamento das informa��es para impress�o (Print).       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function PrintReport(oReport)

Local _cOrder  := ""
Local _cField  := ""
Local _cFilSA3 := oSection:GetSqlExp("SA3")
Local _cFilSA1 := oSection:GetSqlExp("SA1")


If Empty(MV_PAR01) .OR. MV_PAR02 > MV_PAR04 .OR. MV_PAR03 > MV_PAR05
	MsgStop("Par�metros informados incorretamente!",_cRotina+"_002")
	Return
EndIf

//Defini��o da ordem de apresenta��o das informa��es
If oReport:Section(1):GetOrder() == 1			//Ordem por Nome
	_cOrder := "A3_NOME, A1_NOME"
//ElseIf oReport:Section(1):GetOrder() == 2		//Ordem por Nome + ...
//	_cOrder := "Definir aqui a segunda ordem almejada..."
EndIf

_cField  := "%" + _cField  + "%"
_cOrder  := "%" + _cOrder  + "%"
/*
oSection:SetEdit(.T.)
oSection:SetUseQuery(.T.)
oSection:SetEditCell(.T.)
//oSection:DelUserCell(.F.)
*/
//Elimino os filtros do usu�rio para evitar duplicidades na query, uma vez que j� estou tratando (este procedimento precisa ser realizado antes da montagem da Query)
For _x := 1 To Len(oSection:aUserFilter)
	oSection:aUserFilter[_x][02] := oSection:aUserFilter[_x][03] := ""
Next
oSection:CSQLEXP := ""
//PROCESSAMENTO DAS INFORMA��ES PARA IMPRESS�O
//Transforma par�metros do tipo Range em expressao SQL para ser utilizada na query 

MakeSqlExpr(oReport:uParam)
MakeSqlExpr(cPerg)

oSection:BeginQuery()
		BeginSql Alias "SA3TMP"
			SELECT *
			FROM %table:SA3% SA3
				INNER JOIN %table:SA1% SA1 ON SA1.A1_FILIAL     = %xFilial:SA1%
							  AND SA1.A1_COD  BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR04%
							  AND SA1.A1_LOJA BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR05%
							  AND SA1.A1_MSBLQL    <> '1'
							  AND SA1.A1_CGC       <> ''
							  AND SA1.A1_EST       <> 'EX'
							  AND SA1.A1_VEND       = SA3.A3_COD
							  AND SA1.%NotDel%
			WHERE SA3.A3_FILIAL     = %xFilial:SA3%
			  AND SA3.A3_COD        = %Exp:MV_PAR01%
			  AND LEN(SA3.A3_EMAIL) > 3
			  AND SA3.A3_MSBLQL    <> '1'
			  AND SA3.%NotDel%
			ORDER BY A3_FILIAL, A3_COD, A1_FILIAL, A1_NOME, A1_END, A1_CGC
		EndSql
	/*
	Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
	parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
	pela funcao MakeSqlExpr para serem adicionados a query
	*/
oSection:EndQuery()

//MemoWrite("\"+_cRotina+"_QRY_001",oSection:CQUERY)

oSection:Print()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValidPerg �Autor  �Arthur Silva			 Data �  12/12/16 ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se as perguntas existem na SX1. Caso n�o existam,  ���
���          �as cria.                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ValidPerg()

Local _aArea := GetArea()
Local aRegs  := {}
Local _aTam  := {}
Local i      := 0

cPerg := PADR(cPerg,10)

_aTam  := TamSx3("A3_COD" )
// Altera��o - Fernando Bombardi - ALLSS - 03/03/2022
//AADD(aRegs,{cPerg,"01","Do Vendedor           ?","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par01",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
AADD(aRegs,{cPerg,"01","Do Representante        ?","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par01",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
// Fim - Fernando Bombardi - ALLSS - 03/03/2022

_aTam  := TamSx3("A1_COD" )
AADD(aRegs,{cPerg,"02","Do Cliente            ?","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par02",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA1","",""})
_aTam  := TamSx3("A1_LOJA")
AADD(aRegs,{cPerg,"03","Da Loja               ?","","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par03",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})
_aTam  := TamSx3("A1_COD" )
AADD(aRegs,{cPerg,"04","At� o Cliente         ?","","","mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par04",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA1","",""})
_aTam  := TamSx3("A1_LOJA")
AADD(aRegs,{cPerg,"05","At� a Loja            ?","","","mv_ch5",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par05",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})

For i := 1 To Len(aRegs)
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If !SX1->(dbSeek(cPerg+aRegs[i,2]))
		RecLock("SX1",.T.)
		For j := 1 To FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Else
				Exit
			EndIf
		Next
		SX1->(MsUnlock())
	EndIf
Next


RestArea(_aArea)

Return
