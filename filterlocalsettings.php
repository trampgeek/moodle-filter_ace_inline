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
    #[\Override]
    protected function definition_inner($mform) {
        // What each setting would resolve to if THIS context had no override of its own -
        // i.e. the same context-chain walk text_filter::filter() uses at render time, but
        // started one level up, at the parent context. Not "the site admin default": if an
        // ancestor context (e.g. a course category above this course) has its own override,
        // that's what actually gets inherited here, not necessarily the site setting - see the
        // "Use higher-level setting" label/settings_current_parent_value below, both worded to
        // reflect that.
        $parentconfig = \filter_ace_inline\text_filter::resolve_effective_config(
            $this->context->get_parent_context(),
            ['button_label', 'dark_theme_mode', 'simplified_mode']
        );
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
                $darkoptions[$parentconfig['dark_theme_mode']]
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
                $parentconfig['button_label']
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
                $enablemodeoptions[$parentconfig['simplified_mode']]
            )
        );
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
