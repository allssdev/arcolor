<?php
include "../includes/config.php";
$id=$_GET['apagar'];

mysql_query("DELETE FROM usuarios WHERE usuario_id=$id");
mysql_close();
?>
<?php
$lax = "../cadastros/cad_usuarios.php";
header("Location: $lax");
?>