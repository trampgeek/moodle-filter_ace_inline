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
 * JavaScript for implementing both the ace_highlight_code and ace_interactive_code
 * functionality of the ace_line filter (q.v.)
 *
 * @module filter_ace_inline/highlight_code
 * @copyright  Richard Lobb, 2021, The University of Canterbury
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

/*jshint esversion: 8 */

define([], function() {
    const RESULT_SUCCESS = 15;  // Code for a correct Jobe run.
    const ACE_DARK_THEME = 'ace/theme/tomorrow_night';
    const ACE_LIGHT_THEME = 'ace/theme/textmate';
    const MIN_WINDOW_LINES = 1;
    const MAX_WINDOW_LINES = 50;
    const MAX_OUTPUT_LENGTH = 30000;

    let uploadFiles = {};
    /**
     * Escape text special HTML characters.
     * @param {string} text
     * @returns {string} text with various special chars replaced with equivalent
     * html entities. Newlines are replaced with <br>.
     */
    function escapeHtml(text) {
      const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
      };

      return text.replace(/[&<>"']/g, function(m) { return map[m]; });
    }

    /**
     * Extract from the given DOM pre element its various attributes.
     * @param {DOMElement} pre The <pre> element from the DOM.
     * @param {object} defaultParams An object with the default UI parameters.
     * @returns {object} The original defaultParams object with any attributes
     * that exist with in the <pre> element replaced by the pre element
     * attributes. As special cases if there is a start-line-number parameter
     * with the value 'none', start-line-number is set to null.
     */
    function getUiParameters(pre, defaultParams) {
        let uiParameters = {};
        let modifiedLang = false;

        for (const attrName in defaultParams) {
            if (defaultParams.hasOwnProperty(attrName)) { // Redundant but shuts up jshint
                let value = '', dataName = '';
                let attr = pre.attributes.getNamedItem(attrName);
                if (attr) {
                    dataName = attrName;
                } else {  // Try data- as a prefix if 'raw' access fails.
                    dataName = 'data-' + attrName;
                    attr = pre.attributes.getNamedItem(dataName);
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
                            modifiedLang = true; // Keeps track of modifications, so no overrides.
                            break;
                        default:
                            break;
                    }
                } else {
                    value = defaultParams[attrName];
                }
                uiParameters[attrName] = value;
            }
        }
        // Takes the data-lang from the class if edited using Prism TinyMCE editor filter.
        const splitClass = uiParameters['class'].split(" ");
        // Left open so can deal with more attributes if desired.
        splitClass.forEach((attribute) => {
            if (attribute.startsWith('language') && modifiedLang === false) {
                uiParameters['lang'] = attribute.replace('language-', '');
            }
        });
        return uiParameters;
    }

    /**
     * Get the specified language string and return a promise with the respective
     * language string output.
     * @param {string} langStringName The language string name.
     * should be plugged.
     * @returns {string} Promise with the language string output.
     */
    async function getLangString(langStringName) {
        return new Promise((resolve) => {
            require(['core/str'], function(str) {
                resolve(str.get_string(langStringName, 'filter_ace_inline'));
            });
        });
    }


    /**
     * Analyse the response for errors. There are two sorts of error: sandbox failures,
     * for which the field response.error is non-zero meaning the run didn't take
     * place at all and failures in the run
     * itself, such as compile errors, timeouts, runtime errors etc. The
     * various codes are documented in the CodeRunner file sandbox.php.
     * Some error returns, notably compilation error and runtime error, are not
     * treated as errors here, since the stdout + stderr should reveal what
     * happened anyway. More obscure errors are lumped together as 'Unknown
     * runtime error'.
     * @param {object} response The response from the web-service sandbox request.
     * @returns string The language string to use for an error message or '' if
     * no error message.
     */
    function diagnose(response) {
        // Table of error conditions.
        // Each row is response.error, response.result, langstring
        // response.result is ignored if response.error is non-zero.
        // Any condition not in the table is deemed an "Unknown runtime error".
        const ERROR_RESPONSES = [
            [1, 0, 'error_access_denied'], // Sandbox AUTH_ERROR
            [2, 0, 'error_unknown_language'], // Sandbox WRONG_LANG_ID
            [3, 0, 'error_access_denied'], // Sandbox ACCESS_DENIED
            [4, 0, 'error_submission_limit_reached'], // Sandbox SUBMISSION_LIMIT_EXCEEDED
            [5, 0, 'error_sandbox_server_overload'], // Sandbox SERVER_OVERLOAD
            [0, 11, ''], // RESULT_COMPILATION_ERROR
            [0, 12, ''], // RESULT_RUNTIME_ERROR
            [0, 13, 'error_timeout'], // RESULT TIME_LIMIT
            [0, RESULT_SUCCESS, ''], // RESULT_SUCCESS
            [0, 17, 'error_memory_limit'], // RESULT_MEMORY_LIMIT
            [0, 21, 'error_sandbox_server_overload'], // RESULT_SERVER_OVERLOAD
            [0, 30, 'error_excessive_output']  // RESULT OUTPUT_LIMIT
        ];
        for (const row of ERROR_RESPONSES) {
            if (row[0] == response.error && (response.error != 0 || response.result == row[1])) {
                return row[2];
            }
        }
        return 'error_unknown_runtime';
    }

    /**
     * Concatenates the cmpinfo, stdout and stderr fields of the sandbox
     * response, truncating both stdout and stderr to a given maximum length
     * if necessary (in which case '... (truncated)' is appended.
     * @param {object} response Sandbox response object
     * @param {int} maxLen The maximum length of the trimmed stringlen.
     */
    function combinedOutput(response, maxLen) {
        const limit = s => s.length <= maxLen ? s : s.substr(0, maxLen) + '... (truncated)';
        return response.cmpinfo + limit(response.output) + limit(response.stderr);
    }

    /**
     * Gets the uiParameter of 'stdin-taid' which should be the id of an element.
     * @param {object} uiParameters The various parameters (mostly attributes of the pre element)
     * @returns {string} The specified standard input or an empty string if no
     * stdin specified or null if not valid.
     */
    function getStdin(uiParameters) {
        const taid = uiParameters['stdin-taid'];
        const stdin = uiParameters.stdin;
        if (taid) {
            const box = document.querySelector('#' + taid);
            // Handles invalid textarea names.
            return box === null ? null : box.value;
        } else if (stdin) {
            return stdin;
        } else {
            return '';
        }
    }

    /**
     * Gets the uiParameter 'file-taids' and parses it if it is JSON. Promises an
     * arbitrary non-JSON object for error handling in the run_in_sandbox.php, else
     * promises a JSON object of appropriate mappings
     *
     * @param {object} uiParameters The various parameters (mostly attributes of the pre element)
     * @returns {string} An JSON-encoding of an object that defines one or more
     * filename:filecontents mappings.
     */
    async function getFiles(uiParameters) {
        let taids = uiParameters['file-taids'];
        let map = {};

        if (Object.keys(taids).length !== 0) {
            // Catches JSON parse errors for file names.
            try {
                taids = JSON.parse(taids);
            } catch (SyntaxError) {
                return Promise.resolve('error');
            }
            for (const filename in taids) {
                if (taids.hasOwnProperty(filename)) {
                    const id = taids[filename];
                    const file = document.querySelector('#' + id);
                    if (file === null) {
                        return Promise.resolve('bad_id');
                    } else {
                        map[filename] = file.value;
                    }
                }
            }
        }

        // Merge in any explicitly uploaded files.
        for (const name in uploadFiles) {
            if (uploadFiles.hasOwnProperty(name)) {
                map[name] = uploadFiles[name]; // Copy contents across.
            }
        }
        return Promise.resolve(JSON.stringify(map));
    }

    /**
     * Handle a click on the Try it! button; pre-checks the taids for valid ids.
     * @param {html_element} outputDisplayArea The HTML <p> element in which to display output.
     * @param {string} code The code to be run.
     * @param {int} uiParameters The various parameters (mostly attributes of the pre element).
     * Keys are button-name, lang, stdin, files, params, prefix, suffix, codemapper, html-output.
     * @returns {string} code of the code to run, else null but executes errors if needed.
     */
    async function handleButtonClick(outputDisplayArea, code, uiParameters) {
        cleanOutput(outputDisplayArea);
        outputDisplayArea.style.display = '';

        const mapFunc = uiParameters['code-mapper'];
        if (mapFunc) {
            code = window[mapFunc](code);
        }
        code = uiParameters.prefix + code + uiParameters.suffix;
        // Get the parameters by parsing.
        const stdin = getStdin(uiParameters);
        const files = await getFiles(uiParameters);
        // If html/markup is the chosen language; change uiParameters and wrap in Python.
        if ((uiParameters['lang'] === 'markup') || (uiParameters['lang'] === 'html')) {
            outputDisplayArea.setAttribute('class', 'filter-ace-inline-output-html');
            // Save for returning to old language.
            uiParameters['prev-lang'] = uiParameters['lang'];
            uiParameters['html-output'] = true;
            uiParameters['lang'] = 'python3';
            code = "print('''" + code + "''')";
            return code;
        }
        // If textareas are found, pass in the output areas into the UI parameters.
        if (stdin !== null && files !== 'bad_id' ) {
            uiParameters['stdin-parse'] = stdin;
            uiParameters['file-parse'] = files;
            return code;
        } else {
            // Make it display an error.
            outputDisplayArea.setAttribute('class', 'filter-ace-inline-output-user');
            let text = await getLangString('error_user_params');
            text = '*** ' + text + ' ***\n' + await getLangString('error_element_unknown');
            outputDisplayArea.children.item(0).innerHTML = escapeHtml(text);
            return null;
        }
    }

    /**
     * Executes the code through CodeRunner run_in_sandbox.
     * @param {object} ajax The core Moodle ajax module.
     * @param {html_element} outputDisplayArea The HTML <p> element in which to display output.
     * @param {string} code The code to be run.
     * @param {int} uiParameters The various parameters (mostly attributes of the pre element).
     * Keys are button-name, lang, stdin, files, params, prefix, suffix, codemapper, html-output.
     */
    async function executeCode(ajax, outputDisplayArea, code, uiParameters) {
        const htmlOutput = uiParameters['html-output'] !== null;
        const maxLen = uiParameters['max-output-length'];
        let text = '';
        let langString = '';
        ajax.call([{
            methodname: 'qtype_coderunner_run_in_sandbox',
            args: {
                contextid: M.cfg.contextid,
                sourcecode: code,
                language: uiParameters.lang,
                stdin: uiParameters['stdin-parse'],
                files: uiParameters['file-parse'],
                params: uiParameters.params
            },
            done: function(responseJson) {
                cleanOutput(outputDisplayArea);
                const response = JSON.parse(responseJson);
                const error = diagnose(response);
                if (error === '') {
                    // If no errors or compilation error or runtime error.
                    if (!htmlOutput || response.result !== RESULT_SUCCESS) {
                        // Either it's not HTML output or it is but we have compilation or runtime errors.
                        text += combinedOutput(response, maxLen);
                        // If there is an execution error, change the output class.
                        if (response.result !== RESULT_SUCCESS) {
                            outputDisplayArea.setAttribute('class', 'filter-ace-inline-output-error');
                        }
                    } else { // Valid HTML output - just plug in the raw html to the DOM.
                        outputDisplayArea.setAttribute('class', 'filter-ace-inline-output-html');
                        const html = createComponent('div', ['filter-ace-inline-html'], {});
                        html.innerHTML = response.output;
                        outputDisplayArea.after(html);
                    }
                } else {
                    // If an error occurs, display the language string in the
                    // outputDisplayArea plus additional info, for non-sandbox errors.
                    outputDisplayArea.setAttribute('class', 'filter-ace-inline-output-error');
                    let extra = response.error == 0 ? combinedOutput(response, maxLen) : '';
                    if (error === 'error_unknown_runtime') {
                        extra += response.error ? '(Sandbox error code ' + response.error + ')' :
                            '(Run result: ' + response.result + ')';
                    }
                    langString += error;
                    text += extra;
                }
               displayTextOutput(text, langString, outputDisplayArea);
            },
            fail: function(error) {
                cleanOutput(outputDisplayArea);
                // Change the outputDisplayArea to something more ominious...
                outputDisplayArea.setAttribute('class', 'filter-ace-inline-output-user');
                langString += 'error_user_params';
                text += error.message;
                displayTextOutput(text, langString, outputDisplayArea);
            },
        }]);
    }

    /**
     * Displays the text in the specified outputdisplay area.
     * @param {string} text Test to be displayed
     * @param {string} langString LangString for error-handling.
     * @param {html_element} outputDisplayArea The HTML <p> element in which to display output.
     */
    async function displayTextOutput(text, langString, outputDisplayArea) {
        if (langString !== '') {
            text = "*** " + await getLangString(langString) + " ***\n" + text;
        }
        outputDisplayArea.children.item(0).innerHTML = escapeHtml(text);
    }

    /**
     * Cleans the outputDisplayArea and resets to normal, removing any next nodes found.
     * html objects.
     * @param {type} outputDisplayArea Resets the output box.
     */
    function cleanOutput(outputDisplayArea) {
        outputDisplayArea.children.item(0).innerHTML = '';
        const potentialHtml = outputDisplayArea.nextElementSibling;
        if (potentialHtml !== null) {
            if (potentialHtml.class === 'filter-ace-inline-html') {
                 outputDisplayArea.nextElementSibling.remove();
            }
        }
        outputDisplayArea.setAttribute('class', 'filter-ace-inline-output-display');
    }

    /**
     * Add a UI div containing a Try it! button and a paragraph to display the
     * results of a button click (hidden until button clicked).
     * If uiParameters['html-output'] is non-null,
     * the output paragraph is used only for error output, and the output of the run
     * is inserted directly into the DOM after the (usually hidden) paragraph.
     * @param {html_element} insertionPoint The HTML element after which the div should be inserted.
     * @param {function} getCode A function that retrieves the code to be run.
     * @param {int} uiParameters The various parameters (mostly attributes of the pre element).
     * Keys are button-name, lang, stdin, files, params, prefix, suffix, html-output.
     */
    async function addUi(insertionPoint, getCode, uiParameters) {
        // Create the button-node for execution.
        const button = createComponent('button', ['btn', 'btn-secondary', 'btn-ace-inline-execution'], {'type' :
                'button'});
        button.innerHTML = uiParameters['button-name'];
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
        M.util.js_pending('core/ajax');
        require(['core/ajax'], function(ajax) {
            button.addEventListener('click', async function() {
                const code = await handleButtonClick(outputDisplayArea, getCode(), uiParameters);
                // UI parameters get checked first; and if no error, then returns code.
                if (code !== null) { // If there was an error.
                    executeCode(ajax, outputDisplayArea, code, uiParameters);
                    // Return to old language.
                    uiParameters['lang'] = uiParameters['prev-lang'] ? uiParameters['prev-lang'] : uiParameters['lang'];
                }
            });
        });
        M.util.js_complete('core/ajax');
    }

    /**
     * Creates elements en masse by taking an elementName and adding classes
     * and attributes to it.
     *
     * @param {type} elementName
     * @param {type} classList
     * @param {type} attributeArray
     * @returns {Element}
     */
    function createComponent(elementName, classList, attributeArray) {
        const element = document.createElement(elementName);
        classList.forEach(htmlClass => element.classList.add(htmlClass));
        for (const attribute in attributeArray) {
            element.setAttribute(attribute, attributeArray[attribute]);
        }
        return element;
    }


    /**
     * Replace any PRE elements of class ace-highlight-code with a
     * readonly Ace editor window.
     * @param {DOMElement} root The root of the tree in which highlighting should
     * be applied.
     * @param {string} config The plugin configuration settings.
     */
    function applyAceHighlighting(root, config) {
        const defaultParams = {
            'class': 'ace_highlight_code',
            'lang': 'python3',
            'ace-lang': '',
            'font-size': '11pt',
            'start-line-number': null,
            'min-lines': MIN_WINDOW_LINES,
            'max-lines': MAX_WINDOW_LINES,
            'readonly': true,
            'dark-theme-mode': config.dark_theme_mode  // 0, 1, 2 for never, sometimes, always
        };
        applyAceAndBuildUi(root, false, defaultParams);
    }

    /**
     * Replace any PRE elements of class ace-interactive-code with an
     * Ace editor window and a Try it! button that allows the code to be run.
     * @param {DOMElement} root The root of the tree in which the actions should
     * be applied.
     * @param {string} config The plugin configuration settings.
     */
    function applyAceInteractive(root, config) {
        const defaultParams = {
            'class': 'ace_interactive_code',
            'lang': 'python3',
            'ace-lang': '',
            'font-size': '11pt',
            'hidden': false,
            'start-line-number': 1,
            'button-name': config.button_label,
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
            'dark-theme-mode': config.dark_theme_mode  // 0, 1, 2 for never, sometimes, always
        };
        applyAceAndBuildUi(root, true, defaultParams);
    }

    /**
     * Return the length of the given line when rendered by the given Ace editor.
     * @param {Ace-renderer} renderer The Ace renderer.
     * @param {String} line The line whose length is being checked.
     * @return {int} The length of the rendered line in pixels.
     */
    function lineLength(renderer, line) {
      const chars = renderer.session.$getStringScreenWidth(line)[0];
      const width = Math.max(chars, 2) * renderer.characterWidth + // text size
        2 * renderer.$padding + // padding
        2  + // little extra for the cursor
        0; // add border width if needed

      return width;
    }

    /**
     * Return the longest of an array of strings.
     * @param {array} lines An array of lines
     * @return {String} The longest of the lines
     */
    function longest(lines) {
        let longest = '';
        for (const line of lines) {
            if (line.length > longest.length) {
                longest = line;
            }
        }
        return longest;
    }

    /**
     * Set up an onchange handler for file uploads. When the user selects
     * a file, a FileReader is created to read the contents. While the read
     * is in progress, a data-busy attribute is set. When the read is complete
     * a data-file-contents object is defined to map name to contents.
     * @param {HTMLelement} uploadElementId The input element of type file.
     */
    async function setupFileHandler(uploadElementId) {

        /**
         * Read a single file.
         * @param {file} file A file from an 'input type=file' element filelist.
         * @returns {Promise} A promise wrapping the given file's contents.
         */
        function readOneFile(file){
            return new Promise((resolve, reject) => {
              let rdr = new FileReader();
              rdr.onload = () => {
                resolve(rdr.result);
              };
              rdr.onerror = reject;
              rdr.readAsText(file);
            });
        }

        const element = document.querySelector('#' + uploadElementId);
        element.setAttribute('multiple', '1');  // Workaround for the fact Moodle strips this.
        element.addEventListener('change', async () => {
            uploadFiles = {};
            const files = element.files;
            for (const file of files) {
                uploadFiles[file.name] = await readOneFile(file);
            }
        });
    }


    /**
     *
     * @param {html element} pre The pre element that the Ace editor is replacing.
     * @param {object} uiParameters The UI parameters from the Pre element + defaults.
     * @param {bool} isInteractive True if the code is interactive.
     */
    async function setUpAce(pre, uiParameters, isInteractive) {
        const aceModeMap = {  // Ace modes for various languages (default: use language name).
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
        const darkMode = uiParameters['dark-theme-mode']; // 0, 1, 2 for never, sometimes, always
        let theme = null;

        // Use light or dark theme according to user's prefers-color-scheme.
        // Default to light.
        if (darkMode == 2 || (darkMode == 1 && window.matchMedia &&
                window.matchMedia("(prefers-color-scheme: dark)").matches)) {
            theme = ACE_DARK_THEME;
        } else {
            theme = ACE_LIGHT_THEME;
        }
        // Handle the one case of python3 in JOBE.
        uiParameters.lang = uiParameters.lang === 'python' ? 'python3' : uiParameters.lang;
        const showLineNumbers = uiParameters['start-line-number'] ? true : false;
        let aceLang = uiParameters['ace-lang'] ? uiParameters['ace-lang'] : uiParameters.lang;
        aceLang = aceLang.toLowerCase();
        if (aceLang in aceModeMap) {
            aceLang = aceModeMap[aceLang];
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
            minLines: Math.max(numLines, uiParameters['min-lines']),
            maxLines: uiParameters['max-lines'],
            fontSize: uiParameters['font-size'],
            showLineNumbers: showLineNumbers,
            firstLineNumber: uiParameters['start-line-number'],
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
        if (uiParameters.readonly !== null) {
            editor.setReadOnly(true);
        }

        // Add a button and text area for output if ace-interactive-code.
        if (isInteractive) {
            const getCode = () => editor.getSession().getValue();
            addUi(editNode, getCode, uiParameters);
        } else {
            editor.renderer.$cursorLayer.element.style.display = "none"; // Hide cursor.
        }
    }

    /**
     * Replace the given PRE element with an element managed by the Ace editor,
     * unless 'hidden' is true, in which case we just hide the PRE.
     * @param {HTMLelement} pre The PRE element to be be replaced by an Ace editor.
     * @param {bool} isInteractive True for ace-interactive otherwise false.
     * @param {type} uiParameters the User Interface parameters for the element.
     */
    async function applyToPre(pre, isInteractive, uiParameters) {
        if (uiParameters['file-upload-id']) {
            setupFileHandler(uiParameters['file-upload-id']);
        }

        if (!uiParameters.hidden) {
            setUpAce(pre, uiParameters, isInteractive);
        } else if (isInteractive) { // Code is hidden but there's still a button to run it.
            const getCode = () => pre.text();
            addUi(pre, getCode, uiParameters);
        }

        pre.style.display = 'none';  // NB this sets display = 'none', checked above.
    }

    /**
     * Replace all <pre> and <code> elements in the document rooted at root that have
     * the given className or ace-inline attribute, with an Ace editor windows that display the
     * code in whatever language has been set.
     * @param {object} root The root of the HTML document to modify.
     * @param {bool} isInteractive True for ace-interactive otherwise false.
     * @param {object} defaultParams An object defining the allowed pre attributes
     * that control the state of the Ace editor and the (optional) UI.
     */
    async function applyAceAndBuildUi(root, isInteractive, defaultParams) {
        const className = isInteractive ? 'ace-interactive-code' : 'ace-highlight-code';
        const alternativeName = isInteractive ? 'data-ace-interactive-code' : 'data-ace-highlight-code';
        const preElements = root.getElementsByTagName('pre');
        for (const pre of preElements) {
            if (pre.style.display !== 'none') {
                if (pre.classList.contains(className) || pre.hasAttribute(alternativeName)) {
                    applyToPre(pre, isInteractive, getUiParameters(pre, defaultParams));
                }
            }
        }
        // For Markdown compatibility.
        const codeElements = root.getElementsByTagName('code');
        for (const code of codeElements) {
            if (code.parentNode !== null && code.style.display !== 'none' &&
                    (code.hasAttribute(alternativeName) || code.classList.contains(className))) {
                applyToPre(code.parentNode, isInteractive, getUiParameters(code, defaultParams));
            }
        }
    }

    return {
        initAceInteractive: async function(config) {
            if (!window.ace_inline_code_interactive_done) { // Do it once only.
                window.ace_inline_code_interactive_done = true;
                while (!window.ace) {
                    await new Promise(resolve => setTimeout(resolve, 1000));
                }
                applyAceInteractive(document, config);
                // Add a hook for use by dynamically generated content.
                window.applyAceInteractive = function () {
                    applyAceInteractive(document, config);
                };
            }
        },
        initAceHighlighting: async function(config) {
            if (!window.ace_inline_code_highlighting_done) { // Do it once only.
                window.ace_inline_code_highlighting_done = true;
                while (!window.ace) {
                    await new Promise(resolve => setTimeout(resolve, 1000));
                }
                applyAceHighlighting(document, config);
                // Add a hook for use by dynamically generated content.
                window.applyAceHighlighting = function () {
                    applyAceHighlighting(document, config);
                };
            }
        }
    };
});