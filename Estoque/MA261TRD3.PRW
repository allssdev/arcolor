#Include 'Protheus.ch'

/*/{Protheus.doc} User Function nomeFunction
    EM QUE PONTO : Após a gravação dos dados (aCols) no SD3 nas transferencias, e tem a finalidade de atualizar algum arquivo ou campo.
    Envia vetor com os parâmetros:
    PARAMIXB[1] = Número do Recno
    @type  Function
    @author Diego Rodrigues
    @since 30/10/2023
    @version 1.0
/*/
 
User Function MA261TRD3()
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recebe os identificadores Recno() gerados na tabela SD3      ³
//³ para que seja feito o posicionamento                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
Local aRecSD3 := PARAMIXB[1]
Local nX := 1
 
For nX := 1 To Len(aRecSD3)
 
    SD3->(DbGoto(aRecSD3[nX][1])) // Requisicao RE4
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Customizacoes de usuario      ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
    IF SD3->D3_CUSTO1 == 0
        _nCusto := Posicione("SB2",2,XFILIAL("SB2")+"01"+SD3->D3_COD,"B2_CMFIM1")
        RecLock('SD3', .F.)
        SD3->D3_CUSTO1 := SD3->D3_QUANT * _nCusto
        MsUnlock()
    Endif
     
    SD3->(DbGoto(aRecSD3[nX][2])) // Devolucao DE4
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Customizacoes de usuario      ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
      IF SD3->D3_CUSTO1 == 0
        _nCusto := Posicione("SB2",2,XFILIAL("SB2")+"01"+SD3->D3_COD,"B2_CMFIM1")
        RecLock('SD3', .F.)
        SD3->D3_CUSTO1 := SD3->D3_QUANT * _nCusto
        MsUnlock()
    Endif
 
Next nX
 
Return Nil
