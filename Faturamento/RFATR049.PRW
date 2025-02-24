#INCLUDE "PROTHEUS.CH"
#include "RWMAKE.ch"
#include "Colors.ch"
#include "Font.ch"
#Include "HBUTTON.CH"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE 'parmtype.ch'
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH
#INCLUDE "SHELL.CH

#DEFINE _lEnt CHR(13) + CHR(10)

/*/{Protheus.doc} RFATR049
@description Email para aviso de pedido liberado em duplicidade
@author Livia Della Corte
@since 19/02/2020
@version 1.0
@history 19/02/2020, 
@param  PE na liberação de Venda
@type function
@see https://allss.com.br
/*/
user function RFATR049(_cNum)

local _cQry 	:= ""
local _cChv 	:= ""
local _aResu	:= {}
local _cRotina  := "RFATR049"
local _tAlias	:= "TMPRFT49"
local _aMail	:= {}

If Type("cFilAnt")=="U"
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" FUNNAME _cRotina
EndIf


 	_cQry += " SELECT C9_PEDIDO, C6_EMISSAO, QTDLIB ,C6_QTDVEN, C6_NUM, C9_LOJA ,C9_CLIENTE, C9_NFISCAL
 	_cQry += " 	FROM SC6010 (nolock)
 	_cQry += " JOIN (select C9_NFISCAL, C9_PEDIDO C9_PEDIDO, C9_PRODUTO C9_PRODUTO , C9_CLIENTE, C9_LOJA,   SUM(C9_QTDLIB) QTDLIB
 	_cQry += "			from SC9010 (nolock) 
 	_cQry += "			where    C9_DATALIB >= '20200101' AND C9_PEDIDO ='" + _cNum + "' "  
 	_cQry += "			and SC9010.D_E_L_E_T_ = '' 
 	_cQry += "			group by  C9_NFISCAL, C9_PEDIDO, C9_PRODUTO,C9_CLIENTE,C9_LOJA) AS REC ON  C9_PEDIDO = C6_NUM and C9_PRODUTO = C6_PRODUTO 
 	_cQry += "  where QTDLIB > C6_QTDVEN

_cQry := ChangeQuery(_cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_tAlias,.T.,.F.)

_cChv:= ""
dbSelectArea(_tAlias)
(_tAlias)->(dbGoTop())
while !(_tAlias)->(EOF())

	If _cChv <> (_tAlias)->C9_PEDIDO + (_tAlias)->C6_EMISSAO + (_tAlias)->C9_LOJA + (_tAlias)->C9_CLIENTE
		_cChv := (_tAlias)->C9_PEDIDO + (_tAlias)->C6_EMISSAO+ (_tAlias)->C9_LOJA + (_tAlias)->C9_CLIENTE
		_aResu:=  {(_tAlias)->C9_PEDIDO ,(_tAlias)->C6_EMISSAO,(_tAlias)->C9_CLIENTE,(_tAlias)->C9_LOJA,(_tAlias)->C6_QTDVEN, (_tAlias)->QTDLIB}
		AADD(_aMail, _aResu)		
	EndIf	

	(_tAlias)->(dbSkip())
EndDo
(_tAlias)->(dbCloseArea())
If Len(_aMail)
	envMailLead(_aMail)	
Endif

return()

/*/{Protheus.doc} ValidPerg
@description Perguntas do usuário.
@author Júlio Soares
@since 05/07/2016
@version 1.0
@param lJob   , lógico, Indica a execução via JOB.
@param _aMail , array, Variável que traz os relatórios a serem enviados por e-mail.
@type function
@see https://allss.com.br
/*/

static function envMailLead (_aMail)
//	Local	_cMail    := iif(_lJob,SUPERGETMV("MV_LDMAIL",.F.,"livia.dcorte@allss.com.br"), UsrRetMail(RetCodUsr()))  //+  _cMvLeadMail
	Local	_cMail    :=SUPERGETMV("MV_ARDUPC9",.F.,"anderson.coelho@allss.com.br;rodrigo.telecio@allss.com.br") + ";"+ UsrRetMail(RetCodUsr())
	Local 	_cMsgMail := ""
	Local	_dData    := SUBSTR( dtos(date()),7,2)+"/"+SUBSTR( dtos(date()),5,2)+"/"+SUBSTR( dtos(date()),1,4) 

	_cMsgMail := ""
	_cMsgMail += '<table   width="80%"><font size="4" face="Arial"><b><br>Pedido Liberado em Duplicidade</b></font></TABLE>' 
	_cMsgMail += '<table border="1"  width="80%" bgcolor="#FFFFF0">' 
	_cMsgMail += '<tr bgcolor= "#efeff8">'
	_cMsgMail += '   <th width="15%" bgcolor= "#efeff8"><font size="3" face="Arial"><b>Pedido</b></font></td>' 
	_cMsgMail += '   <th width="20%" bgcolor= "#efeff8"><font size="3" face="Arial"><b>Cliente</b></font></td>' 
	_cMsgMail += '   <th width="11%" bgcolor= "#efeff8"><font size="3" face="Arial"><b>Loja</b></font></td>' 
	_cMsgMail += '   <th width="20%" bgcolor= "#efeff8"><font size="3" face="Arial"><b>Emissao</b></font></td>'
	_cMsgMail += '   <th width="17%" bgcolor= "#efeff8"><font size="3" face="Arial"><b>Qtd Vendida</b></font></td>'
	_cMsgMail += '   <th width="17%" bgcolor= "#efeff8"><font size="3" face="Arial"><b>Qtd Liberada</b></font></td>'
	_cMsgMail += '</tr>' 

	for nX := 1 to len(_aMail)
		_cMsgMail += '<tr>' 		
		_cMsgMail += '   <th width="15%" bgcolor= "#efeff8"><font size="3" face="Arial">' + _aMail[nX][1] + '</font></td>' 
		_cMsgMail += '   <th width="20%" bgcolor= "#efeff8"><font size="3" face="Arial">' + _aMail[nX][3] + '</font></td>' 
		_cMsgMail += '   <th width="11%" bgcolor= "#efeff8"><font size="3" face="Arial">' + _aMail[nX][4] + '</font></td>' 
		_cMsgMail += '   <th width="20%" bgcolor= "#efeff8"><font size="3" face="Arial">' + _aMail[nX][2] + '</font></td>'
		_cMsgMail += '   <th width="17%" bgcolor= "#efeff8"><font size="3" face="Arial">' + cvaltochar(_aMail[nX][5]) + '</font></td>'
		_cMsgMail += '   <th width="17%" bgcolor= "#efeff8"><font size="3" face="Arial">' + cvaltochar(_aMail[nX][6]) + '</font></td> </Tr>'
	Next

	_cMsgMail += '</table>'
	_cMsgMail += '<p><b><font size="1" face="Arial">     | E-mail enviado atrav&eacute;s do Protheus | Por favor não responda |</font></b><br></BR>' 

	 If ExistBlock("RCFGM001")
		U_RCFGM001	(	  /*_cTitulo*/		,	;
					_cMsgMail /*_cMsg*/	,	;
					_cMail  /*_cMail*/	,	;
				    "_cFileTmp" 			,	;
					/*_cFromOri*/		,	;
					/*_cBCC*/			,	;
					" | Arcolor | Atenção!! Pedido(s) liberado em Duplicidade | " /*_cAssunto*/,;
					.T. /*_lExcAnex*/	,	;
					.F. /*_lAlert*/			)
	EndIf
return .T.
