@filter @filter_ace_inline @javascript @_file_upload
Feature: Per-widget file uploads for the Ace inline filter
  In order to put more than one file-upload exercise on the same page
  As a teacher
  I need each upload widget to keep hold of its own files, even when two
  widgets are given files that happen to share a name

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
      | questioncategory | qtype       | name           |
      | Test questions   | description | twouploadsdemo |
    And "twouploadsdemo.txt" exists in question "twouploadsdemo" "questiontext" for filter ace inline
    And I have enabled the sandbox and ace inline filter

  Scenario: A single upload widget passes its file to its own block
    When I am on the "twouploadsdemo" "core_question > preview" page logged in as teacher
    And I should not see "ASEES1"
    And I attach the file "lib/tests/fixtures/empty.txt" to the ace inline upload box "uploadboxA"
    And I press "RunA"
    Then I should see "ASEES1"

  Scenario: Two upload widgets given a file of the same name each keep their own copy
    When I am on the "twouploadsdemo" "core_question > preview" page logged in as teacher
    And I should not see "ASEES1"
    And I should not see "BSEES1"
    # Uploaded files are held in one page-wide map keyed by filename, then by widget. Giving
    # both widgets a file of the same name means both need the same key, so the second upload
    # must merge into that entry rather than replace it - otherwise the first widget silently
    # loses its file and its block runs with nothing uploaded.
    And I attach the file "lib/tests/fixtures/empty.txt" to the ace inline upload box "uploadboxA"
    And I attach the file "lib/tests/fixtures/empty.txt" to the ace inline upload box "uploadboxB"
    And I press "RunA"
    Then I should see "ASEES1"
    And I press "RunB"
    And I should see "BSEES1"
