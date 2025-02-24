<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Ver Usuários</title>
<style type="text/css">
.exibeusuarios{
	background-color:#fff;
	width:500px;
	height:auto;
	margin-left:320px;
}
</style>
</head>
<?php
 $res1 = mysql_connect("localhost", "root", "");
 $sql = ("SELECT usuario,senha,usuario_id FROM usuarios ");
 @$res2 = mysql_db_query("painel2", "$sql", $res1);
?>
 
<body>
<h1 align="center">Ver Usuários</h1>
<div class="exibeusuarios" align="center">
<table>
 
<tr>

 
<td></td>
</tr>
 </table>
   </center>
   <center>
<table border=0 width=30%>
 
<tr bgcolor="#0099cc">
<th width="10"><center><font color="#FFFFFF">Usuário</font></center></th>
<th ><center><font color="#FFFFFF">Senha:</font></center></th>
<th ><center><font color="#FFFFFF">Apagar:</font></center></th>
</tr>
 
<?php

while($valor = mysql_fetch_array($res2)) { 
$id = $valor["usuario_id"];
?>
 <tr>
 <td ><font color="#0000FF" face="verdana" size="2"><?=$valor["usuario"]?></font></td>
 <td><font color="#0000FF" face="verdana" size="2"><?=$valor["senha"]?></font></td>
 <td><?php echo "<a href=\"../usuarios/delete.php?id=$id\">Excluir</a>"; ?></td>
   </tr>
 <?php
 }
mysql_close($res1);
?>
 
 </table> <br>
 
</tr>
 </table>
</div>

</body>
</html>