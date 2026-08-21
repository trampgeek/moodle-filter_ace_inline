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

/**
 * Unit tests.
 *
 * @package filter_ace_inline
 * @copyright 2026 Andrew Bainbridge-Smith
 * @license http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 * @covers \filter_ace_inline\text_filter
 */
final class text_filter_test extends \advanced_testcase {
    /**
     * Builds a text_filter wired up with a real moodle_page for the given context, so
     * do_ace_editor()'s $this->page->requires calls have somewhere real to land.
     *
     * @param \context $context The context to filter in.
     * @return text_filter
     */
    private function make_filter(\context $context): text_filter {
        $filter = new text_filter($context, []);
        $page = new \moodle_page();
        $page->set_context($context);
        $filter->setup($page, $context);
        return $filter;
    }

    /**
     * Invokes a protected method on a text_filter instance.
     *
     * @param text_filter $filter
     * @param string $method
     * @param array $args
     * @return mixed
     */
    private function call_protected(text_filter $filter, string $method, array $args = []) {
        $reflection = new \ReflectionMethod($filter, $method);
        $reflection->setAccessible(true);
        return $reflection->invokeArgs($filter, $args);
    }

    /**
     * Returns the AMD JS the filter's page has been told to require, as a single string,
     * so tests can assert on whether our module was queued without rendering the whole page.
     *
     * @param text_filter $filter
     * @return string
     */
    private function queued_amd_modules(text_filter $filter): string {
        $pagereflection = new \ReflectionProperty($filter, 'page');
        $pagereflection->setAccessible(true);
        $page = $pagereflection->getValue($filter);

        $codereflection = new \ReflectionProperty($page->requires, 'amdjscode');
        $codereflection->setAccessible(true);
        return implode("\n", $codereflection->getValue($page->requires));
    }

    public function test_effective_config_falls_back_to_site_default_with_no_overrides(): void {
        $this->resetAfterTest(true);
        set_config('button_label', 'Site default', 'filter_ace_inline');
        set_config('dark_theme_mode', 0, 'filter_ace_inline');
        set_config('simplified_mode', 0, 'filter_ace_inline');

        $course = $this->getDataGenerator()->create_course();
        $filter = $this->make_filter(\context_course::instance($course->id));

        $config = $this->call_protected($filter, 'get_effective_config');

        $this->assertSame('Site default', $config['button_label']);
        $this->assertEquals(0, $config['dark_theme_mode']);
        $this->assertEquals(0, $config['simplified_mode']);
    }

    public function test_effective_config_uses_course_level_override_in_nested_module_context(): void {
        $this->resetAfterTest(true);
        set_config('button_label', 'Site default', 'filter_ace_inline');

        $course = $this->getDataGenerator()->create_course();
        $coursecontext = \context_course::instance($course->id);
        $cm = $this->getDataGenerator()->create_module('page', ['course' => $course->id]);
        $modcontext = \context_module::instance($cm->cmid);

        filter_set_local_config('ace_inline', $coursecontext->id, 'button_label', 'Course override');

        // Filtering content inside the module (nested below the course context where the
        // override lives) must still pick up the course-level override - this is exactly what
        // get_effective_config()'s manual context-chain walk exists to fix, since Moodle core
        // does not inherit local filter config down the context tree on its own.
        $filter = $this->make_filter($modcontext);
        $config = $this->call_protected($filter, 'get_effective_config');

        $this->assertSame('Course override', $config['button_label']);
    }

    public function test_effective_config_uses_category_level_override(): void {
        $this->resetAfterTest(true);
        set_config('button_label', 'Site default', 'filter_ace_inline');

        $category = $this->getDataGenerator()->create_category();
        $categorycontext = \context_coursecat::instance($category->id);
        $course = $this->getDataGenerator()->create_course(['category' => $category->id]);
        $modcontext = \context_module::instance(
            $this->getDataGenerator()->create_module('page', ['course' => $course->id])->cmid
        );

        filter_set_local_config('ace_inline', $categorycontext->id, 'button_label', 'Category override');

        // A category-level override must reach content in a module two levels below it
        // (course, then module), the same walk-up-the-chain mechanism already covered for a
        // course-level override reaching a nested module - this is the other documented
        // hierarchy level (README: "Course Category, Course, and individual Module") that
        // previously had no coverage at all.
        $filter = $this->make_filter($modcontext);
        $config = $this->call_protected($filter, 'get_effective_config');

        $this->assertSame('Category override', $config['button_label']);
    }

    public function test_effective_config_nearest_context_override_wins(): void {
        $this->resetAfterTest(true);

        $course = $this->getDataGenerator()->create_course();
        $coursecontext = \context_course::instance($course->id);
        $cm = $this->getDataGenerator()->create_module('page', ['course' => $course->id]);
        $modcontext = \context_module::instance($cm->cmid);

        filter_set_local_config('ace_inline', $coursecontext->id, 'button_label', 'Course override');
        filter_set_local_config('ace_inline', $modcontext->id, 'button_label', 'Module override');

        $filter = $this->make_filter($modcontext);
        $config = $this->call_protected($filter, 'get_effective_config');

        $this->assertSame('Module override', $config['button_label']);
    }

    public function test_effective_config_merges_partial_overrides_across_context_levels(): void {
        $this->resetAfterTest(true);
        set_config('dark_theme_mode', 0, 'filter_ace_inline');

        $course = $this->getDataGenerator()->create_course();
        $coursecontext = \context_course::instance($course->id);
        $cm = $this->getDataGenerator()->create_module('page', ['course' => $course->id]);
        $modcontext = \context_module::instance($cm->cmid);

        // The module context only overrides button_label - dark_theme_mode must fall through
        // past it to the course-level override, not straight to the site default, since a name
        // only counts as "resolved" once some context in the chain has actually set it.
        filter_set_local_config('ace_inline', $modcontext->id, 'button_label', 'Module label');
        filter_set_local_config('ace_inline', $coursecontext->id, 'dark_theme_mode', 2);

        $filter = $this->make_filter($modcontext);
        $config = $this->call_protected($filter, 'get_effective_config');

        $this->assertSame('Module label', $config['button_label']);
        $this->assertEquals(2, $config['dark_theme_mode']);
    }

    public function test_effective_config_is_memoised_for_the_life_of_the_filter_instance(): void {
        $this->resetAfterTest(true);
        set_config('button_label', 'Original', 'filter_ace_inline');

        $course = $this->getDataGenerator()->create_course();
        $filter = $this->make_filter(\context_course::instance($course->id));

        $first = $this->call_protected($filter, 'get_effective_config');
        set_config('button_label', 'Changed after first call', 'filter_ace_inline');
        $second = $this->call_protected($filter, 'get_effective_config');

        $this->assertSame('Original', $first['button_label']);
        $this->assertSame($first, $second);
    }

    public function test_do_ace_editor_ignores_bare_code_tag_when_simplified_mode_is_off(): void {
        $this->resetAfterTest(true);
        $course = $this->getDataGenerator()->create_course();
        $filter = $this->make_filter(\context_course::instance($course->id));

        $config = ['button_label' => 'Try it!', 'dark_theme_mode' => 0, 'simplified_mode' => 0];
        $this->call_protected($filter, 'do_ace_editor', ['<p>some text with a <code>tag</code></p>', $config]);

        $this->assertStringNotContainsString('filter_ace_inline/ace_inline_code', $this->queued_amd_modules($filter));
    }

    public function test_do_ace_editor_loads_module_for_bare_code_tag_when_simplified_mode_is_on(): void {
        $this->resetAfterTest(true);
        $course = $this->getDataGenerator()->create_course();
        $filter = $this->make_filter(\context_course::instance($course->id));

        $config = ['button_label' => 'Try it!', 'dark_theme_mode' => 0, 'simplified_mode' => 1];
        $this->call_protected($filter, 'do_ace_editor', ['<p>some text with a <code>tag</code></p>', $config]);

        $this->assertStringContainsString('filter_ace_inline/ace_inline_code', $this->queued_amd_modules($filter));
    }

    public function test_do_ace_editor_loads_module_for_explicit_marker_regardless_of_simplified_mode(): void {
        $this->resetAfterTest(true);
        $course = $this->getDataGenerator()->create_course();
        $filter = $this->make_filter(\context_course::instance($course->id));

        $config = ['button_label' => 'Try it!', 'dark_theme_mode' => 0, 'simplified_mode' => 0];
        $text = '<pre class="ace-interactive-code">print("hi")</pre>';
        $this->call_protected($filter, 'do_ace_editor', [$text, $config]);

        $this->assertStringContainsString('filter_ace_inline/ace_inline_code', $this->queued_amd_modules($filter));
    }

    public function test_do_ace_editor_does_nothing_for_plain_text(): void {
        $this->resetAfterTest(true);
        $course = $this->getDataGenerator()->create_course();
        $filter = $this->make_filter(\context_course::instance($course->id));

        $config = ['button_label' => 'Try it!', 'dark_theme_mode' => 0, 'simplified_mode' => 0];
        $this->call_protected($filter, 'do_ace_editor', ['<p>nothing special here</p>', $config]);

        $this->assertStringNotContainsString('filter_ace_inline/ace_inline_code', $this->queued_amd_modules($filter));
    }
}
