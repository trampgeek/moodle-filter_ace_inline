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
 * Basic email protection filter.
 *
 * @package    filter
 * @subpackage simplequestion
 * @copyright  2017 Richard Jones (https://richardnz.net)
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 * 
 */

defined('MOODLE_INTERNAL') || die();
/**
 * This class looks for question tags in Moodle text and
 * replaces them with questions from the question bank.
 * Tags have the format {QUESTION:link text|xxx} where
 *                               link text is the text that links to the question 
 *                               xxx is the id of a question
 * from the bank in the current course.
 */
class filter_simplequestion extends moodle_text_filter {

  function filter($text, array $options = array()) {
  global $PAGE;
  // Might need to change these at some point - eg to double curlies
  $START_TAG = '{QUESTION:';
  $END_TAG = '}';
  $LINKTEXTLIMIT = 20;  // Don't allow too many chars in a link for safety

  $renderer = $PAGE->get_renderer('filter_simplequestion');

    // Basic tests to avoid work
    if (!is_string($text)) {
      // non string data can not be filtered anyway
      return $text;
    }
    if (strpos($text, '{') === false) {
      // Do a quick check to see if we have curlies
      return $text;
    }

    // There may be a question or questions in here somewhere so continue ...
    // Get the question numbers and positions in the text and call the
    // renderer to deal with them
    $text = filter_simplequestion_insert_questions($text, $START_TAG, $END_TAG, $LINKTEXTLIMIT, $renderer);   

    return $text;
  }

}
/**
*
* function to replace question filter text with actual question
*
* params:  string containing patterns, pattern start, pattern end, renderer
*/
function filter_simplequestion_insert_questions($str, $needle, $limit, $linktextlimit, $renderer) {
  
  $newstring = $str;
  While (strpos($newstring, $needle) !== false) {
    $initpos = strpos($newstring, $needle);
    if ($initpos !== false) {
       $pos = $initpos + strlen($needle);  //get up to string
       $endpos = strpos($newstring, $limit);
       $data = substr($newstring, $pos, $endpos - $pos); // extract question data
       
       // get the link text
       $endlinkpos = strpos($data, '|');
       $linktext = substr($data, 0, $endlinkpos);
       
       // get the question number
       $number = substr($data, $endlinkpos + 1, $endpos - $endlinkpos);
       
       // Run some checks (are these sufficient?)
       $linktext = filter_var($linktext, FILTER_SANITIZE_STRING);
       
       if (!filter_var($number, FILTER_VALIDATE_INT) === false) {
        
       $linktext = filter_var($linktext, FILTER_SANITIZE_STRING);
         if (strlen($linktext) > $linktextlimit) {
            $linktext = "Link to question";
         }
         // Render the question link
         $question = $renderer->get_question($number, $linktext);
       } else {

        $question = " {Please check your data} "; 
       }
       
       // Update the text to replace the filtered string
       $newstring = substr_replace($newstring, $question, $initpos, $endpos - $initpos + 1);
       $initpos = $endpos + 1;
    }
  }
  return $newstring;
}