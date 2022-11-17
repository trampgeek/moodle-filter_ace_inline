@filter @filter_ace_inline @javascript @_file_upload
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
    And I have enabled ace inline filter
    And the webserver sandbox is enabled
    And I am on the "Course 1" "core_question > course question import" page logged in as teacher
    And I upload "filter/ace_inline/tests/fixtures/customisedemo.xml" file to "Import" filemanager
    And I set the field "id_format_xml" to "1"
    And I press "id_submitbutton"
    Then I press "Continue"

  Scenario: Checks the text is starting at the right position
    When I am on the "customisedemo" "core_question > preview" page logged in as teacher
    Then I should see lines starting at "5"
  
  Scenario: Checks the font size has changed appropriately when set
    When I am on the "customisedemo" "core_question > preview" page logged in as teacher
    Then I should see font sized "16pt"
  
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
    And I should not see "This ran Python"
    Then I press "notJS"
    Then I should see "This ran Python"


