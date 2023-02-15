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
const MAX_FILE_SIZE_BYTES = 2097152;

/**
 * Gets the uiParameter 'file-taids' and parses it if it is JSON. Promises an
 * arbitrary non-JSON object for error handling in the run_in_sandbox.php, else
 * promises a JSON object of appropriate mappings
 *
 * @param {object} uiParameters The various parameters (mostly attributes of the pre element)
 * @returns {string} An JSON-encoding of an object that defines one or more
 * filename:filecontents mappings.
 */
export const getFiles = async(uiParameters) => {
    const uploadId = uiParameters.paramsMap['file-upload-id'];
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

    // Merge in any explicitly uploaded files with same id in map.
    for (const name in uploadFiles) {
        if (uploadFiles.hasOwnProperty(name) && uploadFiles[name].hasOwnProperty(uploadId)) {
            map[name] = uploadFiles[name][uploadId]; // Copy contents across.
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
export const setupFileHandler = async(uploadElementId) => {
    // Creates a div element to contain error messages and divs for error messages.
    const errorNode = document.createElement("div", [], {'hidden': '1'});
    const errorHtml = createComponent("div", ['filter-ace-inline-files'], {'hidden': '1'});
    const fatalHtml = createComponent("div", ['filter-ace-inline-file-error'], {'hidden': '1'});
    errorNode.appendChild(fatalHtml);
    errorNode.appendChild(errorHtml);

    const element = document.querySelector('#' + uploadElementId);
    element.parentNode.insertBefore(errorNode, element.nextSibling);
    element.setAttribute('multiple', '1'); // Workaround for the fact Moodle strips this.
    element.addEventListener('change', async() => {
        // Cleans the contents of the errors between uploads.
        errorHtml.innerHTML = '';
        fatalHtml.innerHTML = '';
        uploadFiles = {};
        const files = element.files;
        for (const file of files) {
            let fileValues = {};
            const parsedName = parseFileName(file.name);
            // Parses and modifies name to make sure name is accepted by Jobe.
            // Also checks file size and refuses to upload at maximum file size (2MB).
            await readOneFile(file)
                .then(result => {
                    // A map for ids.
                    if (parsedName !== file.name) {
                        errorHtml.innerHTML = '<li><em>' + file.name + '</em><strong>&nbsp;&rArr;&nbsp;'
                            + parsedName + '</strong></li>' + errorHtml.innerHTML;
                        }
                    fileValues[uploadElementId] = result;
                    return null;
                })
                .catch(() => {
                    fatalHtml.innerHTML = '<li><strong><em>' + file.name + '</em>&nbsp;'
                        + '</strong></li>' + fatalHtml.innerHTML;
                });
            if (fileValues.size !== 0) {
                // Maps the name with the filevalue map of id to value.
                uploadFiles[parsedName] = fileValues;
            }
        }
        displayAllFileErrors(errorNode, errorHtml, fatalHtml);
    });
};

/**
 * Read a single file and return an appropriate promise of contents or rejects.
 * Checks file size prior to reading to prevent wasting time processing file.
 * @param {file} file A file from an 'input type=file' element filelist.
 * @returns {Promise} A promise wrapping the given file's contents.
 */
const readOneFile = async(file) => {
    if (file.size > MAX_FILE_SIZE_BYTES) {
        return Promise.reject("excessive size");
    }
    return new Promise((resolve, reject) => {
        let rdr = new FileReader();
        rdr.onload = () => {
          resolve(rdr.result);
        };
        rdr.onerror = reject;
        rdr.readAsText(file);
    });
};

/**
 * Displays all file errors for each error.
 * @param {type} error The error langString to be used.
 * @param {type} errorHtml The errorNode for the error message to be displayed.
 */
const displayFileError = async(error, errorHtml) => {
    errorHtml.innerHTML = '<strong>' + await getLangString(error)
        + '</strong><ul>' + errorHtml.innerHTML + '</ul>';
    errorHtml.removeAttribute('hidden');
};

/**
 * Adds the errors to the error and displays it all.
 *
 * @param {Element} errorNode The element to be displayed.
 * @param {Element} errorHtml The HTML to be displayed for errors.
 * @param {Element} fatalHtml The HTML to be displayed for errors that do not upload
 * files.
 */
const displayAllFileErrors = (errorNode, errorHtml, fatalHtml) => {
    // Hides all errors at first.
    errorHtml.setAttribute('hidden', '1');
    fatalHtml.setAttribute('hidden', '1');
    if (errorHtml.innerHTML !== '' || fatalHtml.innerHTML !== '') {
        if (errorHtml.innerHTML !== '') {
            displayFileError('file_changed_name', errorHtml);
        }
        if (fatalHtml.innerHTML !== '') {
            displayFileError('file_not_uploaded', fatalHtml);
        }
        errorNode.removeAttribute('hidden');
    } else {
        errorNode.setAttribute('hidden', '1');
    }
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