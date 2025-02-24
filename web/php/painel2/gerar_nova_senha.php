<?php

include "includes/config.php";

@$recupera = $_POST['recupera'];
@$email = $_POST['email'];

switch($recupera){

	case "recupera":
		recupera_senha($email);
		break;

	default:
		include "formulario_senha_perdida.html";
		break;
}

function recupera_senha($email){

	if(!isset($email)){

        echo "Você esqueceu de preencher seu email.<br />
			<strong>Use o mesmo email que utilizou em seu cadastro.</strong><br /><br />"; 

		include "formulario_senha_perdida.html";

		exit();

	}

	// Checando se o email informado está cadastrado
		
	$sql_check = mysql_query("SELECT * FROM usuarios WHERE email='{$email}'");
	$sql_check_num = mysql_num_rows($sql_check);

	if($sql_check_num == 0){

		echo "<script>alert('Este email não está cadastrado em nosso banco de dados.');</script>";

		include "formulario_senha_perdida.html";

		exit();

	}
	
	// Se tudo OK vamos gerar uma nova senha e enviar para o email do usuário!

	function makeRandomPassword(){

		$salt = "abchefghjkmnpqrstuvwxyz0123456789";
		srand((double)microtime()*1000000);

		$i = 0;

		while ($i <= 7){

			$num = rand() % 33;
			$tmp = substr($salt, $num, 1);
			@$pass = $pass . $tmp;
			$i++;

		}

		return $pass;

	}

	$senha_randomica = makeRandomPassword();

	$senha = md5($senha_randomica);

	$sql = mysql_query("UPDATE usuarios SET senha='{$senha}' WHERE email ='{$email}'");

	/*$headers = "MIME-Version: 1.0\n";
	$headers .= "Content-type: text/html; charset=iso-8859-1\n";
	$headers .= "From: Teu Domínio - Webmaster<teuemail@domíniodoteuemail.com>"; //COLOQUE TEU EMAIL

	$subject = "Sua nova senha em teusite.com";
	$message = "Olá, redefinimos sua senha.<br /><br />

	<strong>Nova Senha</strong>: {$senha_randomica}<br /><br />

	<a href='http://www.teusite.com/formulario_login.html'>http://www.teusite.com/formulario_login.html</a><br /><br />

	Obrigado!<br /><br />

	Webmaster<br /><br /><br />


	Esta é uma mensagem automática, por favor não responda!";

	mail($email, $subject, $message, $headers);
*/
	echo "Sua nova senha foi gerada com sucesso!<br />Sua Senha é:<br /><br />";

	echo $senha_randomica;
	
	echo "<br />";
	
	echo '<br /><br /><a href="index.php">Voltar ao Login</a>';
	//include "formulario_login.html";

}

?>