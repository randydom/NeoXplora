<?php
  /**
   * Header
   *
   * @package CMS Pro
   * @author wojoscripts.com
   * @copyright 2010
   * @version $Id: header.php, v2.00 2011-04-20 10:12:05 gewa Exp $
   */
  
  if (!defined("_VALID_PHP"))
      die('Direct access to this location is not allowed.');
?>
<!doctype html>
<head>
<?php echo $content->getMeta(); ?>
<script type="text/javascript">
var THEMEURL = "<?php echo THEMEURL; ?>";
var SITEURL = "<?php echo SITEURL; ?>";
</script>
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
<meta charset="UTF-8">
<link href="http://fonts.googleapis.com/css?family=Oswald:300,400,700" media="all" rel="stylesheet" type="text/css" />
<?php $content->getThemeStyle();?>
<script type="text/javascript" src="<?php echo SITEURL;?>/assets/jquery.js"></script>
<script type="text/javascript" src="<?php echo SITEURL;?>/assets/jquery-ui.js"></script>
<script type="text/javascript" src="<?php echo SITEURL;?>/assets/tables.js"></script>
<script type="text/javascript" src="<?php echo SITEURL;?>/assets/global.js"></script>
<script type="text/javascript" src="<?php echo SITEURL;?>/assets/cycle.js"></script>
<script type="text/javascript" src="<?php echo SITEURL;?>/assets/flex.js"></script>
<script type="text/javascript" src="<?php echo THEMEURL;?>/master.js"></script>
<script type="text/javascript" src="<?php echo SITEURL;?>/assets/fancybox/jquery.fancybox.pack.js"></script>
<script type="text/javascript" src="<?php echo SITEURL;?>/assets/fancybox/helpers/jquery.fancybox-media.js"></script>
<link rel="stylesheet" type="text/css" href="<?php echo SITEURL;?>/assets/fancybox/jquery.fancybox.css" media="screen" />
<!--link rel="stylesheet" href="http://code.jquery.com/mobile/1.4.2/jquery.mobile-1.4.2.css">
<script src="http://code.jquery.com/mobile/1.4.2/jquery.mobile-1.4.2.min.js"></script -->
<?php if($core->eucookie):?>
<script type="text/javascript" src="<?php echo SITEURL;?>/assets/eu_cookies.js"></script>
<script type="text/javascript"> 
$(document).ready(function () {
    $("body").acceptCookies({
        position: 'top',
        notice: '<?php echo EU_NOTICE;?>',
        accept: '<?php echo EU_ACCEPT;?>',
        decline: '<?php echo EU_DECLINE;?>',
        decline_t: '<?php echo EU_DECLINE_T;?>',
        whatc: '<?php echo EU_W_COOKIES;?>'
    })
});
</script> 
<?php endif;?>
<?php $content->getPluginAssets();?>
<?php $content->getModuleAssets();?>
</head>
<body<?php $core->renderThemeBg();?>>
  <!-- Header -->
  <header id="header" class="clearfix">
  <div class="container"> 
    

    <div class="row grid_24">
      <div class="sub-header clearfix">
        <div class="col grid_<?php echo ($core->showsearch) ? 14 : 14;?>">
          <div class="logo">
          <a href="<?php echo SITEURL;?>/index.php"><?php echo ($core->logo) ? '<img src="'.SITEURL.'/uploads/'.$core->logo.'" alt="'.$core->company.'" />': $core->company;?></a> </div>
        </div>
      
      <div class="col grid_10" style="text-align:right;">
        
          <a href="<?php echo SITEURL;?>/index.php"><img src="uploads/logo3.png"></a>
        
          </div>
        </div>
      <?php if($core->showsearch):?>
        <!-- Livesearch Start -->
        <div class="col grid_8">
          <div id="search-box" class="flright">
            <form action="<?php echo SITEURL;?>/search.php" method="post" name="search-form">
              <input name="keywords" type="text" id="inputString" onClick="disAutoComplete(this);" />
            </form>
            <div id="suggestions"></div>
          </div>
        </div>
        <!--/ Livesearch End --> 
        <?php endif;?>
      </div>
    </div>
    
    <!-- Main Menu -->
    <div class="row clearfix">
      <nav id="mainmenu" class="col grid_24">
      <div class="menu-mobile-wrapper">
          <a id="menu-mobile-trigger"><span></span></a>
      </div>
         <div class="container">  <?php $mainmenu = $content->getMenuList(); $content->getMenu($mainmenu,0);?></div>
      </nav>
      <!-- Main Menu  /--> 
    </div>
    
  <!-- Header /--> 
  </div> 
  </header>
