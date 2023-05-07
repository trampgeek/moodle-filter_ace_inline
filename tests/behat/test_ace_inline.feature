@filter @filter_ace_inline @javascript
Feature: Create a demo page of Run it! boxes and test them
  To check the ace_inline filter
  As a teacher
  I must be able to create Run it! boxes and run them

  Background:
    Given the following "users" exist:
      | username | firstname | lastname | email            |
      | teacher1 | Teacher   | 1        | teacher1@asd.com |
    And the following "courses" exist:
      | fullname | shortname | category |
      | Course 1 | C1        | 0        |
    And the following "course enrolments" exist:
      | user     | course | role           |
      | teacher1 | C1     | editingteacher |
    And the following "question categories" exist:
      | contextlevel | reference | name           |
      | Course       | C1        | Test questions |
    And I log in as "teacher1"
    And I am on "Course 1" course homepage

Scenario: Create a Python3 Try it! box and run it
    When I press "Turn editing on"
    And I pause
