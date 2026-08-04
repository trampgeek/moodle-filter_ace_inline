/**
 * This file is part of Moodle - http:moodle.org/
 *
 * Moodle is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Moodle is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Moodle.  If not, see <http:www.gnu.org/licenses/>.
 */

/**
 * JavaScript for implementing all the features.
 *
 * @module     filter_ace_inline/ace_inline_code
 * @copyright  Richard Lobb, Michelle Hsieh 2022
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

import {applyAceAndBuildUi} from "filter_ace_inline/local/apply_ace_editor";

/**
 * Applies ace interactive code precisely once per page.
 * @param {array} config Config settings for dark-mode and buttons.
 */
export const initAceInlineEditor = async(config) => {
    if (!globalThis.aceInlineEditorDone) { // Do it once only.
        globalThis.aceInlineEditorDone = true;
        while (!globalThis.ace) {
            await new Promise(resolve => setTimeout(resolve, 1000));
        }
        applyAceAndBuildUi(document, config);
        // Add a hook for use by dynamically generated content.
        globalThis.applyAceInteractive = function() {
            applyAceAndBuildUi(document, config);
        };
    }
};
