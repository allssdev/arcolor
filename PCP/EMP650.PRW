#include 'totvs.ch'
#include 'protheus.ch'

/*/{Protheus.doc} EMP650
Ponto de entrar para alterar o empenho deletando o lote informado dos produtos intermediarios, chamado pelo fonte RPCPA003.
@authorDiego Rodrigues(ALL System Solutions)
@since 16/01/2024
@version P12
@type function
@see https://allss.com.br
/*/

<<<<<<< .mine
User function ()
 Local _aPrdPi := {}
 Local _aPiQtd := {}
 Local _nItem  := 0

    Local aArea  := GetArea()
    local nx
||||||| .r1142
User function EMP650()
 
    Local aArea  := GetArea()
    local nx
=======
User function EMP650()
 Local _aPrdPi := {}
 Local _aPiQtd := {}
 Local _nItem  := 0
 Local _lRet := .F.
 Local aArea  := GetArea()
 Local nx
>>>>>>> .r1183
    For nx := 1 to len(Acols) // Percorre todas as linhas da acols
        dbSelectArea("SB1")
        SB1->(dbSetOrder(1))
        SB1->(MsSeek(FWFilial("SB1")+Acols[nx][nPosCod]),.T.,.F.)
         IF SB1->B1_TIPO = 'PI' // Verifica se linha nao esta Deletada

            Acols[nx][nPosLotCTL] := Space(30)
<<<<<<< .mine

            aADD(_aPrdPi,{SB1->B1_COD, nx, Acols[nx][2]})

         EndIF

||||||| .r1142
        EndIF
=======

            aADD(_aPrdPi,{SB1->B1_COD, nx, Acols[nx][2]})
         EndIF
>>>>>>> .r1183
    Next nx
 
<<<<<<< .mine
    if len(_aPrdPi) > 0
        
        for _nItem := 1 to len(_aPrdPi)
        
            _nLocItem :=  aScan(_aPiQtd, {|x| AllTrim(x[01]) == Alltrim(_aPrdPi[_nItem][1]) })

            if _nLocItem <= 0
        
                aADD(_aPiQtd,{_aPrdPi[_nItem][1],_aPrdPi[_nItem][2],_aPrdPi[_nItem][3] })

            else

                _aPiQtd[_nLocItem][3] += _aPrdPi[_nItem][3]

            endif

        next
    endif

    if len(_aPiQtd) > 0

        for _nItem := 1 to len(_aPiQtd)
        
            _nLocItem :=  aScan(aCols, {|x| AllTrim(x[01]) == Alltrim(_aPiQtd[_nItem][1]) })

            if _nLocItem > 0

                if  _aPiQtd[_nItem][2] == _nLocItem
                
                     aCols[_nLocItem][2] := _aPiQtd[_nItem][3]

                    for nx := 1 to len(aCols)

                        if Alltrim(_aPiQtd[_nItem][1]) == Alltrim(aCols[nx][nPosCod]) .and. nx <> _nLocItem

                            aCols[nx][19] := .T.

                        endif

                    next

                endif
            endif

        next        

    endif

||||||| .r1142
=======
    if len(_aPrdPi) > 0
       for _nItem := 1 to len(_aPrdPi)
            _nLocItem :=  aScan(_aPiQtd, {|x| AllTrim(x[01]) == Alltrim(_aPrdPi[_nItem][1]) })
            if _nLocItem <= 0
                aADD(_aPiQtd,{_aPrdPi[_nItem][1],_aPrdPi[_nItem][2],_aPrdPi[_nItem][3] })
            else
                _aPiQtd[_nLocItem][3] += _aPrdPi[_nItem][3]
            endif
        next
    endif

    if len(_aPiQtd) > 0
        for _nItem := 1 to len(_aPiQtd)
            _nLocItem :=  aScan(aCols, {|x| AllTrim(x[01]) == Alltrim(_aPiQtd[_nItem][1]) })
            if _nLocItem > 0
                if  _aPiQtd[_nItem][2] == _nLocItem
                     aCols[_nLocItem][2] := _aPiQtd[_nItem][3]
                    for nx := 1 to len(aCols)
                        if Alltrim(_aPiQtd[_nItem][1]) == Alltrim(aCols[nx][nPosCod]) .and. nx <> _nLocItem
                            aTail(aCols[nx]) := .T.
                        endif
                    next
                endif
            endif
        next        
    endif

>>>>>>> .r1183
    RestArea(aArea)
Return
