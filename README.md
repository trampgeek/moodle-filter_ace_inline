Source code repository
=====================
https://github.com/richardjonesnz/moodle_filter_simplequestion

Short Description
=================
This is a very simple implementation of a question filter. It allows questions to be
inserted anywhere in Moodle editable text.

Long Description
===============
A simple implementation of a text filter for Moodle. 

In this version the user places special codes within text anywhere in Moodle which 
can then be replaced by a link to a question number in the database.  

The code is of the form {QUESTION:linktext|xxx|display} where xxx is the question id
number and display is the display mode (embed or popup).  

The plugin moodle_atto_question allows a teacher to insert the question codes
via a button which triggers a dialog box.

You can find the question number by looking at the questions in your question bank. 
Click the preview question link and look in the URL, the first id is the question's id number. 

Question number xxx is replaced by a simple encryption technique such that 
the original id number is not displayed by preview.php.

Version
=======
1.5 still in beta testing, help welcome.

Configuration
=============
The start and end tags are configurable as is the link text length.
The question can be displayed as a popup or within an iframe embedded in a hidden 
div - the size of the iframe is configurable.

You can change the encryption key.  Be sure to use only alphabetical characters 
and spaces.

Known bugs, Todos
=================
The ATTO button has the tags hard-coded to the default configuration at the moment. 

Will not work with some advanced question types yet such as drag and drop. I admit to not knowing why this is.

Documentation and screenshots to add to https://richardnz.net/simplequestion.html

Questions and suggestions
=========================
Richard Jones https://richardnz.net richardnz@outlook.com.
Karapiro Village
New Zealand
November 2017

Moodle
======
Tested in Moodle 3.3 and 3.4
Tested on Chrome, Firefox and Edge browsers
Debian Stretch, Apache2, PHP 7.1, Postgres 9.2.
Tracker: https://tracker.moodle.org/browse/CONTRIB-7081
