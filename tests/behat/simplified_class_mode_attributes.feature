@filter @filter_ace_inline @javascript
Feature: Simplified class mode display and behaviour attributes
  In order to control the display and behaviour of Simplified mode code blocks
  As a teacher
  I need to be able to combine the colon-separated attributes documented in the
  README with highlighted or interactive Simplified mode code blocks, for
  different languages

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
      | questioncategory | qtype       | name                         |
      | Test questions   | description | simplifiedclassmodeattrsdemo |
    And "simplifiedclassmodeattrsdemo.txt" exists in question "simplifiedclassmodeattrsdemo" "questiontext" as markdown for filter ace inline
    And I have enabled the sandbox and ace inline filter
    And the following config values are set as admin:
      | simplified_mode | 1 | filter_ace_inline |

  Scenario: line-numbers sets the first displayed line number (C, highlighted)
    When I am on the "simplifiedclassmodeattrsdemo" "core_question > preview" page logged in as teacher
    Then I should see lines starting at "5" with filter ace inline

  Scenario: font-size sets the Ace editor's font size (Python, interactive)
    When I am on the "simplifiedclassmodeattrsdemo" "core_question > preview" page logged in as teacher
    Then I should see font sized "19pt" with filter ace inline

  Scenario: max-lines limits the visible height, scrolling later lines out of view (Python, interactive)
    When I am on the "simplifiedclassmodeattrsdemo" "core_question > preview" page logged in as teacher
    And I should see "MaxLineVisible"
    Then I should not see "MaxLineHidden"

  Scenario: dark-theme-mode forces the dark theme regardless of the site default (C, highlighted)
    When I am on the "simplifiedclassmodeattrsdemo" "core_question > preview" page logged in as teacher
    Then "//pre[contains(., 'darkforcec')]/following-sibling::div[contains(@class, 'ace_editor')][1][contains(concat(' ', normalize-space(@class), ' '), ' ace-tomorrow-night ')]" "xpath_element" should exist

  Scenario: an earlier block's line-numbers does not leak into a later highlighted block with no line-numbers of its own (C, highlighted)
    When I am on the "simplifiedclassmodeattrsdemo" "core_question > preview" page logged in as teacher
    Then "//pre[contains(., 'darkforcec')]/following-sibling::div[contains(@class, 'ace_editor')][1]//div[contains(@class, 'ace_gutter-active-line') and text()='5']" "xpath_element" should not exist

  Scenario: dark-theme-mode forces the light theme regardless of the site default (Python, interactive)
    When I am on the "simplifiedclassmodeattrsdemo" "core_question > preview" page logged in as teacher
    Then "//pre[contains(., 'lightforcepy')]/following-sibling::div[contains(@class, 'ace_editor')][1][contains(concat(' ', normalize-space(@class), ' '), ' ace-tm ')]" "xpath_element" should exist

  Scenario: button-name sets the Try it! button's label (C, interactive)
    When I am on the "simplifiedclassmodeattrsdemo" "core_question > preview" page logged in as teacher
    Then "//pre[contains(., 'buttonnamec')]/following-sibling::div[contains(@class, 'filter-ace-inline-ui-area')][1]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunC')]" "xpath_element" should exist

  Scenario: readonly disables editing while still showing the Try it! button (Python, interactive)
    When I am on the "simplifiedclassmodeattrsdemo" "core_question > preview" page logged in as teacher
    Then "//pre[contains(., 'readonlypy')]/following-sibling::div[contains(@class, 'ace_editor')][1][contains(concat(' ', normalize-space(@class), ' '), ' readonly ')]" "xpath_element" should exist
    And "//pre[contains(., 'readonlypy')]/following-sibling::div[contains(@class, 'filter-ace-inline-ui-area')][1]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'Try it!')]" "xpath_element" should exist

  Scenario: hidden shows only the Try it! button, with no Ace editor at all (C, interactive)
    When I am on the "simplifiedclassmodeattrsdemo" "core_question > preview" page logged in as teacher
    Then "//pre[contains(., 'hiddenc')]/following-sibling::div[1][contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//pre[contains(., 'hiddenc')]/following-sibling::div[1][contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist

  Scenario: stdin-taid pipes a linked textarea's contents to the running program (Python, interactive)
    When I am on the "simplifiedclassmodeattrsdemo" "core_question > preview" page logged in as teacher
    And I press "ReadStdin"
    Then I should see "StdinHello"

  Scenario: file-upload-id links a file input, with no files selected (Python, interactive)
    When I am on the "simplifiedclassmodeattrsdemo" "core_question > preview" page logged in as teacher
    And I press "UploadPy"
    Then I should see "NoUploadFilesFound"

  Scenario: code-mapper transforms the editor content before execution (C, interactive)
    When I am on the "simplifiedclassmodeattrsdemo" "core_question > preview" page logged in as teacher
    And I should not see "MappedC"
    And I press "MapC"
    Then I should see "MappedC"

  Scenario: max-output-length truncates excessive output (C, interactive)
    When I am on the "simplifiedclassmodeattrsdemo" "core_question > preview" page logged in as teacher
    And I press "TruncC"
    Then I should see "0123456789... (truncated)"

  Scenario: html-output renders the program's output as raw HTML (Python, interactive)
    When I am on the "simplifiedclassmodeattrsdemo" "core_question > preview" page logged in as teacher
    And I press "HtmlPy"
    Then I should see the filter-ace-inline-html div containing "ExtHeading"
