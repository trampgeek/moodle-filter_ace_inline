d/**
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
     * class ace-interactive-code with an Ace editor windows that display the
     * code in whatever language has been set. Also provide a Try it! button
     * that runs the code.
     * @param {object} ace The Ace editor code.
     * @param {object} root The root of the HTML document to modify.
     */
    function applyAceInteractive(ace, root) {
    }

    return {
        init: function(config) {
            if (window.ace) {
                applyAceInteractive(ace, document);
            }
        }
    };
});