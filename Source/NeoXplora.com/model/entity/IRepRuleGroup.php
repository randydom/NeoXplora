<?php
namespace NeoX\Entity;

require_once APP_DIR . "/app/system/Entity.php";
class TIRepRuleGroup extends \SkyCore\TEntity {

  public static $tablename = "neox_ireprulegroup";

  public static $tok_id = "Id";
  public static $tok_ruleId = "RuleId";
  public static $tok_order = "Order";
  public static $tok_parentId = "ParentId";
  public static $tok_conjunctionType = "ConjunctionType";

  public function getRuleMainGroup($ruleId) {
    $query = $this->query("
  		  SELECT * FROM [[ireprulegroup]] 
  			WHERE 
          [[ireprulegroup.ruleId]] = :1 AND 
  				[[ireprulegroup.parentId]] IS NULL
  			", $ruleId);
    return $query;
  }

  public function getGroupChildren($groupId) {
    $query = $this->query("
  		  SELECT * FROM [[ireprulegroup]] 
  			WHERE
          [[ireprulegroup.parentId]] = :1
  			", $groupId);
    return $query;
  }

}
?>