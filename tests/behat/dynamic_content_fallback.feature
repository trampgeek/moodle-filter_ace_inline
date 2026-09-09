@filter @filter_ace_inline @javascript
Feature: The whole-document scan fallback still works for dynamically generated content
  In order to let dynamically generated content (e.g. an AJAX response) still be ace-ified
  As a developer using the documented globalThis.applyAceInteractive() hook
  I need applyAceAndBuildUi() to fall back to scanning the whole document when no
  data-ace-inline-scan marker exists, since content added after the page has already
  loaded never goes through text_filter::do_ace_editor() and so is never marked

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
      | questioncategory | qtype       | name                 |
      | Test questions   | description | nonlanguageclassdemo |
    And "nonlanguageclassdemo.txt" exists in question "nonlanguageclassdemo" "questiontext" for filter ace inline
    And I have enabled the sandbox and ace inline filter
    And the following config values are set as admin:
      | simplified_mode | 1 | filter_ace_inline |

  Scenario: A freshly-inserted pre element is ace-ified via the documented hook, with no marked fragment on the page
    When I am on the "nonlanguageclassdemo" "core_question > preview" page logged in as teacher
    # The existing Simplified Mode block on this page queues the AMD module and marks its own
    # fragment - confirms the module is loaded before the step below relies on
    # globalThis.applyAceInteractive() already existing.
    Then I should see "keyword" highlighting on "def" with filter ace inline
    And I insert a fresh ace pre element and call applyAceInteractive for filter ace inline
    # The freshly-inserted element is outside every data-ace-inline-scan fragment on the page
    # (it was appended directly to <body>, never passed through do_ace_editor()) - if the
    # fallback to a whole-document scan were broken, this would stay a plain, visible <pre>.
    And "//pre[contains(., 'FRESHLYINSERTEDMARKER')]" "xpath_element" should not be visible
    And "//pre[contains(., 'FRESHLYINSERTEDMARKER')]/following-sibling::div[contains(concat(' ', normalize-space(@class), ' '), ' ace_editor ')]" "xpath_element" should exist
