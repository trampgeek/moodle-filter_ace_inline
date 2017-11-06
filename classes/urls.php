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
 * From previewlib.php and re-written for this filter
 *
 * @package    moodlecore
 * @subpackage questionengine
 * @copyright  2010 The Open University
 * Modified for use in filter_simplequestion by Richard Jones http://richardnz/net
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

namespace filter_simplequestion;

use moodle_url;
use question_preview_options;

defined('MOODLE_INTERNAL') || die();

// require_once($CFG->libdir . '/weblib.php');

class urls  {

  /**
   * The the URL to use for actions relating to this preview.
   * @param int $enid the encrypted id of the question being previewed.
   * @param int $qubaid the id of the question usage for this preview.
   * @param question_preview_options $options the options in use.
   * @param int $courseid, the id of the course that wants this url.
   */
  
  public static function preview_action_url($enid, $qubaid,
        question_preview_options $options, $courseid, $cmid, $modname) {
    $params = array(
        'id' => $enid,
        'previewid' => $qubaid,
        'courseid' => $courseid,
        'cmid' => $cmid,
        'modname' =>$modname
    );
    $params = array_merge($params, $options->get_url_params());
    return new moodle_url('/filter/simplequestion/preview.php', $params);
  }
  
  public static function preview_embed_url($page_url, $enid, $qubaid,
        question_preview_options $options, $courseid, $cmid, $modname) {
    $params = array(
        'id' => $enid,
        'previewid' => $qubaid,
        'courseid' => $courseid,
        'cmid' => $cmid,
        'modname' =>$modname
    );
    $params = array_merge($params, $options->get_url_params());
    return new moodle_url($page_url, $params);
  }


  /**
   * Generate the URL for starting a new preview of a given question with the given options.
   * @param integer $questionid the question to preview.
   * @param string $preferredbehaviour the behaviour to use for the preview.
   * @param float $maxmark the maximum to mark the question out of.
   * @param question_display_options $displayoptions the display options to use.
   * @param int $variant the variant of the question to preview. If null, one will
   *      be picked randomly.
   * @param object $context context to run the preview in (affects things like
   *      filter settings, theme, lang, etc.) Defaults to $PAGE->context.
   * @return moodle_url the URL.
   */
  
  public static function preview_url($enid, $preferredbehaviour = null,
        $maxmark = null, $displayoptions = null, $variant = null, $courseid) {

    $params = array('id' => $enid, 'courseid' => $courseid);

    if (!is_null($preferredbehaviour)) {
        $params['behaviour'] = $preferredbehaviour;
    }

    if (!is_null($maxmark)) {
        $params['maxmark'] = $maxmark;
    }

    if (!is_null($displayoptions)) {
        $params['correctness']     = $displayoptions->correctness;
        $params['marks']           = $displayoptions->marks;
        $params['markdp']          = $displayoptions->markdp;
        $params['feedback']        = (bool) $displayoptions->feedback;
        $params['generalfeedback'] = (bool) $displayoptions->generalfeedback;
        $params['rightanswer']     = (bool) $displayoptions->rightanswer;
        //$params['history']         = (bool) $displayoptions->history;
    }

    if ($variant) {
        $params['variant'] = $variant;
    }

    return new moodle_url('/filter/simplequestion/preview.php', $params);
  }
}