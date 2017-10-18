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

function get_preview_url($questionid, $courseid) {
    $params = array('id' => $questionid, 'courseid'=>$courseid);
    return new moodle_url('/filter/simplequestion/preview.php', $params);
}

function preview_action_url($questionid, $qubaid,
        question_preview_options $options, $courseid) {
    $params = array(
        'id' => $questionid,
        'courseid' => $courseid,
        'previewid' => $qubaid
    );
    
    $params = array_merge($params, $options->get_url_params());
    return new moodle_url('/filter/simplequestion/preview.php', $params);
}

function preview_form_url($questionid, $courseid, $previewid = null) {
    $params = array(
        'id' => $questionid,
        'courseid' => $courseid,
    );
    if ($previewid) {
        $params['previewid'] = $previewid;
    }
    return new moodle_url('/filter/simplequestion/preview.php', $params);
}
