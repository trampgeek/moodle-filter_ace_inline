@filter @filter_ace_inline @javascript @_file_upload
Feature: Checks that a user could implement MarkdownExtra styled code and it works appropriately
  In order to write Ace-inline code in MarkdownExtra with Ace Inline Functionality
  As a teacher
  I need to be able to upload MarkdownExtra code

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
    And I have enabled the sandbox and ace inline filter
    And I am on the "Course 1" "core_question > course question import" page logged in as teacher
    And I upload "filter/ace_inline/tests/fixtures/markdowndemo.xml" file to "Import" filemanager
    And I set the field "id_format_xml" to "1"
    And I press "id_submitbutton"
    And I press "Continue"

  Scenario: Checks that the MarkdownExtra formatting works for highlighting
    When I am on the "markdowndemo" "core_question > preview" page logged in as teacher
    Then I should see "keyword" highlighting on "None" with filter ace inline

  Scenario: Checks that the MarkdownExtra formatting works for Try It's (including parameters)
    When I am on the "markdowndemo" "core_question > preview" page logged in as teacher
    And I should not see "This ran Java"
    And I press "2markdown"
    And I should see "This ran Java"
    And I press "2markdown"
    Then I should see "This ran Java"

  Scenario: Checks that the (.ace-interactive-code) MarkdownExtra formatting works for Try it's (including parameters)
    When I am on the "markdowndemo" "core_question > preview" page logged in as teacher
    And I should not see "Today is gonna be the day"
    And I press "legacy"
    And I should see "Today is gonna be the day"
    And I press "legacy"
    Then I should see "Today is gonna be the day"
