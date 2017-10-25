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

The code is of the form {QUESTION:linktext|xxx} where xxx is the question id number.  You
can find this number by looking at the questions in your question bank. Click the preview
question link and look in the URL, the first id is the question's id number. 

Question number xxx is replaced by a simple encryption technique such that 
the original id number os not displayed by preview.php.

Configuration
=============
The start and end tags are configurable as is the link text length.
The question can be displayed as a popup or as a regular Moodle page.
You can change the encryption key (bearing in mind that that is a once off operation as existing questions would become changed or lost).

Known bugs, Todos
==========
The question usage attempts table is not currently being cleaned of old attempts, this might eventually pose a problem.

The non-popup config option replaces the course page with the question.  The student would have to use the breadcrumbs to return to the course page.  I have to put this option in an iframe or sliding Bootstrap panel.  At minimum a close button.

Not tested with advanced question types yet such as drag and drop onto image.

Questions and suggestions
=========================
Richard Jones https://richardnz.net richardnz@outlook.com.
October 2017

Moodle
======
Tested in Moodle 3.3.2+ Build 20171006 Version 2017051502.06
Tracker: https://tracker.moodle.org/browse/CONTRIB-7081
