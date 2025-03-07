#Include 'Protheus.ch'

/*/{Protheus.doc} User Function nomeFunction
    EM QUE PONTO : Ap�s a grava��o dos dados (aCols) no SD3 nas transferencias, e tem a finalidade de atualizar algum arquivo ou campo.
    Envia vetor com os par�metros:
    PARAMIXB[1] = N�mero do Recno
    @type  Function
    @author Diego Rodrigues
    @since 30/10/2023
    @version 1.0
/*/
 
User Function MA261TRD3()
 
//��������������������������������������������������������������Ŀ
//� Recebe os identificadores Recno() gerados na tabela SD3      �
//� para que seja feito o posicionamento                         �
//����������������������������������������������������������������
 
Local aRecSD3 := PARAMIXB[1]
Local nX := 1
 
For nX := 1 To Len(aRecSD3)
 
    SD3->(DbGoto(aRecSD3[nX][1])) // Requisicao RE4
    //�������������������������������Ŀ
    //� Customizacoes de usuario      �
    //���������������������������������
 
    IF SD3->D3_CUSTO1 == 0
        _nCusto := Posicione("SB2",2,XFILIAL("SB2")+"01"+SD3->D3_COD,"B2_CMFIM1")
        RecLock('SD3', .F.)
        SD3->D3_CUSTO1 := SD3->D3_QUANT * _nCusto
        MsUnlock()
    Endif
     
    SD3->(DbGoto(aRecSD3[nX][2])) // Devolucao DE4
    //�������������������������������Ŀ
    //� Customizacoes de usuario      �
    //���������������������������������
 
      IF SD3->D3_CUSTO1 == 0
        _nCusto := Posicione("SB2",2,XFILIAL("SB2")+"01"+SD3->D3_COD,"B2_CMFIM1")
        RecLock('SD3', .F.)
        SD3->D3_CUSTO1 := SD3->D3_QUANT * _nCusto
        MsUnlock()
    Endif
 
Next nX
 
Return Nil
