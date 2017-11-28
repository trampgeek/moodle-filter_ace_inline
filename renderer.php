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
 * Functions for inserting and displaying content
 * @package    filter
 * @subpackage simplemodal
 * @copyright  2017 Richard Jones (https://richardnz.net/)
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

/**
 * Custom renderer class for filter_simplemodal
 * @copyright  2017 Richard Jones (https://richardnz.net/)
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */
class filter_simplemodal_renderer extends plugin_renderer_base {
    /**
     * This function returns content
     * @param string $linktext the text for the returned link
     * @return string the html required to display the content
     */
    public function get_content($content) {
        $this->page->requires->js_call_amd('filter_simplemodal/show_content', 
                'init', array($content));
        $button = html_writer::tag('button', 
                get_string('button_label','filter_simplemodal'));
        return html_writer::div($button,'filter_simplemodal_content');
    }
}