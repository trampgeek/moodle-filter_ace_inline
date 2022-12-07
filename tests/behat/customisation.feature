@filter @filter_ace_inline @javascript
Feature: Visual checks for any UI specified customisation
  In order to display custom code-display boxes
  As a teacher
  I need to be able to edit and customise different features

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
      | questioncategory | qtype       | name          |
      | Test questions   | description | customisedemo |
    And "customisedemo.txt" exists in question "customisedemo" "questiontext" for filter ace inline
    And I have enabled the sandbox and ace inline filter

  Scenario: Checks the text is starting at the right position (set to start at 5)
    When I am on the "customisedemo" "core_question > preview" page logged in as teacher
    Then I should see lines starting at "5" with filter ace inline

  Scenario: Checks the font size has changed appropriately when set (set to 16pt size)
    When I am on the "customisedemo" "core_question > preview" page logged in as teacher
    Then I should see font sized "16pt" with filter ace inline

  Scenario: Checks maximum number of lines displayed is exact
    When I am on the "customisedemo" "core_question > preview" page logged in as teacher
    And I should see "I should see this line"
    Then I should not see "I should not see this line"

  Scenario: Checks that the "Try it!" button exists (not is clicked)
    When I am on the "customisedemo" "core_question > preview" page logged in as teacher
    Then I should see "Try it!"

  Scenario: Checks if the "Try it!" button can be customised (to "Run me" for this example)
    When I am on the "customisedemo" "core_question > preview" page logged in as teacher
    Then I should see "Run me"

  Scenario: Checks if setting the ACE highlighting language still runs independently from CodeRunner
    When I am on the "customisedemo" "core_question > preview" page logged in as teacher
    And I should see "identifier" highlighting on "print" with filter ace inline
    And I should see "string" highlighting on "Python" with filter ace inline
    And I should not see "This ran Python"
    Then I press "notJS"
    Then I should see "This ran Python"

  Scenario: Checks if setting the max output length gives the appropriate output
    When I am on the "customisedemo" "core_question > preview" page logged in as teacher
    And I press "uptoten"
    Then I should see "0123456789... (truncated)"

  Scenario: Checks if HTML output shows (twice to double-check handling)
    When I am on the "customisedemo" "core_question > preview" page logged in as teacher
    And I press "HTML time"
    And I should see the filter-ace-inline-html div containing "heading"
    And I press "HTML time"
    Then I should see the filter-ace-inline-html div containing "heading"

  Scenario: Checks if HTML output shows within editors with language-markup (twice to double-check handling)
    When I am on the "customisedemo" "core_question > preview" page logged in as teacher
    And I press "HTML tiny"
    And I should see the filter-ace-inline-html div containing "heading"
    And I press "HTML tiny"
    Then I should see the filter-ace-inline-html div containing "heading"

  Scenario: Checks if the legacy "class='ace-highlight-code" still functions (twice to double-check handling)
    When I am on the "customisedemo" "core_question > preview" page logged in as teacher
    And I press "Legacy"
    Then I should see "This ran Python"
    And I press "Legacy"
    Then I should see "This ran Python"

  Scenario: Checks if the legacy "class='ace-interactive-code'" still functions
    When I am on the "customisedemo" "core_question > preview" page logged in as teacher
    And I should see "constant" highlighting on "True" with filter ace inline
