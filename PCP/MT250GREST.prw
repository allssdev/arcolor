#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MT250GREST � Autor �Adriano Leonardo    � Data �25/10/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada ap�s o estorno do apontamento de produ��o,���
���Desc.     � utilizado para desfazer o ajuste de empenho autom�tico das ���
���          � embalagens (para os casos de perda) no momento do estorno  ���
���          � do apontamento da ordem de produ��o.                       ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/           

User Function MT250GREST()

Local _aSavArea 	:= GetArea()
Local _aSavSD4 		:= SD4->(GetArea())
Local _cRotina  	:= "MT250GREST"
Local _cNumOP		:= SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + SC2->C2_ITEMGRD

Private lMsErroAuto := .F. //Armazena o retorno da fun��o execauto
dbSelectArea("SD4") //Empenhos
SD4->(dbSetOrder(2)) 		//D4_FILIAL + D4_OP
SD4->(dbGoTop())
If SD4->(dbSeek(xFilial("SD4") + _cNumOP))
	While !SD4->(EOF()) .AND. SD4->D4_FILIAL == xFilial("SD4") .AND. SD4->D4_OP == _cNumOP
		//Verifica se foi feito o ajuste do empenho de maneira autom�tica, para que o mesmo seja desfeito
		If AllTrim(Upper(SD4->D4_AUTOAJU)) == "S"
			/*
			D4_AUTOAJU 
				- S=Ajuste autom�tico realizado no apontamento da OP
				- E=Ajuste autom�tico estornado	no estorno da OP
			*/
			//Verifica se h� ajuste a ser estornado
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
		//Verifica se foi feito o ajuste do empenho de maneira autom�tica, para que o mesmo seja desfeito
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
				- S=Ajuste autom�tico realizado no apontamento da OP
				- E=Ajuste autom�tico estornado	no estorno da OP
			*/
			//Verifica se h� ajuste a ser estornado
			// D4_QTDANTE - QUANTIDADE EMPENHO ORIGINAL
			// D4_EMPANTE - SALDO EMPENHO ORIGINAL
			// D4_QTDEORI - QUANTIDADE EMPENHADA
			// D4_QUANT   - SALDO DO EMPENHO
/*			If SD4->D4_QTDANTE>0 .And. SD4->D4_QTDANTE<>SD4->D4_QUANT .And. SD4->D4_QTDEORI<>SD4->D4_EMPANTE
				//MATA380 - Ajuste de empenhos
				nOpc        := 4 // Op��o - Altera��o
				lMsErroAuto := .F.
				MSExecAuto({|x,y| mata380(x,y)},aVetor,nOpc) //Altera��o
				//Verifica se o ajuste foi realizado com sucesso
				If lMsErroAuto
					MsgAlert("Houve uma falha no estorno do empenho do produto: " + AllTrim(Upper(SD4->D4_COD)) + ", anote o erro que ser� apresentado a seguir e informe ao Administrador do sistema!",_cRotina+"_001")
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
//Restauro a �rea de trabalho original
RestArea(_aSavSD4)
RestArea(_aSavArea)

Return()
