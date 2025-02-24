#include "rwmake.ch"
#include "totvs.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMG05OFI  ºAutor  ³Sandro Valex        º Data ³  19/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada referente a imagem de identificacao do     º±±
±±º          ³volume permanente."Oficial"                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function Img05OFI() // imagem de etiqueta de volume permanente (OFICIAL)
	Local cId     := CBGrvEti('05',{CB6->CB6_VOLUME,CB6->CB6_PEDIDO})
	Local nTotEti := paramixb[1]
	Local nAtu    := paramixb[2]
	MSCBBEGIN(1,6)
	MSCBLineV(07,01,34,1)
	MSCBLineV(22,01,34,1)
	MSCBLineV(31,01,34,1)
	MSCBLineV(39,01,34,1)
	MSCBSAY(06,02,"VOLUME","B","3","01,01")
	MSCBSAYBAR(22,02,AllTrim(cId),"B","MB07",8.36,.F.,.T.,.F.,,3,2,.F.,.F.,"1",.T.)
	MSCBSAY(26,02,"PEDIDO","B","2","01,01")
	MSCBSAY(29,02,CB6->CB6_PEDIDO,"B", "2", "01,01")
	MSCBSAY(34,02,"CODIGO","B","2","01,01")
	MSCBSAY(37,02,CB6->CB6_VOLUME , "B", "2", "01,01")
	MSCBSAY(60,06,StrZero(nAtu,2)+"/"+StrZero(nTotEti,2), "B", "6", "01,01")
	MSCBInfoEti("Volume Oficial","30X100")
	MSCBEND()
return .F.