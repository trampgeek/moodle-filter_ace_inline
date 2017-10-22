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
 * This page displays a preview of a question
 *
 * The preview uses the option settings from the activity within which the question
 * is previewed or the default settings if no activity is specified. The question session
 * information is stored in the session as an array of subsequent states rather
 * than in the database.
 *
 * @package    moodlecore
 * @subpackage questionengine
 * @copyright  Alex Smith {@link http://maths.york.ac.uk/serving_maths} and
 *      numerous contributors.
 *  Modified/simplified for moodle_filter_simplequestion by Richard Jones https://richardnz.net/
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

require_once(__DIR__ . '/../../config.php');
require_once($CFG->libdir . '/questionlib.php');
require_once(__DIR__ . '/../../question/previewlib.php');
require_once('locallib.php');
/**
 * The maximum number of variants previewable. If there are more variants than this for a question
 * then we only allow the selection of the first x variants.
 * @var integer
 */
define('QUESTION_PREVIEW_MAX_VARIANTS', 100);

// Get and validate question id.
$def_config = get_config('filter_simplequestion');
$key = $def_config->key;
$popup = $def_config->displaymode;

// Get and decrypt question id (note, encrypted to text).
$enid = required_param('id', PARAM_TEXT); 
$id = (int) filter_simplequestion_decrypt($enid, $key);

// Get our context and course module id
$courseid = required_param('courseid', PARAM_INT);
require_login($courseid);
$context = context_course::instance($courseid);
$preview_url = get_preview_url($enid, $courseid);
$PAGE->set_context($context);
$PAGE->set_url($preview_url); 

// Load the question
$question = question_bank::load_question($id);
question_require_capability_on($question, 'view');  

// Question display options 
$maxvariant = min($question->get_num_variants(), QUESTION_PREVIEW_MAX_VARIANTS);
$options = get_display_options($maxvariant);
$quba = question_engine::make_questions_usage_by_activity('filter_simplequestion', $context);
$qubaid = $quba->get_id();

if (data_submitted() && confirm_sesskey()) {
  // Process the response
  $timenow = time();
  $transaction = $DB->start_delegated_transaction();
  question_engine::load_questions_usage_by_activity($qubaid);
  $quba->process_all_actions($timenow);
  question_engine::save_questions_usage_by_activity($quba);
  $transaction->allow_commit();

} else {
  // Setup the question to be displayed                     
  $quba->set_preferred_behaviour('immediatefeedback');
  $slot = $quba->add_question($question, 0);
  $quba->start_question($slot);
  
  $transaction = $DB->start_delegated_transaction();
  question_engine::save_questions_usage_by_activity($quba);
  $transaction->allow_commit();
}
  // Create the settings form, and initialise the fields.
  //$optionsform = new preview_options_form(preview_form_url($enid, $courseid, $slot),
  //                   array('quba' => $quba, 'maxvariant' => $maxvariant));
  //$optionsform->set_data($options);

$title = get_string('previewquestion', 'filter_simplequestion', format_string($question->name));
$headtags = question_engine::initialise_js() . $quba->render_question_head_html($slot);
$PAGE->set_title($title);
$PAGE->set_heading($title);
echo $OUTPUT->header();


// Start the question form.
echo html_writer::start_tag('form', array('method' => 'post', 'action' => $preview_url,
        'enctype' => 'multipart/form-data', 'id' => 'responseform'));
echo html_writer::start_tag('div');
echo html_writer::empty_tag('input', array('type' => 'hidden', 'name' => 'sesskey', 'value' => sesskey()));
echo html_writer::empty_tag('input', array('type' => 'hidden', 'name' => 'slots', 'value' => $slot));
echo html_writer::empty_tag('input', array('type' => 'hidden', 'name' => 'scrollpos', 'value' => '', 'id' => 'scrollpos'));
echo html_writer::end_tag('div');

// Output the question.
echo $quba->render_question($slot, $options);

/*
// Finish the question form.
// Todo: Add an option in config to show the controls like fill, close, submit
// Meanwhile we do have a check button on the question form with immediate feedback
// 
echo html_writer::start_tag('div', array('id' => 'previewcontrols', 'class' => 'controls'));
//echo html_writer::empty_tag('input', $filldisabled    + array('type' => 'submit',
//        'name' => 'fill',    'value' => get_string('fillincorrect', 'question'), 'class' => 'btn btn-secondary'));
echo html_writer::empty_tag('input', array('type' => 'submit','name' => 'finish',  
     'value' => get_string('answer_question', 'filter_simplequestion'), 
      'class' => 'btn btn-secondary'));
echo html_writer::end_tag('div');
echo html_writer::end_tag('form');
*/
echo $OUTPUT->footer();