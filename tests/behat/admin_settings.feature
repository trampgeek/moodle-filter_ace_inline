@filter @filter_ace_inline @javascript
Feature: Site administrator configuration of the Ace inline filter
  In order to control the default behaviour of the Ace inline filter across the site
  As an admin
  I need to be able to change the button label, dark theme mode and markdown rendering settings

  Background:
    Given the following "courses" exist:
      | fullname | shortname | category |
      | Course 1 | C1        | 0        |
    And the following "question categories" exist:
      | contextlevel | reference | name           |
      | Course       | C1        | Test questions |
    And the following "questions" exist:
      | questioncategory | qtype       | name         |
      | Test questions   | description | settingsdemo |
    And "settingsdemo.txt" exists in question "settingsdemo" "questiontext" for filter ace inline
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

  Scenario: Administrator turns off markdown code-block rendering
    Given I log in as "admin"
    And I navigate to "Plugins > Filters > Ace inline" in site administration
    And I set the field "Markdown Rendering" to "Off"
    And I press "Save changes"
    When I am on the "settingsdemo" "core_question > preview" page logged in as admin
    Then "//pre[contains(., 'MARKDOWNCODEMARKER')]/following-sibling::div[contains(@class, 'ace_editor')]" "xpath_element" should not exist

  Scenario: Administrator turns on markdown code-block rendering
    Given I log in as "admin"
    And I navigate to "Plugins > Filters > Ace inline" in site administration
    And I set the field "Markdown Rendering" to "On"
    And I press "Save changes"
    When I am on the "settingsdemo" "core_question > preview" page logged in as admin
    Then "//pre[contains(., 'MARKDOWNCODEMARKER')]/following-sibling::div[contains(@class, 'ace_editor')]" "xpath_element" should exist
