<?php
  require_once APP_DIR . "/app/system/model.php";
  class ModelTrainSplitter extends Model {
    
    public function getCategory($ignoreIDs = array()) {
      $ignore = '';
      if(is_array($ignoreIDs) && count($ignoreIDs) > 0) {
        $ignore .= " AND se.[[sentence.id]] NOT IN (";
        for($i = 0; $i < count($ignoreIDs); $i++) {
          $ignore .= "'" . $ignoreIDs[$i] . "'";
          if($i != count($ignoreIDs) - 1) $ignore .= ', ';
        }
        $ignore .= ") ";
      }
    
      $query = $this->query("
        SELECT a.[[category.id]] AS id, a.`pageCount`, a.`trainedCount`
        FROM (
          SELECT c2.[[category.id]], c2.`pageCount`, COUNT(p2.[[page.id]]) AS trainedCount 
          FROM (
            SELECT c.[[category.id]], COUNT(p.[[page.id]]) AS pageCount FROM [[category]] c
            INNER JOIN (
              SELECT DISTINCT pg.[[page.id]], pg.[[page.status]], pg.[[page.categoryid]]
              FROM [[page]] pg
              INNER JOIN [[sentence]] se ON pg.[[page.id]] = se.[[sentence.pageid]]
              WHERE se.[[sentence.status]] = :1 " . $ignore . "
            ) p ON c.[[category.id]] = p.[[page.categoryid]]
            GROUP BY(c.[[category.id]])
          ) c2
          LEFT JOIN [[page]] p2 ON p2.[[page.categoryid]] = c2.[[category.id]] AND p2.[[page.status]] NOT IN (:2, :3)
          GROUP BY (c2.[[category.id]])
        ) a INNER JOIN [[page]] p3 ON p3.[[page.categoryid]] = a.[[category.id]]
        GROUP BY p3.[[page.categoryid]]
        ORDER BY a.`trainedCount` ASC
        LIMIT 1;
      ", "ssFinishedGenerate", "psFinishedCrawl", "psFinishedGenerate");
      
      return $this->result($query);
    }
    
    public function getSentence($categoryID, $offset, $sentence_offset, $ignoreIDs = array()) {
      $ignore = '';
      if(is_array($ignoreIDs) && count($ignoreIDs) > 0) {
        $ignore .= " AND se.[[sentence.id]] NOT IN (";
        for($i = 0; $i < count($ignoreIDs); $i++) {
          $ignore .= "'" . $ignoreIDs[$i] . "'";
          if($i != count($ignoreIDs) - 1) $ignore .= ', ';
        }
        $ignore .= ") ";
      }
      
      $query = $this->query("
        SELECT
          se.[[sentence.id]],
          se.[[sentence.name]]
        FROM (
          SELECT DISTINCT p.[[page.id]], p.[[page.status]] 
          FROM [[page]] p
          INNER JOIN [[sentence]] s ON p.[[page.id]] = s.[[sentence.pageid]]
          WHERE p.[[page.categoryid]] = :1
          AND s.[[sentence.status]] = :2
          LIMIT :3, 1
        ) a INNER JOIN [[sentence]] se ON a.[[page.id]] = se.[[sentence.pageid]]
        WHERE se.[[sentence.status]] = :2
        " . $ignore . "
        ORDER BY se.[[sentence.assigneddate]] ASC, se.[[sentence.id]] DESC
        LIMIT :4, 1
      ", $categoryID, "ssFinishedGenerate", $offset, $sentence_offset);
      
      return $this->result($query);
    } 
    
    public function countSentences($categoryID, $offset) {
      $query = $this->query("
        SELECT COUNT(se.[[sentence.id]]) AS sentenceCount
        FROM (
          SELECT DISTINCT p.[[page.id]], p.[[page.status]] 
          FROM [[page]] p
          INNER JOIN [[sentence]] s ON p.[[page.id]] = s.[[sentence.pageid]]
          WHERE p.[[page.categoryid]] = :1
          AND s.[[sentence.status]] = :2
          LIMIT :3, 1
        ) a INNER JOIN [[sentence]] se ON a.[[page.id]] = se.[[sentence.pageid]]
        WHERE se.[[sentence.status]] = :2
      ", $categoryID, "ssFinishedGenerate", $offset);
      
      return $this->result($query);
    }
    
  }
?>