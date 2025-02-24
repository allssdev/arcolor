#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} SIGATMK
@description Fun��o desenvolvida aplicar a rotina de busca avan�ada em todas as telas do m�dulo Call Center.
@author Adriano L. de Souza
@since 05/06/2014
@version 1.0
@type function
@history 24/06/2014, Adriano L. de Souza                               , Implementada a tecla de atalho CTRL+F7 para acesso a rotina "RTMKE029" em diversas rotinas do sistema.
@history 23/01/2020, Anderson C. P. Coelho (ALLSS Solu��es em Sistemas), Rotina documentada no padr�o PDOC.
@history 23/01/2020, Anderson C. P. Coelho (ALLSS Solu��es em Sistemas), Implementada a tecla de atalho CRTL+F11 para acesso a Ficha Financeira ("RFINE011") em diversas rotinas do sistema.
@see https://allss.com.br
/*/
user function SIGATMK()
	if ExistBlock("RTMKE022")
		//Defino tecla de atalho para chamada da rotina de busca avan�ada
		//SetKey(K_CTRL_F5,{|| })
		//SetKey(K_CTRL_F5,{|| U_RTMKE022() })
	    // Teclas alterada em 19/08/15 por J�lio Soares para n�o conflitar com as teclas de atalho padr�o.
		//SetKey( VK_F5,{|| MsgAlert( "Tecla [ F5 ] foi alterada para [ Ctrl + F5 ]" , "Protheus11" )})
		SetKey( K_CTRL_F5, { || })
		SetKey( K_CTRL_F5, { || U_RTMKE022()})
	endif
	if ExistBlock("RTMKE029")
		//Defino tecla de atalho para chamada da rotina de busca avan�ada (por itens - aCols)
		//SetKey(K_CTRL_F7,{|| })
		//SetKey(K_CTRL_F7,{|| U_RTMKE029() })
	    // Teclas alterada em 19/08/15 por J�lio Soares para n�o conflitar com as teclas de atalho padr�o.
		//SetKey( VK_F7,{|| MsgAlert( "Tecla [ F7 ] foi alterada para [ Ctrl + F7 ]" , "Protheus11" )})
		SetKey( K_CTRL_F7, { || })
		SetKey( K_CTRL_F7, { || U_RTMKE029()})
	endif
	if ExistBlock("RFINE011")
		SetKey( K_CTRL_F11, { || })
		SetKey( K_CTRL_F11, { || U_RFINE011("F11")})
	endif
return