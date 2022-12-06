@filter @filter_ace_inline @javascript @_file_upload
Feature: Basic Try it! checks with formatting for TinyMCE compatibility
  In order to make questions in Code Snippets in TinyMCE
  As a teacher
  I need to be able to make questions and have the correct output displayed and shown

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
    And I upload "filter/ace_inline/tests/fixtures/tryittinydemo.xml" file to "Import" filemanager
    And I set the field "id_format_xml" to "1"
    And I press "id_submitbutton"
    Then I press "Continue"

  Scenario: Checks that Tiny-formatted Java can run (done twice to check consistency)
    When I am on the "tryittinydemo" "core_question > preview" page logged in as teacher
    And I should not see "This ran Java"
    Then I press "Java"
    Then I should see "This ran Java"
    Then I press "Java"
    Then I should see "This ran Java"

  Scenario: Checks that Tiny-formatted C can run (done twice to check consistency)
    When I am on the "tryittinydemo" "core_question > preview" page logged in as teacher
    And I should not see "This ran C"
    Then I press "C"
    Then I should see "This ran C"
    Then I press "C"
    Then I should see "This ran C"

  Scenario: Checks that Tiny-formatted Python can run (done twice to check consistency)
    When I am on the "tryittinydemo" "core_question > preview" page logged in as teacher
    And I should not see "This ran Python"
    And I press "Python"
    Then I should see "This ran Python"
    And I press "Python"
    Then I should see "This ran Python"

  Scenario: Checks that an incorrect language throws an appropriate error in Tiny format
    When I am on the "tryittinydemo" "core_question > preview" page logged in as teacher
    And I press "nolanguage"
    Then I should see "qtype_coderunner/Language"

  Scenario: Checks that incorrect code written Tiny format displays the sandbox error
    When I am on the "tryittinydemo" "core_question > preview" page logged in as teacher
    And I press "badcode"
    Then I should see "SyntaxError"

  Scenario: Checks that Tiny-formatted C when highlighted will not run
    When I am on the "tryittinydemo" "core_question > preview" page logged in as teacher
    And I should not see "This ran C"
    Then I should not see "AlternativeB"

  Scenario: Checks that (class='ace-interactive-code language-c') Tiny-formatted C can run (done twice to check consistency)
    When I am on the "tryittinydemo" "core_question > preview" page logged in as teacher
    And I should not see "This ran C"
    Then I press "legacy"
    Then I should see "This ran C"
    Then I press "legacy"
    Then I should see "This ran C"
