<?php

session_start();

include "functions.php";
include("config.php");
protegePagina();
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Painel de Controle</title>
<script language="javascript" src="scripts/ajax.js"></script>
<script language="javascript" src="scripts/instrucao.js"></script>
<link rel="stylesheet" href="styles/styleuser.css" type="text/css" />
</head>

<body>
<div class="topo">
<font color="#000"><?php echo "Bem vindo <strong>". $_SESSION['nome'] ."</strong>! "?></font>
  - A Data de Hoje é:  <?php
$dataAtual = date("d/m/Y");
echo $dataAtual;
?>
<p align="right" class="dir">Fazer <a href="logout.php">Logout</a></p>
</div>
<div id="geral">
<!--inicio dos cadastros-->
<div id="engloba">
<div class="vercont">
<h1>Ver Cadastros</h1><br />
<table width="200" border="0">
  <tr>
    <td>Pessoa Física:</td>
    <td><input type="button" value="Veja" onclick="abrirPag('forms/exibefis.php');" /></td>
  </tr>
  <tr>
    <td>Pessoa Jurídica:</td>
    <td><input type="button" value="Veja" onclick="abrirPag('forms/exibejur.php');" /></td>
  </tr>
</table>
</div>
<div class="noticias">
<h1>Notícias</h1>
<table width="205" border="0">
  <tr>
    <td>Ver Notícias:</td>
    <td><input type="button" value="Veja" onclick="#" /></td>
  </tr>
</table>
</div>
</div>
<div class="exibirpage" id="conteudo_mostrar">
</div>
</div>

<!-- Inicio do footer -->
<div class="footer">
<p align="center"><font color="#FFFFFF">Painel de Controle - Feito e Desenhado por: Pedro Laxe</font></p>
</div>
<!-- Fim do footer -->
</body>
</html>