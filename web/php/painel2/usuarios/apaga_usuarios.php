<?php

mysql_connect("localhost","root","") or die("erro ao conectar");
mysql_select_db("painel2") or die ("erro na tabela");

@$usuario = $_POST['usuario'];
$sql = "DELETE FROM usuarios WHERE usuario ='$usuario' ";

?>

<form action="" method="post">
<select>
<?php
$sql2 = "SELECT * FROM usuarios";
$query = mysql_query($sql2);

while($linha = mysql_fetch_assoc($query)){
$usuario = $linha['usuario'];
echo "<option>$usuario</option>";
}
?>
</select>
<input type="submit" value="Apagar">
</form>