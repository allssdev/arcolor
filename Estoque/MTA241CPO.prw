#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA241CPO �Autor  �Anderson C. P. Coelho � Data �  01/06/15 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada utilizado na inclus�o dos Movimentos      ���
���          �Internos Mod.2, utilizado para, na inclus�o de movimentos   ���
���          �pelos usu�rios listados no par�metro "MV_USR241E", que o    ���
���          �sistema altere a ordem dos campos a serem apresentados para ���
���          �uma ordem espec�fica, buscando o ganho de performance na    ���
���          �digita��o de tais movimentos no sistema.                    ���
���          �                                                            ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MTA241CPO()

Local _aSavArea := GetArea()
Local _aNewHea  := {}
Local _aNewCol  := {}
Local _aOrdem   := {"D3_COD","D3_QUANT","D3_DESCRI","D3_LOCAL","D3_LOTECTL","D3_CUSTO1"}
Local nOpc      := ParamIxb[1]
Local _nPos     := 0

// Manipula��o pelo usu�rio do aHeader e aCols para inclus�o de campos na getdados.
If __cUserId$AllTrim(SuperGetMv("MV_USR241E",,"#000020#")) .AND. nOpc == 3		//Inclus�o
	For _x := 1 To Len(_aOrdem)
		_nPos := aScan(aHeader,{|x| AllTrim(x[02])==AllTrim(_aOrdem[_x])})
		If _nPos > 0
			AADD(_aNewHea,aClone(aHeader[_nPos])  )
			AADD(_aNewCol,aCols[01][_nPos]        )
		EndIf
	Next
	For _x := 1 To Len(aHeader)
		If aScan(_aOrdem,AllTrim(aHeader[_x][02])) == 0
			AADD(_aNewHea,aClone(aHeader[_x])    )
			AADD(_aNewCol,aCols[01][_x]          )
		EndIf
	Next
	If Len(_aNewCol) > 0
		//Ajuste do aHeader
		aHeader := aClone(_aNewHea)
		//Ajuste do aCols
		AADD(_aNewCol,aCols[01][Len(aCols[01])])
		aCols := {}
		AADD(aCols   ,aClone(_aNewCol)         )
	EndIf
	For nx = 1 To Len(aHeader)
		Do Case
			Case Trim(aHeader[nx][2]) == "D3_COD"
				nPosCod:=nX
			Case Trim(aHeader[nx][2]) == "D3_LOCAL"
				nPosLocal:=nX
			Case Trim(aHeader[nx][2]) == "D3_NUMLOTE"
				nPosLote:=nX
			Case Trim(aHeader[nx][2]) == "D3_LOTECTL"
				nPosLotCTL:=nX
			Case Trim(aHeader[nx][2]) == "D3_DTVALID"
				nPosDValid:=nX
			Case Trim(aHeader[nx][2]) == "D3_POTENCI"
				nPosPotenc:=nX
			Case Trim(aHeader[nx][2]) == "D3_QUANT"
				nPosQuant:=nX
			Case Trim(aHeader[nx][2]) == "D3_SEGUM"
				nPosSegUm:=nX
			Case Trim(aHeader[nx][2]) == "D3_QTSEGUM"
				nPosQtSegUm:=nX
			Case Trim(aHeader[nx][2]) == "D3_CUSTO1"
				nPosCusto1:=nX
			Case Trim(aHeader[nx][2]) == "D3_UM"
				nPosUm:=nX
			Case Trim(aHeader[nx][2]) == "D3_CONTA"
				nPosConta:=nX
			Case Trim(aHeader[nx][2]) == "D3_GRUPO"
				nPosGrupo:=nX
			Case Trim(aHeader[nx][2]) == "D3_TIPO"
				nPosTipo:=nX
			Case Trim(aHeader[nx][2]) == "D3_OP"
				nPosOp:=nX
			Case Trim(aHeader[nx][2]) == "D3_TRT"
				nPosTrt:=nX
			Case Trim(aHeader[nx][2]) == "D3_DESCRI"
				nPosDesc:=nX
			Case Trim(aHeader[nx][2]) == "D3_LOCALIZ"
				nPosLocali:=nX
			Case Trim(aHeader[nx][2]) == "D3_NUMSERI"
				nPosNumSer:=nX
			Case Trim(aHeader[nx][2]) == "D3_SERVIC"
				nPosServic:=nX
		EndCase
	Next nx
EndIf

RestArea(_aSavArea)

Return Nil