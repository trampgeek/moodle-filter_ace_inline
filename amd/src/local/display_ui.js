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
 * JavaScript for putting the UI up.
 *
 * @module     filter_ace_inline/local/display_ui
 * @copyright  Richard Lobb, Michelle Hsieh 2022
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

import {createComponent} from "filter_ace_inline/local/utils";
import {handleButtonClick, executeCode} from "filter_ace_inline/local/ace_interactive";

/**
 * Add a UI div containing a Try it! button and a paragraph to display the
 * results of a button click (hidden until button clicked).
 * If uiParameters['html-output'] is non-null,
 * the output paragraph is used only for error output, and the output of the run
 * is inserted directly into the DOM after the (usually hidden) paragraph.
 * @param {html_element} insertionPoint The HTML element after which the div should be inserted.
 * @param {function} getCode A function that retrieves the code to be run.
 * @param {Object} uiParameters The various parameters (mostly attributes of the pre element).
 * Keys are button-name, lang, stdin, files, params, prefix, suffix, html-output.
 */
export const addUi = async(insertionPoint, getCode, uiParameters) => {
    // Create the button-node for execution.
    const button = createComponent('button', ['btn', 'btn-secondary', 'btn-ace-inline-execution'], {'type':
            'button'});
    button.innerHTML = uiParameters.paramsMap['button-name'];
    // Create the div-node to contain pre-node.
    const buttonDiv = document.createElement("div");
    const outputDisplayArea = createComponent('div', ['filter-ace-inline-output-display'], {});
    // Create a pre-node to contain text.
    const outputTextArea = createComponent('pre', ['filter-ace-inline-output-text'], {});
    buttonDiv.append(button);
    insertionPoint.after(buttonDiv);
    buttonDiv.after(outputDisplayArea);
    outputDisplayArea.append(outputTextArea);
    outputDisplayArea.style.display = 'none';
    button.addEventListener('click', async function() {
        const code = await handleButtonClick(outputDisplayArea, getCode(), uiParameters);
        // UI parameters get checked first; and if no error, then returns code.
        if (code !== null) { // If there was an error.
            executeCode(outputDisplayArea, code, uiParameters);
        }
    });
};