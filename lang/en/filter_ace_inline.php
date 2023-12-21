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
 * Strings for component 'filter_ace_inline', language 'en'
 *
 * @package    filter_ace_inline
 * @copyright  Richard Jones, Michelle Hsieh 2017, 2022
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

$string['filtername'] = 'Ace inline';

// Settings strings.
$string['pluginname'] = 'Filter ace inline';
$string['default_button_label'] = 'Try it!';
$string['settings_button_label'] = 'Button label';
$string['settings_button_label_desc'] = 'The label for the "Try it!" button that
    the user clicks to run the code';
$string['settings_dark_always'] = 'Always';
$string['settings_dark_never'] = 'Never';
$string['settings_dark_preference'] = 'When OS or browser prefers dark';
$string['settings_dark_theme'] = 'Set when to use dark theme';
$string['settings_dark_theme_desc'] = 'Select when to use a dark theme for Ace
instead of the default light theme. Can be overridden by an individual instance.
\'sometimes\' behaves according to the browser\'s response to the \'prefers-color-scheme:dark\' media query.';
$string['settings_desc'] = 'Change the settings for this filter.';
$string['settings_heading'] = 'Ace inline filter settings';

// Error strings.
$string['error_access_denied'] = 'Sandbox server access denied';
$string['error_element_unknown'] = 'Id not found for element';
$string['error_excessive_output'] = 'Excessive output';
$string['error_file_read'] = 'File not uploaded';
$string['error_json_params'] = 'Params set are not in correct JSON format';
$string['error_jobe_unknown'] = 'Unknown error from Jobe server';
$string['error_memory_limit'] = 'Memory limit exceeded';
$string['error_sandbox_server_overload'] = 'Jobe server overload';
$string['error_script_unknown'] = 'Mapped function was not found on page';
$string['error_submission_limit_reached'] = 'Jobe sandbox submission limit reached';
$string['error_timeout'] = 'Time limit exceeded';
$string['error_unknown_language'] = 'Unknown language requested';
$string['error_unknown_runtime'] = 'Unknown runtime error';
$string['error_user_params'] = 'User Config Error';

// File handling strings.
$string['file_changed_name'] = 'The following filenames have been changed for sandbox execution:';
$string['file_not_uploaded'] = 'The following files have not been uploaded (max 2MB size):';

// Privacy metadata.
$string['privacy:metadata'] = 'The Ace-inline-filter is applied onto HTML and does not store any data.';
