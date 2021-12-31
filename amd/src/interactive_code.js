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
 * JavaScript for implementing the highlight_code functionality of the
 * ace_line filter (q.v.)
 *
 * @module filter_ace_inline/highlight_code
 * @copyright  Richard Lobb, 2021, The University of Canterbury
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */


define(['jquery'], function($) {
    /**
     * Add a UI div containing a Try it! button and a text area to display the
     * results of a button click.
     * @param {html_element} editNode The Ace edit node after which the div should be inserted.
     * @param {object} aceSession The Ace editor session.
     * @param {int} uiParameters The various parameters (mostly attributes of the pre element).
     * Keys are button-name, output-lines, lang, stdin, files, params.
     */
    function addUi(editNode, aceSession, uiParameters) {
        var button = $("<div><button type='button' class='btn btn-secondary' " +
                "style='margin-bottom:6px;padding:2px 8px;'>" +
                uiParameters['button-name'] + "</button></div>");
        var outputTextarea = $("<textarea readonly rows='" +
                uiParameters['output-lines'] +
                "' style='font-family:monospace; font-size:12px;width:100%'></textarea>");
        editNode.after(button);
        button.after(outputTextarea);
        M.util.js_pending('core/ajax');
        require(['core/ajax'], function(ajax) {
            button.on('click', function() {
                ajax.call([{
                    methodname: 'qtype_coderunner_run_in_sandbox',
                    args: {
                        sourcecode: aceSession.getValue(),
                        language: uiParameters['lang'],
                        stdin: uiParameters['stdin'],
                        files: uiParameters['files'],
                        params: uiParameters['params']
                    },
                    done: function(responseJson) {
                        var response = JSON.parse(responseJson);
                        var text = response.cmpinfo + response.output + response.stderr;
                        outputTextarea.val(text);
                    },
                    fail: function(error) {
                        alert("System error: please report: " + error.message + ' ' + error.debuginfo);
                    }
                }]);
            });
            M.util.js_complete('core/ajax');
        });
    }

    /**
     * Replace all <pre> elements in the document rooted at root that have
     * class ace-interactive-code with an Ace editor windows that display the
     * code in whatever language has been set. Also provide a Try it! button
     * that runs the code.
     * @param {object} ace The Ace editor code.
     * @param {object} root The root of the HTML document to modify.
     * @param {object} config the config parameters from the admin settings panel.
     */
    function applyAceInteractive(ace, root, config) {
        var mode = "ace/mode/python"; // Default is Python.
        let codeElements = root.getElementsByClassName('ace-interactive-code');

        var text, attrName, attr, numLines, value, dataName;
        var showLineNumbers;

        for (var i=0; i < codeElements.length; i++) {
            let uiParameters = {
                'lang': 'python3',
                'font-size': '11pt',
                'output-lines': 1,
                'start-line-number': 1,
                'button-name': config['button_label'],
                'stdin': '',
                'files': '',
                'params': ''
            };
            let pre = codeElements[i];
            if (pre.nodeName !== 'PRE' || pre.hasAttribute('data-processing-done') ||
                    !pre.closest("div[id^='question']")) {
                continue;
            }

            for (attrName in uiParameters) {
                dataName = 'data-' + attrName;
                attr = pre.attributes.getNamedItem(dataName);
                if (attr) {
                    value = attr.value;
                    if (attrName === 'start-line-number' && value.toLowerCase() === 'none') {
                        value = null;
                    } else if (attrName === 'start-line-number' || attrName === 'output-lines') {
                        value = parseInt(value);
                    }
                    uiParameters[attrName] = value;
                }
            }
            showLineNumbers = uiParameters['start-line-number'] ? true : false;
            let jqpre = $(pre);
            var text = jqpre.text();
            numLines = text.split("\n").length;

            let editNode = $("<div></div>"); // Ace editor manages this
            editNode.css({
                width: "100%",
                margin: "6px",
                "line-height": "1.3"
            });

            jqpre.after(editNode);    // Insert the edit node

            let aceConfig = {
                newLineMode: "unix",
                mode: mode,
                maxLines: numLines,
                fontSize: uiParameters['font-size'],
                showLineNumbers: showLineNumbers,
                showGutter: showLineNumbers,
                highlightActiveLine: showLineNumbers
            };
            if (showLineNumbers) {
                aceConfig['firstLineNumber'] = uiParameters['start-line-number'];
            }
            let editor = ace.edit(editNode.get(0), aceConfig);
            editor.$blockScrolling = Infinity;

            let session = editor.getSession();
            session.setValue(text);
            // Add a button and text area for output.
            addUi(editNode, session, uiParameters);
            pre.setAttribute('data-processing-done', '');
            jqpre.hide();

        }
    }

    return {
        init: function(config) {
            if (window.ace) {
                applyAceInteractive(window.ace, document, config);
            }
        }
    };
});