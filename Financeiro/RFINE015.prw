#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"
/*/{Protheus.doc} RFINE015
@description Rotina responsável pelo envio de e-mails para o cliente com Danfe, romaneio de entrega e boletos, sendo este envio executado em segundo plano via job para não comprometer o desempenho do sistema por conta de possível lentidão com a Internet.
@author Adriano Leonardo
@since 09/10/2013
@version 1.0
@param cTitulo, caracter, Título do e-mail
@param _cMensagem, caracter, mensagem do e-mail
@param _cMail, caracter, E-mail destinatário
@param _cAnexo, , Caminho do anexo
@param _cFromOri, , E-mail do remetente
@param _cCco, , E-mail que receberá uma cópia da mensagem
@type function
@see https://allss.com.br
/*/
user function RFINE015(cTitulo,_cMensagem,_cMail,_cAnexo,_cFromOri,_cCco)
	Local _aSavArea := GetArea()
	Local _cEmp     := IIF( type("cNumEmp")<>"U", SubStr(cNumEmp,1,2), "01" )
	Local _cFil     := IIF( type("cNumEmp")<>"U", SubStr(cNumEmp,3,2), "01" )
	Local _cRotina  := "RFINE015"

	If type("cFilAnt")=="U"
		//Seto as configurações de ambiente
		//RpcClearEnv()
		//RpcSetType(3)
		//RpcSetEnv( "01" ,"01",,,'FIN',GetEnvServer())
		PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFil FUNNAME _cRotina
		SetModulo( "SIGAFIN", "FIN" )
	EndIf
	If ExistBlock("RCFGM001")
		U_RCFGM001(cTitulo,_cMensagem,_cMail,_cAnexo,_cFromOri,_cCco) //Chamada da rotina responsável pelo envio de e-mails
	EndIf
	RestArea(_aSavArea)
return