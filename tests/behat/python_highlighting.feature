@filter @filter_ace_inline @javascript @_file_upload
Feature: Visual checks for Python syntax highlighting
  In order to display syntax text highlighting
  As a teacher
  I need to be able to create Python-highlighted text

  Background:
    Given the following "users" exist:
      | username | firstname | lastname | email           |
      | teacher  | Teacher   | 1        | teach1@empl.com |
    And the following "courses" exist:
      | fullname | shortname | category |
      | Course 1 | C1        | 0        |
    And the following "course enrolments" exist:
      | user     | course    | role           |
      | teacher  | C1        | editingteacher |
    And I have enabled ace inline filter
    And I am on the "Course 1" "core_question > course question import" page logged in as teacher
    And I upload "filter/ace_inline/tests/fixtures/pythondemo.xml" file to "Import" filemanager
    And I set the field "id_format_xml" to "1"
    And I press "id_submitbutton"
    Then I press "Continue"

  Scenario: Checks Python is highlighted correctly
    When I am on the "pythondemo" "core_question > preview" page logged in as teacher
    And the programming language is "python"
    And I should see "keyword" highlighting on "print"
    And I should see "constant" highlighting on "True"
    And I should see "keyword" highlighting on "class"
    And I should see "function" highlighting on "range"
    And I should see "string" highlighting on "Class"
    And I should see "keyword" highlighting on "None"
    And I should see "keyword" highlighting on "def"

  Scenario: Checks text is not highlighted in other languages
    When I am on the "pythondemo" "core_question > preview" page logged in as teacher
    And the programming language is "python"
    And I should see "identifier" highlighting on "public"
    And I should see "identifier" highlighting on "System"
    And I should see "identifier" highlighting on "putchar"
    And I should see "identifier" highlighting on "true"
    And I should see "identifier" highlighting on "void"
    And I should see "identifier" highlighting on "null"
