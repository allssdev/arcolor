<?php
/*
* @author: samuel.almeida
* @version: v.1 29/08/2015 
* @description: classe de configuração de ambiente de sistema
*/
class Config{

	static $globals = null;

	//retorna elementos
	static function get($str = ""){
		if(self::$globals == null) self::Init();
		if($str != ""){
			return self::$globals[$str];
		}
		return self::$globals;
	}

	//inicia configuração de acordo com o hambiente do sistema
	static function Init(){
		$array = array();
		//verifica qual o endereço da URL e decide qual a configuração usar
		switch ($_SERVER['SERVER_NAME']){	
			
			//extranet desenvolvimento
			case 'www.devextranet.imagineroland.com.br': $array = self::getDevExtranet(); break;
			//extranet desenvolvimento
			case 'devextranet.imagineroland.com.br': $array = self::getDevExtranet(); break;
                        
			//extranet local
			case 'localhost': $array = self::getLocal(); break;
			//extranet local
			case '127.0.0.1': $array = self::getLocal(); break;

			//ambiente padrao
			default: $array = self::getProducaoExtranet(); break;
		}
		 
		self::$globals = $array;
	}
        
        
        static function getLocal(){
            
		$array = array();

		$array = self::getDevExtranet();
                
		/********CONFIG SYSTEM*******/
		$array['http']                  =	"localhost:8080/Application/devextranet";
		$array['nome_empresa']		=	"Roland DG Brasil";
		$array['nome_sistema']		=	"Extranet";
		$array['ambiente']		=	"Oficial";
		/********CONFIG SYSTEM*******/
            
		/********CONFIG BASE*******/			
		$con = $array['con1']		=	array('HOST'=>'localhost', 'USER'=>'root','PASS'=>'', 'DBASE'=>'imaginer_proposta_dev');
		$con = $array['con2']		=	array('HOST'=>'localhost', 'USER'=>'imaginer_master', 'PASS'=>'Extr@743@#!',	'DBASE'=>'imaginer_envio_de_materiais');
		$con = $array['con3']		=	array('HOST'=>'localhost', 'USER'=>'imaginer_master', 'PASS'=>'Extr@743@#!', 'DBASE'=>'imaginer_cep');
		/********CONFIG BASE*******/
                
		return $array;
        }


	//retorna conexao do ambiente desenvolvimento
	static function getDevExtranet(){
		
		//define o local
		$local = __DIR__."/";


		$array = array();


		/********CONFIG SYSTEM*******/
		$array['http']				=	"http://www.devextranet.imagineroland.com.br/";
		$array['nome_empresa']		=	"Roland DG Brasil";
		$array['nome_sistema']		=	"Extranet";
		$array['ambiente']			=	"Desenvolvimento";
		/********CONFIG SYSTEM*******/
		
		
		/********CONFIG LAYOUT*******/
		$array['assets_metronic']	=	'assets_4.5.1/';
		$array['assets']			=	'../assets_4.5.1';
		$array['js']				=	'src/js/';
		$array['css']				=	'src/css/';
		$array['img']				=   'src/img/';
		$array['imagens']			=   __DIR__.'/../../../imagens/';
		$array['base']				=   __DIR__.'/../../../proposta-comercial/base/';
		$array['lib']				=	$local.'../../lib/';
		$array['dir_json']			=	'json/';
		$array['dir_templates']		=	'templates/';
		$array['dir_pages']			=	'pages/';
		$array['dir_menus']			=	'menus/';
		$array['dir_modules']		=	'modules/';
		$array['dir_script_page']	=	'scripts_page/';		
		$array['dir_anexos']		=   "../../anexos/";
		$array['dir_anexos_users']	=   $array['dir_anexos']."imagens/users/";
		$array['template_metronic']	=	$array['dir_templates']."template_metronic_4.5.1.php";
		$array['menu_top_4.5.1']	=	$array['dir_menus']."menu_metronic_top_4.5.1.php";
		$array['menu_user_and_alert_4.5.1']	=	$array['dir_menus']."menu_top_user_4.5.1.php";		
		
		
		$array['template_metronic_error']	=	$array['dir_templates']."template_metronic_error_4.5.1.php";	
		/********CONFIG LAYOUT*******/

		
		/********CONFIG BASE*******/			
		$con = $array['con1']		=	array('HOST'=>'localhost', 'USER'=>'imaginer_udev', 'PASS'=>'s#ob6A#ye3Tk', 'DBASE'=>'imaginer_proposta_dev');
		$con = $array['con2']		=	array('HOST'=>'localhost', 'USER'=>'imaginer_udev', 'PASS'=>'s#ob6A#ye3Tk', 'DBASE'=>'imaginer_envio_de_materiais_dev');
		$con = $array['con3']		=	array('HOST'=>'localhost', 'USER'=>'imaginer_master', 'PASS'=>'Extr@743@#!', 'DBASE'=>'imaginer_cep_dev');
		/********CONFIG BASE*******/

		
		/********CONFIG RODAPE*******/
		$txtxt						=	"<span class='badge badge-danger' title='Ambiente de Desenvolvimento'>".$array['ambiente']."</span> ";
		$array['footer_credito']	=	$txtxt." 2016 &copy; ".$array['nome_sistema']." by ".$array['nome_empresa'].". ";
		/********CONFIG RODAPE*******/


		/********CONFIG INTEGRAÇÃO PROTHEUS*******/
		$array['url_envio_proposta_protheus'] = "http://187.108.38.218:8283/WS_RDG_TMKA260.apw?WSDL";
		/********CONFIG INTEGRAÇÃO PROTHEUS*******/

		return $array;
	}



}