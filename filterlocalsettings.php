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
 * "Filters" management page. Any field left as "Use site default" is not
 * stored, so filter_ace_inline\text_filter falls back to the admin setting.
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
        $usedefault = get_string('settings_use_default', 'filter_ace_inline');

        $darkoptions = [
            '' => $usedefault,
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
            'text',
            'button_label',
            get_string('settings_button_label', 'filter_ace_inline')
        );
        $mform->setType('button_label', PARAM_TEXT);

        $enablemodeoptions = [
            '' => $usedefault,
            0 => get_string('settings_simplified_mode_off', 'filter_ace_inline'),
            1 => get_string('settings_simplified_mode_enabled', 'filter_ace_inline'),
        ];
        $mform->addElement(
            'select',
            'simplified_mode',
            get_string('settings_simplified_mode_label', 'filter_ace_inline'),
            $enablemodeoptions
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
