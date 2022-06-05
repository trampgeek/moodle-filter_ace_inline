# The Moodle ace_inline filter

Richard Lobb

Version 0.4, 5 June 2022.

github repo: https://github.com/trampgeek/moodle-filter_ace_inline

## Introduction

A Moodle filter for displaying program code and optionally allowing interaction with it.
Unlike most Moodle filters, this one is mostly implemented in JavaScript rather than
PHP and operates
on the rendered HTML rather than the original text. Authors need
to use an HTML editor to define the DOM elements that will be targetted by the
filter.

The plugin really provides two separate filter operations:

 1. HTML \<pre> elements with a class of 'ace-highlight-code' are displayed
    using the JavaScript Ace code editor in read-only mode. This provides
    syntax colouring of the code.

 2. HTML \<pre> elements with a class of 'ace-interactive-code' are also
    displayed using the Ace code editor, but with editing enabled. In addition,
    a button labelled by default `Try it!` allows the student to execute the
    current state of the code and observe the outcome. With sufficient
    ingenuity on the part of the author,
    graphical output and images can be displayed, too. The student
    is not able to enter standard input so this filter does not provide a
    fully interactive shell, although the author can pre-define
    'canned' standard input and even supply pseudo text files to be read by
    the code.

The plugin requires the CodeRunner plugin to be installed first, since that
furnishes the Ace editor required for filter operations.
CodeRunner version 4.2.1
or later is required. In addition, the
ace-interactive-code filter requires that the system administrator has enabled
the CodeRunner sandbox web service (still regarded as experimental) which is
disabled by default. The `Try it!` button send the code from the Ace editor
to the CodeRunner sandbox (usually a Jobe server) for execution using that
web service.

There is a page demonstrating the use of this filter on the CodeRunner site
[here](https://coderunner.org.nz/mod/page/view.php?id=529).

### ace-highlight-code parameters

Additional control of the display and behaviour is via attributes of the
\<pre> element as follows. All attribute names should start with 'data-' to ensure
that the HTML still validates. However, the 'data-' prefix can be dropped if
you don't care about HTML5 validation. For example the 'data-lang' attribute
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

3. data-stdin. This string value defines the standard input "file" to be used for the
   run. HTML5 allows multiline attribute values, so newlines can be inserted into
   the string. For example:

        <pre class="ace-interactive-code"
             data-stdin="I am line 1
        and I am line 2
        ">
        print(input())
        print(input())
        </pre>

4. data-files. This is a JSON specification that defines any additional files
   to be loaded into the working directory. Attribute names are file names and
   attribute values are file contents. Since this is JSON, newlines in file
   contents should be represented as \n. For example:

        <pre class="ace-interactive-code"
             data-files='{"blah.txt": "I am line 1\nAnd I am line 2\n"}'>
        print(open("blah.txt").read())
        </pre>

5. data-params. This is a JSON object that defines any Jobe sandbox parameters that
   are to have non-standard values, such as `cputime` and `memorylimit`. This
   shouldn't generally be needed. Default: '{"cputime": 2}'. Note that the maximum
   cputime is set via the administrative interface and any attempt
   to exceed that is silently overridden, using the administrator-defined
   maximum instead.

6. data-code-mapper. This string value must be the name of a global JavaScript
   function (usually defined in a \<script> element preceding the \<pre> element)
   that takes the Ace editor code as a parameter and returns a modified version,
   e.g. with extra code inserted. If used in conjunction with data-prefix
   and data-suffix (below), the code-mapper function is applied first and then
   the prefix and/or suffix code is added.

7. data-prefix. This string value is code to be inserted in front of the
   contents of the ace editor before sending the program to the Jobe server
   for execution. An extra newline is *not* inserted between the two strings,
   so if you want one you must include it explicitly.

8. data-suffix. This string value is code to be inserted in front of the
   contents of the ace editor before sending the program to the Jobe server
   for execution. An extra newline is *not* inserted between the two strings,
   so if you want one you must include it explicitly.

9. data-html-output. If this attribute is present (with any value) the output
   from the run is interpreted as raw HTML.
   The output from the program is simply wrapped in a \<div> element and inserted
   directly after the Try it! button. An example of a ace-interactive-code
   panel that that uses data-prefix, data-suffix and data-html-output to provide
   Matplotlib graphical output in Python is included in the repo `tests` folder
   (the file `demoaceinline.xml`).

10. data-max-output-length. The maximum length of an output string (more or less).
   Output greater than this is truncated. Default 10,000 characters.

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

        \<moodlehome>/filter/ace_inline_code

Then visit Site administration > Notifications. You should receive the usual
prompting about updating the database to incorporate the new plugin.

To use the ace-interactive-code filter, you will also need to enable the
sandbox web service option within the CodeRunner plugin settings. You should
read carefully the other related CodeRunner web service settings and consider
the various implications. Setting up a separate jobe server for the web service
is recommended if heavy usage of ace-interactive-code is likely in order to
mitigate against overload of the main jobe server, which is generally or far
more importance. Consider also what value to use for the maximum submission
rate by any given Moodle user as this limits the potential for abuse by any
student.

The only plugin setting provided directly by this plugin rather than the
CodeRunner web service allow an administrator to change the default button name
for ace-interactive-code elements (default name: *Try it!*).

## Demo/test

There is a page demonstrating most of the capabilities of this filter
on the CodeRunner site
[here](https://coderunner.org.nz/mod/page/view.php?id=529). The underlying HTML
on that page is mostly the same as in the file
`[testaceinline.xml](https://github.com/trampgeek/moodle-filter_ace_inline/blob/master/tests/demoaceinline.xml)`,
which is included in
the github repo, in the *tests* folder. If you want to experiment yourself, you can
download that file and import it as an xml question into the question bank on
your moodle system. Open it for editing and switch to HTML mode to see how it
is set up. It
includes a final complex example of a python3 ace-interactive-code element
that runs numpy and matplotlib, displaying any output graphs as images in
addition to any text output. This final example needs to have numpy and
matplotlib installed on the jobe server; they're not there by default.