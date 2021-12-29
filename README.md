Source code repository
=====================
https://github.com/trampgeek/moodle_filter_ace_inline

Short Description
=================
A Moodle filter that displays code inline using the Ace editor, possibly also
allowing a simple REPL mode if a sufficiently recent version of the CodeRunner
question type plug in is installed.

Long Description
===============
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

Additional control of the display and behaviour is via text attributes as follows:

 1. lang. This attribute sets the language to be used
    by the Ace editor for
    syntax colouring and, in the case of the ace-interactive-code, the language
    for running the code on the Jobe server. Default: python3. Example:

        <pre class="ace-highlight-code" lang="c">
        #include <stdio.h>
        int main() {
            puts("Hello world");
        }
        </pre>


2. show-line-numbers. This attribute sets whether or not line number are shown.
   Its value is interpreted as a logical value by JavaScript. Use 0 or 'false'
   to turn off line numbers. All other values are interpreted as 'true'.
   Default: false for ace-highlight-code, true for ace-interactive-code.

3. start-line-number. Sets the line number used for the first displayed line of
   code. Default 1. Relevant only if show-line-numbers is true.

4. font-size. Sets the display font size used by Ace. Default 14px.

5. output-lines. This sets the size (number of rows) of the text area
   that displays the output of the code when executed via the Try it! button.
   Relevant only to ace-interactive-code elements. Default 1. Example:

        <pre class="ace-highlight-code" output-lines="10">
        # Default lang = python
        for i in range(10):
            print(i, i * i)
        <pre>

6. button-name. This sets the text within the Try it! button.
   Relevant only to ace-interactive-code elements. Default 'Try it!'.
   Example:

        <pre class="ace-highlight-code" button-name="Run" output-lines="10">
        # Default lang = python
        for i in range(10):
            print(i, i * i)
        </pre>

7. jobe-server. This sets the URL of the Jobe server to be used to run the job.
   Relevant only to ace-interactive-code elements. Default: whatever is set
   by the administrator via the plugin's setting form (which itself defaults
   to the server(s) used by CodeRunner).


Version
=======
0.1

Configuration
=============
The plugin settings allow an administrator to set a different Jobe server
from that used by CodeRunner. This provides an extra level of security and isolates
any possible load placed on the jobe server by use of this plugin from the
normal production jobe server.

