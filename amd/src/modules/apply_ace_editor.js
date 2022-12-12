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
 * JavaScript for applying the ace editor.
 *
 * @module     filter_ace_inline/apply_ace_editor
 * @copyright  Richard Lobb, Michelle Hsieh 2022
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

import {UiParameters} from "filter_ace_inline/./modules/ui_parameters";
import {addUi} from "filter_ace_inline/./modules/display_ui";
import {setupFileHandler} from "filter_ace_inline/./modules/file_helpers";

const ACE_DARK_THEME = 'ace/theme/tomorrow_night';
const ACE_LIGHT_THEME = 'ace/theme/textmate';
const ACE_MODE_MAP = {  // Ace modes for various languages (default: use language name).
    'c': 'c_cpp',
    'cpp': 'c_cpp',
    'js': 'javascript',
    'nodejs': 'javascript',
    'c#': 'cs',
    'octave': 'matlab',
    'c++': 'c_cpp',
    'python2': 'python',
    'python3': 'python',
    'markup': 'html'
};

/**
 * Replace all <pre> and <code> elements in the document rooted at root that have
 * the given className or ace-inline attribute, with an Ace editor windows that display the
 * code in whatever language has been set.
 * @param {object} root The root of the HTML document to modify.
 * @param {bool} isInteractive True for ace-interactive otherwise false.
 * @param {object} config The plugin configuration settings.
 */
export const applyAceAndBuildUi = async (root, isInteractive, config) => {
    const className = isInteractive ? 'ace-interactive-code' : 'ace-highlight-code';
    const alternativeName = isInteractive ? 'data-ace-interactive-code' : 'data-ace-highlight-code';

    const preElements = root.getElementsByTagName('pre');
    for (const pre of preElements) {
        if (pre.style.display !== 'none') {
            const uiParams = new UiParameters(pre);
            uiParams.extractUiParameters(isInteractive, config);
            if (pre.classList.contains(className) || pre.hasAttribute(alternativeName)) {
                applyToPre(pre, isInteractive, uiParams);
            }
        }
    }
    // For Markdown compatibility.
    const codeElements = root.getElementsByTagName('code');
    for (const code of codeElements) {
        if (code.parentNode !== null && code.style.display !== 'none' &&
                (code.hasAttribute(alternativeName) || code.classList.contains(className))) {
            const uiParams = new UiParameters(code);
            uiParams.extractUiParameters(isInteractive, config);
            applyToPre(code.parentNode, isInteractive, uiParams);
        }
    }
};

/**
 * Replace the given PRE element with an element managed by the Ace editor,
 * unless 'hidden' is true, in which case we just hide the PRE.
 * @param {HTMLelement} pre The PRE element to be be replaced by an Ace editor.
 * @param {bool} isInteractive True for ace-interactive otherwise false.
 * @param {Object} uiParameters the User Interface parameters for the element.
 */
const applyToPre = async (pre, isInteractive, uiParameters) => {
    const params = uiParameters.paramsMap;
    if (params['file-upload-id']) {
        setupFileHandler(params['file-upload-id']);
    }

    if (!params.hidden) {
        setUpAce(pre, uiParameters, isInteractive);
    } else if (isInteractive) { // Code is hidden but there's still a button to run it.
        const getCode = () => pre.text();
        addUi(pre, getCode, uiParameters);
    }

    pre.style.display = 'none';  // NB this sets display = 'none', checked above.
};

/**
 * Sets up Ace with all its parameters and adds a button if interactive.
 *
 * @param {html element} pre The pre element that the Ace editor is replacing.
 * @param {object} uiParameters The UI parameters from the Pre element + defaults.
 * @param {bool} isInteractive True if the code is interactive.
 */
const setUpAce = async (pre, uiParameters, isInteractive) => {
    const params = uiParameters.paramsMap;
    const darkMode = params['dark-theme-mode']; // 0, 1, 2 for never, sometimes, always
    let theme = null;

    // Use light or dark theme according to user's prefers-color-scheme.
    // Default to light.
    if (darkMode == 2 || (darkMode == 1 && window.matchMedia &&
            window.matchMedia("(prefers-color-scheme: dark)").matches)) {
        theme = ACE_DARK_THEME;
    } else {
        theme = ACE_LIGHT_THEME;
    }
    const showLineNumbers = params['start-line-number'] ? true : false;
    let aceLang = params['ace-lang'] ? params['ace-lang'] : params.lang;
    aceLang = aceLang.toLowerCase();
    if (aceLang in ACE_MODE_MAP) {
        aceLang = ACE_MODE_MAP[aceLang];
    }
    const mode = 'ace/mode/' + aceLang;
    const text = pre.textContent;
    const lines = text.split("\n");
    const numLines = lines.length;
    const longestLine = longest(lines);

    const editNode = document.createElement('div'); // Ace editor manages this
    const width = pre.scrollWidth;  // Our first guess at a minimum width.
    editNode.style.margin = "6px 0px 6px 0px";
    editNode.style.lineHeight = "1.3";
    editNode.style.minWidth = width + "px";
    pre.after(editNode);    // Insert the edit node

    let aceConfig = {
        newLineMode: "unix",
        mode: mode,
        minLines: Math.max(numLines, params['min-lines']),
        maxLines: params['max-lines'],
        fontSize: params['font-size'],
        showLineNumbers: showLineNumbers,
        firstLineNumber: params['start-line-number'],
        showGutter: showLineNumbers,
        showPrintMargin: false,
        autoScrollEditorIntoView: true,
        highlightActiveLine: showLineNumbers
    };

    const editor = window.ace.edit(editNode, aceConfig);
    const session = editor.getSession();
    const aceWidestLine = lineLength(editor.renderer, longestLine);
    if (aceWidestLine > width) {
        editNode.style.minWidth = Math.ceil(aceWidestLine) + "px";
    }
    session.setValue(text);
    editor.setTheme(theme);
    if (params.readonly !== null) {
        editor.setReadOnly(true);
    }

    // Add a button and text area for output if ace-interactive-code.
    if (isInteractive) {
        const getCode = () => editor.getSession().getValue();
        addUi(editNode, getCode, uiParameters);
    } else {
        editor.renderer.$cursorLayer.element.style.display = "none"; // Hide cursor.
    }
};

/**
 * Return the length of the given line when rendered by the given Ace editor.
 * @param {Ace-renderer} renderer The Ace renderer.
 * @param {String} line The line whose length is being checked.
 * @return {int} The length of the rendered line in pixels.
 */
const lineLength = (renderer, line) => {
  const chars = renderer.session.$getStringScreenWidth(line)[0];
  const width = Math.max(chars, 2) * renderer.characterWidth + // text size
    2 * renderer.$padding + // padding
    2  + // little extra for the cursor
    0; // add border width if needed

  return width;
};

/**
 * Return the longest of an array of strings.
 * @param {array} lines An array of lines
 * @return {String} The longest of the lines
 */
const longest = (lines) => {
    let longest = '';
    for (const line of lines) {
        if (line.length > longest.length) {
            longest = line;
        }
    }
    return longest;
};
