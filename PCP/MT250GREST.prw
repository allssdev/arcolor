#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT250GREST º Autor ³Adriano Leonardo    º Data ³25/10/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada após o estorno do apontamento de produção,º±±
±±ºDesc.     ³ utilizado para desfazer o ajuste de empenho automático das º±±
±±º          ³ embalagens (para os casos de perda) no momento do estorno  º±±
±±º          ³ do apontamento da ordem de produção.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/           

User Function MT250GREST()

Local _aSavArea 	:= GetArea()
Local _aSavSD4 		:= SD4->(GetArea())
Local _cRotina  	:= "MT250GREST"
Local _cNumOP		:= SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + SC2->C2_ITEMGRD

Private lMsErroAuto := .F. //Armazena o retorno da função execauto
dbSelectArea("SD4") //Empenhos
SD4->(dbSetOrder(2)) 		//D4_FILIAL + D4_OP
SD4->(dbGoTop())
If SD4->(dbSeek(xFilial("SD4") + _cNumOP))
	While !SD4->(EOF()) .AND. SD4->D4_FILIAL == xFilial("SD4") .AND. SD4->D4_OP == _cNumOP
		//Verifica se foi feito o ajuste do empenho de maneira automática, para que o mesmo seja desfeito
		If AllTrim(Upper(SD4->D4_AUTOAJU)) == "S"
			/*
			D4_AUTOAJU 
				- S=Ajuste automático realizado no apontamento da OP
				- E=Ajuste automático estornado	no estorno da OP
			*/
			//Verifica se há ajuste a ser estornado
			// D4_QTDANTE - QUANTIDADE EMPENHO ORIGINAL
			// D4_EMPANTE - SALDO EMPENHO ORIGINAL
			// D4_QTDEORI - QUANTIDADE EMPENHADA
			// D4_QUANT   - SALDO DO EMPENHO
			If SD4->D4_QTDANTE>0 .And. SD4->D4_QTDANTE<>SD4->D4_QUANT .And. SD4->D4_QTDEORI<>SD4->D4_EMPANTE
				//MATA380 - Ajuste de empenhos
				while !RecLock("SD4",.F.) ; enddo
					SD4->D4_QUANT   	:= SD4->D4_EMPANTE
					SD4->D4_AUTOAJU		:= "E"
				SD4->(MsUnlock())
			EndIf
		EndIf
		SD4->(dbSkip())
	EndDo
EndIf

/*
dbSelectArea("SD4") //Empenhos
SD4->(dbSetOrder(2)) 		//D4_FILIAL + D4_OP
SD4->(dbGoTop())
If SD4->(dbSeek(xFilial("SD4") + _cNumOP))
	While !SD4->(EOF()) .AND. SD4->D4_FILIAL == xFilial("SD4") .AND. SD4->D4_OP == _cNumOP
		//Verifica se foi feito o ajuste do empenho de maneira automática, para que o mesmo seja desfeito
		If AllTrim(Upper(SD4->D4_AUTOAJU)) == "S"
			aVetor:=  {	{"D4_COD" 		,SD4->D4_COD		  		,Nil},;
						{"D4_LOCAL" 	,SD4->D4_LOCAL        		,Nil},;
						{"D4_OP" 		,SD4->D4_OP     	  		,Nil},;
						{"D4_DATA" 		,SD4->D4_DATA     	  		,Nil},;
						{"D4_QUANT" 	,SD4->D4_QTDANTE			,Nil},;
						{"D4_QTDEORI"	,SD4->D4_EMPANTE		 	,Nil},;
						{"D4_TRT"		,SD4->D4_TRT    	  		,Nil},;
						{"D4_AUTOAJU"	,'E'		    	  		,Nil} }
			/*
			D4_AUTOAJU 
				- S=Ajuste automático realizado no apontamento da OP
				- E=Ajuste automático estornado	no estorno da OP
			*/
			//Verifica se há ajuste a ser estornado
			// D4_QTDANTE - QUANTIDADE EMPENHO ORIGINAL
			// D4_EMPANTE - SALDO EMPENHO ORIGINAL
			// D4_QTDEORI - QUANTIDADE EMPENHADA
			// D4_QUANT   - SALDO DO EMPENHO
/*			If SD4->D4_QTDANTE>0 .And. SD4->D4_QTDANTE<>SD4->D4_QUANT .And. SD4->D4_QTDEORI<>SD4->D4_EMPANTE
				//MATA380 - Ajuste de empenhos
				nOpc        := 4 // Opção - Alteração
				lMsErroAuto := .F.
				MSExecAuto({|x,y| mata380(x,y)},aVetor,nOpc) //Alteração
				//Verifica se o ajuste foi realizado com sucesso
				If lMsErroAuto
					MsgAlert("Houve uma falha no estorno do empenho do produto: " + AllTrim(Upper(SD4->D4_COD)) + ", anote o erro que será apresentado a seguir e informe ao Administrador do sistema!",_cRotina+"_001")
					//MostraErro()
				EndIf
			EndIf
		EndIf
		dbSelectArea("SD4")
		SD4->(dbSetOrder(2))
		SD4->(dbSkip())
	EndDo
EndIf
*/
//Restauro a área de trabalho original
RestArea(_aSavSD4)
RestArea(_aSavArea)

Return()
