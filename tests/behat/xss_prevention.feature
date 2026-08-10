@filter @filter_ace_inline @javascript
Feature: Checks that author-supplied content cannot inject HTML via the Try it! button
  In order to trust filter_ace_inline content authored by other users
  As a site user
  I need author-supplied button labels to never be rendered as HTML

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
      | Test questions   | description | xssdemo |
    And "xssdemo.txt" exists in question "xssdemo" "questiontext" for filter ace inline
    And I have enabled the sandbox and ace inline filter

  Scenario: A crafted data-button-name is shown as literal text, not parsed as HTML
    When I am on the "xssdemo" "core_question > preview" page logged in as teacher
    Then I should see "<b>XSS</b>" in the ".btn-ace-inline-execution" "css_element"
    And "b" "css_element" should not exist in the ".btn-ace-inline-execution" "css_element"

  Scenario: The button still works normally despite the crafted label
    When I am on the "xssdemo" "core_question > preview" page logged in as teacher
    And I press "<b>XSS</b>"
    Then I should see "pwned"
