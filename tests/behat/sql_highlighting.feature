@filter @filter_ace_inline @javascript
Feature: Visual checks for SQL syntax highlighting
  In order to display syntax text highlighting
  As a teacher
  I need to be able to create SQL-highlighted text

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
      | questioncategory | qtype       | name    |
      | Test questions   | description | sqldemo |
    And "sqldemo.txt" exists in question "sqldemo" "questiontext" for filter ace inline
    And I have enabled the sandbox and ace inline filter

  Scenario: Checks SQL is highlighted correctly
    When I am on the "sqldemo" "core_question > preview" page logged in as teacher
    And the programming language is "sql" in filter ace inline
    And I should see "keyword" highlighting on "SELECT" with filter ace inline
    And I should see "keyword" highlighting on "CREATE" with filter ace inline
    And I should see "keyword" highlighting on "GROUP" with filter ace inline
    And I should see "keyword" highlighting on "TABLE" with filter ace inline
    And I should see "function" highlighting on "count" with filter ace inline
    And I should see "sqltype" highlighting on "int" with filter ace inline
    And I should see "sqltype" highlighting on "varchar" with filter ace inline

  Scenario: Checks text is not highlighted in other languages
    When I am on the "sqldemo" "core_question > preview" page logged in as teacher
    And the programming language is "sql" in filter ace inline
    And I should see "identifier" highlighting on "System" with filter ace inline
    And I should see "identifier" highlighting on "def" with filter ace inline
    And I should see "identifier" highlighting on "True" with filter ace inline
    And I should see "identifier" highlighting on "while" with filter ace inline
    And I should see "identifier" highlighting on "boolean" with filter ace inline
    And I should see "identifier" highlighting on "let" with filter ace inline
