<?php 

session_start();

include "../includes/functions.php";
include("../includes/config.php");
protegePagina();
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Painel de Controle</title>
<link rel="stylesheet" type="text/css" href="../styles/styler.css" />
<script language="javascript" src="../scripts/ajax.js"></script>
<script language="javascript" src="../scripts/instrucao.js"></script>
</head>

<body>
<div class="tudosite">
<div class="topo"><font color="#000"><?php echo "Bem vindo <strong>". $_SESSION['nome'] ."</strong>  "?></font>
  - A Data de Hoje &eacute;:  <?php
$dataAtual = date("d/m/Y");
echo $dataAtual;
?><p align="right" class="dir">Fazer <a href="../logout.php">Logout</a></p>
</div><br />
<br />
<div class="menu">
<div id="menu5">
  <ul>
	<li><h3><b>Cadastrar</b></h3></li>
    <li><a href="#" onclick="abrirPag('../clientes/cadastro_fisico.php');">Pessoa F&iacute;sica</a></li>
    <li><a href="#" onclick="abrirPag('../clientes/cadastro_juridico.php');">Pessoa Jur&iacute;dica</a></li>
    <li><a href="#" onclick="abrirPag('cadastra_usuarios.php')";>Cadastrar Usu&aacute;rio</a></li>
	<li><a href="../painel.php">Voltar ao Painel</a></li>
  </ul>
</div>
</div>


<div class="meio" id="conteudo_mostrar"></div>


<div class="rodape"><p align="center">Programado e Desenhado por Pedro Laxe</p></div>
</div>
</body>
</html>