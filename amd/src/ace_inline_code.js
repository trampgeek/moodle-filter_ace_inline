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
     * Get the appropriate language string error message for the given resultCode using
     * AJAX and plug it into the given textarea.
     * @param {int} resultCode The 'result' field of the Jobe return value.
     * @param {DOMnode} textarea The textarea into which the error message
     * should be plugged.
     * @param {string} additionalText Extra text to follow the result code.
     */
    function setErrorMessage(resultCode, textarea, additionalText) {
        if (resultCode == 11) {
            setLangString('result_compilation_error', textarea, additionalText);
        } else if (resultCode == 12) {
            setLangString('result_runtime_error', textarea, additionalText);
        } else if (resultCode == 13) {
            setLangString('result_time_limit', textarea, additionalText);
        } else if (resultCode == 17) {
            setLangString('result_memory_limit', textarea, additionalText);
        } else if (resultCode == 21) {
            setLangString('result_server_overload', textarea, additionalText);
        } else {
            setLangString('result_unknown_error', textarea, additionalText);
        }
    }


    /**
     * Handle a click on the Try it! button.
     * @param {object} ajax The core Moodle ajax module.
     * @param {html_element} outputText The HTML <p> element in which to display output.
     * @param {object} aceSession The Ace editor session.
     * @param {int} uiParameters The various parameters (mostly attributes of the pre element).
     * Keys are button-name, lang, stdin, files, params, prefix, suffix, html-output.
     */
    function handleButtonClick(ajax, outputText, aceSession, uiParameters) {
        var htmlOutput = uiParameters['html-output'] !== null;
        outputText.html('');
        if (htmlOutput) {
            outputText.hide();
        }
        var next = outputText.next('div.filter-ace-inline-html');
        if (next) {
            next.remove();
        }
        var code = uiParameters.prefix + aceSession.getValue() + uiParameters.suffix;
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
                var text = response.cmpinfo + response.output + response.stderr;
                if (response.result === 15) { // Is it RESULT_SUCCESS?
                    if (htmlOutput) {
                        var html = $("<div class='filter-ace-inline-html '" +
                                "style='background-color:#EFF;padding:5px;" +
                                "margin-bottom:20px'>" +
                                response.output + "</div>");
                        outputText.after(html);
                    } else {
                        outputText.show();
                        outputText.html(escapeHtml(text));
                    }
                } else { // Oops. Plug in an error message instead.
                    setErrorMessage(response.result, outputText, text);
                }
            },
            fail: function(error) {
                alert("System error: please report: " + error.message + ' ' + error.debuginfo);
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
        var outputText = $("<p style='font-family:monospace; font-size:12px;width:100%; " +
                "background-color:white;border:1px gray;padding:5px;margin-bottom:20px'></p>");
        editNode.after(button);
        button.after(outputText);
        outputText.hide();
        M.util.js_pending('core/ajax');
        require(['core/ajax'], function(ajax) {
            button.on('click', function() {
                handleButtonClick(ajax, outputText, aceSession, uiParameters);
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
            'params': '{"cputime": 2}',
            'prefix': '',
            'suffix': '',
            'html-output': null
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
            width: "100%",
            margin: "6px",
            "margin-bottom": isInteractive ? "6px" : "20px",
            "line-height": "1.3"
        };

        for (var i=0; i < codeElements.length; i++) {
            var pre = codeElements[i];
            if (pre.nodeName === 'PRE'  && pre.closest("div[id^='question']")
                    && pre.style.display !== 'none') {
                let uiParameters = getUiParameters(pre, defaultParams);
                var showLineNumbers = uiParameters['start-line-number'] ? true : false;
                let jqpre = $(pre);
                var text = jqpre.text();
                var numLines = text.split("\n").length;

                let editNode = $("<div></div>"); // Ace editor manages this
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
                }
                jqpre.hide();  // NB this sets display = 'none', checked above.
            }
        }
    }

    return {
        initAceInteractive: async function(config) {
            while (!window.ace) {
                await new Promise(resolve => setTimeout(resolve, 1000));
            }
            applyAceInteractive(window.ace, document, config);
        },
        initAceHighlighting: async function() {
            while (!window.ace) {
                await new Promise(resolve => setTimeout(resolve, 1000));
            }
            applyAceHighlighting(window.ace, document);
        }
    };
});