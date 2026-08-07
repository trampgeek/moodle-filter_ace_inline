# The Moodle ace_inline filter

Richard Lobb, Michelle Hsieh, Andrew Bainbridge-Smith

Version 1.4.3, 6 August 2026.

Github repo: https://github.com/trampgeek/moodle-filter_ace_inline

## Introduction

A Moodle filter for displaying and optionally interacting with program code by utilising the Moodle CodeRunner question type plugin.
Unlike most Moodle filters, this one is mostly implemented in JavaScript rather than PHP and operates on the rendered HTML rather than the original text. This filter is applied over all HTML elements, therefore can be displayed throughout courses where the user can edit/create HTML elements.

As of Moodle 4.1, the following code adding and editing options are available:
  1. **Utilising the new TinyMCE editor's 'Code sample' option (Moodle 4.1+)**
	  * This option is recommended for casual code authors, as the editing UI allows direct copying and pasting of code without reformatting. Note: Due to TinyMCE's quirks, certain options are limited. See further information below.
  2. **Utilising Markdown Extra, either in the Moodle editor or externally for importing questions (Moodle 3.11+)**
	  * **WARNING:** Due a bug in Moodle, editing of Ace-inline code using Markdown Extra was unavailable
       from around Moodle 4.06 until the bug was fixed in August 2023. You probably
       need a recently updated Moodle 4.2 or later for this feature to be usable.
  3. **Editing the HTML directly in an HTML editor (Moodle 3.11+)**
	  * This option is recommended for code authors who require full functionality/customisation and are comfortable using HTML.
  4. **Simplified rendering control modes, from Version 1.4.0**
      * Prior to this version all fenced \<pre><code> blocks needed to be decorated with appropriate ace-inline filter attributes to enable the ace-inline editor.  With this mode enabled just specifiy the *language string* in the class is suffient.  This is particularly useful if writing Markdown as the *language string* following the triple-ticks (\`\`\`) can now be parsed with this mode enabled, details below.

The plugin provides two separate filter operations:
 1. Syntax highlighting (**highlight**): HTML \<pre> elements with an attribute of **data-ace-highlight-code**  are displayed using the JavaScript Ace code editor in read-only mode. This provides syntax colouring of the code.

 2. Code execution (**interactive**): HTML \<pre> elements with an attribute of **data-ace-interactive-code** are also displayed using the Ace code editor, but with editing enabled. In addition, a button labelled by default `Try it!` allows the student to execute the current state of the code and observe the outcome. With sufficient ingenuity on the part of the author, graphical output and images can be displayed, too (this option requires the author to edit the raw HTML). By adding additional html elements and linking the \<pre> element to them, the author can allow users to enter standard input to the run and even upload files.

It should be noted that the 'interactive' elements are interactive only in the sense that the user can edit and run them; the user cannot interact with the code whilst it is running. However, the code can be modified between executions. As this implementation is a filter, data is not stored persistently, and any changes to the code whilst the filter is activated will not be stored.

The plugin requires the CodeRunner plugin to be installed first, since that furnishes the Ace editor required for filter operations. **CodeRunner version 4.2.3 and Moodle 3.11 or later is required for basic functionality**, although some errors may not display properly.

It is /*recommended/* to use CodeRunner version 5.1+ in conjunction with Moodle 4.1 for full functionality.

In addition, the ace-interactive-code filter requires that the system administrator has enabled the CodeRunner sandbox web service which is disabled by default. The `Try it!` button send the code from the Ace editor to the CodeRunner sandbox (usually a Jobe server) for execution using that web service.

There is a page demonstrating the use of this filter on the CodeRunner site [here](5).

## Editor options
To change text editors in Moodle, click on your user icon, and select "Editor preferences". A drop-down menu can allow a user to switch between editors. Markdown is implemented in "Plain Text Area" and can be selected from a drop-down menu below the implementation of the text editor. TinyMCE referenced is labelled "TinyMCE editor" (**not** the legacy version) and is available from Moodle version 4.1+.

##  TinyMCE (Code sample)

This method is recommended for those who want a user-friendly way of implementing code in Moodle 4.1+. This editor-dependent method would suffice for basic use in most circumstances.

**How to use:**
* Click "Insert" > "Code sample".
* Select the programming language you wish to use.
* Either write your code normally in the "Code view" area, or copy and paste code into the area.
* Click "Save".
* Click "View" > "Source code".
* Locate the code in HTML and add either **data-ace-highlight-code** or **data-ace-interactive-code** into the \<pre> element. Example:
    ~~~
    <pre class="language-python" data-ace-interactive-code >
    <code>
        def hello():
            print("Hello world!")
        hello()
    </code>
    </pre>
    ~~~
* Add any other desired attributes in the \<pre> tag.
* Save the question.
* To edit the code, double-click on the code block in the editor.
  * Alternatively, view Source code to edit both code and parameters.
* Ace-inline formatting will be viewable outside of the editor; and in-built Prism formatting is visible within.

**Alternative Simplified mode *Enabled***
If you're only interested in the syntax highlighting then *enable* the simplified mode in the filter options, then there is no need to add the **data-ace-highlight-code** in the `<pre> fence.

**Caveats:**
* Currently, the use of \<script> tags are not supported by TinyMCE, even when using the Source Code option. Therefore, avoid the use of any \<script> tags, and avoid editing code containing any tags in this editor as the HTML is **automatically stripped of \<script> tags upon editing and saving any material**.
* Use the **'data-'** prefix for every starting parameter. TinyMCE will **strip away any non-'data' tags upon editing and saving the question**.
* If the author wants to use another language which is not available through TinyMCE's "Code sample" drop-down list, then the author should change the language to "HTML/XML" within "Code sample" and add the parameter **data-lang=*"language"*** to the \<pre> tag, where *"language"* represents the desired language in quotes; i.e. "java". Any implemented **data-lang** will override Code sample selected languages.
* Implementing Matplotlib can be done in TinyMCE without the Code mapper, but requires extensive use of HTML-escaped Python. The recommended way of implementing this is under the **Demos and samples** section.

## Markdown Extra editor

This method is recommended for those who want a familiar, consistent way of implementing code in Moodle's editors or in imported XML files. This method is editor-independent and would suffice for basic use and implementation of code in most circumstances.

**Note caveat for bug in (Moodle 3.11+) above.**

**How to use (Standard Use):**
* This filter can recognise both Markdown Extra notation from either imported questions, or from the in-built editor.
* Implement the code with standard Markdown Extra. Click [here](https://michelf.ca/projects/php-markdown/extra/) for a reference to Markdown Extra syntax.
* Add an attribute of either **data-ace-interactive-code=** or **data-ace-highlight-code=**. (Note: the **=** is necessary as Markdown validates tags by identifying "=")
* Add the attribute of the desired language as **data-lang=*language***.
* Add other desired attributes inline (within the {} next to the \`\`\`).
* Example:
    ~~~
    ``` {data-ace-highlight-code= data-lang=python3}
    def main():
        print("Hello world!")
    main()
    ```
    ~~~

**Caveats:**
* Make sure you follow valid Markdown Extra syntax. This means that any extra specified attributes have to be in the **same line** as the initial backticks (\`\`\`) and contain a **=** between each attribute and its value, and **no spaces** within either the attribute or the value (spaces are the delimiter for Markdown Extra).

**How to use (Simplified Use):**
* You must *enable* the simplified mode in the filter options.
* This filter can recognise a *language* string after the initial triple backticks (\`\`\`), as in conventional markdown norms.  This string is captured and parsed.
* Example below will Ace highlight a Python code block:
    ~~~
    ```python
    def main():
        print("Hello world!")
    main()
    ```
    ~~~
* The *language* string can be encoded, with elements separated by a colon (:).  No spaces are allowed in the string.  The first element of the string must be the language specifier. Other options should come in pairs as described in the table in section *Additional Display and Behaviour Attributes*.

* Example below will use Interactive Ace editor for python, with line numbering starting at 3.
    ~~~
    ```python:interactive:line-numbers:3
    def main():
        print("Hello world!")
    main()
    ```
    ~~~


## HTML editor

This method is recommended for those who want full functionality and customisation. It allows the use of advanced features which can transform implemented code with the use of JavaScript scripts embedded into the HTML. Basic familiarity with HTML is recommended, although all steps will be outlined below.

**How to use:**
* Write the code that you wish to implement between \<pre> tags (in a \<pre> element).
* Ensure that certain elements are appropriately HTML escaped (see section **HTML-escaping of code within the \<pre> element** section below).
* Add either **data-ace-interactive-code** or **data-ace-highlight-code** within the initial \<pre> tag.
* Add any other desired attributes in the \<pre> tag.
* Example:
~~~
    <pre data-ace-highlight-code data-lang="java">
    public class hello {
        public static void main(String[] args) {
            System.out.println("Hello world!");
        }
    }
    </pre>
~~~

**Caveats**
* See the section below on **HTML-escaping of code within the \<pre> element**.

## HTML-escaping of code within the \<PRE> element

When using ace-highlight-code or ace-interactive-code elements, problems arise when program code contains characters that have special meaning to the browser, i.e. are part of the HTML syntax. For example, in C:
~~~
    #include <stdio.h>
~~~

To ensure characters like '\<', '\&' etc are not interpreted by the browser, such special characters should be uri-encoded, e.g. as \&lt;, \&amp; etc.

For example, an interactive hello world program in C would be defined in HTML as:
~~~
    <pre class="ace-interactive-code" data-lang="c">
    #include &lt;stdio.h&gt;
    int main() {
        puts("Hello world!\n");
    }
    </pre>
~~~
Within the Ace editor the student just sees the URI-encoded characters as '\<', '\&' etc

## Additional Display and Behaviour Attributes
Additional control of the display and behaviour is via attributes of the
\<pre> element as follows. All attribute names should start with **data-** to ensure that the HTML still validates. However, the **data-** prefix can be dropped if you don't care about HTML5 validation. For example the **data-lang** attribute can just be **lang**.
**Warning:** removing the **data-** prefix can have unexpected effects, involving stripping of tags in certain editors. It is ***highly recommended*** to keep the data prefix in all instances.

Every attribute is supported in HTML.

| Prefix Attribute: | Description: | Supported/Available in:
|-------------------|--------------|-----------------------|
| **data-lang**     | This attribute sets the language to be used by the Ace editor for syntax colouring and in the case of interactive, the language for running the code on the Jobe server. A language must be supported in the Jobe server for the interactive code to run. Default: python3.| Highlight, Interactive, TinyMCE, Markdown |
| **data-ace-lang** | If set and non-empty, sets the language used by the Ace editor for syntax colouring, independently of **data-lang** in interactive. This allows the author to have syntax colouring different to the execution language in Jobe. Information on all Ace highlightable languages can be found [here](https://ace.c9.io/#nav=about) . | Highlight, Interactive, TinyMCE, Markdown |
| **data-start-line-number** | Sets the line number used for the first displayed line of code, if line numbers are to be shown. Set to **none** for no line numbers. Default is **none** for highlight elements and **1** for interactive elements. | Highlight, Interactive, TinyMCE, Markdown |
| **data-font-size** | Sets the display font size used by Ace. Default 14px. | Highlight, Interactive, TinyMCE, Markdown,  Simplified Mode |
| **data-min-lines** | The minimum number of lines to display in the Ace editor. | Highlight, Interactive, TinyMCE, Markdown, Simplified Mode |
| **data-max-lines** | The maximum number of lines to display in the Ace editor. | Highlight, Interactive, TinyMCE, Markdown, Simplified Mode |
| **data-dark-theme-mode** | Selects when to use a dark mode for the Ace editor. Has values 0, 1 or 2 for no, maybe and yes. If 1 (maybe) is chosen, the dark theme will be used if the browser's prefers-color-scheme:dark media query returns a match, so this may change with browser, operating system or time of day. The default value is set by the administrator setting for the plugin. | Highlight, Interactive, TinyMCE, Markdown, Simplified Mode |
| **data-button-name** | This sets the text within the Try it! button. Default 'Try it!'. | Interactive, TinyMCE, Markdown, Simplified Mode (provided it is a single word) |
| **data-readonly** | This disables editing of the code, so students can only run the supplied code without modification. The `Try it!` button is still displayed and operational.| Interactive, TinyMCE, Markdown, Simplified Mode |
| **data-hidden** | This hides the code, leaving only `Try it!` visible. | Interactive, TinyMCE, Markdown, Simplified Mode |
| **data-stdin-taid** | This string value specifies the ID of a textarea element and supplies the HTMLelement.innerText attribute as standard input to the program when the `Try it!` button is clicked. Overrides data-stdin if both are given (and data-stdin is deprecated). | Interactive, TinyMCE, Markdown, Simplified Mode |
| **data-file-taids** | This attribute provides a pseudo-file interface where the user is able to treat one or more supplementary textarea elements like files, entering the pseudo-file contents into the textarea(s) before clicking `Try it!`. The attribute is a JSON specification that maps from filename(s) to the ID(s) of textarea element(s) and supplies the HTMLelement.innerText attribute that will be used to provide the job with one or more files in the working directory. For each attribute, a file of the specified filename is created and the contents of that file are the contents of the associated textarea at the time `Try it!` is clicked. | Interactive, TinyMCE |
| **data-file-upload-id** | This attribute is the ID of an \<input type="file> element. The user can select one or more files (at 2MB max each) using this element and the files are uploaded into the program's working space when it is run. Additionally, filenames will be stripped of symbols that throw errors in executing Jobe. These filenames are also implemented on the command line as argv, and can be accessible by parsing the args. | Interactive, TinyMCE, Markdown, Simplified Mode |
| **data-params** | This is a JSON object that defines any Jobe sandbox parameters that are to have non-standard values, such as `cputime` and `memorylimit`. This shouldn't generally be needed. Default: '{"cputime": 5}'. Note that the maximum cputime is set via the administrative interface for the CodeRunner web service and any attempt to exceed that will display an error. | Interactive, TinyMCE |
| **data-code-mapper** | This string value must be the name of a global JavaScript function (usually defined in a \<script> element preceding the \<pre> element) that takes the Ace editor code as a parameter and returns a modified version, e.g. with extra code inserted. If used in conjunction with data-prefix and data-suffix (below), the code-mapper function is applied first and then the prefix and/or suffix code is added. | Interactive, Markdown, Simplified Mode |
| **data-prefix** |  This string value is code to be inserted in front of the contents of the ace editor before sending the program to the Jobe server for execution. An extra newline is *not* inserted between the two strings, so if you want one you must include it explicitly. | Interactive, TinyMCE, Markdown |
| **data-suffix** |  This string value is code to be inserted after the contents of the ace editor before sending the program to the Jobe server for execution. An extra newline is *not* inserted between the two strings, so if you want one you must include it explicitly. | Interactive, TinyMCE, Markdown |
| **data-html-output** | If this attribute is present (with any value) the output from the run is interpreted as raw HTML. The output from the program is simply wrapped in a \<div> element and inserted directly after `Try it!`. An example of a ace-interactive-code panel that that uses data-prefix, data-suffix and data-html-output to provide Matplotlib graphical output in Python is included in the repo `samples` folder (the file `demoaceinline.xml`). | Interactive, TinyMCE, Markdown, Simplified Mode |
| **data-max-output-length** | The maximum length of an output string (more or less). Output greater than this is truncated. Default 30,000 characters. | Interactive, TinyMCE, Markdown |
| **line-numbers** | Sets the line number used for the first displayed line of code. Default is **1**.  If Option is not specified then line-number is off in highlighted elements. | Simplified Mode |


**For simplified mode the *data-* prefix is not required.**


### Code examples:

Further code examples can be found in the repo `samples` folder.

The following code examples all output "Hello world!".
##
**TinyMCE C program formatting with Code sample.**
Open editor and create a new Code sample in C. Copy and paste the corresponding program into the Code view.
```
#include <stdio.h>
int main() {
   printf("Hello world!");
   return 0;
}
```
Then view the HTML from the Source Code editor in TinyMCE and add **data-ace-interactive** into the \<pre> tag.
The HTML should look like this after adding the tag:
```
<pre class="language-c" data-ace-interactive-code>
<code>#include &lt;stdio.h&gt;
int main() {
   printf("Hello world!");
   return 0;
}</code>
</pre>
```
##
**Markdown Extra Java program formatting with hidden code and `Markdown` button.**
~~~
``` {data-ace-interactive-code= data-lang=Java data-hidden=true data-button-name=Markdown}
public class hello {
    public static void main(String[] args) {
        System.out.println("Hello world!");
    }
}
```
~~~
##
**HTML-made Python program with HTML highlighting and code mapper that reverses the code before execution.**
~~~
<script>
    function reverser(text) {
        let split = text.split("");
        let reversed = split.reverse();
        let joined = reversed.join("");
        return joined;
    }
</script>
<pre data-ace-interactive-code data-ace-lang=html data-code-mapper="reverser">)"!dlrow olleH"(tnirp
</pre>
~~~
##
**TinyMCE text area stdin taid demo in Python.**
Input this directly into the Source Code editor.
~~~
<textarea id="text-demo" cols="40" rows="4">Hello world!</textarea>
~~~
Then insert a Code sample in Python, with the code as below:
~~~
while 1:
    try:
        print(input())
    except EOFError:
        break
~~~
Now, inspect the Source Code and add **data-ace-interactive-code** and **data-stdin-taid="text-demo"** into the \<pre> tag.
After inserting both attributes, the source code should look like:
~~~
<p><textarea id="text-demo" cols="40" rows="4">Hello world!</textarea></p>
<pre class="language-python" data-ace-interactive-code data-stdin-taid="text-demo">
<code>while 1:
    try:
        print(input())
    except EOFError:
        break
</code>
</pre>
~~~

## Demos and Samples

There is a page demonstrating most of the capabilities of this filter on the CodeRunner site [here](https://coderunner.org.nz/mod/page/view.php?id=529). The underlying HTML on that page is mostly the same as in the file `[testaceinline.xml](https://github.com/trampgeek/moodle filter_ace_inline/blob/master/tests/fixtures/demoaceinline.xml)`, which is included in the Github repo, in the `samples` folder. If you want to experiment yourself, you can download that file and import it as an xml question into the question bank on Moodle. Open it for editing and switch to HTML mode to see how it is set up. It includes a final complex example of a Python3 interactive element that runs numpy and matplotlib, displaying any output graphs as images in addition to any text output. This final example needs to have numpy and matplotlib installed on the Jobe server; they are not there by default, and has to be implemented via an HTML editor which is **not** TinyMCE in order to avoid \<script> stripping.

**TinyMCE matplotlib formatting**

Due to the \<script> stripping, there is a demo of an alternative TinyMCE-friendly matplotlib and numpy implementation, using prefix and suffix code with HTML-escaped Python, in the file `[demotinymatplotlib.xml](https://github.com/trampgeek/moodle filter_ace_inline/blob/master/tests/fixtures/demotinymatplotlib.xml)`, which can be found in the Github repo in the `samples` folder.
It is highly recommended to import the question into Moodle as above, and then edit the pre-existing code to suit an author's needs.

## Installation and configuration

Download the plugin from the repository, and unzip the code into

        <moodlehome>/filter/ace_inline

Then visit Site administration > Notifications. You should receive the usual prompt about updating the database to incorporate the new plugin.

Once installed, visit Site administration > Plugins > Plugins overview > Additional plugins. From this page, click the icon next to "Text filters" and turn "Ace inline" to "Off, but available".

This allows the individual teacher/administrator to set local settings for each course; if desired. To access individual course settings, click "More" > "Filters" and set Ace inline to "On".

To use the **interactive** filter, you will also need to enable the **sandbox web service** option within the **CodeRunner plugin** settings. You should read carefully the other related CodeRunner web service settings and consider the various implications. Setting up a separate Jobe server for the web service is recommended if heavy usage of interactive code is likely, in order to mitigate against overload of the main Jobe server.

Note: CodeRunner settings for the web service has a default value for the maximum submission rate (submissions per hour) by any given Moodle user, as this limits the potential for abuse by any student. Use of any interactive execution (running */Try it!/*) will contribute towards this limit.

There are three plugin administrator setting provided directly by this plugin:

  1.  The default button name for **interactive** elements can be changed from its default name: *Try it!* (or whatever was set by the language settings for non-English users) to anything else.
  2.  The administrator can set whether to use the Ace editor's light theme or dark theme by default (although individual filter instances can override this with the data-dark-theme-mode option). There is also an option to use the dark theme 'sometimes', meaning whenever the browser's 'prefers-color-scheme:dark' media query returns a match. This may change with browser, operating system or time of day.
  3.  The administrator can set two different modes about how \<pre><code> blocks should be interpreted.  This is called the *Simplified Mode* which can be either *Off* or *Enabled*.  Markdown and TinyMCE will always put example class decorators in such blocks: (1) Off: \<pre><code> fences must be explicitly decorated to turn on the ace inline filter.  (2) Enabled: a simple class setting with just one attribute in the \<pre> fence will be taken as a language setting and will be ace highlighted (typical from TinyMCE), or a single class setting in a \<code> fence will be parsed to enable many ace inline features (typical of Markdown).

Each of these three settings can also be overridden for an individual course (or other context) (new in v1.4.1). From the course, click "More" > "Filters" and, once "Ace inline" is set to "On", click the "Settings" link next to it to override any of the three settings for that course only. Leave a field as "Use site default" to keep inheriting the site administrator's setting.

## Unexpected behaviour in certain areas of Moodle

Currently, in Moodle 4.1, the forum discussion (but not the general description) strips all tags aside from the "class" tag from any HTML elements. This is editor independent. By using the pre-existing [deprecated] method of setting the \<pre> **class='ace-interactive-code'** or **class='ace-highlight-code'** basic Python 3 functionality can be implemented.

Alternatively, prefix the desired language with **language-** and insert this into the \<pre> class, alongside with **ace-highlight/interactive-code** option to implement basic functionality in the selected language.
Example:
~~~
    <pre class="language-python ace-interactive-code">
    <code>
            def hello():
                 print("Hello world!")
            hello()
    </code>
    </pre>
~~~

Firefox browsers have dynamic scrollbars that hide when the cursor is not hovering over it. To avoid confusion from what may appear as missing code (when in fact, the component is scrollable), the component will expand in width in Firefox browsers to display all code in a line.
This may cause some visual discrepancies between other browsers and Firefox, however functionality remains identical.

It is also recommended to adjust the settings of the scrollbar style in the Firefox browser to allow ease of use.

## Change History
 * Version 1.4.4
   Reworked the name for the new feature from Markdown Extended to Simplified Mode.
   The feature now allows minimist TinyMCE usage to also result in syntax highlighting.

 * Version 1.4.3
   Added Behat tests for the Extended Markdown rendering mode, covering both
   highlighted (read-only) and interactive rendering, for both C and Python
   fenced code blocks (`tests/behat/extended_markdown.feature`). (Claude written)

 * Version 1.4.2
   Added Behat tests covering both the site administrator settings page and the
   new per-course (context-level) settings overrides for the button label, dark
   theme mode and markdown rendering settings. Fixed a bug found while writing
   these tests: a course-level override was only being applied to content
   filtered directly in that exact course context, not to content inside
   activities within the course (which are filtered in their own, separate,
   module context nested below it); the filter now also checks ancestor
   contexts for an override, so a course-level override applies throughout
   that course as expected. (Claude written)

 * Version 1.4.1
   Added support for overriding the three administrator settings (button label, dark theme mode, markdown rendering) at a per-context (e.g. per-course) level. From a course's "More > Filters" page, click "Settings" next to "Ace inline" to override any of these for that course; leave a field as "Use site default" to keep inheriting the administrator's setting. Credit to Paul McKeown for the this idea.

 * Version 1.4.0
   Added feature for allowing standard language string to be added to a markdown code block (triple tick).  This language string can also be encoded with addition Ace filter parameters - the elements separated by colons (:).  Added administrative setting to allow control of Markdown code block rendered, including this new feature (which is called Extended).

 * Version 1.3.11
   Added code to defer hiding of the original &lt;pre&gt; element until the rendering of the content by Ace is complete. If this doesn't happen within 2 seconds,
   the pre element is enclosed in a red border with a warning message and the ace content plus any associated UI is removed.
   
 * Version 1.3.10
   Upgrade to Moodle 4.5 compatibility plus various code and test polishing. All thanks to Luca Bösch.
   
 * Version 1.3.9
   Change background colour of read-only ace-inline divs to light grey
   to distinguish them for editable ones. Various tweaks to behat tests and style file to
   keep the githug CI style checkers happy.
   
 * Version 1.3.8
    Trivial change: confusing error message 'User config error' changed to just 'Run error', as could
    include submission limit reached, for example.

 * Version 1.3.7
    Bug fix for issue #30: latest update won't install (due to bad zip uploaded to Moodle plugin repository.)

 * Version 1.3.6
    Update documentation relating to the use of Markdown extra editing.

 * Version 1.3.5
    * Bug fix: State of filter reverted to 'Off but available' whenever the admin
      filter manager was opened.

 * Version 1.3.4, 1 August 2023.
    * Adding space after each Try it box

 * Version 1.3.3, 10 May 2023.
    * Fix issues with Ace window being far too narrow in many multi-column contexts.

 * Version 1.3.2, 30 April 2023.
    * Fixed issue with replacing the wrong node in MarkdownExtra formatting.
    * Fixed administrator's default "Try it!" setting to actually work.
    * Fixed setting minwidth in multichoice so that text will not be truncated.
    * Added support to allow "style" components to be adapted in. Will be overwritten by Ace Display settings, however, allows other styles such as "min-width" or "margin" to be set with expected results.

 * Version 1.3.1, 15 February 2023.
    * Fixed code to adhere to Eslint.

 * Version 1.3, 7 February 2023.
    * Changed global dynamic hooks to differentiate between the two.

 * Version 1.2.2, 19 January 2023.
    * Updated CI for PHP8 with Moodle 4.1.
    * Kept Firefox handling code boxes with expansion; changed rest to scrolling.
    * Checked with Moodle_3x_stable for compatibility.
    * Updated ReadMe with CodeRunner requirements and Firefox scrollbar issue.

 * Version 1.2.1, 19 December 2022.
    * Added a privacy folder with provider.php.
    * Cleaned up ReadMe.

 * Version 1.2.0, 15 December 2022.
    * Added full error handling and file upload size restrictions (2MB).
    * Mapped files with boxes appropriately.

 * Version 1.1.1, 13 December 2022.
    * Changed modules to local, as per Moodle Documentation.
    * Added file-parsing to JOBE running requirements, including user warnings.
    * Can now use argv's to find filenames and run them.
    * ReadMe and examples to be added tomorrow.

 * Version 1.1.0, 12 December 2022.
    * Entire program is now in Vanilla ES.
        * Decomposed with UiParameters as a class.
        * ace_inline_code.js is the entry class.
        * Remaining supporting classes are in modules.

 * Version 1.0.2, 8 December 2022.
    * Removed all jQuery from code to prepare for ES6 transition.
    * Renamed Behat tests for better definition.
    * Changed Behat tests to insert .txt files from fixtures straight into db instead, to reduce UI dependency.
    * Implemented CI.

 * Version 1.0.1, 5 December 2022.
    * Updated ReadMe fully.
    * Added demo for Matplotlib in TinyMCE.
    * Updated demoaceinline.xml.
    * Patched issue with empty text areas being treated as empty ids. Updated tests accordingly.
    * Cleaned code to comply with Moodle Code Checker.

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
