#ifdef SPANISH
	#define STR0001 "Registro del reloj"
	#define STR0002 "Se imprimira de acuerdo con los parametros solicitados por el"
	#define STR0003 "usuario."
	#define STR0004 "Matricula"
	#define STR0005 "Centro de costo"
	#define STR0006 "Nombre"
	#define STR0007 "Turno"
	#define STR0008 "A Rayas"
	#define STR0009 "Administracion"
	#define STR0013 "Firma del empleado"
	#define STR0014 "T O T A L E S"
	#define STR0015 "Cod Descripcion              Calc.            Cod Descripcion              Calc.          "
	#define STR0016 "Cod Descripcion                       Infor.  Cod Descripcion                       Infor."
	#define STR0017 "Cod Descripcion              Calc.    Infor.  Cod Descripcion              Calc.    Infor."
	#define STR0018 "** Excepcion no Trabajada **"
	#define STR0019 "** Feriado **"
	#define STR0020 "** Ausente **"
	#define STR0021 "** D.S.R. **"
	#define STR0022 "** Compensado **"
	#define STR0023 "** No Trabajado **"
	#define STR0024 "Emp...: "
	#define STR0025 " Matr..: "
	#define STR0026 "  Placa : "
	#define STR0027 "Direc.: "
	#define STR0028 " Nombr.: "
	#define STR0029 "Num Contr:"
	#define STR0030 " Funcion:"
	#define STR0031 "C.C...: "
	#define STR0032 " Categ.: "
	#define STR0033 "Turno.: "
	#define STR0034 "   FECHA   DIA     "
	#define STR0035 "a E. "
	#define STR0036 "a S. "
	#define STR0037 "Motivo de Abono           Horas  Tipo da marcacion"
	#define STR0038 "C.Costo + Nombre"
	#define STR0039 "Periodo de apunte no valido."
	#define STR0040 "Consultar marcaciones"
	#define STR0041 "Motivo de abono"
	#define STR0042 "Fecha"
	#define STR0043 "Dia"
	#define STR0044 "&#170;E."
	#define STR0045 "&#170;S."
	#define STR0046 "Observaciones"
	#define STR0047 "Horas  Tipo de marcacion"
	#define STR0048 "Turno "
	#define STR0049 "Turnos: "
	#define STR0050 "Proceso + Matricula"
	#define STR0051 "Depto.: "
	#define STR0052 "Seleccione la opcion de impresion: "
	#define STR0053 "Por Periodo"
	#define STR0054 "Por Fechas"
	#define STR0055 "Proceso: "
	#define STR0056 "Periodo: "
	#define STR0057 "Procedim.: "
	#define STR0058 "Num.Pago: "
#else
	#ifdef ENGLISH
		#define STR0001 "Time Accounting Report"
		#define STR0002 "It will be printed according to the parameters selected "
		#define STR0003 "by the User."
		#define STR0004 "Registr."
		#define STR0005 "Cost Center"
		#define STR0006 "Name"
		#define STR0007 "Shift"
		#define STR0008 "Z.Form"
		#define STR0009 "Management"
		#define STR0013 "Employee signature"
		#define STR0014 "T O T A L S"
		#define STR0015 "Cod Descript.                Calc.            Cod Descript.                Calc.          "
		#define STR0016 "Cod Descript.                         Infor.  Cod Descript.                         Infor."
		#define STR0017 "Cod Descript.                Calc.    Infor.  Cod Descript.                Calc.    Infor."
		#define STR0018 "** Except. not Worked **"
		#define STR0019 "** Holiday **"
		#define STR0020 "** Absent **"
		#define STR0021 "** D.S.R. **"
		#define STR0022 "** Compensat. **"
		#define STR0023 "** Not Worked **"
		#define STR0024 "Com...: "
		#define STR0025 " Reg..: "
		#define STR0026 "  Plate : "
		#define STR0027 "Add...: "
		#define STR0028 " Name..: "
		#define STR0029 "CGC...: "
		#define STR0030 " Funct.: "
		#define STR0031 "C.C...: "
		#define STR0032 " Categ.: "
		#define STR0033 "Shift.: "
		#define STR0034 "   DATE    DAY     "
		#define STR0035 "to I. "
		#define STR0036 "to O. "
		#define STR0037 "Note                      Hours  Mark Type        "
		#define STR0038 "C.Cent. + Name"
		#define STR0039 "Invalid Annotation Period."
		#define STR0040 "Browse Anotations"
		#define STR0041 "Bonus Reason"
		#define STR0042 "Date"
		#define STR0043 "Day"
		#define STR0044 "&#170;I."
		#define STR0045 "&#170;O."
		#define STR0046 "Observations"
		#define STR0047 "Hours  Mark Type"
		#define STR0048 "Shift "
		#define STR0049 "Shifts: "
		#define STR0050 "Process + Registration"
		#define STR0051 "Dep.: "
		#define STR0052 "Select the printing option: "
		#define STR0053 "By Period"
		#define STR0054 "By Dates"
		#define STR0055 "Process: "
		#define STR0056 "Period: "
		#define STR0057 "Procedure: "
		#define STR0058 "Paym. Nbr.: "
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Espelho Do Ponto", "Espelho do Ponto" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Ser� impresso de acordo com os par�metros solicitados pelo", "Ser� impresso de acordo com os parametros solicitados pelo" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Utilizador.", "usuario." )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Registo", "Matricula" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Centro De Custo", "Centro de Custo" )
		#define STR0006 "Nome"
		#define STR0007 "Turno"
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "C�digo de barras", "Zebrado" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Administra��o", "Administra��o" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Assinatura do Empregado", "Assinatura do Funcionario" )
		#define STR0014 "T O T A I S"
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "C�d descri��o                c�lc.            c�d descri��o                c�lc.          ", "Cod Descricao                Calc.            Cod Descricao                Calc.          " )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "C�d Descri��o                         Infor.  C�d Descri��o                         Infor.", "Cod Descricao                         Infor.  Cod Descricao                         Infor." )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "C�d Descri��o                C�lc.    Infor.  C�d Descri��o                C�lc.    Infor.", "Cod Descricao                Calc.    Infor.  Cod Descricao                Calc.    Infor." )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "** excep��o n�o trabalhada **", "** Excecao nao Trabalhada **" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "** feriado **", "** Feriado **" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "** ausente **", "** Ausente **" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "** d.s.r. **", "** D.S.R. **" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "** Compensado", "** Compensado **" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "** n�o trabalhado **", "** Nao Trabalhado **" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Emp.:", "Emp...: " )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Reg.:", " Matr..: " )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "  Cart�o Reg.: ", "  Chapa : " )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Morada:", "End...: " )
		#define STR0028 " Nome..: "
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "NIF", "CGC...: " )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", " fun��o: ", " Funcao: " )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "C.c.:", "C.C...: " )
		#define STR0032 " Categ.: "
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "Turno:", "Turno.: " )
		#define STR0034 "   DATA    DIA     "
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "A.e.", "a E. " )
		#define STR0036 If( cPaisLoc $ "ANG|PTG", "A s. ", "a S. " )
		#define STR0037 If( cPaisLoc $ "ANG|PTG", "Observa��o  Horas  Tipo Da Marca��o", "Observacao                Horas  Tipo da Marcacao" )
		#define STR0038 If( cPaisLoc $ "ANG|PTG", "C.custo + Nome", "C.Custo + Nome" )
		#define STR0039 If( cPaisLoc $ "ANG|PTG", "Per�odo De Apontamento Inv�lido.", "Periodo de Apontamento Invalido." )
		#define STR0040 If( cPaisLoc $ "ANG|PTG", "Consultar Marca��es", "Consultar Marca&ccedil;&otilde;es" )
		#define STR0041 If( cPaisLoc $ "ANG|PTG", "Motivo De Autoriza��o", "Motivo de Abono" )
		#define STR0042 "Data"
		#define STR0043 "Dia"
		#define STR0044 If( cPaisLoc $ "ANG|PTG", "&#170;e.", "&#170;E." )
		#define STR0045 If( cPaisLoc $ "ANG|PTG", "&#170;s.", "&#170;S." )
		#define STR0046 If( cPaisLoc $ "ANG|PTG", "Observa&��e&s", "Observa&ccedil;&otilde;es" )
		#define STR0047 If( cPaisLoc $ "ANG|PTG", "Horas   Tipo Da Marca&��&o", "Horas  Tipo da Marca&ccedil;&atilde;o" )
		#define STR0048 If( cPaisLoc $ "ANG|PTG", "Turno", "Turno " )
		#define STR0049 If( cPaisLoc $ "ANG|PTG", "Turnos:", "Turnos: " )
		#define STR0050 If( cPaisLoc $ "ANG|PTG", "Processo + registo", "Processo + Matr�cula" )
		#define STR0051 "Depto.: "
		#define STR0052 If( cPaisLoc $ "ANG|PTG", "Seleccionar a op��o  de impressao: ", "Selecione a op��o de impress�o: " )
		#define STR0053 "Por Per�odo"
		#define STR0054 "Por Datas"
		#define STR0055 "Processo: "
		#define STR0056 "Per�odo: "
		#define STR0057 If( cPaisLoc $ "ANG|PTG", "Mapa: ", "Roteiro: " )
		#define STR0058 If( cPaisLoc $ "ANG|PTG", "Num.pgt: ", "Num.Pagto: " )
	#endif
#endif
