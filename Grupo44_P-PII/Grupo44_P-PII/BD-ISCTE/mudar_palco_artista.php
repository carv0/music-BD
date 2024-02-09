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
    // Obtém o código do participante a ser movido para outro palco
    $codigo_participante = $_GET['codigo'];

    // Verifica se o participante está contratado para alguma edição
    $sql_contrato = "SELECT * FROM Contrata WHERE Participante_codigo_ = '$codigo_participante'";
    $result_contrato = $conn->query($sql_contrato);

    if ($result_contrato->num_rows > 0) {
        // Obtém a lista de palcos disponíveis
        $sql_palcos = "SELECT * FROM Palco";
        $result_palcos = $conn->query($sql_palcos);

        echo "<form method='post' action='mudar_palco_final.php'>";
        echo "Selecione o novo palco para o participante:<br>";
        echo "<select name='novo_palco'>";

        while ($row_palco = $result_palcos->fetch_assoc()) {
            echo "<option value='" . $row_palco['codigo'] . "'>" . $row_palco['nome'] . "</option>";
        }

        echo "</select><br>";
        echo "<input type='hidden' name='codigo_participante' value='$codigo_participante'>";
        echo "<input type='submit' value='Mudar Palco'>";
        echo "</form>";
    } else {
        echo "O participante não está contratado para nenhuma edição.";
    }
}

$conn->close();

?>