#INCLUDE "Protheus.CH"
#INCLUDE "rwmake.CH" 
#INCLUDE "TOPCONN.CH"                                    
#INCLUDE "Tbiconn.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFINA003  ºAutor  ³Júlio Soares        º Data ³  05/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina criada para apresentar uma tela onde possa alterar asº±±
±±º          ³observações do título após baixado                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Específico - ARCOLOR                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFINA003()

Local _aSavArea := GetArea()

Local oSay1
Local Prefixo
Local Numero
Local Parcela
Local oBusca
Local oCancela
Local oConfirma
Local oPrefx
Local oNumtit
Local oParc
Local oObstit

Private _cRotina := "RFINA003"
Private _lRet    := .F.

Static oDlg
//Faz validação da rotina para diferenciar a tela a ser montada
If Upper(AllTrim(FunName()))=="FINA740" .OR. Upper(AllTrim(FunName()))=="FINA040"
	_cPrfx := E1_PREFIXO
	_cNum  := E1_NUM
	_cPar  := E1_PARCELA
	_cText := E1_OBSTIT
Else
	_cPrfx := Space(TamSx3("E1_PREFIXO")[01])
	_cNum  := Space(TamSx3("E1_NUM"    )[01])
	_cPar  := Space(TamSx3("E1_PARCELA")[01])
	_cText := ""
EndIf

  DEFINE MSDIALOG oDlg TITLE "Alteração da Observação" FROM 000, 000  TO 270, 490            COLORS 0, 16777215          PIXEL

    @ 004, 060 SAY    oSay1      PROMPT "Selecione o título desejado"  SIZE 125, 012 OF oDlg COLORS 0, 16777215          PIXEL
    @ 022, 005 SAY    Prefixo    PROMPT "Prefixo"                      SIZE 025, 012 OF oDlg COLORS 0, 16777215          PIXEL
	@ 022, 060 SAY    Numero     PROMPT "Numero"                       SIZE 030, 012 OF oDlg COLORS 0, 16777215          PIXEL        
	@ 022, 142 SAY    Parcela    PROMPT "Parcela"                      SIZE 027, 012 OF oDlg COLORS 0, 16777215          PIXEL

  If Upper(AllTrim(FunName()))=="FINA740" .OR. Upper(AllTrim(FunName()))=="FINA040"
    @ 022, 032 MSGET  oPrefix    VAR _cPrfx                            SIZE 025, 012 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 022, 090 MSGET  oNumTit    VAR _cNum                             SIZE 050, 012 OF oDlg COLORS 0, 16777215 READONLY PIXEL 
    @ 022, 175 MSGET  oParc      VAR _cPar                             SIZE 025, 012 OF oDlg COLORS 0, 16777215 READONLY PIXEL
  Else
    @ 022, 032 MSGET  oPrefix    VAR _cPrfx                            SIZE 025, 012 OF oDlg COLORS 0, 16777215          PIXEL
    @ 022, 090 MSGET  oNumTit    VAR _cNum                             SIZE 050, 012 OF oDlg COLORS 0, 16777215          PIXEL 
    @ 022, 175 MSGET  oParc      VAR _cPar                             SIZE 025, 012 OF oDlg COLORS 0, 16777215          PIXEL    
  EndIf
  If Upper(AllTrim(FunName()))=="RFINA003"    
   	@ 020, 207 BUTTON oBusca     PROMPT "Buscar"                       SIZE 030, 015 OF oDlg ACTION Buscar()             PIXEL
  EndIf
    @ 045, 005 GET    oObstit    VAR _cText OF oDlg MULTILINE          SIZE 235, 069         COLORS 0, 16777215 HSCROLL  PIXEL
    @ 117, 100 BUTTON oCancela   PROMPT "Cancela"                      SIZE 062, 015 OF oDlg ACTION Cancelar()           PIXEL
	@ 117, 175 BUTTON oConfirma  PROMPT "Confirma"                     SIZE 060, 015 OF oDlg ACTION Confirmar()          PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

Return(_lRet)

//VALID ExistCpo("SE1",_cNum) F3 "SE1"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFINA003  ºAutor  ³Júlio  Soares       º Data ³  05/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Sub-função para validar o título a ser alterado            º±±
±±º          ³ Por hora a rotina está desativada                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Específico - ARCOLOR                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
Static Function ValidSE1()

Local _aSavSE1 := SE1->(GetArea())

dbSelectArea("SE1")
dbSetOrder(1)
If (_lRet1 := MsSeek(xFilial("SE1")+_cPrfx + _cNum,.T.,.F.))
	_cPrfx := SE1->E1_PREFIXO
	_cNum  := SE1->E1_NUM
	_cPar  := SE1->E1_PARCELA
Else
	_cNum  := Space(TamSx3("E1_NUM")[01])
	Alert("Num n encontrado")
EndIf

//RestArea(_aSavSE1)

Return(_lRet1)
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFINA003  ºAutor  ³Júlio  Soares       º Data ³  05/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Sub - rotina para realizar a busca do título após o        º±±
±±º          ³ preenchimento dos campos de parâmetros                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Específico - ARCOLOR                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Buscar()

dbselectArea("SE1")
dbsetOrder(1) // Numero do título
	If MsSeek(xFilial("SE1")+ _cPrfx +_cNum + _cPar,.T.,.F.)
		_cText := SE1->E1_OBSTIT
	//	_cText := SE1->E1_OBS
	Else
		MSGBOX("Título não encontrado",_cRotina+"_001","STOP")
	EndIf

Return ()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFINA003  ºAutor  ³Júlio  Soares       º Data ³  05/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Sub-rotina de cancelamento                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Específico - ARCOLOR                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Cancelar()

If MsgYesNo("Deseja realmente cancelar?",_cRotina+"_002")
	Close(oDlg)
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFINA003  ºAutor  ³Júlio  Soares       º Data ³  05/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Sub-rotina de gravação                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Específico - ARCOLOR                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Confirmar()

Local _aSavSE1 := GetArea()
dbSelectArea("SE1")
dbsetOrder(1)
If MsSeek(xFilial("SE1")+ _cPrfx +_cNum + _cPar,.T.,.F.)
//	If !Empty(_cText) // Não permite gravar a tela em branco.
		while !RecLock("SE1",.F.) ; enddo
			SE1->E1_OBSTIT := _cText
			// SE1->E1_OBS := _cText
		SE1->(MsUnLock())
		_lRet := .T.
		MSGBOX("Observações gravadas",_cRotina + "002","INFO")
		If Upper(AllTrim(FunName()))=="FINA740" .OR. Upper(AllTrim(FunName()))=="FINA040"
			Close(oDlg)
		Else
			_cPrfx := Space(TamSx3("E1_PREFIXO")[01])
			_cNum  := Space(TamSx3("E1_NUM"    )[01])
			_cPar  := Space(TamSx3("E1_PARCELA")[01])
			_cText := ""
		EndIf
//	Else
//		MSGBOX("Observações em branco NÃO podem gravadas",_cRotina + "003","STOP")
//		_lRet := .F.
//	EndIf
EndIf

RestArea(_aSavSE1)

Return(_lRet)                         
