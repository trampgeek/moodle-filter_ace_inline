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
 * Moodle Ace inline content filter.
 *
 * @package    filter_ace_inline
 * @copyright  2021 Richard Lobb
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

namespace filter_ace_inline;

use core\context;

if (class_exists('\core_filters\text_filter')) {
    class_alias('\core_filters\text_filter', 'filter_ace_inline_base_text_filter');
} else {
    class_alias('\moodle_text_filter', 'filter_ace_inline_base_text_filter');
}

/**
 *
 */
class text_filter extends \filter_ace_inline_base_text_filter {
    /**
     * @var moodle_page page object.
     */
    protected $page;
    /**
     * @var context The context we are in.
     */
    protected $context;
    /**
     * @var array Any options for this filter in this context.
     */
    protected $options;
    /**
     * @var array|null Cached return value of get_effective_config(), memoised since the
     * filter's context is fixed for the life of the instance (see setup()).
     */
    protected $effectiveconfig = null;

    /**
     * This function is called by the filter system to setup the filter.
     *
     * @param \moodle_page $page The page we are going to add requirements to.
     * @param context $context The context which contents are going to be filtered.
     * @return void
     */
    public function setup($page, $context) {
        $this->page = $page;
        $this->context = $context;
        \qtype_coderunner_util::load_ace();
    }

    /**
     * This function is called by the filter system to filter the text.
     *
     * @param string $text The text to filter.
     * @param array $options The filter options.
     * @return string The filtered text.
     * @throws \dml_exception
     */
    public function filter($text, array $options = []) {
        $this->options = $options;
        // Basic test to avoid work.
        if (!is_string($text)) {
            // Non-string content can not be filtered anyway.
            return $text;
        }
        $this->do_ace_editor($text, $this->get_effective_config());
        return $text;
    }

    /**
     * Works out the effective settings for the current context, by looking for a
     * local override (settable via the filter's "Settings" link on a context's
     * Filters management page, e.g. a course) at the current context or the nearest
     * ancestor context that has one, falling back to the site administrator's
     * setting for anything not overridden anywhere in the context chain.
     *
     * Local filter config (unlike the filter's on/off state) is not inherited by
     * Moodle core, so without this a course-level override would only apply to
     * content filtered directly in that exact course context, and not to content
     * inside activities within the course (which are filtered in their own,
     * separate, module context nested below it).
     *
     * Memoised in $this->effectiveconfig, since filter() can be called many times per page
     * (once per piece of content - e.g. once per forum post) and both the context chain walk
     * and each filter_get_local_config() call are real work: the latter is an uncached
     * get_records_menu, so on a page with many posts and a deep context chain, re-running this
     * per call adds up to a lot of avoidable queries for a value that cannot change within the
     * lifetime of this filter instance.
     *
     * @return array The effective 'button_label', 'dark_theme_mode' and 'simplified_mode' settings.
     */
    protected function get_effective_config() {
        if ($this->effectiveconfig !== null) {
            return $this->effectiveconfig;
        }
        $names = ['button_label', 'dark_theme_mode', 'simplified_mode'];
        $config = [];
        for ($context = $this->context; $context; $context = $context->get_parent_context()) {
            $local = filter_get_local_config('ace_inline', $context->id);
            foreach ($names as $name) {
                if (!array_key_exists($name, $config) && array_key_exists($name, $local)) {
                    $config[$name] = $local[$name];
                }
            }
            if (count($config) === count($names)) {
                break;
            }
        }
        foreach ($names as $name) {
            if (!array_key_exists($name, $config)) {
                $config[$name] = get_config('filter_ace_inline', $name);
            }
        }
        $this->effectiveconfig = $config;
        return $this->effectiveconfig;
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
    public function do_ace_editor($text, $config) {
        $hasexplicitmarker = strpos($text, 'ace-interactive-code') !== false
            || strpos($text, 'ace-highlight-code') !== false;
        // The bare '<code' check only applies under simplified mode - without it, this would
        // queue the AMD module on almost every page on most sites, for no reason, since nearly
        // all rendered content contains a <code> element somewhere.
        $hassimplifiedcode = $config['simplified_mode'] == 1 && strpos($text, '<code') !== false;
        if ($hasexplicitmarker || $hassimplifiedcode) {
            $this->page->requires->js_call_amd(
                'filter_ace_inline/ace_inline_code',
                'initAceInlineEditor',
                [$config]
            );
        }

        return $text;
    }
}
