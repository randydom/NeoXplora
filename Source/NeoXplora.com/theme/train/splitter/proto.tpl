<tr data-id='<?php echo $this->proto['id']; ?>' class='aproto'>
  <td>
    <div class="level-indent-wrapper">
      <?php for($i = 0; $i < $this->proto['indentation'] + 1; $i++) { ?>
        <div class="level-indent level<?php echo ($i % 5); ?>"></div>
      <?php } ?>
    </div>
    <div class="content-indent <?php if($this->proto['level'] > 1) { ?>childProto<?php } ?>"> 
      <?php if($this->proto['level'] == 1) { ?>
        > 
      <?php } ?>
      <b><?php echo $this->proto['name'] ?></b>
      <input type='hidden' class='pageID' value='<?php echo $this->proto['pageid']; ?>' />
    </div>
  </td>
  <td>
    <div href="javascript:void(0)" class="revertReviewSplitButton button">Revert</div>
    <?php if($this->proto['level'] == 1) { ?>
      <div href="javascript:void(0)" class="finish button">Finish</div> 
      <div href="javascript:void(0)" class="skip button">Skip</div>
    <?php } ?>
  </td>
</tr>