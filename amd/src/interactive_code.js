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
     * @param {string} buttonName The label for the button.
     * @param {html_element} editNode The Ace edit node after which the div should be inserted.
     * @param {object} aceSession The Ace editor session.
     * @param {int} outputLines The number of lines to allocate to the output text area.
     */
    function addUi(buttonName, editNode, aceSession, outputLines) {
        var button = $("<div><button type='button' class='btn btn-secondary' " +
                "style='margin-bottom:6px;padding:2px 8px;'>" + buttonName + "</button></div>");
        var outputTextarea = $("<textarea readonly rows='" + outputLines +
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
                        language: 'python3',
                        stdin: ''
                    },
                    done: function(responseJson) {
                        var response = JSON.parse(responseJson);
                        var text = response.cmpinfo + response.output + response.stderr;
                        outputTextarea.val(text);
                    },
                    fail: function(error) {
                        alert("System error: please report: " + error);
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
        var codeElements = root.getElementsByClassName('ace-interactive-code');
        var mode = "ace/mode/python"; // Default is Python.
        var outputLines = 1;
        var showLineNumbers = true;
        var buttonName = config['button_label'];
        var editNode, editor, text, numLines;

        for (var i=0; i < codeElements.length; i++) {
            let pre = codeElements[i];
            // Only do not-yet-processed PRE elements within a question
            // (so not in author edit mode).
            if (pre.nodeName !== 'PRE' || pre.hasAttribute('processing-done') ||
                !pre.closest("div[id^='question']")) {
                continue;
            }

            let jqpre = $(pre);
            text = jqpre.html();
            numLines = text.split("\n").length;
            if (pre.hasAttribute("lang")) {
                mode = "ace/mode/" + pre.getAttribute("lang");
            }
            if (pre.hasAttribute("outputlines")) {
                outputLines = parseInt(pre.getAttribute("outputlines"));
            }
            if (pre.hasAttribute("hidelinenumbers")) {
                showLineNumbers = false;
            }
            if (pre.hasAttribute("showlinenumbers")) {
                showLineNumbers = true;
            }

            if (pre.hasAttribute("buttonname")) {
                buttonName = pre.getAttribute("buttonname");
            }

            editNode = $("<div></div>"); // Ace editor manages this
            editNode.css({
                width: "100%",
                margin: "6px",
                "line-height": "1.3"
            });

            jqpre.after(editNode);    // Insert the edit node

            editor = ace.edit(editNode.get(0), {
                newLineMode: "unix",
                mode: mode,
                maxLines: numLines,
                fontSize: "11pt",
                showLineNumbers: showLineNumbers,
                showGutter: showLineNumbers,
                highlightActiveLine: showLineNumbers
            });
            editor.$blockScrolling = Infinity;

            let session = editor.getSession();
            session.setValue(text);
            addUi(buttonName, editNode, session, outputLines);  // Add a button and text area for output.
            pre.setAttribute('processing-done', '');
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