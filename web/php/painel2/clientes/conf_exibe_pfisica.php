<?php
//conf do exibe usu

mysql_connect("localhost","root","")or die("erro ao conectar!");

mysql_select_db("painel2")or die("Nao funcionou!");

@$nome = $linha["ds_cliente"];
@$identidade = $linha["nr_ident"];
@$cnpjcpf = $linha["nr_cnpjcpf"];
@$contato = $linha["ds_contato"];
@$telddd = $linha["nr_ddd"];
@$telefone = $linha["nr_telefone"];
@$email = $linha["email"];
@$endereco = $linha["ds_endereco"];
@$complemento = $linha["ds_complemento"];
@$bairro = $linha["ds_bairro"];
@$cidade = $linha["ds_cidade"];
@$estado = $linha["ds_estado"];
@$cep = $linha["nr_cep"];
@$tp_cliente = $linha["tp_cliente"];

if ($nome || $identidade || $cnpjcpf || $contato || $telddd || $telefone || $email || $endereco || $complemento || $bairro || $cidade || $estado || $cep || $tp_cliente){
$sql = "INSERT INTO cad_cliente  f(ds_cliente,nr_ident,nr_cnpjcpf,ds_contato,nr_ddd,nr_telefone,email,ds_endereco,ds_complemento,ds_bairro,ds_cidade,ds_estado,nr_cep,tp_cliente)) VALUES ('$nome','$identidade','$cnpjcpf','$contato','$telddd','$telefone','$email','$endereco','$complemento','$bairro','$cidade','$estado','$cep','$tp_cliente')";
$res = mysql_query($sql)or die("erro no query");
echo "Enviado <br>";
}else{
//echo "preencha todos os campos";	
}
/*
$sql2 = "SELECT * FROM pfisica";
$query = mysql_query($sql2);
 while($linha = mysql_fetch_assoc($query))
{
$nomefis = $linha['nome'];
$telfis = $linha['telefone'];
$emailfis = $linha['email'];

//echo "Nome: $nomefis <br/> Telefone: $telfis <br/><br/>";
}

*/
?>