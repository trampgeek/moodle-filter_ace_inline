@filter @filter_ace_inline @javascript @_file_upload
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
    And I have enabled ace inline filter
    And the webserver sandbox is enabled
    And I am on the "Course 1" "core_question > course question import" page logged in as teacher
    And I upload "filter/ace_inline/tests/fixtures/codemapperdemo.xml" file to "Import" filemanager
    And I set the field "id_format_xml" to "1"
    And I press "id_submitbutton"
    Then I press "Continue"

  Scenario: Checks Codemapper execution works
    When I am on the "codemapperdemo" "core_question > preview" page logged in as teacher
    And I press "Try it!"
    Then I should see "Yes, this ran Python"
  
    