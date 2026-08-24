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

namespace filter_ace_inline;

defined('MOODLE_INTERNAL') || die();

// Ensure the "local settings form" base class our plugin extends is actually loaded first,
// mirroring what core's filter/manage.php itself always does before it ever touches a
// filter's own filterlocalsettings.php. Which file (and even which namespace) defines that
// base class differs by Moodle version: before Moodle 4.5 it's the global-namespace
// filter_local_settings_form, defined directly in filter/local_settings_form.php; from 4.5 on
// it's \core_filters\local_settings_form (filter/classes/form/local_settings_form.php),
// autoloaded on first reference, with that same file also class_alias()-ing itself to
// \filter_local_settings_form for exactly this kind of backward-compatible reference. A bare
// require_once() of our own filterlocalsettings.php, with neither of those already loaded,
// fatals with "Class not found" - confirmed directly against Moodle core's own release
// branches (filter/local_settings_form.php exists on MOODLE_403_STABLE/MOODLE_404_STABLE,
// 404s from MOODLE_405_STABLE on; filter/classes/form/local_settings_form.php is the reverse)
// after CI failed on 4.3/4.4/4.5 but passed on 5.0+ the first time this test file ran:
// PHPUnit never goes through manage.php's own require, so nothing else guarantees this
// ordering here. filterlocalsettings.php itself needs no equivalent guard - manage.php always
// requires the right file before it ever reaches a filter's own settings form in real use.
global $CFG;
if (file_exists($CFG->dirroot . '/filter/local_settings_form.php')) {
    require_once($CFG->dirroot . '/filter/local_settings_form.php');
} else {
    class_exists('\core_filters\local_settings_form'); // Triggers autoload; defines the alias.
}
require_once(__DIR__ . '/../filterlocalsettings.php');

/**
 * Unit tests for ace_inline_filter_local_settings_form (filterlocalsettings.php).
 *
 * This class is deliberately in the global namespace (it extends core's
 * \filter_local_settings_form and is loaded directly by /filter/manage.php via
 * filter_has_local_settings(), not through component autoloading), so it's referenced here
 * with a leading backslash throughout.
 *
 * @package filter_ace_inline
 * @copyright 2026 Andrew Bainbridge-Smith
 * @license http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 * @covers \ace_inline_filter_local_settings_form
 */
final class filterlocalsettings_test extends \advanced_testcase {
    /**
     * Renders the local settings form for the given context and returns its HTML.
     *
     * @param \context $context
     * @return string
     */
    private function render_form(\context $context): string {
        $form = new \ace_inline_filter_local_settings_form(
            (new \moodle_url('/filter/manage.php'))->out(false),
            'ace_inline',
            $context
        );
        return $form->render();
    }

    public function test_qbank_module_context_hides_the_override_fields(): void {
        $this->resetAfterTest(true);
        $this->setAdminUser();

        $course = $this->getDataGenerator()->create_course();
        try {
            $qbank = $this->getDataGenerator()->create_module('qbank', ['course' => $course->id]);
        } catch (\coding_exception $e) {
            // Mod_qbank (the dedicated Question Bank activity type this test is about) was
            // introduced after this plugin's own minimum supported Moodle version and isn't
            // generator-testable (or doesn't exist at all) on older branches - confirmed on
            // Moodle 4.3/4.4/4.5 in CI, all with this exact "does not support generators yet"
            // message. Nothing to test here on those versions; skip rather than fail.
            $this->markTestSkipped('mod_qbank is not available on this Moodle version: ' . $e->getMessage());
        }
        $context = \context_module::instance($qbank->cmid);

        $html = $this->render_form($context);

        $this->assertStringContainsString('not available for a question bank', $html);
        $this->assertStringNotContainsString('name="dark_theme_mode"', $html);
        $this->assertStringNotContainsString('name="button_label"', $html);
        $this->assertStringNotContainsString('name="simplified_mode"', $html);
        // Save/Cancel would be pointless (and misleading) here: there are no fields to submit.
        $this->assertStringNotContainsString('name="submitbutton"', $html);
    }

    public function test_non_qbank_module_context_shows_the_override_fields(): void {
        $this->resetAfterTest(true);
        $this->setAdminUser();

        $course = $this->getDataGenerator()->create_course();
        $page = $this->getDataGenerator()->create_module('page', ['course' => $course->id]);
        $context = \context_module::instance($page->cmid);

        $html = $this->render_form($context);

        $this->assertStringNotContainsString('not available for a question bank', $html);
        $this->assertStringContainsString('name="dark_theme_mode"', $html);
        $this->assertStringContainsString('name="button_label"', $html);
        $this->assertStringContainsString('name="simplified_mode"', $html);
        $this->assertStringContainsString('name="submitbutton"', $html);
    }

    public function test_parent_context_hint_links_to_the_immediate_parent_when_user_can_manage_it(): void {
        $this->resetAfterTest(true);
        $this->setAdminUser();

        $course = $this->getDataGenerator()->create_course(['fullname' => 'Parent Link Course']);
        $coursecontext = \context_course::instance($course->id);
        $page = $this->getDataGenerator()->create_module('page', ['course' => $course->id]);
        $modcontext = \context_module::instance($page->cmid);

        $html = $this->render_form($modcontext);

        // Admin can manage filter settings everywhere, so the immediate parent (the course)
        // should be named and linked, not just named.
        $this->assertStringContainsString('Parent Link Course', $html);
        $this->assertStringContainsString('contextid=' . $coursecontext->id, $html);
        $this->assertStringContainsString('to check or change this', $html);
    }

    public function test_parent_context_hint_is_unlinked_plain_text_when_user_cannot_manage_it(): void {
        $this->resetAfterTest(true);

        $course = $this->getDataGenerator()->create_course(['fullname' => 'No Access Course']);
        $coursecontext = \context_course::instance($course->id);
        $page = $this->getDataGenerator()->create_module('page', ['course' => $course->id]);
        $modcontext = \context_module::instance($page->cmid);

        // A plain student has no moodle/filter:manage capability anywhere, so the parent
        // context's name should still be shown (so they know where it lives) but not as a
        // link they'd only get a permission error from. Checking specifically for a link
        // carrying the parent's contextid - not just the bare substring "/filter/manage.php",
        // which the form's own <form action="..."> submit URL legitimately contains
        // regardless of capability.
        $student = $this->getDataGenerator()->create_and_enrol($course, 'student');
        $this->setUser($student);

        $html = $this->render_form($modcontext);

        $this->assertStringContainsString('No Access Course', $html);
        $this->assertStringNotContainsString('contextid=' . $coursecontext->id, $html);
    }

    public function test_system_context_hint_points_at_the_site_admin_settings_page(): void {
        $this->resetAfterTest(true);
        $this->setAdminUser();

        $html = $this->render_form(\context_system::instance());

        $this->assertStringContainsString('the site administrator settings', $html);
        $this->assertStringContainsString('section=filtersettingace_inline', $html);
    }
}
