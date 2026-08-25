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
        $this->effectiveconfig = self::resolve_effective_config(
            $this->context,
            ['button_label', 'dark_theme_mode', 'simplified_mode']
        );
        return $this->effectiveconfig;
    }

    /**
     * Core context-chain-walking logic behind get_effective_config(), extracted as a public
     * static method (rather than kept private to get_effective_config()) so the local-settings
     * form (see filterlocalsettings.php) can also use it to show what a context would inherit
     * from ABOVE it - i.e. this same walk, but started one level higher, at
     * $context->get_parent_context(), so the context being edited's own (possibly unsaved)
     * override is never what gets reported as "the higher-level setting".
     *
     * @param \core\context|false|null $context Starting context (inclusive) to search from, or
     *     a falsy value to skip straight to the site administrator's settings -
     *     context::get_parent_context() itself returns false once it reaches the system
     *     context, so passing that straight back in here (as the local-settings form does when
     *     the context being edited already IS the system context) bottoms out correctly with no
     *     special-casing needed by the caller.
     * @param string[] $names Setting names to resolve (a subset of 'button_label',
     *     'dark_theme_mode', 'simplified_mode').
     * @return array Effective value for each of $names.
     */
    public static function resolve_effective_config($context, array $names) {
        $config = [];
        for (; $context; $context = $context->get_parent_context()) {
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
        return $config;
    }

    /**
     * Process the given text by replacing any <pre> elements of class
     * ace-highlight-code with an ace code high-lighted version.
     * The actual work is done by JavaScript; this function just calls the
     * appropriate function. The call to strpos is required regardless becuase
     * apparently Mathjax generates a small content fragment, which is passed
     * through all filters, on all content pages, even editing pages. We
     * don't wish to use our filter on pages being edited.
     * @param string $text The text to be processed.
     * @param array $config The plugin configuration info.
     * @return string The processed text.
     */
    public function do_ace_editor($text, $config) {
        $hasexplicitmarker = strpos($text, 'ace-interactive-code') !== false
            || strpos($text, 'ace-highlight-code') !== false;
        // Simplified Mode has no attribute of its own to opt in with - its only signal is a class
        // on an otherwise-ordinary <pre>/<code> - so this stays deliberately permissive rather
        // than trying to validate the class is a real language name (that's the JS's job; see
        // isSimplifiedClassMode() in apply_ace_editor.js - duplicating Ace's own mode list here
        // would mean keeping a second copy in sync with whatever Ace version CodeRunner ships).
        // It must stay a superset of what the JS actually accepts: every genuine Simplified Mode
        // authoring path (this plugin's own generators, TinyMCE, Markdown Extra) always produces
        // a full <pre><code>...</code></pre> pair with the class on one of the two tags, so the
        // three checks below - both tags present, at least one carrying a class - can never
        // reject anything the JS (isSimplifiedClassMode()'s own hasPreCodePair() check) would
        // have accepted. The two strpos() calls are cheap and short-circuit before the regex ever
        // runs, which also keeps this fast on the common case of a page with neither tag at all.
        $hassimplifiedcode = $config['simplified_mode'] == 1
            && strpos($text, '<pre') !== false
            && strpos($text, '<code') !== false
            && preg_match('/<(?:pre|code)\b[^>]*\bclass\s*=/i', $text) === 1;
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
