<?php

session_start();  // Inicia a session

include "includes/config.php";

@$usuario = $_POST['usuario'];
@$senha = $_POST['senha'];

$senhacrip = md5($senha);

if((!$usuario) || (!$senha)){

	echo "<script>alert('Por favor, todos campos devem ser preenchidos!');</script> <br /><br />";
	include "formulario_login.html";

}
else{

	$senhacrip = md5($senha);

	$sql = mysql_query("SELECT * FROM usuarios WHERE usuario='{$usuario}' AND senha='{$senhacrip}' AND ativado='1'");
	$login_check = mysql_num_rows($sql);

	if($login_check > 0){

		while($row = mysql_fetch_array($sql)){

			foreach( $row AS $key => $val ){

				$$key = stripslashes( $val );

			}

			$_SESSION['usuario_id'] = $usuario_id;
			$_SESSION['nome'] = $nome;
			$_SESSION['sobrenome'] = $sobrenome;
			$_SESSION['email'] = $email;
			$_SESSION['nivel_usuario'] = $nivel_usuario;
		
			mysql_query("UPDATE usuarios SET data_ultimo_login = now() WHERE usuario_id ='{$usuario_id}'");

			header("Location: area_restrita.php");

		}

	}
	else{

		echo "<script>alert('Voce nao pode logar-se! Este usuario e/ou senha nao sao validos!'); </script><br />
			<script>alert('Por favor tente novamente!'); </script><br />";

		include "formulario_login.html";

	}
}

?>