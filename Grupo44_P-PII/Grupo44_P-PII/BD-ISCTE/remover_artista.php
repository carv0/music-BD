<?php

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "Musisys";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Falha na conexão com a base de dados: " . $conn->connect_error);
}

if ($_SERVER["REQUEST_METHOD"] == "GET") {
    // Obtém o código do participante a ser removido
    $codigo_participante = $_GET['codigo'];

    // Verifica se o participante está contratado para alguma edição
    $sql_contrato = "SELECT * FROM Contrata WHERE Participante_codigo_ = '$codigo_participante'";
    $result_contrato = $conn->query($sql_contrato);

    if ($result_contrato->num_rows > 0) {
        // Remove o participante da tabela Contrata
        $sql_remover_contrato = "DELETE FROM Contrata WHERE Participante_codigo_ = '$codigo_participante'";
        $conn->query($sql_remover_contrato);

        echo "Participante foi removido com sucesso.";
    } else {
        echo "O participante não está contratado para nenhuma edição.";
    }
}

$conn->close();

?>