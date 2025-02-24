<?php
session_start();

if(!isset($_SESSION['usuario'])){
	session_unset();
}

if($_SESSION['usuario'] == "samuel.almeida" && false){
	session_unset();
		include 'manutencao.html';
		
		}else{
	header('Location:public/');
}
