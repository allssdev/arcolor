<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Sistema de busca</title>
</head>
 
<body>
<div class="tudo">
<h3>Busca de Nomes de Pessoas</h3>
<form name="frmBusca" method="post" action="<?php require_once('C:/xampp/htdocs/painel2/fern.php');
Annotation("C:\\xampp\\htdocs\\painel2\\cadastros\\buscar.php_0");
 echo $_SERVER['PHP_SELF'] ?>?a=buscar" >
    Nome do cliente:<input type="text" name="palavra" />
    <input type="submit" value="Buscar" />
</form>

 
<?php
include "../includes/config.php";
protegePagina();
// Conex�o com o banco de dados
$conn = @mysql_connect("localhost", "root", "") or die("N�o foi poss�vel a conex�o com o Banco");
	// Selecionando banco

$db = @mysql_select_db("painel2", $conn) or die("N�o foi poss�vel selecionar o Banco");
// Recuperamos a a��o enviada pelo formul�rio
@$a = $_GET['a'];
// Verificamos se a a��o � de busca
if ($a == "buscar") {

    // Pegamos a palavra
    @$palavra = trim($_POST['palavra']);
    // Verificamos no banco de dados produtos equivalente a palavra digitada
    $sql = Hook_19642b6af0764bf47e9e6ec6bcdd44801("SELECT * FROM cad_cliente WHERE ds_cliente LIKE '%".$palavra."%' ORDER BY ds_cliente");

    // Descobrimos o total de registros encontrados
    $numRegistros = mysql_num_rows($sql);

    // Se houver pelo menos um registro, exibe-o
    if ($numRegistros != 0) {

        // Exibe os produtos e seus respectivos pre�os
		
		echo "-----------Pessoas F&iacute;sicas encontradas---------- <br />";
        while ($produto = mysql_fetch_object($sql)) {
            echo $produto->ds_cliente . "<br />";
        }
		echo '<br /><a href="javascript:window.history.go(-1)">Voltar</a>';
    // Se n�o houver registros
    } else {
        echo "Nenhum Cliente foi encontrado com a palavra -> ".$palavra."";
    }
}
mysql_close();

?>

</div>
</body>
</html>