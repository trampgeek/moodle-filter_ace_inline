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
The question can be displayed as a popup or within an iframe embedded in a sliding panel
You can change the encryption key.

Known bugs, Todos
==========
Not sure if iframe solution is ideal, student needs to figure out that clicking
the link opens and closes the sliding panel.  teacher could add instructions to that effect though.

Not tested with advanced question types yet such as drag and drop onto image.

Questions and suggestions
=========================
Richard Jones https://richardnz.net richardnz@outlook.com.
October 2017

Moodle
======
Tested in Moodle 3.3.2+ Build 20171006 Version 2017051502.06
Debian Stretch, Apache2, PHP 7.1, Postgres 9.2.
Tracker: https://tracker.moodle.org/browse/CONTRIB-7081
