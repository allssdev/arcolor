<?php
//conf do exibe usu

mysql_connect("localhost","root","")or die("erro ao conectar!");

mysql_select_db("painel2")or die("Nao funcionou!");

@$nome = $linha["ds_cliente"];
@$razao = $linha["ds_razao"];
@$cnpjcpf = $linha["nr_cnpjcpf"];
@$contato = $linha["ds_contato"];
@$telddd = $linha["nr_ddd"];
@$telefone = $linha["telefone"];
@$email = $linha["email"];
@$endereco = $linha["ds_endereco"];
@$complemento = $linha["ds_complemento"];
@$bairro = $linha["ds_bairro"];
@$cidade = $linha["ds_cidade"];
@$estado = $linha["ds_estado"];
@$cep = $linha["nr_cep"];

if ($nome || $razao || $cnpjcpf || $contato || $telddd || $telefone || $email || $endereco || $complemento || $bairro || $cidade || $estado || $cep){
$sql = "INSERT INTO cad_cliente (ds_cliente,ds_razao,nr_cnpjcpf,ds_contato,nr_ddd,telefone,email,ds_endereco,ds_complemento,ds_bairro,ds_cidade,ds_estado,nr_cep)) VALUES ('$nome','$razao','$cnpjcpf','$contato','$telddd','$telefone','$email','$endereco','$complemento','$bairro','$cidade','$estado','$cep')";
$res = mysql_query($sql)or die("erro no query");
echo "Enviado <br>";
}else{
//echo "preencha todos os campos";	
}

?>