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
 * filter simplequestion admin settings and defaults
 *
 * @package    filter
 * @subpackage simplequestion
 * @copyright  2017 Richard Jones (@link https://richardnz.net/)
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die;

if ($ADMIN->fulltree) {

    // default values for filter.php
    $START_TAG = '{{QUESTION:';
    $END_TAG = '}}';
    $LINKTEXTLIMIT = 40;  
    $KEY = 'this is my secret key';
    $HEIGHT = 600;
    $WIDTH = 450;

    // language strings
    $heading = get_string('settings_heading', 'filter_simplequestion');
    $description = get_string('settings_desc', 'filter_simplequestion');

    $settings->add(new admin_setting_heading('simplequestionsettings', 
            $heading, $description));

    // Start and end tags - disabled until ATTO button can handle them too
    
    $settings->add(new admin_setting_configtext('filter_simplequestion/starttag',
            get_string('settings_start_tag', 'filter_simplequestion'),
            get_string('settings_start_tag_desc', 'filter_simplequestion'),
            $START_TAG, PARAM_TEXT));
    
    $settings->add(new admin_setting_configtext('filter_simplequestion/endtag',
            get_string('settings_end_tag', 'filter_simplequestion'),
            get_string('settings_end_tag_desc', 'filter_simplequestion'), 
            $END_TAG, PARAM_TEXT));
    
    // Maximum length of text link
    $settings->add(new admin_setting_configtext('filter_simplequestion/linklimit',
            get_string('settings_linklimit', 'filter_simplequestion'),
            get_string('settings_linklimit_desc', 'filter_simplequestion'), 
            $LINKTEXTLIMIT, PARAM_INT));

    $settings->add(new admin_setting_configtext('filter_simplequestion/key',
            get_string('settings_key', 'filter_simplequestion'),
            get_string('settings_key_desc', 'filter_simplequestion'), 
            $KEY, PARAM_RAW));

    $options = array(0 => get_string('embed', 'filter_simplequestion'), 
                     1 => get_string('popup', 'filter_simplequestion'));

    $settings->add(new admin_setting_configselect('filter_simplequestion/displaymode',
            get_string('settings_displaymode', 'filter_simplequestion'),
            get_string('settings_displaymode_desc', 'filter_simplequestion'), 
            0, $options));

    $settings->add(new admin_setting_configtext('filter_simplequestion/height',
            get_string('settings_height', 'filter_simplequestion'),
            get_string('settings_height_desc', 'filter_simplequestion'), 
            $HEIGHT, PARAM_INT));
    
    $settings->add(new admin_setting_configtext('filter_simplequestion/width',
            get_string('settings_width', 'filter_simplequestion'),
            get_string('settings_width_desc', 'filter_simplequestion'), 
            $WIDTH, PARAM_INT));
}