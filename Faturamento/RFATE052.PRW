#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFATE052  �Autor  �J�lio Soares       � Data �  22/07/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � ExecBlock criado para atualizar o campo de observa��es     ���
���          � gen�ricas quando o CNPJ Central do cliente for alterado.   ���
�������������������������������������������������������������������������͹��
���          � Esse ExecBlock foi criado em paralelo conforme o ID-1267   ���
���          � ap�s altera��o do processo realizado pelo cliente.         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - espec�fico empresa ARCOLOR                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User function RFATE052()

Local _lEnt := + CHR(13) + CHR(10)

_cCGC1   := M->(A1_CGCCENT)
_cCGC2   := SA1->(A1_CGCCENT)
_cObs    := Alltrim(SA1->(A1_OBSGENR))
_cUsrNom := ''
_cObserv := ''

If _cCGC1 <> _cCGC2 .And. ALTERA
	If PswSeek(__cUserId, .T.)
		_cUsrNom := Alltrim(PswRet()[1][4])
	EndIf
	If FieldPos("A1_OBSGENR")<>0
		If !Empty(SA1->A1_OBSGENR)
			_cObserv := _cObs + _lEnt +'CNPJ central alterado de '+ Transform(_cCGC2,PesqPict("SA1","A1_CGC")) +' para ' +;
			 Transform(_cCGC1,PesqPict("SA1","A1_CGC")) + ' em ' + DTOC(Date()) + ' por ' + (_cUsrNom) + '.' + _lEnt
		Else
			_cObserv := 'CNPJ central alterado de '+ Transform(_cCGC2,PesqPict("SA1","A1_CGC")) +' para ' + Transform(_cCGC1,PesqPict("SA1","A1_CGC")) +;
			 ' em ' + DTOC(Date()) + ' por ' + (_cUsrNom) + '.' + _lEnt
		EndIf
	EndIf
EndIf

Return(_cObserv)