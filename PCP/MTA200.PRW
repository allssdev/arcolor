#Include 'TOTVS.ch'

/*/{Protheus.doc} MA200BUT
@description Ponto de entrada responsavel pela analise do bloqueio dos produtos tipo MP/EM na estrutura.
@description Dispara no momento da confirma��o da tela Enchoice
@author  Diego Rodrigues (ALLSS Solu��es em Sistemas)
@since   12/04/2021
@version P12.1.25 - 1.00
@see https://allss.com.br
/*/

User Function MTA200()

	Local aAreaAtu := GetArea()
    Local cOpc := IIF(Paramixb == NIL,"",ParamIxb)
	Local cCodPA := IIF(!cOpc$"I*A","",cCodPai)
    Local cTipo := ""
    Local cTipblq := SuperGetMv("MV_XTIPPRO",,"MP/EM")
	Local lRet := .T.
    
	
// Executa apenas para inclus�o e altera��o.
	If Alltrim(cOpc) $ "I"

// Guardo a area
	aArea := GetArea()

// Posiciono no produto pai para verificar se � um produto MP/EM

        DbSelectArea("SB1")
        DbSetOrder(1)
        DbSeek(xFilial("SB1") + cCodPA)
        cTipo := SB1->B1_TIPO

        If cTipo $ cTipblq

            MsgInfo( " O Produto principal "+" "+cCodPA+" � um produto do tipo MP - Materia prima ou EM - Embalagem, desta forma n�o � permitido cadastrar estrutura para esses tipos de produtos."," Aten��o ")
            lRet := .F.

        EndIf
  
// Retorna a area
		RestArea(aArea)
				
	Else

		RestArea(aAreaAtu)

	
	EndIf
Return(lRet)
