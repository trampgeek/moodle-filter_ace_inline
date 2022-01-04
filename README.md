# The Moodle ace_inline filter

Richard Lobb

Version 0.1, 4 January 2022.

github repo: https://github.com/trampgeek/moodle_filter_ace_inline

## Introduction

A Moodle filter that displays code inline using the Ace editor, possibly also
allowing a simple REPL mode if a sufficiently recent version of the CodeRunner
question type plugin is installed (currently only the 4.1.1 development
version). It is intended for use by teachers to allow students to run simple
pre-defined code snippets and to experiment with modifying those snippets.

## Detailed Description

A text filter for displaying program code and optionally allowing interaction with it.
Code is displayed using the Ace editor, with syntax colouring appropriate to
the specified language (default, Python). If the 'interactive' mode is
enabled the code can be run using a hot-line to the Jobe ("JOb Engine") server.
The latter capability requires that the CodeRunner question type is also
installed (version xx.yy or later), with an associated Jobe server available.

The filter interprets HTML \<pre> elements with a class of either
'ace-highlight-code' or 'ace-interactive-code', but only in the context
of a Moodle question (usually not a real question but rather a so-called
'Description' question). The contents of the \<pre> element should be code.
In the first case the text is simply displayed
with the Ace text editor for syntax highlighting, but is read-only.
In the second case the code is displayed in an editable form and in addition
a 'Try it!' button allows immediate execution of the code on the Jobe
server, with output displayed in-line.

### ace-highlight-code parameters

Additional control of the display and behaviour is via attributes of the
\<pre> element as follows. All attribute names should start with 'data-' to ensure
that the HTML still validates. However, the 'data-' prefix can be dropped if
you don't care about HTML5 validation. For example the 'data-lang' attribute
can just be 'lang'.

 1. data-lang. This attribute sets the language to be used
    by the Ace editor for
    syntax colouring and, in the case of the ace-interactive-code, the language
    for running the code on the Jobe server. Default: python3. Example:

        <pre class="ace-highlight-code" data-lang="java">
        public class hello {
            public static void main(String[] args) {
                System.out.println("Hello world!");
            }
        }
        </pre>

2. data-start-line-number. Sets the line number used for the first displayed line of
   code, if line numbers are to be shown. Set to 'none' for no line numbers.
   Default is 'none' for ace-highlight-code elements and '1' for ace-interactive-code
   elements.

3. data-font-size. Sets the display font size used by Ace. Default 14px.

### ace-interactive-code-parameters

In addition to the above 3 parameters, ace-interactive-code elements can have
the following additional attributes.

1. data-button-name. This sets the text within the Try it! button.
   Default 'Try it!'.
   Example:

        <pre class="ace-interactive-code" data-button-name="Run">
        # Default lang = python
        for i in range(10):
            print(i, i * i)
        </pre>

2. data-readonly. This disables editing of the code, so students can only run
    the supplied code without modification.

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
   shouldn't generally be needed. Default: '{"cputime": 2}'.

6. data-prefix. This string value is code to be inserted in front of the
   contents of the ace editor before sending the program to the Jobe server
   for execution. An extra newline is *not* inserted between the two strings,
   so if you want one you
   must include it explicitly.

7. data-suffix. This string value is code to be inserted in front of the
   contents of the ace editor before sending the program to the Jobe server
   for execution. An extra newline is *not* inserted between the two strings,
   so if you want one you
   must include it explicitly.

9. data-html-output. If this attribute is present (with any value) the output
   from the run is interpreted as raw HTML.
   The output from the program is simply wrapped in a \<div> element and inserted
   directly after the Try it! button.

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

The

The plugin settings allow an administrator to change the default button name
for ace-interactive-code elements (default name: *Try it!*).

## Demo/test

The unzipped repo contains a file `testaceinline.xml` which is an XML export
or a question that demonstrates most of the capabilities of the filter. It
includes a final complex example of a python3 ace-interactive-code element
that runs numpy and matplotlib, displaying any output graphs as images in
addition to any text output. This final example needs to have numpy and
matplotlib installed on the jobe server; they're not there by default.