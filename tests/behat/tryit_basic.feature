@filter @filter_ace_inline @javascript @_file_upload
Feature: Basic Try it! button checks to make sure the code runs
  In order to have questions which can execute code and display output
  As a teacher
  I need to be able to press buttons which execute code see displayed output

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
    And I upload "filter/ace_inline/tests/fixtures/tryitbasicdemo.xml" file to "Import" filemanager
    And I set the field "id_format_xml" to "1"
    And I press "id_submitbutton"
    Then I press "Continue"

  Scenario: Checks that Java can run (done twice to check consistency)
    When I am on the "tryitbasicdemo" "core_question > preview" page logged in as teacher
    And the programming language is "java"
    And I should not see "This ran Java"
    Then I press "Java"
    Then I should see "This ran Java"
    Then I press "Java"
    Then I should see "This ran Java"

  Scenario: Checks that C can run (done twice to check consistency)
    When I am on the "tryitbasicdemo" "core_question > preview" page logged in as teacher
    And the programming language is "c"
    And I should not see "This ran C"
    Then I press "C"
    Then I should see "This ran C"
    Then I press "C"
    Then I should see "This ran C"

  Scenario: Checks that Python can run
    When I am on the "tryitbasicdemo" "core_question > preview" page logged in as teacher
    And the programming language is "python"
    And I should not see "This ran Python"
    And I press "Python"
    Then I should see "This ran Python"
    And I press "Python"
    Then I should see "This ran Python"

  Scenario: Checks that an incorrect language throws an appropriate error
    When I am on the "tryitbasicdemo" "core_question > preview" page logged in as teacher
    And I press "nolanguage"
    Then I should see "qtype_coderunner/Language"

  Scenario: Checks that incorrect code (i.e. ran through sandbox, but code is written incorrectly) displays the sandbox error
    When I am on the "tryitbasicdemo" "core_question > preview" page logged in as teacher
    And I press "badcode"
    Then I should see "SyntaxError"
