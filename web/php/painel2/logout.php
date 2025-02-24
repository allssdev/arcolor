<?php

session_start();

if(!isset($_REQUEST['logmeout'])){

	echo "Voc&ecirc; deseja sair do Painel?<br />";
	echo "<a href=\"logout.php?logmeout\">Sim</a> | <a href=\"javascript:history.go(-1)\">N&atilde;o</a>";

}
else{

	session_destroy();

	session_unset(); //limpamos as variaveis globais das sessões


		$redirt = "formulario_login.html";
         	header("Location: $redirt");
	}

?>
