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
 * @module     filter_ace_inline/local/apply_ace_editor
 * @copyright  Richard Lobb, Michelle Hsieh 2022
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

import {UiParameters} from "filter_ace_inline/local/ui_parameters";
import {addUi} from "filter_ace_inline/local/display_ui";
import {setupFileHandler} from "filter_ace_inline/local/file_helpers";
import {getCDatatypeMode} from "filter_ace_inline/local/c_datatype_mode";
import {OUTPUT_TEXT_CLASS} from "filter_ace_inline/local/utils";
import {getString} from 'core/str';

const SIMPLIFIED_MODE_ENABLED = "1";

// The legacy explicit opt-in classes. A single class matching one of these is not a language
// name, so it must never be routed through extractExtendedMarkdownParameters() even when
// simplified mode is also enabled site-wide alongside older, explicitly-classed content.
const LEGACY_MARKER_CLASSES = ['ace-highlight-code', 'ace-interactive-code'];

/**
 * True if, under simplified mode, this classList should be parsed as a bare or colon-separated
 * "language[:option:value...]" specifier rather than treated as a normal HTML class.
 * @param {DOMTokenList} classList The classList of the <pre> or <code> element being checked.
 * @return {bool}
 */
const isExtendedMarkdownClass = (classList) =>
    classList.length === 1 && !LEGACY_MARKER_CLASSES.includes(classList[0]);

const ACE_DARK_THEME = 'ace/theme/tomorrow_night';
const ACE_LIGHT_THEME = 'ace/theme/textmate';
const LINE_NUMBER_COL_WIDTH = 42; // Width of line number column in Ace render.
const ACE_MODE_MAP = { // Ace modes for various languages (default: use language name).
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
 * @param {object} config The plugin configuration settings.
 */
export const applyAceAndBuildUi = async(root, config) => {
    // Look for ace editor controls in the <pre> fench first.
    // Snapshot into a plain array: applyToPre() below can insert a new <pre> (the output box
    // addUi() builds) as a later sibling of the pre it's attached to, and getElementsByTagName's
    // collection is live - without this the loop would go on to process its own freshly-inserted
    // output box as if it were more content to highlight.
    const preElements = Array.from(root.getElementsByTagName('pre'));
    for (const pre of preElements) {
        if (pre.classList.contains(OUTPUT_TEXT_CLASS)) {
            continue;
        }
        const isInteractive = pre.classList.contains('ace-interactive-code') ||
            pre.hasAttribute('data-ace-interactive-code') ||
            (config.simplified_mode === SIMPLIFIED_MODE_ENABLED &&
                isExtendedMarkdownClass(pre.classList) &&
                    pre.classList[0].includes('interactive')) ||
            false;
        const isHighlight = pre.classList.contains('ace-highlight-code') ||
            pre.hasAttribute('data-ace-highlight-code') ||
            (config.simplified_mode === SIMPLIFIED_MODE_ENABLED &&
                isExtendedMarkdownClass(pre.classList)) ||
            false;
        if ((isInteractive || isHighlight) && pre.style.display !== 'none') {
            const uiParams = new UiParameters(pre);
            if (config.simplified_mode === SIMPLIFIED_MODE_ENABLED && isExtendedMarkdownClass(pre.classList)) {
                uiParams.extractExtendedMarkdownParameters(isInteractive, config, pre.classList[0].split(":"));
            } else {
                uiParams.extractUiParameters(isInteractive, config);
            }
            applyToPre(pre, isInteractive, uiParams);
        }
    }

    // Look for ace editor controls in the <code> fence, this should take priority over ace editor controls in the <pre> fence.
    const codeElements = Array.from(root.getElementsByTagName('code'));
    for (const code of codeElements) {
        if (code.parentNode !== null && code.parentNode.nodeName === 'PRE' && code.parentNode.style.display !== 'none') {
            const isInteractive = code.classList.contains('ace-interactive-code') ||
                code.hasAttribute('data-ace-interactive-code') ||
                (config.simplified_mode === SIMPLIFIED_MODE_ENABLED &&
                    isExtendedMarkdownClass(code.classList) &&
                        code.classList[0].includes('interactive')) ||
                false;
            const isHighlight = code.classList.contains('ace-highlight-code') ||
                code.hasAttribute('data-ace-highlight-code') ||
                (config.simplified_mode === SIMPLIFIED_MODE_ENABLED &&
                    isExtendedMarkdownClass(code.classList)) ||
                false;

            const uiParams = new UiParameters(code);

            if (config.simplified_mode === SIMPLIFIED_MODE_ENABLED && isExtendedMarkdownClass(code.classList)) {
                uiParams.extractExtendedMarkdownParameters(isInteractive, config, code.classList[0].split(":"));
            } else {
                uiParams.extractUiParameters(isInteractive, config);
            }

            if (isInteractive || isHighlight) {
                applyToPre(code.parentNode, isInteractive, uiParams);
            }
        }
    }
};

/**
 * Wait for Ace editor to render its content layers.
 * @param {HTMLelement} editNode The div element managed by Ace editor.
 * @param {number} expectedLines The expected number of text lines to be rendered.
 * @param {number} timeout Timeout in milliseconds (default 2000).
 * @return {Promise} Resolves when ace_text-layer is rendered, rejects on timeout.
 */
const waitForAceRender = (editNode, expectedLines, timeout = 2000) => {
    // To reduce the risk of false positives, let's be happy with at most 3 rendered
    // lines since AFAIK any failures actually have zero rendered lines.
    expectedLines = Math.min(3, expectedLines);

    return new Promise((resolve, reject) => {
        const startTime = Date.now();

        const checkRendering = () => {
            // On a cold page load Ace's font-metrics measurement can still be pending when the
            // editor is first created, leaving the text layer unpainted even though resize() was
            // already called once. Re-poking resize() on each poll is a cheap way to self-heal
            // once those metrics become available, without weakening the render-detection check.
            if (editNode.env && editNode.env.editor) {
                editNode.env.editor.resize(true);
            }

            // Count the number of div.ace_line elements which represent the actual rendered lines
            const aceLines = editNode.querySelectorAll('div.ace_line');

            if (aceLines.length >= expectedLines) {
                // Successfully found the expected number of rendered lines
                resolve();
            } else if (Date.now() - startTime >= timeout) {
                // Timeout exceeded
                reject(new Error('Ace editor rendering timeout: ace_text-layer not populated'));
            } else {
                // Not ready yet, check again soon
                setTimeout(checkRendering, 50);
            }
        };

        checkRendering();
    });
};

/**
 * Replace the given PRE element with an element managed by the Ace editor,
 * unless 'hidden' is true, in which case we just hide the PRE.
 * @param {HTMLelement} pre The PRE element to be be replaced by an Ace editor.
 * @param {bool} isInteractive True for ace-interactive otherwise false.
 * @param {Object} uiParameters the User Interface parameters for the element.
 */
const applyToPre = async(pre, isInteractive, uiParameters) => {
    const params = uiParameters.paramsMap;
    if (params['file-upload-id']) {
        setupFileHandler(params['file-upload-id']);
    }

    let editNode = null;
    let expectedLines = 0;
    if (!params.hidden) {
        // Count the number of lines in the original pre element
        const text = pre.textContent;
        const numLines = text.split("\n").length;
        const minLines = params['min-lines'];
        const maxLines = params['max-lines'];
        // Calculate expected lines: max(min-lines, min(numLines, max-lines))
        expectedLines = Math.max(minLines, Math.min(numLines, maxLines));
        editNode = await setUpAce(pre, uiParameters, isInteractive);
    } else if (isInteractive) { // Code is hidden but there's still a button to run it.
        const getCode = () => pre.innerText;
        addUi(pre, getCode, uiParameters);
    }

    // Wait for Ace to fully render before hiding the original pre element
    if (editNode) {
        try {
            await waitForAceRender(editNode, expectedLines);
            pre.style.display = 'none'; // NB this sets display = 'none', checked above.
        } catch (error) {
            // Remove the failed Ace editNode
            if (editNode.parentNode) {
                editNode.parentNode.removeChild(editNode);
            }

            // Create and insert warning message before pre
            const warningDiv = document.createElement('div');
            warningDiv.style.color = '#f44336';
            warningDiv.style.marginBottom = '2px';

            try {
                const str = await getString('error_ace_render_failed', 'filter_ace_inline');
                warningDiv.textContent = str;
            } catch {
                // Fallback if string loading fails
                warningDiv.textContent = 'Warning: Ace editor failed to render properly. Displaying plain text instead.';
            }

            pre.parentNode.insertBefore(warningDiv, pre);

            // Style the pre element to make it stand out
            pre.style.border = '2px solid #f44336';
            pre.style.padding = '10px';
            pre.style.display = 'block'; // Ensure it's visible
        }
    } else {
        pre.style.display = 'none';
    }
};

/**
 * Sets up Ace with all its parameters and adds a button if interactive.
 * @param {HTMLelement} pre The pre element that the Ace editor is replacing.
 * @param {Object} uiParameters The UI parameters from the Pre element + defaults.
 * @param {bool} isInteractive True if the code is interactive.
 * @return {HTMLelement} The editNode div element managed by Ace editor.
 */
const setUpAce = async(pre, uiParameters, isInteractive) => {
    const params = uiParameters.paramsMap;
    const darkMode = params['dark-theme-mode']; // 0, 1, 2 for never, sometimes, always
    let theme = null;
    // Use light or dark theme according to user's prefers-color-scheme.
    // Default to light.
    if (darkMode == 2 || (darkMode == 1 && globalThis.matchMedia &&
            globalThis.matchMedia("(prefers-color-scheme: dark)").matches)) {
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
    // The c_cpp mode gets a custom variant that additionally highlights
    // "_t"-suffixed and PascalCase identifiers as datatypes.
    const mode = aceLang === 'c_cpp' ? await getCDatatypeMode() : 'ace/mode/' + aceLang;
    const text = pre.textContent;
    const lines = text.split("\n");
    const numLines = lines.length;
    const longestLine = longest(lines);

    const editNode = document.createElement('div'); // Ace editor manages this
    editNode.style.margin = "6px 0px 6px 0px";
    editNode.style.lineHeight = "1.3";
    editNode.style.width = pre.style.width ? pre.style.width : "100%";
    editNode.style.minHeight = "30px"; // If Ace render fails, at least there's something there to click on!

    editNode.style.resize = "none";
    pre.after(editNode); // Insert the edit node

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

    const editor = globalThis.ace.edit(editNode, aceConfig);
    const session = editor.getSession();
    // Ace defers painting the text layer until it has measured font metrics; without
    // forcing a resize here it can be left blank when created on a freshly-inserted node.
    editor.resize(true);
    if (!pre.style.hasOwnProperty('width') || pre.style.width == 0) {
        const aceWidestLine = Math.ceil(lineLength(editor.renderer, longestLine));
        const minWidth = isInteractive ? aceWidestLine + LINE_NUMBER_COL_WIDTH : aceWidestLine;
        editNode.style.minWidth = minWidth + "px";
    }
    session.setValue(text);

    editor.setTheme(theme);
    if (params.readonly !== null) {
        editor.setReadOnly(true);
        editNode.classList.add('readonly'); // For CSS use.
    }

    // Add a button and text area for output if ace-interactive-code.
    if (isInteractive) {
        const getCode = () => editor.getSession().getValue();
        addUi(editNode, getCode, uiParameters);
    } else {
        editor.renderer.$cursorLayer.element.style.display = "none"; // Hide cursor.
    }

    return editNode;
};

/**
 * Return the length of the given line when rendered by the given Ace editor.
 * @param {Ace-renderer} renderer The Ace renderer.
 * @param {String} line The line whose length is being checked.
 * @return {int} The length of the rendered line in pixels.
 */
const lineLength = (renderer, line) => {
  const chars = renderer.session.$getStringScreenWidth(line)[0];
  const width = Math.max(chars, 2) * renderer.characterWidth + // Text size
    2 * renderer.$padding + // Padding
    2 + // Little extra for the cursor
    0; // Add border width if needed

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
