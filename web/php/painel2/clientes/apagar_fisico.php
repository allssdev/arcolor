<?php

mysql_connect("localhost","root","") or die("erro ao conectar");
mysql_select_db("painel2") or die ("erro na tabela");

if(isset($_POST['ds_cliente'])){
   $ds = $_POST['ds_cliente'];
   $sql = "DELETE FROM cad_cliente WHERE ds_cliente ='$ds'";
   mysql_query($sql);
}

?>

<form action="" method="post">
<select name="ds_cliente">
<?php
$sql2 = "SELECT * FROM cad_cliente WHERE tp_cliente='f'";
$query = mysql_query($sql2);

while($linha = mysql_fetch_assoc($query)){
$ds = $linha['ds_cliente'];
echo "<option value='$linha[ds_cliente]'>$ds</option>";
}
?>
</select>
<input type="submit" value="Apagar">
</form>