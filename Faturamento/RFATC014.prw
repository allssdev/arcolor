#include 'protheus.ch'
#include 'rwmake.ch'
#include 'parmtype.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RFATC014  ºAutor  ³Anderson C. P. Coelho º Data ³ 05/12/16 º±±
±±ºPrograma  ³ RFATC014  ºAutor  ³                      º Data ³   /  /   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Execblock utilizado para carregar as teclas 'F' para os    º±±
±±º          ³pedidos. Este é chamado em diversos Pontos de Entrada,      º±±
±±º          ³facilitando assim a sua manutenção.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//05/12/2016 - construção em andamento...

User Function RFATC014(_cRotina,_aFAtu)

Local _aSavAreaX := GetArea()
Local _aSavSA1X  := SA1->(GetArea())
Local _aSavSA2X  := SA2->(GetArea())
Local _aSavSB1X  := SB1->(GetArea())
Local _aSavSUAX  := SUA->(GetArea())
Local _aSavSUBX  := SUB->(GetArea())
Local _aSavSC5X  := SC5->(GetArea())
Local _aSavSC6X  := SC6->(GetArea())
Local _aSavSC9X  := SC9->(GetArea())
Local _aSavSF2X  := SF2->(GetArea())
Local _aSavSD2X  := SD2->(GetArea())
Local _aSavSF1X  := SF1->(GetArea())
Local _aSavSD1X  := SD1->(GetArea())
Local _aSavSE1X  := SE1->(GetArea())
Local _aSavSE2X  := SE2->(GetArea())
Local _aSavSE5X  := SE5->(GetArea())
Local _aSavSL2X  := SL2->(GetArea())
Local _aSavSL4X  := SL4->(GetArea())
Local _cRotinaX  := "RFATC014"

Default _aFAtu   := {}
Default _cRotina := _cRotinaX

//HELP PROTHEUS
If aScan(_aFAtu,"VK_F1") > 0
	//NÃO UTILIZAR ESTA TECLA DE ATALHO
EndIf
//
If aScan(_aFAtu,"VK_F2") > 0
	SetKey(VK_F2, { ||  })
EndIf
//CONSULTAS PADRÃO
If aScan(_aFAtu,"VK_F3") > 0
	//NÃO UTILIZAR ESTA TECLA DE ATALHO
EndIf
//
If aScan(_aFAtu,"VK_F4") > 0
	SetKey(VK_F4, { ||  })
EndIf
//
If aScan(_aFAtu,"VK_F5") > 0
	SetKey(VK_F5, { ||  })
EndIf
//
If aScan(_aFAtu,"VK_F6") > 0
	SetKey(VK_F6, { ||  })
EndIf
//
If aScan(_aFAtu,"VK_F7") > 0
	SetKey(VK_F7, { ||  })
EndIf
//
If aScan(_aFAtu,"VK_F8") > 0
	SetKey(VK_F8, { ||  })
EndIf
//
If aScan(_aFAtu,"VK_F9") > 0
	SetKey(VK_F9, { ||  })
EndIf
//
If aScan(_aFAtu,"VK_F10") > 0
	SetKey(VK_F10, { ||  })
EndIf
//FICHA FINANCEIRA
If aScan(_aFAtu,"VK_F11") > 0
	SetKey(VK_F11, { ||  })
EndIf
If aScan(_aFAtu,"VK_F12") > 0
	SetKey(VK_F12, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_F1") > 0
	SetKey(K_CTRL_F1, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_F2") > 0
	SetKey(K_CTRL_F2, { ||  })
EndIf
//CONSULTAS PADRÃO
If aScan(_aFAtu,"K_CTRL_F3") > 0
	SetKey(K_CTRL_F3, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_F4") > 0
	SetKey(K_CTRL_F4, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_F5") > 0
	SetKey(K_CTRL_F5, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_F6") > 0
	SetKey(K_CTRL_F6, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_F7") > 0
	SetKey(K_CTRL_F7, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_F8") > 0
	SetKey(K_CTRL_F8, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_F9") > 0
	SetKey(K_CTRL_F9, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_F10") > 0
	SetKey(K_CTRL_F10, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_F11") > 0
	SetKey(K_CTRL_F11, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_F12") > 0
	SetKey(K_CTRL_F12, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_A") > 0
	SetKey(K_CTRL_A, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_B") > 0
	SetKey(K_CTRL_B, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_C") > 0
	//NÃO UTILIZAR ESTA TECLA DE ATALHO
EndIf
//
If aScan(_aFAtu,"K_CTRL_D") > 0
	SetKey(K_CTRL_D, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_E") > 0
	SetKey(K_CTRL_E, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_F") > 0
	SetKey(K_CTRL_F, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_G") > 0
	SetKey(K_CTRL_G, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_H") > 0
	SetKey(K_CTRL_H, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_I") > 0
	SetKey(K_CTRL_I, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_J") > 0
	SetKey(K_CTRL_J, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_K") > 0
	SetKey(K_CTRL_K, { ||  })
EndIf
//CONTROLE DE LOG DOS PEDIDOS
If aScan(_aFAtu,"K_CTRL_L") > 0 .AND. ExistBlock("RFATL001")
	SetKey(K_CTRL_L, { ||  })
	SetKey(K_CTRL_L, { || U_RFATL001(SUA->UA_NUMSC5,POSICIONE('SUA',1,xFilial('SUA')+SUA->UA_NUM,'UA_NUM'),'',_cRotina,)})
EndIf
//
If aScan(_aFAtu,"K_CTRL_M") > 0
	SetKey(K_CTRL_M, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_N") > 0
	SetKey(K_CTRL_N, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_O") > 0
	SetKey(K_CTRL_O, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_P") > 0
	SetKey(K_CTRL_P, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_Q") > 0
	SetKey(K_CTRL_Q, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_R") > 0
	SetKey(K_CTRL_R, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_S") > 0
	SetKey(K_CTRL_S, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_T") > 0
	SetKey(K_CTRL_T, { ||  })
EndIf
//
If aScan(_aFAtu,"K_CTRL_U") > 0
	SetKey(K_CTRL_U, { ||  })
EndIf
If aScan(_aFAtu,"K_CTRL_V") > 0
	SetKey(K_CTRL_V, { ||  })
EndIf
If aScan(_aFAtu,"K_CTRL_W") > 0
	SetKey(K_CTRL_W, { ||  })
EndIf
If aScan(_aFAtu,"K_CTRL_X") > 0
	//NÃO UTILIZAR ESTA TECLA DE ATALHO
EndIf
If aScan(_aFAtu,"K_CTRL_Y") > 0
	SetKey(K_CTRL_Y, { ||  })
EndIf
If aScan(_aFAtu,"K_CTRL_Z") > 0
	SetKey(K_CTRL_Z, { ||  })
EndIf

RestArea(_aSavSA1X )
RestArea(_aSavSA2X )
RestArea(_aSavSB1X )
RestArea(_aSavSUAX )
RestArea(_aSavSUBX )
RestArea(_aSavSC5X )
RestArea(_aSavSC6X )
RestArea(_aSavSC9X )
RestArea(_aSavSF2X )
RestArea(_aSavSD2X )
RestArea(_aSavSF1X )
RestArea(_aSavSD1X )
RestArea(_aSavSE1X )
RestArea(_aSavSE2X )
RestArea(_aSavSE5X )
RestArea(_aSavSL2X )
RestArea(_aSavSL4X )
RestArea(_aSavAreaX)

Return