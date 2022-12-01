# The Moodle ace_inline filter

Richard Lobb, Michelle Hsieh

Version 1.0, 1 December 2022.

github repo: https://github.com/trampgeek/moodle-filter_ace_inline

## Introduction

A Moodle filter for displaying and optionally interacting with program code by utilising the Moodle CodeRunner question type plugin. 
Unlike most Moodle filters, this one is mostly implemented in JavaScript rather than PHP and operates on the rendered HTML rather than the original text. This filter is applied over all HTML elements, therefore can be displayed throughout courses where the user can edit/create HTML elements.

As of Moodle 4.1, the following code adding and editing options are available:
 1. Utilising the new TinyMCE editor's 'Insert' > 'Code sample' option.
    * This option is recommended for casual code authors, as the editing UI allows direct copying and pasting of code without reformatting. Note: Due to TinyMCE's quirks, certain options are limited. See further information below.
 2. Editing the HTML directly in an HTML editor. 
    * This option is recommended for code authors who require full functionality and are comfortable using HTML.
 3. Utilising MarkdownExtra, either in the Moodle editor or externally for importing questions.
    * This option is recommended for code authors who may want to create questions outside of the editor in a readable format and import them into Moodle with expected behaviour. Note: This filter utilises current MarkdownExtra parsing, therefore only valid MarkdownExtra is compatible with this filter.

The plugin provides two separate filter operations:
 1. Syntax highlighting: HTML \<pre> elements with an attribute of **data-ace-highlight-code** are displayed using the JavaScript Ace code editor in read-only mode. This provides syntax colouring of the code.

 2. Code execution: HTML \<pre> elements with an attribute of **data-ace-interactive-code** are also displayed using the Ace code editor, but with editing enabled. In addition, a button labelled by default `Try it!` allows the student to execute the current state of the code and observe the outcome. With sufficient ingenuity on the part of the author, graphical output and images can be displayed, too (this option should be done by editing raw HTML). By adding additional html elements and linking the \<pre> element to them, the author can allow users to enter standard input to the run and even upload files.

It should be noted that the 'interactive' elements are interactive only in the sense that the user can edit and run them; the user cannot interact with the code whilst it is running. However, the code can be modified between executions. As this implementation is a filter, data is not stored persistently, and any changes to the code whilst the filter is activated will not be stored.

The plugin requires the CodeRunner plugin to be installed first, since that furnishes the Ace editor required for filter operations. CodeRunner version 4.2.1 or later is required. In addition, the ace-interactive-code filter requires that the system administrator has enabled the CodeRunner sandbox web service (still regarded as experimental) which is disabled by default. The `Try it!` button send the code from the Ace editor to the CodeRunner sandbox (usually a Jobe server) for execution using that web service.

There is a page demonstrating the use of this filter on the CodeRunner site [here](https://coderunner.org.nz/mod/page/view.php?id=529).

## Editor options
To change text editors in Moodle, click on your user icon, and select "Editor preferences". A drop-down menu can allow a user to switch between editors. Markdown is implemented in "Plain Text Area" and can be selected from a drop-down menu below the implementation of the text editor. TinyMCE referenced is labelled "TinyMCE editor" (**not** the legacy version) and is available from Moodle version 4.1+.

###  TinyMCE (Code sample)
**How to use:**
* Click "Insert" > "Code sample"
* Select the programming language you wish to use
* Either write your code normally in the "Code view" area, or copy and paste code into the area
* Click "Save"
* Click "View" > "Source code"
* Locate the code in HTML and add **data-ace-highlight-code/data-ace-interactive-code** into the \<pre> element. Example:

        <pre class="language-python" data-ace-interactive-code >
        <code>
	        def hello():
	             print("Hello world!")
	        hello()
        </code>
        </pre>

* Save the question.
* To edit the code again, double-click on the code block in the editor.
* Ace-inline will be viewable outside of the editor; and in-built Prism formatting is visible within.

**Caveats:**
* Currently, the use of \<script> tags are not supported by TinyMCE. This includes using the Source Code option of TinyMCE. Therefore, avoid the use of any \<script> tags, and avoid editing code containing any tags in this editor as the HTML is **automatically stripped of \<script> tags upon editing and saving any material**.
* Use the **'data-'** prefix for every starting parameter. TinyMCE will **strip away any non-'data' tags upon editing and saving the question**.
* If you want to use another language which is not yet available on Code samples, the author should change the language to "HTML/XML" and add the parameter **data-lang=*'language'*** to the \<pre> tag. 
* Alternatively, you can switch to Source Code view to edit your code and parameters.

### ace-highlight-code parameters

Additional control of the display and behaviour is via attributes of the
\<pre> element as follows. All attribute names should start with 'data-' to ensure
that the HTML still validates. However, the 'data-' prefix can be dropped if
you don't care about HTML5 validation (**Warning: the 'data-' prefix is necessary for Tiny Editors' compatibility. Tiny will strip out all attributes without 'data-' upon saving.**). For example the 'data-lang' attribute
can just be 'lang'.

 1. data-lang. This attribute sets the language to be used
    by the Ace editor for
    syntax colouring (if data-ace-lang is not set - see next item)
    and, in the case of the ace-interactive-code, the language
    for running the code on the Jobe server. Default: python3. Example:

        <pre class="ace-highlight-code" data-lang="java">
        public class hello {
            public static void main(String[] args) {
                System.out.println("Hello world!");
            }
        }
        </pre>

 2. data-ace-lang. If set and non-empty, sets the language used by the Ace
    editor for syntax colouring, allowing for example a python script to be
    used on Jobe to run code entered by the user in R.

3. data-start-line-number. Sets the line number used for the first displayed line of
   code, if line numbers are to be shown. Set to 'none' for no line numbers.
   Default is 'none' for ace-highlight-code elements and '1' for ace-interactive-code
   elements.

4. data-font-size. Sets the display font size used by Ace. Default 14px.

### ace-interactive-code-parameters

In addition to the above, ace-interactive-code elements can have
the following attributes.

1. data-button-name. This sets the text within the Try it! button.
   Default 'Try it!'.
   Example:

        <pre class="ace-interactive-code" data-button-name="Run me!">
        # Default lang = python
        for i in range(10):
            print(i, i * i)
        </pre>

2. data-readonly. This disables editing of the code, so students can only run
    the supplied code without modification. The `Try it!` button is still displayed
    and operational.

3. data-stdin. DEPRECATED. This string value defines the standard input "file" to be used for the
   run. HTML5 allows multiline attribute values, so newlines can be inserted into
   the string. For example:

        <pre class="ace-interactive-code"
             data-stdin="I am line 1
        and I am line 2
        ">
        print(input())
        print(input())
        </pre>

4. data-stdin-taid. This string value specifies the ID of a textarea, or other
   HTML element with a JQuery val() method, from which the standard input will
   be taken when the Try it! button is clicked. Overrides data-stdin if both
   are given (and data-stdin is deprecated).

5. data-file-taids. This attribute provides a pseudo-file interface where
   the user is able to treat one or more supplementary textarea elements like
   files, entering the pseudo-file contents into the textarea(s) before clicking
   the Try it! button. The attribute is a JSON specification that maps from filename(s)
   to the ID(s) of textareas, or other HTML elements with a val() method, that
   will be used to provide the job with one or more files in the working
   directory. For each attribute, a file of the specified filename is created
   and the contents of that file are the contents of the associated textarea
   at the time the Try it! button is clicked. If data-files is also specified,
   it is ignored. [data-files is deprecated].

6. data-file-ipload-id. This attribute is the ID of an \<input type="file>
   element. The user can select one or more files using this element and the
   files are uploaded into the program's working space when it is run.

7. data-params. This is a JSON object that defines any Jobe sandbox parameters that
   are to have non-standard values, such as `cputime` and `memorylimit`. This
   shouldn't generally be needed. Default: '{"cputime": 2}'. Note that the maximum
   cputime is set via the administrative interface and any attempt
   to exceed that is silently overridden, using the administrator-defined
   maximum instead.

8. data-code-mapper. This string value must be the name of a global JavaScript
   function (usually defined in a \<script> element preceding the \<pre> element)
   that takes the Ace editor code as a parameter and returns a modified version,
   e.g. with extra code inserted. If used in conjunction with data-prefix
   and data-suffix (below), the code-mapper function is applied first and then
   the prefix and/or suffix code is added.

9. data-prefix. This string value is code to be inserted in front of the
   contents of the ace editor before sending the program to the Jobe server
   for execution. An extra newline is *not* inserted between the two strings,
   so if you want one you must include it explicitly.

10. data-suffix. This string value is code to be inserted in front of the
   contents of the ace editor before sending the program to the Jobe server
   for execution. An extra newline is *not* inserted between the two strings,
   so if you want one you must include it explicitly.

11. data-html-output. If this attribute is present (with any value) the output
   from the run is interpreted as raw HTML.
   The output from the program is simply wrapped in a \<div> element and inserted
   directly after the Try it! button. An example of a ace-interactive-code
   panel that that uses data-prefix, data-suffix and data-html-output to provide
   Matplotlib graphical output in Python is included in the repo `tests` folder
   (the file `demoaceinline.xml`).

12. data-min-lines. The minimum number of lines to display in the Ace editor.

13. data-max-lines. The maximum number of lines to display in the Ace editor.

14. data-max-output-length. The maximum length of an output string (more or less).
   Output greater than this is truncated. Default 10,000 characters.

15. data-dark-theme-mode. Selects when to use a dark mode for the Ace editor.
   Has values 0, 1 or 2 for no, maybe and yes. If 1 (maybe) is chosen,
   the dark theme will be used if the browser's prefers-color-scheme:dark media
   query returns a match, so this may change with browser, operating system or
   time of day. The default value is set by the administrator setting for the plugin.

## HTML-escaping of code within the \<PRE> element

When using ace-highlight-code or ace-interactive-code elements,
problems arise when program code contains characters that have special meaning
to the browser, i.e. are part of the HTML syntax. For example, in C:

        #include &lt;stdio.h&gt;

To ensure characters like '\<', '\&' etc are not interpreted by the browser, such
special characters should be uri-encoded, e.g. as \&lt;, \&amp; etc.

For example, an interactive hello world program in C would be defined in HTML as

        <pre class="ace-interactive-code" data-lang="c">
        #include &lt;stdio.h&gt;
        int main() {
            puts("Hello world!\n");
        }
        </pre>

Within the Ace editor the student just sees the URI-encoded characters as
'\<', '\&' etc


## Installation and configuration

Download the plugin from the repository, and unzip the code into

        \<moodlehome>/filter/ace_inline

Then visit Site administration > Notifications. You should receive the usual
prompting about updating the database to incorporate the new plugin.

Once installed, visit Site administration > Plugins > Plugins overview > Additional plugins.
From this page, click the icon next to "Text filters" and turn "Ace inline" to
"Off, but available".

This allows the individual teacher/administrator to set local settings for each
course; if desired. To access individual course settings, click "More" > "Filters"
and set Ace inline to "On".

To use the ace-interactive-code filter, you will also need to enable the
sandbox web service option within the CodeRunner plugin settings. You should
read carefully the other related CodeRunner web service settings and consider
the various implications. Setting up a separate jobe server for the web service
is recommended if heavy usage of ace-interactive-code is likely in order to
mitigate against overload of the main jobe server, which is generally or far
more importance. Consider also what value to use for the maximum submission
rate by any given Moodle user as this limits the potential for abuse by any
student.

There are two plugin administrator setting provided directly by this plugin:

  1.  The default button name for ace-interactive-code elements can
      be changed from its default name: *Try it!* (or whatever was set by the
      language settings for non-English users) to anything else.
  2.  The administrator can set whether to use the Ace editor's light theme or
      dark theme by default (although individual filter instances can override
      this with the data-dark-theme-mode option). There is also an option to
      use the dark theme 'sometimes', meaning whenever the browser's
      'prefers-color-scheme:dark' media query returns a match. This may
      change with browser, operating system or time of day.

## Demo/test

There is a page demonstrating most of the capabilities of this filter
on the CodeRunner site
[here](https://coderunner.org.nz/mod/page/view.php?id=529). The underlying HTML
on that page is mostly the same as in the file
`[testaceinline.xml](https://github.com/trampgeek/moodle-filter_ace_inline/blob/master/tests/fixtures/demoaceinline.xml)`,
which is included in
the github repo, in the *tests* folder. If you want to experiment yourself, you can
download that file and import it as an xml question into the question bank on
your moodle system. Open it for editing and switch to HTML mode to see how it
is set up. It
includes a final complex example of a python3 ace-interactive-code element
that runs numpy and matplotlib, displaying any output graphs as images in
addition to any text output. This final example needs to have numpy and
matplotlib installed on the jobe server; they're not there by default.

## Unexpected behaviour in certain areas of Moodle

Currently, in Moodle 4.1, the forum discussion (but not the general description) strips all tags aside from the "class" tag from any HTML elements. This is editor independent. By using the pre-existing [deprecated] method of setting the \<pre> **class='ace-interactive-code'** or **class='ace-highlight-code'** basic Python 3 functionality can be implemented.

Alternatively, prefix the desired language with **language-** and insert this into the \<pre> class, alongside with **ace-highlight/interactive-code** option to implement basic functionality in the selected language.
Example:

        <pre class="language-python ace-interactive-code">
        <code>
	        def hello():
	             print("Hello world!")
	        hello()
        </code>
        </pre>

## Change History

 * Version 1.0.0, 1 December 2022. 
    * MarkdownExtra compatibility implemented.
    * Moodle 4.1's Tiny MCE editor in-built Code sample compatibility implemented.
    * Errors now show up consistently in the output area; and output boxes show different error colours and error messages.
    * Major code refactor, including CSS handling.
    * Comprehensive Behat tests implemented.
    * Changed implementation to data-ace-highlight/interactive-code attribute on \<pre>.
    * ReadMe is in process of being rewritten; up to TinyMCE.
    * Unexpected behaviour in certain areas of Moodle added.
   
 * Version 0.8.3, 28 September 2022. Introduce a data-hidden attribute that hides
   the code to be executed, allowing authors to set up applet-like elements
   that read data from UI elements or files and display output inline when the
   button (probably renamed) is clicked. Also set data-min-lines default to 1;
   4 was a bad idea.

 * Version 0.8.2, 25 September 2022. Introduce data-file-upload-id attribute
   allowing the user to select files to upload into the workspace on Jobe when
   the code is run. Introduce data-max-lines and data-min-lines to set limits
   on size of Ace window. Remove old data-files attribute. Plus refactor
   code to avoid all use of old-fashioned 'var' declarations in JavaScript.

 * Version 0.7, 21 September 2022. Introduced new attributes *stdin-taid* and
   *file-taids* to allow standard input or file contents to be loaded from
   text areas within the same page. Also added the capability of switching
   to dark mode both at a system default level and within any particular instance
   of the filter.