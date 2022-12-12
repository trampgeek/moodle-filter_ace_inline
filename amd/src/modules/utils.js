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
 * JavaScript for all the utility functions.
 *
 * @module     filter_ace_inline/utils
 * @copyright  Richard Lobb, Michelle Hsieh 2022
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

import {get_string as getString} from 'core/str';

const RESULT_SUCCESS = 15;  // Code for a correct Jobe run.

/**
 * Get the specified language string and return a promise with the respective
 * language string output.
 * @param {string} langStringName The language string name.
 * should be plugged.
 * @returns {string} Promise with the language string output.
 */
export const getLangString = async (langStringName) =>
    getString(langStringName, 'filter_ace_inline')
            .catch();

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
export const diagnose = (response) => {
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
};

/**
 * Escape text special HTML characters.
 * @param {string} text
 * @returns {string} text with various special chars replaced with equivalent
 * html entities. Newlines are replaced with <br>.
 */
export const escapeHtml = (text) => {
  const map = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#039;'
  };

  return text.replace(/[&<>"']/g, function(m) { return map[m]; });
};

/**
 * Concatenates the cmpinfo, stdout and stderr fields of the sandbox
 * response, truncating both stdout and stderr to a given maximum length
 * if necessary (in which case '... (truncated)' is appended.
 * @param {object} response Sandbox response object
 * @param {int} maxLen The maximum length of the trimmed stringlen.
 */
export const combinedOutput = (response, maxLen) => {
    const limit = s => s.length <= maxLen ? s : s.substr(0, maxLen) + '... (truncated)';
    return response.cmpinfo + limit(response.output) + limit(response.stderr);
};


/**
 * Creates elements en masse by taking an elementName and adding classes
 * and attributes to it.
 *
 * @param {string} elementName The name of the HTML element to be made.
 * @param {type} classList A list of all the classes to be added.
 * @param {type} attributeArray A map of attributes and values to be added.
 * @returns {Element}
 */
export const createComponent = (elementName, classList, attributeArray) => {
    const element = document.createElement(elementName);
    classList.forEach(htmlClass => element.classList.add(htmlClass));
    for (const attribute in attributeArray) {
        element.setAttribute(attribute, attributeArray[attribute]);
    }
    return element;
};