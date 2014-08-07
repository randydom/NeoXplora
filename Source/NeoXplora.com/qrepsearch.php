<?php
error_reporting(E_ALL);
include_once 'includes/config.php';
$pagetitle = "QREP Search";
include_once 'includes/header.php';
include_once 'includes/qrepconfig.php';

$strSearchQrep = $_REQUEST['q'];

if($strSearchQrep != '')
{
    $arrSearchQrep = explode(' CONTAINING ',$strSearchQrep);
    $strFinSearchQrep = $arrSearchQrep[1];
    preg_match_all("/\((([^()]*|(?R))*)\)/", $strFinSearchQrep, $matches);
    
    foreach($matches[0] as $key => $value) // mod is rem
    {
        $strFinSearchQrep = str_replace($value, '', $strFinSearchQrep);
    }
    
    $arrExpSearchrep = explode(', ',$strFinSearchQrep);
    //print_r($arrExpSearchrep);
    
    $arrPropertyTypeCol = array("=","<","<=",">",">=","!=");
    $arrPropertyTypeColVal = array("=" => "otEquals", 
                                   "<" => "otSmaller", 
                                   "<=" => "otSmallerOrEqual" , 
                                   ">" => "otGreater", 
                                   ">=" => "otGreaterOrEqual" ,
                                   "!=" => "otDiffers");
                                   
    $strWhere = "";
    $strPropValWhere = "";
    foreach($arrExpSearchrep as $key => $value)
    {
      if(strpos($value, '.'))
      {
          if($strWhere != '')
            $strWhere .= " or ";
          
          $strWhere .= " ( ";
          $strWhere .= " `PropertyType` = 'ptAttribute' ";
          
          $strPT = '';
          foreach ($arrPropertyTypeCol as $propertyType) 
          {
            if (strpos($value, $propertyType) !== false) {
                $strPT = $propertyType; // field value found in a string
            }
          }
          
          if($strPT != '')
          {
             $pattern =  '/\.([^'.preg_quote($strPT, '/').']*?)'.preg_quote($strPT, '/').'/';
             preg_match($pattern, $value, $matches);
             $strWhere .= " and `Key` = '".trim($matches[1])."' ";
          }
          else 
          {
            $arrPropKey = explode('.',$value);
            $strWhere .= " and `Key` = '".trim($arrPropKey[1])."' ";
          }
          
          if($strPT != '')
          $arrPropKeyVal = explode($strPT,$value);
          
          $strKeyVal = $arrPropKeyVal[1];
          
          $strWhere .= " and `Id` IN (SELECT KeyId FROM neox_reppropertyvalue WHERE ( `OperatorType` = '".$arrPropertyTypeColVal[$strPT]."' and `Value` = '".trim($strKeyVal)."' ) )";
          $strWhere .= " ) ";
          
          if($strPropValWhere != '')
            $strPropValWhere .= " or ";
        if($strPT != '')
        $arrPropKeyVal = explode($strPT,$value);
        $strPropValWhere .= " ( `OperatorType` = '".$arrPropertyTypeColVal[$strPT]."' and `Value` = '".trim($arrPropKeyVal[1])."' ) ";
        
          
      }
      else if(strpos($value, ':'))
        {
          /* 
          if($strWhere != '')
            $strWhere .= " or ";
          
          $strWhere .= " ( ";
          $strWhere .= " `PropertyType` = 'ptEvent' ";
          
          $strPT = '';
          foreach ($arrPropertyTypeCol as $propertyType) 
          {
            if (strpos($value, $propertyType) !== false) {
                $strPT = $propertyType; // field value found in a string
            }
          }
          
          if(strpos($value, '='))
          {
            //preg_match('/\:([^\=]*?)\=/', $value, $matches);
             $pattern =  '/\:([^'.preg_quote($strPT, '/').']*?)'.preg_quote($strPT, '/').'/';
             preg_match($pattern, $value, $matches);
             $strWhere .= " and `Key` = '".trim($matches[1])."' ";
          }
          else 
          {
            $arrPropKey = explode(':',$value);
            $strWhere .= " and `Key` = '".trim($arrPropKey[1])."' ";
          }
          $strWhere .= " ) ";
           */
        }
        
       
        /*if($strPropValWhere != '')
            $strPropValWhere .= " or ";
        if($strPT != '')
        $arrPropKeyVal = explode($strPT,$value);
        $strPropValWhere .= " ( `OperatorType` = '".$arrPropertyTypeColVal[$strPT]."' and `Value` = '".trim($arrPropKeyVal[1])."' ) ";
        */
        
    }
   // echo $strWhere;
   // echo $strPropValWhere;
                    
   $qry = "SELECT count(*) as cntKey, PageId FROM 
            (
            SELECT nrk.Id, PageId FROM neox_reppropertykey nrk INNER JOIN neox_repentity nre 
                  ON nre.Id = nrk.ParentEntityId WHERE (".str_replace('`Id`','nrk.Id',$strWhere).") 
            UNION 
            SELECT nrk.Id, PageId FROM neox_reppropertykey nrk INNER JOIN neox_repentity nre 
                  ON nre.Id = nrk.ParentEntityId WHERE ParentEntityId IN ( 
                    SELECT ParentEntityId FROM neox_reppropertykey as nk WHERE (".str_replace('`Id`','nk.Id',$strWhere).") ) and PropertyType = 'ptEvent' 
            ) as resultTB 
            GROUP BY PageId ORDER BY cntKey DESC";
    
    $result=  mysql_query($qry, $link1) or die("error : " . mysql_error($link1));
    
    while($arrResult = mysql_fetch_array($result))
    {
      $arrURL[$arrResult['PageId']] = $arrResult['PageId']; 
    }
    //print_r($arrURL);
    //echo FULLBASE;
    //$rows = $result->fetch_assoc();
    //print_r($rows);
}
?>
<link href="<?php echo FULLBASE; ?>style/search_results.css" rel="stylesheet" type="text/css" />
<script src="<?php echo FULLBASE; ?>js/search.js"></script>
<div id="content">
    <div class="container relative searchPageContainer">
        <div id ="search_box" class="search_box" >
            <div id='logo_box_wrp'>
                <div class="logo"><img src="images/NeoXploraLOGO.png" alt="" border="0" /></div>
            </div>
            <form id="qrepSearchForm" name="qrepSearchForm" action="<?php echo $_SERVER['PHP_SELF'] ?>">
            <div class="search_bar row">
                <input type="text" name="q" id="q" />
                <input type="submit" value="" />
            </div>
            </form>
        </div>
    


<div id="searchResults">
  <div class="searchResultContainer">
  <?php if(count($arrURL) > 0) {
    foreach($arrURL as $strVal){
    echo '<div class="searchResultItem"><a href=""><span class="titletext">'.getPageNameByID($strVal).'</span></a></div>';
    }
  } ?>
  </div>
</div>
</div>
</div>
<?php
include_once 'includes/footer.php';

function getPageNameByID($pageId)
{
  global $link1;
  $qry = "SELECT * FROM neox_page WHERE Id = '".$pageId."' ";
  $result=  mysql_query($qry, $link1) or die("error : " . mysql_error($link1));
  $arrResult = mysql_fetch_assoc($result);
  
  return $arrResult['Name'];
}
?>