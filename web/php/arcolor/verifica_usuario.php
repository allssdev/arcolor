<?php
 
session_start();
 
if ($_SERVER['REQUEST_METHOD'] == 'POST' && count($_POST) > 0) {
 
	$url  = 'http://http://192.168.1.212:8084/rest/AUTHVEND?USR=' . $_POST['usuario'] . '&PWD=' . $_POST['senha'];
 
	$result = file_get_contents($url);
	$json = json_decode($result, true);
 
	$_SESSION['nome'] = $json['ADADOS'][3];
	$_SESSION['codigo'] = $json['ADADOS'][0];
	$_SESSION['codvend'] = $json['ADADOS'][26];
 
	header('Location: ' . SUBFOLDER . '/');
	exit;
 
}
 
?>