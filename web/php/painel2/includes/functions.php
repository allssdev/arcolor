<?php

function session_checker(){

	if(!isset($_SESSION['usuario_id'])){

		header ("Location:formulario_login.html");

		exit(); 
	}
}

function verifica_email($EMAIL){

    list($User, $Domain) = explode("@", $EMAIL);
    $result = @checkdnsrr($Domain, 'MX');

    return($result);

}


?>