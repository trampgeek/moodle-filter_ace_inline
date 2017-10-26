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
 *
 * @package    moodlecore
 * @subpackage questionengine
 * @copyright  2010 The Open University
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 *
 * Modified for use in filter_simplequestion by Richard Jones {@link https://richardnz.net}
 */
namespace filter_simplequestion\task;

 /**
 * Scheduled tasks relating to filter_simplequestion. Specifically, delete any old
 * question usages that are left over in the database. Runs every other day.
 */

class simplequestion_cron extends \core\task\scheduled_task {

    public function get_name() {
      // Shown in admin screens
      return get_string('clean_up_usages', 'filter_simplequestion');
    }

    public function execute() {
      global $DB;
      // We delete simplequestion previews periodically via cron. 
      // They don't contain anything of value as we are not tracking responses
      $component = 'filter_simplequestion';
      $behaviour = 'immediatefeedback';

      $count = $DB->count_records('question_usages', 
                     array('component'=>$component, 'preferredbehaviour'=>$behaviour));
      
      if ($count > 100) {
        $DB->delete_records('question_usages', 
                     array('component'=>$component, 'preferredbehaviour'=>$behaviour));
      }
      return true;
  }
}
