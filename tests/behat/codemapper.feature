@filter @filter_ace_inline @javascript
Feature: Codemapper functionality allows transformation of input code prior to execution
  In order to transform code into other code
  As a teacher
  I need to be able to write JS codemapper code which can modify input code

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
      | questioncategory | qtype       | name           |
      | Test questions   | description | codemapperdemo |
    And "codemapperdemo.txt" exists in question "codemapperdemo" "questiontext" for filter ace inline
    And I have enabled the sandbox and ace inline filter

  Scenario: Checks Codemapper execution works
    When I am on the "codemapperdemo" "core_question > preview" page logged in as teacher
    And I should not see "Yes, this ran Python"
    And I press "Try it!"
    Then I should see "Yes, this ran Python"
