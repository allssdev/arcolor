<HTML>
<HEAD>
 <TITLE>Ficha de Clientes</TITLE>
</HEAD>
<?php
 $res1 = mysql_connect("localhost", "root", "");
 $sql = "SELECT * FROM cad_cliente WHERE tp_cliente = 'f'";
 $res2 = mysql_db_query("painel2", "$sql", $res1);
 $valor = mysql_fetch_array($res2);
 if ($valor["cd_cliente"] > 0) {
?>
<CENTER><FONT face="arial" SIZE="4" COLOR="blue"><B>Ficha Cadastral de Clientes</B></FONT></CENTER><BR><BR><BR>
 
<center><FONT face="arial" SIZE="3" COLOR="blue"><B>Dados Pesssoais</B></FONT></center>
 
<center>
  <table border="5" width="60%" >
 
<tr>
<td><FONT face="arial" SIZE="2" COLOR="blue"> Nome:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" size="20" name="nome" value="<?=$valor["ds_cliente"];?>"></font></td>
  
</tr>
</table><BR>
 </center>
 
 <?
  } else {
    echo "Produto não encontrado";
}
mysql_close($res1);
?>
 
