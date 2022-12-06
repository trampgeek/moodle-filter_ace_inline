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

  Scenario: Checks that if there is no text in the input box, there is no user error.
    When I am on the "taidsdemo" "core_question > preview" page logged in as teacher
    And I press "emptyin"
    Then I should not see "Id not found for element"
    And I should see "I'm empty"

  Scenario: Checks that one can see an error when an incorrect id is inputted
    When I am on the "taidsdemo" "core_question > preview" page logged in as teacher
    And I press "wrongname"
    Then I should see "Id not found for element"

  Scenario: Checks that the file-taids match correctly (done twice to check handling)
    When I am on the "taidsdemo" "core_question > preview" page logged in as teacher
    And I press "file-taids"
    Then I should see "Hello is it me you see?"
    And I press "file-taids"
    Then I should see "Hello is it me you see?"

  Scenario: Checks that a JSON parse error for file-taid mappings gives you a good response (done twice to check handling)
    When I am on the "taidsdemo" "core_question > preview" page logged in as teacher
    And I press "invalid-JSON"
    Then I should not see "Hello is it"
    And I should see "JSON record"
    And I press "invalid-JSON"
    Then I should not see "Hello is it"
    And I should see "JSON record"

  Scenario: Checks that when a valid JSON file-taid input maps with an element not listed, that it errors (done twice to check handling)
    When I am on the "taidsdemo" "core_question > preview" page logged in as teacher
    And I press "wrongFile"
    Then I should see "Id not found for element"
    And I press "wrongFile"
    Then I should see "Id not found for element"

  Scenario: Checks that when uploading a file, the file uploads correctly and is executed correctly (done twice to check uploading persistence handling)
    When I am on the "taidsdemo" "core_question > preview" page logged in as teacher
    And I press "upload"
    Then I should see "No '.txt' files found"
    And I press "upload"
    Then I should see "No '.txt' files found"

  Scenario: Checks that if there is no text in the file, the appropriate text is displayed
    When I am on the "taidsdemo" "core_question > preview" page logged in as teacher
    And I press "hollow"
    Then I should not see "Id not found for element"
    And I should see "NO INPUT SUPPLIED!"
