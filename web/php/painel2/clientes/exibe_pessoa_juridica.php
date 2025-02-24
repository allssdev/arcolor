<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <title>Consulta Pessoas F&iacute;sicas</title>
  <style type="text/css">
 .tabela{
	 width:900px; 
 	 height:auto;
	 padding:2px;
	 border:1px #000;
 }

  </style>
</head>
 
<?php
 $res1 = mysql_connect("localhost", "root", "");
 $sql = ("SELECT cd_cliente,ds_cliente,nr_cnpjcpf,ds_razao,ds_contato,nr_ddd,nr_telefone,email,ds_endereco,ds_complemento,ds_bairro,ds_cidade,ds_estado,nr_cep FROM cad_cliente WHERE tp_cliente= 'j'");
 @$res2 = mysql_db_query("painel2", "$sql", $res1);
?>
 
<body>


<table width="900px" class="tabela">
 
<tr bgcolor="#fff">
<td ><font color="#000">Cliente:</font></td>
<td ><font color="#000">CNPJ:</font></td>
<td ><font color="#000">Raz&atilde;o:</font></td>
<td ><font color="#000">Nome:</font></td>
<td ><font color="#000">Telefone:</font></td>
<td ><font color="#000">Email:</font></td>
<td ><font color="#000">Endere&ccedil;o:</font></td>
<td ><font color="#000">Complemento:</font></td>
<td ><font color="#000">Bairro:</font></td>
<td ><font color="#000">Cidade:</font></td>
<td ><font color="#000">Estado:</font></td>
<td ><font color="#000">Cep:</font></td>
<td ><font color="#000">Apagar:</font></td>
</tr>
 
<?php

while($valor = mysql_fetch_array($res2)) { 
$id = $valor["cd_cliente"];
?>
 	<tr bgcolor="#fff">
 <td><font color="#000"><?=$valor["ds_cliente"]?></font></td>
 <td><font color="#000"><?=$valor["nr_cnpjcpf"]?></font></td>
  <td><font color="#000"><?=$valor["ds_razao"]?></font></td>
   <td><font color="#000"><?=$valor["ds_contato"]?></font></td>
    <td><font color="#000"><?=$valor["nr_ddd"]?> <?=$valor["nr_telefone"]?></font></td>
     <td><font color="#000"><?=$valor["email"]?></font></td>
      <td><font color="#000"><?=$valor["ds_endereco"]?></font></td>
       <td><font color="#000"><?=$valor["ds_complemento"]?></font></td>
        <td><font color="#000"><?=$valor["ds_bairro"]?></font></td>
         <td><font color="#000"><?=$valor["ds_cidade"]?></font></td>
          <td><font color="#000"><?=$valor["ds_estado"]?></font></td>
           <td><font color="#000"><?=$valor["nr_cep"]?></font></td>
 			<td><?php echo "<a href=\"excluirpp.php?id=$id\"> Excluir </a>"; ?></td>
  		</tr>
 <?php
 }
mysql_close($res1);
?>
 </table>
 
 </body>
 </html>