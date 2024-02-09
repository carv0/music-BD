<?php

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "Musisys";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Falha na conexão com a base de dados: " . $conn->connect_error);
}

$numero = $_POST['numero'];
$nome = $_POST['nome'];
$localidade = $_POST['localidade'];
$local= $_POST['local'];
$data_inicio = $_POST['data_inicio'];
$data_fim = $_POST['data_fim'];
$lotacao = $_POST['lotacao'];
$bilhetesVendidos = $_POST['bilhetesVendidos'];
$bilhetesDevolvidos = $_POST['bilhetesDevolvidos'];

$sql = "INSERT INTO Edicao (numero, nome, localidade, local , data_inicio, data_fim, lotacao, totalBilhetesVendidos , total_bilhetes_devolvidos)
        VALUES ('$numero', '$nome', '$localidade', ' $local','$data_inicio', '$data_fim', '$lotacao', ' $bilhetesVendidos', '$bilhetesDevolvidos ')";

if ($conn->query($sql) === TRUE) {
    echo "Edição registada com sucesso.";
} else {
    echo "Erro ao registar edição: " . $conn->error;
}

$conn->close();
?>