#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA070MDB 	�Autor  �Thiago S. de Almeida �Data �  21/12/12   ���
���Programa  �          �Autor  �Adriano Leonardo     �Data �  15/08/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada executado na confirma��o da tela de baixa ���
���          � dos titulos a receber, para valida��o no tipo de baixa.    ���
�������������������������������������������������������������������������͹��
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FA070MDB()

Local _aSavArea := GetArea()
Local _cRotina  := "FA070MDB"
Local _lRet     := .T.

dbSelectArea("SZ3")
dbSetOrder(1)
If MsSeek(xFilial("SZ3") + __cUserId,.T.,.F.)
	If __cUserId $ SZ3->Z3_USERREC
		dbSelectArea("SE1")
		dbSetOrder(1)
		IF !((__cUserId $ SuperGetMv("MV_BXFULL" ,,"000000" )+'/000000')) .And. !MovBanco()
			MsgAlert("Motivo de baixa n�o permitido para este usu�rio!",_cRotina+"_001")
			//Para incluir permiss�o para novos usu�rios acrescente o id do usu�rio no par�metro MV_BXFULL
			_lRet := .F.
   		EndIF
   	EndIf
EndIf

RestArea(_aSavArea)

Return(_lRet)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MOVBANCO �Autor  �Adriano Leonardo    � Data �  15/08/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o respons�vel por verificar se o motivo de baixa      ���
���          � escolhido movimenta banco (retorno l�gico).                ���
�������������������������������������������������������������������������͹��
���Uso       � Espec�fico - ARCOLOR - Programa Principal                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function MovBanco() 

	Local _aSavTemp := GetArea()
	Local _cMotBxa := ""
    Local _cDrive  := ""
    Local _cDir	   := CurDir() //Retorna o diret�rio configurado no INI do AppServer
    Local _cNome   := "SIGAADV"
    Local _cExt	   := ".MOT"
    Local _lRet	   := .T.
    
	_cMotBxa := CMOTBX
	
	//Faz a leitura do arquivo de configura��o dos motivos de baixa (SIGAADV.MOT da pasta System)
	FT_FUSE(_cDrive+_cDir+_cNome+_cExt)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	
	If !FT_FEOF()
		While !FT_FEOF()
			_cMotAux := AllTrim(SubStr(FT_FREADLN(),4 ,10))
			If _cMotBxa == _cMotAux //Verifica se � o motivo selecionado � o escolhido pelo usu�rio
				_cMovBan := SubStr(FT_FREADLN(),15,1)
				If _cMovBan=='N'    //Verifica se o motivo escolhido movimenta banco
					_lRet := .F.
				EndIf
				Exit
			EndIf
			FT_FSKIP()
		EndDo
	EndIf
	FT_FUSE()
RestArea(_aSavTemp)

Return(_lRet)