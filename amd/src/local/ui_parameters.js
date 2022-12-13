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
 * JavaScript for the uiParameters class.
 *
 * @module     filter_ace_inline/local/ui_parameters
 * @copyright  Richard Lobb, Michelle Hsieh 2022
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

const MIN_WINDOW_LINES = 1;
const MAX_WINDOW_LINES = 50;
const MAX_OUTPUT_LENGTH = 30000;

// Ace highlight parameters.
const ACE_HIGHLIGHT = {
    'class': 'ace_highlight_code',
    'lang': 'python3',
    'ace-lang': '',
    'font-size': '11pt',
    'start-line-number': null,
    'min-lines': MIN_WINDOW_LINES,
    'max-lines': MAX_WINDOW_LINES,
    'readonly': true,
    'dark-theme-mode': null
};

// Ace interactive parameters.
const ACE_INTERACTIVE = {
    'class': 'ace_interactive_code',
    'lang': 'python3',
    'ace-lang': '',
    'font-size': '11pt',
    'hidden': false,
    'start-line-number': 1,
    'button-name': 'Try it!',
    'readonly': null,
    'stdin': '',
    'stdin-taid': '',
    'file-taids': {},
    'file-upload-id': null,
    'prefix': '',
    'suffix': '',
    'params': '{"cputime": 5}',
    'code-mapper': null,
    'html-output': null,
    'min-lines': MIN_WINDOW_LINES,
    'max-lines': MAX_WINDOW_LINES,
    'max-output-length': MAX_OUTPUT_LENGTH,
    'dark-theme-mode': null
};

/**
 * Class for the UiParameters; stores the UiParameters and variables
 * required for UiParameters parsing. Makes it according to the type
 * required (highlight/interactive).
 * @type Object containing UiParameters.
 */
export class UiParameters {
    constructor(pre) {
        this.pre = pre;
        this.paramsMap = {};
        this.modifiedLang = false;
        this.execLang = null;
        this.stdin = '';
        this.files = null;
        this.htmlOutput = null;
        this.sandboxParams = [];
    }

    /**
     * Extract from the given DOM pre element its various attributes.
     * @param {boolean} isInteractive True if is interactive, else false.
     * @param {array} config Config for buttons and darkmode.
     */
    extractUiParameters(isInteractive, config) {
        // Adds defaults.
        if (isInteractive) {
            this.paramsMap['button-name'] = config.button_label;
        }
        const defaultParams = isInteractive ? ACE_INTERACTIVE : ACE_HIGHLIGHT;

        for (const attrName in defaultParams) {
            if (defaultParams.hasOwnProperty(attrName)) {
                let value = '', dataName = '';
                let attr = this.pre.attributes.getNamedItem(attrName);
                if (attr) {
                    dataName = attrName;
                } else {  // Try data- as a prefix if 'raw' access fails.
                    dataName = 'data-' + attrName;
                    attr = this.pre.attributes.getNamedItem(dataName);
                }
                if (attr) {
                    value = attr.value;
                    switch (attrName) {
                        case 'start-line-number':
                            value = value.toLowerCase() === 'none' ? null : parseInt(value);
                            break;
                        case 'min-lines':
                        case 'max-lines':
                            value = parseInt(value);
                            break;
                        case 'hidden':
                            value = true; // If the 'hidden' attribute exists, it's True!
                            break;
                        case 'lang':
                            this.modifiedLang = true; // Keeps track of modifications, so no overrides.
                            break;
                        default:
                            break;
                    }
                } else {
                value = defaultParams[attrName];
                }
            this.paramsMap[attrName] = value;
            }
        }

        // Sets dark theme according to config if not previously set.
        if (this.paramsMap['dark-theme-mode'] === null) {
            this.paramsMap['dark-theme-mode'] = config.dark_theme_mode;  // 0, 1, 2 for never, sometimes, always
        }
        // Extracts the Tiny Parameters out.
        this.extractTinyParams();
    }

    /**
     * Extract the language from the TinyMCE code editor.
     */
    extractTinyParams() {
        // Takes the data-lang from the class if edited using Prism TinyMCE editor filter.
        const splitClass = this.paramsMap['class'].split(" ");
        // Left open so can deal with more attributes if desired.
        splitClass.forEach((attribute) => {
            if (attribute.startsWith('language') && this.modifiedLang === false) {
                this.paramsMap['lang'] = attribute.replace('language-', '');
            }
        });
        // Handle the one case of python3 in JOBE.
        if (this.paramsMap['lang'] === 'python') {
            this.paramsMap['lang'] = 'python3';
        }
    }

    /**
     * Sets the uiParameter of stdin 'stdin-taid' which should be the id of an element.
     */
    setStdin() {
        const taid = this.paramsMap['stdin-taid'];
        const stdin = this.paramsMap.stdin;
        if (taid) {
            const box = document.querySelector('#' + taid);
            // Handles invalid textarea names.
            if (box === null) {
                this.stdin = null;
            } else {
                this.stdin = box.value;
            }
        } else if (stdin) {
            this.stdin = stdin;
        } else {
            this.stdin = '';
        }
    }

    /**
     * Sets the uiParameter of files.
     *
     * @param {type} files The files to be processed.
     */
    setFiles(files) {
        this.files = files;
    }

    /**
     * Sets the execution language.
     *
     * @param {type} lang The coding language to be used.
     */
    setExecLang(lang) {
        this.execLang = lang;
    }

    /**
     * Sets HTML output.
     *
     * @param {type} hasHtml If not null, there is Html output.
     */
    setHtmlOutput(hasHtml) {
        this.htmlOutput = hasHtml;
    }

    /**
     * Sets the uiParams' params Array to all files.
     *
     * @param {Array} paramsArray An array of all the filenames used.
     */
    setSandboxParams(paramsArray) {
        this.sandboxParams = paramsArray;
    }

    /**
     * Sets run-params in the paramsMap to be executed on run.
     *
     * @param {String} paramsString A JSON-compliant params string.
     */
    setRunParams(paramsString) {
        this.paramsMap['run-params'] = paramsString;
    }
}
