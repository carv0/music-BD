-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 18-Dez-2023 às 19:42
-- Versão do servidor: 10.4.28-MariaDB
-- versão do PHP: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `testes`
--

DELIMITER $$
--
-- Procedimentos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `CloneEdicao` (IN `original_numero ` INT, IN `clone_data_inicio` DATE)   BEGIN
    DECLARE clone_numero INT;

    -- Clonar edicao
    INSERT INTO edicao (numero, nome, localidade, local, data_inicio, data_fim, lotacao, totalBilhetesVendidos, total_bilhetes_devolvidos)
    SELECT MAX(numero) + 1, nome, localidade, local, clone_data_inicio, NULL, lotacao, NULL, NULL
    FROM edicao WHERE numero = original_numero;
    
    SET clone_numero = (SELECT MAX(numero) FROM edicao);

    -- Clonar palcos
    INSERT INTO palco (Edicao_numero, codigo, nome)
    SELECT clone_numero, codigo, nome FROM palco WHERE Edicao_numero = original_numero;

    -- Clonar dias do festival
    INSERT INTO dia_festival (Edicao_numero, data, qtd_espetadores)
    SELECT clone_numero, DATE_ADD(data, INTERVAL DATEDIFF(clone_data_inicio, data) DAY), qtd_espetadores
    FROM dia_festival WHERE Edicao_numero = original_numero;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `criarEdicao` (IN `p_numero` INT, IN `p_nome` VARCHAR(30), IN `p_localidade` VARCHAR(30), IN `p_local` VARCHAR(30), IN `p_data_inicio` DATE, IN `p_data_fim` DATE, IN `p_lotacao` INT)   BEGIN
    -- Criacao da Edicao
    INSERT INTO edicao(numero, nome, localidade, local, data_inicio, data_fim, lotacao)
    VALUES(p_numero, p_nome, p_localidade, p_local, p_data_inicio, p_data_fim, p_lotacao);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `criar_Palco_Para_Edicao` (IN `p_numero` INT, IN `p_palco_codigo_1` INT, IN `p_palco_nome_1` VARCHAR(30))   BEGIN
    DECLARE edicao_existe INT;

    -- Verificar se a edicao existe
    SELECT COUNT(*) INTO edicao_existe
    FROM edicao
    WHERE numero = p_numero;

    IF edicao_existe > 0 THEN
        -- A edicao existe, então podemos adicionar os palcos

        -- Criação dos Palco associado a Edicao
        INSERT INTO palco(Edicao_numero, codigo, nome)
        VALUES(p_numero, p_palco_codigo_1, p_palco_nome_1);
     END IF;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Q1_Cartaz` (IN `edicao_numero_p` TINYINT(4))   BEGIN
    SELECT participante.nome, contrata.Dia_festival_data
    FROM contrata
    JOIN participante ON contrata.Participante_codigo_ = participante.codigo
    WHERE contrata.Edicao_numero_ = edicao_numero_p
    ORDER BY contrata.Dia_festival_data ASC, contrata.cachet DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Q6_Entrevistados_por` (IN `edicao_numero_p` INT, IN `nome_jornalista_p` VARCHAR(100))   BEGIN
    SELECT participante.nome
    FROM participante
    INNER JOIN entrevista ON participante.codigo = entrevista.Participante_codigo_
    INNER JOIN jornalista ON entrevista.Jornalista_num_carteira_profissional_ = jornalista.num_carteira_profissional
    INNER JOIN edicao ON participante.edicao_numero = edicao.numero
    WHERE edicao.numero = edicao_numero_p
        AND jornalista.nome = nome_jornalista_p;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Q7_Ainda_nao_entrevistados_por` (IN `nome_jornalista_p` VARCHAR(100))   BEGIN

SELECT participante.nome
FROM participante
LEFT JOIN entrevista ON participante.codigo = entrevista.Participante_codigo_
LEFT JOIN jornalista ON entrevista.Jornalista_num_carteira_profissional_ = jornalista.num_carteira_profissional
WHERE jornalista.nome = nome_jornalista_p
    AND participante.edicao_numero = (SELECT MAX(numero) FROM edicao)
    AND entrevista.Participante_codigo_ IS NULL;
    
END$$

--
-- Funções
--
CREATE DEFINER=`root`@`localhost` FUNCTION ` Q3_Qtd_espetadores_no_dia` (`edicao_numero_p` INT, `data_do_festival_p` DATE) RETURNS INT(11)  BEGIN
    DECLARE qtd_espetadores INT;

    SELECT qtd_espetadores
    INTO qtd_espetadores
    FROM dia_festival
    WHERE Edicao_numero = edicao_numero_p AND data = data_do_festival_p;

    RETURN qtd_espetadores;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CalcularMedia` () RETURNS DECIMAL(10,2)  BEGIN
    DECLARE total_lucro DECIMAL(10, 2);
    DECLARE total_edicoes INT;
    
    -- Inicialize as variaveis
    SET total_lucro = 0;
    SET total_edicoes = 0;

    -- Loop atraves das edicoes para calcular o total do lucro
    FOR each_edicao IN (SELECT DISTINCT Edicao_numero FROM contrata) DO
        SET total_lucro = total_lucro + (
            SELECT SUM(cachet) FROM contrata WHERE Edicao_numero_ = each_edicao.Edicao_numero
        );
        SET total_edicoes = total_edicoes + 1;
    END FOR;

    -- Retorna a media do lucro por edicao
    RETURN total_lucro / total_edicoes;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `calcularNumeroParticipantes` () RETURNS INT(11)  BEGIN
DECLARE numeroParticipantes INT;
    -- Encontrar o numero de participantes da ultima edicao
    SELECT COUNT(DISTINCT Participantecodigo) INTO numeroParticipantes
    FROM Contrata
    WHERE Edicaonumero = (SELECT MAX(numero) FROM Edicao);

    -- Retornar o numero de participantes
    RETURN numeroParticipantes;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `acesso`
--

CREATE TABLE `acesso` (
  `Dia_festival_data_` date NOT NULL,
  `Tipo_de_bilhete_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `bilhete`
--

CREATE TABLE `bilhete` (
  `num_serie` int(11) NOT NULL,
  `Tipo_de_bilhete_id` int(11) NOT NULL,
  `Espetador_com_bilhete_Espetador_identificador` int(11) DEFAULT NULL,
  `designacao` varchar(60) DEFAULT NULL,
  `devolvido` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

--
-- Extraindo dados da tabela `bilhete`
--

INSERT INTO `bilhete` (`num_serie`, `Tipo_de_bilhete_id`, `Espetador_com_bilhete_Espetador_identificador`, `designacao`, `devolvido`) VALUES
(1, 1, 1, 'Bilhete 1', 0),
(2, 2, 3, 'Bilhete 1', 0),
(3, 5, 2, 'Bilhete 1', 0),
(4, 4, 1, 'Bilhete 1', 0),
(5, 3, 1, 'Bilhete 1', 0);

--
-- Acionadores `bilhete`
--
DELIMITER $$
CREATE TRIGGER `after_bilhete_insert` AFTER INSERT ON `bilhete` FOR EACH ROW BEGIN
    DECLARE num_serie_bilhete INT;
    DECLARE tipo_bilhete_id INT;
    DECLARE data_festival DATE;
    
    IF NEW.devolvido=0 THEN 
    -- Obter informacoes do bilhete recem-criado
    SELECT NEW.num_serie, NEW.Tipo_de_bilhete_id
    INTO num_serie_bilhete, tipo_bilhete_id;

    -- Obter a data do festival associada ao bilhete
    SELECT Dia_festival_data_
    INTO data_festival
    FROM acesso
    WHERE Tipo_de_bilhete_id = tipo_bilhete_id
        AND Dia_festival_data_ IS NOT NULL;

    -- Atualizar qtd_espetadores no dia de festival correspondente
    UPDATE dia_festival
    SET qtd_espetadores = qtd_espetadores + 1
    WHERE data = data_festival;
    
    ELSE
      UPDATE dia_festival
    SET qtd_espetadores = qtd_espetadores - 1
    WHERE data = data_festival;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_bilhete` BEFORE INSERT ON `bilhete` FOR EACH ROW BEGIN
    DECLARE capacidade_diaria INT;
    DECLARE total_espetadores INT;
    DECLARE data_festival DATE;
    DECLARE tipo_bilhete_id INT;

    -- Obter informações do bilhete a ser inserido
    SELECT NEW.Tipo_de_bilhete_id
    INTO tipo_bilhete_id;

    -- Obter a data do festival associada ao bilhete
    SELECT Dia_festival_data_
    INTO data_festival
    FROM acesso
    WHERE Tipo_de_bilhete_id = tipo_bilhete_id
        AND Dia_festival_data_ IS NOT NULL;

    -- Obter a capacidade diaria do recinto para o dia de festival
    SELECT lotacao, qtd_espetadores
    INTO capacidade_diaria, total_espetadores
    FROM edicao e
    JOIN dia_festival df ON e.numero = df.Edicao_numero
    WHERE df.data = data_festival;

    -- Verificar se a lotacao diaria foi excedida
    IF total_espetadores >= capacidade_diaria THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lotacao diaria excedida. Nao e possivel adicionar mais bilhetes para este dia.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `contrata`
--

CREATE TABLE `contrata` (
  `Edicao_numero_` tinyint(4) NOT NULL,
  `Participante_codigo_` smallint(6) NOT NULL,
  `cachet` int(11) DEFAULT NULL,
  `Palco_Edicao_numero` tinyint(4) NOT NULL,
  `Palco_codigo` tinyint(4) NOT NULL,
  `Dia_festival_data` date NOT NULL,
  `hora_inicio` time DEFAULT NULL,
  `hora_fim` time DEFAULT NULL,
  `Convidado_Edicao_numero_` tinyint(4) NOT NULL,
  `Convidado_Participante_codigo_` smallint(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

--
-- Extraindo dados da tabela `contrata`
--

INSERT INTO `contrata` (`Edicao_numero_`, `Participante_codigo_`, `cachet`, `Palco_Edicao_numero`, `Palco_codigo`, `Dia_festival_data`, `hora_inicio`, `hora_fim`, `Convidado_Edicao_numero_`, `Convidado_Participante_codigo_`) VALUES
(1, 1, 200, 1, 111, '2023-10-18', '22:00:00', '00:00:00', 1, 1),
(2, 2, 1000, 2, 22, '2023-11-14', '18:23:50', '22:23:50', 1, 1),
(3, 3, 10000, 3, 33, '2023-08-23', '22:24:36', '23:24:36', 2, 2),
(4, 4, 900, 4, 44, '2023-11-22', '22:25:17', '23:25:17', 2, 2),
(5, 5, 9000, 5, 55, '2023-09-20', '22:25:17', '23:25:17', 3, 3);

-- --------------------------------------------------------

--
-- Estrutura da tabela `convidado`
--

CREATE TABLE `convidado` (
  `Espetador_com_bilhete_Espetador_identificador` int(11) NOT NULL,
  `profissao` varchar(60) DEFAULT NULL,
  `total_convidados` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

--
-- Extraindo dados da tabela `convidado`
--

INSERT INTO `convidado` (`Espetador_com_bilhete_Espetador_identificador`, `profissao`, `total_convidados`) VALUES
(1, 'Jornalista', 1),
(4, 'Comediante', 2),
(5, 'Artista', 3),
(8, 'Futebolista', 4);

-- --------------------------------------------------------

--
-- Estrutura da tabela `dia_festival`
--

CREATE TABLE `dia_festival` (
  `Edicao_numero` tinyint(4) NOT NULL,
  `data` date NOT NULL,
  `qtd_espetadores` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

--
-- Extraindo dados da tabela `dia_festival`
--

INSERT INTO `dia_festival` (`Edicao_numero`, `data`, `qtd_espetadores`) VALUES
(3, '2023-08-23', 780),
(5, '2023-09-20', 470),
(1, '2023-10-18', 170),
(2, '2023-11-14', 870),
(4, '2023-11-22', 170),
(2, '2024-12-25', 700),
(1, '2024-12-26', 180),
(3, '2024-12-27', 600),
(6, '2024-12-31', 900);

-- --------------------------------------------------------

--
-- Estrutura da tabela `edicao`
--

CREATE TABLE `edicao` (
  `numero` tinyint(4) NOT NULL,
  `nome` varchar(60) DEFAULT NULL,
  `localidade` varchar(60) DEFAULT NULL,
  `local` varchar(60) DEFAULT NULL,
  `data_inicio` date DEFAULT NULL,
  `data_fim` date DEFAULT NULL,
  `lotacao` int(11) DEFAULT NULL,
  `totalBilhetesVendidos` int(11) DEFAULT NULL,
  `total_bilhetes_devolvidos` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

--
-- Extraindo dados da tabela `edicao`
--

INSERT INTO `edicao` (`numero`, `nome`, `localidade`, `local`, `data_inicio`, `data_fim`, `lotacao`, `totalBilhetesVendidos`, `total_bilhetes_devolvidos`) VALUES
(1, 'EDICAO 1', 'Lisboa', 'Lisboa', '2023-10-16', '2023-10-18', 200, 180, 10),
(2, 'EDICAO 2', 'Lisboa', 'Lisboa', '2023-11-07', '2023-11-14', 900, 880, 10),
(3, 'EDICAO 3', 'Porto', 'Porto', '2023-08-15', '2023-08-23', 800, 800, 10),
(4, 'EDICAO 4', 'Guimarães', 'Guimarães', '2023-11-14', '2023-11-22', 600, 180, 10),
(5, 'EDICAO 5', 'Algarve', 'Algarve', '2023-09-12', '2023-09-20', 500, 480, 10),
(6, 'Edicao 6', 'Lisboa', 'Lisboa', '2024-12-30', '2024-12-31', 900, 900, 0),
(7, 'EDICAO 7', 'Lisboa', ' Lisboa', '2024-12-31', '2025-01-04', 700, 600, 0);

-- --------------------------------------------------------

--
-- Estrutura da tabela `elemento_grupo`
--

CREATE TABLE `elemento_grupo` (
  `Individual_Participante_codigo_` smallint(6) NOT NULL,
  `Grupo_Participante_codigo_` smallint(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `entrevista`
--

CREATE TABLE `entrevista` (
  `Participante_codigo_` smallint(6) NOT NULL,
  `Jornalista_num_carteira_profissional_` int(11) NOT NULL,
  `data` date DEFAULT NULL,
  `hora` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

--
-- Extraindo dados da tabela `entrevista`
--

INSERT INTO `entrevista` (`Participante_codigo_`, `Jornalista_num_carteira_profissional_`, `data`, `hora`) VALUES
(1, 111, '0000-00-00', '14:00:00'),
(1, 777, '2024-12-26', '16:25:32'),
(1, 888, '2024-12-26', '22:47:42'),
(2, 666, '0000-00-00', '15:00:00'),
(3, 666, '0000-00-00', '16:00:00'),
(4, 777, '0000-00-00', '17:00:00'),
(5, 888, '0000-00-00', '18:00:00'),
(7, 111, '2024-12-26', '16:26:31');

-- --------------------------------------------------------

--
-- Estrutura da tabela `espetador_com_bilhete`
--

CREATE TABLE `espetador_com_bilhete` (
  `Espetador_identificador` int(11) NOT NULL,
  `nome` varchar(100) DEFAULT NULL,
  `genero` enum('M','F') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

--
-- Extraindo dados da tabela `espetador_com_bilhete`
--

INSERT INTO `espetador_com_bilhete` (`Espetador_identificador`, `nome`, `genero`) VALUES
(1, 'Espetador 1', 'M'),
(2, 'Espetador 2', 'F'),
(3, 'Espetador 3', 'M'),
(4, 'Espetador 4', 'F'),
(5, 'Espetador 5', 'F'),
(6, 'Espetador 6', 'M'),
(7, 'Espetador 7', 'M'),
(8, 'Espetador 8', 'F');

-- --------------------------------------------------------

--
-- Estrutura da tabela `estilo`
--

CREATE TABLE `estilo` (
  `Nome` varchar(30) NOT NULL,
  `id_estilo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

--
-- Extraindo dados da tabela `estilo`
--

INSERT INTO `estilo` (`Nome`, `id_estilo`) VALUES
('POP', 1),
('RAP', 2),
('HIP-POP', 3),
('FUNK', 4),
('COUNTRY', 5);

-- --------------------------------------------------------

--
-- Estrutura da tabela `estilo_de_artista`
--

CREATE TABLE `estilo_de_artista` (
  `Participante_codigo_` smallint(6) NOT NULL,
  `Estilo_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `grupo`
--

CREATE TABLE `grupo` (
  `Participante_codigo` smallint(6) NOT NULL,
  `qtd_elementos` tinyint(4) DEFAULT NULL,
  `nome` varchar(80) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `individual`
--

CREATE TABLE `individual` (
  `Participante_codigo` smallint(6) NOT NULL,
  `Pais_id` int(11) DEFAULT NULL,
  `nome` varchar(80) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `jornalista`
--

CREATE TABLE `jornalista` (
  `Espetador_identificador` int(11) NOT NULL,
  `Media_id` int(11) NOT NULL,
  `num_carteira_profissional` int(11) NOT NULL,
  `nome` varchar(100) DEFAULT NULL,
  `genero` enum('M','F') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

--
-- Extraindo dados da tabela `jornalista`
--

INSERT INTO `jornalista` (`Espetador_identificador`, `Media_id`, `num_carteira_profissional`, `nome`, `genero`) VALUES
(1, 1, 111, 'Jornalista 1', 'M'),
(6, 2, 666, 'Jornalista 2', 'F'),
(7, 3, 777, 'Jornalista 3', 'F'),
(8, 5, 888, 'Jornalista 4', 'F');

-- --------------------------------------------------------

--
-- Estrutura da tabela `livre_transito`
--

CREATE TABLE `livre_transito` (
  `Edicao_numero_` tinyint(4) NOT NULL,
  `Jornalista_num_carteira_profissional_` int(11) NOT NULL,
  `numero` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

--
-- Extraindo dados da tabela `livre_transito`
--

INSERT INTO `livre_transito` (`Edicao_numero_`, `Jornalista_num_carteira_profissional_`, `numero`) VALUES
(1, 111, 1),
(2, 111, 1),
(3, 666, 1),
(4, 777, 2),
(5, 888, 3);

-- --------------------------------------------------------

--
-- Estrutura da tabela `media`
--

CREATE TABLE `media` (
  `nome` varchar(30) NOT NULL,
  `tipo` enum('Rádio','TV','Jornal','Revista') DEFAULT NULL,
  `id_media` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

--
-- Extraindo dados da tabela `media`
--

INSERT INTO `media` (`nome`, `tipo`, `id_media`) VALUES
('RTP', 'TV', 1),
('SIC', 'TV', 2),
('TVI', 'TV', 3),
('CMTV', 'TV', 4),
('CNN', 'TV', 5);

-- --------------------------------------------------------

--
-- Estrutura da tabela `montado`
--

CREATE TABLE `montado` (
  `Palco_Edicao_numero_` tinyint(4) NOT NULL,
  `Palco_codigo_` tinyint(4) NOT NULL,
  `Tecnico_numero_` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

--
-- Acionadores `montado`
--
DELIMITER $$
CREATE TRIGGER `roadie_montagem_palco` BEFORE INSERT ON `montado` FOR EACH ROW BEGIN

DECLARE participante_artista_codigo INT;
DECLARE palco_artista_codigo INT;


    -- Obter o codigo do participante (artista) associado ao roadie
    SELECT Participante_codigo INTO participante_artista_codigo
    FROM roadie
    WHERE Tecnico_numero = NEW.Tecnico_numero_;

    -- Obter o codigo do palco onde o artista atua
    SELECT Palco_codigo
    INTO palco_artista_codigo
    FROM contrata
    WHERE Edicao_numero_ = NEW.Palco_Edicao_numero_
        AND Participante_codigo_ = participante_artista_codigo;

    -- Verificar se o palco onde o roadie esta sendo atribuido e o mesmo onde o artista atua
    IF palco_artista_codigo IS NULL OR palco_artista_codigo != NEW.Palco_codigo_ THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Roadie nao pode montar em palco onde o artista nao atua';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `pagante`
--

CREATE TABLE `pagante` (
  `Espetador_com_bilhete_Espetador_identificador` int(11) NOT NULL,
  `idade` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

--
-- Extraindo dados da tabela `pagante`
--

INSERT INTO `pagante` (`Espetador_com_bilhete_Espetador_identificador`, `idade`) VALUES
(1, 30),
(4, 40),
(5, 19),
(8, 20);

-- --------------------------------------------------------

--
-- Estrutura da tabela `pais`
--

CREATE TABLE `pais` (
  `nome` varchar(60) NOT NULL,
  `id_pais` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `palco`
--

CREATE TABLE `palco` (
  `Edicao_numero` tinyint(4) NOT NULL,
  `codigo` tinyint(4) NOT NULL,
  `nome` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

--
-- Extraindo dados da tabela `palco`
--

INSERT INTO `palco` (`Edicao_numero`, `codigo`, `nome`) VALUES
(1, 111, 'Palco 1'),
(2, 22, 'Palco 2'),
(3, 33, 'palco 3'),
(4, 44, 'palco 4'),
(5, 55, 'palco 5');

-- --------------------------------------------------------

--
-- Estrutura da tabela `papel`
--

CREATE TABLE `papel` (
  `Nome` varchar(30) NOT NULL,
  `id_papel` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `papel_no_grupo`
--

CREATE TABLE `papel_no_grupo` (
  `Elemento_grupo_Individual_Participante_codigo__` smallint(6) NOT NULL,
  `Elemento_grupo_Grupo_Participante_codigo__` smallint(6) NOT NULL,
  `Papel_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `participante`
--

CREATE TABLE `participante` (
  `codigo` smallint(6) NOT NULL,
  `nome` varchar(80) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

--
-- Extraindo dados da tabela `participante`
--

INSERT INTO `participante` (`codigo`, `nome`) VALUES
(1, 'Participante 1'),
(2, 'Participante 2'),
(3, 'Participante 3'),
(4, 'Participante 4'),
(5, 'Participante 5'),
(6, 'Participante 6'),
(7, 'Participante 7'),
(8, 'Participante 8');

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `q2_resultados_diarios`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `q2_resultados_diarios` (
`data` date
,`qtd_espetadores` int(11)
,`faturacao` decimal(28,2)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `q4_estilos_musicais_por_edicao`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `q4_estilos_musicais_por_edicao` (
`Edicao` tinyint(4)
,`Estilo` varchar(30)
,`Qtd_artistas` bigint(21)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `q5_todos_os_participantes`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `q5_todos_os_participantes` (
`nome` varchar(80)
,`Anos_desde_ultima_atuacao` decimal(10,4)
,`Ultimo_cachet` int(11)
);

-- --------------------------------------------------------

--
-- Estrutura da tabela `reportagem`
--

CREATE TABLE `reportagem` (
  `Dia_festival_data_` date NOT NULL,
  `Jornalista_num_carteira_profissional_` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `roadie`
--

CREATE TABLE `roadie` (
  `Tecnico_numero` int(11) NOT NULL,
  `Participante_codigo` smallint(6) NOT NULL,
  `nome` varchar(120) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tecnico`
--

CREATE TABLE `tecnico` (
  `numero` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

--
-- Extraindo dados da tabela `tecnico`
--

INSERT INTO `tecnico` (`numero`) VALUES
(1),
(2),
(3),
(4),
(5),
(6),
(7),
(8);

-- --------------------------------------------------------

--
-- Estrutura da tabela `tema`
--

CREATE TABLE `tema` (
  `Edicao_numero` tinyint(4) NOT NULL,
  `Participante_codigo` smallint(6) NOT NULL,
  `nr_ordem` tinyint(4) NOT NULL,
  `titulo` varchar(60) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tipo_de_bilhete`
--

CREATE TABLE `tipo_de_bilhete` (
  `Nome` varchar(30) NOT NULL,
  `preco` decimal(6,2) DEFAULT NULL,
  `id_tipo_de_bilhete` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;

--
-- Extraindo dados da tabela `tipo_de_bilhete`
--

INSERT INTO `tipo_de_bilhete` (`Nome`, `preco`, `id_tipo_de_bilhete`) VALUES
('Tipo 1', 20.00, 1),
('Tipo 1', 20.00, 2),
('Tipo 2', 80.00, 3),
('Tipo 2', 80.00, 4),
('Tipo 3', 120.00, 5),
('Tipo 3', 120.00, 6),
('Tipo 4', 100.00, 7);

-- --------------------------------------------------------

--
-- Estrutura para vista `q2_resultados_diarios`
--
DROP TABLE IF EXISTS `q2_resultados_diarios`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `q2_resultados_diarios`  AS SELECT `dia_festival`.`data` AS `data`, `dia_festival`.`qtd_espetadores` AS `qtd_espetadores`, sum(case when `bilhete`.`devolvido` = 0 then `tipo_de_bilhete`.`preco` else 0 end) AS `faturacao` FROM (((`dia_festival` left join `acesso` on(`dia_festival`.`data` = `acesso`.`Dia_festival_data_`)) left join `bilhete` on(`acesso`.`Tipo_de_bilhete_id` = `bilhete`.`Tipo_de_bilhete_id`)) left join `tipo_de_bilhete` on(`bilhete`.`Tipo_de_bilhete_id` = `tipo_de_bilhete`.`id_tipo_de_bilhete`)) GROUP BY `dia_festival`.`data` ;

-- --------------------------------------------------------

--
-- Estrutura para vista `q4_estilos_musicais_por_edicao`
--
DROP TABLE IF EXISTS `q4_estilos_musicais_por_edicao`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `q4_estilos_musicais_por_edicao`  AS SELECT `contrata`.`Edicao_numero_` AS `Edicao`, `estilo`.`Nome` AS `Estilo`, count(`contrata`.`Participante_codigo_`) AS `Qtd_artistas` FROM ((`contrata` join `estilo_de_artista` on(`contrata`.`Participante_codigo_` = `estilo_de_artista`.`Participante_codigo_`)) join `estilo` on(`estilo_de_artista`.`Estilo_id` = `estilo`.`id_estilo`)) GROUP BY `contrata`.`Edicao_numero_`, `estilo`.`Nome` ;

-- --------------------------------------------------------

--
-- Estrutura para vista `q5_todos_os_participantes`
--
DROP TABLE IF EXISTS `q5_todos_os_participantes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `q5_todos_os_participantes`  AS SELECT `participante`.`nome` AS `nome`, (to_days(curdate()) - to_days(`contrata`.`Dia_festival_data`)) / 365 AS `Anos_desde_ultima_atuacao`, `contrata`.`cachet` AS `Ultimo_cachet` FROM (`participante` left join `contrata` on(`participante`.`codigo` = `contrata`.`Participante_codigo_`)) WHERE (`contrata`.`Participante_codigo_`,`contrata`.`Dia_festival_data`) in (select `contrata`.`Participante_codigo_`,max(`contrata`.`Dia_festival_data`) AS `Ultima_data` from `contrata` group by `contrata`.`Participante_codigo_`) ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
