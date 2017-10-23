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
// Get and validate question id.
$def_config = get_config('filter_simplequestion');
$key = $def_config->key;
$popup = $def_config->displaymode;

// Get and decrypt question id (note, encrypted to text).
$enid = required_param('id', PARAM_TEXT); 
$id = (int) filter_simplequestion_decrypt($enid, $key);

$question = question_bank::load_question($id);
$courseid = required_param('courseid', PARAM_INT);
require_login($courseid);
$context = context_course::instance($courseid);
//$preview_url = get_preview_url($enid, $courseid);

$PAGE->set_context($context);
//$PAGE->set_url($preview_url); 

//question_require_capability_on($question, 'view');
$PAGE->set_pagelayout('popup');

// Get and validate display options.
$maxvariant = min($question->get_num_variants(), QUESTION_PREVIEW_MAX_VARIANTS);
$options = new question_preview_options($question);
//$options->load_user_defaults();
$options->set_from_request();
$options->behaviour = 'immediatefeedback';
$PAGE->set_url(preview_url($enid, $options->behaviour, $options->maxmark,
        $options, $options->variant, $courseid));

// Get and validate existing preview, or start a new one.
$previewid = optional_param('previewid', 0, PARAM_INT);

if ($previewid) {
    try {
        $quba = question_engine::load_questions_usage_by_activity($previewid);

    } catch (Exception $e) {
        // This may not seem like the right error message to display, but
        // actually from the user point of view, it makes sense.
        print_error('friendlymessage', 'filter_simplequestion',
                question_preview_url($question->id, $options->behaviour,
                $options->maxmark, $options, $options->variant, $context), null, $e);
    }
    /* 
    if ($quba->get_owning_context()->instanceid != $context) {
        print_error('notyourpreview', 'question');
    }
    */
    $slot = $quba->get_first_question_number();
    $usedquestion = $quba->get_question($slot);
    if ($usedquestion->id != $question->id) {
        print_error('questionidmismatch', 'filter_simplequestion');
    }
    $question = $usedquestion;
    $options->variant = $quba->get_variant($slot);

} else {

    //$quba = question_engine::make_questions_usage_by_activity(
    //        'filter_simplequestion', $context);

    $quba = question_engine::make_questions_usage_by_activity(
            'core_question_preview', context_user::instance($USER->id));

    $quba->set_preferred_behaviour($options->behaviour);
    $slot = $quba->add_question($question, $options->maxmark);

    if ($options->variant) {
        $options->variant = min($maxvariant, max(1, $options->variant));
    } else {
        $options->variant = rand(1, $maxvariant);
    }

    $quba->start_question($slot, $options->variant);

    $transaction = $DB->start_delegated_transaction();
    question_engine::save_questions_usage_by_activity($quba);
    $transaction->allow_commit();
}
$options->behaviour = $quba->get_preferred_behaviour();
$options->maxmark = $quba->get_question_max_mark($slot);

// Create the settings form, and initialise the fields.
//$optionsform = new preview_options_form(question_preview_form_url($question->id, $context, $previewid),
//        array('quba' => $quba, 'maxvariant' => $maxvariant));
// $optionsform->set_data($options);

/*
// Process change of settings, if that was requested.
if ($newoptions = $optionsform->get_submitted_data()) {
    // Set user preferences.
    $options->save_user_preview_options($newoptions);
    if (!isset($newoptions->variant)) {
        $newoptions->variant = $options->variant;
    }
    if (isset($newoptions->saverestart)) {
        restart_preview($previewid, $question->id, $newoptions, $context);
    }
}
*/
// Prepare a URL that is used in various places.
$actionurl = preview_action_url($enid, $quba->get_id(), $options, $courseid);

// Process any actions from the buttons at the bottom of the form.
if (data_submitted() && confirm_sesskey()) {

    try {

        if (optional_param('restart', false, PARAM_BOOL)) {
            restart_preview($previewid, $question->id, $options, $context);

        } else if (optional_param('fill', null, PARAM_BOOL)) {
            $correctresponse = $quba->get_correct_response($slot);
            if (!is_null($correctresponse)) {
                $quba->process_action($slot, $correctresponse);

                $transaction = $DB->start_delegated_transaction();
                question_engine::save_questions_usage_by_activity($quba);
                $transaction->allow_commit();
            }
            redirect($actionurl);

        } else if (optional_param('finish', null, PARAM_BOOL)) {
            $quba->process_all_actions();
            $quba->finish_all_questions();

            $transaction = $DB->start_delegated_transaction();
            question_engine::save_questions_usage_by_activity($quba);
            $transaction->allow_commit();
            redirect($actionurl);

        } else {
            $quba->process_all_actions();

            $transaction = $DB->start_delegated_transaction();
            question_engine::save_questions_usage_by_activity($quba);
            $transaction->allow_commit();

            $scrollpos = optional_param('scrollpos', '', PARAM_RAW);
            if ($scrollpos !== '') {
                $actionurl->param('scrollpos', (int) $scrollpos);
            }
            redirect($actionurl);
        }

    } catch (question_out_of_sequence_exception $e) {
        print_error('friendlymessage', 'filter_simplequestion', $actionurl);

    } catch (Exception $e) {
        // This sucks, if we display our own custom error message, there is no way
        // to display the original stack trace.
        $debuginfo = '';
        if (!empty($e->debuginfo)) {
            $debuginfo = $e->debuginfo;
        }
        print_error('postsubmiterror', 'filter_simplequestion', $actionurl,
                $e->getMessage(), $debuginfo);
    }
}

if ($question->length) {
    $displaynumber = '1';
} else {
    $displaynumber = 'i';
}
// Control form is disabled
//
// $restartdisabled = array();
// $finishdisabled = array();
// $filldisabled = array();
//if ($quba->get_question_state($slot)->is_finished()) {
//    $finishdisabled = array('disabled' => 'disabled');
//    $filldisabled = array('disabled' => 'disabled');
// }
// If question type cannot give us a correct response, disable this button.
//if (is_null($quba->get_correct_response($slot))) {
//    $filldisabled = array('disabled' => 'disabled');
//}
//if (!$previewid) {
//    $restartdisabled = array('disabled' => 'disabled');
//}

// Start output.
$title = get_string('previewquestion', 'filter_simplequestion', format_string($question->name));
$headtags = question_engine::initialise_js() . $quba->render_question_head_html($slot);
$PAGE->set_title($title);
$PAGE->set_heading($title);
echo $OUTPUT->header();

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

// Finish the question form.
/*
echo html_writer::start_tag('div', array('id' => 'previewcontrols', 'class' => 'controls'));
echo html_writer::empty_tag('input', $restartdisabled + array('type' => 'submit',
        'name' => 'restart', 'value' => get_string('restart', 'question'), 'class' => 'btn btn-secondary'));
echo html_writer::empty_tag('input', $finishdisabled  + array('type' => 'submit',
        'name' => 'save',    'value' => get_string('save', 'question'), 'class' => 'btn btn-secondary'));
echo html_writer::empty_tag('input', $filldisabled    + array('type' => 'submit',
        'name' => 'fill',    'value' => get_string('fillincorrect', 'question'), 'class' => 'btn btn-secondary'));
echo html_writer::empty_tag('input', $finishdisabled  + array('type' => 'submit',
        'name' => 'finish',  'value' => get_string('submitandfinish', 'question'), 'class' => 'btn btn-secondary'));
echo html_writer::end_tag('div');
echo html_writer::end_tag('form');

// Display the settings form.
//$optionsform->display();
*/
$PAGE->requires->js_module('core_question_engine');
$PAGE->requires->strings_for_js(array(
    'closepreview',
), 'question');
$PAGE->requires->yui_module('moodle-question-preview', 'M.question.preview.init');
echo $OUTPUT->footer();