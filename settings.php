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
 * filter ace_inline admin settings and defaults
 *
 * @package    filter
 * @subpackage ace_inline
 * @copyright  2017 Richard Jones (@link https://richardnz.net/)
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die;

if ($ADMIN->fulltree) {

    // default values for filter.php
    $BUTTON_LABEL = get_string('default_button_label', 'filter_ace_inline');

    // language strings
    $heading = get_string('settings_heading', 'filter_ace_inline');
    $description = get_string('settings_desc', 'filter_ace_inline');

    $settings->add(new admin_setting_heading('ace_inlinesettings',
            $heading, $description));


    $settings->add(new admin_setting_configtext('filter_ace_inline/button_label',
            get_string('settings_button_label', 'filter_ace_inline'),
            get_string('settings_button_label_desc', 'filter_ace_inline'),
            $BUTTON_LABEL, PARAM_TEXT));
}