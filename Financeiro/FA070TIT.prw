#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA070TIT  ºAutor  ³Júlio Soares        º Data ³  05/15/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada chamado após a confirmação do título      º±±
±±º          ³ Chama execblock RFINE009 que apresenta tela onde é possivelº±±
±±º          ³ inserir ou alterar a carteira e/ou observações do título   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Alterado o ponto de entrada retirando o execblock RFINE009 º±±
±±º          ³ e implementado diretamente no fonte.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico empresa - ARCOLOR                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FA070TIT()

Local    _aSavArea := GetArea()

Private  _lRet     := .T.
Private  _cRotina  := "FA070TIT"

// - TRECHO INSERIDO EM 23/07/2014 POR JÚLIO SOARES PARA TRATAR UMA FALHA ENCONTRADA NA ROTINA ONDE AO ALTERAR O TIPO DE BAIXA O JUROS ZERADO É RETORNADO POR REFRESH DENTRO DA ROTINA
// - DESSA FORMA O PERCENTUAL DE JUROS É GRAVADO COM 0.2 APÓS A ALTERAÇÃO EXECUTADA NO PONTO DE ENTRADA "FA070POS".
/*
while !RecLock("SE1",.F.) ; enddo
	SE1->E1_PORCJUR := 0.2
SE1->(MsUnlock())
*/
// - Trecho inserido por Júlio Soares em 20/01/2014 para validar se o usuário deseja baixar o título mesmo com a agregação dos valores de juros e/ou multas
	If nJuros > 0 .OR. nMulta > 0
		_lRet := MSGBOX ('CONFIRMAR BAIXA DO TÍTULO COM A AGREGAÇÃO DOS VALORES DE JUROS E/OU MULTA ? ',_cRotina+'_001','YESNO')
	EndIf
// - Fim inserção.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Implementado tela para a alteração da carteira e/ou observaçoes do titulo após baixar o mesmo.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If _lRet .AND. Upper(AllTrim(FunName()))=="FINA740"
	Static oSay1
	Static oSay2
	Static grpCart
	Static oCart
	Static grpObs
	Static oObstit
	Static oCancela
	Static oConfirma
	Static oDlg

	Private _cPrfx     := SE1->E1_PREFIXO
	Private _cNum      := SE1->E1_NUM
	Private _cPar      := SE1->E1_PARCELA
	dbselectArea("SE1")
	SE1->(dbsetOrder(1))          // Indice por numero do título
	If SE1->(MsSeek(xFilial("SE1")+ _cPrfx +_cNum + _cPar,.T.,.F.))
		_cCart   := SE1->E1_CARTEIR
		_cObstit := SE1->E1_OBSTIT
		  DEFINE MSDIALOG oDlg TITLE "Alteração de Títulos" FROM 000, 000  TO 235, 450 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME// Inibe o botao "X" da tela
			oDlg:lEscClose := .F.//Não permite fechar a tela com o "Esc"
		    @ 004, 007 GROUP  grpCart   TO 025, 220 PROMPT "Carteira"                                OF oDlg COLOR  0, 16777215 PIXEL
		    @ 010, 050 MSGET  oCart     VAR _cCart                                     SIZE 020, 010 OF oDlg COLORS 0, 16777215 PIXEL
		    @ 030, 007 GROUP  grpObs    TO 095, 220 PROMPT "Observações do Título"                   OF oDlg COLOR  0, 16777215 PIXEL
		    @ 038, 010 GET    oObstit   VAR _cObstit                                                 OF oDlg MULTILINE SIZE 207, 054 COLORS 0, 16777215 HSCROLL PIXEL
		    @ 100, 090 BUTTON oCancela  PROMPT "Cancela"                               SIZE 062, 015 OF oDlg ACTION Cancelar()  PIXEL
		    @ 100, 157 BUTTON oConfirma PROMPT "Confirma"                              SIZE 060, 015 OF oDlg ACTION Confirmar() PIXEL
		
		  ACTIVATE MSDIALOG oDlg CENTERED
	Else
		_cCart   := ""
		_cObstit := ""
	EndIf
EndIf

RestArea(_aSavArea)

Return(_lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Cancelar  ºAutor  ³Júlio Soares        º Data ³  05/15/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Sub rotina de cancelamento                                 º±±
±±º          ³ NÃO GRAVA AS INFORMAÇÕES INSERIDAS OU ALTERADAS            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Cancelar()

MSGBOX("Observações não gravadas",_cRotina+"_001","INFO")
Close(oDlg)

Return(.F.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Confirmar ºAutor  ³Júlio Soares        º Data ³  05/15/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Sub rotina de Gravação                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Confirmar()

Local _aSavSE1 := GetArea()

dbSelectArea("SE1")
while !RecLock("SE1",.F.) ; enddo
	SE1->E1_CARTEIR  := _cCart
	SE1->E1_OBSTIT   := _cObstit
SE1->(MsUnLock())
MSGBOX("Observações gravadas com sucesso!",_cRotina + "_002","INFO")
Close(oDlg)
	
RestArea(_aSavSE1)

Return(_lRet)

/*
If ExistBlock("RFINE009")
	Execblock ("RFINE009")
Else
	MsgAlert("Rotina RFINE009 não encontrada, informe o Administrador do sistema",_cRotina+"_001")
EndIf
*/
RestArea(_aSavArea)

Return()