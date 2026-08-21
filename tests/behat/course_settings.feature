@filter @filter_ace_inline @javascript
Feature: Course-level configuration overrides for the Ace inline filter
  In order to customise the Ace inline filter's behaviour for just my own course
  As a teacher
  I need to be able to override the site's button label, dark theme mode and
  simplified mode settings for my course only, leaving other courses on
  the site default

  Background:
    Given the following "users" exist:
      | username | firstname | lastname | email           |
      | teacher  | Teacher   | 1        | teach1@empl.com |
    And the following "courses" exist:
      | fullname | shortname | category |
      | Course 1 | C1        | 0        |
      | Course 2 | C2        | 0        |
    And the following "course enrolments" exist:
      | user    | course | role           |
      | teacher | C1     | editingteacher |
      | teacher | C2     | editingteacher |
    And the following "question categories" exist:
      | contextlevel | reference | name              |
      | Course       | C1        | Test questions C1 |
      | Course       | C2        | Test questions C2 |
    And the following "questions" exist:
      | questioncategory   | qtype       | name                    |
      | Test questions C1  | description | settingsdemoc1          |
      | Test questions C2  | description | settingsdemoc2          |
      | Test questions C1  | description | simplifiedmodedemoc1    |
      | Test questions C2  | description | simplifiedmodedemoc2    |
    And "settingsdemo.txt" exists in question "settingsdemoc1" "questiontext" for filter ace inline
    And "settingsdemo.txt" exists in question "settingsdemoc2" "questiontext" for filter ace inline
    And "simplifiedmodedemo.txt" exists in question "simplifiedmodedemoc1" "questiontext" as markdown for filter ace inline
    And "simplifiedmodedemo.txt" exists in question "simplifiedmodedemoc2" "questiontext" as markdown for filter ace inline
    And I have enabled the sandbox and ace inline filter

  Scenario: Teacher overrides the button label for their course only
    Given I am on the "C1" "Course" page logged in as teacher
    And I navigate to "Filters" in current page administration
    And I click on "Settings" "link" in the "Ace inline" "table_row"
    And I set the field "Button label" to "Run C1 code"
    And I press "Save changes"
    When I am on the "settingsdemoc1" "core_question > preview" page logged in as teacher
    Then I should see "Run C1 code"
    When I am on the "settingsdemoc2" "core_question > preview" page logged in as teacher
    Then I should see "Try it!"
    And I should not see "Run C1 code"

  Scenario: Teacher overrides the dark theme mode for their course only
    Given I am on the "C1" "Course" page logged in as teacher
    And I navigate to "Filters" in current page administration
    And I click on "Settings" "link" in the "Ace inline" "table_row"
    And I set the field "Set when to use dark theme" to "Always"
    And I press "Save changes"
    When I am on the "settingsdemoc1" "core_question > preview" page logged in as teacher
    Then "//div[contains(concat(' ', normalize-space(@class), ' '), ' ace-tomorrow-night ')]" "xpath_element" should exist
    When I am on the "settingsdemoc2" "core_question > preview" page logged in as teacher
    Then "//div[contains(concat(' ', normalize-space(@class), ' '), ' ace-tomorrow-night ')]" "xpath_element" should not exist

  Scenario: Teacher overrides simplified mode for their course only
    Given I am on the "C1" "Course" page logged in as teacher
    And I navigate to "Filters" in current page administration
    And I click on "Settings" "link" in the "Ace inline" "table_row"
    And I set the field "Simplified mode" to "Enabled"
    And I press "Save changes"
    When I am on the "simplifiedmodedemoc1" "core_question > preview" page logged in as teacher
    Then "//pre[contains(., 'SIMPLIFIEDHIGHLIGHTMARKER')]/following-sibling::div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    When I am on the "simplifiedmodedemoc2" "core_question > preview" page logged in as teacher
    Then "//pre[contains(., 'SIMPLIFIEDHIGHLIGHTMARKER')]/following-sibling::div[contains(@class, 'ace_editor')]" "xpath_element" should not exist

  Scenario: A field left as "Use higher-level setting" keeps inheriting the administrator's setting
    Given I log in as "admin"
    And I visit "/admin/settings.php?section=filtersettingace_inline"
    And I set the field "Button label" to "Site button"
    And I press "Save changes"
    And I log out
    And I am on the "C1" "Course" page logged in as teacher
    And I navigate to "Filters" in current page administration
    And I click on "Settings" "link" in the "Ace inline" "table_row"
    And I set the field "Set when to use dark theme" to "Always"
    And I press "Save changes"
    When I am on the "settingsdemoc1" "core_question > preview" page logged in as teacher
    Then I should see "Site button"

  Scenario: Admin overrides the button label for a whole course category
    Given the following "categories" exist:
      | name        | category | idnumber |
      | Category A  | 0        | CATA     |
    And the following "courses" exist:
      | fullname   | shortname | category |
      | Category Course | CATC | CATA     |
    And the following "course enrolments" exist:
      | user    | course | role           |
      | teacher | CATC   | editingteacher |
    And the following "question categories" exist:
      | contextlevel | reference | name                |
      | Course       | CATC      | Test questions CATC |
    And the following "questions" exist:
      | questioncategory     | qtype       | name             |
      | Test questions CATC  | description | settingsdemocatc |
    And "settingsdemo.txt" exists in question "settingsdemocatc" "questiontext" for filter ace inline
    And I log in as "admin"
    And I am on course index
    And I follow "Category A"
    And I navigate to "Filters" in current page administration
    And I click on "Settings" "link" in the "Ace inline" "table_row"
    And I set the field "Button label" to "Category override"
    And I press "Save changes"
    And I log out
    When I am on the "settingsdemocatc" "core_question > preview" page logged in as teacher
    Then I should see "Category override"

  Scenario: Teacher overrides the button label directly on a quiz's own Filters settings, not just the course
    Given the following "activities" exist:
      | activity | course | name   | idnumber |
      | quiz     | C1     | Quiz 1 | quiz1    |
    And I am on the "Quiz 1" "quiz activity" page logged in as teacher
    And I navigate to "Filters" in current page administration
    And I click on "Settings" "link" in the "Ace inline" "table_row"
    And I set the field "Button label" to "Module override"
    And I press "Save changes"
    And I navigate to "Filters" in current page administration
    And I click on "Settings" "link" in the "Ace inline" "table_row"
    Then the field "Button label" matches value "Module override"
    And I should see "Overriding the higher-level setting"
    # Resetting to blank (button_label's own equivalent of "Use higher-level setting", since
    # it's a text field, not a select) must actually clear the override, not just look cleared.
    When I set the field "Button label" to ""
    And I press "Save changes"
    And I navigate to "Filters" in current page administration
    And I click on "Settings" "link" in the "Ace inline" "table_row"
    Then I should see "Following the higher-level setting"

  Scenario: Teacher resets a "Use higher-level setting" select field back to inheriting
    Given I am on the "C1" "Course" page logged in as teacher
    And I navigate to "Filters" in current page administration
    And I click on "Settings" "link" in the "Ace inline" "table_row"
    And I set the field "Set when to use dark theme" to "Always"
    And I press "Save changes"
    And I am on the "settingsdemoc1" "core_question > preview" page logged in as teacher
    # Confirm the override actually took effect before testing that resetting it removes it -
    # otherwise the second assertion below would trivially pass even if reset did nothing.
    Then "//div[contains(concat(' ', normalize-space(@class), ' '), ' ace-tomorrow-night ')]" "xpath_element" should exist
    When I am on the "C1" "Course" page logged in as teacher
    And I navigate to "Filters" in current page administration
    And I click on "Settings" "link" in the "Ace inline" "table_row"
    And I set the field "Set when to use dark theme" to "Use higher-level setting"
    And I press "Save changes"
    And I am on the "settingsdemoc1" "core_question > preview" page logged in as teacher
    Then "//div[contains(concat(' ', normalize-space(@class), ' '), ' ace-tomorrow-night ')]" "xpath_element" should not exist
