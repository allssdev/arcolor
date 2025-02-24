#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*                                     
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA070POS  ºAutor  ³Thiago S. De Almeida   º Data ³ 27/12/12 º±±
±±º          ³          ºAutor  ³Júlio Soares           º Data ³ 20/01/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada utilizado antes da montagem da tela de    º±±
±±º          ³ baixa do contas a receber.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada utilizado para que os valores de juros e  º±±
±±º          ³ multa sejam zerados antes da montagem do box de baixa.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

User Function FA070POS()

Local _aSavArea := GetArea()


// - Trecho inserida por Júlio Soares em 20/01/2014 para que os valores de juros e multas venham com o valor zerado.
//nMulta := 0
//nJuros := 0
// - TRECHO INSERIDO EM 23/07/2014 POR JÚLIO SOARES PARA TRATAR UMA FALHA ENCONTRADA NA ROTINA ONDE AO ALTERAR O TIPO DE BAIXA O JUROS ZERADO É RETORNADO POR REFRESH DENTRO DA ROTINA
// - DESSA FORMA O PERCENTUAL DE JUROS É GRAVADO COM 0 DIRETO NO TITULO E RESTAURADO NO PONTO DE ENTRADA "FA070TIT".
/*
while !RecLock("SE1",.F.) ; enddo 
	SE1->E1_PORCJUR := 0
SE1->(MSUnlock())
*/
// - Fim da alteração.

If MsSeek(xFilial("SZ3") + __cUserId,.T.,.F.)
	If __cUserId $ SZ3->Z3_USERREC
		_aParam1 := STRTOKARR(GETMV("MV_CXFIN"), '/') // Parametro padrão que define a banco, agencia, conta padrão para baixas no contas a receber.
		cBanco   := _aParam1[1]
		cAgencia := _aParam1[2]
		cConta   := _aParam1[3]
	EndIf
EndIf

RestArea(_aSavArea)

Return()