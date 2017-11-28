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
 * @subpackage simplemodal
 * @copyright  2017 Richard Jones (https://richardnz.net)
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();
/**
 * This filter looks for content tags in Moodle text and
 * replaces them with specified user-defined content.
 * @see filter_manager::apply_filter_chain()
 */
class filter_simplemodal extends moodle_text_filter {
    /**
     * This function looks for tags in Moodle text and
     * replaces them with questions from the question bank.
     * Tags have the format {{CONTENT:xxx}} where:
     *          - xxx is the user specified content
     * @param string $text to be processed by the text
     * @param array $options filter options
     * @return string text after processing
     */
    function filter($text, array $options = array()) {
        global $PAGE;

        // Basic test to avoid work
        if (!is_string($text)) {
            // non string content can not be filtered anyway
            return $text;
        }

        // Admin might need to change these at some point - eg to double curlies,
        // therefore defined in {@link settings.php} with default values
        $def_config = get_config('filter_simplemodal');
        $starttag = $def_config->starttag;
        $endtag = $def_config->endtag;

        // Do a quick check to see if we have a tag
        if (strpos($text, $starttag) === false) {
            return $text;
        }

        $renderer = $PAGE->get_renderer('filter_simplemodal');
        // Check our context and get the course id
        $coursectx = $this->context->get_course_context(false);
        if (!$coursectx) {
            return $text;
        }
        $courseid = $coursectx->instanceid;

        // There may be a tag in here somewhere so continue
        // Get the contents and positions in the text and call the
        // renderer to deal with them
        $text = filter_simplemodal_insert_content($text, $starttag, $endtag, $courseid, $renderer);
        return $text;
    }
}
/**
 *
 * function to replace question filter text with actual question
 *
 * @param string $str text to be processed
 * @param string $starttag start tag pattern to be searched for
 * @param string $endtag end tag for text to replace
 * @param int $courseid id of course text is in
 * @param renderer $renderer - filter renderer
 * @return a replacement text string
 */
function filter_simplemodal_insert_content($str, $starttag, $endtag, $courseid, $renderer) {

    $newstring = $str;
    // While we have the start tag in the text
    while (strpos($newstring, $starttag) !== false) {
        $initpos = strpos($newstring, $starttag);
        if ($initpos !== false) {
            $pos = $initpos + strlen($starttag);  // get up to string
            $endpos = strpos($newstring, $endtag);
            $content = substr($newstring, $pos, $endpos - $pos); // extract content
            // Clean the string
            $content = filter_var($content, FILTER_SANITIZE_STRING);
            $content = $renderer->get_content($content, $courseid);
            // Update the text to replace the filtered string
            $newstring = substr_replace($newstring, $content, $initpos,
                    $endpos - $initpos + strlen($endtag));
            $initpos = $endpos + strlen($endtag);
        }
    }
    return $newstring;
}