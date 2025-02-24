
<html>
 
<head>
  <title>Consulta Pessoas F&iacute;sicas</title>
</head>
 
<?php
 $res1 = mysql_connect("localhost", "root", "");
 $sql = ("SELECT cd_cliente,ds_cliente,nr_cnpjcpf,nr_ident,ds_contato,nr_ddd,nr_telefone,email,ds_endereco,ds_complemento,ds_bairro,ds_cidade,ds_estado,nr_cep FROM cad_cliente WHERE tp_cliente= 'f'");
 @$res2 = mysql_db_query("painel2", "$sql", $res1);
?>
 
<body>
<center>
<table>
 
<tr>

<td></td>
</tr>
 </table>
   </center>
   <center>
<table border=0 width=928px>
 
<tr bgcolor="#0099cc">
<th width="10"><center><font color="#FFFFFF">C&oacute;digo:</font></center></th>
<th ><font color="#FFFFFF">Nome do Cliente:</font></th>
<th ><font color="#FFFFFF">CPF:</font></th>
<th ><font color="#FFFFFF">Identidade:</font></th>
<th ><font color="#FFFFFF">Nome de Contato:</font></th>
<th ><font color="#FFFFFF">DDD + Telefone:</font></th>
<th ><font color="#FFFFFF">email:</font></th>
<th ><font color="#FFFFFF">Endere&ccedil;o:</font></th>
<th ><font color="#FFFFFF">Complemento:</font></th>
<th ><font color="#FFFFFF">Bairro:</font></th>
<th ><font color="#FFFFFF">Cidade:</font></th>
<th ><font color="#FFFFFF">Estado:</font></th>
<th ><font color="#FFFFFF">Cep:</font></th>
<th ><font color="#FFFFFF">Apagar:</font></th>
</tr>
 
<?php

while($valor = mysql_fetch_array($res2)) { 
$id = $valor["cd_cliente"];
?>
 <tr>
 <td ><font color="#0000FF" face="verdana" size="2"><?=$valor["cd_cliente"]?></font></td>
 <td><font color="#0000FF" face="verdana" size="2"><?=$valor["ds_cliente"]?></font></td>
 <td><font color="#0000FF" face="verdana" size="2"><?=$valor["nr_cnpjcpf"]?></font></td>
  <td><font color="#0000FF" face="verdana" size="2"><?=$valor["nr_ident"]?></font></td>
   <td><font color="#0000FF" face="verdana" size="2"><?=$valor["ds_contato"]?></font></td>
    <td><font color="#0000FF" face="verdana" size="2"><?=$valor["nr_ddd"]?> <?=$valor["nr_telefone"]?></font></td>
     <td><font color="#0000FF" face="verdana" size="2"><?=$valor["email"]?></font></td>
      <td><font color="#0000FF" face="verdana" size="2"><?=$valor["ds_endereco"]?></font></td>
       <td><font color="#0000FF" face="verdana" size="2"><?=$valor["ds_complemento"]?></font></td>
        <td><font color="#0000FF" face="verdana" size="2"><?=$valor["ds_bairro"]?></font></td>
         <td><font color="#0000FF" face="verdana" size="2"><?=$valor["ds_cidade"]?></font></td>
          <td><font color="#0000FF" face="verdana" size="2"><?=$valor["ds_estado"]?></font></td>
           <td><font color="#0000FF" face="verdana" size="2"><?=$valor["nr_cep"]?></font></td>
 <td><?php echo "<a href=\"excluirpp.php?id=$id\"> Excluir </a>"; ?></td>
   </tr>
 <?php
 }
mysql_close($res1);
?>
 
 </table> <br>
 
</tr>
 </table>
 </center>
 </body>
 </html>