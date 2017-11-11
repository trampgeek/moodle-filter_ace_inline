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
 * Functions for inserting and displaying questions
 * @package    filter
 * @subpackage simplequestion
 * @copyright  2017 Richard Jones (https://richardnz.net/)
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

/**
 * Custom renderer class for filter_simplequestion
 * @copyright  2017 Richard Jones (https://richardnz.net/)
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */
class filter_simplequestion_renderer extends plugin_renderer_base {
    /**
     * This function returns a question preview page link
     * @param int $number the question id
     * @param string $linktext the text for the returned link
     * @param string $popup whether the question is embedded
     *        or displayed in a popup window
     * @param int $courseid the id of the course the question is in
     * @return string the html required to display the question
     */
    public function get_question($number, $linktext, $popup, $courseid) {
        global $CFG;

        $url = '/filter/simplequestion/preview.php';

        // Check if I'm inside a module to set context
        // Am I displaying in a popup or embedded?
        if ($this->page->cm) {
            $modname = $this->page->cm->modname;
            $cmid = $this->page->cm->id;
            $link = new moodle_url($url, array('id' => $number, 'courseid' => $courseid,
                    'popup' => $popup, 'modname' => $modname, 'cmid' => $cmid));
        } else {

            $link = new moodle_url($url, array('id' => $number, 'courseid' => $courseid,
                    'popup' => $popup));
        }

        // Check for link text
        if ($linktext === '') {
            $linktext = get_string('link_text', 'filter_simplequestion');
        }

        // Check for popup or embed
        if ($popup === 'popup') {
            // Show the preview page
            return $this->output->action_link($link, $linktext,
                    new popup_action('click', $link));
        } else {
            // embed the question right here
            return $this->embed_question($number, $link, $linktext);
        }
    }
    /**
     * This function returns the html to display an error message
     * @param string $text the error message
     * @return string the html required to display the message
     */
    public function get_error($text) {
        $html = html_writer::start_tag('div',
                array('class' => 'filter_simplequestion_error'));
        $html .= $text;
        $html .= html_writer::end_tag('div');
        return $html;
    }
    /**
     * This function returns the html to embed a question in a sliding panel
     * @param string $number the encoded question id number
     * @param string $link the url of the page to display
     * @param string $linktext the text of the link
     * @return string the html required to embed the question
     */
    public function embed_question($number, $link, $linktext) {

        // Get the iFrame size from config
        $def_config = get_config('filter_simplequestion');
        $height = $def_config->height;
        $width = $def_config->width;

        $html = '';
        $html .= html_writer::start_tag('div',
              array('class' => 'filter_simplequestion_container'));

        $target = '#' . $number; // id of the collabsible div
        $attributes = array('href' => $target, 'data-toggle' => 'collapse');
        $html .= html_writer::start_tag('a', $attributes);
        $html .= $linktext;
        $html .= html_writer::end_tag('a');
     
        // The collabsible div - toggles on link being clicked
        $div_array = array('id' => $number, 'class' => 'collapse');
        $html .= html_writer::start_tag('div', $div_array);

        // the question preview page is embedded here
        $attributes = array('height' => $height, 'width' => $width, 'src' => $link);
        $html .= html_writer::start_tag('iframe', $attributes);
        $html .= html_writer::end_tag('iframe');
        $html .= html_writer::end_tag('div');
        $html .= html_writer::end_tag('div');

        return $html;
    }
    /**
     * This function shows the form which displays and processes the question
     * Extracted from preview.php to here
     * @param string $actionurl the url to process the form
     * @param quba $quba the question usage by activity instance
     * @param int $slot the usage slot the question is in
     * @param question $question the question instance
     * @param array $options the display options for the question
     */
    public function display_question($actionurl, $quba, $slot, $question, $options) {
        // Heading info
        $title = get_string('previewquestion', 'filter_simplequestion',
                format_string($question->name));
        $this->page->set_heading($title);
        echo $this->output->header();

        // Start the simplified question form.
        echo html_writer::start_tag('form', array('method' => 'post',
                  'action' => $actionurl, 'enctype' => 'multipart/form-data',
                  'id' => 'responseform'));
        echo html_writer::start_tag('div');
        echo html_writer::empty_tag('input', array('type' => 'hidden',
                'name' => 'sesskey', 'value' => sesskey()));
        echo html_writer::empty_tag('input', array('type' => 'hidden',
                'name' => 'slots', 'value' => $slot));
        echo html_writer::end_tag('div');

        // Output the question.
        echo $quba->render_question($slot, $options);

        echo html_writer::end_tag('form');
    }
    /**
     * This function return the html required to display controls for
     * exiting back to course or module the form which displays and processes the question
     * @param string $popup whether the question is embedded or in popup
     * @return string the html required to display the controls
     */
    public function display_controls($popup) {
 
        // Add controls for exiting back to course or module
        echo html_writer::start_tag('div',
                array('class' => 'filter_simplequestion_controls'));

        // for popup close the window message
        if ($popup === 'popup') {
            // Todo: add a button to close the window
            echo get_string('use_close', 'filter_simplequestion');
  
        } else {
            // for embedded click link to close panel
            echo get_string('click_link', 'filter_simplequestion');
        }

        echo html_writer::end_tag('div');
    }
}