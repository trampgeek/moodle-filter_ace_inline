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


define(['jquery'], function($) {
    var RESULT_SUCCESS = 15;  // Code for a correct Jobe run.
    /**
     * Escape text special HTML characters.
     * @param {string} text
     * @returns {string} text with various special chars replaced with equivalent
     * html entities. Newlines are replaced with <br>.
     */
    function escapeHtml(text) {
      var map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;',
        ' ': '&nbsp;',
        "\n": '<br>'
      };

      return text.replace(/[&<>"' \n]/g, function(m) { return map[m]; });
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
        var attrName, attr, value, dataName;
        var uiParameters = {};

        for (attrName in defaultParams) {
            attr = pre.attributes.getNamedItem(attrName);
            if (attr) {
                dataName = attrName;
            } else {  // Try data- as a prefix if 'raw' access fails.
                dataName = 'data-' + attrName;
                attr = pre.attributes.getNamedItem(dataName);
            }
            if (attr) {
                value = attr.value;
                if (attrName === 'start-line-number') {
                    value = value.toLowerCase() === 'none' ? null : parseInt(value);
                }
            } else {
                value = defaultParams[attrName];
            }
            uiParameters[attrName] = value;
        }
        return uiParameters;
    }

    /**
     * Get the specified language string using
     * AJAX and plug it into the given textarea
     * @param {string} langStringName The language string name.
     * @param {DOMnode} textarea The textarea into which the error message
     * should be plugged.
     * @param {string} additionalText Extra text to follow the result code.
     */
    function setLangString(langStringName, textarea, additionalText) {
        require(['core/str'], function(str) {
            var promise = str.get_string(langStringName, 'filter_ace_inline');
            $.when(promise).then(function(message) {
                textarea.show();
                textarea.html(escapeHtml("*** " + message + " ***\n" + additionalText));
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
        var ERROR_RESPONSES = [
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
        for (var i=0; i < ERROR_RESPONSES.length; i++) {
            var row = ERROR_RESPONSES[i];
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
        var limit = s => s.length <= maxLen ? s : s.substr(0, maxLen) + '... (truncated)';
        return response.cmpinfo + limit(response.output) + limit(response.stderr);
    }

    /**
     * Handle a click on the Try it! button.
     * @param {object} ajax The core Moodle ajax module.
     * @param {html_element} outputDisplayArea The HTML <p> element in which to display output.
     * @param {object} aceSession The Ace editor session.
     * @param {int} uiParameters The various parameters (mostly attributes of the pre element).
     * Keys are button-name, lang, stdin, files, params, prefix, suffix, codemapper, html-output.
     */
    function handleButtonClick(ajax, outputDisplayArea, aceSession, uiParameters) {
        var htmlOutput = uiParameters['html-output'] !== null;
        var maxLen = uiParameters['max-output-length'];
        outputDisplayArea.html('');
        if (htmlOutput) {
            outputDisplayArea.hide();
        }
        var next = outputDisplayArea.next('div.filter-ace-inline-html');
        if (next) {
            next.remove();
        }
        var code = aceSession.getValue();
        var mapFunc = uiParameters['code-mapper'];
        if (mapFunc) {
            code = window[mapFunc](code);
        }
        code = uiParameters['prefix'] + code + uiParameters['suffix'];
        ajax.call([{
            methodname: 'qtype_coderunner_run_in_sandbox',
            args: {
                sourcecode: code,
                language: uiParameters['lang'],
                stdin: uiParameters['stdin'],
                files: uiParameters['files'],
                params: uiParameters['params']
            },
            done: function(responseJson) {
                var response = JSON.parse(responseJson);
                var error = diagnose(response);
                if (error === '') {
                    // If no errors or compilation error or runtime error
                    if (!htmlOutput || response.result !== RESULT_SUCCESS) {
                        // Either it's not HTML output or it is but we have compilation or runtime errors.
                        var text = combinedOutput(response, maxLen);
                        outputDisplayArea.show();
                        outputDisplayArea.html(escapeHtml(text));
                    } else { // Valid HTML output - just plug in the raw html to the DOM.
                        var html = $("<div class='filter-ace-inline-html '" +
                                "style='background-color:#eff;padding:5px;'" +
                                response.output + "</div>");
                        outputDisplayArea.after(html);
                    }
                } else {
                    // If an error occurs, display the language string in the
                    // outputDisplayArea plus additional info.
                    var extra = response.error == 0 ? combinedOutput(response, maxLen) : '';
                    if (error === 'error_unknown_runtime') {
                        extra += response.error ? '(Sandbox error code ' + response.error + ')' :
                                '(Run result: ' + response.result + ')';
                    }
                    setLangString(error, outputDisplayArea, extra);
                }
            },
            fail: function(error) {
                alert(error.message);
            }
        }]);
    }

    /**
     * Add a UI div containing a Try it! button and a paragraph to display the
     * results of a button click (hidden until button clicked).
     * If uiParameters['html-output'] is non-null,
     * the output paragraph is used only for error output, and the output of the run
     * is inserted directly into the DOM after the (usually hidden) paragraph.
     * @param {html_element} editNode The Ace edit node after which the div should be inserted.
     * @param {object} aceSession The Ace editor session.
     * @param {int} uiParameters The various parameters (mostly attributes of the pre element).
     * Keys are button-name, lang, stdin, files, params, prefix, suffix, html-output.
     */
    function addUi(editNode, aceSession, uiParameters) {
        var button = $("<div><button type='button' class='btn btn-secondary' " +
                "style='margin-bottom:6px;padding:2px 8px;'>" +
                uiParameters['button-name'] + "</button></div>");
        var outputDisplayArea = $("<p style='font-family:monospace; font-size:12px;width:100%;" +
                "background-color:#eff;border:1px gray;padding:5px;'></p>");
        editNode.after(button);
        button.after(outputDisplayArea);
        outputDisplayArea.hide();
        M.util.js_pending('core/ajax');
        require(['core/ajax'], function(ajax) {
            button.on('click', function() {
                handleButtonClick(ajax, outputDisplayArea, aceSession, uiParameters);
            });
        });
        M.util.js_complete('core/ajax');
    }


    /**
     * Replace any PRE elements of class ace-highlight-code with a
     * readonly Ace editor window.
     * @param {object} ace The JavaScript Ace editor object.
     * @param {DOMElement} root The root of the tree in which highlighting should
     * be applied.
     */
    function applyAceHighlighting(ace, root) {
        var defaultParams = {
            'lang': 'python3',
            'font-size': '11pt',
            'start-line-number': null,
            'readonly': true
        };
        applyAceAndBuildUi(ace, root, false, defaultParams);
    }

    /**
     * Replace any PRE elements of class ace-interactive-code with an
     * Ace editor window and a Try it! button that allows the code to be run.
     * @param {object} ace The JavaScript Ace editor object.
     * @param {DOMElement} root The root of the tree in which the actions should
     * be applied.
     * @param {object} config The plugin configuration (settings).
     */
    function applyAceInteractive(ace, root, config) {
        var defaultParams = {
            'lang': 'python3',
            'font-size': '11pt',
            'start-line-number': 1,
            'button-name': config['button_label'],
            'readonly': null,
            'stdin': '',
            'files': '',
            'prefix': '',
            'suffix': '',
            'params': '{"cputime": 5}',
            'code-mapper': null,
            'html-output': null,
            'max-output-length': 10000
        };
        applyAceAndBuildUi(ace, root, true, defaultParams);
    }

    /**
     * Replace all <pre> elements in the document rooted at root that have
     * the given className with an Ace editor windows that display the
     * code in whatever language has been set.
     * @param {object} ace The Ace editor code.
     * @param {object} root The root of the HTML document to modify.
     * @param {bool} isInteractive True for ace-interactive otherwise false.
     * @param {object} defaultParams An object defining the allowed pre attributes
     * that control the state of the Ace editor and the (optional) UI.
     */
    function applyAceAndBuildUi(ace, root, isInteractive, defaultParams) {
        var MAX_WINDOW_LINES = 50;
        var mode = "ace/mode/python"; // Default is Python.
        var className = isInteractive ? 'ace-interactive-code' : 'ace-highlight-code';
        var codeElements = root.getElementsByClassName(className);
        var css = {
            margin: "6px",
            "line-height": "1.3"
        };

        for (var i=0; i < codeElements.length; i++) {
            var pre = codeElements[i];
            if (pre.nodeName === 'PRE' && pre.style.display !== 'none') {
                let uiParameters = getUiParameters(pre, defaultParams);
                var showLineNumbers = uiParameters['start-line-number'] ? true : false;
                let jqpre = $(pre);
                var text = jqpre.text();
                var numLines = text.split("\n").length;

                let editNode = $("<div></div>"); // Ace editor manages this
                css['min-width'] = pre.offsetWidth;
                editNode.css(css);
                jqpre.after(editNode);    // Insert the edit node

                let aceConfig = {
                    newLineMode: "unix",
                    mode: mode,
                    minLines: numLines,
                    maxLines: MAX_WINDOW_LINES,
                    fontSize: uiParameters['font-size'],
                    showLineNumbers: showLineNumbers,
                    firstLineNumber: uiParameters['start-line-number'],
                    showGutter: showLineNumbers,
                    showPrintMargin: false,
                    autoScrollEditorIntoView: true,
                    highlightActiveLine: showLineNumbers
                };

                let editor = ace.edit(editNode.get(0), aceConfig);
                let session = editor.getSession();
                session.setValue(text);
                if (uiParameters.readonly !== null) {
                    editor.setReadOnly(true);
                }

                // Add a button and text area for output if ace-interactive-code.
                if (isInteractive) {
                    addUi(editNode, session, uiParameters);
                } else {
                    editor.renderer.$cursorLayer.element.style.display = "none"; // Hide cursor.
                }
                jqpre.hide();  // NB this sets display = 'none', checked above.
            }
        }
    }

    return {
        initAceInteractive: async function(config) {
            if (!window.ace_inline_code_interactive_done) { // Do it once only.
                while (!window.ace) {
                    await new Promise(resolve => setTimeout(resolve, 1000));
                }
                applyAceInteractive(window.ace, document, config);
                // Add a hook for use by dynamically generated content.
                window.applyAceInteractive = function () {
                    applyAceInteractive(window.ace, document, config);
                };
            }
            window.ace_inline_code_interactive_done = true;
        },
        initAceHighlighting: async function() {
            if (!window.ace_inline_code_highlighting_done) { // Do it once only.
                while (!window.ace) {
                    await new Promise(resolve => setTimeout(resolve, 1000));
                }
                applyAceHighlighting(window.ace, document);
                // Add a hook for use by dynamically generated content.
                window.applyAceHighlighting = function () {
                    applyAceHighlighting(window.ace, document);
                };
            }
            window.ace_inline_code_highlighting_done = true;
        }
    };
});