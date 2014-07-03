<?php echo $this->fetch("header"); ?>
      <div class="boxContainer">
        <div class="buttons">
          <div class='active'>Train</div>
          <div>Examples</div>
          <div>Review</div>
          <div>Bye</div>
        </div>
        <div class="clear"></div>
        <div class="button">
          Add
          <ul class='button-dropdown'>
            <li id="add-person">Person</li>
            <li id="add-object">Object</li>
          </ul>
        </div>
        <div class="clear"></div>
        <br/>
        <div class="boxLeft">
          <?php foreach($this->sentences AS $sentence) { ?>
            <?php echo $sentence; ?><br/>
          <?php } ?>
        </div>
        <div class="boxRight">
          <?php $k = 1; ?>
          <?php foreach($this->entities AS $entity) { ?>
            <div class='entity'>
              <div class='portrait color<?php echo $k++; ?>'>
                <?php /*<img src="<?php echo $this->site_url; ?>images/person.png" /> */ ?>
              </div>
              <div class='info'>
                <?php foreach($entity['data'] as $info_key => $info_values) { ?>
                  <div class='label'><?php echo $info_key; ?></div>
                    <?php foreach($info_values AS $info_value) { ?>
                      <div class='value'><?php echo $info_value; ?></div>
                    <?php } ?>
                <?php } ?>
              </div>
              
            </div>
          <?php } ?>
          <div class='clear'></div>          
        </div>
        <div class='clear'></div>
      </div>
    
<?php echo $this->fetch("footer"); ?>

<!--
background: #bfd255; /* Old browsers */
background: -moz-linear-gradient(left, #bfd255 0%, #72aa00 100%); /* FF3.6+ */
background: -webkit-gradient(linear, left top, right top, color-stop(0%,#bfd255), color-stop(100%,#72aa00)); /* Chrome,Safari4+ */
background: -webkit-linear-gradient(left, #bfd255 0%,#72aa00 100%); /* Chrome10+,Safari5.1+ */
background: -o-linear-gradient(left, #bfd255 0%,#72aa00 100%); /* Opera 11.10+ */
background: -ms-linear-gradient(left, #bfd255 0%,#72aa00 100%); /* IE10+ */
background: linear-gradient(to right, #bfd255 0%,#72aa00 100%); /* W3C */
filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#bfd255', endColorstr='#72aa00',GradientType=1 ); /* IE6-9 */ -->