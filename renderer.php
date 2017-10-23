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
    // What's the most sensible thing to do here?
    // I'm thinking return a popup link to preview.php
    // Todo: look at this: https://moodle.org/mod/forum/discuss.php?d=332254

    $url = '/filter/simplequestion/preview.php'; 

    // Now the question number will be visible within the link, do we care?
    // Not for the simplequestion version anyway
    $link = new moodle_url($url, array('id'=>$number, 'courseid'=>$courseid));
    
    // Check for link text
    if ($linktext === '') { $linktext = get_string('link_text', 'filter_simplequestion'); }
    
    // Todo: Add an option to have the link inline or as a popup
    $text = $this->output->action_link($link, $linktext, new popup_action('click', $link)); 
    return $text;
  }
}