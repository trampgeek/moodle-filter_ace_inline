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
 * Timing for the filter_simplequestion cron task
 *
 * @package    filter
 * @subpackage simplequestion
 * @copyright  2017 Richard Jones (https://richardnz.net)
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 * 
 */
$tasks = array(
  // If I have this right, run every other day at 02:21 AM
  // Admins can run any time and adjust via task scheduler
  // The cron will delete simplequestion records when the table gets large  
  array('classname' => 'filter_simplequestion\task\simplequestion_cron',
        'blocking' => 0,      
        'minute' => '21',
        'hour' => '2',
        'day' => '*/2',
        'dayofweek' => '*',
        'month' => '*'
    )
);