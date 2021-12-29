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
     * Replace all <pre> elements in the document rooted at root that have
     * class ace-highlight-code with Ace editor windows that display the
     * code in whatever language has been set.
     * @param {object} ace The Ace editor code.
     * @param {object} root The root of the HTML document to modify.
     */
    function applyAceHighlighting(ace, root) {
        var highlight = ace.require("ace/ext/static_highlight");
        var codeElements = root.getElementsByClassName('ace-highlight-code');

        for (var i=0; i < codeElements.length; i++) {
            let element = codeElements[i];
            // Make sure we don't apply style twice, and do it only in moodle questions.
            if (element.hasAttribute("ace-highlight-done") || !element.closest("div[id^='question']")) {
                  continue;
            }

            var mode = "ace/mode/python";
            if (element.hasAttribute("lang")) {
                mode = "ace/mode/" + element.getAttribute("lang");
            }

            var startLineNumber = 1;
            if (element.hasAttribute("start-line-number")) {
                startLineNumber = parseInt(element.getAttribute("start-line-number"));
            }

            highlight(element, {
                mode: mode,
                showGutter: (element.hasAttribute("show-line-numbers") || element.classList.contains("show-line-numbers")),
                firstLineNumber: startLineNumber
            }, function(highlighted) {
                    var fontSize = "14px";
                    if (element.hasAttribute("font-size")) {
                        fontSize = element.getAttribute("font-size");
                    }
                    var children = element.getElementsByClassName('ace_static_highlight');
                    if (children.length > 0) {  // How can there not be children?!
                        children[0].style['font-size'] = fontSize ;
                    } else {
                    }
                    element.setAttribute('ace-highlight-done', '');
            });
        }
    }

    return {
        init: function(config) {
            if (window.ace) {
                applyAceHighlighting(ace, document);
            }
        }
    };
});