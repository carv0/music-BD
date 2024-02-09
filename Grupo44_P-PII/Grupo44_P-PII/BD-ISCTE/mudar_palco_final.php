<?php

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "Musisys";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Falha na conexão com a base de dados: " . $conn->connect_error);
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Obtém os dados do formulário
    $codigo_participante = $_POST['codigo_participante'];
    $novo_palco_nome = $_POST['novo_palco'];

    // Consulta o código do novo palco
    $sql_codigo_palco = "SELECT codigo FROM Palco WHERE nome = '$novo_palco_nome'";
    $result_codigo_palco = $conn->query($sql_codigo_palco);

    if ($result_codigo_palco) {
        // Verifica se o novo palco foi encontrado
        if ($result_codigo_palco->num_rows > 0) {
            // Obtém o código do palco
            $row_codigo_palco = $result_codigo_palco->fetch_assoc();
            $codigo_palco = $row_codigo_palco['codigo'];

            // Atualiza o palco do participante na tabela Contrata
            $sql_atualizar_palco = "UPDATE Contrata SET Palco_codigo = $codigo_palco WHERE Participante_codigo_ = $codigo_participante";

            // Executa a query de atualização
            if ($conn->query($sql_atualizar_palco) === TRUE) {
                echo "Palco foi atualizado com sucesso.";
            } else {
                echo "Erro ao atualizar o palco do participante: " . $conn->error;
            }
        } else {
            // Caso o novo palco não seja encontrado
            echo " Novo palco não foi encontrado.";
        }
    } else {
       
        echo "Erro ao consultar o código do novo palco: " . $conn->error;
    }
} else {
    echo "Requisição inválida.";
}

$conn->close();

?>

