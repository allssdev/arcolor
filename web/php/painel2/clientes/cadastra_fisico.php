<?php
include "../includes/config.php"; // Chama a conexao com o banco de dados

$tabela_bd = "cad_cliente"; // altere de acordo com sua tabela

$nome = $_POST["ds_cliente"];
$identidade = $_POST["nr_ident"];
$cnpjcpf = $_POST["nr_cnpjcpf"];
$contato = $_POST["ds_contato"];
$telddd = $_POST["nr_ddd"];
@$telefone = $_POST["nr_telefone"];
$email = $_POST["email"];
$endereco = $_POST["ds_endereco"];
$complemento = $_POST["ds_complemento"];
$bairro = $_POST["ds_bairro"];
$cidade = $_POST["ds_cidade"];
$estado = $_POST["ds_estado"];
$cep = $_POST["nr_cep"];


$sql = mysql_query("INSERT INTO $tabela_bd(ds_cliente,nr_ident,nr_cnpjcpf,ds_contato,nr_ddd,nr_telefone,email,ds_endereco,ds_complemento,ds_bairro,ds_cidade,ds_estado,nr_cep) VALUES('$nome','$identidade','$cnpjcpf','$contato','$telddd','$telefone','$email','$endereco','$complemento','$bairro','$cidade','$estado','$cep')"); /*linha para cadastrar no banco de dados.*/
if ($sql) { // verificação para saber se foi cadastrado
echo '<script> alert("Cadastrado com sucesso!") </script>';
} else { // Caso dê erro
echo '<script> alert("Falha ao cadastrar... :( ") </script>'.mysql_error();
}

?>
Voc&ecirc; ser&aacute; Redirecionado a P&aacute;gina anterior<META HTTP-EQUIV="REFRESH" CONTENT="2; URL=../cadastros/cadastros.php">
