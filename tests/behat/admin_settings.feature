@filter @filter_ace_inline @javascript
Feature: Site administrator configuration of the Ace inline filter
  In order to control the default behaviour of the Ace inline filter across the site
  As an admin
  I need to be able to change the button label, dark theme mode and simplified mode settings

  Background:
    Given the following "courses" exist:
      | fullname | shortname | category |
      | Course 1 | C1        | 0        |
    And the following "question categories" exist:
      | contextlevel | reference | name           |
      | Course       | C1        | Test questions |
    And the following "questions" exist:
      | questioncategory | qtype       | name                |
      | Test questions   | description | settingsdemo        |
      | Test questions   | description | simplifiedmodedemo  |
    And "settingsdemo.txt" exists in question "settingsdemo" "questiontext" for filter ace inline
    And "simplifiedmodedemo.txt" exists in question "simplifiedmodedemo" "questiontext" as markdown for filter ace inline
    And I have enabled the sandbox and ace inline filter

  Scenario: Administrator changes the default button label
    Given I log in as "admin"
    And I navigate to "Plugins > Filters > Ace inline" in site administration
    And I set the field "Button label" to "Run course code"
    And I press "Save changes"
    When I am on the "settingsdemo" "core_question > preview" page logged in as admin
    Then I should see "Run course code"
    And I should not see "Try it!"

  Scenario: Administrator sets the dark theme mode to always
    Given I log in as "admin"
    And I navigate to "Plugins > Filters > Ace inline" in site administration
    And I set the field "Set when to use dark theme" to "Always"
    And I press "Save changes"
    When I am on the "settingsdemo" "core_question > preview" page logged in as admin
    Then "//div[contains(concat(' ', normalize-space(@class), ' '), ' ace-tomorrow-night ')]" "xpath_element" should exist

  Scenario: Administrator sets the dark theme mode to never
    Given I log in as "admin"
    And I navigate to "Plugins > Filters > Ace inline" in site administration
    And I set the field "Set when to use dark theme" to "Never"
    And I press "Save changes"
    When I am on the "settingsdemo" "core_question > preview" page logged in as admin
    Then "//div[contains(concat(' ', normalize-space(@class), ' '), ' ace-tm ')]" "xpath_element" should exist

  Scenario: Simplified mode is off by default so plain markdown-fenced code is left untouched
    When I am on the "simplifiedmodedemo" "core_question > preview" page logged in as admin
    Then "//pre[contains(., 'SIMPLIFIEDHIGHLIGHTMARKER')]/following-sibling::div[contains(@class, 'ace_editor')]" "xpath_element" should not exist

  Scenario: Administrator enables simplified mode so a bare fenced code block becomes highlighted and read-only
    Given I log in as "admin"
    And I navigate to "Plugins > Filters > Ace inline" in site administration
    And I set the field "Simplified mode" to "Enabled"
    And I press "Save changes"
    When I am on the "simplifiedmodedemo" "core_question > preview" page logged in as admin
    Then "//pre[contains(., 'SIMPLIFIEDHIGHLIGHTMARKER')]/following-sibling::div[contains(@class, 'ace_editor')][1][contains(concat(' ', normalize-space(@class), ' '), ' readonly ')]" "xpath_element" should exist
    And "//pre[contains(., 'SIMPLIFIEDHIGHLIGHTMARKER')]/following-sibling::div[contains(@class, 'ace_editor')][1]/following-sibling::div[1][contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist

  Scenario: Administrator enables simplified mode so a ":interactive" fenced code block becomes editable with a Try it! button
    Given I log in as "admin"
    And I navigate to "Plugins > Filters > Ace inline" in site administration
    And I set the field "Simplified mode" to "Enabled"
    And I press "Save changes"
    When I am on the "simplifiedmodedemo" "core_question > preview" page logged in as admin
    Then "//pre[contains(., 'SIMPLIFIEDINTERACTIVEMARKER')]/following-sibling::div[contains(@class, 'ace_editor')][1][contains(concat(' ', normalize-space(@class), ' '), ' readonly ')]" "xpath_element" should not exist
    And "//pre[contains(., 'SIMPLIFIEDINTERACTIVEMARKER')]/following-sibling::div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'Try it!')]" "xpath_element" should exist
