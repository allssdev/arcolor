#include "rwmake.ch"
#include "totvs.ch"
/*
Padrao DATAMAX
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMG05     ºAutor  ³Sandro Valex        º Data ³  19/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada referente a imagem de identificacao do     º±±
±±º          ³volume temporario                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function IMG05()   // imagem de etiqueta de volume temporaria
	Local cVolume := paramixb[1]
	Local cPedido := paramixb[2]
	Local cNota   := IF(len(paramixb)>=3,paramixb[3],nil)
	Local cSerie  := IF(len(paramixb)>=4,paramixb[4],nil)
	Local cID     := CBGrvEti('05',{cVolume,cPedido,cNota,cSerie})
	Local sConteudo

	//MSCBLOADGRF("SIGA.BMP")
	MSCBLOADGRF("lgrl01.bmp")
	MSCBBEGIN(1,6)
	MSCBBOX(02,01,76,34,1)
	MSCBLineH(30,30,76,1)
	MSCBLineH(02,23,76,1)
	MSCBLineH(02,15,76,1)
	MSCBLineV(30,23,34,1)
	MSCBGRAFIC(2,26,"SIGA")
	MSCBSAY(33,31,"VOLUME","N","2","01,01")
	MSCBSAY(33,27,"CODIGO","N","2","01,01")
	MSCBSAY(33,24,cVolume , "N", "2", "01,01")
	If cNota==NIL
		MSCBSAY(05,20,"PEDIDO","N","2","01,01")
		MSCBSAY(05,16,cPedido,"N", "2", "01,01")
	Else
		MSCBSAY(05,20,"NOTA","N","2","01,01")
		MSCBSAY(05,16,cNota+ ' '+cSerie,"N", "2", "01,01")
	EndIf
	MSCBSAYBAR(22,03,cId,"N","MB07",8.36,.F.,.T.,.F.,,3,2,.F.,.F.,"1",.T.)
	MSCBInfoEti("Volume Temp.","30X100")
	sConteudo := MSCBEND()

return sConteudo