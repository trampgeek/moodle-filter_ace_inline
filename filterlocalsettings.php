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
 * Per-context (e.g. course) overrides of the ace_inline filter's site settings.
 *
 * Loaded by /filter/manage.php, which detects this file's presence via
 * filter_has_local_settings() and shows a "Settings" link on the context's
 * "Filters" management page. Any field left as "Use higher-level setting" is not
 * stored, so filter_ace_inline\text_filter falls back to the nearest ancestor
 * context's override, or the site admin setting if none of them have one either.
 *
 * @package    filter_ace_inline
 * @copyright  2026 Andrew Bainbridge-Smith
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

/**
 * Local settings form for the ace_inline filter.
 */
class ace_inline_filter_local_settings_form extends \filter_local_settings_form {
    /**
     * Set by definition_inner() when this context can't offer any override fields at all (the
     * Question Bank case below) - add_action_buttons() checks this to suppress Save/Cancel too,
     * since the base class's definition() calls it unconditionally after definition_inner(), and
     * showing Save/Cancel next to a "not available here" notice with no fields to submit would be
     * misleading (and Save would just re-display the same notice with nothing to actually save).
     *
     * @var bool
     */
    private $hideactionbuttons = false;

    #[\Override]
    protected function definition_inner($mform) {
        // A Question Bank module's own context is never an ancestor of anywhere these
        // questions are actually rendered (e.g. a quiz that uses them): module contexts are
        // always siblings under their course, and question-usage filtering at attempt time
        // uses the quiz's own context regardless of where a question was authored. The only
        // place an override set here would ever apply is this question bank's own preview
        // pages - not offering the fields at all, rather than offering ones whose effect
        // would be real but misleadingly narrow (a teacher would reasonably expect this to
        // govern how their questions look wherever they're used, which it can't).
        if ($this->context->contextlevel == CONTEXT_MODULE) {
            [, $cm] = get_course_and_cm_from_cmid($this->context->instanceid);
            if ($cm->modname === 'qbank') {
                $mform->addElement(
                    'static',
                    'qbank_context_notice',
                    '',
                    get_string('settings_qbank_context_unavailable', 'filter_ace_inline')
                );
                $this->hideactionbuttons = true;
                return;
            }
        }

        // What each setting would resolve to if THIS context had no override of its own -
        // i.e. the same context-chain walk text_filter::filter() uses at render time, but
        // started one level up, at the parent context. Not "the site admin default": if an
        // ancestor context (e.g. a course category above this course) has its own override,
        // that's what actually gets inherited here, not necessarily the site setting - see the
        // "Use higher-level setting" label/settings_current_parent_value below, both worded to
        // reflect that.
        $parentcontext = $this->context->get_parent_context();
        $parentconfig = \filter_ace_inline\text_filter::resolve_effective_config(
            $parentcontext,
            ['button_label', 'dark_theme_mode', 'simplified_mode']
        );
        // Deliberately just the immediate parent, not wherever up the chain the override
        // (if any) actually lives: that could be several levels further up, possibly in a
        // context this user has no permission to even see, let alone change - the immediate
        // parent is always a safe, relevant place to point at (its own value might just be
        // inherited too, but that's for its own settings page to reveal in turn).
        $parentname = $this->parent_context_description($parentcontext);

        // Unlike dark_theme_mode/simplified_mode (selects, whose own selected option already
        // unambiguously shows whether this context is overriding or not), button_label is a
        // plain text field where "blank" is the only way to mean "not overridden" - so it can't
        // also show its own current override text as normal field content without that looking
        // identical to a deliberate empty-string override. Whether THIS context (not its
        // parent) already has its own override determines the wording below.
        $hasownbuttonlabel = array_key_exists('button_label', filter_get_local_config($this->filter, $this->context->id));

        $useparent = get_string('settings_use_parent', 'filter_ace_inline');

        $darkoptions = [
            '' => $useparent,
            0 => get_string('settings_dark_never', 'filter_ace_inline'),
            1 => get_string('settings_dark_preference', 'filter_ace_inline'),
            2 => get_string('settings_dark_always', 'filter_ace_inline'),
        ];
        $mform->addElement(
            'select',
            'dark_theme_mode',
            get_string('settings_dark_theme', 'filter_ace_inline'),
            $darkoptions
        );
        $mform->addElement(
            'static',
            'dark_theme_mode_parentvalue',
            '',
            get_string(
                'settings_current_parent_value',
                'filter_ace_inline',
                (object) ['value' => $darkoptions[$parentconfig['dark_theme_mode']], 'parentname' => $parentname]
            )
        );

        $mform->addElement(
            'text',
            'button_label',
            get_string('settings_button_label', 'filter_ace_inline'),
            ['placeholder' => $parentconfig['button_label']]
        );
        $mform->setType('button_label', PARAM_TEXT);
        $mform->addElement(
            'static',
            'button_label_parentvalue',
            '',
            get_string(
                $hasownbuttonlabel ? 'settings_overriding_parent' : 'settings_following_parent',
                'filter_ace_inline',
                (object) ['value' => $parentconfig['button_label'], 'parentname' => $parentname]
            )
        );

        $enablemodeoptions = [
            '' => $useparent,
            0 => get_string('settings_simplified_mode_off', 'filter_ace_inline'),
            1 => get_string('settings_simplified_mode_enabled', 'filter_ace_inline'),
        ];
        $mform->addElement(
            'select',
            'simplified_mode',
            get_string('settings_simplified_mode_label', 'filter_ace_inline'),
            $enablemodeoptions
        );
        $mform->addElement(
            'static',
            'simplified_mode_parentvalue',
            '',
            get_string(
                'settings_current_parent_value',
                'filter_ace_inline',
                (object) ['value' => $enablemodeoptions[$parentconfig['simplified_mode']], 'parentname' => $parentname]
            )
        );
    }

    #[\Override]
    public function add_action_buttons($cancel = true, $submitlabel = null) {
        if ($this->hideactionbuttons) {
            return;
        }
        parent::add_action_buttons($cancel, $submitlabel);
    }

    /**
     * Human-readable, possibly-linked description of where to look to check or change
     * whatever this context would inherit - the immediate parent context, or the site
     * administrator settings page when that parent either doesn't exist (this context IS the
     * system context) or IS the system context itself (e.g. a top-level course category, whose
     * parent context is the system context, not a "manage filters" page for it - the system
     * context has no such settings of its own outside the site administrator's page). Deliberately
     * never further up the chain than that - see definition_inner()'s comment on $parentname for
     * why.
     *
     * @param \core\context|false $parentcontext $this->context->get_parent_context()'s result.
     * @return string HTML - a link when the current user can actually manage settings there,
     *     otherwise the plain (unlinked) name, so we never offer a link that would just 403.
     */
    private function parent_context_description($parentcontext) {
        if (!$parentcontext || $parentcontext->contextlevel == CONTEXT_SYSTEM) {
            $name = get_string('settings_site_admin_settings_page', 'filter_ace_inline');
            if (!has_capability('moodle/site:config', \context_system::instance())) {
                return $name;
            }
            $url = new \moodle_url('/admin/settings.php', ['section' => 'filtersettingace_inline']);
            return \html_writer::link($url, $name);
        }
        $name = $parentcontext->get_context_name();
        if (!has_capability('moodle/filter:manage', $parentcontext)) {
            return $name;
        }
        $url = new \moodle_url('/filter/manage.php', ['contextid' => $parentcontext->id, 'filter' => $this->filter]);
        return \html_writer::link($url, $name);
    }

    #[\Override]
    public function save_changes($data) {
        // Override the default implementation, which stores every submitted field
        // (including the 'submitbutton' element added by add_action_buttons()) as
        // local config, to only persist this form's three known settings.
        $data = (array) $data;
        foreach (['dark_theme_mode', 'button_label', 'simplified_mode'] as $name) {
            $value = $data[$name] ?? '';
            if ($value !== '') {
                filter_set_local_config($this->filter, $this->context->id, $name, $value);
            } else {
                filter_unset_local_config($this->filter, $this->context->id, $name);
            }
        }
    }
}
