#ifdef SPANISH
	#define STR0001 "Calculo del Plan de Salud"
	#define STR0002 "Este Programa calculara los valores de los Planes de Salud"
	#define STR0003 "�Informe una fecha de Referencia mayor o igual a la Competencia de la Planilla de Haberes!"
	#define STR0004 "Calculando Plan de Salud de:"
	#define STR0005 "Calculo del Plan de Salud"
	#define STR0006 "�Filtrar Competencia!"
	#define STR0007 "Inicio del procesamiento"
	#define STR0008 "Fin del procesamiento"
	#define STR0009 "Tabla no Registrada o Valores fuera del Rango"
	#define STR0010 "Codigo:"
	#define STR0011 "As. Medica"
	#define STR0012 "As. Odontologica"
	#define STR0013 "del Tipo"
	#define STR0014 "Rango Salarial"
	#define STR0015 "Rango Etario"
	#define STR0016 "Valor Fijo"
	#define STR0017 "Porcentaje sobre Salario"
	#define STR0018 "Dependientes y Agregados calculados con valores en CEROS"
	#define STR0019 "LOG de Calculo de Plan de Salud"
	#define STR0020 "Sec Dependiente:"
	#define STR0021 "Sec Agregado: "
	#define STR0022 "Atencion"
	#define STR0023 "Ejecute la opcion de compatibilizador referente al Nuevo Plan de Salud. Para mayores informaciones, verifique respectivo Boletin Tecnico."
	#define STR0024 "OK"
	#define STR0025 "Enter a period greater or equal to Last Period pending in Payroll!"
	#define STR0026 "Titular posee mas de un plan con mismo Proveedor"
	#define STR0027 "Titular no posee plan de salud activo para el Mes y Ano del calculo"
	#define STR0028 "El titular posee plan de salud con Periodo Inicial y Final divergente del Mes y Ano del calculo"
	#define STR0029 "Sucursal: "
	#define STR0030 "Proceso: "
	#define STR0031 " Inicio: "
	#define STR0032 " Fin: "
	#define STR0033 "Sueldo/Etaria"
	#define STR0034 "Coparticipacion o reembolso calculado aunque el plan de salud esta expirado"
	#define STR0035 " Proveedor: "
	#define STR0036 " Fecha de ocurrencia: "
	#define STR0037 " Observacion: "
	#define STR0038 "Archivo de empleados con informacion de que el empleado tiene seguro de salud, sin embargo no existe seguro activo."
	#define STR0039 "Archivo de dependientes con informacion de que tiene seguro de salud, sin embargo no existe seguro activo."
#else
	#ifdef ENGLISH
		#define STR0001 "Health Plan Calculation"
		#define STR0002 "This Program calculates Health Plan values"
		#define STR0003 "Enter a Reference date later or equal to Payroll Jurisdiction!"
		#define STR0004 "Calculating Health Plan of:"
		#define STR0005 "Health Plan Calculation"
		#define STR0006 "Filter Jurisdiction!"
		#define STR0007 "Start of processing"
		#define STR0008 "Processing end"
		#define STR0009 "Table not Registered or values out of Range"
		#define STR0010 "Code:"
		#define STR0011 "Plan Medical"
		#define STR0012 "Plan Dental"
		#define STR0013 "of Type"
		#define STR0014 "Salary Range"
		#define STR0015 "Age Range"
		#define STR0016 "Fixed Amount"
		#define STR0017 "Percentage upon Salary"
		#define STR0018 "Dependant and Aggregate values calculated with ZEROS"
		#define STR0019 "Health Plan Calculation LOG"
		#define STR0020 "Dependant Sequence:"
		#define STR0021 "Aggregate Sequence: "
		#define STR0022 "Attention"
		#define STR0023 "Run the compatibilizer option related to the New Health Plan. For more information, check the respective Technical Newsletter."
		#define STR0024 "OK"
		#define STR0025 "Enter a period greater or equal to Last Period pending in Payroll!"
		#define STR0026 "Owner has more than one plan with the same Supplier"
		#define STR0027 "Holder does not have any active health care plan for the calculation month and year."
		#define STR0028 "Holder has a health care plan with Initial and Final Period different from  the calculation Month and Year"
		#define STR0029 "Branch: "
		#define STR0030 "Process: "
		#define STR0031 " Start: "
		#define STR0032 " End: "
		#define STR0033 "Salary/Age"
		#define STR0034 "Co-participation or reimbursement calculated with expiring health insurance plan"
		#define STR0035 " Supplier: "
		#define STR0036 " Date of Occurrence: "
		#define STR0037 " Note: "
		#define STR0038 "Employees file with information that employee has health care plan, but it is not active."
		#define STR0039 "Dependents file with information that dependent has health care plan, but it is not active."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "C�lculo do plano de sa�de", "Calculo do Plano de Saude" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Este programa calcular� os valores dos Planos de Saude", "Este Programa calcular� os valores dos Planos de Saude" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Informe uma data de refer�ncia maior ou igual � compet�ncia da Folha de Pagamento.", "Informe uma data de Refer�ncia maior ou igual � Compet�ncia da Folha de Pagamento!" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "A calcular Plano de Sa�de de:", "Calculando Plano de Saude de:" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "C�lculo do Plano de Sa�de", "Calculo do Plano de Saude" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Filtrar compet�ncia.", "Filtrar Compet�ncia!" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "In�cio do processamento", "Inicio do processamento" )
		#define STR0008 "Fim do processamento"
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Tabela n�o registada ou valores fora da faixa", "Tabela n�o Cadastrada ou Valores fora da Faixa" )
		#define STR0010 "C�digo:"
		#define STR0011 "As. M�dica"
		#define STR0012 "As. Odontol�gica"
		#define STR0013 "do Tipo"
		#define STR0014 "Faixa Salarial"
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Faixa et�ria", "Faixa Et�ria" )
		#define STR0016 "Valor Fixo"
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Porcentagem sobre sal�rio", "Porcentagem sobre Salario" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Dependentes e agregados calculados com valores com ZEROS", "Dependentes e Agregados calculados com valores com ZEROS" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "LOG de C�lculo de Plano de Sa�de", "LOG de Calculo de Plano de Saude" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Seq.Dependente:", "Seq Dependente:" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Seq.Agregado: ", "Seq Agregado: " )
		#define STR0022 "Aten��o"
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Execute a op��o do compatibilizador referente ao Novo Plano de Sa�de. Para mais informa��es, verifique respectivo Boletim T�cnico.", "Execute a op��o do compatibilizador referente ao Novo Plano de Sa�de. Para maiores informa��es, verifique respectivo Boletim T�cnico." )
		#define STR0024 "OK"
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Informe um per�odo maior ou igual ao �ltimo per�odo em aberto da folha.", "Informe um periodo maior ou igual ao Ultimo Periodo em aberto da Folha!" )
		#define STR0026 "Titular possui mais de um plano com mesmo Fornecedor"
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "O titular n�o possui plano de sa�de activo para o m�s e ano do c�lculo", "Titular nao possui plano de sa�de ativo para o M�s e Ano do c�lculo" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Titular possui plano de sa�de com per�odo inicial e final divergente do m�s e ano do c�lculo", "Titular possui plano de sa�de com Per�odo Inicial e Final divergente do M�s e Ano do c�lculo" )
		#define STR0029 "Filial: "
		#define STR0030 "Processo: "
		#define STR0031 " In�cio: "
		#define STR0032 " Fim: "
		#define STR0033 "Salarial/Et�ria"
		#define STR0034 "Co-participa��o ou reembolso calculado mesmo com plano de saude expirado"
		#define STR0035 " Fornecedor: "
		#define STR0036 " Data de Ocorrencia: "
		#define STR0037 " Observa��o: "
		#define STR0038 "Cadastro de funcion�rios com informa��o de que funcion�rio possui plano de sa�de, por�m n�o existe plano ativo."
		#define STR0039 "Cadastro de dependentes com informa��o de que possui plano de sa�de, por�m n�o existe plano ativo."
	#endif
#endif
