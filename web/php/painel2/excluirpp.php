<?php

$conexao = mysql_connect("localhost","root","");
$db = mysql_select_db("painel2");
$id = $_GET['id'];
$sql = mysql_query("DELETE FROM cad_cliente WHERE cd_cliente='$id'");
$resultado = mysql_query($sql);
echo "Excluido com Sucesso!!!";


?>
