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

The linktext is limited to 40 characters (do you really need more - there's a constant in the code).

This question is then previewed in a popup with a simplified version of preview.php

Tested in Moodle 3.3.2+ Build 20171006 Version 2017051502.06

Richard Jones https://richardnz.net richardnz@outlook.com.

October 2017
