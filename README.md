# The Moodle ace_inline filter

Richard Lobb, Michelle Hsieh, Andrew Bainbridge-Smith

Version 1.5.7, 22 August 2026.

Github repo: https://github.com/trampgeek/moodle-filter_ace_inline

## Introduction
A Moodle filter for syntax highlighting and optionally interacting with program code by utilising the Moodle CodeRunner question type plugin.  

Unlike most Moodle filters, this one is mostly implemented in JavaScript rather than PHP and operates on the rendered HTML rather than the original text. This filter is applied to all HTML elements, and can therefore be displayed throughout courses where the user can edit/create HTML elements.  The filter also works with Markdown written text, and operates after the conversion from Markdown to HTML.

The display control mechanism used by the plugin is the JavaScript [*Ace Editor*](https://ace.c9.io).

The plugin requires the CodeRunner plugin to be installed first, since that furnishes the Ace editor required for filter operations. **CodeRunner version 4.2.1 or later, and Moodle 4.3 or later, are required** - Moodle enforces this minimum at install time. This plugin is tested in continuous integration against Moodle 4.3 through 5.2.


## Installation
Download the plugin from the repository, and unzip the code into

        <moodlehome>/public/filter/ace_inline

Then visit Site administration > Notifications. You should receive the usual prompt about updating the database to incorporate the new plugin.

Once installed, visit Site administration > Plugins > Plugins overview > Additional plugins. From this page, click the icon next to "Text filters" and turn "Ace inline" to "Off, but available".

This allows the individual teacher/administrator to set local settings for each course, if desired. To access individual course settings, click "More" > "Filters" and set Ace inline to "On".

To use the **interactive** filter, you will also need to enable the **sandbox web service** option within the **CodeRunner plugin** settings. You should read carefully the other related CodeRunner web service settings and consider the various implications. Setting up a separate Jobe server for the web service is recommended if heavy usage of interactive code is likely, in order to mitigate against overload of the main Jobe server.

Note: CodeRunner settings for the web service have a default value for the maximum submission rate (submissions per hour) by any given Moodle user, as this limits the potential for abuse by any student. Use of any interactive execution (running *Try it!*) will contribute towards this limit.


## Configuration
There are three administrator settings provided directly by this plugin:

  1.  **Dark Mode**: Whether to use the Ace editor's light theme or dark theme by default. There is also an option to use the dark theme 'sometimes', meaning whenever the browser's 'prefers-color-scheme:dark' media query returns a match. This may change with browser, operating system or time of day.
  2.  **Button Label**: The default button name for *interactive* elements can be changed from its default name: *Try it!* (or whatever was set by the language settings for non-English users) to anything else.
  3.  **Simplified Mode**: Whether the simplified authoring mode is *enabled* or *off*.  *Off* means **only** classic mode authoring of code blocks can activate the ace rendering engine. *Enabled* means **both** classic and simplified authoring of code blocks can activate the ace rendering engine. More on authoring modes below.
  
These settings can be set at a Site level by Site Admin, and then overridden at the Course Category, Course, and individual Module level (*More/Filters*) for fine-grained control. The one exception is a Question Bank module's own context: a question's rendering is always governed by whichever context it's actually being displayed in (e.g. a quiz), not the question bank it was authored in, so an override set there would have no effect outside that bank's own preview pages - this option is therefore not offered for Question Bank modules.

## Rendering Modes
The filter has two rendering modes: *highlight* and *interactive*.  Highlight applies syntax highlighting only (read-only).  There are also other rendering attributes that can be specified to modify these base behaviours.

*interactive* includes a button (default label of `Try it!`) that will execute the current state of the code using the CodeRunner plugin mechanics and the sandbox *Jobe* server. With sufficient ingenuity on the part of the author, graphical output and images can be displayed. Further mechanisms for supplying user inputs to the running program (such as files, or linking to other html elements) can also be specified. This is controlled by additional rendering attributes.

Note that the code is not executed on the client. It should also be noted that the *interactive* elements are interactive only in the sense that the user can edit and run them; the user cannot interact with the code whilst it is running. However, the code can be modified between executions. As this implementation is a filter, data is not stored persistently, and any changes to the code whilst the filter is activated will not be stored.

Specification of the rendering mode is made by decorating the `<pre>` fence for HTML authored text or after the triple backticks (\`\`\`) in the case of Markdown authored text.  More on authoring modes below, with examples after that.

Finally, there are a number of additional rendering attributes that are described later in this document.


## Authoring Modes
The filter supports four authoring modes, as combinations of either HTML or Markdown text, and classic or simplified mode for attribute specification.  The simplified mode was introduced in version 1.4.  Specifically the modes are:

1. HTML-classic
2. HTML-simplified
3. Markdown-classic
4. Markdown-simplified

Authoring modes specify how you write code blocks and in particular rendering attributes for the ace engine.

There is an interaction between authoring modes and authoring tools users should be aware of:

 - The **TinyMCE** editor is a fantastic tool for authoring in HTML mode.  The editor does a great job of cleaning up HTML code and will strip out ill-formed constructs.  The rendering modes and attributes **must** be specified in the `<pre>` fence when authoring in HTML mode.  Examples are given later.
 - The **Markdown Extra** engine used by Moodle will capture the text after the typical initial triple backticks (\`\`\`) as a `class` attribute in the rendered HTML of the `<code>` fence.  Note that this text must contain whitespaces or the semicolon (;).  Alternatively if a bracketed form (\{\}) follows the backticks then these contents are rendered as attributes within the `<code>` fence.  It is the different ways that the text following the backticks is interpreted that leads to the *classic* and *simplified* authoring modes.  Again examples are given later.

Both **TinyMCE** and **Markdown Extra** ensure the authored code block is encapsulated in the HTML fence `<pre><code>`.

If the simplified authoring mode is *enabled* then the `class` attribute in the `<pre>` fence for HTML authored text, or in the `<code>` authored text will be interpreted as an encoded string that specifies the *language* of the code block and other ace rendering attributes (see below).


## Rendering Attributes
Additional control of the display and behaviour is via attributes of the
`<pre>` fence element for HTML authoring, or the `<code>` fence element for Markdown, as follows. All attribute names should start with **data-** to ensure that the HTML still validates. However, the **data-** prefix can be dropped if you don't care about HTML5 validation, or using the *simplified* mode. For example the **data-lang** attribute can just be **lang**.

**Warning:** removing the **data-** prefix can have unexpected effects, involving stripping of tags in certain editors -- especially **TinyMCE**. It is ***highly recommended*** to keep the data prefix in all instances.

Every attribute is supported when authoring in raw HTML. The last column of the table lists the other authoring methods that support each attribute.

| Prefix Attribute: | Description: | Supported/Available in: |
|-------------------|--------------|-----------------------|
| **data-lang**     | This attribute sets the language to be used by the Ace editor for syntax colouring and in the case of interactive, the language for running the code on the Jobe server. A language must be supported in the Jobe server for the interactive code to run. Default: python3.| Highlight, Interactive, TinyMCE, Markdown, Simplified Mode |
| **data-ace-lang** | If set and non-empty, sets the language used by the Ace editor for syntax colouring, independently of **data-lang** in interactive. This allows the author to have syntax colouring different to the execution language in Jobe. Information on all Ace highlightable languages can be found [here](https://ace.c9.io/#nav=about) . | Highlight, Interactive, TinyMCE, Markdown, Simplified Mode |
| **data-start-line-number** | Sets the line number used for the first displayed line of code, if line numbers are to be shown. Set to **none** for no line numbers. Default is **none** for highlight elements and **1** for interactive elements. | Highlight, Interactive, TinyMCE, Markdown, Simplified Mode |
| **data-font-size** | Sets the display font size used by Ace. Default 14px. | Highlight, Interactive, TinyMCE, Markdown,  Simplified Mode |
| **data-min-lines** | The minimum number of lines to display in the Ace editor. | Highlight, Interactive, TinyMCE, Markdown, Simplified Mode |
| **data-max-lines** | The maximum number of lines to display in the Ace editor. | Highlight, Interactive, TinyMCE, Markdown, Simplified Mode |
| **data-dark-theme-mode** | Selects when to use a dark mode for the Ace editor. Has values 0, 1 or 2 for no, maybe and yes. If 1 (maybe) is chosen, the dark theme will be used if the browser's prefers-color-scheme:dark media query returns a match, so this may change with browser, operating system or time of day. The default value is set by the administrator setting for the plugin. | Highlight, Interactive, TinyMCE, Markdown, Simplified Mode |
| **data-button-name** | This sets the text within the Try it! button. Default 'Try it!'. | Interactive, TinyMCE, Markdown, Simplified Mode (provided it is a single word) |
| **data-readonly** | This disables editing of the code, so students can only run the supplied code without modification. The `Try it!` button is still displayed and operational.| Interactive, TinyMCE, Markdown, Simplified Mode |
| **data-hidden** | This hides the code, leaving only `Try it!` visible. | Interactive, TinyMCE, Markdown, Simplified Mode |
| **data-stdin-taid** | This string value specifies the ID of a textarea element and supplies the HTMLelement.innerText attribute as standard input to the program when the `Try it!` button is clicked. Overrides data-stdin if both are given (and data-stdin is deprecated). | Interactive, TinyMCE, Markdown, Simplified Mode |
| **data-stdin** | ***Deprecated** - use data-stdin-taid instead.* This string value is supplied directly as standard input to the program when the `Try it!` button is clicked. | Interactive, TinyMCE, Markdown, Simplified Mode |
| **data-file-taids** | This attribute provides a pseudo-file interface where the user is able to treat one or more supplementary textarea elements like files, entering the pseudo-file contents into the textarea(s) before clicking `Try it!`. The attribute is a JSON specification that maps from filename(s) to the ID(s) of textarea element(s) and supplies the HTMLelement.innerText attribute that will be used to provide the job with one or more files in the working directory. For each attribute, a file of the specified filename is created and the contents of that file are the contents of the associated textarea at the time `Try it!` is clicked. | Interactive, TinyMCE |
| **data-file-upload-id** | This attribute is the ID of an `<input type="file">` element. The user can select one or more files (at 2MB max each) using this element and the files are uploaded into the program's working space when it is run. Additionally, filenames will be stripped of symbols that throw errors in executing Jobe. These filenames are also implemented on the command line as argv, and can be accessed by parsing the args. | Interactive, TinyMCE, Markdown, Simplified Mode |
| **data-params** | This is a JSON object that defines any Jobe sandbox parameters that are to have non-standard values, such as `cputime` and `memorylimit`. This shouldn't generally be needed. Default: '{"cputime": 5}'. Note that the maximum cputime is set via the administrative interface for the CodeRunner web service and any attempt to exceed that will display an error. | Interactive, TinyMCE |
| **data-code-mapper** | This string value must be the name of a global JavaScript function (usually defined in a `<script>` element preceding the `<pre>` element) that takes the Ace editor code as a parameter and returns a modified version, e.g. with extra code inserted. If used in conjunction with data-prefix and data-suffix (below), the code-mapper function is applied first and then the prefix and/or suffix code is added. | Interactive, Markdown, Simplified Mode |
| **data-prefix** |  This string value is code to be inserted in front of the contents of the ace editor before sending the program to the Jobe server for execution. An extra newline is *not* inserted between the two strings, so if you want one you must include it explicitly. | Interactive, TinyMCE, Markdown |
| **data-suffix** |  This string value is code to be inserted after the contents of the ace editor before sending the program to the Jobe server for execution. An extra newline is *not* inserted between the two strings, so if you want one you must include it explicitly. | Interactive, TinyMCE, Markdown |
| **data-html-output** | If this attribute is present (with any value) the output from the run is interpreted as raw HTML. The output from the program is simply wrapped in a `<div>` element and inserted directly after `Try it!`. An example of an ace-interactive-code panel that uses data-prefix, data-suffix and data-html-output to provide Matplotlib graphical output in Python is included in the repo `samples` folder (the file `demoaceinline.xml`). | Interactive, TinyMCE, Markdown, Simplified Mode |
| **data-max-output-length** | The maximum length of an output string (more or less). Output greater than this is truncated. Default 30,000 characters. | Interactive, TinyMCE, Markdown, Simplified Mode |
| **line-numbers** | Sets the line number used for the first displayed line of code. Default is **1**.  If Option is not specified then line-number is off in highlighted elements. | Simplified Mode |

**For simplified mode the *data-* prefix is not required.**


## Editor options for authoring modes
To change text editors in Moodle, click on your user icon, and select "Editor preferences". A drop-down menu can allow a user to switch between editors. Markdown is implemented in "Plain Text Area" and can be selected from a drop-down menu below the implementation of the text editor. TinyMCE referenced is labelled "TinyMCE editor" (**not** the legacy version) and is available from Moodle version 4.1+.


## Example using HTML editor -- TinyMCE (Code sample)
This method is recommended for those who want a user-friendly way of implementing code in Moodle 4.1+. This editor-dependent method would suffice for basic use in most circumstances.

HTML (including embedded in Markdown) is required for full functionality and customisation. It allows the use of advanced features which can transform implemented code with the use of JavaScript scripts embedded into the HTML. Basic familiarity with HTML is recommended, although all steps will be outlined below.

**How to use:**

* Click "Insert" > "Code sample".
* Select the programming language you wish to use.
* Either write your code normally in the "Code view" area, or copy and paste code into the area.
* Click "Save".
* Click "View" > "Source code".
* Locate the code in HTML and add either **data-ace-highlight-code** or **data-ace-interactive-code** into the `<pre>` element. Example:

~~~
    <pre class="language-python" data-ace-interactive-code >
    <code>
        def hello():
            print("Hello world!")
        hello()
    </code>
    </pre>
~~~

* Add any other desired attributes in the `<pre>` tag.
* Save the question.
* To edit the code, double-click on the code block in the editor.
  * Alternatively, view Source code to edit both code and parameters.
* Ace-inline formatting will be viewable outside of the editor, and in-built Prism formatting is visible within.

**Alternative Simplified mode *Enabled***

If you're only interested in the syntax highlighting then *enable* the simplified mode in the filter options, then there is no need to add the **data-ace-highlight-code** in the `<pre>` fence.

**Caveats:**

* Currently, the use of `<script>` tags is not supported by TinyMCE, even when using the Source Code option. Therefore, avoid the use of any `<script>` tags, and avoid editing code containing any tags in this editor as the HTML is **automatically stripped of `<script>` tags upon editing and saving any material**.
* Use the **'data-'** prefix for every starting parameter. TinyMCE will **strip away any non-'data' tags upon editing and saving the question**.
* If the author wants to use another language which is not available through TinyMCE's "Code sample" drop-down list, then the author should change the language to "HTML/XML" within "Code sample" and add the parameter **data-lang=*"language"*** to the `<pre>` tag, where *"language"* represents the desired language in quotes; i.e. "java". Any implemented **data-lang** will override Code sample selected languages.
* Implementing Matplotlib can be done in TinyMCE without the Code mapper, but requires extensive use of HTML-escaped Python. The recommended way of implementing this is under the **Demos and samples** section.


## HTML-escaping of code within the `<PRE>` element
When using ace-highlight-code or ace-interactive-code elements, problems arise when program code contains characters that have special meaning to the browser, i.e. are part of the HTML syntax. For example, in C:
~~~
    #include <stdio.h>
~~~

To ensure characters like `<` and `&` are not interpreted by the browser, such special characters should be written as HTML entities, e.g. `&lt;`, `&amp;` etc.

For example, an interactive hello world program in C would be defined in HTML as:
~~~
    <pre data-ace-interactive-code data-lang="c">
    #include &lt;stdio.h&gt;
    int main() {
        puts("Hello world!\n");
    }
    </pre>
~~~
Within the Ace editor the student just sees the decoded characters `<`, `&` etc.



## Markdown Extra editor
This method is recommended for those who want a familiar, consistent way of implementing code in Moodle's editors or in imported XML files. This method is editor-independent and would suffice for basic use and implementation of code in most circumstances.

HTML (including embedded in Markdown) is required for full functionality and customisation. It allows the use of advanced features which can transform implemented code with the use of JavaScript scripts embedded into the HTML. Basic familiarity with HTML is recommended, although all steps will be outlined below.

**How to use (Classic Use):**

* This filter can recognise both Markdown Extra notation from either imported questions, or from the in-built editor.
* Implement the code with standard Markdown Extra. Click [here](https://michelf.ca/projects/php-markdown/extra/) for a reference to Markdown Extra syntax.
* Add an attribute of either **data-ace-interactive-code=** or **data-ace-highlight-code=**. (Note: the **=** is necessary as Markdown validates tags by identifying "=")
* Add the attribute of the desired language as **data-lang=*language***.
* Add other desired attributes inline (within the {} next to the \`\`\`).
* Example:

        ``` {data-ace-highlight-code= data-lang=python3}
        def main():
            print("Hello world!")
        main()
        ```

**Caveats:**

* Make sure you follow valid Markdown Extra syntax. This means that any extra specified attributes have to be in the **same line** as the initial backticks (\`\`\`) and contain a **=** between each attribute and its value, and **no spaces** within either the attribute or the value (spaces are the delimiter for Markdown Extra).

**How to use (Simplified Use):**

* You must *enable* the simplified mode in the filter options.
* This filter can recognise a *language* string after the initial triple backticks (\`\`\`), as in conventional markdown norms.  This string is captured and parsed.
* Example below will Ace highlight a Python code block:

        ```python
        def main():
            print("Hello world!")
        main()
        ```
* The *language* string can be encoded, with elements separated by a colon (:).  No spaces are allowed in the string.  The first element of the string must be the language specifier. It may be followed by the flag *interactive*, to use the interactive Ace editor rather than read-only highlighting, and by attribute/value pairs as described in the table in section *Rendering Attributes*.

* Example below will use Interactive Ace editor for python, with line numbering starting at 3.

        ```python:interactive:line-numbers:3
        def main():
            print("Hello world!")
        main()
        ```


### Code examples:
Further code examples can be found in the repo `samples` folder.

The following code examples all output "Hello world!".

---

**TinyMCE C program formatting with Code sample.**

Open editor and create a new Code sample in C. Copy and paste the corresponding program into the Code view.
```
#include <stdio.h>
int main() {
   printf("Hello world!");
   return 0;
}
```
Then view the HTML from the Source Code editor in TinyMCE and add **data-ace-interactive-code** into the `<pre>` tag.
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

---

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

---

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

---

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
Now, inspect the Source Code and add **data-ace-interactive-code** and **data-stdin-taid="text-demo"** into the `<pre>` tag.
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
There is a page demonstrating most of the capabilities of this filter on the CodeRunner site [here](https://coderunner.org.nz/mod/page/view.php?id=529). The underlying HTML on that page is mostly the same as in the file [`demoaceinline.xml`](https://github.com/trampgeek/moodle-filter_ace_inline/blob/main/samples/demoaceinline.xml), which is included in the Github repo, in the `samples` folder. If you want to experiment yourself, you can download that file and import it as an xml question into the question bank on Moodle. Open it for editing and switch to HTML mode to see how it is set up. It includes a final complex example of a Python3 interactive element that runs numpy and matplotlib, displaying any output graphs as images in addition to any text output. This final example needs to have numpy and matplotlib installed on the Jobe server (they are not there by default), and it has to be implemented via an HTML editor which is **not** TinyMCE in order to avoid `<script>` stripping.

**TinyMCE matplotlib formatting**

Due to the `<script>` stripping, there is a demo of an alternative TinyMCE-friendly matplotlib and numpy implementation, using prefix and suffix code with HTML-escaped Python, in the file [`demotinymatplotlib.xml`](https://github.com/trampgeek/moodle-filter_ace_inline/blob/main/samples/demotinymatplotlib.xml), which can be found in the Github repo in the `samples` folder.
It is highly recommended to import the question into Moodle as above, and then edit the pre-existing code to suit an author's needs.

There are a very large set of automated samples, as Moodle questions in xml, in `tests/qbank` that handle different rendering modes, authoring modes and languages. These can be quickly assessed with supporting Moodle quizzes, as xml files, in `tests\quizzes`.

## Testing scripts
There are a set of scripts in `tests\scripts` that can be used to populate the tree `tests\scenarios` with fixtures for Behat tests.  The scenarios subtree is used to generate the `tests\qbank` (moodle question xml samples) and the `tests\quizzes` (moodle quiz xml samples).

As the number of samples generated is large this can lead to excessively long Behat testing.  The script `tests\scripts\generate_behat_suite.py` by default produces a relatively medium-sized suite of tests.  If the CLI flag `--comprehensive` is specified then a much larger suite of tests is generated.


## Unexpected behaviour in certain areas of Moodle
Currently, in Moodle 4.1, the forum discussion (but not the general description) strips all tags aside from the "class" tag from any HTML elements. This is editor independent. By using the pre-existing [deprecated] method of setting the `<pre>` **class='ace-interactive-code'** or **class='ace-highlight-code'** basic Python 3 functionality can be implemented.

Alternatively, prefix the desired language with **language-** and insert this into the `<pre>` class, alongside the **ace-highlight/interactive-code** option, to implement basic functionality in the selected language.
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

Firefox browsers have dynamic scrollbars that hide when the cursor is not hovering over it. To avoid confusion from what may appear as missing code (when in fact, the component is scrollable), the component will expand in width in Firefox browsers to display all code in a line. This may cause some visual discrepancies between other browsers and Firefox, however functionality remains identical.

It is also recommended to adjust the settings of the scrollbar style in the Firefox browser to allow ease of use.


 **Utilising Markdown Extra, either in the Moodle editor or externally for importing questions (Moodle 3.11+)**
     * **WARNING:** Due to a bug in Moodle, editing of Ace-inline code using Markdown Extra was unavailable from around Moodle 4.06 until the bug was fixed in August 2023. You probably need a recently updated Moodle 4.2 or later for this feature to be usable.


## Change History
See [CHANGES.md](CHANGES.md).
