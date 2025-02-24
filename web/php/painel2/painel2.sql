# Host: localhost  (Version: 5.5.27)
# Date: 2012-10-18 12:52:39
# Generator: MySQL-Front 5.2  (Build 5.106)

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE */;
/*!40101 SET SQL_MODE='' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES */;
/*!40103 SET SQL_NOTES='ON' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS */;
/*!40014 SET FOREIGN_KEY_CHECKS=0 */;

#
# Source for table "cad_cliente"
#

DROP TABLE IF EXISTS `cad_cliente`;
CREATE TABLE `cad_cliente` (
  `cd_cliente` int(10) NOT NULL AUTO_INCREMENT,
  `ds_cliente` varchar(255) DEFAULT NULL,
  `nr_cnpjcpf` varchar(50) DEFAULT NULL,
  `nr_ident` varchar(50) DEFAULT NULL,
  `ds_contato` varchar(200) DEFAULT NULL,
  `nr_ddd` char(3) DEFAULT NULL,
  `nr_telefone` varchar(15) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `ds_endereco` varchar(50) DEFAULT NULL,
  `ds_complemento` varchar(50) DEFAULT NULL,
  `ds_bairro` varchar(50) DEFAULT NULL,
  `ds_cidade` varchar(50) DEFAULT NULL,
  `ds_estado` varchar(50) DEFAULT NULL,
  `nr_cep` varchar(9) DEFAULT NULL,
  `ds_razao` varchar(100) DEFAULT NULL,
  `tp_cliente` char(1) DEFAULT 'f',
  PRIMARY KEY (`cd_cliente`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=latin1;

#
# Data for table "cad_cliente"
#

INSERT INTO `cad_cliente` VALUES (16,'spacetec','2222222222222',NULL,'pedro','21','22530548','pedro@spacetec.com.br','av rio branco','37 1502','centro','rio de janeiro','RJ','24320000','spacetec soluÃ§oes tecnologicas','j');

#
# Source for table "usuarios"
#

DROP TABLE IF EXISTS `usuarios`;
CREATE TABLE `usuarios` (
  `usuario_id` int(5) NOT NULL AUTO_INCREMENT,
  `nome` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `sobrenome` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `email` varchar(100) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `usuario` varchar(32) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `senha` varchar(32) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `info` text COLLATE latin1_general_ci NOT NULL,
  `nivel_usuario` enum('0','1','2') COLLATE latin1_general_ci NOT NULL DEFAULT '0',
  `data_cadastro` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `data_ultimo_login` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `ativado` enum('0','1') COLLATE latin1_general_ci NOT NULL DEFAULT '0',
  PRIMARY KEY (`usuario_id`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

#
# Data for table "usuarios"
#

/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'pedro','laxe','pedrolaxe@gmail.com','admin','d3ce9efea6244baa7bf718f12dd0c331','lol','2','2012-09-11 13:18:48','2012-10-18 12:40:13','1'),(7,'rodrigo','laxe','rodrigo@localhost.com','rodrigo','7e3839d7c35d683d292bb9e425c46f11','rodrigo laxe','2','0000-00-00 00:00:00','2012-09-17 11:29:51','1');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;

/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
