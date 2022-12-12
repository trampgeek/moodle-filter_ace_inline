@filter @filter_ace_inline @javascript
Feature: Visual checks for Java syntax highlighting
  In order to display syntax text highlighting
  As a teacher
  I need to be able to create Java-highlighted text

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
      | questioncategory | qtype       | name     |
      | Test questions   | description | javademo |
    And "javademo.txt" exists in question "javademo" "questiontext" for filter ace inline
    And I have enabled the sandbox and ace inline filter

  Scenario: Checks Java is highlighted correctly
    When I am on the "javademo" "core_question > preview" page logged in as teacher
    And the programming language is "java" in filter ace inline
    And I should see "keyword" highlighting on "abstract" with filter ace inline
    And I should see "keyword" highlighting on "void" with filter ace inline
    And I should see "string" highlighting on "running" with filter ace inline
    And I should see "function" highlighting on "Boolean" with filter ace inline
    And I should see "function" highlighting on "Integer" with filter ace inline
    And I should see "keyword" highlighting on "boolean" with filter ace inline
    And I should see "function" highlighting on "System" with filter ace inline
    And I should see "constant" highlighting on "null" with filter ace inline

  Scenario: Checks text is not highlighted in other languages
    When I am on the "javademo" "core_question > preview" page logged in as teacher
    And the programming language is "java" in filter ace inline
    And I should see "identifier" highlighting on "putchar" with filter ace inline
    And I should see "identifier" highlighting on "include" with filter ace inline
    And I should see "identifier" highlighting on "stdio" with filter ace inline
    And I should see "identifier" highlighting on "bool" with filter ace inline
    And I should see "identifier" highlighting on "None" with filter ace inline

  Scenario: Checks text is not highlighted as JavaScript
    When I am on the "javademo" "core_question > preview" page logged in as teacher
    And the programming language is "java" in filter ace inline
    And I should see "identifier" highlighting on "let" with filter ace inline
    And I should see "identifier" highlighting on "of" with filter ace inline
    And I should see "identifier" highlighting on "function" with filter ace inline
