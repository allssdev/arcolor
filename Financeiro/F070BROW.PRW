#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F070BROW 	�Autor  �Thiago S. de Almeida �Data �  21/12/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada para Filtrar Titulos na rotina Baixas a,  ���
���          � Receber onde os usuarios poder�o vizualizar os titulos 	  ���
���          � conforme	regra do cadastro da SZ3.                         ���
�������������������������������������������������������������������������͹��
��� SETFKEY  � Inserido trecho para tecla de atalho de par�metro F12      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function F070BROW()

Local _aSavArea := GetArea()

Default aRotina := MenuDef()

// Trecho incluido em 13/11/2013 por J�lio Soares para implementar valida��o do cPerg quanto a par�metros de comiss�es.
If ExistBlock('RFINE012')
	Pergunte("FIN070",.F.)
	MV_PAR05 := 2 // For�a o par�metro para n�o considerar os juros recebidos na base de c�lculo das comiss�es
	//SetKey(VK_F12,{|| })
	//SetKey(VK_F12,{|| U_RFINE012() })
    // Teclas alterada em 19/08/15 por J�lio Soares para n�o conflitar com as teclas de atalho padr�o.
//	SetKey( VK_F12,{|| MsgAlert( "Tecla [ F12 ] foi alterada para [ Ctrl + F12 ]" , "Protheus11" )})
	SetKey( K_CTRL_F12, { || })
	SetKey( K_CTRL_F12, { || U_FINE012()})
EndIf

dbSelectArea("SE1")
_aSavSE1 := SE1->(GetArea())
dbSelectArea("SZ3")
_aSavSZ3 := SZ3->(GetArea())
SZ3->(dbSetOrder(1))
If SZ3->(MsSeek(xFilial("SZ3") + __cUserId,.T.,.F.))
	If __cUserId $ SZ3->Z3_USERREC 
		If ExistBlock("RFINA001")
			_nPosRot := aScan(aRotina,{|x|AllTrim(x[02])=="fA070Lot"})
			If _nPosRot > 0
				aRotina[_nPosRot][02] := "U_RFINA001()"
			EndIf
		EndIf
		dbSelectArea("SE1")
		dbSetOrder(1)
		dbGoTop()
		SET FILTER TO SE1->E1_PORTADO == SZ3->Z3_CODBCRE .AND. SE1->E1_AGEDEP == SZ3->Z3_AGENREC .AND. SE1->E1_CONTA == SZ3->Z3_CONTREC
		dbFilter()
	EndIf
EndIf

RestArea(_aSavSZ3)
RestArea(_aSavSE1)
RestArea(_aSavArea)

Return

// - Fim da valida��o F12
/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �21/11/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static function MenuDef()

Local aRotina := {}

If GetNewPar("MV_ACATIVO",.F.)
	aAdd( aRotina,{"Pesquisar","FA070Pes",0,1,,.F.})
Else
	aAdd( aRotina,{"Pesquisar","AxPesqui",0,1,,.F.})
EndIf

aAdd( aRotina, { "Visualizar", "fa070Visual" , 0 , 2      })
aAdd( aRotina, { "Baixar"    , "fA070Tit"    , 0 , 4      })
aAdd( aRotina, { "Lote"      , "fA070Lot"    , 0 , 4      })
aAdd( aRotina, { "Canc Baixa", "fA070Can"    , 0 , 5      })
aAdd( aRotina, { "Excluir"   , "fA070CAN"    , 0 , 5,52   })
aAdd( aRotina, { "Le&genda"  , "FA040Legenda", 0 , 6, ,.F.})

Return(aRotina)