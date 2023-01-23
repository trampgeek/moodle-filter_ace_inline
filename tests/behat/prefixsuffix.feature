@filter @filter_ace_inline @javascript
Feature: Checks that prefix and suffix code customisation is implemented correctly
  In order to have questions which can prefix and suffix additional
  As a teacher
  I need to be able to add suffixed and prefixed code successfully

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
      | questioncategory | qtype       | name             |
      | Test questions   | description | prefixsuffixdemo |
    And "prefixsuffixdemo.txt" exists in question "prefixsuffixdemo" "questiontext" for filter ace inline
    And I have enabled the sandbox and ace inline filter

  Scenario: Checks that prefix can run and give correct output
    When I am on the "prefixsuffixdemo" "core_question > preview" page logged in as teacher
    And I press "prefix"
    Then I should see "Hi Jacob, next year you'll be 12"

  Scenario: Then, as a previewer, I should be able to edit the textarea and change the output
    When I am on the "prefixsuffixdemo" "core_question > preview" page logged in as teacher
    And I set the field "textarea" to:
        """
        Jessica
        23
        """
    And I press "prefix"
    Then I should see "Hi Jessica, next year you'll be 24"

  Scenario: Checks the suffix can run and give correct output
    When I am on the "prefixsuffixdemo" "core_question > preview" page logged in as teacher
    And I press "mystery"
    Then I should see "desrever"
