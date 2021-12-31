Source code repository
=====================
https://github.com/trampgeek/moodle_filter_ace_inline

Short Description
=================
A Moodle filter that displays code inline using the Ace editor, possibly also
allowing a simple REPL mode if a sufficiently recent version of the CodeRunner
question type plug in is installed.

Long Description
================
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
with the Ace text editor for syntax highlight, but is read-only.
In the second case the code is displayed in an editable form and in addition
a 'Try it!' button allows immediate execution of the code on the Jobe
server, with output displayed in-line.

Additional control of the display and behaviour is via attributes of the
\<pre> element as follows. All attribute names start with 'data-' to ensure
that the HTML still validates.

 1. data-lang. This attribute sets the language to be used
    by the Ace editor for
    syntax colouring and, in the case of the ace-interactive-code, the language
    for running the code on the Jobe server. Default: python3. Example:

        <pre class="ace-highlight-code" data-lang="c">
        #include <stdio.h>
        int main() {
            puts("Hello world");
        }
        </pre>

2. data-start-line-number. Sets the line number used for the first displayed line of
   code, if line numbers are to be shown. Set to 'none' for no line numbers.
   Default is 'none' for ace-highlight-code elements and '1' for ace-interactive-code
   elements.

3. data-font-size. Sets the display font size used by Ace. Default 14px.

Further attributes relevant to ace-interactive-code elements only:

1. data-output-lines. This sets the size (number of rows) of the text area
   that displays the output of the code when executed via the Try it! button.
   Relevant only to ace-interactive-code elements. Default 1. Example:

        <pre class="ace-interactive-code" data-output-lines="10">
        # Default lang = python
        for i in range(10):
            print(i, i * i)
        <pre>

2. data-button-name. This sets the text within the Try it! button.
   Relevant only to ace-interactive-code elements. Default 'Try it!'.
   Example:

        <pre class="ace-interactive-code" data-button-name="Run" data-output-lines="10">
        # Default lang = python
        for i in range(10):
            print(i, i * i)
        </pre>

3. data-stdin. This string value defines the standard input "file" to be used for the
   run. HTML5 allows multiline attribute values, so newlines can be inserted into
   the string. For example:

        <pre class="ace-interactive-code" data-output-lines="2"
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

        <pre class="ace-interactive-code" data-output-lines="2"
             data-files='{"blah.txt": "I am line 1\nAnd I am line 2\n"}'>
        print(open("blah.txt").read())
        </pre>

5. data-params. This is a JSON object that defines any Jobe sandbox parameters that
   are to have non-standard values, such as `cputime` and `memorylimit`. This
   shouldn't generally be needed.

HTML-escaping of code within the \<PRE> element
==============================================

When using ace-interactive-code elements, problems arise when program code contains characters that have special meaning
to the browser, i.e. are part of the HTML syntax. For example, in C:

        #include &lt;stdio.h&gt;

To ensure characters like '\<', '\&' etc are not interpreted by the browser, such
special characters should be uri-encoded, e.g. as \&lt;, \&amp; etc.

For example, an interactive helloworld program in C would be defined in HTML as

        <pre class="ace-interactive-code" data-lang="c">
        #include &lt;stdio.h&gt;
        int main() {
            puts("Hello world!\n");
        }
        </pre>


Version
=======
0.1

Configuration
=============
The plugin settings allow an administrator to set a different Jobe server
from that used by CodeRunner. This provides an extra level of security and isolates
any possible load placed on the jobe server by use of this plugin from the
normal production jobe server.

gi