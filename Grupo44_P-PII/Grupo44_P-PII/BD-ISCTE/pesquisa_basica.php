<?php

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "Musisys";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Falha na conexão com a base de dados: " . $conn->connect_error);
}

$codigo = $_POST['codigo'];

$sql = "SELECT * FROM Participante WHERE codigo = '$codigo'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    echo "<h3>Resultado da Pesquisa Básica</h3>";
    while ($row = $result->fetch_assoc()) {
        echo "Código do Participante: " . $row['codigo'] . "<br>";
        echo "Nome do Participante: " . $row['nome'] . "<br>";
        
    }
} else {
    echo "Nenhum resultado encontrado para o código de participante $codigo";
}

$conn->close();
?>