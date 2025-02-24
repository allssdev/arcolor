<?php
require "../includes/config.php";
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Cadastro de Pessoal Jurídica</title>
</head>

<body>
<form action="../clientes/cadastra_juridico.php" method="post">  
<table width="519" border="0">
  <tr>
    <td width="133">Nome:</td>
    <td width="370"><input type="text" name="ds_cliente" size="58" /></td>
  </tr>
  <tr>
    <td>Razão Social:</td>
    <td><input type="text" name="ds_razao" size="58" /></td>
  </tr>
  <tr>
    <td>CNPJ/CPF</td>
    <td><input name="nr_cnpjcpf" type="text" size="27" /></td>
  </tr>
  <tr>
    <td>Nome para Contato:</td>
    <td><input type="text" name="ds_contato" /></td>
  </tr>
  <tr>
    <td>Telefone:</td>
    <td><input type="text" size="2" maxlength="2" name="nr_ddd" /><input type="text" size="15" maxlength="15" name="nr_telefone" /></td>
  </tr>
  <tr>
    <td>Email:</td>
    <td><input type="text" name="email" maxlength="50" size="27" /></td>
  </tr>
  <tr>
    <td>Endereço:</td>
    <td><input type="text" name="ds_endereco" size="50" maxlength="50" />
</td>
  </tr>
  <tr>
    <td>Complemento:</td>
    <td><input type="text" name="ds_complemento" size="40" maxlength="50" /></td>
  </tr>
  <tr>
    <td>Bairro:</td>
    <td><input type="text" name="ds_bairro" size="30" maxlength="50" /></td>
  </tr>
  <tr>
    <td>Cidade:</td>
    <td><input type="text" name="ds_cidade" size="40" maxlength="50" /></td>
  </tr>
  <tr>
    <td>Estado:</td>
    <td><?php GeraEstados('ds_estado'); ?></td>
  </tr>
  <tr>
    <td>Cep:</td>
    <td><input name="nr_cep" type="text" maxlength="9" />
      (00000-000) </td>
  </tr>
    <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
   <tr>
    <td><input type="submit" value="Enviar" /><input type="reset" value="Limpar" /></td>
  </tr>

</table>
</form>

</body>
</html>