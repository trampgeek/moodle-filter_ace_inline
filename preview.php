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
 * Modified for filter_simplequestion by Richard Jones {@link https://richardnz.net}
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

require_once(__DIR__ . '/../../config.php');
require_once($CFG->libdir . '/questionlib.php');
require_once(__DIR__ . '/../../question/previewlib.php');

/**
 * The maximum number of variants previewable.
 * If there are more variants than this for a question
 * then we only allow the selection of the first x variants.
 * @var integer
 */
define('QUESTION_PREVIEW_MAX_VARIANTS', 100);
// Get and validate question id.
$def_config = get_config('filter_simplequestion');
$key = $def_config->key;

// Get and decrypt question id (note, encrypted to text).
$enid = required_param('id', PARAM_TEXT);
$id = (int) \filter_simplequestion\utility\tools::decrypt($enid, $key);

$question = question_bank::load_question($id);
$courseid = required_param('courseid', PARAM_INT);
require_login($courseid);
$context = context_course::instance($courseid);

// Collect any module information so we can return there
$modname = optional_param('modname', 'none', PARAM_TEXT);
$cmid = optional_param('cmid', 0, PARAM_INT);

// get the display opption to popup or embed
// (for the controls below the question)
$popup = required_param('popup', PARAM_TEXT);

$PAGE->set_context($context);
$renderer = $PAGE->get_renderer('filter_simplequestion');

// Get and validate display options.
$maxvariant = min($question->get_num_variants(), QUESTION_PREVIEW_MAX_VARIANTS);
$options = new question_preview_options($question);
$options->behaviour = 'immediatefeedback';
$page_url = \filter_simplequestion\urls::preview_url($enid, $popup,
            $options->behaviour, $options->maxmark,
            $options, $options->variant, $courseid);
$PAGE->set_url($page_url);

// Get and validate existing preview, or start a new one.
$previewid = optional_param('previewid', 0, PARAM_INT);

if ($previewid) {
    try {
        $quba = question_engine::load_questions_usage_by_activity($previewid);

    } catch (Exception $e) {
        // This may not seem like the right error message to display, but
        // actually from the user point of view, it makes sense.
        print_error('friendlymessage', 'filter_simplequestion',
                preview_url($enid, $options->behaviour,
                $options->maxmark, $options, $options->variant, $courseid), null, $e);
    }

    $slot = $quba->get_first_question_number();
    $usedquestion = $quba->get_question($slot);
    if ($usedquestion->id != $question->id) {
        print_error('questionidmismatch', 'filter_simplequestion');
    }
    $question = $usedquestion;
    $options->variant = $quba->get_variant($slot);

} else {

    $quba = question_engine::make_questions_usage_by_activity(
            'filter_simplequestion', $context);

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

// Prepare a URL that is used in various places.
$actionurl = \filter_simplequestion\urls::preview_action_url(
                 $enid, $popup, $quba->get_id(), $options, $courseid, $cmid, $modname);

// Process check button action
if (data_submitted() && confirm_sesskey()) {
    try {

        $quba->process_all_actions();
        $quba->finish_all_questions();

        $transaction = $DB->start_delegated_transaction();
        question_engine::save_questions_usage_by_activity($quba);
        $transaction->allow_commit();
 
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

// Start output.
$renderer->display_question($actionurl, $quba, $slot, $question, $options);

$renderer->display_controls($popup);