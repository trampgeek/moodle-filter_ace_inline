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
 * Version details
 *
 * @package    filter
 * @subpackage simplequestion
 * @copyright  Muhammad Ali: https://stackoverflow.com/users/1418637/muhammad-ali
 * @license    https://creativecommons.org/licenses/by-sa/3.0/
 *
 */
defined('MOODLE_INTERNAL') || die();

// https://stackoverflow.com/questions/24350891/how-to-encrypt-decrypt-an-integer-in-php 

function filter_simplequestion_decrypt($string, $key) {
  $result = '';
  $string = base64_decode($string);
  for($i=0; $i<strlen($string); $i++) {
    $char = substr($string, $i, 1);
    $keychar = substr($key, ($i % strlen($key))-1, 1);
    $char = chr(ord($char)-ord($keychar));
    $result.=$char;
  }
  return $result;
}

function filter_simplequestion_encrypt($string, $key) {
  $result = '';
  for($i=0; $i<strlen($string); $i++) {
    $char = substr($string, $i, 1);
    $keychar = substr($key, ($i % strlen($key))-1, 1);
    $char = chr(ord($char)+ord($keychar));
    $result.=$char;
  }
return base64_encode($result);
}

/**
 * Library functions used by question/preview.php. 
 * From previewlib.php and re-written for this filter
 *
 * @package    moodlecore
 * @subpackage questionengine
 * @copyright  2010 The Open University
 * Modified for use in filter_simplequestion by Richard Jones http://richardnz/net
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

function get_display_options($maxvariant) {

  $options = array();
  // Question options - note just 1 question in the attempt
  $options = new question_display_options();
  $options->marks = question_display_options::MAX_ONLY;
  $options->markdp = 0; // Display marks to 2 decimal places.
  $options->feedback = 'immediatefeedback';
  $options->generalfeedback = question_display_options::HIDDEN;
  $options->variant = $maxvariant;
  if ($options->variant) {
    $options->variant = min($maxvariant, max(1, $options->variant));
  } else {
    $options->variant = rand(1, $maxvariant);
  }
  return $options;
}

/**
 * The the URL to use for actions relating to this preview.
 * @param int $enid the encrypted id of the question being previewed.
 * @param int $qubaid the id of the question usage for this preview.
 * @param question_preview_options $options the options in use.
 */
function preview_action_url($enid, $qubaid,
        question_preview_options $options, $courseid) {
    $params = array(
        'id' => $enid,
        'previewid' => $qubaid,
        'courseid' => $courseid
    );
    $params = array_merge($params, $options->get_url_params());
    return new moodle_url('/filter/simplequestion/preview.php', $params);
}

/**
 * Generate the URL for starting a new preview of a given question with the given options.
 * @param integer $questionid the question to preview.
 * @param string $preferredbehaviour the behaviour to use for the preview.
 * @param float $maxmark the maximum to mark the question out of.
 * @param question_display_options $displayoptions the display options to use.
 * @param int $variant the variant of the question to preview. If null, one will
 *      be picked randomly.
 * @param object $context context to run the preview in (affects things like
 *      filter settings, theme, lang, etc.) Defaults to $PAGE->context.
 * @return moodle_url the URL.
 */
function preview_url($enid, $preferredbehaviour = null,
        $maxmark = null, $displayoptions = null, $variant = null, $courseid) {

    $params = array('id' => $enid, 'courseid' => $courseid);

    if (!is_null($preferredbehaviour)) {
        $params['behaviour'] = $preferredbehaviour;
    }

    if (!is_null($maxmark)) {
        $params['maxmark'] = $maxmark;
    }

    if (!is_null($displayoptions)) {
        $params['correctness']     = $displayoptions->correctness;
        $params['marks']           = $displayoptions->marks;
        $params['markdp']          = $displayoptions->markdp;
        $params['feedback']        = (bool) $displayoptions->feedback;
        $params['generalfeedback'] = (bool) $displayoptions->generalfeedback;
        $params['rightanswer']     = (bool) $displayoptions->rightanswer;
        $params['history']         = (bool) $displayoptions->history;
    }

    if ($variant) {
        $params['variant'] = $variant;
    }

    return new moodle_url('/filter/simplequestion/preview.php', $params);
}
