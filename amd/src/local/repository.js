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
 * JavaScript specifically to run the Ajax calls.
 *
 * @module     filter_ace_inline/local/repository
 * @copyright  Richard Lobb, Michelle Hsieh 2022
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

import Ajax from 'core/ajax';

/**
 * Takes the core Moodle ajax module and returns a Promise with the
 * inputted parameters.
 * @param {type} code
 * @param {type} uiParameters
 * @returns {Promise} A Promise respomnse from the sandbox
 */
export const processCode = (code, uiParameters) => Ajax.call([{
        methodname: 'qtype_coderunner_run_in_sandbox',
        args: {
            contextid: M.cfg.contextid,
            sourcecode: code,
            language: uiParameters.execLang,
            stdin: uiParameters.stdin,
            files: uiParameters.files,
            params: uiParameters.paramsMap['run-params']
        }
}])[0];
