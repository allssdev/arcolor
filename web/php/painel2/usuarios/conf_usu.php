<?php
//

mysql_connect("localhost","root","")or die("erro ao conectar!"); //conecta ao bd

mysql_select_db("painel2")or die("Nao funcionou!");
//estão com arroba, pois ta dando Notice no php, por causa da variavel 'linha'.
@$nomeusu = $linha['nome']; 
@$usuariousu = $linha['usuario'];
@$senhausu = $linha['senha'];

if ($nomeusu || $usuariousu || $senhausu ){
$sql = "INSERT INTO usuarios (nome,usuario,senha) VALUES ('$nomeusu','$usuariousu','$senhausu')"; //nem precisa comentar mané! kkkkk
$res = mysql_query($sql)or die("erro no query"); //dá erro se nao conectar ao bd
echo "Enviado <br>"; //da essa msgm se enviou ao bd
}else{
//echo "preencha todos os campos";	
}

?>