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
 * Library functions used by question/preview.php. 
 * From previewlib.php and re-written for this filter
 *
 * @package    filter
 * @subpackage simplequestion
 * @copyright  2010 The Open University
 * Modified for use in filter_simplequestion by Richard Jones http://richardnz/net
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */
namespace filter_simplequestion;
defined('MOODLE_INTERNAL') || die();
/** 
 * Control question display options
 */
class displayoptions  {
    /** 
     * Set the display options for a question
     * @param int $maxvariant The maximum number of variants previewable.
     * @return array $options the display options
     */
    public static function get_options($maxvariant) {

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
        }  else {
            $options->variant = rand(1, $maxvariant);
        } 
        return $options;
    }
}