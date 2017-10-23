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
    $link = new moodle_url($url, array('id'=>$number, 'courseid'=>$courseid));
    
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
  public function display_question($actionurl, $quba, $slot, $question, $options, $displaynumber) {
    global $PAGE;

    // Heading info
    $title = get_string('previewquestion', 'filter_simplequestion', format_string($question->name));
    $headtags = question_engine::initialise_js() . $quba->render_question_head_html($slot);
    $PAGE->set_title($title);
    $PAGE->set_heading($title);
    echo $this->output->header();
     
    // Start the question form.
    echo html_writer::start_tag('form', array('method' => 'post', 'action' => $actionurl,
        'enctype' => 'multipart/form-data', 'id' => 'responseform'));
    echo html_writer::start_tag('div');
    echo html_writer::empty_tag('input', array('type' => 'hidden', 'name' => 'sesskey', 'value' => sesskey()));
    echo html_writer::empty_tag('input', array('type' => 'hidden', 'name' => 'slots', 'value' => $slot));
    echo html_writer::empty_tag('input', array('type' => 'hidden', 'name' => 'scrollpos', 'value' => '', 'id' => 'scrollpos'));
    echo html_writer::end_tag('div');

    // Output the question.
    echo $quba->render_question($slot, $options, $displaynumber);

    $PAGE->requires->js_module('core_question_engine');
    $PAGE->requires->strings_for_js(array(
      'closepreview',
      ), 'question');
    $PAGE->requires->yui_module('moodle-question-preview', 'M.question.preview.init');

    echo $this->output->footer();
}
}