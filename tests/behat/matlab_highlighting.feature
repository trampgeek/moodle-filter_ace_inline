@filter @filter_ace_inline @javascript
Feature: Visual checks for Matlab syntax highlighting
  In order to display syntax text highlighting
  As a teacher
  I need to be able to create Matlab-highlighted text

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
      | Test questions   | description | matlabdemo |
    And "matlabdemo.txt" exists in question "matlabdemo" "questiontext" for filter ace inline
    And I have enabled the sandbox and ace inline filter

  Scenario: Checks Pascal is highlighted correctly
    When I am on the "matlabdemo" "core_question > preview" page logged in as teacher
    And the programming language is "matlab" in filter ace inline
    And I should see "function" highlighting on "disp" with filter ace inline
    And I should see "function" highlighting on "clc" with filter ace inline
    And I should see "function" highlighting on "whos" with filter ace inline
    And I should see "keyword" highlighting on "for" with filter ace inline
    And I should see "keyword" highlighting on "end" with filter ace inline
    And I should see "string" highlighting on "trial" with filter ace inline

  Scenario: Checks text is not highlighted in other languages
    When I am on the "matlabdemo" "core_question > preview" page logged in as teacher
    And the programming language is "matlab" in filter ace inline
    And I should see "identifier" highlighting on "None" with filter ace inline
    And I should see "identifier" highlighting on "Integer" with filter ace inline
    And I should see "identifier" highlighting on "public" with filter ace inline
    And I should see "identifier" highlighting on "static" with filter ace inline
    And I should see "identifier" highlighting on "int" with filter ace inline
    And I should see "identifier" highlighting on "def" with filter ace inline
