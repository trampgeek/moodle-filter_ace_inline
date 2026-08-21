# Change History

 * Version 1.5.7, 22 August 2026.
    * Blame: morriemajor
    * Reduced the configuration options window to remove the ability to change settings in a Question Bank view, as this could lead to a misleading understanding of the rendered output. Updated Behat tests to test configuration setting behaviour. Further improvements to README.

 * Version 1.5.6, 20 August 2026.
    * Blame: morriemajor
    * Redrafting README.md

 * Version 1.5.5, 20 August 2026.
    * Blame: morriemajor
    * Improvements to filter settings so that you can immediately see the current parent-level setting and whether it has been overridden.

 * Version 1.5.4, 19 August 2026.
    * Blame: morriemajor
    * Minor changes to reduce CI noise.

 * Version 1.5.3, 19 August 2026.
    * Blame: morriemajor
    * Reduced Behat coverage for authoring modes, other than html-classic, to single attributes only. The script `tests/scripts/generate_behat_suite.py` with CLI flag `--comprehensive` will regenerate the more comprehensive Behat test suite.

 * Version 1.5.2, 19 August 2026.
    * Blame: morriemajor
    * Updates to make the testing scripts and structure work with qbank_gitsync, should you wish to use this infrastructure. Note that for this reason `tests/qbank/`'s question XML files need to be tracked despite being able to be auto-generated. Further, the `tests/scenarios/` fixtures, while also being able to be auto-generated, are tracked because of their connection to the Behat feature files.

 * Version 1.5.1, 18 August 2026.
    * Blame: morriemajor
    * Added extensive Behat tests - probably too many!

 * Version 1.5.0, 17 August 2026.
    * Blame: Richard Lobb
    * Merged a large pull request from Andrew Bainbridge-Smith (thanks Andrew!):
      * Consolidated the two Ace initialisation entry points (`initAceHighlighting` and `initAceInteractive`) into a single `initAceInlineEditor`, scanning each `<pre>` once.
      * Extended Simplified Mode: a fenced code block's class can now also flag it as interactive and carry the display/behaviour attributes (line numbers, font size, button name, etc.) via colon-separated values, e.g. `python3:interactive:button-name:Run`.
      * Added C/C++ datatype highlighting (identifiers ending in `_t` or written in PascalCase are highlighted as datatypes).
      * Added a per-course (context-level) override for the Simplified Mode setting, alongside the existing button-label and dark-theme overrides.
      * Fixed an XSS vulnerability: the Try it! button's label was inserted via `innerHTML`
     instead of `textContent`.
      * Fixed a race condition that could leave the Ace editor blank on a cold page load.
      * Fixed the CI pipeline's Code Checker ignore-file configuration: moodle-plugin-ci's `codechecker` command is only an alias for `phpcs`, so the ignore-file environment variables need the `PHPCS_` prefix, not `CODECHECKER_`.
    * Plus a few minor fixes made afterwards: a substring false-positive in Simplified Mode's interactive-block detection, restored MariaDB test coverage in CI, and reworded the Simplified Mode admin setting label/description.

 * Version 1.4.6, 11 August 2026.
    * Blame: morriemajor
    * Extensive bugs identified by Paul McKeown, fixes made with the aid of Claude.  Still unresolved: appropriate human checks on some of the behat tests.

 * Version 1.4.5, 7 August 2026.
    * Blame: morriemajor
    * Added C(++) datatype highlighting: identifiers ending in "_t" (e.g. size_t, uint32_t) or written in PascalCase (e.g. MyStruct) are now highlighted as datatypes, distinct from ordinary identifiers and keywords. Implemented as a custom Ace mode built at runtime on top of CodeRunner's vendored C/C++ mode, rather than editing that vendored file directly, so it survives CodeRunner/Ace upgrades. (Claude written)

 * Version 1.4.4, 7 August 2026.
    * Blame: morriemajor
    * Reworked the name for the new feature from Markdown Extended to Simplified Mode. The feature now allows minimist TinyMCE usage to also result in syntax highlighting, i.e simplified mode by encoding the class string in the `<pre>` fence.

 * Version 1.4.3, 6 August 2026.
    * Blame: morriemajor
    * Added Behat tests for the Extended Markdown rendering mode, covering both highlighted (read-only) and interactive rendering, for both C and Python fenced code blocks (`tests/behat/extended_markdown.feature`). (Claude written)

 * Version 1.4.2, 6 August 2026.
    * Blame: morriemajor
    * Added Behat tests covering both the site administrator settings page and the new per-course (context-level) settings overrides for the button label, dark theme mode and markdown rendering settings. Fixed a bug found while writing these tests: a course-level override was only being applied to content filtered directly in that exact course context, not to content inside activities within the course (which are filtered in their own, separate, module context nested below it); the filter now also checks ancestor contexts for an override, so a course-level override applies throughout that course as expected. (Claude written)

 * Version 1.4.1, 6 August 2026.
    * Blame: morriemajor
    * Added support for overriding the three administrator settings (button label, dark theme mode, markdown rendering) at a per-context (e.g. per-course) level. From a course's "More > Filters" page, click "Settings" next to "Ace inline" to override any of these for that course; leave a field as "Use site default" to keep inheriting the administrator's setting. Credit to Paul McKeown for this idea.

 * Version 1.4.0, 5 August 2026.
    * Blame: morriemajor
    * Added feature for allowing standard language string to be added to a markdown code block (triple tick).  This language string can also be encoded with additional Ace Inline filter parameters - the elements separated by colons (:).  Added administrative setting to allow control of Markdown code block rendered, including this new feature (which is called Extended).

 * Version 1.3.11, 7 November 2025.
    * Blame: Richard Lobb
    * Added code to defer hiding of the original `<pre>` element until the rendering of the content by Ace is complete. If this doesn't happen within 2 seconds, the pre element is enclosed in a red border with a warning message and the ace content plus any associated UI is removed.

 * Version 1.3.10, 8 November 2024.
    * Blame: Richard Lobb
    * Upgrade to Moodle 4.5 compatibility plus various code and test polishing. All thanks to Luca Bösch.

 * Version 1.3.9, 27 September 2024.
    * Blame: Richard Lobb
    * Change background colour of read-only ace-inline divs to light grey to distinguish them for editable ones. Various tweaks to behat tests and style file to keep the githug CI style checkers happy.

 * Version 1.3.8, 19 May 2024.
    * Blame: Richard Lobb
    * Trivial change: confusing error message 'User config error' changed to just 'Run error', as could include submission limit reached, for example.

 * Version 1.3.7, 19 December 2023.
    * Blame: Richard Lobb
    * Bug fix for issue #30: latest update won't install (due to bad zip uploaded to Moodle plugin repository.)

 * Version 1.3.6, 29 September 2023.
    * Blame: Richard Lobb
    * Update documentation relating to the use of Markdown extra editing.

 * Version 1.3.5, 15 September 2023.
    * Blame: Richard Lobb
    * Bug fix: State of filter reverted to 'Off but available' whenever the admin filter manager was opened.

 * Version 1.3.4, 1 August 2023.
    * Blame: Richard Lobb
    * Adding space after each Try it box

 * Version 1.3.3, 10 May 2023.
    * Blame: Richard Lobb
    * Fix issues with Ace window being far too narrow in many multi-column contexts.
 
 * Version 1.3.2, 30 April 2023.
    * Blame: Michelle Hsieh
    * Fixed issue with replacing the wrong node in MarkdownExtra formatting.
    * Fixed administrator's default "Try it!" setting to actually work.
    * Fixed setting minwidth in multichoice so that text will not be truncated.
    * Added support to allow "style" components to be adapted in. Will be overwritten by Ace Display settings, however, allows other styles such as "min-width" or "margin" to be set with expected results.

 * Version 1.3.1, 15 February 2023.
    * Blame: Michelle Hsieh
    * Fixed code to adhere to Eslint.

 * Version 1.3, 7 February 2023.
    * Blame: Michelle Hsieh
    * Changed global dynamic hooks to differentiate between the two.

 * Version 1.2.2, 19 January 2023.
    * Blame: Michelle Hsieh
    * Updated CI for PHP8 with Moodle 4.1.
    * Kept Firefox handling code boxes with expansion; changed rest to scrolling.
    * Checked with Moodle_3x_stable for compatibility.
    * Updated ReadMe with CodeRunner requirements and Firefox scrollbar issue.

 * Version 1.2.1, 19 December 2022.
     * Blame: Michelle Hsieh
    * Added a privacy folder with provider.php.
    * Cleaned up ReadMe.

 * Version 1.2.0, 15 December 2022.
     * Blame: Michelle Hsieh
    * Added full error handling and file upload size restrictions (2MB).
    * Mapped files with boxes appropriately.

 * Version 1.1.1, 13 December 2022.
    * Blame: Michelle Hsieh
    * Changed modules to local, as per Moodle Documentation.
    * Added file-parsing to JOBE running requirements, including user warnings.
    * Can now use argv's to find filenames and run them.
    * ReadMe and examples to be added tomorrow.

 * Version 1.1.0, 12 December 2022.
    * Blame: Michelle Hsieh
    * Entire program is now in Vanilla ES.
        * Decomposed with UiParameters as a class.
        * ace_inline_code.js is the entry class.
        * Remaining supporting classes are in modules.

 * Version 1.0.2, 8 December 2022.
    * Blame: Michelle Hsieh
    * Removed all jQuery from code to prepare for ES6 transition.
    * Renamed Behat tests for better definition.
    * Changed Behat tests to insert .txt files from fixtures straight into db instead, to reduce UI dependency.
    * Implemented CI.

 * Version 1.0.1, 5 December 2022.
    * Blame: Michelle Hsieh
    * Updated ReadMe fully.
    * Added demo for Matplotlib in TinyMCE.
    * Updated demoaceinline.xml.
    * Patched issue with empty text areas being treated as empty ids. Updated tests accordingly.
    * Cleaned code to comply with Moodle Code Checker.

 * Version 1.0.0, 1 December 2022.
    * Blame: Michelle Hsieh
    * MarkdownExtra compatibility implemented.
    * Moodle 4.1's Tiny MCE editor in-built Code sample compatibility implemented.
    * Errors now show up consistently in the output area; and output boxes show different error colours and error messages.
    * Major code refactor, including CSS handling.
    * Comprehensive Behat tests implemented.
    * Changed implementation to data-ace-highlight/interactive-code attribute on `<pre>`.
    * ReadMe is in process of being rewritten; up to TinyMCE.
    * Unexpected behaviour in certain areas of Moodle added.

 * Version 0.8.3, 28 September 2022. 
   * Blame: Richard Lobb
   * Introduce a data-hidden attribute that hides the code to be executed, allowing authors to set up applet-like elements that read data from UI elements or files and display output inline when the button (probably renamed) is clicked. Also set data-min-lines default to 1; 4 was a bad idea.

 * Version 0.8.2, 25 September 2022. 
    * Blame: Richard Lobb
    * Introduce data-file-upload-id attribute allowing the user to select files to upload into the workspace on Jobe when the code is run. Introduce data-max-lines and data-min-lines to set limits on size of Ace window. Remove old data-files attribute. Plus refactor code to avoid all use of old-fashioned 'var' declarations in JavaScript.
   
 * Version 0.7, 21 September 2022. 
    * Blame: Richard Lobb
    * Introduced new attributes *stdin-taid* and *file-taids* to allow standard input or file contents to be loaded frommtext areas within the same page. Also added the capability of switching to dark mode both at a system default level and within any particular instance of the filter.
