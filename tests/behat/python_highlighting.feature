@filter @filter_ace_inline @javascript
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
    And the following "question categories" exist:
      | contextlevel | reference | name           |
      | Course       | C1        | Test questions |
    And the following "questions" exist:
      | questioncategory | qtype       | name       |
      | Test questions   | description | pythondemo |
    And "pythondemo.txt" exists in question "pythondemo" "questiontext" for filter ace inline
    And I have enabled the sandbox and ace inline filter

  Scenario: Checks Python is highlighted correctly
    When I am on the "pythondemo" "core_question > preview" page logged in as teacher
    And the programming language is "python" in filter ace inline
    And I should see "keyword" highlighting on "print" with filter ace inline
    And I should see "constant" highlighting on "True" with filter ace inline
    And I should see "keyword" highlighting on "class" with filter ace inline
    And I should see "function" highlighting on "range" with filter ace inline
    And I should see "string" highlighting on "Class" with filter ace inline
    And I should see "keyword" highlighting on "None" with filter ace inline
    And I should see "keyword" highlighting on "def" with filter ace inline

  Scenario: Checks text is not highlighted in other languages
    When I am on the "pythondemo" "core_question > preview" page logged in as teacher
    And the programming language is "python" in filter ace inline
    And I should see "identifier" highlighting on "public" with filter ace inline
    And I should see "identifier" highlighting on "System" with filter ace inline
    And I should see "identifier" highlighting on "putchar" with filter ace inline
    And I should see "identifier" highlighting on "true" with filter ace inline
    And I should see "identifier" highlighting on "void" with filter ace inline
    And I should see "identifier" highlighting on "null" with filter ace inline
