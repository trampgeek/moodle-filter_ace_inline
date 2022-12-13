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
 * JavaScript for helping parse files and pseudofiles.
 *
 * @module     filter_ace_inline/local/file_helpers
 * @copyright  Richard Lobb, Michelle Hsieh 2022
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

import {createComponent, getLangString} from "filter_ace_inline/local/utils";

let uploadFiles = {};

/**
 * Gets the uiParameter 'file-taids' and parses it if it is JSON. Promises an
 * arbitrary non-JSON object for error handling in the run_in_sandbox.php, else
 * promises a JSON object of appropriate mappings
 *
 * @param {object} uiParameters The various parameters (mostly attributes of the pre element)
 * @returns {string} An JSON-encoding of an object that defines one or more
 * filename:filecontents mappings.
 */
export const getFiles = async (uiParameters) => {
    let taids = uiParameters.paramsMap['file-taids'];
    let sandboxArgs = [];
    let map = {};

    if (Object.keys(taids).length !== 0) {
        // Catches JSON parse errors for file names.
        try {
            taids = JSON.parse(taids);
        } catch (SyntaxError) {
            return Promise.resolve('error');
        }
        for (const filename in taids) {
            if (taids.hasOwnProperty(filename)) {
                const id = taids[filename];
                const file = document.querySelector('#' + id);
                if (file === null) {
                    return Promise.resolve('bad_id');
                } else {
                    map[filename] = file.value;
                }
            }
        }
    }

    // Merge in any explicitly uploaded files.
    for (const name in uploadFiles) {
        if (uploadFiles.hasOwnProperty(name)) {
            map[name] = uploadFiles[name]; // Copy contents across.
            sandboxArgs.push(name);
        }
    }

    // Add all the sandbox file names into uiSandboxparams for Args access.
    uiParameters.setSandboxParams(sandboxArgs);
    return Promise.resolve(JSON.stringify(map));
};

/**
 * Set up an onchange handler for file uploads. When the user selects
 * a file, a FileReader is created to read the contents. While the read
 * is in progress, a data-busy attribute is set. When the read is complete
 * a data-file-contents object is defined to map name to contents.
 * @param {HTMLelement} uploadElementId The input element of type file.
 */
export const setupFileHandler = async (uploadElementId) => {
    // Create a pre element to contain error messages.
    const errorNode = createComponent("div", ['filter-ace-inline-files'], {'hidden' : ''});

    /**
     * Read a single file.
     * @param {file} file A file from an 'input type=file' element filelist.
     * @returns {Promise} A promise wrapping the given file's contents.
     */
    function readOneFile(file){
        return new Promise((resolve, reject) => {
          let rdr = new FileReader();
          rdr.onload = () => {
            resolve(rdr.result);
          };
          rdr.onerror = reject;
          rdr.readAsText(file);
        });
    }

    const element = document.querySelector('#' + uploadElementId);
    element.parentNode.insertBefore(errorNode, element.nextSibling);
    element.setAttribute('multiple', '1');  // Workaround for the fact Moodle strips this.
    element.addEventListener('change', async () => {
        errorNode.innerHTML = '';
        uploadFiles = {};
        const files = element.files;
        // Parses and modifies name to make sure name is accepted by Jobe.
        for (const file of files) {
            const parsedName = parseFileName(file.name);
            if (parsedName !== file.name) {
                errorNode.innerHTML = '<li><em>' + file.name + '</em><strong>&nbsp;&gt;&gt;&nbsp;'
                        + parsedName + '</strong></li>' + errorNode.innerHTML;
            }
            uploadFiles[parsedName] = await readOneFile(file);
        }
        // Deals with error display.
        if (errorNode.innerHTML !== '') {
            errorNode.innerHTML = '<strong>' + await getLangString('file_changed_name')
                    + '</strong><ul>' + errorNode.innerHTML + '</ul>';
            errorNode.removeAttribute('hidden');
        } else {
            errorNode.setAttribute('hidden');
        }
    });
};

/**
 * Parses text according to what Jobe accepts. Modify this if using other
 * sandboxes with different acceptance parameters.
 *
 * @param {String} filename The name of the file to be parsed.
 * @returns {String} The string of the parsed filename.
 */
const parseFileName = (filename) => {
    // Matches all the spaces and replaces it with _.
    const stripped = filename.replace(/\s/g, '_');
    // Matches anything which isn't alphanumeric, _, - or . and removes it.
    return stripped.replace(/[^A-Za-z0-9._-]/g, '');
};