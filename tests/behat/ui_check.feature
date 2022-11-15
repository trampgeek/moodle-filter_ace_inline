@filter @filter_ace_inline @javascript @_file_upload
Feature: Visual checks on display
  In order to display interactive programming text
  As a teacher
  I need to be able to create text with syntax highlighting

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
    And I enable ace inline filter
    And I am on the "Course 1" "core_question > course question import" page logged in as teacher
    And I upload "filter/ace_inline/tests/fixtures/demoaceinline.xml" file to "Import" filemanager
    And I set the field "id_format_xml" to "1"
    And I press "id_submitbutton"
    Then I press "Continue"

  Scenario: Check syntax highlighting exists on question
    When I am on the "TestAceInline" "core_question > preview" page logged in as teacher
    And I should see "Try it!"
    Then I should see syntax highlighting on "print"
