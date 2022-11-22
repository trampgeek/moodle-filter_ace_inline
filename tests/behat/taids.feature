@filter @filter_ace_inline @javascript @_file_upload 
Feature: Checks that HTML elements can be identified, else made and mapped appropriately
  In order to have questions which allow input into HTML/TextAreas
  As a teacher
  I need to be able to write text and code which can be used with Ace Inline

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
    And I upload "filter/ace_inline/tests/fixtures/taidsdemo.xml" file to "Import" filemanager
    And I set the field "id_format_xml" to "1"
    And I press "id_submitbutton"
    Then I press "Continue"
   
  Scenario: Checks that correct taid can run and give correct output
    When I am on the "taidsdemo" "core_question > preview" page logged in as teacher
    And I press "taids"
    Then I should see "Hello World!"

  Scenario: Checks that editing the taid gives the correct output
    When I am on the "taidsdemo" "core_question > preview" page logged in as teacher
    And I press "taids"
    Then I should see "Hello World!"
    Then I set the field "textarea" to:
        """
        Goo
        dbye
         Wor
        ld
        !
        """
    And I press "taids"
    Then I should see "Goodbye World!"



