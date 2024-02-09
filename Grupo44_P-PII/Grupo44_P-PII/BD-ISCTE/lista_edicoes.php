<?php

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "Musisys";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Falha na conexão com a base de dados: " . $conn->connect_error);
}

// Obtém a data atual
$data_atual = date('Y-m-d');

// Encontra as próximas edições
$sql_edicoes = "SELECT * FROM Edicao WHERE data_inicio > '$data_atual' ORDER BY data_inicio";
$result_edicoes = $conn->query($sql_edicoes);

if ($result_edicoes->num_rows > 0) {
    echo "<h3>Próximas Edições</h3>";
    while ($row_edicao = $result_edicoes->fetch_assoc()) {
        echo "Número: " . $row_edicao['numero'] . "<br>";
        echo "Nome: " . $row_edicao['nome'] . "<br>";
        echo "Localidade: " . $row_edicao['localidade'] . "<br>";
        echo "Local: " . $row_edicao['local'] . "<br>";
        echo "Data de Início: " . $row_edicao['data_inicio'] . "<br>";
        echo "Data de Fim: " . $row_edicao['data_fim'] . "<br>";
        echo "Lotação: " . $row_edicao['lotacao'] . "<br>";
        echo "Bilhetes Vendidos: " . $row_edicao['totalBilhetesVendidos'] . "<br>";
        echo "Bilhetes Devolvidos: " . $row_edicao['total_bilhetes_devolvidos'] . "<br>";

        // Listar artistas e palcos para cada edição 
        $numero_edicao = $row_edicao['numero'];
        $sql_artistas = "SELECT p.codigo, p.nome, c.Palco_codigo
                        FROM Contrata c
                        INNER JOIN Participante p ON c.Participante_codigo_ = p.codigo
                        WHERE c.Edicao_numero_ = '$numero_edicao'";
        $result_artistas = $conn->query($sql_artistas);

        if ($result_artistas->num_rows > 0) {
            echo "<p>Artistas:</p>";
            while ($row_artista = $result_artistas->fetch_assoc()) {
                echo " - Artista: " . $row_artista['nome'] . " (Palco: " . $row_artista['Palco_codigo'] . ") ";
                echo "<a href='remover_artista.php?codigo=" . $row_artista['codigo'] . "'>Remover</a> ";
                echo "<a href='mudar_palco_artista.php?codigo=" . $row_artista['codigo'] . "'>Mudar Palco</a><br>";
            }
        } else {
            echo "<p>Nenhum artista contratado para esta edição.</p>";
        }

        echo "<hr>"; // Linha de separação entre edições
    }
} else {
    echo "<p>Nenhuma edição futura foi encontrada.</p>";
}

$conn->close();

?>