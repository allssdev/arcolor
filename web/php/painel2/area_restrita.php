<?php

session_start();
include "includes/config.php";
protegePagina();
include "includes/functions.php";


session_checker();

if($_SESSION['nivel_usuario'] == 1){

$redirecina = "painel_user.php";
header("Location: $redirecina");

}

if($_SESSION['nivel_usuario'] == 0){
$redir = "painel_tec.php";
header("Location: $redir");

}

if($_SESSION['nivel_usuario'] == 2){
$redire = "painel.php";
header("Location: $redire");

}

echo "<a href=\"logout.php\">Sair</a>";

?>