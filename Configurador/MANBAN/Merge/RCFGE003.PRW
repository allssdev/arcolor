#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRCFGE003  บAutor  ณAdriano Leonardo    บ Data ณ  14/02/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina responsแvel por montar o comando merge para sincro- บฑฑ
ฑฑบ          ณ nia entre os bancos de dados dos servidores 1 e 2.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณProtheus 11 - Especํfico para a empresa Arcolor.(CD Control)บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function RCFGE003(_cServOri,_cServDes,_cTabela,_cFiltro,_cInsert,_cUpdate,_cInstPos)

Local _aSavArea		:= GetArea()
Local _cRotina		:= "RCFGE003"
Local _lAtuStru		:= .F.

Default _cServOri	:= "Protheus11"
Default _cServDes	:= "P11Oficial"
Default _cTabela	:= ""
Default _cFiltro	:= ""
Default _cInsert	:= ""
Default _cUpdate	:= ""
Default _cInstPos	:= ""

Private _lRecDel	:= .F.
If TCSQLExec("SELECT * FROM [" + AllTrim(_cServOri) + "].[dbo].[" + _cTabela + "]") < 0
	RestArea(_aSavArea)
	Return
EndIf
//Inicializo as variแveis
_cCampo	:= _cOrige := _cDesti := _cUpdat := ""
_cFixos := ""
_cFixIn := ""
_cFixVl := ""
//Resgato o alias da tabela
_cAlias := SubStr(_cTabela,1,3)
//Checo se os campos existem
_cCkCpo := "SELECT " + _cTabela + ".R_E_C_N_O_ AS [MR_E_C_N_O_] FROM [" + AllTrim(_cServOri) + "].[dbo].[" + _cTabela + "]"
If TCSQLExec(_cCkCpo) >= 0
	_cFixos += _cTabela + ".R_E_C_N_O_ AS [MR_E_C_N_O_], "
	_cFixIn += "R_E_C_N_O_,"
	_cFixVl += "MR_E_C_N_O_,"
	_cAltBD := " If Exists(SELECT 1 FROM syscolumns WHERE id = object_id('[" + AllTrim(_cServOri) + "].[dbo]." + RetSqlName(_cAlias) + "') AND name = 'R_E_C_N_O_'  )
	_cAltBD += " ALTER TABLE " + AllTrim(_cServDes) + ".dbo." + RetSqlName(_cAlias) + " ADD R_E_C_N_O_   INT "   + " NOT NULL CONSTRAINT R_E_C_N_O__RF DEFAULT " + '0'
	If !Empty(_cAltBD)
		TCSQLExec(_cAltBD)
	EndIf
EndIf
_cCkCpo := "SELECT " + _cTabela + ".R_E_C_D_E_L_ AS [MR_E_C_D_E_L_] FROM [" + AllTrim(_cServOri) + "].[dbo].[" + _cTabela + "]"
If TCSQLExec(_cCkCpo) >= 0
	_cFixos += _cTabela + ".R_E_C_D_E_L_ AS [MR_E_C_D_E_L_], "
	_cFixIn += "R_E_C_D_E_L_,"
	_cFixVl += "MR_E_C_D_E_L_,"
	_cAltBD := " If Exists(SELECT 1 FROM syscolumns WHERE id = object_id('[" + AllTrim(_cServOri) + "].[dbo]." + RetSqlName(_cAlias) + "') AND name = 'R_E_C_D_E_L_')
	_cAltBD += " ALTER TABLE " + AllTrim(_cServDes) + ".dbo." + RetSqlName(_cAlias) + " ADD R_E_C_D_E_L_ INT " + " NOT NULL CONSTRAINT R_E_C_D_E_L__RF DEFAULT " + '0'
	If !Empty(_cAltBD)
		TCSQLExec(_cAltBD)
	EndIf
EndIf
_cCkCpo := "SELECT " + _cTabela + ".D_E_L_E_T_ AS [MD_E_L_E_T_]  FROM [" + AllTrim(_cServOri) + "].[dbo].[" + _cTabela + "]"
If TCSQLExec(_cCkCpo) >= 0
	_cFixos += _cTabela + ".D_E_L_E_T_ AS [MD_E_L_E_T_], "
	_cFixIn += "D_E_L_E_T_,"
	_cFixVl += "MD_E_L_E_T_,"
	_cAltBD := " If Exists(SELECT 1 FROM syscolumns WHERE id = object_id('[" + AllTrim(_cServOri) + "].[dbo]." + RetSqlName(_cAlias) + "') AND name = 'D_E_L_E_T_')
	_cAltBD += " ALTER TABLE " + AllTrim(_cServDes) + ".dbo." + RetSqlName(_cAlias) + " ADD D_E_L_E_T_ VARCHAR(1) " + " NOT NULL CONSTRAINT D_E_L_E_T__RF DEFAULT " + ''
	If !Empty(_cAltBD)
		TCSQLExec(_cAltBD)
	EndIf
EndIf
If !Empty(_cAlias)
	//Cria็ใo da tabela/estrutura porventura inexistente na base de dados de destino
	_cAltBD   := "SELECT * INTO " + AllTrim(_cServDes) + ".dbo." + RetSqlName(_cAlias) + " FROM " + AllTrim(_cServOri) + ".dbo." + RetSqlName(_cAlias) + " WHERE 1=0"
	_lAtuStru := TCSQLExec(_cAltBD) >= 0
	//Populo as variแveis com informa็๕es dos campos de acordo com a SX3 (Dicionแrio de dados)
	dbSelectArea("SX3")
	SX3->(dbSetOrder(1))
	If SX3->(dbSeek(_cAlias))
		While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO == _cAlias 
			If AllTrim(Upper(SX3->X3_CONTEXT))<>"V" .And. AllTrim(Upper(SX3->X3_TIPO))<>"M"//Filtro campos virtuais
				//Cria็ใo dos campos porventura nใo existentes na base de destino
				If !_lAtuStru
					_cAltBD := ""
					_cAltBD := " If Exists(SELECT 1 FROM syscolumns WHERE id = object_id('[" + AllTrim(_cServOri) + "].[dbo]." + RetSqlName(_cAlias) + "') AND name = '" + AllTrim(SX3->X3_CAMPO) + "')
					If SX3->X3_TIPO == "N"
						_cAltBD += " ALTER TABLE " + AllTrim(_cServDes) + ".dbo." + RetSqlName(SX3->X3_ARQUIVO) + " ADD " + AllTrim(SX3->X3_CAMPO) + " FLOAT "                                        + " NOT NULL CONSTRAINT " + AllTrim(SX3->X3_ARQUIVO) + "_" + AllTrim(SX3->X3_CAMPO) + "_RF DEFAULT " + '0'							//cValToChar(CriaVar(SX3->X3_CAMPO))
					ElseIf SX3->X3_TIPO == "C"
						_cAltBD += " ALTER TABLE " + AllTrim(_cServDes) + ".dbo." + RetSqlName(SX3->X3_ARQUIVO) + " ADD " + AllTrim(SX3->X3_CAMPO) + " VARCHAR(" + cValToChar(SX3->X3_TAMANHO) + ") " + " NOT NULL CONSTRAINT " + AllTrim(SX3->X3_ARQUIVO) + "_" + AllTrim(SX3->X3_CAMPO) + "_RF DEFAULT " + Space(SX3->X3_TAMANHO)		//CriaVar(SX3->X3_CAMPO)
					ElseIf SX3->X3_TIPO == "D"
						_cAltBD += " ALTER TABLE " + AllTrim(_cServDes) + ".dbo." + RetSqlName(SX3->X3_ARQUIVO) + " ADD " + AllTrim(SX3->X3_CAMPO) + " VARCHAR(" + cValToChar(SX3->X3_TAMANHO) + ") " + " NOT NULL CONSTRAINT " + AllTrim(SX3->X3_ARQUIVO) + "_" + AllTrim(SX3->X3_CAMPO) + "_RF DEFAULT " + Space(SX3->X3_TAMANHO)
					ElseIf SX3->X3_TIPO == "M"
						_cAltBD += " ALTER TABLE " + AllTrim(_cServDes) + ".dbo." + RetSqlName(SX3->X3_ARQUIVO) + " ADD " + AllTrim(SX3->X3_CAMPO) + " IMAGE " + ") "                                 + " NOT NULL CONSTRAINT " + AllTrim(SX3->X3_ARQUIVO) + "_" + AllTrim(SX3->X3_CAMPO) + "_RF DEFAULT " + ''							//CriaVar(SX3->X3_CAMPO)
					Else
						_cAltBD := ""
					EndIf
					If !Empty(_cAltBD)
						TCSQLExec(_cAltBD)
					EndIf
				EndIf
				_cCampo := IIf(Empty(_cCampo),AllTrim(SX3->X3_CAMPO) + " AS [M" + AllTrim(SX3->X3_CAMPO) + "] ",_cCampo + ", " + AllTrim(SX3->X3_CAMPO) + " AS [M" + AllTrim(SX3->X3_CAMPO) + "] ")
				_cUpdat := IIf(Empty(_cUpdat),AllTrim(SX3->X3_CAMPO) + "=M" + AllTrim(SX3->X3_CAMPO),_cUpdat + ", " + AllTrim(SX3->X3_CAMPO) + "=M" + AllTrim(SX3->X3_CAMPO))
				_cOrige := IIf(Empty(_cOrige),AllTrim(SX3->X3_CAMPO),_cOrige + ", " +AllTrim(SX3->X3_CAMPO))
				_cDesti := IIf(Empty(_cDesti),"M" + AllTrim(SX3->X3_CAMPO),_cDesti + ", M" + AllTrim(SX3->X3_CAMPO))
			EndIf
			dbSelectArea("SX3")
			SX3->(dbSetOrder(1))
			SX3->(dbSkip())
		EndDo
	EndIf
	
	If Empty(_cFixos)
	
		_cQryTeste := "SELECT COUNT(*) CONTEM FROM " + AllTrim(_cServOri) + ".INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='" + AllTrim(_cTabela) + "' AND COLUMN_NAME='R_E_C_D_E_L_'"
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQryTeste),"TABREC",.F.,.T.)
		
		dbSelectArea("TABREC")
		
		If TABREC->CONTEM>0 //Avalio se a tabela possui o campo R_E_C_D_E_L_
			_cFixos += "R_E_C_N_O_ AS [MR_E_C_N_O_], D_E_L_E_T_ AS [MD_E_L_E_T_], R_E_C_D_E_L_ AS [MR_E_C_D_E_L_],"
			_cUpdat += ", R_E_C_D_E_L_=MR_E_C_D_E_L_"
			_lRecDel:= .T.
		Else
			_cFixos += "R_E_C_N_O_ AS [MR_E_C_N_O_], D_E_L_E_T_ AS [MD_E_L_E_T_],"
		EndIf
		
		dbSelectArea("TABREC")
		dbCloseArea()
		
	EndIf
	
	_cMerge := "MERGE [" + _cServDes + "].[dbo].[" + _cTabela + "] AS DEST "
	_cMerge += "USING (SELECT " + _cFixos + _cCampo + " FROM [" + _cServOri + "].[dbo].[" + _cTabela + "] " + _cFiltro + " ) AS ORIG "
	_cMerge += "ON (DEST.R_E_C_N_O_)=(ORIG.MR_E_C_N_O_) "
	_cMerge += "WHEN MATCHED THEN "

	If Empty(_cUpdate)
		_cMerge += "	UPDATE SET " + _cUpdat + " "
	Else
		//Inํcio - Trecho adicionado por Adriano Leonardo em 13/06/2014 para melhoria na rotina, preven็ใo de chave duplicada
		//Certifico a tabela possui R_E_C_D_E_L_ e que este serแ atualizado no update para impedir chave duplicada
		If _lRecDel .And. !("R_E_C_D_E_L_" $ _cUpdate)
			_cUpdate := StrTran(_cUpdate, "SET ","SET R_E_C_D_E_L_=MR_E_C_D_E_L_, ")
		EndIf
		
		//Certifico a tabela possui D_E_L_E_T_ e que este serแ atualizado no update para impedir chave duplicada
		If !("D_E_L_E_T_" $ _cUpdate)
			_cUpdate := StrTran(_cUpdate, "SET ","SET D_E_L_E_T_=MD_E_L_E_T_, ")
		EndIf
		//Final  - Trecho adicionado por Adriano Leonardo em 13/06/2014 para melhoria na rotina, preven็ใo de chave duplicada
		_cMerge += " " + _cUpdate + " "
	EndIf
	
	_cMerge += "WHEN NOT MATCHED THEN "
	
	If Empty(_cFixIn)
		
		_cQryTeste := "SELECT COUNT(*) CONTEM FROM " + AllTrim(_cServOri) + ".INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='" + AllTrim(_cTabela) + "' AND COLUMN_NAME='R_E_C_D_E_L_'"
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQryTeste),"TABREC",.F.,.T.)
		
		dbSelectArea("TABREC")
		
		If TABREC->CONTEM>0 //Avalio se a tabela possui o campo R_E_C_D_E_L_
			_cFixIn += "R_E_C_N_O_, D_E_L_E_T_, R_E_C_D_E_L_, "
			_cFixVl += "MR_E_C_N_O_, MD_E_L_E_T_, MR_E_C_D_E_L_, "
		Else
			_cFixIn += "R_E_C_N_O_, D_E_L_E_T_, "
			_cFixVl += "MR_E_C_N_O_, MD_E_L_E_T_, "
		EndIf
		
		dbSelectArea("TABREC")
		dbCloseArea()
	EndIf
	
	If Empty(_cInsert)
		_cMerge += "	INSERT ( " + _cFixIn + _cOrige + ") VALUES ( " + _cFixVl + _cDesti + ") "
	Else
		_cMerge += " " + _cInsert + " "
	EndIf
	_cMerge += "; " //Aten็ใo - O merge precisa do ; para funcionar, este ้ usado como delimitador da fun็ใo merge

	MsgRun("Aguarde, atualizando a " + _cTabela + "!","[" + _cRotina + "] MERGE",{|| IIF(TcSqlExec(_cMerge)<0,MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_003"),NIL)})
	If !Empty(_cInstPos)

		// Inํcio - Trecho adicionado por Adriano Leonardo em 12/11/2013 para melhoria na rotina
		_aAuxInst := StrTokArr(_cInstPos,";")
		
		For _nCont := 1 To Len(_aAuxInst)
			MsgRun("Aguarde, atualizando a " + _cTabela + "!","[" + _cRotina + "] MERGE - Instr. Posterior " + AllTrim(Str(_nCont)),{|| IIF(TcSqlExec(_aAuxInst[_nCont])<0,MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_004"),NIL)})
		Next
		
		// Fim    - Trecho adicionado por Adriano Leonardo em 12/11/2013 para melhoria na rotina
		
		//MsgRun("Aguarde, atualizando a " + _cTabela + "!","[" + _cRotina + "] MERGE - Instr. Posterior",{|| IIF(TcSqlExec(_cInstPos)<0,MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_004"),NIL)}) //Linha comentada por Adriano Leonardo em 12/11/2013 para melhoria na rotina
	EndIf
Else
	MsgAlert("Tabela nใo selecionada!",_cRotina+"_001")
EndIf

RestArea(_aSavArea)

Return()