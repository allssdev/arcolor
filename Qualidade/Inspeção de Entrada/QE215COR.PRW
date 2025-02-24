User Function QE215COR()

Local aDados := PARAMIXB[1]// Customização do usuário
Local _aDados := {}

Aadd(_aDados,{"QEK->QEK_SITENT == '1' ","BR_CINZA"})    //Entrada sem medicoes cadastradas 
Aadd(_aDados,{"QEK->QEK_SITENT == '2' ","BR_VERDE"})    //Laudo Aprovado 
Aadd(_aDados,{"QEK->QEK_SITENT == '3' ","BR_VERMELHO"}) //Laudo Reprovado	
Aadd(_aDados,{"QEK->QEK_SITENT == '4' ","BR_AMARELO"})  //Liberacao Urgente
Aadd(_aDados,{"QEK->QEK_SITENT == '5' ","BR_LARANJA"})  //Laudo Condicional
Aadd(_aDados,{"QEK->QEK_SITENT == '6' ","BR_PINK"})     //Laudo sem Movimentacao de Estoque  
Aadd(_aDados,{"QEK->QEK_SITENT == '7' ","BR_MARROM"})   //Laudo Geral Pedente
Aadd(_aDados,{"QEK->QEK_SITENT == '8' ","BR_BRANCO"})   //Laudo Laboratorio Pendente   
//Aadd(_aDados,{"QEK->QEK_SITENT == '9' ","BR_PINK" })    //Laudo baixas parciais 
//Aadd(_aDados,{"QEK->QEK_SITENT == '6' ","BR_PINK" })  //Laudo sem Movimentacao de Estoque  


Return _aDados
