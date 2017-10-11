Short Description
=================
This is a very simple implementation of a question filter. It allows questions to be
inserted anywhere in Moodle editable text.

Long Description
===============
A simple implementation of a text filter for Moodle.  Use of this filter will, in principle
allow clever students to keep trying question id's until they discover the ones for
your exam. That would require considerable effort on their part.

Work aroundS: Only use the question bank for practice, not for real tests. 
              Have a million questions or so.
              Have a lot of versions of the same question to confuse them.
              Try not to worry too much.

In this version the user places special codes within text anywhere in Moodle which 
can then be replaced by a link to a question number in the database.  

The code is of the form {QUESTION:linktext|xxx} where xxx is the question id number.  You
can find this number by looking at the questions in your question bank. Click the preview
question link and look in the URL, the first id is the question's id number. 

This question is then previewed in a popup with a simplified version of preview.php

Tested in Moodle 3.3

Richard Jones https://richardnz.net richardnz@outlook.com.

October 2017
