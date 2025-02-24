<?php

$conexao = mysql_connect("localhost","root","");
$db = mysql_select_db("painel2");
$id = $_GET['id'];
$sql = mysql_query("DELETE FROM usuarios WHERE usuario_id='$id'");
$resultado = mysql_query($sql);
echo "Excluido Com Sucesso!";


?>
<META HTTP-EQUIV="REFRESH" CONTENT="2; URL=javascript:history.back();">