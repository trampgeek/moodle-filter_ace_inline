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
 * @package    filter_ace_inline
 * @subpackage ace_inline
 * @copyright  2017 Richard Jones
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

if ($ADMIN->fulltree) {
    // Default values for filter.php.
    $buttonlabel = get_string('default_button_label', 'filter_ace_inline');

    // Language strings.
    $heading = get_string('settings_heading', 'filter_ace_inline');
    $description = get_string('settings_desc', 'filter_ace_inline');

    $settings->add(new admin_setting_heading('ace_inlinesettings',
            $heading, $description));

    $darkoptions = [
        0 => get_string('settings_dark_never', 'filter_ace_inline'),
        1 => get_string('settings_dark_preference', 'filter_ace_inline'),
        2 => get_string('settings_dark_always', 'filter_ace_inline')];

    $settings->add(new admin_setting_configselect(
        "filter_ace_inline/dark_theme_mode",
        get_string('settings_dark_theme', 'filter_ace_inline'),
        get_string('settings_dark_theme_desc', 'filter_ace_inline'),
        0, $darkoptions));

    $settings->add(new admin_setting_configtext('filter_ace_inline/button_label',
            get_string('settings_button_label', 'filter_ace_inline'),
            get_string('settings_button_label_desc', 'filter_ace_inline'),
            $buttonlabel, PARAM_TEXT));
}
