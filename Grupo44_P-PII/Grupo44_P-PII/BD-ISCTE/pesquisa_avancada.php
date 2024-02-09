<?php

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "Musisys";


$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Falha na conexão com a base de dados: " . $conn->connect_error);
}

$palco = $_POST['palco'];
$entrevistas = $_POST['entrevistas'];

$sql = "SELECT DISTINCT p.*
        FROM Participante p
        INNER JOIN Contrata c ON p.codigo = c.Participante_codigo_
        LEFT JOIN Entrevista e ON p.codigo = e.Participante_codigo_
        WHERE c.Palco_codigo = '$palco' AND (SELECT COUNT(*) FROM Entrevista WHERE Participante_codigo_ = p.codigo) >= '$entrevistas'";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    echo "<h3>Resultado da Pesquisa Avançada</h3>";
    while ($row = $result->fetch_assoc()) {
        echo "Código do Participante: " . $row['codigo'] . "<br>";
        echo "Nome do Participante: " . $row['nome'] . "<br>";
        echo "<hr>";
    }
} else {
    echo "Nenhum resultado encontrado .";
}

$conn->close();
?>