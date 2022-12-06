@filter @filter_ace_inline @javascript @_file_upload
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
    And I have enabled ace inline filter
    And the webserver sandbox is enabled
    And I am on the "Course 1" "core_question > course question import" page logged in as teacher
    And I upload "filter/ace_inline/tests/fixtures/paramsdemo.xml" file to "Import" filemanager
    And I set the field "id_format_xml" to "1"
    And I press "id_submitbutton"
    Then I press "Continue"

  Scenario: Checks if the data params works appropriately
    When I am on the "paramsdemo" "core_question > preview" page logged in as teacher
    And I press "matplotlib"
    Then I should see "successfulmatplotlib"

  @trythis
  Scenario: Checks if the data params CPU excess throws appropriate error
    When I am on the "paramsdemo" "core_question > preview" page logged in as teacher
    And the cpu time is limited
    And I press "excessive"
    Then I should not see "excessivecpuoops"
    And I should see "time specified exceeds set"
