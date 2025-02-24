#INCLUDE 'Protheus.ch'
#INCLUDE 'rwmake.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RCFGM002  �Autor  �Microsiga           � Data �  07/24/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � Fonte criado para receber par�metros de outras rotinas e   ���
���          � enviar mensagens via workflow para usuarios.               ���
�������������������������������������������������������������������������͹��
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa Arcolor                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RCFGM002(_cDe,_cPara,_cAssunt,_cCorp,_cPrior)

Local cDe     := _cDe     // - REMETENTE
Local cPara   := _cPara   // - DESTINAT�RIO
Local cAssunt := _cAssunt // - ASSUNTO
Local cCorpo  := _cCorp   // - CORPO DA MENSAGEM
Local cPrior  := _cPrior  //   �0� � Alta,   �1� � Normal, �2� - Baixa

WFMessenger(cDe,cPara,cAssunt,cCorpo,cPrior)

Return()