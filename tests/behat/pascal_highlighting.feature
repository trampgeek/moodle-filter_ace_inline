@filter @filter_ace_inline @javascript
Feature: Visual checks for Pascal syntax highlighting
  In order to display syntax text highlighting
  As a teacher
  I need to be able to create Pascal-highlighted text

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
      | Test questions   | description | pascaldemo |
    And "pascaldemo.txt" exists in question "pascaldemo" "questiontext" for filter ace inline
    And I have enabled the sandbox and ace inline filter

  Scenario: Checks Pascal is highlighted correctly
    When I am on the "pascaldemo" "core_question > preview" page logged in as teacher
    And the programming language is "pascal" in filter ace inline
    And I should see "keyword" highlighting on "program" with filter ace inline
    And I should see "keyword" highlighting on "uses" with filter ace inline
    And I should see "keyword" highlighting on "const" with filter ace inline
    And I should see "keyword" highlighting on "var" with filter ace inline
    And I should see "string" highlighting on "Demo2" with filter ace inline
    And I should see "keyword" highlighting on "end" with filter ace inline
    And I should see "keyword" highlighting on "begin" with filter ace inline

  Scenario: Checks text is not highlighted in other languages
    When I am on the "pascaldemo" "core_question > preview" page logged in as teacher
    And the programming language is "pascal" in filter ace inline
    And I should see "identifier" highlighting on "return" with filter ace inline
    And I should see "identifier" highlighting on "include" with filter ace inline
    And I should see "identifier" highlighting on "stdio" with filter ace inline
    And I should see "identifier" highlighting on "int" with filter ace inline
    And I should see "identifier" highlighting on "let" with filter ace inline
