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
    const RESULT_SUCCESS = 15;  // Code for a correct Jobe run.
    const ACE_DARK_THEME = 'ace/theme/tomorrow_night';
    const ACE_LIGHT_THEME = 'ace/theme/textmate';
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
        outputDisplayArea.next('div.filter-ace-inline-html').remove();

        var code = aceSession.getValue();
        var mapFunc = uiParameters['code-mapper'];
        if (mapFunc) {
            code = window[mapFunc](code);
        }
        code = uiParameters.prefix + code + uiParameters.suffix;
        ajax.call([{
            methodname: 'qtype_coderunner_run_in_sandbox',
            args: {
                contextid: M.cfg.contextid,
                sourcecode: code,
                language: uiParameters.lang,
                stdin: uiParameters.stdin,
                files: uiParameters.files,
                params: uiParameters.params
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
                        // Repeat the deletion of previous output in case of multiple button clicks.
                        outputDisplayArea.next('div.filter-ace-inline-html').remove();
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
        var button = $("<button type='button' class='btn btn-secondary' " +
                "style='margin-bottom:6px;padding:2px 8px;'>" +
                uiParameters['button-name'] + "</button>");
        var buttonDiv = $("<div></div>");
        var outputDisplayArea = $("<pre style='width:100%;white-space:pre-wrap;background-color:#eff;" +
                "border:1px gray;padding:5px;overflow-wrap:break-word;max-height:600px;overflow:auto;'></pre>");
        buttonDiv.append(button);
        editNode.after(buttonDiv);
        buttonDiv.after(outputDisplayArea);
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
     * @param {DOMElement} root The root of the tree in which highlighting should
     * be applied.
     * @param {string} config The plugin configuration settings.
     */
    function applyAceHighlighting(root, config) {
        var defaultParams = {
            'lang': 'python3',
            'ace-lang': '',
            'font-size': '11pt',
            'start-line-number': null,
            'readonly': true,
            'dark_theme_mode': config['dark_theme_mode']  // 0, 1, 2 for never, sometimes, always
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
        var defaultParams = {
            'lang': 'python3',
            'ace-lang': '',
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
            'max-output-length': 30000,
            'dark_theme_mode': config['dark_theme_mode']  // 0, 1, 2 for never, sometimes, always
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
      var chars = renderer.session.$getStringScreenWidth(line)[0];

      var width = Math.max(chars, 2) * renderer.characterWidth // text size
        + 2 * renderer.$padding // padding
        + 2  // little extra for the cursor
        + 0; // add border width if needed

      return width;
    }

    /**
     * Return the longest of an array of strings.
     * @param {array} lines An array of lines
     * @return {String} The longest of the lines
     */
    function longest(lines) {
        var longest = '';
        for (var i = 0; i < lines.length; i++) {
            if (lines[i].length > longest.length) {
                longest = lines[i];
            }
        }
        return longest;
    }
    /**
     * Replace the given PRE element with an element managed by the Ace editor.
     * @param {type} pre The PRE element to be be replaced by an Ace editor.
     * @param {bool} isInteractive True for ace-interactive otherwise false.
     * @param {type} theme Ace theme to use
     * @param {type} uiParameters the User Interface parameters for the element.
     */
    function applyToPre(pre, isInteractive, theme, uiParameters) {
        var MAX_WINDOW_LINES = 50;
        var aceModeMap = {  // Ace modes for various languages (default: use language name).
            'c': 'c_cpp',
            'cpp': 'c_cpp',
            'js': 'javascript',
            'nodejs': 'javascript',
            'c#': 'cs',
            'octave': 'matlab',
            'c++': 'c_cpp',
            'python2': 'python',
            'python3': 'python'
        };
        var showLineNumbers = uiParameters['start-line-number'] ? true : false;
        var aceLang = uiParameters['ace-lang'] ? uiParameters['ace-lang'] : uiParameters['lang'];
        aceLang = aceLang.toLowerCase();
        if (aceLang in aceModeMap) {
            aceLang = aceModeMap[aceLang];
        }
        var mode = 'ace/mode/' + aceLang;
        var jqpre = $(pre);
        var text = jqpre.text();
        var lines = text.split("\n");
        var numLines = lines.length;
        var longestLine = longest(lines);

        var editNode = $("<div></div>"); // Ace editor manages this
        var width = pre.scrollWidth;  // Our first guess at a minimum width.
        var css = {
            "margin": "6px 0px 6px 0px", // Top, right, bottom, left
            "line-height": "1.3",
            "min-width": width + "px"
        };
        editNode.css(css);
        jqpre.after(editNode);    // Insert the edit node

        var aceConfig = {
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

        var editor = window.ace.edit(editNode.get(0), aceConfig);
        var session = editor.getSession();
        var aceWidestLine = lineLength(editor.renderer, longestLine);
        if (aceWidestLine > width) {
            editNode.css({'min-width': Math.ceil(aceWidestLine) + "px"});
        }
        session.setValue(text);
        editor.setTheme(theme);
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

        // After rendering, update the container min-width if the rendered
        // length of the longest lines exceeds the preset min-width.

    }

    /**
     * Replace all <pre> elements in the document rooted at root that have
     * the given className with an Ace editor windows that display the
     * code in whatever language has been set.
     * @param {object} root The root of the HTML document to modify.
     * @param {bool} isInteractive True for ace-interactive otherwise false.
     * @param {object} defaultParams An object defining the allowed pre attributes
     * that control the state of the Ace editor and the (optional) UI.
     */
    function applyAceAndBuildUi(root, isInteractive, defaultParams) {
        var className = isInteractive ? 'ace-interactive-code' : 'ace-highlight-code';
        var codeElements = root.getElementsByClassName(className);
        var darkMode = defaultParams['dark_theme_mode']; // 0, 1, 2 for never, sometimes, always
        var theme = null;

        // Use light or dark theme according to user's prefers-color-scheme.
        // Default to light.
        if (darkMode == 2 || (darkMode == 1 && window.matchMedia &&
                window.matchMedia("(prefers-color-scheme: dark)").matches)) {
            theme = ACE_DARK_THEME;
        } else {
            theme = ACE_LIGHT_THEME;
        }

        for (let i=0; i < codeElements.length; i++) {
            let pre = codeElements[i];
            let uiParameters = getUiParameters(pre, defaultParams);
            if (pre.nodeName === 'PRE' && pre.style.display !== 'none') {
                applyToPre(pre, isInteractive, theme, uiParameters);
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