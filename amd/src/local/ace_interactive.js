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
 * JavaScript for the ace interactive part.
 *
 * @module     filter_ace_inline/local/ace_interactive
 * @copyright  Richard Lobb, Michelle Hsieh 2022
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

import {createComponent, combinedOutput, diagnose, escapeHtml, getLangString} from "filter_ace_inline/local/utils";
import {getFiles} from "filter_ace_inline/local/file_helpers";
import {processCode} from "filter_ace_inline/local/repository";

const RESULT_SUCCESS = 15;  // Code for a correct Jobe run.

/**
 * Handle a click on the Try it! button; pre-checks the taids for valid ids.
 * @param {html_element} outputDisplayArea The HTML <p> element in which to display output.
 * @param {string} code The code to be run.
 * @param {Object} uiParameters The various parameters (mostly attributes of the pre element).
 * Keys are button-name, lang, stdin, files, params, prefix, suffix, codemapper, html-output.
 * @returns {string} code of the code to run, else null but executes errors if needed.
 */
export const handleButtonClick = async (outputDisplayArea, code, uiParameters) => {
    cleanOutput(outputDisplayArea);
    let errorText = '';
    const params = uiParameters.paramsMap;
    outputDisplayArea.style.display = '';
    // Handle languages at this state.
    uiParameters.setExecLang(params['lang']);
    uiParameters.setHtmlOutput(params['html-output']);

    const mapFunc = params['code-mapper'];
    if (mapFunc in window) {
        code = window[mapFunc](code);
    } else if (mapFunc !== null) {
        errorText = await getLangString('error_script_unknown');
    }

    code = params.prefix + code + params.suffix;
    // Get the parameters by parsing.
    uiParameters.setStdin();
    uiParameters.setFiles(await getFiles(uiParameters));
    // If html/markup is the chosen language; change uiParameters and wrap in Python.
    if ((params['lang'] === 'markup') || (params['lang'] === 'html')) {
        outputDisplayArea.setAttribute('class', 'filter-ace-inline-output-html');
        uiParameters.setHtmlOutput(true);
        uiParameters.setExecLang('python3');
        code = "print('''" + code + "''')";
    }

    // Check if params is a good JSON string.
    try {
        // Adds any uploaded files onto the uiParams and resets uiParams sandbox params.
        let sandboxParams = JSON.parse(params['params']);
        if (sandboxParams.hasOwnProperty('runargs')) {
            sandboxParams['runargs'] = sandboxParams['runargs'].concat(uiParameters.sandboxParams);
        } else {
            sandboxParams['runargs'] = uiParameters.sandboxParams;
        }
        uiParameters.setRunParams(JSON.stringify(sandboxParams));
    } catch (SyntaxError) {
        errorText = await getLangString('error_json_params');
    }

    // If there is a bad id.
    if (uiParameters.stdin === null || uiParameters.files === 'bad_id') {
        errorText = await getLangString('error_element_unknown');
    }

    // Make it display a User error if there is an error and return no code.
    if (errorText !== '') {
        let text = '*** ' +  await getLangString('error_user_params') + ' ***\n' + errorText;
        outputDisplayArea.setAttribute('class', 'filter-ace-inline-output-user');
        outputDisplayArea.children.item(0).innerHTML = escapeHtml(text);
        return null;
    }

    return code;
};

/**
 * Executes the code through CodeRunner run_in_sandbox.
 * @param {html_element} outputDisplayArea The HTML <p> element in which to display output.
 * @param {string} code The code to be run.
 * @param {int} uiParameters The various parameters (mostly attributes of the pre element).
 * Keys are button-name, lang, stdin, files, params, prefix, suffix, codemapper, html-output.
 */
export const executeCode = async (outputDisplayArea, code, uiParameters) => {
    await processCode(code, uiParameters).then(responseJson => {
        displaySuccess(responseJson, outputDisplayArea, uiParameters);
    })
        .catch(error => {
            cleanOutput(outputDisplayArea);
            // Change the outputDisplayArea to something more ominious...
            outputDisplayArea.setAttribute('class', 'filter-ace-inline-output-user');
            displayTextOutput(error.message, 'error_user_params', outputDisplayArea);
    });
};

/**
 * Displays the output of the successful AJAX promise.
 * @param {JSON} responseJson The Json object response.
 * @param {Element} outputDisplayArea The area to have the text displayed.
 * @param {Object} uiParameters The UiParameters object that contains all the bits.
 */
const displaySuccess = (responseJson, outputDisplayArea, uiParameters) => {
    let text = '';
    let langString = '';
    const params = uiParameters.paramsMap;
    const htmlOutput = uiParameters.htmlOutput !== null;
    const maxLen = params['max-output-length'];

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
};


/**
 * Displays the text in the specified outputdisplay area.
 * @param {string} text Test to be displayed
 * @param {string} langString LangString for error-handling.
 * @param {html_element} outputDisplayArea The HTML <p> element in which to display output.
 */
const displayTextOutput = async (text, langString, outputDisplayArea) => {
    if (langString !== '') {
        text = "*** " + await getLangString(langString) + " ***\n" + text;
    }
    outputDisplayArea.children.item(0).innerHTML = escapeHtml(text);
};

/**
 * Cleans the outputDisplayArea and resets to normal, removing any next nodes found.
 * html objects.
 * @param {type} outputDisplayArea Resets the output box.
 */
const cleanOutput = (outputDisplayArea) => {
    outputDisplayArea.children.item(0).innerHTML = '';
    const potentialHtml = outputDisplayArea.nextElementSibling;
    if (potentialHtml !== null) {
        if (potentialHtml.className === 'filter-ace-inline-html') {
             outputDisplayArea.parentNode.removeChild(outputDisplayArea.nextSibling);
        }
    }
    outputDisplayArea.setAttribute('class', 'filter-ace-inline-output-display');
};
