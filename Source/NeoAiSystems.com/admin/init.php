<?php
  /**
   * Init
   *
   * @version $Id: init.php, v2.00 2011-04-20 10:12:05 gewa Exp $
   */
  if (!defined("_VALID_PHP"))
      die('Direct access to this location is not allowed.');
?>
<?php error_reporting(E_ALL);

  // Magic Quotes Fix
  if (ini_get('magic_quotes_gpc')) {
      function clean($data)
      {
          if (is_array($data)) {
              foreach ($data as $key => $value) {
                  $data[clean($key)] = clean($value);
              }
          } else {
              $data = stripslashes($data);
          }
          
          return $data;
      }
      
      $_GET = clean($_GET);
      $_POST = clean($_POST);
      $_COOKIE = clean($_COOKIE);
  }
  
  if (substr(PHP_OS, 0, 3) == "WIN") {
      $WOJOLITE = str_replace("admin\\init.php", "", realpath(__FILE__));
  } else {
      $WOJOLITE = str_replace("admin/init.php", "", realpath(__FILE__));
  }
  
  define("WOJOLITE", $WOJOLITE);
  
  $configFile = WOJOLITE . "lib/config.ini.php";
  if (file_exists($configFile)) {
      require_once($configFile);
  } else {
      header("Location: ../setup/");
  }
  
  require_once(WOJOLITE . "lib/class_db.php");
  $db = new Database(DB_SERVER, DB_USER, DB_PASS, DB_DATABASE);
  $db->connect();
  
  include(WOJOLITE . "lib/headerRefresh.php");
  require_once(WOJOLITE . "lib/class_filter.php");
  $request = new Filter();

  //Include Functions
  require_once(WOJOLITE . "lib/functions.php");
  require_once(WOJOLITE . "lib/fn_seo.php");
  
  //Start Core Class 
  require_once(WOJOLITE . "lib/class_core.php");
  $core = new Core();  
  
  //StartUser Class 
  require_once(WOJOLITE . "lib/class_user.php");
  $user = new Users();
  
  //Load Content Class
  require_once(WOJOLITE . "lib/class_content.php");
  $content = new Content();

  //Load Membership Class
  require_once(WOJOLITE . "lib/class_membership.php");
  $member = new Membership();

  //Load Security Class
  require_once(WOJOLITE . "lib/class_security.php");
  $wojosec = new Security($core->attempt, $core->flood);
   
  define("SITEURL", $core->site_url);
  define("ADMINURL", $core->site_url."/admin");
  define("UPLOADS", WOJOLITE."uploads/");
  define("UPLOADURL", SITEURL."/uploads");
  define("MODPATH", WOJOLITE."admin/modules/");
  define("THEMEURL", SITEURL."/theme/".$core->theme);
?>