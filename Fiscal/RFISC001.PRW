#include "rwmake.ch"
#include "ap5mail.ch"
#include "topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "PROTHEUS.CH"
#include "MSGRAPHI.CH" 
#include 'topconn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"                           
#INCLUDE "JPEG.CH"
#INCLUDE "AVPRINT.CH"
#INCLUDE "FONT.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "VKEY.CH"  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATC002  � Autor � Renan Felipe       � Data �  18/12/12   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Tabela SX5                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 Arcolor                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function RFISC001()

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private _cAliasSX5 := GetNextAlias()


axCadastro("SX5","Grupos de Tributacao",cVldExc,cVldAlt)

Return