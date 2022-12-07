@filter @filter_ace_inline @javascript
Feature: Checks for the data-params feature
  In order to execute matplotlib or other code which requires excessive CPU/memory
  As a teacher
  I need to be able to edit the parameters of execution

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
      | Test questions   | description | paramsdemo |
    And "paramsdemo.txt" exists in question "paramsdemo" "questiontext" for filter ace inline
    And I have enabled the sandbox and ace inline filter

  Scenario: Checks if the data params works appropriately
    When I am on the "paramsdemo" "core_question > preview" page logged in as teacher
    And I should not see "successfulmatplotlib"
    And I press "matplotlib"
    Then I should see "successfulmatplotlib"
