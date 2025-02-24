#IFDEF SPANISH
   #define STR0001 "Buscar"
   #define STR0002 "Visualizar"
   #define STR0003 "Incluir"
   #define STR0004 "Modificar"
   #define STR0005 "Borrar"
   #define STR0006 "Automatico"
   #define STR0007 "Leyenda"
   #define STR0008 "Maestro de inventario"
   #define STR0009 "No puede dejarse vacio el campo Direccion."
   #define STR0010 "Opcion disponible solamente cuando utilice ubicacion"
   #define STR0011 "No Iniciado"
   #define STR0012 "En ejecucion"
   #define STR0013 "Finalizado"
   #define STR0014 "Procesado"
   #define STR0015 "Leyenda - Maestro Inventario"
   #define STR0016 "Estatus"
   #define STR0017 "Monitor"
   #define STR0018 "Informe"
   #define STR0019 "Es necesario activar el parametro MV_CBPE012"
   #define STR0020 "¡Inventario en ejecucion, no podra modificarse!"
   #define STR0021 "¡Inventario en pausa, no podra modificarse!"
   #define STR0022 "¡Inventario concluido, no podra modificarse!"
   #define STR0023 "¡No se permite el borrado de Maestros de Inventario ya procesados!"
   #define STR0024 "Asientos Inventariados"
   #define STR0025 "¿Desea proseguir con el borrado?"
   #define STR0026 "Atencion"
   #define STR0027 "¡No se permite el borrado de Maestros de Inventario con conteos en ejecucion!"
   #define STR0028 "Es necesario borrar o finalizar el conteo en ejecucion."
   #define STR0029 "Ya se realizaron conteos para este Maestro de Inventario, "
   #define STR0030 "si se borra el mismo, ¡todos los conteos realizados tambien se borraran!"
   #define STR0031 "Fecha del Inventario menor que la fecha base"
   #define STR0032 "Inventario ya registrado "
   #define STR0033 "Generacion automatica"
   #define STR0034 "Esta rutina tiene el objetivo de efectuar la generacion"
   #define STR0035 "automatica de maestros de inventario a partir del"
   #define STR0036 "range informado por el operador en los parametros."
   #define STR0037 "A T E N C I O N :"
   #define STR0038 "Esta rutina tiene el objetivo de efectuar el borrado"
   #define STR0039 "automatico de maestros de inventarios informados "
   #define STR0040 "en los parametros solicitados."
   #define STR0041 "automatico de los asientos de inventarios infor-"
   #define STR0042 "mados en los parametros solicitados."
   #define STR0043 "El numero de conteos no puede ser igual o inferior a cero, ¡por favor verifique!"
   #define STR0044 "En Pausa"
   #define STR0045 "Contado"
   #define STR0046 "Maestros Inventariados"
   #define STR0047 "                         I N F O R M A T I V O"
   #define STR0048 "               H I S T O R I A L   D E   B O R R A D O S"       
   #define STR0049 "                                   D E"
   #define STR0050 "                  M A E S T R O S  D E  I N V E N T A R I O"
   #define STR0051 "P A R A M E T R O S:"
   #define STR0052 "De Maestro  : "
   #define STR0053 "A Maestro : "
   #define STR0054 "M A E S T R O S   P R O C E S A D O S :"
   #define STR0055 "Maestro: "
   #define STR0056 ", borrado con exito!"
   #define STR0057 "Cantidad de maestros de inventarios borrados.: "
   #define STR0058 "Asientos de Inventario"
   #define STR0059 "               H I S T O R I A L   D E   G E N E R A C I O N E S"
   #define STR0060 "            A S I E N T O  D  E  I N V E N T A R I O (SB7)"
   #define STR0061 "I T E M S   P R O C E S A D O S :"
   #define STR0062 "Cantidad de maestros de inventarios analizados.: "
   #define STR0063 "Cantidad de maestros de inventarios Ok.........: "
   #define STR0064 "Cantidad de maestros de inventarios Divergentes: "
   #define STR0065 "D O C U M E N T O S   P R O C E S A D O S :"
   #define STR0066 "Maestro:"
   #define STR0067 ", se borraron "
   #define STR0068 " documentos en la tabla de asie. invent."
   #define STR0069 "Ajuste de Inventario"
   #define STR0070 "                 M A E S T R O   D E   I N V E N T A R I O"
   #define STR0071 "Pregunta "
   #define STR0072 " - Lugar: "
   #define STR0073 " - Direccion: "
   #define STR0074 " - Producto: "
   #define STR0075 'Este Maestro de Inventario esta finalizado, si el mesmo se borrara, se efectuara el borrado de '
   #define STR0076 'todas las STR0024 (SB7) de este Maestro y este Maestro de Inventario quedara con el'
   #define STR0077 'Estatus de la STR0012.'
   #define STR0078 'Para borrar definitivamente este '
   #define STR0079 'Mestro de Inventario, esta rutina debera ejecutarse hasta que el Maestro de inventario este con ' 
   #define STR0080 'Estatus de la STR0011 o STR0012.'
   #define STR0081 'Esta rutina tiene el objetivo de efectuar la generacion automatica'
   #define STR0082 'del asiento de inventario (tabla SB7), a traves de la tabla'
   #define STR0083 'de maestro de inventario (CBA), que ya se finalizo. En caso que'
   #define STR0084 'el modelo del inventario sea el "2", solo se generara asiento'
   #define STR0085 'para los totales inventariados diferentes del saldo en stock.'
   #define STR0086 'Esta rutina generara movimientos de ajuste para corregir el saldo del'
   #define STR0087 'stock. Estos movimientos se basaran en los conteos realizados y'
   #define STR0088 'registrados en la rutina de inventario.'
   #define STR0089 'Esta rutina tambien efectuara el ajuste de las etiquetas (CB0), en caso que el'
   #define STR0090 'cliente utilice codigo interno.'
   #define STR0091 'Esta Rutina borrara todas las STR0046 que tengan el siguiente estatus:'
   #define STR0092 '0 = No iniciado'
   #define STR0093 '2 = En Pausa'
   #define STR0094 '3 = Contado'
   #define STR0095 'Para los maestros que tuvieran conteo en ejecucion, ¡los mismos deberan finalizarse antes '
   #define STR0096 'de su borrado!'
   #define STR0097 'Esta Rutina generara la STR0024 (SB7) de los '
   #define STR0098 'Maestros de Inventario informados en el range, modificando el Estatus a STR0013'
   #define STR0099 '¿Desea proseguir con la generacion de la STR0058?'
   #define STR0100 'Esta Rutina borrara todas las STR0024 (SB7) de los '
   #define STR0101 'Maestros de Inventario informados en el range, modificando el Estatus a STR0012'
   #define STR0102 '¿Desea proseguir con la STR0069?'
   #define STR0103 'Si'
   #define STR0104 'No'
   #define STR0105 "E X C E P C I O N E S:"
   #define STR0106 "- No se genero maestro de inventario para el(los) item(s) siguiente(s)."
   #define STR0107 "Lugar: "
   #define STR0108 "Producto: "
   #define STR0109 "Exito(s)....:"
   #define STR0110 "Divergencia(s):"
#ELSE
   #IFDEF ENGLISH
      #define STR0001 "Search"
      #define STR0002 "View"
      #define STR0003 "Add"
      #define STR0004 "Modify"
      #define STR0005 "Delete"
      #define STR0006 "Automatic"
      #define STR0007 "Legend"
      #define STR0008 "Inventory Master"
      #define STR0009 "Address field cannot be blank."
      #define STR0010 "Option available only when addressing is used"
      #define STR0011 "Not started"
      #define STR0012 "In progress"
      #define STR0013 "Concluded"
      #define STR0014 "Processed"
      #define STR0015 "Legend - Inventory Master"
      #define STR0016 "Status"
      #define STR0017 "Monitor"
      #define STR0018 "Report"
      #define STR0019 "The parameter MV_CBPE012 must be activated"
      #define STR0020 "Inventory in progress, cannot be modified!!!"
      #define STR0021 "Inventory paused, cannot be altered!!!"
      #define STR0022 "Inventory concluded, cannot be modified!!!"
      #define STR0023 "Inventory Masters already processed cannot be deleted!!!"
      #define STR0024 "Inventoried entries"
      #define STR0025 "Wish to proceed with deletion?"
      #define STR0026 "Attention"
      #define STR0027 "Inventory Masters in progress cannot be deleted!!!"
      #define STR0028 "The counting in progress must be deleted or concluded."
      #define STR0029 "Counting for this Inventory Master already done, "
      #define STR0030 "if it is deleted, all the counts made will be deleted too!!!"
      #define STR0031 "Inventory date less than the database"
      #define STR0032 "Inventory already registered"
      #define STR0033 "Automatic generation"
      #define STR0034 "The objective of this routine is to generate"
      #define STR0035 "inventory masters automatically, from the"
      #define STR0036 "range input by the operator in the parameters."
      #define STR0037 "A T T E N T I O N:"
      #define STR0038 "The objective of this routine is to delete"
      #define STR0039 "automatically the inventory masters input "
      #define STR0040 "in the parameters requested."
      #define STR0041 "automatically the inventory entries input"
      #define STR0042 "in the parameters requested."
      #define STR0043 "Number of counts cannot be equal to or less than zero, please check!!!"
      #define STR0044 "Paused"
      #define STR0045 "Counted"
      #define STR0046 "Inventoried Masters"
      #define STR0047 "                         N E W S L E T T E R"
      #define STR0048 "               H I S T O R Y   O F   D E L E T I O N S "
      #define STR0049 "                                   O F"
      #define STR0050 "                  I N V E N T O R Y   M A S T E R S"
      #define STR0051 "P A R A M E T E R S:"
      #define STR0052 "Master from: "
      #define STR0053 "Master till: "
      #define STR0054 "M A S T E R S   P R O C E S S E D :"
      #define STR0055 "Master: "
      #define STR0056 ", deleted successfully!"
      #define STR0057 "Number of inventory masters deleted: "
      #define STR0058 "Inventory Entries"
      #define STR0059 "               G E N E R A T I O N   H I S T O R Y "
      #define STR0060 "            I N V E N T O R Y    E N T R Y (SB7)"
      #define STR0061 "I T E M S   P R O C E S S E D :"
      #define STR0062 "Number of inventory masters analyzed: "
      #define STR0063 "Number of inventory masters Ok.........: "
      #define STR0064 "Number of inventory masters discrepant: "
      #define STR0065 "D O C U M E N T S   P R O C E S S E D :"
      #define STR0066 "Master:"
      #define STR0067 ", were deleted "
      #define STR0068 " documents in the table invent.entr."
      #define STR0069 "Inventory Adjustment"
      #define STR0070 "                 I N V E N T O R Y   M A S T E R"
      #define STR0071 "Question "
      #define STR0072 " - Locat.: "
      #define STR0073 " - Address: "
      #define STR0074 " - Product: "
      #define STR0075 'This Inventory Master is concluded, its deletion will cause the deletion of'
      #define STR0076 'all STR0024 (SB7) of this Master and this Inventory Master will have the '
      #define STR0077 'Status of STR0012.'
      #define STR0078 'For conclusive deletion of this'
      #define STR0079 'Inventory Masterm, this routine must be executed till the Inventory Master has the'
      #define STR0080 'Status of STR0011 of STR0012.'
      #define STR0081 'The objective of this routine is to generate automatically'
      #define STR0082 'the inventory entry (table SB7), through the table'
      #define STR0083 'of inventory master (CBA), which was already concluded. If'
      #define STR0084 'the inventory model is "2", an entry will be generated only'
      #define STR0085 'for the totals inventoried different from the balance in stock.'
      #define STR0086 'This routine will generate adjustment entries to correct the balance in'
      #define STR0087 'stock. These entries will be based on counts made and'
      #define STR0088 'registered in the inventory routine.'
      #define STR0089 'This routine will also adjust the labels (CB0), if the'
      #define STR0090 'customer uses internal code.'
      #define STR0091 'This routine will delete all the STR0046 with the following status:'
      #define STR0092 '0 = Not started'
      #define STR0093 '2 = Paused'
      #define STR0094 '3 = Counted'
      #define STR0095 'For master in progress, the same must be closed before '
      #define STR0096 'their deletion!'
      #define STR0097 'This Routine will generate STR0024 (SB7) of '
      #define STR0098 'Inventory masters input in the range, modifying the status to STR0013'
      #define STR0099 'Wish to proceed with generation of STR0058?'
      #define STR0100 'This routine will delete all the STR0024 (SB7) of the '
      #define STR0101 'Inventory Masters input in the range, modifying the status to STR0012'
      #define STR0102 'Wish to proceed with STR0069?'
      #define STR0103 'Yes'
      #define STR0104 'No'
      #define STR0105 "E X C E P T I O N S:"
      #define STR0106 "- Inventory master was not generated for the item(s) below."
      #define STR0107 "Locat.: "
      #define STR0108 "Product: "
      #define STR0109 "Success(es)....:"
      #define STR0110 "Discrepancy(ies):"
   #ELSE
      #define STR0001 "Pesquisar"
      #define STR0002 "Visualizar"
      #define STR0003 "Incluir"
      #define STR0004 "Alterar"
      #define STR0005 "Excluir"
      #define STR0006 "Automatico"
      #define STR0007 "Legenda"
      #define STR0008 "Mestre de inventario"
      #define STR0009 "O campo endereco nao pode ficar em branco."
      #define STR0010 "Opcao disponivel somente quando utilizar enderecamento"
      #define STR0011 "Nao Iniciado"
      #define STR0012 "Em Andamento"
      #define STR0013 "Finalizado"
      #define STR0014 "Processado"
      #define STR0015 "Legenda - Mestre Inventario"
      #define STR0016 "Status"
      #define STR0017 "Monitor"
      #define STR0018 "Relatorio"
      #define STR0019 "Necessario ativar o parametro MV_CBPE012"
      #define STR0020 "Inventario em andamento, nao sera possivel alterar!!!"
      #define STR0021 "Inventario em pausa, nao sera possivel alterar!!!"
      #define STR0022 "Inventario concluido, nao sera possivel alterar!!!"
      #define STR0023 "Nao e permitida a exclusao de Mestres de Inventario ja processado !!!"
      #define STR0024 "Lancamentos Inventariados"
      #define STR0025 "Deseja prosseguir com a exclusao?"
      #define STR0026 "Atencao"
      #define STR0027 "Nao e permitida a exclusao de Mestres de Inventario com contagens em andamento!!!"
      #define STR0028 "Necessario excluir ou finalizar a contagem em andamento."
      #define STR0029 "Ja foram realizadas contagens para este Mestre de Inventario, "
      #define STR0030 "se o mesmo for excluido todas as contagens realizadas tambem serao excluidas !!!"
      #define STR0031 "Data do Inventario menor que a database"
      #define STR0032 "Inventario ja cadastrado "
      #define STR0033 "Geracao automatica"
      #define STR0034 "Esta rotina tem o objetivo de efetuar a geracao"
      #define STR0035 "automatica de mestres de inventario, a partir do"
      #define STR0036 "range informado pelo operador nos parametros."
      #define STR0037 "A T E N C A O:"
      #define STR0038 "Esta rotina tem o objetivo de efetuar a exclusao"
      #define STR0039 "automatica de mestres de inventarios informados "
      #define STR0040 "nos parametros solicitados."
      #define STR0041 "automatica dos lancamentos de inventarios infor-"
      #define STR0042 "mados nos parametros solicitados."
      #define STR0043 "O numero de contagens nao pode ser igual ou inferior a zero, favor verificar !!!"
      #define STR0044 "Em Pausa"
      #define STR0045 "Contado"
      #define STR0046 "Mestres Inventariados"
      #define STR0047 "                         I N F O R M A T I V O"
      #define STR0048 "               H I S T O R I C O   D A S   E X C L U S O E S"
      #define STR0049 "                                   D E"
      #define STR0050 "                  M E S T R E S  D E  I N V E N T A R I O"
      #define STR0051 "P A R A M E T R O S:"
      #define STR0052 "Mestre De  : "
      #define STR0053 "Mestre Ate : "
      #define STR0054 "M E S T R E S   P R O C E S S A D O S :"
      #define STR0055 "Mestre: "
      #define STR0056 ", excluido com sucesso!"
      #define STR0057 "Quantidade de mestres de inventarios excluidos.: "
      #define STR0058 "Lancamentos de Inventario"
      #define STR0059 "               H I S T O R I C O   D A S   G E R A C O E S"
      #define STR0060 "            L A N C A M E N T O  D O  I N V E N T A R I O (SB7)"
      #define STR0061 "I T E N S   P R O C E S S A D O S :"
      #define STR0062 "Quantidade de mestres de inventarios analisados.: "
      #define STR0063 "Quantidade de mestres de inventarios Ok.........: "
      #define STR0064 "Quantidade de mestres de inventarios Divergentes: "
      #define STR0065 "D O C U M E N T O S   P R O C E S S A D O S :"
      #define STR0066 "Mestre:"
      #define STR0067 ", foram excluidos "
      #define STR0068 " documentos na tabela de lanc. invent."
      #define STR0069 "Acerto de Inventario"
      #define STR0070 "                 M E S T R E   D E   I N V E N T A R I O"
      #define STR0071 "Pergunta "
      #define STR0072 " - Local: "
      #define STR0073 " - Endereco: "
      #define STR0074 " - Produto: "
      #define STR0075 'Este Mestre de Inventario esta finalizado, se o mesmo for excluido, sera efetuada a exclusao de '
      #define STR0076 'todos "Lancamentos inventariados" (SB7) deste Mestre, e este Mestre de Inventario ficara com '
      #define STR0077 'Status de "Em Andamento".'
      #define STR0078 'Para excluir definitivamente este '
      #define STR0079 'Mestre de Inventario, esta rotina devera ser executada ate que o Mestre de inventario esteja com '
      #define STR0080 'Status de "Nao Iniciado" ou "Em Andamento".'
      #define STR0081 'Esta rotina tem o objetivo de efetuar a geracao automatica'
      #define STR0082 'do lancamento de inventario (tabela SB7), atraves da tabela'
      #define STR0083 'de mestre de inventario (CBA), que ja foi finalizada. Caso'
      #define STR0084 'o modelo do inventario seja o "2", so sera gerado lancamento'
      #define STR0085 'para os totais inventariados diferentes do saldo em estoque.'
      #define STR0086 'Esta rotina ira gerar movimentacoes de ajuste para corrigir o saldo do'
      #define STR0087 'estoque. Estas movimentacoes serao baseadas nas contagens realizadas e'
      #define STR0088 'cadastradas na rotina de inventario.'
      #define STR0089 'Esta rotina tambem ira efetuar o ajuste das etiquetas (CB0), caso o'
      #define STR0090 'cliente utilize codigo interno.'
      #define STR0091 'Esta Rotina ira excluir todos "Mestres Inventariados" que possuirem o seguinte status:'
      #define STR0092 '0 = Nao iniciado'
      #define STR0093 '2 = Em Pausa'
      #define STR0094 '3 = Contado'
      #define STR0095 'Para os mestres que possuirem contagem em andamento, as mesmas deverao ser encerradas antes '
      #define STR0096 'de sua exclusao!'
      #define STR0097 'Esta Rotina ira gerar "Lancamento inventariados" (SB7) dos '
      #define STR0098 'Mestres de Inventario informados no range, alterando o Status para "Finalizado"'
      #define STR0099 'Deseja prosseguir com a geracao de "Lancamentos de inventario"?'
      #define STR0100 'Esta Rotina ira excluir todos "Lancamentos inventariados" (SB7) dos '
      #define STR0101 'Mestres de Inventario informados no range, alterando o Status para "Em Andamento"'
      #define STR0102 'Deseja prosseguir com o "Acerto de Inventario"?'
      #define STR0103 'Sim'
      #define STR0104 'Nao'
      #define STR0105 "E X C E C O E S:"
      #define STR0106 "- Nao foi gerado mestre de inventario para o(s) item(s) abaixo."
      #define STR0107 "Local: "
      #define STR0108 "Produto: "
      #define STR0109 "Sucesso(s)....:"
      #define STR0110 "Divergencia(s):"
   #ENDIF
#ENDIF
