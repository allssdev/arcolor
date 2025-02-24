<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Formul�rio Cadastro</title>
<style type="text/css">
<!--
.form2{
	width:500px;
	margin-left:50px;
	margin-top:50px;
	border:solid #000 2px;
	background-color:#FFF;
	
}
-->
</style></head>

<body>
<div class="form2">
<form action="../clientes/valida_usuario.php" method="post">
<table width="300" border="0" align="center">
  <tr>
    <td>Nome:</td>
    <td><input type="text" name="nome" /></td>
  </tr>
   <tr>
    <td>Sobrenome:</td>
    <td><input type="text" name="sobrenome" /></td>
  </tr>
  <tr>
    <td>Usu&aacute;rio:</td>
    <td><input type="text" name="usuario" /></td>
  </tr>
  <tr>
    <td>Email:</td>
    <td><input type="text" name="email" /></td>
  </tr>
  <tr>
    <td>Senha:</td>
    <td><input type="password" name="senha" /></td>
  </tr>
   <tr>
     <tr>
    <td>Informa&ccedil;&otilde;es:</td>
    <td><textarea name="info" rows="5" cols="25"></textarea></td>
  </tr>
  <tr>
    <td><input type="submit" value="Cadastar" /></td>
  </tr>
</table>
</form>
</div>
</body>
</html>
