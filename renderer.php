<?php

// This file is part of Moodle - http://moodle.org/
//
// Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Moodle.  If not, see <http://www.gnu.org/licenses/>.

/**
 * Custom renderer class for filter_simplequestion
 *
 * @package    filter
 * @subpackage simplequestion
 * @copyright  2017 Richard Jones (https://richardnz.net/)
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

class filter_simplequestion_renderer extends plugin_renderer_base {

  /**
  *
  * Given a question id, show the preview.php page
  *
  */
  public function get_question($number, $linktext, $courseid) {
    global $CFG;
    // Todo: look at this: https://moodle.org/mod/forum/discuss.php?d=332254
    
    $url = '/filter/simplequestion/preview.php'; 

    // Check if I'm inside a module
    if ($this->page->cm) {
      $modname = $this->page->cm->modname;
      $cmid = $this->page->cm->id;
      $link = new moodle_url($url, array('id'=>$number, 
                                       'courseid'=>$courseid,
                                       'modname'=>$modname,
                                       'cmid'=>$cmid));
    } else {

    $link = new moodle_url($url, array('id'=>$number, 
                                       'courseid'=>$courseid));
    }

    // Check for link text
    if ($linktext === '') { $linktext = get_string('link_text', 'filter_simplequestion'); }
    
    // Check config for popuup or embed
    $def_config = get_config('filter_simplequestion');
    $popup = $def_config->displaymode;
    if ($popup) {
      // Show the preview page
      return $this->output->action_link($link, $linktext, new popup_action('click', $link));
    } else { 

      // embed the question right here
      return $this->embed_question($number, $link, $linktext);
    }
  }

  public function embed_question($number, $link, $linktext) {
    
    $def_config = get_config('filter_simplequestion');
    $height = $def_config->height;
    $width = $def_config->width;

    $html = '';
    $html .= html_writer::start_tag('div', array('class'=>'filter_simplequestion_container'));
      
      $target = '#' . $number;
      $attributes = array('href'=>$target, 'data-toggle'=>'collapse'); 
      $html .= html_writer::start_tag('a', $attributes);
      $html .= $linktext;
      $html .= html_writer::end_tag('a');
    
      $div_array = array('id'=>$number, 'class'=>'collapse');
    
        $html .= html_writer::start_tag('div', $div_array);
        
        // the preview page needs to be embedded right here
        $attributes = array('height'=>$height, 'width'=>$width, 'src'=>$link);
        $html .= html_writer::start_tag('iframe', $attributes);
        $html .= html_writer::end_tag('iframe');
      
      $html .= html_writer::end_tag('div');
    
    $html .= html_writer::end_tag('div');
    
    return $html;
  }

  // Question display form for popup
  public function display_question($actionurl, $quba, $slot, $question, 
                                   $options, $popup, $courseid) {
    // Heading info
    $title = get_string('previewquestion', 'filter_simplequestion', format_string($question->name));
    $this->page->set_title($title);
    $this->page->set_heading($title);
    echo $this->output->header();

    // Start the simplified question form.
    echo html_writer::start_tag('form', array('method' => 'post', 'action' => $actionurl,
        'enctype' => 'multipart/form-data', 'id' => 'responseform'));
    echo html_writer::start_tag('div');
    echo html_writer::empty_tag('input', array('type' => 'hidden', 'name' => 'sesskey', 'value' => sesskey()));
    echo html_writer::empty_tag('input', array('type' => 'hidden', 'name' => 'slots', 'value' => $slot));
    echo html_writer::end_tag('div');
    
    // Output the question.
    echo $quba->render_question($slot, $options);

    echo html_writer::end_tag('form');
  }
  
  public function display_controls($popup, $courseid, $cmid, $modname) {
    
    // Add controls for exiting back to course or module
    echo html_writer::start_tag('div', array('class'=>'filter_simplequestion_controls')); 
    
    // for popup close the window message
    if ($popup) {
      echo get_string('use_close', 'filter_simplequestion');
    
    } else {  
    // for embedded click link to close panel 
      echo get_string('click_link', 'filter_simplequestion');
    }

    echo html_writer::end_tag('div');

    // End the output
    echo $this->output->footer();
  }
}