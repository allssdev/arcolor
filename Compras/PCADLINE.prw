#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCADLINE  ºAutor  ³Anderson C. P. Coelho º Data ³  22/04/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Os pontos de entrada PCADHEAD e PCADLINE se encontram na   º±±
±±º          ³função MaComViewPC.                                         º±±
±±º          ³ São usados para inserir colunas na consulta de ULTIMOS     º±±
±±º          ³PEDIDOS na opção do botão HISTORICO DE PRODUTOS no Pedido deº±±
±±º          ³compras,o PCADLINE acrescenta elementos no array dos dados, º±±
±±º          ³e o PCADHEAD acrescenta os títulos das colunas.             º±±
±±º          ³                                                            º±±
±±º          ³ O retorno do ponto de entrada PCADHEAD deverá ser um array º±±
±±º          ³contendo os titulos dos campos que serão exibidos na tela.  º±±
±±º          ³                                                            º±±
±±º          ³ O retorno do ponto de entrada PCADLINE deverá ser um array º±±
±±º          ³contendo o conteúdo dos campos que serão exibidos na tela.  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico para a empresa Arcolor.            º±±
±±º          ³ FUNCIONA EM CONJUNTO COM OS PONTOS DE ENTRADA PCADHEAD() e º±±
±±º          ³ PCADCOLH().                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PCADLINE()

Local _aSavArea := GetArea()
Local _aSavSA2  := SA2->(GetArea())
Local _aSavSE4  := SE4->(GetArea())
Local _aDet     := {}		//ParamIxb

/*
_aDet := {	C7_NUM                                         ,;
			C7_ITEM                                        ,;
			SA2->A2_NOME                                   ,;
			TransForm(C7_QUANT,PesqPict("SC7","C7_QUANT")) ,;
			TransForm(C7_PRECO,PesqPict("SC7","C7_PRECO")) ,;
			TransForm(C7_QUJE ,PesqPict("SC7","C7_QUJE" )) ,;
			C7_DATPRF                                      ,;
			C7_ANTEPRO                                     ,;
			C7_COND+" - "+SE4->E4_DESCRI                   ,;
			C7_RESIDUO                                     }
*/

_aDet := {	C7_NUM                                         ,;
			C7_ITEM                                        ,;
			SA2->A2_NOME                                   ,;
			TransForm(C7_QUANT,PesqPict("SC7","C7_QUANT")) ,;
			TransForm(C7_PRECO,PesqPict("SC7","C7_PRECO")) ,;
			TransForm(C7_QUJE ,PesqPict("SC7","C7_QUJE" )) ,;
			C7_DATPRF                                      ,;
			C7_COND+" - "+SE4->E4_DESCRI                   ,;
			C7_RESIDUO                                     }

RestArea(_aSavSE4 )
RestArea(_aSavSA2 )
RestArea(_aSavArea)

Return(_aDet)
