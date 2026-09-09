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
 * Behat for ace inline filter
 *
 * @package    filter_ace_inline
 * @copyright  2022 Michelle Hsieh, Richard Lobb, University of Canterbury
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

use Behat\Mink\Exception\ExpectationException;
use Facebook\WebDriver\Exception\NoSuchAlertException;

/**
 * Class designed for behat tests for ace_inline specifically.
 *
 * Contains all the definitions required for ace_inline
 * Behat testing.
 */
class behat_filter_ace_inline extends behat_base {
    /**
     * Enables the ace inline functionality globally and
     * the webserver sandbox to enabled for testing purposes.
     * Reads the configurations from test-sandbox-config.php which
     * is defined by .github/ci.yml when testing on github.
     * Make sure it enables Jobe (jobesandbox_enabled),
     * sets up the jobe host (jobe_host) and enables the
     * webservice (wsenable).
     *
     * @Given I have enabled the sandbox and ace inline filter
     */
    public function the_ace_inline_sandbox_enabled() {
        global $CFG;
        filter_set_global_state('ace_inline', TEXTFILTER_ON, 0);
        require($CFG->dirroot . '/filter/ace_inline/tests/fixtures/test-sandbox-config.php');
    }

    /**
     * Checks if the programming language is correct, else throws an
     * expectation error with message.
     *
     * @Given the programming language is :langstring in filter ace inline
     * @throws ExpectationException The error message.
     * @param string $langstring The expected language string.
     */
    public function program_set_to($langstring) {
        // Assume if python, is default as per settings.
        if (!preg_match("/python/i", $langstring)) {
            $xpath = "//pre[@data-lang='$langstring']";
        } else {
            $xpath = "//pre";
        }
        $error = "Language is not set as $langstring";
        $driver = $this->getSession()->getDriver();
        if (!$driver->find($xpath)) {
            throw new ExpectationException($error, $this->getSession());
        }
    }

    /**
     * Checks if expected word has syntax highlighting. Takes in the
     * type expected and the text expected and searches for the text
     * within a <span> container of the appropriate type.
     *
     * @Then I should see :typeString highlighting on :textString with filter ace inline
     * @throws ExpectationException The error message.
     * @param string $typestring The type of highlighting expected
     * @param string $textstring The expected keyword as a string.
     */
    public function i_should_see_highlighting($typestring, $textstring) {
        // Parse the typeString.
        $acetype = $this->parse_type_string($typestring);

        // Check if there is a <span> holding exactly the expected text, of that class-type.
        // Needs starts-with as C's function tag is particular and boolean flags.
        //
        // The text match is exact rather than a substring. With contains(), an assertion that
        // "int" is a C keyword was also satisfied by Python's "print" in a different block on
        // the same page, so a token could be reported as correctly highlighted when it was not
        // highlighted, or even present, anywhere in the block under test.
        //
        // Quotes and angle brackets are stripped before comparing, because Ace includes a
        // token's delimiters in its span: a string literal is one span reading "text" and an
        // include is one span reading <stdio.h>. Features name the token itself, so those
        // characters have to come off before the comparison. Everything else must match exactly.
        $strippeddelimiters = "translate(text(), concat('\"', \"'\", '<>'), '')";
        $xpath = "//span[starts-with(@class, '$acetype') and normalize-space($strippeddelimiters) = "
            . behat_context_helper::escape($textstring) . "]";
        $error = "'{$textstring}' is not found/formatted as an $acetype";
        $driver = $this->getSession()->getDriver();
        if (!$driver->find($xpath)) {
            if ($acetype == 'error') {
                $error = "'{$typestring}' is not a valid type";
            }
            throw new ExpectationException($error, $this->getSession());
        }
    }

    /**
     * Checks if the starting line is the correct line to start from. Searches
     * the text for the correct active line and gets the number. Assumes ace starts
     * from specified line and line++ per line.
     *
     * @Then I should see lines starting at :number with filter ace inline
     * @param string $number The number expected to be found at the start.
     * @throws ExpectationException The error message.
     */
    public function i_see_lines_starting_at($number) {
        // Changes the number to a quoted number for exact number.
        $quotednumber = "\"{$number}\"";

        // Checks to see if the first line starts with the right number.
        $xpath = "//div[contains(@class, 'ace_gutter-active-line')and text()=$quotednumber]";
        $driver = $this->getSession()->getDriver();
        $error = "Code does not start at line {$quotednumber}";
        if (!$driver->find($xpath)) {
            throw new ExpectationException($error, $this->getSession());
        }
    }

    /**
     * Checks if the font-size is as specified. Takes in a font-size in
     * format "11pt" etc. and checks if the style contains specified font-size.
     *
     * @Then I should see font sized :fontsize with filter ace inline
     * @param string $fontsize The size on the font in format "11pt" etc.
     * @throws ExpectationException The error message.
     */
    public function i_see_font_size($fontsize) {
        // Turn the font size into an appropriate string to search in style.
        $fontstring = "'{$fontsize};'";
        $xpath = "//div[contains(concat(' ', normalize-space(@class), ' '), ' ace_editor ') and contains(@style, $fontstring)]";
        $driver = $this->getSession()->getDriver();
        $error = "Font size is not {$fontsize}";
        if (!$driver->find($xpath)) {
            throw new ExpectationException($error, $this->getSession());
        }
    }

    /**
     * Parses a string input and returns the corresponding acetype identifier
     * for highlight-checking purposes. Identifier is just generic-type
     * span class.
     *
     * @param string $input The string to be parsed.
     * @return string The corresponding acetype identifier.
     */
    private function parse_type_string($input) {
        // A array map of keywords to identifiers.
        $array = [
            "identifier" => "ace_identifier",
            "keyword" => "ace_keyword",
            "string" => "ace_string",
            "include" => "ace_constant ace_other",
            "constant" => "ace_constant ace_language",
            "function" => "ace_support ace_function",
            "type" => "ace_storage ace_type",
            // Deprecated alias for "type". Ace tags C's bool and JavaScript's function with the
            // same token classes as SQL's types, so the name is no longer SQL-specific; kept so
            // any feature file not yet migrated keeps working.
            "sqltype" => "ace_storage ace_type",
        ];

        if (isset($array[$input])) {
            $acetype = $array[$input];
        } else {
            $acetype = "error";
        }
        return ($acetype);
    }

    /**
     * Attaches a file to one of the filter's upload widgets, which is a plain
     * <input type="file"> rather than a Moodle filemanager, so core's
     * "I upload ... file to ... filemanager" step does not apply to it.
     *
     * The path must be inside $CFG->dirroot. Selenium drives a browser in its own container,
     * which mounts only the Moodle tree, at the same path the webserver sees it under; a file
     * anywhere else - including this plugin's own tests/fixtures, which is bind-mounted into
     * the webserver alone - does not exist as far as the browser is concerned.
     *
     * @Given I attach the file :filepath to the ace inline upload box :elementid
     * @throws ExpectationException If the file or the upload box cannot be found.
     * @param string $filepath Path to the file to attach, relative to the Moodle root.
     * @param string $elementid The id of the <input type="file"> element.
     */
    public function i_attach_file_to_upload_box($filepath, $elementid) {
        global $CFG;
        $fullpath = $CFG->dirroot . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $filepath);
        if (!is_readable($fullpath)) {
            throw new ExpectationException("The file to be uploaded, {$fullpath}, does not exist.", $this->getSession());
        }
        $input = $this->getSession()->getPage()->findById($elementid);
        if ($input === null) {
            throw new ExpectationException("There is no upload box with id '{$elementid}'.", $this->getSession());
        }
        $input->attachFile($fullpath);
    }

    /**
     * Checks if there is a filter-ace-inline HTML <div> containing the text.
     *
     * @Then I should see the filter-ace-inline-html div containing :text
     * @param string $text The text you should see in the <div>
     */
    public function i_see_html_div_containing($text) {
        $xpath = "//div[contains(@class, 'filter-ace-inline-html') and contains(., "
            . behat_context_helper::escape($text) . ")]";
        $driver = $this->getSession()->getDriver();
        $error = "{$text} was not found in the HTML div";
        if (!$driver->find($xpath)) {
            throw new ExpectationException($error, $this->getSession());
        }
    }

    /**
     * Checks the Ace editor's configured minLines option (as set via
     * data-min-lines) for the editor immediately following the <pre> block
     * whose text contains the given marker. Checking the live editor's own
     * option, rather than counting rendered .ace_line elements, is used
     * because Ace does not necessarily render one DOM node per blank padding
     * line - it may just reserve vertical space - so a DOM line count is not
     * a reliable signal of minLines having been applied.
     *
     * @Then I should see a min-lines value of :number after :marker with filter ace inline
     * @param string $number The expected minLines value.
     * @param string $marker Text uniquely identifying the target <pre> block.
     * @throws ExpectationException The error message.
     */
    public function i_see_min_lines_value($number, $marker) {
        $js = "Array.from(document.querySelectorAll('pre')).find(p => p.textContent.includes(" . json_encode($marker) . "))"
            . ".nextElementSibling.env.editor.getOption('minLines');";
        $actual = $this->getSession()->evaluateScript($js);
        if ((string) $actual !== (string) $number) {
            throw new ExpectationException(
                "Expected a minLines option of {$number} after '{$marker}', found {$actual}",
                $this->getSession()
            );
        }
    }

    /**
     * Checks that the gutter line numbers Ace actually rendered for the editor immediately
     * following the <pre> block whose text contains the given marker start at the given number
     * and increment by exactly 1 for every subsequent line.
     *
     * Unlike i_see_ace_option_value()'s firstLineNumber check, which only confirms the *option*
     * passed to Ace was correct, this reads the live .ace_gutter-cell elements Ace actually
     * painted into the DOM - proof the whole rendered sequence is right, not just that the
     * starting configuration was. .ace_gutter-active-line (used by the leak-avoidance regression
     * test elsewhere in this file) only marks the cursor's own line, so it cannot show this on
     * its own.
     *
     * @Then I should see line numbers starting at :number after :marker with filter ace inline
     * @param string $number The expected first line number.
     * @param string $marker Text uniquely identifying the target <pre> block.
     * @throws ExpectationException The error message.
     */
    public function i_see_line_numbers_starting_at($number, $marker) {
        $js = "Array.from(Array.from(document.querySelectorAll('pre')).find(p => p.textContent.includes("
            . json_encode($marker) . ")).nextElementSibling.querySelectorAll('.ace_gutter-cell'))"
            . ".map(cell => cell.textContent.trim()).filter(text => text !== '');";
        $gutterlines = $this->getSession()->evaluateScript($js);
        $this->assert_gutter_sequence($gutterlines, $number, "after '{$marker}'");
    }

    /**
     * As i_see_line_numbers_starting_at() above, but for the sole Ace editor on the page - no
     * marker needed. Used by the generated tests/behat/scenarios/ suite (see
     * tests/scripts/generate_behat_suite.py), where every fixture gets its own dedicated
     * question page, so there is always exactly one Ace editor to find - same reasoning as
     * i_see_ace_option_value() below.
     *
     * @Then I should see line numbers starting at :number with filter ace inline
     * @param string $number The expected first line number.
     * @throws ExpectationException The error message.
     */
    public function i_see_sole_editor_line_numbers_starting_at($number) {
        $js = "Array.from(document.querySelector('.ace_editor').querySelectorAll('.ace_gutter-cell'))"
            . ".map(cell => cell.textContent.trim()).filter(text => text !== '');";
        $gutterlines = $this->getSession()->evaluateScript($js);
        $this->assert_gutter_sequence($gutterlines, $number, "for the sole ace editor");
    }

    /**
     * Shared assertion behind i_see_line_numbers_starting_at() and
     * i_see_sole_editor_line_numbers_starting_at(): checks that $gutterlines (the
     * .ace_gutter-cell text values Ace actually rendered, top to bottom) starts at $number and
     * increments by exactly 1 per entry.
     *
     * @param array $gutterlines The rendered gutter cell text values, in DOM order.
     * @param string $number The expected first line number.
     * @param string $context Human-readable text identifying which editor, for the error message.
     * @throws ExpectationException The error message.
     */
    private function assert_gutter_sequence($gutterlines, $number, $context) {
        if (empty($gutterlines)) {
            throw new ExpectationException("No gutter line numbers found {$context}.", $this->getSession());
        }
        $expected = (int) $number;
        foreach ($gutterlines as $index => $actual) {
            $wanted = (string) ($expected + $index);
            if ((string) $actual !== $wanted) {
                throw new ExpectationException(
                    "Expected line number {$wanted} at gutter row {$index} {$context}, found '{$actual}'"
                        . " (full rendered sequence: " . implode(',', $gutterlines) . ")",
                    $this->getSession()
                );
            }
        }
    }

    /**
     * Checks a named Ace editor option's value for the sole Ace editor on
     * the current page. Unlike i_see_min_lines_value() above, this does not
     * take a marker to disambiguate between multiple blocks on one page -
     * it is used by the generated tests/behat/scenarios/ suite (see
     * tests/scripts/generate_behat_suite.py), where every fixture gets its
     * own dedicated question page, so there is always exactly one Ace
     * editor to find. The JS side wraps the option value in String() so
     * booleans (e.g. readOnly) and numbers (e.g. firstLineNumber) both
     * compare cleanly against the Gherkin string argument.
     *
     * @Then I should see an ace option :optionname value :value with filter ace inline
     * @param string $optionname The Ace editor option name, e.g. "firstLineNumber".
     * @param string $value The expected value, as its String() representation.
     * @throws ExpectationException The error message.
     */
    public function i_see_ace_option_value($optionname, $value) {
        $js = "String(document.querySelector('.ace_editor').env.editor.getOption("
            . json_encode($optionname) . "));";
        $actual = $this->getSession()->evaluateScript($js);
        if ((string) $actual !== (string) $value) {
            throw new ExpectationException(
                "Expected ace option '{$optionname}' to be '{$value}', found '{$actual}'",
                $this->getSession()
            );
        }
    }

    /**
     * Checks the actual rendered (computed) background colour of the Ace editor div that carries
     * all of the given space-separated classes - deliberately checking the computed style rather
     * than mere class presence, since CSS cascade/specificity can make the rendered background
     * disagree with what the class list alone would suggest. This is exactly what let a real bug
     * slip through unnoticed: a readonly Ace editor under the dark theme carries both
     * "ace-tomorrow-night" and "readonly", but a separate, higher-specificity styles.css rule
     * targeting ".readonly" alone silently overrode the dark theme's own background with a
     * light grey, regardless of which theme was actually active.
     *
     * @Then I should see computed background colour :colour on the ace editor with classes :classes with filter ace inline
     * @param string $colour Expected CSS computed colour, e.g. "rgb(29, 31, 33)".
     * @param string $classes Space-separated classes the target div must all carry.
     * @throws ExpectationException The error message.
     */
    public function i_see_computed_background_colour($colour, $classes) {
        $classlist = array_filter(array_map('trim', explode(' ', $classes)));
        $conditions = array_map(function($class) {
            return "contains(concat(' ', normalize-space(@class), ' '), " . json_encode(" {$class} ") . ")";
        }, $classlist);
        $xpath = "//div[" . implode(' and ', $conditions) . "]";
        $js = "getComputedStyle(document.evaluate(" . json_encode($xpath)
            . ", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue).backgroundColor;";
        $actual = $this->getSession()->evaluateScript($js);
        if ($actual !== $colour) {
            throw new ExpectationException(
                "Expected background colour '{$colour}' on the ace editor with classes '{$classes}',"
                    . " found '{$actual}'",
                $this->getSession()
            );
        }
    }

    /**
     * Inserts a fresh, undecorated ace-highlight <pre> element directly into the page body via
     * JavaScript - bypassing this filter entirely - then invokes the documented
     * globalThis.applyAceInteractive() hook. Simulates dynamically generated content added after
     * the page has already loaded (e.g. an AJAX response), which never goes through
     * text_filter::do_ace_editor() and so is never wrapped in the data-ace-inline-scan marker
     * div - proving applyAceAndBuildUi()'s whole-document fallback scan still works when no
     * marked fragment covers the new content.
     *
     * @Given I insert a fresh ace pre element and call applyAceInteractive for filter ace inline
     */
    public function insert_fresh_ace_pre_and_call_apply_ace_interactive() {
        $js = "var el = document.createElement('pre');"
            . "el.setAttribute('data-ace-highlight-code', '');"
            . "el.setAttribute('data-lang', 'python3');"
            . "el.textContent = 'FRESHLYINSERTEDMARKER';"
            . "document.body.appendChild(el);"
            . "window.applyAceInteractive();";
        $this->getSession()->executeScript($js);
    }

    /**
     * Adds the contents of a text file into a specified field in a question.
     *
     * @Given :filename exists in question :name :field for filter ace inline
     * @param string $filename The name of the file in fixtures.
     * @param string $name The name of the question.
     * @param string $field The field to be adjusted.
     */
    public function file_contents_exists_in_question_contents($filename, $name, $field) {
        global $DB;
        // Get the contents of the file in fixtures.
        $contents = file_get_contents(__DIR__ . '/../fixtures/' . $filename);
        // Set the specified field to contents in the database if id is correct.
        $DB->set_field('question', $field, $contents, ['name' => $name]);
    }

    /**
     * Adds the contents of a text file, as real Markdown source, into a specified
     * field in a question, and sets that field's format to Markdown so it is
     * actually parsed as Markdown (e.g. converting fenced code blocks to
     * <pre><code>) before the ace_inline filter processes the rendered HTML.
     *
     * @Given :filename exists in question :name :field as markdown for filter ace inline
     * @param string $filename The name of the file in fixtures.
     * @param string $name The name of the question.
     * @param string $field The field to be adjusted.
     */
    public function file_contents_exists_in_question_contents_as_markdown($filename, $name, $field) {
        global $DB;
        // Get the contents of the file in fixtures.
        $contents = file_get_contents(__DIR__ . '/../fixtures/' . $filename);
        // Set the specified field to contents, and its format to Markdown, in the database.
        $DB->set_field('question', $field, $contents, ['name' => $name]);
        $DB->set_field('question', $field . 'format', FORMAT_MARKDOWN, ['name' => $name]);
    }

    /**
     * As file_contents_exists_in_question_contents(), but loads from
     * tests/scenarios/ given a path relative to that directory (e.g.
     * "highlight/markdown-simplified/c/perm001.txt") rather than a flat
     * filename in tests/fixtures/. Used by the generated tests/behat/scenarios/
     * suite (see tests/scripts/generate_behat_suite.py), whose fixtures live
     * in a nested render/authoring/language tree that can change shape over
     * time, so a single path-parameterised step is used instead of one step
     * per fixture.
     *
     * @Given :relpath exists in question :name :field from scenarios for filter ace inline
     * @param string $relpath Path to the file, relative to tests/scenarios/.
     * @param string $name The name of the question.
     * @param string $field The field to be adjusted.
     */
    public function scenario_fixture_exists_in_question_contents($relpath, $name, $field) {
        global $DB;
        $contents = file_get_contents(__DIR__ . '/../scenarios/' . $relpath);
        $DB->set_field('question', $field, $contents, ['name' => $name]);
    }

    /**
     * As file_contents_exists_in_question_contents_as_markdown(), but loads
     * from tests/scenarios/ given a relative path - see
     * scenario_fixture_exists_in_question_contents() above for why this is
     * a separate, path-parameterised step rather than reusing the
     * tests/fixtures/-only original.
     *
     * @Given :relpath exists in question :name :field from scenarios as markdown for filter ace inline
     * @param string $relpath Path to the file, relative to tests/scenarios/.
     * @param string $name The name of the question.
     * @param string $field The field to be adjusted.
     */
    public function scenario_fixture_exists_in_question_contents_as_markdown($relpath, $name, $field) {
        global $DB;
        $contents = file_get_contents(__DIR__ . '/../scenarios/' . $relpath);
        $DB->set_field('question', $field, $contents, ['name' => $name]);
        $DB->set_field('question', $field . 'format', FORMAT_MARKDOWN, ['name' => $name]);
    }
}
