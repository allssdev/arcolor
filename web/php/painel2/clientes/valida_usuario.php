<?php //inicia o script PHP
 
//configuração de banco - ABAIXO -
$host = "localhost"; //host
$user = "root"; //usuário do bd
$pass = ""; //senha do bd
$banco = "painel2"; //nome do banco de dados
 
$conexao = mysql_connect($host, $user, $pass) or die ("falha ao conectar no servidor de banco de dados"); //or die - serve para se nao conectar ao bd ele manda a mensagem de erro

mysql_select_db($banco, $conexao); //query de seleção de banco de dados

$nome = $_POST['nome'];
$sobrenome = $_POST['sobrenome'];
$usuario = $_POST['usuario'];
$email = $_POST['email'];
$senha = $_POST['senha'];
$ativado = "1";
$info = $_POST['info'];

$codificado = md5($senha);


 	
$query = "INSERT INTO usuarios (nome,sobrenome,usuario,email,senha,ativado,info) VALUES ('".$nome."', '".$sobrenome."', '".$usuario."', '".$email."', '".$codificado."', '".$ativado."', '".$info."')"; //insere na tabela usuarios os valores 'nome usuario senha e classe'

if(mysql_query($query, $conexao)) //ve se da falha ao cadastrar os login
{
	echo "Cadastro efetuado com sucesso"; //aparece se cadastro direito
}
else
{
	echo "Falha ao efetuar cadastro"; //aparece se deu M
}
 
?> 
<p>Voc&ecirc; ser&aacute; redirecionado para o Login...</p><META HTTP-EQUIV="REFRESH" CONTENT="2; URL=../formulario_login.html">
