#include 'protheus.ch'
#include 'FwMVCdef.ch'
static cTitulo := "Configura��es da UF - GNRE Online"
/*/{Protheus.doc} RFISC002
Fun��o de usu�rio para configura��es da UF - GNRE Online
@author Rodrigo Telecio - ALLSS Solu��es em Sistemas (rodrigo.telecio@allss.com.br)
@since 13/04/2022
@version P12.1.33
@type Function
@obs Sem observa��es
@see https://allss.com.br
@history 19/04/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Vers�o inicial de rotina.
@history 13/05/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Adequa��es diversas para GNRE 2.00.
/*/
user function RFISC002()
local aArea   := GetArea()
local oBrowse
//Inst�nciando FWMBrowse - Somente com dicion�rio de dados
oBrowse := FWMBrowse():New()
//Setando a tabela
oBrowse:SetAlias("ZZA")
//Setando a descri��o da rotina
oBrowse:SetDescription(cTitulo)
//Ativa a Browse
oBrowse:Activate()
RestArea(aArea)
return nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  �Rodrigo Telecio       Data � 13/04/2022  ���
�������������������������������������������������������������������������͹��
���Desc.     � Cria��o do menu em MVC.                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal.                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
static function MenuDef()
local aRot := {}    
//Adicionando op��es
ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.RFISC002' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.RFISC002' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.RFISC002' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.RFISC002' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5 
return aRot
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Rodrigo Telecio       Data � 13/04/2022  ���
�������������������������������������������������������������������������͹��
���Desc.     � Cria��o do modelo de dados em MVC.                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal.                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static function ModelDef()
local oModel
local oStruZZA  := FWFormStruct(1,"ZZA")
oModel          := MPFormModel():New("MD_PARAMGNRE") 
oModel:addFields('MASTERZZA',,oStruZZA)
oModel:SetPrimaryKey({'ZZA_FILIAL','ZZA_EST','ZZA_CODREC','ZZA_TIPOGN','ZZA_DOCORI','ZZA_DETREC','ZZA_CODPRO'})
return oModel
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �Rodrigo Telecio       Data � 13/04/2022  ���
�������������������������������������������������������������������������͹��
���Desc.     � Cria��o da vis�o em MVC.                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal.                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static function ViewDef()
local oModel    := ModelDef()
local oView
local oStrZZA   := FWFormStruct(2,'ZZA')
oView           := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('FORM_PARAMGNRE',oStrZZA,'MASTERZZA') 
oView:CreateHorizontalBox('BOX_FORM_PARAMGNRE',100)
oView:SetOwnerView('FORM_PARAMGNRE','BOX_FORM_PARAMGNRE')
return oView
 