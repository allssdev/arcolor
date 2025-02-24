<?php
	require_once 'config.php';
	
	if(isset($_REQUEST['get_all_revendas'])){
		$sql = "SELECT TOP 50 A3_COD,A3_NOME,A3_NREDUZ FROM SA3020 WHERE A3_COD LIKE '%00' ORDER BY A3_NREDUZ ASC";
		$result = odbc_exec($connect , $sql);
		
		$dados = array();
		while (odbc_fetch_row($result)) {
			array_push($dados,array('COD_PROTHEUS'=>trim(odbc_result($result, "A3_COD")),'NOME'=>trim(odbc_result($result, "A3_NOME")),'NOME_ABR'=>trim(odbc_result($result, "A3_NREDUZ"))));
		}	
		
		echo json_encode($dados);
	}
	
	if(isset($_REQUEST['get_ws_revendas'])){
		$wsdl    = $Url_WebService."WS_CRM_REVENDAS.apw?WSDL";
		$client  = new SoapClient($wsdl,array("cache_wsdl"=>WSDL_CACHE_NONE));           
		$aParams = array("REVENDA"=>'DBR00');
		$result = $client->ListRevendas($aParams);
						
		$revendas = (array) $result->LISTREVENDASRESULT->CRMREVENDAS;
	
		$dados = array();
		foreach($revendas as $d => $dd){
			$dados[] = array(
				'COD_PROTHEUS'=>trim($dd->A3_COD),
				'NOME'=>trim($dd->A3_NOME),
				'NOME_ABR'=> trim($dd->A3_NREDUZ)
			);
		}
		
		echo json_encode($dados);
	}
	
	if(isset($_REQUEST['get_ws_concorrentes'])){
		$wsdl    = $Url_WebService."WS_CRM_CONCORRENTES.apw?WSDL";
		$client  = new SoapClient($wsdl,array("cache_wsdl"=>WSDL_CACHE_NONE));           
		$aParams = array("CONCORRENTE"=>'DBR00');
		$result = $client->ListConcorrentes($aParams);
						
				
		$concorrentes = (array) $result->LISTCONCORRENTESRESULT->CRMCONCORRENTES;
		
	
		$dados = array();
		if(false)
		foreach($concorrentes as $d => $dd){
			$dados[] = array(
				'COD_PROTHEUS'=>trim($dd->A3_COD),
				'NOME'=>trim($dd->A3_NOME),
				'NOME_ABR'=> trim($dd->A3_NREDUZ)
			);
		}
		
		echo json_encode($concorrentes);
	}
	
	
	
