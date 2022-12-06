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
 * Ace inline filter for displaying and possibly editing and running code.
 *
 * @package    filter_ace_inline
 * @copyright  2021 Richard Lobb
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

require_once($CFG->dirroot . '/question/type/coderunner/classes/util.php');

/**
 * Class which implements the ace-inline filter.
 * 
 * This filter looks for <pre> elements of class 'ace-highlight-code' or
 * 'ace-interactive-code' in Moodle question text and
 * replaces them an Ace editor panel to allow display and (for ace-interactive-code)
 * editing and execution, of program code.
 */
class filter_ace_inline extends moodle_text_filter {

    /*
     * Add the javascript to load the Ace editor.
     *
     * @param moodle_page $page The current page.
     * @param context $context The current context.
     */
    public function setup($page, $context) {
        qtype_coderunner_util::load_ace();
    }

    /**
     * This function does the appropriate replacement of the <pre> elements
     * with the Ace editor and (for ace-interactive) Try it! button.
     * Only text within Moodle questions (usually but not necessarily description
     * questions) is subject to replacement.
     * @param {string} $text to be processed
     * @return {string} text after processing
     */
    public function filter($text, array $options = array()) {
        // Basic test to avoid work.
        if (!is_string($text)) {
            // Non-string content can not be filtered anyway.
            return $text;
        }
        $config = array(
            'button_label' => get_config('filter_ace_inline', 'button_label'),
            'dark_theme_mode' => get_config('filter_ace_inline', 'dark_theme_mode')
        );
        $this->do_ace_highlight($text, $config);
        $this->do_ace_interactive($text, $config);
        return $text;
    }

    /**
     * Process the given text by replacing any <pre> elements of class
     * ace-highlight-code with an ace code high-lighted version.
     * The actual work is done by JavaScript; this function just calls the
     * appropriate function. The call to strpos is required regardless becuase
     * apparently Mathjax generates a small content fragment, which is passed
     * through all filters, on all content pages, even editing pages. We
     * don't wish to use our filter on pages being edited.
     * @param {string} $text The text to be processed.
     * @param {array} $config The plugin configuration info.
     * @return {string} The processed text.
     */
    public function do_ace_highlight($text, $config) {
        global $PAGE;
        if (strpos($text, 'ace-highlight-code') !== false) {
            $PAGE->requires->js_call_amd('filter_ace_inline/ace_inline_code',
                    'initAceHighlighting', array($config));
        }

        return $text;
    }

    /**
     * Process the given text by replacing any <pre> elements of class
     * ace-interactive-code with an ace editor plus a Try it! button.
     * The call to strpos is required regardless becuase
     * apparently Mathjax generates a small content fragment, which is passed
     * through all filters, on all content pages, even editing pages. We
     * don't wish to use our filter on pages being edited.
     * @param {string} $text The text to be processed.
     * @param {array} $config The plugin configuration info.
     * @return {string} The processed text
     */
    public function do_ace_interactive($text, $config) {
        global $PAGE, $COURSE;
        if (strpos($text, 'ace-interactive-code') !== false) {
            $PAGE->requires->js_call_amd('filter_ace_inline/ace_inline_code',
                    'initAceInteractive', array($config));
        }
        return $text;
    }
}
