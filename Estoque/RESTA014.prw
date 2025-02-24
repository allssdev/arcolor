#include 'rwmake.ch'
#include 'protheus.ch'
#include 'tbiconn.ch'
#include 'shell.ch'
/*/{Protheus.doc} RESTA014
(TEMPOR�RIO) Fun��o de usu�rio para fazer carga de dados na tabela CBJ (Produto x Endere�o).
@author Rodrigo Telecio (rodrigo.telecio@allss.com.br)
@since 12/01/2024
@version P12.1.2310
@type Function
@obs Sem observa��es
@see https://allss.com.br/
@history 12/01/2024, Rodrigo Telecio (rodrigo.telecio@allss.com.br), #7110 - Vers�o inicial da rotina.
/*/
user function RESTA014()
local aArea         := GetArea()
local cRotina       := AllTrim(FunName())
local cTitulo       := "Cad. Prod.x End. em massa"
if !__cUserID $ "000000|000270"
    Aviso('TOTVS','Execu��o n�o autorizada para este usu�rio.',{"&OK",3,'N�o autorizado'})
else
    Processa( { |lEnd| ProcReg(lEnd) }, "[" + cRotina + "] " + cTitulo, "Processando...",.F.)
endif
RestArea(aArea)
return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ProcReg  �Autor  � Rodrigo Telecio    � Data � 12/01/2024  ���
�������������������������������������������������������������������������͹��
���Descri��o � Fun��o de processamento                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                            			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static function ProcReg(lEnd)
local cArmazem      := "VC"
local cEndereco     := "CONSIGNADO"
local nSequen       := "00"
local cAliasSB1     := GetNextAlias()
local cAliasCBJ     := ""
beginsql alias cAliasSB1
    SELECT
        SB1.B1_COD, SB1.B1_DESC
    FROM
        %table:SB1% SB1 (NOLOCK)
    WHERE
        SB1.B1_MSBLQL   <> '1'
        AND SB1.B1_TIPO = 'PA'
        AND SB1.%notdel%
    ORDER BY
        SB1.B1_COD
endsql
dbSelectArea(cAliasSB1)
ProcRegua(RecCount())
(cAliasSB1)->(dbGoTop())
if (cAliasSB1)->(!EOF())
    while (cAliasSB1)->(!EOF())
        dbSelectArea("CBJ")
        dbSetOrder(1)
        if !dbSeek(xFilial("CBJ") + (cAliasSB1)->B1_COD + cArmazem + cEndereco)
            cAliasCBJ       := GetNextAlias()
            nSequen         := "00"
            beginsql alias cAliasCBJ
                SELECT
                    MAX(CBJ.CBJ_ITEM) AS CBJ_ITEM
                FROM
                    %table:CBJ% AS CBJ (NOLOCK)
                WHERE
                    CBJ.CBJ_CODPRO   = %Exp:(cAliasSB1)->B1_COD%
                    AND CBJ.%notdel%
            endsql
            dbSelectArea(cAliasCBJ)
            (cAliasCBJ)->(dbGoTop())
            if (cAliasCBJ)->(!EOF())
                while (cAliasCBJ)->(!EOF())
                    nSequen := (cAliasCBJ)->CBJ_ITEM
                    (cAliasCBJ)->(dbSkip())
                enddo
            endif
            (cAliasCBJ)->(dbCloseArea())
            dbSelectArea("CBJ")
            RecLock("CBJ",.T.)
            CBJ->CBJ_FILIAL := xFilial("SBJ")
            CBJ->CBJ_CODPRO := (cAliasSB1)->B1_COD
            CBJ->CBJ_ITEM   := Soma1(nSequen)
            CBJ->CBJ_ARMAZ  := cArmazem
            CBJ->CBJ_ENDERE := cEndereco
            MsUnlock()
        endif
        (cAliasSB1)->(dbSkip())
    enddo
endif
return
