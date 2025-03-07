#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MT450FIM  �Autor  � J�lio Soares       � Data �  25/10/2013���
���          �           �Autor  � J�lio Soares       � Data �  24/03/2014���
���          �           �Autor  � J�lio Soares       � Data �  11/07/2016���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada utilizado para gravar status do atendi-   ���
���          � mento para libera��o de cr�dito.                           ���
�������������������������������������������������������������������������͹��
���          � Trecho inserido para que o log de atualiza��o seja gravado ���
���          � tamb�m na tabela SC5 (Pedido de vendas)                    ���
�������������������������������������������������������������������������͹��
���          � Trecho inserido para que a data de libera��o do cr�dito    ���
���          � seja gravada em campo espec�fico.                          ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para empresa Arcolor.              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT450FIM()

Local _aSavArea := GetArea()
Local _aSavSUA  := SUA->(GetArea())
Local _aSavSA1  := SA1->(GetArea())
Local _aSavSC5  := SC5->(GetArea())
Local _aSavSC9  := SC9->(GetArea())
Local _cRotina  := "MT450FIM"
Local _cLogx    := "Cr�dito Liberado Manualmente."
Local _cNumPed  := SC9->C9_PEDIDO
Local _lEnt     := CHR(13) + CHR (10)

Private _cLog   := ""

If Type("aTmpFil")=="U"
	Public aTmpFil := {}
EndIf
If Type("aSelFil")=="U"
	Public aSelFil := {}
EndIf
dbSelectArea("SUA")
SUA->(dbOrderNickName("UA_NUMSC5"))
If SUA->(MsSeek(xFilial("SUA")+_cNumPed,.T.,.F.)) .AND. SUA->(FieldPos("UA_LOGSTAT")) > 0
	_cLog := Alltrim(SUA->UA_LOGSTAT)
	RecLock("SUA",.F.)
		SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
							UsrRetName(__cUserId) + _lEnt + _cLogx
	SUA->(MsUnLock())
EndIf
// - Trecho inserido em 24/03/2014 por J�lio Soares para gravar status tamb�m no quadro de vendas.
dbSelectArea("SC5")
SC5->(dbSetOrder(1)) //C5_FILIAL+C5_NUM
If SC5->(MsSeek(xFilial("SC5")+_cNumPed,.T.,.F.)) .AND. SUA->(FieldPos("UA_LOGSTAT")) > 0
	_cLog := Alltrim(SC5->C5_LOGSTAT)
	RecLock("SC5",.F.)
		SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
							UsrRetName(__cUserId) + _lEnt + _cLogx
	SC5->(MsUnLock())
EndIf
//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
If ExistBlock("RFATL001")
	U_RFATL001(	SC5->C5_NUM  ,;
				SUA->UA_NUM,;
				_cLogx     ,;
				_cRotina    )
EndIf
// - Fim
// Trecho inserido por Arthur Silva em 15/08/16, para preencher o campo "C5_DTLIBCR"
dbSelectArea("SC5")
SC5->(dbSetOrder(1)) //C5_FILIAL+C5_NUM
If SC5->(MsSeek(xFilial("SC5")+_cNumPed,.T.,.F.))
	RecLock("SC5",.F.)
		SC5->C5_DTLIBCR:= dDataBase
	SC5->(MsUnLock())
EndIf
// - Fim
// Trecho inserido em 11/07/2016 por J�lio Soares para que a data da libera��o do cr�dito seja gravada
dbSelectArea("SC9")
SC9->(dbSetOrder(1))		//C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
If SC9->(MsSeek(xFilial("SC9")+_cNumPed,.T.,.F.))
	If SC9->(FieldPos("C9_DTLIBCR")) > 0
		While !SC9->(EOF()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. SC9->C9_PEDIDO == _cNumPed
			RecLock("SC9",.F.)
				SC9->C9_DTLIBCR := dDataBase 
			SC9->(MsUnlock())
			dbSelectArea("SC9")
			SC9->(dbSetOrder(1))		//C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
			SC9->(dbSkip())
		EndDo
	Else 
		MSGBOX('O campo C9_DTLIBCR n�o existe no banco de dados, informe o administrador do sistema',_cRotina+'_001','')
	EndIf
EndIf
// - Fim trecho

// DESATIVADO ALTERA��O DAS TECLAS DE ATALHO EM 21/08/15 POR J�LIO SOARES AP�S SOLICITA��O DO SR. MARIO
SetKey(VK_F7 , { || _ALTERPED()})
// Teclas alterada em 19/08/15 por J�lio Soares para n�o conflitar com as teclas de atalho padr�o.
//SetKey( VK_F7,{|| MsgAlert( "Tecla [ F7 ] foi alterada para [ Ctrl + F7 ]" , "Protheus11" )})
//SetKey( K_CTRL_F7, { || })
//SetKey( K_CTRL_F7, { || _ALTERPED()})

// DESATIVADO ALTERA��O EM 21/08/15 POR J�LIO SOARES AP�S SOLICITA��O DO SR. MARIO
SetKey(VK_F8 , { || _ALTER()      })
// Teclas alterada em 19/08/15 por J�lio Soares para n�o conflitar com as teclas de atalho padr�o.
//SetKey( VK_F8,{|| MsgAlert( "Tecla [ F8 ] foi alterada para [ Ctrl + F8 ]" , "Protheus11" )})
//SetKey( K_CTRL_F8, { || })
//SetKey( K_CTRL_F8, { || _ALTER()})

// DESATIVADO ALTERA��O EM 21/08/15 POR J�LIO SOARES AP�S SOLICITA��O DO SR. MARIO
SetKey(VK_F9 , { || FICHCON("PED")})
// Teclas alterada em 19/08/15 por J�lio Soares para n�o conflitar com as teclas de atalho padr�o.
//SetKey( VK_F9,{|| MsgAlert( "Tecla [ F9 ] foi alterada para [ Ctrl + F9 ]" , "Protheus11" )})
//SetKey( K_CTRL_F9, { || })
//SetKey( K_CTRL_F9, { || FICHCON("PED")})

// DESATIVADO ALTERA��O EM 21/08/15 POR J�LIO SOARES AP�S SOLICITA��O DO SR. MARIO
SetKey(VK_F10, { || FICHCON("FAT")})                                    
// Teclas alterada em 19/08/15 por J�lio Soares para n�o conflitar com as teclas de atalho padr�o.
//SetKey( VK_F10,{|| MsgAlert( "Tecla [ F10 ] foi alterada para [ Ctrl + F10 ]" , "Protheus11" )})
//SetKey( K_CTRL_F10, { || })
//SetKey( K_CTRL_F10, { || FICHCON("FAT")})

// DESATIVADO ALTERA��O EM 21/08/15 POR J�LIO SOARES AP�S SOLICITA��O DO SR. MARIO
SetKey(VK_F11, { || FICHFINAN()   })
// Teclas alterada em 19/08/15 por J�lio Soares para n�o conflitar com as teclas de atalho padr�o.
//SetKey( VK_F11,{|| MsgAlert( "Tecla [ F11 ] foi alterada para [ Ctrl + F11 ]" , "Protheus11" )})
//SetKey( K_CTRL_F11, { || })
//SetKey( K_CTRL_F11, { || FICHFINAN()})

RestArea(_aSavSUA )
RestArea(_aSavSA1 )
RestArea(_aSavSC5 )
RestArea(_aSavSC9 )
RestArea(_aSavArea)

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �_ALTERPED �Autor  �J�lio Soares        � Data �  29/01/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o de altera��o do pedido de vendas posicionado,       ���
���          �acionado pela tecla F7.                                     ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function _ALTERPED()

If ExistBlock("RFATE035")
	Execblock("RFATE035")
Else
	MSGBOX('Fun��o n�o encontrada, informe o Administrador do sistema',_cRotina+'_001','ALERT')
EndIf

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � _Alter  �Autor  �J�lio Soares         � Data �  23/12/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Tecla de atalho para realizar a altera��o do cadastro      ���
���          � posicionado.                                               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal.                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*
Static Function _ALTER()

If MSGBOX('Deseja alterar o cadastro do cliente '+(SA1->A1_NOME)+'?',_cRotina + '_01','YESNO')
	A030Altera('SA1',(Recno()),3)
Endif

Return()
*/
Static Function _ALTER()

Local _aSavArea  := GetArea()
Local _lIncui    := INCLUI
Local _lAltera   := ALTERA
Private _cCli    := SC5->C5_CLIENTE
Private _cLoja   := SC5->C5_LOJACLI
Private _cNome   := SC5->C5_NOMCLI

Private aRotAuto := Nil

dbSelectArea("SA1")
_aSavSA1 := SA1->(GetArea())
SA1->(dbSetOrder(1))
If MSGBOX('Deseja alterar o cadastro do cliente '+ Alltrim(_cNome) +'?',_cRotina + '_002','YESNO')
	If SA1->(MsSeek(xFilial("SA1")+_cCli+_cLoja,.T.,.F.))
		nReg   := SA1->(Recno())
		INCLUI := .F.
		ALTERA := .T.
	//	A030Altera("SA1",nReg,4)
		AxAltera("SA1",nReg,4)
	Else
		MSGBOX('Cliente' + _cCli +' - ' + Alltrim(_cNome) + ' N�o encontrado, INFORME O ADMINISTRADOR DO SISTEMA.',_cRotina + '_003','ALERT')
	EndIf
	INCLUI := _lIncui
	ALTERA := _lAltera
EndIf

RestArea(_aSavSA1 )
RestArea(_aSavArea)

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FICHCON  �Autor  �J�lio Soares        � Data �  23/12/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Chamada da Ficha de consulta do Pedido/Faturamentos do     ���
���          �cliente esta rotina � acionada pelas teclas F9 e F10.       ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal.                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
// - F9/F10
Static Function FICHCON(_Tp)

Local   _aSavArea := GetArea()
Local   _aSavSA1  := {}
Local   _aSavSC5  := {}
Local   _aAlias   := {}
Local   _aGet     := {"","","",""}
Local   _aParam   := {}
Local   _aSavPar  := {}
Local   _nSeq     := 1
Local   _nBrowse  := 0
Local   _lPerg    := .F.

Private _cCli     := SC5->C5_CLIENTE
Private _cLoja    := SC5->C5_LOJACLI
Private _cNome    := SC5->C5_NOMCLI

DEFAULT _Tp := "PED"

//Salvo as perguntas iniciais
/* FB - RELEASE 12.1.23
While Type(("MV_PAR"+StrZero(_nSeq,2)))<>"U"
	AADD(_aSavPar, {("MV_PAR"+StrZero(_nSeq,2)), &("MV_PAR"+StrZero(_nSeq,2)) } )
	_nSeq++
EndDo
*/
_bTYPE := "Type(('MV_PAR'+StrZero(_nSeq,2)))"
While &(_bTYPE) <> "U"
	AADD(_aSavPar, {("MV_PAR"+StrZero(_nSeq,2)), &("MV_PAR"+StrZero(_nSeq,2)) } )
	_nSeq++
EndDo

lExibe    := .T. // - Informa se a pesquisa deve ser exibida.
lRelat    := .F. 
nCasas    := SuperGetMv("MV_CENT",,"2")
If Pergunte("FIC010",AllTrim(FunName())=="FINC010") .OR. AllTrim(FunName())<>"FINC010"
	AADD(_aParam,MV_PAR01)
	AADD(_aParam,MV_PAR02)
	AADD(_aParam,MV_PAR03)
	AADD(_aParam,MV_PAR04)
	AADD(_aParam,MV_PAR05)
	AADD(_aParam,MV_PAR06)
	AADD(_aParam,MV_PAR07)
	AADD(_aParam,MV_PAR08)
	AADD(_aParam,MV_PAR09)
	AADD(_aParam,MV_PAR10)
	AADD(_aParam,MV_PAR11)
	AADD(_aParam,MV_PAR12)
	AADD(_aParam,MV_PAR13)
	AADD(_aParam,MV_PAR14)
	AADD(_aParam,MV_PAR15)
EndIf
dbSelectArea("SC5")
_aSavSC5 := SC5->(GetArea())
If UPPER(AllTrim(FunName())) == "MATA450"
	SC5->(dbSetOrder(1))
	If SC5->(MsSeek(xFilial("SC5") + SC9->C9_PEDIDO,.T.,.F.))
		_cCli     := SC5->C5_CLIENTE
		_cLoja    := SC5->C5_LOJACLI
		_cNome    := SC5->C5_NOMCLI
	EndIf
EndIf
dbSelectArea("SA1")
_aSavSA1 := SA1->(GetArea())
SA1->(dbSetOrder(1))
If SA1->(MsSeek(xFilial("SA1")+_cCli+_cLoja,.T.,.F.))
	If _Tp == "PED"
		_nBrowse := 3
		_aAlias  := {}
	//	Fc010Con(cAlias,nRecno,nOpcx) // - Apresenta a tela da posi��o do cliente
		Fc010Brow(_nBrowse,@_aAlias,_aParam,.T.,_aGet)
		For _x := 1 To Len(_aAlias)
			dbSelectArea(_aAlias[_x][01])
			(_aAlias[_x][01])->(dbCloseArea())
			If File(_aAlias[_x][02]+OrdBagExt())
				FErase(_aAlias[_x][02]+OrdBagExt())
			EndIf
		Next
		_nBrowse := 0
		_aAlias  := {}
		_aParam  := {}	
	ElseIf _Tp == "FAT"
		_nBrowse := 4
		_aAlias  := {}
	//	Fc010Con() // - Apresenta a tela da posi��o do cliente
		Fc010Brow(_nBrowse,@_aAlias,_aParam,.T.,_aGet)
		For _x := 1 To Len(_aAlias)
			dbSelectArea(_aAlias[_x][01])
			(_aAlias[_x][01])->(dbCloseArea())
			If File(_aAlias[_x][02]+OrdBagExt())
				FErase(_aAlias[_x][02]+OrdBagExt())
			EndIf
		Next
		_nBrowse := 0
		_aAlias  := {}
		_aParam  := {}
	EndIf
EndIf	

//Restauro as perguntas iniciais
For _x := 1 To Len(_aSavPar)
	&(_aSavPar[_x][01]) := _aSavPar[_x][02]
Next

RestArea(_aSavSC5 )
RestArea(_aSavSA1 )
RestArea(_aSavArea)

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FICHFINAN �Autor  �J�lio Soares        � Data �  17/10/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock utilizado para montar a ficha financeira do      ���
���          � cliente.                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal.                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function FICHFINAN()

Local _aSavArea := GetArea()
Local _aSavSA1  := {}
Local _aSavSC5  := {}

Public _cClir   := SC5->C5_CLIENTE
Public _cLojr   := SC5->C5_LOJACLI
Public _cNomr   := SC5->C5_NOMCLI
Public _cCGCr   := SC5->C5_CGCCENT

dbSelectArea("SC5")
_aSavSC5 := SC5->(GetArea())
If UPPER(AllTrim(FunName())) == "MATA450"
	SC5->(dbSetOrder(1))
	If SC5->(MsSeek(xFilial("SC5") + SC9->C9_PEDIDO,.T.,.F.))
		_cClir := SC5->C5_CLIENTE
		_cLojr := SC5->C5_LOJACLI
		_cNomr := SC5->C5_NOMCLI
		_cCGCr := SC5->C5_CGCCENT
	EndIf
EndIf
dbSelectArea("SA1")
_aSavSA1 := SA1->(GetArea())
SA1->(dbSetOrder(1))
SA1->(MsSeek(xFilial("SA1")+_cClir+_cLojr,.T.,.F.))
If ExistBlock("RFINE011")
	ExecBlock("RFINE011")
Else
	MSGBOX('FUN��O N�O ENCONTRADA, INFORME O ADMINISTRADOR DO SISTEMA.',_cRotina + '_004','ALERT')
EndIf

_cClir := ""
_cLojr := ""
_cNomr := ""
_cCGCr := ""

RestArea(_aSavSA1 )
RestArea(_aSavSC5 )
RestArea(_aSavArea)

Return()