<?php echo $this->fetch("header"); ?>
<div class="boxContainer">
  <div class="buttons leftMenu">
    <a href="train.php?type=interpreter">Train</a>
    <a href="browse.php?type=interpreter">Browse</a>
    <?php if($this->userlevel == 'admin') { ?>
    <a href="review.php?type=interpreter" class='active'>Review</a>
    <?php } ?>
  </div>
  <div class="button bigButton rightMenu">
    Interpreter
    <ul class='button-dropdown'>
      <li><a href="train.php?type=splitter">Splitter</a></li>
      <li><a href="train.php?type=interpreter">Interpreter</a></li>
      <li><a href="train.php?type=linker">Linker</a></li>
      <li><a href="train.php?type=tutor">Tutor</a></li>
      <li><a href="train.php?type=deducer">Deducer</a></li>
      <li><a href="train.php?type=summarizer">Summarizer</a></li>
      <li><a href="train.php?type=quizzer">Quizzer</a></li>
    </ul>
  </div>
  <div class="clear"></div>
  <div class="buttons smaller">
    <a href="javascript:void(0)" class="approveAllBtn">Approve All</a>
    <a href="javascript:void(0)" class="dismissAllBtn">Dismiss All</a>
  </div>
  <div class="clear"></div>
  <br/>
  <div class="boxContent">
    
  </div>
  <div class="boxPagination">
    
  </div>
</div>
<?php echo $this->fetch("footer"); ?>