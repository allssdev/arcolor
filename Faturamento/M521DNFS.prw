#include 'Protheus.ch'
#include 'RwMake.ch'
#include 'parmtype.ch'
#include 'fivewin.ch'
#include 'tbiconn.ch'
#include 'ap5mail.ch'
#include 'totvs.ch'
#include 'apwebsrv.ch'
#include 'restful.ch'
#include 'xmlxfun.ch'
#include 'tbiconn.ch'
#include 'fileio.ch'

#define _CLRF CHR(13)+CHR(10)

/*/{Protheus.doc} M521DNFS
    @description O ponto de entrada M521DNFS existente na função MaDelNfs será disparado após o fechamento dos lançamentos contábeis onde o retorno deverá ser uma variável lógica. O ponto possui como parâmetro o Array aPedido.  
    @author Livia Della Corte (ALLSS Soluções em Sistemas)
    @since 16/05/2023
    @version 1.0
    @type Function
    @see https://allss.com.br
/*/

User Function M521DNFS()

	Local _aArea     := GetArea()
	//Local cAliasLif  := 'M521DNFS'
	//Local cQuery     := ' '
	local _cMail        := AllTrim(SuperGetMv("MV_XCANNFE",,"liviadellacorte@gmail.com"))
	local cAssunto:=" "
	local LJOB:= .F.


_cMsgMail := ""
_cMsgMail += '<b><font size="3" face="Arial">E-mail enviado atrav&eacute;s do Protheus</font></b><br></BR>' + _CLRF
_cMsgMail += '<font size="2" face="Arial">NF Cancelada. Motivo: '+ Alltrim(SF2->F2_MOTEXCL) +' .</font><p>&nbsp;</P>' + _CLRF
_cMsgMail += '<table border="0" width="100%" bgcolor="#FFFFFF">' + _CLRF
_cMsgMail += '<tr>' + _CLRF
_cMsgMail += '   <td width="30%"><font size="3" face="Arial"><b>NF       </b></font></td>' + _CLRF
_cMsgMail += '   <td width="30%"><font size="3" face="Arial"><b>Serie        </b></font></td>' + _CLRF
_cMsgMail += '   <td width="20%"><font size="3" face="Arial"><b>Cliente        </b></font></td>' + _CLRF
_cMsgMail += '   <td width="20%"><font size="3" face="Arial"><b>Emissão    </b></font></td>' + _CLRF
_cMsgMail += '</tr>' + _CLRF
_cMsgMail += '<tr>' + _CLRF
_cMsgMail += '   <td width="30%"><font size="2" face="Arial"> '  + AllTrim(SF2->F2_DOC) + ' </font></td>' + _CLRF
_cMsgMail += '   <td width="30%"><font size="2" face="Arial"> '  + AllTrim(SF2->F2_SERIE) +  ' </font></td>' + _CLRF
_cMsgMail += '   <td width="20%"><font size="2" face="Arial"> '  + AllTrim(SF2->F2_DOC) + ' </font></td>' + _CLRF
_cMsgMail += '   <td width="20%"><font size="2" face="Arial"> '  + substr(dtos(SF2->F2_EMISSAO),7,2) + '/'+ substr(dtos(SF2->F2_EMISSAO),5,2)+'/'+substr(dtos(SF2->F2_EMISSAO),1,4) + ' </font></td>' + _CLRF
_cMsgMail += '</tr>' + _CLRF
_cMsgMail += '</table>' + _CLRF
_cMsgMail += '<br><br><p><i>OBS.: E-mail enviado automaticamente pelo sistema. Por favor não responda!</i></p>' + _CLRF
_cMsgMail += '<br><br><br><p align="center"><a href="https://allss.com.br"><img style="border: none; width: 80px; max-width: 80px !important; height: 150px; max-height: 50px !important;" src="https://allss.com.br/allssmail.jpg" alt="ALL System Solutions"/></a><br><a href="https://allss.com.br"><i><font face="Arial" size=1 color="#808080">Powered by ALLSS Soluções em Sistemas.</font></i></a></p><br>' + _CLRF

cAssunto:= "Cancelamento NF: " + AllTrim(SF2->F2_DOC) +" /"+ AllTrim(SF2->F2_SERIE)  + "Cliente: " + alltrim( SA1->A1_NOME) 

U_RCFGM001(	cCadastro ,;
			_cMsgMail,;
			_cMail,;
			,;
			,;
			,;
			cAssunto,;
			.F. ,;
			!lJob )	
Restarea(_aArea)

Return .T.
