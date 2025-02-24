#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE _CLRF CHR(13) + CHR (10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TK271FCPY ºAutor  ³Renan Felipe         º Data ³  29/12/12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada é executado ao fim da gravação de cópia deº±±
±±º          ³atendimento do Televendas para gravar o campo UA->COPY.     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Call Center - Específico para a Arcolor.     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TK271FCPY(_cAtOrig,_cAtDest)

Local _aArea     := GetArea()
Local _aSavSA1   := SA1->(GetArea())
Local _aSavSUA   := SUA->(GetArea())
Local _aSavSUB   := SUB->(GetArea())
Local _aSavSA4   := SA4->(GetArea())
Local _cRotina   := 'TK271FCPY'
Local _cCliOri   := ""
Local _cLojOri   := ""
Local _cObsSep   := ""
Local _cLogx     := ""
Private _cInd := "2"

If Type("_cAtOrig")=="U"
	_cAtOrig := PARAMIXB[1]
EndIf
If Type("_cAtDest")=="U"
	_cAtDest := PARAMIXB[2]
EndIf
_cLogx := "Atendimento originado por cópia do atendimento '" + _cAtOrig + "'."
dbSelectArea("SUA")
SUA->(dbSetOrder(1))
If SUA->(MsSeek(xFilial("SUA") + _cAtOrig,.T.,.F.))
	_cCliOri   := SUA->UA_CLIENTE
	_cLojOri   := SUA->UA_LOJA
EndIf
dbSelectArea("SUA")
SUA->(dbSetOrder(1))
If SUA->(MsSeek(xFilial("SUA") + _cAtDest,.T.,.F.))
	If !IIF(Type("lProspect")=="L",lProspect,SUA->UA_PROSPEC)
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1") + SUA->UA_CLIENTE + SUA->UA_LOJA,.T.,.F.)) .AND. !Empty(SA1->A1_OBSSEP)
			_cObsSep += AllTrim(SA1->A1_OBSSEP) + CHR(13) + CHR(10)			
		EndIf
	EndIf
	//Início - Trecho adicionado por Adriano Leonardo em 16/06/2014 para validação da transportadora (bloqueio)
		_lTranspOK := .T.
		If !Empty(SUA->UA_TRANSP) //.And. lRet
			dbSelectArea("SA4")
			SA4->(dbSetOrder(1))
			If SA4->(MsSeek(xFilial("SA4")+SUA->UA_TRANSP,.T.,.F.))
				If AllTrim(SA4->A4_MSBLQL)=="1"
					_lTranspOK := .F.
					_cLogx += _cLogx + "A transportadora do atendimento copiado está bloqueada para uso e não será copiada. Favor revisar!"
					MsgAlert(_cLogx,_cRotina+"_002")
				ElseIf !Empty(SA4->A4_OBSSEP)
					_cObsSep += AllTrim(SA4->A4_OBSSEP) + _CLRF
				EndIf
			EndIf
		EndIf
	//Final  - Trecho adicionado por Adriano Leonardo em 16/06/2014 para validação da transportadora (bloqueio)
	dbSelectArea("SUA")
	RecLock("SUA",.F.)
		If !Empty(SuperGetMv("MV_DTFIXAT",,STOD("")))
			SUA->UA_EMISSAO := SuperGetMv("MV_DTFIXAT",,MsDate())
		EndIf
		If SUA->(FieldPos("UA_COPY"))>0
			SUA->UA_COPY     := "S"
		EndIf
		If SUA->(FieldPos("UA_CLIORCP"))>0
			SUA->UA_CLIORCP  := _cCliOri
		EndIf
		If SUA->(FieldPos("UA_LJORCP"))>0
			SUA->UA_LJORCP   := _cLojOri
		EndIf
		If SUA->(FieldPos("UA_STATSC9"))>0
			SUA->UA_STATSC9  := ""
		EndIf
		If SUA->(FieldPos("UA_OBSSEP"))>0
			SUA->UA_OBSSEP   := _cObsSep + SUA->UA_OBSSEP
		EndIf
		If SUA->(FieldPos("UA_LOGSTAT"))>0
			SUA->UA_LOGSTAT  := Replicate("-",60) + _CLRF + DTOC(Date()) + " - " + Time() + " - " + UsrRetName(__cUserId) + _CLRF + _cLogx
		EndIf
		// Em 19/07/2016 Acrescentadas validações FieldPos para identificar existencia dos campos devido as várias empresas
		If SUA->(FieldPos("UA_CODOBS"))>0	
			SUA->UA_CODOBS   := ""
		EndIf
		If SUA->(FieldPos("UA_OBSBLQ"))>0	
			SUA->UA_OBSBLQ   := ""
		EndIf
		If SUA->(FieldPos("UA_DESCPAG"))>0	
			SUA->UA_DESCPAG  := "" //Linha adicionada por Adriano Leonardo em 10/07/2014 para limpar campo customizado
		EndIf
		If SUA->(FieldPos("UA_ARQXLS"))>0	
			SUA->UA_ARQXLS   := ""
		EndIf
		//Inicio -Trecho adicionado por Renan 19/07/2016 para trazer informações corretas quando efetuada a copia de um pedido de outro cliente.		
		If SUA->(FieldPos("UA_NOMECLI"))>0	
			SUA->UA_NOMECLI	 := SA1->A1_NOME
		EndIf
		If SUA->(FieldPos("UA_NOMREDZ"))>0	
			SUA->UA_NOMREDZ  := SA1->A1_NREDUZ
		EndIf
		If SUA->(FieldPos("UA_CGC"))>0 
			SUA->UA_CGC		 := SA1->A1_CGC
		EndIf
		If SUA->(FieldPos("UA_CGCCENT"))>0 .AND. SA1->(FieldPos("A1_CGCCENT"))>0
			SUA->UA_CGCCENT  := SA1->A1_CGCCENT
		EndIf
		//Final -Trecho adicionado por Renan 19/07/2016 para trazer informações corretas quando efetuada a copia de um pedido de outro cliente.
		//Inicio -Trecho adicionado por Renan 13/10/2016 para trazer informações corretas quando efetuada a copia de um pedido de outro cliente.
		If SUA->(FieldPos("UA_TPDIV"))>0 
			SUA->UA_TPDIV	:= SA1->A1_TPDIV
		EndIf
		If SUA->(FieldPos("UA_TABELA"))>0 
			SUA->UA_TABELA	:= SA1->A1_TABELA
		EndIf
		If SUA->(FieldPos("UA_CONDPG"))>0 
			SUA->UA_CONDPG	:= SA1->A1_COND
		EndIf
		If SUA->(FieldPos("UA_VEND"))>0 
			SUA->UA_VEND	:= SA1->A1_VEND
		EndIf
		If SUA->(FieldPos("UA_TPFRETE"))>0 
			SUA->UA_TPFRETE	:= SA1->A1_TPFRET
		EndIf
		//Final -Trecho adicionado por Renan 13/10/2016 para trazer informações corretas quando efetuada a copia de um pedido de outro cliente.
		//Início  - Trecho adicionado por Adriano Leonardo em 16/06/2014 para validação da transportadora (bloqueio)
		If SUA->(FieldPos("UA_TRANSP"))>0
			If !_lTranspOK
				SUA->UA_TRANSP := ""
			Else
				SUA->UA_TRANSP := SA1->A1_TRANSP
			EndIf
		EndIf
		//Final  - Trecho adicionado por Adriano Leonardo em 16/06/2014 para validação da transportadora (bloqueio)	
		//Início  - Trecho adicionado por Diego Rodrigues em 15/08/2024 para validação de produto da linha industrial
		If (IIF(EXISTBLOCK("RTMKE035"),U_RTMKE035(),.F.))
				SUA->UA_XLININD := _cInd
		EndIf
		//Final  - Trecho adicionado por Diego Rodrigues em 15/08/2024 para validação de produto da linha industrial		
	SUA->(MsUnLock())
	//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
	If ExistBlock("RFATL001")
		U_RFATL001(	SUA->UA_NUMSC5,;
					SUA->UA_NUM,;
					_cLogx,;
					_cRotina)
	EndIf
EndIf

MSGBOX("Atendimento " + _cAtDest + " gerado com sucesso.",_cRotina+"_001","INFO")

RestArea(_aSavSA1)
RestArea(_aSavSUA)
RestArea(_aSavSUB)
RestArea(_aSavSA4)
RestArea(_aArea)

Return NIL
