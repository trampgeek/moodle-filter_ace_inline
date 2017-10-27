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
    $link = new moodle_url($url, array('id'=>$number, 
                                       'courseid'=>$courseid));
    
    // Check for link text
    if ($linktext === '') { $linktext = get_string('link_text', 'filter_simplequestion'); }
    
    // Check config for popuup or embed
    $def_config = get_config('filter_simplequestion');
    $popup = $def_config->displaymode;
    if ($popup) {
      return $this->output->action_link($link, $linktext, new popup_action('click', $link));
    } else { 
      return html_writer::link($link, $linktext);
    }
  }
  // Question display form
  public function display_question($actionurl, $quba, $slot, $question, 
                                   $options, $displaynumber, $popup) {
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
    echo $quba->render_question($slot, $options, $displaynumber);
  }

  public function display_controls($enid, $courseid, $popup) {

    // Form controls for simplequestion
    echo html_writer::start_tag('div', array('class'=>'filter_simplequestion_controls')); 
    // for popup close the window
    if ($popup) {
      echo get_string('use_close', 'filter_simplequestion');
    
    } else if ($this->page->cm) {

      // Do something specific to this module
      $modname = $this->page->cm->modname;
      $cmid = $this->page->cm->id;
      
      $linktext =  get_string('return_module', 'filter_simplequestion');
      $url = '/mod/' . $modname . '/view.php'; 
      $link = new moodle_url($url, array('id'=>$cmid));
      echo html_writer::link($link, $linktext);

    } else {  
    // for embedded have a link, won't work in activity module  
      $linktext =  get_string('return_course', 'filter_simplequestion');
      $url = '/course/view.php'; 
      $link = new moodle_url($url, array('id'=>$courseid));
      echo html_writer::link($link, $linktext);
    }

    echo html_writer::end_tag('div');
    echo html_writer::end_tag('form');
    
    // End the output
    echo $this->output->footer();
  }
}