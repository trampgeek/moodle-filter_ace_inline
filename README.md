Source code repository
=====================
https://github.com/richardjonesnz/moodle_filter_simplemodal

Short Description
=================
A template for filters

Long Description
===============
A text filter template.  The filter interprets text marked 
with opening and closing tags {{CONTENT:arbitrary content}} 
and then shows it in an alert box via an AMD module.

The text is replaced by a button with a fixed label.

Version
=======
1.0

Configuration
=============
The tags can be configured.  It has height and width config 
but these are unused.

Documentation
=============
Thanks to justin Hunt.

Download the zip or clone the repo.

Edit all the files in this directory and its subdirectories and change
all the instances of the string "simplemodel" to your atto plugin name
(eg "widget"). Don't do this manually. Use an IDE or a programmers text
editor like TextWrangler (mac) or Notepad++ (pc)
  
If you are using Linux, you could also use the following command
$ find . -type f -exec sed -i 's/simplemodal/widget/g' {} \;

On a mac, use:
$ find . -type f -exec sed -i '' 's/simplemodal/widget/g' {} \;

Rename the file lang/en/filter_simplemodal.php to lang/en/filter_widget.php
where "widget" is the name of your text filter plugin

Place the plugin folder folder into the /filter folder of the moodle directory.

Modify version.php and set the initial version of your module.

Visit Settings > Site Administration > Notifications, and let Moodle guide you through the install.

Known bugs, Todos, Suggestions
==============================
You can make the button text configurable if you like.
You could develop it into a model panel that shows interesting things.
You can adapt it to multiple buttons - but would need an id for each one.

Questions and suggestions
=========================
Richard Jones https://richardnz.net richardnz@outlook.com.
Karapiro Village
New Zealand
November 2017

Moodle
======
Tested in 3.4
Tested on Chrome
