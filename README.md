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

You can find the question number by looking at the questions in your question bank. 
Click the preview question link and look in the URL, the first id is the question's id number. 

Question number xxx is replaced by a simple encryption technique such that 
the original id number is not displayed by preview.php.

Version
=======
1.4 still in beta testing, help welcome.

Configuration
=============
The start and end tags are configurable as is the link text length.
The question can be displayed as a popup or within an iframe embedded in a sliding 
panel - the size of the iframe is configurable.

The sliding panel uses a Bootstrap collabsible.

You can change the encryption key.  Be sure to use only alphabetical characters 
and spaces.

The associated moodle_ATTO_button plugin allows a button to be added to the ATTO
editor toolbar and the codes are then inserted by dialog

Known bugs, Todos
=================
Add option to have link text or toggle button in embedded questions.

The button has the tags hard-coded to the default configuration at the moment.

Will not work with some advanced question types yet such as drag and drop. I probably
over-simplified the question form. Will check that.

Questions and suggestions
=========================
Richard Jones https://richardnz.net richardnz@outlook.com.
Karapiro Village
New Zealand
November 2017

Moodle
======
Tested in Moodle 3.4, 3.3.2+ Build 20171006 Version 2017051502.06
Tested on Chrome, Firefox and Edge browsers
Debian Stretch, Apache2, PHP 7.1, Postgres 9.2.
Tracker: https://tracker.moodle.org/browse/CONTRIB-7081
