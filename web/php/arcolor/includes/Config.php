<?php
/*
* @author: samuel.almeida
* @version: v.1 29/08/2015 
* @description: classe de configuração de ambiente de sistema
*/
class Config{

	static $globals = null;

	//inicia configuração de acordo com o hambiente do sistema
	static function Init(){
		$array = array();
		//verifica qual o endereço da URL e decide qual a configuração usar
		switch ($_SERVER['SERVER_NAME']){	
			
			//extranet producao
			case 'www.extranet.imagineroland.com.br': $array = self::getProducaoExtranet(); break;
			//extranet producao
			case 'extranet.imagineroland.com.br': $array = self::getProducaoExtranet(); break;


			//extranet desenvolvimento
			case 'www.devextranet.imagineroland.com.br': $array = self::getDevExtranet(); break;
			//extranet desenvolvimento
			case 'devextranet.imagineroland.com.br': $array = self::getDevExtranet(); break;

			//ambiente padrao
			default: $array = self::getProducaoExtranet(); break;
		}
		 
		self::$globals = $array;
	}

	//retorna conexao do ambiente producao
	static function getProducaoExtranet(){
		$array = array();

		/********CONFIG SYSTEM*******/
		$array['http'] = "http://www.extranet.imagineroland.com.br/";

		$array['error_browser'] = "v2/erro-browser/index.php";
		$array['error_admin'] = "v2/erro-admin.php";
		$array['error'] = "v2/erro.php";

		$array['http_error_browser'] = $array['http'].$array['error_browser'];
		$array['http_error_admin']	= $array['http'].$array['error_admin'];
		$array['http_error']		= $array['http'].$array['error'];

		$array['nome_sistema']="Extranet";
		$array['ambiente'] = "Desenvolvimento";
		/********CONFIG SYSTEM*******/
		

		/********CONFIG BASE*******/			
		$con = $array['con1']=array('HOST'=>'localhost','USER'=>'imaginer_master','PASS'=>'Extr@743@#!','DBASE'=>'imaginer_proposta');
		$con = $array['con2']=array('HOST'=>'localhost','USER'=>'imaginer_master','PASS'=>'Extr@743@#!','DBASE'=>'imaginer_envio_de_materiais');
		$con = $array['con3']=array('HOST'=>'localhost','USER'=>'imaginer_master','PASS'=>'Extr@743@#!','DBASE'=>'imaginer_cep');
		/********CONFIG BASE*******/

		$caminho = str_replace('extranet-v2','devextranet',$_SERVER['DOCUMENT_ROOT']);

		
		/********CONFIG LAYOUT*******/
		$array['layout_template']='../app/bootstrap/';
		$array['layout_scripts']='../app/src/scripts/';
		$array['layout_css']='../app/src/css/';
		$array['layout_img']='../app/src/img/';
		$array['layout_lib']='../app/lib/';
		$array['dir_templates']="../app/views/templates/";
		$array['dir_pages']="../app/views/pages/";
		$array['dir_menus']="../app/views/menus/";
		$array['dir_script_page']="../app/views/scripts_page/";
		$array['dir_app']="../app/";
		$array['dir_json']="../app/json/";
		$array['template_page']= 'template_bootstrap.php';
		/********CONFIG LAYOUT*******/


		/********CONFIG RODAPE*******/
		$txtxt = "<span class='badge badge-success' title='Ambiente Producao'>".$array['ambiente']."</span> ";
		$array['footer_credito'] = $txtxt." 2013 &copy; ".$array['nome_sistema']." by nome empresa. ";
		/********CONFIG RODAPE*******/

		return $array;
	}

	//retorna conexao do ambiente desenvolvimento
	static function getDevExtranet(){
		$array = array();

		/********CONFIG SYSTEM*******/
		$array['http'] = "http://www.devextranet.imagineroland.com.br/";

		$array['error_browser'] = "v2/erro-browser/index.php";
		$array['error_admin'] = "v2/erro-admin.php";
		$array['error'] = "v2/erro.php";

		$array['http_error_browser'] = $array['http'].$array['error_browser'];
		$array['http_error_admin']	= $array['http'].$array['error_admin'];
		$array['http_error']		= $array['http'].$array['error'];
		$array['nome_sistema']="Extranet";
		$array['ambiente'] = "Desenvolvimento";
		/********CONFIG SYSTEM*******/
		

		/********CONFIG BASE*******/			
		$con = $array['con1']=array('HOST'=>'localhost','USER'=>'imaginer_udev','PASS'=>'s#ob6A#ye3Tk','DBASE'=>'imaginer_proposta_dev');
		$con = $array['con2']=array('HOST'=>'localhost','USER'=>'imaginer_udev','PASS'=>'s#ob6A#ye3Tk','DBASE'=>'imaginer_envio_de_materiais_dev');
		$con = $array['con3']=array('HOST'=>'localhost','USER'=>'imaginer_master','PASS'=>'Extr@743@#!','DBASE'=>'imaginer_cep');
		/********CONFIG BASE*******/

		
		return $array;
	}



}