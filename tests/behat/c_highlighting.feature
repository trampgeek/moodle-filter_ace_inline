@filter @filter_ace_inline @javascript
Feature: Visual checks for C(++) syntax highlighting
  In order to display syntax text highlighting
  As a teacher
  I need to be able to create C(++)-highlighted text

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
      | questioncategory | qtype       | name  |
      | Test questions   | description | cdemo |
    And "cdemo.txt" exists in question "cdemo" "questiontext" for filter ace inline
    And I have enabled the sandbox and ace inline filter

  Scenario: Checks C(++) is highlighted correctly
    When I am on the "cdemo" "core_question > preview" page logged in as teacher
    And the programming language is "c" in filter ace inline
    And I should see "include" highlighting on "iostream" with filter ace inline
    And I should see "include" highlighting on "stdio" with filter ace inline
    And I should see "keyword" highlighting on "using" with filter ace inline
    And I should see "keyword" highlighting on "bool" with filter ace inline
    And I should see "function" highlighting on "putchar" with filter ace inline
    And I should see "string" highlighting on "Hello" with filter ace inline
    And I should see "keyword" highlighting on "include" with filter ace inline

  Scenario: Checks text is not highlighted in other languages
    When I am on the "cdemo" "core_question > preview" page logged in as teacher
    And the programming language is "c" in filter ace inline
    And I should see "identifier" highlighting on "System" with filter ace inline
    And I should see "identifier" highlighting on "None" with filter ace inline
    And I should see "identifier" highlighting on "True" with filter ace inline
    And I should see "identifier" highlighting on "Boolean" with filter ace inline
    And I should see "identifier" highlighting on "boolean" with filter ace inline
    And I should see "identifier" highlighting on "let" with filter ace inline
